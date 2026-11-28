// =============================================================================
// File        : sim/filelist.f
// Mô tả       : Danh sách file mã nguồn RTL và Testbench dùng đường dẫn tương đối
// Cách dùng   : Chạy từ thư mục sim/ với lệnh: vlog -f filelist.f
// =============================================================================

// --- 1. Các module RTL ---
../rtl/in_buf.v
../rtl/met_upd.v
../rtl/sur_mem.v
../rtl/trb.v
../rtl/ctrl.v
../rtl/viterbi_top.v

// --- 2. Các Unit Testbench  ---
../testbench/tb_in_buf.v
../testbench/tb_ctrl.v
../testbench/tb_sur_mem.v
../testbench/tb_trb.v
../testbench/tb_bmc.v
../testbench/tb_acs.v
../testbench/tb_met_upd.v
../testbench/tb_viterbi_top.v
