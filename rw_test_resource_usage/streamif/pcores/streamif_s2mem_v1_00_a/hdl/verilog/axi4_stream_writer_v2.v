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
