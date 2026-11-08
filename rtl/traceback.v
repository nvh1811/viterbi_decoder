// =============================================================================
// File        : traceback.v
// Module      : traceback
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-017 (Phụ trách: Nguyễn Văn Hiếu)
// Tham chiếu  : Mục 9.5 (Bảng 23 & Hình 11) — Đặc tả thiết kế BTL_Nhóm 9_VLSI
// Chức năng   :
//   - Reset (rst_n = 0): xóa tb_state, decoded_work và data_out về 0.
//   - Khi select_en = 1 (pha SELECT): chọn trạng thái có PM cuối nhỏ nhất từ pm_bus
//     (nếu hòa ưu tiên 00 -> 01 -> 10 -> 11) nạp vào tb_state, xóa decoded_work = 0.
//   - Khi tb_en = 1 (pha TRACEBACK):
//       + Ghi tb_state[1] vào decoded_work[7 - tb_step]
//       + Đọc decision = survivor_word[tb_state]
//       + Cập nhật tb_state <= {tb_state[0], decision}
//   - Khi out_en = 1 (pha DONE): chốt decoded_work[7:0] sang data_out[7:0].
// =============================================================================

module traceback (
    input  wire        clk,            // Clock; cập nhật thanh ghi tại cạnh lên
    input  wire        rst_n,          // Reset bất đồng bộ, tích cực mức 0
    input  wire [19:0] pm_bus,         // 4 PM cuối {PM11, PM10, PM01, PM00}
    input  wire [3:0]  survivor_word,  // Hàng decision đang đọc tại tb_step
    input  wire [2:0]  tb_step,        // Chỉ số bước truy vết (7..0)
    input  wire        select_en,      // Chọn state có PM nhỏ nhất và xóa decoded_work
    input  wire        tb_en,          // Thực hiện 1 bước truy vết và ghi 1 bit vào decoded_work
    input  wire        out_en,         // Chuyển đủ 8 bit decoded_work sang data_out
    output reg  [7:0]  data_out        // Kết quả giải mã 8-bit; giữ giá trị đến lần xuất tiếp theo
);

    // TODO (VT-017): Thực hiện bộ chọn PM nhỏ nhất, thanh ghi tb_state, decoded_work và data_out

endmodule
