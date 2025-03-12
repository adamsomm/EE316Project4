## This file is a general .xdc for the Cora Z7-07S Rev. B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## PL System Clock
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports iCLK]
create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports iCLK]

## RGB LEDs
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { led0_b }]; #IO_L22N_T3_AD7N_35 Sch=led0_b
#set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { led0_g }]; #IO_L16P_T2_35 Sch=led0_g
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { led0_r }]; #IO_L21P_T3_DQS_AD14P_35 Sch=led0_r
#set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { led1_b }]; #IO_0_35 Sch=led1_b
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { led1_g }]; #IO_L22P_T3_AD7P_35 Sch=led1_g
#set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { led1_r }]; #IO_L23N_T3_35 Sch=led1_r

## Buttons
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports reset]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L4P_T0_35 Sch=btn[1]

## Pmod Header JA
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports TX_out]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports RX_in]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports ps2_clk]
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports ps2_data]
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { data_in[4] }]; #IO_L12P_T1_MRCC_34 Sch=ja_p[3]
#set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { data_in[5] }]; #IO_L12N_T1_MRCC_34 Sch=ja_n[3]
#set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { ja[6] }]; #IO_L22P_T3_34 Sch=ja_p[4]
#set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { ja[7] }]; #IO_L22N_T3_34 Sch=ja_n[4]

## Pmod Header JB
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports LCDscl]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports LCDsda]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports Sevscl]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports Sevsda]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports regPulse]
#set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { jb[5] }]; #IO_L18N_T2_34 Sch=jb_n[3]
#set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { jb[6] }]; #IO_L4P_T0_34 Sch=jb_p[4]
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { jb[7] }]; #IO_L4N_T0_34 Sch=jb_n[4]

## Crypto SDA
#set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { crypto_sda }];

## Dedicated Analog Inputs
#set_property -dict { PACKAGE_PIN K9    IOSTANDARD LVCMOS33 } [get_ports { Vp_Vn_0_v_p }]; #VP_0 Sch=xadc_v_p
#set_property -dict { PACKAGE_PIN L10   IOSTANDARD LVCMOS33 } [get_ports { Vp_Vn_0_v_n }]; #VN_0 Sch=xadc_v_n

## ChipKit Outer Analog Header - as Single-Ended Analog Inputs
## NOTE: These ports can be used as single-ended analog inputs with voltages from 0-3.3V (ChipKit analog pins A0-A5) or as digital I/O.
## WARNING: Do not use both sets of constraints at the same time!
#set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { Vaux1_0_v_p }]; #IO_L3P_T0_DQS_AD1P_35 Sch=ck_an_p[0]
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { Vaux1_0_v_n }]; #IO_L3N_T0_DQS_AD1N_35 Sch=ck_an_n[0]
#set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { Vaux9_0_v_p }]; #IO_L5P_T0_AD9P_35 Sch=ck_an_p[1]
#set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports { Vaux9_0_v_n }]; #IO_L5N_T0_AD9N_35 Sch=ck_an_n[1]
#set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { Vaux6_0_v_p }]; #IO_L20P_T3_AD6P_35 Sch=ck_an_p[2]
#set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { Vaux6_0_v_n }]; #IO_L20N_T3_AD6N_35 Sch=ck_an_n[2]
#set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { Vaux15_0_v_p }]; #IO_L24P_T3_AD15P_35 Sch=ck_an_p[3]
#set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { Vaux15_0_v_n }]; #IO_L24N_T3_AD15N_35 Sch=ck_an_n[3]
#set_property -dict { PACKAGE_PIN J20   IOSTANDARD LVCMOS33 } [get_ports { Vaux5_0_v_p }]; #IO_L17P_T2_AD5P_35 Sch=ck_an_p[4]
#set_property -dict { PACKAGE_PIN H20   IOSTANDARD LVCMOS33 } [get_ports { Vaux5_0_v_n }]; #IO_L17N_T2_AD5N_35 Sch=ck_an_n[4]
#set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports { Vaux13_0_v_p }]; #IO_L18P_T2_AD13P_35 Sch=ck_an_p[5]
#set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS33 } [get_ports { Vaux13_0_v_n }]; #IO_L18N_T2_AD13N_35 Sch=ck_an_n[5]
## ChipKit Outer Analog Header - as Digital I/O
## NOTE: The following constraints should be used when using these ports as digital I/O.
#set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { ck_a0 }]; #IO_L6N_T0_VREF_35 Sch=ck_a[0]
#set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports { ck_a1 }]; #IO_L10N_T1_AD11N_35 Sch=ck_a[1]
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { ck_a2 }]; #IO_L12P_T1_MRCC_35 Sch=ck_a[2]
#set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { ck_a3 }]; #IO_L11P_T1_SRCC_35 Sch=ck_a[3]
#set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { ck_a4 }]; #IO_L21N_T3_DQS_AD14N_35 Sch=ck_a[4]
#set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { ck_a5 }]; #IO_L6P_T0_34 Sch=ck_a[5]

