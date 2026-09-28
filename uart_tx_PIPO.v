// File: uart_tx_PIPO.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath / input register
//
// Description:
// This register captures the input payload and holds it stable while the
// FSM sequences the UART frame. The stored value is then used by the
// multiplexer and parity calculator.
//
// Clock domains:
//  - clk: synchronous register clock
module uart_tx_PIPO(
    input clk,
    input en,
    input [7:0] data_in,
    output reg [7:0] data_out
);

  always @(posedge clk) begin
    if (en) begin
      data_out <= data_in;
    end 
  end

endmodule