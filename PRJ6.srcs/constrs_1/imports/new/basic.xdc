# =========================================================
# 拓展任务秒表：物理引脚约束
# =========================================================

# 时钟与全局复位
set_property -dict {PACKAGE_PIN K21 IOSTANDARD LVCMOS33} [get_ports clk_50M] 
create_clock -period 20.000 -name clk_50M -waveform {0.000 10.000} [get_ports clk_50M]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports reset_btn] 

# 状态控制开关
set_property -dict {PACKAGE_PIN P4 IOSTANDARD LVCMOS33} [get_ports key4]

# 脉冲触发按键 
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports key5]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports key6]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports set_tens]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports set_ones]

# 倒计时闪烁预警灯 (映射至最右侧 leds[0])
set_property -dict {PACKAGE_PIN B24 IOSTANDARD LVCMOS33} [get_ports blink_led]

# 数码管 DPY0 (显示低位)
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS33} [get_ports {dpy0[0]}]
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {dpy0[1]}]
set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33} [get_ports {dpy0[2]}]
set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS33} [get_ports {dpy0[3]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {dpy0[4]}]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVCMOS33} [get_ports {dpy0[5]}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {dpy0[6]}]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports {dpy0[7]}]

# 数码管 DPY1 (显示高位)
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {dpy1[0]}]
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33} [get_ports {dpy1[1]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {dpy1[2]}]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports {dpy1[3]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {dpy1[4]}]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {dpy1[5]}]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {dpy1[6]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {dpy1[7]}]

# 全局配置
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]