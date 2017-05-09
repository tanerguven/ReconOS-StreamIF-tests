library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

library reconos_v3_01_a;
use reconos_v3_01_a.reconos_pkg.all;

entity hwt_sort_demo is
	port (
		-- OSIF FIFO ports
		OSIF_FIFO_Sw2Hw_Data    : in  std_logic_vector(31 downto 0);
		OSIF_FIFO_Sw2Hw_Fill    : in  std_logic_vector(15 downto 0);
		OSIF_FIFO_Sw2Hw_Empty   : in  std_logic;
		OSIF_FIFO_Sw2Hw_RE      : out std_logic;

		OSIF_FIFO_Hw2Sw_Data    : out std_logic_vector(31 downto 0);
		OSIF_FIFO_Hw2Sw_Rem     : in  std_logic_vector(15 downto 0);
		OSIF_FIFO_Hw2Sw_Full    : in  std_logic;
		OSIF_FIFO_Hw2Sw_WE      : out std_logic;

		-- MEMIF FIFO ports
		MEMIF_FIFO_Hwt2Mem_Data    : out std_logic_vector(31 downto 0);
		MEMIF_FIFO_Hwt2Mem_Rem     : in  std_logic_vector(15 downto 0);
		MEMIF_FIFO_Hwt2Mem_Full    : in  std_logic;
		MEMIF_FIFO_Hwt2Mem_WE      : out std_logic;

		MEMIF_FIFO_Mem2Hwt_Data    : in  std_logic_vector(31 downto 0);
		MEMIF_FIFO_Mem2Hwt_Fill    : in  std_logic_vector(15 downto 0);
		MEMIF_FIFO_Mem2Hwt_Empty   : in  std_logic;
		MEMIF_FIFO_Mem2Hwt_RE      : out std_logic;

		HWT_Clk   : in  std_logic;
		HWT_Rst   : in  std_logic;

		DEBUG_DATA : out std_logic_vector(5 downto 0);


        -- AXIS input
        S_AXIS_TREADY	    : out	std_logic;
		S_AXIS_TDATA	    : in	std_logic_vector(31 downto 0);
        S_AXIS_TSTRB        : in    std_logic_vector(3 downto 0);
		S_AXIS_TLAST	    : in	std_logic;
		S_AXIS_TVALID	    : in	std_logic;
        MM2S_CTRL_Addr      : out	std_logic_vector(31 downto 0);
		MM2S_CTRL_Start     : out	std_logic;
		MM2S_CTRL_Enabled   : out	std_logic;
        MM2S_CTRL_Idle      : in	std_logic;

        -- AXIS output
		M_AXIS_TVALID	    : out	std_logic;
		M_AXIS_TDATA	    : out	std_logic_vector(31 downto 0);
        M_AXIS_TSTRB        : out   std_logic_vector(3 downto 0);
		M_AXIS_TLAST	    : out	std_logic;
		M_AXIS_TREADY	    : in	std_logic;
        S2MM_CTRL_Addr      : out	std_logic_vector(31 downto 0);
		S2MM_CTRL_Start     : out	std_logic;
		S2MM_CTRL_Enabled   : out	std_logic;
        S2MM_CTRL_Idle      : in	std_logic
	);

	attribute SIGIS   : string;

	attribute SIGIS of HWT_Clk   : signal is "Clk";
	attribute SIGIS of HWT_Rst   : signal is "Rst";

end entity hwt_sort_demo;

