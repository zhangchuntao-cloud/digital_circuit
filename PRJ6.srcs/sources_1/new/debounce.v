`timescale 1ns / 1ps
module debounce #(
    parameter DEBOUNCE_T = 20'd1_000_000 
)(
    input clk, input rst, input btn_in, output pulse_out
);
    reg sync_0, sync_1, stable, stable_d1;
    reg [19:0] cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_0 <= 0; sync_1 <= 0; stable <= 0; stable_d1 <= 0; cnt <= 0;
        end else begin
            sync_0 <= btn_in; 
            sync_1 <= sync_0;
            if (sync_1 != stable) begin
                cnt <= cnt + 1'b1;
                if (cnt == DEBOUNCE_T) begin
                    stable <= sync_1; cnt <= 0;
                end
            end else cnt <= 0;
            stable_d1 <= stable;
        end
    end
    assign pulse_out = stable & ~stable_d1; // 提取上升沿单脉冲
endmodule