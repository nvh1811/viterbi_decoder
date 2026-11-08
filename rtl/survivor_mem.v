// =============================================================================
// File        : survivor_mem.v
// Module      : survivor_mem
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-016 (Phụ trách: Nguyễn Văn Hiếu)
// Tham chiếu  : Mục 9.4 (Bảng 22 & Hình 10) — Đặc tả thiết kế BTL_Nhóm 9_VLSI
// Chức năng   :
//   - Bộ nhớ 8 hàng x 4 bit lưu decision_vec[3:0] của 8 bước trellis.
//   - Ghi đồng bộ tại cạnh lên clk khi rst_n = 1 và survivor_we = 1 tại địa chỉ fwd_step.
//   - Không xóa mảng khi reset (khóa ghi khi rst_n = 0).
//   - Đọc tổ hợp: survivor_word = mem[tb_step].
// =============================================================================

module survivor_mem (
    input  wire       clk,            // Clock; ghi bộ nhớ tại cạnh lên
    input  wire       rst_n,          // Tích cực mức 0; khóa ghi khi reset, không xóa mảng
    input  wire       survivor_we,    // Cho phép ghi decision_vec khi rst_n = 1
    input  wire [2:0] fwd_step,       // Địa chỉ hàng ghi (0..7)
    input  wire [3:0] decision_vec,   // 4 decision bit {state11, state10, state01, state00}
    input  wire [2:0] tb_step,        // Địa chỉ hàng đọc khi truy vết (7..0)
    output wire [3:0] survivor_word   // Đầu ra đọc tổ hợp của survivor_mem[tb_step]
);

    // TODO (VT-016): Khai báo mảng 8x4 bit, logic ghi đồng bộ và đọc tổ hợp

endmodule
