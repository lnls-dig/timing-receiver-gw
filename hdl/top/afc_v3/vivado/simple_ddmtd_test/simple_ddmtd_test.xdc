#######################################################################
##                      Artix 7 AMC V3                               ##
#######################################################################

# FPGA_CLK1_P
set_property IOSTANDARD DIFF_SSTL15              [get_ports sys_clk_p_i]
set_property IN_TERM UNTUNED_SPLIT_50            [get_ports sys_clk_p_i]
# FPGA_CLK1_N
set_property PACKAGE_PIN AL7                     [get_ports sys_clk_n_i]
set_property IOSTANDARD DIFF_SSTL15              [get_ports sys_clk_n_i]
set_property IN_TERM UNTUNED_SPLIT_50            [get_ports sys_clk_n_i]
## BOOT_CLK_IN. This cannot be used
# with DDR3 core as there are different
# I/O standards
#set_property PACKAGE_PIN AE5                    [get_ports boot_clk_i]
#set_property IOSTANDARD LVCMOS25                [get_ports boot_clk_i]
# MGT213_CLK1_N
set_property PACKAGE_PIN AH18                    [get_ports clk_20m_vcxo_n_i]
# MGT213_CLK1_P
set_property PACKAGE_PIN AG18                    [get_ports clk_20m_vcxo_p_i]
# MGT116_CLK1_N
set_property PACKAGE_PIN G14                     [get_ports clk_afc_si57x_n_i]
# MGT116_CLK1_P
set_property PACKAGE_PIN H14                     [get_ports clk_afc_si57x_p_i]

# TXD		IO_25_34
set_property PACKAGE_PIN AB11                    [get_ports rs232_txd_o]
set_property IOSTANDARD LVCMOS25                 [get_ports rs232_txd_o]
# VADJ1_RXD	IO_0_34
set_property PACKAGE_PIN Y11                     [get_ports rs232_rxd_i]
set_property IOSTANDARD LVCMOS25                 [get_ports rs232_rxd_i]

# System Reset
# Bank 16 VCCO - VADJ_FPGA - IO_25_16.
# NET = FPGA_RESET_DN, PIN = IO_L19P_T3_13
set_false_path -through                          [get_nets sys_rst_button_n_i]
set_property PACKAGE_PIN AG26                    [get_ports sys_rst_button_n_i]
set_property IOSTANDARD LVCMOS25                 [get_ports sys_rst_button_n_i]
set_property PULLUP true                         [get_ports sys_rst_button_n_i]

# AFC LEDs
# LED Red - IO_L6P_T0_36
set_property PACKAGE_PIN K10                     [get_ports {leds_o[2]}]
set_property IOSTANDARD LVCMOS25                 [get_ports {leds_o[2]}]
# Led Green - IO_25_36
set_property PACKAGE_PIN L7                      [get_ports {leds_o[1]}]
set_property IOSTANDARD LVCMOS25                 [get_ports {leds_o[1]}]
# Led Blue - IO_0_36
set_property PACKAGE_PIN H12                     [get_ports {leds_o[0]}]
set_property IOSTANDARD LVCMOS25                 [get_ports {leds_o[0]}]

# AFC Si57x
# IO_0_14
set_property PACKAGE_PIN V24                     [get_ports afc_si57x_scl_b]
set_property IOSTANDARD LVCMOS25                 [get_ports afc_si57x_scl_b]
# IO_25_14
set_property PACKAGE_PIN W24                     [get_ports afc_si57x_sda_b]
set_property IOSTANDARD LVCMOS25                 [get_ports afc_si57x_sda_b]
# IO_0_13
set_property PACKAGE_PIN AD23                    [get_ports afc_si57x_oe_o]
set_property IOSTANDARD LVCMOS25                 [get_ports afc_si57x_oe_o]

#######################################################################
##                           Trigger	                             ##
#######################################################################

set_property PACKAGE_PIN AM9                     [get_ports {trig_b[0]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_b[0]}]

set_property PACKAGE_PIN AP11                    [get_ports {trig_b[1]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_b[1]}]

set_property PACKAGE_PIN AP10                    [get_ports {trig_b[2]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_b[2]}]

set_property PACKAGE_PIN AM11                    [get_ports {trig_b[3]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_b[3]}]

set_property PACKAGE_PIN AN8                     [get_ports {trig_b[4]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_b[4]}]

set_property PACKAGE_PIN AP8                     [get_ports {trig_b[5]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_b[5]}]

set_property PACKAGE_PIN AL8                     [get_ports {trig_b[6]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_b[6]}]

set_property PACKAGE_PIN AL9                     [get_ports {trig_b[7]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_b[7]}]

set_property PACKAGE_PIN AJ10                    [get_ports {trig_dir_o[0]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_dir_o[0]}]

set_property PACKAGE_PIN AK11                    [get_ports {trig_dir_o[1]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_dir_o[1]}]

set_property PACKAGE_PIN AJ11                    [get_ports {trig_dir_o[2]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_dir_o[2]}]

set_property PACKAGE_PIN AL10                    [get_ports {trig_dir_o[3]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_dir_o[3]}]

set_property PACKAGE_PIN AM10                    [get_ports {trig_dir_o[4]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_dir_o[4]}]

set_property PACKAGE_PIN AN11                    [get_ports {trig_dir_o[5]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_dir_o[5]}]

set_property PACKAGE_PIN AN9                     [get_ports {trig_dir_o[6]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_dir_o[6]}]

set_property PACKAGE_PIN AP9                     [get_ports {trig_dir_o[7]}]
set_property IOSTANDARD LVCMOS15                 [get_ports {trig_dir_o[7]}]

#######################################################################
##                      AFC Diagnostics Contraints                   ##
#######################################################################

set_property PACKAGE_PIN J9                      [get_ports diag_spi_cs_i]
set_property IOSTANDARD LVCMOS25                 [get_ports diag_spi_cs_i]

set_property PACKAGE_PIN V28                     [get_ports diag_spi_si_i]
set_property IOSTANDARD LVCMOS25                 [get_ports diag_spi_si_i]

set_property PACKAGE_PIN V29                     [get_ports diag_spi_so_o]
set_property IOSTANDARD LVCMOS25                 [get_ports diag_spi_so_o]

set_property PACKAGE_PIN J8                      [get_ports diag_spi_clk_i]
set_property IOSTANDARD LVCMOS25                 [get_ports diag_spi_clk_i]

#######################################################################
##                      ADN4604ASVZ Contraints                      ##
#######################################################################

set_property PACKAGE_PIN U24                     [get_ports adn4604_vadj2_clk_updt_n_o]
set_property IOSTANDARD LVCMOS25                 [get_ports adn4604_vadj2_clk_updt_n_o]
set_property PULLUP true                         [get_ports adn4604_vadj2_clk_updt_n_o]

