// File: uart_parity_calculator.v
// Author: Diego Dominguez
// Hierarchy: UART datapath / parity generation
//
// Description:
// This module computes the parity bit associated with the current byte.
// The implementation uses an XOR reduction so that the parity bit is
// generated without requiring a separate counter or state machine.
//
// Clock domains:
//  - none: purely combinational logic
module uart_parity_calculator(
    input [7:0] data_in,
    output reg parity_out
);

  // The parity_out signal is computed as the XOR of all bits in data_in.
  always @(*) begin
    parity_out = ^data_in;
  end

endmodule