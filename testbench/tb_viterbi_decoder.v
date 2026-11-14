// =============================================================================
// File        : tb_viterbi_decoder.v
// Module      : tb_viterbi_decoder (Top-level Testbench)
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-020d (Phụ trách: Vũ Nguyễn Đăng Nhật)
// Tham chiếu  : Verification Plan (TC-05 .. TC-12) — BTL_Nhóm 9_VLSI
// Lưu ý       :
//   - File ../data_file/input.txt chứa 1024 dòng nhị phân 16-bit (đưa vào data_in)
//   - File ../data_file/output.txt chứa 1024 dòng nhị phân 8-bit (đối chiếu data_out)
//   - Sử dụng $readmemb vì dữ liệu trong file ở dạng nhị phân (0/1).
// =============================================================================

`timescale 1ns / 1ps

module tb_viterbi_decoder;

    // Tham số kiểm thử
    localparam NUM_VECTORS = 1025;
    localparam CLK_PERIOD  = 5.0; // 200 MHz (5ns)

    // Tín hiệu kết nối DUT
    reg         clk;
    reg         rst_n;
    reg         start;
    reg  [15:0] data_in;
    wire [7:0]  data_out;
    wire        done;

    // Bộ nhớ lưu Golden Vectors từ thư mục data_file/
    reg [15:0] input_vectors    [0:NUM_VECTORS-1];
    reg [7:0]  expected_outputs [0:NUM_VECTORS-1];

    integer i;
    // Khởi tạo DUT (Top-level module)
    viterbi_decoder dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start),
        .data_in  (data_in),
        .data_out (data_out),
        .done     (done)
    );

    // Tạo xung nhịp clock
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2.0) clk = ~clk;

    // Nạp dữ liệu kiểm thử chuẩn (TC-12)
    initial begin
        $readmemb("../data_file/input.txt",  input_vectors);
        $readmemb("../data_file/output.txt", expected_outputs);
    end

    // Kịch bản kiểm thử chính
    initial begin
        rst_n   = 1'b0;
        start   = 1'b0;
        data_in = 16'h0000;

        // TODO (VT-020d - TC-05 .. TC-12):
        // - Giải phóng reset, đưa từng khung input_vectors[i] vào data_in cùng xung start = 1 (1 clock)
        // - Chờ đúng 18 chu kỳ clock (done == 1), đối chiếu data_out với expected_outputs[i]
        // - Thống kê số lượng PASS / FAIL trên toàn bộ 1024 vector.
        @(negedge clk);
        @(negedge clk);

        rst_n = 1'b1;

        @(negedge clk);
        
        for (i = 0; i < NUM_VECTORS; i = i + 1) begin
            data_in = input_vectors[i];
            start   = 1'b1;
            @(negedge clk);
            start = 1'b0;
            repeat (18) @(posedge clk);
            if (done !== 1'b1) begin
                $display("FAIL - Vector %0d", i);
            end
            else begin
                if (data_out === expected_outputs[i]) begin
                    $display("TRUE - Vector %0d", i);
                end
                else begin
                    $display("FAIL - Vector %0d: Input=%b Expected=%b Actual=%b", i, input_vectors[i], expected_outputs[i], data_out);
                end
            end
        end
        #100;
        $finish;
    end

endmodule
