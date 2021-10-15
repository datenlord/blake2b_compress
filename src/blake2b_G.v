`include "defines.v"
module blake2b_G (
    input  wire clk,
    input  wire rst,

    // input signals
    input  wire [`GIndex_Bus]      index_i,
    input  wire [`RoundIndex_Bus]  round_i, 
    input  wire [`Word_Bus]        a,
    input  wire [`Word_Bus]        b,
    input  wire [`Word_Bus]        c,
    input  wire [`Word_Bus]        d,
                                  
    // signals to sigma table     
    output wire [`SigmaIndex_Bus]  sigma_column_o_0,
    output wire [`SigmaIndex_Bus]  sigma_row_o_0,
    input  wire [`MIndex_Bus]      mindex_i_0,

    output wire [`SigmaIndex_Bus]  sigma_column_o_1,
    output wire [`SigmaIndex_Bus]  sigma_row_o_1,
    input  wire [`MIndex_Bus]      mindex_i_1,

    // signals to message block
    output wire [`MIndex_Bus]      mindex_o_0,
    input  wire [`Word_Bus]        m_i_0,

    output wire [`MIndex_Bus]      mindex_o_1,
    input  wire [`Word_Bus]        m_i_1,

    // output signals
    output reg [`Word_Bus]         a_o,
    output reg [`Word_Bus]         b_o,
    output reg [`Word_Bus]         c_o,
    output reg [`Word_Bus]         d_o
    );

    // fetch message
    assign mindex_o_0 = (rst == `RstEnable) ? 4'd0 : mindex_i_0;
    assign mindex_o_1 = (rst == `RstEnable) ? 4'd0 : mindex_i_1;

    // fetch mindex
    assign sigma_column_o_0 = (rst == `RstEnable) ? 4'd0 : {index_i,1'b0};
    assign sigma_row_o_0    = (rst == `RstEnable) ? 4'd0 : round_i;

    assign sigma_column_o_1 = (rst == `RstEnable) ? 4'd0 : {index_i, 1'b1};
    assign sigma_row_o_1    = (rst == `RstEnable) ? 4'd0 : round_i;


    // generate output signals
    wire [`Word_Bus] a_temp_0, b_temp_0, c_temp_0, d_temp_0;
    assign a_temp_0 = a + b + m_i_0;

    wire [`Word_Bus] d_xor_a_0 = d ^ a_temp_0;
    assign d_temp_0 = (d_xor_a_0 >> 32) | (d_xor_a_0 << 32);

    assign c_temp_0 = c + d_temp_0;

    wire [`Word_Bus] b_xor_c_0 = b ^ c_temp_0;
    assign b_temp_0 = (b_xor_c_0 >> 24)|(b_xor_c_0 << 40);


    wire [`Word_Bus] a_temp_1, b_temp_1, c_temp_1, d_temp_1;
    assign a_temp_1 = a_temp_0 + b_temp_0 + m_i_1;

    wire [`Word_Bus] d_xor_a_1 = d_temp_0 ^ a_temp_1;
    assign d_temp_1 = (d_xor_a_1 >> 16) | (d_xor_a_1 << 48);

    assign c_temp_1 = c_temp_0 + d_temp_1;

    wire [`Word_Bus] b_xor_c_1 = b_temp_0 ^ c_temp_1;
    assign b_temp_1 = (b_xor_c_1 >> 63) | (b_xor_c_1 << 1);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            {a_o, b_o, c_o, d_o} <= {64'd0, 64'd0, 64'd0, 64'd0};
        end
        else begin
            {a_o, b_o, c_o, d_o} <= {a_temp_1, b_temp_1, c_temp_1, d_temp_1};
        end
    end

endmodule 




