def convert_to_int(list_of_bits):
    this = "0b"
    for bit in list_of_bits:
        this += str(bit)
    return int(this, base=2)

def convert_to_32bit(list_of_bits):
    return sum([int(list_of_bits[bit])*pow(2, bit) for bit in xrange(32)])

def convert_to_bits(word32):
    return [int(bit) for bit in reversed("{0:032b}".format(word32))]

