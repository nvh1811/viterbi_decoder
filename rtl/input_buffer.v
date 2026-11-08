// =============================================================================
// File        : input_buffer.v
// Module      : input_buffer
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-013 (Phụ trách: Nguyễn Văn Hiếu)
// Tham chiếu  : Mục 9.1 (Bảng 17) — Đặc tả thiết kế BTL_Nhóm 9_VLSI
// Chức năng   :
//   - Chốt khung dữ liệu mã hóa 16-bit (data_in) vào thanh ghi frame_reg
//     tại cạnh lên clk khi frame_load = 1.
//   - Xóa frame_reg về 0 khi rst_n = 0 (bất đồng bộ, tích cực mức thấp).
//   - Xuất tổ hợp cặp bit nhận rx_pair theo chỉ số bước tiến fwd_step (0..7).
// =============================================================================

module input_buffer (
    input  wire        clk,         // Clock hệ thống; chốt frame_reg tại cạnh lên
    input  wire        rst_n,       // Reset bất đồng bộ, tích cực mức thấp; xóa frame_reg về 0
    input  wire        frame_load,  // Cho phép nạp data_in vào frame_reg (IDLE & start)
    input  wire [15:0] data_in,     // Khung dữ liệu mã hóa 16-bit (8 cặp bit)
    input  wire [2:0]  fwd_step,    // Chọn cặp bit nhận (0..7)
    output wire [1:0]  rx_pair      // Cặp bit nhận 
);

    // TODO (VT-013): Khai báo thanh ghi frame_reg[15:0] và bộ chọn MUX 8:1 cho rx_pair

endmodule
