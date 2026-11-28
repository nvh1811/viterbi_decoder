`timescale 1ns/1ps

module tb_in_buf;
    reg         clk;
    reg         rstn;
    reg         ctrl_load_flag;
    reg  [15:0] input_data;
    reg  [2:0]  ctrl_fwd_cnt;
    wire [1:0]  met_upd_rx;

    integer err_cnt;
    integer i;
    reg [1:0] exp_pair;

    in_buf dut (
        .clk            (clk),
        .rstn           (rstn),
        .ctrl_load_flag (ctrl_load_flag),
        .input_data     (input_data),
        .ctrl_fwd_cnt   (ctrl_fwd_cnt),
        .met_upd_rx     (met_upd_rx)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_rx;
        input [1:0] exp;
        input [255:0] msg;
        begin
            #1;
            if (met_upd_rx !== exp) begin
                $display("[FAIL] %0s | exp=%b, got=%b", msg, exp, met_upd_rx);
                err_cnt = err_cnt + 1;
            end else begin
                $display("[PASS] %0s | met_upd_rx=%b", msg, met_upd_rx);
            end
        end
    endtask

    task run_frame_sweep;
        input [15:0] frame_val;
        begin
            @(negedge clk);
            ctrl_load_flag = 1'b1;
            input_data     = frame_val;
            @(posedge clk);
            #1;
            ctrl_load_flag = 1'b0;
            input_data     = 16'h0000; // Doi ben ngoai de xac nhan frm_reg da chot

            if (dut.frm_reg !== frame_val) begin
                $display("[FAIL] frm_reg chot sai: exp=%h, got=%h", frame_val, dut.frm_reg);
                err_cnt = err_cnt + 1;
            end else begin
                $display("[PASS] frm_reg chot thanh cong khung 0x%h", dut.frm_reg);
            end

            for (i = 0; i < 8; i = i + 1) begin
                ctrl_fwd_cnt = i[2:0];
                exp_pair     = frame_val[15 - 2*i -: 2];
                check_rx(exp_pair, "TC-01: Tach cap bit dung thu tu tu trai sang phai");
                @(posedge clk);
            end
        end
    endtask

    initial begin
        $display("=== BAT DAU MO PHONG: tb_in_buf (VT-021 | TC-01 & TC-13) ===");
        err_cnt        = 0;
        rstn           = 1'b0;
        ctrl_load_flag = 1'b0;
        input_data     = 16'h0000;
        ctrl_fwd_cnt   = 3'd0;

        // 1. TC-13: Uu tien reset bat dong bo > ctrl_load_flag
        @(negedge clk);
        ctrl_load_flag = 1'b1;
        input_data     = 16'hABCD;
        @(posedge clk);
        check_rx(2'b00, "TC-13: Uu tien rstn=0 bo qua ctrl_load_flag=1");

        // 2. TC-13: Nha reset, giu nguyen gia tri khi ctrl_load_flag=0
        @(negedge clk);
        rstn           = 1'b1;
        ctrl_load_flag = 1'b0;
        @(posedge clk);
        check_rx(2'b00, "TC-13: Giu nguyen frm_reg=0 khi ctrl_load_flag=0");

        // 3. TC-01: Lan luot nap 0xA55A va 0xF00F, quet ctrl_fwd_cnt 0..7
        run_frame_sweep(16'hA55A); // Tao chuoi: 10, 10, 01, 01, 01, 01, 10, 10
        run_frame_sweep(16'hF00F); // Tao chuoi: 11, 11, 00, 00, 00, 00, 11, 11

        // 4. Reset bat dong bo giua chung
        #2;
        rstn = 1'b0;
        ctrl_fwd_cnt = 3'd0;
        check_rx(2'b00, "TC-13: Reset bat dong bo xoa frm_reg giua chung");

        if (err_cnt == 0)
            $display("=== KET QUA tb_in_buf: PASS 100%% (0 loi) ===");
        else
            $display("=== KET QUA tb_in_buf: FAIL (%0d loi) ===", err_cnt);
        $finish;
    end
endmodule