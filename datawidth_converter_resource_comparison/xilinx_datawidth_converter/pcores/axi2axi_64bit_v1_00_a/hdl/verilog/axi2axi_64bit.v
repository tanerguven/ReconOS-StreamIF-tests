`timescale 1 ns / 1 ps

module axi2axi_64bit #
  (
   parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
   // Burst Length. Supports 4, 8, 16, 32, 64, 128, 256 burst lengths
   parameter integer C_M_AXI_BURST_LEN	= 256,
   parameter integer C_M_AXI_ID_WIDTH	= 1,
   parameter integer C_M_AXI_ADDR_WIDTH	= 32,
   parameter integer C_M_AXI_DATA_WIDTH	= 64,
   parameter integer C_M_AXI_AWUSER_WIDTH	= 1,
   parameter integer C_M_AXI_ARUSER_WIDTH	= 1,
   parameter integer C_M_AXI_WUSER_WIDTH	= 1,
   parameter integer C_M_AXI_RUSER_WIDTH	= 1,
   parameter integer C_M_AXI_BUSER_WIDTH	= 1,

   parameter integer C_S_AXI_BURST_LEN	= 256,
   parameter integer C_S_AXI_ID_WIDTH	= 1,
   parameter integer C_S_AXI_ADDR_WIDTH	= 32,
   parameter integer C_S_AXI_DATA_WIDTH	= 64,
   parameter integer C_S_AXI_AWUSER_WIDTH	= 1,
   parameter integer C_S_AXI_ARUSER_WIDTH	= 1,
   parameter integer C_S_AXI_WUSER_WIDTH	= 1,
   parameter integer C_S_AXI_RUSER_WIDTH	= 1,
   parameter integer C_S_AXI_BUSER_WIDTH	= 1
   )
  (
   /* */
   input wire 								M_AXI_ACLK,
   input wire 								M_AXI_ARESETN,
   output wire [C_M_AXI_ID_WIDTH-1 : 0] 	M_AXI_AWID,
   output wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	M_AXI_AWADDR,
   output wire [7 : 0] 						M_AXI_AWLEN,
   output wire [2 : 0] 						M_AXI_AWSIZE,
   output wire [1 : 0] 						M_AXI_AWBURST,
   output wire 								M_AXI_AWLOCK,
   output wire [3 : 0] 						M_AXI_AWCACHE,
   output wire [2 : 0] 						M_AXI_AWPROT,
   output wire [3 : 0] 						M_AXI_AWQOS,
   output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
   output wire 								M_AXI_AWVALID,
   input wire 								M_AXI_AWREADY,
   output wire [C_M_AXI_DATA_WIDTH-1 : 0] 	M_AXI_WDATA,
   output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
   output wire 								M_AXI_WLAST,
   output wire [C_M_AXI_WUSER_WIDTH-1 : 0] 	M_AXI_WUSER,
   output wire 								M_AXI_WVALID,
   input wire 								M_AXI_WREADY,
   input wire [C_M_AXI_ID_WIDTH-1 : 0] 		M_AXI_BID,
   input wire [1 : 0] 						M_AXI_BRESP,
   input wire [C_M_AXI_BUSER_WIDTH-1 : 0] 	M_AXI_BUSER,
   input wire 								M_AXI_BVALID,
   output wire 								M_AXI_BREADY,
   output wire [C_M_AXI_ID_WIDTH-1 : 0] 	M_AXI_ARID,
   output wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	M_AXI_ARADDR,
   output wire [7 : 0] 						M_AXI_ARLEN,
   output wire [2 : 0] 						M_AXI_ARSIZE,
   output wire [1 : 0] 						M_AXI_ARBURST,
   output wire 								M_AXI_ARLOCK,
   output wire [3 : 0] 						M_AXI_ARCACHE,
   output wire [2 : 0] 						M_AXI_ARPROT,
   output wire [3 : 0] 						M_AXI_ARQOS,
   output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
   output wire 								M_AXI_ARVALID,
   input wire 								M_AXI_ARREADY,
   input wire [C_M_AXI_ID_WIDTH-1 : 0] 		M_AXI_RID,
   input wire [C_M_AXI_DATA_WIDTH-1 : 0] 	M_AXI_RDATA,
   input wire [1 : 0] 						M_AXI_RRESP,
   input wire 								M_AXI_RLAST,
   input wire [C_M_AXI_RUSER_WIDTH-1 : 0] 	M_AXI_RUSER,
   input wire 								M_AXI_RVALID,
   output wire 								M_AXI_RREADY,

   /* */
   input wire 								S_AXI_ACLK,
   input wire 								S_AXI_ARESETN,
   input wire [C_S_AXI_ID_WIDTH-1 : 0] 		S_AXI_AWID,
   input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	S_AXI_AWADDR,
   input wire [7 : 0] 						S_AXI_AWLEN,
   input wire [2 : 0] 						S_AXI_AWSIZE,
   input wire [1 : 0] 						S_AXI_AWBURST,
   input wire 								S_AXI_AWLOCK,
   input wire [3 : 0] 						S_AXI_AWCACHE,
   input wire [2 : 0] 						S_AXI_AWPROT,
   input wire [3 : 0] 						S_AXI_AWQOS,
   input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] 	S_AXI_AWUSER,
   input wire 								S_AXI_AWVALID,
   output wire 								S_AXI_AWREADY,
   input wire [C_S_AXI_DATA_WIDTH-1 : 0] 	S_AXI_WDATA,
   input wire [C_S_AXI_DATA_WIDTH/8-1 : 0] 	S_AXI_WSTRB,
   input wire 								S_AXI_WLAST,
   input wire [C_S_AXI_WUSER_WIDTH-1 : 0] 	S_AXI_WUSER,
   input wire 								S_AXI_WVALID,
   output wire 								S_AXI_WREADY,
   output wire [C_S_AXI_ID_WIDTH-1 : 0] 	S_AXI_BID,
   output wire [1 : 0] 						S_AXI_BRESP,
   output wire [C_S_AXI_BUSER_WIDTH-1 : 0] 	S_AXI_BUSER,
   output wire 								S_AXI_BVALID,
   input wire 								S_AXI_BREADY,
   input wire [C_S_AXI_ID_WIDTH-1 : 0] 		S_AXI_ARID,
   input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	S_AXI_ARADDR,
   input wire [7 : 0] 						S_AXI_ARLEN,
   input wire [2 : 0] 						S_AXI_ARSIZE,
   input wire [1 : 0] 						S_AXI_ARBURST,
   input wire 								S_AXI_ARLOCK,
   input wire [3 : 0] 						S_AXI_ARCACHE,
   input wire [2 : 0] 						S_AXI_ARPROT,
   input wire [3 : 0] 						S_AXI_ARQOS,
   input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] 	S_AXI_ARUSER,
   input wire 								S_AXI_ARVALID,
   output wire 								S_AXI_ARREADY,
   output wire [C_S_AXI_ID_WIDTH-1 : 0] 	S_AXI_RID,
   output wire [C_S_AXI_DATA_WIDTH-1 : 0] 	S_AXI_RDATA,
   output wire [1 : 0] 						S_AXI_RRESP,
   output wire 								S_AXI_RLAST,
   output wire [C_S_AXI_RUSER_WIDTH-1 : 0] 	S_AXI_RUSER,
   output wire 								S_AXI_RVALID,
   input wire 								S_AXI_RREADY


   );


  assign S_AXI_AWREADY = M_AXI_AWREADY;
  assign S_AXI_WREADY = M_AXI_WREADY;
  assign S_AXI_BID = M_AXI_BID;
  assign S_AXI_BRESP = M_AXI_BRESP;
  assign S_AXI_BUSER = M_AXI_BUSER;
  assign S_AXI_BVALID = M_AXI_BVALID;
  assign S_AXI_ARREADY = M_AXI_ARREADY;
  assign S_AXI_RID = M_AXI_RID;
  assign S_AXI_RDATA = M_AXI_RDATA;
  assign S_AXI_RRESP = M_AXI_RRESP;
  assign S_AXI_RLAST = M_AXI_RLAST;
  assign S_AXI_RUSER = M_AXI_RUSER;
  assign S_AXI_RVALID = M_AXI_RVALID;


  assign M_AXI_AWID = S_AXI_AWID;
  assign M_AXI_AWADDR = S_AXI_AWADDR;
  assign M_AXI_AWLEN = S_AXI_AWLEN;
  assign M_AXI_AWSIZE = S_AXI_AWSIZE;
  assign M_AXI_AWBURST = S_AXI_AWBURST;
  assign M_AXI_AWLOCK = S_AXI_AWLOCK;
  assign M_AXI_AWCACHE = S_AXI_AWCACHE;
  assign M_AXI_AWPROT = S_AXI_AWPROT;
  assign M_AXI_AWQOS = S_AXI_AWQOS;
  assign M_AXI_AWUSER = S_AXI_AWUSER;
  assign M_AXI_AWVALID = S_AXI_AWVALID;
  assign M_AXI_WDATA = S_AXI_WDATA;
  assign M_AXI_WSTRB = S_AXI_WSTRB;
  assign M_AXI_WLAST = S_AXI_WLAST;
  assign M_AXI_WUSER = S_AXI_WUSER;
  assign M_AXI_WVALID = S_AXI_WVALID;
  assign M_AXI_BREADY = S_AXI_BREADY;
  assign M_AXI_ARID = S_AXI_ARID;
  assign M_AXI_ARADDR = S_AXI_ARADDR;
  assign M_AXI_ARLEN = S_AXI_ARLEN;
  assign M_AXI_ARSIZE = S_AXI_ARSIZE;
  assign M_AXI_ARBURST = S_AXI_ARBURST;
  assign M_AXI_ARLOCK = S_AXI_ARLOCK;
  assign M_AXI_ARCACHE = S_AXI_ARCACHE;
  assign M_AXI_ARPROT = S_AXI_ARPROT;
  assign M_AXI_ARQOS = S_AXI_ARQOS;
  assign M_AXI_ARUSER = S_AXI_ARUSER;
  assign M_AXI_ARVALID = S_AXI_ARVALID;
  assign M_AXI_RREADY = S_AXI_RREADY;


endmodule
