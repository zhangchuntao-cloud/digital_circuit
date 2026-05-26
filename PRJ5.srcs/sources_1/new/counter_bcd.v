`timescale 1ns / 1ps

// 4 位 BCD 同步加减计数器  74LS192

module counter_bcd #(
    parameter RST_VAL = 4'd0 // 复位时的默认初始值
)(
    input wire clk,
    input wire rst,        // 异步高有效复位
    input wire en,        
    input wire dir,        // 0为加法，1为减法
    input wire load,       // 同步置数使能
    input wire [3:0] data, 
    output reg [3:0] q,    // 当前计数值
    output wire co         
);


    assign co = en & ((dir == 1'b0 & q == 4'd9) | (dir == 1'b1 & q == 4'd0));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= RST_VAL;
        end else if (load) begin
            q <= data;    
        end else if (en) begin
            if (dir == 1'b0) begin
                q <= (q == 4'd9) ? 4'd0 : q + 1'b1; 
            end else begin
                q <= (q == 4'd0) ? 4'd9 : q - 1'b1; 
            end
        end
    end
endmodule