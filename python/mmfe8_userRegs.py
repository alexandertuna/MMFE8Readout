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
#### On PCROD0 use from Numpy import *
import numpy as np
#from Numeric import *
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
from mmfe8_udp import udp_stuff 



############################################################################
############################################################################
##########################                     #############################
##########################    userRegs CLASS   #############################
##########################                     #############################
############################################################################
############################################################################

class userRegs:


    #########################################
    #
    #          user defined functions  
    #
    #  This needs to be changed to allow Bill  <<=====================
    #  to use registers for debugging.         <<=====================
    #  This probably needs to be a new class.  <<=====================
    #
    #########################################

    def set_udp_ip(self, NEW_UDP_IP):
        self.UDP_IP = NEW_UDP_IP
        print "New ip addr set in mmfe8_userRegs.py class userRegs = " + self.UDP_IP

    def set_udp_port(self, NEW_UDP_PORT):
        self.UDP_PORT = NEW_UDP_PORT        
        #print "New port set in mmfe8_udp.py class udp_stuff = " + str(self.UDP_PORT)

    def tobits(self, s):
        result = []
        for c in s:
            bits = bin(ord(c))[2:]
            bits = '00000000'[len(bits):] + bits
            #result.extend([int(b) for b in bits])
        return bits

    def write_button_statusReg1_callback(self, widget, textBox):
        """
        try:            
            entry = int(textBox.get_text(),base=16)
            if entry > 0xffffffff:
                myMsg = "a ValueError exception occurred\nReg 1 Value > 0xFFFFFFFF."
                self.on_erro(widget, myMsg)
            else:    
                
                #self.udp_client(
                # IPbus Transaction
                self.hw.getNode("B").getNode("A0").write(entry)
                self.hw.dispatch()
                
                print "Wrote",hex(entry),"to STATUS REG 1"
            
        except IOError as e:
            myMsg = "I/O Error:  {1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except ValueError:
            myMsg = "a ValueError exception occurred\nStatus Reg 1 not hexadecimal."
            self.on_erro(widget, myMsg)
        except:
            print  "Unexpected Error:  ", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")
        """
        return
 
    def write_button_Reg1_callback(self, widget, textBox):
        VALUE = textBox.get_text()
        myValue = string.split(VALUE,'x')
        if (len(myValue) == 1):
            MESSAGE = "W 0x44A10104 0x" + myValue[0] + '\0' + '\n'
        elif (len(myValue) == 2):
            MESSAGE = "W 0x44A10104 0x" + myValue[1] + '\0' + '\n'
        else:
            print "ERROR:  Improper value"
            textBox.set_text("Error!")
            return 0
        #print myValue
        print "Sending: " + MESSAGE
        data = self.udp.udp_client(MESSAGE,self.UDP_IP,self.UDP_PORT)
        myData = string.split(data,'\n')
        #textBox.set_text(myData[2])
       
        """
        try:
            entry = int(textBox.get_text(),base=16)
            if entry > 0xffffffff:
                myMsg = "a ValueError exception occurred\nCtrl Reg 2 Value > 0xFFFFFFFF."
                self.on_erro(widget, myMsg)
            else:                    
                # IPbus Transaction
                self.hw.getNode("B").getNode("A3").write(entry)
                self.hw.dispatch()                
                print "Wrote",hex(entry),"to 32-bit Scratch Pad Reg\n"
        except IOError as e:
            myMsg = "I/O Error:  {1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except ValueError:
            myMsg = "a ValueError exception occurred\nCtrl Reg 1 Value not hexadecimal."
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error:  ", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")
        """
        
    def write_button_Reg2_callback(self, widget, textBox):
        try:
            entry = int(textBox.get_text(),base=16)
            if entry > 0xffffffff:
                myMsg = "a ValueError exception occurred\nCtrl Reg 2 Value > 0xFFFFFFFF."
                self.on_erro(widget, myMsg)
            else:                   
                MESSAGE = "W 0x44A10108 " + str(entry) + '\0' + '\n'             
                print "Wrote",hex(entry),"to User Defined REG 2"
                data = self.udp.udp_client(MESSAGE,self.UDP_IP,self.UDP_PORT)
                myData = string.split(data,'\n')
                #textBox.set_text(myData[2])

        except IOError as e:
            myMsg = "I/O Error:  {1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except ValueError:
            myMsg = "a ValueError exception occurred\nUser Defined Reg 2 Value not hexadecimal."
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error:  ", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")

        
    def write_button_Reg3_callback(self, widget, textBox):
        try:
            entry = int(textBox.get_text(),base=16)
            if entry > 0xffffffff:
                myMsg = "a ValueError exception occurred\nUser Defined Reg 3 Value > 0xFFFFFFFF."
                self.on_erro(widget, myMsg)
            else:    
                MESSAGE = "W 0x44A1010C " + str(entry) + '\0' + '\n'                 
                print "Wrote",hex(entry),"to User Defined REG 3"
                data = self.udp.udp_client(MESSAGE,self.UDP_IP,self.UDP_PORT)
                myData = string.split(data,'\n')
                #textBox.set_text(myData[2])

        except IOError as e:
            myMsg = "I/O Error:  {1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except ValueError:
            myMsg = "a ValueError exception occurred\nUser Defined Reg 3 Value not hexadecimal."
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Writing to User Defined Reg 3:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")


    def write_button_Reg4_callback(self, widget, textBox):
        try:
            entry = int(textBox.get_text(),base=16)
            if entry > 0xffffffff:
                myMsg = "a ValueError exception occurred\nUser Defined Reg 4 Value > 0xFFFFFFFF."
                self.on_erro(widget, myMsg)
            else:    
                MESSAGE = "W 0x44A10110 " + str(entry) + '\0' + '\n'                                                
                print "Wrote",hex(entry),"to User Defined REG 4"
                data = self.udp.udp_client(MESSAGE,self.UDP_IP,self.UDP_PORT)
                myData = string.split(data,'\n')
                #textBox.set_text(myData[2])

        except IOError as e:
            myMsg = "I/O Error:  {1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except ValueError:
            myMsg = "a ValueError exception occurred\nUser Defined Reg 4 Value not hexadecimal."
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Writing to User Defined Reg 4:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")

    def write_button_Reg5_callback(self, widget, textBox):
        try:
            entry = int(textBox.get_text(),base=16)
            if entry > 0xffffffff:
                myMsg = "a ValueError exception occurred\nReg 5 Value > 0xFFFFFFFF."
                self.on_erro(widget, myMsg)
            else:    
                MESSAGE = "w 0x44A10114 " + str(entry) + '\0' + '\n'
                print "Wrote",hex(entry),"to User Defined Reg 5"
                data = self.udp.udp_client(MESSAGE,self.UDP_IP,self.UDP_PORT)
                myData = string.split(data,'\n')
                #textBox.set_text(myData[2])

        except IOError as e:
            myMsg = "I/O Error:  {1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except ValueError:
            myMsg = "a ValueError exception occurred\nCtrl Reg 63 Value not hexadecimal."
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Writing to Ctrl Reg 63:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")

    def write_button_RegN_callback(self, widget, textBox0, textBox1):
        try:
            addr  = textBox0.get_text()
            entry = textBox1.get_text()
            if int(entry, base=16) > int("0xffffffff", base=16):
                myMsg = "a ValueError exception occurred\nReg Value > 0xFFFFFFFF."
                self.on_erro(widget, myMsg)
            else:    
                MESSAGE = "w " + str(addr) + " " + str(entry) + '\0' + '\n'
                print "Wrote", entry, "to User Defined Reg", addr
                data = self.udp.udp_client(MESSAGE, self.UDP_IP, self.UDP_PORT)
                myData = string.split(data,'\n')
                #textBox.set_text(myData[2])
        except IOError as e:
            myMsg = "I/O Error:  {1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except ValueError:
            myMsg = "a ValueError exception occurred\nCtrl Reg 63 Value not hexadecimal."
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Writing to Ctrl Reg 63:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")


    #==========================  READ BUTTONS  ===========================   
    def read_button_statusReg1_callback(self, widget, textBox):
        """
        try:
            # IPbus Transaction
            
            #entry = self.hw.getNode("B").getNode("A0").read()
            #self.hw.dispatch()
            
            #print "Status Reg 1 value =",             
            # Enter into box.
            #textBox.set_text(hex(entry))
            #print "Status Reg 1 contains", hex(entry)
        """
        MESSAGE = "r 0x44A10000 1\n"
        data = self.udp.udp_client(MESSAGE,self.UDP_IP,self.UDP_PORT)
        myData = string.split(data,' ')
        textBox.set_text(myData[2])
        print "Should be 0xC0FFEE00"
        """"    
        except IOError as e:
            myMsg = "I/O Error Reading Status Reg 1:\n{1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Errohw.getNoder Reading Status Reg 1:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")
        " """       


