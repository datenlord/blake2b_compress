`include "defines.v"
`include "blake2b_compress.v"

//~ `New testbench
`timescale  1ns / 1ps

module testbench (
    
    );

    reg clk = 0, rst = 1;

    reg [`Word_Bus] h [ 7:0];
    reg [`Word_Bus] m [15:0];
    reg [`Word_Bus] t [ 1:0];
    reg [`Word_Bus] f [ 1:0];

    wire [ 8*`Word_Width-1 : 0] h_temp;
    wire [16*`Word_Width-1 : 0] m_temp;
    wire [ 2*`Word_Width-1 : 0] t_temp;
    wire [ 2*`Word_Width-1 : 0] f_temp;

    wire [ 8*`Word_Width-1 : 0] h_o;
    wire [`Word_Bus] h_o_temp [ 7:0];


    genvar i;
    generate
        for ( i = 0; i<16 ;i=i+1 ) begin
            assign m_temp[`Word_Width*(i+1)-1:`Word_Width*i] = m[i];
        end
        for ( i = 0; i<8 ;i=i+1 ) begin
            assign h_temp[`Word_Width*(i+1)-1:`Word_Width*i] = h[i];
            assign h_o_temp[i] = h_o[`Word_Width*(i+1)-1:`Word_Width*i];
        end
        for ( i = 0; i<2 ;i=i+1 ) begin
            assign t_temp[`Word_Width*(i+1)-1:`Word_Width*i] = t[i];
            assign f_temp[`Word_Width*(i+1)-1:`Word_Width*i] = f[i];

        end
    endgenerate


    parameter period = 10;
    initial begin
        clk = 0;
        forever #(period/2) clk = ~clk;
    end

    initial begin
        #period rst = 0;
    end


    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            h[0] <= 0;
            h[1] <= 0;
            h[2] <= 0;
            h[3] <= 0;
            h[4] <= 0;
            h[5] <= 0;
            h[6] <= 0;
            h[7] <= 0;
        end
        else begin
            h[0] <= 0;
            h[1] <= 100000;
            h[2] <= 200000;
            h[3] <= 300000;
            h[4] <= 400000;
            h[5] <= 500000;
            h[6] <= 600000;
            h[7] <= 700000;
        end
    end
    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            f[0] <= 0;
            f[1] <= 0;           
            t[0] <= 0;
            t[1] <= 0;

        end
        else begin
            f[0] <= 100000;
            f[1] <= 200000;
            t[0] <= 300000;
            t[1] <= 500000;
        end
    end

    integer j=0;
        always @(posedge clk) begin
        if(rst == `RstEnable) begin
            for (j = 0; j<16 ;j=j+1 ) begin
                m[j] <= 0;
            end
        end
        else begin
            for (j = 0; j<16 ;j=j+1 ) begin
                m[j] <= j*100000;
            end
        end
    end



    blake2b_compress blake2b_compress_inst(
        .clk(clk),
        .rst(rst),

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
        
        for (j = 0;j<8 ;j=j+1 ) begin
            $display("%h",h_o_temp[j]);
        end
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd"); // 指定用作dumpfile的文件
		$dumpvars; // dump all vars
	end

endmodule //testbench