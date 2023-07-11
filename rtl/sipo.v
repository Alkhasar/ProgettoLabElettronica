/**
* Serial in parallel out
*
* Module used to turn serial data into a bus
*
* clk       (wire in): Always assuming 100Mhz clk in 
* rst       (wire in): Sync reset high
* serial_in (wire in): Serial input
*
* bus_out   (wire out): Parallel output
*
*/
`timescale 10 ns / 1 ns

module sipo (
    input wire clk,
    input wire rst,   
    input wire serial_in,
    output wire [15:0] bus_out
);

    reg [15:0] shift_register;
    always @(negedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            shift_register <= {16{1'b0}};
        end
        else begin
            shift_register <= {shift_register[14:0], serial_in};
        end
    end
    assign bus_out = shift_register;

endmodule
