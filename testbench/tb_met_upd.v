`timescale 1ns / 1ps

module tb_met_upd;

    reg clk;
    reg rstn;
    reg ctrl_init_flag;
    reg ctrl_en;
    reg [1:0] in_buf_rx;
    wire [19:0] trb_pm;
    wire [3:0] sur_mem_dec;

    reg [1:0] rx_vectors [0:7];
    reg [4:0] exp_pm00 [0:7];
    reg [4:0] exp_pm01 [0:7];
    reg [4:0] exp_pm10 [0:7];
    reg [4:0] exp_pm11 [0:7];

    integer i;
    integer error_count;

    met_upd dut (
        .clk(clk),
        .rstn(rstn),
        .ctrl_init_flag(ctrl_init_flag),
        .ctrl_en(ctrl_en),
        .in_buf_rx(in_buf_rx),
        .trb_pm(trb_pm),
        .sur_mem_dec(sur_mem_dec)
    );

    initial clk = 1'b0;
    always #2.5 clk = ~clk;

    initial begin
        error_count = 0;
        rstn = 1'b0;
        ctrl_init_flag = 1'b0;
        ctrl_en = 1'b0;
        in_buf_rx = 2'b00;

        rx_vectors[0] = 2'b00;
        rx_vectors[1] = 2'b11;
        rx_vectors[2] = 2'b11;
        rx_vectors[3] = 2'b01;
        rx_vectors[4] = 2'b10;
        rx_vectors[5] = 2'b11;
        rx_vectors[6] = 2'b10;
        rx_vectors[7] = 2'b11;

        exp_pm00[0]=0; exp_pm01[0]=31; exp_pm10[0]=2; exp_pm11[0]=31;
        exp_pm00[1]=2; exp_pm01[1]=3;  exp_pm10[1]=0; exp_pm11[1]=3;
        exp_pm00[2]=3; exp_pm01[2]=1;  exp_pm10[2]=2; exp_pm11[2]=1;
        exp_pm00[3]=2; exp_pm01[3]=1;  exp_pm10[3]=2; exp_pm11[3]=2;
        exp_pm00[4]=2; exp_pm01[4]=2;  exp_pm10[4]=2; exp_pm11[4]=2;
        exp_pm00[5]=2; exp_pm01[5]=3;  exp_pm10[5]=2; exp_pm11[5]=3;
        exp_pm00[6]=3; exp_pm01[6]=2;  exp_pm10[6]=3; exp_pm11[6]=3;
        exp_pm00[7]=2; exp_pm01[7]=4;  exp_pm10[7]=3; exp_pm11[7]=4;

        #1;
        if (trb_pm !== {5'd31, 5'd31, 5'd31, 5'd31}) begin
            $display("[ERROR] Reset PM: expected=31,31,31,31 actual=%h", trb_pm);
            error_count = error_count + 1;
        end

        @(negedge clk);
        rstn = 1'b1;
        ctrl_init_flag = 1'b1;
        ctrl_en = 1'b1;
        @(posedge clk);
        #1;
        if (trb_pm !== {5'd31, 5'd31, 5'd31, 5'd0}) begin
            $display("[ERROR] frame_init priority: expected PM00=0 others=31, actual=%h", trb_pm);
            error_count = error_count + 1;
        end

        @(negedge clk);
        ctrl_init_flag = 1'b0;
        ctrl_en = 1'b0;
        in_buf_rx = 2'b11;
        @(posedge clk);
        #1;
        if (trb_pm !== {5'd31, 5'd31, 5'd31, 5'd0}) begin
            $display("[ERROR] Hold PM when ctrl_en=0: expected=%h actual=%h",
                     {5'd31, 5'd31, 5'd31, 5'd0}, trb_pm);
            error_count = error_count + 1;
        end

        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            in_buf_rx = rx_vectors[i];
            ctrl_en = 1'b1;
            @(posedge clk);
            #1;
            if (trb_pm !== {exp_pm11[i], exp_pm10[i], exp_pm01[i], exp_pm00[i]}) begin
                $display("[ERROR] Step %0d rx=%b expected PM={%0d,%0d,%0d,%0d} actual=%h",
                         i+1, rx_vectors[i], exp_pm11[i], exp_pm10[i], exp_pm01[i], exp_pm00[i], trb_pm);
                error_count = error_count + 1;
            end
        end

        if (error_count > 0)
            $display("TONG SO LOI tb_met_upd = %0d", error_count);

        $finish;
    end

endmodule
