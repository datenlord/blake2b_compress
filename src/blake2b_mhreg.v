`include "defines.v"
module blake2b_mhreg (
    input wire clk,
    input wire rst,

    input  wire [16*`Word_Width-1:0] m_i,
    output reg  [16*`Word_Width-1:0] m_o,

    input  wire [ 8*`Word_Width-1:0] h_i,
    output reg  [ 8*`Word_Width-1:0] h_o, 

    input  wire [8*`MIndex_Width-1:0] mindex_bus_i,
    output wire [8*`Word_Width-1  :0] m_bus_o
    );

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            m_o <= 0;
            h_o <= 0;
        end
        else begin
            m_o <= m_i;
            h_o <= h_i;
        end
    end

    wire [`Word_Bus] m_temp[15:0];
    wire [`Word_Bus] m_bus_temp[7:0];
    wire [`MIndex_Bus] mindex_bus_temp[7:0];

    genvar i;
    generate
        for (i = 0;i<16 ;i = i+1 ) begin
            assign m_temp[i] = m_o[(i+1)*`Word_Width-1 : i*`Word_Width]; 
        end

        for (i = 0;i<8 ;i = i+1 ) begin
            assign m_bus_o[(i+1)*`Word_Width-1 : i*`Word_Width] = m_bus_temp [i];
            
            assign mindex_bus_temp [i] = mindex_bus_i[(i+1)*`MIndex_Width-1 : i*`MIndex_Width];
            assign m_bus_temp[i] = m_temp[ mindex_bus_temp[i] ];  
        end
    endgenerate



endmodule //blake2b_mblock



