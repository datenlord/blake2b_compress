`include "defines.v"
module blake2b_mhreg (
    input wire clk_i,
    input wire rst_i,

    input  wire [16*`WORD_WIDTH-1:0] m_i,
    output reg  [16*`WORD_WIDTH-1:0] m_o,

    input  wire [8*`WORD_WIDTH-1:0] h_i,
    output reg  [8*`WORD_WIDTH-1:0] h_o,

    input  wire [8*`MINDEX_WIDTH-1:0] mindex_bus_i,
    output wire [8*`WORD_WIDTH-1 : 0] m_bus_o
);

  always @(posedge clk_i) begin
    if (rst_i == `RST_ENABLE) begin
      m_o <= 0;
      h_o <= 0;
    end else begin
      m_o <= m_i;
      h_o <= h_i;
    end
  end

  wire [`WORD_BUS] m_temp[16];
  wire [`WORD_BUS] m_bus_temp[8];
  wire [`MINDEX_BUS] mindex_bus_temp[8];



  for (genvar i = 0; i < 16; i = i + 1) begin : gen_m_temp
    assign m_temp[i] = m_o[(i+1)*`WORD_WIDTH-1 : i*`WORD_WIDTH];
  end

  for (genvar i = 0; i < 8; i = i + 1) begin : gen_m_bus_o
    assign m_bus_o[(i+1)*`WORD_WIDTH-1 : i*`WORD_WIDTH] = m_bus_temp[i];

    assign mindex_bus_temp[i] = mindex_bus_i[(i+1)*`MINDEX_WIDTH-1 : i*`MINDEX_WIDTH];
    assign m_bus_temp[i] = m_temp[mindex_bus_temp[i]];
  end



endmodule  //blake2b_mblock



