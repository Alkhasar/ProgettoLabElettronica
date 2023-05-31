// Real setup testbench

`timescale 10ns / 1ns

module tb_top();
    /**
    * SIMULATION CLOCK GENERATOR
    **/
    wire fpga_clk;
    tb_sim_clk #(.PERIOD(10.0)) ClkGen (.clk(fpga_clk));

    // Main reset
    reg rst = 1'b1;
    
    /**
    * TOP_MODULE INSTANCE
    **/
    reg [7:0] DB = 8'd0;
    reg INT = 1'd0;
    wire WR;

    top TOP (
        // Main signals
        .clk(fpga_clk),
        .rst(rst),

        // ADC Signals
        .INT(INT),
        .DB(DB),
        .WR(WR)
    );
    
    initial begin
        // Keeping everything resetted (SAME as GSR)
        #10 rst = 1'b0;         // After 100ns

        // Stop simulation
        #1000 $finish;
    end

    always @(posedge TOP.tick) begin
        // Conversion stimulus
        #100 INT = 1'b1;  
        #100 INT = 1'b0;

        // Assiging a value o data bus
        #1 DB = {$random} %255;
        #20 DB = 8'd0;
    end 


endmodule