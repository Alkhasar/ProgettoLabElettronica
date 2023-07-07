/**
* posedge detector
*
* clk  (wire in): Always assuming 100Mhz clk in 
* logic_signal  (wire in): Level logic signal
*
* pulse_signal (reg out): A single pulse output signal
*
*/
`timescale 10 ns / 1 ns

module posedge_detector(
    input wire clk,
    input wire logic_signal,
    output reg pulse_signal
);

    reg delayed_signal = 1'b0;
    always @(posedge clk) begin
        delayed_signal <= logic_signal; 
    end
    assign pulse_signal = logic_signal & delayed_signal;


endmodule