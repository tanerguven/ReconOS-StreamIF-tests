--                                                        ____  _____
--                            ________  _________  ____  / __ \/ ___/
--                           / ___/ _ \/ ___/ __ \/ __ \/ / / /\__ \
--                          / /  /  __/ /__/ /_/ / / / / /_/ /___/ /
--                         /_/   \___/\___/\____/_/ /_/\____//____/
-- 
-- ======================================================================
--
--   title:        IP-Core - PROC_CONTROL - Proc control implementation
--
--   project:      ReconOS
--   author:       Christoph Rüthing, University of Paderborn
--   description:  The Proc Conrol is used to control the different
--                 hardware parts through a single interface. It allows
--                 to reset the HWTs seperately and asynchronously and
--                 configures the MMU. To provide its functionality it
--                 has several registers.
--                 Register Definition (as seen from Bus):
--                   Reg0: Number of HWT-Slots (OSIFS) - Read only
--                   # all MMU related stuff
--                   Reg1: PGD address - Read / Write
--                   Reg2: Page fault address (only valid on interrupt)
--                         read to clear interrupt, write after handling
--                   Reg3: TLB hits - Read only
--                   Reg4: TLB misses - Read only
--                   # resets
--                   Reg5: ReconOS reset (reset everything) - Write only
--                   Reg6: HWT reset (multiple registers) - Write only
--                         | x , x-1, ... | x-32 , x-33, ... 0 |
--
--                   Page fault handling works the following:
--                     1.) MMU raises MMU_Pgf
--                     2.) Proc control raises PROC_Pgf_Int
--                     3.) CPU clears interrupt by reading register 2
--                     4.) CPU handles page fault and acknowledges this
--                         by writing to register 2
--                     5.) Proc control informs MMU by raising MMU_Ready
--                         that the page fault has been handled
--
-- ======================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.ipif_pkg.all;

library axi_lite_ipif_v1_01_a;
use axi_lite_ipif_v1_01_a.axi_lite_ipif;

library reconos_proc_control_v1_00_a;
use reconos_proc_control_v1_00_a.user_logic;


