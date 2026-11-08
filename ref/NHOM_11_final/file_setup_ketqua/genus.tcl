set_db init_lib_search_path ../lib/
set_db init_hdl_search_path ../rtl/

read_libs sky130_ss_1.62_125_nldm.lib

read_hdl {viterbi_top.v sym_extract.v bmu.v acsu.v pmsm.v smu_tbu.v ctrl_unit.v}

elaborate viterbi_top

set_db [get_db lib_cells *SDFF*] .dont_use true

read_sdc ../constraints/constraints.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

syn_generic
syn_map
syn_opt

# Report
report_timing > reports/report_timing.rpt
report_area   > reports/report_area.rpt
report_power  > reports/report_power.rpt
report_qor    > reports/report_qor.rpt

# Output
write_hdl > outputs/viterbi_netlist.v
write_sdc > outputs/viterbi_sdc.sdc