########################################################################
###                      FMC Connector HPC1                           ##
########################################################################
#
#set_property PACKAGE_PIN H29                     [get_ports fmc1_ha_n_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[0] ]
#set_property PACKAGE_PIN J29                     [get_ports fmc1_ha_p_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[0] ]
#set_property PACKAGE_PIN K28                     [get_ports fmc1_ha_n_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[1] ]
#set_property PACKAGE_PIN L28                     [get_ports fmc1_ha_p_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[1] ]
#set_property PACKAGE_PIN J34                     [get_ports fmc1_ha_n_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[2] ]
#set_property PACKAGE_PIN K33                     [get_ports fmc1_ha_p_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[2] ]
#set_property PACKAGE_PIN J30                     [get_ports fmc1_ha_n_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[3] ]
#set_property PACKAGE_PIN K30                     [get_ports fmc1_ha_p_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[3] ]
#set_property PACKAGE_PIN L34                     [get_ports fmc1_ha_n_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[4] ]
#set_property PACKAGE_PIN L33                     [get_ports fmc1_ha_p_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[4] ]
#set_property PACKAGE_PIN H34                     [get_ports fmc1_ha_n_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[5] ]
#set_property PACKAGE_PIN J33                     [get_ports fmc1_ha_p_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[5] ]
#set_property PACKAGE_PIN K27                     [get_ports fmc1_ha_n_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[6] ]
#set_property PACKAGE_PIN L27                     [get_ports fmc1_ha_p_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[6] ]
#set_property PACKAGE_PIN K32                     [get_ports fmc1_ha_n_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[7] ]
#set_property PACKAGE_PIN L32                     [get_ports fmc1_ha_p_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[7] ]
#set_property PACKAGE_PIN L30                     [get_ports fmc1_ha_n_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[8] ]
#set_property PACKAGE_PIN L29                     [get_ports fmc1_ha_p_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[8] ]
#set_property PACKAGE_PIN J31                     [get_ports fmc1_ha_n_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[9] ]
#set_property PACKAGE_PIN K31                     [get_ports fmc1_ha_p_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[9] ]
#set_property PACKAGE_PIN G32                     [get_ports fmc1_ha_n_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[10]]
#set_property PACKAGE_PIN H32                     [get_ports fmc1_ha_p_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[10]]
#set_property PACKAGE_PIN L25                     [get_ports fmc1_ha_n_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[11]]
#set_property PACKAGE_PIN M25                     [get_ports fmc1_ha_p_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[11]]
#set_property PACKAGE_PIN G34                     [get_ports fmc1_ha_n_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[12]]
#set_property PACKAGE_PIN H33                     [get_ports fmc1_ha_p_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[12]]
#set_property PACKAGE_PIN J25                     [get_ports fmc1_ha_n_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[13]]
#set_property PACKAGE_PIN K25                     [get_ports fmc1_ha_p_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[13]]
#set_property PACKAGE_PIN L24                     [get_ports fmc1_ha_n_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[14]]
#set_property PACKAGE_PIN M24                     [get_ports fmc1_ha_p_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[14]]
#set_property PACKAGE_PIN G30                     [get_ports fmc1_ha_n_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[15]]
#set_property PACKAGE_PIN G29                     [get_ports fmc1_ha_p_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[15]]
#set_property PACKAGE_PIN G31                     [get_ports fmc1_ha_n_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[16]]
#set_property PACKAGE_PIN H31                     [get_ports fmc1_ha_p_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[16]]
#set_property PACKAGE_PIN H28                     [get_ports fmc1_ha_n_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[17]]
#set_property PACKAGE_PIN J28                     [get_ports fmc1_ha_p_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[17]]
#set_property PACKAGE_PIN G27                     [get_ports fmc1_ha_n_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[18]]
#set_property PACKAGE_PIN H27                     [get_ports fmc1_ha_p_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[18]]
#set_property PACKAGE_PIN G26                     [get_ports fmc1_ha_n_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[19]]
#set_property PACKAGE_PIN H26                     [get_ports fmc1_ha_p_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[19]]
#set_property PACKAGE_PIN J26                     [get_ports fmc1_ha_n_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[20]]
#set_property PACKAGE_PIN K26                     [get_ports fmc1_ha_p_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[20]]
#set_property PACKAGE_PIN G25                     [get_ports fmc1_ha_n_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[21]]
#set_property PACKAGE_PIN G24                     [get_ports fmc1_ha_p_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[21]]
#set_property PACKAGE_PIN H24                     [get_ports fmc1_ha_n_i[22]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[22]]
#set_property PACKAGE_PIN J24                     [get_ports fmc1_ha_p_i[22]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[22]]
#set_property PACKAGE_PIN J23                     [get_ports fmc1_ha_n_i[23]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_n_i[23]]
#set_property PACKAGE_PIN K23                     [get_ports fmc1_ha_p_i[23]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_ha_p_i[23]]
#set_property PACKAGE_PIN Y5                      [get_ports fmc1_hb_n_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[0] ]
#set_property PACKAGE_PIN W5                      [get_ports fmc1_hb_p_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[0] ]
#set_property PACKAGE_PIN W8                      [get_ports fmc1_hb_n_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[1] ]
#set_property PACKAGE_PIN W9                      [get_ports fmc1_hb_p_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[1] ]
#set_property PACKAGE_PIN V8                      [get_ports fmc1_hb_n_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[2] ]
#set_property PACKAGE_PIN V9                      [get_ports fmc1_hb_p_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[2] ]
#set_property PACKAGE_PIN Y10                     [get_ports fmc1_hb_n_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[3] ]
#set_property PACKAGE_PIN W10                     [get_ports fmc1_hb_p_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[3] ]
#set_property PACKAGE_PIN Y7                      [get_ports fmc1_hb_n_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[4] ]
#set_property PACKAGE_PIN Y8                      [get_ports fmc1_hb_p_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[4] ]
#set_property PACKAGE_PIN AA9                     [get_ports fmc1_hb_n_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[5] ]
#set_property PACKAGE_PIN AA10                    [get_ports fmc1_hb_p_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[5] ]
#set_property PACKAGE_PIN W4                      [get_ports fmc1_hb_n_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[6] ]
#set_property PACKAGE_PIN V4                      [get_ports fmc1_hb_p_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[6] ]
#set_property PACKAGE_PIN AB9                     [get_ports fmc1_hb_n_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[7] ]
#set_property PACKAGE_PIN AB10                    [get_ports fmc1_hb_p_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[7] ]
#set_property PACKAGE_PIN W3                      [get_ports fmc1_hb_n_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[8] ]
#set_property PACKAGE_PIN V3                      [get_ports fmc1_hb_p_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[8] ]
#set_property PACKAGE_PIN V1                      [get_ports fmc1_hb_n_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[9] ]
#set_property PACKAGE_PIN V2                      [get_ports fmc1_hb_p_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[9] ]
#set_property PACKAGE_PIN V6                      [get_ports fmc1_hb_n_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[10]]
#set_property PACKAGE_PIN V7                      [get_ports fmc1_hb_p_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[10]]
#set_property PACKAGE_PIN Y1                      [get_ports fmc1_hb_n_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[11]]
#set_property PACKAGE_PIN W1                      [get_ports fmc1_hb_p_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[11]]
#set_property PACKAGE_PIN AC6                     [get_ports fmc1_hb_n_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[12]]
#set_property PACKAGE_PIN AC7                     [get_ports fmc1_hb_p_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[12]]
#set_property PACKAGE_PIN Y2                      [get_ports fmc1_hb_n_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[13]]
#set_property PACKAGE_PIN Y3                      [get_ports fmc1_hb_p_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[13]]
#set_property PACKAGE_PIN AC1                     [get_ports fmc1_hb_n_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[14]]
#set_property PACKAGE_PIN AC2                     [get_ports fmc1_hb_p_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[14]]
#set_property PACKAGE_PIN AC8                     [get_ports fmc1_hb_n_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[15]]
#set_property PACKAGE_PIN AC9                     [get_ports fmc1_hb_p_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[15]]
#set_property PACKAGE_PIN AB1                     [get_ports fmc1_hb_n_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[16]]
#set_property PACKAGE_PIN AB2                     [get_ports fmc1_hb_p_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[16]]
#set_property PACKAGE_PIN AA4                     [get_ports fmc1_hb_n_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[17]]
#set_property PACKAGE_PIN AA5                     [get_ports fmc1_hb_p_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[17]]
#set_property PACKAGE_PIN AB6                     [get_ports fmc1_hb_n_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[18]]
#set_property PACKAGE_PIN AB7                     [get_ports fmc1_hb_p_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[18]]
#set_property PACKAGE_PIN AB4                     [get_ports fmc1_hb_n_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[19]]
#set_property PACKAGE_PIN AB5                     [get_ports fmc1_hb_p_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[19]]
#set_property PACKAGE_PIN AA2                     [get_ports fmc1_hb_n_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[20]]
#set_property PACKAGE_PIN AA3                     [get_ports fmc1_hb_p_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[20]]
#set_property PACKAGE_PIN AC3                     [get_ports fmc1_hb_n_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_n_i[21]]
#set_property PACKAGE_PIN AC4                     [get_ports fmc1_hb_p_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_hb_p_i[21]]
#set_property PACKAGE_PIN K6                      [get_ports fmc1_la_n_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[0] ]
#set_property PACKAGE_PIN K7                      [get_ports fmc1_la_p_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[0] ]
#set_property PACKAGE_PIN J5                      [get_ports fmc1_la_n_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[1] ]
#set_property PACKAGE_PIN J6                      [get_ports fmc1_la_p_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[1] ]
#set_property PACKAGE_PIN G6                      [get_ports fmc1_la_n_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[2] ]
#set_property PACKAGE_PIN G7                      [get_ports fmc1_la_p_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[2] ]
#set_property PACKAGE_PIN G1                      [get_ports fmc1_la_n_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[3] ]
#set_property PACKAGE_PIN H1                      [get_ports fmc1_la_p_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[3] ]
#set_property PACKAGE_PIN J1                      [get_ports fmc1_la_n_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[4] ]
#set_property PACKAGE_PIN K1                      [get_ports fmc1_la_p_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[4] ]
#set_property PACKAGE_PIN H3                      [get_ports fmc1_la_n_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[5] ]
#set_property PACKAGE_PIN H4                      [get_ports fmc1_la_p_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[5] ]
#set_property PACKAGE_PIN K5                      [get_ports fmc1_la_n_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[6] ]
#set_property PACKAGE_PIN L5                      [get_ports fmc1_la_p_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[6] ]
#set_property PACKAGE_PIN K2                      [get_ports fmc1_la_n_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[7] ]
#set_property PACKAGE_PIN K3                      [get_ports fmc1_la_p_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[7] ]
#set_property PACKAGE_PIN F2                      [get_ports fmc1_la_n_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[8] ]
#set_property PACKAGE_PIN F3                      [get_ports fmc1_la_p_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[8] ]
#set_property PACKAGE_PIN J3                      [get_ports fmc1_la_n_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[9] ]
#set_property PACKAGE_PIN J4                      [get_ports fmc1_la_p_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[9] ]
#set_property PACKAGE_PIN G2                      [get_ports fmc1_la_n_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[10]]
#set_property PACKAGE_PIN H2                      [get_ports fmc1_la_p_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[10]]
#set_property PACKAGE_PIN L2                      [get_ports fmc1_la_n_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[11]]
#set_property PACKAGE_PIN M2                      [get_ports fmc1_la_p_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[11]]
#set_property PACKAGE_PIN K8                      [get_ports fmc1_la_n_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[12]]
#set_property PACKAGE_PIN L8                      [get_ports fmc1_la_p_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[12]]
#set_property PACKAGE_PIN G9                      [get_ports fmc1_la_n_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[13]]
#set_property PACKAGE_PIN G10                     [get_ports fmc1_la_p_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[13]]
#set_property PACKAGE_PIN H8                      [get_ports fmc1_la_n_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[14]]
#set_property PACKAGE_PIN H9                      [get_ports fmc1_la_p_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[14]]
#set_property PACKAGE_PIN J11                     [get_ports fmc1_la_n_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[15]]
#set_property PACKAGE_PIN K11                     [get_ports fmc1_la_p_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[15]]
#set_property PACKAGE_PIN L9                      [get_ports fmc1_la_n_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[16]]
#set_property PACKAGE_PIN L10                     [get_ports fmc1_la_p_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[16]]
#set_property PACKAGE_PIN T4                      [get_ports fmc1_la_n_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[17]]
#set_property PACKAGE_PIN T5                      [get_ports fmc1_la_p_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[17]]
#set_property PACKAGE_PIN P3                      [get_ports fmc1_la_n_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[18]]
#set_property PACKAGE_PIN P4                      [get_ports fmc1_la_p_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[18]]
#set_property PACKAGE_PIN U4                      [get_ports fmc1_la_n_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[19]]
#set_property PACKAGE_PIN U5                      [get_ports fmc1_la_p_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[19]]
#set_property PACKAGE_PIN P10                     [get_ports fmc1_la_n_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[20]]
#set_property PACKAGE_PIN R10                     [get_ports fmc1_la_p_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[20]]
#set_property PACKAGE_PIN M6                      [get_ports fmc1_la_n_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[21]]
#set_property PACKAGE_PIN M7                      [get_ports fmc1_la_p_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[21]]
#set_property PACKAGE_PIN M4                      [get_ports fmc1_la_n_i[22]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[22]]
#set_property PACKAGE_PIN M5                      [get_ports fmc1_la_p_i[22]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[22]]
#set_property PACKAGE_PIN N2                      [get_ports fmc1_la_n_i[23]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[23]]
#set_property PACKAGE_PIN N3                      [get_ports fmc1_la_p_i[23]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[23]]
#set_property PACKAGE_PIN M10                     [get_ports fmc1_la_n_i[24]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[24]]
#set_property PACKAGE_PIN M11                     [get_ports fmc1_la_p_i[24]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[24]]
#set_property PACKAGE_PIN N7                      [get_ports fmc1_la_n_i[25]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[25]]
#set_property PACKAGE_PIN N8                      [get_ports fmc1_la_p_i[25]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[25]]
#set_property PACKAGE_PIN T2                      [get_ports fmc1_la_n_i[26]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[26]]
#set_property PACKAGE_PIN T3                      [get_ports fmc1_la_p_i[26]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[26]]
#set_property PACKAGE_PIN R2                      [get_ports fmc1_la_n_i[27]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[27]]
#set_property PACKAGE_PIN R3                      [get_ports fmc1_la_p_i[27]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[27]]
#set_property PACKAGE_PIN T7                      [get_ports fmc1_la_n_i[28]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[28]]
#set_property PACKAGE_PIN T8                      [get_ports fmc1_la_p_i[28]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[28]]
#set_property PACKAGE_PIN P8                      [get_ports fmc1_la_n_i[29]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[29]]
#set_property PACKAGE_PIN P9                      [get_ports fmc1_la_p_i[29]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[29]]
#set_property PACKAGE_PIN M1                      [get_ports fmc1_la_n_i[30]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[30]]
#set_property PACKAGE_PIN N1                      [get_ports fmc1_la_p_i[30]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[30]]
#set_property PACKAGE_PIN U6                      [get_ports fmc1_la_n_i[31]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[31]]
#set_property PACKAGE_PIN U7                      [get_ports fmc1_la_p_i[31]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[31]]
#set_property PACKAGE_PIN P1                      [get_ports fmc1_la_n_i[32]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[32]]
#set_property PACKAGE_PIN R1                      [get_ports fmc1_la_p_i[32]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[32]]
#set_property PACKAGE_PIN U1                      [get_ports fmc1_la_n_i[33]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_n_i[33]]
#set_property PACKAGE_PIN U2                      [get_ports fmc1_la_p_i[33]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc1_la_p_i[33]]
#set_property PACKAGE_PIN AM30                    [get_ports fmc2_ha_n_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[0] ]
#set_property PACKAGE_PIN AL30                    [get_ports fmc2_ha_p_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[0] ]
#set_property PACKAGE_PIN AL29                    [get_ports fmc2_ha_n_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[1] ]
#set_property PACKAGE_PIN AL28                    [get_ports fmc2_ha_p_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[1] ]
#set_property PACKAGE_PIN AP31                    [get_ports fmc2_ha_n_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[2] ]
#set_property PACKAGE_PIN AN31                    [get_ports fmc2_ha_p_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[2] ]
#set_property PACKAGE_PIN AN26                    [get_ports fmc2_ha_n_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[3] ]
#set_property PACKAGE_PIN AM26                    [get_ports fmc2_ha_p_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[3] ]
#set_property PACKAGE_PIN AK25                    [get_ports fmc2_ha_n_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[4] ]
#set_property PACKAGE_PIN AJ25                    [get_ports fmc2_ha_p_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[4] ]
#set_property PACKAGE_PIN AM25                    [get_ports fmc2_ha_n_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[5] ]
#set_property PACKAGE_PIN AL25                    [get_ports fmc2_ha_p_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[5] ]
#set_property PACKAGE_PIN AM32                    [get_ports fmc2_ha_n_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[6] ]
#set_property PACKAGE_PIN AL32                    [get_ports fmc2_ha_p_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[6] ]
#set_property PACKAGE_PIN AN32                    [get_ports fmc2_ha_n_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[7] ]
#set_property PACKAGE_PIN AM31                    [get_ports fmc2_ha_p_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[7] ]
#set_property PACKAGE_PIN AN27                    [get_ports fmc2_ha_n_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[8] ]
#set_property PACKAGE_PIN AM27                    [get_ports fmc2_ha_p_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[8] ]
#set_property PACKAGE_PIN AK26                    [get_ports fmc2_ha_n_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[9] ]
#set_property PACKAGE_PIN AJ26                    [get_ports fmc2_ha_p_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[9] ]
#set_property PACKAGE_PIN AP26                    [get_ports fmc2_ha_n_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[10]]
#set_property PACKAGE_PIN AP25                    [get_ports fmc2_ha_p_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[10]]
#set_property PACKAGE_PIN AL33                    [get_ports fmc2_ha_n_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[11]]
#set_property PACKAGE_PIN AK33                    [get_ports fmc2_ha_p_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[11]]
#set_property PACKAGE_PIN AN29                    [get_ports fmc2_ha_n_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[12]]
#set_property PACKAGE_PIN AM29                    [get_ports fmc2_ha_p_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[12]]
#set_property PACKAGE_PIN AP28                    [get_ports fmc2_ha_n_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[13]]
#set_property PACKAGE_PIN AN28                    [get_ports fmc2_ha_p_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[13]]
#set_property PACKAGE_PIN AP34                    [get_ports fmc2_ha_n_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[14]]
#set_property PACKAGE_PIN AN34                    [get_ports fmc2_ha_p_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[14]]
#set_property PACKAGE_PIN AK30                    [get_ports fmc2_ha_n_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[15]]
#set_property PACKAGE_PIN AJ29                    [get_ports fmc2_ha_p_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[15]]
#set_property PACKAGE_PIN AL27                    [get_ports fmc2_ha_n_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[16]]
#set_property PACKAGE_PIN AK27                    [get_ports fmc2_ha_p_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[16]]
#set_property PACKAGE_PIN AK28                    [get_ports fmc2_ha_n_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[17]]
#set_property PACKAGE_PIN AJ28                    [get_ports fmc2_ha_p_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[17]]
#set_property PACKAGE_PIN AP33                    [get_ports fmc2_ha_n_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[18]]
#set_property PACKAGE_PIN AN33                    [get_ports fmc2_ha_p_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[18]]
#set_property PACKAGE_PIN AK31                    [get_ports fmc2_ha_n_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[19]]
#set_property PACKAGE_PIN AJ30                    [get_ports fmc2_ha_p_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[19]]
#set_property PACKAGE_PIN AK32                    [get_ports fmc2_ha_n_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[20]]
#set_property PACKAGE_PIN AJ31                    [get_ports fmc2_ha_p_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[20]]
#set_property PACKAGE_PIN AP30                    [get_ports fmc2_ha_n_i[21]]
#set_property PACKAGE_PIN AP29                    [get_ports fmc2_ha_p_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[21]]
#set_property PACKAGE_PIN AM34                    [get_ports fmc2_ha_n_i[22]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[22]]
#set_property PACKAGE_PIN AL34                    [get_ports fmc2_ha_p_i[22]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[22]]
#set_property PACKAGE_PIN AJ34                    [get_ports fmc2_ha_n_i[23]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_n_i[23]]
#set_property PACKAGE_PIN AJ33                    [get_ports fmc2_ha_p_i[23]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_ha_p_i[23]]
#set_property PACKAGE_PIN T29                     [get_ports fmc2_hb_n_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[0] ]
#set_property PACKAGE_PIN U29                     [get_ports fmc2_hb_p_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[0] ]
#set_property PACKAGE_PIN M27                     [get_ports fmc2_hb_n_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[1] ]
#set_property PACKAGE_PIN N26                     [get_ports fmc2_hb_p_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[1] ]
#set_property PACKAGE_PIN M34                     [get_ports fmc2_hb_n_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[2] ]
#set_property PACKAGE_PIN N34                     [get_ports fmc2_hb_p_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[2] ]
#set_property PACKAGE_PIN T34                     [get_ports fmc2_hb_n_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[3] ]
#set_property PACKAGE_PIN U34                     [get_ports fmc2_hb_p_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[3] ]
#set_property PACKAGE_PIN U27                     [get_ports fmc2_hb_n_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[4] ]
#set_property PACKAGE_PIN U26                     [get_ports fmc2_hb_p_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[4] ]
#set_property PACKAGE_PIN P34                     [get_ports fmc2_hb_n_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[5] ]
#set_property PACKAGE_PIN P33                     [get_ports fmc2_hb_p_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[5] ]
#set_property PACKAGE_PIN P30                     [get_ports fmc2_hb_n_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[6] ]
#set_property PACKAGE_PIN R30                     [get_ports fmc2_hb_p_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[6] ]
#set_property PACKAGE_PIN N24                     [get_ports fmc2_hb_n_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[7] ]
#set_property PACKAGE_PIN P24                     [get_ports fmc2_hb_p_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[7] ]
#set_property PACKAGE_PIN P26                     [get_ports fmc2_hb_n_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[8] ]
#set_property PACKAGE_PIN R26                     [get_ports fmc2_hb_p_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[8] ]
#set_property PACKAGE_PIN R28                     [get_ports fmc2_hb_n_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[9] ]
#set_property PACKAGE_PIN T28                     [get_ports fmc2_hb_p_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[9] ]
#set_property PACKAGE_PIN T25                     [get_ports fmc2_hb_n_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[10]]
#set_property PACKAGE_PIN U25                     [get_ports fmc2_hb_p_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[10]]
#set_property PACKAGE_PIN R27                     [get_ports fmc2_hb_n_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[11]]
#set_property PACKAGE_PIN T27                     [get_ports fmc2_hb_p_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[11]]
#set_property PACKAGE_PIN M32                     [get_ports fmc2_hb_n_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[12]]
#set_property PACKAGE_PIN N31                     [get_ports fmc2_hb_p_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[12]]
#set_property PACKAGE_PIN N28                     [get_ports fmc2_hb_n_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[13]]
#set_property PACKAGE_PIN N27                     [get_ports fmc2_hb_p_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[13]]
#set_property PACKAGE_PIN P31                     [get_ports fmc2_hb_n_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[14]]
#set_property PACKAGE_PIN R31                     [get_ports fmc2_hb_p_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[14]]
#set_property PACKAGE_PIN T30                     [get_ports fmc2_hb_n_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[15]]
#set_property PACKAGE_PIN U30                     [get_ports fmc2_hb_p_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[15]]
#set_property PACKAGE_PIN U32                     [get_ports fmc2_hb_n_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[16]]
#set_property PACKAGE_PIN U31                     [get_ports fmc2_hb_p_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[16]]
#set_property PACKAGE_PIN P29                     [get_ports fmc2_hb_n_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[17]]
#set_property PACKAGE_PIN P28                     [get_ports fmc2_hb_p_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[17]]
#set_property PACKAGE_PIN M29                     [get_ports fmc2_hb_n_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[18]]
#set_property PACKAGE_PIN N29                     [get_ports fmc2_hb_p_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[18]]
#set_property PACKAGE_PIN M31                     [get_ports fmc2_hb_n_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[19]]
#set_property PACKAGE_PIN M30                     [get_ports fmc2_hb_p_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[19]]
#set_property PACKAGE_PIN N33                     [get_ports fmc2_hb_n_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[20]]
#set_property PACKAGE_PIN N32                     [get_ports fmc2_hb_p_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[20]]
#set_property PACKAGE_PIN R33                     [get_ports fmc2_hb_n_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_n_i[21]]
#set_property PACKAGE_PIN T33                     [get_ports fmc2_hb_p_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_hb_p_i[21]]
#set_property PACKAGE_PIN AF28                    [get_ports fmc2_la_n_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[0] ]
#set_property PACKAGE_PIN AE28                    [get_ports fmc2_la_p_i[0] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[0] ]
#set_property PACKAGE_PIN AF30                    [get_ports fmc2_la_n_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[1] ]
#set_property PACKAGE_PIN AF29                    [get_ports fmc2_la_p_i[1] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[1] ]
#set_property PACKAGE_PIN AH31                    [get_ports fmc2_la_n_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[2] ]
#set_property PACKAGE_PIN AG31                    [get_ports fmc2_la_p_i[2] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[2] ]
#set_property PACKAGE_PIN AH24                    [get_ports fmc2_la_n_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[3] ]
#set_property PACKAGE_PIN AG24                    [get_ports fmc2_la_p_i[3] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[3] ]
#set_property PACKAGE_PIN AC27                    [get_ports fmc2_la_n_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[4] ]
#set_property PACKAGE_PIN AC26                    [get_ports fmc2_la_p_i[4] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[4] ]
#set_property PACKAGE_PIN AH34                    [get_ports fmc2_la_n_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[5] ]
#set_property PACKAGE_PIN AH33                    [get_ports fmc2_la_p_i[5] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[5] ]
#set_property PACKAGE_PIN AF23                    [get_ports fmc2_la_n_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[6] ]
#set_property PACKAGE_PIN AE23                    [get_ports fmc2_la_p_i[6] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[6] ]
#set_property PACKAGE_PIN AH27                    [get_ports fmc2_la_n_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[7] ]
#set_property PACKAGE_PIN AG27                    [get_ports fmc2_la_p_i[7] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[7] ]
#set_property PACKAGE_PIN AE25                    [get_ports fmc2_la_n_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[8] ]
#set_property PACKAGE_PIN AD25                    [get_ports fmc2_la_p_i[8] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[8] ]
#set_property PACKAGE_PIN AG25                    [get_ports fmc2_la_n_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[9] ]
#set_property PACKAGE_PIN AF25                    [get_ports fmc2_la_p_i[9] ]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[9] ]
#set_property PACKAGE_PIN AH32                    [get_ports fmc2_la_n_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[10]]
#set_property PACKAGE_PIN AG32                    [get_ports fmc2_la_p_i[10]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[10]]
#set_property PACKAGE_PIN AE30                    [get_ports fmc2_la_n_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[11]]
#set_property PACKAGE_PIN AD30                    [get_ports fmc2_la_p_i[11]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[11]]
#set_property PACKAGE_PIN AF27                    [get_ports fmc2_la_n_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[12]]
#set_property PACKAGE_PIN AE27                    [get_ports fmc2_la_p_i[12]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[12]]
#set_property PACKAGE_PIN AG34                    [get_ports fmc2_la_n_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[13]]
#set_property PACKAGE_PIN AF34                    [get_ports fmc2_la_p_i[13]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[13]]
#set_property PACKAGE_PIN AF33                    [get_ports fmc2_la_n_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[14]]
#set_property PACKAGE_PIN AE33                    [get_ports fmc2_la_p_i[14]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[14]]
#set_property PACKAGE_PIN AD29                    [get_ports fmc2_la_n_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[15]]
#set_property PACKAGE_PIN AD28                    [get_ports fmc2_la_p_i[15]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[15]]
#set_property PACKAGE_PIN AD34                    [get_ports fmc2_la_n_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[16]]
#set_property PACKAGE_PIN AD33                    [get_ports fmc2_la_p_i[16]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[16]]
#set_property PACKAGE_PIN AB32                    [get_ports fmc2_la_n_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[17]]
#set_property PACKAGE_PIN AB31                    [get_ports fmc2_la_p_i[17]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[17]]
#set_property PACKAGE_PIN W31                     [get_ports fmc2_la_n_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[18]]
#set_property PACKAGE_PIN W30                     [get_ports fmc2_la_p_i[18]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[18]]
#set_property PACKAGE_PIN AB27                    [get_ports fmc2_la_n_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[19]]
#set_property PACKAGE_PIN AB26                    [get_ports fmc2_la_p_i[19]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[19]]
#set_property PACKAGE_PIN AB25                    [get_ports fmc2_la_n_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[20]]
#set_property PACKAGE_PIN AB24                    [get_ports fmc2_la_p_i[20]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[20]]
#set_property PACKAGE_PIN AA33                    [get_ports fmc2_la_n_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[21]]
#set_property PACKAGE_PIN AA32                    [get_ports fmc2_la_p_i[21]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[21]]
#set_property PACKAGE_PIN AA25                    [get_ports fmc2_la_n_i[22]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[22]]
#set_property PACKAGE_PIN AA24                    [get_ports fmc2_la_p_i[22]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[22]]
#set_property PACKAGE_PIN Y25                     [get_ports fmc2_la_n_i[23]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[23]]
#set_property PACKAGE_PIN W25                     [get_ports fmc2_la_p_i[23]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[23]]
#set_property PACKAGE_PIN Y33                     [get_ports fmc2_la_n_i[24]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[24]]
#set_property PACKAGE_PIN Y32                     [get_ports fmc2_la_p_i[24]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[24]]
#set_property PACKAGE_PIN AB29                    [get_ports fmc2_la_n_i[25]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[25]]
#set_property PACKAGE_PIN AA29                    [get_ports fmc2_la_p_i[25]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[25]]
#set_property PACKAGE_PIN AC32                    [get_ports fmc2_la_n_i[26]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[26]]
#set_property PACKAGE_PIN AC31                    [get_ports fmc2_la_p_i[26]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[26]]
#set_property PACKAGE_PIN AA28                    [get_ports fmc2_la_n_i[27]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[27]]
#set_property PACKAGE_PIN AA27                    [get_ports fmc2_la_p_i[27]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[27]]
#set_property PACKAGE_PIN W29                     [get_ports fmc2_la_n_i[28]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[28]]
#set_property PACKAGE_PIN W28                     [get_ports fmc2_la_p_i[28]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[28]]
#set_property PACKAGE_PIN AC34                    [get_ports fmc2_la_n_i[29]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[29]]
#set_property PACKAGE_PIN AC33                    [get_ports fmc2_la_p_i[29]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[29]]
#set_property PACKAGE_PIN W34                     [get_ports fmc2_la_n_i[30]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[30]]
#set_property PACKAGE_PIN W33                     [get_ports fmc2_la_p_i[30]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[30]]
#set_property PACKAGE_PIN V32                     [get_ports fmc2_la_n_i[31]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[31]]
#set_property PACKAGE_PIN V31                     [get_ports fmc2_la_p_i[31]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[31]]
#set_property PACKAGE_PIN AB34                    [get_ports fmc2_la_n_i[32]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[32]]
#set_property PACKAGE_PIN AA34                    [get_ports fmc2_la_p_i[32]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[32]]
#set_property PACKAGE_PIN V34                     [get_ports fmc2_la_n_i[33]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_n_i[33]]
#set_property PACKAGE_PIN V33                     [get_ports fmc2_la_p_i[33]]
#set_property IOSTANDARD LVCMOS25                 [get_ports fmc2_la_p_i[33]]

