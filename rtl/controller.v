module controller (
    input  wire       clk,         
    input  wire       rstn,        
    input  wire       viterbi_enable,        
    output wire       frame_load,  
    output wire       frame_init,   
    output wire       metric_en,    
    output wire       survivor_we,  
    output wire       select_en, 
    output wire       tb_en,      
    output wire       out_en,      
    output reg  [2:0] fwd_step,     
    output reg  [2:0] tb_step,     
    output reg        output_done          
);
    localparam IDLE       = 3'b000;
    localparam FORWARD    = 3'b001;
    localparam SELECT     = 3'b010;
    localparam TRACEBACK  = 3'b011;
    localparam DONE       = 3'b100;

    reg [2:0] state;
    reg [2:0] next_state;

    always @(*) begin
        case (state)
            IDLE:      next_state = viterbi_enable     ? FORWARD   : IDLE;
            FORWARD:   next_state = (fwd_step == 3'd7) ? SELECT    : FORWARD;
            SELECT:    next_state = TRACEBACK;
            TRACEBACK: next_state = (tb_step == 3'd0)  ? DONE      : TRACEBACK;
            DONE:      next_state = IDLE;
            default:   next_state = IDLE;
        endcase
    end

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            fwd_step    <= 3'd0;
            tb_step     <= 3'd0;
            output_done <= 1'b0;
            state       <= IDLE;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    output_done <= 1'b0;
                    fwd_step    <= viterbi_enable ? 3'd0 : fwd_step;
                end

                FORWARD: begin
                    output_done <= 1'b0;
                    fwd_step    <= (fwd_step == 3'd7) ? fwd_step : (fwd_step + 1'b1);
                end

                SELECT: begin
                    output_done <= 1'b0;
                    tb_step     <= 3'd7;
                end

                TRACEBACK: begin
                    output_done <= 1'b0;
                    tb_step     <= (tb_step == 3'd0) ? tb_step : (tb_step - 1'b1);
                end

                DONE: begin
                    output_done <= 1'b1;
                end

                default: begin
                    fwd_step    <= 3'd0;
                    tb_step     <= 3'd0;
                    output_done <= 1'b0;
                end
            endcase
        end
    end     

    assign frame_load  = rstn && (state == IDLE)      && viterbi_enable;
    assign frame_init  = rstn && (state == IDLE)      && viterbi_enable;
    assign metric_en   = (state == FORWARD);
    assign survivor_we = (state == FORWARD);
    assign select_en   = (state == SELECT);
    assign tb_en       = (state == TRACEBACK);
    assign out_en      = (state == DONE);     

endmodule
