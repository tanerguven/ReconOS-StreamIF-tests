library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

library reconos_v3_01_a;
use reconos_v3_01_a.reconos_pkg.all;

entity hwt_performance_test_memif is
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

		DEBUG_DATA : out std_logic_vector(5 downto 0)
	);

	attribute SIGIS   : string;

	attribute SIGIS of HWT_Clk   : signal is "Clk";
	attribute SIGIS of HWT_Rst   : signal is "Rst";

end entity hwt_performance_test_memif;

architecture implementation of hwt_performance_test_memif is
	-- just for simpler use
	signal clk   : std_logic;
	signal rst   : std_logic;

	type STATE_TYPE is (
      STATE_GET_INDATA_ADDRS,
      STATE_READ_INDATA,
      STATE_RW_READ,
      STATE_RW_WRITE,
      STATE_RW_END,
      STATE_RW_ACK,
      STATE_THREAD_EXIT);


	constant C_LOCAL_RAM_SIZE          : integer := 512;
	constant C_LOCAL_RAM_ADDRESS_WIDTH : integer := clog2(C_LOCAL_RAM_SIZE);
	constant C_LOCAL_RAM_SIZE_IN_BYTES : integer := 4*C_LOCAL_RAM_SIZE;

	type LOCAL_MEMORY_T is array (0 to C_LOCAL_RAM_SIZE-1) of std_logic_vector(31 downto 0);

	signal len      : std_logic_vector(23 downto 0);
	signal state    : STATE_TYPE;
	signal i_osif   : i_osif_t;
	signal o_osif   : o_osif_t;
	signal i_memif  : i_memif_t;
	signal o_memif  : o_memif_t;

	signal i_ram    : i_ram_t;
	signal o_ram    : o_ram_t;

	signal o_RAMAddr_reconos   : std_logic_vector(0 to C_LOCAL_RAM_ADDRESS_WIDTH-1);
	signal o_RAMAddr_reconos_2 : std_logic_vector(0 to 31);
	signal o_RAMData_reconos   : std_logic_vector(0 to 31);
	signal o_RAMWE_reconos     : std_logic;
	signal i_RAMData_reconos   : std_logic_vector(0 to 31);

	constant o_RAMAddr_max : std_logic_vector(0 to C_LOCAL_RAM_ADDRESS_WIDTH-1) := (others=>'1');

	shared variable local_ram : LOCAL_MEMORY_T;


	constant C_INDATA_COUNT		: integer	:= 3;
	signal indata_addrs	: std_logic_vector(31 downto 0);
    signal tmp_word : std_logic_vector(31 downto 0);


	constant C_MBOX_RECV	: std_logic_vector(31 downto 0)	:= x"00000000";
	constant C_MBOX_SEND	: std_logic_vector(31 downto 0)	:= x"00000001";
	signal ignore   : std_logic_vector(31 downto 0);

	signal write_addr	: std_logic_vector(31 downto 0);
	signal read_addr	: std_logic_vector(31 downto 0);

    signal ack : std_logic_vector(31 downto 0);

    signal burst_no : std_logic_vector(14 downto 0);
    signal burst_count : std_logic_vector(14 downto 0);

begin

	clk <= HWT_Clk;
	rst <= HWT_Rst;

    DEBUG_DATA <= (others => '1');


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


	-- os and memory synchronisation state machine
	reconos_fsm: process (clk,rst,o_osif,o_memif) is
		variable done  : boolean;
		variable addr_pos				: integer;
	begin
		if rst = '1' then
			osif_reset(o_osif);
			memif_reset(o_memif);
			ram_reset(o_ram);

            len <= conv_std_logic_vector(C_LOCAL_RAM_SIZE_IN_BYTES,24);

			state <= STATE_GET_INDATA_ADDRS;
			done  := False;
			indata_addrs			<= (others => '0');
			addr_pos				:= C_INDATA_COUNT - 1;

            burst_no <= (others => '0');
            burst_count <= (others => '0');

		elsif rising_edge(clk) then


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
                                write_addr <= tmp_word;
                                addr_pos := addr_pos - 1;
                            when 0 =>
                                read_addr <= tmp_word;
                                burst_no <= (others => '0');
                                state <= STATE_RW_READ;
                            when others =>
                                --
                        end case;
					end if;

				when STATE_RW_READ =>
					memif_read(i_ram,o_ram,i_memif,o_memif,read_addr,X"00000000",len,done);
					if done then
						state <= STATE_RW_WRITE;
					end if;

				when STATE_RW_WRITE =>
					memif_write(i_ram,o_ram,i_memif,o_memif,X"00000000",write_addr,len,done);
					if done then
                        burst_no <= burst_no + 1;
                        read_addr <= read_addr + C_LOCAL_RAM_SIZE_IN_BYTES;
                        write_addr <= write_addr + C_LOCAL_RAM_SIZE_IN_BYTES;
                        state <= STATE_RW_END;
                     end if;

                when STATE_RW_END =>
                    if (burst_no >= burst_count) then
                        state <= STATE_RW_ACK;
                    else
                        state <= STATE_RW_READ;
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
