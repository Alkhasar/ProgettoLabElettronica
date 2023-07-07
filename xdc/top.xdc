################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

#######################################
##   on-board 100 MHz clock signal   ##
#######################################
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports fpga_clk] ;

#############
## REG2REG ##
#############
create_clock -period 10.000 -name fpga_clk -waveform {0.000 5.000} -add [get_ports fpga_clk];

############
## IN2REG ##
############
## constrain the in2reg timing paths (assume approx. 1/2 clock period)
# set_input_delay -clock fpga_clk 2.000 [get_ports CONV_ST];
set_input_delay -clock fpga_clk 2.000 [get_ports S_DATA];
set_input_delay -clock fpga_clk 2.000 [get_ports button_rst];
set_input_delay -clock fpga_clk 2.000 [get_ports start_switch];

#############
## REG2OUT ##
#############
## constrain the reg2out timing paths (assume approx. 1/2 clock period)
# set_output_delay -clock fpga_clk 7.000 [get_ports WR]
# set_output_delay -clock fpga_clk 7.000 [get_ports adc_busy];
# set_output_delay -clock fpga_clk 7.000 [get_ports adc_ready];
# set_output_delay -clock fpga_clk 7.000 [get_ports adc_data*];

############
## IN2OUT ##
############
set_max_delay 5 -from [all_inputs] -to [all_outputs]

######################
##   push-buttons   ##
######################
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports button_rst];              # BUTTON 0


######################
##   push-buttons   ##
######################
set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33 } [get_ports start_switch];           # SWITCH 0


########################
##   Pmod header JA   ##
########################
set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports CONV_ST];                # Ja[1]
set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS33 } [get_ports S_CLK];                  # Ja[2]
set_property -dict { PACKAGE_PIN A11  IOSTANDARD LVCMOS33 } [get_ports adc_busy];               # Ja[3] 
set_property -dict { PACKAGE_PIN D12  IOSTANDARD LVCMOS33 } [get_ports adc_ready];              # Ja[4]


########################
##   Pmod Header JB   ##
######################## 
set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports  adc_data ]; # Jb[1] 
# set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { adc_data[1] }]; # Jb[2]  
# set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { adc_data[2] }]; # Jb[3] 
# set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { adc_data[3] }]; # Jb[4] 
# set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { adc_data[4] }]; # Jb[5] 
# set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { adc_data[5] }]; # Jb[6] 
# set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { adc_data[6] }]; # Jb[7]
# set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { adc_data[7] }]; # Jb[8] 

########################
##   Pmod Header JD   ##
######################## 
set_property -dict { PACKAGE_PIN D4  IOSTANDARD LVCMOS33 } [get_ports S_DATA ]; # Jd[1] 
# set_property -dict { PACKAGE_PIN D3  IOSTANDARD LVCMOS33 } [get_ports { DB[1] }]; # Jd[2] 
# set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 } [get_ports { DB[2] }]; # Jd[3] 
# set_property -dict { PACKAGE_PIN F3  IOSTANDARD LVCMOS33 } [get_ports { DB[3] }]; # Jd[4] 
# set_property -dict { PACKAGE_PIN E2  IOSTANDARD LVCMOS33 } [get_ports { DB[4] }]; # Jd[5] 
# set_property -dict { PACKAGE_PIN D2  IOSTANDARD LVCMOS33 } [get_ports { DB[5] }]; # Jd[6] 
# set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports { DB[6] }]; # Jd[7]
# set_property -dict { PACKAGE_PIN G2  IOSTANDARD LVCMOS33 } [get_ports { DB[7] }]; # Jd[8] 

################################
##   additional constraints   ##
################################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design];
set_property CONFIG_MODE SPIx4  [current_design];