#######################################################################
##                          PCIe constraints                        ##
#######################################################################

#PCIe clock
# MGT216_CLK1_N -> MGTREFCLK0N_216
set_property PACKAGE_PIN G18                     [get_ports pcie_clk_n_i]
# MGT216_CLK1_P -> MGTREFCLK0P_216
set_property PACKAGE_PIN H18                     [get_ports pcie_clk_p_i]

#XDC supplied by PCIe IP core generates
# GTP connection in reverse order, we have to swap it.
# Simply providing correct connections will generate
# errors "Cannot set LOC ... because the PACKAGE_PIN
# is occupied by ...".
# So, firstly set PCIe lanes to temporary locations
#PCIe lane 0
# TX213_0_P            -> MGTPTXP0_213
set_property PACKAGE_PIN AN19                    [get_ports {pci_exp_txp_o[0]}]
# TX213_0_N            -> MGTPTXN0_213
set_property PACKAGE_PIN AP19                    [get_ports {pci_exp_txn_o[0]}]
# RX213_0_P            -> MGTPRXP0_213
set_property PACKAGE_PIN AL18                    [get_ports {pci_exp_rxp_i[0]}]
# RX213_0_N            -> MGTPRXN0_213
set_property PACKAGE_PIN AM18                    [get_ports {pci_exp_rxn_i[0]}]
#PCIe lane 1
# TX213_1_P            -> MGTPTXP1_213
set_property PACKAGE_PIN AN21                    [get_ports {pci_exp_txp_o[1]}]
# TX213_1_N            -> MGTPTXN1_213
set_property PACKAGE_PIN AP21                    [get_ports {pci_exp_txn_o[1]}]
# RX213_1_P            -> MGTPRXP1_213
set_property PACKAGE_PIN AJ19                    [get_ports {pci_exp_rxp_i[1]}]
# RX213_1_N            -> MGTPRXN1_213
set_property PACKAGE_PIN AK19                    [get_ports {pci_exp_rxn_i[1]}]
#PCIe lane 2
# TX213_2_P            -> MGTPTXP2_213
set_property PACKAGE_PIN AL22                    [get_ports {pci_exp_txp_o[2]}]
# TX213_2_N            -> MGTPTXN2_213
set_property PACKAGE_PIN AM22                    [get_ports {pci_exp_txn_o[2]}]
# RX213_2_P            -> MGTPRXP2_213
set_property PACKAGE_PIN AL20                    [get_ports {pci_exp_rxp_i[2]}]
# RX213_2_N            -> MGTPRXN2_213
set_property PACKAGE_PIN AM20                    [get_ports {pci_exp_rxn_i[2]}]
#PCIe lane 3
# TX213_3_P            -> MGTPTXP3_213
set_property PACKAGE_PIN AN23                    [get_ports {pci_exp_txp_o[3]}]
# TX213_3_N            -> MGTPTXN3_213
set_property PACKAGE_PIN AP23                    [get_ports {pci_exp_txn_o[3]}]
# RX213_3_P            -> MGTPRXP3_213
set_property PACKAGE_PIN AJ21                    [get_ports {pci_exp_rxp_i[3]}]
# RX213_3_N            -> MGTPRXN3_213
set_property PACKAGE_PIN AK21                    [get_ports {pci_exp_rxn_i[3]}]

