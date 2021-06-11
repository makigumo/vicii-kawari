`timescale 1ns/1ps

`include "common.vh"

// NOTE: Clock pins must be declared in constr.xdc to match
// selected configuration here.

// Chose one:
//`define USE_INTCLOCK_PAL      // use on-board clock
`define USE_INTCLOCK_NTSC     // use on-board clock
//`define USE_EXTCLOCK_PAL      // use external clock
//`define USE_EXTCLOCK_NTSC    // use external clock


// For the CMod A35t PDIP board.
// This module:
//     1) generates the 4x dot and 4x color clocks
//     2) selects the chip
//     3) generates the reset signal and holds for approx 150ms at startup
module clockgen(
           input src_clock,
           output clk_dot4x,
           output clk_col16x,
           output [1:0] chip
       );

// TODO: Use dynamic clock config module to select the clock
// mult/divide params based on an 'is_pal' input. Also set
// chip based on that.  At the moment, the type still has to
// be hard coded in the bitstream..

`ifdef USE_INTCLOCK_PAL

assign chip = `CHIP6569;

// This isn't the right thing to do here. This causes a couple of
// synthesis warnings.  This is just for the case where we don't
// have an external clock to use so no biggie.
BUFG sysbuf2 (
         .O(src_clockb),
         .I(src_clock)
     );

// Generate the 4x dot clock. See vicii.v for values.
dot4x_12_pal_clockgen dot4x_12_pal_clockgen(
                          .clk_in12mhz(src_clock),    // external 12 Mhz clock
                          .reset(1'b0),
                          .clk_dot4x(clk_dot4x),      // generated 4x dot clock
                          .locked(locked)
                      );

// Generate a 16x color clock. See vicii.v for values.
color16x_12_pal_clockgen color16x_12_pal_clockgen(
                             .clk_in12mhz(src_clockb), // external 12 Mhz clock
                             .reset(1'b0),
                             .clk_col16x(clk_col16x)     // generated 4x col clock
                         );

`endif

`ifdef USE_INTCLOCK_NTSC

assign chip = `CHIP6567R8;

// This isn't the right thing to do here. This causes a couple of
// synthesis warnings.  This is just for the case where we don't
// have an external clock to use so no biggie.
BUFG sysbuf2 (
         .O(src_clockb),
         .I(src_clock)
     );

// Generate the 4x dot clock. See vicii.v for values.
dot4x_12_ntsc_clockgen dot4x_12_ntsc_clockgen(
                           .clk_in12mhz(src_clock),    // external 12 Mhz clock
                           .reset(1'b0),
                           .clk_dot4x(clk_dot4x),      // generated 4x dot clock
                           .locked(locked)
                       );

// Generate a 16x color clock. See vicii.v for values.
color16x_12_ntsc_clockgen color16x_12_ntsc_clockgen(
                              .clk_in12mhz(src_clockb),    // external 12 Mhz clock
                              .reset(1'b0),
                              .clk_col16x(clk_col16x)     // generated 4x col clock
                          );
`endif

// Use an external clock for pal.
`ifdef USE_EXTCLOCK_PAL

assign chip = `CHIP6569;

// Handles both dot4x and col16x
dot4x_17_pal_clockgen dot4x_17_pal_clockgen(
                          .clk_in17mhz(src_clock),
                          .reset(1'b0),
                          .clk_col16x(clk_col16x),
                          .clk_dot4x(clk_dot4x),
                          .locked(locked)
                      );

`endif

// Use an external clock for ntsc.
`ifdef USE_EXTCLOCK_NTSC

assign chip = `CHIP6567R8;

// Handles both dot4x and col16x
dot4x_14_ntsc_clockgen dot4x_14_ntsc_clockgen(
                           .clk_in14mhz(src_clock),
                           .reset(1'b0),
                           .clk_col16x(clk_col16x),
                           .clk_dot4x(clk_dot4x),
                           .locked(locked)
                       );
`endif

endmodule : clockgen