# Reg 1 Read
    def read_button_Reg1_callback(self, widget, textBox): 
#        MESSAGE = "r 0x40000100 1\n"
        MESSAGE = "r 0x44A10104 1\n"
        data = self.udp.udp_client(MESSAGE,self.UDP_IP,self.UDP_PORT)
        myData = string.split(data,' ')
        textBox.set_text(myData[2])        
#        textBox.set_text(myData[1])        


# Reg 2 Read
    def read_button_Reg2_callback(self, widget, textBox):
        try:          
#            MSG = "r 0x44A10104 1\n"
            MSG = "r 0x44A10108 1\n"
            data = self.udp.udp_client(MSG,self.UDP_IP,self.UDP_PORT)
            myData = string.split(data,' ')
            textBox.set_text(myData[2])        
       
        except IOError as e:
            myMsg = "I/O Error Reading Reg 2:\n{1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Reading Reg 2:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")
       

# Reg 3 Read
    def read_button_Reg3_callback(self, widget, textBox):
        try:
#            MSG = "r 0x44A10108 1\n"
            MSG = "r 0x44A1010C 1\n"
            data = self.udp.udp_client(MSG,self.UDP_IP,self.UDP_PORT)
            myData = string.split(data,' ')
            textBox.set_text(myData[2])        
          
        except IOError as e:
            myMsg = "I/O Error Reading Reg 3:\n{1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Reading Reg 3:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")


