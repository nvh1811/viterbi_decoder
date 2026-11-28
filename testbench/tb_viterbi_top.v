`timescale 1ns / 1ps

module tb_viterbi_top;

    localparam NUM_VECTORS = 1025;
    localparam CLK_PERIOD = 5.0;

    reg clk;
    reg rstn;
    reg viterbi_enable;
    reg [15:0] input_data;
    wire [7:0] output_data;
    wire output_done;

    reg [15:0] input_vectors [0:NUM_VECTORS-1];
    reg [7:0] expected_outputs [0:NUM_VECTORS-1];

    integer i;
    integer j;
    integer error_count;
    integer valid_vectors;
    integer wait_count;

    viterbi_top dut (
        .clk(clk),
        .rstn(rstn),
        .viterbi_enable(viterbi_enable),
        .input_data(input_data),
        .output_data(output_data),
        .output_done(output_done)
    );

    initial begin
        clk = 0;
        forever begin
            @(negedge clk);
            clk = ~clk;
        end
    end

    initial begin
        for (i = 0; i < NUM_VECTORS; i = i + 1) begin
            input_vectors[i] = 16'hxxxx;
            expected_outputs[i] = 8'hxx;
        end

        $readmemb("../data_file/input.txt", input_vectors);
        $readmemb("../data_file/output.txt", expected_outputs);

        #1;
        valid_vectors = 0;
        for (i = 0; i < NUM_VECTORS; i = i + 1) begin
            if ((^input_vectors[i] !== 1'bx) && (^expected_outputs[i] !== 1'bx))
                valid_vectors = valid_vectors + 1;
        end

        if (valid_vectors != NUM_VECTORS) begin
            $display("[ERROR] So dong du lieu hop le khong dung: expected=%0d actual=%0d",
                     NUM_VECTORS, valid_vectors);
            $display("Kiem tra duong dan input.txt va output.txt trong thu muc sim.");
            $finish;
        end
    end

    initial begin
        error_count = 0;
        rstn = 1'b0;
        viterbi_enable = 1'b0;
        input_data = 16'h0000;

        repeat (2) @(negedge clk);
        rstn = 1'b1;

        for (i = 0; i < NUM_VECTORS; i = i + 1) begin
            @(negedge clk);
            input_data = input_vectors[i];
            viterbi_enable = 1'b1;

            @(negedge clk);
            viterbi_enable = 1'b0;

            wait_count = 0;
            while ((output_done !== 1'b1) && (wait_count < 20)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (output_done !== 1'b1) begin
                error_count = error_count + 1;
            end
            else if (output_data !== expected_outputs[i]) begin
                error_count = error_count + 1;
            end

            @(posedge clk);
            #1;
        end

        if (error_count > 0)
            $display("TONG SO LOI tb_viterbi_top = %0d", error_count);

        $finish;
    end

endmodule
