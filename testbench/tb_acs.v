// =============================================================================
// File        : tb_acs.v
// Module      : tb_acs
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020b (Phụ trách: Vũ Nguyễn Đăng Nhật)
// Tham chiếu  : Mục 9.3.1 (Bảng 20), N05, TC-03 — BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_acs;

    // Tín hiệu kết nối DUT
    reg  [4:0] pm_a;
    reg  [4:0] pm_b;
    reg  [1:0] bm_a;
    reg  [1:0] bm_b;
    wire [4:0] next_pm;
    wire       decision;

    // Khởi tạo DUT (module acs)
    acs dut (
        .pm_a     (pm_a),
        .pm_b     (pm_b),
        .bm_a     (bm_a),
        .bm_b     (bm_b),
        .next_pm  (next_pm),
        .decision (decision)
    );

    initial begin
        pm_a = 5'd0;
        pm_b = 5'd31;
        bm_a = 2'd0;
        bm_b = 2'd0;

        // TODO (VT-020b - N05, TC-03):
        // - Kiểm tra bão hòa tại 31 khi pm_a/pm_b = 30, 31 và bm = 0, 1, 2
        // - Kiểm tra chọn nhánh nhỏ hơn và ưu tiên nhánh A (decision = 0) khi hòa

        #20;
        $finish;
    end

endmodule
