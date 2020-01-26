module ledClock(clk, btnC, an, seg);
input clk;
input btnC;
output reg [3:0] an;
output reg [6:0] seg;
reg [28:0]count;
reg [15:0]number; 
reg [3:0]bcd;
reg[19:0]cnt; 
wire enable;
wire [1:0]ac_cn; 
always @(posedge clk)
begin
if(btnC)
    count<=0;
else begin
     if(count>=99999999) 
        count<=0;   
    else 
        count<=count+1;
end
end
assign enable=(count==99999999)?1:0;

always @(posedge clk)
begin
if(btnC)begin
    number<=0;
end 
else if(enable==1)
begin
if(number>=99)
number<=0;
else
    number=number+1;
    end
end 

always@(posedge clk)
begin
if(btnC)
cnt<=0;
else
cnt<=cnt+1;
end

assign ac_cn= cnt[19:18];

always @(*)
begin
case(ac_cn)
2'b00: 
begin
bcd=number/1000;
an=4'b0111;
end

2'b01:
begin
bcd=(number%1000)/100;
an=4'b1011;
end

2'b10:
begin
bcd=((number%1000)%100)/10;
an=4'b1101;
end

2'b11:
begin
bcd=((number%1000)%100)%10;
an=4'b1110;
end
endcase
end

always@(*)
begin
case(bcd)
 4'b0000: seg = 7'b1000000; // "0" 1000000
 4'b0001: seg = 7'b1111001; // "1" 1111001
 4'b0010: seg = 7'b0100100; // "2" 0100100
 4'b0011: seg = 7'b0110000; // "3" 0110000
 4'b0100: seg = 7'b0011001; // "4" 0011001
 4'b0101: seg = 7'b0010010; // "5" 0010010
 4'b0110: seg = 7'b0000010; // "6" 0000010
 4'b0111: seg = 7'b1111000; // "7" 1111000
 4'b1000: seg = 7'b0000000; // "8" 0000000
 4'b1001: seg = 7'b0010000; // "9" 0010000
 default: seg = 7'b1000000; // "0" 1000000
 endcase
 end
endmodule
