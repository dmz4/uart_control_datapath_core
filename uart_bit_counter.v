// File: uart_bit_counter.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath / bit-counter
// Version history:
//  v1.0  2026-09-26  Initial UART bit counter implementation,
//                   including documentation and naming convention
//
// Description:
// This module counts the bit index inside the transmitted byte. It
// increments from 0 to 7 and generates a pulse when the last bit has
// been reached. That information is used by the control path to end the
// byte transmission sequence.
//
// Clock domains:
//  - clk: synchronous counter clock
module uart_bit_counter(
    input clk,
    input en,
    output reg [2:0] bit_index,
    output reg tick
);

  // The module is designed to assert tick when the counter reaches the
  // last bit position, which corresponds to the 8th transmitted bit.
  assign tick = (bit_index == 7) ? 1'b1 : 1'b0;

  always @(posedge clk) begin
    if (en) begin
      if (bit_index == 7) begin
        bit_index <= 0;
      end else begin
        bit_index <= bit_index + 1;
      end
    end
  end

endmodule