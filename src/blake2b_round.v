`include "defines.v"
`include "blake2b_G.v"
`include "blake2b_sigma.v"

module blake2b_round #(
    parameter round_select = 0
    // round_select = 0 blake2b_round implements G0 G1 G2 G3
    // round_select = 1 blake2b_round implements G4 G5 G6 G7
)(
    input wire clk,
    input wire rst,

    input  wire [`RoundIndex_Bus] round_i,
    output reg  [`RoundIndex_Bus] round_o,

    input  wire  [16*`Word_Width-1:0] v_i,
    output wire  [16*`Word_Width-1:0] v_o,

    output wire [8*`MIndex_Width-1:0] mindex_bus_o,
    input  wire [8*`Word_Width-1  :0] m_bus_i
);


    // generate round_o
    wire [`RoundIndex_Bus] round_next;
    generate
        if(round_select == 0) begin
            assign round_next = round_i;
        end
        else begin
            assign round_next = round_i + 4'd1;
        end
    endgenerate

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            round_o <= 4'd0;
        end
        else begin
            round_o <= round_next;
        end
    end

    // instantiate blake2b_G module
    wire [`Word_Bus] v_i_temp [15:0];
    wire [`Word_Bus] v_o_temp [15:0];
    genvar i;
    generate
        for (i = 0;i < 16 ;i = i+1 ) begin
            assign v_i_temp[i] = v_i[(i+1)*`Word_Width-1 : i*`Word_Width];
            assign v_o[(i+1)*`Word_Width-1 : i*`Word_Width] = v_o_temp[i];
        end
    endgenerate

    wire [`MIndex_Bus] mindex_bus_temp[7:0];
    wire [`Word_Bus] m_bus_temp [7:0];
    genvar j;
    generate
        for (j = 0;j < 8 ; j= j+1 ) begin
            assign mindex_bus_o[(j+1)*`MIndex_Width-1 : j*`MIndex_Width] = mindex_bus_temp[j];
            assign m_bus_temp [j] = m_bus_i[(j+1)*`Word_Width-1 : j*`Word_Width];

        end
    endgenerate

    // instantiate G0 G1 G2 G3 / G4 G5 G6 G7

    wire [3:0] sigma_column_0, sigma_row_0, m_index_0;
    wire [3:0] sigma_column_1, sigma_row_1, m_index_1;

    wire [3:0] sigma_column_2, sigma_row_2, m_index_2;
    wire [3:0] sigma_column_3, sigma_row_3, m_index_3;

    wire [3:0] sigma_column_4, sigma_row_4, m_index_4;
    wire [3:0] sigma_column_5, sigma_row_5, m_index_5;

    wire [3:0] sigma_column_6, sigma_row_6, m_index_6;
    wire [3:0] sigma_column_7, sigma_row_7, m_index_7;

    generate
        if(round_select == 0) begin // if round_select==0 instantiate G0 G1 G2 G3
            blake2b_G blake2b_G0 (
                .clk(clk),
                .rst(rst),
                // input signals
                .index_i(3'd0    ),
                .round_i(round_i ),
                            
                .a      (v_i_temp[ 0]),
                .b      (v_i_temp[ 4]),
                .c      (v_i_temp[ 8]),
                .d      (v_i_temp[12]),
                                            
                // signals to sigma table     
                .sigma_column_o_0(sigma_column_0),
                .sigma_row_o_0   (sigma_row_0   ),
                .mindex_i_0     (m_index_0     ),

                .sigma_column_o_1(sigma_column_1),
                .sigma_row_o_1   (sigma_row_1   ),
                .mindex_i_1     (m_index_1     ),

                // signals to message reg
                .mindex_o_0     (mindex_bus_temp[0]),
                .m_i_0           (m_bus_temp[0]),

                .mindex_o_1     (mindex_bus_temp[1]),
                .m_i_1           (m_bus_temp[1]),

                // output signals
                .a_o   (v_o_temp[ 0]),
                .b_o   (v_o_temp[ 4]),
                .c_o   (v_o_temp[ 8]),
                .d_o   (v_o_temp[12])
            );

            blake2b_G blake2b_G1 (
                .clk(clk),
                .rst(rst),

                // input signals
                .index_i(3'd1    ),
                .round_i(round_i ),
                        
                .a      (v_i_temp[ 1]),
                .b      (v_i_temp[ 5]),
                .c      (v_i_temp[ 9]),
                .d      (v_i_temp[13]),
                                        
                // signals to sigma table     
                .sigma_column_o_0(sigma_column_2),
                .sigma_row_o_0   (sigma_row_2   ),
                .mindex_i_0     (m_index_2     ),

                .sigma_column_o_1(sigma_column_3),
                .sigma_row_o_1   (sigma_row_3   ),
                .mindex_i_1     (m_index_3     ),

                // signals to message reg
                .mindex_o_0     (mindex_bus_temp[2]),
                .m_i_0           (m_bus_temp[2]),

                .mindex_o_1     (mindex_bus_temp[3]),
                .m_i_1           (m_bus_temp[3]),

                // output signals
                .a_o   (v_o_temp[ 1]),
                .b_o   (v_o_temp[ 5]),
                .c_o   (v_o_temp[ 9]),
                .d_o   (v_o_temp[13])
            );

            blake2b_G blake2b_G2 (
                .clk(clk),
                .rst(rst),

                // input signals
                .index_i(3'd2    ),
                .round_i(round_i ),
                        
                .a      (v_i_temp[ 2]),
                .b      (v_i_temp[ 6]),
                .c      (v_i_temp[10]),
                .d      (v_i_temp[14]),
                                        
                // signals to sigma table     
                .sigma_column_o_0(sigma_column_4),
                .sigma_row_o_0   (sigma_row_4   ),
                .mindex_i_0     (m_index_4     ),

                .sigma_column_o_1(sigma_column_5),
                .sigma_row_o_1   (sigma_row_5   ),
                .mindex_i_1     (m_index_5     ),

                // signals to message reg
                .mindex_o_0     (mindex_bus_temp[4]),
                .m_i_0           (m_bus_temp[4]),

                .mindex_o_1     (mindex_bus_temp[5]),
                .m_i_1           (m_bus_temp[5]),

                // output signals
                .a_o   (v_o_temp[ 2]),
                .b_o   (v_o_temp[ 6]),
                .c_o   (v_o_temp[10]),
                .d_o   (v_o_temp[14])
            );

            blake2b_G blake2b_G3 (
                .clk(clk),
                .rst(rst),

                // input signals
                .index_i(3'd3    ),
                .round_i(round_i ),
                        
                .a      (v_i_temp[ 3]),
                .b      (v_i_temp[ 7]),
                .c      (v_i_temp[11]),
                .d      (v_i_temp[15]),
                                        
                // signals to sigma table     
                .sigma_column_o_0(sigma_column_6),
                .sigma_row_o_0   (sigma_row_6   ),
                .mindex_i_0     (m_index_6     ),

                .sigma_column_o_1(sigma_column_7),
                .sigma_row_o_1   (sigma_row_7   ),
                .mindex_i_1     (m_index_7     ),

                // signals to message reg
                .mindex_o_0     (mindex_bus_temp[6]),
                .m_i_0           (m_bus_temp[6]),

                .mindex_o_1     (mindex_bus_temp[7]),
                .m_i_1           (m_bus_temp[7]),

                // output signals
                .a_o   (v_o_temp[ 3]),
                .b_o   (v_o_temp[ 7]),
                .c_o   (v_o_temp[11]),
                .d_o   (v_o_temp[15])
            );
        end
        else begin // if round_select == 1 instantiate G4 G5 G6 G7

            blake2b_G blake2b_G4 (
                .clk(clk),
                .rst(rst),

                // input signals
                .index_i(3'd4    ),
                .round_i(round_i ),
                        
                .a      (v_i_temp[ 0]),
                .b      (v_i_temp[ 5]),
                .c      (v_i_temp[10]),
                .d      (v_i_temp[15]),
                                        
                // signals to sigma table     
                .sigma_column_o_0(sigma_column_0),
                .sigma_row_o_0   (sigma_row_0   ),
                .mindex_i_0     (m_index_0     ),

                .sigma_column_o_1(sigma_column_1),
                .sigma_row_o_1   (sigma_row_1   ),
                .mindex_i_1     (m_index_1     ),

                // signals to message reg
                .mindex_o_0     (mindex_bus_temp[0]),
                .m_i_0           (m_bus_temp[0]),

                .mindex_o_1     (mindex_bus_temp[1]),
                .m_i_1           (m_bus_temp[1]),

                // output signals
                .a_o   (v_o_temp[ 0]),
                .b_o   (v_o_temp[ 5]),
                .c_o   (v_o_temp[10]),
                .d_o   (v_o_temp[15])
            );


            blake2b_G blake2b_G5 (
                .clk(clk),
                .rst(rst),

                // input signals
                .index_i(3'd5    ),
                .round_i(round_i ),
                        
                .a      (v_i_temp[ 1]),
                .b      (v_i_temp[ 6]),
                .c      (v_i_temp[11]),
                .d      (v_i_temp[12]),
                                        
                // signals to sigma table     
                .sigma_column_o_0(sigma_column_2),
                .sigma_row_o_0   (sigma_row_2   ),
                .mindex_i_0     (m_index_2     ),

                .sigma_column_o_1(sigma_column_3),
                .sigma_row_o_1   (sigma_row_3   ),
                .mindex_i_1     (m_index_3     ),

                // signals to message reg
                .mindex_o_0     (mindex_bus_temp[2]),
                .m_i_0           (m_bus_temp[2]),

                .mindex_o_1     (mindex_bus_temp[3]),
                .m_i_1           (m_bus_temp[3]),

                // output signals
                .a_o   (v_o_temp[ 1]),
                .b_o   (v_o_temp[ 6]),
                .c_o   (v_o_temp[11]),
                .d_o   (v_o_temp[12])
            );

            blake2b_G blake2b_G6 (
                .clk(clk),
                .rst(rst),

                // input signals
                .index_i(3'd6    ),
                .round_i(round_i ),
                        
                .a      (v_i_temp[ 2]),
                .b      (v_i_temp[ 7]),
                .c      (v_i_temp[ 8]),
                .d      (v_i_temp[13]),
                                        
                // signals to sigma table     
                .sigma_column_o_0(sigma_column_4),
                .sigma_row_o_0   (sigma_row_4   ),
                .mindex_i_0     (m_index_4     ),

                .sigma_column_o_1(sigma_column_5),
                .sigma_row_o_1   (sigma_row_5   ),
                .mindex_i_1     (m_index_5     ),

                // signals to message reg
                .mindex_o_0     (mindex_bus_temp[4]),
                .m_i_0           (m_bus_temp[4]),

                .mindex_o_1     (mindex_bus_temp[5]),
                .m_i_1           (m_bus_temp[5]),

                // output signals
                .a_o   (v_o_temp[ 2]),
                .b_o   (v_o_temp[ 7]),
                .c_o   (v_o_temp[ 8]),
                .d_o   (v_o_temp[13])
            );

            blake2b_G blake2b_G7 (
                .clk(clk),
                .rst(rst),

                // input signals
                .index_i(3'd7    ),
                .round_i(round_i ),
                        
                .a      (v_i_temp[ 3]),
                .b      (v_i_temp[ 4]),
                .c      (v_i_temp[ 9]),
                .d      (v_i_temp[14]),
                                        
                // signals to sigma table     
                .sigma_column_o_0(sigma_column_6),
                .sigma_row_o_0   (sigma_row_6   ),
                .mindex_i_0      (m_index_6     ),
                                  
                .sigma_column_o_1(sigma_column_7),
                .sigma_row_o_1   (sigma_row_7   ),
                .mindex_i_1      (m_index_7     ),
                                 
                // signals to message reg
                .mindex_o_0      (mindex_bus_temp[6]),
                .m_i_0           (m_bus_temp[6]),

                .mindex_o_1      (mindex_bus_temp[7]),
                .m_i_1           (m_bus_temp[7]),
                                 
                // output signals
                .a_o   (v_o_temp[ 3]),
                .b_o   (v_o_temp[ 4]),
                .c_o   (v_o_temp[ 9]),
                .d_o   (v_o_temp[14])
            );

        end
    endgenerate


    blake2b_sigma blake2b_sigma0 (

        .sigma_column(sigma_column_0),
        .sigma_row   (sigma_row_0   ),
        .m_index     (m_index_0     )
    );

    blake2b_sigma blake2b_sigma1 (
        
        .sigma_column(sigma_column_1),
        .sigma_row   (sigma_row_1   ),
        .m_index     (m_index_1     )
    );


    // Instantiate G1 module

    blake2b_sigma blake2b_sigma2 (

        .sigma_column(sigma_column_2),
        .sigma_row   (sigma_row_2   ),
        .m_index     (m_index_2     )
    );

    blake2b_sigma blake2b_sigma3 (
        
        .sigma_column(sigma_column_3),
        .sigma_row   (sigma_row_3   ),
        .m_index     (m_index_3     )
    );


    blake2b_sigma blake2b_sigma4 (

        .sigma_column(sigma_column_4),
        .sigma_row   (sigma_row_4   ),
        .m_index     (m_index_4     )
    );

    blake2b_sigma blake2b_sigma5 (
        
        .sigma_column(sigma_column_5),
        .sigma_row   (sigma_row_5   ),
        .m_index     (m_index_5     )
    );

    blake2b_sigma blake2b_sigma6 (

        .sigma_column(sigma_column_6),
        .sigma_row   (sigma_row_6   ),
        .m_index     (m_index_6     )
    );

    blake2b_sigma blake2b_sigma7 (
        
        .sigma_column(sigma_column_7),
        .sigma_row   (sigma_row_7   ),
        .m_index     (m_index_7     )
    );

endmodule //blake2b_round





