`timescale 1ns / 1ps
module stopwatch_ext #(
    parameter BASE_1S    = 26'd49_999_999, 
    parameter BASE_0_1S  = 26'd4_999_999,  
    parameter DEBOUNCE_T = 20'd1_000_000   
)(
    input clk_50M, input reset_btn,
    input key4, input key5, input key6, input set_tens, input set_ones,
    output [7:0] dpy0, output [7:0] dpy1, output blink_led
    ,
    output [3:0] out_high, output [3:0] out_low
);

    // 例化 4 个消抖器芯片
    wire p_k5, p_k6, p_s_tens, p_s_ones;
    debounce #(.DEBOUNCE_T(DEBOUNCE_T)) db5(.clk(clk_50M), .rst(reset_btn), .btn_in(key5), .pulse_out(p_k5));
    debounce #(.DEBOUNCE_T(DEBOUNCE_T)) db6(.clk(clk_50M), .rst(reset_btn), .btn_in(key6), .pulse_out(p_k6));
    debounce #(.DEBOUNCE_T(DEBOUNCE_T)) dbt(.clk(clk_50M), .rst(reset_btn), .btn_in(set_tens), .pulse_out(p_s_tens));
    debounce #(.DEBOUNCE_T(DEBOUNCE_T)) dbo(.clk(clk_50M), .rst(reset_btn), .btn_in(set_ones), .pulse_out(p_s_ones));

    // 例化动态分频
    wire tick, pwm;
    dynamic_divider #(
        .B_1S(BASE_1S), .B_0_1S(BASE_0_1S)
    ) div_inst (
        .clk(clk_50M), .rst(reset_btn), 
        .key5_p(p_k5), .key6_p(p_k6), .freeze(~key4), // key4=0时冻结
        .tick(tick), .led_pwm(pwm),
        .is_0_1s(is_0_1s_mode) // 【新增】接收精度状态
    );

    // 加减计数器级联
    wire [3:0] q_high, q_low;
    wire co_low;
    
    wire stop = (q_high == 0) & (q_low == 0);
    wire is_set_mode = ~key4; // 0设置
    

    wire en_low = is_set_mode ? p_s_ones : (tick & ~stop);
    wire en_high = is_set_mode ? p_s_tens : co_low;
    
    wire load_high = is_set_mode & p_s_tens & (q_high == 4'd9);

    // 低位计数器
    counter_bcd #(.RST_VAL(4'd9)) u_cnt_low (
        .clk(clk_50M), .rst(reset_btn),
        .en(en_low), .dir(~is_set_mode), // 设置0，运行1
        .load(1'b0), .data(4'd0), 
        .q(q_low), .co(co_low)
    );

    // 高位计数器
    counter_bcd #(.RST_VAL(4'd1)) u_cnt_high (
        .clk(clk_50M), .rst(reset_btn),
        .en(en_high), .dir(~is_set_mode),
        .load(load_high), .data(4'd1), 
        .q(q_high), .co()
    );

    assign out_high = q_high;
    assign out_low = q_low;

    wire warning_1s = (~is_0_1s_mode) & (q_high == 4'd0) & (q_low <= 4'd3) & (q_low > 4'd0);
    wire warning_0_1s = (is_0_1s_mode) & (q_high <= 4'd3) & ({q_high, q_low} != 8'd0);

    wire low_time_warning = warning_1s | warning_0_1s;
    assign blink_led = low_time_warning ? pwm : 1'b0;
    

    SEG7_LUT seg_inst0(.iDIG(q_low), .oSEG1(dpy0));
    SEG7_LUT seg_inst1(.iDIG(q_high), .oSEG1(dpy1));

endmodule