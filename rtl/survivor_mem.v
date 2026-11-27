module survivor_mem (
    input  wire       clk,           
    input  wire       rstn,         
    input  wire       survivor_we,    
    input  wire [2:0] fwd_step,       
    input  wire [3:0] decision_vec,   
    input  wire [2:0] tb_step,        
    output wire [3:0] survivor_word   
);
    reg [3:0] sur_mem [0:7];

    always @(posedge clk) begin
        if (rstn) begin
            if (survivor_we) begin
                sur_mem[fwd_step] <= decision_vec;
            end
        end
    end

    assign survivor_word = sur_mem[tb_step];

endmodule
