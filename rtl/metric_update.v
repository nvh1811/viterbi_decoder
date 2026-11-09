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
    assign bm00 = (rx_pair[1] ^ 1'b0) + (rx_pair[0] ^ 1'b0);  // BM cho nhánh đến trạng thái đích 00
    assign bm01 = (rx_pair[1] ^ 1'b0) + (rx_pair[0] ^ 1'b1);  // BM cho nhánh đến trạng thái đích 01
    assign bm10 = (rx_pair[1] ^ 1'b1) + (rx_pair[0] ^ 1'b0);  // BM cho nhánh đến trạng thái đích 10
    assign bm11 = (rx_pair[1] ^ 1'b1) + (rx_pair[0] ^ 1'b1);

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
    input  wire [1:0] bma,         // BM của nhánh từ cha A đến trạng thái đích (0..2)
    input  wire [1:0] bmb,         // BM của nhánh từ cha B đến trạng thái đích (0..2)
    output wire [4:0] next_pm,      // PM nhỏ hơn trong hai ứng viên sau bão hòa về 31
    output wire       decision      // 0: chọn cha A; 1: chọn cha B (hòa chọn A)
);

    localparam [4:0] MAX_VAL = 5'd31;

    wire [5:0] sum_a = {1'b0, pm_a} + {4'b0, bma};
    wire [5:0] sum_b = {1'b0, pm_b} + {4'b0, bmb};

    wire [4:0] cand_a = (sum_a >= 6'd31) ? MAX_VAL : sum_a[4:0];
    wire [4:0] cand_b = (sum_b >= 6'd31) ? MAX_VAL : sum_b[4:0];

    assign decision = (cand_a <= cand_b) ? 1'b0 : 1'b1;
    assign next_pm  = (cand_a <= cand_b) ? cand_a : cand_b;
    
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
    output reg [19:0] pm_bus,       // {PM11[4:0], PM10[4:0], PM01[4:0], PM00[4:0]}
    output wire [3:0]  decision_vec  // 4 decision bit tổ hợp {state11, state10, state01, state00}
);

    wire [1:0] bm00;
    wire [1:0] bm01;
    wire [1:0] bm10;
    wire [1:0] bm11;

    wire [4:0] next_pm_00;
    wire [4:0] next_pm_01;
    wire [4:0] next_pm_10;
    wire [4:0] next_pm_11;

    bmc bmc1(.rx_pair(rx_pair), .bm00(bm00), .bm01(bm01), .bm10(bm10), .bm11(bm11));
    acs acs00(.pm_a(pm_bus[4:0]), .pm_b(pm_bus[9:5]), .bma(bm00), .bmb(bm11), .next_pm(next_pm_00), .decision(decision_vec[0]));
    acs acs01(.pm_a(pm_bus[14:10]), .pm_b(pm_bus[19:15]), .bma(bm10), .bmb(bm01), .next_pm(next_pm_01), .decision(decision_vec[1]));
    acs acs10(.pm_a(pm_bus[4:0]), .pm_b(pm_bus[9:5]), .bma(bm11), .bmb(bm00), .next_pm(next_pm_10), .decision(decision_vec[2]));
    acs acs11(.pm_a(pm_bus[14:10]), .pm_b(pm_bus[19:15]), .bma(bm01), .bmb(bm10), .next_pm(next_pm_11), .decision(decision_vec[3]));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pm_bus <= {4{5'd31}};
        end else if (frame_init) begin
            pm_bus <= {5'd31, 5'd31, 5'd31, 5'd0};
        end else if (metric_en) begin
            pm_bus <= {next_pm_11, next_pm_10, next_pm_01, next_pm_00};
        end
    end

endmodule
