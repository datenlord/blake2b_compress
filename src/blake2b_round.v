`include "defines.v"
`include "blake2b_G.v"
`include "blake2b_sigma.v"

module blake2b_round #(
    parameter reg RoundSelect = 0
    // RoundSelect = 0 blake2b_round implements G0 G1 G2 G3
    // RoundSelect = 1 blake2b_round implements G4 G5 G6 G7
) (
    input wire clk_i,
    input wire rst_i,

    input  wire [`ROUND_INDEX_BUS] round_i,
    output reg  [`ROUND_INDEX_BUS] round_o,

    input  wire [16*`WORD_WIDTH-1:0] v_i,
    output wire [16*`WORD_WIDTH-1:0] v_o,

    output wire [8*`MINDEX_WIDTH-1:0] mindex_bus_o,
    input  wire [8*`WORD_WIDTH-1 : 0] m_bus_i
);


  // generate round_o
  wire [`ROUND_INDEX_BUS] round_next;

  if (RoundSelect == 0) begin : gen_sel_0
    assign round_next = round_i;
  end else begin : gen_sel_1
    assign round_next = round_i + 4'd1;
  end


  always @(posedge clk_i) begin
    if (rst_i == `RST_ENABLE) begin
      round_o <= 4'd0;
    end else begin
      round_o <= round_next;
    end
  end

  // instantiate blake2b_G module
  wire [`WORD_BUS] v_i_temp[16];
  wire [`WORD_BUS] v_o_temp[16];


  for (genvar i = 0; i < 16; i = i + 1) begin : gen_v_temp
    assign v_i_temp[i] = v_i[(i+1)*`WORD_WIDTH-1 : i*`WORD_WIDTH];
    assign v_o[(i+1)*`WORD_WIDTH-1 : i*`WORD_WIDTH] = v_o_temp[i];
  end


  wire [`MINDEX_BUS] mindex_bus_temp[8];
  wire [  `WORD_BUS] m_bus_temp     [8];


  for (genvar j = 0; j < 8; j = j + 1) begin : gen_m_index
    assign mindex_bus_o[(j+1)*`MINDEX_WIDTH-1 : j*`MINDEX_WIDTH] = mindex_bus_temp[j];
    assign m_bus_temp[j] = m_bus_i[(j+1)*`WORD_WIDTH-1 : j*`WORD_WIDTH];
  end


  // instantiate G0 G1 G2 G3 / G4 G5 G6 G7

  wire [3:0] sigma_column_0, sigma_row_0, m_index_0;
  wire [3:0] sigma_column_1, sigma_row_1, m_index_1;

  wire [3:0] sigma_column_2, sigma_row_2, m_index_2;
  wire [3:0] sigma_column_3, sigma_row_3, m_index_3;

  wire [3:0] sigma_column_4, sigma_row_4, m_index_4;
  wire [3:0] sigma_column_5, sigma_row_5, m_index_5;

  wire [3:0] sigma_column_6, sigma_row_6, m_index_6;
  wire [3:0] sigma_column_7, sigma_row_7, m_index_7;

  if (RoundSelect == 0) begin : gen_round_select_0  // if RoundSelect==0 instantiate G0 G1 G2 G3
    blake2b_G blake2b_g0 (
        .clk_i  (clk_i),
        .rst_i  (rst_i),
        // input signals
        .index_i(3'd0),
        .round_i(round_i),

        .a_i(v_i_temp[0]),
        .b_i(v_i_temp[4]),
        .c_i(v_i_temp[8]),
        .d_i(v_i_temp[12]),

        // signals to sigma table
        .sigma_column_0_o(sigma_column_0),
        .sigma_row_0_o   (sigma_row_0),
        .mindex_0_i      (m_index_0),

        .sigma_column_1_o(sigma_column_1),
        .sigma_row_1_o   (sigma_row_1),
        .mindex_1_i      (m_index_1),

        // signals to message reg
        .mindex_0_o(mindex_bus_temp[0]),
        .m_0_i     (m_bus_temp[0]),

        .mindex_1_o(mindex_bus_temp[1]),
        .m_1_i     (m_bus_temp[1]),

        // output signals
        .a_o(v_o_temp[0]),
        .b_o(v_o_temp[4]),
        .c_o(v_o_temp[8]),
        .d_o(v_o_temp[12])
    );

    blake2b_G blake2b_g1 (
        .clk_i(clk_i),
        .rst_i(rst_i),

        // input signals
        .index_i(3'd1),
        .round_i(round_i),

        .a_i(v_i_temp[1]),
        .b_i(v_i_temp[5]),
        .c_i(v_i_temp[9]),
        .d_i(v_i_temp[13]),

        // signals to sigma table
        .sigma_column_0_o(sigma_column_2),
        .sigma_row_0_o   (sigma_row_2),
        .mindex_0_i      (m_index_2),

        .sigma_column_1_o(sigma_column_3),
        .sigma_row_1_o   (sigma_row_3),
        .mindex_1_i      (m_index_3),

        // signals to message reg
        .mindex_0_o(mindex_bus_temp[2]),
        .m_0_i     (m_bus_temp[2]),

        .mindex_1_o(mindex_bus_temp[3]),
        .m_1_i     (m_bus_temp[3]),

        // output signals
        .a_o(v_o_temp[1]),
        .b_o(v_o_temp[5]),
        .c_o(v_o_temp[9]),
        .d_o(v_o_temp[13])
    );

    blake2b_G blake2b_g2 (
        .clk_i(clk_i),
        .rst_i(rst_i),

        // input signals
        .index_i(3'd2),
        .round_i(round_i),

        .a_i(v_i_temp[2]),
        .b_i(v_i_temp[6]),
        .c_i(v_i_temp[10]),
        .d_i(v_i_temp[14]),

        // signals to sigma table
        .sigma_column_0_o(sigma_column_4),
        .sigma_row_0_o   (sigma_row_4),
        .mindex_0_i      (m_index_4),

        .sigma_column_1_o(sigma_column_5),
        .sigma_row_1_o   (sigma_row_5),
        .mindex_1_i      (m_index_5),

        // signals to message reg
        .mindex_0_o(mindex_bus_temp[4]),
        .m_0_i     (m_bus_temp[4]),

        .mindex_1_o(mindex_bus_temp[5]),
        .m_1_i     (m_bus_temp[5]),

        // output signals
        .a_o(v_o_temp[2]),
        .b_o(v_o_temp[6]),
        .c_o(v_o_temp[10]),
        .d_o(v_o_temp[14])
    );

    blake2b_G blake2b_g3 (
        .clk_i(clk_i),
        .rst_i(rst_i),

        // input signals
        .index_i(3'd3),
        .round_i(round_i),

        .a_i(v_i_temp[3]),
        .b_i(v_i_temp[7]),
        .c_i(v_i_temp[11]),
        .d_i(v_i_temp[15]),

        // signals to sigma table
        .sigma_column_0_o(sigma_column_6),
        .sigma_row_0_o   (sigma_row_6),
        .mindex_0_i      (m_index_6),

        .sigma_column_1_o(sigma_column_7),
        .sigma_row_1_o   (sigma_row_7),
        .mindex_1_i      (m_index_7),

        // signals to message reg
        .mindex_0_o(mindex_bus_temp[6]),
        .m_0_i     (m_bus_temp[6]),

        .mindex_1_o(mindex_bus_temp[7]),
        .m_1_i     (m_bus_temp[7]),

        // output signals
        .a_o(v_o_temp[3]),
        .b_o(v_o_temp[7]),
        .c_o(v_o_temp[11]),
        .d_o(v_o_temp[15])
    );
  end else begin : gen_round_select_1  // if RoundSelect == 1 instantiate G4 G5 G6 G7

    blake2b_G blake2b_g4 (
        .clk_i(clk_i),
        .rst_i(rst_i),

        // input signals
        .index_i(3'd4),
        .round_i(round_i),

        .a_i(v_i_temp[0]),
        .b_i(v_i_temp[5]),
        .c_i(v_i_temp[10]),
        .d_i(v_i_temp[15]),

        // signals to sigma table
        .sigma_column_0_o(sigma_column_0),
        .sigma_row_0_o   (sigma_row_0),
        .mindex_0_i      (m_index_0),

        .sigma_column_1_o(sigma_column_1),
        .sigma_row_1_o   (sigma_row_1),
        .mindex_1_i      (m_index_1),

        // signals to message reg
        .mindex_0_o(mindex_bus_temp[0]),
        .m_0_i     (m_bus_temp[0]),

        .mindex_1_o(mindex_bus_temp[1]),
        .m_1_i     (m_bus_temp[1]),

        // output signals
        .a_o(v_o_temp[0]),
        .b_o(v_o_temp[5]),
        .c_o(v_o_temp[10]),
        .d_o(v_o_temp[15])
    );


    blake2b_G blake2b_g5 (
        .clk_i(clk_i),
        .rst_i(rst_i),

        // input signals
        .index_i(3'd5),
        .round_i(round_i),

        .a_i(v_i_temp[1]),
        .b_i(v_i_temp[6]),
        .c_i(v_i_temp[11]),
        .d_i(v_i_temp[12]),

        // signals to sigma table
        .sigma_column_0_o(sigma_column_2),
        .sigma_row_0_o   (sigma_row_2),
        .mindex_0_i      (m_index_2),

        .sigma_column_1_o(sigma_column_3),
        .sigma_row_1_o   (sigma_row_3),
        .mindex_1_i      (m_index_3),

        // signals to message reg
        .mindex_0_o(mindex_bus_temp[2]),
        .m_0_i     (m_bus_temp[2]),

        .mindex_1_o(mindex_bus_temp[3]),
        .m_1_i     (m_bus_temp[3]),

        // output signals
        .a_o(v_o_temp[1]),
        .b_o(v_o_temp[6]),
        .c_o(v_o_temp[11]),
        .d_o(v_o_temp[12])
    );

    blake2b_G blake2b_g6 (
        .clk_i(clk_i),
        .rst_i(rst_i),

        // input signals
        .index_i(3'd6),
        .round_i(round_i),

        .a_i(v_i_temp[2]),
        .b_i(v_i_temp[7]),
        .c_i(v_i_temp[8]),
        .d_i(v_i_temp[13]),

        // signals to sigma table
        .sigma_column_0_o(sigma_column_4),
        .sigma_row_0_o   (sigma_row_4),
        .mindex_0_i      (m_index_4),

        .sigma_column_1_o(sigma_column_5),
        .sigma_row_1_o   (sigma_row_5),
        .mindex_1_i      (m_index_5),

        // signals to message reg
        .mindex_0_o(mindex_bus_temp[4]),
        .m_0_i     (m_bus_temp[4]),

        .mindex_1_o(mindex_bus_temp[5]),
        .m_1_i     (m_bus_temp[5]),

        // output signals
        .a_o(v_o_temp[2]),
        .b_o(v_o_temp[7]),
        .c_o(v_o_temp[8]),
        .d_o(v_o_temp[13])
    );

    blake2b_G blake2b_g7 (
        .clk_i(clk_i),
        .rst_i(rst_i),

        // input signals
        .index_i(3'd7),
        .round_i(round_i),

        .a_i(v_i_temp[3]),
        .b_i(v_i_temp[4]),
        .c_i(v_i_temp[9]),
        .d_i(v_i_temp[14]),

        // signals to sigma table
        .sigma_column_0_o(sigma_column_6),
        .sigma_row_0_o   (sigma_row_6),
        .mindex_0_i      (m_index_6),

        .sigma_column_1_o(sigma_column_7),
        .sigma_row_1_o   (sigma_row_7),
        .mindex_1_i      (m_index_7),

        // signals to message reg
        .mindex_0_o(mindex_bus_temp[6]),
        .m_0_i     (m_bus_temp[6]),

        .mindex_1_o(mindex_bus_temp[7]),
        .m_1_i     (m_bus_temp[7]),

        // output signals
        .a_o(v_o_temp[3]),
        .b_o(v_o_temp[4]),
        .c_o(v_o_temp[9]),
        .d_o(v_o_temp[14])
    );

  end



  blake2b_sigma blake2b_sigma0 (

      .sigma_column_i(sigma_column_0),
      .sigma_row_i   (sigma_row_0),
      .m_index_o     (m_index_0)
  );

  blake2b_sigma blake2b_sigma1 (

      .sigma_column_i(sigma_column_1),
      .sigma_row_i   (sigma_row_1),
      .m_index_o     (m_index_1)
  );


  // Instantiate G1 module

  blake2b_sigma blake2b_sigma2 (

      .sigma_column_i(sigma_column_2),
      .sigma_row_i   (sigma_row_2),
      .m_index_o     (m_index_2)
  );

  blake2b_sigma blake2b_sigma3 (

      .sigma_column_i(sigma_column_3),
      .sigma_row_i   (sigma_row_3),
      .m_index_o     (m_index_3)
  );


  blake2b_sigma blake2b_sigma4 (

      .sigma_column_i(sigma_column_4),
      .sigma_row_i   (sigma_row_4),
      .m_index_o     (m_index_4)
  );

  blake2b_sigma blake2b_sigma5 (

      .sigma_column_i(sigma_column_5),
      .sigma_row_i   (sigma_row_5),
      .m_index_o     (m_index_5)
  );

  blake2b_sigma blake2b_sigma6 (

      .sigma_column_i(sigma_column_6),
      .sigma_row_i   (sigma_row_6),
      .m_index_o     (m_index_6)
  );

  blake2b_sigma blake2b_sigma7 (

      .sigma_column_i(sigma_column_7),
      .sigma_row_i   (sigma_row_7),
      .m_index_o     (m_index_7)
  );

endmodule  //blake2b_round





