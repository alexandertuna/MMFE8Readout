import numpy as np
from channel import Channel

class registers:
    SPG    = 16 # input charge polarity
    SDP    = 17 # disable at peak
    SBMX   = 18 # route analog monitor to pdo output
    SBFT   = 19 # analog output buffers enable tdo
    SBFP   = 20 # analog output buffers enable pdo
    SBFM   = 21 # analog output buffers enable mo
    SLG    = 22 # leakage current disable
    SM     = 23 # monitor multiplexing
    SCMX   = 29 # monitor multiplexing enable
    SFA    = 30 # ART enable
    SFAM   = 31 # ART mode
    ST     = 32 # peaking time
    SFM    = 34 # UNKNOWN
    SG     = 35 # gain
    SNG    = 38 # neighbor triggering enable
    STOT   = 39 # timing outputs control
    STTT   = 40 # timing outputs enable
    SSH    = 41 # sub-hysteresis discrimination enable
    STC    = 42 # TAC slope adjustment
    SDT    = 44 # course threshold DAC
    SDP2   = 54 # test pulse DAC
    SC10b  = 65 # 10-bit ADC conversion time
    SC8b   = 67 # 8-bit ADC conversion time
    SC6b   = 70 # 6-bit ADC conversion time
    S8b    = 71 # 8-bit ADC conversion mode
    S6b    = 72 # 6-bit ADC conversion enable
    SPDC   = 73 # ADCs enable
    SDCKS  = 74 # dual clock edge serialized data enable
    SDCKA  = 75 # dual clock edge serialized ART enable
    SDCK6b = 76 # dual clock edge serialized 6-bit enable
    SDRV   = 77 # tristates analog outputs with token, used in analog mode
    STPP   = 78 # timing outputs control 2

    bits_SM    = 6
    bits_ST    = 2
    bits_SG    = 3
    bits_STC   = 2
    bits_SDT   = 10
    bits_SDP2  = 10
    bits_SC10b = 2
    bits_SC8b  = 2
    bits_SC6b  = 3

class VMM:

    def __init__(self):
        self.channel_settings = np.zeros((64, 24), dtype=int)
        self.global_settings  = np.zeros((96),     dtype=int)
        self.reg              = np.zeros((64, 24), dtype=int)
        self.msg              = np.zeros((67),     dtype=np.uint32)
        self.globalreg        = np.zeros((96),     dtype=int)
        self.channels         = []
        for ch in xrange(64):
            self.channels.append(Channel(ch))

    def get_channel_val(self):
        for ch_num in range(64):
            chan_val = self.channels[ch_num].get_chan_val()
            for i in range(24):
                self.reg[ch_num][i] = chan_val[i]
        return self.reg

