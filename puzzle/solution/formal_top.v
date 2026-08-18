module formal_top (
  input clk,
  input rst_n,
  input I
);
  wire success;
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
  // shrinks the search space considerably
  wire enable = 1'b1;

  puzzle dut (
      .clk(clk),
      .rst_n(rst_n),
      .enable(enable),
      .I(I),
      .success(success),
      .VPWR(VPWR),
      .VGND(VGND)
      // O[7:0] deliberately left unconnected: irrelevant to `success`,
      // and leaving it floating lets `opt -full; clean` delete the whole
      // output-generator cone so the solver only has to reason about the
      // logic that actually feeds `success`.
  );

  reg [1:0] rst_count = 0;
  always @(posedge clk) begin
    if (rst_count < 2) rst_count <= rst_count + 1;

    if (rst_count < 2) begin
      assume (rst_n == 0);
    end else begin
      assume (rst_n == 1);
    end

    cover (success);
  end
endmodule
