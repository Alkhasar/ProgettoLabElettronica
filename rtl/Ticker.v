/**
* Tick Counter Module (with Sync Reset)
*
* N_TICKS (param int): Number of clk pulses after wich an output tick is emitted DEFAULT: 1 (Runs as fast as the clock)
*
* clk  (wire in): Always assuming 100Mhz clk in 
* rst  (wire in): Sync reset high
* en   (wire in): Enable
*
* tick (wire out): A single puls
*
*/

`timescale 10 ns / 1 ns

module ticker #(parameter integer N_TICKS = 100) (
    // Inputs
    input wire clk,
    input wire rst,
    input wire en,

    // Outputs
    output reg tick
);
    
    // Using CeilingLog_2 to get the number of bits needed to have a counter with the right size
    reg [$clog2(N_TICKS)-1:0] clk_counts = 'b0;

    // Whenever clk has a transition, check if rst is high. Then, if it's low, check if 
    // counter needs to be resetted (while emitting a tick), else increase the counter and keep tick 
    // low
    always @(posedge clk) begin
        
            if (rst == 1'b1) begin
                tick <= 1'b0;
                clk_counts <= 'b0;
            end
            else begin
                if (en == 1'b1) begin
                    if (clk_counts == N_TICKS - 1) begin
                        clk_counts <= 'b0;
                        tick <= 'b1;    
                    end
                    else begin
                        clk_counts <= clk_counts + 'b1;
                        tick <= 'b0; 
                    end
                end
            end
        end


endmodule