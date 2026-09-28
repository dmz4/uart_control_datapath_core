`timescale 1ns/1ps

module uart_tb;

  localparam CLK_PERIOD = 1000; // Clock period in nanoseconds (1 MHz clock)

  reg clk, start_tx;
  reg [7:0] data_in;

  wire data_tx_rx, done;
  wire [7:0] data_out;
  

  uart_rx_top uart_rx_ins(
    .clk(clk),
    .data_in(data_tx_rx),
    .data_out(data_out),
    .done(done)
  );

  uart_tx_top uart_tx_ins(
    .clk(clk),
    .data_in(data_in),
    .start_tx(start_tx),
    .tx_serial(data_tx_rx)
  );

  initial begin
    $monitor($time, "%b %b %h", start_tx, done, data_out);
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, uart_tb);
    clk = 0;
    start_tx = 0;
    data_in = 8'h0;
    
    #(CLK_PERIOD*3000) $finish;
  end

  initial begin
    #(CLK_PERIOD/2)
    start_tx = 1'b1;
    data_in = 8'hA5;
    #(CLK_PERIOD) 
    start_tx = 1'b0;
    #(CLK_PERIOD*1200)
    data_in = 8'h2C;
    #(CLK_PERIOD/2)
    start_tx = 1'b1;
    #(CLK_PERIOD)
    start_tx = 1'b0;

  end

  always #(CLK_PERIOD/2) clk = ~clk;


endmodule