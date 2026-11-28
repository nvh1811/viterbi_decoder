module viterbi_top (
    input  wire        clk,
    input  wire        rstn,
    input  wire        viterbi_enable,
    input  wire [15:0] input_data,
    output wire [7:0]  output_data,
    output wire        output_done
);
    wire        in_buf_load_flag;
    wire        met_upd_init_flag;
    wire        met_upd_en;
    wire        sur_mem_we;
    wire        trb_sel_flag;
    wire        trb_tb_en;
    wire        trb_out_flag;
    wire [2:0]  fwd_cnt;
    wire [2:0]  tb_cnt;

    wire [1:0]  in_buf_rx;
    wire [19:0] trb_pm;
    wire [3:0]  sur_mem_dec;
    wire [3:0]  trb_word;

    ctrl u_ctrl (
        .clk                    (clk),
        .rstn                   (rstn),
        .viterbi_enable         (viterbi_enable),
        .in_buf_load_flag       (in_buf_load_flag),
        .met_upd_init_flag      (met_upd_init_flag),
        .met_upd_en             (met_upd_en),
        .sur_mem_we             (sur_mem_we),
        .trb_sel_flag           (trb_sel_flag),
        .trb_tb_en              (trb_tb_en),
        .trb_out_flag           (trb_out_flag),
        .in_buf_sur_mem_fwd_cnt (fwd_cnt),
        .sur_mem_trb_tb_cnt     (tb_cnt),
        .output_done            (output_done)
    );

    in_buf u_in_buf (
        .clk            (clk),
        .rstn           (rstn),
        .ctrl_load_flag (in_buf_load_flag),
        .input_data     (input_data),
        .ctrl_fwd_cnt   (fwd_cnt),
        .met_upd_rx     (in_buf_rx)
    );

    met_upd u_met_upd (
        .clk            (clk),
        .rstn           (rstn),
        .ctrl_init_flag (met_upd_init_flag),
        .ctrl_en        (met_upd_en),
        .in_buf_rx      (in_buf_rx),
        .trb_pm         (trb_pm),
        .sur_mem_dec    (sur_mem_dec)
    );

    sur_mem u_sur_mem (
        .clk          (clk),
        .rstn         (rstn),
        .ctrl_we      (sur_mem_we),
        .ctrl_fwd_cnt (fwd_cnt),
        .met_upd_dec  (sur_mem_dec),
        .ctrl_tb_cnt  (tb_cnt),
        .trb_word     (trb_word)
    );

    trb u_trb (
        .clk           (clk),
        .rstn          (rstn),
        .met_upd_pm    (trb_pm),
        .sur_mem_word  (trb_word),
        .ctrl_tb_cnt   (tb_cnt),
        .ctrl_sel_flag (trb_sel_flag),
        .ctrl_tb_en    (trb_tb_en),
        .ctrl_out_flag (trb_out_flag),
        .output_data   (output_data)
    );

endmodule