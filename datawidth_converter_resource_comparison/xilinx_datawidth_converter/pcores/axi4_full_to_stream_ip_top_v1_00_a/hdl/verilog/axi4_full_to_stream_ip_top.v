module axi4_full_to_stream_ip_top #
  (
   /* AXI_MM */
   parameter integer C_M00_AXI_DATA_WIDTH = 32,
					 parameter C_M_TARGET_SLAVE_BASE_ADDR = 32'h00000000,
   // Burst Length. Supports 4, 8, 16, 32, 64, 128, 256 burst lengths
   parameter integer C_M00_AXI_BURST_LEN = 256,
   parameter integer C_M00_AXI_ID_WIDTH = 1,
   parameter integer C_M00_AXI_ADDR_WIDTH = 32,
   parameter integer C_M00_AXI_AWUSER_WIDTH = 1,
   parameter integer C_M00_AXI_ARUSER_WIDTH = 1,
   parameter integer C_M00_AXI_WUSER_WIDTH = 1,
   parameter integer C_M00_AXI_RUSER_WIDTH = 1,
   parameter integer C_M00_AXI_BUSER_WIDTH = 1,

   /* AXIS */
   parameter integer C_M01_AXIS_TDATA_WIDTH = 32
   )
  (
   input wire 									  ACLK,
   input wire 									  ARESETN,

   /* control ports hwt */
   input wire [31:0] 							  MM2S_CTRL_Addr,
   input wire 									  MM2S_CTRL_Start,
   input wire 									  MM2S_CTRL_Enabled,
   output wire 									  MM2S_CTRL_Idle,

   /* control ports stramif_control */
   input wire [31:0] 							  STREAMIF_CTRL_Addr,
   input wire 									  STREAMIF_CTRL_AddrValid,
   input wire 									  STREAMIF_CTRL_Start,
   output wire 									  STREAMIF_CTRL_Idle,

   /* axi4-stream ports */
   input wire 									  M01_AXIS_TREADY,
   output wire [C_M01_AXIS_TDATA_WIDTH-1 : 0] 	  M01_AXIS_TDATA,
   output wire [(C_M01_AXIS_TDATA_WIDTH/8)-1 : 0] M01_AXIS_TSTRB,
   output wire 									  M01_AXIS_TLAST,
   output wire 									  M01_AXIS_TVALID,
   /* axi4-mm ports */
   output wire [C_M00_AXI_ID_WIDTH-1 : 0] 		  M00_AXI_AWID,
   output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] 	  M00_AXI_AWADDR,
   output wire [7 : 0] 							  M00_AXI_AWLEN,
   output wire [2 : 0] 							  M00_AXI_AWSIZE,
   output wire [1 : 0] 							  M00_AXI_AWBURST,
   output wire 									  M00_AXI_AWLOCK,
   output wire [3 : 0] 							  M00_AXI_AWCACHE,
   output wire [2 : 0] 							  M00_AXI_AWPROT,
   output wire [3 : 0] 							  M00_AXI_AWQOS,
   output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] 	  M00_AXI_AWUSER,
   output wire 									  M00_AXI_AWVALID,
   input wire 									  M00_AXI_AWREADY,
   output wire [C_M00_AXI_DATA_WIDTH-1 : 0] 	  M00_AXI_WDATA,
   output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] 	  M00_AXI_WSTRB,
   output wire 									  M00_AXI_WLAST,
   output wire [C_M00_AXI_WUSER_WIDTH-1 : 0] 	  M00_AXI_WUSER,
   output wire 									  M00_AXI_WVALID,
   input wire 									  M00_AXI_WREADY,
   input wire [C_M00_AXI_ID_WIDTH-1 : 0] 		  M00_AXI_BID,
   input wire [1 : 0] 							  M00_AXI_BRESP,
   input wire [C_M00_AXI_BUSER_WIDTH-1 : 0] 	  M00_AXI_BUSER,
   input wire 									  M00_AXI_BVALID,
   output wire 									  M00_AXI_BREADY,
   output wire [C_M00_AXI_ID_WIDTH-1 : 0] 		  M00_AXI_ARID,
   output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] 	  M00_AXI_ARADDR,
   output wire [7 : 0] 							  M00_AXI_ARLEN,
   output wire [2 : 0] 							  M00_AXI_ARSIZE,
   output wire [1 : 0] 							  M00_AXI_ARBURST,
   output wire 									  M00_AXI_ARLOCK,
   output wire [3 : 0] 							  M00_AXI_ARCACHE,
   output wire [2 : 0] 							  M00_AXI_ARPROT,
   output wire [3 : 0] 							  M00_AXI_ARQOS,
   output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] 	  M00_AXI_ARUSER,
   output wire 									  M00_AXI_ARVALID,
   input wire 									  M00_AXI_ARREADY,
   input wire [C_M00_AXI_ID_WIDTH-1 : 0] 		  M00_AXI_RID,
   input wire [C_M00_AXI_DATA_WIDTH-1 : 0] 		  M00_AXI_RDATA,
   input wire [1 : 0] 							  M00_AXI_RRESP,
   input wire 									  M00_AXI_RLAST,
   input wire [C_M00_AXI_RUSER_WIDTH-1 : 0] 	  M00_AXI_RUSER,
   input wire 									  M00_AXI_RVALID,
   output wire 									  M00_AXI_RREADY
   );


  /* read_address */
  reg [31:0] 								read_address;
  always @(posedge ACLK) begin
	if (ARESETN == 0) begin
	  read_address <= 0;
	end else begin
	  if (MM2S_CTRL_Enabled)
		read_address <= MM2S_CTRL_Addr;
	  else if (STREAMIF_CTRL_AddrValid)
		read_address <= STREAMIF_CTRL_Addr;
	  else
		read_address <= read_address;
	end
  end

  /* idle signal */
  wire 										idle;
  assign STREAMIF_CTRL_Idle = idle;
  assign MM2S_CTRL_Idle = idle;


  /* start_signal logic */
  wire 										start_input;
  assign start_input = (MM2S_CTRL_Enabled) ? MM2S_CTRL_Start : STREAMIF_CTRL_Start;
  reg 										start_input_old;
  wire 										start_signal;
  always @(posedge ACLK) begin
	if (ARESETN == 0) begin
	  start_input_old <= 0;
	end else begin
	  start_input_old <= start_input;
	end
  end
  assign start_signal = (~start_input_old & start_input);

  axi4_full_to_stream #
  	(
  	 .C_M_AXI_BURST_LEN(C_M00_AXI_BURST_LEN),
	 .C_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
	 .C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
	 .C_M_AXI_ID_WIDTH(C_M00_AXI_ID_WIDTH),
	 .C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
	 .C_M_AXI_AWUSER_WIDTH(C_M00_AXI_AWUSER_WIDTH),
	 .C_M_AXI_ARUSER_WIDTH(C_M00_AXI_ARUSER_WIDTH),
	 .C_M_AXI_WUSER_WIDTH(C_M00_AXI_WUSER_WIDTH),
	 .C_M_AXI_RUSER_WIDTH(C_M00_AXI_RUSER_WIDTH),
	 .C_M_AXI_BUSER_WIDTH(C_M00_AXI_BUSER_WIDTH)
  	 )
  	 axi4_full_to_stream_i
  	(
  	 .ACLK(ACLK),
  	 .ARESETN(ARESETN),
  	 /* */
  	 .restart_read_count(0),
	 .read_address(read_address),
  	 .start_read(start_signal),
  	 .output_idle(idle),
  	 /* */
  	 .M_AXI_AWID(M00_AXI_AWID),
  	 .M_AXI_AWADDR(M00_AXI_AWADDR),
  	 .M_AXI_AWLEN(M00_AXI_AWLEN),
  	 .M_AXI_AWSIZE(M00_AXI_AWSIZE),
  	 .M_AXI_AWBURST(M00_AXI_AWBURST),
  	 .M_AXI_AWLOCK(M00_AXI_AWLOCK),
  	 .M_AXI_AWCACHE(M00_AXI_AWCACHE),
  	 .M_AXI_AWPROT(M00_AXI_AWPROT),
  	 .M_AXI_AWQOS(M00_AXI_AWQOS),
  	 .M_AXI_AWUSER(M00_AXI_AWUSER),
  	 .M_AXI_AWVALID(M00_AXI_AWVALID),
  	 .M_AXI_AWREADY(M00_AXI_AWREADY),
  	 .M_AXI_WDATA(M00_AXI_WDATA),
  	 .M_AXI_WSTRB(M00_AXI_WSTRB),
  	 .M_AXI_WLAST(M00_AXI_WLAST),
  	 .M_AXI_WUSER(M00_AXI_WUSER),
  	 .M_AXI_WVALID(M00_AXI_WVALID),
  	 .M_AXI_WREADY(M00_AXI_WREADY),
  	 .M_AXI_BID(M00_AXI_BID),
  	 .M_AXI_BRESP(M00_AXI_BRESP),
  	 .M_AXI_BUSER(M00_AXI_BUSER),
  	 .M_AXI_BVALID(M00_AXI_BVALID),
  	 .M_AXI_BREADY(M00_AXI_BREADY),
  	 .M_AXI_ARID(M00_AXI_ARID),
  	 .M_AXI_ARADDR(M00_AXI_ARADDR),
  	 .M_AXI_ARLEN(M00_AXI_ARLEN),
  	 .M_AXI_ARSIZE(M00_AXI_ARSIZE),
  	 .M_AXI_ARBURST(M00_AXI_ARBURST),
  	 .M_AXI_ARLOCK(M00_AXI_ARLOCK),
  	 .M_AXI_ARCACHE(M00_AXI_ARCACHE),
  	 .M_AXI_ARPROT(M00_AXI_ARPROT),
  	 .M_AXI_ARQOS(M00_AXI_ARQOS),
  	 .M_AXI_ARUSER(M00_AXI_ARUSER),
  	 .M_AXI_ARVALID(M00_AXI_ARVALID),
  	 .M_AXI_ARREADY(M00_AXI_ARREADY),
  	 .M_AXI_RID(M00_AXI_RID),
  	 .M_AXI_RDATA(M00_AXI_RDATA),
  	 .M_AXI_RRESP(M00_AXI_RRESP),
  	 .M_AXI_RLAST(M00_AXI_RLAST),
  	 .M_AXI_RUSER(M00_AXI_RUSER),
  	 .M_AXI_RVALID(M00_AXI_RVALID),
  	 .M_AXI_RREADY(M00_AXI_RREADY),
  	 /* */
  	 .M_AXIS_TVALID(M01_AXIS_TVALID),
  	 .M_AXIS_TDATA(M01_AXIS_TDATA),
  	 .M_AXIS_TSTRB(M01_AXIS_TSTRB),
  	 .M_AXIS_TLAST(M01_AXIS_TLAST),
  	 .M_AXIS_TREADY(M01_AXIS_TREADY)
  	 );

