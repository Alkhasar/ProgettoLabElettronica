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

`timescale 10ns / 1ns

module top (
    // Base inputs
    input wire clk,
    input wire rst,

    // ADC Connections
    input wire INT,
    input wire [7:0] DB,
    output wire WR,

    // DEBUG STUFF
    output wire adc_busy, adc_ready,
    output wire [7:0] adc_data
);

    wire tick;
    reg en = 1'b1;

    ticker #(.N_TICKS(500)) TEST_TICKER (
         // Inputs
        .clk(clk),
        .rst(rst),
        .en(en),
        .tick(tick)
    );

    
    // wire adc_busy, adc_ready;
    // wire [7:0] adc_data;

    adc_driver ADC_DRIVER (
        // Inputs
        .clk(clk),
        .acquire(tick),
        .rst(rst),
        .INT(INT),
        .DB(DB),

        // Outputs
        .busy(adc_busy),
        .ready(adc_ready),
        .data(adc_data),
        .WR(WR)
    );

endmodule