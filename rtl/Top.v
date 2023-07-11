/**
*   Top Module for the ADC driver
*
*   fpga_clk        (wire in)   : Main FPGA clock
*   button_rst      (wire in)   : Main async reset
*   en              (wire in)   : Switch enable
*   
*   S_DATA          (wire in)   : Serial data from ADC
*   S_CLK           (wire out)  : Serial ticks used to drive the adc
*   CONV_ST         (wire out)  : Signal to start an acquisition
*
*   adc_busy        (wire out)  : Flag to signal busy adc
*   adc_ready       (wire out)  : Flag to signal adc data is ready
*
*   deser_out       (wire out)  : Serial data probe
*
*   TxD             (wire out)  : Serial transmission pin
*   tx_probe        (wire out)  : Serial transmission probe
*   tx_busy         (wire out)  : Serial busy flag
*   tx_clk          (wire out)  : Serial ticks flag
*/

`timescale 10 ns / 1 ns

module top (
    // Base inputs
    input wire fpga_clk,
    input wire button_rst,
    input wire en,

    // ADC Connections
    input wire S_DATA,
    output wire S_CLK,
    output wire CONV_ST,

    // Sebug wires
    output wire adc_busy, 
    output wire adc_ready,

    output wire [15:0] deser_out,

    // UART
    output wire TxD,
    output wire tx_probe,
    output wire tx_busy,
    output wire tx_clk
);

    //############//
    // PLL MODULE //
    //############//

    // PLL Instance
    wire clk, pll_locked ;
    PLL  PLL_inst (.reset(button_rst), .CLK_IN(fpga_clk), .CLK_OUT(clk), .LOCKED(pll_locked) ) ;   // generates 100 MHz output clock with maximum input-jitter filtering

    // Assigning with either pll_lock or b utton reset
    wire rst = ~pll_locked | button_rst;

    //#########//
    // TICKERS //
    //#########//

    wire serial_tick, adc_tick, acquisition_tick;

    // 460800 baud rate -> 2.170us, 11.520kB/s
    assign tx_clk = serial_tick;
    ticker #(.N_TICKS(217)) SERIAL_TICKER (
        // Inputs
        .clk(clk),
        .rst(rst),
        .en(en),

        // output
        .tick(serial_tick)
    );
    
    // 
    ticker #(.N_TICKS(5)) ADC_TICKER (
        // Inputs
        .clk(clk),
        .rst(rst),
        .en(en),

        // output
        .tick(adc_tick)
    );

    // 43.4 us per acquisition tick
    ticker #(.N_TICKS(6000)) ACQUISITION_TICKER (
         // Inputs
        .clk(clk),
        .rst(rst),
        .en(en),

        // output
        .tick(acquisition_tick)
    );

    //############//
    // ADC DRIVER //
    //############//

    // Gated acquisition signal
    wire acquire_signal = acquisition_tick & en;
    wire adc_data;

    adc_driver ADC_DRIVER (
        // Inputs
        .clk(clk),
        .acquire(acquire_signal),
        .rst(~en),
        .serial_clk(adc_tick),
        .S_DATA(S_DATA),

        // Outputs
        .busy(adc_busy),
        .ready(adc_ready),
        .S_CLK(S_CLK),
        .CONV_ST(CONV_ST),
        .data(adc_data)
    );

    //####################//
    // SINGLE PULSE DELAY //
    //####################//

    wire S_CLK_delayed;
    (* dont_touch = "yes" *) 
    single_delay DELAY (
        .clk(clk),
        .line_in(S_CLK),
        .line_out(S_CLK_delayed)
    );
    
    //########################//
    // SERIAL IN PARALLEL OUT //
    //########################//
    sipo SIPO (
        .clk(S_CLK_delayed),
        .rst(acquire_signal),
        .serial_in(adc_data),
        .bus_out(deser_out)
    );

    //###################//
    // UART transmission //
    //###################//
    assign tx_probe = TxD;
    uart_tx #(.NBYTES(2)) UART_TRASMISSION (
        .clk(clk),
        .tx_start(adc_ready),
        .tx_en(serial_tick),
        .tx_data(deser_out),
        .tx_busy(tx_busy),
        .TxD(TxD)
    );

endmodule