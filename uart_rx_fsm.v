// File: uart_rx_fsm.v
// Author: Diego Dominguez
// Hierarchy: UART receiver control path / FSM
//
// Description:
// This module controls the receive sequence. It waits for a start bit,
// enables the sampling tick, shifts each received bit into the register,
// processes the parity phase, and returns to idle after the byte is
// complete.
//
// Control behavior:
//  - IDLE: waiting for the start bit
//  - WAIT_TICK: waiting for the baud tick before sampling
//  - REC_BIT: receiving one bit and advancing the bit counter
//  - PARITY_BIT: handling the parity field
//  - BYTE_DONE: end-of-byte state before returning to idle
module uart_rx_fsm(
    input clk,
    input start_bit,
    input baud_tick,
    input byte_done,
    output reg baud_rate_sel,
    output reg bit_counter_en,
    output reg shift_reg_en,
    output reg clear_baud_ticks,
    output reg done,
    output reg clear_bit_counter
);

  reg [2:0] state = 4'b000;
  reg [2:0] next_state = 4'b000;

  parameter IDLE = 4'b000, WAIT_TICK = 4'b001;
  parameter REC_BIT = 4'b011, PARITY_BIT = 4'b010, BYTE_DONE = 4'b110;

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
          next_state = PARITY_BIT;
        else
          next_state = REC_BIT;
      end

      PARITY_BIT: begin
        if (baud_tick)
          next_state = BYTE_DONE;
        else
          next_state = PARITY_BIT;
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
        baud_rate_sel = 1'b0; // baud rate 19200
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b0;
        clear_baud_ticks = 1'b1;
        clear_bit_counter = 1'b1;
        done = 0;
      end

      WAIT_TICK: begin
        baud_rate_sel = 1'b0; // baud rate 19200
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b1;
        clear_baud_ticks = 1'b0;
        clear_bit_counter = 1'b0;
        done = 0;
      end

      REC_BIT: begin
        baud_rate_sel = 1'b1; // baud rate 9600
        done = 0;
        clear_bit_counter = 1'b0;
        clear_baud_ticks = 1'b0;
        if (baud_tick) begin
            bit_counter_en = 1'b1;
            shift_reg_en = 1'b1;
          end
        else begin
            bit_counter_en = 1'b0;
            shift_reg_en = 1'b0;
        end
      end

      PARITY_BIT: begin
        baud_rate_sel = 1'b1; // baud rate 9600
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b0;
        clear_baud_ticks = 1'b0;
        clear_bit_counter = 1'b0;
        done = 0;
      end

      BYTE_DONE: begin
        baud_rate_sel = 1'b1; // baud rate 9600
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b0;
        clear_baud_ticks = 1'b0;
        clear_bit_counter = 1'b0;
        done = 1;
      end

      default: begin
        baud_rate_sel = 1'b0; // baud rate 19200
        bit_counter_en = 1'b0;
        shift_reg_en = 1'b0;
        clear_baud_ticks = 1'b1;
        clear_bit_counter = 1'b1;
        done = 0;
      end
    endcase
  end

endmodule