entity reconos_proc_control is
	generic (
		-- Proc Control paramters
		C_NUM_HWTS   : integer   := 1;
	
		-- Bus protocol parameters, do not add to or delete
		C_S_AXI_DATA_WIDTH   : integer            := 32;
		C_S_AXI_ADDR_WIDTH   : integer            := 32;
		C_S_AXI_MIN_SIZE     : std_logic_vector   := X"000001FF";
		C_USE_WSTRB          : integer            := 0;
		C_DPHASE_TIMEOUT     : integer            := 8;
		C_BASEADDR           : std_logic_vector   := X"FFFFFFFF";
		C_HIGHADDR           : std_logic_vector   := X"00000000";
		C_FAMILY             : string             := "virtex6";
		C_NUM_REG            : integer            := 1;
		C_NUM_MEM            : integer            := 1;
		C_SLV_AWIDTH         : integer            := 32;
		C_SLV_DWIDTH         : integer            := 32
	);
	port (
		-- Proc control ports
		PROC_Clk        : in  std_logic;
		PROC_Rst        : in  std_logic;
		-- BEGIN GENERATE LOOP
		PROC_Hwt_Rst_0    : out std_logic;
		PROC_Hwt_Rst_1    : out std_logic;
		PROC_Hwt_Rst_2    : out std_logic;
		PROC_Hwt_Rst_3    : out std_logic;
		PROC_Hwt_Rst_4    : out std_logic;
		PROC_Hwt_Rst_5    : out std_logic;
		PROC_Hwt_Rst_6    : out std_logic;
		PROC_Hwt_Rst_7    : out std_logic;
		-- END GENERATE LOOP
		PROC_Sys_Rst    : out std_logic;
		PROC_Pgf_Int    : out std_logic;

		-- MMU related ports
		MMU_Pgf         : in  std_logic;
		MMU_Fault_Addr  : in  std_logic_vector(31 downto 0);
		MMU_Retry       : out std_logic;
		MMU_Pgd         : out std_logic_vector(31 downto 0);
		MMU_Tlb_Hits    : in  std_logic_vector(31 downto 0);
		MMU_Tlb_Misses  : in  std_logic_vector(31 downto 0);

		-- Bus protocol ports, do not add to or delete
		S_AXI_ACLK      : in  std_logic;
		S_AXI_ARESETN   : in  std_logic;
		S_AXI_AWADDR    : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWVALID   : in  std_logic;
		S_AXI_WDATA     : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB     : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID    : in  std_logic;
		S_AXI_BREADY    : in  std_logic;
		S_AXI_ARADDR    : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARVALID   : in  std_logic;
		S_AXI_RREADY    : in  std_logic;
		S_AXI_ARREADY   : out std_logic;
		S_AXI_RDATA     : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP     : out std_logic_vector(1 downto 0);
		S_AXI_RVALID    : out std_logic;
		S_AXI_WREADY    : out std_logic;
		S_AXI_BRESP     : out std_logic_vector(1 downto 0);
		S_AXI_BVALID    : out std_logic;
		S_AXI_AWREADY   : out std_logic
	);

	attribute MAX_FANOUT   : string;
	attribute SIGIS        : string;

	attribute MAX_FANOUT of S_AXI_ACLK      : signal is "10000";
	attribute MAX_FANOUT of S_AXI_ARESETN   : signal is "10000";
	
	attribute SIGIS of S_AXI_ACLK      : signal is "Clk";
	attribute SIGIS of PROC_Clk        : signal is "Clk";
	attribute SIGIS of S_AXI_ARESETN   : signal is "Rst";
	attribute SIGIS of PROC_Rst        : signal is "Rst";
	-- BEGIN GENERATE LOOP
	attribute SIGIS of PROC_Hwt_Rst_0  : signal is "Rst";
	attribute SIGIS of PROC_Hwt_Rst_1  : signal is "Rst";
	attribute SIGIS of PROC_Hwt_Rst_2  : signal is "Rst";
	attribute SIGIS of PROC_Hwt_Rst_3  : signal is "Rst";
	attribute SIGIS of PROC_Hwt_Rst_4  : signal is "Rst";
	attribute SIGIS of PROC_Hwt_Rst_5  : signal is "Rst";
	attribute SIGIS of PROC_Hwt_Rst_6  : signal is "Rst";
	attribute SIGIS of PROC_Hwt_Rst_7  : signal is "Rst";
	-- END GENERATE LOOP
	attribute SIGIS of PROC_Sys_Rst    : signal is "Rst";
	attribute SIGIS of PROC_Pgf_Int    : signal is "Intr_Level_High";
end entity reconos_proc_control;


