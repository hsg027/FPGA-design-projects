//interface of fpga-vga display- keyboard
// when a numeric key is pressed on keyboard, it displays that number on VGA screen. 

module keyboard_read(PS2Clk, PS2Data, data_out);
input wire PS2Clk,
input wire PS2Data,
output wire [15:0] data_out
reg [15:0] data_in_current;
reg [15:0] data_in_previous;
reg [15:0]current_state;
reg [15:0]next_state;


initial
begin
current_state = 0;
//data_out = 8'hf0;
end

always @ (negedge PS2Clk) //next state assignment
	begin
	current_state <= next_state;
	end

always @ (current_state) //next state calculation
	begin
	case (current_state)
	4'd0:
	begin
	if(PS2Data == 0)
	   next_state = 1;
	else
	   next_state = 0;
	end
	4'd1: next_state = 2;
	4'd2: next_state = 3;
	4'd3: next_state = 4;
	4'd4: next_state = 5;	
	4'd5: next_state = 6;
	4'd6: next_state = 7;
	4'd7: next_state = 8;
	4'd8: next_state = 9;
	4'd9: next_state = 10;
	4'd10:next_state = 0;
	endcase
	end

//Output assignment
always @ (current_state)
    begin
    case(current_state)
    4'd1: data_in_current[0] = PS2Data;
    4'd2: data_in_current[1] = PS2Data;
    4'd3: data_in_current[2] = PS2Data;
    4'd4: data_in_current[3] = PS2Data;
    4'd5: data_in_current[4] = PS2Data;
    4'd6: data_in_current[5] = PS2Data;
    4'd7: data_in_current[6] = PS2Data;
    4'd8: data_in_current[7] = PS2Data;
    4'd9: data_in_previous = data_in_current;
    endcase
    end 

 assign data_out = data_in_previous;

endmodule

//DISPLAY MODULE

module vga_display(
input wire clk,
input wire reset,
output wire hsync_local, 
output wire vsync_local, 
output wire display_active_area,
output wire [9:0] x_position,
output wire [9:0] y_position);

//variables for pixel clock
reg [1:0] pixel_clk_reg;
wire [1:0] pixel_clk_next;
wire pixel_clk_enable;

//variables to track horizontal and vertical pixel count
reg [9:0] v_count_current;
reg [9:0] h_count_current;
reg [9:0] h_count_next;
reg [9:0] v_count_next;

//variables for generating sync signals
reg vsync_cur;
reg hsync_cur;
wire vsync_next;
wire hsync_next;

// 2 bit counter to generate 25 MHz pixel clock
always @(posedge clk, posedge reset)
     begin
     if(reset)
        pixel_clk_reg <= 0;
     else
        pixel_clk_reg <= pixel_clk_next;
      end

assign pixel_clk_next = pixel_clk_reg + 1; 

// assert after every 4 counts
assign pixel_clk_enable = (pixel_clk_reg == 0); 

//Next state assignment of Horizontal, Vertical sync signals and Horizontal,
//Vertical counters	
always @(posedge clk)
   begin
   if(reset)
     begin
     v_count_current<= 0;
     h_count_current<=0;
     vsync_cur<=0;
     hsync_cur<=0;
     end
   else
      begin
      v_count_current<= v_count_next;
      h_count_current<= h_count_next;
      vsync_cur<= vsync_next;
      hsync_cur<= hsync_next;
      end
  end

//Next state calculation of Horizontal, Vertical sync signals and Horizontal, //Vertical counters
always @(*)
  begin 
  h_count_next = pixel_clk_enable ? 
  h_count_current == 799 ? 0 : h_count_current + 1 : h_count_current;
end

always @(*) begin
  v_count_next = pixel_clk_enable && h_count_current == 799 ? 
 (v_count_current == 524 ? 0 : v_count_current + 1) : v_count_current;
  end



assign hsync_next = h_count_current >= 688 && h_count_current <=755 ;

assign vsync_next = v_count_current > 488 && v_count_current <491 ;

assign display_active_area= (h_count_current<640 && v_count_current<480)?1:0;

assign hsync_local= hsync_cur;
assign vsync_local= vsync_cur;
assign x_position = h_count_current;
assign y_position = v_count_current;
endmodule

//MODULE MEMORY

-- IP VLNV: xilinx.com:ip:blk_mem_gen:8.4
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY blk_mem_gen_v8_4_1;
USE blk_mem_gen_v8_4_1.blk_mem_gen_v8_4_1;

ENTITY blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END blk_mem_gen_0;

