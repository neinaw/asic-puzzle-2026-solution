`default_nettype wire
module sky130_fd_sc_hd__a2111oi_2 (
  A1,
  A2,
  B1,
  C1,
  D1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input C1;
  input D1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !B1 & !C1 & !D1) | (!A2 & !B1 & !C1 & !D1);
endmodule

module sky130_fd_sc_hd__a211o_2 (
  A1,
  A2,
  B1,
  C1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input C1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & A2) | (B1) | (C1);
endmodule

module sky130_fd_sc_hd__a211oi_2 (
  A1,
  A2,
  B1,
  C1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input C1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !B1 & !C1) | (!A2 & !B1 & !C1);
endmodule

module sky130_fd_sc_hd__a21bo_2 (
  A1,
  A2,
  B1_N,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1_N;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & A2) | (!B1_N);
endmodule

module sky130_fd_sc_hd__a21boi_2 (
  A1,
  A2,
  B1_N,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1_N;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & B1_N) | (!A2 & B1_N);
endmodule

module sky130_fd_sc_hd__a21o_2 (
  A1,
  A2,
  B1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & A2) | (B1);
endmodule

module sky130_fd_sc_hd__a21oi_2 (
  A1,
  A2,
  B1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !B1) | (!A2 & !B1);
endmodule

module sky130_fd_sc_hd__a221o_2 (
  A1,
  A2,
  B1,
  B2,
  C1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  output X;
  input VPWR;
  input VGND;
  assign X = (B1 & B2) | (A1 & A2) | (C1);
endmodule

module sky130_fd_sc_hd__a221oi_2 (
  A1,
  A2,
  B1,
  B2,
  C1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !B1 & !C1) | (!A1 & !B2 & !C1) | (!A2 & !B1 & !C1) | (!A2 & !B2 & !C1);
endmodule

module sky130_fd_sc_hd__a22o_2 (
  A1,
  A2,
  B1,
  B2,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input B2;
  output X;
  input VPWR;
  input VGND;
  assign X = (B1 & B2) | (A1 & A2);
endmodule

module sky130_fd_sc_hd__a22oi_2 (
  A1,
  A2,
  B1,
  B2,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input B2;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !B1) | (!A1 & !B2) | (!A2 & !B1) | (!A2 & !B2);
endmodule

module sky130_fd_sc_hd__a311o_2 (
  A1,
  A2,
  A3,
  B1,
  C1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  input C1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & A2 & A3) | (B1) | (C1);
endmodule

module sky130_fd_sc_hd__a31o_2 (
  A1,
  A2,
  A3,
  B1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & A2 & A3) | (B1);
endmodule

module sky130_fd_sc_hd__a31oi_2 (
  A1,
  A2,
  A3,
  B1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !B1) | (!A2 & !B1) | (!A3 & !B1);
endmodule

module sky130_fd_sc_hd__a32o_2 (
  A1,
  A2,
  A3,
  B1,
  B2,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  input B2;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & A2 & A3) | (B1 & B2);
endmodule

module sky130_fd_sc_hd__a41oi_2 (
  A1,
  A2,
  A3,
  A4,
  B1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input A4;
  input B1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !B1) | (!A2 & !B1) | (!A3 & !B1) | (!A4 & !B1);
endmodule

module sky130_fd_sc_hd__and2_2 (
  A,
  B,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  output X;
  input VPWR;
  input VGND;
  assign X = (A & B);
endmodule

module sky130_fd_sc_hd__and2b_2 (
  A_N,
  B,
  X,
  VPWR,
  VGND
);
  input A_N;
  input B;
  output X;
  input VPWR;
  input VGND;
  assign X = (!A_N & B);
endmodule

module sky130_fd_sc_hd__and3_2 (
  A,
  B,
  C,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  output X;
  input VPWR;
  input VGND;
  assign X = (A & B & C);
endmodule

module sky130_fd_sc_hd__and3b_2 (
  A_N,
  B,
  C,
  X,
  VPWR,
  VGND
);
  input A_N;
  input B;
  input C;
  output X;
  input VPWR;
  input VGND;
  assign X = (!A_N & B & C);
endmodule

module sky130_fd_sc_hd__and4_2 (
  A,
  B,
  C,
  D,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  input D;
  output X;
  input VPWR;
  input VGND;
  assign X = (A & B & C & D);
endmodule

module sky130_fd_sc_hd__and4b_2 (
  A_N,
  B,
  C,
  D,
  X,
  VPWR,
  VGND
);
  input A_N;
  input B;
  input C;
  input D;
  output X;
  input VPWR;
  input VGND;
  assign X = (!A_N & B & C & D);
endmodule

module sky130_fd_sc_hd__and4bb_2 (
  A_N,
  B_N,
  C,
  D,
  X,
  VPWR,
  VGND
);
  input A_N;
  input B_N;
  input C;
  input D;
  output X;
  input VPWR;
  input VGND;
  assign X = (!A_N & !B_N & C & D);
endmodule

module sky130_fd_sc_hd__conb_1 (
  HI,
  LO,
  VPWR,
  VGND
);
  output HI;
  output LO;
  input VPWR;
  input VGND;
  assign HI = 1;
  assign LO = 0;
endmodule

module sky130_fd_sc_hd__dfrtp_2 (
  CLK,
  D,
  Q,
  RESET_B,
  VPWR,
  VGND
);
  input CLK;
  input D;
  output reg Q;
  input RESET_B;
  input VPWR;
  input VGND;
  always @(posedge CLK or negedge RESET_B)
    if (!RESET_B) Q <= 1'b0;
    else begin
      Q <= D;
    end
endmodule

module sky130_fd_sc_hd__dfstp_2 (
  CLK,
  D,
  Q,
  SET_B,
  VPWR,
  VGND
);
  input CLK;
  input D;
  output reg Q;
  input SET_B;
  input VPWR;
  input VGND;
  always @(posedge CLK or negedge SET_B)
    if (!SET_B) Q <= 1'b1;
    else begin
      Q <= D;
    end
endmodule

module sky130_fd_sc_hd__dfxtp_2 (
  CLK,
  D,
  Q,
  VPWR,
  VGND
);
  input CLK;
  input D;
  output reg Q;
  input VPWR;
  input VGND;
  initial Q = 1'b0;
  always @(posedge CLK) begin
    Q <= D;
  end
endmodule

module sky130_fd_sc_hd__inv_2 (
  A,
  Y,
  VPWR,
  VGND
);
  input A;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A);
endmodule

module sky130_fd_sc_hd__mux2_1 (
  A0,
  A1,
  S,
  X,
  VPWR,
  VGND
);
  input A0;
  input A1;
  input S;
  output X;
  input VPWR;
  input VGND;
  assign X = (A0 & !S) | (A1 & S);
endmodule

module sky130_fd_sc_hd__nand2_2 (
  A,
  B,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A) | (!B);
endmodule

module sky130_fd_sc_hd__nand2b_2 (
  A_N,
  B,
  Y,
  VPWR,
  VGND
);
  input A_N;
  input B;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (A_N) | (!B);
endmodule

module sky130_fd_sc_hd__nand3_2 (
  A,
  B,
  C,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A) | (!B) | (!C);
endmodule

module sky130_fd_sc_hd__nand3b_2 (
  A_N,
  B,
  C,
  Y,
  VPWR,
  VGND
);
  input A_N;
  input B;
  input C;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (A_N) | (!B) | (!C);
endmodule

module sky130_fd_sc_hd__nand4_2 (
  A,
  B,
  C,
  D,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  input D;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A) | (!B) | (!C) | (!D);
endmodule

module sky130_fd_sc_hd__nor2_2 (
  A,
  B,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A & !B);
endmodule

module sky130_fd_sc_hd__nor3_2 (
  A,
  B,
  C,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A & !B & !C);
endmodule

module sky130_fd_sc_hd__nor3b_2 (
  A,
  B,
  C_N,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  input C_N;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A & !B & C_N);
endmodule

module sky130_fd_sc_hd__nor4_2 (
  A,
  B,
  C,
  D,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  input D;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A & !B & !C & !D);
endmodule

module sky130_fd_sc_hd__nor4b_2 (
  A,
  B,
  C,
  D_N,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  input D_N;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A & !B & !C & D_N);
endmodule

module sky130_fd_sc_hd__o211a_2 (
  A1,
  A2,
  B1,
  C1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input C1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & B1 & C1) | (A2 & B1 & C1);
endmodule

module sky130_fd_sc_hd__o211ai_2 (
  A1,
  A2,
  B1,
  C1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input C1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !A2) | (!B1) | (!C1);
endmodule

module sky130_fd_sc_hd__o21a_2 (
  A1,
  A2,
  B1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & B1) | (A2 & B1);
endmodule

module sky130_fd_sc_hd__o21ai_2 (
  A1,
  A2,
  B1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !A2) | (!B1);
endmodule

module sky130_fd_sc_hd__o21ba_2 (
  A1,
  A2,
  B1_N,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1_N;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & !B1_N) | (A2 & !B1_N);
endmodule

module sky130_fd_sc_hd__o21bai_2 (
  A1,
  A2,
  B1_N,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1_N;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !A2) | (B1_N);
endmodule

module sky130_fd_sc_hd__o221a_2 (
  A1,
  A2,
  B1,
  B2,
  C1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & B1 & C1) | (A2 & B1 & C1) | (A1 & B2 & C1) | (A2 & B2 & C1);
endmodule

module sky130_fd_sc_hd__o22a_2 (
  A1,
  A2,
  B1,
  B2,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input B2;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & B1) | (A2 & B1) | (A1 & B2) | (A2 & B2);
endmodule

module sky130_fd_sc_hd__o22ai_2 (
  A1,
  A2,
  B1,
  B2,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input B1;
  input B2;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!B1 & !B2) | (!A1 & !A2);
endmodule

module sky130_fd_sc_hd__o2bb2a_2 (
  A1_N,
  A2_N,
  B1,
  B2,
  X,
  VPWR,
  VGND
);
  input A1_N;
  input A2_N;
  input B1;
  input B2;
  output X;
  input VPWR;
  input VGND;
  assign X = (!A1_N & B1) | (!A2_N & B1) | (!A1_N & B2) | (!A2_N & B2);
endmodule

module sky130_fd_sc_hd__o311a_2 (
  A1,
  A2,
  A3,
  B1,
  C1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  input C1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & B1 & C1) | (A2 & B1 & C1) | (A3 & B1 & C1);
endmodule

module sky130_fd_sc_hd__o31a_2 (
  A1,
  A2,
  A3,
  B1,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & B1) | (A2 & B1) | (A3 & B1);
endmodule

module sky130_fd_sc_hd__o31ai_2 (
  A1,
  A2,
  A3,
  B1,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !A2 & !A3) | (!B1);
endmodule

module sky130_fd_sc_hd__o32a_2 (
  A1,
  A2,
  A3,
  B1,
  B2,
  X,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  input B2;
  output X;
  input VPWR;
  input VGND;
  assign X = (A1 & B1) | (A1 & B2) | (A2 & B1) | (A3 & B1) | (A2 & B2) | (A3 & B2);
endmodule

module sky130_fd_sc_hd__o32ai_2 (
  A1,
  A2,
  A3,
  B1,
  B2,
  Y,
  VPWR,
  VGND
);
  input A1;
  input A2;
  input A3;
  input B1;
  input B2;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A1 & !A2 & !A3) | (!B1 & !B2);
endmodule

module sky130_fd_sc_hd__or2_2 (
  A,
  B,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  output X;
  input VPWR;
  input VGND;
  assign X = (A) | (B);
endmodule

module sky130_fd_sc_hd__or3_2 (
  A,
  B,
  C,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  output X;
  input VPWR;
  input VGND;
  assign X = (A) | (B) | (C);
endmodule

module sky130_fd_sc_hd__or3b_2 (
  A,
  B,
  C_N,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  input C_N;
  output X;
  input VPWR;
  input VGND;
  assign X = (A) | (B) | (!C_N);
endmodule

module sky130_fd_sc_hd__or4_2 (
  A,
  B,
  C,
  D,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  input D;
  output X;
  input VPWR;
  input VGND;
  assign X = (A) | (B) | (C) | (D);
endmodule

module sky130_fd_sc_hd__or4b_2 (
  A,
  B,
  C,
  D_N,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  input C;
  input D_N;
  output X;
  input VPWR;
  input VGND;
  assign X = (A) | (B) | (C) | (!D_N);
endmodule

module sky130_fd_sc_hd__or4bb_2 (
  A,
  B,
  C_N,
  D_N,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  input C_N;
  input D_N;
  output X;
  input VPWR;
  input VGND;
  assign X = (A) | (B) | (!C_N) | (!D_N);
endmodule

module sky130_fd_sc_hd__xnor2_2 (
  A,
  B,
  Y,
  VPWR,
  VGND
);
  input A;
  input B;
  output Y;
  input VPWR;
  input VGND;
  assign Y = (!A & !B) | (A & B);
endmodule

module sky130_fd_sc_hd__xor2_2 (
  A,
  B,
  X,
  VPWR,
  VGND
);
  input A;
  input B;
  output X;
  input VPWR;
  input VGND;
  assign X = (A & !B) | (!A & B);
endmodule

