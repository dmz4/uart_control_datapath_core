// File: uart_rx_top.v
// Author: Diego Dominguez
// Hierarchy: Top-level UART receiver module
// Version history:
//  v1.0  2026-09-26  Initial UART receiver RTL implementation,
//                   including documentation and naming convention
//
// Description:
// This module instantiates the receiver control path and datapath.
// It receives an incoming serial bit stream, synchronizes it, samples
// the bits according to the baud generator, and reconstructs the 8-bit
// output word.
//
// Clock domains:
//  - clk: system clock used by both the receiver FSM and datapath
//
// Critical timing:
//  - data_out is updated only on clock edges, therefore all control
//    signals must be stable before the active clock transition.
module uart_rx_top(
    input clk,
    input data_in,
    output [7:0] data_out
);

  wire start_bit, baud_tick, byte_done;
  wire baud_rate_sel, bit_counter_en, shift_reg_en, clear_baud_ticks;

  // Control path: detects the start bit and schedules bit sampling.
  uart_rx_fsm fsm_inst(
    .clk(clk),
    .start_bit(start_bit),
    .baud_tick(baud_tick),
    .byte_done(byte_done),
    .baud_rate_sel(baud_rate_sel),
    .bit_counter_en(bit_counter_en),
    .shift_reg_en(shift_reg_en),
    .clear_baud_ticks(clear_baud_ticks)
  );

  // Datapath: synchronizes, shifts, and reconstructs the received byte.
  uart_rx_datapath datapath_inst(
    .clk(clk),
    .rx_serial_in(data_in),
    .baud_rate_sel(baud_rate_sel),
    .bit_counter_en(bit_counter_en),
    .shift_reg_en(shift_reg_en),
    .start_bit(start_bit),
    .baud_tick(baud_tick),
    .byte_done(byte_done),
    .data_out(data_out),
    .clear_baud_ticks(clear_baud_ticks)
  );

endmodule