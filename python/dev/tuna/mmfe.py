from vmm            import VMM
from mmfe8_userRegs import userRegs
from udp            import udp_stuff

import numpy as np

nvmms = 8

class MMFE:

    def __init__(self):
        print
        print "Creating instance of MMFE"
        print 

        self.VMM = []
        for _ in range(nvmms):
            self.VMM.append(VMM())

        self.udp = udp_stuff()
        self.UDP_PORT = 50001
        self.UDP_IP   = ""

        self.vmm_cfg_sel          = np.zeros((32), dtype=int)
        self.readout_runlength    = np.zeros((32), dtype=int)
        self.acq_count_runlength  = np.zeros((32), dtype=int)
        self.acq_hold_runlength   = np.zeros((32), dtype=int)
        self.xadc                 = np.zeros((32), dtype=int)
        self.admux                = np.zeros((32), dtype=int)
        self.control              = np.zeros((32), dtype=int)
        self.ds2411_low           = np.zeros((32), dtype=int)
        self.ds2411_high          = np.zeros((32), dtype=int)
        self.counts_to_acq_reset  = np.zeros((32), dtype=int)
        self.counts_to_acq_hold   = np.zeros((32), dtype=int)
        self.chnlReg              = np.zeros((51), dtype=int)
        self.byteint              = np.zeros((51), dtype=np.uint32)
        self.byteword             = np.zeros((32), dtype=int)
        self.userRegs = userRegs()

        #0x44A100EC  #vmm_global_reset          #reset & vmm_gbl_rst_i & vmm_cfg_en_vec( 7 downto 0)
        #0x44A100EC  #vmm_cfg_sel               #vmm_2display_i(16 downto 12) & mmfeID(11 downto 8) & vmm_readout_i(7 downto 0)
        #0x44A100F0  #cktp_period_dutycycle     #clk_tp_period_cnt(15 downto 0) & clk_tp_dutycycle_cnt(15 downto 0)
        #0x44A100F4  #ReadOut_RunLength         #ext_trigger_in_sel(26)&axi_data_to_use(25)&int_trig(24)&vmm_readout_i(23 downto 16)&pulses(15 downto 0)
        #0x44A10120  #counts_to_acq_reset       #counts_to_acq_reset( 31 downto 0)
        #0x44A10120  #counts_to_acq_hold        #counts_to_hold_acq_reset( 31 downto 0)
        #0x44A100F8  #xadc                      #read
        #0x44A100F8  #admux                     #write
        #0x44A100FC  #was vmm_global_reset      #reset & vmm_gbl_rst_i & vmm_cfg_en_vec( 7 downto 0)
        #0x44A10100  #axi_reg_60( 0)            #original reset
        #0x44A10104,08,0C,00,14                 #user_reg_1 #user_reg_2 #user_reg_3 #user_reg_4         
        #0x44A10104,08,0C,00,14                 #user_reg_1 #user_reg_2 #user_reg_3 #user_reg_4 #user_reg_5
        #0x44A10118  #DS411_low                 #Low
        #0x44A1011C  #DS411_high                #High
        #0x44A10120  #counts_to_acq_reset       #0 to FFFF_FFFF #0=Not Used
        #0x44A10120  #counts_to_hold_acq_reset  #0 to FFFF_FFFF #0=Not Used

