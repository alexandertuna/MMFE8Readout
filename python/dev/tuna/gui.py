#!/usr/bin/env python26

#    by Charlie Armijo, Ken Johns, Bill Hart, Sarah Jones, James Wymer, Kade Gigliotti
#    Experimental Elementary Particle Physics Laboratory
#    Physics Department
#    University of Arizona    
#    armijo at physics.arizona.edu
#    johns at physics.arizona.edu
#
#    This is version 7 of the MMFE8 GUI

import pygtk
pygtk.require('2.0')
import gtk
from array import *
import numpy as np
from struct import *
import gobject 
from subprocess import call
from time import sleep
import sys
import os
import string
import random
import binstr
import socket
import time
import math

from mmfe8_userRegs import userRegs
from vmm            import VMM, registers
from udp            import udp_stuff
from channel        import index

nvmms = 8
nchannels = 64


class GUI:
    """
    """

    def destroy(self, widget):
        print
        print "Goodbye from the MMFE8 GUI!"
        print
        gtk.main_quit()

    def write_vmm_config(self, widget):
        """ 
        Create full config list.
        Command strings must be <= 100 chars due to bram limitations on artix7.
        """
        current_vmm = int(self.notebook.get_current_page())
        self.VMM[current_vmm].entry_SDP_.grab_focus()
        self.VMM[current_vmm].entry_SDT.grab_focus()
        self.button_write.grab_focus()

        reg           = self.VMM[current_vmm].get_channel_val()
        reglist       = list(self.VMM[current_vmm].reg.flatten())
        globalreglist = list(self.VMM[current_vmm].globalreg.flatten())
        fullreg       = reglist[::-1] + globalreglist[::-1] 

        n_words = len(fullreg) / 32
        if len(fullreg) % 32 != 0:
            fatal("Number of bits to write is not divisible by 32! Bad!")

        chunk_size         = 6
        words_to_write     = []
        vmm_config_address = "0x44A10020"

        for iter in xrange(n_words):

            bits    = fullreg[iter*32:(iter+1)*32]
            bitword = self.convert_to_32bit(bits)
            words_to_write.append("0x{0:X}".format(bitword))

            if (iter+1) % chunk_size == 0 or iter == n_words-1:

                message = "w %s %s" % (vmm_config_address, " ".join(words_to_write))
                self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)

                words_to_write = []
                vmm_config_address = "0x{0:X}".format(int(vmm_config_address, base=16) + 4*chunk_size)

        self.load_IDs()

    def print_config(self, widget):
        current_vmm = int(self.notebook.get_current_page())
        self.VMM[current_vmm].entry_SDP_.grab_focus()
        self.VMM[current_vmm].entry_SDT.grab_focus()
        self.button_print_config.grab_focus()

        reg           = self.VMM[current_vmm].get_channel_val()
        reglist       = list(self.VMM[current_vmm].reg.flatten())
        globalreglist = list(self.VMM[current_vmm].globalreg.flatten())
        fullreg       = reglist[::-1] + globalreglist[::-1]

        print
        print "Config for VMM", str(current_vmm)
        n_words = len(fullreg) / 32

        for iter in xrange(n_words):
            bits    = fullreg[iter*32:(iter+1)*32]
            bitword = self.convert_to_32bit(bits)
            print "0x{0:08x}  register {1:2d}".format(bitword, iter)
        print

    def daq_readOut(self):
        fifo_count = 0
        attempts = 10
        while fifo_count == 0 and attempts > 0:
            attempts -= 1
            message = "r 0x44A10014 1" # word count of data fifo
            data = self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
            data_list = string.split(data, " ")
            fifo_count = int(data_list[2], 16)
            sleep(1)

        print "FIFOCNT ", fifo_count
        if fifo_count % 2 != 0:
            print "Warning! Lost one count in fifo reading."
            fifo_count -= 1

        peeks_per_cycle = 10
        cycles    = fifo_count / peeks_per_cycle
        remainder = fifo_count % peeks_per_cycle

        for cycle in reversed(xrange(1+cycles)):
            
            peeks     = peeks_per_cycle if cycle > 0 else remainder
            message   = "k 0x44A10010 %s" % (peeks)
            data      = self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
            data_list = data.split()

            # what are the 0th and 1th words?

            for iword in xrange(2, peeks+1, 2):

                word0 = int(data_list[iword],   16)
                word1 = int(data_list[iword+1], 16)

                if not word0 > 0:
                    print "Out of order or no data."
                    continue

                word0 = word0 >> 2       # get rid of first 2 bits (threshold)
                addr  = (word0 & 63) + 1 # get channel number as on GUI
                word0 = word0 >> 6       # get rid of address
                amp   = word0 & 1023     # get amplitude

                word0  = word0 >> 10     # ?
                timing = word0 & 255     # 
                word0  = word0 >> 8      # we will later check for vmm number
                vmm    = word0 &  7      # get vmm number

                bcid_gray = int(word1 & 4095)
                bcid_bin  = binstr.b_gray_to_bin(binstr.int_to_b(bcid_gray, 16))
                bcid_int  = binstr.b_to_int(bcid_bin)

                word1 = word1 >> 12      # later we will get the turn number   
                word1 = word1 >> 4       # 4 bits of zeros?
                immfe = int(word1 & 255) # do we need to convert this?

                print "%s %s %s %s %s %s %s %s" % (data_list[iword], data_list[iword+1], 
                                                   addr, str(amp), str(timing), str(bcid_int), str(vmm), str(immfe))
                with open('mmfe8Test.dat', 'a') as myfile:
                    myfile.write(str(int(addr))+'\t'+ str(int(amp))+'\t'+ str(int(timing))+'\t'+ str(myIntBCid) +'\t'+ str(vmm) +'\n')

    def read_xadc(self, widget):
        message = "x"
        for i in range(100):
            data      = self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
            data_list = data.split()
            pd = [int(data_list[n], 16)/4096.0 for n in xrange(1, 9)]
            print 'XADC = {0:.4f} {1:.4f} {2:.4f} {3:.4f} {4:.4f} {5:.4f} {6:.4f} {7:.4f}'.format(pd[0],pd[1],pd[2],pd[3],pd[4],pd[5],pd[6],pd[7]) 
            s = '{0:.4f}\t{1:.4f}\t{2:.4f}\t{3:.4f}\t{4:.4f}\t{5:.4f}\t{6:.4f}\t{7:.4f}\n'.format(pd[0],pd[1],pd[2],pd[3],pd[4],pd[5],pd[6],pd[7])
            with open('mmfe8-xadc.dat', 'a') as myfile:
                myfile.write(s)  

    def send_ext_trig(self, widget):
        print "Sending Ext Trig"
        for trig in [0, 1, 0]:
            message = "w 0x44A10148 %i" % (trig)
            self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
            sleep(trig)
        print "Send Ext Trig Pulse Completed"
                
    def internal_trigger(self, widget):
        widget.set_label("ON"          if widget.get_active() else "OFF")
        self.readout_runlength[24] = 1 if widget.get_active() else 0
        self.write_readout_runlength()

    def external_trigger(self, widget):
        widget.set_label("ON"          if widget.get_active() else "OFF")
        self.readout_runlength[26] = 1 if widget.get_active() else 0
        self.write_readout_runlength()

    def leaky_readout(self, widget):
        widget.set_label("ON"          if widget.get_active() else "OFF")
        self.readout_runlength[25] = 1 if widget.get_active() else 0
        self.write_readout_runlength()

    def set_pulses(self, widget, entry):
        try:
            value = int(widget.get_text())
        except ValueError:
            print "ERROR: Pulses value must be a decimal number"
            return 
        if value < 0 or value > 999: #0x3E7
            print "SDP value out of range"
            print "0 <= Pulses <= 999" 
            return

        word = '{0:010b}'.format(value)
        for bit in xrange(len(word)):
            self.readout_runlength[9 - bit] = int(word[bit])
        
        self.write_readout_runlength()

    def set_acq_reset_count(self, widget, entry):
        try:
            entry = widget.get_text()
            value = int(entry, base=16)
        except ValueError:
            print "acq_count value must be a hex number"
            return
        if value < 0 or value > 0xffffffff: #0x3E7
            print "Acq count value out of range"
            print "0 <= acq_count <= 0xffffffff" 
            return

        message = "w 0x44A10120 %s" % (value)
        print "Writing %s counts to acq. reset" % (value)
        self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)

    def set_acq_reset_hold(self, widget, entry):
        try:
            entry = widget.get_text()
            value = int(entry, base=16)
        except ValueError:
            print "acq_hold value must be a hex number"
            return
        if value < 0 or value > 0xffffffff: #0x3E7
            print "Acq hold value out of range"
            print "0 <= acq_hold <= 0xffffffff" 
            return

        message = "w 0x44A10124 %s" % (value)
        print "Writing %s counts to acq. hold" % (value)
        self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)

    def start(self, widget):
        self.control[2] = 1
        self.write_control()

        self.daq_readOut()                   
        sleep(1)

        self.control[2] = 0
        self.write_control()

    def reset_global(self, widget):
        self.control[0] = 1
        self.write_control()

        sleep(1)

        self.control[0] = 0
        self.write_control()

    def system_init(self, widget):
        self.control[1] = 1
        self.write_control()

        sleep(1)

        self.control[1] = 0
        self.write_control()

    def system_load(self, widget):
        self.control[3] = 1
        self.write_control()

        sleep(1)

        self.control[3] = 0
        self.write_control()

    def convert_to_int(self, list_of_bits):
        this = "0b"
        for bit in list_of_bits:
            this += str(bit)
        return int(this, base=2)

    def convert_to_32bit(self, list_of_bits):
        return sum([int(list_of_bits[bit])*pow(2, bit) for bit in xrange(32)])

    def write_control(self):
        message = "w 0x44A100FC 0x{0:X}".format(self.convert_to_32bit(self.control))
        self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
                        
    def write_readout_runlength(self):
        message = "w 0x44A100F4 0x{0:X}".format(self.convert_to_32bit(self.readout_runlength))
        self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
        
    def write_vmm_cfg_sel(self):
        message = "w 0x44A100EC 0x{0:X}".format(self.convert_to_32bit(self.vmm_cfg_sel))
        self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
                        
    def set_IDs(self, widget):
        self.load_IDs()

    def load_IDs(self):
        self.write_vmm_cfg_sel()
        self.write_readout_runlength()

    def set_board_ip(self, widget, textBox):
        choice = widget.get_active()
        self.userRegs.set_udp_ip(self.ipAddr[choice])
        self.UDP_IP =            self.ipAddr[choice]
        textBox.set_text(str(choice))
        self.mmfeID = int(choice)
        print "MMFE8 IP address = %s and ID = %s" % (self.UDP_IP, self.mmfeID)

        word = '{0:04b}'.format(choice)
        for bit in xrange(len(word)):
            self.vmm_cfg_sel[11 - bit] = int(word[bit])

        last_three_digits = self.UDP_IP.split(".")[-1]
        last_digit        = last_three_digits[-1]
        last_digit_hex    = hex(int(last_digit))
        message = "w 0x44A10150 %s" % (last_digit_hex)
        print "Writing last digit of IP address: %s" % (last_digit_hex)
        self.udp.udp_client(message, self.UDP_IP, self.UDP_PORT)
        
    def set_display(self, widget):
        word = '{0:05b}'.format(widget.get_active())
        for bit in xrange(len(word)):
            self.vmm_cfg_sel[16 - bit] = int(word[bit])

        self.write_vmm_cfg_sel()

    def set_display_no_enet(self, widget):
        word = '{0:05b}'.format(widget.get_active())
        for bit in xrange(len(word)):
            self.vmm_cfg_sel[16 - bit] = int(word[bit])

        # self.write_vmm_cfg_sel()

    def readout_vmm_callback(self, widget, ivmm):
        self.readout_runlength[16+ivmm] = 1 if widget.get_active() else 0
        self.load_IDs()

    def reset_vmm_callback(self, widget, ivmm):
        self.vmm_cfg_sel[ivmm] = 1 if widget.get_active() else 0
        self.load_IDs()

    def __init__(self):
        print
        print "loading MMFE8 GUI"
        print 
        self.tv = gtk.TextView()
        self.tv.set_editable(False)
        self.tv.set_wrap_mode(gtk.WRAP_WORD)
        self.buffer = self.tv.get_buffer()

        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_position(gtk.WIN_POS_CENTER)
        self.window.set_default_size(1440,900)
        self.window.set_resizable(True)
        self.window.set_title("MMFE8 vmm2 Setup GUI (v7.0.0)")
        self.window.set_border_width(0)

        self.notebook = gtk.Notebook()
        self.notebook.set_tab_pos(gtk.POS_TOP)
        # self.notebook.modify_bg(gtk.STATE_NORMAL, gtk.gdk.color_parse("#FFFFFF"))
        self.tab_label_1 = gtk.Label("MMFE 0")
        self.tab_label_9 = gtk.Label("User Defined")
        self.VMM = []
        for i in range(8):
            self.VMM.append(VMM())
        self.udp = udp_stuff()
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

        self.mmfeID = 0
        #self.vmmGlobalReset = np.zeros((32), dtype=int)         #0x44A100EC  #vmm_global_reset          #reset & vmm_gbl_rst_i & vmm_cfg_en_vec( 7 downto 0)
        #self.vmm_cfg_sel_reg = np.zeros((32), dtype=int)        #0x44A100EC  #vmm_cfg_sel               #vmm_2display_i(16 downto 12) & mmfeID(11 downto 8) & vmm_readout_i(7 downto 0)
        self.vmm_cfg_sel = np.zeros((32), dtype=int)             #0x44A100EC  #vmm_cfg_sel               #vmm_2display_i(16 downto 12) & mmfeID(11 downto 8) & vmm_readout_i(7 downto 0)
        self.cktp_period_dutycycle = np.zeros((32), dtype=int)   #0x44A100F0  #cktp_period_dutycycle     #clk_tp_period_cnt(15 downto 0) & clk_tp_dutycycle_cnt(15 downto 0)
        #self.start_mmfe8 = np.zeros((32), dtype=int)
        self.readout_runlength = np.zeros((32), dtype=int)               #0x44A100F4  #ReadOut_RunLength         #ext_trigger_in_sel(26)&axi_data_to_use(25)&int_trig(24)&vmm_readout_i(23 downto 16)&pulses(15 downto 0)
        self.acq_count_runlength = np.zeros((32), dtype=int)     #0x44A10120  #counts_to_acq_reset       #counts_to_acq_reset( 31 downto 0)
        self.acq_hold_runlength = np.zeros((32), dtype=int)      #0x44A10120  #counts_to_acq_hold        #counts_to_hold_acq_reset( 31 downto 0)
        self.xadc = np.zeros((32), dtype=int)                    #0x44A100F8  #xadc                      #read
        self.admux = np.zeros((32), dtype=int)                   #0x44A100F8  #admux                     #write
        self.control = np.zeros((32), dtype=int)                         #0x44A100FC  #was vmm_global_reset      #reset & vmm_gbl_rst_i & vmm_cfg_en_vec( 7 downto 0)
        #self.system_init = np.zeros((32), dtype=int)            #0x44A10100  #axi_reg_60( 0)            #original reset
        #self.userRegs = userRegs()                              #0x44A10104,08,0C,00,14                 #user_reg_1 #user_reg_2 #user_reg_3 #user_reg_4         
        self.userRegs = userRegs()                               #0x44A10104,08,0C,00,14                 #user_reg_1 #user_reg_2 #user_reg_3 #user_reg_4 #user_reg_5
        self.ds2411_low = np.zeros((32), dtype=int)              #0x44A10118  #DS411_low                 #Low
        self.ds2411_high = np.zeros((32), dtype=int)             #0x44A1011C  #DS411_high                #High
        self.counts_to_acq_reset = np.zeros((32), dtype=int)     #0x44A10120  #counts_to_acq_reset       #0 to FFFF_FFFF #0=Not Used
        self.counts_to_acq_hold = np.zeros((32), dtype=int)      #0x44A10120  #counts_to_hold_acq_reset       #0 to FFFF_FFFF #0=Not Used
        self.terminate = 0                    
        self.UDP_PORT = 50001
        self.UDP_IP = ""
        self.chnlReg = np.zeros((51), dtype=int)
        self.byteint = np.zeros((51), dtype=np.uint32)
        self.byteword = np.zeros((32), dtype=int)

        # GUI global buttons
        self.button_add_mmfe = gtk.Button("Add MMFE")
        self.button_add_mmfe.set_size_request(-1,-1)
        self.button_add_mmfe.modify_bg(gtk.STATE_NORMAL, gtk.gdk.color_parse("#ADD8E6"))

        self.button_exit = gtk.Button("EXIT")
        self.button_exit.set_size_request(-1,-1)
        self.button_exit.connect("clicked", self.destroy)

        self.button_start = gtk.Button("Start")
        self.button_start.child.set_justify(gtk.JUSTIFY_CENTER)
        self.label_start = self.button_start.get_children()[0]
        self.button_start.set_size_request(-1,-1)
        self.button_start.connect("clicked", self.start)
        #self.button_start.set_sensitive(False)

        self.label_pulses = gtk.Label("pulses")
        self.label_pulses.set_markup('<span color="blue"><b>Pulses:</b></span>')
        self.label_pulses.set_justify(gtk.JUSTIFY_LEFT)
        self.entry_pulses = gtk.Entry(max=3)
        self.entry_pulses.set_text("0")
        self.entry_pulses.set_editable(True)
        self.entry_pulses.connect("focus-out-event", self.set_pulses)
        self.entry_pulses.connect("activate", self.set_pulses, self.entry_pulses)

        #self.combo_pulses.connect("changed", self.set_pulses)
        #self.combo_pulses.set_active(0)
        self.box_pulses = gtk.HBox()
        self.box_pulses.pack_start(self.label_pulses, expand=True)
        self.box_pulses.pack_start(self.entry_pulses, expand=False)

        self.label_pulses2 = gtk.Label("999 == Continuous")
        self.label_pulses2.set_markup('<span color="purple"><b>999 == Continuous</b></span>')
        self.label_pulses2.set_justify(gtk.JUSTIFY_CENTER)

        self.label_acq_reset_count = gtk.Label("acq_rst_count")
        self.label_acq_reset_count.set_markup('<span color="blue"><b>acq_reset_count:</b></span>')
        self.label_acq_reset_count.set_justify(gtk.JUSTIFY_LEFT)
        self.entry_acq_reset_count = gtk.Entry(max=8)
        self.entry_acq_reset_count.set_text("0")
        self.entry_acq_reset_count.set_editable(True)
        self.entry_acq_reset_count.connect("focus-out-event", self.set_acq_reset_count)
        self.entry_acq_reset_count.connect("activate", self.set_acq_reset_count, self.entry_acq_reset_count)

        #self.combo_acq_reset_count.connect("changed", self.set_acq_reset_count)
        #self.combo_acq_reset_count.set_active(0)
        self.box_acq_reset_count = gtk.HBox()
        self.box_acq_reset_count.pack_start(self.label_acq_reset_count, expand=True)
        self.box_acq_reset_count.pack_start(self.entry_acq_reset_count, expand=False)

        self.label_acq_reset_count2 = gtk.Label("0 == None")
        self.label_acq_reset_count2.set_markup('<span color="purple"><b>0 == No Reset</b></span>')
        self.label_acq_reset_count2.set_justify(gtk.JUSTIFY_CENTER)

        self.counts_to_acq_reset = np.zeros((32), dtype=int)                    #0x44A1010C  #DS411_high                #High

        self.label_acq_reset_hold = gtk.Label("acq_rst_hold")
        self.label_acq_reset_hold.set_markup('<span color="blue"><b>acq_reset_hold:</b></span>')
        self.label_acq_reset_hold.set_justify(gtk.JUSTIFY_LEFT)
        self.entry_acq_reset_hold = gtk.Entry(max=8)
        self.entry_acq_reset_hold.set_text("0")
        self.entry_acq_reset_hold.set_editable(True)
        self.entry_acq_reset_hold.connect("focus-out-event", self.set_acq_reset_hold)
        self.entry_acq_reset_hold.connect("activate", self.set_acq_reset_hold, self.entry_acq_reset_hold)

        #self.combo_acq_reset_hold.connect("changed", self.set_acq_reset_hold)
        #self.combo_acq_reset_hold.set_active(0)
        self.box_acq_reset_hold = gtk.HBox()
        self.box_acq_reset_hold.pack_start(self.label_acq_reset_hold, expand=True)
        self.box_acq_reset_hold.pack_start(self.entry_acq_reset_hold, expand=False)

        self.label_acq_reset_hold2 = gtk.Label("0 == None")
        self.label_acq_reset_hold2.set_markup('<span color="purple"><b>0 == No Reset</b></span>')
        self.label_acq_reset_hold2.set_justify(gtk.JUSTIFY_CENTER)

        self.counts_to_acq_hold = np.zeros((32), dtype=int)                    #0x44A1010C  #DS411_high                #High

        self.label_global_config = gtk.Label("Global Configuration")
        self.label_global_config.set_markup('<span color="blue" size="18000"><b>Global Configuration</b></span>')
        self.box_global_config = gtk.HBox()
        self.box_global_config.pack_start(self.label_global_config, expand=False)

        self.button_resetVMM = gtk.Button("VMM Global Reset")
        self.button_resetVMM.set_size_request(-1,-1)
        self.button_resetVMM.connect("clicked", self.reset_global)
        #self.button_resetVMM.set_sensitive(False)

        self.button_SystemInit = gtk.Button("System Reset")
        self.button_SystemInit.set_size_request(-1,-1)
        self.button_SystemInit.connect("clicked", self.system_init) ###<<<======

        self.button_SystemLoad = gtk.Button("VMM Load")
        self.button_SystemLoad.set_size_request(-1,-1)
        self.button_SystemLoad.connect("clicked", self.system_load)

        self.label_vmmGlobal_Reset = gtk.Label("vmm2")
        self.label_vmmGlobal_Reset.set_markup('<span color="red"><b>VMMs to Reset / Load</b></span>')
        self.label_vmmGlobal_Reset.set_justify(gtk.JUSTIFY_CENTER)

        self.vmm_reset_table = gtk.Table(rows=2, columns=8, homogeneous=True)
        self.vmm_reset_buttons = []
        for ivmm in xrange(nvmms):
            self.vmm_reset_buttons.append(gtk.CheckButton())
            self.vmm_reset_buttons[ivmm].connect("toggled", self.reset_vmm_callback, ivmm)
            self.vmm_reset_table.attach(gtk.Label(str(ivmm)),         left_attach=ivmm, right_attach=ivmm+1, top_attach=0, bottom_attach=1, xpadding=0, ypadding=0)
            self.vmm_reset_table.attach(self.vmm_reset_buttons[ivmm], left_attach=ivmm, right_attach=ivmm+1, top_attach=1, bottom_attach=2, xpadding=0, ypadding=0)

        self.label_vmmReadoutMask = gtk.Label("vmm2")
        self.label_vmmReadoutMask.set_markup('<span color="red"><b>VMM Readout Enable</b></span>')
        self.label_vmmReadoutMask.set_justify(gtk.JUSTIFY_CENTER)

        self.vmm_readout_table = gtk.Table(rows=2, columns=8, homogeneous=True)
        self.vmm_readout_buttons = []
        for ivmm in xrange(nvmms):
            self.vmm_readout_buttons.append(gtk.CheckButton())
            self.vmm_readout_buttons[ivmm].connect("toggled", self.readout_vmm_callback, ivmm)
            self.vmm_readout_table.attach(gtk.Label(str(ivmm)),           left_attach=ivmm, right_attach=ivmm+1, top_attach=0, bottom_attach=1, xpadding=0, ypadding=0)
            self.vmm_readout_table.attach(self.vmm_readout_buttons[ivmm], left_attach=ivmm, right_attach=ivmm+1, top_attach=1, bottom_attach=2, xpadding=0, ypadding=0)

        self.button_write = gtk.Button("Write to Config Buffer")
        self.button_write.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_write.set_size_request(-1,-1)
        self.button_write.connect("clicked", self.write_vmm_config)
        
        self.label_internal_trigger =  gtk.Label("Internal Trigger:    ")
        self.label_internal_trigger.set_markup('<span color="blue"><b>Internal Trigger:    </b></span>')
        self.button_internal_trigger = gtk.ToggleButton("OFF")
        self.button_internal_trigger.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_internal_trigger.connect("clicked", self.internal_trigger)
        self.button_internal_trigger.set_size_request(-1,-1)
        
        self.label_external_trigger =  gtk.Label("External Trigger:    ")
        self.label_external_trigger.set_markup('<span color="blue"><b>External Trigger:    </b></span>')
        self.button_external_trigger = gtk.ToggleButton("OFF")
        self.button_external_trigger.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_external_trigger.connect("clicked", self.external_trigger)
        self.button_external_trigger.set_size_request(-1,-1)

        self.button_ext_trig_pulse = gtk.Button("Send External Trigger")
        self.button_ext_trig_pulse.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_ext_trig_pulse.connect("clicked", self.send_ext_trig)
        self.button_ext_trig_pulse.set_size_request(-1,-1)
        
        self.label_leaky_readout =  gtk.Label("Leaky Readout Data:    ")
        self.label_leaky_readout.set_markup('<span color="blue"><b>Leaky Readout:    </b></span>')
        self.button_leaky_readout = gtk.ToggleButton("OFF")
        self.button_leaky_readout.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_leaky_readout.connect("clicked", self.leaky_readout)
        self.button_leaky_readout.set_size_request(-1,-1)
        
        self.button_read_XADC = gtk.Button("Read XADC")
        self.button_read_XADC.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_read_XADC.connect("clicked", self.read_xadc)
        self.button_read_XADC.set_size_request(-1,-1)
        
        self.button_print_config = gtk.Button("Print Config Load")
        self.button_print_config.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_print_config.set_size_request(-1,-1)
        self.button_print_config.connect("clicked", self.print_config)

        self.label_mmfe8_id = gtk.Label("mmfe8")
        self.label_mmfe8_id.set_markup('<span color="red"><b>mmfe\nID</b></span>')
        self.label_mmfe8_id.set_justify(gtk.JUSTIFY_CENTER)
        self.entry_mmfeID = gtk.Entry(max=3)
        self.entry_mmfeID.set_text(str(self.mmfeID))
        self.entry_mmfeID.set_editable(False)
        
        self.label_mmfe_global = gtk.Label("MMFE Configuration")
        self.label_mmfe_global.set_markup('<span color="red" size="18000"><b>MMFE Configuration</b></span>')
        self.label_mmfe_global.set_justify(gtk.JUSTIFY_CENTER)
        self.box_mmfe_global = gtk.HBox()
        self.box_mmfe_global.pack_start(self.label_mmfe_global, expand=False)

        self.label_mmfe_number = gtk.Label("VMM #")
        self.label_mmfe_number.set_markup('<span color="red"><b>MMFE #</b></span>')
        self.label_mmfe_number.set_justify(gtk.JUSTIFY_CENTER)
        self.combo_mmfe_number = gtk.combo_box_new_text()
        for immfe in xrange(1):
            self.combo_mmfe_number.append_text(str(immfe))
        self.combo_mmfe_number.set_active(0)
        self.box_mmfe_number = gtk.HBox()
        self.box_mmfe_number.pack_start(self.label_mmfe_number, expand=False)
        self.box_mmfe_number.pack_start(self.combo_mmfe_number, expand=False)

        self.label_IP = gtk.Label("IP ADDRESS")
        self.label_IP.set_markup('<span color="red"><b>IP ADDRESS</b></span>')
        self.label_IP.set_justify(gtk.JUSTIFY_CENTER)
        self.combo_IP = gtk.combo_box_new_text()
        for i in range (len(self.ipAddr)):
            self.combo_IP.append_text(self.ipAddr[i]) 

        self.combo_IP.set_active(0)
        self.combo_IP.connect("changed", self.set_board_ip, self.entry_mmfeID) 

        self.combo_display = gtk.combo_box_new_text()
        for i in range(32):
            self.combo_display.append_text(str(hex(i)))
        self.combo_display.connect("changed", self.set_display_no_enet)
        self.combo_display.set_active(0)

        self.button_setIDs = gtk.Button("Set IDs")
        self.button_setIDs.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_setIDs.set_size_request(-1,-1)        
        self.button_setIDs.connect("clicked", self.set_IDs)
        
        self.label_mmfe8_id = gtk.Label("mmfe8")
        self.label_mmfe8_id.set_markup('<span color="red"><b>mmfe8 ID</b></span>')
        self.label_mmfe8_id.set_justify(gtk.JUSTIFY_CENTER)
        self.label_Space20 = gtk.Label("   ")
        self.box_mmfeID = gtk.HBox()
        self.box_mmfeID.pack_start(self.label_mmfe8_id,expand=True)
        self.box_mmfeID.pack_start(self.entry_mmfeID,expand=False)

        self.label_display_id = gtk.Label("vmm2")
        self.label_display_id.set_markup('<span color="red"><b>Scope  </b></span>')
        self.label_display_id.set_justify(gtk.JUSTIFY_CENTER)

        self.label_Space21 = gtk.Label("    ")
        self.box_labelID = gtk.HBox()
        self.box_labelID.pack_start(self.label_Space20,expand=True) #
        #self.box_labelID.pack_start(self.label_Space21,expand=False)
        #self.box_labelID.pack_start(self.label_vmm2_id,expand=False)
        #self.box_labelID.pack_start(self.qs_table,expand=False)

        self.label_Space22 = gtk.Label("  ") 

        self.box_ResetID = gtk.VBox()
        self.box_ResetID.pack_start(self.label_vmmGlobal_Reset,expand=False)
        self.box_ResetID.pack_start(self.vmm_reset_table,expand=False)
        self.box_ResetID.pack_start(self.button_resetVMM,expand=False)

        self.box_ReadoutMask = gtk.VBox()
        self.box_ReadoutMask.pack_start(self.label_vmmReadoutMask, expand=False)
        self.box_ReadoutMask.pack_start(self.vmm_readout_table,    expand=False)
        #self.box_ResetID.pack_start(self.button_resetVMM,expand=False)

        self.box_vmmID = gtk.HBox()
        self.box_vmmID.pack_start(self.button_setIDs,expand=False)
        self.box_vmmID.pack_start(self.label_Space21,expand=True)
        self.box_vmmID.pack_start(self.label_display_id,expand=False)
        self.box_vmmID.pack_start(self.combo_display,expand=False)

        self.box_internal_trigger = gtk.HBox()
        self.box_internal_trigger.pack_start(self.label_internal_trigger,expand=False) #
        self.box_internal_trigger.pack_start(self.button_internal_trigger,expand=True)

        self.box_external_trigger = gtk.HBox()
        self.box_external_trigger.pack_start(self.label_external_trigger,expand=False) #
        self.box_external_trigger.pack_start(self.button_external_trigger,expand=True)

        self.box_leaky_readout = gtk.HBox()
        self.box_leaky_readout.pack_start(self.label_leaky_readout,expand=False) #
        self.box_leaky_readout.pack_start(self.button_leaky_readout,expand=True)

        #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        #                          FRAME 1   
        #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        self.frame_Reset = gtk.Frame()
        self.frame_Reset.set_shadow_type(gtk.SHADOW_OUT)
        self.frame_Reset.add(self.box_ResetID)

        self.frame_ReadoutMask = gtk.Frame()
        self.frame_ReadoutMask.set_shadow_type(gtk.SHADOW_OUT)
        self.frame_ReadoutMask.add(self.box_ReadoutMask)

        self.box_buttons = gtk.VBox()
        self.box_buttons.set_spacing(5)
        self.box_buttons.set_border_width(5)
        self.box_buttons.set_size_request(-1,-1)

        self.box_buttons.pack_start(self.box_global_config, expand=False)
        self.box_buttons.pack_start(self.button_SystemInit, expand=False)
        self.box_buttons.pack_start(self.button_SystemLoad, expand=False)
        self.box_buttons.pack_start(self.box_internal_trigger,expand=False)
        self.box_buttons.pack_start(self.box_external_trigger,expand=False)
        self.box_buttons.pack_start(self.box_leaky_readout,expand=False)
        self.box_buttons.pack_start(self.box_pulses,expand=False)        
        self.box_buttons.pack_start(self.label_pulses2,expand=False)
        self.box_buttons.pack_start(self.box_acq_reset_count,expand=False)        
        self.box_buttons.pack_start(self.label_acq_reset_count2,expand=False)
        self.box_buttons.pack_start(self.box_acq_reset_hold,expand=False)        
        self.box_buttons.pack_start(self.label_acq_reset_hold2,expand=False)
              
        self.box_buttons.pack_start(self.button_start,expand=False)
        self.box_buttons.pack_start(self.button_read_XADC,expand=False)
        self.box_buttons.pack_start(self.button_ext_trig_pulse,expand=False)
        self.box_buttons.pack_start(self.button_exit,expand=False)
        self.box_buttons.pack_start(self.button_add_mmfe, expand=False)

        self.box_mmfe = gtk.VBox()
        self.box_mmfe.set_spacing(5)
        self.box_mmfe.set_border_width(5)
        self.box_mmfe.set_size_request(-1,-1)

        self.box_mmfe.pack_start(self.box_mmfe_global, expand=False)
        self.box_mmfe.pack_start(self.box_mmfe_number, expand=False)
        self.box_mmfe.pack_start(self.label_IP,        expand=False)
        self.box_mmfe.pack_start(self.combo_IP,        expand=False)

        self.box_mmfe.pack_start(self.box_mmfeID,expand=False)
        self.box_mmfe.pack_start(self.frame_ReadoutMask,expand=False)
        self.box_mmfe.pack_start(self.box_vmmID,expand=False)
        self.box_mmfe.pack_start(self.button_print_config,expand=False)
        self.box_mmfe.pack_start(self.button_write,expand=False)
        self.box_mmfe.pack_start(self.frame_Reset,expand=False)  

        self.frame_mmfe = gtk.Frame()
        self.frame_mmfe.set_border_width(4)
        self.frame_mmfe.set_shadow_type(gtk.SHADOW_IN)
        self.frame_mmfe.add(self.box_mmfe)
        self.frame_mmfe.set_size_request(300, -1)

        self.page1_box = gtk.HBox(homogeneous=0, spacing=0)
        self.page1_box.pack_start(self.frame_mmfe)
        # --------------------------------------------------------------------------------

        self.vmm_header = gtk.Label("")
        self.vmm_header.set_markup('<span color="green" size="18000"><b>VMM Configuration</b></span>')

        self.vmm_number       = gtk.HBox()
        self.vmm_number_label = gtk.Label("")
        self.vmm_number_label.set_markup('<span color="green"><b>VMM #</b></span>')
        self.vmm_number_combo = gtk.combo_box_new_text()
        for ivmm in xrange(nvmms):
            self.vmm_number_combo.append_text(str(ivmm))
        self.vmm_number_combo.append_text("all")
        self.vmm_number_combo.connect("changed", self.set_current_vmm)
        for obj in [self.vmm_number_label, self.vmm_number_combo]:
            self.vmm_number.pack_start(obj, expand=False)

        # create buttons
        self.vmm_spg    = gtk.CheckButton("Input Charge Polarity (spg)")
        self.vmm_sdp    = gtk.CheckButton("Disable-at-Peak (sdp)")
        self.vmm_sbmx   = gtk.CheckButton("Route Analog Monitor to PDO Output (sbmx)")
        self.vmm_sbft   = gtk.CheckButton("Analog Output Buffer, TDO (sbft)")
        self.vmm_sbfp   = gtk.CheckButton("Analog Output Buffer, PDO (sbfp)")
        self.vmm_sbfm   = gtk.CheckButton("Analog Output Buffer, MO (sbfm)")
        self.vmm_slg    = gtk.CheckButton("Leakage Current Disable (slg)")
        self.vmm_scmx   = gtk.CheckButton("SCMX")
        self.vmm_sfa    = gtk.CheckButton("ART Enable (sfa)")
        self.vmm_sfm    = gtk.CheckButton("SFM (doubles leakage current)")
        self.vmm_sng    = gtk.CheckButton("Neighbor Triggering (sng)")
        self.vmm_sttt   = gtk.CheckButton("Timing Outputs (sttt)")
        self.vmm_ssh    = gtk.CheckButton("Sub-Hysteresis Discrimination (ssh)")
        self.vmm_s8b    = gtk.CheckButton("8-bit ADC Mode (s8b)")
        self.vmm_s6b    = gtk.CheckButton("6-bit ADC Mode (s6b) (disables 8 & 10 bit ADC)")
        self.vmm_spdc   = gtk.CheckButton("ADCs Enable (spdc)")
        self.vmm_sdcks  = gtk.CheckButton("Dual Clock Edge, Serialized Data Enable (sdcks)")
        self.vmm_sdcka  = gtk.CheckButton("Dual Clock Edge, Serialized ART Enable (sdcka)")
        self.vmm_sdck6b = gtk.CheckButton("Dual Clock Edge, Serialized 6-bit Enable (sdck6b)")
        self.vmm_sdrv   = gtk.CheckButton("Tristates Analog Outputs (sdrv)")
        self.vmm_stpp   = gtk.CheckButton("Timing Outputs Control 2 (stpp)")
        
        # connect them to functions
        self.vmm_spg.connect(   "toggled", self.vmm_callback_bit, registers.SPG)
        self.vmm_sdp.connect(   "toggled", self.vmm_callback_bit, registers.SDP)
        self.vmm_sbmx.connect(  "toggled", self.vmm_callback_bit, registers.SBMX)
        self.vmm_sbft.connect(  "toggled", self.vmm_callback_bit, registers.SBFT)
        self.vmm_sbfp.connect(  "toggled", self.vmm_callback_bit, registers.SBFP)
        self.vmm_sbfm.connect(  "toggled", self.vmm_callback_bit, registers.SBFM)
        self.vmm_slg.connect(   "toggled", self.vmm_callback_bit, registers.SLG)
        self.vmm_scmx.connect(  "toggled", self.vmm_callback_bit, registers.SCMX)
        self.vmm_sfa.connect(   "toggled", self.vmm_callback_bit, registers.SFA)
        self.vmm_sfm.connect(   "toggled", self.vmm_callback_bit, registers.SFM)
        self.vmm_sng.connect(   "toggled", self.vmm_callback_bit, registers.SNG)
        self.vmm_sttt.connect(  "toggled", self.vmm_callback_bit, registers.STTT)
        self.vmm_ssh.connect(   "toggled", self.vmm_callback_bit, registers.SSH)
        self.vmm_s8b.connect(   "toggled", self.vmm_callback_bit, registers.S8b)
        self.vmm_s6b.connect(   "toggled", self.vmm_callback_bit, registers.S6b)
        self.vmm_spdc.connect(  "toggled", self.vmm_callback_bit, registers.SPDC)
        self.vmm_sdcks.connect( "toggled", self.vmm_callback_bit, registers.SDCKS)
        self.vmm_sdcka.connect( "toggled", self.vmm_callback_bit, registers.SDCKA)
        self.vmm_sdck6b.connect("toggled", self.vmm_callback_bit, registers.SDCK6b)
        self.vmm_sdrv.connect(  "toggled", self.vmm_callback_bit, registers.SDRV)
        self.vmm_stpp.connect(  "toggled", self.vmm_callback_bit, registers.STPP)

        # create menus
        self.vmm_sm      = gtk.HBox()
        self.vmm_sm_menu = gtk.combo_box_new_text()
        self.vmm_sm_menu.append_text("CHN 1")
        self.vmm_sm_menu.append_text("CHN 2 | pulser DAC")
        self.vmm_sm_menu.append_text("CHN 3 | threshold DAC")
        self.vmm_sm_menu.append_text("CHN 4 | band-gap ref")
        self.vmm_sm_menu.append_text("CHN 5 | temp")
        for i in range(5, 64):
            self.vmm_sm_menu.append_text("CHN " + str(i+1))
        self.vmm_sm.pack_start(self.vmm_sm_menu,           expand=False)
        self.vmm_sm.pack_start(gtk.Label(" Monitor (sm)"), expand=False)

        self.vmm_sfam      = gtk.HBox()
        self.vmm_sfam_menu = gtk.combo_box_new_text()
        self.vmm_sfam_menu.append_text("timing-at-threshold")
        self.vmm_sfam_menu.append_text("timing-at-peak")
        self.vmm_sfam.pack_start(self.vmm_sfam_menu,                expand=False)
        self.vmm_sfam.pack_start(gtk.Label(" ART En. Mode (sfam)"), expand=False)

        self.vmm_st      = gtk.HBox()
        self.vmm_st_menu = gtk.combo_box_new_text()
        self.vmm_st_menu.append_text("200 ns")
        self.vmm_st_menu.append_text("100 ns")
        self.vmm_st_menu.append_text(" 50 ns")
        self.vmm_st_menu.append_text(" 25 ns")
        self.vmm_st.pack_start(self.vmm_st_menu,                expand=False)
        self.vmm_st.pack_start(gtk.Label(" Peaking Time (st)"), expand=False)

        self.vmm_sg      = gtk.HBox()
        self.vmm_sg_menu = gtk.combo_box_new_text()
        for text in ["0.5 (000)", "1.0 (001)", "3.0 (010)" , "4.5 (011)", 
                     "6.0 (100)", "9.0 (101)", "12.0 (110)", "16.0 (111)"]:
            self.vmm_sg_menu.append_text(text)
        self.vmm_sg.pack_start(self.vmm_sg_menu,               expand=False)
        self.vmm_sg.pack_start(gtk.Label(" Gain, mV/fC (sg)"), expand=False)

        self.vmm_stot      = gtk.HBox()
        self.vmm_stot_menu = gtk.combo_box_new_text()
        self.vmm_stot_menu.append_text("threshold-to-peak")
        self.vmm_stot_menu.append_text("time-over-threshold")
        self.vmm_stot.pack_start(self.vmm_stot_menu,                       expand=False)
        self.vmm_stot.pack_start(gtk.Label(" Timing Outputs Mode (stot)"), expand=False)

        self.vmm_stc      = gtk.HBox()
        self.vmm_stc_menu = gtk.combo_box_new_text()
        for text in ["125 ns (00)", "250 ns (01)", "500 ns (10)", "1000 ns (11)"]:
            self.vmm_stc_menu.append_text(text)
        self.vmm_stc.pack_start(self.vmm_stc_menu,             expand=False)
        self.vmm_stc.pack_start(gtk.Label(" TAC Slope (stc)"), expand=False)

        self.vmm_sc10b      = gtk.HBox()
        self.vmm_sc10b_menu = gtk.combo_box_new_text()
        for text in ["0 ns (00)", "1 ns (01)", "2 ns (10)", "3 ns (11)"]:
            self.vmm_sc10b_menu.append_text(text)
        self.vmm_sc10b.pack_start(self.vmm_sc10b_menu,                          expand=False)
        self.vmm_sc10b.pack_start(gtk.Label(" 10-bit Conversion Time (sc10b)"), expand=False)

        self.vmm_sc8b      = gtk.HBox()
        self.vmm_sc8b_menu = gtk.combo_box_new_text()
        for text in ["0 ns (00)", "1 ns (01)", "2 ns (10)", "3 ns (11)"]:
            self.vmm_sc8b_menu.append_text(text)
        self.vmm_sc8b.pack_start(self.vmm_sc8b_menu,                          expand=False)
        self.vmm_sc8b.pack_start(gtk.Label("  8-bit Conversion Time (sc8b)"), expand=False)

        self.vmm_sc6b      = gtk.HBox()
        self.vmm_sc6b_menu = gtk.combo_box_new_text()
        for text in ["0 ns (000)", "1 ns (001)", "2 ns (010)", "3 ns (011)",
                     "4 ns (100)", "5 ns (101)", "6 ns (110)", "7 ns (111)",
                     ]:
            self.vmm_sc6b_menu.append_text(text)
        self.vmm_sc6b.pack_start(self.vmm_sc6b_menu,                          expand=False)
        self.vmm_sc6b.pack_start(gtk.Label("  6-bit Conversion Time (sc6b)"), expand=False)

        self.vmm_sdt      = gtk.HBox()
        self.vmm_sdt_menu = gtk.combo_box_new_text()
        for text in xrange(1024):
            self.vmm_sdt_menu.append_text(str(text))
        self.vmm_sdt.pack_start(self.vmm_sdt_menu,                            expand=False)
        self.vmm_sdt.pack_start(gtk.Label(" Threshold DAC (max 1023) (sdt)"), expand=False)

        self.vmm_sdp2      = gtk.HBox()
        self.vmm_sdp2_menu = gtk.combo_box_new_text()
        for text in xrange(1024):
            self.vmm_sdp2_menu.append_text(str(text))
        self.vmm_sdp2.pack_start(self.vmm_sdp2_menu,                             expand=False)
        self.vmm_sdp2.pack_start(gtk.Label(" Test pulse DAC (max 1023) (sdp2)"), expand=False)

        # connect them to functions
        self.vmm_sfam_menu.connect( "changed", self.vmm_callback_bit,  registers.SFAM)
        self.vmm_stot_menu.connect( "changed", self.vmm_callback_bit,  registers.STOT)
        self.vmm_sm_menu.connect(   "changed", self.vmm_callback_word, registers.SM,    registers.bits_SM)
        self.vmm_st_menu.connect(   "changed", self.vmm_callback_word, registers.ST,    registers.bits_ST)
        self.vmm_sg_menu.connect(   "changed", self.vmm_callback_word, registers.SG,    registers.bits_SG)
        self.vmm_stc_menu.connect(  "changed", self.vmm_callback_word, registers.STC,   registers.bits_STC)
        self.vmm_sdt_menu.connect(  "changed", self.vmm_callback_word, registers.SDT,   registers.bits_SDT)
        self.vmm_sdp2_menu.connect( "changed", self.vmm_callback_word, registers.SDP2,  registers.bits_SDP2)

        reverse = True
        self.vmm_sc10b_menu.connect("changed", self.vmm_callback_word, registers.SC10b, registers.bits_SC10b, reverse)
        self.vmm_sc8b_menu.connect( "changed", self.vmm_callback_word, registers.SC8b,  registers.bits_SC8b,  reverse)
        self.vmm_sc6b_menu.connect( "changed", self.vmm_callback_word, registers.SC6b,  registers.bits_SC6b,  reverse)

        # defaults for all VMMs
        self.vmm_number_combo.set_active(nvmms)
        self.vmm_sm_menu.set_active(8)
        self.vmm_sg_menu.set_active(5)
        self.vmm_stc_menu.set_active(2)
        self.vmm_sdt_menu.set_active(220)
        self.vmm_sdp2_menu.set_active(120)
        for obj in [self.vmm_sbft, self.vmm_sbfp, self.vmm_sbfm, self.vmm_scmx, self.vmm_sfa,
                    self.vmm_sfm,  self.vmm_s8b,  self.vmm_spdc,
                    ]:
            obj.set_active(1)
        for obj in [self.vmm_sfam_menu,  self.vmm_st_menu,   self.vmm_stot_menu,
                    self.vmm_sc10b_menu, self.vmm_sc8b_menu, self.vmm_sc6b_menu,
                    ]:
            obj.set_active(0)

        # place the buttons and menus
        self.vmm_variables = gtk.VBox()
        self.vmm_variables.set_border_width(5)
        for obj in [self.vmm_header, self.vmm_number, self.vmm_spg,  self.vmm_sdp,  self.vmm_sbmx,
                    self.vmm_sbft,   self.vmm_sbfp,   self.vmm_sbfm, self.vmm_slg,  self.vmm_scmx, self.vmm_sm,
                    self.vmm_sfa,    self.vmm_sfam,   self.vmm_st,   self.vmm_sfm,  self.vmm_sg,   self.vmm_sng,
                    self.vmm_sttt,   self.vmm_stot,   self.vmm_ssh,  self.vmm_stc,  self.vmm_s8b,  self.vmm_s6b,
                    self.vmm_sc10b,  self.vmm_sc8b,   self.vmm_sc6b, self.vmm_spdc, self.vmm_sdcks, self.vmm_sdcka,
                    self.vmm_sdck6b, self.vmm_sdrv,   self.vmm_stpp, self.vmm_sdt,  self.vmm_sdp2,
                    ]:
            self.vmm_variables.pack_start(obj, expand=False)
        
        self.vmm_frame = gtk.Frame()
        self.vmm_frame.set_border_width(4)
        self.vmm_frame.set_shadow_type(gtk.SHADOW_IN)
        self.vmm_frame.add(self.vmm_variables)
        self.vmm_variables_frame = gtk.HBox()
        self.vmm_variables_frame.pack_start(self.vmm_frame)

        self.page1_box.pack_start(self.vmm_variables_frame, expand=True)
        # --------------------------------------------------------------------------------

        self.channel_header = gtk.Label("")
        self.channel_header.set_markup('<span color="purple" size="18000"><b>Channel Configuration</b></span>')

        self.channel_variables = gtk.VBox()
        self.channel_variables.set_border_width(5)

        self.channel_label = gtk.Label("  SP SC SL ST SM SD       SMX         SZ10b         SZ8b         SZ6b     ")
        self.channel_box   = []
        self.channel_num   = []
        self.channel_SP    = []
        self.channel_SC    = []
        self.channel_SL    = []
        self.channel_ST    = []
        self.channel_SM    = []
        self.channel_SMX   = []
        self.channel_SD    = []
        self.channel_SZ10b = []
        self.channel_SZ8b  = []
        self.channel_SZ6b  = []

        for channel in xrange(nchannels+1):

            quickset = (channel == nchannels)

            self.channel_box.append(gtk.HBox())
            self.channel_num.append(gtk.Label("%02i" % (channel)))
            if quickset:
                self.channel_num[-1].set_text(" *  ")

            # create buttons
            self.channel_SP.append( gtk.ToggleButton(label="n"))
            self.channel_SC.append( gtk.CheckButton())
            self.channel_SL.append( gtk.CheckButton())
            self.channel_ST.append( gtk.CheckButton())
            self.channel_SM.append( gtk.CheckButton())
            self.channel_SMX.append(gtk.CheckButton())

            # create menus
            self.channel_SD.append(   gtk.combo_box_new_text())
            self.channel_SZ10b.append(gtk.combo_box_new_text())
            self.channel_SZ8b.append( gtk.combo_box_new_text())
            self.channel_SZ6b.append( gtk.combo_box_new_text())
            for i in range(16):
                self.channel_SD[-1].append_text(str(i) + " mv")
            for i in range(32):
                self.channel_SZ10b[-1].append_text(str(i) + " ns")
            for i in range(16):
                self.channel_SZ8b[-1].append_text(str(i) + " ns")
            for i in range(8):
                self.channel_SZ6b[-1].append_text(str(i) + " ns")
            
            if quickset:
                self.channel_SP[-1] = gtk.ToggleButton(label="  ")
                self.channel_SP[-1].set_inconsistent(True)
                for obj in [self.channel_SC,
                            self.channel_SL,
                            self.channel_ST,
                            self.channel_SM,
                            self.channel_SMX,
                            ]:
                    obj[-1].set_inconsistent(True)

            # connect to functions
            ch = "all" if quickset else channel
            self.channel_SP[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.SP)
            self.channel_SC[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.SC)
            self.channel_SL[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.SL)
            self.channel_ST[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.ST)
            self.channel_SM[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.SM)
            self.channel_SMX[-1].connect(  "clicked", self.channel_callback_bit,  ch, index.SMX)
            self.channel_SD[-1].connect(   "changed", self.channel_callback_word, ch, index.SD,    index.bits_SD)
            self.channel_SZ10b[-1].connect("changed", self.channel_callback_word, ch, index.SZ10b, index.bits_SZ10b)
            self.channel_SZ8b[-1].connect( "changed", self.channel_callback_word, ch, index.SZ8b,  index.bits_SZ8b)
            self.channel_SZ6b[-1].connect( "changed", self.channel_callback_word, ch, index.SZ6b,  index.bits_SZ6b)

            # defaults
            if not quickset:
                for obj in [self.channel_SD[-1], self.channel_SZ10b[-1], self.channel_SZ8b[-1], self.channel_SZ6b[-1]]:
                    obj.set_active(0)

            # build the row
            for obj in [self.channel_num[-1],
                        self.channel_SP[-1],
                        self.channel_SC[-1],
                        self.channel_SL[-1],
                        self.channel_ST[-1],
                        self.channel_SM[-1],
                        self.channel_SMX[-1],
                        self.channel_SD[-1],
                        self.channel_SZ10b[-1],
                        self.channel_SZ8b[-1],
                        self.channel_SZ6b[-1],
                        ]:
                self.channel_box[-1].pack_start(obj, expand=False)

        # build the window
        self.channel_variables.pack_start(self.channel_header, expand=False)
        for obj in [self.vspace(), self.channel_label, 
                    self.vspace(), self.channel_box[nchannels], 
                    self.vspace()]:
            self.channel_variables.pack_start(obj)
        for channel in xrange(nchannels):
            self.channel_variables.pack_start(self.channel_box[channel])
        
        self.channel_frame = gtk.Frame()
        self.channel_frame.set_border_width(4)
        self.channel_frame.set_shadow_type(gtk.SHADOW_IN)
        self.channel_frame.add(self.channel_variables)
        self.channel_variables_frame = gtk.HBox()
        self.channel_variables_frame.pack_start(self.channel_frame)

        self.page1_box.pack_start(self.channel_variables_frame, expand=True)

        # --------------------------------------------------------------------------------

        self.page1_scrolledWindow = gtk.ScrolledWindow()
        self.page1_viewport = gtk.Viewport()
        self.page1_viewport.add(self.page1_box)
        self.page1_scrolledWindow.add(self.page1_viewport)

        self.notebook.append_page(self.page1_scrolledWindow,  self.tab_label_1)
        self.notebook.append_page(self.userRegs.userRegs_box, self.tab_label_9)

        self.box_GUI = gtk.HBox(homogeneous=0, spacing=0)
        self.box_GUI.pack_start(self.box_buttons, expand=False)
        self.box_GUI.pack_end(self.notebook, expand=True)

        self.window.add(self.box_GUI)
        self.window.show_all()
        self.window.connect("destroy", self.destroy)


    def set_current_vmm(self, widget):
        active = widget.get_active()
        self.current_vmm = active if active != nvmms else "all"
        print "Set current VMM # = %s" % (self.current_vmm if not self.current_vmm == nvmms else "all")
        if self.current_vmm == "all":
            return
        else:
            self.refresh_vmm_options()
            self.refresh_channel_options()

    def refresh_vmm_options(self):
        try:
            vmm = self.VMM[self.current_vmm]
        except:
            sys.exit("ERROR: Attempted to refresh all VMMs. This is not possible")

        self.vmm_spg.set_active(      vmm.globalreg[registers.SPG])
        self.vmm_sdp.set_active(      vmm.globalreg[registers.SDP])
        self.vmm_sbmx.set_active(     vmm.globalreg[registers.SBMX])
        self.vmm_sbft.set_active(     vmm.globalreg[registers.SBFT])
        self.vmm_sbfp.set_active(     vmm.globalreg[registers.SBFP])
        self.vmm_sbfm.set_active(     vmm.globalreg[registers.SBFM])
        self.vmm_slg.set_active(      vmm.globalreg[registers.SLG])
        self.vmm_scmx.set_active(     vmm.globalreg[registers.SCMX])
        self.vmm_sfm.set_active(      vmm.globalreg[registers.SFM])
        self.vmm_sng.set_active(      vmm.globalreg[registers.SNG])
        self.vmm_sttt.set_active(     vmm.globalreg[registers.STTT])
        self.vmm_ssh.set_active(      vmm.globalreg[registers.SSH])
        self.vmm_s8b.set_active(      vmm.globalreg[registers.S8b])
        self.vmm_s6b.set_active(      vmm.globalreg[registers.S6b])
        self.vmm_spdc.set_active(     vmm.globalreg[registers.SPDC])
        self.vmm_sdcks.set_active(    vmm.globalreg[registers.SDCKS])
        self.vmm_sdcks.set_active(    vmm.globalreg[registers.SDCKA])
        self.vmm_sdck6b.set_active(   vmm.globalreg[registers.SDCK6b])
        self.vmm_sdrv.set_active(     vmm.globalreg[registers.SDRV])
        self.vmm_stpp.set_active(     vmm.globalreg[registers.STPP])

        self.vmm_sfam_menu.set_active(vmm.globalreg[registers.SFAM])
        self.vmm_stot_menu.set_active(vmm.globalreg[registers.STOT])

        self.vmm_sm_menu.set_active(   self.convert_to_int(vmm.globalreg[registers.SM    : registers.SM    + registers.bits_SM]))
        self.vmm_st_menu.set_active(   self.convert_to_int(vmm.globalreg[registers.ST    : registers.ST    + registers.bits_ST]))
        self.vmm_sg_menu.set_active(   self.convert_to_int(vmm.globalreg[registers.SG    : registers.SG    + registers.bits_SG]))
        self.vmm_stc_menu.set_active(  self.convert_to_int(vmm.globalreg[registers.STC   : registers.STC   + registers.bits_STC]))
        self.vmm_sc10b_menu.set_active(self.convert_to_int(vmm.globalreg[registers.SC10b : registers.SC10b + registers.bits_SC10b]))
        self.vmm_sc8b_menu.set_active( self.convert_to_int(vmm.globalreg[registers.SC8b  : registers.SC8b  + registers.bits_SC8b]))
        self.vmm_sc6b_menu.set_active( self.convert_to_int(vmm.globalreg[registers.SC6b  : registers.SC6b  + registers.bits_SC6b]))
        self.vmm_sdt_menu.set_active(  self.convert_to_int(vmm.globalreg[registers.SDT   : registers.SDT   + registers.bits_SDT]))
        self.vmm_sdp2_menu.set_active( self.convert_to_int(vmm.globalreg[registers.SDP2  : registers.SDP2  + registers.bits_SDP2]))

    def vmm_callback_bit(self, widget, register):
        vmms = self.VMM if self.current_vmm == "all" else [ self.VMM[self.current_vmm] ]

        for vmm in vmms:
            vmm.globalreg[register] = 1 if widget.get_active() else 0

    def vmm_callback_word(self, widget, register, nbits, reverse=False, debug=False):
        padding = "0%ib" % nbits
        word    = format(int(widget.get_active()), padding)
        vmms    = self.VMM if self.current_vmm == "all" else [ self.VMM[self.current_vmm] ]
        if reverse:
            word = word[::-1]
        if debug:
            print "Writing %s to register %s with %s bits | VMM_%s" % (word, register, nbits, self.current_vmm)

        # insert word starting at register
        for vmm in vmms:
            vmm.globalreg[register:register+nbits] = list(word)

    def channel_callback_bit(self, widget, ch, register):
        vmms = self.VMM if self.current_vmm == "all" else [ self.VMM[self.current_vmm] ]

        for vmm in vmms:
            channels = vmm.chan_list if ch == "all" else [ vmm.chan_list[ch] ]
            for channel in channels:
                channel.chan_val[register] = 1 if widget.get_active() else 0

                if widget in self.channel_SP[:-1]:
                    widget.set_label("p" if widget.get_active() else "n")

            if ch == "all" and self.current_vmm != "all":
                self.refresh_channel_options()

    def channel_callback_word(self, widget, ch, register, nbits):
        if widget.get_active() < 0:
            return

        padding = "0%ib" % nbits
        word    = format(int(widget.get_active()), padding)
        vmms    = self.VMM if self.current_vmm == "all" else [ self.VMM[self.current_vmm] ]

        # insert word starting at register
        for vmm in vmms:
            channels = vmm.chan_list if ch == "all" else [ vmm.chan_list[ch] ]
            for channel in channels:
                channel.chan_val[register:register+nbits] = list(word)

            if ch == "all" and self.current_vmm != "all":
                self.refresh_channel_options()

    def refresh_channel_options(self):

        # quick set
        for obj in [self.channel_SD[nchannels],
                    self.channel_SZ10b[nchannels],
                    self.channel_SZ8b[nchannels],
                    self.channel_SZ6b[nchannels],
                    ]:
            obj.set_active(-1)

        try:
            vmm = self.VMM[self.current_vmm]
        except:
            sys.exit("ERROR: Attempted to refresh all VMMs. This is not possible")

        for ch in xrange(nchannels):

            channel = vmm.chan_list[ch]

            self.channel_SP[ch].set_active( channel.chan_val[index.SP])
            self.channel_SC[ch].set_active( channel.chan_val[index.SC])
            self.channel_SL[ch].set_active( channel.chan_val[index.SL])
            self.channel_ST[ch].set_active( channel.chan_val[index.ST])
            self.channel_SM[ch].set_active( channel.chan_val[index.SM])
            self.channel_SMX[ch].set_active(channel.chan_val[index.SMX])

            self.channel_SD[ch].set_active(   self.convert_to_int(channel.chan_val[index.SD    : index.SD    + index.bits_SD]))
            self.channel_SZ10b[ch].set_active(self.convert_to_int(channel.chan_val[index.SZ10b : index.SZ10b + index.bits_SZ10b]))
            self.channel_SZ8b[ch].set_active( self.convert_to_int(channel.chan_val[index.SZ8b  : index.SZ8b  + index.bits_SZ8b]))
            self.channel_SZ6b[ch].set_active( self.convert_to_int(channel.chan_val[index.SZ6b  : index.SZ6b  + index.bits_SZ6b]))


    def vspace(self):
        return gtk.Label(" ")

    def main(self):
        gtk.main()


if __name__ == "__main__":
    gui = GUI()
    gui.main()

