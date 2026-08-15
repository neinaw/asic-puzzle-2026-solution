`timescale 1ns / 1ps

module inverter (
  input  wire in,
  output wire out
);
  assign out = ~in;
endmodule
