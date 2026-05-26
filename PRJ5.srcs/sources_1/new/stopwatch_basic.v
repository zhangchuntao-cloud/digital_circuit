`timescale 1ns / 1ps

module stopwatch_basic #(
    parameter TIME_1HZ = 26'd49_999_999
)(
    input clk_50M,
    input reset_btn,
    input key0,       // 正计时运行
    input key1,       // 倒计时运行
    input key2,       // 0:正向, 1:倒向
    output [7:0] dpy0,
    output [7:0] dpy1
    ,
    output [3:0] out_tens,
    output [3:0] out_ones 
);


    // 分频器网络 

    reg [25:0] cnt_div;
    wire tick_1hz = (cnt_div >= TIME_1HZ);

    always @(posedge clk_50M or posedge reset_btn) begin
        if (reset_btn) cnt_div <= 26'd0;
        else if (tick_1hz) cnt_div <= 26'd0;
        else cnt_div <= cnt_div + 1'b1;
    end

    // 模式切换边沿检测

    reg key2_d1;
    always @(posedge clk_50M or posedge reset_btn) begin
        if (reset_btn) key2_d1 <= 1'b0;
        else key2_d1 <= key2;
    end
    wire mode_switch_pulse = (key2 ^ key2_d1); 

  
    wire [3:0] q_ones, q_tens;
    wire co_ones; 
    
    wire stop_flag = (key2 == 1'b1) & (q_tens == 4'd0) & (q_ones == 4'd0);

    // 运行使能
    wire run_en = (key2 == 1'b0) ? key0 : (key1 & ~stop_flag);
    
    // 级联使能
    wire en_ones = tick_1hz & run_en;
    wire en_tens = co_ones; 

    wire load_pulse = mode_switch_pulse;
    
    wire [3:0] load_val_tens = (key2 == 1'b1) ? 4'd1 : 4'd0;
    wire [3:0] load_val_ones = (key2 == 1'b1) ? 4'd9 : 4'd0;


    // 例化个位计数器
    counter_bcd #(.RST_VAL(4'd0)) u_cnt_ones (
        .clk(clk_50M), .rst(reset_btn), 
        .en(en_ones), .dir(key2),
        .load(load_pulse), .data(load_val_ones), 
        .q(q_ones), .co(co_ones)
    );

    // 例化十位计数器
    counter_bcd #(.RST_VAL(4'd0)) u_cnt_tens (
        .clk(clk_50M), .rst(reset_btn), 
        .en(en_tens), .dir(key2),
        .load(load_pulse), .data(load_val_tens), 
        .q(q_tens), .co() 
    );

  
    assign out_ones = q_ones;
    assign out_tens = q_tens;
    
    SEG7_LUT seg_inst0(.iDIG(q_ones), .oSEG1(dpy0));
    SEG7_LUT seg_inst1(.iDIG(q_tens), .oSEG1(dpy1));

endmodule