ARCHITECTURE blk_mem_gen_0_arch OF blk_mem_gen_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF blk_mem_gen_0_arch: ARCHITECTURE IS "yes";
  COMPONENT blk_mem_gen_v8_4_1 IS
    GENERIC (
      C_FAMILY : STRING;
      C_XDEVICEFAMILY : STRING;
      C_ELABORATION_DIR : STRING;
      C_INTERFACE_TYPE : INTEGER;
      C_AXI_TYPE : INTEGER;
      C_AXI_SLAVE_TYPE : INTEGER;
      C_USE_BRAM_BLOCK : INTEGER;
      C_ENABLE_32BIT_ADDRESS : INTEGER;
      C_CTRL_ECC_ALGO : STRING;
      C_HAS_AXI_ID : INTEGER;
      C_AXI_ID_WIDTH : INTEGER;
      C_MEM_TYPE : INTEGER;
      C_BYTE_SIZE : INTEGER;
      C_ALGORITHM : INTEGER;
      C_PRIM_TYPE : INTEGER;
      C_LOAD_INIT_FILE : INTEGER;
      C_INIT_FILE_NAME : STRING;
      C_INIT_FILE : STRING;
      C_USE_DEFAULT_DATA : INTEGER;
      C_DEFAULT_DATA : STRING;
      C_HAS_RSTA : INTEGER;
      C_RST_PRIORITY_A : STRING;
      C_RSTRAM_A : INTEGER;
      C_INITA_VAL : STRING;
      C_HAS_ENA : INTEGER;
      C_HAS_REGCEA : INTEGER;
      C_USE_BYTE_WEA : INTEGER;
      C_WEA_WIDTH : INTEGER;
      C_WRITE_MODE_A : STRING;
      C_WRITE_WIDTH_A : INTEGER;
      C_READ_WIDTH_A : INTEGER;
      C_WRITE_DEPTH_A : INTEGER;
      C_READ_DEPTH_A : INTEGER;
      C_ADDRA_WIDTH : INTEGER;
      C_HAS_RSTB : INTEGER;
      C_RST_PRIORITY_B : STRING;
      C_RSTRAM_B : INTEGER;
      C_INITB_VAL : STRING;
      C_HAS_ENB : INTEGER;
      C_HAS_REGCEB : INTEGER;
      C_USE_BYTE_WEB : INTEGER;
      C_WEB_WIDTH : INTEGER;
      C_WRITE_MODE_B : STRING;
      C_WRITE_WIDTH_B : INTEGER;
      C_READ_WIDTH_B : INTEGER;
      C_WRITE_DEPTH_B : INTEGER;
      C_READ_DEPTH_B : INTEGER;
      C_ADDRB_WIDTH : INTEGER;
      C_HAS_MEM_OUTPUT_REGS_A : INTEGER;
      C_HAS_MEM_OUTPUT_REGS_B : INTEGER;
      C_HAS_MUX_OUTPUT_REGS_A : INTEGER;
      C_HAS_MUX_OUTPUT_REGS_B : INTEGER;
      C_MUX_PIPELINE_STAGES : INTEGER;
      C_HAS_SOFTECC_INPUT_REGS_A : INTEGER;
      C_HAS_SOFTECC_OUTPUT_REGS_B : INTEGER;
      C_USE_SOFTECC : INTEGER;
      C_USE_ECC : INTEGER;
      C_EN_ECC_PIPE : INTEGER;
      C_HAS_INJECTERR : INTEGER;
      C_SIM_COLLISION_CHECK : STRING;
      C_COMMON_CLK : INTEGER;
      C_DISABLE_WARN_BHV_COLL : INTEGER;
      C_EN_SLEEP_PIN : INTEGER;
      C_USE_URAM : INTEGER;
      C_EN_RDADDRA_CHG : INTEGER;
      C_EN_RDADDRB_CHG : INTEGER;
      C_EN_DEEPSLEEP_PIN : INTEGER;
      C_EN_SHUTDOWN_PIN : INTEGER;
      C_EN_SAFETY_CKT : INTEGER;
      C_DISABLE_WARN_BHV_RANGE : INTEGER;
      C_COUNT_36K_BRAM : STRING;
      C_COUNT_18K_BRAM : STRING;
      C_EST_POWER_SUMMARY : STRING
    );
    PORT (
      clka : IN STD_LOGIC;
      rsta : IN STD_LOGIC;
      ena : IN STD_LOGIC;
      regcea : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      clkb : IN STD_LOGIC;
      rstb : IN STD_LOGIC;
      enb : IN STD_LOGIC;
      regceb : IN STD_LOGIC;
      web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
      dinb : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      doutb : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      injectsbiterr : IN STD_LOGIC;
      injectdbiterr : IN STD_LOGIC;
      eccpipece : IN STD_LOGIC;
      sbiterr : OUT STD_LOGIC;
      dbiterr : OUT STD_LOGIC;
      rdaddrecc : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
      sleep : IN STD_LOGIC;
      deepsleep : IN STD_LOGIC;
      shutdown : IN STD_LOGIC;
      rsta_busy : OUT STD_LOGIC;
      rstb_busy : OUT STD_LOGIC;
      s_aclk : IN STD_LOGIC;
      s_aresetn : IN STD_LOGIC;
      s_axi_awid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_awvalid : IN STD_LOGIC;
      s_axi_awready : OUT STD_LOGIC;
      s_axi_wdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      s_axi_wstrb : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      s_axi_wlast : IN STD_LOGIC;
      s_axi_wvalid : IN STD_LOGIC;
      s_axi_wready : OUT STD_LOGIC;
      s_axi_bid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_bvalid : OUT STD_LOGIC;
      s_axi_bready : IN STD_LOGIC;
      s_axi_arid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_arvalid : IN STD_LOGIC;
      s_axi_arready : OUT STD_LOGIC;
      s_axi_rid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_rdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_rlast : OUT STD_LOGIC;
      s_axi_rvalid : OUT STD_LOGIC;
      s_axi_rready : IN STD_LOGIC;
      s_axi_injectsbiterr : IN STD_LOGIC;
      s_axi_injectdbiterr : IN STD_LOGIC;
      s_axi_sbiterr : OUT STD_LOGIC;
      s_axi_dbiterr : OUT STD_LOGIC;
      s_axi_rdaddrecc : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
    );
  END COMPONENT blk_mem_gen_v8_4_1;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF blk_mem_gen_0_arch: ARCHITECTURE IS "blk_mem_gen_v8_4_1,Vivado 2017.4";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF blk_mem_gen_0_arch : ARCHITECTURE IS "blk_mem_gen_0,blk_mem_gen_v8_4_1,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF blk_mem_gen_0_arch: ARCHITECTURE IS "blk_mem_gen_0,blk_mem_gen_v8_4_1,{x_ipProduct=Vivado 2017.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=blk_mem_gen,x_ipVersion=8.4,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_FAMILY=artix7,C_XDEVICEFAMILY=artix7,C_ELABORATION_DIR=./,C_INTERFACE_TYPE=0,C_AXI_TYPE=1,C_AXI_SLAVE_TYPE=0,C_USE_BRAM_BLOCK=0,C_ENABLE_32BIT_ADDRESS=0,C_CTRL_ECC_ALGO=NONE,C_HAS_AXI_ID=0,C_AXI_ID_WIDTH=4,C_MEM_TYPE=3,C_BYTE_SIZE=9,C_ALGORITHM=1,C_PRIM_TYPE=1,C_LOAD_INIT_FILE=1,C_INIT_FILE_NAME=blk_m" & 
"em_gen_0.mif,C_INIT_FILE=blk_mem_gen_0.mem,C_USE_DEFAULT_DATA=0,C_DEFAULT_DATA=0,C_HAS_RSTA=0,C_RST_PRIORITY_A=CE,C_RSTRAM_A=0,C_INITA_VAL=0,C_HAS_ENA=0,C_HAS_REGCEA=0,C_USE_BYTE_WEA=0,C_WEA_WIDTH=1,C_WRITE_MODE_A=WRITE_FIRST,C_WRITE_WIDTH_A=24,C_READ_WIDTH_A=24,C_WRITE_DEPTH_A=1538,C_READ_DEPTH_A=1538,C_ADDRA_WIDTH=11,C_HAS_RSTB=0,C_RST_PRIORITY_B=CE,C_RSTRAM_B=0,C_INITB_VAL=0,C_HAS_ENB=0,C_HAS_REGCEB=0,C_USE_BYTE_WEB=0,C_WEB_WIDTH=1,C_WRITE_MODE_B=WRITE_FIRST,C_WRITE_WIDTH_B=24,C_READ_WIDTH_B=" & 
"24,C_WRITE_DEPTH_B=1538,C_READ_DEPTH_B=1538,C_ADDRB_WIDTH=11,C_HAS_MEM_OUTPUT_REGS_A=0,C_HAS_MEM_OUTPUT_REGS_B=0,C_HAS_MUX_OUTPUT_REGS_A=0,C_HAS_MUX_OUTPUT_REGS_B=0,C_MUX_PIPELINE_STAGES=0,C_HAS_SOFTECC_INPUT_REGS_A=0,C_HAS_SOFTECC_OUTPUT_REGS_B=0,C_USE_SOFTECC=0,C_USE_ECC=0,C_EN_ECC_PIPE=0,C_HAS_INJECTERR=0,C_SIM_COLLISION_CHECK=ALL,C_COMMON_CLK=0,C_DISABLE_WARN_BHV_COLL=0,C_EN_SLEEP_PIN=0,C_USE_URAM=0,C_EN_RDADDRA_CHG=0,C_EN_RDADDRB_CHG=0,C_EN_DEEPSLEEP_PIN=0,C_EN_SHUTDOWN_PIN=0,C_EN_SAFETY_CK" & 
"T=0,C_DISABLE_WARN_BHV_RANGE=0,C_COUNT_36K_BRAM=1,C_COUNT_18K_BRAM=1,C_EST_POWER_SUMMARY=Estimated Power for IP     _     3.66155 mW}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF douta: SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT";
  ATTRIBUTE X_INTERFACE_INFO OF addra: SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR";
  ATTRIBUTE X_INTERFACE_PARAMETER OF clka: SIGNAL IS "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_WRITE_MODE READ_WRITE";
  ATTRIBUTE X_INTERFACE_INFO OF clka: SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK";
BEGIN
  U0 : blk_mem_gen_v8_4_1
    GENERIC MAP (
      C_FAMILY => "artix7",
      C_XDEVICEFAMILY => "artix7",
      C_ELABORATION_DIR => "./",
      C_INTERFACE_TYPE => 0,
      C_AXI_TYPE => 1,
      C_AXI_SLAVE_TYPE => 0,
      C_USE_BRAM_BLOCK => 0,
      C_ENABLE_32BIT_ADDRESS => 0,
      C_CTRL_ECC_ALGO => "NONE",
      C_HAS_AXI_ID => 0,
      C_AXI_ID_WIDTH => 4,
      C_MEM_TYPE => 3,
      C_BYTE_SIZE => 9,
      C_ALGORITHM => 1,
      C_PRIM_TYPE => 1,
      C_LOAD_INIT_FILE => 1,
      C_INIT_FILE_NAME => "blk_mem_gen_0.mif",
      C_INIT_FILE => "blk_mem_gen_0.mem",
      C_USE_DEFAULT_DATA => 0,
      C_DEFAULT_DATA => "0",
      C_HAS_RSTA => 0,
      C_RST_PRIORITY_A => "CE",
      C_RSTRAM_A => 0,
      C_INITA_VAL => "0",
      C_HAS_ENA => 0,
      C_HAS_REGCEA => 0,
      C_USE_BYTE_WEA => 0,
      C_WEA_WIDTH => 1,
      C_WRITE_MODE_A => "WRITE_FIRST",
      C_WRITE_WIDTH_A => 24,
      C_READ_WIDTH_A => 24,
      C_WRITE_DEPTH_A => 1538,
      C_READ_DEPTH_A => 1538,
      C_ADDRA_WIDTH => 11,
      C_HAS_RSTB => 0,
      C_RST_PRIORITY_B => "CE",
      C_RSTRAM_B => 0,
      C_INITB_VAL => "0",
      C_HAS_ENB => 0,
      C_HAS_REGCEB => 0,
      C_USE_BYTE_WEB => 0,
      C_WEB_WIDTH => 1,
      C_WRITE_MODE_B => "WRITE_FIRST",
      C_WRITE_WIDTH_B => 24,
      C_READ_WIDTH_B => 24,
      C_WRITE_DEPTH_B => 1538,
      C_READ_DEPTH_B => 1538,
      C_ADDRB_WIDTH => 11,
      C_HAS_MEM_OUTPUT_REGS_A => 0,
      C_HAS_MEM_OUTPUT_REGS_B => 0,
      C_HAS_MUX_OUTPUT_REGS_A => 0,
      C_HAS_MUX_OUTPUT_REGS_B => 0,
      C_MUX_PIPELINE_STAGES => 0,
      C_HAS_SOFTECC_INPUT_REGS_A => 0,
      C_HAS_SOFTECC_OUTPUT_REGS_B => 0,
      C_USE_SOFTECC => 0,
      C_USE_ECC => 0,
      C_EN_ECC_PIPE => 0,
      C_HAS_INJECTERR => 0,
      C_SIM_COLLISION_CHECK => "ALL",
      C_COMMON_CLK => 0,
      C_DISABLE_WARN_BHV_COLL => 0,
      C_EN_SLEEP_PIN => 0,
      C_USE_URAM => 0,
      C_EN_RDADDRA_CHG => 0,
      C_EN_RDADDRB_CHG => 0,
      C_EN_DEEPSLEEP_PIN => 0,
      C_EN_SHUTDOWN_PIN => 0,
      C_EN_SAFETY_CKT => 0,
      C_DISABLE_WARN_BHV_RANGE => 0,
      C_COUNT_36K_BRAM => "1",
      C_COUNT_18K_BRAM => "1",
      C_EST_POWER_SUMMARY => "Estimated Power for IP     :     3.66155 mW"
    )
    PORT MAP (
      clka => clka,
      rsta => '0',
      ena => '0',
      regcea => '0',
      wea => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      addra => addra,
      dina => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 24)),
      douta => douta,
      clkb => '0',
      rstb => '0',
      enb => '0',
      regceb => '0',
      web => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      addrb => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 11)),
      dinb => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 24)),
      injectsbiterr => '0',
      injectdbiterr => '0',
      eccpipece => '0',
      sleep => '0',
      deepsleep => '0',
      shutdown => '0',
      s_aclk => '0',
      s_aresetn => '0',
      s_axi_awid => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 4)),
      s_axi_awaddr => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s_axi_awlen => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)),
      s_axi_awsize => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 3)),
      s_axi_awburst => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 2)),
      s_axi_awvalid => '0',
      s_axi_wdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 24)),
      s_axi_wstrb => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      s_axi_wlast => '0',
      s_axi_wvalid => '0',
      s_axi_bready => '0',
      s_axi_arid => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 4)),
      s_axi_araddr => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s_axi_arlen => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)),
      s_axi_arsize => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 3)),
      s_axi_arburst => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 2)),
      s_axi_arvalid => '0',
      s_axi_rready => '0',
      s_axi_injectsbiterr => '0',
      s_axi_injectdbiterr => '0'
    );
