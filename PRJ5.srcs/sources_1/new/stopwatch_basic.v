// 时间尺度：仿真单位1ns，精度1ps
`timescale 1ns / 1ps

// 秒表顶层模块：支持正计时/倒计时、启停、模式切换
module stopwatch_basic #(
    // 分频参数：50MHz -> 1Hz，计数到49,999,999产生1秒脉冲
    parameter TIME_1HZ = 26'd49_999_999
)(
    input clk_50M,         // 系统时钟：50MHz
    input reset_btn,       // 复位按键：高电平复位
    input key0,            // 正计时启动键
    input key1,            // 倒计时启动键
    input key2,            // 模式选择：0=正计时，1=倒计时
    output [7:0] dpy0,     // 个位数码管段码输出
    output [7:0] dpy1,     // 十位数码管段码输出
    output [3:0] out_tens, // 十位计数值（BCD）
    output [3:0] out_ones  // 个位计数值（BCD）
);

//==================== 1Hz 时钟分频逻辑 ====================
reg [25:0] cnt_div;      // 26位分频计数器，最大计数值49,999,999
wire tick_1hz = (cnt_div >= TIME_1HZ); // 1Hz脉冲：计数到阈值时为高

// 分频计数器时序：50MHz循环计数，到阈值清零并产生1Hz脉冲
always @(posedge clk_50M or posedge reset_btn) begin
    if (reset_btn)        // 复位：计数器清零
        cnt_div <= 26'd0;
    else if (tick_1hz)   // 计满1秒：计数器清零
        cnt_div <= 26'd0;
    else                   // 正常计数：自增1
        cnt_div <= cnt_div + 1'b1;
end

//==================== 模式切换边沿检测 ====================
reg key2_d1;              // key2延迟1拍寄存器（同步+边沿检测用）

// 同步key2信号，避免亚稳态
always @(posedge clk_50M or posedge reset_btn) begin
    if (reset_btn)
        key2_d1 <= 1'b0;
    else
        key2_d1 <= key2; // 每个时钟沿锁存key2
end

// 模式切换脉冲：key2变化瞬间产生1个时钟周期高电平（上升/下降沿都检测）
wire mode_switch_pulse = (key2 ^ key2_d1);

//==================== 计数器与控制信号定义 ====================
wire [3:0] q_ones, q_tens; // 个位、十位计数器输出（BCD）
wire co_ones;                // 个位计数器进位/借位输出

// 倒计时停止标志：倒计时模式下，计数值=00时置1
wire stop_flag = (key2 == 1'b1) & (q_tens == 4'd0) & (q_ones == 4'd0);

// 运行使能：正计时=key0控制；倒计时=key1且未到0
wire run_en = (key2 == 1'b0) ? key0 : (key1 & ~stop_flag);

// 计数器使能：个位=1Hz脉冲+运行使能；十位=个位进位/借位
wire en_ones = tick_1hz & run_en;
wire en_tens = co_ones;

// 置数脉冲：模式切换瞬间同步加载初值
wire load_pulse = mode_switch_pulse;

// 模式对应初值：正计时=00；倒计时=19
wire [3:0] load_val_tens = (key2 == 1'b1) ? 4'd1 : 4'd0;
wire [3:0] load_val_ones = (key2 == 1'b1) ? 4'd9 : 4'd0;

//==================== 个位BCD计数器实例（0-9） ====================
counter_bcd #(.RST_VAL(4'd0)) u_cnt_ones (
    .clk(clk_50M),         // 系统时钟
    .rst(reset_btn),       // 复位
    .en(en_ones),           // 个位使能：1Hz+运行
    .dir(key2),             // 计数方向：0=加，1=减
    .load(load_pulse),     // 模式切换置数
    .data(load_val_ones),  // 个位初值：0或9
    .q(q_ones),             // 个位输出
    .co(co_ones)            // 个位进位/借位（给十位）
);

//==================== 十位BCD计数器实例（0-1） ====================
counter_bcd #(.RST_VAL(4'd0)) u_cnt_tens (
    .clk(clk_50M),         // 系统时钟
    .rst(reset_btn),       // 复位
    .en(en_tens),           // 十位使能：个位进位/借位
    .dir(key2),             // 计数方向：0=加，1=减
    .load(load_pulse),     // 模式切换置数
    .data(load_val_tens),  // 十位初值：0或1
    .q(q_tens),             // 十位输出
    .co()                    // 十位进位/借位（悬空，不用）
);

//==================== 输出与数码管译码 ====================
assign out_ones = q_ones;  // 个位值输出
assign out_tens = q_tens;  // 十位值输出

// 七段数码管译码：BCD转段码
SEG7_LUT seg_inst0(.iDIG(q_ones), .oSEG1(dpy0)); // 个位译码
SEG7_LUT seg_inst1(.iDIG(q_tens), .oSEG1(dpy1)); // 十位译码

endmodule




/*




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



*/
