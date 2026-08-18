module puzzle_wrapper(
  input clk,
  input rst_n,
  input enable,
  input I,
  output success,
  output [7:0] O
);
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
  puzzle dut(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .I(I),
    .success(success),
    .\O[0] (O[0]),
    .\O[1] (O[1]),
    .\O[2] (O[2]),
    .\O[3] (O[3]),
    .\O[4] (O[4]),
    .\O[5] (O[5]),
    .\O[6] (O[6]),
    .\O[7] (O[7]),
    .VPWR(VPWR),
    .VGND(VGND)
  );
endmodule
