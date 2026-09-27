// File: uart_rx_register.v
// Author: Diego Dominguez
// Hierarchy: UART receiver datapath / shift register
// Version history:
//  v1.0  2026-09-26  Initial UART receive shift register implementation,
//                   including documentation and naming convention
//
// Description:
// This register shifts the incoming serial bits into the receive byte.
// Each sampled bit is inserted at the MSB side and the previous data is
// shifted toward the LSB side, effectively assembling the full word.
//
// Clock domains:
//  - clk: synchronous sampling clock
module uart_rx_register(
    input clk,
    input en,
    input shift_data_in,
    output reg [7:0] shift_reg_q
);

  // On every rising edge, the incoming bit is captured and the existing
  // byte is shifted to make room for the next sample.
  always @(posedge clk) begin
    if (en)
      shift_reg_q <= {shift_data_in, shift_reg_q[7:1]};
  end

endmodule