architecture implementation of reconos_proc_control is

	constant USER_SLV_DWIDTH   : integer   := C_S_AXI_DATA_WIDTH;
	constant IPIF_SLV_DWIDTH   : integer   := C_S_AXI_DATA_WIDTH;

	constant ZERO_ADDR_PAD       : std_logic_vector(0 to 31)   := (others => '0');
	constant USER_SLV_BASEADDR   : std_logic_vector            := C_BASEADDR;
	constant USER_SLV_HIGHADDR   : std_logic_vector            := C_HIGHADDR;

	constant IPIF_ARD_ADDR_RANGE_ARRAY   : SLV64_ARRAY_TYPE   := 
		(
			ZERO_ADDR_PAD & USER_SLV_BASEADDR,  -- user logic slave space base address
			ZERO_ADDR_PAD & USER_SLV_HIGHADDR   -- user logic slave space high address
		);

	constant USER_SLV_NUM_REG   : integer   := C_NUM_HWTS / C_SLV_DWIDTH + 7;
	constant USER_NUM_REG       : integer   := USER_SLV_NUM_REG;
	constant TOTAL_IPIF_CE      : integer   := USER_NUM_REG;

	constant IPIF_ARD_NUM_CE_ARRAY   : INTEGER_ARRAY_TYPE   := 
		(
			0  => (USER_SLV_NUM_REG)            -- number of ce for user logic slave space
		);

	-- Index for CS/CE
	constant USER_SLV_CS_INDEX   : integer   := 0;
	constant USER_SLV_CE_INDEX   : integer   := calc_start_ce_index(IPIF_ARD_NUM_CE_ARRAY, USER_SLV_CS_INDEX);

	constant USER_CE_INDEX       : integer   := USER_SLV_CE_INDEX;

	-- IP Interconnect (IPIC) signal declarations
	signal ipif_Bus2IP_Clk      : std_logic;
	signal ipif_Bus2IP_Resetn   : std_logic;
	signal ipif_Bus2IP_Addr     : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal ipif_Bus2IP_RNW      : std_logic;
	signal ipif_Bus2IP_BE       : std_logic_vector(IPIF_SLV_DWIDTH/8-1 downto 0);
	signal ipif_Bus2IP_CS       : std_logic_vector((IPIF_ARD_ADDR_RANGE_ARRAY'LENGTH)/2-1 downto 0);
	signal ipif_Bus2IP_RdCE     : std_logic_vector(calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1 downto 0);
	signal ipif_Bus2IP_WrCE     : std_logic_vector(calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1 downto 0);
	signal ipif_Bus2IP_Data     : std_logic_vector(IPIF_SLV_DWIDTH-1 downto 0);
	signal ipif_IP2Bus_WrAck    : std_logic;
	signal ipif_IP2Bus_RdAck    : std_logic;
	signal ipif_IP2Bus_Error    : std_logic;
	signal ipif_IP2Bus_Data     : std_logic_vector(IPIF_SLV_DWIDTH-1 downto 0);
	signal user_Bus2IP_RdCE     : std_logic_vector(USER_NUM_REG-1 downto 0);
	signal user_Bus2IP_WrCE     : std_logic_vector(USER_NUM_REG-1 downto 0);
	signal user_IP2Bus_Data     : std_logic_vector(USER_SLV_DWIDTH-1 downto 0);
	signal user_IP2Bus_RdAck    : std_logic;
	signal user_IP2Bus_WrAck    : std_logic;
	signal user_IP2Bus_Error    : std_logic;

	signal hwt_rst : std_logic_vector(C_NUM_HWTS - 1 downto 0);

begin

	AXI_LITE_IPIF_I : entity axi_lite_ipif_v1_01_a.axi_lite_ipif
		generic map (
			C_S_AXI_DATA_WIDTH       => IPIF_SLV_DWIDTH,
			C_S_AXI_ADDR_WIDTH       => C_S_AXI_ADDR_WIDTH,
			C_S_AXI_MIN_SIZE         => C_S_AXI_MIN_SIZE,
			C_USE_WSTRB              => C_USE_WSTRB,
			C_DPHASE_TIMEOUT         => C_DPHASE_TIMEOUT,
			C_ARD_ADDR_RANGE_ARRAY   => IPIF_ARD_ADDR_RANGE_ARRAY,
			C_ARD_NUM_CE_ARRAY       => IPIF_ARD_NUM_CE_ARRAY,
			C_FAMILY                 => C_FAMILY
		)
		port map (
			S_AXI_ACLK      => S_AXI_ACLK,
			S_AXI_ARESETN   => S_AXI_ARESETN,
			S_AXI_AWADDR    => S_AXI_AWADDR,
			S_AXI_AWVALID   => S_AXI_AWVALID,
			S_AXI_WDATA     => S_AXI_WDATA,
			S_AXI_WSTRB     => S_AXI_WSTRB,
			S_AXI_WVALID    => S_AXI_WVALID,
			S_AXI_BREADY    => S_AXI_BREADY,
			S_AXI_ARADDR    => S_AXI_ARADDR,
			S_AXI_ARVALID   => S_AXI_ARVALID,
			S_AXI_RREADY    => S_AXI_RREADY,
			S_AXI_ARREADY   => S_AXI_ARREADY,
			S_AXI_RDATA     => S_AXI_RDATA,
			S_AXI_RRESP     => S_AXI_RRESP,
			S_AXI_RVALID    => S_AXI_RVALID,
			S_AXI_WREADY    => S_AXI_WREADY,
			S_AXI_BRESP     => S_AXI_BRESP,
			S_AXI_BVALID    => S_AXI_BVALID,
			S_AXI_AWREADY   => S_AXI_AWREADY,
			Bus2IP_Clk      => ipif_Bus2IP_Clk,
			Bus2IP_Resetn   => ipif_Bus2IP_Resetn,
			Bus2IP_Addr     => ipif_Bus2IP_Addr,
			Bus2IP_RNW      => ipif_Bus2IP_RNW,
			Bus2IP_BE       => ipif_Bus2IP_BE,
			Bus2IP_CS       => ipif_Bus2IP_CS,
			Bus2IP_RdCE     => ipif_Bus2IP_RdCE,
			Bus2IP_WrCE     => ipif_Bus2IP_WrCE,
			Bus2IP_Data     => ipif_Bus2IP_Data,
			IP2Bus_WrAck    => ipif_IP2Bus_WrAck,
			IP2Bus_RdAck    => ipif_IP2Bus_RdAck,
			IP2Bus_Error    => ipif_IP2Bus_Error,
			IP2Bus_Data     => ipif_IP2Bus_Data
		);

	USER_LOGIC_I : entity reconos_proc_control_v1_00_a.user_logic
		generic map (
			-- Proc Control parameters
			C_NUM_HWTS   => C_NUM_HWTS,
		
			-- Bus protocol parameters
			C_NUM_REG      => USER_NUM_REG,
			C_SLV_DWIDTH   => USER_SLV_DWIDTH
		)
		port map (
			-- Proc Control ports
			PROC_Clk     => PROC_Clk,
			PROC_Rst     => not PROC_Rst,
			PROC_Hwt_Rst => hwt_rst,
			PROC_Sys_Rst => PROC_Sys_Rst,
			PROC_Pgf_Int => PROC_Pgf_Int,

			-- MMU related ports
			MMU_Pgf        => MMU_Pgf,
			MMU_Fault_Addr => MMU_Fault_Addr,
			MMU_Retry      => MMU_Retry,
			MMU_Pgd        => MMU_Pgd,
			MMU_Tlb_Hits   => MMU_Tlb_Hits,
			MMU_Tlb_Misses => MMU_Tlb_Misses,

		
			-- Bus protocol ports
			Bus2IP_Clk      => ipif_Bus2IP_Clk,
			Bus2IP_Resetn   => ipif_Bus2IP_Resetn,
			Bus2IP_Data     => ipif_Bus2IP_Data,
			Bus2IP_BE       => ipif_Bus2IP_BE,
			Bus2IP_RdCE     => user_Bus2IP_RdCE,
			Bus2IP_WrCE     => user_Bus2IP_WrCE,
			IP2Bus_Data     => user_IP2Bus_Data,
			IP2Bus_RdAck    => user_IP2Bus_RdAck,
			IP2Bus_WrAck    => user_IP2Bus_WrAck,
			IP2Bus_Error    => user_IP2Bus_Error
		);

	-- connect internal signals
	ipif_IP2Bus_Data <= user_IP2Bus_Data;
	ipif_IP2Bus_WrAck <= user_IP2Bus_WrAck;
	ipif_IP2Bus_RdAck <= user_IP2Bus_RdAck;
	ipif_IP2Bus_Error <= user_IP2Bus_Error;

	user_Bus2IP_RdCE <= ipif_Bus2IP_RdCE(USER_NUM_REG-1 downto 0);
	user_Bus2IP_WrCE <= ipif_Bus2IP_WrCE(USER_NUM_REG-1 downto 0);

	-- BEGIN GENERATE LOOP
	PROC_Hwt_Rst_0 <= hwt_rst(0);
	PROC_Hwt_Rst_1 <= hwt_rst(1);
	PROC_Hwt_Rst_2 <= hwt_rst(2);
	PROC_Hwt_Rst_3 <= hwt_rst(3);
	PROC_Hwt_Rst_4 <= hwt_rst(4);
	PROC_Hwt_Rst_5 <= hwt_rst(5);
	PROC_Hwt_Rst_6 <= hwt_rst(6);
	PROC_Hwt_Rst_7 <= hwt_rst(7);
	-- END GENERATE LOOP

end implementation;