# Now assign the correct ones

#PCIe lane 0
# TX216_0_P            -> MGTPTXP0_216
set_property PACKAGE_PIN B23                     [get_ports {pci_exp_txp_o[0]}]
# TX216_0_N            -> MGTPTXN0_216
set_property PACKAGE_PIN A23                     [get_ports {pci_exp_txn_o[0]}]
# RX216_0_P            -> MGTPRXP0_216
set_property PACKAGE_PIN F21                     [get_ports {pci_exp_rxp_i[0]}]
# RX216_0_N            -> MGTPRXN0_216
set_property PACKAGE_PIN E21                     [get_ports {pci_exp_rxn_i[0]}]
#PCIe lane 1
# TX216_1_P            -> MGTPTXP1_216
set_property PACKAGE_PIN D22                     [get_ports {pci_exp_txp_o[1]}]
# TX216_1_N            -> MGTPTXN1_216
set_property PACKAGE_PIN C22                     [get_ports {pci_exp_txn_o[1]}]
# RX216_1_P            -> MGTPRXP1_216
set_property PACKAGE_PIN D20                     [get_ports {pci_exp_rxp_i[1]}]
# RX216_1_N            -> MGTPRXN1_216
set_property PACKAGE_PIN C20                     [get_ports {pci_exp_rxn_i[1]}]
#PCIe lane 2
# TX216_2_P            -> MGTPTXP2_216
set_property PACKAGE_PIN B21                     [get_ports {pci_exp_txp_o[2]}]
# TX216_2_N            -> MGTPTXN2_216
set_property PACKAGE_PIN A21                     [get_ports {pci_exp_txn_o[2]}]
# RX216_2_P            -> MGTPRXP2_216
set_property PACKAGE_PIN F19                     [get_ports {pci_exp_rxp_i[2]}]
# RX216_2_N            -> MGTPRXN2_216
set_property PACKAGE_PIN E19                     [get_ports {pci_exp_rxn_i[2]}]
#PCIe lane 3
# TX216_3_P            -> MGTPTXP3_216
set_property PACKAGE_PIN B19                     [get_ports {pci_exp_txp_o[3]}]
# TX216_3_N            -> MGTPTXN3_216
set_property PACKAGE_PIN A19                     [get_ports {pci_exp_txn_o[3]}]
# RX216_3_P            -> MGTPRXP3_216
set_property PACKAGE_PIN D18                     [get_ports {pci_exp_rxp_i[3]}]
# RX216_3_N            -> MGTPRXN3_216
set_property PACKAGE_PIN C18                     [get_ports {pci_exp_rxn_i[3]}]

