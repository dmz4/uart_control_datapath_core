// File: uart_bit_counter.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath / bit-counter
//
// Description:
// This module counts the bit index inside the active UART frame. It
// advances while the enable input is asserted and resets when the clear
// signal is driven. The byte_done output marks the end of the frame
// sequence for the control FSM.
//
// Clock domains:
//  - clk: synchronous counter clock
module uart_bit_counter(
    input clk,
    input en,
    input clear,
    output reg [2:0] bit_index,
    output byte_done
);

  // The module is designed to assert byte_done when the counter reaches
  // the last bit position, which corresponds to the 8th transmitted bit.
  assign byte_done = (bit_index == 7) ? 1'b1 : 1'b0;

  always @(posedge clk) begin
    if (clear) begin
      bit_index <= 0;
    end 
    else if (en) begin
      if (bit_index == 7) begin
        bit_index <= 0;
      end else begin
        bit_index <= bit_index + 1;
      end
    end
  end

endmodule