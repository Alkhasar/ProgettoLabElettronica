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
* │  COUNTER 8b  │ NEXT  │   │  │PRESENT│               │                    │
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
*   data [7:0]  (wire out)  : Data Bus connected to data_memory
*
*   INT         (wire in)   : ADC interrupt signal conversion done
*   DB [7:0]    (wire in)   : ADC Data Bus
*   WR          (reg out)   : ADC start conversion signal
*
**/

`timescale 10ns / 1ns
`define TIME_BITS 7

module adc_driver(
    // Base Inputs
    input wire clk,
    input wire acquire,
    input wire rst,

    // Outputs
    output reg busy,
    output reg ready,
    output wire [7:0] data,

    // Chip PINS
    input wire INT,             // Interrupt
    input wire [7:0] DB,       // Data Bus
    output reg WR               // Write

);
    // FSM state regs
    reg [2:0] state, next;

    // States parameter
    parameter [2:0]
        IDLE                    = 3'b000,
        WR_LOW                  = 3'b001,
        WAIT_INT_UP             = 3'b010,
        WAIT_INT_DOWN           = 3'b011,
        WAIT_ACCESS             = 3'b100,
        READ_DATA               = 3'b101,
        WAIT_RESET              = 3'b110;

    // Counter to keep track of passed time (COUNTS AS FSM INPUT)
    wire [`TIME_BITS - 1:0] passed_time;
    reg clk_enable, clk_reset;
    counter #(.N_BITS(`TIME_BITS)) adc_driver_counter (.clk(clk), .rst(clk_reset), .en(clk_enable), .count(passed_time));

    // Reg to save DB data
    reg [7:0] old_data;

    // Main always loop to reset or start reading data
    always @(posedge clk) begin
        if (rst == 1'b1)    state <= IDLE;
        else                state <= next;
    end

    // Next state combinational logic
    always @(state or passed_time or INT or acquire) begin
        // Simulation trick to check non setted transitions
        next = 'bx;
        case(state)
            IDLE                :   if(acquire == 1'b1)         next = WR_LOW;
                                    else                        next = IDLE;                       
            WR_LOW              :   if(passed_time == 8'd80)    next = WAIT_INT_UP;
                                    else                        next = WR_LOW;
            WAIT_INT_UP         :   if(INT == 1'b1)             next = WAIT_INT_DOWN;
                                    else                        next = WAIT_INT_UP;
            WAIT_INT_DOWN       :   if(INT == 1'b0)             next = WAIT_ACCESS;
                                    else                        next = WAIT_INT_DOWN;
            WAIT_ACCESS         :   if(passed_time == 8'd10)    next = READ_DATA;
                                    else                        next = WAIT_ACCESS;
            READ_DATA           :                               next = WAIT_RESET;
            WAIT_RESET          :   if(passed_time == 8'd60)    next = IDLE;
                                    else                        next = WAIT_RESET;
            default             :   next = IDLE ; // May be removed
        endcase
    end

    // Outputs sequential logic
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            // Outputs
            WR          <= 1'b1;
            busy        <= 1'b0;
            ready       <= 1'b1;

            // Internal regs
            old_data    <= 8'b0;
            clk_reset   <= 1'b1;
            clk_enable  <= 1'b0;
        end
        else begin
            case(next)
                IDLE            :   begin
                                        // Outputs
                                        WR          <= 1'b1;
                                        busy        <= 1'b0;
                                        ready       <= 1'b1;
    
                                        // Internal regs              
                                        clk_reset   <= 1'b1;
                                        clk_enable  <= 1'b0;
                                    end
                WR_LOW          :   begin
                                        WR          <= 1'b0;
                                        busy        <= 1'b1;
                                        ready       <= 1'b0;
    
                                        // Internal regs              
                                        clk_reset   <= 1'b0;
                                        clk_enable  <= 1'b1;
                                    end
                WAIT_INT_UP     :   begin
                                        WR          <= 1'b1;
                                        busy        <= 1'b1;
                                        ready       <= 1'b0;

                                        // Internal regs              
                                        clk_reset   <= 1'b1;
                                        clk_enable  <= 1'b0;
                                    end 
                WAIT_INT_DOWN   :   begin
                                        WR          <= 1'b1;
                                        busy        <= 1'b1;
                                        ready       <= 1'b0;

                                        // Internal regs              
                                        clk_reset   <= 1'b1;
                                        clk_enable  <= 1'b0;
                                    end
                WAIT_ACCESS     :   begin
                                        WR          <= 1'b1;
                                        busy        <= 1'b1;
                                        ready       <= 1'b0;

                                        // Internal regs              
                                        clk_reset   <= 1'b0;
                                        clk_enable  <= 1'b1;
                                    end
                READ_DATA       :   begin
                                        WR          <= 1'b1;
                                        busy        <= 1'b1;
                                        ready       <= 1'b0;

                                        // Internal regs              
                                        clk_reset   <= 1'b1;
                                        clk_enable  <= 1'b0;

                                        // Assigning DB data to old_data
                                        old_data    <= {DB[7], DB[6], DB[5], DB[4], DB[3], DB[2], DB[1], DB[0]};
                                    end
                WAIT_RESET      :   begin
                                        WR          <= 1'b1;
                                        busy        <= 1'b1;
                                        ready       <= 1'b1;

                                        // Internal regs              
                                        clk_reset   <= 1'b0;
                                        clk_enable  <= 1'b1;
                                    end
            endcase
        end
    end

    assign data = old_data;

    
endmodule