#######################################################################
# Pinout and Related I/O Constraints
#######################################################################

#######################################################################
##                    Timing constraints                             ##
#######################################################################

#######################################################################
##                          Clocks                                   ##
#######################################################################

# 125 MHz AMC TCLKB input clock
create_clock -period 8.000 -name sys_clk_p_i     [get_ports sys_clk_p_i]

# Create generated clocks from SYS PLL/MMCM
create_generated_clock -name clk_sys             [get_pins -hier -filter {NAME =~ *cmp_pll_sys_inst/cmp_sys_pll/CLKOUT0}]
set clk_sys_period                               [get_property PERIOD [get_clocks clk_sys]]
create_generated_clock -name clk_200mhz          [get_pins -hier -filter {NAME =~ *cmp_pll_sys_inst/cmp_sys_pll/CLKOUT1}]
set clk_200mhz_period                            [get_property PERIOD [get_clocks clk_200mhz]]
create_generated_clock -name clk_300mhz          [get_pins -hier -filter {NAME =~ *cmp_pll_sys_inst/cmp_sys_pll/CLKOUT2}]
set clk_300mhz_period                            [get_property PERIOD [get_clocks clk_300mhz]]

# 20 MHz VCXO input clock
create_clock -period 50.000 -name dmtd_clk_i     [get_ports clk_20m_vcxo_p_i]

