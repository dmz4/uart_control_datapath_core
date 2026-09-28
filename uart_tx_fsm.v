// File: uart_tx_fsm.v
// Author: Diego Dominguez
// Hierarchy: UART transmitter control path / FSM
//
// Description:
// This module implements the control unit for the UART transmitter.
// It sequences the frame transmission from the idle state to the start,
// payload, parity, and completion phases. The FSM controls the mux
// selection, payload register enable, and bit-counter progression.
//
// Clock domains:
//  - clk: state machine clock
//
// Control behavior:
//  - IDLE: waiting for start_tx
//  - WAIT_TICK: waiting for the baud tick before sending the start bit
//  - SEND_BIT: transmitting the payload bits
//  - PARITY_BIT: transmitting the parity field
//  - BYTE_DONE: finalization state before returning to idle
module uart_tx_fsm(
    input clk,
    input baud_tick,
    input start_tx,
    input byte_done,
    output reg reg_input,
    output reg [1:0]  sel_next_bit,
    output reg bit_counter_en,
    output reg clear_baud_ticks,
    output reg clear_bit_counter
);

  reg [2:0] state = 3'b000;
  reg [2:0] next_state = 3'b000;

  parameter IDLE = 3'b000, WAIT_TICK = 3'b001;
  parameter SEND_BIT = 3'b011, PARITY_BIT = 3'b010, BYTE_DONE = 3'b110;

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
          next_state = PARITY_BIT;
        else
          next_state = SEND_BIT;
      end

      PARITY_BIT : begin
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

  // Output decode. These signals are generated from the current state
  // and enable datapath operations such as bit selection and counter
  // updates.
  always @(*) begin
    
    case (state)
      IDLE: begin
        sel_next_bit = 2'b01; // Select idle bit
        clear_baud_ticks = 1'b1;
        clear_bit_counter = 1'b1;
        bit_counter_en = 1'b0;
        reg_input = 1'b0;
      end

      WAIT_TICK: begin
        clear_baud_ticks = 1'b0;
        sel_next_bit = 2'b00; // Select start bit
        clear_bit_counter = 1'b0;
        bit_counter_en = 1'b0;
        reg_input = 1'b1;
      end

      SEND_BIT: begin
        clear_baud_ticks = 1'b0;
        sel_next_bit = 2'b10; // Select data bit
        clear_bit_counter = 1'b0;
        reg_input = 1'b0;
        if (baud_tick)
          bit_counter_en = 1'b1;
        else
          bit_counter_en = 1'b0;
      end

      PARITY_BIT: begin
        clear_baud_ticks = 1'b0;
        sel_next_bit = 2'b11; // Select parity bit
        clear_bit_counter = 1'b0;
        reg_input = 1'b0;
        bit_counter_en = 1'b0;
      end

      BYTE_DONE: begin
        clear_baud_ticks = 1'b0;
        sel_next_bit = 2'b01; // Select idle bit
        clear_bit_counter = 1'b0;
        reg_input = 1'b0;
        bit_counter_en = 1'b0;
      end

      default: begin
        clear_baud_ticks = 1'b1;
        sel_next_bit = 2'b01; // Select idle bit
        clear_bit_counter = 1'b1;
        reg_input = 1'b0;
        bit_counter_en = 1'b0;
      end
    endcase
  end

endmodule