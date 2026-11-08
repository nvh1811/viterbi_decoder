# ####################################################################

#  Created by Genus(TM) Synthesis Solution 23.17-s085_1 on Sun May 17 23:51:41 +07 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design viterbi_top

create_clock -name "clk" -period 5.0 -waveform {0.0 2.5} [get_ports clk]
set_clock_transition 0.1 [get_clocks clk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports rst_n]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports en]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[15]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[14]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[13]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[12]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[11]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[10]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[9]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[8]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {encoded_in[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {decoded_out[7]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {decoded_out[6]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {decoded_out[5]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {decoded_out[4]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {decoded_out[3]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {decoded_out[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {decoded_out[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {decoded_out[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports done]
set_wire_load_mode "enclosed"
set_dont_use true [get_lib_cells sky130_ss_1.62_125/SDFFRX1]
set_dont_use true [get_lib_cells sky130_ss_1.62_125/SDFFRX4]
set_dont_use true [get_lib_cells sky130_ss_1.62_125/SDFFSRX1]
set_dont_use true [get_lib_cells sky130_ss_1.62_125/SDFFSRX4]
set_dont_use true [get_lib_cells sky130_ss_1.62_125/SDFFSX1]
set_dont_use true [get_lib_cells sky130_ss_1.62_125/SDFFSX4]
set_dont_use true [get_lib_cells sky130_ss_1.62_125/SDFFX1]
set_dont_use true [get_lib_cells sky130_ss_1.62_125/SDFFX4]
set_clock_uncertainty -setup 0.01 [get_ports clk]
set_clock_uncertainty -hold 0.01 [get_ports clk]
