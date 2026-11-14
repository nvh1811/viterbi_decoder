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
        .bma     (bm_a),
        .bmb     (bm_b),
        .next_pm  (next_pm),
        .decision (decision)
    );

    //Khởi tạo các biến
    integer pa, pb, ba, bb;
    integer tonga, tongb;
    reg [4:0] pm;
    reg dec;

    integer error_count;
    
    initial begin
        error_count = 0;
        
        for (pa = 30; pa <=31; pa = pa + 1) begin
            for (pb = 30; pb <=31; pb = pb + 1) begin
                for (ba = 0; ba <=2; ba = ba + 1) begin
                    for (bb = 0; bb <=2; bb = bb + 1) begin

                        pm_a = pa;
                        pm_b = pb;
                        bm_a = ba;
                        bm_b = bb;
                        #1;

                        tonga = pa + ba;
                        tongb = pb + bb;
                    
                        if (tonga > 31) begin
                            tonga = 31;
                        end
                        if (tongb > 31) begin
                            tongb = 31;
                        end

                        if (tonga > tongb) begin
                            pm = tongb;
                            dec = 1'b1;
                        end
                        if (tonga <= tongb) begin
                            pm = tonga;
                            dec = 1'b0;
                        end

                        if ((next_pm !== pm) || (decision !== dec)) begin
                            error_count = error_count + 1;
                        end
                    end
                end
            end
        end
        // TODO (VT-020b - N05, TC-03):
        // - Kiểm tra bão hòa tại 31 khi pm_a/pm_b = 30, 31 và bm = 0, 1, 2
        // - Kiểm tra chọn nhánh nhỏ hơn và ưu tiên nhánh A (decision = 0) khi hòa
        if (error_count > 0) begin
            $display("TONG SO LOI tb_acs = %0d", error_count);
        end
        #20;
        $finish;
    end

endmodule