architecture implementation of hwt_sort_demo is
	-- just for simpler use
	signal clk   : std_logic;
	signal rst   : std_logic;

	type STATE_TYPE is (
      STATE_GET_ADDR2MADDRS,
      STATE_READ_MADDRS,
      STATE_SET_ADDR,
      STATE_START,
      STATE_WAIT,
      STATE_END,
      STATE_ACK,
      STATE_THREAD_EXIT);


	-- The sorting application reads 'C_LOCAL_RAM_SIZE' 32-bit words into the local RAM,
	-- from a given address (send in a message box), sorts them and writes them back into main memory.

	-- IMPORTANT: define size of local RAM here!!!!
	constant C_LOCAL_RAM_SIZE          : integer := 2048;
	constant C_LOCAL_RAM_ADDRESS_WIDTH : integer := clog2(C_LOCAL_RAM_SIZE);
	constant C_LOCAL_RAM_SIZE_IN_BYTES : integer := 4*C_LOCAL_RAM_SIZE;

	type LOCAL_MEMORY_T is array (0 to C_LOCAL_RAM_SIZE-1) of std_logic_vector(31 downto 0);


	--signal addr     : std_logic_vector(31 downto 0);
	--signal addr_write     : std_logic_vector(31 downto 0);

	constant C_MADDRS		: integer	:= 2;
	type MADDR_BOX_TYPE is array(0 to C_MADDRS-1) of std_logic_vector(31 downto 0);
	signal maddrs			: MADDR_BOX_TYPE;
	signal addr2maddrs	: std_logic_vector(31 downto 0);

	signal len      : std_logic_vector(23 downto 0);
	signal state    : STATE_TYPE;
	signal i_osif   : i_osif_t;
	signal o_osif   : o_osif_t;
	signal i_memif  : i_memif_t;
	signal o_memif  : o_memif_t;
	signal i_ram    : i_ram_t;
	signal o_ram    : o_ram_t;

	signal o_RAMAddr_sorter : std_logic_vector(0 to C_LOCAL_RAM_ADDRESS_WIDTH-1) := (others=>'0');
	signal o_RAMData_sorter : std_logic_vector(0 to 31) := (others=>'0');
	signal o_RAMWE_sorter   : std_logic := '0';
	signal i_RAMData_sorter : std_logic_vector(0 to 31);

	signal o_RAMAddr_reconos   : std_logic_vector(0 to C_LOCAL_RAM_ADDRESS_WIDTH-1);
	signal o_RAMAddr_reconos_2 : std_logic_vector(0 to 31);
	signal o_RAMData_reconos   : std_logic_vector(0 to 31);
	signal o_RAMWE_reconos     : std_logic;
	signal i_RAMData_reconos   : std_logic_vector(0 to 31);

	constant o_RAMAddr_max : std_logic_vector(0 to C_LOCAL_RAM_ADDRESS_WIDTH-1) := (others=>'1');

	shared variable local_ram : LOCAL_MEMORY_T;

	constant C_MBOX_RECV	: std_logic_vector(31 downto 0)	:= x"00000000";
	constant C_MBOX_SEND	: std_logic_vector(31 downto 0)	:= x"00000001";
	signal ignore   : std_logic_vector(31 downto 0);

	signal s2mm_addr	: std_logic_vector(31 downto 0);
	signal mm2s_addr	: std_logic_vector(31 downto 0);

    signal start : std_logic;
    signal mm2s_idle : std_logic;
    signal s2mm_idle : std_logic;

    signal burst_addr : std_logic_vector(31 downto 0);

    signal ack : std_logic_vector(31 downto 0);

	constant C_BURST_COUNT  : integer := 4096;
    --constant C_BURST_COUNT  : integer := 1024;