endmodule
`timescale 1 ns / 1 ps

module axi4_full_to_stream #
  (
   parameter integer C_AXI_DATA_WIDTH = 32,
   /* AXI_MM */
   parameter C_M_TARGET_SLAVE_BASE_ADDR = 32'h00000000,
   // Burst Length. Supports 4, 8, 16, 32, 64, 128, 256 burst lengths
   parameter integer C_M_AXI_BURST_LEN = 256,
   parameter integer C_M_AXI_ID_WIDTH = 1,
   parameter integer C_M_AXI_ADDR_WIDTH = 32,
   parameter integer C_M_AXI_AWUSER_WIDTH = 0,
   parameter integer C_M_AXI_ARUSER_WIDTH = 0,
   parameter integer C_M_AXI_WUSER_WIDTH = 0,
   parameter integer C_M_AXI_RUSER_WIDTH = 0,
   parameter integer C_M_AXI_BUSER_WIDTH = 0
   )
  (
   input wire 								ACLK,
   input wire 								ARESETN,
   /* control ports */
   input wire [7:0]                         restart_read_count,
   input wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	read_address,
   input wire 								start_read,
   output wire 								output_idle,
   /* axi4-stream ports */
   input wire 								M_AXIS_TREADY,
   output wire [C_AXI_DATA_WIDTH-1 : 0] 	M_AXIS_TDATA,
   output wire [(C_AXI_DATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
   output wire 								M_AXIS_TLAST,
   output wire 								M_AXIS_TVALID,
   /* axi4-mm ports */
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
   output wire [C_AXI_DATA_WIDTH-1 : 0] 	M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1 : 0] 	M_AXI_WSTRB,
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
   input wire [C_AXI_DATA_WIDTH-1 : 0] 		M_AXI_RDATA,
   input wire [1 : 0] 						M_AXI_RRESP,
   input wire 								M_AXI_RLAST,
   input wire [C_M_AXI_RUSER_WIDTH-1 : 0] 	M_AXI_RUSER,
   input wire 								M_AXI_RVALID,
   output wire 								M_AXI_RREADY
   );

  function integer clogb2 (input integer bit_depth);
	begin
	  for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	    bit_depth = bit_depth >> 1;
	end
  endfunction



  /* axi_stream_writer signals */
  reg 								   stream_writer_enabled = 0;
  wire [C_AXI_DATA_WIDTH-1:0]		   stream_writer_data;
  wire 								   stream_writer_data_valid;
  wire 								   stream_writer_data_last;
  wire 								   stream_writer_ready;

  axi_stream_writer_v2 #
	(
	 .C_M_AXIS_TDATA_WIDTH(32)
	 )
  axi_stream_writer_i
	(
	 .M_AXIS_ACLK(ACLK),
	 .M_AXIS_ARESETN(ARESETN),
	 /* */
	 .start(stream_writer_enabled),
	 .data(stream_writer_data),
	 .data_valid(stream_writer_data_valid),
	 .data_last(stream_writer_data_last),
	 .ready(stream_writer_ready),
	 /* */
	 .M_AXIS_TVALID(M_AXIS_TVALID),
	 .M_AXIS_TDATA(M_AXIS_TDATA),
	 .M_AXIS_TSTRB(M_AXIS_TSTRB),
	 .M_AXIS_TLAST(M_AXIS_TLAST),
	 .M_AXIS_TREADY(M_AXIS_TREADY)
	 );


  /* axi4_full_master_rw signals */

  reg [C_M_AXI_ADDR_WIDTH-1:0] 				axi_mm_write_address = 0;
  reg [C_AXI_DATA_WIDTH-1:0] 				axi_mm_write_data = 0;
  reg 										axi_mm_write_data_valid = 0;
  reg 										axi_mm_write_start = 0;
  wire 										axi_mm_write_ready;
  wire 										axi_mm_write_end;

  reg [C_M_AXI_ADDR_WIDTH-1:0] 				axi_mm_read_address = 0;
  reg 										axi_mm_read_start = 0;
  wire [C_AXI_DATA_WIDTH-1:0] 				axi_mm_read_data;
  wire 										axi_mm_read_data_valid;
  wire 										axi_mm_read_data_last;
  wire 										axi_mm_read_ready;
  wire 										axi_mm_read_end;

  wire 										axi_mm_output_idle;
  wire 										axi_mm_output_error;

  axi4_full_master_rw_v3 #
	(
	 .C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
	 .C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
	 .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
	 .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
	 .C_M_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
	 .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
	 .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
	 .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
	 .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
	 .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
	 )
  axi_mm_i
	(
	 .write_address(axi_mm_write_address),
	 .write_data(axi_mm_write_data),
	 .write_data_valid(axi_mm_write_data_valid),
	 .write_data_last(), // FIXME: --
	 .write_start(axi_mm_write_start),
	 .write_ready(axi_mm_write_ready),
	 .write_end(axi_mm_write_end),

	 .read_address(axi_mm_read_address),
	 .read_start(axi_mm_read_start),
	 .read_data(axi_mm_read_data),
	 .read_data_valid(axi_mm_read_data_valid),
	 .read_data_last(axi_mm_read_data_last), // FIXME: --
	 .read_ready(axi_mm_read_ready),
	 .read_end(axi_mm_read_end),

	 .output_idle(axi_mm_output_idle),
	 .output_error(axi_mm_output_error),
	 /* */
	 .M_AXI_ACLK(ACLK),
	 .M_AXI_ARESETN(ARESETN),
	 /* */
	 .M_AXI_AWID(M_AXI_AWID),
	 .M_AXI_AWADDR(M_AXI_AWADDR),
	 .M_AXI_AWLEN(M_AXI_AWLEN),
	 .M_AXI_AWSIZE(M_AXI_AWSIZE),
	 .M_AXI_AWBURST(M_AXI_AWBURST),
	 .M_AXI_AWLOCK(M_AXI_AWLOCK),
	 .M_AXI_AWCACHE(M_AXI_AWCACHE),
	 .M_AXI_AWPROT(M_AXI_AWPROT),
	 .M_AXI_AWQOS(M_AXI_AWQOS),
	 .M_AXI_AWUSER(M_AXI_AWUSER),
	 .M_AXI_AWVALID(M_AXI_AWVALID),
	 .M_AXI_AWREADY(M_AXI_AWREADY),
	 .M_AXI_WDATA(M_AXI_WDATA),
	 .M_AXI_WSTRB(M_AXI_WSTRB),
	 .M_AXI_WLAST(M_AXI_WLAST),
	 .M_AXI_WUSER(M_AXI_WUSER),
	 .M_AXI_WVALID(M_AXI_WVALID),
	 .M_AXI_WREADY(M_AXI_WREADY),
	 .M_AXI_BID(M_AXI_BID),
	 .M_AXI_BRESP(M_AXI_BRESP),
	 .M_AXI_BUSER(M_AXI_BUSER),
	 .M_AXI_BVALID(M_AXI_BVALID),
	 .M_AXI_BREADY(M_AXI_BREADY),
	 .M_AXI_ARID(M_AXI_ARID),
	 .M_AXI_ARADDR(M_AXI_ARADDR),
	 .M_AXI_ARLEN(M_AXI_ARLEN),
	 .M_AXI_ARSIZE(M_AXI_ARSIZE),
	 .M_AXI_ARBURST(M_AXI_ARBURST),
	 .M_AXI_ARLOCK(M_AXI_ARLOCK),
	 .M_AXI_ARCACHE(M_AXI_ARCACHE),
	 .M_AXI_ARPROT(M_AXI_ARPROT),
	 .M_AXI_ARQOS(M_AXI_ARQOS),
	 .M_AXI_ARUSER(M_AXI_ARUSER),
	 .M_AXI_ARVALID(M_AXI_ARVALID),
	 .M_AXI_ARREADY(M_AXI_ARREADY),
	 .M_AXI_RID(M_AXI_RID),
	 .M_AXI_RDATA(M_AXI_RDATA),
	 .M_AXI_RRESP(M_AXI_RRESP),
	 .M_AXI_RLAST(M_AXI_RLAST),
	 .M_AXI_RUSER(M_AXI_RUSER),
	 .M_AXI_RVALID(M_AXI_RVALID),
	 .M_AXI_RREADY(M_AXI_RREADY)
	 );

  reg [3:0] state;
  reg [7:0] run_no;

  assign stream_writer_data = axi_mm_read_data;
  assign stream_writer_data_valid = axi_mm_read_data_valid & (state == 1) ;
  assign axi_mm_read_ready = stream_writer_ready;
  assign stream_writer_data_last = axi_mm_read_data_last;

  assign output_idle = (state == 0);
  always @(posedge ACLK) begin
    // $display("axi_stream_writer_ready: %x", axi_stream_writer_ready);
	if (ARESETN == 0) begin
	  state <= 0;
	  run_no <= 0;

	end else begin
	  case (state)
		0: begin // idle
		  if (start_read) begin
		    run_no <= 0;
			axi_mm_read_address <= read_address;
			axi_mm_read_start <= 1;

			stream_writer_enabled <= 1;
			state <= 1;
			$display("axi4_mm2s state <= 1");
		  end
		end
		1: begin // write
		  axi_mm_read_start <= 0;

		  if (axi_mm_read_end) begin
			stream_writer_enabled <= 0;
			state <= 2;
			$display("axi4_mm2s state <= 2");
		  end

		  // $display("stream_writer_ready : %x", stream_writer_ready);

		end
		2: begin // end
		  if (run_no == restart_read_count) begin
		      state <= 0;
		      $display("axi4_mm2s state <= 0");
		  end else begin
              state <= 3;
              $display("axi4_mm2s state <= 3");
		  end
        end
		3: begin // restart
		  // state 2'de de bu islem yapilabilir, Fakat 1 clock bosta bekletmek icin state 3 eklendi
		  run_no <= run_no + 1;
          axi_mm_read_address <= read_address;
          axi_mm_read_start <= 1;
          stream_writer_enabled <= 1;
          state <= 1;
          $display("axi4_mm2s state <= 1");
		end
 	  endcase
	end
  end


endmodule

`timescale 1 ns / 1 ps

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
`timescale 1 ns / 1 ps

module axi_stream_writer_v2 #
  (
   parameter integer C_M_AXIS_TDATA_WIDTH = 32
  )
  (
   input wire 									start, // FIXME: sil
   input wire [C_M_AXIS_TDATA_WIDTH-1:0] 		data,
   input wire 									data_valid,
   input wire 									data_last,
   output wire 									ready,
   /* axi4-stream ports */
   input wire 									M_AXIS_ACLK,
   input wire 									M_AXIS_ARESETN,
   output wire 									M_AXIS_TVALID,
   output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] 	M_AXIS_TDATA,
   output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
   output wire 									M_AXIS_TLAST,
   input wire 									M_AXIS_TREADY
   );


  /* I/O connections */
  assign M_AXIS_TVALID	= data_valid;
  assign M_AXIS_TDATA	= data;
  assign M_AXIS_TLAST	= data_last;
  assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

  assign ready = M_AXIS_TREADY;

endmodule
`timescale 1 ns / 1 ps