## ChipKit Inner Analog Header - as Differential Analog Inputs
## NOTE: These ports can be used as differential analog inputs with voltages from 0-1.0V (ChipKit analog pins A6-A11) or as digital I/O.
## WARNING: Do not use both sets of constraints at the same time!
#set_property -dict { PACKAGE_PIN C20   IOSTANDARD LVCMOS33 } [get_ports { Vaux0_0_v_p }]; #IO_L1P_T0_AD0P_35 Sch=ad_p[0]
#set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports { Vaux0_0_v_n }]; #IO_L1N_T0_AD0N_35 Sch=ad_n[0]
#set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports { Vaux12_0_v_p }]; #IO_L15P_T2_DQS_AD12P_35 Sch=ad_p[12]
#set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS33 } [get_ports { Vaux12_0_v_n }]; #IO_L15N_T2_DQS_AD12N_35 Sch=ad_n[12]
#set_property -dict { PACKAGE_PIN B19   IOSTANDARD LVCMOS33 } [get_ports { Vaux8_0_v_p }]; #IO_L2P_T0_AD8P_35 Sch=ad_p[8]
#set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports { Vaux8_0_v_n }]; #IO_L2N_T0_AD8N_35 Sch=ad_n[8]
## ChipKit Inner Analog Header - as Digital I/O
## NOTE: The following constraints should be used when using the inner analog header ports as digital I/O.
#set_property -dict { PACKAGE_PIN C20   IOSTANDARD LVCMOS33 } [get_ports { ck_a6 }]; #IO_L1P_T0_AD0P_35 Sch=ad_p[0]
#set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports { ck_a7 }]; #IO_L1N_T0_AD0N_35 Sch=ad_n[0]
#set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports { ck_a8 }]; #IO_L15P_T2_DQS_AD12P_35 Sch=ad_p[12]
#set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS33 } [get_ports { ck_a9 }]; #IO_L15N_T2_DQS_AD12N_35 Sch=ad_n[12]
#set_property -dict { PACKAGE_PIN B19   IOSTANDARD LVCMOS33 } [get_ports { ck_a10 }]; #IO_L2P_T0_AD8P_35 Sch=ad_p[8]
#set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports { ck_a11 }]; #IO_L2N_T0_AD8N_35 Sch=ad_n[8]

## ChipKit Outer Digital Header
#set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { data_in[7] }]; #IO_L11P_T1_SRCC_34 Sch=ck_io[0]
#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { data_in[6] }]; #IO_L3N_T0_DQS_34 Sch=ck_io[1]
#set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { data_in[5] }]; #IO_L5P_T0_34 Sch=ck_io[2]
#set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { data_in[4] }]; #IO_L5N_T0_34 Sch=ck_io[3]
#set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { data_in[3] }]; #IO_L21P_T3_DQS_34 Sch=ck_io[4]
#set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { data_in[2] }]; #IO_L21N_T3_DQS_34 Sch=ck_io[5]
#set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { data_in[1] }]; #IO_L19N_T3_VREF_34 Sch=ck_io[6]
#set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { data_in[0] }]; #IO_L6N_T0_VREF_34 Sch=ck_io[7]
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { ck_io8 }]; #IO_L13P_T2_MRCC_34 Sch=ck_io[8]
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { ck_io9 }]; #IO_L8N_T1_AD10N_35 Sch=ck_io[9]
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { ck_io10 }]; #IO_L11N_T1_SRCC_34 Sch=ck_io[10]
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { ck_io11 }]; #IO_L12N_T1_MRCC_35 Sch=ck_io[11]
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { ck_io12 }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=ck_io[12]
#set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { ck_io13 }]; #IO_L19N_T3_VREF_35 Sch=ck_io[13]

