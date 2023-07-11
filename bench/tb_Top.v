// Real setup testbench

`timescale 10 ns / 1 ns

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
    reg S_DATA = 1'b0;
    reg en = 1'b0;
    wire S_CLK, CONV_ST;

    // Debug wires
    wire adc_busy, adc_ready, TxD, tx_busy;
    // wire [15:0] deser_out;

    top TOP (
        // Main signals
        .fpga_clk(fpga_clk),
        .button_rst(rst),
        .en(en),

        // ADC Signals
        .S_DATA(S_DATA),
        .S_CLK(S_CLK),
        .CONV_ST(CONV_ST),

        // Test signals
        .adc_busy(adc_busy),
        .adc_ready(adc_ready),

        .deser_out(deser_out),

        // UART
        .TxD(TxD),
        .tx_busy(tx_busy)
    );
    
    initial begin
        // Keeping everything resetted (SAME as GSR)
        #10 rst = 1'b0;         // After 100ns

        // Start Button
        #11 en = 1'b1;

        // Stop simulation
        #50000 $finish;
    end

    // External signal
    always @(posedge TOP.S_CLK) begin
        // Assiging a value to data bus
        #1 S_DATA = {$random} % 2;
    end 

endmodule
