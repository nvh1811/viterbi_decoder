// =============================================================================
// File        : tb_traceback.v
// Module      : tb_traceback
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020c (Phụ trách: Nguyễn Đình Tuyển)
// Tham chiếu  : Mục 9.5 (Bảng 23), N08, N09, TC-04 — BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_trb;

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

    integer i;
    reg [3:0] mock_sur_mem [0:7];

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
        $display("=== BAT DAU MO PHONG: tb_traceback (VT-020c - N08, N09, TC-04) ===");
        rst_n         = 1'b0;
        pm_bus        = 20'd0;
        survivor_word = 4'd0;
        tb_step       = 3'd7;
        select_en     = 1'b0;
        tb_en         = 1'b0;
        out_en        = 1'b0;

        // 1. Kiểm tra reset bất đồng bộ xóa data_out về 0
        #2;
        if (data_out !== 8'h00)
            $display("[FAIL] Reset: data_out = %h (Mong doi: 00)", data_out);
        else
            $display("[PASS] Reset: data_out = 00");

        @(negedge clk);
        rst_n = 1'b1;

        // 2. N08 & N09: Kiểm tra chọn PM nhỏ nhất và 8 bước truy vết (Bản tin gốc: 8'b10110010 = 8'hB2)
        mock_sur_mem[0] = 4'b0000;
        mock_sur_mem[1] = 4'b0000;
        mock_sur_mem[2] = 4'b0100;
        mock_sur_mem[3] = 4'b0000;
        mock_sur_mem[4] = 4'b0010;
        mock_sur_mem[5] = 4'b0001;
        mock_sur_mem[6] = 4'b0000;
        mock_sur_mem[7] = 4'b0000;

        // Cấp PM cuối: PM01 = 2 (nhỏ nhất) -> start state = 01
        @(negedge clk);
        pm_bus    = {5'd8, 5'd6, 5'd2, 5'd5};
        select_en = 1'b1;
        @(posedge clk);
        #1;
        select_en = 1'b0;
        $display("[INFO] N08 - Chon trang thai bat dau truy vet (PM01=2 nho nhat)");

        // Thực hiện 8 bước TRACEBACK (tb_step = 7..0)
        for (i = 7; i >= 0; i = i - 1) begin
            @(negedge clk);
            tb_step       = i[2:0];
            survivor_word = mock_sur_mem[i];
            tb_en         = 1'b1;
            @(posedge clk);
            #1;
            if (data_out !== 8'h00)
                $display("[FAIL] N09 - data_out bi thay doi som tai buoc tb_step=%0d", i);
        end
        tb_en = 1'b0;

        // Chốt kết quả ra data_out khi out_en = 1
        @(negedge clk);
        out_en = 1'b1;
        @(posedge clk);
        #1;
        out_en = 1'b0;

        if (data_out !== 8'b10110010)
            $display("[FAIL] N09 - Ket qua giai ma: data_out=%b (Mong doi: 10110010)", data_out);
        else
            $display("[PASS] N09 - Ket qua giai ma chinh xac: data_out=%b (8'h%h)", data_out, data_out);

        // 3. TC-04: Kiểm tra quy tắc phá hòa chọn PM cuối (Ưu tiên 00 -> 01 -> 10 -> 11)
        for (i = 0; i < 8; i = i + 1) mock_sur_mem[i] = 4'b0000;

        @(negedge clk);
        pm_bus    = {5'd4, 5'd4, 5'd4, 5'd4}; // 4 PM bằng nhau -> ưu tiên chọn 00
        select_en = 1'b1;
        @(posedge clk);
        #1;
        select_en = 1'b0;

        for (i = 7; i >= 0; i = i - 1) begin
            @(negedge clk);
            tb_step       = i[2:0];
            survivor_word = mock_sur_mem[i];
            tb_en         = 1'b1;
            @(posedge clk);
            #1;
        end
        tb_en = 1'b0;

        if (data_out !== 8'b10110010)
            $display("[FAIL] TC-04 - Khong giu ket qua cu truoc khi out_en=1");
        else
            $display("[PASS] TC-04 - Giu nguyen ket qua cu (%b) trong khi xu ly khung moi", data_out);

        @(negedge clk);
        out_en = 1'b1;
        @(posedge clk);
        #1;
        out_en = 1'b0;

        if (data_out !== 8'b00000000)
            $display("[FAIL] TC-04 - Pha hoa chon PM: data_out=%b (Mong doi: 00000000)", data_out);
        else
            $display("[PASS] TC-04 - Pha hoa uu tien 00 chinh xac: data_out=%b", data_out);

        #50;
        $display("=== KET THUC MO PHONG: tb_traceback ===");
        $finish;
    end

endmodule