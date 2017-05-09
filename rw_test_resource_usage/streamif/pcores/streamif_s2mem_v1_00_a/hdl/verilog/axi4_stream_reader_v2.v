`timescale 1 ns / 1 ps

module axi4_stream_reader_v2 #
  (
   parameter integer C_S_AXIS_TDATA_WIDTH = 32
   )
  (
   /* axi4-stream ports */
   input wire 								   S_AXIS_ACLK,
   input wire 								   S_AXIS_ARESETN,
   output wire 								   S_AXIS_TREADY,
   input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] 	   S_AXIS_TDATA,
   input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
   input wire 								   S_AXIS_TLAST,
   input wire 								   S_AXIS_TVALID,
   /* control signals */
   input wire 								   ready,
   output wire 								   data_valid,
   output wire [C_S_AXIS_TDATA_WIDTH-1:0] 	   data
   // FIXME: data_last
   );

  /* io connections */
  assign S_AXIS_TREADY = ready;
  assign data_valid = S_AXIS_TVALID;
  assign data = S_AXIS_TDATA;

endmodule
