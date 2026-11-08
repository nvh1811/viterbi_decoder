// =============================================================================
// File        : tb_input_buffer.v
// Module      : tb_input_buffer
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020a (Phụ trách: Nguyễn Đình Tuyển)
// Tham chiếu  : Mục 9.1, N03, TC-01 — Verification Plan BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_input_buffer;

    // Tín hiệu kết nối DUT
    reg         clk;
    reg         rst_n;
    reg         frame_load;
    reg  [15:0] data_in;
    reg  [2:0]  fwd_step;
    wire [1:0]  rx_pair;

    // Khởi tạo DUT
    input_buffer dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .frame_load (frame_load),
        .data_in    (data_in),
        .fwd_step   (fwd_step),
        .rx_pair    (rx_pair)
    );

    // Tạo xung nhịp clock (ví dụ 200 MHz -> chu kỳ 5ns)
    initial clk = 1'b0;
    always #2.5 clk = ~clk;

    initial begin
        // Khởi tạo tín hiệu
        rst_n      = 1'b0;
        frame_load = 1'b0;
        data_in    = 16'h0000;
        fwd_step   = 3'd0;

        // TODO (VT-020a - TC-01): Kiểm tra reset, nạp gói 16'hA55A / 16'hF00F
        // và quét fwd_step = 0..7 kiểm tra rx_pair xuất đúng từ MSB đến LSB.

        #20;
        $finish;
    end

endmodule
