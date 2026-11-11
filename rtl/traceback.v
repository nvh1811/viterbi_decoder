module traceback (
    input  wire        clk,            // Clock; cập nhật thanh ghi tại cạnh lên
    input  wire        rst_n,          // Reset bất đồng bộ, tích cực mức 0
    input  wire [19:0] pm_bus,         // 4 PM cuối {PM11, PM10, PM01, PM00}
    input  wire [3:0]  survivor_word,  // Hàng decision đang đọc tại tb_step
    input  wire [2:0]  tb_step,        // Chỉ số bước truy vết (7..0)
    input  wire        select_en,      // Chọn state có PM nhỏ nhất và xóa decoded_work
    input  wire        tb_en,          // Thực hiện 1 bước truy vết và ghi 1 bit vào decoded_work
    input  wire        out_en,         // Chuyển đủ 8 bit decoded_work sang data_out
    output reg  [7:0]  data_out        // Kết quả giải mã 8-bit; giữ giá trị đến lần xuất tiếp theo
);
    reg [7:0] decoder_work;
    reg [1:0] tb_state;

    wire [4:0] pm00 = pm_bus[4:0];
    wire [4:0] pm01 = pm_bus[9:5];
    wire [4:0] pm10 = pm_bus[14:10];
    wire [4:0] pm11 = pm_bus[19:15];

    reg [4:0] pm_min;
    reg [1:0] min_state;

    reg [1:0] parent_state;
    wire decision_bit = survivor_word[tb_state];

    always@(*) begin
        pm_min = pm00;
        min_state = 2'b00;
        if (pm01 < pm_min) begin
            pm_min = pm01;
            min_state = 2'b01;
        end else if(pm10 < pm_min) begin
            pm_min = pm10;
            min_state = 2'b10;
        end else if(pm11 < pm_min) begin
            pm_min = pm11;
            min_state = 2'b11;
        end
    end

    always@(*) begin
        case(tb_state) 
            2'b00: parent_state = (decision_bit == 0) ? 2'b00 : 2'b01;
            2'b01: parent_state = (decision_bit == 0) ? 2'b10 : 2'b11;
            2'b10: parent_state = (decision_bit == 0) ? 2'b00 : 2'b01;
            2'b11: parent_state = (decision_bit == 0) ? 2'b10 : 2'b11;
            default: parent_state = 2'b00;
        endcase
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tb_state <= 2'b00;
            decoder_work <= 8'd0;
            data_out <= 8'd0;
        end else if(select_en) begin
            tb_state <= min_state;
            decoder_work <= 8'd0;
        end else if(tb_en) begin
            decoder_work[3'd7 - tb_step] <= tb_state[1];
            tb_state <= parent_state;
        end else if(out_en) begin
            data_out <= decoder_work;
        end
    end
endmodule
