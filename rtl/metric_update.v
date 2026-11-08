// =============================================================================
// File        : metric_update.v
// Modules     : bmc, acs, metric_update
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-014 & VT-015 (Phụ trách: Nguyễn Văn Hiếu)
// Tham chiếu  : Mục 9.2 (Bảng 18–19) & Mục 9.3 (Bảng 20–21) — BTL_Nhóm 9_VLSI
// =============================================================================

// -----------------------------------------------------------------------------
// 1. Module con: BMC — Branch Metric Computation (Mục 9.2 - Bảng 18)
//    Logic tổ hợp hoàn toàn, tính khoảng cách Hamming giữa rx_pair và 4 cặp mã
//    kỳ vọng (00, 01, 10, 11). Mỗi BM rộng 2 bit, giá trị 0..2.
// -----------------------------------------------------------------------------
module bmc (
    input  wire [1:0] rx_pair,      // Cặp bit nhận cần tính Branch Metric
    output wire [1:0] bm00,         // Khoảng cách Hamming(rx_pair, 2'b00)
    output wire [1:0] bm01,         // Khoảng cách Hamming(rx_pair, 2'b01)
    output wire [1:0] bm10,         // Khoảng cách Hamming(rx_pair, 2'b10)
    output wire [1:0] bm11          // Khoảng cách Hamming(rx_pair, 2'b11)
);

    // TODO (VT-014): Thực hiện logic tổ hợp XOR và cộng 2 bit cho bm00, bm01, bm10, bm11

endmodule


// -----------------------------------------------------------------------------
// 2. Module con: ACS — Add-Compare-Select (Mục 9.3.1 - Bảng 20)
//    Logic tổ hợp cho 1 trạng thái đích:
//    - Cộng 6-bit không dấu: sum = {1'b0, pm} + {4'b0, bm}
//    - Bão hòa tại MAX_VAL = 5'd31 (nếu pm == 31 hoặc sum > 31 thì cand = 31)
//    - So sánh cand_a và cand_b: nếu cand_a <= cand_b chọn nhánh A (decision = 0),
//      ngược lại chọn nhánh B (decision = 1).
// -----------------------------------------------------------------------------
module acs (
    input  wire [4:0] pm_a,         // PM cũ của trạng thái cha A (31 = không tới được)
    input  wire [4:0] pm_b,         // PM cũ của trạng thái cha B (31 = không tới được)
    input  wire [1:0] bm_a,         // BM của nhánh từ cha A đến trạng thái đích (0..2)
    input  wire [1:0] bm_b,         // BM của nhánh từ cha B đến trạng thái đích (0..2)
    output wire [4:0] next_pm,      // PM nhỏ hơn trong hai ứng viên sau bão hòa về 31
    output wire       decision      // 0: chọn cha A; 1: chọn cha B (hòa chọn A)
);

    // TODO (VT-015): Thực hiện logic Cộng, Bão hòa ở 31, So sánh và Chọn

endmodule


// -----------------------------------------------------------------------------
// 3. Module chính: metric_update (Mục 9.3.2 - Bảng 21 & Mục 6.3)
//    Gồm 1 khối BMC dùng chung, 4 khối ACS song song (cho đích 00, 01, 10, 11)
//    và 4 thanh ghi PM 5-bit:
//    - Reset (rst_n = 0): PM00 = PM01 = PM10 = PM11 = 5'd31
//    - Khởi tạo khung (frame_init = 1): PM00 = 5'd0, PM01 = PM10 = PM11 = 5'd31
//    - Cập nhật (metric_en = 1): chốt đồng thời 4 next_pm vào 4 thanh ghi PM
//    - Đóng gói:
//        pm_bus[19:0]      = {PM11, PM10, PM01, PM00}
//        decision_vec[3:0] = {dec11, dec10, dec01, dec00}
// -----------------------------------------------------------------------------
module metric_update (
    input  wire        clk,          // Clock; chốt đồng thời 4 PM tại cạnh lên
    input  wire        rst_n,        // Reset bất đồng bộ, tích cực mức 0; đặt 4 PM = 31
    input  wire        frame_init,   // Khởi tạo PM = (0, 31, 31, 31); ưu tiên hơn metric_en
    input  wire        metric_en,    // Cho phép cập nhật cả 4 PM từ kết quả ACS
    input  wire [1:0]  rx_pair,      // Cặp bit nhận cấp cho BMC dùng chung
    output wire [19:0] pm_bus,       // {PM11[4:0], PM10[4:0], PM01[4:0], PM00[4:0]}
    output wire [3:0]  decision_vec  // 4 decision bit tổ hợp {state11, state10, state01, state00}
);

    // TODO (VT-015): Kết nối bmc, 4 acs (theo Bảng 5 ánh xạ nhánh) và 4 thanh ghi PM

endmodule
