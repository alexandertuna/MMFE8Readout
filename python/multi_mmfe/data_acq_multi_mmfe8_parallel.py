import time
import numpy as np
import sys


import multiprocessing as mp

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
# reading = 0
# waiting = 0
# ready = 0
# notchecking = 1
# all_done = []

class data_acq:
    
    def __init__(self):
        print
        print "Loading MMFE8 GUI with %i MMFE" % (nmmfes)
        print 
        
        for i in xrange(nmmfes):
            MMFEs.append(MMFE())
        self.reading = 0
        self.waiting = 0
        self.ready = 0
        self.time = 0
        self.lock = mp.Lock()
        self.exit = mp.Event()

    def set_ip(self):
        ind = 0
        for board in MMFEs:
            board.set_ip(ip_addresses[ind])
            ind = ind + 1

    def check_first_board_flag(self,cond, cond2,stop):
        bcidold = 0
        self.reading = 1
        while not self.exit.is_set():
            if self.reading is 1:
                found = MMFEs[0].check_for_data_flag()
                if found is 1:
                    bcidtemp = board.readOut_BCID(0)
                    if (bcidold == bcidtemp):
                        continue
                    bcidold = bcidtemp
                    with cond:
                        cond.notify_all()
                    cond2.acquire()
                    cond2.wait()
    def readout_board(self, board, ind, cond,cond2,stop):
        bcidold = 0
        while not self.exit.is_set():
#            print "chjeck"
            if self.reading is 0:
                break
            with cond:
                cond.wait()
                bcidnow = board.readOut_BCID(ind)
                board.start(ind)
                if ind is 0:
                    cond2.acquire()
                    cond2.notify()
                    cond2.release()
    def shutdown(self):
        self.exit.set()

if __name__=="__main__":

    threads = []
    data_take = data_acq()
    
    # setting up board ips
    for mmfe in xrange(nmmfes):
        ip_addresses.append("192.168.0." + raw_input("Enter in %i IP Address: " % (mmfe+1)))
        print ip_addresses[mmfe]
    data_take.set_ip()

    #checking for data

    print "TO USE THIS, MAKE SURE TIME FOR TRIGGER DATA IS SET CORRECTLY\n"

    cond = mp.Condition()
    cond2 = mp.Condition()
    stop = mp.JoinableQueue()
    for board in MMFEs:
        threads.append(mp.Process(target=data_take.readout_board, args=(board,MMFEs.index(board),cond,cond2,stop)))
    threads.append(mp.Process(target=data_take.check_first_board_flag, args=(cond,cond2,stop)))
    starting = raw_input("To start data taking, enter 1: ")
    if starting is "1":
        data_take.reading = 1
        for thread in threads:
            thread.start()
    user_input = raw_input("To stop data taking, enter 0: ")
    if user_input is "0":
        print "oops, we stopped!"
        data_take.shutdown()
        quit()
#        for thread in threads:
#            thread.terminate()
#            thread.join()
