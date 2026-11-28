`timescale 1ns/1ps

module tb_sur_mem;
    reg        clk;
    reg        rstn;
    reg        ctrl_we;
    reg  [2:0] ctrl_fwd_cnt;
    reg  [3:0] met_upd_dec;
    reg  [2:0] ctrl_tb_cnt;
    wire [3:0] trb_word;

    integer err_cnt;
    integer i;
    reg [3:0] exp_mem [0:7];

    sur_mem dut (
        .clk          (clk),
        .rstn         (rstn),
        .ctrl_we      (ctrl_we),
        .ctrl_fwd_cnt (ctrl_fwd_cnt),
        .met_upd_dec  (met_upd_dec),
        .ctrl_tb_cnt  (ctrl_tb_cnt),
        .trb_word     (trb_word)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $display("=== BAT DAU MO PHONG: tb_sur_mem (VT-023) ===");
        err_cnt      = 0;
        rstn         = 1'b0;
        ctrl_we      = 1'b1; // Thu bat we luc rstn=0 de phu nhanh if (rstn)
        ctrl_fwd_cnt = 3'd0;
        met_upd_dec  = 4'hF;
        ctrl_tb_cnt  = 3'd0;

        // 1. Kiem tra khoa ghi khi rstn = 0
        @(posedge clk);
        #1;
        if (trb_word === 4'hF) begin
            $display("[FAIL] Reset (rstn=0): Khong duoc ghi du lieu moi khi reset");
            err_cnt = err_cnt + 1;
        end else begin
            $display("[PASS] Reset (rstn=0): Khoa ghi du lieu thanh cong");
        end

        // 2. Ghi dong bo 8 hang (ctrl_fwd_cnt = 0..7)
        @(negedge clk);
        rstn    = 1'b1;
        ctrl_we = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            ctrl_fwd_cnt = i[2:0];
            met_upd_dec  = (4'hA + i[3:0]); // Mau du lieu khac nhau cho tung hang
            exp_mem[i]   = (4'hA + i[3:0]);
            @(posedge clk);
            #1;
        end
        $display("[INFO] Da ghi dong bo 8 hang (ctrl_fwd_cnt = 0..7)");

        // 3. Tat ctrl_we=0, thu ghi de va reset giua chung de kiem tra bao toan du lieu
        @(negedge clk);
        ctrl_we      = 1'b0;
        ctrl_fwd_cnt = 3'd3;
        met_upd_dec  = 4'h0;
        @(posedge clk);

        rstn = 1'b0; // Reset khong xoa mang 32 bit
        @(posedge clk);
        rstn = 1'b1;

        // 4. Doc to hop nguoc tu hang 7 ve hang 0 (ctrl_tb_cnt = 7..0)
        for (i = 7; i >= 0; i = i - 1) begin
            ctrl_tb_cnt = i[2:0];
            #2; // Doc to hop khong can doi clock
            if (trb_word !== exp_mem[i]) begin
                $display("[FAIL] Hang %0d: exp=%h, got=%h", i, exp_mem[i], trb_word);
                err_cnt = err_cnt + 1;
            end else begin
                $display("[PASS] Doc to hop hang %0d dung: trb_word=%h", i, trb_word);
            end
        end

        if (err_cnt == 0)
            $display("=== KET QUA tb_sur_mem: PASS 100%% (0 loi) ===");
        else
            $display("=== KET QUA tb_sur_mem: FAIL (%0d loi) ===", err_cnt);
        $finish;
    end
endmodule