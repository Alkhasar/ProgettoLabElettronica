/**
*   Top Module for the CCD array DAQ
*
*   clk (wire in): Main FPGA clock
*   rst (wire in): Main async reset
*
*   INT (wire in): ADC interrupt
*   DB  (bus wire in): ADC data bus
*   WR  (wire out): Write operation
*/

`timescale 10 ns / 1 ns

module top (
    // Base inputs
    input wire fpga_clk,
    input wire button_rst,
    input wire start_switch,

    // ADC Connections
    input wire S_DATA,
    output wire S_CLK,
    output wire CONV_ST,

    // DEBUG STUFF
    output wire adc_busy, adc_ready,
    output wire adc_data
);


    // PLL Instance
    wire clk, pll_locked ;
    PLL  PLL_inst (.reset(button_rst), .CLK_IN(fpga_clk), .CLK_OUT(clk), .LOCKED(pll_locked) ) ;   // generates 100 MHz output clock with maximum input-jitter filtering

    // Assigning with either pll_lock or b utton reset
    wire rst = ~pll_locked | button_rst;

    wire serial_tick;
    reg adc_tick = 1'd0;
    reg en = 1'b1;

    // 460800 baud rate -> 2.170us, 11.520kB/s
    ticker #(.N_TICKS(217)) SERIAL_TICKER (
         // Inputs
        .clk(clk),
        .rst(rst),
        .en(en),
        .tick(serial_tick)
    );

    // 100us acquisition
    // ticker #(.N_TICKS(4340)) ADC_ACQUISITION (
    //      // Inputs
    //     .clk(clk),
    //     .rst(rst),
    //     .en(en),
    //     .tick(adc_tick)
    // );

    wire logical_signal = adc_busy | start_switch;
    posedge_detector POSEDGE_DETECTOR (.clk(clk), .logic_signal(logical_signal), .pulse_signal(adc_tick));


    wire acquire_signal = adc_tick & start_switch;

    adc_driver ADC_DRIVER (
        // Inputs
        .clk(clk),
        .acquire(acquire_signal),
        .rst(rst),
        .serial_clk(serial_tick),
        .S_DATA(S_DATA),

        // Outputs
        .busy(adc_busy),
        .ready(adc_ready),
        .data(adc_data),
        .S_CLK(S_CLK),
        .CONV_ST(CONV_ST)
    );


endmodule