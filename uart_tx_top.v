// File: uart_tx_top.v
// Author: Diego Dominguez
// Hierarchy: Top-level UART transmitter module
//
// Description:
// This module instantiates the UART transmitter control path and
// datapath. Its purpose is to serialize an 8-bit input word into a
// complete serial frame, including the start, payload, parity, and idle
// phases defined by the FSM and the timing generator.
//
// Clock domains:
//  - clk: system clock used by the transmitter FSM and datapath
//
// Critical timing:
//  - tx_serial changes only on the clock edge, therefore all control
//    signals must be stable before the active edge of clk.
module uart_tx_top(
    input clk,
    input [7:0] data_in,
    input start_tx,
    output tx_serial
);

  wire bit_select_en;
  wire bit_counter_en;
  wire idle_high_en;
  wire baud_tick;
  wire clear_baud_ticks;
  wire clear_bit_counter;
  wire byte_done;
  wire reg_input;
  wire [1:0] sel_next_bit;

  // Control path: it decides when the module is idle, when it must
  // transmit a bit, and when the byte has been completed.
  uart_tx_fsm fsm_inst(
    .clk(clk),
    .start_tx(start_tx),
    .baud_tick(baud_tick),
    .byte_done(byte_done),
    .sel_next_bit(sel_next_bit),
    .bit_counter_en(bit_counter_en),
    .clear_baud_ticks(clear_baud_ticks),
    .clear_bit_counter(clear_bit_counter),
    .reg_input(reg_input)
  );

  // Datapath: it selects the bit to send, increments the bit counter,
  // and drives the serial output tx_serial.
  uart_tx_datapath datapath_inst(
    .clk(clk),
    .data_in(data_in),
    .sel_next_bit(sel_next_bit),
    .bit_counter_en(bit_counter_en),
    .byte_done(byte_done),
    .baud_tick(baud_tick),
    .tx_serial(tx_serial),
    .clear_baud_ticks(clear_baud_ticks),
    .clear_bit_counter(clear_bit_counter),
    .reg_input(reg_input)
  );

endmodule