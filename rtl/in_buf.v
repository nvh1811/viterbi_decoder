module in_buf (
    input  wire        clk,        
    input  wire        rstn,       
    input  wire        ctrl_load_flag,  
    input  wire [15:0] input_data,    
    input  wire [2:0]  ctrl_fwd_cnt,    
    output wire [1:0]  met_upd_rx  
);   
    reg [15:0] frm_reg;

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            frm_reg <= 16'b0;
        end else if(ctrl_load_flag) begin
            frm_reg <= input_data;
        end else begin
            frm_reg <= frm_reg;
        end
    end

    assign met_upd_rx = (ctrl_fwd_cnt == 3'd0) ? frm_reg[15:14] :
                        (ctrl_fwd_cnt == 3'd1) ? frm_reg[13:12] :
                        (ctrl_fwd_cnt == 3'd2) ? frm_reg[11:10] :
                        (ctrl_fwd_cnt == 3'd3) ? frm_reg[9:8]   :
                        (ctrl_fwd_cnt == 3'd4) ? frm_reg[7:6]   :
                        (ctrl_fwd_cnt == 3'd5) ? frm_reg[5:4]   :
                        (ctrl_fwd_cnt == 3'd6) ? frm_reg[3:2]   : frm_reg[1:0];

endmodule
