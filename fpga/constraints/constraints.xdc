## ==============================================================================
## XDC Constraints for Flex-NTT (ML-KEM Accelerator)
## Target: AMD / Xilinx Artix-7 (xc7a35tcsg324-1)
## Top Module: mlkem_ntt_fsm
## ==============================================================================

## -----------------------------------------------------------------------------
## 1. Clock Constraint (50 MHz / 20.0 ns period)
## -----------------------------------------------------------------------------
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

## -----------------------------------------------------------------------------
## 2. I/O Timing Budget
## -----------------------------------------------------------------------------
# Input timing budget (Board delay + skew aligned with Artix-7 IBUF clock insertion)
set_input_delay -clock [get_clocks clk] -max 3.000 [get_ports {rst_n start is_intt load_en {load_addr[*]} {load_data[*]} read_en {read_addr[*]}}]
set_input_delay -clock [get_clocks clk] -min 2.500 [get_ports {rst_n start is_intt load_en {load_addr[*]} {load_data[*]} read_en {read_addr[*]}}]

# Output timing budget
set_output_delay -clock [get_clocks clk] -max 3.000 [get_ports {done {read_data[*]}}]
set_output_delay -clock [get_clocks clk] -min 0.500 [get_ports {done {read_data[*]}}]

## -----------------------------------------------------------------------------
## 3. I/O Standard & Voltage Properties
## -----------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports *]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## -----------------------------------------------------------------------------
## 4. Package Pin Location Constraints (47 Ports on xc7a35tcsg324-1)
## -----------------------------------------------------------------------------
# Control signals
set_property PACKAGE_PIN E3 [get_ports clk]
set_property PACKAGE_PIN C2 [get_ports rst_n]
set_property PACKAGE_PIN A8 [get_ports start]
set_property PACKAGE_PIN C11 [get_ports is_intt]
set_property PACKAGE_PIN D9 [get_ports load_en]
set_property PACKAGE_PIN B8 [get_ports read_en]
set_property PACKAGE_PIN H5 [get_ports done]

# load_addr[7:0]
set_property PACKAGE_PIN J5 [get_ports {load_addr[0]}]
set_property PACKAGE_PIN T9 [get_ports {load_addr[1]}]
set_property PACKAGE_PIN T10 [get_ports {load_addr[2]}]
set_property PACKAGE_PIN R10 [get_ports {load_addr[3]}]
set_property PACKAGE_PIN U11 [get_ports {load_addr[4]}]
set_property PACKAGE_PIN U12 [get_ports {load_addr[5]}]
set_property PACKAGE_PIN H6 [get_ports {load_addr[6]}]
set_property PACKAGE_PIN T13 [get_ports {load_addr[7]}]

# load_data[11:0]
set_property PACKAGE_PIN R16 [get_ports {load_data[0]}]
set_property PACKAGE_PIN R17 [get_ports {load_data[1]}]
set_property PACKAGE_PIN T18 [get_ports {load_data[2]}]
set_property PACKAGE_PIN U18 [get_ports {load_data[3]}]
set_property PACKAGE_PIN R13 [get_ports {load_data[4]}]
set_property PACKAGE_PIN T14 [get_ports {load_data[5]}]
set_property PACKAGE_PIN T15 [get_ports {load_data[6]}]
set_property PACKAGE_PIN V16 [get_ports {load_data[7]}]
set_property PACKAGE_PIN U14 [get_ports {load_data[8]}]
set_property PACKAGE_PIN V14 [get_ports {load_data[9]}]
set_property PACKAGE_PIN V12 [get_ports {load_data[10]}]
set_property PACKAGE_PIN V11 [get_ports {load_data[11]}]

# read_addr[7:0]
set_property PACKAGE_PIN P17 [get_ports {read_addr[0]}]
set_property PACKAGE_PIN P18 [get_ports {read_addr[1]}]
set_property PACKAGE_PIN N17 [get_ports {read_addr[2]}]
set_property PACKAGE_PIN M17 [get_ports {read_addr[3]}]
set_property PACKAGE_PIN P14 [get_ports {read_addr[4]}]
set_property PACKAGE_PIN N14 [get_ports {read_addr[5]}]
set_property PACKAGE_PIN K15 [get_ports {read_addr[6]}]
set_property PACKAGE_PIN J15 [get_ports {read_addr[7]}]

# read_data[11:0]
set_property PACKAGE_PIN H17 [get_ports {read_data[0]}]
set_property PACKAGE_PIN K16 [get_ports {read_data[1]}]
set_property PACKAGE_PIN M16 [get_ports {read_data[2]}]
set_property PACKAGE_PIN N16 [get_ports {read_data[3]}]
set_property PACKAGE_PIN P15 [get_ports {read_data[4]}]
set_property PACKAGE_PIN N15 [get_ports {read_data[5]}]
set_property PACKAGE_PIN R15 [get_ports {read_data[6]}]
set_property PACKAGE_PIN T16 [get_ports {read_data[7]}]
set_property PACKAGE_PIN U16 [get_ports {read_data[8]}]
set_property PACKAGE_PIN V17 [get_ports {read_data[9]}]
set_property PACKAGE_PIN U17 [get_ports {read_data[10]}]
set_property PACKAGE_PIN V15 [get_ports {read_data[11]}]

## DRC & Methodology Waivers


set_load 5.000 [all_outputs]
set_property LOAD 5 [get_ports done]
set_property LOAD 5 [get_ports {read_data[0]}]
set_property LOAD 5 [get_ports {read_data[10]}]
set_property LOAD 5 [get_ports {read_data[11]}]
set_property LOAD 5 [get_ports {read_data[1]}]
set_property LOAD 5 [get_ports {read_data[2]}]
set_property LOAD 5 [get_ports {read_data[3]}]
set_property LOAD 5 [get_ports {read_data[4]}]
set_property LOAD 5 [get_ports {read_data[5]}]
set_property LOAD 5 [get_ports {read_data[6]}]
set_property LOAD 5 [get_ports {read_data[7]}]
set_property LOAD 5 [get_ports {read_data[8]}]
set_property LOAD 5 [get_ports {read_data[9]}]
