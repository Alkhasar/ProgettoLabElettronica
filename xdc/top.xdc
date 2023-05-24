################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#######################################
##   on-board 100 MHz clock signal   ##
#######################################
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk];
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]

######################
##   push-buttons   ##
######################
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports rst];

################################
##   additional constraints   ##
################################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4  [current_design]
set_property CONFIG_MODE SPIx4  [current_design]