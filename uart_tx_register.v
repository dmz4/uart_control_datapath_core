// File: uart_tx_register.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath / serial register
//
// Description:
// This register captures the selected serial bit and stores it until the
// next clock edge. The output serial_out is the signal effectively
// assigned to the UART TX line.
//
// Clock domains:
//  - clk: synchronous register clock
module uart_tx_register(
    input clk,
    input serial_data_in,
    output reg serial_out
);

  // The value presented at input serial_data_in is sampled on each rising
  // edge and propagated to the output serial_out.
  always @(posedge clk) begin
    serial_out <= serial_data_in;
  end

endmodule
