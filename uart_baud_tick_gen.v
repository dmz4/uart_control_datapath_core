// File: uart_baud_tick_gen.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath / baud-rate tick generator
//
// Description:
// This module generates a one-clock pulse at the configured baud rate.
// The counter is compared against the requested countdown value, and
// when the threshold is reached, tick is asserted for one cycle. The
// clear input allows the counter to be reset at the start of a new frame.
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
  wire [7:0] limit;

  assign limit = baud_rate_sel ? 7'd104 : 7'd52; // Selects the baud rate when receptor is working because it needs 2x speed than 9600 bps to get the center of the bits


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
