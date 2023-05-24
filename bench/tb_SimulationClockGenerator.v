/**
* Test bench module for generating a clk during simulations
*
* PERIOD (param real): clock period in nanoseconds
*/

`timescale 10ns / 1ns

module tb_SimulationClockGenerator #(parameter real PERIOD = 10.0) (
    output reg clk
);
    initial begin
        // Initialising clk
        clk = 1'b0;

        // Inverting clk after half period
        forever #(PERIOD/2.0) clk = ~clk ;
    end
endmodule