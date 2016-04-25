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

class udp_stuff:


    def __init__(self):
        self.UDP_IP = ""
        self.UDP_PORT = 50001
        return
    """
    def set_udp_ip(self, NEW_UDP_IP):
        self.UDP_IP = NEW_UDP_IP
        print "New ip addr set in mmfe8_udp.py class udp_stuff = " + self.UDP_IP

    def set_udp_port(self, NEW_UDP_PORT):
        self.UDP_PORT = NEW_UDP_PORT        
        print "New port set in mmfe8_udp.py class udp_stuff = " + str(self.UDP_PORT)
    """
    def udp_client(self, MESSAGE, myUDP_IP, myUDP_PORT=50001):
        self.UDP_IP = myUDP_IP 
        self.UDP_PORT = myUDP_PORT       
        sock = socket.socket(socket.AF_INET, # Internet
             socket.SOCK_DGRAM) # UDP 
        sock.settimeout(5)

        MESSAGE = MESSAGE.replace("\0", "")
        MESSAGE = MESSAGE.replace("\n", "")
#        print "replaced stuff"
        MESSAGE += "\0\n"

        try:
            #send data
#            print >>sys.stderr, 'sending "%s"' % MESSAGE
#            print "to " + self.UDP_IP + ", " + str(self.UDP_PORT)
            sent = sock.sendto(MESSAGE,(self.UDP_IP, self.UDP_PORT))
            #receive response
#            print >>sys.stderr, 'waiting for response'
            data, server = sock.recvfrom(4096)
#            print >>sys.stderr, 'received:\n' + data
        except:
            print "ERROR:  ", sys.exc_info()[0]
#        print "closing socket\n--=====================--\n"
        sock.close()
        return data


        

    """
    def daq_ReadOutserver(self):
        # This creates a new thread to read each data packet
        loopback = False
        active = self.combo_vmm2_id.get_active()
        sock = socket.socket(socket.AF_INET, # Internet
                      socket.SOCK_DGRAM) # UDP
        if active == 0:
            UDP_IP = self.ipAddr[0] # loopback
            UDP_PORT = self.UDP_PORT_data
            loopback = True
        else:
            UDP_IP = hostAddr
            UDP_PORT = hostPort
        #    sock.bind((UDP_IP, UDP_PORT))
        print("DAQ Read Out Server Started")
        while True:
            if self.stopReadOut:
                print("Exiting DAQ Read Out Server.")
                break
            n = 1
            if loopback:
                data = ""
                for n in range(60):
                    sleep(0.001)
                    Vmm = random.randint(0, 7) << 6
                    BC = random.randint(0, 4196)
                    BCtop = BC >> 6
                    BClow = (BC & 0x3F) << 26
                    Tim = random.randint(0, 255) << 18
                    Amp = random.randint(0, 1023) << 8
                    Addr = random.randint(0, 63) << 2
                    data2 = Vmm + BCtop
                    data1 = BClow + Tim + Amp + Addr + 2
                    data = data + "0x" + str(hex(data1)) + " 0x" + str(hex(data2)) + " "
            else:         
                #    data, addr = sock.recvfrom(2048) # buffer size is 2048 bytes
                continue
            try:
                thread.start_new_thread(handleData, data)
                n = n + 1
            except:
                print "Error:  Unable to start thread {0}.".format(n)        
    """
   


