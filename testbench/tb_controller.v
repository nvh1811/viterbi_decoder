// =============================================================================
// File        : tb_controller.v
// Module      : tb_controller
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020a (Phụ trách: Nguyễn Đình Tuyển)
// Tham chiếu  : Mục 7, Mục 9.6, N10, N11, TC-09, TC-10 — BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_controller;

    // Tín hiệu kết nối DUT
    reg        clk;
    reg        rst_n;
    reg        start;
    wire       frame_load;
    wire       frame_init;
    wire       metric_en;
    wire       survivor_we;
    wire       select_en;
    wire       tb_en;
    wire       out_en;
    wire [2:0] fwd_step;
    wire [2:0] tb_step;
    wire       done;

    // Khởi tạo DUT
    controller dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start),
        .frame_load  (frame_load),
        .frame_init  (frame_init),
        .metric_en   (metric_en),
        .survivor_we (survivor_we),
        .select_en   (select_en),
        .tb_en       (tb_en),
        .out_en      (out_en),
        .fwd_step    (fwd_step),
        .tb_step     (tb_step),
        .done        (done)
    );

    // Tạo xung nhịp clock (chu kỳ 5ns)
    initial clk = 1'b0;
    always #2.5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        start = 1'b0;

        // TODO (VT-020a - N10, N11, TC-09, TC-10):
        // - Kiểm tra trình tự 5 pha IDLE -> FORWARD(8) -> SELECT(1) -> TRACEBACK(8) -> DONE(1) -> IDLE
        // - Kiểm tra 7 tín hiệu enable theo Bảng 13
        // - Kiểm tra reset giữa chừng (TC-09) và phục hồi từ trạng thái lỗi 101/110/111 (TC-10)

        #50;
        $finish;
    end

endmodule
