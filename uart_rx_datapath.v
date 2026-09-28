// File: uart_rx_datapath.v
// Author: Diego Dominguez
// Hierarchy: UART receiver datapath
//
// Description:
// This module assembles the receiver datapath. It synchronizes the
// incoming serial signal, shifts the data bits into the receive
// register, generates the baud-rate tick, counts the received bits, and
// evaluates the parity-related flow for the current frame.
//
// Functional blocks:
//  - uart_rx_doubleFF: synchronizes the external RX line to the clock
//  - uart_rx_register: shifts the sampled bit stream into the output byte
//  - uart_baud_tick_gen: creates the timing pulse used for sampling
//  - uart_bit_counter: tracks the bit position inside the received byte
//  - uart_parity_calculator: computes parity from the received payload
module uart_rx_datapath(
    input clk,
    input rx_serial_in,
    input baud_rate_sel,
    input bit_counter_en,
    input shift_reg_en,
    input clear_baud_ticks,
    input clear_bit_counter,
    output start_bit,
    output parity_bit,
    output baud_tick,
    output byte_done,
    output [7:0] data_out
);

  wire [2:0] bit_index;

  // Synchronization stage: removes metastability from the external RX line.
  uart_rx_doubleFF double_ff_inst(
    .clk(clk),
    .rx_in(rx_serial_in),
    .rx_out(start_bit)
  );

  // Shift register: captures the serial data stream and assembles the byte.
  uart_rx_register rx_register_inst(
    .clk(clk),
    .en(shift_reg_en),
    .shift_data_in(rx_serial_in),
    .shift_reg_q(data_out)
  );

  // Baud generator: produces the sampling tick for each RX bit interval.
  uart_baud_tick_gen baud_tick_gen_inst(
    .clk(clk),
    .baud_rate_sel(baud_rate_sel),
    .clear(clear_baud_ticks),
    .tick(baud_tick)
  );

  // Bit counter: advances the receive index and marks the end of a byte.
  uart_bit_counter bit_counter_inst(
    .clk(clk),
    .clear(clear_bit_counter),
    .bit_index(bit_index),
    .byte_done(byte_done),
    .en(bit_counter_en)
  );

  uart_parity_calculator parity_calc_inst(
    .data_in(data_out),
    .parity_out(parity_bit)
  );

endmodule
