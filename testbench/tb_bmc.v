// =============================================================================
// File        : tb_bmc.v
// Module      : tb_bmc
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020b (Phụ trách: Vũ Nguyễn Đăng Nhật)
// Tham chiếu  : Mục 9.2 (Bảng 18–19), N04, TC-02 — BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_bmc;

    // Tín hiệu kết nối DUT
    reg  [1:0] rx_pair;
    wire [1:0] bm00;
    wire [1:0] bm01;
    wire [1:0] bm10;
    wire [1:0] bm11;

    // Khởi tạo DUT (module bmc)
    bmc dut (
        .rx_pair (rx_pair),
        .bm00    (bm00),
        .bm01    (bm01),
        .bm10    (bm10),
        .bm11    (bm11)
    );

    initial begin
        // kiểm tra khi 00
        rx_pair = 2'b00;
        #1
        if ((bm00 !== 2'd0) || (bm01 !== 2'd1) || (bm10 !== 2'd1) || (bm11 !== 2'd2)) begin
            $display (FAIL);
        end
        else begin
            $display (SUCCESS);
        end

        // kiểm tra khi 10
        rx_pair = 2'b10;
        #1
        if ((bm00 !== 2'd1) || (bm01 !== 2'd2) || (bm10 !== 2'd0) || (bm11 !== 2'd1)) begin
            $display (FAIL);
        end
        else begin
            $display (SUCCESS);
        end

        // kiểm tra khi 01
        rx_pair = 2'b01;
        #1
        if ((bm00 !== 2'd1) || (bm01 !== 2'd0) || (bm10 !== 2'd2) || (bm11 !== 2'd1)) begin
            $display (FAIL);
        end
        else begin
            $display (SUCCESS);
        end

        // kiểm tra khi 11
        rx_pair = 2'b11;
        #1
        if ((bm00 !== 2'd2) || (bm01 !== 2'd1) || (bm10 !== 2'd1) || (bm11 !== 2'd0)) begin
            $display (FAIL);
        end
        else begin
            $display (SUCCESS);
        end
        // TODO (VT-020b - N04, TC-02):
        // - Quét rx_pair = 00, 01, 10, 11 và đối chiếu bm00, bm01, bm10, bm11 với Bảng 19
        // - Kiểm tra phát hiện giá trị không hợp lệ X/Z
        #20;
        $finish;
    end

endmodule
