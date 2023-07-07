/**
* ADC driver implementation uing a Moore State Machine with 3 always loop
* - Output changes 1 clk pulse later
* - Current output depends only on current state
*
* PERSONAL CHANGES:
* - To comply with vivado design suggestions, sync reset active high
*
* ┌──────────────────────────────────────────────────────────────────────────┐
* │                                         OUTPUT LOGIC & REGISTERS         │
* │                                   ┌──────────────────────────────────┐   │
* │                                   │                                  │   │
* │                                   │      COMB           SEQU         │   │
* │                                   │      LOGIC          LOGIC        │   │
* │                                   │    ┌───────┐       ┌───────┐     │   │
* │                                   │    │       │       │       │  WR │   │
* │                                   │    │       │       │       ├─────┼──►│
* │                           3b NEXT │    │       │       │       │ BUSY│   │
* │                          ┌────────┼───►│  OUT  ├──────►│  OUT  ├─────┼──►│
* │                          │        │    │ LOGIC │       │  F/F  │ DATA│   │
* │                          │        │    │       │    ┌─►│►      ├─────┼──►│
* │                          │        │    └───────┘    │  └───────┘     │   │
* │                          │        │                 │                │   │
* │  NEXT STATE              │        └─────────────────┼────────────────┘   │
* │  SEQ LOGIC     COMB      │    SEQU                  │                    │
* │                LOGIC     │    LOGIC                 │                    │
* │              ┌───────┐   │  ┌───────┐               │                    │
* │  ADC INPUTS  │       │   │  │       │ CLKED PRESENT │                    │
* │  ───────────►│       │   │  │       │ STATE LOGIC   │                    │
* │  COUNTER 11b │ NEXT  │   │  │PRESENT│               │                    │
* │  ───────────►│ STATE ├───┴─►│ STATE ├──┐            │                    │
* │              │ LOGIC │      │  F/F  │  │            │                    │
* │         ┌───►│       │   ┌─►│►      │  │ 3b STATE   │                    │
* │         │    └───────┘   │  └───────┘  │            │                    │
* │  CLK    │                │             │            │                    │
* │  ───────┼────────────────┴─────────────┼────────────┘                    │
* │         │                              │                                 │
* │         └──────────────────────────────┘                                 │
* │                                                                          │
* └──────────────────────────────────────────────────────────────────────────┘
*  
*   clk         (wire in)   : Main fpga clk
*   acquire     (wire in)   : Signal to start a conversion
*   rst         (wire in)   : Sync reset active high
*
*   busy        (reg out)   : Conversion ongoing flag
*   ready       (reg out)   : Data ready flag
*   data        (wire out)  : Serial Data wire connected
*
*   S_DATA      (wire in)   : ADC serial data in
*   S_CLK       (reg out)   : ADC serial clk
*   CONV_ST     (reg out)   : ADC start conversion signal
*
**/

