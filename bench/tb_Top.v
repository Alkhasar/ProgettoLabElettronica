/**
* Test bench module for top.v
*/

`timescale 10ns / 1ns

module tb_Top();

    // Main reset
    reg rst = 1'b1;

    /**
    * SIMULATION CLOCK GENERATOR
    **/
    reg fpga_clk;
    tb_SimulationClockGenerator #(.PERIOD(10.0)) ClkGen (.clk(fpga_clk));

    /**
    * TB_TICKER
    **/
    reg tick;
    Ticker ticker_DUT (.clk(fpga_clk), .rst(rst), .tick(tick));

    Top MAIN (.clk(fpga_clk), .rst(rst));

    initial begin
        #0 rst = 1b'1;
        #100 rst = 1'b0;
        #300 rst = 1'b1;
        #400 rst = 1'b0;
        #999 rst = 1'b1;
        #1000 rst = 1'b0;
        #5000 $finish;
    end

endmodule