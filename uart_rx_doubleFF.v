// File: uart_rx_doubleFF.v
// Author: Diego Dominguez
// Hierarchy: UART receiver synchronization stage / double flip-flop
//
// Description:
// This module synchronizes the asynchronous UART input signal to the
// system clock using a two-stage flip-flop chain. The purpose is to
// reduce metastability before the receiver logic samples the signal.
//
// Clock domains:
//  - clk: synchronous sampling clock
module uart_rx_doubleFF(
    input wire clk,
    input wire rx_in,
    output reg rx_out
);

  reg rx_ff1;

  // The input is sampled in two stages to reduce metastability risk.
  always @(posedge clk) begin
    rx_ff1 <= rx_in;
    rx_out <= rx_ff1;
  end

endmodule
