`timescale 1ns / 1ps

module dff (
  input  wire d,
  input  wire clk,
  input  wire rst_n,
  output reg  q
);
  always @(posedge clk) begin
    if (!rst_n) begin
      q <= 0;
    end else begin
      q <= d;
    end
  end
endmodule
