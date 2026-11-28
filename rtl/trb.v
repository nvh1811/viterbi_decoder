module trb (
    input  wire        clk,            
    input  wire        rstn,          
    input  wire [19:0] met_upd_pm,         
    input  wire [3:0]  sur_mem_word,  
    input  wire [2:0]  ctrl_tb_cnt,       
    input  wire        ctrl_sel_flag,      
    input  wire        ctrl_tb_en,          
    input  wire        ctrl_out_flag,        
    output reg  [7:0]  output_data        
);
    wire [4:0] pm00 = met_upd_pm[4:0];
    wire [4:0] pm01 = met_upd_pm[9:5];
    wire [4:0] pm10 = met_upd_pm[14:10];
    wire [4:0] pm11 = met_upd_pm[19:15];

    wire [1:0] min_st;

    wire dec;
    wire [1:0] prev_st;

    reg [1:0] tb_st;
    reg [7:0] work_reg;

    assign min_st =     (pm00 <= pm01 && pm00 <= pm10 && pm00 <= pm11) ? 2'b00 :
                        (pm01 <= pm10 && pm01 <= pm11)                 ? 2'b01 :
                        (pm10 <= pm11)                                 ? 2'b10 : 2'b11;

    assign dec =        (tb_st == 2'b00) ? sur_mem_word[0] :
                        (tb_st == 2'b01) ? sur_mem_word[1] :
                        (tb_st == 2'b10) ? sur_mem_word[2] : sur_mem_word[3];

    assign prev_st = {tb_st[0], dec};

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            tb_st       <= 2'b00;
            work_reg    <= 8'd0;
            output_data <= 8'd0;
        end else if(ctrl_sel_flag) begin
            tb_st       <= min_st;
            work_reg    <= 8'd0;
            output_data <= output_data;
        end else if(ctrl_tb_en) begin
            tb_st                        <= prev_st;
            work_reg[3'd7 - ctrl_tb_cnt] <= tb_st[1];
            output_data                  <= output_data;
        end else if(ctrl_out_flag) begin
            tb_st       <= tb_st;
            work_reg    <= work_reg;
            output_data <= work_reg;
        end else begin
            tb_st       <= tb_st;
            work_reg    <= work_reg;
            output_data <= output_data;
        end
    end

endmodule
