`timescale 1ns/1ps

module tb_trb;
    reg         clk;
    reg         rstn;
    reg  [19:0] met_upd_pm;
    reg  [3:0]  sur_mem_word;
    reg  [2:0]  ctrl_tb_cnt;
    reg         ctrl_sel_flag;
    reg         ctrl_tb_en;
    reg         ctrl_out_flag;
    wire [7:0]  output_data;

    integer err_cnt;
    integer step;
    reg [3:0] sur_rom [0:7];

    trb dut (
        .clk           (clk),
        .rstn          (rstn),
        .met_upd_pm    (met_upd_pm),
        .sur_mem_word  (sur_mem_word),
        .ctrl_tb_cnt   (ctrl_tb_cnt),
        .ctrl_sel_flag (ctrl_sel_flag),
        .ctrl_tb_en    (ctrl_tb_en),
        .ctrl_out_flag (ctrl_out_flag),
        .output_data   (output_data)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task test_select_tie;
        input [19:0] pm_vec;
        input [1:0]  exp_st;
        input [255:0] msg;
        begin
            @(negedge clk);
            met_upd_pm    = pm_vec;
            ctrl_sel_flag = 1'b1;
            @(posedge clk);
            #1;
            ctrl_sel_flag = 1'b0;
            if (dut.tb_st !== exp_st) begin
                $display("[FAIL] %0s | exp_st=%b, got=%b", msg, exp_st, dut.tb_st);
                err_cnt = err_cnt + 1;
            end else begin
                $display("[PASS] %0s | tb_st=%b", msg, dut.tb_st);
            end
        end
    endtask

    initial begin
        $display("=== BAT DAU MO PHONG: tb_trb (VT-023 | TC-04 & TC-13) ===");
        err_cnt       = 0;
        rstn          = 1'b0;
        met_upd_pm    = 20'd0;
        sur_mem_word  = 4'd0;
        ctrl_tb_cnt   = 3'd0;
        ctrl_sel_flag = 1'b0;
        ctrl_tb_en    = 1'b0;
        ctrl_out_flag = 1'b0;

        // 1. TC-13: Reset
        @(posedge clk);
        #1;
        if (output_data !== 8'd0 || dut.tb_st !== 2'b00 || dut.work_reg !== 8'd0) begin
            $display("[FAIL] Reset: Thanh ghi chua ve 0");
            err_cnt = err_cnt + 1;
        end else begin
            $display("[PASS] TC-13: Reset tb_st, work_reg, output_data ve 0");
        end

        @(negedge clk);
        rstn = 1'b1;

        // 2. TC-04 & Phu luc A.2: Kiem tra quy tac uu tien hoa (00 -> 01 -> 10 -> 11)
        // Gom ca 4 cap hoa dac biet khong xuat hien o top: 00-01, 00-11, 01-10, 10-11
        // Dinh dang: {pm11, pm10, pm01, pm00}
        test_select_tie({5'd3, 5'd3, 5'd3, 5'd3}, 2'b00, "Hoa 4 state (00-01-10-11) -> chon 00");
        test_select_tie({5'd7, 5'd6, 5'd2, 5'd2}, 2'b00, "Hoa 2 state dac biet (00-01) -> chon 00");
        test_select_tie({5'd2, 5'd6, 5'd7, 5'd2}, 2'b00, "Hoa 2 state dac biet (00-11) -> chon 00");
        test_select_tie({5'd7, 5'd2, 5'd2, 5'd6}, 2'b01, "Hoa 2 state dac biet (01-10) -> chon 01");
        test_select_tie({5'd4, 5'd4, 5'd4, 5'd8}, 2'b01, "Hoa 3 state (01-10-11) -> chon 01");
        test_select_tie({5'd5, 5'd5, 5'd9, 5'd9}, 2'b10, "Hoa 2 state dac biet (10-11) -> chon 10");
        test_select_tie({5'd2, 5'd7, 5'd7, 5'd7}, 2'b11, "State 11 nho nhat -> chon 11");

        // 3. TC-13: Giu nguyen thanh ghi khi cac enable = 0
        @(posedge clk);
        #1;
        if (dut.tb_st !== 2'b11) begin
            $display("[FAIL] TC-13: Giu nguyen trang thai khi enable=0");
            err_cnt = err_cnt + 1;
        end else begin
            $display("[PASS] TC-13: Giu nguyen thanh ghi khi cac enable=0");
        end

        // 4. TC-04 & TC-13: Chu trinh SELECT -> TRACEBACK (8 buoc) -> DONE -> Ban tin: 8'hB6
        sur_rom[7] = 4'b0100; // S8=10 (1), dec=sur[2]=1 -> S7=01
        sur_rom[6] = 4'b0010; // S7=01 (0), dec=sur[1]=1 -> S6=11
        sur_rom[5] = 4'b0000; // S6=11 (1), dec=sur[3]=0 -> S5=10
        sur_rom[4] = 4'b0100; // S5=10 (1), dec=sur[2]=1 -> S4=01
        sur_rom[3] = 4'b0010; // S4=01 (0), dec=sur[1]=1 -> S3=11
        sur_rom[2] = 4'b0000; // S3=11 (1), dec=sur[3]=0 -> S2=10
        sur_rom[1] = 4'b0000; // S2=10 (1), dec=sur[2]=0 -> S1=00
        sur_rom[0] = 4'b0000; // S1=00 (0), dec=sur[0]=0 -> S0=00

        // SELECT
        @(negedge clk);
        met_upd_pm    = {5'd9, 5'd1, 5'd5, 5'd4};
        ctrl_sel_flag = 1'b1;
        @(posedge clk);
        #1;
        ctrl_sel_flag = 1'b0;
        $display("[INFO] SELECT: Chon trang thai bat dau truy vet tb_st=%b", dut.tb_st);

        // TRACEBACK 8 buoc
        for (step = 7; step >= 0; step = step - 1) begin
            @(negedge clk);
            ctrl_tb_en   = 1'b1;
            ctrl_tb_cnt  = step[2:0];
            sur_mem_word = sur_rom[step];
            @(posedge clk);
        end
        @(negedge clk);
        ctrl_tb_en = 1'b0;

        // DONE
        ctrl_out_flag = 1'b1;
        @(posedge clk);
        #1;
        ctrl_out_flag = 1'b0;
        if (output_data !== 8'hB6 || dut.tb_st !== 2'b00) begin
            $display("[FAIL] DONE: exp output_data=8'hB6 (got %h), tb_st=00 (got %b)",
                     output_data, dut.tb_st);
            err_cnt = err_cnt + 1;
        end else begin
            $display("[PASS] DONE: Khoi phuc chinh xac output_data=8'hB6 va lui ve state 00");
        end

        if (err_cnt == 0)
            $display("=== KET QUA tb_trb: PASS 100%% (0 loi) ===");
        else
            $display("=== KET QUA tb_trb: FAIL (%0d loi) ===", err_cnt);
        $finish;
    end
endmodule