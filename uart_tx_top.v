// File: uart_tx_top.v
// Author: Diego Dominguez
// Hierarchy: Top-level UART transmitter module
// Version history:
//  v1.0  2026-09-26  Initial UART transmitter RTL implementation,
//                   including documentation and naming convention
//
// Description:
// This module instantiates the UART transmitter control path and
// datapath. Its purpose is to serialize an 8-bit input word into a
// continuous serial stream on tx_serial, following the timing provided
// by the baud-rate generator.
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
    output reg tx_serial
);

  wire bit_select_en;
  wire bit_counter_en;
  wire idle_high_en;
  wire baud_tick;
  wire clear_baud_ticks;
  wire byte_done;

  // Control path: it decides when the module is idle, when it must
  // transmit a bit, and when the byte has been completed.
  uart_tx_fsm fsm_inst(
    .clk(clk),
    .start_tx(start_tx),
    .baud_tick(baud_tick),
    .byte_done(byte_done),
    .bit_select_en(bit_select_en),
    .bit_counter_en(bit_counter_en),
    .idle_high_en(idle_high_en),
    .clear_baud_ticks(clear_baud_ticks)
  );

  // Datapath: it selects the bit to send, increments the bit counter,
  // and drives the serial output tx_serial.
  uart_tx_datapath datapath_inst(
    .clk(clk),
    .data_in(data_in),
    .bit_select_en(bit_select_en),
    .bit_counter_en(bit_counter_en),
    .idle_high_en(idle_high_en),
    .byte_done(byte_done),
    .baud_tick(baud_tick),
    .tx_serial(tx_serial),
    .clear_baud_ticks(clear_baud_ticks)
  );

endmodule