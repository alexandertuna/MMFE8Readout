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
    num_trig = 0
    for line in datafile:
        thisline = line.split()
        if len(thisline) < 2:
            continue
        if thisline[2]=='!Err':
            print "skip"
            continue
        fifocount = int(thisline[0])
        fifotrig = int(thisline[1], 16)
        if num_trig != int(fifotrig & 1048575):
            numwordsread = 0
        num_trig = int(fifotrig & 1048575)
        print "num_trig: ",num_trig,"\n"
        fifotrig = fifotrig >> 20
        bcid_trig = int(fifotrig & 4095)
        print "bcid_trig: ",bcid_trig,"\n"
        print "thisline: ", thisline,"\n"
        linelength = 0
        for word in xrange(4,len(thisline)):
            if int(thisline[word],16) > 0:
                linelength = linelength + 1
        numwordsread = numwordsread + linelength
        header = "fifo_cnt = %s num_words_read = %s bcid_trig = %s num_trig = %s "
        decodedfile.write(header % (fifocount, numwordsread, bcid_trig, num_trig) + '\n')

    decodedfile.close()
    datafile.close()
    print "done decoding, exiting \n"
    

if __name__ == "__main__":
    main(sys.argv[1:])
