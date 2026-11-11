module input_buffer (
    input  wire        clk,         // Clock hệ thống; chốt frame_reg tại cạnh lên
    input  wire        rst_n,       // Reset bất đồng bộ, tích cực mức thấp; xóa frame_reg về 0
    input  wire        frame_load,  // Cho phép nạp data_in vào frame_reg (IDLE & start)
    input  wire [15:0] data_in,     // Khung dữ liệu mã hóa 16-bit (8 cặp bit)
    input  wire [2:0]  fwd_step,    // Chọn cặp bit nhận (0..7)
    output reg [1:0]  rx_pair      // Cặp bit nhận 
);

    reg [15:0] frame_reg;  // Thanh ghi lưu khung dữ liệu mã hóa 16-bit

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            frame_reg <= 16'b0;  // Xóa frame_reg về 0 khi rst_n = 0
        end else if (frame_load) begin
            frame_reg <= data_in;  // Nạp data_in vào frame_reg tại cạnh lên clk khi frame_load = 1
        end
    end
    always@(fwd_step or frame_reg) begin
        case(fwd_step)
            3'd0: rx_pair = frame_reg[15:14];  // Cặp bit nhận đầu tiên
            3'd1: rx_pair = frame_reg[13:12];  // Cặp bit nhận thứ hai
            3'd2: rx_pair = frame_reg[11:10];  // Cặp bit nhận thứ ba
            3'd3: rx_pair = frame_reg[9:8];    // Cặp bit nhận thứ tư
            3'd4: rx_pair = frame_reg[7:6];    // Cặp bit nhận thứ năm
            3'd5: rx_pair = frame_reg[5:4];    // Cặp bit nhận thứ sáu
            3'd6: rx_pair = frame_reg[3:2];    // Cặp bit nhận thứ bảy
            3'd7: rx_pair = frame_reg[1:0];    // Cặp bit nhận cuối cùng
            default: rx_pair = 2'b00;          // Mặc định (không hợp lệ)
        endcase
    end
endmodule
