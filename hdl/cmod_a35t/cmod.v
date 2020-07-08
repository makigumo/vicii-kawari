`timescale 1ns/1ps

`include "common.vh"

// NOTE: Clock pins must be declared in constr.xdc to match
// selected configuration here.

// Chose one:
`define USE_SYSCLOCK_PAL      // use on-board clock
//`define USE_SYSCLOCK_NTSC     // use on-board clock
//`define USE_PALCLOCK_PAL      // use external clock
//`define USE_NTSCCLOCK_NTSC    // use external clock


// For the CMod A35t PDIP board.
// This module:
//     1) generates the 4x dot and 4x color clocks
//     2) selects the chip
//     3) generates the reset signal and holds for approx 150ms at startup
module cmod(
           input sys_clock,
           output clk_dot4x,
           output clk_col4x,
           output rst,
           output [1:0] chip
       );

wire sys_clockb;

reg [21:0] rstcntr = 0;
wire internal_rst = !rstcntr[21];

BUFG sysbuf2 (
         .O(sys_clockb),
         .I(sys_clock)
     );

// Keep internel reset high for approx 150ms
always @(posedge sys_clockb)
    if (internal_rst)
        rstcntr <= rstcntr + 4'd1;

`ifdef USE_SYSCLOCK_PAL

assign chip = CHIP6569;

// Generate the 4x dot clock. See vicii.v for values.
dot4x_12_pal_clockgen dot4x_12_pal_clockgen(
                          .clk_in12mhz(sys_clockb),    // external 12 Mhz clock
                          .reset(internal_rst),
                          .clk_dot4x(clk_dot4x),      // generated 4x dot clock
                          .locked(locked)
                      );
// Generate a 4x color clock. See vicii.v for values.
color4x_12_pal_clockgen color4x_12_pal_clockgen(
                            .clk_in12mhz(sys_clockb),    // external 12 Mhz clock
                            .reset(internal_rst),
                            .clk_color4x(clk_col4x)     // generated 4x col clock
                        );
`endif

`ifdef USE_SYSCLOCK_NTSC

assign chip = CHIP6567R8;

// Generate the 4x dot clock. See vicii.v for values.
dot4x_12_ntsc_clockgen dot4x_12_ntsc_clockgen(
                           .clk_in12mhz(sys_clockb),    // external 12 Mhz clock
                           .reset(internal_rst),
                           .clk_dot4x(clk_dot4x),      // generated 4x dot clock
                           .locked(locked)
                       );
// Generate a 4x color clock. See vicii.v for values.
color4x_12_ntsc_clockgen color4x_12_ntsc_clockgen(
                             .clk_in12mhz(sys_clockb),    // external 12 Mhz clock
                             .reset(internal_rst),
                             .clk_color4x(clk_col4x)     // generated 4x col clock
                         );
`endif

// Use an external clock for pal.
`ifdef USE_PALCLOCK_PAL
assign chip = CHIP6569;
dot4x_17_pal_clockgen dot4x_17_pal_clockgen(
                          .clk_in17mhz(sys_clockb),
                          .reset(internal_rst),
                          .clk_col4x(clk_col4x),
                          .clk_dot4x(clk_dot4x),
                          .locked(locked)
                      );
`endif

// Use an external clock for ntsc.
`ifdef USE_NTSCCLOCK_NTSC
assign chip = CHIP6567R8;
dot4x_14_ntsc_clockgen dot4x_14_ntsc_clockgen(
                           .clk_in14mhz(sys_clockb),
                           .reset(internal_rst),
                           .clk_col4x(clk_col4x),
                           .clk_dot4x(clk_dot4x),
                           .locked(locked)
                       );
`endif

assign rst = !locked;

endmodule : cmod
