// File: uart_baud_tick_gen.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath / baud-rate tick generator
// Version history:
//  v1.0  2026-09-26  Initial UART baud tick generator implementation,
//                   including documentation and naming convention
//
// Description:
// This module generates a one-clock pulse at the configured baud rate.
// The counter is compared against the requested countdown value, and
// when the threshold is reached, baud_tick is asserted for one cycle.
//
// Clock domains:
//  - clk: system clock used for baud generation
module uart_baud_tick_gen(
    input clk,
    input baud_rate_sel,
    input clear,
    output reg tick
);

  integer counter;
  integer limit;

  assign limit = baud_rate_sel ? 104 : 52;
  // Selects the baud rate based on the baud_rate_sel input.

  // The counter is reset and a pulse is generated when the baud-period
  // limit has been reached. This approximates a UART bit-period timer.
  always @(posedge clk) begin
    if (clear) begin
      counter <= 0;
      tick <= 0;
    end
    else if(counter == limit) begin
      counter <= 0;
      tick <= 1;
    end else begin
      counter <= counter + 1;
      tick <= 0;
    end
  end

endmodule
