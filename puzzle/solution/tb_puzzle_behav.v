`timescale 1ns / 1ps
module tb_puzzle_behav;
  localparam MAX_CYCLES = 4096;
  localparam EXTRA_CYCLES = 50;

  reg           clk = 0;
  reg           rst_n;
  reg           I;
  wire          enable = 1'b1;
  wire          success;
  wire    [7:0] O;

  reg     [1:0] seq_mem       [0:MAX_CYCLES-1];
  integer       n_cycles;
  integer       i;

  puzzle_wrapper dut (
      .clk(clk),
      .rst_n(rst_n),
      .enable(enable),
      .I(I),
      .success(success),
      .O(O)
  );

  // initialize the testbench, load stimulus
  initial begin
    $dumpfile("outdir/solution.vcd");
    $dumpvars(0, tb_puzzle_behav);

    $readmemb("outdir/stimulus.mem", seq_mem);
    for (
        n_cycles = 0; n_cycles < MAX_CYCLES && seq_mem[n_cycles] !== 2'bxx; n_cycles = n_cycles + 1
    )
    ;  // count how many cycles we got from the formal testbench

    I <= seq_mem[0][1];
    rst_n <= seq_mem[0][0];
    forever #5 clk = ~clk;
  end

  initial begin
    @(posedge clk);
    // initial witness
    for (i = 1; i < n_cycles; i = i + 1) begin
      I <= seq_mem[i][1];
      rst_n <= seq_mem[i][0];
      @(posedge clk);
    end

    // toggle I randomly
    for (i = n_cycles; i < n_cycles + EXTRA_CYCLES; i = i + 1) begin
      rst_n <= 1'b1;
      I <= $random;
      @(posedge clk);
    end

    $display();
    $display("Done!");
    $display();
    $finish(2);
  end

  // monitor output
  initial begin
    $monitor("success = %b, Output (hex): %x, Output (ASCII): '%c'", success, O, O);
  end

endmodule
