module bmc (
    input  wire [1:0] rx_pair,      
    output wire [1:0] bm00,         
    output wire [1:0] bm01,         
    output wire [1:0] bm10,         
    output wire [1:0] bm11          
);
    wire [1:0] e00 = rx_pair ^ 2'b00;
    wire [1:0] e01 = rx_pair ^ 2'b01;
    wire [1:0] e10 = rx_pair ^ 2'b10;
    wire [1:0] e11 = rx_pair ^ 2'b11;

    assign bm00 = {1'b0, e00[1]} + {1'b0, e00[0]};
    assign bm01 = {1'b0, e01[1]} + {1'b0, e01[0]};
    assign bm10 = {1'b0, e10[1]} + {1'b0, e10[0]};
    assign bm11 = {1'b0, e11[1]} + {1'b0, e11[0]};
endmodule

module acs (
    input  wire [4:0] pm_a,         
    input  wire [4:0] pm_b,         
    input  wire [1:0] bm_a,         
    input  wire [1:0] bm_b,         
    output wire [4:0] next_pm,      
    output wire       decision      
);
    wire [5:0] sum_a = {1'b0, pm_a} + {4'b0000, bm_a};
    wire [5:0] sum_b = {1'b0, pm_b} + {4'b0000, bm_b};

    wire [4:0] cand_a = (sum_a >= 6'd31) ? 5'd31 : sum_a[4:0];
    wire [4:0] cand_b = (sum_b >= 6'd31) ? 5'd31 : sum_b[4:0];

    assign decision = cand_a > cand_b;
    assign next_pm  = decision ? cand_b : cand_a;

endmodule

module metric_update (
    input  wire        clk,          
    input  wire        rstn,        
    input  wire        frame_init,   
    input  wire        metric_en,   
    input  wire [1:0]  rx_pair,      
    output wire [19:0] pm_bus,       
    output wire [3:0]  decision_vec  
);
    wire [1:0] bm00;
    wire [1:0] bm01;
    wire [1:0] bm10;
    wire [1:0] bm11;

    wire [4:0] next_pm00;
    wire [4:0] next_pm01;
    wire [4:0] next_pm10;
    wire [4:0] next_pm11;

    reg [4:0] pm00;
    reg [4:0] pm01;
    reg [4:0] pm10;
    reg [4:0] pm11;

    bmc bmc0(   .rx_pair(rx_pair), 
                .bm00(bm00), 
                .bm01(bm01), 
                .bm10(bm10), 
                .bm11(bm11)
            );
    
    acs acs00(  .pm_a(pm00),
                .pm_b(pm01),
                .bm_a(bm00),
                .bm_b(bm11),
                .next_pm(next_pm00),
                .decision(decision_vec[0])
            );

    acs acs01(  .pm_a(pm10),
                .pm_b(pm11),
                .bm_a(bm10),
                .bm_b(bm01),
                .next_pm(next_pm01),
                .decision(decision_vec[1])
            );

    acs acs10(  .pm_a(pm00),
                .pm_b(pm01),
                .bm_a(bm11),
                .bm_b(bm00),
                .next_pm(next_pm10),
                .decision(decision_vec[2])
            );

    acs acs11(  .pm_a(pm10),
                .pm_b(pm11),
                .bm_a(bm01),
                .bm_b(bm10),
                .next_pm(next_pm11),
                .decision(decision_vec[3])
            );

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            pm00 <= 5'd31;
            pm01 <= 5'd31;
            pm10 <= 5'd31;
            pm11 <= 5'd31;
        end else if(frame_init) begin
            pm00 <= 5'd0;
            pm01 <= 5'd31;
            pm10 <= 5'd31;
            pm11 <= 5'd31;
        end else if(metric_en) begin
            pm00 <= next_pm00;
            pm01 <= next_pm01;
            pm10 <= next_pm10;
            pm11 <= next_pm11;
        end else begin
            pm00 <= pm00;
            pm01 <= pm01;
            pm10 <= pm10;
            pm11 <= pm11;
        end
    end

    assign pm_bus = {pm11, pm10, pm01, pm00};

endmodule
