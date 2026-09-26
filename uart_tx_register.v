// File: uart_tx_register.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath / serial register
// Version history:
//  v1.0  2026-09-26  Initial UART register implementation,
//                   including documentation and naming convention
//
// Description:
// This register captures the selected serial bit and stores it until the
// next clock edge. The output q is the signal effectively assigned to
// the UART tx line.
//
// Clock domains:
//  - clk: synchronous register clock
module uart_tx_register(
    input clk,
    input d,
    output reg q
);

  // The value presented at input d is sampled on each rising edge and
  // propagated to the output q.
  always @(posedge clk) begin
    q <= d;
  end

endmodule