END blk_mem_gen_0_arch;

//MAIN MODULE

module Lab4(clk, PS2Clk, PS2Data, btnC, Hsync, Vsync, vgaRed, vgaGreen, vgaBlue);
input clk, PS2Clk, PS2Data, btnC;
output Hsync, Vsync;
output wire [3:0] vgaRed, vgaGreen, vgaBlue
wire [15:0] key_pressed;
reg [15:0] number_display;
wire [9:0] x;
wire [9:0] y;
wire video_on;
reg [3:0] red_t, blue_t, green_t;
wire [10:0] addra;
wire [23:0] douta;
reg [3:0] number;

//Using the keyboard read module
keyboard_read keyboard_read_1(.PS2Clk(PS2Clk), .PS2Data(PS2Data), .data_out(key_pressed));

//Using the memory module
blk_mem_gen_0 memory(.clka(clk), .addra(addra), .douta(douta));

//Using the VGA display module
vga_display display_1(.clk(clk), .reset(btnC), .hsync_local(Hsync), .vsync_local(Vsync), .display_active_area(video_on), .x_position(x), .y_position(y));

// Key pressed calculation
always @(posedge clk)
    begin
    case(key_pressed)
	8'h45: number_display = 4'd0;
	8'h16: number_display = 4'd1;
	8'h1E: number_display = 4'd2;
	8'h26: number_display = 4'd3;
	8'h25: number_display = 4'd4;
	8'h2E: number_display = 4'd5;
	8'h36: number_display = 4'd6;
	8'h3D: number_display = 4'd7;
	8'h3E: number_display = 4'd8;
	8'h46: number_display = 4'd9;
	8'h5A: number_display = 8'h5A;
	default: number_display = 4'd10;
	endcase
	end
	
//Address calculation
assign addra = ((number_display*8*16) + (y-8)*8 + (x-8));

//Display memory value corresponding to outputs
always @ (posedge clk)
begin
if((x>7 && x<16) && (y>7 && y<24)) begin
red_t<=douta;
blue_t<=4'b0000;
green_t<=4'b0000;
end
else begin
red_t<=4'b0000;
blue_t<=4'b0000;
green_t<=4'b0000;
end
end  

assign vgaRed = video_on?red_t:4'b0000;
assign vgaGreen = video_on?blue_t:4'b0000;
assign vgaBlue = video_on?green_t:4'b0000;

endmodule
