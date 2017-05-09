module streamif_ctrl #
  (
   parameter integer HWT_COUNT = 1,
   /* AXI lite */
   parameter integer C_S_AXI_DATA_WIDTH = 32,
   parameter integer C_S_AXI_ADDR_WIDTH = 5,
   parameter integer C_S_AXI_BASEADDR = 32'h00000000, // ise icin gerekli
   parameter integer C_S_AXI_HIGHADDR = 32'hffffffff // ise icin gerekli
   )
  (

   // BEGIN GENERATE LOOP
   input wire [31:0] 						 StreamIF_CTRL_0_Addr,
   input wire [31:0] 						 StreamIF_CTRL_1_Addr,
   input wire [31:0] 						 StreamIF_CTRL_2_Addr,
   input wire [31:0] 						 StreamIF_CTRL_3_Addr,
   input wire [31:0] 						 StreamIF_CTRL_4_Addr,
   input wire [31:0] 						 StreamIF_CTRL_5_Addr,
   input wire [31:0] 						 StreamIF_CTRL_6_Addr,
   input wire [31:0] 						 StreamIF_CTRL_7_Addr,
   input wire 								 StreamIF_CTRL_0_AddrValid,
   input wire 								 StreamIF_CTRL_1_AddrValid,
   input wire 								 StreamIF_CTRL_2_AddrValid,
   input wire 								 StreamIF_CTRL_3_AddrValid,
   input wire 								 StreamIF_CTRL_4_AddrValid,
   input wire 								 StreamIF_CTRL_5_AddrValid,
   input wire 								 StreamIF_CTRL_6_AddrValid,
   input wire 								 StreamIF_CTRL_7_AddrValid,
   input wire 								 StreamIF_CTRL_0_Start,
   input wire 								 StreamIF_CTRL_1_Start,
   input wire 								 StreamIF_CTRL_2_Start,
   input wire 								 StreamIF_CTRL_3_Start,
   input wire 								 StreamIF_CTRL_4_Start,
   input wire 								 StreamIF_CTRL_5_Start,
   input wire 								 StreamIF_CTRL_6_Start,
   input wire 								 StreamIF_CTRL_7_Start,
   output wire 								 StreamIF_CTRL_0_Idle,
   output wire 								 StreamIF_CTRL_1_Idle,
   output wire 								 StreamIF_CTRL_2_Idle,
   output wire 								 StreamIF_CTRL_3_Idle,
   output wire 								 StreamIF_CTRL_4_Idle,
   output wire 								 StreamIF_CTRL_5_Idle,
   output wire 								 StreamIF_CTRL_6_Idle,
   output wire 								 StreamIF_CTRL_7_Idle,
   // END GENERATE LOOP

   input wire 								 S_AXI_ACLK,
   input wire 								 S_AXI_ARESETN,
   input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	 S_AXI_AWADDR,
   input wire [2 : 0] 						 S_AXI_AWPROT,
   input wire 								 S_AXI_AWVALID,
   output wire 								 S_AXI_AWREADY,
   input wire [C_S_AXI_DATA_WIDTH-1 : 0] 	 S_AXI_WDATA,
   input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
   input wire 								 S_AXI_WVALID,
   output wire 								 S_AXI_WREADY,
   output wire [1 : 0] 						 S_AXI_BRESP,
   output wire 								 S_AXI_BVALID,
   input wire 								 S_AXI_BREADY,
   input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	 S_AXI_ARADDR,
   input wire [2 : 0] 						 S_AXI_ARPROT,
   input wire 								 S_AXI_ARVALID,
   output wire 								 S_AXI_ARREADY,
   output wire [C_S_AXI_DATA_WIDTH-1 : 0] 	 S_AXI_RDATA,
   output wire [1 : 0] 						 S_AXI_RRESP,
   output wire 								 S_AXI_RVALID,
   input wire 								 S_AXI_RREADY
   );

   wire [31:0] 						 StreamIF_CTRL_Addr,
   wire [15:0] 						 StreamIF_CTRL_AddrValid,
   wire [15:0] 						 StreamIF_CTRL_Start,
   wire [15:0] 						 StreamIF_CTRL_Idle,

  // BEGIN GENERATE LOOP
  assign StreamIF_CTRL_read_0_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_read_1_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_read_2_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_read_3_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_read_4_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_read_5_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_read_6_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_read_7_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_read_0_AddrValid = StreamIF_CTRL_AddrValid[0 * 2];
  assign StreamIF_CTRL_read_1_AddrValid = StreamIF_CTRL_AddrValid[1 * 2];
  assign StreamIF_CTRL_read_2_AddrValid = StreamIF_CTRL_AddrValid[2 * 2];
  assign StreamIF_CTRL_read_3_AddrValid = StreamIF_CTRL_AddrValid[3 * 2];
  assign StreamIF_CTRL_read_4_AddrValid = StreamIF_CTRL_AddrValid[4 * 2];
  assign StreamIF_CTRL_read_5_AddrValid = StreamIF_CTRL_AddrValid[5 * 2];
  assign StreamIF_CTRL_read_6_AddrValid = StreamIF_CTRL_AddrValid[6 * 2];
  assign StreamIF_CTRL_read_7_AddrValid = StreamIF_CTRL_AddrValid[7 * 2];
  assign StreamIF_CTRL_read_0_Start = StreamIF_CTRL_Start[0 * 2];
  assign StreamIF_CTRL_read_1_Start = StreamIF_CTRL_Start[1 * 2];
  assign StreamIF_CTRL_read_2_Start = StreamIF_CTRL_Start[2 * 2];
  assign StreamIF_CTRL_read_3_Start = StreamIF_CTRL_Start[3 * 2];
  assign StreamIF_CTRL_read_4_Start = StreamIF_CTRL_Start[4 * 2];
  assign StreamIF_CTRL_read_5_Start = StreamIF_CTRL_Start[5 * 2];
  assign StreamIF_CTRL_read_6_Start = StreamIF_CTRL_Start[6 * 2];
  assign StreamIF_CTRL_read_7_Start = StreamIF_CTRL_Start[7 * 2];
  assign StreamIF_CTRL_Idle[0 * 2] = StreamIF_CTRL_read_0_Idle;
  assign StreamIF_CTRL_Idle[1 * 2] = StreamIF_CTRL_read_1_Idle;
  assign StreamIF_CTRL_Idle[2 * 2] = StreamIF_CTRL_read_2_Idle;
  assign StreamIF_CTRL_Idle[3 * 2] = StreamIF_CTRL_read_3_Idle;
  assign StreamIF_CTRL_Idle[4 * 2] = StreamIF_CTRL_read_4_Idle;
  assign StreamIF_CTRL_Idle[5 * 2] = StreamIF_CTRL_read_5_Idle;
  assign StreamIF_CTRL_Idle[6 * 2] = StreamIF_CTRL_read_6_Idle;
  assign StreamIF_CTRL_Idle[7 * 2] = StreamIF_CTRL_read_7_Idle;








  assign StreamIF_CTRL_write_0_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_write_1_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_write_2_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_write_3_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_write_4_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_write_5_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_write_6_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_write_7_Addr = StreamIF_CTRL_Addr;
  assign StreamIF_CTRL_write_0_AddrValid = StreamIF_CTRL_AddrValid[0 * 2 + 1];
  assign StreamIF_CTRL_write_1_AddrValid = StreamIF_CTRL_AddrValid[1 * 2 + 1];
  assign StreamIF_CTRL_write_2_AddrValid = StreamIF_CTRL_AddrValid[2 * 2 + 1];
  assign StreamIF_CTRL_write_3_AddrValid = StreamIF_CTRL_AddrValid[3 * 2 + 1];
  assign StreamIF_CTRL_write_4_AddrValid = StreamIF_CTRL_AddrValid[4 * 2 + 1];
  assign StreamIF_CTRL_write_5_AddrValid = StreamIF_CTRL_AddrValid[5 * 2 + 1];
  assign StreamIF_CTRL_write_6_AddrValid = StreamIF_CTRL_AddrValid[6 * 2 + 1];
  assign StreamIF_CTRL_write_7_AddrValid = StreamIF_CTRL_AddrValid[7 * 2 + 1];
  assign StreamIF_CTRL_write_0_Start = StreamIF_CTRL_Start[0 * 2 + 1];
  assign StreamIF_CTRL_write_1_Start = StreamIF_CTRL_Start[1 * 2 + 1];
  assign StreamIF_CTRL_write_2_Start = StreamIF_CTRL_Start[2 * 2 + 1];
  assign StreamIF_CTRL_write_3_Start = StreamIF_CTRL_Start[3 * 2 + 1];
  assign StreamIF_CTRL_write_4_Start = StreamIF_CTRL_Start[4 * 2 + 1];
  assign StreamIF_CTRL_write_5_Start = StreamIF_CTRL_Start[5 * 2 + 1];
  assign StreamIF_CTRL_write_6_Start = StreamIF_CTRL_Start[6 * 2 + 1];
  assign StreamIF_CTRL_write_7_Start = StreamIF_CTRL_Start[7 * 2 + 1];
  assign StreamIF_CTRL_Idle[0 * 2 + 1] = StreamIF_CTRL_write_0_Idle;
  assign StreamIF_CTRL_Idle[1 * 2 + 1] = StreamIF_CTRL_write_1_Idle;
  assign StreamIF_CTRL_Idle[2 * 2 + 1] = StreamIF_CTRL_write_2_Idle;
  assign StreamIF_CTRL_Idle[3 * 2 + 1] = StreamIF_CTRL_write_3_Idle;
  assign StreamIF_CTRL_Idle[4 * 2 + 1] = StreamIF_CTRL_write_4_Idle;
  assign StreamIF_CTRL_Idle[5 * 2 + 1] = StreamIF_CTRL_write_5_Idle;
  assign StreamIF_CTRL_Idle[6 * 2 + 1] = StreamIF_CTRL_write_6_Idle;
  assign StreamIF_CTRL_Idle[7 * 2 + 1] = StreamIF_CTRL_write_7_Idle;
  // END GENERATE LOOP

  genvar 							 i;
  generate
	for (i = (HWT_COUNT*2); i < 16 ; i = i + 1) begin: gen
	  assign StreamIF_CTRL_Idle[i] = 0;
	end
  endgenerate



  // ---------------------------------------------



  /* AXI Lite Slave signals */
  wire [32-1:0] 							reg0_address_and_devno;
  wire [32-1:0] 							reg1_control;
  wire [32-1:0] 							reg1_control_in;

  /* addres signal (4096 byte aligned) */
  assign StreamIF_CTRL_Addr = {reg0_address_and_devno[31:12], 12'b0};

  /* idle signal */
  assign reg1_control_in = {16'b0, StreamIF_CTRL_Idle};

  /* start signal */
  assign StreamIF_CTRL_Start = reg1_control[15:0];


  /* AddrValid signal */
  wire [7:0] 								devSelect;
  assign devSelect = reg0_address_and_devno[7:0];

  wire [0:0] 								devRange;
  assign devRange = reg0_address_and_devno[8:8];

  always @(*) begin
  	case (devRange)
  	  0: StreamIF_CTRL_AddrValid = {8'b0, devSelect[7:0]};
  	  1: StreamIF_CTRL_AddrValid = {devSelect[7:0], 8'b0};
  	endcase
  end

/*
 32 device
  wire [1:0] 								devRange;
  assign devRange = reg0_address_and_devno[10:8];
  always @(*) begin
  	case (devRange)
  	  0: StreamIF_CTRL_AddrValid = {24'b0, devSelect};
  	  1: StreamIF_CTRL_AddrValid = {16'b0, devSelect, 8'b0};
  	  2: StreamIF_CTRL_AddrValid = {8'b0, devSelect, 16'b0};
  	  3: StreamIF_CTRL_AddrValid = {devSelect, 24'b0};
  	endcase
  end
*/


  axi4_lite_slave axi4_lite_slave_i
	(
	 .S_AXI_ACLK(ACLK),
	 .S_AXI_ARESETN(ARESETN),
	 .S_AXI_AWADDR(S_AXI_AWADDR),
	 .S_AXI_AWPROT(S_AXI_AWPROT),
	 .S_AXI_AWVALID(S_AXI_AWVALID),
	 .S_AXI_AWREADY(S_AXI_AWREADY),
	 .S_AXI_WDATA(S_AXI_WDATA),
	 .S_AXI_WSTRB(S_AXI_WSTRB),
	 .S_AXI_WVALID(S_AXI_WVALID),
	 .S_AXI_WREADY(S_AXI_WREADY),
	 .S_AXI_BRESP(S_AXI_BRESP),
	 .S_AXI_BVALID(S_AXI_BVALID),
	 .S_AXI_BREADY(S_AXI_BREADY),
	 .S_AXI_ARADDR(S_AXI_ARADDR),
	 .S_AXI_ARPROT(S_AXI_ARPROT),
	 .S_AXI_ARVALID(S_AXI_ARVALID),
	 .S_AXI_ARREADY(S_AXI_ARREADY),
	 .S_AXI_RDATA(S_AXI_RDATA),
	 .S_AXI_RRESP(S_AXI_RRESP),
	 .S_AXI_RVALID(S_AXI_RVALID),
	 .S_AXI_RREADY(S_AXI_RREADY),
	 /* */
	 .reg0_in(reg0_address_and_devno),
	 .reg0_out(reg0_address_and_devno),
	 .reg1_in(reg1_control_in),
	 .reg1_out(reg1_control),
	 .reg2_in(0),
	 .reg2_out(),
	 .reg3_in(0),
	 .reg3_out()
	 );

endmodule
