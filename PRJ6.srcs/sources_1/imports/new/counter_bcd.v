`timescale 1ns / 1ps
// =========================================================
// 模块功能：标准 4 位 BCD 同步加减计数器 (类似 74LS192)
// =========================================================
module counter_bcd #(
    parameter RST_VAL = 4'd0 // 复位时的默认初始值
)(
    input wire clk,
    input wire rst,        // 异步高有效复位
    input wire en,         // 使能端 (高电平有效)
    input wire dir,        // 计数方向：0为加法，1为减法
    input wire load,       // 同步置数使能 (高电平有效)
    input wire [3:0] data, // 同步预置数数据
    output reg [3:0] q,    // 当前计数值
    output wire co         // 进位/借位脉冲输出 (组合逻辑)
);

    // 产生进位/借位脉冲，用于级联下一级计数器
    assign co = en & ((dir == 1'b0 & q == 4'd9) | (dir == 1'b1 & q == 4'd0));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= RST_VAL;
        end else if (load) begin
            q <= data;     // 同步预置数最高优先级
        end else if (en) begin
            if (dir == 1'b0) begin
                q <= (q == 4'd9) ? 4'd0 : q + 1'b1; // 加法逢9归0
            end else begin
                q <= (q == 4'd0) ? 4'd9 : q - 1'b1; // 减法借0退9
            end
        end
    end
endmodule