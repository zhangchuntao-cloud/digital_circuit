`timescale 1ns / 1ps
module dynamic_divider #(
    parameter B_1S = 26'd49_999_999,
    parameter B_0_1S = 26'd4_999_999
)(
    input clk, input rst, input key5_p, input key6_p, input freeze,
    output tick, output led_pwm,
    output is_0_1s  
);
    reg [1:0] freq_st; reg prec_st;
    always @(posedge clk or posedge rst) begin
        if (rst) begin freq_st <= 0; prec_st <= 0; end
        else begin
            if (key5_p) freq_st <= (freq_st == 2) ? 0 : freq_st + 1;
            if (key6_p) prec_st <= ~prec_st;
        end
    end

    reg [25:0] target, cnt;
    reg [25:0] base;
    
    assign is_0_1s = prec_st; 

    always @(*) begin
        
        base = prec_st ? B_0_1S : B_1S;
        case(freq_st)
            2'd0: target = base;
            2'd1: target = base >> 1;
            2'd2: target = base >> 2;
            default: target = base;
        endcase
    end

    assign tick = (cnt >= target);
    assign led_pwm = (cnt > (target >> 1));

    always @(posedge clk or posedge rst) begin
        if (rst) cnt <= 0;
        else if (tick || freeze) cnt <= 0; // 冻结信号可重置时钟
        else cnt <= cnt + 1;
    end
endmodule