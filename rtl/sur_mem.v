module sur_mem (
    input  wire       clk,           
    input  wire       rstn,         
    input  wire       ctrl_we,    
    input  wire [2:0] ctrl_fwd_cnt,       
    input  wire [3:0] met_upd_dec,   
    input  wire [2:0] ctrl_tb_cnt,        
    output wire [3:0] trb_word   
);
    reg [3:0] sur_arr [0:7];

    always @(posedge clk) begin
        if (rstn) begin
            if (ctrl_we) begin
                sur_arr[ctrl_fwd_cnt] <= met_upd_dec;
            end
        end
    end

    assign trb_word = sur_arr[ctrl_tb_cnt];

endmodule
