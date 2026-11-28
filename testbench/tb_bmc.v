`timescale 1ns / 1ps

module tb_bmc;

    reg [1:0] in_buf_rx;
    wire [1:0] acs_bm00;
    wire [1:0] acs_bm01;
    wire [1:0] acs_bm10;
    wire [1:0] acs_bm11;

    reg [1:0] expected_bm00;
    reg [1:0] expected_bm01;
    reg [1:0] expected_bm10;
    reg [1:0] expected_bm11;

    integer i;
    integer error_count;

    bmc dut (
        .in_buf_rx(in_buf_rx),
        .acs_bm00(acs_bm00),
        .acs_bm01(acs_bm01),
        .acs_bm10(acs_bm10),
        .acs_bm11(acs_bm11)
    );

    initial begin
        error_count = 0;

        for (i = 0; i < 4; i = i + 1) begin
            in_buf_rx = i;
            case (i)
                0: begin
                    expected_bm00 = 0;
                    expected_bm01 = 1;
                    expected_bm10 = 1;
                    expected_bm11 = 2;
                end
                1: begin
                    expected_bm00 = 1;
                    expected_bm01 = 0;
                    expected_bm10 = 2;
                    expected_bm11 = 1;
                end
                2: begin
                    expected_bm00 = 1;
                    expected_bm01 = 2;
                    expected_bm10 = 0;
                    expected_bm11 = 1;
                end
                default: begin
                    expected_bm00 = 2;
                    expected_bm01 = 1;
                    expected_bm10 = 1;
                    expected_bm11 = 0;
                end
            endcase

            #1;
            if (acs_bm00 !== expected_bm00) begin
                $display("[ERROR] BMC rx=%b bm00: expected=%d actual=%d", in_buf_rx, expected_bm00, acs_bm00);
                error_count = error_count + 1;
            end
            if (acs_bm01 !== expected_bm01) begin
                $display("[ERROR] BMC rx=%b bm01: expected=%d actual=%d", in_buf_rx, expected_bm01, acs_bm01);
                error_count = error_count + 1;
            end
            if (acs_bm10 !== expected_bm10) begin
                $display("[ERROR] BMC rx=%b bm10: expected=%d actual=%d", in_buf_rx, expected_bm10, acs_bm10);
                error_count = error_count + 1;
            end
            if (acs_bm11 !== expected_bm11) begin
                $display("[ERROR] BMC rx=%b bm11: expected=%d actual=%d", in_buf_rx, expected_bm11, acs_bm11);
                error_count = error_count + 1;
            end
        end

        if (error_count > 0)
            $display("TONG SO LOI tb_bmc = %0d", error_count);

        $finish;
    end

endmodule
