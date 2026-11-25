module traceback (
    input  wire        clk,            
    input  wire        rstn,          
    input  wire [19:0] pm_bus,         
    input  wire [3:0]  survivor_word,  
    input  wire [2:0]  tb_step,       
    input  wire        select_en,      
    input  wire        tb_en,          
    input  wire        out_en,        
    output reg  [7:0]  output_data        
);
    
endmodule