## ChipKit Inner Digital Header
#set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { ck_io26 }]; #IO_L19P_T3_34 Sch=ck_io[26]
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { ck_io27 }]; #IO_L2N_T0_34 Sch=ck_io[27]
#set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { ck_io28 }]; #IO_L3P_T0_DQS_PUDC_B_34 Sch=ck_io[28]
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { ck_io29 }]; #IO_L10P_T1_34 Sch=ck_io[29]
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { ck_io30 }]; #IO_L9P_T1_DQS_34 Sch=ck_io[30]
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { ck_io31 }]; #IO_L9N_T1_DQS_34 Sch=ck_io[31]
#set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { ck_io32 }]; #IO_L20P_T3_34 Sch=ck_io[32]
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { ck_io33 }]; #IO_L20N_T3_34 Sch=ck_io[33]
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { ck_io34 }]; #IO_L23N_T3_34 Sch=ck_io[34]
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { ck_io35 }]; #IO_L23P_T3_34 Sch=ck_io[35]
#set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { ck_io36 }]; #IO_L8P_T1_AD10P_35 Sch=ck_io[36]
#set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { ck_io37 }]; #IO_L11N_T1_SRCC_35 Sch=ck_io[37]
#set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { ck_io38 }]; #IO_L13N_T2_MRCC_35 Sch=ck_io[38]
#set_property -dict { PACKAGE_PIN H18   IOSTANDARD LVCMOS33 } [get_ports { ck_io39 }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=ck_io[39]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { ck_io40 }]; #IO_L16N_T2_35 Sch=ck_io[40]
#set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS33 } [get_ports { ck_io41 }]; #IO_L9N_T1_DQS_AD3N_35 Sch=ck_io[41]

## ChipKit SPI
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { ck_miso }]; #IO_L10N_T1_34 Sch=ck_miso
#set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { ck_mosi }]; #IO_L2P_T0_34 Sch=ck_mosi
#set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { ck_sck }]; #IO_L19P_T3_35 Sch=ck_sck
#set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { ck_ss }]; #IO_L6P_T0_35 Sch=ck_ss

## ChipKit I2C
#set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { scl }]; #IO_L24N_T3_34 Sch=ck_scl
#set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { sda }]; #IO_L24P_T3_34 Sch=ck_sda

##Misc. ChipKit signals
#set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { ck_ioa }]; #IO_L7N_T1_AD2N_35 Sch=ck_ioa

