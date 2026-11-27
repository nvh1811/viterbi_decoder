module input_buffer (
    input  wire        clk,        
    input  wire        rstn,       
    input  wire        frame_load,  
    input  wire [15:0] input_data,    
    input  wire [2:0]  fwd_step,    
    output wire [1:0]  rx_pair  
);   
    reg [15:0] frame_reg;

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            frame_reg <= 16'b0;
        end else if(frame_load) begin
            frame_reg <= input_data;
        end else begin
            frame_reg <= frame_reg;
        end
    end

    assign rx_pair = (fwd_step == 3'd0) ? frame_reg[15:14] :
                     (fwd_step == 3'd1) ? frame_reg[13:12] :
                     (fwd_step == 3'd2) ? frame_reg[11:10] :
                     (fwd_step == 3'd3) ? frame_reg[9:8]   :
                     (fwd_step == 3'd4) ? frame_reg[7:6]   :
                     (fwd_step == 3'd5) ? frame_reg[5:4]   :
                     (fwd_step == 3'd6) ? frame_reg[3:2]   : frame_reg[1:0];

endmodule
