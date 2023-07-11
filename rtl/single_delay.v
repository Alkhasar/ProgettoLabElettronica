/**
* Serial in parallel out
*
* Single FLIP-FLOP delay line (needs a DONT_TOUCH)
*
* clk           (wire in): Always assuming 100Mhz clk in 
* line_in       (wire in): Input signal
* line_out      (wire in): Delayed output
*
*/
`timescale 10 ns / 1 ns

module  single_delay (
    input wire clk,
    input wire line_in,
    output reg line_out
);

    always @(negedge clk) begin
        line_out = line_in;
    end

endmodule