# Create generated clocks from DMTD PLL/MMCM
create_generated_clock -name clk_dmtd            [get_pins -hier -filter {NAME =~ *cmp_dmtd_pll_inst/cmp_sys_pll/CLKOUT0}]
set clk_dmtd_period                              [get_property PERIOD [get_clocks clk_dmtd]]
create_generated_clock -name clk_dmtd_div2       [get_pins -hier -filter {NAME =~ *cmp_dmtd_pll_inst/cmp_sys_pll/CLKOUT1}]
set clk_dmtd_div2_period                         [get_property PERIOD [get_clocks clk_dmtd_div2]]

# 125 MHz Si57x input clock
create_clock -period 8.000 -name clk_afc_si57x   [get_ports clk_afc_si57x_p_i]
set clk_afc_si57x_period                         [get_property PERIOD [get_clocks clk_afc_si57x]]

# DDR3 clock generate by IP
set clk_pll_ddr_period                           [get_property PERIOD [get_clocks clk_pll_i]]

#######################################################################
##                         Cross Clock Constraints                   ##
#######################################################################

# Reset synchronization path.
set_false_path -through                          [get_pins -hier -filter {NAME =~ *cmp_sys_reset/master_rstn_reg/C}]
# Get the cell driving the corresponding net
set sys_reset_ffs                                [get_nets -hier -filter {NAME =~ *cmp_sys_reset*/master_rstn*}]
set_property ASYNC_REG TRUE                      [get_cells [all_fanin -flat -only_cells -startpoints_only [get_pins -of_objects [get_nets $sys_reset_ffs]]]]

