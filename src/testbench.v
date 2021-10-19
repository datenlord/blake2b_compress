`include "defines.v"
`include "blake2b_compress.v"

//~ `New testbench
`timescale 1ns / 1ps

module testbench ();

  // standard input and output from files
  reg [`WORD_BUS] standard_input [28];
  reg [`WORD_BUS] standard_output[ 8];

  initial begin
    $readmemh("./input.txt", standard_input, 0, 27);
    $readmemh("./output.txt", standard_output, 0, 7);
  end

  reg clk = 0, rst = 1;

  reg [`WORD_BUS] h[8];
  reg [`WORD_BUS] m[16];
  reg [`WORD_BUS] t[2];
  reg [`WORD_BUS] f[2];

  wire [8*`WORD_WIDTH-1 : 0] h_temp;
  wire [16*`WORD_WIDTH-1 : 0] m_temp;
  wire [2*`WORD_WIDTH-1 : 0] t_temp;
  wire [2*`WORD_WIDTH-1 : 0] f_temp;

  wire [8*`WORD_WIDTH-1 : 0] h_o;
  wire [`WORD_BUS] h_o_temp[8];



  for (genvar i = 0; i < 16; i = i + 1) begin : gen_m_temp
    assign m_temp[`WORD_WIDTH*(i+1)-1:`WORD_WIDTH*i] = m[i];
  end
  for (genvar i = 0; i < 8; i = i + 1) begin : gen_h_temp
    assign h_temp[`WORD_WIDTH*(i+1)-1:`WORD_WIDTH*i] = h[i];
    assign h_o_temp[i] = h_o[`WORD_WIDTH*(i+1)-1:`WORD_WIDTH*i];
  end
  for (genvar i = 0; i < 2; i = i + 1) begin : gen_t_temp
    assign t_temp[`WORD_WIDTH*(i+1)-1:`WORD_WIDTH*i] = t[i];
    assign f_temp[`WORD_WIDTH*(i+1)-1:`WORD_WIDTH*i] = f[i];

  end



  // generate clk signal
  localparam reg PERIOD = 10;
  initial begin
    clk = 0;
    forever #(PERIOD / 2) clk = ~clk;
  end

  // generate rst signal
  initial begin
    #PERIOD rst = 0;
  end

  // generate input signals to target module
  always @(posedge clk) begin
    if (rst == `RST_ENABLE) begin
      f[0] <= 0;
      f[1] <= 0;
      t[0] <= 0;
      t[1] <= 0;

    end else begin
      f[0] <= standard_input[0];
      f[1] <= standard_input[1];
      t[0] <= standard_input[2];
      t[1] <= standard_input[3];
    end
  end

  always @(posedge clk) begin
    if (rst == `RST_ENABLE) begin
      h[0] <= 0;
      h[1] <= 0;
      h[2] <= 0;
      h[3] <= 0;
      h[4] <= 0;
      h[5] <= 0;
      h[6] <= 0;
      h[7] <= 0;
    end else begin
      h[0] <= standard_input[4];
      h[1] <= standard_input[5];
      h[2] <= standard_input[6];
      h[3] <= standard_input[7];
      h[4] <= standard_input[8];
      h[5] <= standard_input[9];
      h[6] <= standard_input[10];
      h[7] <= standard_input[11];
    end
  end

  integer j = 0;
  always @(posedge clk) begin
    if (rst == `RST_ENABLE) begin
      for (j = 0; j < 16; j = j + 1) begin
        m[j] <= 0;
      end
    end else begin
      for (j = 0; j < 16; j = j + 1) begin
        m[j] <= standard_input[12+j];
      end
    end
  end


  // instantiate the target module
  blake2b_compress blake2b_compress_inst (
      .clk_i(clk),
      .rst_i(rst),

      //input signals
      .h_i(h_temp),
      .m_i(m_temp),
      .t_i(t_temp),
      .f_i(f_temp),

      //output signals
      .h_o(h_o)
  );


  initial begin
    #1000;
    $display("The output h of blake2b_compress module:");
    for (j = 0; j < 8; j = j + 1) begin
      if (h_o_temp[j] != standard_output[j]) begin
        $error("The output h[%c]of target module is wrong!!", j + 48);
        $finish();
      end
    end
    $display("Test Case Passed!!!\n");
    $finish;
  end

  initial begin
    $dumpfile("wave.vcd");  // create wave file
    $dumpvars;  // dump all vars
  end

endmodule  //testbench