# Reg 4 Read
    def read_button_Reg4_callback(self, widget, textBox):
        try:
            MSG = "r 0x44A10110 1\n"
            data = self.udp.udp_client(MSG,self.UDP_IP,self.UDP_PORT)
            myData = string.split(data,' ')
            textBox.set_text(myData[2])        
          
        except IOError as e:
            myMsg = "I/O Error Reading Reg 4:\n{1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Reading Reg 4:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")


# Reg 5 Read
    def read_button_Reg5_callback(self, widget, textBox):
        try:
            MSG = "r 0x44A1014C 1\n"
#            MSG = "r 0x44A10114 1\n"
            data = self.udp.udp_client(MSG,self.UDP_IP,self.UDP_PORT)
            myData = string.split(data,' ')
            textBox.set_text(myData[2])        
          
        except IOError as e:
            myMsg = "I/O Error Reading Reg 5:\n{1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Reading Reg 5:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")

# Reg N Read
    def read_button_RegN_callback(self, widget, textBox0, textBox1):
        try:
            addr  = textBox0.get_text()
            print addr
            MESSAGE = "r " + str(addr) + " " + '1' + '\n'
            print "Read to User Defined Reg", addr
            data = self.udp.udp_client(MESSAGE, self.UDP_IP, self.UDP_PORT)
            myData = string.split(data,' ')
            textBox1.set_text(myData[2])
        except IOError as e:
            myMsg = "I/O Error:  {1}".format(e.errno, e.strerror)
            self.on_erro(widget, myMsg)
        except:
            print "Unexpected Error Reading to Reg N:\n", sys.exc_info()[0]
            self.on_erro(widget, "Unexpected Error:\nDetails printed to shell.")


    ######################################################################
    #
    #
    #                          __init__
    #
    #
    ######################################################################

    def __init__(self):       
        self.userRegs_box = gtk.VBox(homogeneous=False)
        self.table = gtk.Table(rows=4, columns=4, homogeneous=False)
        self.table.set_row_spacings(10)
        self.table.set_col_spacings(10)
        self.UDP_IP = ""
        self.UDP_PORT=50001
        self.udp = udp_stuff()
        self.topfiller_label_1 = gtk.Label("")
        self.topfiller_label_1a = gtk.Label("")
        self.topfiller_label_2 = gtk.Label(" Registers\n(press buttons to activate)")
        self.topfiller_label_2.set_markup('<span color="blue" size="24000" ><b> Registers</b></span>\n<span><b>(press buttons to activate)</b></span>')
        self.bottomfiller_label_3 = gtk.Label("")
        self.bottomfiller_label_4 = gtk.Label("")
        self.top = gtk.VBox(homogeneous=True,spacing=0)
        self.top.pack_start(self.topfiller_label_1,expand=True)
        self.top.pack_start(self.topfiller_label_1a,expand=True)
        self.top.pack_start(self.topfiller_label_2,expand=True)
        self.bottom = gtk.VBox(homogeneous=True,spacing=0)
        self.bottom.pack_start(self.bottomfiller_label_3,expand=True)
        self.bottom.pack_start(self.bottomfiller_label_4,expand=True)
        self.leftfiller_label = gtk.Label("") 

        #self.leftfiller_label.set_markup('<span color="blue"><b>38-Bit FIFO CTRL/STATUS</b></span>\n<span>    (0x44A1_0082)\n<b>------------------------------</b> \
                #\nWRITE\nBit 3 = FIFO41 reset\nBit 5 = FIFO38 read enable\n\nREAD\nBit 0 = almost empty\nBit 1 = empty \
                #\nBit 2 = almost full\nBit 3 = full</span>')
        self.rightfiller_label = gtk.Label("")

        #self.rightfiller_label.set_markup('<span color="blue"><b>CFG CTRL/STATUS REG A63</b></span>\n<span>    (0x44A1_01FF)\n<b>------------------------------</b> \

        #       \nBIT 0 = VMM CFG load Enable\nBIT 1 = cfg_run \
        #        \nBIT 2 = gbl_rst\nBIT 3 = acq_rst\nBIT 4 = ENA [0,1]\nBIT 5 = CKTP (1=run)  \
        #        \nBIT 6 = token clock (1=enable)\nBIT 8:7 = token clock delay\nBIT 11:9 = CFG clock delay\nBIT 31:12 = 0</span>')
        self.label_title_a = gtk.Label("32-bit Hexadecimal")
        self.label_title_b = gtk.Label("32-bit Hexadecimal")        
    
        ###  text boxes ###
        self.write_entry_statusReg1 = gtk.Entry(max=13)
        self.write_entry_statusReg1.set_text("Read Only Reg")
        self.write_entry_statusReg1.set_editable(False)        
        self.write_entry_Reg1 = gtk.Entry(max=10)
        self.write_entry_Reg1.set_text("0")
        
        self.write_entry_Reg2 = gtk.Entry(max=10)
        self.write_entry_Reg2.set_text("0")
        
        self.write_entry_Reg3 = gtk.Entry(max=10)
        self.write_entry_Reg3.set_text("0")

        self.write_entry_Reg4 = gtk.Entry(max=10)
        self.write_entry_Reg4.set_text("0")
        
        self.write_entry_Reg5 = gtk.Entry(max=10)
        self.write_entry_Reg5.set_text("0")

        self.write_entry_RegN = gtk.Entry(max=10)
        self.write_entry_RegN.set_text("0")

        self.write_addr_RegN = gtk.Entry(max=10)
        self.write_addr_RegN.set_text("0x44A1xxxx")


        ### the following have been set to read only
        self.read_entry_statusReg1 = gtk.Entry()
        self.read_entry_statusReg1.set_text("")
        self.read_entry_statusReg1.set_editable(False)
        
        self.read_entry_Reg1 = gtk.Entry()
        self.read_entry_Reg1.set_text("")
        self.read_entry_Reg1.set_editable(False)
        
        self.read_entry_Reg2 = gtk.Entry(max=10)
        self.read_entry_Reg2.set_text("")
        self.read_entry_Reg2.set_editable(False)
        
        self.read_entry_Reg3 = gtk.Entry(max=10)
        self.read_entry_Reg3.set_text("")
        self.read_entry_Reg3.set_editable(False)
        
        self.read_entry_Reg4 = gtk.Entry(max=10)
        self.read_entry_Reg4.set_text("")
        self.read_entry_Reg4.set_editable(False)

        self.read_entry_Reg5 = gtk.Entry(max=10)
        self.read_entry_Reg5.set_text("")
        self.read_entry_Reg5.set_editable(False)

        self.read_entry_RegN = gtk.Entry(max=10)
        self.read_entry_RegN.set_text("")
        self.read_entry_Reg5.set_editable(False)

        self.read_addr_RegN = gtk.Entry(max=10)
        self.read_addr_RegN.set_text("0x44A1xxxx")


        ### page 9 buttons ###
        
        self.write_button_statusReg1 = gtk.Button("WRITE\nStatus Reg 1")
        self.write_button_statusReg1.set_sensitive(False)
        self.write_button_Reg1 = gtk.Button("WRITE Reg 1\n0x44A10104")
        self.write_button_Reg2 = gtk.Button("WRITE Reg 2\n0x44A10108")
        self.write_button_Reg3 = gtk.Button("WRITE Reg 3\n0x44A1010C")
        self.write_button_Reg4 = gtk.Button("WRITE Reg 4\n0x44A10110")
        self.write_button_Reg5 = gtk.Button("WRITE Reg 5\n0x44A10114")
        self.write_button_RegN = gtk.Button("WRITE Reg N")

        self.write_button_statusReg1.child.set_justify(gtk.JUSTIFY_CENTER)
        self.write_button_Reg1.child.set_justify(gtk.JUSTIFY_CENTER)
        self.write_button_Reg2.child.set_justify(gtk.JUSTIFY_CENTER)
        self.write_button_Reg3.child.set_justify(gtk.JUSTIFY_CENTER)
        self.write_button_Reg4.child.set_justify(gtk.JUSTIFY_CENTER)
        self.write_button_Reg5.child.set_justify(gtk.JUSTIFY_CENTER)
        self.write_button_RegN.child.set_justify(gtk.JUSTIFY_CENTER)

        self.write_button_statusReg1.set_size_request(100,45)
        self.write_button_Reg1.set_size_request(100,45)
        self.write_button_Reg2.set_size_request(100,45)
        self.write_button_Reg3.set_size_request(100,45)
        self.write_button_Reg4.set_size_request(100,45)
        self.write_button_Reg5.set_size_request(100,45)
        self.write_button_RegN.set_size_request(100,45)

        self.write_button_statusReg1.connect("clicked", self.write_button_statusReg1_callback,self.write_entry_statusReg1)
        self.write_button_Reg1.connect("clicked", self.write_button_Reg1_callback, self.write_entry_Reg1)
        self.write_button_Reg2.connect("clicked", self.write_button_Reg2_callback, self.write_entry_Reg2)
        self.write_button_Reg3.connect("clicked", self.write_button_Reg3_callback, self.write_entry_Reg3)
        self.write_button_Reg4.connect("clicked", self.write_button_Reg4_callback, self.write_entry_Reg4)
        self.write_button_Reg5.connect("clicked", self.write_button_Reg5_callback, self.write_entry_Reg5)
        self.write_button_RegN.connect("clicked", self.write_button_RegN_callback, self.write_addr_RegN, self.write_entry_RegN)

        self.read_button_statusReg1 = gtk.Button("READ\nAxi_Reg_0")
        self.read_button_Reg1 = gtk.Button("READ Reg 1\nAxi_Reg_61")
        self.read_button_Reg2 = gtk.Button("READ Reg 2\nAxi_Reg_62")
        self.read_button_Reg3 = gtk.Button("READ Reg 3\nAxi_Reg_63")
        self.read_button_Reg4 = gtk.Button("READ Reg 4\nAxi_Reg_64")
        self.read_button_Reg5 = gtk.Button("READ Reg 5\nAxi_Reg_79")
        self.read_button_RegN = gtk.Button("READ Reg N\nAxi_Reg_N")

        self.read_button_statusReg1.child.set_justify(gtk.JUSTIFY_CENTER)
        self.read_button_Reg1.child.set_justify(gtk.JUSTIFY_CENTER)
        self.read_button_Reg2.child.set_justify(gtk.JUSTIFY_CENTER)
        self.read_button_Reg3.child.set_justify(gtk.JUSTIFY_CENTER)
        self.read_button_Reg4.child.set_justify(gtk.JUSTIFY_CENTER)
        self.read_button_Reg5.child.set_justify(gtk.JUSTIFY_CENTER)
        self.read_button_RegN.child.set_justify(gtk.JUSTIFY_CENTER)

        self.read_button_statusReg1.set_size_request(100,45)
        self.read_button_Reg1.set_size_request(100,45)
        self.read_button_Reg2.set_size_request(100,45)
        self.read_button_Reg3.set_size_request(100,45)
        self.read_button_Reg4.set_size_request(100,45)
        self.read_button_Reg5.set_size_request(100,45)
        self.read_button_RegN.set_size_request(100,45)
 
        self.read_button_statusReg1.connect("clicked", self.read_button_statusReg1_callback, self.read_entry_statusReg1) 
        self.read_button_Reg1.connect("clicked", self.read_button_Reg1_callback, self.read_entry_Reg1)
        self.read_button_Reg2.connect("clicked", self.read_button_Reg2_callback, self.read_entry_Reg2)
        self.read_button_Reg3.connect("clicked", self.read_button_Reg3_callback, self.read_entry_Reg3)
        self.read_button_Reg4.connect("clicked", self.read_button_Reg4_callback, self.read_entry_Reg4)
        self.read_button_Reg5.connect("clicked", self.read_button_Reg5_callback, self.read_entry_Reg5)
        self.read_button_RegN.connect("clicked", self.read_button_RegN_callback, self.read_addr_RegN, self.read_entry_RegN)


        ### pack user defined register boxes ###
        self.table.attach(self.label_title_a, left_attach=4, right_attach=5, top_attach=0, bottom_attach=1, xpadding=0, ypadding=0)
        self.table.attach(self.label_title_b, left_attach=6, right_attach=7, top_attach=0, bottom_attach=1, xpadding=0, ypadding=0)
        self.table.attach(self.leftfiller_label, left_attach=0, right_attach=3, top_attach=0, bottom_attach=4, xpadding=40, ypadding=20)
        self.table.attach(self.rightfiller_label, left_attach=7, right_attach=10, top_attach=0, bottom_attach=4, xpadding=40, ypadding=20)        
        self.table.attach(self.write_button_statusReg1, left_attach=3, right_attach=4, top_attach=1, bottom_attach=2, xpadding=10, ypadding=20)
        self.table.attach(self.write_button_Reg1, left_attach=3, right_attach=4, top_attach=2, bottom_attach=3, xpadding=10, ypadding=20)
        self.table.attach(self.write_button_Reg2, left_attach=3, right_attach=4, top_attach=3, bottom_attach=4, xpadding=10, ypadding=20)
        self.table.attach(self.write_button_Reg3, left_attach=3, right_attach=4, top_attach=4, bottom_attach=5, xpadding=10, ypadding=20)
        self.table.attach(self.write_button_Reg4, left_attach=3, right_attach=4, top_attach=5, bottom_attach=6, xpadding=10, ypadding=20)
        self.table.attach(self.write_button_Reg5, left_attach=3, right_attach=4, top_attach=6, bottom_attach=7, xpadding=10, ypadding=20)
        self.table.attach(self.write_button_RegN, left_attach=3, right_attach=4, top_attach=7, bottom_attach=8, xpadding=10, ypadding=20)
        self.table.attach(self.write_entry_statusReg1, left_attach=4, right_attach=5, top_attach=1, bottom_attach=2, xpadding=60, ypadding=20)
        self.table.attach(self.write_entry_Reg1, left_attach=4, right_attach=5, top_attach=2, bottom_attach=3, xpadding=60, ypadding=20)
        self.table.attach(self.write_entry_Reg2, left_attach=4, right_attach=5, top_attach=3, bottom_attach=4, xpadding=60, ypadding=20)
        self.table.attach(self.write_entry_Reg3, left_attach=4, right_attach=5, top_attach=4, bottom_attach=5, xpadding=60, ypadding=20)
        self.table.attach(self.write_entry_Reg4, left_attach=4, right_attach=5, top_attach=5, bottom_attach=6, xpadding=60, ypadding=20)
        self.table.attach(self.write_entry_Reg5, left_attach=4, right_attach=5, top_attach=6, bottom_attach=7, xpadding=60, ypadding=20)
        self.table.attach(self.write_addr_RegN,  left_attach=4, right_attach=5, top_attach=7, bottom_attach=8, xpadding=60, ypadding=0)
        self.table.attach(self.write_entry_RegN, left_attach=4, right_attach=5, top_attach=8, bottom_attach=9, xpadding=60, ypadding=0)
        self.table.attach(self.read_button_statusReg1, left_attach=5, right_attach=6, top_attach=1, bottom_attach=2, xpadding=20, ypadding=20)
        self.table.attach(self.read_button_Reg1, left_attach=5, right_attach=6, top_attach=2, bottom_attach=3, xpadding=20, ypadding=20)
        self.table.attach(self.read_button_Reg2, left_attach=5, right_attach=6, top_attach=3, bottom_attach=4, xpadding=20, ypadding=20)
        self.table.attach(self.read_button_Reg3, left_attach=5, right_attach=6, top_attach=4, bottom_attach=5, xpadding=20, ypadding=20)
        self.table.attach(self.read_button_Reg4, left_attach=5, right_attach=6, top_attach=5, bottom_attach=6, xpadding=20, ypadding=20)
        self.table.attach(self.read_button_Reg5, left_attach=5, right_attach=6, top_attach=6, bottom_attach=7, xpadding=20, ypadding=20)
        self.table.attach(self.read_button_RegN, left_attach=5, right_attach=6, top_attach=7, bottom_attach=8, xpadding=20, ypadding=20)
        self.table.attach(self.read_entry_statusReg1, left_attach=6, right_attach=7, top_attach=1, bottom_attach=2, xpadding=60, ypadding=20)
        self.table.attach(self.read_entry_Reg1, left_attach=6, right_attach=7, top_attach=2, bottom_attach=3, xpadding=60, ypadding=20)
        self.table.attach(self.read_entry_Reg2, left_attach=6, right_attach=7, top_attach=3, bottom_attach=4, xpadding=60, ypadding=20)
        self.table.attach(self.read_entry_Reg3, left_attach=6, right_attach=7, top_attach=4, bottom_attach=5, xpadding=60, ypadding=20)
        self.table.attach(self.read_entry_Reg4, left_attach=6, right_attach=7, top_attach=5, bottom_attach=6, xpadding=60, ypadding=20)
        self.table.attach(self.read_entry_Reg5, left_attach=6, right_attach=7, top_attach=6, bottom_attach=7, xpadding=60, ypadding=20)
        self.table.attach(self.read_entry_RegN, left_attach=6, right_attach=7, top_attach=7, bottom_attach=8, xpadding=60, ypadding=20)
        self.table.attach(self.read_addr_RegN, left_attach=6, right_attach=7, top_attach=8, bottom_attach=9, xpadding=60, ypadding=20)

        self.userRegs_box.pack_start(self.top)
        self.userRegs_box.pack_start(self.table, fill=False)
        self.userRegs_box.pack_start(self.bottom)
        



