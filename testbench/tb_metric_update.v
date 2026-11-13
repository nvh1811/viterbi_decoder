// =============================================================================
// File        : tb_metric_update.v
// Module      : tb_metric_update
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020b (Phụ trách: Vũ Nguyễn Đăng Nhật)
// Tham chiếu  : Mục 9.3.2 (Bảng 21), N05, N06 — BTL_Nhóm 9_VLSI
// =============================================================================

`timescale 1ns / 1ps

module tb_metric_update;

    // Tín hiệu kết nối DUT
    reg         clk;
    reg         rst_n;
    reg         frame_init;
    reg         metric_en;
    reg  [1:0]  rx_pair;
    wire [19:0] pm_bus;
    wire [3:0]  decision_vec;

    // Tách pm_bus để dễ quan sát trên waveform (Mục 6.3)
    wire [4:0] pm00 = pm_bus[4:0];
    wire [4:0] pm01 = pm_bus[9:5];
    wire [4:0] pm10 = pm_bus[14:10];
    wire [4:0] pm11 = pm_bus[19:15];

    // Task
    task buoc;
        input [1:0] rx;
        input [4:0] exp00;
        input [4:0] exp01;
        input [4:0] exp10;
        input [4:0] exp11;

        reg [19:0] old_pm_bus;

        begin
            @(negedge clk);
            old_pm_bus = pm_bus;
            rx_pair = rx;
            metric_en = 1'b1;
            #1;

            if (pm_bus !== old_pm_bus) begin
                $display("FAIL");
            end

            @(posedge clk);
            #1;

            if (pm_bus !== {exp11, exp10, exp01, exp00}) begin

                $display("FAIL: rx_pair = %b", rx);
            end
            else begin

                $display("PASS: rx_pair=%b", rx);
            end
            metric_en = 1'b0;
        end
    endtask
    
    // Khởi tạo DUT
    metric_update dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .frame_init   (frame_init),
        .metric_en    (metric_en),
        .rx_pair      (rx_pair),
        .pm_bus       (pm_bus),
        .decision_vec (decision_vec)
    );

    // Tạo xung nhịp clock (chu kỳ 5ns)
    initial clk = 1'b0;
    always #2.5 clk = ~clk;

    initial begin
        rst_n      = 1'b0;
        frame_init = 1'b0;
        metric_en  = 1'b0;
        rx_pair    = 2'b00;

        #1
        // TODO (VT-020b - N06):
        // - Kiểm tra reset đặt 4 PM = (31, 31, 31, 31)
        if (pm_bus !== {5'd31, 5'd31, 5'd31, 5'd31}) begin
            $display("FALSE");
        end
        else begin
            $display("SUCCESS");
        end
        
        // - Kiểm tra frame_init đặt 4 PM = (0, 31, 31, 31)
        @(negedge clk);
        rst_n      = 1'b1;
        frame_init = 1'b1;
    
        @(posedge clk);
        #1;
        
        if (pm_bus !== {5'd31, 5'd31, 5'd31, 5'd0}) begin
            $display("FALSE");
        end
        else begin
            $display("SUCCESS");
        end

        frame_init = 1'b0;
        
        // - Kiểm tra 8 bước cập nhật PM theo ví dụ Mục 2.5 trong Docs
        // Bước 1
        buoc(2'b00, 5'd0, 5'd31, 5'd2, 5'd31);

        // Bước 2
        buoc(2'b11, 5'd2, 5'd3, 5'd0, 5'd3);

        // Bước 3
        buoc(2'b11, 5'd3, 5'd1, 5'd2, 5'd1);

        // Bước 4
        buoc(2'b01, 5'd2, 5'd1, 5'd4, 5'd1);

        // Bước 5
        buoc(2'b10, 5'd2, 5'd3, 5'd2, 5'd3);

        // Bước 6
        buoc(2'b11, 5'd4, 5'd3, 5'd2, 5'd3);
        
        // Bước 7
        buoc(2'b10, 5'd4, 5'd2, 5'd4, 5'd4);
        
        // Bước 8
        buoc(2'b10, 5'd2, 5'd5, 5'd4, 5'd5);
        
        #50;
        $finish;
    end

endmodule
