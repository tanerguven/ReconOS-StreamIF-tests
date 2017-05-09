module dualport_ram  #
  (
   parameter integer C_DATA_WIDTH = 64,
   parameter integer C_ADDR_SIZE = 9
   )
  (
   input 						 clk,
   input 						 wea,
   input 						 reb,
   input [C_ADDR_SIZE-1:0] 		 addra,
   input [C_ADDR_SIZE-1:0] 		 addrb,
   input [C_DATA_WIDTH-1:0] 	 dia,
   output reg [C_DATA_WIDTH-1:0] dob
   );

  localparam C_COUNT = (1<<C_ADDR_SIZE);

  reg [C_DATA_WIDTH-1:0] 	 ram [C_COUNT-1:0] /* synthesis syn_ramstyle = "block_ram" syn_ramstyle = "no_rw_check" */;

  // exemplar attribute ram block_ram TRUE

  always @ (posedge clk) begin
    if (wea)
      ram[addra] <= dia;
	if (reb) begin
      dob <= ram[addrb];
	  // $display("ram out: %d %x", addrb, ram[addrb]);
	end
  end

endmodule  // dualport_ram
