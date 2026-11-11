module controller (
    input  wire       clk,          // Clock; cập nhật FSM, bộ đếm và done tại cạnh lên
    input  wire       rst_n,        // Reset bất đồng bộ, tích cực mức 0
    input  wire       start,        // Yêu cầu nhận khung; chỉ được chấp nhận ở IDLE
    output wire       frame_load,   // IDLE & start=1: chốt khung vào input_buffer
    output wire       frame_init,   // IDLE & start=1: khởi tạo PM cho khung mới
    output wire       metric_en,    // FORWARD: cho phép cập nhật 4 PM
    output wire       survivor_we,  // FORWARD: ghi 4 decision bit vào survivor_mem
    output wire       select_en,    // SELECT: chọn trạng thái bắt đầu truy vết
    output wire       tb_en,        // TRACEBACK: thực hiện 1 bước truy vết
    output wire       out_en,       // DONE: cập nhật data_out
    output reg  [2:0] fwd_step,     // Chỉ số FORWARD (0..7); giữ tại 7 sau bước cuối
    output reg  [2:0] tb_step,      // Nạp 7 tại SELECT; giảm trong TRACEBACK (7..0)
    output reg        done          // Xung 1 clock báo kết quả hợp lệ sau cạnh xử lý DONE
);

    localparam [2:0] IDLE      = 3'b000,
                     FORWARD   = 3'b001,
                     SELECT    = 3'b010,
                     TRACEBACK = 3'b011,
                     DONE      = 3'b100;
    
    reg [2:0] state = IDLE;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
            state    <= IDLE;
            fwd_step <= 3'd0;
            tb_step  <= 3'd7;
            done     <= 1'b0;
        end else begin 
            done <= 1'b0;
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= FORWARD;
                        fwd_step <= 3'd0;
                    end
                end
                FORWARD: begin
                    if (fwd_step == 3'd7) state <= SELECT;
                    else fwd_step <= fwd_step + 3'd1;                      
                end
                SELECT: begin
                    state   <= TRACEBACK;
                    tb_step <= 3'd7;
                end
                FORWARD: begin
                    if(tb_step == 3'd0) state <= DONE;
                    else tb_step <= tb_step - 3'd1;
                end
                DONE: begin
                    done <= 1'b1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    assign frame_load  = (state == IDLE) && start;
    assign frame_init  = (state == IDLE) && start;
    assign metric_en   = (state == FORWARD);
    assign survivor_we = (state == FORWARD);
    assign select_en   = (state == SELECT);
    assign tb_en       = (state == TRACEBACK);
    assign out_en      = (state == DONE);

endmodule