module axi4_full_master_rw_v3 #
  (
   parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
   // Burst Length. Supports 4, 8, 16, 32, 64, 128, 256 burst lengths
   parameter integer C_M_AXI_BURST_LEN	= 4,
   parameter integer C_M_AXI_ID_WIDTH	= 1,
   parameter integer C_M_AXI_ADDR_WIDTH	= 32,
   parameter integer C_M_AXI_DATA_WIDTH	= 32,
   parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
   parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
   parameter integer C_M_AXI_WUSER_WIDTH	= 0,
   parameter integer C_M_AXI_RUSER_WIDTH	= 0,
   parameter integer C_M_AXI_BUSER_WIDTH	= 0
   )
  (
   input wire [C_M_AXI_ADDR_WIDTH-1:0] 		write_address,
   input wire 								write_start,
   input wire [C_M_AXI_DATA_WIDTH-1:0] 		write_data,
   input wire 								write_data_valid,
   output wire 								write_data_last,
   output wire 								write_ready,
   output wire 								write_end,

   input wire [C_M_AXI_ADDR_WIDTH-1:0] 		read_address,
   input wire 								read_start,
   output wire [C_M_AXI_DATA_WIDTH-1:0] 		read_data,
   output wire 								read_data_valid,
   output wire 								read_data_last,
   input wire 								read_ready,
   output wire 								read_end,

   output wire 								output_idle,
   output wire 								output_error,
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
   output wire 								M_AXI_RREADY
   );


  function integer clogb2 (input integer bit_depth);
	begin
	  for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	    bit_depth = bit_depth >> 1;
	end
  endfunction


  /* axi signals */
  reg [C_M_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
  reg 							 axi_awvalid;
  wire [C_M_AXI_DATA_WIDTH-1 : 0] axi_wdata;
  reg 							  axi_wlast;
  wire 							  axi_wvalid;
  reg 							  axi_bready;
  reg [C_M_AXI_ADDR_WIDTH-1 : 0]  axi_araddr = 0;
  reg 							  axi_arvalid = 0;
  wire 							  axi_rready;

  /* */
  reg 							  error_reg;
  wire 							  write_resp_error;



  /*  */
  reg [2:0]  write_control_state = 0;
  reg [7:0]  write_burst_count = 0;
  reg [2:0]  read_control_state = 0;

  // I/O Connections assignments

  //I/O Connections. Write Address (AW)
  assign M_AXI_AWID	= 'b0;
  assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
  assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
  assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
  assign M_AXI_AWBURST	= 2'b01;
  assign M_AXI_AWLOCK	= 1'b0;
  assign M_AXI_AWCACHE	= 4'b0010;  //Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port.
  assign M_AXI_AWPROT	= 3'h0;
  assign M_AXI_AWQOS	= 4'h0;
  assign M_AXI_AWUSER	= 'b1;
  assign M_AXI_AWVALID	= axi_awvalid;
  //Write Data(W)
  assign M_AXI_WDATA	= axi_wdata;
  assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
  assign M_AXI_WLAST	= axi_wlast;
  assign M_AXI_WUSER	= 'b0;
  assign M_AXI_WVALID	= axi_wvalid;
  //Write Response (B)
  assign M_AXI_BREADY	= axi_bready;
  //Read Address (AR)
  assign M_AXI_ARID	= 'b0;
  assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
  assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
  assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
  assign M_AXI_ARBURST	= 2'b01;
  assign M_AXI_ARLOCK	= 1'b0;
  assign M_AXI_ARCACHE	= 4'b0010; //Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port
  assign M_AXI_ARPROT	= 3'h0;
  assign M_AXI_ARQOS	= 4'h0;
  assign M_AXI_ARUSER	= 'b1;
  assign M_AXI_ARVALID	= axi_arvalid;
  //Read and Read Response (R)
  assign M_AXI_RREADY	= axi_rready;

  /* */
  assign output_idle = (write_control_state==0) && (read_control_state==0);
  assign output_error = error_reg;


  reg 		 write_control_wen;

  assign axi_wvalid = (write_data_valid && write_control_wen);
  assign axi_wdata = write_data;
  assign write_ready = (M_AXI_WREADY && write_control_wen);
  assign write_data_last = axi_wlast;

  always @(posedge M_AXI_ACLK) begin
	if (M_AXI_ARESETN == 0) begin
	  write_control_state <= 0;
	  axi_awaddr <= 0;
	  axi_awvalid <= 0;
	  axi_bready <= 0;

	  write_burst_count <= 0;
	  axi_wlast <= 0;

	  write_control_wen <= 0;
	end else begin
	  case (write_control_state)
		0: begin // idle
		  if (write_start) begin
			axi_awaddr <= write_address;
			axi_awvalid <= 1;

			write_control_state <= write_control_state + 1;
			$display("[axi4_full_master_rw_2] write_address: %x", write_address);
		  end
		end
		1: begin
		  if (M_AXI_AWREADY) begin
			axi_awvalid <= 0;

			write_control_state <= write_control_state + 1;

			write_burst_count <= 0;
			write_control_wen <= 1;
		  end
		end
		2: begin // burst state
		  if (M_AXI_WVALID && M_AXI_WREADY) begin

			if (write_burst_count == C_M_AXI_BURST_LEN-2) begin
			  axi_wlast <= 1;
			  write_control_state <= write_control_state + 1;
			end

			write_burst_count <= write_burst_count + 1;
			$display("[axi4_full_master_rw_v3] write: %x (%d/%d)", axi_wdata, write_burst_count+1, C_M_AXI_BURST_LEN);
		  end
		end
		3: begin
		  write_control_wen <= 0;
		  axi_wlast <= 0;
		  axi_bready <= 1;
		  write_control_state <= write_control_state + 1;
		  $display("[axi4_full_master_rw_v3] write: %x (%d/%d)", axi_wdata, write_burst_count+1, C_M_AXI_BURST_LEN);
		end
		4: begin
		  if (M_AXI_BVALID) begin
		  	axi_bready <= 0;
			write_control_state <= 0;
		  end
		end
	  endcase
	end
  end

  // gecikmeyi azaltmak icin bu sekilde cikis verildi
  // 1 clock high sinyal uretir
  assign write_end = (write_control_state == 4 && M_AXI_BVALID);



  assign read_data = M_AXI_RDATA;
  assign read_data_valid = M_AXI_RVALID && ((read_control_state == 2) || (read_control_state == 1)); // FIXME: state 1 de dahil olabilir
  assign read_data_last = M_AXI_RLAST;

  assign axi_rready = (read_ready && read_control_state == 2);

  /* read control state machine */
  always @(posedge M_AXI_ACLK) begin
	if (M_AXI_ARESETN == 0) begin
	  read_control_state <= 0;
	  axi_araddr <= 0;
	  axi_arvalid <= 0;
	end else begin
	  case (read_control_state)
		0: begin
		  if (read_start) begin
			axi_araddr <= read_address;
			axi_arvalid <= 1;
			read_control_state <= 1;
			$display("axi4_full_master_rw_v3 read_address: %x", read_address);
		  end
		end
		1: begin
		  if (M_AXI_ARREADY) begin
			axi_arvalid <= 0;
			read_control_state <= 2;
		  end
		end
		2: begin // burst state
		  if (M_AXI_RLAST && M_AXI_RVALID) // axi crossbar RLAST i tumune gonderiyor
			read_control_state <= 3;

		end
		3: begin // end state
			read_control_state <= 0;
		end
	  endcase
	end
  end

  assign read_end = (read_control_state == 3);

  /* error_reg */
  assign write_resp_error = axi_bready & M_AXI_BVALID & M_AXI_BRESP[1];
  always @(posedge M_AXI_ACLK) begin
	if (M_AXI_ARESETN == 0)
	  error_reg <= 1'b0;
	else if (write_resp_error)
	  error_reg <= 1'b1;
	else
	  error_reg <= error_reg;
  end


endmodule
