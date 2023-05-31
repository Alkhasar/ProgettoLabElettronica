/**
* Generic N_BIT counter with syncronized rest active high
*
*   clk (wire in)   : Main fpga clk
*   rst (wire in)   : Sync reset active high
*   en  (wire in)   : Count enable
*
*   count (reg out) : Current count
**/
`timescale 10ns / 1ns

module counter  #(parameter integer N_BITS = 4) (
    // Inputs
    input wire clk,
    input wire rst,
    input wire en,

    // Outputs
    output reg [N_BITS - 1:0] count
);
    
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            count <= 'b0;
        end
        else begin
            if(en == 1'b1) begin
                count <= count + 'b1;
            end
        end
    end

endmodule