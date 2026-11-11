module survivor_mem (
    input  wire       clk,            // Clock; ghi bộ nhớ tại cạnh lên
    input  wire       rst_n,          // Tích cực mức 0; khóa ghi khi reset, không xóa mảng
    input  wire       survivor_we,    // Cho phép ghi decision_vec khi rst_n = 1
    input  wire [2:0] fwd_step,       // Địa chỉ hàng ghi (0..7)
    input  wire [3:0] decision_vec,   // 4 decision bit {state11, state10, state01, state00}
    input  wire [2:0] tb_step,        // Địa chỉ hàng đọc khi truy vết (7..0)
    output wire [3:0] survivor_word   // Đầu ra đọc tổ hợp của survivor_mem[tb_step]
);

    reg [3:0] sur_mem [7:0];

    always@(posedge clk) begin
        if(rst_n && survivor_we) begin
            sur_mem[fwd_step] <= decision_vec;
        end
    end

    assign survivor_word = sur_mem[tb_step];

endmodule
