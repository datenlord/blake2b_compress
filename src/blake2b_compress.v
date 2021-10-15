`include "defines.v"
`include "blake2b_round.v"
`include "blake2b_mhreg.v"
module blake2b_compress(
    input wire clk,
    input wire rst,

    //input signals
    input  wire [ 8*`Word_Width-1 : 0] h_i,
    input  wire [16*`Word_Width-1 : 0] m_i,
    input  wire [ 2*`Word_Width-1 : 0] t_i,
    input  wire [ 2*`Word_Width-1 : 0] f_i,

    //output signals
    output wire [ 8*`Word_Width-1 : 0] h_o
    );

    // initiate h,m,t,f
    wire [`Word_Bus] h_temp [ 7:0];
    wire [`Word_Bus] t_temp [ 1:0];
    wire [`Word_Bus] f_temp [ 1:0];
    wire [`Word_Bus] v_temp [15:0];

    genvar i;
    generate
        for(i=0 ;i< 8 ;i=i+1) begin
            assign h_temp[i] = h_i[(i+1)*`Word_Width-1 : i*`Word_Width];
        end        
    endgenerate
    
    assign { t_temp[0],f_temp[0] } = { t_i[ 63: 0], f_i[ 63: 0]};
    assign { t_temp[1],f_temp[1] } = { t_i[127:64], f_i[127:64]};

    // initiate v_temp
    assign {v_temp[3], v_temp[2], v_temp[1], v_temp[0]} = {h_temp[3], h_temp[2],h_temp[1],h_temp[0]};
    assign {v_temp[7], v_temp[6], v_temp[5], v_temp[4]} = {h_temp[7], h_temp[6],h_temp[5],h_temp[4]};
    assign {v_temp[11], v_temp[10], v_temp[9], v_temp[8]} = {`blake2b_IV3,`blake2b_IV2,`blake2b_IV1,`blake2b_IV0};
    assign {v_temp[15], v_temp[14], v_temp[13], v_temp[12]} = {f_temp[1]^`blake2b_IV7, f_temp[0]^`blake2b_IV6, t_temp[1]^`blake2b_IV5, t_temp[0]^`blake2b_IV4};


    // instantiate blake2b_round_a blake2b_round_b mhreg modules
    wire [16*`Word_Width-1:0]   v_connection     [24:0];
    wire [`RoundIndex_Bus]      round_connection [24:0];
    wire [16*`Word_Width-1:0]   m_connection     [24:0];
    wire [ 8*`Word_Width-1:0]   h_connection     [24:0];
    wire [ 8*`MIndex_Width-1:0] mindex_connection[23:0];
    wire [ 8*`Word_Width-1:0]   m_bus_connection [23:0];

    genvar j;
    generate
        for (j = 0;j<16 ; j=j+1) begin
            assign v_connection[0][`Word_Width*(j+1)-1:`Word_Width*j] = v_temp[j];
        end
    endgenerate

    assign round_connection[0] = 4'd0;
    assign m_connection[0] = m_i;
    assign h_connection[0] = h_i;

    genvar k;
    generate
        for (k = 0;k<12 ;k=k+1 ) begin:gen
            blake2b_round #(
                .round_select(0)
            ) blake2b_round_a_inst(
                .clk(clk),
                .rst(rst),
                
                .round_i(round_connection[2*k]),
                .round_o(round_connection[2*k+1]),
                
                .v_i(v_connection[2*k]),
                .v_o(v_connection[2*k+1]),
                
                .mindex_bus_o(mindex_connection[2*k]),
                .m_bus_i(m_bus_connection[2*k])
                );


            blake2b_mhreg blake2b_mhreg_a(
                .clk(clk),
                .rst(rst),

                .m_i(m_connection[2*k  ]),
                .m_o(m_connection[2*k+1]),
                
                .h_i(h_connection[2*k  ]),
                .h_o(h_connection[2*k+1]), 
                
                .mindex_bus_i(mindex_connection[2*k]),
                .m_bus_o(m_bus_connection[2*k])
                );

            blake2b_round#(
                .round_select(1)
            ) blake2b_round_b_inst(
                .clk(clk),
                .rst(rst),
                
                .round_i(round_connection[2*k+1]),
                .round_o(round_connection[2*k+2]),
                
                .v_i(v_connection[2*k+1]),
                .v_o(v_connection[2*k+2]),
                
                .mindex_bus_o(mindex_connection[2*k+1]),
                .m_bus_i(m_bus_connection[2*k+1])
                );


            blake2b_mhreg blake2b_mhreg_b(
                .clk(clk),
                .rst(rst),

                .m_i(m_connection[2*k+1]),
                .m_o(m_connection[2*k+2]),
                
                .h_i(h_connection[2*k+1]),
                .h_o(h_connection[2*k+2]), 
                
                .mindex_bus_i(mindex_connection[2*k+1]),
                .m_bus_o(m_bus_connection[2*k+1])
                );
        end
    endgenerate

    wire [`Word_Bus] h_connection_temp [ 7:0];
    wire [`Word_Bus] v_connection_temp [16:0];
    wire [`Word_Bus] h_o_temp [ 7:0];

    generate
        for (i = 0;i<16 ;i=i+1 ) begin
            assign v_connection_temp[i] = v_connection[24][`Word_Width*(i+1)-1 : `Word_Width*i];
        end
        for (i = 0 ;i<8;i=i+1 ) begin
            assign h_connection_temp [i] = h_connection[24][`Word_Width*(i+1)-1 : `Word_Width*i];
            assign h_o_temp[i] = h_connection_temp[i] ^ v_connection_temp[i] ^ v_connection_temp[i+8];
            assign h_o[`Word_Width*(i+1)-1 : `Word_Width*i] = h_o_temp[i];
        end
    endgenerate

endmodule //blake2b_compress









