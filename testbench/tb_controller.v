// =============================================================================
// File        : tb_controller.v
// Module      : tb_controller
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020a (Phụ trách: Nguyễn Đình Tuyển)
// Tham chiếu  : Mục 7, Mục 9.6, N10, N11, TC-09, TC-10 — BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_controller;

    // Tín hiệu kết nối DUT
    reg        clk;
    reg        rst_n;
    reg        start;
    wire       frame_load;
    wire       frame_init;
    wire       metric_en;
    wire       survivor_we;
    wire       select_en;
    wire       tb_en;
    wire       out_en;
    wire [2:0] fwd_step;
    wire [2:0] tb_step;
    wire       done;

    integer step;

    // Khởi tạo DUT
    controller dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start),
        .frame_load  (frame_load),
        .frame_init  (frame_init),
        .metric_en   (metric_en),
        .survivor_we (survivor_we),
        .select_en   (select_en),
        .tb_en       (tb_en),
        .out_en      (out_en),
        .fwd_step    (fwd_step),
        .tb_step     (tb_step),
        .done        (done)
    );

    // Tạo xung nhịp clock (chu kỳ 5ns)
    initial clk = 1'b0;
    always #2.5 clk = ~clk;

    initial begin
        $display("=== BAT DAU MO PHONG: tb_controller (VT-020a) ===");
        rst_n = 1'b0;
        start = 1'b0;

        // 1. Kiểm tra trạng thái Reset
        #2;
        if (done !== 1'b0 || frame_load !== 1'b0 || metric_en !== 1'b0 || select_en !== 1'b0 || tb_en !== 1'b0 || out_en !== 1'b0)
            $display("[FAIL] Reset: Tin hieu dieu khien khong ve 0");
        else
            $display("[PASS] Reset: Tat ca enable va done ve 0");

        // Nhả reset tại sườn âm, giữ start = 0 ở IDLE
        @(negedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        #1;
        if (frame_load !== 1'b0 || metric_en !== 1'b0)
            $display("[FAIL] IDLE (start=0): Tu dong chuyen trang thai sai");
        else
            $display("[PASS] IDLE (start=0): Giu trang thai cho");

        // 2. Kiểm tra trình tự 5 pha: IDLE -> FORWARD(8) -> SELECT(1) -> TRACEBACK(8) -> DONE(1) -> IDLE
        // Cấp start = 1 tại IDLE (Trước cạnh E0)
        @(negedge clk);
        start = 1'b1;
        #1;
        if (frame_load !== 1'b1 || frame_init !== 1'b1)
            $display("[FAIL] Truoc canh E0: frame_load=%b, frame_init=%b (Mong doi: 1, 1)", frame_load, frame_init);
        else
            $display("[PASS] Truoc canh E0: Bat frame_load=1 va frame_init=1 (Bang 13)");

        // Cạnh E0: Chuyển từ IDLE -> FORWARD
        @(posedge clk);
        #1;
        start = 1'b0;

        // 8 bước FORWARD (E1..E8)
        for (step = 0; step < 8; step = step + 1) begin
            // Kích thử start=1 ở bước 3 để kiểm tra bỏ qua start khi bận
            if (step == 3) start = 1'b1;
            else start = 1'b0;

            if (metric_en !== 1'b1 || survivor_we !== 1'b1 || fwd_step !== step[2:0])
                $display("[FAIL] FORWARD buoc %0d: metric_en=%b, survivor_we=%b, fwd_step=%0d", 
                         step, metric_en, survivor_we, fwd_step);
            else
                $display("[PASS] FORWARD buoc %0d: metric_en=1, survivor_we=1, fwd_step=%0d", 
                         step, fwd_step);
            @(posedge clk);
            #1;
        end
        start = 1'b0;

        // Trạng thái SELECT (1 chu kỳ)
        if (select_en !== 1'b1 || metric_en !== 1'b0 || survivor_we !== 1'b0)
            $display("[FAIL] SELECT: select_en=%b (Mong doi: 1)", select_en);
        else
            $display("[PASS] SELECT: select_en=1");

        // Cạnh E9: Chuyển từ SELECT -> TRACEBACK (tb_step = 7)
        @(posedge clk);
        #1;

        // 8 bước TRACEBACK (E10..E17)
        for (step = 7; step >= 0; step = step - 1) begin
            if (tb_en !== 1'b1 || tb_step !== step[2:0])
                $display("[FAIL] TRACEBACK buoc %0d: tb_en=%b, tb_step=%0d", step, tb_en, tb_step);
            else
                $display("[PASS] TRACEBACK buoc %0d: tb_en=1, tb_step=%0d", step, tb_step);
            @(posedge clk);
            #1;
        end

        // Trạng thái DONE (1 chu kỳ)
        if (out_en !== 1'b1 || tb_en !== 1'b0 || done !== 1'b0)
            $display("[FAIL] DONE (Truoc canh E18): out_en=%b, done=%b (Mong doi: 1, 0)", out_en, done);
        else
            $display("[PASS] DONE (Truoc canh E18): out_en=1, done=0");

        // Cạnh E18: Chốt done = 1, chuyển về IDLE
        @(posedge clk);
        #1;
        if (done !== 1'b1 || out_en !== 1'b0)
            $display("[FAIL] Sau canh E18: done=%b, out_en=%b (Mong doi: 1, 0)", done, out_en);
        else
            $display("[PASS] Sau canh E18: done=1 (xung bao hoan thanh)");

        // Cạnh E19: Hạ done về 0 tại IDLE
        @(posedge clk);
        #1;
        if (done !== 1'b0)
            $display("[FAIL] Sau canh E19: done=%b (Mong doi: 0)", done);
        else
            $display("[PASS] Sau canh E19: done tu ha ve 0");

        // 3. TC-09: Kiểm tra Reset giữa chừng hủy khung đang xử lý
        @(negedge clk);
        start = 1'b1;
        @(posedge clk);
        #1;
        start = 1'b0;
        @(posedge clk); // Đang ở FORWARD
        #1;
        rst_n = 1'b0;   // Kích reset bất đồng bộ
        #1;
        if (metric_en !== 1'b0 || done !== 1'b0 || fwd_step !== 3'd0)
            $display("[FAIL] TC-09 (Reset giua chung): Khong huy trang thai ve IDLE");
        else
            $display("[PASS] TC-09 (Reset giua chung): Huy khung va dua ve IDLE thanh cong");

        @(negedge clk);
        rst_n = 1'b1;

        // 4. TC-10: Kiểm tra phục hồi từ trạng thái lỗi 101 / 110 / 111
        @(negedge clk);
        dut.state = 3'b101; // Ép vào trạng thái bất hợp lệ 101
        #1;
        if (frame_load !== 1'b0 || frame_init !== 1'b0 || metric_en !== 1'b0 || 
            survivor_we !== 1'b0 || select_en !== 1'b0 || tb_en !== 1'b0 || out_en !== 1'b0)
            $display("[FAIL] TC-10 (FSM loi 101): Cac tin hieu enable khong tat ve 0");
        else
            $display("[PASS] TC-10 (FSM loi 101): Tat toan bo enable ve 0");

        @(posedge clk); // Đợi 1 cạnh lên clock để FSM tự phục hồi về IDLE
        #1;
        if (dut.state !== 3'b000 || done !== 1'b0)
            $display("[FAIL] TC-10 (Phuc hoi FSM): Khong tu dong ve IDLE (state=%b)", dut.state);
        else
            $display("[PASS] TC-10 (Phuc hoi FSM): Tu dong phuc hoi ve IDLE thanh cong");

        #20;
        $display("=== KET THUC MO PHONG: tb_controller ===");
        $finish;
    end

endmodule