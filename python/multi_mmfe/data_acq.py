import time
import numpy as np
import sys


from multiprocessing import Process
import threading as thr

from udp import udp_stuff
from mmfe8_daq    import MMFE
from vmm     import VMM, registers
from udp     import udp_stuff
from channel import index
from helpers import convert_to_int, convert_to_32bit

nmmfes    = 1 if len(sys.argv)==1 else int(sys.argv[1])
nvmms     = 8
nchannels = 64
ip_addresses = []
MMFEs = []
reading = 0

class data_acq:
    
    def __init__(self):
        print
        print "Loading MMFE8 GUI with %i MMFE" % (nmmfes)
        print 
        
        for i in xrange(nmmfes):
            MMFEs.append(MMFE())

    def set_ip(self):
        ind = 0
        for board in MMFEs:
            board.set_ip(ip_addresses[ind])
            ind = ind + 1

    def start():
        #doesn't seem to work inside a function#
        t1 = thr.Thread(target=thread1)
        t2 = thr.Thread(target=thread2)
        t1.start()
        t2.start()
        user_input = raw_input("1 to stop")
        if user_input is "1":
            print "hi"
            con = 0
            print "turned off!!"
        while True:
            pass
                
    def check_first_board_flag(self):
        while reading is 1:
            firstboard = MMFEs[0]
            print "shit"
            ready = firstboard.check_for_data_flag()
            if ready is 1:
                ind = 0
                for board in MMFes:
                    board.daq_readOut_quiet(ind)
                    ind = ind + 1
        print "done reading!\n"
        
    def thread1(self):
        global con
        while con is 1:
            print "hi\n"
            print "thread1 done!"
        return

if __name__=="__main__":

    threads = []
    data_take = data_acq()
    global con
    con = 1
    
    # setting up board ips
    for mmfe in xrange(nmmfes):
        ip_addresses.append("192.168.0." + raw_input("Enter in %i IP Address: " % (mmfe+1)))
        print ip_addresses[mmfe]
    data_take.set_ip()

    #checking for data
    for board in MMFEs:
        #threads.append(thr.Thread(target=data_take.thread1)) #this is a test thread function
        threads.append(thr.Thread(target=data_take.check_first_board_flag))
    starting = raw_input("To start data taking, enter 1")
    if starting is "1":
        reading = 1
        for thread in threads:
            thread.start()
    user_input = raw_input("To stop data taking, enter 0")
    if user_input is "0":
        print "oops, we stopped!"
        con = 0
        reading = 0
        print "Am I reading? ", reading
#    while True:
#        pass

