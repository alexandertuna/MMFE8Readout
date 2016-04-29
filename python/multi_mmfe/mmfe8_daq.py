import os
import time
import binstr
import numpy as np

from vmm     import VMM
from udp     import udp_stuff
from helpers import convert_to_32bit

nvmms = 8

class MMFE:

    def __init__(self):

        print "Creating instance of MMFE_DAQ"

        self.VMMs = []
        for _ in range(nvmms):
            self.VMMs.append(VMM())

        self.udp         = udp_stuff()
        self.UDP_PORT    = 50001
        self.UDP_IP      = "192.168.0.000"
        self.udp_message = "r 0x44A1xxxx 0x1"

        self.vmm_cfg_sel          = np.zeros((32), dtype=int)
        self.readout_runlength    = np.zeros((32), dtype=int)
        self.admux                = np.zeros((32), dtype=int)
        self.control              = np.zeros((32), dtype=int)
        self.ds2411_low           = np.zeros((32), dtype=int)
        self.ds2411_high          = np.zeros((32), dtype=int)
        self.chnlReg              = np.zeros((51), dtype=int)
        self.byteint              = np.zeros((51), dtype=np.uint32)
        self.byteword             = np.zeros((32), dtype=int)

        self.ext_trig_on     = 0
        self.ext_trig_w_pulse= 0

        self.mmfeID = 0
        self.ipAddr = ["127.0.0.1",
                       "192.168.0.130",
                       "192.168.0.101",
                       "192.168.0.102",
                       "192.168.0.103",
                       "192.168.0.104",
                       "192.168.0.105",
                       "192.168.0.106",
                       "192.168.0.107",
                       "192.168.0.108",
                       "192.168.0.109",
                       "192.168.0.110",
                       "192.168.0.111",
                       "192.168.0.112",
                       "192.168.0.167",
                       ]

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

    def ping(self):
        print
        print "Pinging MMFE: %s" % (self.UDP_IP)
        os.system("ping %s -c 2" % (self.UDP_IP))
        print

    def check_for_data_flag(self):
        '''continuous checking for data'''
        msg = "r 0x44A10144 1" # read read_data variable in FPGA
        check_reading = self.udp.udp_client(msg, self.UDP_IP, self.UDP_PORT)
        check_reading_str = check_reading.split()
        print check_reading_str #comment this out later!
        if int(check_reading_str[2],16) is 1:
            return 1
        else: 
            return 0

    def daq_readOut_quiet(self, board_id):
        data       = None
        fifo_count = 0
        attempts   = 10

        bcidreg = "r 0x44A1014C 1" # read bcid_captured and external_trigger number in FPGA                              
        check_bcidreg = self.udp.udp_client(bcidreg,self.UDP_IP,self.UDP_PORT)
        check_bcidreg_str = check_bcidreg.split()
        self.bcid_reg = check_bcidreg_str[2]

        while fifo_count == 0 and attempts > 0:
            attempts -= 1
            message = "r 0x44A10014 1" # word count of data fifo
            data = self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
            if data != None:
                data_list  = data.split(" ")
                fifo_count = int(data_list[2], 16)
                #            time.sleep(1)

        print "FIFOCNT ", fifo_count
        if data == None or fifo_count == 0:
            print "Warning: Did not receive data. Stop readout."
            return
        if fifo_count == 0:
            print "Warning: found 0 FIFO counts. Stop readout."
            return
        if fifo_count % 2 != 0:
            print "Warning: Lost one count in fifo reading."
            fifo_count -= 1

        peeks_per_cycle = 10
        cycles    = fifo_count / peeks_per_cycle
        remainder = fifo_count % peeks_per_cycle
        myfile = open('mmfe8TestQuiet_%i.dat' %(board_id), 'a')
        for cycle in reversed(xrange(1+cycles)):
            
            peeks     = peeks_per_cycle if cycle > 0 else remainder
            message   = "k 0x44A10010 %s" % (peeks)
            data      = self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)

            if data != '!Err!':
                myfile.write(self.bcid_reg, '\t' + data + '\n')            
                #data_list = data.split()                
        myfile.close()

    def external_trigger_w_pulse(self, ctrlbit):
        if ctrlbit is 1:
            message = "w 0x44A1013C 1"
            self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
            self.ext_trig_w_pulse = 1
        else:
            message = "w 0x44A1013C 0"
            self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
            self.ext_trig_w_pulse = 0        

    def external_trigger(self, ctrlbit):
        self.readout_runlength[26] = 1 if ctrlbit else 0
        self.ext_trig_on = self.readout_runlength[26]
        self.write_readout_runlength()

    def start(self):
        self.control[2] = 1
        self.write_control()

        if self.ext_trig_on is 0:
            print "turn on ext trig!!"
        else:
            self.daq_readOut_quiet()
        #time.sleep(1)

        self.control[2] = 0
        self.write_control()

    def write_control(self):
        message = "w 0x44A100FC 0x{0:X}".format(convert_to_32bit(self.control))
        self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)


    def set_ip(self, ip_address):
        self.UDP_IP = ip_address

        try:
            self.mmfeID = self.ipAddr.index(self.UDP_IP)
        except:
            print "Warning: Did not find %s in list of valid IP addresses. Set mmfeID=0." % (self.UDP_IP)
            self.mmfeID = 0

        #word = '{0:04b}'.format(self.mmfeID)
        #for bit in xrange(len(word)):
        #self.vmm_cfg_sel[11 - bit] = int(word[bit])
        #print
        print "Set MMFE8 IP address = %s" % (self.UDP_IP)
        #print "Set MMFE8 ID         = %s" % (self.mmfeID)
        #print

        #last_three_digits = self.UDP_IP.split(".")[-1]
        #last_digit        = last_three_digits[-1]
        #last_digit_hex    = hex(int(last_digit))
        #message = "w 0x44A10150 %s" % (last_digit_hex)
        #print "Writing last digit of IP address: %s" % (last_digit_hex)
        #self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)