`timescale 10 ns / 1 ns

`define TIME_BITS 12
`define DATA_BITS 10


module adc_driver(
    // Base Inputs
    input wire clk,
    input wire acquire,
    input wire rst,
    input wire serial_clk,

    // Outputs
    output reg busy,
    output reg ready,
    output reg data,
 
    // Chip PINS
    input wire S_DATA,                      // Data Bus
    output reg S_CLK,                      // Interrupt
    output reg CONV_ST                      // Write

);
    // ADC driver SCLK enable
    reg S_CLK_EN;

    // FSM state regs
    reg [2:0] state, next;

    // States parameter
    parameter [2:0]
        INIT                    = 3'b000,
        WAIT_POWERUP            = 3'b001,
        IDLE                    = 3'b010,
        CONVST_DOWN             = 3'b011,
        CONVST_UP               = 3'b100,
        WAIT_CONV               = 3'b101,
        READ_DATA               = 3'b110,
        WAIT_RESET              = 3'b111;

    // Counter to keep track of passed time (COUNTS AS FSM INPUT)
    wire [`TIME_BITS - 1:0] passed_time;
    reg counter_enable, counter_reset;
    counter #(.N_BITS(`TIME_BITS)) adc_driver_counter (.clk(clk), .rst(counter_reset), .en(counter_enable), .count(passed_time));
    
    // Serial data counter
    wire [`DATA_BITS - 1:0] read_data;
    reg data_counter_enable, data_counter_reset;
    counter #(.N_BITS(`DATA_BITS)) output_data_counter (.clk(serial_clk), .rst(data_counter_reset), .en(data_counter_enable), .count(read_data));


    // Main always loop to reset or start reading data
    always @(posedge clk) begin
        if (rst == 1'b1)    state <= INIT;
        else                state <= next;
    end

    // Next state combinational logic
    always @(state or passed_time or read_data or acquire) begin
        // Simulation trick to check non setted transitions
        next = 'bx;
        case(state)
            INIT                :   if(passed_time == 12'd10)   next = WAIT_POWERUP;
                                    else                        next = INIT; 
            WAIT_POWERUP        :   if(passed_time == 12'd170)  next = IDLE;
                                    else                        next = WAIT_POWERUP;
            IDLE                :   if(acquire == 1'b1)         next = CONVST_DOWN;
                                    else                        next = IDLE;
            CONVST_DOWN         :   if(passed_time == 12'd3)    next = CONVST_UP;
                                    else                        next = CONVST_DOWN;
            CONVST_UP           :                               next = WAIT_CONV;
            WAIT_CONV           :   if(passed_time == 12'd233)  next = READ_DATA;
                                    else                        next = WAIT_CONV;
            READ_DATA           :   if(read_data == 4'd10)      next = WAIT_RESET;
                                    else                        next = READ_DATA;
            WAIT_RESET          :   if(passed_time == 12'd4)    next = IDLE;
                                    else                        next = WAIT_RESET;
            default             :   next = IDLE ; // May be removed
        endcase
    end

    
    // Assigning data to S_DATA
    assign data     = S_DATA     & S_CLK_EN;
    assign S_CLK    = serial_clk & S_CLK_EN;

    // Outputs sequential logic
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            // ADC outputs
            S_CLK_EN            <= 1'b0;
            CONV_ST             <= 1'b1;

            // Internal output
            busy                <= 1'b0;
            ready               <= 1'b1;

            // Timer regs
            counter_reset       <= 1'b1;
            counter_enable      <= 1'b0;

            // Data counter regs
            data_counter_reset  <= 1'b1;
            data_counter_enable <= 1'b0;
        end
        else begin
            case(next)
                INIT            :   begin
                                        // ADC Outputs
                                        S_CLK_EN        <= 1'b0;
                                        CONV_ST         <= 1'b0;

                                        // Internal Outputs
                                        busy            <= 1'b1;
                                        ready           <= 1'b0;
    
                                        // Counter regs             
                                        counter_reset   <= 1'b0;
                                        counter_enable  <= 1'b1;

                                        // Data counter regs
                                        data_counter_reset  <= 1'b1;
                                        data_counter_enable <= 1'b0;
                                    end
                
                WAIT_POWERUP    :   begin
                                        // ADC Outputs
                                        S_CLK_EN        <= 1'b0;
                                        CONV_ST         <= 1'b1;

                                        // Internal Outputs
                                        busy            <= 1'b1;
                                        ready           <= 1'b0;
    
                                        // Counter regs             
                                        counter_reset   <= 1'b0;
                                        counter_enable  <= 1'b1;
                                        
                                        // Data counter regs
                                        data_counter_reset  <= 1'b1;
                                        data_counter_enable <= 1'b0;
                                    end

                IDLE            :   begin
                                        // ADC Outputs
                                        S_CLK_EN           <= 1'b0;
                                        CONV_ST         <= 1'b1;

                                        // Internal Outputs
                                        busy            <= 1'b0;
                                        ready           <= 1'b0;
    
                                        // Counter regs             
                                        counter_reset   <= 1'b1;
                                        counter_enable  <= 1'b0;
                                        
                                        // Data counter regs
                                        data_counter_reset  <= 1'b1;
                                        data_counter_enable <= 1'b0;
                                    end

                CONVST_DOWN     :   begin
                                        // ADC Outputs
                                        S_CLK_EN        <= 1'b0;
                                        CONV_ST         <= 1'b0;

                                        // Internal Outputs
                                        busy            <= 1'b1;
                                        ready           <= 1'b0;
    
                                        // Counter regs             
                                        counter_reset   <= 1'b0;
                                        counter_enable  <= 1'b1;
                                        
                                        // Data counter regs
                                        data_counter_reset  <= 1'b1;
                                        data_counter_enable <= 1'b0;
                                    end

                CONVST_UP       :   begin
                                        // ADC Outputs
                                        S_CLK_EN        <= 1'b0;
                                        CONV_ST         <= 1'b1;

                                        // Internal Outputs
                                        busy            <= 1'b1;
                                        ready           <= 1'b0;
    
                                        // Counter regs             
                                        counter_reset   <= 1'b0;
                                        counter_enable  <= 1'b1;
                                        
                                        // Data counter regs
                                        data_counter_reset  <= 1'b1;
                                        data_counter_enable <= 1'b0;
                                    end

                WAIT_CONV       :   begin
                                        // ADC Outputs
                                        S_CLK_EN        <= 1'b0;
                                        CONV_ST         <= 1'b1;

                                        // Internal Outputs
                                        busy            <= 1'b1;
                                        ready           <= 1'b0;
    
                                        // Counter regs             
                                        counter_reset   <= 1'b0;
                                        counter_enable  <= 1'b1;
                                        
                                        // Data counter regs
                                        data_counter_reset  <= 1'b1;
                                        data_counter_enable <= 1'b0;
                                    end

                READ_DATA       :   begin
                                        // ADC Outputs
                                        S_CLK_EN        <= 1'b1;
                                        CONV_ST         <= 1'b1;

                                        // Internal Outputs
                                        busy            <= 1'b1;
                                        ready           <= 1'b1;
    
                                        // Counter regs             
                                        counter_reset   <= 1'b1;
                                        counter_enable  <= 1'b0;
                                        
                                        // Data counter regs
                                        data_counter_reset  <= 1'b0;
                                        data_counter_enable <= 1'b1;
                                    end

                WAIT_RESET       :   begin
                                        // ADC Outputs
                                        S_CLK_EN        <= 1'b0;
                                        CONV_ST         <= 1'b1;

                                        // Internal Outputs
                                        busy            <= 1'b1;
                                        ready           <= 1'b0;

                                        // Counter regs             
                                        counter_reset   <= 1'b0;
                                        counter_enable  <= 1'b1;
                                        
                                        // Data counter regs
                                        data_counter_reset  <= 1'b1;
                                        data_counter_enable <= 1'b0;
                                    end
            endcase
        end
    end
    
endmodule
