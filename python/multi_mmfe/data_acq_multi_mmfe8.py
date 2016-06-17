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
waiting = 0

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

    def check_first_board_flag(self):
        while True:
            if reading is 1:
#                print "reading!!"
                firstboard = MMFEs[0]
                global ready
                ready = firstboard.check_for_data_flag()
                
    def readout_board(self, board, ind):
        bcidold = 0
        while True:
            if waiting is 1:
                global ready
                if ready is 1:
#                    print "found flag!"
                    reading = 0 # stop checking for read flag
                    # only allow one readout per trigger                                                                                                                                         
                    bcidtemp = board.readOut_BCID(ind)
                    if bcidold == bcidtemp:
                        continue
                    bcidold = bcidtemp
                    board.start(ind)
                    reading = 1
        
if __name__=="__main__":

    threads = []
    data_take = data_acq()
    global ready
    
    
    # setting up board ips
    for mmfe in xrange(nmmfes):
        ip_addresses.append("192.168.0." + raw_input("Enter in %i IP Address: " % (mmfe+1)))
        print ip_addresses[mmfe]
    data_take.set_ip()

    #checking for data

    print "TO USE THIS, MAKE SURE TIME FOR TRIGGER DATA IS SET CORRECTLY\n"

#    threads.append(thr.Thread(target=data_take.check_first_board_flag))
    ready = 0
    waiting = 1
    for board in MMFEs:
        threads.append(thr.Thread(target=data_take.readout_board, args=(board,MMFEs.index(board))))
    threads.append(thr.Thread(target=data_take.check_first_board_flag))
    starting = raw_input("To start data taking, enter 1: ")
    if starting is "1":
        waiting = 1
        reading = 1
#        for board in MMFEs:
#            threads[MMFEs.index(board)].start(board,MMFEs.index(board))
        for thread in threads:
            thread.start()
    user_input = raw_input("To stop data taking, enter 0: ")
    if user_input is "0":
        print "oops, we stopped!"
        waiting = 0
        reading = 0
