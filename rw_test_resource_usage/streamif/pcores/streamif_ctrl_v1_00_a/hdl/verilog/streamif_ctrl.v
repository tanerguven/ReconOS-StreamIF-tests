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
   output wire [31:0] 						 STREAMIF_CTRL_mm2s_0_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_mm2s_1_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_mm2s_2_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_mm2s_3_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_mm2s_4_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_mm2s_5_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_mm2s_6_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_mm2s_7_Addr,
   output wire 								 STREAMIF_CTRL_mm2s_0_AddrValid,
   output wire 								 STREAMIF_CTRL_mm2s_1_AddrValid,
   output wire 								 STREAMIF_CTRL_mm2s_2_AddrValid,
   output wire 								 STREAMIF_CTRL_mm2s_3_AddrValid,
   output wire 								 STREAMIF_CTRL_mm2s_4_AddrValid,
   output wire 								 STREAMIF_CTRL_mm2s_5_AddrValid,
   output wire 								 STREAMIF_CTRL_mm2s_6_AddrValid,
   output wire 								 STREAMIF_CTRL_mm2s_7_AddrValid,
   output wire 								 STREAMIF_CTRL_mm2s_0_Start,
   output wire 								 STREAMIF_CTRL_mm2s_1_Start,
   output wire 								 STREAMIF_CTRL_mm2s_2_Start,
   output wire 								 STREAMIF_CTRL_mm2s_3_Start,
   output wire 								 STREAMIF_CTRL_mm2s_4_Start,
   output wire 								 STREAMIF_CTRL_mm2s_5_Start,
   output wire 								 STREAMIF_CTRL_mm2s_6_Start,
   output wire 								 STREAMIF_CTRL_mm2s_7_Start,
   input wire 								 STREAMIF_CTRL_mm2s_0_Idle,
   input wire 								 STREAMIF_CTRL_mm2s_1_Idle,
   input wire 								 STREAMIF_CTRL_mm2s_2_Idle,
   input wire 								 STREAMIF_CTRL_mm2s_3_Idle,
   input wire 								 STREAMIF_CTRL_mm2s_4_Idle,
   input wire 								 STREAMIF_CTRL_mm2s_5_Idle,
   input wire 								 STREAMIF_CTRL_mm2s_6_Idle,
   input wire 								 STREAMIF_CTRL_mm2s_7_Idle,
   output wire 								 STREAMIF_CTRL_mm2s_0_Reset,
   output wire 								 STREAMIF_CTRL_mm2s_1_Reset,
   output wire 								 STREAMIF_CTRL_mm2s_2_Reset,
   output wire 								 STREAMIF_CTRL_mm2s_3_Reset,
   output wire 								 STREAMIF_CTRL_mm2s_4_Reset,
   output wire 								 STREAMIF_CTRL_mm2s_5_Reset,
   output wire 								 STREAMIF_CTRL_mm2s_6_Reset,
   output wire 								 STREAMIF_CTRL_mm2s_7_Reset,
   input wire 								 STREAMIF_CTRL_mm2s_0_ResetOK,
   input wire 								 STREAMIF_CTRL_mm2s_1_ResetOK,
   input wire 								 STREAMIF_CTRL_mm2s_2_ResetOK,
   input wire 								 STREAMIF_CTRL_mm2s_3_ResetOK,
   input wire 								 STREAMIF_CTRL_mm2s_4_ResetOK,
   input wire 								 STREAMIF_CTRL_mm2s_5_ResetOK,
   input wire 								 STREAMIF_CTRL_mm2s_6_ResetOK,
   input wire 								 STREAMIF_CTRL_mm2s_7_ResetOK,








   output wire [31:0] 						 STREAMIF_CTRL_s2mm_0_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_s2mm_1_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_s2mm_2_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_s2mm_3_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_s2mm_4_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_s2mm_5_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_s2mm_6_Addr,
   output wire [31:0] 						 STREAMIF_CTRL_s2mm_7_Addr,
   output wire 								 STREAMIF_CTRL_s2mm_0_AddrValid,
   output wire 								 STREAMIF_CTRL_s2mm_1_AddrValid,
   output wire 								 STREAMIF_CTRL_s2mm_2_AddrValid,
   output wire 								 STREAMIF_CTRL_s2mm_3_AddrValid,
   output wire 								 STREAMIF_CTRL_s2mm_4_AddrValid,
   output wire 								 STREAMIF_CTRL_s2mm_5_AddrValid,
   output wire 								 STREAMIF_CTRL_s2mm_6_AddrValid,
   output wire 								 STREAMIF_CTRL_s2mm_7_AddrValid,
   output wire 								 STREAMIF_CTRL_s2mm_0_Start,
   output wire 								 STREAMIF_CTRL_s2mm_1_Start,
   output wire 								 STREAMIF_CTRL_s2mm_2_Start,
   output wire 								 STREAMIF_CTRL_s2mm_3_Start,
   output wire 								 STREAMIF_CTRL_s2mm_4_Start,
   output wire 								 STREAMIF_CTRL_s2mm_5_Start,
   output wire 								 STREAMIF_CTRL_s2mm_6_Start,
   output wire 								 STREAMIF_CTRL_s2mm_7_Start,
   input wire 								 STREAMIF_CTRL_s2mm_0_Idle,
   input wire 								 STREAMIF_CTRL_s2mm_1_Idle,
   input wire 								 STREAMIF_CTRL_s2mm_2_Idle,
   input wire 								 STREAMIF_CTRL_s2mm_3_Idle,
   input wire 								 STREAMIF_CTRL_s2mm_4_Idle,
   input wire 								 STREAMIF_CTRL_s2mm_5_Idle,
   input wire 								 STREAMIF_CTRL_s2mm_6_Idle,
   input wire 								 STREAMIF_CTRL_s2mm_7_Idle,
   output wire 								 STREAMIF_CTRL_s2mm_0_Reset,
   output wire 								 STREAMIF_CTRL_s2mm_1_Reset,
   output wire 								 STREAMIF_CTRL_s2mm_2_Reset,
   output wire 								 STREAMIF_CTRL_s2mm_3_Reset,
   output wire 								 STREAMIF_CTRL_s2mm_4_Reset,
   output wire 								 STREAMIF_CTRL_s2mm_5_Reset,
   output wire 								 STREAMIF_CTRL_s2mm_6_Reset,
   output wire 								 STREAMIF_CTRL_s2mm_7_Reset,
   input wire 								 STREAMIF_CTRL_s2mm_0_ResetOK,
   input wire 								 STREAMIF_CTRL_s2mm_1_ResetOK,
   input wire 								 STREAMIF_CTRL_s2mm_2_ResetOK,
   input wire 								 STREAMIF_CTRL_s2mm_3_ResetOK,
   input wire 								 STREAMIF_CTRL_s2mm_4_ResetOK,
   input wire 								 STREAMIF_CTRL_s2mm_5_ResetOK,
   input wire 								 STREAMIF_CTRL_s2mm_6_ResetOK,
   input wire 								 STREAMIF_CTRL_s2mm_7_ResetOK,








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

  wire [31:0] 								 STREAMIF_CTRL_Addr;
  reg [15:0] 								 STREAMIF_CTRL_AddrValid;
  wire [15:0] 								 STREAMIF_CTRL_Start;
  wire [15:0] 								 STREAMIF_CTRL_Idle;

  // BEGIN GENERATE LOOP
  assign STREAMIF_CTRL_mm2s_0_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_mm2s_1_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_mm2s_2_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_mm2s_3_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_mm2s_4_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_mm2s_5_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_mm2s_6_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_mm2s_7_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_mm2s_0_AddrValid = STREAMIF_CTRL_AddrValid[0 * 2];
  assign STREAMIF_CTRL_mm2s_1_AddrValid = STREAMIF_CTRL_AddrValid[1 * 2];
  assign STREAMIF_CTRL_mm2s_2_AddrValid = STREAMIF_CTRL_AddrValid[2 * 2];
  assign STREAMIF_CTRL_mm2s_3_AddrValid = STREAMIF_CTRL_AddrValid[3 * 2];
  assign STREAMIF_CTRL_mm2s_4_AddrValid = STREAMIF_CTRL_AddrValid[4 * 2];
  assign STREAMIF_CTRL_mm2s_5_AddrValid = STREAMIF_CTRL_AddrValid[5 * 2];
  assign STREAMIF_CTRL_mm2s_6_AddrValid = STREAMIF_CTRL_AddrValid[6 * 2];
  assign STREAMIF_CTRL_mm2s_7_AddrValid = STREAMIF_CTRL_AddrValid[7 * 2];
  assign STREAMIF_CTRL_mm2s_0_Start = STREAMIF_CTRL_Start[0 * 2];
  assign STREAMIF_CTRL_mm2s_1_Start = STREAMIF_CTRL_Start[1 * 2];
  assign STREAMIF_CTRL_mm2s_2_Start = STREAMIF_CTRL_Start[2 * 2];
  assign STREAMIF_CTRL_mm2s_3_Start = STREAMIF_CTRL_Start[3 * 2];
  assign STREAMIF_CTRL_mm2s_4_Start = STREAMIF_CTRL_Start[4 * 2];
  assign STREAMIF_CTRL_mm2s_5_Start = STREAMIF_CTRL_Start[5 * 2];
  assign STREAMIF_CTRL_mm2s_6_Start = STREAMIF_CTRL_Start[6 * 2];
  assign STREAMIF_CTRL_mm2s_7_Start = STREAMIF_CTRL_Start[7 * 2];
  assign STREAMIF_CTRL_Idle[0 * 2] = STREAMIF_CTRL_mm2s_0_Idle;
  assign STREAMIF_CTRL_Idle[1 * 2] = STREAMIF_CTRL_mm2s_1_Idle;
  assign STREAMIF_CTRL_Idle[2 * 2] = STREAMIF_CTRL_mm2s_2_Idle;
  assign STREAMIF_CTRL_Idle[3 * 2] = STREAMIF_CTRL_mm2s_3_Idle;
  assign STREAMIF_CTRL_Idle[4 * 2] = STREAMIF_CTRL_mm2s_4_Idle;
  assign STREAMIF_CTRL_Idle[5 * 2] = STREAMIF_CTRL_mm2s_5_Idle;
  assign STREAMIF_CTRL_Idle[6 * 2] = STREAMIF_CTRL_mm2s_6_Idle;
  assign STREAMIF_CTRL_Idle[7 * 2] = STREAMIF_CTRL_mm2s_7_Idle;








  assign STREAMIF_CTRL_mm2s_0_Reset = 0;
  assign STREAMIF_CTRL_mm2s_1_Reset = 0;
  assign STREAMIF_CTRL_mm2s_2_Reset = 0;
  assign STREAMIF_CTRL_mm2s_3_Reset = 0;
  assign STREAMIF_CTRL_mm2s_4_Reset = 0;
  assign STREAMIF_CTRL_mm2s_5_Reset = 0;
  assign STREAMIF_CTRL_mm2s_6_Reset = 0;
  assign STREAMIF_CTRL_mm2s_7_Reset = 0;








  assign STREAMIF_CTRL_s2mm_0_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_s2mm_1_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_s2mm_2_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_s2mm_3_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_s2mm_4_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_s2mm_5_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_s2mm_6_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_s2mm_7_Addr = STREAMIF_CTRL_Addr;
  assign STREAMIF_CTRL_s2mm_0_AddrValid = STREAMIF_CTRL_AddrValid[0 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_1_AddrValid = STREAMIF_CTRL_AddrValid[1 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_2_AddrValid = STREAMIF_CTRL_AddrValid[2 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_3_AddrValid = STREAMIF_CTRL_AddrValid[3 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_4_AddrValid = STREAMIF_CTRL_AddrValid[4 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_5_AddrValid = STREAMIF_CTRL_AddrValid[5 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_6_AddrValid = STREAMIF_CTRL_AddrValid[6 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_7_AddrValid = STREAMIF_CTRL_AddrValid[7 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_0_Start = STREAMIF_CTRL_Start[0 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_1_Start = STREAMIF_CTRL_Start[1 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_2_Start = STREAMIF_CTRL_Start[2 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_3_Start = STREAMIF_CTRL_Start[3 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_4_Start = STREAMIF_CTRL_Start[4 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_5_Start = STREAMIF_CTRL_Start[5 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_6_Start = STREAMIF_CTRL_Start[6 * 2 + 1];
  assign STREAMIF_CTRL_s2mm_7_Start = STREAMIF_CTRL_Start[7 * 2 + 1];
  assign STREAMIF_CTRL_Idle[0 * 2 + 1] = STREAMIF_CTRL_s2mm_0_Idle;
  assign STREAMIF_CTRL_Idle[1 * 2 + 1] = STREAMIF_CTRL_s2mm_1_Idle;
  assign STREAMIF_CTRL_Idle[2 * 2 + 1] = STREAMIF_CTRL_s2mm_2_Idle;
  assign STREAMIF_CTRL_Idle[3 * 2 + 1] = STREAMIF_CTRL_s2mm_3_Idle;
  assign STREAMIF_CTRL_Idle[4 * 2 + 1] = STREAMIF_CTRL_s2mm_4_Idle;
  assign STREAMIF_CTRL_Idle[5 * 2 + 1] = STREAMIF_CTRL_s2mm_5_Idle;
  assign STREAMIF_CTRL_Idle[6 * 2 + 1] = STREAMIF_CTRL_s2mm_6_Idle;
  assign STREAMIF_CTRL_Idle[7 * 2 + 1] = STREAMIF_CTRL_s2mm_7_Idle;








  assign STREAMIF_CTRL_s2mm_0_Reset = 0;
  assign STREAMIF_CTRL_s2mm_1_Reset = 0;
  assign STREAMIF_CTRL_s2mm_2_Reset = 0;
  assign STREAMIF_CTRL_s2mm_3_Reset = 0;
  assign STREAMIF_CTRL_s2mm_4_Reset = 0;
  assign STREAMIF_CTRL_s2mm_5_Reset = 0;
  assign STREAMIF_CTRL_s2mm_6_Reset = 0;
  assign STREAMIF_CTRL_s2mm_7_Reset = 0;
  // END GENERATE LOOP

  genvar 							 i;
  generate
	for (i = (HWT_COUNT*2); i < 16 ; i = i + 1) begin: gen
	  assign STREAMIF_CTRL_Idle[i] = 0;
	end
  endgenerate



  // ---------------------------------------------



  /* AXI Lite Slave signals */
  wire [32-1:0] 							reg0_address_and_devno;
  wire [32-1:0] 							reg1_control;
  wire [32-1:0] 							reg1_control_in;

  /*
   FIXME: reg_hwt_0, reg_hwt_1, ..., reg_hwt_7
     base : 16 bit 64 kb aligned : 0-4 GB
     mask : 16 bit 64 kb aligned : 0-4 GB
   */

  /* addresb signal (4096 byte aligned) */
  assign STREAMIF_CTRL_Addr = {reg0_address_and_devno[31:12], 12'b0};

  /* idle signal */
  assign reg1_control_in = {16'b0, STREAMIF_CTRL_Idle};

  /* start signal */
  assign STREAMIF_CTRL_Start = reg1_control[15:0];


  /* AddrValid signal */
  wire [7:0] 								devSelect;
  assign devSelect = reg0_address_and_devno[7:0];

  wire [0:0] 								devRange;
  assign devRange = reg0_address_and_devno[8:8];

  always @(*) begin
  	case (devRange)
  	  0: STREAMIF_CTRL_AddrValid = {8'b0, devSelect[7:0]};
  	  1: STREAMIF_CTRL_AddrValid = {devSelect[7:0], 8'b0};
  	endcase
  end

/*
 32 device
  wire [1:0] 								devRange;
  assign devRange = reg0_address_and_devno[10:8];
  always @(*) begin
  	case (devRange)
  	  0: STREAMIF_CTRL_AddrValid = {24'b0, devSelect};
  	  1: STREAMIF_CTRL_AddrValid = {16'b0, devSelect, 8'b0};
  	  2: STREAMIF_CTRL_AddrValid = {8'b0, devSelect, 16'b0};
  	  3: STREAMIF_CTRL_AddrValid = {devSelect, 24'b0};
  	endcase
  end
*/


  axi4_lite_slave axi4_lite_slave_i
	(
	 .S_AXI_ACLK(S_AXI_ACLK),
	 .S_AXI_ARESETN(S_AXI_ARESETN),
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



module axi4_lite_slave #
  (
   // Users to add parameters here
   // User parameters ends
   // Do not modify the parameters beyond this line

   // Width of S_AXI data bus
   parameter integer C_S_AXI_DATA_WIDTH = 32,
   // Width of S_AXI address bus
   parameter integer C_S_AXI_ADDR_WIDTH = 5
   )
  (
   // Users to add ports here
   input [31:0] 							 reg0_in,
   output reg [31:0] 						 reg0_out,
   input [31:0] 							 reg1_in,
   output reg [31:0] 						 reg1_out,
   input [31:0] 							 reg2_in,
   output reg [31:0] 						 reg2_out,
   input [31:0] 							 reg3_in,
   output reg [31:0] 						 reg3_out,
   // User ports ends
   // Do not modify the ports beyond this line

   // Global Clock Signal
   input wire 								 S_AXI_ACLK,
   // Global Reset Signal. This Signal is Active LOW
   input wire 								 S_AXI_ARESETN,
   // Write address (issued by master, acceped by Slave)
   input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	 S_AXI_AWADDR,
   // Write channel Protection type. This signal indicates the
   // privilege and security level of the transaction, and whether
   // the transaction is a data access or an instruction access.
   input wire [2 : 0] 						 S_AXI_AWPROT,
   // Write address valid. This signal indicates that the master signaling
   // valid write address and control information.
   input wire 								 S_AXI_AWVALID,
   // Write address ready. This signal indicates that the slave is ready
   // to accept an address and associated control signals.
   output wire 								 S_AXI_AWREADY,
   // Write data (issued by master, acceped by Slave)
   input wire [C_S_AXI_DATA_WIDTH-1 : 0] 	 S_AXI_WDATA,
   // Write strobes. This signal indicates which byte lanes hold
   // valid data. There is one write strobe bit for each eight
   // bits of the write data bus.
   input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
   // Write valid. This signal indicates that valid write
   // data and strobes are available.
   input wire 								 S_AXI_WVALID,
   // Write ready. This signal indicates that the slave
   // can accept the write data.
   output wire 								 S_AXI_WREADY,
   // Write response. This signal indicates the status
   // of the write transaction.
   output wire [1 : 0] 						 S_AXI_BRESP,
   // Write response valid. This signal indicates that the channel
   // is signaling a valid write response.
   output wire 								 S_AXI_BVALID,
   // Response ready. This signal indicates that the master
   // can accept a write response.
   input wire 								 S_AXI_BREADY,
   // Read address (issued by master, acceped by Slave)
   input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	 S_AXI_ARADDR,
   // Protection type. This signal indicates the privilege
   // and security level of the transaction, and whether the
   // transaction is a data access or an instruction access.
   input wire [2 : 0] 						 S_AXI_ARPROT,
   // Read address valid. This signal indicates that the channel
   // is signaling valid read address and control information.
   input wire 								 S_AXI_ARVALID,
   // Read address ready. This signal indicates that the slave is
   // ready to accept an address and associated control signals.
   output wire 								 S_AXI_ARREADY,
   // Read data (issued by slave)
   output wire [C_S_AXI_DATA_WIDTH-1 : 0] 	 S_AXI_RDATA,
   // Read response. This signal indicates the status of the
   // read transfer.
   output wire [1 : 0] 						 S_AXI_RRESP,
   // Read valid. This signal indicates that the channel is
   // signaling the required read data.
   output wire 								 S_AXI_RVALID,
   // Read ready. This signal indicates that the master can
   // accept the read data and response information.
   input wire 								 S_AXI_RREADY
   );

  // AXI4LITE signals
  reg [C_S_AXI_ADDR_WIDTH-1 : 0] 			 axi_awaddr;
  reg 										 axi_awready;
  reg 										 axi_wready;
  reg [1 : 0] 								 axi_bresp;
  reg 										 axi_bvalid;
  reg [C_S_AXI_ADDR_WIDTH-1 : 0] 			 axi_araddr;
  reg 										 axi_arready;
  reg [C_S_AXI_DATA_WIDTH-1 : 0] 			 axi_rdata;
  reg [1 : 0] 								 axi_rresp;
  reg 										 axi_rvalid;

  // Example-specific design signals
  // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  // ADDR_LSB is used for addressing 32/64 bit registers/memories
  // ADDR_LSB = 2 for 32 bits (n downto 2)
  // ADDR_LSB = 3 for 64 bits (n downto 3)
  localparam integer 						 ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
  localparam integer 						 OPT_MEM_ADDR_BITS = 2;
  //----------------------------------------------
  //-- Signals for user logic register space example
  //------------------------------------------------
  //-- Number of Slave Registers 8
  //
  wire 										 slv_reg_rden;
  wire 										 slv_reg_wren;
  reg [C_S_AXI_DATA_WIDTH-1:0] 				 reg_data_out;
  integer 									 byte_index;

  // I/O Connections assignments

  assign S_AXI_AWREADY	= axi_awready;
  assign S_AXI_WREADY	= axi_wready;
  assign S_AXI_BRESP	= axi_bresp;
  assign S_AXI_BVALID	= axi_bvalid;
  assign S_AXI_ARREADY	= axi_arready;
  assign S_AXI_RDATA	= axi_rdata;
  assign S_AXI_RRESP	= axi_rresp;
  assign S_AXI_RVALID	= axi_rvalid;
  // Implement axi_awready generation
  // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
  // de-asserted when reset is low.

  always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end
	  else
	    begin
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when
	          // there is a valid write address and write data
	          // on the write address and data bus. This design
	          // expects no outstanding transactions.
	          axi_awready <= 1'b1;
	        end
	      else
	        begin
	          axi_awready <= 1'b0;
	        end
	    end
	end

  // Implement axi_awaddr latching
  // This process is used to latch the address when both
  // S_AXI_AWVALID and S_AXI_WVALID are valid.

  always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end
	  else
	    begin
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end
	end

  // Implement axi_wready generation
  // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
  // de-asserted when reset is low.

  always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end
	  else
	    begin
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when
	          // there is a valid write address and write data
	          // on the write address and data bus. This design
	          // expects no outstanding transactions.
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end
	end

  // Implement memory mapped register select and write logic generation
  // The write data is accepted and written to memory mapped registers when
  // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  // select byte enables of slave registers while writing.
  // These registers are cleared when reset (active low) is applied.
  // Slave register write enable is asserted when valid address and data are available
  // and the slave is ready to accept the write address and write data.
  assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

  // TODO: yazma icin burayi doldur
  always @( posedge S_AXI_ACLK ) begin
	if ( S_AXI_ARESETN == 1'b0 ) begin
	  reg0_out <= 0;
	  reg1_out <= 0;
	  reg2_out <= 0;
	  reg3_out <= 0;
	end else begin
	  if (slv_reg_wren) begin
	    case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
	      3'h0:
			reg0_out <= S_AXI_WDATA;
	      3'h1:
			reg1_out <= S_AXI_WDATA;
	      3'h2:
			reg2_out <= S_AXI_WDATA;
	      3'h3:
			reg3_out <= S_AXI_WDATA;
	      // 3'h4:
	      // 3'h5:
	      // 3'h6:
	      // 3'h7:
	      default : begin
	      end
	    endcase
	  end else begin
	      // FIXME: gecici deneme, bu modulu kullanan modullere gore burayi duzenle
	      reg1_out <= 0;
	  end
	end
  end

  // Implement write response logic generation
  // The write response and response valid signals are asserted by the slave
  // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
  // This marks the acceptance of address and indicates the status of
  // write transaction.

  always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end
	  else
	    begin
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid)
	            //check if bready is asserted while bvalid is high)
	            //(there is a possibility that bready is always asserted high)
	            begin
	              axi_bvalid <= 1'b0;
	            end
	        end
	    end
	end

  // Implement axi_arready generation
  // axi_arready is asserted for one S_AXI_ACLK clock cycle when
  // S_AXI_ARVALID is asserted. axi_awready is
  // de-asserted when reset (active low) is asserted.
  // The read address is also latched when S_AXI_ARVALID is
  // asserted. axi_araddr is reset to zero on reset assertion.

  always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end
	  else
	    begin
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end
	end

  // Implement axi_arvalid generation
  // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_ARVALID and axi_arready are asserted. The slave registers
  // data are available on the axi_rdata bus at this instance. The
  // assertion of axi_rvalid marks the validity of read data on the
  // bus and axi_rresp indicates the status of read transaction.axi_rvalid
  // is deasserted on reset (active low). axi_rresp and axi_rdata are
  // cleared to zero on reset (active low).
  always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end
	  else
	    begin
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end
	    end
	end

  // Implement memory mapped register select and read logic generation
  // Slave register read enable is asserted when valid address is available
  // and the slave is ready to accept the read address.
  assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

  // TODO: okuma icin burayi doldur
  always @(*) begin
	// Address decoding for reading registers
	case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	  3'h0   : reg_data_out <= reg0_in;
	  3'h1   : reg_data_out <= reg1_in;
	  3'h2   : reg_data_out <= reg2_in;
	  3'h3   : reg_data_out <= reg3_in;
	  3'h4   : reg_data_out <= 0;
	  3'h5   : reg_data_out <= 0;
	  3'h6   : reg_data_out <= 0;
	  3'h7   : reg_data_out <= 0;
	  default : reg_data_out <= 0;
	endcase
  end

  // Output register or memory read data
  always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end
	  else
	    begin
	      // When there is a valid read address (S_AXI_ARVALID) with
	      // acceptance of read address by the slave (axi_arready),
	      // output the read dada
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end
	    end
	end

  // Add user logic here

  // User logic ends

endmodule
