// =============================================================================
// File        : tb_survivor_mem.v
// Module      : tb_survivor_mem
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020c (Phụ trách: Nguyễn Đình Tuyển)
// Tham chiếu  : Mục 9.4 (Bảng 22), N07 — Verification Plan BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_sur_mem;

    // Tín hiệu kết nối DUT
    reg        clk;
    reg        rst_n;
    reg        survivor_we;
    reg  [2:0] fwd_step;
    reg  [3:0] decision_vec;
    reg  [2:0] tb_step;
    wire [3:0] survivor_word;

    integer i;
    reg [3:0] test_data [0:7];

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
        $display("=== BAT DAU MO PHONG: tb_survivor_mem (VT-020c - N07) ===");

        test_data[0] = 4'b0001;
        test_data[1] = 4'b1010;
        test_data[2] = 4'b0110;
        test_data[3] = 4'b1100;
        test_data[4] = 4'b0011;
        test_data[5] = 4'b1001;
        test_data[6] = 4'b0101;
        test_data[7] = 4'b1111;

        rst_n        = 1'b0;
        survivor_we  = 1'b0;
        fwd_step     = 3'd0;
        decision_vec = 4'b0000;
        tb_step      = 3'd0;

        // 1. Ghi đồng bộ 8 hàng (fwd_step = 0..7) khi rst_n = 1, survivor_we = 1
        @(negedge clk);
        rst_n = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            survivor_we  = 1'b1;
            fwd_step     = i[2:0];
            decision_vec = test_data[i];
            @(posedge clk);
            #1;
        end
        survivor_we = 1'b0;
        $display("[INFO] N07 - Da ghi dong bo 8 hang (fwd_step = 0..7)");

        // 2. Đọc tổ hợp survivor_word theo tb_step = 7..0
        for (i = 7; i >= 0; i = i - 1) begin
            tb_step = i[2:0];
            #1;
            if (survivor_word !== test_data[i])
                $display("[FAIL] N07 - Doc hang %0d: survivor_word=%b (Mong doi: %b)", 
                         i, survivor_word, test_data[i]);
            else
                $display("[PASS] N07 - Doc to hop hang %0d: survivor_word=%b", 
                         i, survivor_word);
        end

        // 3. Kiểm tra không ghi đè khi survivor_we = 0
        @(negedge clk);
        survivor_we  = 1'b0;
        fwd_step     = 3'd3;
        decision_vec = 4'b0000;
        @(posedge clk);
        #1;
        tb_step = 3'd3;
        #1;
        if (survivor_word !== test_data[3])
            $display("[FAIL] Ghi de khi survivor_we=0: hang 3 bi doi thanh %b", survivor_word);
        else
            $display("[PASS] Giu nguyen du lieu khi survivor_we=0");

        // 4. Kiểm tra khóa ghi khi rst_n = 0 và không xóa mảng đã lưu
        @(negedge clk);
        rst_n        = 1'b0;
        survivor_we  = 1'b1;
        fwd_step     = 3'd5;
        decision_vec = 4'b0000;
        @(posedge clk);
        #1;
        tb_step = 3'd5;
        #1;
        if (survivor_word !== test_data[5])
            $display("[FAIL] N07 (Khoa ghi khi rst_n=0): hang 5 bi thay doi thanh %b", survivor_word);
        else
            $display("[PASS] N07 (Khoa ghi khi rst_n=0): Bao toan mang du lieu thanh cong");

        #50;
        $display("=== KET THUC MO PHONG: tb_survivor_mem ===");
        $finish;
    end

endmodule