set_false_path -through                          [get_pins -hier -filter {NAME =~ *cmp_dmtd_reset/master_rstn_reg/C}]
# Get the cell driving the corresponding net
set dmtd_reset_ffs                               [get_nets -hier -filter {NAME =~ *cmp_dmtd_reset*/master_rstn*}]
set_property ASYNC_REG TRUE                      [get_cells [all_fanin -flat -only_cells -startpoints_only [get_pins -of_objects [get_nets $dmtd_reset_ffs]]]]

set_false_path -through                          [get_pins -hier -filter {NAME =~ *cmp_afc_si57x_reset/master_rstn_reg/C}]
# Get the cell driving the corresponding net
set afc_si57x_reset_ffs                          [get_nets -hier -filter {NAME =~ *cmp_afc_si57x_reset*/master_rstn*}]
set_property ASYNC_REG TRUE                      [get_cells [all_fanin -flat -only_cells -startpoints_only [get_pins -of_objects [get_nets $afc_si57x_reset_ffs]]]]

# DDR 3 temperature monitor reset path
# chain of FFs synched with clk_sys.
#  We use asynchronous assertion and
#  synchronous deassertion
set_false_path -through                          [get_nets -hier -filter {NAME =~ *theTlpControl/Memory_Space/wb_FIFO_Rst}]
# DDR 3 temperature monitor reset path
set_max_delay -datapath_only -from               [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20.000

# DMTD CLK_SYS Sampling.
# Give 1x the source clock
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks clk_dmtd] $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks clk_dmtd] -to [get_clocks clk_sys] $clk_dmtd_period
# Why does this do not get set by
#  the above constraints?
set_max_delay -from                              [get_pins -hier -filter {NAME =~*/cmp_sys_pll/CLKOUT0}] -to [get_pins -hier -filter {NAME =~*/DMTD_A/gen_straight.clk_i_d0_reg/D}] $clk_sys_period
set_max_delay -from                              [get_pins -hier -filter {NAME =~*/cmp_sys_pll/CLKOUT0}] -to [get_pins -hier -filter {NAME =~*/DMTD_B/gen_straight.clk_i_d0_reg/D}] $clk_sys_period

