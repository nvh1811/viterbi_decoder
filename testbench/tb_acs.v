`timescale 1ns / 1ps

module tb_acs;

    reg [4:0] met_upd_pm_a;
    reg [4:0] met_upd_pm_b;
    reg [1:0] bmc_bm_a;
    reg [1:0] bmc_bm_b;
    wire [4:0] met_upd_nxt_pm;
    wire met_upd_dec;

    integer pa;
    integer pb;
    integer ba;
    integer bb;
    integer sum_a;
    integer sum_b;
    integer expected_pm;
    integer expected_dec;
    integer error_count;

    acs dut (
        .met_upd_pm_a(met_upd_pm_a),
        .met_upd_pm_b(met_upd_pm_b),
        .bmc_bm_a(bmc_bm_a),
        .bmc_bm_b(bmc_bm_b),
        .met_upd_nxt_pm(met_upd_nxt_pm),
        .met_upd_dec(met_upd_dec)
    );

    initial begin
        error_count = 0;

        for (pa = 0; pa <= 31; pa = pa + 1) begin
            for (pb = 0; pb <= 31; pb = pb + 1) begin
                for (ba = 0; ba <= 2; ba = ba + 1) begin
                    for (bb = 0; bb <= 2; bb = bb + 1) begin
                        met_upd_pm_a = pa;
                        met_upd_pm_b = pb;
                        bmc_bm_a = ba;
                        bmc_bm_b = bb;
                        #1;

                        sum_a = pa + ba;
                        sum_b = pb + bb;

                        if (sum_a >= 31)
                            sum_a = 31;
                        if (sum_b >= 31)
                            sum_b = 31;

                        if (sum_a > sum_b) begin
                            expected_pm = sum_b;
                            expected_dec = 1;
                        end
                        else begin
                            expected_pm = sum_a;
                            expected_dec = 0;
                        end

                        if (met_upd_nxt_pm !== expected_pm[4:0]) begin
                            error_count = error_count + 1;
                        end
                        if (met_upd_dec !== expected_dec[0]) begin
                            error_count = error_count + 1;
                        end
                    end
                end
            end
        end

        if (error_count > 0)
            $display("TONG SO LOI tb_acs = %0d", error_count);

        $finish;
    end

endmodule
