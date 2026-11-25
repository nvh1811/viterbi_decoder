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

    

endmodule
