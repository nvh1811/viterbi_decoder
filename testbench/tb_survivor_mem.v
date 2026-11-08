// =============================================================================
// File        : tb_survivor_mem.v
// Module      : tb_survivor_mem
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020c (Phụ trách: Nguyễn Đình Tuyển)
// Tham chiếu  : Mục 9.4 (Bảng 22), N07 — Verification Plan BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_survivor_mem;

    // Tín hiệu kết nối DUT
    reg        clk;
    reg        rst_n;
    reg        survivor_we;
    reg  [2:0] fwd_step;
    reg  [3:0] decision_vec;
    reg  [2:0] tb_step;
    wire [3:0] survivor_word;

    // Khởi tạo DUT
    survivor_mem dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .survivor_we   (survivor_we),
        .fwd_step      (fwd_step),
        .decision_vec  (decision_vec),
        .tb_step       (tb_step),
        .survivor_word (survivor_word)
    );

    // Tạo xung nhịp clock (chu kỳ 5ns)
    initial clk = 1'b0;
    always #2.5 clk = ~clk;

    initial begin
        rst_n        = 1'b0;
        survivor_we  = 1'b0;
        fwd_step     = 3'd0;
        decision_vec = 4'b0000;
        tb_step      = 3'd0;

        // TODO (VT-020c - N07):
        // - Kiểm tra khóa ghi khi rst_n = 0
        // - Kiểm tra ghi đồng bộ 8 hàng (fwd_step = 0..7) khi survivor_we = 1
        // - Kiểm tra đọc tổ hợp survivor_word theo tb_step = 7..0

        #50;
        $finish;
    end

endmodule
