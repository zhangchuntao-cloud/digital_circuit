
// 数码管连接关系示意图，dpy1同理
// p=dpy0[0]   // ---a---
// c=dpy0[1]   // |     |
// d=dpy0[2]  // f     b
// e=dpy0[3]  // |     |
// b=dpy0[4]  // ---g---
// a=dpy0[5]  // |     |
// f=dpy0[6]  // e     c
// g=dpy0[7]  // |     |
//                 // ---d---  p

//对应于dpy[7:0]，各段排列顺序为g f  a b e d c p


module SEG7_LUT (   oSEG1,iDIG   );
input   wire[3:0]   iDIG;
output  wire[7:0]   oSEG1;
reg     [6:0]   oSEG;

always @(iDIG)
begin
        case(iDIG)
        //不在乎最后一位，因为它是小数点
        4'h1: oSEG = 7'b1110110;    // ---t----
        4'h2: oSEG = 7'b0100001;    // |      |
        4'h3: oSEG = 7'b0100100;    // lt    rt
        4'h4: oSEG = 7'b0010110;    // |      |
        4'h5: oSEG = 7'b0001100;    // ---m----
        4'h6: oSEG = 7'b0001000;    // |      |
        4'h7: oSEG = 7'b1100110;    // lb    rb
        4'h8: oSEG = 7'b0000000;    // |      |
        4'h9: oSEG = 7'b0000110;    // ---b----
        4'ha: oSEG = 7'b0000010;
        4'hb: oSEG = 7'b0011000;
        4'hc: oSEG = 7'b1001001;
        4'hd: oSEG = 7'b0110000;
        4'he: oSEG = 7'b0001001;
        4'hf: oSEG = 7'b0001011;
        4'h0: oSEG = 7'b1000000;
        endcase
end

assign oSEG1 = {~oSEG,1'b0};

endmodule
