//interface of fpga with keyboard
// if a numeric key is pressed on keyboard, the number is displayed on FPGA LEDs

module keyboard(PS2Clock, PS2Data, led);
input wire PS2Clock; //keyboard clock of 25 MHZ
input wire PS2Data; //8 bit data from keyboard
output [15:0]led; //16-bit LED display
reg [15:0] led_out; //register to store led value
reg [3:0] state, state_next; // to keep track of present and next states

reg [7:0]data_current;
reg [7:0]data_previous;

//initial state definition
initial 
begin
state<=4'b0;
end

always @(PS2Data or state)
begin
case(state)
4'd0: begin
if(PS2Data==0) //check for ps2d signal
state_next<=4'd1; // increase the state, if signal is low 
else
state_next<=4'd0; //stays in same state if signal is not low
end
4'd1: state_next<=4'd2; //once state has reached from 0 to 1, then it is no longer dependent on input
4'd2: state_next<=4'd3; // it will increase irrespective of the input
4'd3: state_next<=4'd4;
4'd4: state_next<=4'd5;
4'd5: state_next<=4'd6;
4'd6: state_next<=4'd7;
4'd7: state_next<=4'd8;
4'd8: state_next<=4'd9;
4'd9: state_next<=4'd10;
4'd10: state_next<=4'd0; //go back to initial stage when final stage has been reached
endcase
end

//logic to determine the value of next state
always @(posedge PS2Clock)
state<=state_next;

//to handle 8-bits of data
always @ (state)
    begin
    case(state)
    	4'd1: data_current[0] = PS2Data;
    	4'd2: data_current[1] = PS2Data;
    	4'd3: data_current[2] = PS2Data;
    	4'd4: data_current[3] = PS2Data;
    	4'd5: data_current[4] = PS2Data;
    	4'd6: data_current[5] = PS2Data;
    	4'd7: data_current[6] = PS2Data;
    	4'd8: data_current[7] = PS2Data;
    	4'd9: data_previous = data_current;
    endcase
    end 

//to display LED output based on the hexadecimal signal coming from keyboard
always@(posedge PS2Clock)
begin
case(data_previous)
8'h0E: led_out= 16'd0; 
8'h16: led_out= 16'd1; 
8'h1E: led_out= 16'd2; 
8'h26: led_out= 16'd3; 
8'h25: led_out= 16'd4;
8'h2E: led_out= 16'd5;
8'h36: led_out= 16'd6;
8'h3D: led_out= 16'd7;
8'h3E: led_out= 16'd8;
8'h46: led_out= 16'd9;
default: led_out=16'b1111111111111111; //when any other button is pressed, all LEDs will be lit
endcase
end

assign led=led_out;
endmodule
