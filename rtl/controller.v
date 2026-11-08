// =============================================================================
// File        : controller.v
// Module      : controller
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-018 (Phụ trách: Nguyễn Văn Hiếu)
// Tham chiếu  : Mục 7 (Bảng 13–14) & Mục 9.6 (Bảng 24) — BTL_Nhóm 9_VLSI
// Chức năng   :
//   - FSM 5 trạng thái: IDLE (000), FORWARD (001), SELECT (010),
//     TRACEBACK (011), DONE (100). Tự phục hồi về IDLE nếu rơi vào 101/110/111.
//   - Quản lý bộ đếm fwd_step (0..7) và tb_step (7..0).
//   - Giải mã tổ hợp 7 tín hiệu enable theo Bảng 13 và xuất xung done (1 chu kỳ).
// =============================================================================

module controller (
    input  wire       clk,          // Clock; cập nhật FSM, bộ đếm và done tại cạnh lên
    input  wire       rst_n,        // Reset bất đồng bộ, tích cực mức 0
    input  wire       start,        // Yêu cầu nhận khung; chỉ được chấp nhận ở IDLE
    output wire       frame_load,   // IDLE & start=1: chốt khung vào input_buffer
    output wire       frame_init,   // IDLE & start=1: khởi tạo PM cho khung mới
    output wire       metric_en,    // FORWARD: cho phép cập nhật 4 PM
    output wire       survivor_we,  // FORWARD: ghi 4 decision bit vào survivor_mem
    output wire       select_en,    // SELECT: chọn trạng thái bắt đầu truy vết
    output wire       tb_en,        // TRACEBACK: thực hiện 1 bước truy vết
    output wire       out_en,       // DONE: cập nhật data_out
    output reg  [2:0] fwd_step,     // Chỉ số FORWARD (0..7); giữ tại 7 sau bước cuối
    output reg  [2:0] tb_step,      // Nạp 7 tại SELECT; giảm trong TRACEBACK (7..0)
    output reg        done          // Xung 1 clock báo kết quả hợp lệ sau cạnh xử lý DONE
);

    // Mã hóa trạng thái FSM theo Bảng 14 (Mục 7.1)
    localparam [2:0] IDLE      = 3'b000,
                     FORWARD   = 3'b001,
                     SELECT    = 3'b010,
                     TRACEBACK = 3'b011,
                     DONE      = 3'b100;

    // TODO (VT-018): Thực hiện thanh ghi trạng thái FSM, bộ đếm fwd_step, tb_step, done và 7 enable

endmodule
