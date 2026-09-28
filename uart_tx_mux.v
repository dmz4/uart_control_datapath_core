// File: uart_tx_mux.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath / output selector
//
// Description:
// This module selects the active UART frame value to drive onto the
// serial output. The selected source depends on the FSM state and may be
// idle, start, data, or parity.
//
// Clock domains:
//  - none: purely combinational selection logic
module uart_tx_mux(
    input [3:0] data_in,
    input [1:0] sel,
    output reg data_out
);

  always @(*) begin
    case(sel)
      2'b00: data_out = data_in[0];
      2'b01: data_out = data_in[1];
      2'b10: data_out = data_in[2];
      2'b11: data_out = data_in[3];
      default: data_out = 1'b0; 
      endcase
  end
endmodule