## User Digital I/O Header J1
#set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { user_dio[1] }]; #IO_L9P_T1_DQS_AD3P_35 Sch=user_dio[1]
#set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { user_dio[2] }]; #IO_L7P_T1_AD2P_35 Sch=user_dio[2]
#set_property -dict { PACKAGE_PIN N20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[3] }]; #IO_L14P_T2_SRCC_34 Sch=user_dio[3]
#set_property -dict { PACKAGE_PIN P20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[4] }]; #IO_L14N_T2_SRCC_34 Sch=user_dio[4]
#set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports { user_dio[5] }]; #IO_L13N_T2_MRCC_34 Sch=user_dio[5]
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { user_dio[6] }]; #IO_0_34 Sch=user_dio[6]
#set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[7] }]; #IO_L15P_T2_DQS_34 Sch=user_dio[7]
#set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { user_dio[8] }]; #IO_25_34 Sch=user_dio[8]
#set_property -dict { PACKAGE_PIN U20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[9] }]; #IO_L15N_T2_DQS_34 Sch=user_dio[9]
#set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[10] }]; #IO_L16P_T2_34 Sch=user_dio[10]
#set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[11] }]; #IO_L16N_T2_34 Sch=user_dio[11]
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { user_dio[12] }]; #IO_L10P_T1_AD11P_35 Sch=user_dio[12]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list iCLK_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {ps2_keyboard_to_ascii_inst/ascii_code[0]} {ps2_keyboard_to_ascii_inst/ascii_code[1]} {ps2_keyboard_to_ascii_inst/ascii_code[2]} {ps2_keyboard_to_ascii_inst/ascii_code[3]} {ps2_keyboard_to_ascii_inst/ascii_code[4]} {ps2_keyboard_to_ascii_inst/ascii_code[5]} {ps2_keyboard_to_ascii_inst/ascii_code[6]} {ps2_keyboard_to_ascii_inst/ascii_code[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {ps2_keyboard_to_ascii_inst/ascii[0]} {ps2_keyboard_to_ascii_inst/ascii[1]} {ps2_keyboard_to_ascii_inst/ascii[2]} {ps2_keyboard_to_ascii_inst/ascii[3]} {ps2_keyboard_to_ascii_inst/ascii[4]} {ps2_keyboard_to_ascii_inst/ascii[5]} {ps2_keyboard_to_ascii_inst/ascii[6]} {ps2_keyboard_to_ascii_inst/ascii[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 5 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {uart_user_logic_inst/shiftcount[0]} {uart_user_logic_inst/shiftcount[1]} {uart_user_logic_inst/shiftcount[2]} {uart_user_logic_inst/shiftcount[3]} {uart_user_logic_inst/shiftcount[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 128 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {LCD_data[0]} {LCD_data[1]} {LCD_data[2]} {LCD_data[3]} {LCD_data[4]} {LCD_data[5]} {LCD_data[6]} {LCD_data[7]} {LCD_data[8]} {LCD_data[9]} {LCD_data[10]} {LCD_data[11]} {LCD_data[12]} {LCD_data[13]} {LCD_data[14]} {LCD_data[15]} {LCD_data[16]} {LCD_data[17]} {LCD_data[18]} {LCD_data[19]} {LCD_data[20]} {LCD_data[21]} {LCD_data[22]} {LCD_data[23]} {LCD_data[24]} {LCD_data[25]} {LCD_data[26]} {LCD_data[27]} {LCD_data[28]} {LCD_data[29]} {LCD_data[30]} {LCD_data[31]} {LCD_data[32]} {LCD_data[33]} {LCD_data[34]} {LCD_data[35]} {LCD_data[36]} {LCD_data[37]} {LCD_data[38]} {LCD_data[39]} {LCD_data[40]} {LCD_data[41]} {LCD_data[42]} {LCD_data[43]} {LCD_data[44]} {LCD_data[45]} {LCD_data[46]} {LCD_data[47]} {LCD_data[48]} {LCD_data[49]} {LCD_data[50]} {LCD_data[51]} {LCD_data[52]} {LCD_data[53]} {LCD_data[54]} {LCD_data[55]} {LCD_data[56]} {LCD_data[57]} {LCD_data[58]} {LCD_data[59]} {LCD_data[60]} {LCD_data[61]} {LCD_data[62]} {LCD_data[63]} {LCD_data[64]} {LCD_data[65]} {LCD_data[66]} {LCD_data[67]} {LCD_data[68]} {LCD_data[69]} {LCD_data[70]} {LCD_data[71]} {LCD_data[72]} {LCD_data[73]} {LCD_data[74]} {LCD_data[75]} {LCD_data[76]} {LCD_data[77]} {LCD_data[78]} {LCD_data[79]} {LCD_data[80]} {LCD_data[81]} {LCD_data[82]} {LCD_data[83]} {LCD_data[84]} {LCD_data[85]} {LCD_data[86]} {LCD_data[87]} {LCD_data[88]} {LCD_data[89]} {LCD_data[90]} {LCD_data[91]} {LCD_data[92]} {LCD_data[93]} {LCD_data[94]} {LCD_data[95]} {LCD_data[96]} {LCD_data[97]} {LCD_data[98]} {LCD_data[99]} {LCD_data[100]} {LCD_data[101]} {LCD_data[102]} {LCD_data[103]} {LCD_data[104]} {LCD_data[105]} {LCD_data[106]} {LCD_data[107]} {LCD_data[108]} {LCD_data[109]} {LCD_data[110]} {LCD_data[111]} {LCD_data[112]} {LCD_data[113]} {LCD_data[114]} {LCD_data[115]} {LCD_data[116]} {LCD_data[117]} {LCD_data[118]} {LCD_data[119]} {LCD_data[120]} {LCD_data[121]} {LCD_data[122]} {LCD_data[123]} {LCD_data[124]} {LCD_data[125]} {LCD_data[126]} {LCD_data[127]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {data_s[0]} {data_s[1]} {data_s[2]} {data_s[3]} {data_s[4]} {data_s[5]} {data_s[6]} {data_s[7]} {data_s[8]} {data_s[9]} {data_s[10]} {data_s[11]} {data_s[12]} {data_s[13]} {data_s[14]} {data_s[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 136 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {uart_user_logic_inst/sr_out[0]} {uart_user_logic_inst/sr_out[1]} {uart_user_logic_inst/sr_out[2]} {uart_user_logic_inst/sr_out[3]} {uart_user_logic_inst/sr_out[4]} {uart_user_logic_inst/sr_out[5]} {uart_user_logic_inst/sr_out[6]} {uart_user_logic_inst/sr_out[7]} {uart_user_logic_inst/sr_out[8]} {uart_user_logic_inst/sr_out[9]} {uart_user_logic_inst/sr_out[10]} {uart_user_logic_inst/sr_out[11]} {uart_user_logic_inst/sr_out[12]} {uart_user_logic_inst/sr_out[13]} {uart_user_logic_inst/sr_out[14]} {uart_user_logic_inst/sr_out[15]} {uart_user_logic_inst/sr_out[16]} {uart_user_logic_inst/sr_out[17]} {uart_user_logic_inst/sr_out[18]} {uart_user_logic_inst/sr_out[19]} {uart_user_logic_inst/sr_out[20]} {uart_user_logic_inst/sr_out[21]} {uart_user_logic_inst/sr_out[22]} {uart_user_logic_inst/sr_out[23]} {uart_user_logic_inst/sr_out[24]} {uart_user_logic_inst/sr_out[25]} {uart_user_logic_inst/sr_out[26]} {uart_user_logic_inst/sr_out[27]} {uart_user_logic_inst/sr_out[28]} {uart_user_logic_inst/sr_out[29]} {uart_user_logic_inst/sr_out[30]} {uart_user_logic_inst/sr_out[31]} {uart_user_logic_inst/sr_out[32]} {uart_user_logic_inst/sr_out[33]} {uart_user_logic_inst/sr_out[34]} {uart_user_logic_inst/sr_out[35]} {uart_user_logic_inst/sr_out[36]} {uart_user_logic_inst/sr_out[37]} {uart_user_logic_inst/sr_out[38]} {uart_user_logic_inst/sr_out[39]} {uart_user_logic_inst/sr_out[40]} {uart_user_logic_inst/sr_out[41]} {uart_user_logic_inst/sr_out[42]} {uart_user_logic_inst/sr_out[43]} {uart_user_logic_inst/sr_out[44]} {uart_user_logic_inst/sr_out[45]} {uart_user_logic_inst/sr_out[46]} {uart_user_logic_inst/sr_out[47]} {uart_user_logic_inst/sr_out[48]} {uart_user_logic_inst/sr_out[49]} {uart_user_logic_inst/sr_out[50]} {uart_user_logic_inst/sr_out[51]} {uart_user_logic_inst/sr_out[52]} {uart_user_logic_inst/sr_out[53]} {uart_user_logic_inst/sr_out[54]} {uart_user_logic_inst/sr_out[55]} {uart_user_logic_inst/sr_out[56]} {uart_user_logic_inst/sr_out[57]} {uart_user_logic_inst/sr_out[58]} {uart_user_logic_inst/sr_out[59]} {uart_user_logic_inst/sr_out[60]} {uart_user_logic_inst/sr_out[61]} {uart_user_logic_inst/sr_out[62]} {uart_user_logic_inst/sr_out[63]} {uart_user_logic_inst/sr_out[64]} {uart_user_logic_inst/sr_out[65]} {uart_user_logic_inst/sr_out[66]} {uart_user_logic_inst/sr_out[67]} {uart_user_logic_inst/sr_out[68]} {uart_user_logic_inst/sr_out[69]} {uart_user_logic_inst/sr_out[70]} {uart_user_logic_inst/sr_out[71]} {uart_user_logic_inst/sr_out[72]} {uart_user_logic_inst/sr_out[73]} {uart_user_logic_inst/sr_out[74]} {uart_user_logic_inst/sr_out[75]} {uart_user_logic_inst/sr_out[76]} {uart_user_logic_inst/sr_out[77]} {uart_user_logic_inst/sr_out[78]} {uart_user_logic_inst/sr_out[79]} {uart_user_logic_inst/sr_out[80]} {uart_user_logic_inst/sr_out[81]} {uart_user_logic_inst/sr_out[82]} {uart_user_logic_inst/sr_out[83]} {uart_user_logic_inst/sr_out[84]} {uart_user_logic_inst/sr_out[85]} {uart_user_logic_inst/sr_out[86]} {uart_user_logic_inst/sr_out[87]} {uart_user_logic_inst/sr_out[88]} {uart_user_logic_inst/sr_out[89]} {uart_user_logic_inst/sr_out[90]} {uart_user_logic_inst/sr_out[91]} {uart_user_logic_inst/sr_out[92]} {uart_user_logic_inst/sr_out[93]} {uart_user_logic_inst/sr_out[94]} {uart_user_logic_inst/sr_out[95]} {uart_user_logic_inst/sr_out[96]} {uart_user_logic_inst/sr_out[97]} {uart_user_logic_inst/sr_out[98]} {uart_user_logic_inst/sr_out[99]} {uart_user_logic_inst/sr_out[100]} {uart_user_logic_inst/sr_out[101]} {uart_user_logic_inst/sr_out[102]} {uart_user_logic_inst/sr_out[103]} {uart_user_logic_inst/sr_out[104]} {uart_user_logic_inst/sr_out[105]} {uart_user_logic_inst/sr_out[106]} {uart_user_logic_inst/sr_out[107]} {uart_user_logic_inst/sr_out[108]} {uart_user_logic_inst/sr_out[109]} {uart_user_logic_inst/sr_out[110]} {uart_user_logic_inst/sr_out[111]} {uart_user_logic_inst/sr_out[112]} {uart_user_logic_inst/sr_out[113]} {uart_user_logic_inst/sr_out[114]} {uart_user_logic_inst/sr_out[115]} {uart_user_logic_inst/sr_out[116]} {uart_user_logic_inst/sr_out[117]} {uart_user_logic_inst/sr_out[118]} {uart_user_logic_inst/sr_out[119]} {uart_user_logic_inst/sr_out[120]} {uart_user_logic_inst/sr_out[121]} {uart_user_logic_inst/sr_out[122]} {uart_user_logic_inst/sr_out[123]} {uart_user_logic_inst/sr_out[124]} {uart_user_logic_inst/sr_out[125]} {uart_user_logic_inst/sr_out[126]} {uart_user_logic_inst/sr_out[127]} {uart_user_logic_inst/sr_out[128]} {uart_user_logic_inst/sr_out[129]} {uart_user_logic_inst/sr_out[130]} {uart_user_logic_inst/sr_out[131]} {uart_user_logic_inst/sr_out[132]} {uart_user_logic_inst/sr_out[133]} {uart_user_logic_inst/sr_out[134]} {uart_user_logic_inst/sr_out[135]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 8 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {uart_user_logic_inst/rx_data[0]} {uart_user_logic_inst/rx_data[1]} {uart_user_logic_inst/rx_data[2]} {uart_user_logic_inst/rx_data[3]} {uart_user_logic_inst/rx_data[4]} {uart_user_logic_inst/rx_data[5]} {uart_user_logic_inst/rx_data[6]} {uart_user_logic_inst/rx_data[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 3 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {mode[0]} {mode[1]} {mode[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list ps2_keyboard_to_ascii_inst/ascii_new_pulse]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list ps2_keyboard_to_ascii_inst/ps2_clk]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list ps2_keyboard_to_ascii_inst/ps2_data]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list uart_user_logic_inst/rx_full]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list uart_user_logic_inst/shift_trig]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets iCLK_IBUF_BUFG]
