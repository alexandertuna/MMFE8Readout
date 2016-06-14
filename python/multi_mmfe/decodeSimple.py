#!/usr/bin/python

import sys, getopt,binstr


def main(argv):
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv, "hi:o:", ["ifile=", "ofile="])
    except getopt.GetoptError:
        print 'decode.py -i <inputfile> -o <outputfile>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'decode.py -i <inputfile> -o <outputfile>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg

    datafile = open(inputfile, 'r')
    decodedfile = open(outputfile, 'w')
    decodedfile.write('fifo_cnt \t bcid_trig \t num_trig \t channel \t PDO \t TDO \t BCID \t VMM \t MMFE8')
#    num_trig = 0
    for line in datafile:
        thisline = line.split()
        if len(thisline) < 2:
            continue
        if thisline[2]=='!Err':
            print "skip"
            continue
        fifocount = int(thisline[0])
        fifotrig = int(thisline[1], 16)
#        if num_trig != int(fifotrig & 1048575):
#            numwordsread = 0
        num_trig = int(fifotrig & 1048575)
        print "num_trig: ",num_trig,"\n"
        fifotrig = fifotrig >> 20
        bcid_trig = int(fifotrig & 4095)
        print "bcid_trig: ",bcid_trig,"\n"
        print "thisline: ", thisline,"\n"
#        linelength = 0
#        for word in xrange(4,len(thisline)):
#            if int(thisline[word],16) > 0:
#                linelength = linelength + 1
#        numwordsread = numwordsread + linelength
        for iword in xrange(4, (len(thisline)), 2): #get rid of peak command/address and fifo bcid/num trig
            print "iword ",iword
            print thisline[iword]
            word0 = int(thisline[iword],   16)
            word1 = int(thisline[iword+1], 16)
            print word0
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

            decodedfile.write(str(fifocount) + '\t' + str(bcid_trig) + '\t' + str(num_trig) + '\t' + str(thisline[iword]) + '\t'+ str(addr) + '\t' + str(amp) + '\t' + str(timing) + '\t' + str(bcid_int) + str(vmm) + str(immfe))
            # to_print = "word0 = %s word1 = %s addr = %s amp = %s time = %s bcid = %s vmm = %s mmfe = %s"
            # Header = "fifo_cnt = %s bcid_trig = %s num_trig = %s "
            # decodedfile.write(header % (fifocount, bcid_trig, num_trig) + to_print % (thisline[iword], thisline[iword+1],
            #                                                                           str(addr),     str(amp), str(timing),
            #                                                                           str(bcid_int), str(vmm), str(immfe)) + '\n')
    decodedfile.close()
    datafile.close()
    print "done decoding, exiting \n"
    

if __name__ == "__main__":
    main(sys.argv[1:])
