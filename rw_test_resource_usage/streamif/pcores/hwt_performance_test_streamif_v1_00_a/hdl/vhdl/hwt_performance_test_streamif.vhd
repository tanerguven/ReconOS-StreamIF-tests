library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

library reconos_v3_01_a;
use reconos_v3_01_a.reconos_pkg.all;

entity hwt_performance_test_streamif is
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
        MM2S_CTRL_Last      : in	std_logic;

        -- AXIS output
		M_AXIS_TVALID	    : out	std_logic;
		M_AXIS_TDATA	    : out	std_logic_vector(31 downto 0);
        M_AXIS_TSTRB        : out   std_logic_vector(3 downto 0);
		M_AXIS_TLAST	    : out	std_logic;
		M_AXIS_TREADY	    : in	std_logic;
        S2MM_CTRL_Addr      : out	std_logic_vector(31 downto 0);
		S2MM_CTRL_Start     : out	std_logic;
		S2MM_CTRL_Enabled   : out	std_logic;
        S2MM_CTRL_Idle      : in	std_logic;
        S2MM_CTRL_Last      : in    std_logic
	);

	attribute SIGIS   : string;

	attribute SIGIS of HWT_Clk   : signal is "Clk";
	attribute SIGIS of HWT_Rst   : signal is "Rst";

end entity hwt_performance_test_streamif;

architecture implementation of hwt_performance_test_streamif is
	-- just for simpler use
	signal clk   : std_logic;
	signal rst   : std_logic;

	type STATE_TYPE is (
      STATE_GET_INDATA_ADDRS,
      STATE_READ_INDATA,

      STATE_RW_START,
      STATE_RW_WAIT,
      STATE_RW_END,
      STATE_RW_ACK,

      STATE_THREAD_EXIT);


	constant C_INDATA_COUNT		: integer	:= 3;
	signal indata_addrs	: std_logic_vector(31 downto 0);
    signal tmp_word : std_logic_vector(31 downto 0);

	signal state    : STATE_TYPE;
	signal i_osif   : i_osif_t;
	signal o_osif   : o_osif_t;
	signal i_memif  : i_memif_t;
	signal o_memif  : o_memif_t;


	constant C_MBOX_RECV	: std_logic_vector(31 downto 0)	:= x"00000000";
	constant C_MBOX_SEND	: std_logic_vector(31 downto 0)	:= x"00000001";
	signal ignore   : std_logic_vector(31 downto 0);

	signal s2mm_addr	: std_logic_vector(31 downto 0);
	signal mm2s_addr	: std_logic_vector(31 downto 0);

    signal mm2s_idle : std_logic;
    signal s2mm_idle : std_logic;

    signal ack : std_logic_vector(31 downto 0);

    signal burst_no : std_logic_vector(14 downto 0);
    signal burst_count : std_logic_vector(14 downto 0);


begin

	clk <= HWT_Clk;
	rst <= HWT_Rst;

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


    MM2S_CTRL_Addr <= mm2s_addr;
    MM2S_CTRL_Enabled <= '1';
    mm2s_idle <= MM2S_CTRL_Idle;

    S2MM_CTRL_Addr <= s2mm_addr;
    S2MM_CTRL_Enabled <= '1';
    s2mm_idle <= S2MM_CTRL_Idle;


	-- os and memory synchronisation state machine
	reconos_fsm: process (clk,rst,o_osif,o_memif) is
		variable done  : boolean;
		variable addr_pos				: integer;
	begin
		if rst = '1' then
			osif_reset(o_osif);
			memif_reset(o_memif);
			state <= STATE_GET_INDATA_ADDRS;
			done  := False;
			indata_addrs			<= (others => '0');
			addr_pos				:= C_INDATA_COUNT - 1;
            s2mm_addr <= (others => '0');
            mm2s_addr <= (others => '0');
            S2MM_CTRL_Start <= '0';
            MM2S_CTRL_Start <= '0';

            burst_no <= (others => '0');
            burst_count <= (others => '0');

		elsif rising_edge(clk) then

            S_AXIS_TREADY <= M_AXIS_TREADY;
            M_AXIS_TVALID <= S_AXIS_TVALID;
            M_AXIS_TDATA <= S_AXIS_TDATA;
            M_AXIS_TSTRB <= S_AXIS_TSTRB;
            M_AXIS_TLAST <= S_AXIS_TLAST;

			case state is

				-- Get address pointing to the address array
				when STATE_GET_INDATA_ADDRS =>
					osif_mbox_get(i_osif, o_osif, C_MBOX_RECV, indata_addrs, done);
					if (done) then
						if (indata_addrs = x"FFFFFFFF") then
							state <= STATE_THREAD_EXIT;
						else
							indata_addrs <= indata_addrs(31 downto 2) & "00";
							addr_pos := C_INDATA_COUNT - 1;
							state <= STATE_READ_INDATA;
						end if;
					end if;

				-- Read address array
				when STATE_READ_INDATA =>
					memif_read_word(i_memif, o_memif, indata_addrs, tmp_word, done);
					if done then
                        indata_addrs <= indata_addrs + 4;
                        case addr_pos is
                            when 2 =>
                                burst_count <= tmp_word(14 downto 0);
                                addr_pos := addr_pos - 1;
                            when 1 =>
                                s2mm_addr <= tmp_word;
                                addr_pos := addr_pos - 1;
                            when 0 =>

                                burst_no <= (others => '0');
                                S2MM_CTRL_Start <= '0';
                                MM2S_CTRL_Start <= '0';

                                mm2s_addr <= tmp_word;
                                state <= STATE_RW_START;
                            when others =>
                                --
                        end case;
					end if;

                -- STATE_RW

                when STATE_RW_START =>
                    S2MM_CTRL_Start <= '1';
                    MM2S_CTRL_Start <= '1';
                    if (s2mm_idle='0' and mm2s_idle='0') then
                      state <= STATE_RW_WAIT;
                    end if;

				when STATE_RW_WAIT =>
                    S2MM_CTRL_Start <= '0';
                    MM2S_CTRL_Start <= '0';
                    if (s2mm_idle='1' and mm2s_idle='1') then
                        burst_no <= burst_no + 1;
                        state <= STATE_RW_END;
                    end if;

                when STATE_RW_END =>
                    if (burst_no >= burst_count) then
                        state <= STATE_RW_ACK;
                    else
                        mm2s_addr <= mm2s_addr + 1024;
                        s2mm_addr <= s2mm_addr + 1024;
                        state <= STATE_RW_START;
                    end if;

				when STATE_RW_ACK =>
					osif_mbox_put(i_osif, o_osif, C_MBOX_SEND, ack, ignore, done);
					if done then
                        state <= STATE_GET_INDATA_ADDRS;
                    end if;

				when STATE_THREAD_EXIT =>
					osif_thread_exit(i_osif,o_osif);

			end case;
		end if;
	end process;

end architecture;
