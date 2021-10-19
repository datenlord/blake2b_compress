`include "defines.v"
module blake2b_G (
    input wire clk_i,
    input wire rst_i,

    // input signals
    input  wire [     `GINDEX_BUS] index_i,
    input  wire [`ROUND_INDEX_BUS] round_i,
    input  wire [       `WORD_BUS] a_i,
    input  wire [       `WORD_BUS] b_i,
    input  wire [       `WORD_BUS] c_i,
    input  wire [       `WORD_BUS] d_i,
    //signals to sigma table
    output wire [`SIGMA_INDEX_BUS] sigma_column_0_o,
    output wire [`SIGMA_INDEX_BUS] sigma_row_0_o,
    input  wire [     `MINDEX_BUS] mindex_0_i,

    output wire [`SIGMA_INDEX_BUS] sigma_column_1_o,
    output wire [`SIGMA_INDEX_BUS] sigma_row_1_o,
    input  wire [     `MINDEX_BUS] mindex_1_i,

    // signals to message block
    output wire [`MINDEX_BUS] mindex_0_o,
    input  wire [  `WORD_BUS] m_0_i,

    output wire [`MINDEX_BUS] mindex_1_o,
    input  wire [  `WORD_BUS] m_1_i,

    // output signals
    output reg [`WORD_BUS] a_o,
    output reg [`WORD_BUS] b_o,
    output reg [`WORD_BUS] c_o,
    output reg [`WORD_BUS] d_o
);

  // fetch message
  assign mindex_0_o = (rst_i == `RST_ENABLE) ? 4'd0 : mindex_0_i;
  assign mindex_1_o = (rst_i == `RST_ENABLE) ? 4'd0 : mindex_1_i;

  // fetch mindex
  assign sigma_column_0_o = (rst_i == `RST_ENABLE) ? 4'd0 : {index_i,1'b0};
  assign sigma_row_0_o    = (rst_i == `RST_ENABLE) ? 4'd0 : round_i;

  assign sigma_column_1_o = (rst_i == `RST_ENABLE) ? 4'd0 : {index_i, 1'b1};
  assign sigma_row_1_o    = (rst_i == `RST_ENABLE) ? 4'd0 : round_i;


  // generate output signals
  wire [`WORD_BUS] a_temp_0, b_temp_0, c_temp_0, d_temp_0;
  assign a_temp_0 = a_i + b_i + m_0_i;

  wire [`WORD_BUS] d_xor_a_0 = d_i ^ a_temp_0;
  assign d_temp_0 = (d_xor_a_0 >> 32) | (d_xor_a_0 << 32);

  assign c_temp_0 = c_i + d_temp_0;

  wire [`WORD_BUS] b_xor_c_0 = b_i ^ c_temp_0;
  assign b_temp_0 = (b_xor_c_0 >> 24) | (b_xor_c_0 << 40);


  wire [`WORD_BUS] a_temp_1, b_temp_1, c_temp_1, d_temp_1;
  assign a_temp_1 = a_temp_0 + b_temp_0 + m_1_i;

  wire [`WORD_BUS] d_xor_a_1 = d_temp_0 ^ a_temp_1;
  assign d_temp_1 = (d_xor_a_1 >> 16) | (d_xor_a_1 << 48);

  assign c_temp_1 = c_temp_0 + d_temp_1;

  wire [`WORD_BUS] b_xor_c_1 = b_temp_0 ^ c_temp_1;
  assign b_temp_1 = (b_xor_c_1 >> 63) | (b_xor_c_1 << 1);

  always @(posedge clk_i) begin
    if (rst_i == `RST_ENABLE) begin
      {a_o, b_o, c_o, d_o} <= {64'd0, 64'd0, 64'd0, 64'd0};
    end else begin
      {a_o, b_o, c_o, d_o} <= {a_temp_1, b_temp_1, c_temp_1, d_temp_1};
    end
  end

endmodule




