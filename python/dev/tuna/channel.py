import numpy as np

class index:
    SP    =  0 # input charge polarity
    SC    =  1 # large sensor capacitance mode
    SL    =  2 # leakage current disable
    ST    =  3 # test capacitor enable 
    SM    =  4 # mask enable
    SD    =  5 # threshold DAC
    SMX   =  9 # channel monitor mode
    SZ10b = 10 # 10-bit ADC
    SZ8b  = 15 #  8-bit ADC
    SZ6b  = 19 #  6-bit ADC

    bits_SD    = 4
    bits_SZ10b = 5
    bits_SZ8b  = 4
    bits_SZ6b  = 3

class Channel:

    def __init__(self, channel_number):
        self.value = np.zeros((24), dtype=int)

    def get_value(self):
        return self.value

