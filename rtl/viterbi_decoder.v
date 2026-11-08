// =============================================================================
// File        : viterbi_decoder.v
// Module      : viterbi_decoder (Top-level Module)
// Project     : Bộ giải mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI
// Task        : VT-019 (Phụ trách: Nguyễn Văn Hiếu)
// Tham chiếu  : Mục 4.1 (Bảng 6), Mục 5 & Mục 6 — Đặc tả thiết kế BTL_Nhóm 9_VLSI
// Chức năng   :
//   - Kết nối 5 khối chức năng: input_buffer, metric_update, survivor_mem,
//     traceback, và controller.
// =============================================================================

module viterbi_decoder (
    input  wire        clk,       // Clock hệ thống (cạnh lên)
    input  wire        rst_n,     // Reset bất đồng bộ, tích cực mức thấp
    input  wire        start,     // Yêu cầu giải mã (1 chu kỳ khi IDLE)
    input  wire [15:0] data_in,   // Khung dữ liệu mã hóa 16-bit (8 cặp bit)
    output wire [7:0]  data_out,  // Kết quả giải mã 8-bit (hợp lệ khi done = 1)
    output wire        done       // Báo hoàn thành giải mã trong 1 chu kỳ clock
);

    // -------------------------------------------------------------------------
    // Dây tín hiệu điều khiển nội bộ (Bảng 12 - Mục 6.2)
    // -------------------------------------------------------------------------
    wire       frame_load;
    wire       frame_init;
    wire       metric_en;
    wire       survivor_we;
    wire       select_en;
    wire       tb_en;
    wire       out_en;

    // -------------------------------------------------------------------------
    // Dây tín hiệu dữ liệu & địa chỉ nội bộ (Bảng 11 - Mục 6.1)
    // -------------------------------------------------------------------------
    wire [2:0]  fwd_step;
    wire [2:0]  tb_step;
    wire [1:0]  rx_pair;
    wire [19:0] pm_bus;
    wire [3:0]  decision_vec;
    wire [3:0]  survivor_word;

    // -------------------------------------------------------------------------
    // Khởi tạo và kết nối 5 khối chức năng (Bảng 9 - Mục 5.2)
    // -------------------------------------------------------------------------
    controller u_controller (
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

    input_buffer u_input_buffer (
        .clk         (clk),
        .rst_n       (rst_n),
        .frame_load  (frame_load),
        .data_in     (data_in),
        .fwd_step    (fwd_step),
        .rx_pair     (rx_pair)
    );

    metric_update u_metric_update (
        .clk          (clk),
        .rst_n        (rst_n),
        .frame_init   (frame_init),
        .metric_en    (metric_en),
        .rx_pair      (rx_pair),
        .pm_bus       (pm_bus),
        .decision_vec (decision_vec)
    );

    survivor_mem u_survivor_mem (
        .clk           (clk),
        .rst_n         (rst_n),
        .survivor_we   (survivor_we),
        .fwd_step      (fwd_step),
        .decision_vec  (decision_vec),
        .tb_step       (tb_step),
        .survivor_word (survivor_word)
    );

    traceback u_traceback (
        .clk           (clk),
        .rst_n         (rst_n),
        .pm_bus        (pm_bus),
        .survivor_word (survivor_word),
        .tb_step       (tb_step),
        .select_en     (select_en),
        .tb_en         (tb_en),
        .out_en        (out_en),
        .data_out      (data_out)
    );

endmodule
