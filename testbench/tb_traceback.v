// =============================================================================
// File        : tb_traceback.v
// Module      : tb_traceback
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020c (Phụ trách: Nguyễn Đình Tuyển)
// Tham chiếu  : Mục 9.5 (Bảng 23), N08, N09, TC-04 — BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_traceback;

    // Tín hiệu kết nối DUT
    reg         clk;
    reg         rst_n;
    reg  [19:0] pm_bus;
    reg  [3:0]  survivor_word;
    reg  [2:0]  tb_step;
    reg         select_en;
    reg         tb_en;
    reg         out_en;
    wire [7:0]  data_out;

    // Khởi tạo DUT
    traceback dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .pm_bus        (pm_bus),
        .survivor_word (survivor_word),
        .tb_step       (tb_step),
        .select_en     (select_en),
        .tb_en         (tb_en),
        .out_en        (out_en),
        .data_out      (data_out)
    );

    // Tạo xung nhịp clock (chu kỳ 5ns)
    initial clk = 1'b0;
    always #2.5 clk = ~clk;

    initial begin
        rst_n         = 1'b0;
        pm_bus        = 20'd0;
        survivor_word = 4'd0;
        tb_step       = 3'd7;
        select_en     = 1'b0;
        tb_en         = 1'b0;
        out_en        = 1'b0;

        // TODO (VT-020c - N08, N09, TC-04):
        // - Kiểm tra chọn state có PM nhỏ nhất và quy tắc phá hòa 00 -> 01 -> 10 -> 11 (TC-04)
        // - Kiểm tra 8 bước truy vết ghi decoded_work[7 - tb_step] và chốt ra data_out khi out_en = 1

        #50;
        $finish;
    end

endmodule
