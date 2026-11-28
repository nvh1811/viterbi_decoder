`timescale 1ns/1ps

module tb_ctrl;
    reg        clk;
    reg        rstn;
    reg        viterbi_enable;
    wire       in_buf_load_flag;
    wire       met_upd_init_flag;
    wire       met_upd_en;
    wire       sur_mem_we;
    wire       trb_sel_flag;
    wire       trb_tb_en;
    wire       trb_out_flag;
    wire [2:0] in_buf_sur_mem_fwd_cnt;
    wire [2:0] sur_mem_trb_tb_cnt;
    wire       output_done;

    integer err_cnt;
    integer step;

    ctrl dut (
        .clk                    (clk),
        .rstn                   (rstn),
        .viterbi_enable         (viterbi_enable),
        .in_buf_load_flag       (in_buf_load_flag),
        .met_upd_init_flag      (met_upd_init_flag),
        .met_upd_en             (met_upd_en),
        .sur_mem_we             (sur_mem_we),
        .trb_sel_flag           (trb_sel_flag),
        .trb_tb_en              (trb_tb_en),
        .trb_out_flag           (trb_out_flag),
        .in_buf_sur_mem_fwd_cnt (in_buf_sur_mem_fwd_cnt),
        .sur_mem_trb_tb_cnt     (sur_mem_trb_tb_cnt),
        .output_done            (output_done)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_enables;
        input [6:0] exp_en; // {load, init, upd_en, we, sel, tb_en, out}
        input       exp_done;
        input [255:0] msg;
        reg   [6:0] got_en;
        begin
            #1;
            got_en = {in_buf_load_flag, met_upd_init_flag, met_upd_en, sur_mem_we,
                      trb_sel_flag, trb_tb_en, trb_out_flag};
            if (got_en !== exp_en || output_done !== exp_done) begin
                $display("[FAIL] %0s | exp_en=%b got_en=%b | exp_done=%b got_done=%b",
                         msg, exp_en, got_en, exp_done, output_done);
                err_cnt = err_cnt + 1;
            end else begin
                $display("[PASS] %0s", msg);
            end
        end
    endtask

    initial begin
        $display("=== BAT DAU MO PHONG: tb_ctrl (VT-021) ===");
        err_cnt        = 0;
        rstn           = 1'b0;
        viterbi_enable = 1'b1; // Thu bat enable luc reset=0 de phu Condition coverage

        // 1. Reset
        @(posedge clk);
        check_enables(7'b0000000, 1'b0, "Reset (rstn=0): Tat ca enable=0 du viterbi_enable=1");

        // 2. IDLE voi viterbi_enable = 0
        @(negedge clk);
        rstn           = 1'b1;
        viterbi_enable = 1'b0;
        @(posedge clk);
        check_enables(7'b0000000, 1'b0, "IDLE (viterbi_enable=0): Giu trang thai cho");

        // 3. Kich viterbi_enable = 1 tai IDLE
        @(negedge clk);
        viterbi_enable = 1'b1;
        check_enables(7'b1100000, 1'b0, "IDLE (viterbi_enable=1): Bat load_flag & init_flag");

        // 4. 8 chu ky FORWARD (fwd_cnt = 0..7)
        for (step = 0; step < 8; step = step + 1) begin
            @(posedge clk);
            viterbi_enable = (step == 3) ? 1'b1 : 1'b0; // Thu xen ngang enable khi ban
            #1;
            if (in_buf_sur_mem_fwd_cnt !== step[2:0]) begin
                $display("[FAIL] FORWARD fwd_cnt=%0d, exp=%0d", in_buf_sur_mem_fwd_cnt, step);
                err_cnt = err_cnt + 1;
            end
            check_enables(7'b0011000, 1'b0, "FORWARD: Bat met_upd_en & sur_mem_we");
        end

        // 5. SELECT (1 chu ky)
        @(posedge clk);
        check_enables(7'b0000100, 1'b0, "SELECT: Bat trb_sel_flag");

        // 6. 8 chu ky TRACEBACK (tb_cnt = 7..0)
        for (step = 7; step >= 0; step = step - 1) begin
            @(posedge clk);
            #1;
            if (sur_mem_trb_tb_cnt !== step[2:0]) begin
                $display("[FAIL] TRACEBACK tb_cnt=%0d, exp=%0d", sur_mem_trb_tb_cnt, step);
                err_cnt = err_cnt + 1;
            end
            check_enables(7'b0000010, 1'b0, "TRACEBACK: Bat trb_tb_en");
        end

        // 7. DONE (1 chu ky) & quay ve IDLE
        @(posedge clk);
        viterbi_enable = 1'b1; // Bo qua enable khi dang DONE
        check_enables(7'b0000001, 1'b0, "DONE (truoc canh): Bat trb_out_flag");

        @(posedge clk);
        viterbi_enable = 1'b0;
        check_enables(7'b0000000, 1'b1, "Sau DONE: Phat xung output_done=1 trong 1 chu ky");

        @(posedge clk);
        check_enables(7'b0000000, 1'b0, "IDLE ke tiep: output_done tu ha ve 0");

        // 8. Kiem tra Reset giua chung khi dang FORWARD
        @(negedge clk);
        viterbi_enable = 1'b1;
        @(posedge clk);
        @(negedge clk);
        viterbi_enable = 1'b0;
        rstn           = 1'b0;
        @(posedge clk);
        check_enables(7'b0000000, 1'b0, "Reset giua chung: Huy khung ve IDLE");
        @(negedge clk);
        rstn = 1'b1;

        // 9. Phuc hoi trang thai FSM khong hop le (101, 110, 111) -> 100% FSM & Branch coverage
        force dut.cur_st = 3'b101;
        #2;
        check_enables(7'b0000000, 1'b0, "FSM loi 101: Tat toan bo enable");
        release dut.cur_st;
        @(posedge clk);
        check_enables(7'b0000000, 1'b0, "FSM loi 101: Phuc hoi ve IDLE");

        force dut.cur_st = 3'b110;
        @(posedge clk);
        release dut.cur_st;
        @(posedge clk);
        check_enables(7'b0000000, 1'b0, "FSM loi 110: Phuc hoi ve IDLE");

        force dut.cur_st = 3'b111;
        @(posedge clk);
        release dut.cur_st;
        @(posedge clk);
        check_enables(7'b0000000, 1'b0, "FSM loi 111: Phuc hoi ve IDLE");

        if (err_cnt == 0)
            $display("=== KET QUA tb_ctrl: PASS 100%% (0 loi) ===");
        else
            $display("=== KET QUA tb_ctrl: FAIL (%0d loi) ===", err_cnt);
        $finish;
    end
endmodule