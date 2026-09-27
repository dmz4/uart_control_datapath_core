// File: uart_tx_fsm.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter control path / FSM
// Version history:
//  v1.0  2026-09-26  Initial UART transmitter FSM implementation,
//                   including documentation and naming convention
//
// Description:
// This module implements the control unit for the UART transmitter.
// It coordinates the transmission sequence through a small state
// machine that waits for a start request, waits for each baud tick,
// enables bit shifting, and returns to idle when the byte is complete.
//
// Clock domains:
//  - clk: state machine clock
//
// Control behavior:
//  - IDLE: waiting for start_tx
//  - WAIT_TICK: waiting for the baud period before sending a bit
//  - SEND_BIT: data transmission and bit counter advance
//  - BYTE_DONE: end-of-byte completion state before returning to idle
module uart_tx_fsm(
    input clk,
    input baud_tick,
    input start_tx,
    input byte_done,
    output reg bit_select_en,
    output reg bit_counter_en,
    output reg idle_high_en,
    output reg clear_baud_ticks
);

  reg [3:0] state = 4'b0000;
  reg [3:0] next_state = 4'b0000;

  parameter IDLE = 4'b0000, WAIT_TICK = 4'b0001;
  parameter SEND_BIT = 4'b0011, BYTE_DONE = 4'b0010;

  // State register update. The next-state value is captured on each
  // rising edge of the clock.
  always @(posedge clk) begin
    state <= next_state;
  end

  // FSM transitions. This block defines the sequential progression of the
  // transmission process.
  always @(*) begin
    case (state)
      IDLE: begin
        if (start_tx)
          next_state = WAIT_TICK;
        else
          next_state = IDLE;
      end

      WAIT_TICK: begin
        if (baud_tick)
          next_state = SEND_BIT;
        else
          next_state = WAIT_TICK;
      end

      SEND_BIT: begin
        if (baud_tick & byte_done)
          next_state = BYTE_DONE;
        else
          next_state = SEND_BIT;
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

  // Output decode. These signals are generated from the current state
  // and enable datapath operations such as bit selection and counter
  // updates.
  always @(*) begin
    bit_counter_en = 1'b0;
    case (state)
      IDLE: begin
        bit_select_en = 1'b0;
        idle_high_en = 1'b1;
        clear_baud_ticks = 1'b1;
      end

      WAIT_TICK: begin
        clear_baud_ticks = 1'b0;
        bit_select_en = 1'b0;
        idle_high_en = 1'b0;
      end

      SEND_BIT: begin
        clear_baud_ticks = 1'b0;
        bit_select_en = 1'b1;
        idle_high_en = 1'b0;
        if (baud_tick)
          bit_counter_en = 1'b1;
        else
          bit_counter_en = 1'b0;
      end

      BYTE_DONE: begin
        clear_baud_ticks = 1'b0;
        bit_select_en = 1'b0;
        idle_high_en = 1'b1;
      end

      default: begin
        clear_baud_ticks = 1'b1;
        bit_select_en = 1'b0;
        idle_high_en = 1'b1;
      end
    endcase
  end

endmodule