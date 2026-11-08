create_clock -name clk -period 5 -waveform {0 2.5} [get_ports clk]
set_clock_transition -rise 0.1 [get_clocks clk]
set_clock_transition -fall 0.1 [get_clocks clk]
set_clock_uncertainty 0.01 [get_ports clk]

set_input_delay -max 1.0 -clock [get_clocks clk] [get_ports {rst_n en encoded_in[*]}]

set_output_delay -max 1.0 -clock [get_clocks clk] [get_ports {decoded_out[*] done}]
