// File: uart_tx_datapath.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter datapath
//
// Description:
// This module implements the operational path of the UART transmitter.
// It selects the next bit to drive onto the serial line, stores the
// input payload in a temporary register, calculates the parity bit, and
// drives the output signal according to the control FSM.
//
// Functional blocks:
//  - uart_tx_mux: selects the current frame value to serialize
//  - uart_tx_PIPO: captures the input payload for transmission
//  - uart_tx_register: serializes the selected bit to the TX line
//  - uart_baud_tick_gen: emits the baud-rate tick signal
//  - uart_bit_counter: tracks the current transmitted bit position
//  - uart_parity_calculator: generates the parity bit for the frame
module uart_tx_datapath(
    input clk,
    input [7:0] data_in,
    input [1:0] sel_next_bit,
    input bit_counter_en,
    input clear_baud_ticks,
    input clear_bit_counter,
    input reg_input,
    output byte_done,
    output baud_tick,
    output tx_serial
);

  wire next_tx_bit;
  wire [2:0] bit_index;
  wire parity_out;
  wire [7:0] data_in_reg;

  
  uart_tx_mux tx_mux_inst(
    .data_in({parity_out, data_in_reg[bit_index], 1'b1, 1'b0}), // Start bit is 0, stop bit is 1
    .sel(sel_next_bit),
    .data_out(next_tx_bit)
    
  );
  uart_tx_PIPO tx_PIPO_inst(
    .clk(clk),
    .data_in(data_in),
    .en(reg_input),
    .data_out(data_in_reg)
  );                     

  // Serial register: loads the selected bit at each clock edge.
  uart_tx_register tx_register_inst(
    .clk(clk),
    .serial_data_in(next_tx_bit),
    .serial_out(tx_serial)
  );

  // Baud generator: produces the timing tick used to serialize each bit.
  uart_baud_tick_gen baud_tick_gen_inst(
    .clk(clk),
    .baud_rate_sel(1'b1),
    .clear(clear_baud_ticks),
    .tick(baud_tick)
  );

  // Byte counter: advances the bit index. When the byte is complete, it
  // asserts byte_done to inform the control FSM that the transmission has
  // ended.
  uart_bit_counter bit_counter_inst(
    .clk(clk),
    .clear(clear_bit_counter),
    .bit_index(bit_index),
    .byte_done(byte_done),
    .en(bit_counter_en)
  );

  uart_parity_calculator uart_parity_inst(
    .data_in(data_in_reg),
    .parity_out(parity_out)
  );

endmodule

