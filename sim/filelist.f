// =============================================================================
// File        : sim/filelist.f
// Mô tả       : Danh sách file mã nguồn RTL và Testbench dùng đường dẫn tương đối
// Cách dùng   : Chạy từ thư mục sim/ với lệnh: vlog -f filelist.f
// =============================================================================

// --- 1. Các module RTL (Nguyễn Văn Hiếu) ---
../rtl/input_buffer.v
../rtl/metric_update.v
../rtl/survivor_mem.v
../rtl/traceback.v
../rtl/controller.v
../rtl/viterbi_top.v

// --- 2. Các Unit Testbench của Nguyễn Đình Tuyển ---
../testbench/tb_input_buffer.v
../testbench/tb_controller.v
../testbench/tb_survivor_mem.v
../testbench/tb_traceback.v

// --- 3. Các Unit & Top Testbench của Vũ Nguyễn Đăng Nhật ---
../testbench/tb_bmc.v
../testbench/tb_acs.v
../testbench/tb_metric_update.v
../testbench/tb_viterbi_top.v
