`include "defines.v"
`include "blake2b_round.v"
`include "blake2b_mhreg.v"
module blake2b_compress (
    input wire clk_i,
    input wire rst_i,

    //input signals
    input wire [ 8*`WORD_WIDTH-1 : 0] h_i,
    input wire [16*`WORD_WIDTH-1 : 0] m_i,
    input wire [ 2*`WORD_WIDTH-1 : 0] t_i,
    input wire [ 2*`WORD_WIDTH-1 : 0] f_i,

    //output signals
    output wire [8*`WORD_WIDTH-1 : 0] h_o
);

  // initiate h,m,t,f
  wire [`WORD_BUS] h_temp[ 8];
  wire [`WORD_BUS] t_temp[ 2];
  wire [`WORD_BUS] f_temp[ 2];
  wire [`WORD_BUS] v_temp[16];


  for (genvar i = 0; i < 8; i = i + 1) begin : gen_h_temp
    assign h_temp[i] = h_i[(i+1)*`WORD_WIDTH-1 : i*`WORD_WIDTH];
  end


  assign {t_temp[0], f_temp[0]} = {t_i[63:0], f_i[63:0]};
  assign {t_temp[1], f_temp[1]} = {t_i[127:64], f_i[127:64]};

  // initiate v_temp
  assign {v_temp[3], v_temp[2], v_temp[1], v_temp[0]} = {
    h_temp[3], h_temp[2], h_temp[1], h_temp[0]
  };
  assign {v_temp[7], v_temp[6], v_temp[5], v_temp[4]} = {
    h_temp[7], h_temp[6], h_temp[5], h_temp[4]
  };
  assign {v_temp[11], v_temp[10], v_temp[9], v_temp[8]} = {
    `BLAKE2B_IV3, `BLAKE2B_IV2, `BLAKE2B_IV1, `BLAKE2B_IV0
  };
  assign {v_temp[15], v_temp[14], v_temp[13], v_temp[12]} = {
    f_temp[1] ^ `BLAKE2B_IV7,
    f_temp[0] ^ `BLAKE2B_IV6,
    t_temp[1] ^ `BLAKE2B_IV5,
    t_temp[0] ^ `BLAKE2B_IV4
  };


  // instantiate blake2b_round_a blake2b_round_b mhreg modules
  wire [ 16*`WORD_WIDTH-1:0 ] v_connection     [25];
  wire [   `ROUND_INDEX_BUS]  round_connection [25];
  wire [ 16*`WORD_WIDTH-1:0 ] m_connection     [25];
  wire [  8*`WORD_WIDTH-1:0 ] h_connection     [25];
  wire [8*`MINDEX_WIDTH-1:0 ] mindex_connection[25];
  wire [  8*`WORD_WIDTH-1:0 ] m_bus_connection [25];


  for (genvar j = 0; j < 16; j = j + 1) begin : gen_v_connection
    assign v_connection[0][`WORD_WIDTH*(j+1)-1:`WORD_WIDTH*j] = v_temp[j];
  end

  assign round_connection[0] = 4'd0;
  assign m_connection[0]     = m_i;
  assign h_connection[0]     = h_i;


  for (genvar k = 0; k < 12; k = k + 1) begin : gen_blake2b_round
    blake2b_round #(
        .RoundSelect(0)
    ) blake2b_round_a_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .round_i(round_connection[2*k]),
        .round_o(round_connection[2*k+1]),

        .v_i(v_connection[2*k]),
        .v_o(v_connection[2*k+1]),

        .mindex_bus_o(mindex_connection[2*k]),
        .m_bus_i(m_bus_connection[2*k])
    );


    blake2b_mhreg blake2b_mhreg_a (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .m_i(m_connection[2*k]),
        .m_o(m_connection[2*k+1]),

        .h_i(h_connection[2*k]),
        .h_o(h_connection[2*k+1]),

        .mindex_bus_i(mindex_connection[2*k]),
        .m_bus_o(m_bus_connection[2*k])
    );

    blake2b_round #(
        .RoundSelect(1)
    ) blake2b_round_b_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .round_i(round_connection[2*k+1]),
        .round_o(round_connection[2*k+2]),

        .v_i(v_connection[2*k+1]),
        .v_o(v_connection[2*k+2]),

        .mindex_bus_o(mindex_connection[2*k+1]),
        .m_bus_i(m_bus_connection[2*k+1])
    );


    blake2b_mhreg blake2b_mhreg_b (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .m_i(m_connection[2*k+1]),
        .m_o(m_connection[2*k+2]),

        .h_i(h_connection[2*k+1]),
        .h_o(h_connection[2*k+2]),

        .mindex_bus_i(mindex_connection[2*k+1]),
        .m_bus_o(m_bus_connection[2*k+1])
    );
  end


  wire [`WORD_BUS] h_connection_temp[ 8];
  wire [`WORD_BUS] v_connection_temp[16];
  wire [`WORD_BUS] h_o_temp         [ 8];


  for (genvar i = 0; i < 16; i = i + 1) begin : gen_v_connection_temp
    assign v_connection_temp[i] = v_connection[24][`WORD_WIDTH*(i+1)-1 : `WORD_WIDTH*i];
  end

  for (genvar i = 0; i < 8; i = i + 1) begin : gen_h_o
    assign h_connection_temp[i] = h_connection[24][`WORD_WIDTH*(i+1)-1 : `WORD_WIDTH*i];
    assign h_o_temp[i] = h_connection_temp[i] ^ v_connection_temp[i] ^ v_connection_temp[i+8];
    assign h_o[`WORD_WIDTH*(i+1)-1 : `WORD_WIDTH*i] = h_o_temp[i];
  end


endmodule  //blake2b_compress









