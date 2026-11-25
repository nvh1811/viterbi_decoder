module bmc (
    input  wire [1:0] rx_pair,      
    output wire [1:0] bm00,         
    output wire [1:0] bm01,         
    output wire [1:0] bm10,         
    output wire [1:0] bm11          
);

endmodule

module acs (
    input  wire [4:0] pm_a,         
    input  wire [4:0] pm_b,         
    input  wire [1:0] bm_a,         
    input  wire [1:0] bm_b,         
    output wire [4:0] next_pm,      
    output wire       decision      
);

    
endmodule

module metric_update (
    input  wire        clk,          
    input  wire        rstn,        
    input  wire        frame_init,   
    input  wire        metric_en,   
    input  wire [1:0]  rx_pair,      
    output wire [19:0]  pm_bus,       
    output wire [3:0]  decision_vec  
);

    

endmodule
