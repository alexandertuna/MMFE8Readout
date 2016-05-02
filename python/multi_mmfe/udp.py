#    by Charlie Armijo, Ken Johns, Bill Hart, Sarah Jones, James Wymer, Kade Gigliotti
#    Experimental Elementary Particle Physics Laboratory
#    Physics Department
#    University of Arizona    
#    armijo at physics.arizona.edu
#    johns at physics.arizona.edu
#
#    This is version 7 of the MMFE8 GUI

import os
import sys
import socket

class udp_stuff:

    def __init__(self):
        self.UDP_IP = ""
        self.UDP_PORT = 50001

    def udp_client(self, MESSAGE, myUDP_IP, myUDP_PORT=50001, ping=False, debug=False):
        self.UDP_IP   = myUDP_IP 
        self.UDP_PORT = myUDP_PORT       
        sock = socket.socket(socket.AF_INET,    # Internet
                             socket.SOCK_DGRAM) # UDP 
        sock.settimeout(2)

        MESSAGE = MESSAGE.replace("\0", "")
        MESSAGE = MESSAGE.replace("\n", "")
        MESSAGE += " \0\n"

        if ping:
            attempt = 0
            while os.system("ping %s -c 1 > /dev/null" % (self.UDP_IP)):
                print "Ping attempt %s to %s failed. Trying again." % (attempt, self.UDP_IP)
                attempt += 1
            if attempt > 0:
                print "Ping attempt %s succeeded." % (attempt)

        try:
            if debug:
                print "Sending %r to %s :: %s" % (MESSAGE, self.UDP_IP, self.UDP_PORT)

            sent = sock.sendto(MESSAGE,(self.UDP_IP, self.UDP_PORT))
            data, server = sock.recvfrom(4096)

            if debug:
                print "Receive %r" % (data)
                
        except:
            print "ERROR: UDP communication failed.", sys.exc_info()[0]
            return

        if debug:
            print "Closing socket"
            print
        sock.close()
        return data

