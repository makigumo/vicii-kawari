`timescale 1ns/1ps

`include "common.vh"

// Top level module for the CMod A35t PDIP board.
//
// Two clock configurations are supported:
//     1) using the on-board 12Mhz clock
//     2) using external 14.318181 and/or 17.734475 Mhz clocks
//
// System clock:
//     This config uses the on-board 12Mhz clock and uses an MMCM
//     to generate both the 4x dot and 4x color clocks.
//
// External Clocks:
//     This config takes in a 4x color clock signal and uses an MMCM
//     to generate the 4x dot clock and pass through the 4x color
//     clock.
//
// In either case, the 4x color clock is divided by 4 to produce a
// color ref clock for an external composite encoder.  The 4x dot clock
// is divided by 32 to generate the CPU phi clock.
//
// NOTE: The system clock configuration does not produce a suitable
// color clock for PAL composite video.  This is due to there being
// no mult/div possible from a 12Mhz clock to get an accurate color
// clock.  Consequently, colors will 'shimmer'.  For a stable PAL
// composite signal, an external clock must be used. HDMI or VGA
// output options don't require a color clock so the clock gens
// could be modified to accept a 4x dot clock and phi could then
// be derived from that clock.

module top(
           input sys_clock,     // driven by sim
           input clk_col4x,     // driven by sim
           input clk_col16x,    // driven by sim

	   input [1:0] chip,    // chip config pin from MCU
	   input is_15khz,      // freq config pin from MCU
	   input is_hide_raster_lines, // config pin from MCU
	   output tx,
	   //input rx,
	   input cclk,
           output cpu_reset,    // reset for 6510 CPU
           output clk_phi,      // output phi clock for CPU
           output clk_dot4x,    // pixel clock for external HDMI encoder
           output active,       // display active for HDMI
           output hsync,        // hsync signal for VGA/HDMI
           output vsync,        // vsync signal for VGA/HDMI

`ifdef HAVE_COLOR_CLOCKS
           // use_scan_doubler is valid only when HAVE_COLOR_CLOCKS is
           // set. If an external composite encoder is going to be used,
           // use_scan_doubler must be false. If use_scan_doubler is false,
           // RGB values will be driven by the pixel sequencer directly at
           // native resolution (which is what you need for a composite
           // encoder). Otherwise, RGB values will go through the scan doubler
           // suitable for VGA or DVI output. (NOTE: The vga scan doubler may
           // not be configured to double anything. It depends on how
           // it is configured but it is still required for any VGA/DVI
           // output). When HAVE_COLOR_CLOCKS is not set only VGA or DVI
           // output is possible so the scan doubler is always used in that
           // case.
           input use_scan_doubler,

           // If we have a composite encoder, we output two
           // signals to drive it.
`ifdef HAVE_COMPOSITE_ENCODER
           output clk_colref,    // color ref for encoder
           output csync,         // csync for encoder
`endif
           // If we are generating luma/chroma, add outputs
`ifdef GEN_LUMA_CHROMA
           output [5:0] luma,    // luma out
           output [5:0] chroma,  // chroma out
`endif

`endif  // HAVE_COLOR_CLOCKS

           output [5:0] red,    // red out
           output [5:0] green,  // green out
           output [5:0] blue,   // blue out
`ifndef IS_SIMULATOR    
           inout tri [5:0] adl, // address (lower 6 bits)
           output tri [5:0] adh,// address (high 6 bits)
           inout tri [7:0] dbl, // data bus lines (ram/rom)
           input [3:0] dbh,     // data bus lines (color)
`else
           input [5:0] adl,
           output [5:0] adh,
           input [7:0] dbl,
           input [3:0] dbh,
           output [7:0] dbo_sim,
           output [11:0] ado_sim,
`endif
           input ce,            // chip enable (LOW=enable, HIGH=disabled)
           input rw,            // read/write (LOW=write, HIGH=read)
           output irq,          // irq
           input lp,            // light pen
           output aec,          // aec
           output ba,           // ba
           output cas,          // column address strobe
           output ras,          // row address strobe
           output ls245_data_dir  // DIR for data bus transceiver
           //output ls245_data_oe,   // OE for data bus transceiver
           //output ls245_addr_dir,  // DIR for addr bus transceiver
           //output ls245_addr_oe    // OE for addr bus transceiver
       );

wire rst;

wire ls245_data_oe; // not enough pins on cmod_a7, just ground it
wire ls245_addr_dir;  // not enough pins on cmod_a7, use aec
//wire ls245_addr_oe;  // not enough pins on cmod_a7, just ground it

`ifdef HAVE_COMPOSITE_ENCODER
// Divides the color4x clock by 4 to get color reference clock
clk_div4 clk_colorgen (
             .clk_in(clk_col4x),     // from 4x color clock
             .reset(rst),
             .clk_out(clk_colref));  // create color ref clock
`endif

// This is a reset line for the CPU which would have to be
// connected with a jumper.  It holds the CPU in reset
// before the clock is locked.  TODO: Find out if this is
// actually required.
assign cpu_reset = rst;

wire [7:0] dbo;
wire [11:0] ado;

// When these are true, the VIC is writing to the data
// or address bus so ab/db will be assigned from
// ado/dbo respectively.  Otherwise, we tri-state
// those lines and VIC can read from adi/dbi.
// NOTE: The VIC only ever reads the lower 6 bits from
// the address lines. This is the reason for the adl/adh
// split below.
wire vic_write_ab;
wire vic_write_db;

wire[7:0] tx_data_4x;
wire tx_new_data_4x;

// Instantiate the vicii with our clocks and pins.
vicii vic_inst(
          .rst(rst),
          .chip(chip),
	  .tx_data_4x(tx_data_4x),
	  .tx_new_data_4x(tx_new_data_4x),
	  .is_15khz(is_15khz),
	  .is_hide_raster_lines(is_hide_raster_lines),
          .clk_dot4x(clk_dot4x),
          .clk_phi(clk_phi),
	  .active(active),
	  .hsync(hsync),
	  .vsync(vsync),
`ifdef HAVE_COLOR_CLOCKS
	  .use_scan_doubler(use_scan_doubler),
          .clk_col16x(clk_col16x),
`ifdef HAVE_COMPOSITE_ENCODER
	  .csync(csync),
`endif
`ifdef GEN_LUMA_CHROMA
          .luma(luma),
          .chroma(chroma),
`endif
`endif  // HAVE_COLOR_CLOCKS
          .adi(adl[5:0]),
          .ado(ado),
          .dbi({dbh,dbl}),
          .dbo(dbo),
          .ce(ce),
          .rw(rw),
          .aec(aec),
          .irq(irq),
          .lp(lp),
          .ba(ba),
          .cas(cas),
          .ras(ras),
          .ls245_data_dir(ls245_data_dir),
          .ls245_data_oe(ls245_data_oe),
          .ls245_addr_dir(ls245_addr_dir),
          //.ls245_addr_oe(ls245_addr_oe),
          .vic_write_db(vic_write_db),
          .vic_write_ab(vic_write_ab),
	  .red(red),
	  .green(green),
	  .blue(blue)
      );

`ifndef IS_SIMULATOR
// Write to bus condition, else tri state.
assign dbl[7:0] = vic_write_db ? dbo : 8'bz; // CPU reading
assign adl = vic_write_ab ? ado[5:0] : 6'bz; // vic or stollen cycle
assign adh = vic_write_ab ? ado[11:6] : 6'bz;
`else
assign ado_sim = ado;
assign dbo_sim = dbo;
`endif

// NOTE: For the simulator, sys_clock is actually the same as
// our dot4x clock.  But it's just for simulaion purposes to
// check tx is working.
// Propagate tx from 4x domain to sys_clock domain
reg[7:0] tx_data_sys_pre;
reg tx_new_data_sys_pre;
reg[7:0] tx_data_sys;
reg tx_new_data_sys;

always @(posedge sys_clock) tx_data_sys_pre <= tx_data_4x;
always @(posedge sys_clock) tx_data_sys<= tx_data_sys_pre;

always @(posedge sys_clock) tx_new_data_sys_pre <= tx_new_data_4x;
always @(posedge sys_clock) tx_new_data_sys <= tx_new_data_sys_pre;

avr_interface mojo_avr_interface(
    .clk(sys_clock),
    .rst(rst),
    .cclk(cclk),
    .tx(tx),
    //.rx(rx),
    .tx_data(tx_data_sys),
    .new_tx_data(tx_new_data_sys)
    //output [7:0] rx_data,
    //output new_rx_data
  );

endmodule : top
