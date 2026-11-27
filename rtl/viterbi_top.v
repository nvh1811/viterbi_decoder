module viterbi_top (
    input  wire        clk,
    input  wire        rstn,
    input  wire        viterbi_enable,
    input  wire [15:0] input_data,
    output wire [7:0]  output_data,
    output wire        output_done
);
    wire        frame_load;
    wire        frame_init;
    wire        metric_en;
    wire        survivor_we;
    wire        select_en;
    wire        tb_en;
    wire        out_en;
    wire [2:0]  fwd_step;
    wire [2:0]  tb_step;

    wire [1:0]  rx_pair;
    wire [19:0] pm_bus;
    wire [3:0]  decision_vec;
    wire [3:0]  survivor_word;

    controller u_controller (
        .clk            (clk),
        .rstn           (rstn),
        .viterbi_enable (viterbi_enable),
        .frame_load     (frame_load),
        .frame_init     (frame_init),
        .metric_en      (metric_en),
        .survivor_we    (survivor_we),
        .select_en      (select_en),
        .tb_en          (tb_en),
        .out_en         (out_en),
        .fwd_step       (fwd_step),
        .tb_step        (tb_step),
        .output_done    (output_done)
    );

    input_buffer u_input_buffer (
        .clk            (clk),
        .rstn           (rstn),
        .frame_load     (frame_load),
        .input_data     (input_data),
        .fwd_step       (fwd_step),
        .rx_pair        (rx_pair)
    );

    metric_update u_metric_update (
        .clk            (clk),
        .rstn           (rstn),
        .frame_init     (frame_init),
        .metric_en      (metric_en),
        .rx_pair        (rx_pair),
        .pm_bus         (pm_bus),
        .decision_vec   (decision_vec)
    );

    survivor_mem u_survivor_mem (
        .clk            (clk),
        .rstn           (rstn),
        .survivor_we    (survivor_we),
        .fwd_step       (fwd_step),
        .decision_vec   (decision_vec),
        .tb_step        (tb_step),
        .survivor_word  (survivor_word)
    );

    traceback u_traceback (
        .clk            (clk),
        .rstn           (rstn),
        .pm_bus         (pm_bus),
        .survivor_word  (survivor_word),
        .tb_step        (tb_step),
        .select_en      (select_en),
        .tb_en          (tb_en),
        .out_en         (out_en),
        .output_data    (output_data)
    );

endmodule