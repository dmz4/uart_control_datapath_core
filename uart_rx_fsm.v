// File: uart_rx_fsm.v
// Author: Diego Dominguez
// Hierarchy: UART receiver control path / FSM
// Version history:
//  v1.0  2026-09-26  Initial UART receiver FSM implementation,
//                   including documentation and naming convention
//
// Description:
// This module controls the receive sequence. It waits for a start bit,
// enables the sampling tick, shifts each received bit into the register,
// and returns to idle after the byte is complete.
//
// Control behavior:
//  - IDLE: waiting for the start bit
//  - WAIT_TICK: waiting for the baud tick before sampling
//  - REC_BIT: receiving one bit and advancing the bit counter
//  - BYTE_DONE: end-of-byte state before returning to idle
module uart_rx_fsm(
    input clk,
    input start_bit,
    input baud_tick,
    input byte_done,
    output reg baud_rate_sel,
    output reg bit_counter_en,
    output reg shift_reg_en,
    output reg clear_baud_ticks
);

  reg [3:0] state = 4'b0000;
  reg [3:0] next_state = 4'b0000;

  parameter IDLE = 4'b0000, WAIT_TICK = 4'b0001;
  parameter REC_BIT = 4'b0011, BYTE_DONE = 4'b0010;

  // State register update. The FSM advances on each rising edge.
  always @(posedge clk) begin
    state <= next_state;
  end

  // Transition logic: defines the sequential order of the receive process.
  always @(*) begin
    case (state)
      IDLE: begin
        if (~start_bit)
          next_state = WAIT_TICK;
        else
          next_state = IDLE;
      end

      WAIT_TICK: begin
        if (baud_tick)
          next_state = REC_BIT;
        else
          next_state = WAIT_TICK;
      end

      REC_BIT: begin
        if (baud_tick & byte_done)
          next_state = BYTE_DONE;
        else
          next_state = REC_BIT;
      end

      BYTE_DONE: begin
        if (baud_tick)
          next_state = IDLE;
        else
          next_state = BYTE_DONE;
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

  // Output decode: drives the datapath control signals for each state.
  always @(*) begin
    case (state)
      IDLE: begin
        baud_rate_sel = 1'b0; // baud rate 4800
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b0;
        clear_baud_ticks = 1'b1;
      end

      WAIT_TICK: begin
        baud_rate_sel = 1'b0; // baud rate 4800
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b1;
        clear_baud_ticks = 1'b0;
      end

      REC_BIT: begin
        baud_rate_sel = 1'b1; // baud rate 9600
        shift_reg_en = 1'b1;
        clear_baud_ticks = 1'b0;
        if (baud_tick)
          bit_counter_en = 1'b1;
        else
          bit_counter_en = 1'b0;
      end

      BYTE_DONE: begin
        baud_rate_sel = 1'b1; // baud rate 9600
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b0;
        clear_baud_ticks = 1'b0;
      end

      default: begin
        baud_rate_sel = 1'b0; // baud rate 4800
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b0;
        clear_baud_ticks = 1'b1;
      end
    endcase
  end

endmodule