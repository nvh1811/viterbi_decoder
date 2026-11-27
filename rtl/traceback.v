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
    wire [4:0] pm00 = pm_bus[4:0];
    wire [4:0] pm01 = pm_bus[9:5];
    wire [4:0] pm10 = pm_bus[14:10];
    wire [4:0] pm11 = pm_bus[19:15];

    wire [1:0] min_state;

    wire decision;
    wire [1:0] prev_state;

    reg [1:0] tb_state;
    reg [7:0] decoded_work;

    assign min_state =  (pm00 <= pm01 && pm00 <= pm10 && pm00 <= pm11) ? 2'b00 :
                        (pm01 <= pm10 && pm01 <= pm11)                 ? 2'b01 :
                        (pm10 <= pm11)                                 ? 2'b10 : 2'b11;

    assign decision =   (tb_state == 2'b00) ? survivor_word[0] :
                        (tb_state == 2'b01) ? survivor_word[1] :
                        (tb_state == 2'b10) ? survivor_word[2] : survivor_word[3];

    assign prev_state = {tb_state[0], decision};

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            tb_state     <= 2'b00;
            decoded_work <= 8'd0;
            output_data  <= 8'd0;
        end else if(select_en) begin
            tb_state     <= min_state;
            decoded_work <= 8'd0;
            output_data  <= output_data;
        end else if(tb_en) begin
            tb_state     <= prev_state;
            decoded_work[3'd7 - tb_step] <= tb_state[1];
            output_data  <= output_data;
        end else if(out_en) begin
            tb_state     <= tb_state;
            decoded_work <= decoded_work;
            output_data  <= decoded_work;
        end else begin
            tb_state     <= tb_state;
            decoded_work <= decoded_work;
            output_data  <= output_data;
        end
    end

endmodule
