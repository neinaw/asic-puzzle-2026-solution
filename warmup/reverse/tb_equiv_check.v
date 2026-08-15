`timescale 1ns / 1ps

module gold_wrap (
  input  clk,
  input  rst_n,
  input  en,
  input  A,
  input  B,
  output S
);
  adder_demo gold (
      .clk(clk),
      .rst_n(rst_n),
      .en(en),
      .A(A),
      .B(B),
      .S(S)
  );
endmodule

module gate_wrap (
  input  clk,
  input  rst_n,
  input  en,
  input  A,
  input  B,
  output S
);
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
  extracted u_gate (
      .clk(clk),
      .rst_n(rst_n),
      .en(en),
      .A(A),
      .B(B),
      .S(S),
      .VPWR(VPWR),
      .VGND(VGND)
  );
endmodule

module tb;
  reg clk = 0;
  reg rst_n;
  reg en;
  reg A;
  reg B;
  wire S_gold, S_gate;

  gold_wrap g0 (
      .clk(clk),
      .rst_n(rst_n),
      .en(en),
      .A(A),
      .B(B),
      .S(S_gold)
  );
  gate_wrap g1 (
      .clk(clk),
      .rst_n(rst_n),
      .en(en),
      .A(A),
      .B(B),
      .S(S_gate)
  );

  always #5 clk = ~clk;

  integer i;
  integer mismatches = 0;

  initial begin
    rst_n = 0;
    en = 0;
    A = 0;
    B = 0;
    repeat (4) @(posedge clk);
    rst_n = 1;

    for (i = 0; i < 4000; i = i + 1) begin
      @(negedge clk);
      en = $random % 2;
      A  = $random % 2;
      B  = $random % 2;
      // occasionally toggle reset to exercise rst_n path too
      if ((i % 137) == 0) begin
        rst_n = 0;
      end else begin
        rst_n = 1;
      end
      @(posedge clk);
      #1;
      if (S_gold !== S_gate) begin
        mismatches = mismatches + 1;
        if (mismatches < 20)
          $display(
              "MISMATCH at cycle %0d: S_gold=%b S_gate=%b (rst_n=%b en=%b A=%b B=%b)",
              i,
              S_gold,
              S_gate,
              rst_n,
              en,
              A,
              B
          );
      end
    end

    $display("checks=%0d mismatches=%0d", i, mismatches);
    if (mismatches == 0) $display("EQUIV_OK");
    else $display("EQUIV_FAIL");
    $finish;
  end
endmodule
