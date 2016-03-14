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
import numpy as np
import sys

from mmfe    import MMFE
from vmm     import VMM, registers
from udp     import udp_stuff
from channel import index
from helpers import convert_to_int, convert_to_32bit

nmmfes    = 2
nvmms     = 8
nchannels = 64

class GUI:
    """
    """

    def destroy(self, widget):
        print
        print "Goodbye from the MMFE8 GUI!"
        print
        gtk.main_quit()

    def write_vmm_config(self, widget):
        for mmfe in self.current_MMFEs():
            for vmm in self.current_VMMs(mmfe):
                mmfe.write_vmm_config(widget, vmm)

    def print_vmm_config(self, widget):
        for mmfe in self.current_MMFEs():
            for vmm in self.current_VMMs(mmfe):
                mmfe.print_vmm_config(widget, vmm)

    def read_xadc(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.read_xadc(widget)

    def send_external_trig(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.send_external_trig(widget)

    def leaky_readout(self, widget):
        widget.set_label("Leaky Readout [ON]" if widget.get_active() else "Leaky Readout [OFF]")
        for mmfe in self.current_MMFEs():
            mmfe.leaky_readout(widget)

    def internal_trigger(self, widget):
        widget.set_label("Internal Trigger [ON]" if widget.get_active() else "Internal Trigger [OFF]")
        for mmfe in self.current_MMFEs():
            mmfe.internal_trigger(widget)

    def external_trigger(self, widget):
        widget.set_label("External Trigger [ON]" if widget.get_active() else "External Trigger [OFF]")
        for mmfe in self.current_MMFEs():
            mmfe.external_trigger(widget)

    def set_pulses(self, widget):
        try:
            value = int(widget.get_text())
        except ValueError:
            print "ERROR: Pulses value must be a decimal number"
            return 
        if value < 0 or value > 999: #0x3E7
            print "SDP value out of range"
            print "0 <= Pulses <= 999" 
            return

        for mmfe in self.current_MMFEs():
            mmfe.set_pulses(widget)

    def set_acq_reset_count(self, widget):
        try:
            value = int(widget.get_text(), base=16)
        except ValueError:
            print "acq_count value must be a hex number"
            return
        if value < 0 or value > 0xffffffff: #0x3E7
            print "Acq count value out of range"
            print "0 <= acq_count <= 0xffffffff" 
            return

        for mmfe in self.current_MMFEs():
            mmfe.set_acq_reset_count(widget)

    def send_user_udp(self, widget):
        """
        Communicate with the MMFE directly.
        r for read, w for write, p for poke, k for peek
        Relevant registers include:
            axi_reg(61) <=> 0x44A10104
            axi_reg(62) <=> 0x44A10108
            axi_reg(63) <=> 0x44A1010C
            axi_reg(64) <=> 0x44A10110
            axi_reg(65) <=> 0x44A10114
        """
        message = widget.get_text()

        for mmfe in self.current_MMFEs():
            mmfe.udp_message = message
            mmfe.udp.udp_client(mmfe.udp_message, mmfe.UDP_IP, mmfe.UDP_PORT, debug=True)

    def set_acq_reset_hold(self, widget):
        try:
            value = int(widget.get_text(), base=16)
        except ValueError:
            print "acq_hold value must be a hex number"
            return
        if value < 0 or value > 0xffffffff: #0x3E7
            print "Acq hold value out of range"
            print "0 <= acq_hold <= 0xffffffff" 
            return

        for mmfe in self.current_MMFEs():
            mmfe.set_acq_reset_hold(widget)

    def start(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.start(widget)

    def start_all(self, widget):
        for mmfe in self.MMFEs:
            mmfe.start(widget)

    def reset_global(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.reset_global(widget)

    def system_init(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.system_init(widget)

    def system_load(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.system_load(widget)

    def set_IDs(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.set_IDs(widget)

    def set_ip(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.set_ip(widget)
            self.entry_mmfeID.set_text(str(mmfe.mmfeID))

    def set_display(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.set_display(widget)

    def set_display_no_enet(self, widget):
        for mmfe in self.current_MMFEs():
            mmfe.set_display_no_enet(widget)

    def readout_vmm_callback(self, widget, ivmm):
        for mmfe in self.current_MMFEs():
            mmfe.readout_vmm_callback(widget, ivmm)

    def reset_vmm_callback(self, widget, ivmm):
        for mmfe in self.current_MMFEs():
            mmfe.reset_vmm_callback(widget, ivmm)

    def __init__(self):
        print
        print "loading MMFE8 GUI"
        print 

        self.MMFEs = []
        for i in xrange(nmmfes):
            self.MMFEs.append(MMFE())

        self.tv = gtk.TextView()
        self.tv.set_editable(False)
        self.tv.set_wrap_mode(gtk.WRAP_WORD)
        self.buffer = self.tv.get_buffer()

        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_position(gtk.WIN_POS_CENTER)
        self.window.set_default_size(1440,900)
        self.window.set_resizable(True)
        self.window.set_title("MMFE8 vmm2 Setup GUI (v7.0.0)")
        self.window.set_border_width(0)

        self.notebook = gtk.Notebook()
        self.notebook.set_tab_pos(gtk.POS_TOP)

        self.button_exit = gtk.Button("EXIT")
        self.button_exit.set_size_request(-1,-1)
        self.button_exit.connect("clicked", self.destroy)

        self.button_start = gtk.Button("Start")
        self.button_start.child.set_justify(gtk.JUSTIFY_CENTER)
        self.label_start = self.button_start.get_children()[0]
        self.button_start.set_size_request(-1,-1)
        self.button_start.connect("clicked", self.start)

        self.button_start_all = gtk.Button("Start All MMFE")
        self.button_start_all.modify_bg(gtk.STATE_NORMAL, gtk.gdk.color_parse("#CD5C5C"))
        self.button_start_all.connect("clicked", self.start_all)

        self.label_pulses = gtk.Label()
        self.label_pulses.set_markup('<span color="red"> Pulses [enter] (999 = contin.)</span>')
        self.label_pulses.set_justify(gtk.JUSTIFY_LEFT)
        self.entry_pulses = gtk.Entry(max=3)
        self.entry_pulses.set_size_request(140, -1)
        self.entry_pulses.connect("activate", self.set_pulses)

        self.box_pulses = gtk.HBox()
        self.box_pulses.pack_start(self.entry_pulses, expand=False)
        self.box_pulses.pack_start(self.label_pulses, expand=False)

        self.label_acq_reset_count = gtk.Label("")
        self.label_acq_reset_count.set_markup('<span color="red"> acq_reset_count [enter]</span>')
        self.label_acq_reset_count.set_justify(gtk.JUSTIFY_LEFT)
        self.entry_acq_reset_count = gtk.Entry(max=8)
        self.entry_acq_reset_count.set_size_request(140, -1)
        self.entry_acq_reset_count.connect("activate", self.set_acq_reset_count)
        self.box_acq_reset_count = gtk.HBox()
        self.box_acq_reset_count.pack_start(self.entry_acq_reset_count, expand=False)
        self.box_acq_reset_count.pack_start(self.label_acq_reset_count, expand=False)

        self.label_acq_reset_hold = gtk.Label("")
        self.label_acq_reset_hold.set_markup('<span color="red"> acq_reset_hold [enter]</span>')
        self.label_acq_reset_hold.set_justify(gtk.JUSTIFY_LEFT)
        self.entry_acq_reset_hold = gtk.Entry(max=8)
        self.entry_acq_reset_hold.set_size_request(140, -1)
        self.entry_acq_reset_hold.connect("activate", self.set_acq_reset_hold)
        self.box_acq_reset_hold = gtk.HBox()
        self.box_acq_reset_hold.pack_start(self.entry_acq_reset_hold, expand=False)
        self.box_acq_reset_hold.pack_start(self.label_acq_reset_hold, expand=False)

        self.label_user_udp = gtk.Label("")
        self.label_user_udp.set_markup('<span color="red"> Send User UDP [enter]</span>')
        self.label_user_udp.set_justify(gtk.JUSTIFY_LEFT)
        self.entry_user_udp = gtk.Entry()
        self.entry_user_udp.set_size_request(140, -1)
        self.entry_user_udp.connect("activate", self.send_user_udp)
        self.box_user_udp = gtk.HBox()
        self.box_user_udp.pack_start(self.entry_user_udp, expand=False)
        self.box_user_udp.pack_start(self.label_user_udp, expand=False)

        self.button_resetVMM = gtk.Button("VMM Global Reset")
        self.button_resetVMM.connect("clicked", self.reset_global)

        self.button_SystemInit = gtk.Button("System Reset")
        self.button_SystemInit.connect("clicked", self.system_init)

        self.button_SystemLoad = gtk.Button("VMM Load")
        self.button_SystemLoad.connect("clicked", self.system_load)

        self.label_vmmGlobal_Reset = gtk.Label("vmm2")
        self.label_vmmGlobal_Reset.set_markup('<span color="red">VMMs to Reset / Load</span>')

        self.vmm_reset_table = gtk.Table(rows=2, columns=8, homogeneous=True)
        self.vmm_reset_buttons = []
        for ivmm in xrange(nvmms):
            self.vmm_reset_buttons.append(gtk.CheckButton())
            self.vmm_reset_buttons[ivmm].connect("toggled", self.reset_vmm_callback, ivmm)
            self.vmm_reset_table.attach(gtk.Label(str(ivmm)),         left_attach=ivmm, right_attach=ivmm+1, top_attach=0, bottom_attach=1, xpadding=0, ypadding=0)
            self.vmm_reset_table.attach(self.vmm_reset_buttons[ivmm], left_attach=ivmm, right_attach=ivmm+1, top_attach=1, bottom_attach=2, xpadding=0, ypadding=0)

        self.label_vmmReadoutMask = gtk.Label("vmm2")
        self.label_vmmReadoutMask.set_markup('<span color="red">VMM Readout Enable</span>')

        self.vmm_readout_table = gtk.Table(rows=2, columns=8, homogeneous=True)
        self.vmm_readout_buttons = []
        for ivmm in xrange(nvmms):
            self.vmm_readout_buttons.append(gtk.CheckButton())
            self.vmm_readout_buttons[ivmm].connect("toggled", self.readout_vmm_callback, ivmm)
            self.vmm_readout_table.attach(gtk.Label(str(ivmm)),           left_attach=ivmm, right_attach=ivmm+1, top_attach=0, bottom_attach=1, xpadding=0, ypadding=0)
            self.vmm_readout_table.attach(self.vmm_readout_buttons[ivmm], left_attach=ivmm, right_attach=ivmm+1, top_attach=1, bottom_attach=2, xpadding=0, ypadding=0)

        self.button_print_config = gtk.Button("Print Config")
        self.button_write_config = gtk.Button("Write Config")
        self.button_write_config.connect("clicked", self.write_vmm_config)        
        self.button_print_config.connect("clicked", self.print_vmm_config)

        self.button_configs = gtk.HBox()
        self.button_configs.pack_start(self.button_write_config, expand=True)
        self.button_configs.pack_start(self.button_print_config, expand=True)

        self.label_internal_trigger =  gtk.Label("")
        self.label_internal_trigger.set_markup('<span color="red"> Internal Trigger </span>')
        self.button_internal_trigger = gtk.ToggleButton("Internal Trigger [OFF]")
        self.button_internal_trigger.connect("clicked", self.internal_trigger)
        
        self.label_external_trigger =  gtk.Label("")
        self.label_external_trigger.set_markup('<span color="red"> External Trigger </span>')
        self.button_external_trigger = gtk.ToggleButton("External Trigger [OFF]")
        self.button_external_trigger.connect("clicked", self.external_trigger)

        self.button_ext_trig_pulse = gtk.Button("Send External Trigger")
        self.button_ext_trig_pulse.connect("clicked", self.send_external_trig)
        
        self.label_leaky_readout =  gtk.Label("")
        self.label_leaky_readout.set_markup('<span color="red"> Leaky Readout </span>')
        self.button_leaky_readout = gtk.ToggleButton("Leaky Readout [OFF]")
        self.button_leaky_readout.connect("clicked", self.leaky_readout)
        self.button_leaky_readout.set_size_request(-1,-1)
        
        self.button_read_XADC = gtk.Button("Read XADC")
        self.button_read_XADC.connect("clicked", self.read_xadc)
        self.button_read_XADC.set_size_request(-1,-1)
        
        self.label_mmfe_global = gtk.Label("")
        self.label_mmfe_global.set_markup('<span color="red" size="18000"><b>MMFE Configuration</b></span>')

        self.label_mmfe_number = gtk.Label("")
        self.label_mmfe_number.set_markup('<span color="red"><b>MMFE #</b></span>')
        self.label_mmfe_number.set_justify(gtk.JUSTIFY_CENTER)
        self.combo_mmfe_number = gtk.combo_box_new_text()
        for immfe in xrange(nmmfes):
            self.combo_mmfe_number.append_text(str(immfe))
        self.combo_mmfe_number.connect("changed", self.set_current_mmfe)
        self.box_mmfe_number = gtk.HBox()
        self.box_mmfe_number.pack_start(self.label_mmfe_number, expand=False)
        self.box_mmfe_number.pack_start(self.combo_mmfe_number, expand=False)

        self.label_ip = gtk.Label("")
        self.label_ip.set_markup('<span color="red"> IP Address [enter]</span>')
        self.label_ip.set_justify(gtk.JUSTIFY_LEFT)
        self.entry_ip = gtk.Entry()
        self.entry_ip.set_text("192.168.0.101")
        self.entry_ip.set_editable(True)
        self.entry_ip.connect("activate", self.set_ip)

        self.box_ip = gtk.HBox()
        self.box_ip.pack_start(self.entry_ip, expand=False)
        self.box_ip.pack_start(self.label_ip, expand=False)

        self.combo_display = gtk.combo_box_new_text()
        for i in range(32):
            self.combo_display.append_text(str(hex(i)))
        self.combo_display.connect("changed", self.set_display_no_enet)

        self.button_setIDs = gtk.Button("Set IDs")
        self.button_setIDs.child.set_justify(gtk.JUSTIFY_CENTER)
        self.button_setIDs.set_size_request(-1,-1)        
        self.button_setIDs.connect("clicked", self.set_IDs)
        
        self.label_mmfeID = gtk.Label("")
        self.label_mmfeID.set_markup('<span color="red"> MMFE ID</span>')
        self.label_mmfeID.set_justify(gtk.JUSTIFY_CENTER)
        self.entry_mmfeID = gtk.Entry(max=3)
        self.entry_mmfeID.set_text(str("0"))
        self.box_mmfeID = gtk.HBox()
        self.box_mmfeID.pack_start(self.entry_mmfeID, expand=False)
        self.box_mmfeID.pack_start(self.label_mmfeID, expand=False)

        self.label_display_id = gtk.Label("vmm2")
        self.label_display_id.set_markup('<span color="red">Scope  </span>')
        self.label_display_id.set_justify(gtk.JUSTIFY_CENTER)

        self.label_Space21 = gtk.Label("    ")
        self.box_labelID = gtk.HBox()

        self.box_ResetID = gtk.VBox()
        self.box_ResetID.pack_start(self.label_vmmGlobal_Reset,expand=False)
        self.box_ResetID.pack_start(self.vmm_reset_table,expand=False)
        self.box_ResetID.pack_start(self.button_resetVMM,expand=False)

        self.box_ReadoutMask = gtk.VBox()
        self.box_ReadoutMask.pack_start(self.label_vmmReadoutMask, expand=False)
        self.box_ReadoutMask.pack_start(self.vmm_readout_table,    expand=False)

        self.box_vmmID = gtk.HBox()
        self.box_vmmID.pack_start(self.button_setIDs,    expand=False)
        self.box_vmmID.pack_start(self.label_Space21,    expand=True)
        self.box_vmmID.pack_start(self.label_display_id, expand=False)
        self.box_vmmID.pack_start(self.combo_display,    expand=False)

        self.frame_Reset = gtk.Frame()
        self.frame_Reset.set_shadow_type(gtk.SHADOW_OUT)
        self.frame_Reset.add(self.box_ResetID)

        self.frame_ReadoutMask = gtk.Frame()
        self.frame_ReadoutMask.set_shadow_type(gtk.SHADOW_OUT)
        self.frame_ReadoutMask.add(self.box_ReadoutMask)

        self.box_buttons = gtk.VBox()
        self.box_buttons.set_spacing(5)
        self.box_buttons.set_border_width(5)
        self.box_buttons.set_size_request(-1,-1)

        self.box_mmfe = gtk.VBox()
        self.box_mmfe.set_spacing(5)
        self.box_mmfe.set_border_width(5)
        self.box_mmfe.set_size_request(-1,-1)

        self.box_mmfe.pack_start(self.label_mmfe_global, expand=False)
        self.box_mmfe.pack_start(self.box_mmfe_number,   expand=False)
        self.box_mmfe.pack_start(self.box_ip,            expand=False)

        self.box_mmfe.pack_start(self.box_mmfeID,          expand=False)
        self.box_mmfe.pack_start(self.frame_ReadoutMask,   expand=False)
        self.box_mmfe.pack_start(self.box_vmmID,           expand=False)
        self.box_mmfe.pack_start(self.button_configs,      expand=False)
        self.box_mmfe.pack_start(self.frame_Reset,         expand=False)  

        self.box_mmfe.pack_start(self.button_SystemInit,    expand=False)
        self.box_mmfe.pack_start(self.button_SystemLoad,    expand=False)
        self.box_mmfe.pack_start(self.vspace(),             expand=False)

        self.box_mmfe.pack_start(self.button_internal_trigger, expand=False)
        self.box_mmfe.pack_start(self.button_external_trigger, expand=False)
        self.box_mmfe.pack_start(self.button_leaky_readout,    expand=False)
        self.box_mmfe.pack_start(self.box_pulses,           expand=False)
        self.box_mmfe.pack_start(self.box_acq_reset_count,  expand=False)
        self.box_mmfe.pack_start(self.box_acq_reset_hold,   expand=False)
        self.box_mmfe.pack_start(self.box_user_udp,         expand=False)
        self.box_mmfe.pack_start(self.vspace(),             expand=False)

        self.box_mmfe.pack_start(self.button_start,          expand=False)
        self.box_mmfe.pack_start(self.button_read_XADC,      expand=False)
        self.box_mmfe.pack_start(self.button_ext_trig_pulse, expand=False)
        self.box_mmfe.pack_start(self.button_exit,           expand=False)
        self.box_mmfe.pack_start(self.vspace(),              expand=False)
        self.box_mmfe.pack_start(self.button_start_all,      expand=False)

        self.frame_mmfe = gtk.Frame()
        self.frame_mmfe.set_border_width(4)
        self.frame_mmfe.set_shadow_type(gtk.SHADOW_IN)
        self.frame_mmfe.add(self.box_mmfe)
        self.frame_mmfe.set_size_request(300, -1)

        self.page1_box = gtk.HBox(homogeneous=0, spacing=0)
        self.page1_box.pack_start(self.frame_mmfe)

        self.vmm_header = gtk.Label("")
        self.vmm_header.set_markup('<span color="green" size="18000"><b>VMM Configuration</b></span>')

        self.vmm_number       = gtk.HBox()
        self.vmm_number_label = gtk.Label("")
        self.vmm_number_label.set_markup('<span color="green"><b>VMM #</b></span>')
        self.vmm_number_combo = gtk.combo_box_new_text()
        for ivmm in xrange(nvmms):
            self.vmm_number_combo.append_text(str(ivmm))
        self.vmm_number_combo.append_text("all")
        self.vmm_number_combo.connect("changed", self.set_current_vmm)
        for obj in [self.vmm_number_label, self.vmm_number_combo]:
            self.vmm_number.pack_start(obj, expand=False)

        # create buttons
        self.vmm_spg    = gtk.CheckButton("Input Charge Polarity (spg)")
        self.vmm_sdp    = gtk.CheckButton("Disable-at-Peak (sdp)")
        self.vmm_sbmx   = gtk.CheckButton("Route Analog Monitor to PDO Output (sbmx)")
        self.vmm_sbft   = gtk.CheckButton("Analog Output Buffer, TDO (sbft)")
        self.vmm_sbfp   = gtk.CheckButton("Analog Output Buffer, PDO (sbfp)")
        self.vmm_sbfm   = gtk.CheckButton("Analog Output Buffer, MO (sbfm)")
        self.vmm_slg    = gtk.CheckButton("Leakage Current Disable (slg)")
        self.vmm_scmx   = gtk.CheckButton("SCMX")
        self.vmm_sfa    = gtk.CheckButton("ART Enable (sfa)")
        self.vmm_sfm    = gtk.CheckButton("SFM (doubles leakage current)")
        self.vmm_sng    = gtk.CheckButton("Neighbor Triggering (sng)")
        self.vmm_sttt   = gtk.CheckButton("Timing Outputs (sttt)")
        self.vmm_ssh    = gtk.CheckButton("Sub-Hysteresis Discrimination (ssh)")
        self.vmm_s8b    = gtk.CheckButton("8-bit ADC Mode (s8b)")
        self.vmm_s6b    = gtk.CheckButton("6-bit ADC Mode (s6b) (disables 8 & 10 bit ADC)")
        self.vmm_spdc   = gtk.CheckButton("ADCs Enable (spdc)")
        self.vmm_sdcks  = gtk.CheckButton("Dual Clock Edge, Serialized Data Enable (sdcks)")
        self.vmm_sdcka  = gtk.CheckButton("Dual Clock Edge, Serialized ART Enable (sdcka)")
        self.vmm_sdck6b = gtk.CheckButton("Dual Clock Edge, Serialized 6-bit Enable (sdck6b)")
        self.vmm_sdrv   = gtk.CheckButton("Tristates Analog Outputs (sdrv)")
        self.vmm_stpp   = gtk.CheckButton("Timing Outputs Control 2 (stpp)")
        
        # connect them to functions
        self.vmm_spg.connect(   "toggled", self.vmm_callback_bit, registers.SPG)
        self.vmm_sdp.connect(   "toggled", self.vmm_callback_bit, registers.SDP)
        self.vmm_sbmx.connect(  "toggled", self.vmm_callback_bit, registers.SBMX)
        self.vmm_sbft.connect(  "toggled", self.vmm_callback_bit, registers.SBFT)
        self.vmm_sbfp.connect(  "toggled", self.vmm_callback_bit, registers.SBFP)
        self.vmm_sbfm.connect(  "toggled", self.vmm_callback_bit, registers.SBFM)
        self.vmm_slg.connect(   "toggled", self.vmm_callback_bit, registers.SLG)
        self.vmm_scmx.connect(  "toggled", self.vmm_callback_bit, registers.SCMX)
        self.vmm_sfa.connect(   "toggled", self.vmm_callback_bit, registers.SFA)
        self.vmm_sfm.connect(   "toggled", self.vmm_callback_bit, registers.SFM)
        self.vmm_sng.connect(   "toggled", self.vmm_callback_bit, registers.SNG)
        self.vmm_sttt.connect(  "toggled", self.vmm_callback_bit, registers.STTT)
        self.vmm_ssh.connect(   "toggled", self.vmm_callback_bit, registers.SSH)
        self.vmm_s8b.connect(   "toggled", self.vmm_callback_bit, registers.S8b)
        self.vmm_s6b.connect(   "toggled", self.vmm_callback_bit, registers.S6b)
        self.vmm_spdc.connect(  "toggled", self.vmm_callback_bit, registers.SPDC)
        self.vmm_sdcks.connect( "toggled", self.vmm_callback_bit, registers.SDCKS)
        self.vmm_sdcka.connect( "toggled", self.vmm_callback_bit, registers.SDCKA)
        self.vmm_sdck6b.connect("toggled", self.vmm_callback_bit, registers.SDCK6b)
        self.vmm_sdrv.connect(  "toggled", self.vmm_callback_bit, registers.SDRV)
        self.vmm_stpp.connect(  "toggled", self.vmm_callback_bit, registers.STPP)

        # create menus
        self.vmm_sm      = gtk.HBox()
        self.vmm_sm_menu = gtk.combo_box_new_text()
        self.vmm_sm_menu.append_text("CHN 1")
        self.vmm_sm_menu.append_text("CHN 2 | pulser DAC")
        self.vmm_sm_menu.append_text("CHN 3 | threshold DAC")
        self.vmm_sm_menu.append_text("CHN 4 | band-gap ref")
        self.vmm_sm_menu.append_text("CHN 5 | temp")
        for i in range(5, 64):
            self.vmm_sm_menu.append_text("CHN " + str(i+1))
        self.vmm_sm.pack_start(self.vmm_sm_menu,           expand=False)
        self.vmm_sm.pack_start(gtk.Label(" Monitor (sm)"), expand=False)

        self.vmm_sfam      = gtk.HBox()
        self.vmm_sfam_menu = gtk.combo_box_new_text()
        self.vmm_sfam_menu.append_text("timing-at-threshold")
        self.vmm_sfam_menu.append_text("timing-at-peak")
        self.vmm_sfam.pack_start(self.vmm_sfam_menu,                expand=False)
        self.vmm_sfam.pack_start(gtk.Label(" ART En. Mode (sfam)"), expand=False)

        self.vmm_st      = gtk.HBox()
        self.vmm_st_menu = gtk.combo_box_new_text()
        self.vmm_st_menu.append_text("200 ns")
        self.vmm_st_menu.append_text("100 ns")
        self.vmm_st_menu.append_text(" 50 ns")
        self.vmm_st_menu.append_text(" 25 ns")
        self.vmm_st.pack_start(self.vmm_st_menu,                expand=False)
        self.vmm_st.pack_start(gtk.Label(" Peaking Time (st)"), expand=False)

        self.vmm_sg      = gtk.HBox()
        self.vmm_sg_menu = gtk.combo_box_new_text()
        for text in ["0.5 (000)", "1.0 (001)", "3.0 (010)" , "4.5 (011)", 
                     "6.0 (100)", "9.0 (101)", "12.0 (110)", "16.0 (111)"]:
            self.vmm_sg_menu.append_text(text)
        self.vmm_sg.pack_start(self.vmm_sg_menu,               expand=False)
        self.vmm_sg.pack_start(gtk.Label(" Gain, mV/fC (sg)"), expand=False)

        self.vmm_stot      = gtk.HBox()
        self.vmm_stot_menu = gtk.combo_box_new_text()
        self.vmm_stot_menu.append_text("threshold-to-peak")
        self.vmm_stot_menu.append_text("time-over-threshold")
        self.vmm_stot.pack_start(self.vmm_stot_menu,                       expand=False)
        self.vmm_stot.pack_start(gtk.Label(" Timing Outputs Mode (stot)"), expand=False)

        self.vmm_stc      = gtk.HBox()
        self.vmm_stc_menu = gtk.combo_box_new_text()
        for text in ["125 ns (00)", "250 ns (01)", "500 ns (10)", "1000 ns (11)"]:
            self.vmm_stc_menu.append_text(text)
        self.vmm_stc.pack_start(self.vmm_stc_menu,             expand=False)
        self.vmm_stc.pack_start(gtk.Label(" TAC Slope (stc)"), expand=False)

        self.vmm_sc10b      = gtk.HBox()
        self.vmm_sc10b_menu = gtk.combo_box_new_text()
        for text in ["0 ns (00)", "1 ns (01)", "2 ns (10)", "3 ns (11)"]:
            self.vmm_sc10b_menu.append_text(text)
        self.vmm_sc10b.pack_start(self.vmm_sc10b_menu,                          expand=False)
        self.vmm_sc10b.pack_start(gtk.Label(" 10-bit Conversion Time (sc10b)"), expand=False)

        self.vmm_sc8b      = gtk.HBox()
        self.vmm_sc8b_menu = gtk.combo_box_new_text()
        for text in ["0 ns (00)", "1 ns (01)", "2 ns (10)", "3 ns (11)"]:
            self.vmm_sc8b_menu.append_text(text)
        self.vmm_sc8b.pack_start(self.vmm_sc8b_menu,                          expand=False)
        self.vmm_sc8b.pack_start(gtk.Label("  8-bit Conversion Time (sc8b)"), expand=False)

        self.vmm_sc6b      = gtk.HBox()
        self.vmm_sc6b_menu = gtk.combo_box_new_text()
        for text in ["0 ns (000)", "1 ns (001)", "2 ns (010)", "3 ns (011)",
                     "4 ns (100)", "5 ns (101)", "6 ns (110)", "7 ns (111)",
                     ]:
            self.vmm_sc6b_menu.append_text(text)
        self.vmm_sc6b.pack_start(self.vmm_sc6b_menu,                          expand=False)
        self.vmm_sc6b.pack_start(gtk.Label("  6-bit Conversion Time (sc6b)"), expand=False)

        self.vmm_sdt      = gtk.HBox()
        self.vmm_sdt_menu = gtk.combo_box_new_text()
        for text in xrange(1024):
            self.vmm_sdt_menu.append_text(str(text))
        self.vmm_sdt.pack_start(self.vmm_sdt_menu,                            expand=False)
        self.vmm_sdt.pack_start(gtk.Label(" Threshold DAC (max 1023) (sdt)"), expand=False)

        self.vmm_sdp2      = gtk.HBox()
        self.vmm_sdp2_menu = gtk.combo_box_new_text()
        for text in xrange(1024):
            self.vmm_sdp2_menu.append_text(str(text))
        self.vmm_sdp2.pack_start(self.vmm_sdp2_menu,                             expand=False)
        self.vmm_sdp2.pack_start(gtk.Label(" Test pulse DAC (max 1023) (sdp2)"), expand=False)

        # connect them to functions
        self.vmm_sfam_menu.connect( "changed", self.vmm_callback_bit,  registers.SFAM)
        self.vmm_stot_menu.connect( "changed", self.vmm_callback_bit,  registers.STOT)
        self.vmm_sm_menu.connect(   "changed", self.vmm_callback_word, registers.SM,    registers.bits_SM)
        self.vmm_st_menu.connect(   "changed", self.vmm_callback_word, registers.ST,    registers.bits_ST)
        self.vmm_sg_menu.connect(   "changed", self.vmm_callback_word, registers.SG,    registers.bits_SG)
        self.vmm_stc_menu.connect(  "changed", self.vmm_callback_word, registers.STC,   registers.bits_STC)
        self.vmm_sdt_menu.connect(  "changed", self.vmm_callback_word, registers.SDT,   registers.bits_SDT)
        self.vmm_sdp2_menu.connect( "changed", self.vmm_callback_word, registers.SDP2,  registers.bits_SDP2)

        reverse = True
        self.vmm_sc10b_menu.connect("changed", self.vmm_callback_word, registers.SC10b, registers.bits_SC10b, reverse)
        self.vmm_sc8b_menu.connect( "changed", self.vmm_callback_word, registers.SC8b,  registers.bits_SC8b,  reverse)
        self.vmm_sc6b_menu.connect( "changed", self.vmm_callback_word, registers.SC6b,  registers.bits_SC6b,  reverse)

        # place the buttons and menus
        self.vmm_variables = gtk.VBox()
        self.vmm_variables.set_border_width(5)
        for obj in [self.vmm_header, self.vmm_number, self.vmm_spg,  self.vmm_sdp,  self.vmm_sbmx,
                    self.vmm_sbft,   self.vmm_sbfp,   self.vmm_sbfm, self.vmm_slg,  self.vmm_scmx, self.vmm_sm,
                    self.vmm_sfa,    self.vmm_sfam,   self.vmm_st,   self.vmm_sfm,  self.vmm_sg,   self.vmm_sng,
                    self.vmm_sttt,   self.vmm_stot,   self.vmm_ssh,  self.vmm_stc,  self.vmm_s8b,  self.vmm_s6b,
                    self.vmm_sc10b,  self.vmm_sc8b,   self.vmm_sc6b, self.vmm_spdc, self.vmm_sdcks, self.vmm_sdcka,
                    self.vmm_sdck6b, self.vmm_sdrv,   self.vmm_stpp, self.vmm_sdt,  self.vmm_sdp2,
                    ]:
            self.vmm_variables.pack_start(obj, expand=False)
        
        self.vmm_frame = gtk.Frame()
        self.vmm_frame.set_border_width(4)
        self.vmm_frame.set_shadow_type(gtk.SHADOW_IN)
        self.vmm_frame.add(self.vmm_variables)
        self.vmm_variables_frame = gtk.HBox()
        self.vmm_variables_frame.pack_start(self.vmm_frame)

        self.page1_box.pack_start(self.vmm_variables_frame, expand=True)

        self.channel_header = gtk.Label("")
        self.channel_header.set_markup('<span color="purple" size="18000"><b>Channel Configuration</b></span>')

        self.channel_variables = gtk.VBox()
        self.channel_variables.set_border_width(5)

        self.channel_label = gtk.Label("SP   SC   SL   ST   SM           SMX       SD           SZ10b           SZ8b           SZ6b")
        self.channel_box   = []
        self.channel_num   = []
        self.channel_SP    = []
        self.channel_SC    = []
        self.channel_SL    = []
        self.channel_ST    = []
        self.channel_SM    = []
        self.channel_SMX   = []
        self.channel_SD    = []
        self.channel_SZ10b = []
        self.channel_SZ8b  = []
        self.channel_SZ6b  = []

        for channel in xrange(nchannels+1):

            quickset = (channel == nchannels)

            self.channel_box.append(gtk.HBox())
            self.channel_num.append(gtk.Label("%02i" % (channel+1)))
            if quickset:
                self.channel_num[-1].set_text(" *  ")

            # create buttons
            self.channel_SP.append( gtk.ToggleButton(label="n"))
            self.channel_SC.append( gtk.CheckButton())
            self.channel_SL.append( gtk.CheckButton())
            self.channel_ST.append( gtk.CheckButton())
            self.channel_SM.append( gtk.CheckButton())
            self.channel_SMX.append(gtk.CheckButton())

            # create menus
            self.channel_SD.append(   gtk.combo_box_new_text())
            self.channel_SZ10b.append(gtk.combo_box_new_text())
            self.channel_SZ8b.append( gtk.combo_box_new_text())
            self.channel_SZ6b.append( gtk.combo_box_new_text())
            for i in range(16):
                self.channel_SD[-1].append_text(str(i) + " mv")
            for i in range(32):
                self.channel_SZ10b[-1].append_text(str(i) + " ns")
            for i in range(16):
                self.channel_SZ8b[-1].append_text(str(i) + " ns")
            for i in range(8):
                self.channel_SZ6b[-1].append_text(str(i) + " ns")
            
            if quickset:
                self.channel_SP[-1] = gtk.ToggleButton(label="  ")
                self.channel_SP[-1].set_inconsistent(True)
                for obj in [self.channel_SC,
                            self.channel_SL,
                            self.channel_ST,
                            self.channel_SM,
                            self.channel_SMX,
                            ]:
                    obj[-1].set_inconsistent(True)

            # connect to functions
            ch = "all" if quickset else channel
            self.channel_SP[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.SP)
            self.channel_SC[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.SC)
            self.channel_SL[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.SL)
            self.channel_ST[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.ST)
            self.channel_SM[-1].connect(   "clicked", self.channel_callback_bit,  ch, index.SM)
            self.channel_SMX[-1].connect(  "clicked", self.channel_callback_bit,  ch, index.SMX)
            self.channel_SD[-1].connect(   "changed", self.channel_callback_word, ch, index.SD,    index.bits_SD)
            self.channel_SZ10b[-1].connect("changed", self.channel_callback_word, ch, index.SZ10b, index.bits_SZ10b)
            self.channel_SZ8b[-1].connect( "changed", self.channel_callback_word, ch, index.SZ8b,  index.bits_SZ8b)
            self.channel_SZ6b[-1].connect( "changed", self.channel_callback_word, ch, index.SZ6b,  index.bits_SZ6b)

            # build the row
            for obj in [self.channel_num[-1],
                        self.channel_SP[-1],
                        self.channel_SC[-1],
                        self.channel_SL[-1],
                        self.channel_ST[-1],
                        self.channel_SM[-1],
                        self.channel_SD[-1],
                        self.channel_SMX[-1],
                        self.channel_SZ10b[-1],
                        self.channel_SZ8b[-1],
                        self.channel_SZ6b[-1],
                        ]:
                self.channel_box[-1].pack_start(obj, expand=True)

        # build the window
        self.channel_variables.pack_start(self.channel_header, expand=True)
        for obj in [self.vspace(), self.channel_label, 
                    self.vspace(), self.channel_box[nchannels], 
                    self.vspace()]:
            self.channel_variables.pack_start(obj, expand=True)
        for channel in xrange(nchannels):
            self.channel_variables.pack_start(self.channel_box[channel], expand=True)
        
        self.channel_frame = gtk.Frame()
        self.channel_frame.set_border_width(4)
        self.channel_frame.set_shadow_type(gtk.SHADOW_IN)
        self.channel_frame.add(self.channel_variables)
        self.channel_variables_frame = gtk.HBox()
        self.channel_variables_frame.pack_start(self.channel_frame)

        self.page1_box.pack_start(self.channel_variables_frame, expand=True)

        # --------------------
        # set defaults here
        # --------------------
        print
        print "Setting default values"
        print

        for immfe in xrange(nmmfes):

            self.current_vmm = "all" # dummy for initialization

            self.combo_mmfe_number.set_active(immfe)
            self.combo_display.set_active(0)

            self.vmm_number_combo.set_active(0)
            self.vmm_number_combo.set_active(nvmms)

            self.vmm_sm_menu.set_active(8)
            self.vmm_sg_menu.set_active(5)
            self.vmm_stc_menu.set_active(2)
            self.vmm_sc8b_menu.set_active(3)
            self.vmm_sdt_menu.set_active(220)
            self.vmm_sdp2_menu.set_active(120)
            for obj in [self.vmm_sbft, self.vmm_sbfp, self.vmm_sbfm, self.vmm_scmx, self.vmm_sfa,
                        self.vmm_sfm,  self.vmm_s8b,  self.vmm_spdc,
                        ]:
                obj.set_active(1)
            for obj in [self.vmm_sfam_menu,  self.vmm_st_menu,   self.vmm_stot_menu,
                        self.vmm_sc10b_menu, self.vmm_sc6b_menu,
                        ]:
                obj.set_active(0)

            for ch in xrange(nchannels):
                for obj in [self.channel_SD[ch], 
                            self.channel_SZ10b[ch], 
                            self.channel_SZ8b[ch], 
                            self.channel_SZ6b[ch],
                            ]:
                    obj.set_active(0)
                for obj in [self.channel_SM[ch], 
                            ]:
                    obj.set_active(1)

        self.combo_mmfe_number.set_active(0)
        self.vmm_number_combo.set_active(0)

        print
        print "Done with default values"
        print

        # --------------------------------------------------------------------------------

        self.page1_scrolledWindow = gtk.ScrolledWindow()
        self.page1_viewport = gtk.Viewport()
        self.page1_viewport.add(self.page1_box)
        self.page1_scrolledWindow.add(self.page1_viewport)

        self.notebook.append_page(self.page1_scrolledWindow, gtk.Label("MMFE"))

        self.box_GUI = gtk.HBox(homogeneous=0, spacing=0)
        self.box_GUI.pack_start(self.box_buttons, expand=False)
        self.box_GUI.pack_end(self.notebook, expand=True)

        self.window.add(self.box_GUI)
        self.window.show_all()
        self.window.connect("destroy", self.destroy)

    def set_current_mmfe(self, widget):
        self.current_mmfe = widget.get_active()
        print "Set current MMFE # = %s" % (self.current_mmfe)
        if self.current_mmfe == "all":
            return
        else:
            self.refresh_mmfe_options()
            if self.current_vmm == "all":
                return
            else:
                self.refresh_vmm_options()
                self.refresh_channel_options()

    def set_current_vmm(self, widget):
        active = widget.get_active()
        if active == nvmms:
            self.current_vmm = "all"
        else:
            self.current_vmm = active

        print "Set current VMM # = %s" % (self.current_vmm if not self.current_vmm == nvmms else "all")
        if self.current_vmm == "all":
            return
        else:
            self.refresh_vmm_options()
            self.refresh_channel_options()

    def current_MMFEs(self):
        if self.current_mmfe == "all":
            return self.MMFEs
        else:
            return [ self.MMFEs[self.current_mmfe] ]

    def current_VMMs(self, mmfe):
        if self.current_vmm == "all":
            return mmfe.VMM
        else:
            return [ mmfe.VMM[self.current_vmm] ]

    def refresh_mmfe_options(self):

        mmfe = self.MMFEs[self.current_mmfe] if self.current_mmfe != "all" else sys.exit("Error: Cannot refresh all MMFEs.")

        self.entry_ip.set_text(str(mmfe.UDP_IP))
        self.entry_pulses.set_text(str(mmfe.pulses))
        self.entry_acq_reset_count.set_text(str(mmfe.acq_reset_count))
        self.entry_acq_reset_hold.set_text(str(mmfe.acq_reset_hold))
        self.entry_user_udp.set_text(mmfe.udp_message)
        self.entry_mmfeID.set_text(str(mmfe.mmfeID))

        self.combo_display.set_active(convert_to_int(mmfe.vmm_cfg_sel[16 : 16-5 : -1]))

        for ivmm in xrange(nvmms):
            self.vmm_readout_buttons[ivmm].set_active(mmfe.readout_runlength[16+ivmm])
            self.vmm_reset_buttons[  ivmm].set_active(mmfe.vmm_cfg_sel[ivmm])

    def refresh_vmm_options(self):

        mmfe = self.MMFEs[self.current_mmfe] if self.current_mmfe != "all" else sys.exit("Error: Cannot refresh VMMs of all MMFE.")
        vmm  = mmfe.VMM[self.current_vmm]    if self.current_vmm  != "all" else sys.exit("Error: Cannot refresh all VMMs.")

        self.vmm_spg.set_active(      vmm.globalreg[registers.SPG])
        self.vmm_sdp.set_active(      vmm.globalreg[registers.SDP])
        self.vmm_sbmx.set_active(     vmm.globalreg[registers.SBMX])
        self.vmm_sbft.set_active(     vmm.globalreg[registers.SBFT])
        self.vmm_sbfp.set_active(     vmm.globalreg[registers.SBFP])
        self.vmm_sbfm.set_active(     vmm.globalreg[registers.SBFM])
        self.vmm_slg.set_active(      vmm.globalreg[registers.SLG])
        self.vmm_scmx.set_active(     vmm.globalreg[registers.SCMX])
        self.vmm_sfm.set_active(      vmm.globalreg[registers.SFM])
        self.vmm_sng.set_active(      vmm.globalreg[registers.SNG])
        self.vmm_sttt.set_active(     vmm.globalreg[registers.STTT])
        self.vmm_ssh.set_active(      vmm.globalreg[registers.SSH])
        self.vmm_s8b.set_active(      vmm.globalreg[registers.S8b])
        self.vmm_s6b.set_active(      vmm.globalreg[registers.S6b])
        self.vmm_spdc.set_active(     vmm.globalreg[registers.SPDC])
        self.vmm_sdcks.set_active(    vmm.globalreg[registers.SDCKS])
        self.vmm_sdcks.set_active(    vmm.globalreg[registers.SDCKA])
        self.vmm_sdck6b.set_active(   vmm.globalreg[registers.SDCK6b])
        self.vmm_sdrv.set_active(     vmm.globalreg[registers.SDRV])
        self.vmm_stpp.set_active(     vmm.globalreg[registers.STPP])

        self.vmm_sfam_menu.set_active(vmm.globalreg[registers.SFAM])
        self.vmm_stot_menu.set_active(vmm.globalreg[registers.STOT])

        self.vmm_sm_menu.set_active(   convert_to_int(vmm.globalreg[registers.SM    : registers.SM    + registers.bits_SM]))
        self.vmm_st_menu.set_active(   convert_to_int(vmm.globalreg[registers.ST    : registers.ST    + registers.bits_ST]))
        self.vmm_sg_menu.set_active(   convert_to_int(vmm.globalreg[registers.SG    : registers.SG    + registers.bits_SG]))
        self.vmm_stc_menu.set_active(  convert_to_int(vmm.globalreg[registers.STC   : registers.STC   + registers.bits_STC]))
        self.vmm_sdt_menu.set_active(  convert_to_int(vmm.globalreg[registers.SDT   : registers.SDT   + registers.bits_SDT]))
        self.vmm_sdp2_menu.set_active( convert_to_int(vmm.globalreg[registers.SDP2  : registers.SDP2  + registers.bits_SDP2]))

        # reversed
        self.vmm_sc10b_menu.set_active(convert_to_int(vmm.globalreg[registers.SC10b : registers.SC10b - registers.bits_SC10b : -1]))
        self.vmm_sc8b_menu.set_active( convert_to_int(vmm.globalreg[registers.SC8b  : registers.SC8b  - registers.bits_SC8b  : -1]))
        self.vmm_sc6b_menu.set_active( convert_to_int(vmm.globalreg[registers.SC6b  : registers.SC6b  - registers.bits_SC6b  : -1]))

    def vmm_callback_bit(self, widget, register):

        for mmfe in self.current_MMFEs():
            for vmm in self.current_VMMs(mmfe):
                vmm.globalreg[register] = 1 if widget.get_active() else 0

    def vmm_callback_word(self, widget, register, nbits, reverse=False, debug=False):
        """ 
        Insert word (length: nbits) starting at register.
        """
        padding = "0%ib" % nbits
        word    = format(int(widget.get_active()), padding)
        if reverse:
            word = word[::-1]
        if debug:
            print "Writing %s to register %s with %s bits | VMM_%s" % (word, register, nbits, self.current_vmm)

        for mmfe in self.current_MMFEs():
            for vmm in self.current_VMMs(mmfe):
                if not reverse:
                    vmm.globalreg[register:register+nbits]     = list(word)
                else:
                    vmm.globalreg[register-nbits+1:register+1] = list(word)

    def channel_callback_bit(self, widget, ch, register):

        for mmfe in self.current_MMFEs():
            for vmm in self.current_VMMs(mmfe):
                channels = vmm.chan_list if ch == "all" else [ vmm.chan_list[ch] ]
                for channel in channels:
                    channel.chan_val[register] = 1 if widget.get_active() else 0

                    if widget in self.channel_SP[:-1]:
                        widget.set_label("p" if widget.get_active() else "n")
    
                if ch == "all" and self.current_vmm != "all":
                    self.refresh_channel_options()

    def channel_callback_word(self, widget, ch, register, nbits):
        """ 
        Insert word (length: nbits) starting at register.
        """
        if widget.get_active() < 0:
            return

        padding = "0%ib" % nbits
        word    = format(int(widget.get_active()), padding)

        for mmfe in self.current_MMFEs():
            for vmm in self.current_VMMs(mmfe):
                channels = vmm.chan_list if ch == "all" else [ vmm.chan_list[ch] ]
                for channel in channels:
                    channel.chan_val[register:register+nbits] = list(word)

                if ch == "all" and self.current_vmm != "all":
                    self.refresh_channel_options()

    def refresh_channel_options(self):

        # quick set
        for obj in [self.channel_SD[nchannels],
                    self.channel_SZ10b[nchannels],
                    self.channel_SZ8b[nchannels],
                    self.channel_SZ6b[nchannels],
                    ]:
            obj.set_active(-1)

        mmfe = self.MMFEs[self.current_mmfe] if self.current_mmfe != "all" else sys.exit("Error: Cannot refresh VMMs of all MMFE.")
        vmm  = mmfe.VMM[self.current_vmm]    if self.current_vmm  != "all" else sys.exit("Error: Cannot refresh all VMMs.")

        for ch in xrange(nchannels):

            channel = vmm.chan_list[ch]

            self.channel_SP[ch].set_active( channel.chan_val[index.SP])
            self.channel_SC[ch].set_active( channel.chan_val[index.SC])
            self.channel_SL[ch].set_active( channel.chan_val[index.SL])
            self.channel_ST[ch].set_active( channel.chan_val[index.ST])
            self.channel_SM[ch].set_active( channel.chan_val[index.SM])
            self.channel_SMX[ch].set_active(channel.chan_val[index.SMX])

            self.channel_SD[ch].set_active(   convert_to_int(channel.chan_val[index.SD    : index.SD    + index.bits_SD]))
            self.channel_SZ10b[ch].set_active(convert_to_int(channel.chan_val[index.SZ10b : index.SZ10b + index.bits_SZ10b]))
            self.channel_SZ8b[ch].set_active( convert_to_int(channel.chan_val[index.SZ8b  : index.SZ8b  + index.bits_SZ8b]))
            self.channel_SZ6b[ch].set_active( convert_to_int(channel.chan_val[index.SZ6b  : index.SZ6b  + index.bits_SZ6b]))

    def vspace(self):
        return gtk.Label(" ")

    def main(self):
        gtk.main()


if __name__ == "__main__":
    gui = GUI()
    gui.main()

