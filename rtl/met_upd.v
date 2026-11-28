module bmc (
    input  wire [1:0] in_buf_rx,      
    output wire [1:0] acs_bm00,         
    output wire [1:0] acs_bm01,         
    output wire [1:0] acs_bm10,         
    output wire [1:0] acs_bm11          
);
    wire [1:0] e00 = in_buf_rx ^ 2'b00;
    wire [1:0] e01 = in_buf_rx ^ 2'b01;
    wire [1:0] e10 = in_buf_rx ^ 2'b10;
    wire [1:0] e11 = in_buf_rx ^ 2'b11;

    assign acs_bm00 = {1'b0, e00[1]} + {1'b0, e00[0]};
    assign acs_bm01 = {1'b0, e01[1]} + {1'b0, e01[0]};
    assign acs_bm10 = {1'b0, e10[1]} + {1'b0, e10[0]};
    assign acs_bm11 = {1'b0, e11[1]} + {1'b0, e11[0]};
endmodule

module acs (
    input  wire [4:0] met_upd_pm_a,         
    input  wire [4:0] met_upd_pm_b,         
    input  wire [1:0] bmc_bm_a,         
    input  wire [1:0] bmc_bm_b,         
    output wire [4:0] met_upd_nxt_pm,      
    output wire       met_upd_dec      
);
    wire [5:0] sum_a = {1'b0, met_upd_pm_a} + {4'b0000, bmc_bm_a};
    wire [5:0] sum_b = {1'b0, met_upd_pm_b} + {4'b0000, bmc_bm_b};

    wire [4:0] cand_a = (sum_a >= 6'd31) ? 5'd31 : sum_a[4:0];
    wire [4:0] cand_b = (sum_b >= 6'd31) ? 5'd31 : sum_b[4:0];

    assign met_upd_dec    = cand_a > cand_b;
    assign met_upd_nxt_pm = met_upd_dec ? cand_b : cand_a;

endmodule

module met_upd (
    input  wire        clk,          
    input  wire        rstn,        
    input  wire        ctrl_init_flag,   
    input  wire        ctrl_en,   
    input  wire [1:0]  in_buf_rx,      
    output wire [19:0] trb_pm,       
    output wire [3:0]  sur_mem_dec  
);
    wire [1:0] acs_bm00;
    wire [1:0] acs_bm01;
    wire [1:0] acs_bm10;
    wire [1:0] acs_bm11;

    wire [4:0] nxt_pm00;
    wire [4:0] nxt_pm01;
    wire [4:0] nxt_pm10;
    wire [4:0] nxt_pm11;

    reg [4:0] pm00;
    reg [4:0] pm01;
    reg [4:0] pm10;
    reg [4:0] pm11;

    bmc u_bmc(  .in_buf_rx(in_buf_rx), 
                .acs_bm00(acs_bm00), 
                .acs_bm01(acs_bm01), 
                .acs_bm10(acs_bm10), 
                .acs_bm11(acs_bm11)
            );
    
    acs acs_00( .met_upd_pm_a(pm00),
                .met_upd_pm_b(pm01),
                .bmc_bm_a(acs_bm00),
                .bmc_bm_b(acs_bm11),
                .met_upd_nxt_pm(nxt_pm00),
                .met_upd_dec(sur_mem_dec[0])
            );

    acs acs_01( .met_upd_pm_a(pm10),
                .met_upd_pm_b(pm11),
                .bmc_bm_a(acs_bm10),
                .bmc_bm_b(acs_bm01),
                .met_upd_nxt_pm(nxt_pm01),
                .met_upd_dec(sur_mem_dec[1])
            );

    acs acs_10( .met_upd_pm_a(pm00),
                .met_upd_pm_b(pm01),
                .bmc_bm_a(acs_bm11),
                .bmc_bm_b(acs_bm00),
                .met_upd_nxt_pm(nxt_pm10),
                .met_upd_dec(sur_mem_dec[2])
            );

    acs acs_11( .met_upd_pm_a(pm10),
                .met_upd_pm_b(pm11),
                .bmc_bm_a(acs_bm01),
                .bmc_bm_b(acs_bm10),
                .met_upd_nxt_pm(nxt_pm11),
                .met_upd_dec(sur_mem_dec[3])
            );

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            pm00 <= 5'd31;
            pm01 <= 5'd31;
            pm10 <= 5'd31;
            pm11 <= 5'd31;
        end else if(ctrl_init_flag) begin
            pm00 <= 5'd0;
            pm01 <= 5'd31;
            pm10 <= 5'd31;
            pm11 <= 5'd31;
        end else if(ctrl_en) begin
            pm00 <= nxt_pm00;
            pm01 <= nxt_pm01;
            pm10 <= nxt_pm10;
            pm11 <= nxt_pm11;
        end else begin
            pm00 <= pm00;
            pm01 <= pm01;
            pm10 <= pm10;
            pm11 <= pm11;
        end
    end

    assign trb_pm = {pm11, pm10, pm01, pm00};

endmodule
