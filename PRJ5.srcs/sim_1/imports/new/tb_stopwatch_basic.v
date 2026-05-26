`timescale 1ns / 1ps

module tb_stopwatch_basic();
    reg clk_50M;
    reg reset_btn;
    reg key0, key1, key2;
    wire [7:0] dpy0, dpy1;
    wire [3:0] out_tens, out_ones; 

    stopwatch_basic #(
        .TIME_1HZ(26'd4)  // 5个周期(100ns)为一秒
    ) uut (
        .clk_50M(clk_50M), .reset_btn(reset_btn),
        .key0(key0), .key1(key1), .key2(key2),
        .dpy0(dpy0), .dpy1(dpy1),
        .out_tens(out_tens), .out_ones(out_ones)
    );

    initial begin
        clk_50M = 0; forever #10 clk_50M = ~clk_50M;
    end

    initial begin
        reset_btn = 1; key0 = 0; key1 = 0; key2 = 0;
        #200; // 宽裕的复位时间
        
        reset_btn = 0;
        #200;
        
        // 开启正计时
        key0 = 1;
        #1000;
        reset_btn = 1;
        #100
        reset_btn = 0; 
        #400
        
        key0 = 0;
        #200; 
        key2 = 1;
        #200;  
        
        // 开启倒计时
        key1 = 1;
        #2400; 

        $stop;
    end
endmodule