begin
	DEBUG_DATA(5) <= '1' when state = STATE_GET_ADDR2MADDRS else '0';
	DEBUG_DATA(4) <= '1' when state = STATE_READ_MADDRS else '0';
	DEBUG_DATA(3) <= '1' when state = STATE_SET_ADDR else '0';
	DEBUG_DATA(2) <= '1' when state = STATE_WAIT else '0';
	DEBUG_DATA(1) <= '1' when state = STATE_ACK else '0';
	DEBUG_DATA(0) <= '1' when state = STATE_THREAD_EXIT else '0';

	clk <= HWT_Clk;
	rst <= HWT_Rst;


	-- local dual-port RAM
	local_ram_ctrl_1 : process (clk) is
	begin
		if (rising_edge(clk)) then
			if (o_RAMWE_reconos = '1') then
				local_ram(conv_integer(unsigned(o_RAMAddr_reconos))) := o_RAMData_reconos;
			else
				i_RAMData_reconos <= local_ram(conv_integer(unsigned(o_RAMAddr_reconos)));
			end if;
		end if;
	end process;

	local_ram_ctrl_2 : process (clk) is
	begin
		if (rising_edge(clk)) then
			if (o_RAMWE_sorter = '1') then
				local_ram(conv_integer(unsigned(o_RAMAddr_sorter))) := o_RAMData_sorter;
			else
				i_RAMData_sorter <= local_ram(conv_integer(unsigned(o_RAMAddr_sorter)));
			end if;
		end if;
	end process;


	-- ReconOS initilization
	osif_setup (
		i_osif,
		o_osif,
		OSIF_FIFO_Sw2Hw_Data,
		OSIF_FIFO_Sw2Hw_Fill,
		OSIF_FIFO_Sw2Hw_Empty,
		OSIF_FIFO_Hw2Sw_Rem,
		OSIF_FIFO_Hw2Sw_Full,
		OSIF_FIFO_Sw2Hw_RE,
		OSIF_FIFO_Hw2Sw_Data,
		OSIF_FIFO_Hw2Sw_WE
	);

	memif_setup (
		i_memif,
		o_memif,
		MEMIF_FIFO_Mem2Hwt_Data,
		MEMIF_FIFO_Mem2Hwt_Fill,
		MEMIF_FIFO_Mem2Hwt_Empty,
		MEMIF_FIFO_Hwt2Mem_Rem,
		MEMIF_FIFO_Hwt2Mem_Full,
		MEMIF_FIFO_Mem2Hwt_RE,
		MEMIF_FIFO_Hwt2Mem_Data,
		MEMIF_FIFO_Hwt2Mem_WE
	);

	ram_setup (
		i_ram,
		o_ram,
		o_RAMAddr_reconos_2,
		o_RAMWE_reconos,
		o_RAMData_reconos,
		i_RAMData_reconos
	);

	o_RAMAddr_reconos(0 to C_LOCAL_RAM_ADDRESS_WIDTH-1) <= o_RAMAddr_reconos_2((32-C_LOCAL_RAM_ADDRESS_WIDTH) to 31);


    -- streamif signals
    S_AXIS_TREADY <= M_AXIS_TREADY;
    M_AXIS_TVALID <= S_AXIS_TVALID;
    M_AXIS_TDATA <= S_AXIS_TDATA;
    M_AXIS_TSTRB <= (others => '0');
    M_AXIS_TLAST <= S_AXIS_TLAST;

    MM2S_CTRL_Addr <= mm2s_addr;
    MM2S_CTRL_Start <= start;
	MM2S_CTRL_Enabled <= '1';
    mm2s_idle <= MM2S_CTRL_Idle;

    S2MM_CTRL_Addr <= s2mm_addr;
	S2MM_CTRL_Start <= start;
	S2MM_CTRL_Enabled <= '1';
    s2mm_idle <= S2MM_CTRL_Idle;


	-- os and memory synchronisation state machine
	reconos_fsm: process (clk,rst,o_osif,o_memif,o_ram) is
		variable done  : boolean;
		variable addr_pos				: integer;
	begin
		if rst = '1' then
			osif_reset(o_osif);
			memif_reset(o_memif);
			ram_reset(o_ram);
			state <= STATE_GET_ADDR2MADDRS;
			done  := False;
			addr2maddrs			<= (others => '0');
			addr_pos				:= C_MADDRS - 1;
            len <= conv_std_logic_vector(C_LOCAL_RAM_SIZE_IN_BYTES,24);
			--len <= (others => '0');
            s2mm_addr <= (others => '0');
            mm2s_addr <= (others => '0');
            start <= '0';
		elsif rising_edge(clk) then
			case state is

				-- Get address pointing to the addresses pointing to the 3 matrixes via FSL.
				when STATE_GET_ADDR2MADDRS =>
					osif_mbox_get(i_osif, o_osif, C_MBOX_RECV, addr2maddrs, done);
					if (done) then
						if (addr2maddrs = x"FFFFFFFF") then
							state <= STATE_THREAD_EXIT;
						else
							addr2maddrs <= addr2maddrs(31 downto 2) & "00";
							addr_pos := C_MADDRS - 1;
							state <= STATE_READ_MADDRS;
						end if;
					end if;

				-- Read addresses pointing to input matrixes A, B and output matrix C from main memory.
				when STATE_READ_MADDRS =>
					memif_read_word(i_memif, o_memif, addr2maddrs, maddrs(addr_pos), done);
					if done then
						if (addr_pos = 0) then
                            state <= STATE_SET_ADDR;
                            burst_addr <= (others => '0');
						else
							addr_pos := addr_pos - 1;
							addr2maddrs <= conv_std_logic_vector(unsigned(addr2maddrs) + 4, 32);
						end if;
					end if;


                when STATE_SET_ADDR =>
                    -- (burst_addr * 256 * 4);
                    mm2s_addr <= maddrs(0) + burst_addr;
                    s2mm_addr <= maddrs(1) + burst_addr;
                    start <= '0';
                    state <= STATE_START;

                when STATE_START =>
                    start <= '1';
                    if (s2mm_idle='0' and mm2s_idle='0') then
                      state <= STATE_WAIT;
                    end if;

				when STATE_WAIT =>
                    if (s2mm_idle='1' and mm2s_idle='1') then
                        burst_addr <= burst_addr + 1024;
                        state <= STATE_END;
                    end if;

                when STATE_END =>
                    if (burst_addr = (C_BURST_COUNT*1024)) then
                        state <= STATE_ACK;
                    else
                        state <= STATE_SET_ADDR;
                    end if;

				when STATE_ACK =>
					osif_mbox_put(i_osif, o_osif, C_MBOX_SEND, ack, ignore, done);
					if done then state <= STATE_GET_ADDR2MADDRS; end if;

				-- thread exit
				when STATE_THREAD_EXIT =>
					osif_thread_exit(i_osif,o_osif);

			end case;
		end if;
	end process;

end architecture;
