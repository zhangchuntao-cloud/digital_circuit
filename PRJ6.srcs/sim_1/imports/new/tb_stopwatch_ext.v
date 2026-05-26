`timescale 1ns / 1ps

module tb_stopwatch_ext();
    reg clk_50M;
    reg reset_btn;
    reg key4, key5, key6, set_tens, set_ones;
    wire [7:0] dpy0, dpy1;
    wire blink_led;
    wire [3:0] out_high, out_low; 

    stopwatch_ext #(
        .BASE_1S(26'd9),   // 1倍速：10个周期 (200ns)
        .BASE_0_1S(26'd1), 
        .DEBOUNCE_T(20'd1) 
    ) uut (
        .clk_50M(clk_50M), .reset_btn(reset_btn),
        .key4(key4), .key5(key5), .key6(key6),
        .set_tens(set_tens), .set_ones(set_ones),
        .dpy0(dpy0), .dpy1(dpy1), .blink_led(blink_led)
        ,
        .out_high(out_high), .out_low(out_low)
    );

    initial begin
        clk_50M = 0; forever #10 clk_50M = ~clk_50M;
    end

    initial begin

        reset_btn = 1; 
        key4 = 0; key5 = 0; key6 = 0; 
        set_tens = 0; set_ones = 0;
        #200; reset_btn = 0; #200;

        set_tens = 1; #200; set_tens = 0; #200;
        set_ones = 1; #200; set_ones = 0; #200;

        key4 = 1; #800; 

        key5 = 1; #200; key5 = 0; #200;
        #400; 

        key5 = 1; #200; key5 = 0; #200;
        #400; 

        key5 = 1; #200; key5 = 0; #200; 
        

        key4 = 0; #400; 
        
     
        set_tens = 1; #200; set_tens = 0; #200;
        set_tens = 1; #200; set_tens = 0; #200;  
        set_tens = 1; #200; set_tens = 0; #200; 
        set_ones = 1; #200; set_ones = 0; #200;
 
        

        key4 = 1; #400; 
        
        key6 = 1; #200; key6 = 0; #200;
        
       
        #800;

        $stop;
    end
endmodule