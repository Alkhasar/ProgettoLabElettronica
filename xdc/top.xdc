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
set_input_delay -clock fpga_clk 2.000 [get_ports S_DATA];
set_input_delay -clock fpga_clk 2.000 [get_ports button_rst];
set_input_delay -clock fpga_clk 2.000 [get_ports en];

############
## IN2OUT ##
############
set_max_delay 5 -from [all_inputs] -to [all_outputs]

######################
##   push-buttons   ##
######################
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports button_rst];      # BUTTON 0

########################
##   slide switches   ##
########################
set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33 } [get_ports en];             # SWITCH 0

############################
##   USB-UART Interface   ##
############################
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports TxD]  ;           #IO_L19N_T3_VREF_16 Sch=uart_rxd_out


########################
##   Pmod header JA   ##
########################
set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports CONV_ST]     ; # Ja[1]
set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS33 } [get_ports S_CLK]       ; # Ja[2]
set_property -dict { PACKAGE_PIN A11  IOSTANDARD LVCMOS33 } [get_ports S_DATA]      ; # Ja[3] 
set_property -dict { PACKAGE_PIN D12  IOSTANDARD LVCMOS33 } [get_ports adc_busy]    ; # Ja[4]
set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVCMOS33 } [get_ports adc_ready]   ; #IO_L6N_T0_VREF_15 Sch=ja[7]
set_property -dict { PACKAGE_PIN B18  IOSTANDARD LVCMOS33 } [get_ports tx_probe]    ; #IO_L10P_T1_AD11P_15 Sch=ja[8]
set_property -dict { PACKAGE_PIN A18  IOSTANDARD LVCMOS33 } [get_ports tx_busy]     ; #IO_L10N_T1_AD11N_15 Sch=ja[9]
set_property -dict { PACKAGE_PIN K16  IOSTANDARD LVCMOS33 } [get_ports tx_clk]      ; #IO_25_15 Sch=ja[10]


########################
##   Pmod Header JB   ##
########################

set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports  deser_out[0]]   ; #IO_L11P_T1_SRCC_15 Sch=jb_p[1]
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports  deser_out[1]]   ; #IO_L11N_T1_SRCC_15 Sch=jb_n[1]
set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports  deser_out[2]]   ; #IO_L12P_T1_MRCC_15 Sch=jb_p[2]
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports  deser_out[3]]   ; #IO_L12N_T1_MRCC_15 Sch=jb_n[2]
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports  deser_out[4]]   ; #IO_L23P_T3_FOE_B_15 Sch=jb_p[3]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports  deser_out[5]]   ; #IO_L23N_T3_FWE_B_15 Sch=jb_n[3]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports  deser_out[6]]   ; #IO_L24P_T3_RS1_15 Sch=jb_p[4]
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports  deser_out[7]]   ; #IO_L24N_T3_RS0_15 Sch=jb_n[4]

########################
##   Pmod Header JC   ##
########################
set_property -dict { PACKAGE_PIN U12  IOSTANDARD LVCMOS33 } [get_ports deser_out[8]]    ; #IO_L20P_T3_A08_D24_14 Sch=jc_p[1]
set_property -dict { PACKAGE_PIN V12  IOSTANDARD LVCMOS33 } [get_ports deser_out[9]]    ; #IO_L20N_T3_A07_D23_14 Sch=jc_n[1]
set_property -dict { PACKAGE_PIN V10  IOSTANDARD LVCMOS33 } [get_ports deser_out[10]]   ; #IO_L21P_T3_DQS_14 Sch=jc_p[2]
set_property -dict { PACKAGE_PIN V11  IOSTANDARD LVCMOS33 } [get_ports deser_out[11]]   ; #IO_L21N_T3_DQS_A06_D22_14 Sch=jc_n[2]
set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports deser_out[12]]   ; #IO_L22P_T3_A05_D21_14 Sch=jc_p[3]
set_property -dict { PACKAGE_PIN V14  IOSTANDARD LVCMOS33 } [get_ports deser_out[13]]   ; #IO_L22N_T3_A04_D20_14 Sch=jc_n[3]
set_property -dict { PACKAGE_PIN T13  IOSTANDARD LVCMOS33 } [get_ports deser_out[14]]   ; #IO_L23P_T3_A03_D19_14 Sch=jc_p[4]
set_property -dict { PACKAGE_PIN U13  IOSTANDARD LVCMOS33 } [get_ports deser_out[15]]   ; #IO_L23N_T3_A02_D18_14 Sch=jc_n[4]



################################
##   additional constraints   ##
################################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design];
set_property CONFIG_MODE SPIx4  [current_design];