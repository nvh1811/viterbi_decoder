module ctrl (
    input  wire       clk,         
    input  wire       rstn,        
    input  wire       viterbi_enable,        
    output wire       in_buf_load_flag,  
    output wire       met_upd_init_flag,   
    output wire       met_upd_en,    
    output wire       sur_mem_we,  
    output wire       trb_sel_flag, 
    output wire       trb_tb_en,      
    output wire       trb_out_flag,      
    output reg  [2:0] in_buf_sur_mem_fwd_cnt,     
    output reg  [2:0] sur_mem_trb_tb_cnt,     
    output reg        output_done          
);
    localparam IDLE       = 3'b000;
    localparam FORWARD    = 3'b001;
    localparam SELECT     = 3'b010;
    localparam TRACEBACK  = 3'b011;
    localparam DONE       = 3'b100;

    reg [2:0] cur_st;
    reg [2:0] nxt_st;

    always @(*) begin
        case (cur_st)
            IDLE:      nxt_st = viterbi_enable                   ? FORWARD   : IDLE;
            FORWARD:   nxt_st = (in_buf_sur_mem_fwd_cnt == 3'd7) ? SELECT    : FORWARD;
            SELECT:    nxt_st = TRACEBACK;
            TRACEBACK: nxt_st = (sur_mem_trb_tb_cnt == 3'd0)     ? DONE      : TRACEBACK;
            DONE:      nxt_st = IDLE;
            default:   nxt_st = IDLE;
        endcase
    end

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            in_buf_sur_mem_fwd_cnt <= 3'd0;
            sur_mem_trb_tb_cnt     <= 3'd0;
            output_done            <= 1'b0;
            cur_st                 <= IDLE;
        end else begin
            cur_st <= nxt_st;

            case (cur_st)
                IDLE: begin
                    output_done            <= 1'b0;
                    in_buf_sur_mem_fwd_cnt <= viterbi_enable ? 3'd0 : in_buf_sur_mem_fwd_cnt;
                end

                FORWARD: begin
                    output_done            <= 1'b0;
                    in_buf_sur_mem_fwd_cnt <= (in_buf_sur_mem_fwd_cnt == 3'd7) ? in_buf_sur_mem_fwd_cnt : (in_buf_sur_mem_fwd_cnt + 1'b1);
                end

                SELECT: begin
                    output_done        <= 1'b0;
                    sur_mem_trb_tb_cnt <= 3'd7;
                end

                TRACEBACK: begin
                    output_done        <= 1'b0;
                    sur_mem_trb_tb_cnt <= (sur_mem_trb_tb_cnt == 3'd0) ? sur_mem_trb_tb_cnt : (sur_mem_trb_tb_cnt - 1'b1);
                end

                DONE: begin
                    output_done <= 1'b1;
                end

                default: begin
                    in_buf_sur_mem_fwd_cnt <= 3'd0;
                    sur_mem_trb_tb_cnt     <= 3'd0;
                    output_done            <= 1'b0;
                end
            endcase
        end
    end     

    assign in_buf_load_flag  = rstn && (cur_st == IDLE)      && viterbi_enable;
    assign met_upd_init_flag = rstn && (cur_st == IDLE)      && viterbi_enable;
    assign met_upd_en        = (cur_st == FORWARD);
    assign sur_mem_we        = (cur_st == FORWARD);
    assign trb_sel_flag      = (cur_st == SELECT);
    assign trb_tb_en         = (cur_st == TRACEBACK);
    assign trb_out_flag      = (cur_st == DONE);     

endmodule
