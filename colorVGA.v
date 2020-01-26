//module for sync and display settings
module display(hsync, vsync, reset, clk, count, pix_x, pix_y, video, pixel);
input wire reset, clk;
output wire hsync, vsync, count, video, pixel;
output wire [9:0] pix_x, pix_y; //pixel locations

reg [9:0] vcount, hcount, hcount_new, vcount_new; //keep track of horizontal and vertical pixel count
reg vsync, hsync; // keep track of horizontal and vertical sync signals
wire vsync_new, hsync_new; 

always @(posedge clk)
begin
if(reset)
begin
	vcount<= 0;
	hcount<=0;
	vsync<=0;
	hsync<=0;
end


else
begin
	vcount<= vcount_new; //next values or incremented values to be assigned
	hcount<= hcount_new; 
	vsync<= vsync_new;
	hsync<= hsync_new;
end
end
// mod-4 counter to generate 25 MHz pixel tick
	reg [1:0] pix;
	wire [1:0] pix_new;
	wire tick;
	
	always @(posedge clk, posedge reset)
		if(reset)
		  pix <= 0;
		else
		  pix <= pix_new;
	
	assign pix_new = pix + 1; // increment pix 
	
	assign tick = (pix == 0); // assert tick 1/4 of the time Generates 25MHz clock


always @(*) //logic to calculate next horizontal and vertical pixel value
		begin
		hcount_new = tick ? 
		               hcount == 799 ? 0 : hcount + 1
			       : hcount;
		
		vcount_new = tick && hcount == 799 ? 
		               (vcount == 524 ? 0 : vcount + 1) 
			       : vcount;
		end

  assign hsync_new = hcount >= 688    //calculate new hsync value
                           && hcount <=755 ;
   
assign vsync_new = vcount >= 513 && vcount <=514 ;  //calculate new vsync value
assign video= (hcount<640 & vcount<480)?1:0;  //video register will be on when pixel count is within the display area

assign hsync= hsync;
assign vsync= vsync;
assign x= hcount;
assign y= vcount;
assign p_tick= tick;

endmodule

module color(clk, btnC, btnR, color, LED, Hsync, Vsync );
input wire clk, btnC, btnR;

output wire [11:0] color;
output wire Hsync, Vsync;
output wire [15:0]LED;

wire video;
reg [11:0] color_reg;
reg [15:0]led_out;
reg [28:0] count;
wire enable;

vga_display v1(.clk(clk), .reset(btnC), .hsync(Hsync), .vsync(Vsync), .video(video), .count(), .x(), .y(),.pixel()  );
//to implement 1 sec of delay while implementing LED using push button
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
//logic for LED display
always @(posedge clk)
begin
if(btnC)begin
	led_out<=16'd0;
	end
else if(enable==1)
begin
if (led_out>16'd7)
	led_out<=16'd0;
else if(btnR)
	led_out<= led_out+16'd1;
else
	led_out<=led_out;
end
end

assign LED = led_out;

always @(posedge clk)
if(btnC)
color_reg<=12'b000000000000;
else
begin
case(LED)
16'd0 : color_reg<= 12'b000000000000;
16'd1 : color_reg<= 12'b111111111111;
16'd2 : color_reg<= 12'b111100000000;
16'd3 : color_reg<= 12'b000011110000;
16'd4 : color_reg<= 12'b000000001111;
16'd5 : color_reg<= 12'b111111110000;
16'd6 : color_reg<= 12'b000011111111;
16'd7 : color_reg<= 12'b111100001111;
endcase
end
assign color= (video)? color_reg : 12'b0;
endmodule
