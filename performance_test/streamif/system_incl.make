#################################################################
# Makefile generated by Xilinx Platform Studio 
# Project:/home/sandbox/reconos_streamif_test/performance_test/streamif/system.xmp
#
# WARNING : This file will be re-generated every time a command
# to run a make target is invoked. So, any changes made to this  
# file manually, will be lost when make is invoked next. 
#################################################################

XILINX_EDK_DIR = /mnt/ise/ISE_DS/EDK

SYSTEM = system

MHSFILE = system.mhs

PCWPRJFILE = data/ps7_system_prj.xml

FPGA_ARCH = zynq

DEVICE = xc7z020clg484-1

INTSTYLE = default

XPS_HDL_LANG = vhdl
GLOBAL_SEARCHPATHOPT = 
PROJECT_SEARCHPATHOPT = 

SEARCHPATHOPT = $(PROJECT_SEARCHPATHOPT) $(GLOBAL_SEARCHPATHOPT)

SUBMODULE_OPT = 

PLATGEN_OPTIONS = -p $(DEVICE) -lang $(XPS_HDL_LANG) -intstyle $(INTSTYLE) $(SEARCHPATHOPT) $(SUBMODULE_OPT) -msg __xps/ise/xmsgprops.lst

OBSERVE_PAR_OPTIONS = -error yes

MICROBLAZE_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/microblaze/mb_bootloop.elf
MICROBLAZE_BOOTLOOP_LE = $(XILINX_EDK_DIR)/sw/lib/microblaze/mb_bootloop_le.elf
PPC405_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/ppc405/ppc_bootloop.elf
PPC440_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/ppc440/ppc440_bootloop.elf
BOOTLOOP_DIR = bootloops

BRAMINIT_ELF_IMP_FILES =
BRAMINIT_ELF_IMP_FILE_ARGS =

BRAMINIT_ELF_SIM_FILES =
BRAMINIT_ELF_SIM_FILE_ARGS =

SIM_CMD = xterm -e ./isim_system

BEHAVIORAL_SIM_SCRIPT = simulation/behavioral/$(SYSTEM)_setup.tcl

STRUCTURAL_SIM_SCRIPT = simulation/structural/$(SYSTEM)_setup.tcl

TIMING_SIM_SCRIPT = simulation/timing/$(SYSTEM)_setup.tcl

DEFAULT_SIM_SCRIPT = $(BEHAVIORAL_SIM_SCRIPT)

SIMGEN_OPTIONS = -p $(DEVICE) -lang $(XPS_HDL_LANG) -intstyle $(INTSTYLE) $(SEARCHPATHOPT) $(BRAMINIT_ELF_SIM_FILE_ARGS) -msg __xps/ise/xmsgprops.lst -s isim


CORE_STATE_DEVELOPMENT_FILES = 