# DMTD CLK_SI57x Sampling.
# Give 1x the source clock
set_max_delay -datapath_only -from               [get_clocks clk_afc_si57x] -to [get_clocks clk_dmtd] $clk_afc_si57x_period
set_max_delay -datapath_only -from               [get_clocks clk_dmtd] -to [get_clocks clk_afc_si57x] $clk_dmtd_period
# Why does this do not get set by
#  the above constraints?
set_max_delay -from                              [get_clocks clk_afc_si57x] -to [get_pins -hier -filter {NAME =~*/DMTD_A/gen_straight.clk_i_d0_reg/D}] $clk_afc_si57x_period
set_max_delay -from                              [get_clocks clk_afc_si57x] -to [get_pins -hier -filter {NAME =~*/DMTD_B/gen_straight.clk_i_d0_reg/D}] $clk_afc_si57x_period

# PCIe <-> DDR3. Give 1x the source clock
set_max_delay -from                              [get_clocks clk_pll_i] -to [get_clocks clk_125mhz] $clk_pll_ddr_period

# Acquisition core <-> DDR3 clock. 1x source clock destination
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks clk_pll_i] $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks clk_pll_i] -to [get_clocks clk_sys] $clk_pll_ddr_period

# DDR3 reset path. Copied from
# ddr_core.xdc and modified accordingly
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *cmp_pcie_cntr/user_lnk_up_int_i/C}] -to [get_cells -hier *rstdiv0_sync_r*] 5

# Constraint the asynchronous reset of the DDR3 module. It should be safe to declare it
# as a false path, but let's give it a 5 ns, as the constraint above.
# Here we want to get a valid startpoint from the NET name ddr_reset. So, we must:
# 1. Get the complete name of this NET
# 2. Get the pin name that is connected to this NET and filter it
#     so get only the OUT pins and the LEAF name of it (as opposed to
#     a hierarchical name)
# 3. This pin will be probably the Q pin of the driving FF, but for a timing,
#     analysis we want a valid startpoint. So, we get only this by using the all_fanin
#     command
set pcie_user_ddr_reset                          [all_fanin -flat -only_cells -startpoints_only [get_pins -of_objects [get_nets -hier -filter {NAME =~ */theTlpControl/Memory_Space/ddr_reset}] -filter {IS_LEAF && (DIRECTION == "OUT")}]]
set_max_delay -from                              [get_cells $pcie_user_ddr_reset] 5.000

# Constraint DDR <-> PCIe clocks CDC
set_max_delay -datapath_only -from               [get_clocks -include_generated_clocks pcie_clk] -to [get_clocks -include_generated_clocks clk_pll_i] 5.000
set_max_delay -datapath_only -from               [get_clocks -include_generated_clocks clk_pll_i] -to [get_clocks -include_generated_clocks pcie_clk] 5.000

# Acquisition core register CDC
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_*_pkt*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_shots*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_curr_chan*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period

set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_*_pkt*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_shots*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_curr_chan*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period

# This path is only valid after acq_start
# signal, which is controlled by software and
# is activated many many miliseconds after
# all of the other. So, give it 1x the
# destination clock period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_core_regs/*/C}] -to [get_clocks clk_sys] $clk_sys_period

# Use Distributed RAMs for FMC ACQ FIFOs.
#  They are small and sparse.
set_property RAM_STYLE DISTRIBUTED               [get_cells -hier -filter {NAME =~ */cmp_acq_fc_fifo/cmp_fc_source/*.*/*.*/mem_reg*}]

#######################################################################
##                      Placement Constraints                        ##
#######################################################################

# Constrain the PCIe core elements placement,
# so that it won't fail timing analysis.
create_pblock GRP_pcie_core
add_cells_to_pblock                              [get_pblocks GRP_pcie_core] [get_cells -hier -filter {NAME =~ */pcie_core_i/*}]
resize_pblock                                    [get_pblocks GRP_pcie_core] -add {CLOCKREGION_X0Y4:CLOCKREGION_X0Y4}
#
## Place the DMA design not far from PCIe core,
# otherwise it also breaks timing
#create_pblock GRP_ddr_core
#add_cells_to_pblock                              [get_pblocks GRP_ddr_core] [get_cells -hier -filter  {NAME =~ */cmp_xwb_pcie_cntr/cmp_wb_pcie_cntr/cmp_pcie_cntr/pcie_core_i/DDRs_ctrl_module/ddr_core_inst/*]]
#resize_pblock                                    [get_pblocks GRP_ddr_core] -add {CLOCKREGION_X1Y0:CLOCKREGION_X1Y1}
#
## Place DDR core temperature monitor
#create_pblock GRP_ddr_core_temp_mon
#add_cells_to_pblock                              [get_pblocks GRP_ddr_core_temp_mon] [get_cells -quiet [list cmp_xwb_pcie_cntr_a7/cmp_wb_pcie_cntr_a7/cmp_pcie_cntr_a7/u_ddr_core/temp_mon_enabled.u_tempmon/*]]
#resize_pblock                                    [get_pblocks GRP_ddr_core_temp_mon] -add {CLOCKREGION_X0Y2:CLOCKREGION_X0Y3}

## Place acquisition core 0
#create_pblock GRP_acq_core_0
#add_cells_to_pblock                              [get_pblocks GRP_acq_core_0] [get_cells -hier -filter {NAME =~ */cmp_wb_facq_core_mux/gen_facq_core[0].*}]
#resize_pblock                                    [get_pblocks GRP_acq_core_0] -add {CLOCKREGION_X0Y3:CLOCKREGION_X1Y3} -remove {CLOCKREGION_X0Y4:CLOCKREGION_X1Y4}

#######################################################################
##                         Bitstream Settings                        ##
#######################################################################

set_property BITSTREAM.CONFIG.CONFIGRATE 12      [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES  [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4     [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE     [current_design]
set_property CFGBVS VCCO                         [current_design]
set_property CONFIG_VOLTAGE 3.3                  [current_design]
