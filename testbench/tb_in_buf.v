// =============================================================================
// File        : tb_input_buffer.v
// Module      : tb_input_buffer
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020a (Phụ trách: Nguyễn Đình Tuyển)
// Tham chiếu  : Mục 9.1, N03, TC-01 — Verification Plan BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_in_buf;

    // Tín hiệu kết nối DUT
    reg         clk;
    reg         rst_n;
    reg         frame_load;
    reg  [15:0] data_in;
    reg  [2:0]  fwd_step;
    wire [1:0]  rx_pair;

    integer i;
    reg [15:0] test_frame;
    reg [1:0]  exp_pair;

    // Khởi tạo DUT
    input_buffer dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .frame_load (frame_load),
        .data_in    (data_in),
        .fwd_step   (fwd_step),
        .rx_pair    (rx_pair)
    );

    // Tạo xung nhịp clock (chu kỳ 5ns)
    initial clk = 1'b0;
    always #2.5 clk = ~clk;

    initial begin
        $display("=== BAT DAU MO PHONG: tb_input_buffer (VT-020a - TC-01) ===");
        rst_n      = 1'b0;
        frame_load = 1'b0;
        data_in    = 16'h0000;
        fwd_step   = 3'd0;

        // 1. Kiểm tra reset bất đồng bộ xóa frame_reg về 0
        #2;
        if (rx_pair !== 2'b00)
            $display("[FAIL] Reset: rx_pair = %b (Mong doi: 00)", rx_pair);
        else
            $display("[PASS] Reset: rx_pair = %b", rx_pair);

        @(negedge clk);
        rst_n = 1'b1;

        // 2. Kiểm tra giữ nguyên khi frame_load = 0
        data_in    = 16'hFFFF;
        frame_load = 1'b0;
        @(posedge clk);
        #1;
        if (rx_pair !== 2'b00)
            $display("[FAIL] Giu nguyen khi frame_load=0: rx_pair = %b", rx_pair);
        else
            $display("[PASS] Giu nguyen gia tri khi frame_load=0");

        // 3. TC-01 (Gói 1): Nạp gói 16'hA55A và quét fwd_step = 0..7
        test_frame = 16'hA55A;
        @(negedge clk);
        data_in    = test_frame;
        frame_load = 1'b1;
        @(posedge clk);
        #1;
        frame_load = 1'b0;
        data_in    = 16'h0000; // Đổi data_in bên ngoài để kiểm tra tính chốt của thanh ghi

        for (i = 0; i < 8; i = i + 1) begin
            fwd_step = i[2:0];
            #1;
            exp_pair = test_frame[15 - 2*i -: 2];
            if (rx_pair !== exp_pair)
                $display("[FAIL] TC-01 (16'hA55A) fwd_step=%0d: rx_pair=%b (Mong doi: %b)", i, rx_pair, exp_pair);
            else
                $display("[PASS] TC-01 (16'hA55A) fwd_step=%0d: rx_pair=%b", i, rx_pair);
        end

        // 4. TC-01 (Gói 2): Nạp gói 16'hF00F và quét fwd_step = 0..7
        test_frame = 16'hF00F;
        @(negedge clk);
        data_in    = test_frame;
        frame_load = 1'b1;
        @(posedge clk);
        #1;
        frame_load = 1'b0;

        for (i = 0; i < 8; i = i + 1) begin
            fwd_step = i[2:0];
            #1;
            exp_pair = test_frame[15 - 2*i -: 2];
            if (rx_pair !== exp_pair)
                $display("[FAIL] TC-01 (16'hF00F) fwd_step=%0d: rx_pair=%b (Mong doi: %b)", i, rx_pair, exp_pair);
            else
                $display("[PASS] TC-01 (16'hF00F) fwd_step=%0d: rx_pair=%b", i, rx_pair);
        end

        // 5. Kiểm tra reset giữa chừng xóa sạch frame_reg
        #2;
        rst_n = 1'b0;
        #1;
        if (rx_pair !== 2'b00)
            $display("[FAIL] Reset giua chung: rx_pair=%b (Mong doi: 00)", rx_pair);
        else
            $display("[PASS] Reset giua chung xoa frame_reg thanh cong");

        #20;
        $display("=== KET THUC MO PHONG: tb_input_buffer ===");
        $finish;
    end

endmodule