WRAPPER_NGC_FILES = implementation/system_axi_hwt_wrapper.ngc \
implementation/system_axi_acp_wrapper.ngc \
implementation/system_processing_system7_0_wrapper.ngc \
implementation/system_hwt_static_0_wrapper.ngc \
implementation/system_streamif_s2mem_0_wrapper.ngc \
implementation/system_reconos_osif_fifo_0_sw2hw_wrapper.ngc \
implementation/system_reconos_osif_fifo_0_hw2sw_wrapper.ngc \
implementation/system_reconos_memif_fifo_0_hwt2mem_wrapper.ngc \
implementation/system_reconos_memif_fifo_0_mem2hwt_wrapper.ngc \
implementation/system_hwt_static_1_wrapper.ngc \
implementation/system_streamif_s2mem_1_wrapper.ngc \
implementation/system_reconos_osif_fifo_1_sw2hw_wrapper.ngc \
implementation/system_reconos_osif_fifo_1_hw2sw_wrapper.ngc \
implementation/system_reconos_memif_fifo_1_hwt2mem_wrapper.ngc \
implementation/system_reconos_memif_fifo_1_mem2hwt_wrapper.ngc \
implementation/system_hwt_static_2_wrapper.ngc \
implementation/system_streamif_s2mem_2_wrapper.ngc \
implementation/system_reconos_osif_fifo_2_sw2hw_wrapper.ngc \
implementation/system_reconos_osif_fifo_2_hw2sw_wrapper.ngc \
implementation/system_reconos_memif_fifo_2_hwt2mem_wrapper.ngc \
implementation/system_reconos_memif_fifo_2_mem2hwt_wrapper.ngc \
implementation/system_hwt_static_3_wrapper.ngc \
implementation/system_streamif_s2mem_3_wrapper.ngc \
implementation/system_reconos_osif_fifo_3_sw2hw_wrapper.ngc \
implementation/system_reconos_osif_fifo_3_hw2sw_wrapper.ngc \
implementation/system_reconos_memif_fifo_3_hwt2mem_wrapper.ngc \
implementation/system_reconos_memif_fifo_3_mem2hwt_wrapper.ngc \
implementation/system_hwt_static_4_wrapper.ngc \
implementation/system_streamif_s2mem_4_wrapper.ngc \
implementation/system_reconos_osif_fifo_4_sw2hw_wrapper.ngc \
implementation/system_reconos_osif_fifo_4_hw2sw_wrapper.ngc \
implementation/system_reconos_memif_fifo_4_hwt2mem_wrapper.ngc \
implementation/system_reconos_memif_fifo_4_mem2hwt_wrapper.ngc \
implementation/system_hwt_static_5_wrapper.ngc \
implementation/system_streamif_s2mem_5_wrapper.ngc \
implementation/system_reconos_osif_fifo_5_sw2hw_wrapper.ngc \
implementation/system_reconos_osif_fifo_5_hw2sw_wrapper.ngc \
implementation/system_reconos_memif_fifo_5_hwt2mem_wrapper.ngc \
implementation/system_reconos_memif_fifo_5_mem2hwt_wrapper.ngc \
implementation/system_hwt_static_6_wrapper.ngc \
implementation/system_streamif_s2mem_6_wrapper.ngc \
implementation/system_reconos_osif_fifo_6_sw2hw_wrapper.ngc \
implementation/system_reconos_osif_fifo_6_hw2sw_wrapper.ngc \
implementation/system_reconos_memif_fifo_6_hwt2mem_wrapper.ngc \
implementation/system_reconos_memif_fifo_6_mem2hwt_wrapper.ngc \
implementation/system_hwt_static_7_wrapper.ngc \
implementation/system_streamif_s2mem_7_wrapper.ngc \
implementation/system_reconos_osif_fifo_7_sw2hw_wrapper.ngc \
implementation/system_reconos_osif_fifo_7_hw2sw_wrapper.ngc \
implementation/system_reconos_memif_fifo_7_hwt2mem_wrapper.ngc \
implementation/system_reconos_memif_fifo_7_mem2hwt_wrapper.ngc \
implementation/system_reconos_osif_0_wrapper.ngc \
implementation/system_reconos_osif_intc_0_wrapper.ngc \
implementation/system_reconos_proc_control_0_wrapper.ngc \
implementation/system_reconos_memif_arbiter_0_wrapper.ngc \
implementation/system_reconos_memif_burst_converter_0_wrapper.ngc \
implementation/system_reconos_memif_mmu_0_wrapper.ngc \
implementation/system_reconos_memif_memory_controller_0_wrapper.ngc \
implementation/system_streamif_ctrl_0_wrapper.ngc \
implementation/system_axi_hp0_wrapper.ngc \
implementation/system_axi_hp1_wrapper.ngc \
implementation/system_axi_hp2_wrapper.ngc \
implementation/system_axi_hp3_wrapper.ngc

POSTSYN_NETLIST = implementation/$(SYSTEM).ngc

SYSTEM_BIT = implementation/$(SYSTEM).bit

DOWNLOAD_BIT = implementation/download.bit

SYSTEM_ACE = implementation/$(SYSTEM).ace

UCF_FILE = data/system.ucf

BMM_FILE = implementation/$(SYSTEM).bmm

BITGEN_UT_FILE = etc/bitgen.ut

XFLOW_OPT_FILE = etc/fast_runtime.opt
XFLOW_DEPENDENCY = __xps/xpsxflow.opt $(XFLOW_OPT_FILE)

XPLORER_DEPENDENCY = __xps/xplorer.opt
XPLORER_OPTIONS = -p $(DEVICE) -uc $(SYSTEM).ucf -bm $(SYSTEM).bmm -max_runs 7

FPGA_IMP_DEPENDENCY = $(BMM_FILE) $(POSTSYN_NETLIST) $(UCF_FILE) $(XFLOW_DEPENDENCY)

SDK_EXPORT_DIR = SDK/SDK_Export/hw
SYSTEM_HW_HANDOFF = $(SDK_EXPORT_DIR)/$(SYSTEM).xml
SYSTEM_HW_HANDOFF_BIT = $(SDK_EXPORT_DIR)/$(SYSTEM).bit
SYSTEM_HW_HANDOFF_DEP = $(SYSTEM_HW_HANDOFF)
