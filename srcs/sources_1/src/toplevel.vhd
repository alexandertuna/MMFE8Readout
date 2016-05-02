--Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2014.4.1 (win64) Build 1149489 Thu Feb 19 16:23:09 MST 2015
--Date        : Wed Mar 11 13:50:06 2015
--Host        : lithe-ad-work running 64-bit Service Pack 1  (build 7601)
--Command     : generate_target mbsys_wrapper.bd
--Design      : mbsys_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
use work.vmm_pkg.all;

--AW: change gui delay_count address
-- trying to make synchronization neater

entity toplevel is
    port (

        -- LED's
        LED_BANK_13 : out std_logic;
        LED_BANK_14 : out std_logic;
        LED_BANK_15 : out std_logic;
        LED_BANK_16 : out std_logic;
        LED_BANK_34 : out std_logic;
        LED_BANK_35 : out std_logic;

        -- External pins
        -- these are 2.5V
        EXTERNAL_3_P : out std_logic;
        EXTERNAL_3_N : out std_logic;
        EXTERNAL_2_P : out std_logic;
        EXTERNAL_2_N : out std_logic;
        EXTERNAL_1_P : out std_logic;
        EXTERNAL_1_N : out std_logic;
        -- except external_0 pins are 1.2V        
        EXTERNAL_0_P : out std_logic;
        EXTERNAL_0_N : out std_logic;

        -- External trigger input
        --EXTERNAL_TRIGGER_HDMI : in std_logic;
        EXTERNAL_TRIGGER_HDMI_P : in std_logic;
        EXTERNAL_TRIGGER_HDMI_N : in std_logic;

        -- Clocks
        -- 200 MHz system clock
        MGTREFCLK1P      : in std_logic;
        MGTREFCLK1N      : in std_logic;
        -- 125 MHz ethernet clock
        MGTREFCLK0P      : in std_logic;
        MGTREFCLK0N      : in std_logic;
        -- 200.0359MHz from bank 14
        X_2V5_DIFF_CLK_P : in std_logic;
        X_2V5_DIFF_CLK_N : in std_logic;

        -- MDIO interaface 
        ENET_MDIO    : inout std_logic;
        ENET_MDC     : out   std_logic;
        ENET_PHY_INT : in    std_logic;
        ENET_RST_N   : out   std_logic;

        -- SGMII
        sgmii_rtl_rxn : in  std_logic;
        sgmii_rtl_rxp : in  std_logic;
        sgmii_rtl_txn : out std_logic;
        sgmii_rtl_txp : out std_logic;

        -- Analog Mux ports 
        MuxAddr0   : out std_logic;
        MuxAddr1   : out std_logic;
        MuxAddr2   : out std_logic;
        MuxAddr3_p : out std_logic;
        MuxAddr3_n : out std_logic;

        -- XADC Ports
        Vaux0_v_n  : in std_logic;
        Vaux0_v_p  : in std_logic;
        Vaux10_v_n : in std_logic;
        Vaux10_v_p : in std_logic;
        Vaux11_v_n : in std_logic;
        Vaux11_v_p : in std_logic;
        Vaux1_v_n  : in std_logic;
        Vaux1_v_p  : in std_logic;
        Vaux2_v_n  : in std_logic;
        Vaux2_v_p  : in std_logic;
        Vaux3_v_n  : in std_logic;
        Vaux3_v_p  : in std_logic;
        Vaux8_v_n  : in std_logic;
        Vaux8_v_p  : in std_logic;
        Vaux9_v_n  : in std_logic;
        Vaux9_v_p  : in std_logic;
        Vp_Vn_v_n  : in std_logic;
        Vp_Vn_v_p  : in std_logic;
        -- vmm signals
        -- signals are as seen by vmm
        -- ckbc is the bc clock TO the vmm
        -- do is the data FROM the vmm

        DI_1_P, DI_1_N : out std_logic;
        DI_2_P, DI_2_N : out std_logic;
        DI_3_P, DI_3_N : out std_logic;
        DI_4_P, DI_4_N : out std_logic;
        DI_5_P, DI_5_N : out std_logic;
        DI_6_P, DI_6_N : out std_logic;
        DI_7_P, DI_7_N : out std_logic;
        DI_8_P, DI_8_N : out std_logic;

        DATA0_1_P, DATA0_1_N : in std_logic;
        DATA0_2_P, DATA0_2_N : in std_logic;
        DATA0_3_P, DATA0_3_N : in std_logic;
        DATA0_4_P, DATA0_4_N : in std_logic;
        DATA0_5_P, DATA0_5_N : in std_logic;
        DATA0_6_P, DATA0_6_N : in std_logic;
        DATA0_7_P, DATA0_7_N : in std_logic;
        DATA0_8_P, DATA0_8_N : in std_logic;

        DATA1_1_P, DATA1_1_N : in std_logic;
        DATA1_2_P, DATA1_2_N : in std_logic;
        DATA1_3_P, DATA1_3_N : in std_logic;
        DATA1_4_P, DATA1_4_N : in std_logic;
        DATA1_5_P, DATA1_5_N : in std_logic;
        DATA1_6_P, DATA1_6_N : in std_logic;
        DATA1_7_P, DATA1_7_N : in std_logic;
        DATA1_8_P, DATA1_8_N : in std_logic;

--    DETECTOR_ID_0       : IN STD_LOGIC;
--    DETECTOR_ID_1       : IN STD_LOGIC;
--    DETECTOR_ID_2       : IN STD_LOGIC;
--    DETECTOR_ID_3       : IN STD_LOGIC;
--    DETECTOR_ID_4       : IN STD_LOGIC;
--    DETECTOR_ID_5       : IN STD_LOGIC;
--    DETECTOR_ID_6       : IN STD_LOGIC;
--    DETECTOR_ID_7       : IN STD_LOGIC;

        DETECTOR_ID : in std_logic_vector (7 downto 0);

        --looped back ART_1_P_N
        ELINK_TX_1_P, ELINK_TX_1_N   : in std_logic;
        ELINK_TX_2_P, ELINK_TX_2_N   : in std_logic;
        ELINK_TX_3_P, ELINK_TX_3_N   : in std_logic;
        ELINK_TX_4_P, ELINK_TX_4_N   : in std_logic;
        ELINK_CLK_1_P, ELINK_CLK_1_N : in std_logic;
        ELINK_RX_1_P, ELINK_RX_1_N   : in std_logic;
        ELINK_CLK_2_P, ELINK_CLK_2_N : in std_logic;
        ELINK_RX_2_P, ELINK_RX_2_N   : in std_logic;


        DO_1_P, DO_1_N : in std_logic;
        DO_2_P, DO_2_N : in std_logic;
        DO_3_P, DO_3_N : in std_logic;
        DO_4_P, DO_4_N : in std_logic;
        DO_5_P, DO_5_N : in std_logic;
        DO_6_P, DO_6_N : in std_logic;
        DO_7_P, DO_7_N : in std_logic;
        DO_8_P, DO_8_N : in std_logic;

        WEN_1_P, WEN_1_N : out std_logic;
        WEN_2_P, WEN_2_N : out std_logic;
        WEN_3_P, WEN_3_N : out std_logic;
        WEN_4_P, WEN_4_N : out std_logic;
        WEN_5_P, WEN_5_N : out std_logic;
        WEN_6_P, WEN_6_N : out std_logic;
        WEN_7_P, WEN_7_N : out std_logic;
        WEN_8_P, WEN_8_N : out std_logic;

        ENA_1_P, ENA_1_N : out std_logic;
        ENA_2_P, ENA_2_N : out std_logic;
        ENA_3_P, ENA_3_N : out std_logic;
        ENA_4_P, ENA_4_N : out std_logic;
        ENA_5_P, ENA_5_N : out std_logic;
        ENA_6_P, ENA_6_N : out std_logic;
        ENA_7_P, ENA_7_N : out std_logic;
        ENA_8_P, ENA_8_N : out std_logic;

        CKTK_1_P, CKTK_1_N : out std_logic;
        CKTK_2_P, CKTK_2_N : out std_logic;
        CKTK_3_P, CKTK_3_N : out std_logic;
        CKTK_4_P, CKTK_4_N : out std_logic;
        CKTK_5_P, CKTK_5_N : out std_logic;
        CKTK_6_P, CKTK_6_N : out std_logic;
        CKTK_7_P, CKTK_7_N : out std_logic;
        CKTK_8_P, CKTK_8_N : out std_logic;

        CKTP_1_P, CKTP_1_N : out std_logic;
        CKTP_2_P, CKTP_2_N : out std_logic;
        CKTP_3_P, CKTP_3_N : out std_logic;
        CKTP_4_P, CKTP_4_N : out std_logic;
        CKTP_5_P, CKTP_5_N : out std_logic;
        CKTP_6_P, CKTP_6_N : out std_logic;
        CKTP_7_P, CKTP_7_N : out std_logic;
        CKTP_8_P, CKTP_8_N : out std_logic;

        CKBC_1_P, CKBC_1_N : out std_logic;
        CKBC_2_P, CKBC_2_N : out std_logic;
        CKBC_3_P, CKBC_3_N : out std_logic;
        CKBC_4_P, CKBC_4_N : out std_logic;
        CKBC_5_P, CKBC_5_N : out std_logic;
        CKBC_6_P, CKBC_6_N : out std_logic;
        CKBC_7_P, CKBC_7_N : out std_logic;
        CKBC_8_P, CKBC_8_N : out std_logic;

        CKDT_1_P, CKDT_1_N : out std_logic;
        CKDT_2_P, CKDT_2_N : out std_logic;
        CKDT_3_P, CKDT_3_N : out std_logic;
        CKDT_4_P, CKDT_4_N : out std_logic;
        CKDT_5_P, CKDT_5_N : out std_logic;
        CKDT_6_P, CKDT_6_N : out std_logic;
        CKDT_7_P, CKDT_7_N : out std_logic;
        CKDT_8_P, CKDT_8_N : out std_logic;

        CKART_1_P, CKART_1_N : out std_logic;
        CKART_2_P, CKART_2_N : out std_logic;
        CKART_3_P, CKART_3_N : out std_logic;
        CKART_4_P, CKART_4_N : out std_logic;
        CKART_5_P, CKART_5_N : out std_logic;
        CKART_6_P, CKART_6_N : out std_logic;
        CKART_7_P, CKART_7_N : out std_logic;
        CKART_8_P, CKART_8_N : out std_logic;

        TKO_8_P, TKO_8_N   : in  std_logic;
        SETB_8_P, SETB_8_N : in  std_logic;
        TKI_1_P, TKI_1_N   : out std_logic;
        SETT_1_P, SETT_1_N : in  std_logic

        );
end toplevel;

architecture STRUCTURE of toplevel is

    attribute dont_touch : string;

    component mbsys is
        port (
            mgtrefclk1 : in std_logic;  -- 

            diff_clock_rtl_clk_n : in  std_logic;
            diff_clock_rtl_clk_p : in  std_logic;
            --ref_clk_125_p : in STD_LOGIC;
            --ref_clk_125_n  : in STD_LOGIC;
            ext_reset_in         : in  std_logic;  -- Active LOW!!!
            mdio_rtl_mdc         : out std_logic;
            mdio_rtl_mdio_i      : in  std_logic;
            mdio_rtl_mdio_o      : out std_logic;
            mdio_rtl_mdio_t      : out std_logic;
            sgmii_rtl_rxn        : in  std_logic;
            sgmii_rtl_rxp        : in  std_logic;
            sgmii_rtl_txn        : out std_logic;
            sgmii_rtl_txp        : out std_logic;

            reset_rtl : out std_logic;

            Vaux0_v_n  : in std_logic;
            Vaux0_v_p  : in std_logic;
            Vaux10_v_n : in std_logic;
            Vaux10_v_p : in std_logic;
            Vaux11_v_n : in std_logic;
            Vaux11_v_p : in std_logic;
            Vaux1_v_n  : in std_logic;
            Vaux1_v_p  : in std_logic;
            Vaux2_v_n  : in std_logic;
            Vaux2_v_p  : in std_logic;
            Vaux3_v_n  : in std_logic;
            Vaux3_v_p  : in std_logic;
            Vaux8_v_n  : in std_logic;
            Vaux8_v_p  : in std_logic;
            Vaux9_v_n  : in std_logic;
            Vaux9_v_p  : in std_logic;
            Vp_Vn_v_n  : in std_logic;
            Vp_Vn_v_p  : in std_logic;

--    gpio_rtl_tri_i    : in STD_LOGIC_VECTOR ( 31 downto 0 );
--    gpio_rtl_tri_o    : out STD_LOGIC_VECTOR ( 31 downto 0 );
--    gpio_rtl_tri_t    : out STD_LOGIC_VECTOR ( 31 downto 0 );    

            EXT_AXI_RESETN  : out std_logic_vector (0 to 0);
            EXT_AXI_awaddr  : out std_logic_vector (31 downto 0);
            EXT_AXI_awprot  : out std_logic_vector (2 downto 0);
            EXT_AXI_awvalid : out std_logic_vector (0 to 0);
            EXT_AXI_awready : in  std_logic_vector (0 to 0);
            EXT_AXI_wdata   : out std_logic_vector (31 downto 0);
            EXT_AXI_wstrb   : out std_logic_vector (3 downto 0);
            EXT_AXI_wvalid  : out std_logic_vector (0 to 0);
            EXT_AXI_wready  : in  std_logic_vector (0 to 0);
            EXT_AXI_bresp   : in  std_logic_vector (1 downto 0);
            EXT_AXI_bvalid  : in  std_logic_vector (0 to 0);
            EXT_AXI_bready  : out std_logic_vector (0 to 0);
            EXT_AXI_araddr  : out std_logic_vector (31 downto 0);
            EXT_AXI_arprot  : out std_logic_vector (2 downto 0);
            EXT_AXI_arvalid : out std_logic_vector (0 to 0);
            EXT_AXI_arready : in  std_logic_vector (0 to 0);
            EXT_AXI_rdata   : in  std_logic_vector (31 downto 0);
            EXT_AXI_rresp   : in  std_logic_vector (1 downto 0);
            EXT_AXI_rvalid  : in  std_logic_vector (0 to 0);
            EXT_AXI_rready  : out std_logic_vector (0 to 0);
            ext_axi_clk     : out std_logic
            );
    end component mbsys;


    component IOBUF is
        port (
            I  : in    std_logic;
            O  : out   std_logic;
            T  : in    std_logic;
            IO : inout std_logic
            );
    end component IOBUF;


-- kjohns components are here
    component clk_wiz_0
        port
            (
                -- Clock in ports
                clk_in1 : in std_logic;

                -- Clock out ports
                clk_200_o : out std_logic;
                clk_160_o : out std_logic;
                clk_100_o : out std_logic;
                clk_50_o  : out std_logic;
                clk_40_o  : out std_logic;
                clk_20_o  : out std_logic;
                clk_10_o  : out std_logic
                );
    end component;

    attribute SYN_BLACK_BOX              : boolean;
    attribute SYN_BLACK_BOX of clk_wiz_0 : component is true;

    attribute BLACK_BOX_PAD_PIN              : string;
    attribute BLACK_BOX_PAD_PIN of clk_wiz_0 : component is "clk_in1,clk_200_o,clk_160_o,clk_100_o,clk_50_o,clk_40_o,clk_20_o,clk_10_o";


    component clk_wiz_200_to_400
        port
            (
                -- Clock in ports
                clk_in1_p : in std_logic;
                clk_in1_n : in std_logic;

                -- Clock out ports
                clk_out_400 : out std_logic
                );
    end component;

    --ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
    attribute SYN_BLACK_BOX of clk_wiz_200_to_400 : component is true;


    --ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
    attribute BLACK_BOX_PAD_PIN of clk_wiz_200_to_400 : component is "clk_in1_p,clk_in1_n,clk_out_400";


    component clk_wiz_low_jitter
        port
            (                           -- Clock in ports
                clk_in1 : in std_logic;

                -- Clock out ports
                clk_out1 : out std_logic
                );
    end component;

--ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
    attribute SYN_BLACK_BOX of clk_wiz_low_jitter : component is true;

--ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
    attribute BLACK_BOX_PAD_PIN of clk_wiz_low_jitter : component is "clk_in1,clk_out1";


    component ila_top
        port (
            clk     : in std_logic;
            probe0  : in std_logic_vector(31 downto 0);
            probe1  : in std_logic_vector(7 downto 0);
            probe2  : in std_logic_vector(7 downto 0);
            probe3  : in std_logic_vector(15 downto 0);
            probe4  : in std_logic_vector(7 downto 0);
            probe5  : in std_logic_vector(7 downto 0);
            probe6  : in std_logic_vector(7 downto 0);
            probe7  : in std_logic_vector(7 downto 0);
            probe8  : in std_logic_vector(37 downto 0);
            probe9  : in std_logic_vector(37 downto 0);
            probe10 : in std_logic_vector(37 downto 0);
            probe11 : in std_logic_vector(37 downto 0);
            probe12 : in std_logic_vector(37 downto 0);
            probe13 : in std_logic_vector(37 downto 0);
            probe14 : in std_logic_vector(37 downto 0);
            probe15 : in std_logic_vector(37 downto 0);
            probe16 : in std_logic_vector(31 downto 0);
            probe17 : in std_logic_vector(31 downto 0);
            probe18 : in std_logic_vector(31 downto 0);
            probe19 : in std_logic_vector(31 downto 0)
            );
    end component;



    component external_trigger is
        port (clk_40                  : in  std_logic;
              reset_bcid_counter      : in  std_logic;
              ext_trigger_in          : in  std_logic;
              ext_trigger_en          : in  std_logic;
              ext_trigger_pulse_o     : out std_logic;
              busy_from_ext_trigger_o : out std_logic;
              busy_from_acq_rst_o     : out std_logic;
              bcid_counter_o          : out std_logic_vector (11 downto 0);
              bcid_captured_o         : out std_logic_vector (11 downto 0);
              bcid_corrected_o        : out std_logic_vector (11 downto 0);
              bcid_corrected_m1       : out std_logic_vector (11 downto 0);
              bcid_corrected_m2       : out std_logic_vector (11 downto 0);
              bcid_corrected_m3       : out std_logic_vector (11 downto 0);
              bcid_corrected_m4       : out std_logic_vector (11 downto 0);
              bcid_corrected_m5       : out std_logic_vector (11 downto 0);
              bcid_corrected_p1       : out std_logic_vector (11 downto 0);
              bcid_corrected_p2       : out std_logic_vector (11 downto 0);
              bcid_corrected_p3       : out std_logic_vector (11 downto 0);
              bcid_corrected_p4       : out std_logic_vector (11 downto 0);
              bcid_corrected_p5       : out std_logic_vector (11 downto 0);
              turn_counter_o          : out std_logic_vector (15 downto 0);
              turn_counter_captured_o : out std_logic_vector (15 downto 0);
              num_ext_trig_o          : out std_logic_vector (19 downto 0);
              acq_rst_from_ext_trig_o : out std_logic;
              vmm_cktk_ext_trig_en_o  : out std_logic;
              read_data_o             : out std_logic;
              fifo_rst_from_ext_trig_o : out std_logic;
              reading_fin : in std_logic;
              ext_trigger_edge_slow : in std_logic
              );
    end component;


    component leaky_readout is
        port (
            clk_200 : in std_logic;
            axi_clk : in std_logic;
            reset   : in std_logic;

--     signals from external_trigger    
            ext_trigger_pulse        : in std_logic;
            busy_from_ext_trigger    : in std_logic;
            bcid_corrected           : in std_logic_vector (11 downto 0);
            bcid_corrected_m1        : in std_logic_vector (11 downto 0);
            bcid_corrected_m2        : in std_logic_vector (11 downto 0);
            bcid_corrected_m3        : in std_logic_vector (11 downto 0);
            bcid_corrected_m4        : in std_logic_vector (11 downto 0);
            bcid_corrected_m5        : in std_logic_vector (11 downto 0);
            bcid_corrected_p1        : in std_logic_vector (11 downto 0);
            bcid_corrected_p2        : in std_logic_vector (11 downto 0);
            bcid_corrected_p3        : in std_logic_vector (11 downto 0);
            bcid_corrected_p4        : in std_logic_vector (11 downto 0);
            bcid_corrected_p5        : in std_logic_vector (11 downto 0);
            turn_counter_ext_trigger : in std_logic_vector (15 downto 0);

--     signals from the data fifo
            data_fifo_rd_en : out std_logic;
            data_fifo_dout  : in  std_logic_vector(31 downto 0);
            data_fifo_empty : in  std_logic;
            --data_fifo_rd_count            : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
            --data_fifo_wr_count            : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);

--     axi      
            axi_pop_vmm1        : in  std_logic;
            axi_rdata_ls_vmm1   : out std_logic_vector(31 downto 0);
            axi_rdata_rcnt_vmm1 : out std_logic_vector(31 downto 0)
            );
    end component;


    type array_8x32bit is array (0 to 7) of std_logic_vector(31 downto 0);
    type array_Int_8 is array (0 to 7) of integer;
    type array_8x38bit is array (0 to 7) of std_logic_vector(37 downto 0);
    type array_51x32bit is array (4 to 54) of std_logic_vector(31 downto 0);

    component vmm_cfg is
        port
            (
                clk_ila     : in std_logic;
                clk200      : in std_logic;
                vmm_clk_200 : in std_logic;
                EXT_AXI_CLK : in std_logic;


                clk100      : in std_logic;
                vmm_clk_100 : in std_logic;
                clk10 : std_logic;
                vmm_clk_10 : in std_logic;

                reset : in std_logic;

                cfg_bit_in  : in  std_logic;
                cfg_bit_out : out std_logic;


                vmm_wen_gbl_rst : out std_logic;  -- gbl reset wen output for vmm selected for sys init
                vmm_wen_acq_rst : out std_logic_vector(7 downto 0);  -- acq reset wen output on per vmm vector

                vmm_ena_gbl_rst : out std_logic;  -- global reset ena output for vmm selected for gbl reset or sys init
                vmm_ena_acq_rst : out std_logic_vector(7 downto 0);  -- acq reset ena output on per vmm vector

                vmm_wen_cfg_sr : out std_logic;  -- config shift reg ena output for vmm selected for sys init
                vmm_ena_cfg_sr : out std_logic;  -- config shift reg ena output for vmm selected for sys init

                vmm_acq_rst_running      : out std_logic_vector(7 downto 0);  -- used to allow vmm_ena_acq_rst to drive low by not anding with vmm_ena_vmm_cfg_sm
--        vmm_ena_vmm_cfg_sm          : out   std_logic_vector( 7 DOWNTO 0);  -- sys_init_sm_acq_en
                vmm_ena_vmm_cfg_sm_vec_o : out std_logic_vector(7 downto 0) := (others => '0');


                vmm_ckdt_en_vec : out std_logic_vector(7 downto 0);
                vmm_ckdt        : in  std_logic;

                vmm_ckart_en : out std_logic;
                vmm_ckart    : in  std_logic;


                vmm_cktk_daq_en_vec : out std_logic_vector(7 downto 0);  -- from daq
                vmm_cktk_cfg_sr_en  : out std_logic;  --from config module          
                vmm_cktk            : in  std_logic;

                vmm_cktp_en : out std_logic;
                vmm_cktp    : in  std_logic;

                vmm_ckbc_en        : out std_logic;
                vmm_ckbc           : in  std_logic;
                reset_bcid_counter : out std_logic;

                vmm_data1_vec : in std_logic_vector(7 downto 0);
                vmm_data0_vec : in std_logic_vector(7 downto 0);
                vmm_art_vec   : in std_logic_vector(7 downto 0);
                turn_counter  : in std_logic_vector(15 downto 0);

                wr_en     : buffer std_logic;
                vmm_rd_en : out    std_logic_vector(7 downto 0);

                vmm_din_vec       : out array_8x32bit;  --from daq
                dt_cntr_intg0_vec : out array_Int_8;    --from daq
                dt_cntr_intg1_vec : out array_Int_8;    --from daq

                vmm_data_buf_vec : out    array_8x38bit;  --from daq
                vmm_dout_vec     : out    array_8x32bit;  --from daq
                rr_state         : buffer std_logic_vector(7 downto 0);
                din              : buffer std_logic_vector(31 downto 0);

                vmm_ro          : in  std_logic_vector(7 downto 0);
                vmm_configuring : out std_logic;
                rst_state       : out std_logic_vector(2 downto 0);

                LEDx  : out std_logic_vector(2 downto 0);
                testX : in  std_logic;

                axi_reg : in array_81x32bit;  --axi config data

                vmm_cfg_sel : in std_logic_vector(31 downto 0);

                axi_clk : in std_logic;

                rr_data_fifo_rd_en : in  std_logic := '0';
                rr_data_fifo_dout  : out std_logic_vector(31 downto 0);
                rr_data_fifo_empty : out std_logic := '0';
                rr_rd_data_count   : out std_logic_vector(9 downto 0);
                rr_wr_data_count   : out std_logic_vector(9 downto 0);

                vmm_gbl_rst     : in  std_logic                    := '0';
                vmm_gbl_rst_sum : out std_logic                    := '0';
                vmm_cfg_en_vec  : in  std_logic_vector(7 downto 0) := (others => '0');  --selected for configuration from the gui
                vmm_load        : in  std_logic;

                vmm_ena_vmm_cfg_sm_o    : out std_logic;
                acq_rst_from_vmm_fsm_o  : out std_logic;
--       vmm_ena_vmm_cfg_sm_vec_o  : out std_logic_vector( 7 downto 0)
                acq_rst_term_count      : in  std_logic_vector(31 downto 0) := x"00000000";  -- 40 @ 40MHz @ 200MHz;
                acq_rst_hold_term_count : in  std_logic_vector(31 downto 0) := x"00000000";  -- 40 @ 40MHz @ 200MHz;

                acq_rst_from_data0_o : out std_logic_vector(7 downto 0);
--        vmm_acq_rst_running         : in std_logic_vector( 7 downto 0);
--        acq_rst_term_count          : in array_8x32bit;
                dt_state             : out array_8x4bit;
                acq_rst_counter      : out array_8x32bit;
                acq_rst_from_ext_trig : in std_logic;
                fifo_rst_from_ext_trig : in std_logic;
                int_trig : in std_logic
                );
    end component;


    component scope_select is
        port (
            scopeD0 : out std_logic;
            scopeD1 : out std_logic;
            scopeD2 : out std_logic;
            scopeD3 : out std_logic;
            scopeD4 : out std_logic;
            scopeD5 : out std_logic;
            scopeD6 : out std_logic;
            scopeD7 : out std_logic;

            scope_CE     : out std_logic_vector (7 downto 0) := (others => '1');
            vmm_2display : in  std_logic_vector(4 downto 0)  := (others => '0');

            vmm_ckbc    : in std_logic;
            vmm_ckbc_en : in std_logic;
            vmm_ckbc_all_en : in std_logic;

            vmm_cktp      : in std_logic;
            vmm_cktp_en   : in std_logic;
            vmm_di        : in std_logic;
            vmm_di_en_vec : in std_logic_vector (7 downto 0) := (others => '1');

            vmm_data0_vec : in std_logic_vector (7 downto 0) := (others => '1');
            vmm_data1_vec : in std_logic_vector (7 downto 0) := (others => '1');

            vmm_do_vec  : in std_logic_vector (7 downto 0) := (others => '1');
            vmm_wen_vec : in std_logic_vector (7 downto 0) := (others => '1');
            vmm_ena_vec : in std_logic_vector (7 downto 0) := (others => '1');

            vmm_ckart   : in std_logic;
            vmm_art_vec : in std_logic_vector (7 downto 0) := (others => '1');

            vmm_cktk        : in std_logic;
            vmm_cktk_en_vec : in std_logic_vector (7 downto 0) := (others => '1');
            vmm_ckdt        : in std_logic;
            vmm_ckdt_en_vec : in std_logic_vector (7 downto 0) := (others => '1');

            ext_trigger_in        : in std_logic;
            ext_trigger_deb       : in std_logic;
            ext_trigger_pulse     : in std_logic;
            busy_from_ext_trigger : in std_logic;

            vmm_cfg_en_vec  : in std_logic_vector (7 downto 0) := (others => '1');
            vmm_gbl_rst     : in std_logic;
            vmm_gbl_rst_sum : in std_logic                     := '0';

            reset           : in std_logic;
            reset_old       : in std_logic;
            reset_new       : in std_logic;
            vmm_load        : in std_logic;
            rst_state       : in std_logic_vector(2 downto 0);
            vmm_configuring : in std_logic;
            int_trig        : in std_logic;
            cktp_done       : in std_logic;

            LEDx : in std_logic_vector(2 downto 0);

            vmm_ena_vmm_cfg_sm     : in std_logic;
            acq_rst_from_vmm_fsm   : in std_logic;
            vmm_ena_vmm_cfg_sm_vec : in std_logic_vector(7 downto 0);
            acq_rst_from_data0  : in std_logic_vector(7 downto 0);
            vmm_acq_rst_running : in std_logic_vector(7 downto 0);
            acq_rst_term_count  : in std_logic_vector(31 downto 0);

            dt_state        : in array_8x4bit;
            acq_rst_counter : in array_8x32bit

            );
    end component;



--------------------===================-------------------
-------------------- Signals-------------------
--------------------===================-------------------




    signal mgtrefclk1      : std_logic;
    signal clk_400_noclean : std_logic;
    signal clk_400_clean   : std_logic;

    signal mdio_rtl_mdio_io : std_logic;
    signal mdio_rtl_mdio_i  : std_logic;
    signal mdio_rtl_mdio_o  : std_logic;
    signal mdio_rtl_mdio_t  : std_logic;
    signal mdio_rtl_mdc     : std_logic;

    signal reset_rtl : std_logic;

    -- kjohns signals here begin
    -- other signals
    --signal count          : std_logic_vector( 28 downto 0);
    signal count1  : std_logic_vector(31 downto 0);
    signal count12 : std_logic_vector(31 downto 0);

    signal LED         : std_logic_vector(5 downto 0);
    signal LEDx        : std_logic_vector(2 downto 0);
    signal vmm_sel     : std_logic_vector(2 downto 0);
    signal display_sel : std_logic;

    signal vmm_configuring : std_logic;
    signal vmm_cfg_en_vec  : std_logic_vector(7 downto 0);

    signal temp : std_logic;

    -- general vmm signals
    signal vmm_di        : std_logic;
    signal vmm_di_en_vec : std_logic_vector (7 downto 0);  -- := (others=>'0') ;
    signal vmm_di_r_vec  : std_logic_vector (7 downto 0);  -- := (others=>'0') ;
    signal vmm_do        : std_logic := '0';
    signal vmm_do_vec    : std_logic_vector (7 downto 0);  -- := (others=>'0' ;
    signal vmm_wen_vec   : std_logic_vector (7 downto 0);  -- := (others=>'0' ;

    signal vmm_wen_en  : std_logic;
    signal vmm_wen_R   : std_logic;
    signal vmm_ena     : std_logic;
    signal vmm_ena_vec : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_ena_en  : std_logic;
    signal vmm_ena_R   : std_logic;

    signal vmm_data0_sync_vec : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_data0_async_vec : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_data0_vec : std_logic_vector (7 downto 0) := (others => '0');

    signal vmm_data1_sync_vec : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_data1_async_vec : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_data1_vec : std_logic_vector (7 downto 0) := (others => '0');

    signal fifo_wr_en_i : std_logic;
    signal din_i        : std_logic_vector(31 downto 0);

    signal vmm_din_vec : array_8x32bit;  --from daq

    signal dt_cntr_intg0_vec : array_Int_8;    --from daq
    signal dt_cntr_intg1_vec : array_Int_8;    --from daq
    signal vmm_dout_vec      : array_8x32bit;  --from daq
    signal vmm_dout_vec_i    : array_8x32bit;  --from daq
    signal vmm_rd_en         : std_logic_vector (7 downto 0) := (others => '0');
    signal dt_cntr_intg0_i   : integer;
    signal dt_cntr_intg1_i   : integer;


    signal vmm_data_buf_i   : std_logic_vector(37 downto 0);
    signal vmm_data_buf_vec : array_8x38bit;

    signal rr_state : std_logic_vector(7 downto 0);
    signal din      : std_logic_vector(31 downto 0);

    signal clk_ila : std_logic;
    signal clk_200 : std_logic;
    signal clk_160 : std_logic;
    signal clk_100 : std_logic;
    signal clk_50  : std_logic;
    signal clk_40  : std_logic;
    signal clk_20  : std_logic;
    signal clk_10  : std_logic;

    --  signal  rst_status_next : std_logic; -- charlie
    signal vmm_global_reset  : std_logic                     := '0';  -- charlie
    signal vmm_global_reset2 : std_logic                     := '0';  -- charlie
    signal count1_next       : std_logic_vector(31 downto 0) := x"00000000";  -- charlie  
    signal count1_rst        : std_logic                     := '0';  -- charlie 
    signal count1_max        : std_logic                     := '0';  -- charlie
    signal vmm_2display      : std_logic_vector(4 downto 0);  -- charlie
    signal vmm_ro_i          : std_logic_vector(7 downto 0)  := b"11111111";

    signal clk_dt_period_cnt    : std_logic_vector(15 downto 0) := x"0010";
    signal clk_dt_dutycycle_cnt : std_logic_vector(15 downto 0) := x"0008";
    signal clk_bc_period_cnt    : std_logic_vector(15 downto 0) := x"0004";
    signal clk_bc_dutycycle_cnt : std_logic_vector(15 downto 0) := x"0002";

    signal clk_tp_period_cnt    : std_logic_vector(19 downto 0) := x"007D0";--20 us
    signal clk_tp_dutycycle_cnt : std_logic_vector(19 downto 0) := x"003E8";--10 us

    signal clk_tp_period_cnt_calib    : std_logic_vector(19 downto 0) := x"30D40"; --1 kHz
    signal clk_tp_dutycycle_cnt_calib : std_logic_vector(19 downto 0) := x"186A0"; -- 500 microseconds

    signal counter_for_cktp_done : std_logic_vector(15 downto 0) := x"0000";
    signal cktp_done             : std_logic                     := '0';

    signal counter_for_cktp_done_calib : std_logic_vector(15 downto 0) := x"0000";
    signal cktp_done_calib             : std_logic                     := '1';

    signal clk_tk_period_cnt     : std_logic_vector(15 downto 0) := x"0013";
    signal clk_tk_dutycycle_cnt  : std_logic_vector(15 downto 0) := x"0003";
    signal pulses                : std_logic_vector(15 downto 0) := x"0000";
    signal int_trig              : std_logic                     := '0';
    signal int_trig_d            : std_logic                     := '0';
    signal int_trig_d2            : std_logic                     := '0';
    signal int_trig_edge         : std_logic                     := '0';
    signal start                 : std_logic                     := '0';
    signal vmm_load              : std_logic                     := '0';

--    signal vmm_ena_vmm_cfg_sm         : std_logic ;
    signal vmm_ena_cfg_sr  : std_logic;
    signal vmm_ena_cfg_rst : std_logic;
    signal vmm_wen_cfg_sr  : std_logic;
    signal vmm_wen_cfg_rst : std_logic;

    signal clk_art_X    : std_logic;
    signal vmm_art_vec  : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_art      : std_logic;
    signal vmm_ckart    : std_logic;
    signal vmm_ckart_en : std_logic;
    signal vmm_ckart_r  : std_logic;
    signal vmm_clk_int  : std_logic;

    signal vmm_cktk       : std_logic;
    signal vmm_cktk_r_vec : std_logic_vector (7 downto 0) := (others => '0');

    signal vmm_cktk_daq_en_vec : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_cktk_en_vec     : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_cktk_cfg_sr_en  : std_logic;

    signal vmm_cktk_sync : std_logic;
    signal clk_tk_X      : std_logic;
    signal clk_tk_enable : std_logic;
    signal clk_tk_sync   : std_logic;
    signal clk_tk_cntr   : std_logic_vector (15 downto 0) := (others => '0');
    signal clk_tk_out    : std_logic;
    signal testX         : std_logic                      := '0';

    signal vmm_cktp      : std_logic;
    signal vmm_cktp_en   : std_logic;
    signal vmm_cktp_sync : std_logic;
    signal vmm_cktp_r    : std_logic;
    signal clk_tp_X      : std_logic;
    signal clk_tp_enable : std_logic;
    signal clk_tp_sync   : std_logic;
    signal clk_tp_cntr   : std_logic_vector (19 downto 0) := (others => '0');
    signal clk_tp_out    : std_logic;
    signal clk_tp_cntr_calib   : std_logic_vector (19 downto 0) := (others => '0');
    signal clk_tp_out_calib    : std_logic;

    signal delay_count   : std_logic_vector (19 downto 0) := (others => '0');
    signal delay_counter : std_logic_vector (19 downto 0) := (others => '0');
    signal rise_counter  : std_logic_vector (15 downto 0) := x"0000";
    
    signal vmm_ckbc           : std_logic;
    signal vmm_ckbc_en        : std_logic;  --from vmm_cfg
    signal vmm_ckbc_all_en    : std_logic;
    signal reset_bcid_counter : std_logic;
    signal vmm_ckbc_sync      : std_logic;
    signal vmm_ckbc_R         : std_logic;
    signal clk_bc_X           : std_logic;
    signal clk_bc_enable      : std_logic;
    signal clk_bc_sync        : std_logic;
    signal clk_bc_cntr        : std_logic_vector (15 downto 0) := (others => '0');
    signal clk_bc_out         : std_logic;

    signal vmm_ckdt        : std_logic;
    signal vmm_ckdt_kj     : std_logic;
    signal counter_kj      : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_ckdt_en_vec : std_logic_vector (7 downto 0) := (others => '0');

    signal vmm_ckdt_r_vec : std_logic_vector (7 downto 0) := (others => '0');

    signal clk_dt_enable : std_logic;
    signal clk_dt_sync   : std_logic;
    signal clk_dt_cntr   : std_logic_vector (15 downto 0) := (others => '0');
    signal clk_dt_out    : std_logic;

    signal ext_trigger_pulse     : std_logic;
    signal busy_from_ext_trigger : std_logic;
    signal busy_from_acq_rst     : std_logic;
    signal bcid_counter          : std_logic_vector (11 downto 0);
    signal bcid_captured         : std_logic_vector (11 downto 0);
    signal bcid_corrected        : std_logic_vector (11 downto 0);
    signal bcid_corrected_m1     : std_logic_vector (11 downto 0);
    signal bcid_corrected_m2     : std_logic_vector (11 downto 0);
    signal bcid_corrected_m3     : std_logic_vector (11 downto 0);
    signal bcid_corrected_m4     : std_logic_vector (11 downto 0);
    signal bcid_corrected_m5     : std_logic_vector (11 downto 0);
    signal bcid_corrected_p1     : std_logic_vector (11 downto 0);
    signal bcid_corrected_p2     : std_logic_vector (11 downto 0);
    signal bcid_corrected_p3     : std_logic_vector (11 downto 0);
    signal bcid_corrected_p4     : std_logic_vector (11 downto 0);
    signal bcid_corrected_p5     : std_logic_vector (11 downto 0);
    signal turn_counter          : std_logic_vector (15 downto 0);
    signal turn_counter_captured : std_logic_vector (15 downto 0);

    --ann
    signal num_ext_trig          : std_logic_vector (19 downto 0);
    signal acq_rst_from_ext_trig : std_logic;
    signal acq_rst_from_ext_trig_d : std_logic;
    signal acq_rst_from_ext_trig_edge : std_logic := '0';
    signal vmm_cktk_ext_trig_en  : std_logic;
    signal read_data  : std_logic;
    signal fifo_rst  : std_logic;
    
    signal clk_X_1 : std_logic;
    signal clk_X_2 : std_logic;

    signal scopeD7   : std_logic;
    signal scopeD6   : std_logic;
    signal scopeD5   : std_logic;
    signal scopeD4   : std_logic;
    signal scopeD3   : std_logic;
    signal scopeD2   : std_logic;
    signal scopeD1   : std_logic;
    signal scopeD0   : std_logic;
    signal scopeD7_i : std_logic;
    signal scopeD6_i : std_logic;
    signal scopeD5_i : std_logic;
    signal scopeD4_i : std_logic;
    signal scopeD3_i : std_logic;
    signal scopeD2_i : std_logic;
    signal scopeD1_i : std_logic;
    signal scopeD0_i : std_logic;

    signal scope_CE : std_logic_vector (7 downto 0) := (others => '1');
    signal scope_R  : std_logic_vector (7 downto 0) := (others => '0');

    signal reset_out : std_logic;
    signal reset     : std_logic;
    signal count1p   : std_logic;

    signal logic_dump  : std_logic;
    signal vmm_gbl_rst : std_logic := '0';
    signal system_init : std_logic := '0';

    signal probe0_out_i : std_logic_vector(31 downto 0);
    signal probe1_out_i : std_logic_vector(31 downto 0);
    signal probe2_out_i : std_logic_vector(31 downto 0);
    signal probe3_out_i : std_logic_vector(31 downto 0);
    signal probe4_out_i : std_logic_vector(31 downto 0);
    signal probe5_out_i : std_logic_vector(31 downto 0);
    signal probe6_out_i : std_logic_vector(37 downto 0);
    signal probe7_out_i : std_logic_vector(10 downto 0);
    signal probe8_out_i : std_logic_vector(31 downto 0);

    signal xxxx      : std_logic;
    signal reset_new : std_logic;
    -- ann added
    signal reset_new_d : std_logic;
    signal reset_new_edge : std_logic;

    signal reset_old : std_logic;


    attribute mark_debug                : string;
    attribute mark_debug of vmm_wen_vec : signal is "true";
    attribute mark_debug of vmm_ena_vec : signal is "true";
    attribute mark_debug of vmm_ckbc    : signal is "true";
    attribute mark_debug of vmm_ckbc_en : signal is "true";
    attribute mark_debug of vmm_ckbc_all_en : signal is "true";
    attribute mark_debug of vmm_cktp    : signal is "true";
    attribute mark_debug of cktp_done   : signal is "true";
    attribute mark_debug of vmm_cktk    : signal is "true";

    attribute mark_debug of vmm_cktk_en_vec : signal is "true";

    attribute mark_debug of vmm_ckdt        : signal is "true";
    attribute mark_debug of vmm_ckdt_en_vec : signal is "true";
    attribute mark_debug of fifo_wr_en_i    : signal is "true";
    attribute mark_debug of vmm_data0_vec   : signal is "true";
    attribute mark_debug of vmm_data1_vec   : signal is "true";
    attribute mark_debug of dt_cntr_intg0_i : signal is "true";
    attribute mark_debug of dt_cntr_intg1_i : signal is "true";
    attribute mark_debug of din_i           : signal is "true";
    attribute mark_debug of din             : signal is "true";
    attribute mark_debug of rr_state        : signal is "true";
    attribute mark_debug of vmm_data_buf_i  : signal is "true";

    attribute keep : string;

    attribute keep of xxxx              : signal is "true";
    attribute keep of vmm_ena_vec       : signal is "true";
    attribute keep of vmm_ckbc          : signal is "true";
    attribute keep of vmm_ckbc_en       : signal is "true";
    attribute keep of vmm_ckbc_all_en   : signal is "true";
    attribute keep of vmm_cktp          : signal is "true";
    attribute keep of cktp_done         : signal is "true";
    attribute keep of vmm_cktk          : signal is "true";
    attribute keep of vmm_cktk_en_vec   : signal is "true";
    attribute keep of vmm_ckdt          : signal is "true";
    attribute keep of vmm_ckdt_en_vec   : signal is "true";
    attribute keep of fifo_wr_en_i      : signal is "true";
    attribute keep of vmm_data0_vec     : signal is "true";
    attribute keep of vmm_data1_vec     : signal is "true";
    attribute keep of dt_cntr_intg0_i   : signal is "true";
    attribute keep of dt_cntr_intg1_i   : signal is "true";
    attribute keep of din_i             : signal is "true";
    attribute keep of din               : signal is "true";
    attribute keep of rr_state          : signal is "true";
    attribute keep of vmm_data_buf_i    : signal is "true";
    attribute keep of clk_400_clean     : signal is "true";
    attribute keep of clk_200           : signal is "true";
    attribute keep of vmm_global_reset  : signal is "true";
    attribute keep of vmm_global_reset2 : signal is "true";

    attribute keep of reset          : signal is "true";
    attribute keep of reset_new      : signal is "true";
    attribute keep of reset_old      : signal is "true";
    attribute keep of vmm_2display   : signal is "true";
    attribute keep of vmm_gbl_rst    : signal is "true";
    attribute keep of vmm_cfg_en_vec : signal is "true";

    -- external trigger signals
    signal ext_trigger_port  : std_logic;
    signal ext_trigger_en  : std_logic;
    signal ext_trigger_flag: std_logic;
    signal ext_trigger_sim : std_logic;  --ann
    signal ext_trigger_sync : std_logic;  --ann

    signal ext_trigger_d : std_logic := '0';  --ann
    signal ext_trigger_edge : std_logic;  --ann    
    signal ext_trigger_d_slow : std_logic := '0';  --ann
        signal ext_trigger_d2_slow : std_logic := '0';  --ann
    signal ext_trigger_edge_slow : std_logic;  --ann
    signal reading_fin_flag : std_logic;  --ann
    signal reading_fin_flag_d : std_logic;  --ann
    signal reading_fin_flag_edge : std_logic;  --ann
    signal ext_trig_w_pulse : std_logic;
    signal ext_trigger_deb : std_logic;
    signal turn_captured   : std_logic_vector (15 downto 0);
    signal Q1, Q2, Q3      : std_logic;
    signal data_fifo_rd_en : std_logic;
    signal data_fifo_dout  : std_logic_vector(31 downto 0);
    signal data_fifo_empty : std_logic;
    signal ext_trigger_delayed : std_logic;


    -- vmm signals
    signal vmm_di_1    : std_logic;
    signal vmm_wen_1   : std_logic;
    signal vmm_ena_1   : std_logic;
    signal vmm_cktk_1  : std_logic;
    signal vmm_cktp_1  : std_logic;
    signal vmm_ckbc_1  : std_logic;
    signal vmm_ckdt_1  : std_logic;
    signal vmm_ckart_1 : std_logic;

    signal vmm_di_2    : std_logic;
    signal vmm_wen_2   : std_logic;
    signal vmm_ena_2   : std_logic;
    signal vmm_cktk_2  : std_logic;
    signal vmm_cktp_2  : std_logic;
    signal vmm_ckbc_2  : std_logic;
    signal vmm_ckdt_2  : std_logic;
    signal vmm_ckart_2 : std_logic;

    signal vmm_di_3    : std_logic;
    signal vmm_wen_3   : std_logic;
    signal vmm_ena_3   : std_logic;
    signal vmm_cktk_3  : std_logic;
    signal vmm_cktp_3  : std_logic;
    signal vmm_ckbc_3  : std_logic;
    signal vmm_ckdt_3  : std_logic;
    signal vmm_ckart_3 : std_logic;

    signal vmm_di_4    : std_logic;
    signal vmm_wen_4   : std_logic;
    signal vmm_ena_4   : std_logic;
    signal vmm_cktk_4  : std_logic;
    signal vmm_cktp_4  : std_logic;
    signal vmm_ckbc_4  : std_logic;
    signal vmm_ckdt_4  : std_logic;
    signal vmm_ckart_4 : std_logic;

    signal vmm_di_5    : std_logic;
    signal vmm_wen_5   : std_logic;
    signal vmm_ena_5   : std_logic;
    signal vmm_cktk_5  : std_logic;
    signal vmm_cktp_5  : std_logic;
    signal vmm_ckbc_5  : std_logic;
    signal vmm_ckdt_5  : std_logic;
    signal vmm_ckart_5 : std_logic;

    signal vmm_di_6    : std_logic;
    signal vmm_wen_6   : std_logic;
    signal vmm_ena_6   : std_logic;
    signal vmm_cktk_6  : std_logic;
    signal vmm_cktp_6  : std_logic;
    signal vmm_ckbc_6  : std_logic;
    signal vmm_ckdt_6  : std_logic;
    signal vmm_ckart_6 : std_logic;

    signal vmm_di_7    : std_logic;
    signal vmm_wen_7   : std_logic;
    signal vmm_ena_7   : std_logic;
    signal vmm_cktk_7  : std_logic;
    signal vmm_cktp_7  : std_logic;
    signal vmm_ckbc_7  : std_logic;
    signal vmm_ckdt_7  : std_logic;
    signal vmm_ckart_7 : std_logic;

    signal vmm_di_8    : std_logic;
    signal vmm_wen_8   : std_logic;
    signal vmm_ena_8   : std_logic;
    signal vmm_cktk_8  : std_logic;
    signal vmm_cktp_8  : std_logic;
    signal vmm_ckbc_8  : std_logic;
    signal vmm_ckdt_8  : std_logic;
    signal vmm_ckart_8 : std_logic;

    signal vmm_tko    : std_logic;
    signal vmm_setb   : std_logic;
    signal vmm_tki    : std_logic;
    signal vmm_tki_i  : std_logic;
    signal vmm_tki_en : std_logic;
    signal vmm_sett   : std_logic;

--    signal  DETECTOR_ID    : STD_LOGIC_VECTOR ( 7 downto 0);

    -- kjohns signals here end

    --signal  gpio_i : STD_LOGIC_VECTOR ( 31 downto 0 ); 
    --signal  gpio_o : STD_LOGIC_VECTOR ( 31 downto 0 );   
    --signal  gpio_t : STD_LOGIC_VECTOR ( 31 downto 0 );

    signal EXT_AXI_araddr  : std_logic_vector (31 downto 0);
    signal EXT_AXI_arready : std_logic;  -->> in
    signal EXT_AXI_arvalid : std_logic;  --<< out
    signal EXT_AXI_arprot  : std_logic_vector (2 downto 0);

    signal EXT_AXI_awaddr  : std_logic_vector (31 downto 0);
    signal EXT_AXI_awready : std_logic;  -->> in
    signal EXT_AXI_awvalid : std_logic;  --<< out
    signal EXT_AXI_awprot  : std_logic_vector (2 downto 0);

    signal EXT_AXI_rdata    : std_logic_vector (31 downto 0);
    signal EXT_AXI_rready   : std_logic;                      --<< out
    signal EXT_AXI_rvalid   : std_logic;                      -->> in
    signal EXT_AXI_rvalid_z : std_logic_vector (2 downto 0);  -- used to delay  rvalid response

    signal EXT_AXI_wdata   : std_logic_vector (31 downto 0);
    signal EXT_AXI_wready  : std_logic;  -->> in
    signal EXT_AXI_wvalid  : std_logic;  --<< out  
    signal EXT_AXI_wstrb   : std_logic_vector (3 downto 0);
    signal EXT_AXI_wdata_v : std_logic_vector (31 downto 0);




    attribute dont_touch of EXT_AXI_araddr  : signal is "true";
    attribute dont_touch of EXT_AXI_arready : signal is "true";
    attribute dont_touch of EXT_AXI_arvalid : signal is "true";
    attribute dont_touch of EXT_AXI_arprot  : signal is "true";

    attribute dont_touch of EXT_AXI_awaddr  : signal is "true";
    attribute dont_touch of EXT_AXI_awready : signal is "true";
    attribute dont_touch of EXT_AXI_awvalid : signal is "true";
    attribute dont_touch of EXT_AXI_awprot  : signal is "true";

    attribute dont_touch of EXT_AXI_rdata  : signal is "true";
    attribute dont_touch of EXT_AXI_rready : signal is "true";
    attribute dont_touch of EXT_AXI_rvalid : signal is "true";

    attribute dont_touch of EXT_AXI_wdata  : signal is "true";
    attribute dont_touch of EXT_AXI_wready : signal is "true";
    attribute dont_touch of EXT_AXI_wvalid : signal is "true";
    attribute dont_touch of EXT_AXI_wstrb  : signal is "true";



    signal axi_addr_muxed : std_logic_vector (15 downto 0);
    signal axi_addr_read  : std_logic_vector (15 downto 0);
    signal axi_addr_write : std_logic_vector (15 downto 0);

    signal EXT_AXI_CLK    : std_logic;  --<< out  
    signal EXT_AXI_RESETN : std_logic;  --<< out  
-- nathan changed 79 to 80
    signal axi_we_axi_reg : std_logic_vector (80 downto 0);

    signal axi_we_axi_reg_amux : std_logic;
    
-- nathan changed to 81 type
    signal axi_reg : array_81x32bit;    --axi config data

    signal axi_reg_amux               : std_logic_vector(3 downto 0);
    -- Created two, but only used one
    signal axi_pop_vmm1, axi_pop_vmm2 : std_logic;
    signal axi_rdata_ls_vmm1          : std_logic_vector(31 downto 0);
    signal axi_rdata_ls_vmm2          : std_logic_vector(31 downto 0) := (others => '0');
    signal axi_rdata_rcnt_vmm1        : std_logic_vector(31 downto 0);
    signal axi_rdata_rcnt_vmm2        : std_logic_vector(31 downto 0) := (others => '0');

    signal rr_data_fifo_rd_en : std_logic := '0';
    signal rr_data_fifo_dout  : std_logic_vector(31 downto 0);
    signal rr_data_fifo_empty : std_logic := '0';

--    signal data_fifo_rd_en_leak          : STD_LOGIC := '0';    

    signal axi_data_to_use          : std_logic                     := '0';
    signal axi_pop_vmm1_rr          : std_logic                     := '0';
    signal axi_rdata_ls_vmm1_rr     : std_logic_vector(31 downto 0) := (others => '0');
    signal axi_rdata_rcnt_vmm1_rr   : std_logic_vector(31 downto 0) := (others => '0');
    signal axi_pop_vmm1_leak        : std_logic                     := '0';
    signal axi_rdata_ls_vmm1_leak   : std_logic_vector(31 downto 0) := (others => '0');
    signal axi_rdata_rcnt_vmm1_leak : std_logic_vector(31 downto 0) := (others => '0');

    signal rr_rd_data_count : std_logic_vector(31 downto 0) := (others => '0');


    signal vmm_cfg_sel                 : std_logic_vector(31 downto 0);  -- axi_reg_55;
    signal clk_tp_period_dutycycle_cnt : std_logic_vector(31 downto 0);  -- axi_reg_56;
    signal readout_runlength           : std_logic_vector(31 downto 0);  -- axi_reg_57;
    signal control                     : std_logic_vector(31 downto 0);  -- axi_reg_59;

    signal user_reg_1 : std_logic_vector(31 downto 0);
    signal user_reg_2 : std_logic_vector(31 downto 0);
    signal user_reg_3 : std_logic_vector(31 downto 0);
    signal user_reg_4 : std_logic_vector(31 downto 0);
    signal user_reg_5 : std_logic_vector(31 downto 0);

    signal mmfeID : std_logic_vector(3 downto 0) := x"e";

    signal probe0_i  : std_logic_vector(31 downto 0);
    signal probe8_i  : std_logic_vector(37 downto 0);
    signal probe9_i  : std_logic_vector(37 downto 0);
    signal probe10_i : std_logic_vector(37 downto 0);
    signal probe11_i : std_logic_vector(37 downto 0);
    signal probe12_i : std_logic_vector(37 downto 0);
    signal probe13_i : std_logic_vector(37 downto 0);
    signal probe14_i : std_logic_vector(37 downto 0);
    signal probe15_i : std_logic_vector(37 downto 0);

    signal probe17_i : std_logic_vector(31 downto 0);
    signal probe18_i : std_logic_vector(31 downto 0);
    signal probe19_i : std_logic_vector(31 downto 0);

    signal DS2411_low  : std_logic_vector(31 downto 0) := x"aaaaaaaa";
    signal DS2411_high : std_logic_vector(31 downto 0) := x"55555555";

    signal xadc : std_logic_vector(31 downto 0) := x"00000000";

    signal rst_state       : std_logic_vector(2 downto 0);
    signal vmm_gbl_rst_sum : std_logic := '0';

    signal clk_ets_cntr          : std_logic_vector(15 downto 0) := x"0000";
    signal clk_ets_period_cnt    : std_logic_vector(15 downto 0) := x"C350";  -- at 100MHz in -> 2KHz out
    signal clk_ets_out           : std_logic                     := '0';
    signal clk_ets_dutycycle_cnt : std_logic_vector(15 downto 0) := x"0005";  -- at 100MHz in -> 50 ns out

    signal ext_trigger_in_sel : std_logic := '0';
    signal ext_trigger_in_sw  : std_logic := '0';

    signal vmm_wen_gbl_rst         : std_logic                     := '0';
    signal vmm_ena_gbl_rst         : std_logic                     := '0';
    signal vmm_acq_rst_running     : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_wen_acq_rst         : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_ena_acq_rst         : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_ena_vmm_cfg_sm_vec  : std_logic_vector (7 downto 0) := (others => '0');
    signal vmm_ena_vmm_cfg_sm      : std_logic                     := '0';
    signal acq_rst_from_vmm_fsm    : std_logic                     := '0';
--    signal vmm_cfg_en_vec                : STD_LOGIC_VECTOR ( 7 downto 0) := (others=>'0');
--    signal LEDx                          : std_logic_vector( 2 downto 0);
    signal acq_rst_term_count      : std_logic_vector(31 downto 0) := x"00080000";  -- 40 @ 40MHz @ 200MHz;
    signal acq_rst_hold_term_count : std_logic_vector(31 downto 0) := x"0000000C";  -- 200MHz
    signal acq_rst_from_data0      : std_logic_vector(7 downto 0);
--  signal acq_rst_term_count             : array_8x32bit;
    signal dt_state                : array_8x4bit;

    signal acq_rst_counter : array_8x32bit;

-------------------------=============================================---------------------------

begin

    mbsys_i : component mbsys
        port map (
            EXT_AXI_CLK         => EXT_AXI_CLK,
            EXT_AXI_RESETN(0)   => EXT_AXI_RESETN,
            EXT_AXI_araddr      => EXT_AXI_araddr,
            EXT_AXI_arprot      => EXT_AXI_arprot,
            EXT_AXI_arready(0)  => EXT_AXI_arready,
            EXT_AXI_arvalid (0) => EXT_AXI_arvalid,
            EXT_AXI_awaddr      => EXT_AXI_awaddr,
            EXT_AXI_awprot      => EXT_AXI_awprot,
            EXT_AXI_awready(0)  => EXT_AXI_awready,
            EXT_AXI_awvalid(0)  => EXT_AXI_awvalid,
            EXT_AXI_bready      => open,
            EXT_AXI_bresp       => "00",
            EXT_AXI_bvalid(0)   => '1',
            EXT_AXI_rdata       => EXT_AXI_rdata(31 downto 0),
            EXT_AXI_rready(0)   => EXT_AXI_rready,
            EXT_AXI_rresp       => "00",
            EXT_AXI_rvalid(0)   => EXT_AXI_rvalid,
            EXT_AXI_wdata       => EXT_AXI_wdata(31 downto 0),
            EXT_AXI_wready(0)   => EXT_AXI_wready,
            EXT_AXI_wstrb       => EXT_AXI_wstrb,
            EXT_AXI_wvalid(0)   => EXT_AXI_wvalid,

            Vaux0_v_n => Vaux0_v_n,
            Vaux0_v_p => Vaux0_v_p,
            Vaux1_v_n => Vaux1_v_n,
            Vaux1_v_p => Vaux1_v_p,
            Vaux2_v_n => Vaux2_v_n,
            Vaux2_v_p => Vaux2_v_p,
            Vaux3_v_n => Vaux3_v_n,
            Vaux3_v_p => Vaux3_v_p,

            Vaux8_v_n  => Vaux8_v_n,
            Vaux8_v_p  => Vaux8_v_p,
            Vaux9_v_n  => Vaux9_v_n,
            Vaux9_v_p  => Vaux9_v_p,
            Vaux10_v_n => Vaux10_v_n,
            Vaux10_v_p => Vaux10_v_p,
            Vaux11_v_n => Vaux11_v_n,
            Vaux11_v_p => Vaux11_v_p,

            Vp_Vn_v_n => Vp_Vn_v_n,
            Vp_Vn_v_p => Vp_Vn_v_p,

--      gpio_rtl_tri_i  => open, --gpio_i,
--      gpio_rtl_tri_o  => gpio_o,
--      gpio_rtl_tri_t  => gpio_t,   

--      mgtrefclk1 => mgtrefclk1,
            mgtrefclk1 => clk_200,

            diff_clock_rtl_clk_n => MGTREFCLK0N,
            diff_clock_rtl_clk_p => MGTREFCLK0P,

            --ref_clk_125_p       => MGTREFCLK0P,
            --ref_clk_125_n       => MGTREFCLK0N,        

            ext_reset_in    => '1',
            mdio_rtl_mdc    => mdio_rtl_mdc,
            mdio_rtl_mdio_i => mdio_rtl_mdio_i,
            mdio_rtl_mdio_o => mdio_rtl_mdio_o,
            mdio_rtl_mdio_t => mdio_rtl_mdio_t,

            reset_rtl => reset_rtl,

            sgmii_rtl_rxn => sgmii_rtl_rxn,
            sgmii_rtl_rxp => sgmii_rtl_rxp,
            sgmii_rtl_txn => sgmii_rtl_txn,
            sgmii_rtl_txp => sgmii_rtl_txp
            );


-- --------------------------------------------------------------------------------------------------------------


    mdio_rtl_mdio_iobuf : component IOBUF
        port map (
            I  => mdio_rtl_mdio_o,
            IO => mdio_rtl_mdio_io,
            O  => mdio_rtl_mdio_i,
            T  => mdio_rtl_mdio_t
            );

    -- MDIO
    ENET_MDIO  <= mdio_rtl_mdio_io;
    ENET_MDC   <= mdio_rtl_mdc;
    -- ENET_PHY_INT    for now, don't catch phy interrupts
    ENET_RST_N <= reset_rtl;


-- --------------------------------------------------------------------------------------------------------------

-- note andy uses mgtrefclk0, it is in his process

    IBUFDS_GTE2_inst_1 : IBUFDS_GTE2
        generic map (
            CLKCM_CFG    => true,       -- Refer to Transceiver User Guide
            CLKRCV_TRST  => true,       -- Refer to Transceiver User Guide
            CLKSWING_CFG => "11"        -- Refer to Transceiver User Guide
            )
        port map (
            O     => mgtrefclk1,        -- Buffer output
            ODIV2 => open,
            CEB   => '0',
            I     => MGTREFCLK1P,  -- Diff_p buffer input (connect directly to top-level port)
            IB    => MGTREFCLK1N  -- Diff_n buffer input (connect directly to top-level port)
            );


-- --------------------------------------------------------------------------------------------------------------


--The system reset process



    U_System_Reset : process(clk_50)
    begin
        if rising_edge(clk_50) then
            if(reset_old = '1') or (reset_new = '1') then
                if(count12 = x"00000010") then
                    vmm_global_reset2 <= '0';
                    count12           <= x"00000010";
                else
                    count12           <= count12 + '1';
                    vmm_global_reset2 <= '1';
                end if;
            else
                vmm_global_reset2 <= '0';
                count12           <= (others => '0');
            end if;
        end if;
    end process U_System_Reset;

    reset <= vmm_global_reset2;
--reset <= vmm_global_reset2 or system_init;

    
  sys_reset_edge_detect : process(reset_new)
    -- detects falling edge of system reset
  begin
    if falling_edge(reset_new) then
      reset_new_edge <= '1';
    end if;
  end process sys_reset_edge_detect;

    
    

-- Clock instances here   



-- 200MHz is multiplied to 400MHz 
    clk_200_to_400_inst : clk_wiz_200_to_400
        port map (

            -- Clock in ports
            clk_in1_p   => X_2V5_DIFF_CLK_P,
            clk_in1_n   => X_2V5_DIFF_CLK_N,
            -- Clock out ports  
            clk_out_400 => clk_400_noclean
            );


--400MHz is jitter cleaned
    clk_400_low_jitter_inst : clk_wiz_low_jitter
        port map (

            -- Clock in ports
            clk_in1 => clk_400_noclean,

            -- Clock out ports  
            clk_out1 => clk_400_clean
            );


--400MHz clean clock is used to generate phase locked user clocks
    clk_user_inst : clk_wiz_0
        port map (

            -- Clock in ports
            clk_in1 => clk_400_clean,

            -- Clock out ports  
            clk_200_o => clk_200,
            clk_160_o => clk_160,
            clk_100_o => clk_100,
            clk_50_o  => clk_50,
            clk_40_o  => clk_40,
            clk_20_o  => clk_20,
            clk_10_o  => clk_10
            );



-- Assign the main clocks


--   clk_dt_out <= clk_100;
    clk_dt_out <= clk_50;
    vmm_ckart  <= clk_160;
    clk_tk_out <= clk_10;               --10MHz, 45 deg
    clk_bc_out <= clk_40;


---------------------
-- CKTP Clock Process
---------------------


-- kjohns changed this from clk_200 to clk_100
-- kjohns removed clk_tp_sync
-- bill was using barrel shifter at 200MHz for this, to use minimum pulse width, synchronized to clock edge
-- easily changed by writing any desired pattern to barral shifter 

   --ann

    -- this process is now only generating when ext_trigger_in_sel is high
    U_cktp_gen : process(clk_100, reset)
    begin
        if rising_edge(clk_100) then
            if ((reset = '1' or ext_trigger_edge= '1') and (ext_trigger_in_sel = '1') and (ext_trig_w_pulse = '1')) then --
                clk_tp_cntr <= clk_tp_period_cnt;
                clk_tp_out  <= '0';
                cktp_done   <= '0';
            else
                if ((ext_trigger_port = '1') and (ext_trigger_in_sel = '1') and (vmm_cktp_en = '1') and (cktp_done = '0') and (ext_trig_w_pulse = '1')) then
                    if clk_tp_cntr = clk_tp_period_cnt then
                        clk_tp_cntr <= (others => '0');
                        clk_tp_out  <= '1';
                    else
                        clk_tp_cntr <= clk_tp_cntr + '1';
                        if clk_tp_cntr = clk_tp_dutycycle_cnt then
                            clk_tp_out <= '0';
                        end if;
                    end if;
                end if;

                if pulses = x"03e7" then  -- x"03e7" <=> 999 
                    cktp_done <= '0';
                else
                  if ext_trigger_in_sel = '1' then
                    if counter_for_cktp_done = x"0001" then
                      cktp_done <= '1';
                      clk_tp_out <= '0';
                    end if;
                  elsif counter_for_cktp_done = pulses then  ---------what is
                                                             ---------this for?
                    cktp_done <= '1';
                  end if;
                end if;
            end if;
        end if;
    end process U_cktp_gen;

    -- this should really be put on a clock
    U_cktp_done : process (clk_tp_out, reset, int_trig_edge, ext_trigger_edge)
    begin
        if (int_trig_edge = '1' or  reset = '1' or ext_trigger_edge = '1') then
        --if reset = '1' then
            counter_for_cktp_done <= (others => '0');
        else
            if falling_edge(clk_tp_out) then  -- changed from rising-edge
                counter_for_cktp_done <= counter_for_cktp_done + '1';
            end if;
        end if;
    end process U_cktp_done;


-- implemented CKTP synchronization with CKBC, set by variable called
-- delay_count which is axi register 74 (values of 0, 1, 2, 3, 4 corresponding
-- to multiples of 5 ns)

    CKTP_calibration : process(clk_200)
    begin
      if rising_edge(clk_200) then
        if ((int_trig_edge = '1') and (ext_trigger_in_sel = '0') and cktp_done_calib = '1') then
          if clk_bc_out = '1' then        --sync with CKBC
            if to_integer(unsigned(rise_counter)) > 0 then  
              clk_tp_cntr_calib  <= clk_tp_period_cnt_calib;
              clk_tp_out_calib   <= '0';
              cktp_done_calib <= '0';
              rise_counter <= (others => '0');
            else
              rise_counter <= rise_counter + '1';
            end if;
          else --want this to reset every cycle
            rise_counter <= (others => '0');
          end if;
        else
          if((int_trig = '1') and (cktp_done_calib = '0') and (ext_trigger_in_sel = '0')) then  
            if clk_tp_cntr_calib = clk_tp_period_cnt_calib then
              if clk_tp_out_calib = '0' then
                if delay_counter = delay_count then
                  clk_tp_out_calib  <= '1';
                  clk_tp_cntr_calib <= delay_count + '1';
                else
                  delay_counter <= delay_counter + '1';
                end if;
              end if;
            else
              clk_tp_cntr_calib <= clk_tp_cntr_calib + '1';
              if clk_tp_cntr_calib = clk_tp_dutycycle_cnt_calib then
                clk_tp_out_calib    <= '0';
                delay_counter <= (others => '0');
              end if;
            end if;
          end if;

          if pulses = x"03e7" then        -- x"03e7" <=> 999 
            cktp_done_calib <= '0';
          else
            if counter_for_cktp_done_calib = pulses then
              cktp_done_calib <= '1';
            end if;
          end if;
        end if;
      end if;
    end process CKTP_calibration;

    -- this should really be put on a clock
    CKTP_calibration_done : process (clk_tp_out_calib, reset, int_trig_edge, ext_trigger_edge)
    begin
        if (int_trig_edge = '1' or  reset = '1' or ext_trigger_edge = '1') then
        --if reset = '1' then
            counter_for_cktp_done_calib <= (others => '0');
        else
            if falling_edge(clk_tp_out_calib) then  -- changed from rising-edge
                counter_for_cktp_done_calib <= counter_for_cktp_done_calib + '1';
            end if;
        end if;
    end process CKTP_calibration_done;
    
    edge_detect : process(clk_bc_out, int_trig, int_trig_d)
    begin
      if rising_edge(clk_bc_out) then
        int_trig_d <= int_trig;
        int_trig_d2 <= int_trig_d;
      end if;
      int_trig_edge <= ((not int_trig_d2) and int_trig);
    end process edge_detect;

    Ext_trig_sim : process(clk_100, reset)
    begin
        if rising_edge(clk_100) then
            if reset = '1' then
                clk_ets_cntr <= clk_ets_period_cnt;
                clk_ets_out  <= '0';
            else
                if clk_ets_cntr = clk_ets_period_cnt then
                    clk_ets_cntr <= (others => '0');
                    clk_ets_out  <= '1';
                else
                    clk_ets_cntr <= clk_ets_cntr + '1';
                    if clk_ets_cntr = clk_ets_dutycycle_cnt then
                        clk_ets_out <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process Ext_trig_sim;



--------------------------------
-- ila       
--------------------------------



--                     31         30            29         28            27          26         25         24
    probe0_i <= vmm_ckbc & vmm_ckbc_all_en & vmm_cktp & vmm_cktp_en & cktp_done & vmm_cktk & vmm_ckdt & data_fifo_rd_en &
--                  23                  22           21      20          19          18            13               12                  11
                ext_trigger_pulse & clk_tp_out & reset & reset_new & reset_old & vmm_2display & vmm_gbl_rst & vmm_cfg_en_vec(0) & x"000";

----                     31         30            29         28            27          26         25         24
--    probe0_i <= vmm_ckbc & vmm_ckbc_en & vmm_cktp & vmm_cktp_en & cktp_done & vmm_cktk & vmm_ckdt & data_fifo_rd_en &
----                  23                  22           21      20          19          18            13               12                  11
--                ext_trigger_pulse & clk_tp_out & reset & reset_new & reset_old & vmm_2display & vmm_gbl_rst & vmm_cfg_en_vec(0) & x"000";


    
    probe8_i  <= vmm_data_buf_vec(0)(37 downto 0);
    probe9_i  <= vmm_data_buf_vec(1)(37 downto 0);
    probe10_i <= vmm_data_buf_vec(2)(37 downto 0);
    probe11_i <= vmm_data_buf_vec(3)(37 downto 0);
    probe12_i <= vmm_data_buf_vec(4)(37 downto 0);
    probe13_i <= vmm_data_buf_vec(5)(37 downto 0);
    probe14_i <= vmm_data_buf_vec(6)(37 downto 0);
    probe15_i <= vmm_data_buf_vec(7)(37 downto 0);

--                      31          30      29         28            27        26      19    18       17                     12  11                       3     2     0     
    probe17_i <= vmm_load & start & int_trig & vmm_gbl_rst & vmm_ro_i(7 downto 0) & mmfeID & vmm_2display(4 downto 0) & vmm_cfg_en_vec(7 downto 0) & b"000";
    probe18_i <= clk_tp_period_cnt(15 downto 0) & clk_tp_dutycycle_cnt(15 downto 0);
    probe19_i <= pulses(15 downto 0) & clk_tp_dutycycle_cnt(15 downto 0);




    ila_top_inst : ila_top
        port map (
            clk => clk_200,

            probe0 => probe0_i,
            probe1 => vmm_ena_vec(7 downto 0),
            probe2 => vmm_wen_vec(7 downto 0),
            probe3 => counter_for_cktp_done(15 downto 0),
            probe4 => vmm_cktk_en_vec(7 downto 0),
            probe5 => vmm_ckdt_en_vec(7 downto 0),
            probe6 => vmm_data0_vec(7 downto 0),
            probe7 => vmm_data1_vec(7 downto 0),
            probe8 => probe8_i,
            probe9 => probe9_i,

            probe10 => probe10_i,
            probe11 => probe11_i,
            probe12 => probe12_i,
            probe13 => probe13_i,
            probe14 => probe14_i,
            probe15 => probe15_i,
            probe16 => data_fifo_dout(31 downto 0),
            probe17 => probe17_i,
            probe18 => probe18_i,
            probe19 => probe19_i
            );       


------------------------------------------------
-- External Trigger Input
------------------------------------------------



--  input for external trigger 
--    ibuf_inst_1 : IBUF port map (O => ext_trigger_in, I => EXTERNAL_TRIGGER_HDMI);
    ibuf_inst_1 : IBUFDS port map (O => ext_trigger_port, I => EXTERNAL_TRIGGER_HDMI_P, IB => EXTERNAL_TRIGGER_HDMI_N);

    reading_fin_edge_detect : process(clk_50, reading_fin_flag, reading_fin_flag_d)
    begin
      --rising edge detect
      if rising_edge(clk_50) then
        reading_fin_flag_d <= reading_fin_flag;
      end if;
      reading_fin_flag_edge <= ((not reading_fin_flag_d) and reading_fin_flag);
    end process reading_fin_edge_detect;

    ext_trig_edge_detect : process(clk_100, ext_trigger_port, ext_trigger_d)
    begin
    --rising edge detect
      if rising_edge(clk_100) then
        ext_trigger_d <= ext_trigger_port;
      end if;
      ext_trigger_edge <= (not(ext_trigger_d) and ext_trigger_port);
    end process ext_trig_edge_detect;

    ext_trig_edge_detect_slow : process(clk_40, ext_trigger_port, ext_trigger_d_slow)
    begin
    --should sustain ext_trigger_edge_slow for 50 ns after cktp_done = '1'
      if rising_edge(clk_40) then
            ext_trigger_d_slow <= ext_trigger_port;     
      end if;
      ext_trigger_edge_slow <= (not(ext_trigger_d_slow) and ext_trigger_port);
    end process ext_trig_edge_detect_slow;
    
    ext_trig_gate : process(clk_40, ext_trigger_port)
    begin
    --rising edge detect
      if rising_edge(clk_40) then
            ext_trigger_sync <= ext_trigger_port;     
      end if;
    end process ext_trig_gate;
    
-- simulated input
    ext_trigger_sel : process (ext_trigger_in_sel, clk_40)
    begin
      if rising_edge(clk_40) then
        if ext_trigger_in_sel = '1' then
          if ext_trigger_port = '1' and cktp_done = '1' then
            ext_trigger_flag <= '1';
            ext_trigger_delayed <= ext_trigger_flag;
          else
            ext_trigger_flag <= '0';
            ext_trigger_delayed <= '0';
          end if;
        else
          ext_trigger_flag <= '0';
        end if;
      end if;
    end process ext_trigger_sel;

--   debounce it 
--   i took the code from the template (coding examples, misc, debounce circuit) 
--   here is the debounce circuit for the external_trigger_in
    process(clk_200)
    begin
        if (clk_200'event and clk_200 = '1') then
            if (reset = '1') then
                Q1 <= '0';
                Q2 <= '0';
                Q3 <= '0';
            else
--            elsif cktp_done = '1' then
              
--                Q1 <= ext_trigger_flag;
                Q1 <= ext_trigger_delayed;
--                Q1 <= ext_trigger_port;
                Q2 <= Q1;
                Q3 <= Q2;
            end if;
        end if;
    end process;

    ext_trigger_deb <= Q1 and Q2 and Q3;

--    vmm_ckbc_en <= not(busy_from_ext_trigger or busy_from_acq_rst);  

    --should include busy from just resetting the BCID counter
    
-----------------------------------
--External Trigger Implementation  
-----------------------------------



    external_trigger_inst : external_trigger
        
        port map (
            clk_40                  => clk_40,
            reset_bcid_counter      => reset_bcid_counter,
            ext_trigger_in          => ext_trigger_deb,
            ext_trigger_en          => ext_trigger_in_sel,
            ext_trigger_pulse_o     => ext_trigger_pulse,
            busy_from_ext_trigger_o => busy_from_ext_trigger,
            busy_from_acq_rst_o     => busy_from_acq_rst,
            bcid_counter_o          => bcid_counter,
            bcid_captured_o         => bcid_captured,

            bcid_corrected_o  => bcid_corrected,
            bcid_corrected_m1 => bcid_corrected_m1,
            bcid_corrected_m2 => bcid_corrected_m2,
            bcid_corrected_m3 => bcid_corrected_m3,
            bcid_corrected_m4 => bcid_corrected_m4,
            bcid_corrected_m5 => bcid_corrected_m5,
            bcid_corrected_p1 => bcid_corrected_p1,
            bcid_corrected_p2 => bcid_corrected_p2,
            bcid_corrected_p3 => bcid_corrected_p3,
            bcid_corrected_p4 => bcid_corrected_p4,
            bcid_corrected_p5 => bcid_corrected_p5,
            turn_counter_o    => turn_counter,

            turn_counter_captured_o => turn_counter_captured,
            num_ext_trig_o => num_ext_trig,
            acq_rst_from_ext_trig_o => acq_rst_from_ext_trig,
            vmm_cktk_ext_trig_en_o => vmm_cktk_ext_trig_en,
            read_data_o => read_data,
            fifo_rst_from_ext_trig_o => fifo_rst,
            reading_fin => reading_fin_flag,
            ext_trigger_edge_slow => ext_trigger_edge_slow
            );



---------------------------------          
-- Leaky Bucket implementation
---------------------------------


    leaky_readout_inst : leaky_readout
        port map (
            clk_200 => clk_200,
            axi_clk => EXT_AXI_CLK,
            reset   => reset,

            --     signals from external_trigger    
            ext_trigger_pulse        => ext_trigger_pulse,
            busy_from_ext_trigger    => busy_from_ext_trigger,
            bcid_corrected           => bcid_corrected,
            bcid_corrected_m1        => bcid_corrected_m1,
            bcid_corrected_m2        => bcid_corrected_m2,
            bcid_corrected_m3        => bcid_corrected_m3,
            bcid_corrected_m4        => bcid_corrected_m4,
            bcid_corrected_m5        => bcid_corrected_m5,
            bcid_corrected_p1        => bcid_corrected_p1,
            bcid_corrected_p2        => bcid_corrected_p2,
            bcid_corrected_p3        => bcid_corrected_p3,
            bcid_corrected_p4        => bcid_corrected_p4,
            bcid_corrected_p5        => bcid_corrected_p5,
            turn_counter_ext_trigger => turn_counter_captured,

            --     signals from the data fifo
            data_fifo_rd_en => data_fifo_rd_en,
            data_fifo_dout  => rr_data_fifo_dout,
            data_fifo_empty => rr_data_fifo_empty,
            --data_fifo_rd_count      =>  data_fifo_rd_count,     
            --data_fifo_wr_count      =>  data_fifo_wr_count,

            --     axi      
            --axi_pop_vmm1            =>  axi_pop_vmm1,                              
            --axi_rdata_ls_vmm1       =>  axi_rdata_ls_vmm1,    
            --axi_rdata_rcnt_vmm1     =>  axi_rdata_rcnt_vmm1                          

            axi_pop_vmm1        => axi_pop_vmm1_leak,
            axi_rdata_ls_vmm1   => axi_rdata_ls_vmm1_leak,
            axi_rdata_rcnt_vmm1 => axi_rdata_rcnt_vmm1_leak
            );   



-------------------------------------------=====================================


    Use_RR_or_Leaky_data : process (axi_data_to_use, axi_pop_vmm1, data_fifo_dout, axi_rdata_rcnt_vmm1_rr,
                                    axi_rdata_ls_vmm1_leak, axi_rdata_rcnt_vmm1_leak)

    begin
        case axi_data_to_use is
            when '0' =>                 -- rr to axi
                rr_data_fifo_rd_en  <= axi_pop_vmm1;  -- pop from axi to rr                 
                axi_rdata_ls_vmm1   <= rr_data_fifo_dout;  -- fifo_data from rr to axi
                axi_rdata_rcnt_vmm1 <= rr_rd_data_count;  -- fifo edata count from rr to axi                      

                axi_pop_vmm1_leak <= axi_pop_vmm1;  -- pop from axi to leak                  
                data_fifo_dout    <= rr_data_fifo_dout;  -- fifo data from rr to leaky

            when '1' =>                 -- leak to axi
                rr_data_fifo_rd_en <= data_fifo_rd_en;  -- pop from leak to rr                 
                data_fifo_dout     <= rr_data_fifo_dout;  -- fifo data from rr to leaky
                data_fifo_empty    <= rr_data_fifo_empty;  -- fifo status from rr to leaky

                axi_pop_vmm1_leak   <= axi_pop_vmm1;  -- pop from axi to leak                  
                axi_rdata_ls_vmm1   <= axi_rdata_ls_vmm1_leak;  -- fifo data from leaky to axi
                axi_rdata_rcnt_vmm1 <= axi_rdata_rcnt_vmm1_leak;  -- fifo count from leaky to axi                          

        end case;
    end process Use_RR_or_Leaky_data;



-------------------------------------------=====================================



-----------------------------------
--Vmm_configuration and DAQ Module
-----------------------------------


    vmm_cfg_inst : vmm_cfg
        port map
        (
            clk_ila     => clk_100,
            clk200      => clk_200 ,    -- 200MHz
            vmm_clk_200 => clk_200 ,
            EXT_AXI_CLK => EXT_AXI_CLK,
            clk100      => clk_100 ,    -- 100MHz
            vmm_clk_100 => clk_100 ,
            clk10 => clk_10 ,
            vmm_clk_10 => clk_10 ,

            reset => reset,

            cfg_bit_in  => vmm_do,  -- in from vmm --b
            cfg_bit_out => vmm_di,  -- out to vmm  --b



            vmm_wen_gbl_rst => vmm_wen_gbl_rst,  -- gbl reset wen output for vmm selected for sys init
            vmm_wen_acq_rst => vmm_wen_acq_rst,  -- acq reset wen output on per vmm vector

            vmm_ena_gbl_rst => vmm_ena_gbl_rst,  -- global reset ena output for vmm selected for gbl reset or sys init
            vmm_ena_acq_rst => vmm_ena_acq_rst,  -- acq reset ena output on per vmm vector

            vmm_wen_cfg_sr => vmm_wen_cfg_sr,  -- config shift reg ena output for vmm selected for sys init
            vmm_ena_cfg_sr => vmm_ena_cfg_sr,  -- config shift reg ena output for vmm selected for sys init

            vmm_acq_rst_running      => vmm_acq_rst_running,  -- used to allow vmm_ena_acq_rst to drive low by not anding with vmm_ena_vmm_cfg_sm
--        vmm_ena_vmm_cfg_sm    => vmm_ena_vmm_cfg_sm,                   -- sys_init_sm_acq_en
            vmm_ena_vmm_cfg_sm_vec_o => vmm_ena_vmm_cfg_sm_vec,


            vmm_ckdt_en_vec => vmm_ckdt_en_vec,
            vmm_ckdt        => vmm_ckdt,

            vmm_ckart_en => vmm_ckart_en,
            vmm_ckart    => vmm_ckart,

            vmm_cktk_daq_en_vec => vmm_cktk_daq_en_vec,  --from daq
            vmm_cktk_cfg_sr_en  => vmm_cktk_cfg_sr_en,   --from config module
            vmm_cktk            => vmm_cktk,

            vmm_cktp_en => vmm_cktp_en,
            vmm_cktp    => vmm_cktp,

            vmm_ckbc_en        => vmm_ckbc_en,
            vmm_ckbc           => vmm_ckbc,
            reset_bcid_counter => reset_bcid_counter,

            vmm_data0_vec => vmm_data0_vec,
            vmm_data1_vec => vmm_data1_vec,
            vmm_art_vec   => vmm_art_vec,
            turn_counter  => turn_counter,

            wr_en => fifo_wr_en_i,

            vmm_rd_en => vmm_rd_en,

            vmm_din_vec       => vmm_din_vec,        --from daq
            dt_cntr_intg0_vec => dt_cntr_intg0_vec,  --from daq
            dt_cntr_intg1_vec => dt_cntr_intg1_vec,  --from daq
            vmm_data_buf_vec  => vmm_data_buf_vec,   --from daq
            vmm_dout_vec      => vmm_dout_vec,       --from daq 

            rr_state => rr_state,
            din      => din,

            vmm_ro => vmm_ro_i,

            vmm_configuring => vmm_configuring,
            rst_state       => rst_state,


            LEDx  => LEDx,
            testX => testX,

            axi_reg => axi_reg,         --axi config data

            vmm_cfg_sel => axi_reg(59),

            axi_clk => EXT_AXI_CLK,

            rr_data_fifo_rd_en => rr_data_fifo_rd_en,
            rr_data_fifo_dout  => rr_data_fifo_dout,
            rr_data_fifo_empty => rr_data_fifo_empty,
            rr_rd_data_count   => rr_rd_data_count(9 downto 0),
            rr_wr_data_count   => open,

            vmm_gbl_rst     => vmm_gbl_rst,
            vmm_gbl_rst_sum => vmm_gbl_rst_sum,
            vmm_cfg_en_vec  => vmm_cfg_en_vec,
            vmm_load        => vmm_load,

            vmm_ena_vmm_cfg_sm_o   => vmm_ena_vmm_cfg_sm,
            acq_rst_from_vmm_fsm_o => acq_rst_from_vmm_fsm,
--        vmm_ena_vmm_cfg_sm_vec_o => vmm_ena_vmm_cfg_sm_vec

            acq_rst_term_count      => acq_rst_term_count,
            acq_rst_hold_term_count => acq_rst_hold_term_count,
            acq_rst_from_data0_o => acq_rst_from_data0,
--        vmm_acq_rst_running     => vmm_acq_rst_running,
--        acq_rst_term_count      => acq_rst_term_count,
            dt_state             => dt_state,
            acq_rst_counter      => acq_rst_counter,
            acq_rst_from_ext_trig => acq_rst_from_ext_trig,
            fifo_rst_from_ext_trig => fifo_rst,
            int_trig => int_trig
            );



------------------
--Do I/O from VMM
------------------


    -- i/o for vmm
    -- config data in from vmm 

    do_diff_1 : IBUFDS port map (O => vmm_do_vec(0), I => DO_1_P, IB => DO_1_N);
    do_diff_2 : IBUFDS port map (O => vmm_do_vec(1), I => DO_2_P, IB => DO_2_N);
    do_diff_3 : IBUFDS port map (O => vmm_do_vec(2), I => DO_3_P, IB => DO_3_N);
    do_diff_4 : IBUFDS port map (O => vmm_do_vec(3), I => DO_4_P, IB => DO_4_N);
    do_diff_5 : IBUFDS port map (O => vmm_do_vec(4), I => DO_5_P, IB => DO_5_N);
    do_diff_6 : IBUFDS port map (O => vmm_do_vec(5), I => DO_6_P, IB => DO_6_N);
    do_diff_7 : IBUFDS port map (O => vmm_do_vec(6), I => DO_7_P, IB => DO_7_N);
    do_diff_8 : IBUFDS port map (O => vmm_do_vec(7), I => DO_8_P, IB => DO_8_N);


----------------
--Di I/O to VMM
----------------


    -- config data out to vmm 
    di_diff_1 : OBUFDS port map (O => DI_1_P, OB => DI_1_N, I => vmm_di_1);
    di_diff_2 : OBUFDS port map (O => DI_2_P, OB => DI_2_N, I => vmm_di_2);
    di_diff_3 : OBUFDS port map (O => DI_3_P, OB => DI_3_N, I => vmm_di_3);
    di_diff_4 : OBUFDS port map (O => DI_4_P, OB => DI_4_N, I => vmm_di_4);
    di_diff_5 : OBUFDS port map (O => DI_5_P, OB => DI_5_N, I => vmm_di_5);
    di_diff_6 : OBUFDS port map (O => DI_6_P, OB => DI_6_N, I => vmm_di_6);
    di_diff_7 : OBUFDS port map (O => DI_7_P, OB => DI_7_N, I => vmm_di_7);
    di_diff_8 : OBUFDS port map (O => DI_8_P, OB => DI_8_N, I => vmm_di_8);

    vmm_di_r_vec(0) <= not(vmm_di_en_vec(0));
    vmm_di_r_vec(1) <= not(vmm_di_en_vec(1));
    vmm_di_r_vec(2) <= not(vmm_di_en_vec(2));
    vmm_di_r_vec(3) <= not(vmm_di_en_vec(3));
    vmm_di_r_vec(4) <= not(vmm_di_en_vec(4));
    vmm_di_r_vec(5) <= not(vmm_di_en_vec(5));
    vmm_di_r_vec(6) <= not(vmm_di_en_vec(6));
    vmm_di_r_vec(7) <= not(vmm_di_en_vec(7));

    di_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_di_1, C => vmm_di, CE => vmm_di_en_vec(0), D1 => '1', D2 => '0', R => vmm_di_r_vec(0), S => '0');
    di_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_di_2, C => vmm_di, CE => vmm_di_en_vec(1), D1 => '1', D2 => '0', R => vmm_di_r_vec(1), S => '0');
    di_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_di_3, C => vmm_di, CE => vmm_di_en_vec(2), D1 => '1', D2 => '0', R => vmm_di_r_vec(2), S => '0');
    di_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_di_4, C => vmm_di, CE => vmm_di_en_vec(3), D1 => '1', D2 => '0', R => vmm_di_r_vec(3), S => '0');
    di_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_di_5, C => vmm_di, CE => vmm_di_en_vec(4), D1 => '1', D2 => '0', R => vmm_di_r_vec(4), S => '0');
    di_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_di_6, C => vmm_di, CE => vmm_di_en_vec(5), D1 => '1', D2 => '0', R => vmm_di_r_vec(5), S => '0');
    di_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_di_7, C => vmm_di, CE => vmm_di_en_vec(6), D1 => '1', D2 => '0', R => vmm_di_r_vec(6), S => '0');
    di_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_di_8, C => vmm_di, CE => vmm_di_en_vec(7), D1 => '1', D2 => '0', R => vmm_di_r_vec(7), S => '0');


----------------------
--WEN I/O
----------------------


    wen_diff_1 : OBUFDS port map (O => WEN_1_P, OB => WEN_1_N, I => vmm_wen_1);
    wen_diff_2 : OBUFDS port map (O => WEN_2_P, OB => WEN_2_N, I => vmm_wen_2);
    wen_diff_3 : OBUFDS port map (O => WEN_3_P, OB => WEN_3_N, I => vmm_wen_3);
    wen_diff_4 : OBUFDS port map (O => WEN_4_P, OB => WEN_4_N, I => vmm_wen_4);
    wen_diff_5 : OBUFDS port map (O => WEN_5_P, OB => WEN_5_N, I => vmm_wen_5);
    wen_diff_6 : OBUFDS port map (O => WEN_6_P, OB => WEN_6_N, I => vmm_wen_6);
    wen_diff_7 : OBUFDS port map (O => WEN_7_P, OB => WEN_7_N, I => vmm_wen_7);
    wen_diff_8 : OBUFDS port map (O => WEN_8_P, OB => WEN_8_N, I => vmm_wen_8);

    vmm_wen_R <= not(vmm_wen_en);

    wen_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_wen_1, C => vmm_wen_vec(0), CE => vmm_wen_en, D1 => '1', D2 => '0', R => vmm_wen_R, S => '0');
    wen_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_wen_2, C => vmm_wen_vec(1), CE => vmm_wen_en, D1 => '1', D2 => '0', R => vmm_wen_R, S => '0');
    wen_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_wen_3, C => vmm_wen_vec(2), CE => vmm_wen_en, D1 => '1', D2 => '0', R => vmm_wen_R, S => '0');
    wen_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_wen_4, C => vmm_wen_vec(3), CE => vmm_wen_en, D1 => '1', D2 => '0', R => vmm_wen_R, S => '0');
    wen_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_wen_5, C => vmm_wen_vec(4), CE => vmm_wen_en, D1 => '1', D2 => '0', R => vmm_wen_R, S => '0');
    wen_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_wen_6, C => vmm_wen_vec(5), CE => vmm_wen_en, D1 => '1', D2 => '0', R => vmm_wen_R, S => '0');
    wen_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_wen_7, C => vmm_wen_vec(6), CE => vmm_wen_en, D1 => '1', D2 => '0', R => vmm_wen_R, S => '0');
    wen_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_wen_8, C => vmm_wen_vec(7), CE => vmm_wen_en, D1 => '1', D2 => '0', R => vmm_wen_R, S => '0');

    vmm_wen_en <= '1';



-------------------
--ENA I/O
-------------------


    ena_diff_1 : OBUFDS port map (O => ENA_1_P, OB => ENA_1_N, I => vmm_ena_1);
    ena_diff_2 : OBUFDS port map (O => ENA_2_P, OB => ENA_2_N, I => vmm_ena_2);
    ena_diff_3 : OBUFDS port map (O => ENA_3_P, OB => ENA_3_N, I => vmm_ena_3);
    ena_diff_4 : OBUFDS port map (O => ENA_4_P, OB => ENA_4_N, I => vmm_ena_4);
    ena_diff_5 : OBUFDS port map (O => ENA_5_P, OB => ENA_5_N, I => vmm_ena_5);
    ena_diff_6 : OBUFDS port map (O => ENA_6_P, OB => ENA_6_N, I => vmm_ena_6);
    ena_diff_7 : OBUFDS port map (O => ENA_7_P, OB => ENA_7_N, I => vmm_ena_7);
    ena_diff_8 : OBUFDS port map (O => ENA_8_P, OB => ENA_8_N, I => vmm_ena_8);

    vmm_ena_R <= not(vmm_ena_en);

    ena_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ena_1, C => vmm_ena_vec(0), CE => vmm_ena_en, D1 => '1', D2 => '0', R => vmm_ena_R, S => '0');
    ena_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ena_2, C => vmm_ena_vec(1), CE => vmm_ena_en, D1 => '1', D2 => '0', R => vmm_ena_R, S => '0');
    ena_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ena_3, C => vmm_ena_vec(2), CE => vmm_ena_en, D1 => '1', D2 => '0', R => vmm_ena_R, S => '0');
    ena_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ena_4, C => vmm_ena_vec(3), CE => vmm_ena_en, D1 => '1', D2 => '0', R => vmm_ena_R, S => '0');
    ena_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ena_5, C => vmm_ena_vec(4), CE => vmm_ena_en, D1 => '1', D2 => '0', R => vmm_ena_R, S => '0');
    ena_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ena_6, C => vmm_ena_vec(5), CE => vmm_ena_en, D1 => '1', D2 => '0', R => vmm_ena_R, S => '0');
    ena_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ena_7, C => vmm_ena_vec(6), CE => vmm_ena_en, D1 => '1', D2 => '0', R => vmm_ena_R, S => '0');
    ena_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ena_8, C => vmm_ena_vec(7), CE => vmm_ena_en, D1 => '1', D2 => '0', R => vmm_ena_R, S => '0');
    
    vmm_ena_en <= '1';




    -----------------
    --CKBC I/O
    -----------------




    ckbc_diff_1 : OBUFDS port map (O => CKBC_1_P, OB => CKBC_1_N, I => vmm_ckbc_1);
    ckbc_diff_2 : OBUFDS port map (O => CKBC_2_P, OB => CKBC_2_N, I => vmm_ckbc_2);
    ckbc_diff_3 : OBUFDS port map (O => CKBC_3_P, OB => CKBC_3_N, I => vmm_ckbc_3);
    ckbc_diff_4 : OBUFDS port map (O => CKBC_4_P, OB => CKBC_4_N, I => vmm_ckbc_4);
    ckbc_diff_5 : OBUFDS port map (O => CKBC_5_P, OB => CKBC_5_N, I => vmm_ckbc_5);
    ckbc_diff_6 : OBUFDS port map (O => CKBC_6_P, OB => CKBC_6_N, I => vmm_ckbc_6);
    ckbc_diff_7 : OBUFDS port map (O => CKBC_7_P, OB => CKBC_7_N, I => vmm_ckbc_7);
    ckbc_diff_8 : OBUFDS port map (O => CKBC_8_P, OB => CKBC_8_N, I => vmm_ckbc_8);

    vmm_ckbc_R <= not(vmm_ckbc_all_en);
--    vmm_ckbc_R <= not(vmm_ckbc_en);

    ckbc_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckbc_1, C => vmm_ckbc, CE => vmm_ckbc_all_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    ckbc_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckbc_2, C => vmm_ckbc, CE => vmm_ckbc_all_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    ckbc_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckbc_3, C => vmm_ckbc, CE => vmm_ckbc_all_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    ckbc_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckbc_4, C => vmm_ckbc, CE => vmm_ckbc_all_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    ckbc_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckbc_5, C => vmm_ckbc, CE => vmm_ckbc_all_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    ckbc_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckbc_6, C => vmm_ckbc, CE => vmm_ckbc_all_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    ckbc_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckbc_7, C => vmm_ckbc, CE => vmm_ckbc_all_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    ckbc_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckbc_8, C => vmm_ckbc, CE => vmm_ckbc_all_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');


    --ckbc_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
    --    port map(Q => vmm_ckbc_1, C => vmm_ckbc, CE => vmm_ckbc_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    --ckbc_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
    --    port map(Q => vmm_ckbc_2, C => vmm_ckbc, CE => vmm_ckbc_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    --ckbc_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
    --    port map(Q => vmm_ckbc_3, C => vmm_ckbc, CE => vmm_ckbc_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    --ckbc_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
    --    port map(Q => vmm_ckbc_4, C => vmm_ckbc, CE => vmm_ckbc_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    --ckbc_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
    --    port map(Q => vmm_ckbc_5, C => vmm_ckbc, CE => vmm_ckbc_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    --ckbc_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
    --    port map(Q => vmm_ckbc_6, C => vmm_ckbc, CE => vmm_ckbc_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    --ckbc_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
    --    port map(Q => vmm_ckbc_7, C => vmm_ckbc, CE => vmm_ckbc_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');
    --ckbc_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
    --    port map(Q => vmm_ckbc_8, C => vmm_ckbc, CE => vmm_ckbc_en, D1 => '1', D2 => '0', R => vmm_ckbc_R, S => '0');

    vmm_ckbc <= clk_bc_out;



-------------------------
--CKTK I/O
-------------------------



    cktk_diff_1 : OBUFDS port map (O => CKTK_1_P, OB => CKTK_1_N, I => vmm_cktk_1);
    cktk_diff_2 : OBUFDS port map (O => CKTK_2_P, OB => CKTK_2_N, I => vmm_cktk_2);
    cktk_diff_3 : OBUFDS port map (O => CKTK_3_P, OB => CKTK_3_N, I => vmm_cktk_3);
    cktk_diff_4 : OBUFDS port map (O => CKTK_4_P, OB => CKTK_4_N, I => vmm_cktk_4);
    cktk_diff_5 : OBUFDS port map (O => CKTK_5_P, OB => CKTK_5_N, I => vmm_cktk_5);
    cktk_diff_6 : OBUFDS port map (O => CKTK_6_P, OB => CKTK_6_N, I => vmm_cktk_6);
    cktk_diff_7 : OBUFDS port map (O => CKTK_7_P, OB => CKTK_7_N, I => vmm_cktk_7);
    cktk_diff_8 : OBUFDS port map (O => CKTK_8_P, OB => CKTK_8_N, I => vmm_cktk_8);

    vmm_cktk_r_vec(0) <= not(vmm_cktk_en_vec(0));
    vmm_cktk_r_vec(1) <= not(vmm_cktk_en_vec(1));
    vmm_cktk_r_vec(2) <= not(vmm_cktk_en_vec(2));
    vmm_cktk_r_vec(3) <= not(vmm_cktk_en_vec(3));
    vmm_cktk_r_vec(4) <= not(vmm_cktk_en_vec(4));
    vmm_cktk_r_vec(5) <= not(vmm_cktk_en_vec(5));
    vmm_cktk_r_vec(6) <= not(vmm_cktk_en_vec(6));
    vmm_cktk_r_vec(7) <= not(vmm_cktk_en_vec(7));

    cktk_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktk_1, C => vmm_cktk, CE => vmm_cktk_en_vec(0), D1 => '1', D2 => '0', R => vmm_cktk_r_vec(0), S => '0');
    cktk_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktk_2, C => vmm_cktk, CE => vmm_cktk_en_vec(1), D1 => '1', D2 => '0', R => vmm_cktk_r_vec(1), S => '0');
    cktk_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktk_3, C => vmm_cktk, CE => vmm_cktk_en_vec(2), D1 => '1', D2 => '0', R => vmm_cktk_r_vec(2), S => '0');
    cktk_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktk_4, C => vmm_cktk, CE => vmm_cktk_en_vec(3), D1 => '1', D2 => '0', R => vmm_cktk_r_vec(3), S => '0');
    cktk_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktk_5, C => vmm_cktk, CE => vmm_cktk_en_vec(4), D1 => '1', D2 => '0', R => vmm_cktk_r_vec(4), S => '0');
    cktk_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktk_6, C => vmm_cktk, CE => vmm_cktk_en_vec(5), D1 => '1', D2 => '0', R => vmm_cktk_r_vec(5), S => '0');
    cktk_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktk_7, C => vmm_cktk, CE => vmm_cktk_en_vec(6), D1 => '1', D2 => '0', R => vmm_cktk_r_vec(6), S => '0');
    cktk_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktk_8, C => vmm_cktk, CE => vmm_cktk_en_vec(7), D1 => '1', D2 => '0', R => vmm_cktk_r_vec(7), S => '0');
    
    vmm_cktk <= clk_tk_out;



-----------------------
--CKTP I/O
-----------------------



    cktp_diff_1 : OBUFDS port map (O => CKTP_1_P, OB => CKTP_1_N, I => vmm_cktp_1);
    cktp_diff_2 : OBUFDS port map (O => CKTP_2_P, OB => CKTP_2_N, I => vmm_cktp_2);
    cktp_diff_3 : OBUFDS port map (O => CKTP_3_P, OB => CKTP_3_N, I => vmm_cktp_3);
    cktp_diff_4 : OBUFDS port map (O => CKTP_4_P, OB => CKTP_4_N, I => vmm_cktp_4);
    cktp_diff_5 : OBUFDS port map (O => CKTP_5_P, OB => CKTP_5_N, I => vmm_cktp_5);
    cktp_diff_6 : OBUFDS port map (O => CKTP_6_P, OB => CKTP_6_N, I => vmm_cktp_6);
    cktp_diff_7 : OBUFDS port map (O => CKTP_7_P, OB => CKTP_7_N, I => vmm_cktp_7);
    cktp_diff_8 : OBUFDS port map (O => CKTP_8_P, OB => CKTP_8_N, I => vmm_cktp_8);


-- kjohns for the moment we are pulsing all vmm

    cktp_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktp_1, C => vmm_cktp, CE => '1', D1 => '1', D2 => '0', R => '0', S => '0');
    cktp_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktp_2, C => vmm_cktp, CE => '1', D1 => '1', D2 => '0', R => '0', S => '0');
    cktp_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktp_3, C => vmm_cktp, CE => '1', D1 => '1', D2 => '0', R => '0', S => '0');
    cktp_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktp_4, C => vmm_cktp, CE => '1', D1 => '1', D2 => '0', R => '0', S => '0');
    cktp_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktp_5, C => vmm_cktp, CE => '1', D1 => '1', D2 => '0', R => '0', S => '0');
    cktp_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktp_6, C => vmm_cktp, CE => '1', D1 => '1', D2 => '0', R => '0', S => '0');
    cktp_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktp_7, C => vmm_cktp, CE => '1', D1 => '1', D2 => '0', R => '0', S => '0');
    cktp_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_cktp_8, C => vmm_cktp, CE => '1', D1 => '1', D2 => '0', R => '0', S => '0');
    
    vmm_cktp <= clk_tp_out or clk_tp_out_calib;




-----------------------------
--Data0, Data1 I/O
-----------------------------


  data0_diff_1 : IBUFDS port map (O => vmm_data0_async_vec(0), I => DATA0_1_P, IB => DATA0_1_N);
  data0_diff_2 : IBUFDS port map (O => vmm_data0_async_vec(1), I => DATA0_2_P, IB => DATA0_2_N);
  data0_diff_3 : IBUFDS port map (O => vmm_data0_async_vec(2), I => DATA0_3_P, IB => DATA0_3_N);
  data0_diff_4 : IBUFDS port map (O => vmm_data0_async_vec(3), I => DATA0_4_P, IB => DATA0_4_N);
  data0_diff_5 : IBUFDS port map (O => vmm_data0_async_vec(4), I => DATA0_5_P, IB => DATA0_5_N);
  data0_diff_6 : IBUFDS port map (O => vmm_data0_async_vec(5), I => DATA0_6_P, IB => DATA0_6_N);
  data0_diff_7 : IBUFDS port map (O => vmm_data0_async_vec(6), I => DATA0_7_P, IB => DATA0_7_N);
  data0_diff_8 : IBUFDS port map (O => vmm_data0_async_vec(7), I => DATA0_8_P, IB => DATA0_8_N);


  data1_diff_1 : IBUFDS port map (O => vmm_data1_async_vec(0), I => DATA1_1_P, IB => DATA1_1_N);
  data1_diff_2 : IBUFDS port map (O => vmm_data1_async_vec(1), I => DATA1_2_P, IB => DATA1_2_N);
  data1_diff_3 : IBUFDS port map (O => vmm_data1_async_vec(2), I => DATA1_3_P, IB => DATA1_3_N);
  data1_diff_4 : IBUFDS port map (O => vmm_data1_async_vec(3), I => DATA1_4_P, IB => DATA1_4_N);
  data1_diff_5 : IBUFDS port map (O => vmm_data1_async_vec(4), I => DATA1_5_P, IB => DATA1_5_N);
  data1_diff_6 : IBUFDS port map (O => vmm_data1_async_vec(5), I => DATA1_6_P, IB => DATA1_6_N);
  data1_diff_7 : IBUFDS port map (O => vmm_data1_async_vec(6), I => DATA1_7_P, IB => DATA1_7_N);
  data1_diff_8 : IBUFDS port map (O => vmm_data1_async_vec(7), I => DATA1_8_P, IB => DATA1_8_N);

  --synchronizing data0 and data1 inputs to clk_200
  
  sync_data: process (clk_200)
  begin  -- process sync_data0
    if rising_edge(clk_200) then
      for I in 0 to 7 loop
        vmm_data0_sync_vec(I) <= vmm_data0_async_vec(I);
        vmm_data0_vec(I) <= vmm_data0_sync_vec(I);
        vmm_data1_sync_vec(I) <= vmm_data1_async_vec(I);
        vmm_data1_vec(I) <= vmm_data1_sync_vec(I);
      end loop;  -- I
    end if;
  end process sync_data;

------------------
--CKDT I/O
------------------



    ckdt_diff_1 : OBUFDS port map (O => ckdt_1_P, OB => ckdt_1_N, I => vmm_ckdt_1);
    ckdt_diff_2 : OBUFDS port map (O => ckdt_2_P, OB => ckdt_2_N, I => vmm_ckdt_2);
    ckdt_diff_3 : OBUFDS port map (O => ckdt_3_P, OB => ckdt_3_N, I => vmm_ckdt_3);
    ckdt_diff_4 : OBUFDS port map (O => ckdt_4_P, OB => ckdt_4_N, I => vmm_ckdt_4);
    ckdt_diff_5 : OBUFDS port map (O => ckdt_5_P, OB => ckdt_5_N, I => vmm_ckdt_5);
    ckdt_diff_6 : OBUFDS port map (O => ckdt_6_P, OB => ckdt_6_N, I => vmm_ckdt_6);
    ckdt_diff_7 : OBUFDS port map (O => ckdt_7_P, OB => ckdt_7_N, I => vmm_ckdt_7);
    ckdt_diff_8 : OBUFDS port map (O => ckdt_8_P, OB => ckdt_8_N, I => vmm_ckdt_8);

    vmm_ckdt_r_vec(0) <= not(vmm_ckdt_en_vec(0));
    vmm_ckdt_r_vec(1) <= not(vmm_ckdt_en_vec(1));
    vmm_ckdt_r_vec(2) <= not(vmm_ckdt_en_vec(2));
    vmm_ckdt_r_vec(3) <= not(vmm_ckdt_en_vec(3));
    vmm_ckdt_r_vec(4) <= not(vmm_ckdt_en_vec(4));
    vmm_ckdt_r_vec(5) <= not(vmm_ckdt_en_vec(5));
    vmm_ckdt_r_vec(6) <= not(vmm_ckdt_en_vec(6));
    vmm_ckdt_r_vec(7) <= not(vmm_ckdt_en_vec(7));



    ckdt_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckdt_1, C => vmm_ckdt, CE => vmm_ckdt_en_vec(0), D1 => '1', D2 => '0', R => vmm_ckdt_r_vec(0), S => '0');
    ckdt_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckdt_2, C => vmm_ckdt, CE => vmm_ckdt_en_vec(1), D1 => '1', D2 => '0', R => vmm_ckdt_r_vec(1), S => '0');
    ckdt_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckdt_3, C => vmm_ckdt, CE => vmm_ckdt_en_vec(2), D1 => '1', D2 => '0', R => vmm_ckdt_r_vec(2), S => '0');
    ckdt_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckdt_4, C => vmm_ckdt, CE => vmm_ckdt_en_vec(3), D1 => '1', D2 => '0', R => vmm_ckdt_r_vec(3), S => '0');
    ckdt_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckdt_5, C => vmm_ckdt, CE => vmm_ckdt_en_vec(4), D1 => '1', D2 => '0', R => vmm_ckdt_r_vec(4), S => '0');
    ckdt_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckdt_6, C => vmm_ckdt, CE => vmm_ckdt_en_vec(5), D1 => '1', D2 => '0', R => vmm_ckdt_r_vec(5), S => '0');
    ckdt_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckdt_7, C => vmm_ckdt, CE => vmm_ckdt_en_vec(6), D1 => '1', D2 => '0', R => vmm_ckdt_r_vec(6), S => '0');
    ckdt_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckdt_8, C => vmm_ckdt, CE => vmm_ckdt_en_vec(7), D1 => '1', D2 => '0', R => vmm_ckdt_r_vec(7), S => '0');




    vmm_ckdt <= clk_dt_out;
-- a test for why we can't see vmm_ckdt on the scope 
-- we cannot see the 200 MHz clock on our crummy scope 
-- this should do a divide by 4   
    process(clk_200)
    begin
        if rising_edge(clk_200) then
            counter_kj <= counter_kj + b"00000001";
        end if;
    end process;
    vmm_ckdt_kj <= counter_kj(2);



------------------------
-- ART Clock I/O
------------------------



    ckart_diff_1 : OBUFDS port map (O => ckart_1_P, OB => ckart_1_N, I => vmm_ckart_1);
    ckart_diff_2 : OBUFDS port map (O => ckart_2_P, OB => ckart_2_N, I => vmm_ckart_2);
    ckart_diff_3 : OBUFDS port map (O => ckart_3_P, OB => ckart_3_N, I => vmm_ckart_3);
    ckart_diff_4 : OBUFDS port map (O => ckart_4_P, OB => ckart_4_N, I => vmm_ckart_4);
    ckart_diff_5 : OBUFDS port map (O => ckart_5_P, OB => ckart_5_N, I => vmm_ckart_5);
    ckart_diff_6 : OBUFDS port map (O => ckart_6_P, OB => ckart_6_N, I => vmm_ckart_6);
    ckart_diff_7 : OBUFDS port map (O => ckart_7_P, OB => ckart_7_N, I => vmm_ckart_7);
    ckart_diff_8 : OBUFDS port map (O => ckart_8_P, OB => ckart_8_N, I => vmm_ckart_8);

    vmm_ckart_r <= not(vmm_ckart_en);


    ckart_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckart_1, C => vmm_ckart, CE => vmm_ckart_en, D1 => '1', D2 => '0', R => vmm_ckart_r, S => '0');
    ckart_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckart_2, C => vmm_ckart, CE => vmm_ckart_en, D1 => '1', D2 => '0', R => vmm_ckart_r, S => '0');
    ckart_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckart_3, C => vmm_ckart, CE => vmm_ckart_en, D1 => '1', D2 => '0', R => vmm_ckart_r, S => '0');
    ckart_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckart_4, C => vmm_ckart, CE => vmm_ckart_en, D1 => '1', D2 => '0', R => vmm_ckart_r, S => '0');
    ckart_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckart_5, C => vmm_ckart, CE => vmm_ckart_en, D1 => '1', D2 => '0', R => vmm_ckart_r, S => '0');
    ckart_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckart_6, C => vmm_ckart, CE => vmm_ckart_en, D1 => '1', D2 => '0', R => vmm_ckart_r, S => '0');
    ckart_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckart_7, C => vmm_ckart, CE => vmm_ckart_en, D1 => '1', D2 => '0', R => vmm_ckart_r, S => '0');
    ckart_ODDR_8 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => vmm_ckart_8, C => vmm_ckart, CE => vmm_ckart_en, D1 => '1', D2 => '0', R => vmm_ckart_r, S => '0');



-------------------------------------------------
-- ART looped back via miniSAS on ELINK_TX_X_P_N
-------------------------------------------------


    elink_tx_1_diff : IBUFDS port map (O => vmm_art_vec(0), I => ELINK_TX_1_P, IB => ELINK_TX_1_N);
    elink_tx_2_diff : IBUFDS port map (O => vmm_art_vec(1), I => ELINK_TX_2_P, IB => ELINK_TX_2_N);
    elink_tx_3_diff : IBUFDS port map (O => vmm_art_vec(2), I => ELINK_TX_3_P, IB => ELINK_TX_3_N);
    elink_tx_4_diff : IBUFDS port map (O => vmm_art_vec(3), I => ELINK_TX_4_P, IB => ELINK_TX_4_N);
    elink_ck_1_diff : IBUFDS port map (O => vmm_art_vec(4), I => ELINK_CLK_1_P, IB => ELINK_CLK_1_N);
    elink_rx_1_diff : IBUFDS port map (O => vmm_art_vec(5), I => ELINK_RX_1_P, IB => ELINK_RX_1_N);
    elink_ck_2_diff : IBUFDS port map (O => vmm_art_vec(6), I => ELINK_CLK_2_P, IB => ELINK_CLK_2_N);
    elink_rx_2_diff : IBUFDS port map (O => vmm_art_vec(7), I => ELINK_RX_2_P, IB => ELINK_RX_2_N);



------------------------------------------------------
-- vmm tokens -- must be set to '0' to operate vmm
------------------------------------------------------


    token_diff_1 : IBUFDS port map (O => vmm_TKO, I => TKO_8_P, IB => TKO_8_N);
    token_diff_2 : IBUFDS port map (O => vmm_SETB, I => SETB_8_P, IB => SETB_8_N);
    token_diff_4 : IBUFDS port map (O => vmm_SETT, I => SETT_1_P, IB => SETT_1_N);

    token_diff_3 : OBUFDS port map (O => TKI_1_P, OB => TKI_1_N, I => vmm_TKI);
    token_ODDR_1 : ODDR port map(Q    => vmm_TKI, C => vmm_TKI_i, CE => vmm_TKI_en, D1 => '1', D2 => '0', R => '0', S => '0');
    vmm_TKI_i  <= '0';
    vmm_TKI_en <= '1';




---------------------------------
-- Scope Monitor I/O
---------------------------------



--Note: these are set in the correct order now -- bill

    -- monitor pins
    obuf_inst_21 : OBUF port map (O => EXTERNAL_0_P, I => scopeD0);
    obuf_inst_22 : OBUF port map (O => EXTERNAL_0_N, I => scopeD1);
    obuf_inst_23 : OBUF port map (O => EXTERNAL_1_P, I => scopeD2);
    obuf_inst_24 : OBUF port map (O => EXTERNAL_1_N, I => scopeD3);
    obuf_inst_25 : OBUF port map (O => EXTERNAL_2_P, I => scopeD4);
    obuf_inst_26 : OBUF port map (O => EXTERNAL_2_N, I => scopeD5);
    obuf_inst_27 : OBUF port map (O => EXTERNAL_3_P, I => scopeD6);
    obuf_inst_28 : OBUF port map (O => EXTERNAL_3_N, I => scopeD7);

    scope_R(0) <= not(scope_CE(0));
    scope_R(1) <= not(scope_CE(1));
    scope_R(2) <= not(scope_CE(2));
    scope_R(3) <= not(scope_CE(3));
    scope_R(4) <= not(scope_CE(4));
    scope_R(5) <= not(scope_CE(5));
    scope_R(6) <= not(scope_CE(6));
    scope_R(7) <= not(scope_CE(7));

    scope_ODDR_0 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => scopeD0, C => scopeD0_i, CE => scope_CE(0), D1 => '1', D2 => '0', R => scope_R(0), S => '0');
    scope_ODDR_1 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => scopeD1, C => scopeD1_i, CE => scope_CE(1), D1 => '1', D2 => '0', R => scope_R(1), S => '0');
    scope_ODDR_2 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => scopeD2, C => scopeD2_i, CE => scope_CE(2), D1 => '1', D2 => '0', R => scope_R(2), S => '0');
    scope_ODDR_3 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => scopeD3, C => scopeD3_i, CE => scope_CE(3), D1 => '1', D2 => '0', R => scope_R(3), S => '0');
    scope_ODDR_4 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => scopeD4, C => scopeD4_i, CE => scope_CE(4), D1 => '1', D2 => '0', R => scope_R(4), S => '0');
    scope_ODDR_5 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => scopeD5, C => scopeD5_i, CE => scope_CE(5), D1 => '1', D2 => '0', R => scope_R(5), S => '0');
    scope_ODDR_6 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => scopeD6, C => scopeD6_i, CE => scope_CE(6), D1 => '1', D2 => '0', R => scope_R(6), S => '0');
    scope_ODDR_7 : ODDR generic map(DDR_CLK_EDGE => "OPPOSITE_EDGE", INIT => '0', SRTYPE => "SYNC")
        port map(Q => scopeD7, C => scopeD7_i, CE => scope_CE(7), D1 => '1', D2 => '0', R => scope_R(7), S => '0');



-----------------------------------
--Scope Monitor Module
-----------------------------------



    scope_select_inst : scope_select
        port map(

            scopeD0 => scopeD0_i,
            scopeD1 => scopeD1_i,
            scopeD2 => scopeD2_i,
            scopeD3 => scopeD3_i,
            scopeD4 => scopeD4_i,
            scopeD5 => scopeD5_i,
            scopeD6 => scopeD6_i,
            scopeD7 => scopeD7_i,

            scope_CE     => scope_CE,
            vmm_2display => vmm_2display,


            vmm_ckbc    => vmm_ckbc,
            vmm_ckbc_en => vmm_ckbc_en,
            vmm_ckbc_all_en => vmm_ckbc_all_en,

            vmm_cktp    => vmm_cktp,
            vmm_cktp_en => vmm_cktp_en,

            vmm_di        => vmm_di,
            vmm_di_en_vec => vmm_di_en_vec,

            vmm_data0_vec => vmm_data0_vec,
            vmm_data1_vec => vmm_data1_vec,

            vmm_do_vec  => vmm_do_vec,
            vmm_wen_vec => vmm_wen_vec,
            vmm_ena_vec => vmm_ena_vec,
            vmm_ckart   => vmm_ckart,
            vmm_art_vec => vmm_art_vec,

            vmm_cktk        => vmm_cktk,
            vmm_cktk_en_vec => vmm_cktk_en_vec,

            vmm_ckdt        => vmm_ckdt,
            vmm_ckdt_en_vec => vmm_ckdt_en_vec,

            ext_trigger_in        => ext_trigger_port,
            ext_trigger_deb       => ext_trigger_deb,
            ext_trigger_pulse     => ext_trigger_pulse,
            busy_from_ext_trigger => busy_from_ext_trigger,

            vmm_cfg_en_vec  => vmm_cfg_en_vec,
            vmm_gbl_rst     => vmm_gbl_rst,
            vmm_gbl_rst_sum => vmm_gbl_rst_sum,

            reset     => reset,
            reset_old => reset_old,
            reset_new => reset_new,
            vmm_load  => vmm_load,

            rst_state       => rst_state,
            vmm_configuring => vmm_configuring,
            int_trig        => int_trig,
            cktp_done       => cktp_done,

            LEDx => LEDx,

            vmm_ena_vmm_cfg_sm     => vmm_ena_vmm_cfg_sm,
            acq_rst_from_vmm_fsm   => acq_rst_from_vmm_fsm,
            vmm_ena_vmm_cfg_sm_vec => vmm_ena_vmm_cfg_sm_vec,

            acq_rst_from_data0  => acq_rst_from_data0,
            vmm_acq_rst_running => vmm_acq_rst_running,
            acq_rst_term_count  => acq_rst_term_count,

            dt_state        => dt_state,
            acq_rst_counter => acq_rst_counter
            );

---------------------------------------------                   
-- control steering for configuring 8 vmm's
---------------------------------------------


    process(clk_200, vmm_cfg_en_vec, vmm_cktk_daq_en_vec, vmm_cktk_cfg_sr_en,
            vmm_ena_vmm_cfg_sm_vec, vmm_ena_cfg_rst, vmm_ena_cfg_sr, vmm_wen_cfg_sr,
            vmm_wen_cfg_rst, reset_new_edge, vmm_cktk_ext_trig_en, busy_from_ext_trigger,
            busy_from_acq_rst, vmm_ckbc_en)

    begin
        if(rising_edge(clk_200)) then
            for I in 0 to 7 loop
                if((vmm_cfg_en_vec(I) = '1') and (vmm_configuring = '1')) then
                    vmm_di_en_vec(I)   <= '1';
                    vmm_cktk_en_vec(I) <= vmm_cktk_cfg_sr_en;
--              vmm_ena_vmm_cfg_sm_vec( I) <= vmm_ena_vmm_cfg_sm;
                    vmm_wen_vec(I)     <= vmm_wen_cfg_sr or vmm_wen_gbl_rst or vmm_wen_acq_rst(I)  ; 
                    vmm_ena_vec(I)     <= vmm_ena_cfg_sr or
                                          vmm_ena_gbl_rst or
                                          vmm_ena_acq_rst(I) or
                                          (vmm_ena_vmm_cfg_sm_vec(I) and (not vmm_acq_rst_running(I)));
               elsif (ext_trigger_in_sel = '1') then  --reset controls for
                                                      --ext_trig project
                    vmm_di_en_vec(I)   <= '0';
                    vmm_cktk_en_vec(I) <= vmm_cktk_daq_en_vec(I)
                                          and (vmm_cktk_ext_trig_en or not(ext_trigger_in_sel));
                    vmm_ckbc_all_en <=  vmm_ckbc_en and not(busy_from_ext_trigger or busy_from_acq_rst); --
                    vmm_wen_vec(I)     <= vmm_wen_acq_rst(I) ; 
                    vmm_ena_vec(I)     <= vmm_ena_acq_rst(I)
                                          or (reset_new_edge and (not vmm_acq_rst_running(I)))
                                          or (vmm_ena_vmm_cfg_sm_vec(I) and (not vmm_acq_rst_running(I)));
               else
                    vmm_di_en_vec(I)   <= '0';
                    vmm_cktk_en_vec(I) <= vmm_cktk_daq_en_vec(I)
                                          and (vmm_cktk_ext_trig_en or not(ext_trigger_in_sel));
                    vmm_ckbc_all_en <=  vmm_ckbc_en and not(busy_from_ext_trigger or busy_from_acq_rst); --
                    --added combined control
                                                                  
--              vmm_ena_vmm_cfg_sm_vec( I) <= vmm_ena_vmm_cfg_sm;
                    vmm_wen_vec(I)     <= vmm_wen_acq_rst(I) ;  --
                    
                    -----------------------------------------------------------
--                    vmm_wen_vec(I)     <= vmm_wen_acq_rst(I);
--                    vmm_ena_vec(I)     <= vmm_ena_acq_rst(I) or (vmm_ena_vmm_cfg_sm_vec(I) and (not vmm_acq_rst_running(I)));
                    -- ann changed
--                    vmm_ena_vec(I)     <= vmm_ena_acq_rst(I) or (reset_new_edge and (not vmm_acq_rst_running(I))) or (vmm_ena_vmm_cfg_sm_vec(I) and (not vmm_acq_rst_running(I)));
                    vmm_ena_vec(I)     <= vmm_ena_acq_rst(I)
                                          or (reset_new_edge and (not vmm_acq_rst_running(I)))
                                          or (vmm_ena_vmm_cfg_sm_vec(I) and (not vmm_acq_rst_running(I)));
                end if;
            end loop;

        end if;
    end process;



-- --------------------------------------------------------------------------------------------------------------
-- AXI READ handshaking - with wait states!
--  two cycles after arread is intiated, we assert rvalid.  We keep rvalid asserted, until the slave responds with
-- tready, which indicates it read the data and we deassert valid until another address is written
-- --------------------------------------------------------------------------------------------------------------
    U_AXI_READ_CAPT : process(EXT_AXI_CLK)
    begin
        if(rising_edge(EXT_AXI_CLK)) then
            if (EXT_AXI_arready = '1') then  --Got a new read address 
                EXT_AXI_rvalid_z <= "100";
            elsif (EXT_AXI_rready = '1' and EXT_AXI_rvalid = '1') then
                EXT_AXI_rvalid_z <= "000";
            else
                EXT_AXI_rvalid_z <= EXT_AXI_rvalid_z(2) & EXT_AXI_rvalid_z(2 downto 1);
            end if;
        end if;
    end process;
    -- AFter the two cycle delay, read valid is strobed.  
    EXT_AXI_rvalid <= EXT_AXI_rvalid_z(0);


-- --------------------------------------------------------------------------------------------------------------
-- AXI capture of address and write data - no wait necessary
--  two cycles after arread is intiated, we assert rvalid.  We keep rvalid asserted, until the slave responds with
-- tready, which indicates it read the data and we deassert valid until another address is written
-- -----------------------------------------------
    U_AXI_ADDWRITE_CAPT : process(EXT_AXI_CLK)
    begin
        if(rising_edge(EXT_AXI_CLK)) then
            if (EXT_AXI_arvalid = '1') then  --Got a new read address 
                if(EXT_AXI_arready = '0') then
                    EXT_AXI_arready <= '1';
                else
                    EXT_AXI_arready <= '0';
                end if;
            end if;
            if (EXT_AXI_awvalid = '1') then  --Got a new read address 
                if(EXT_AXI_awready = '0') then
                    EXT_AXI_awready <= '1';
                else
                    EXT_AXI_awready <= '0';
                end if;
            end if;
            if (EXT_AXI_wvalid = '1') then   --Got a new read address 
                if(EXT_AXI_wready = '0') then
                    EXT_AXI_wready <= '1';
                else
                    EXT_AXI_wready <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Capture the AXI bus master (i.e mb) address (both read and/or write) and data(write) 
    -- Also multiplex the address between read and write...
    --  axi_addr_muxed is what I use.  
    U_AXI_ADDR : process(EXT_AXI_CLK)
    begin
        if(rising_edge(EXT_AXI_CLK)) then
            if(EXT_AXI_RESETN = '0') then
                axi_addr_muxed  <= (others => '0');
                axi_addr_write  <= (others => '0');
                axi_addr_read   <= (others => '0');
                EXT_AXI_wdata_v <= (others => '0');
            else
                if (EXT_AXI_arvalid = '1') then
                    axi_addr_read  <= EXT_AXI_araddr(15 downto 0);
                    axi_addr_muxed <= EXT_AXI_araddr(15 downto 0);
                elsif (EXT_AXI_awvalid = '1') then
                    axi_addr_write <= EXT_AXI_awaddr(15 downto 0);
                    axi_addr_muxed <= EXT_AXI_awaddr(15 downto 0);
                end if;
                if (EXT_AXI_wvalid = '1') then
                    EXT_AXI_wdata_v <= EXT_AXI_wdata;
                end if;
            end if;
        end if;
    end process;

-- ---------------------------------------------------------------------------------
-- Decode the AXI write strobe
--   00010          -> 
--   00014          -> Coefficient/Offset Memory (Write Only)
-- ---------------------------------------------------------------------------------
    U_AXI_WE_STROBE : process(EXT_AXI_CLK)
    begin
        if(rising_edge(EXT_AXI_CLK)) then
            if(EXT_AXI_RESETN = '0') then
                axi_we_axi_reg      <= (others => '0');
                axi_we_axi_reg_amux <= '0';
            else
                axi_we_axi_reg                                                                 <= (others => '0');
                axi_we_axi_reg(to_integer (unsigned((axi_addr_write(15 downto 2) - x"0004")))) <= EXT_AXI_wvalid and EXT_AXI_wready;
                if (axi_addr_write = X"0200") then
                    axi_we_axi_reg_amux <= EXT_AXI_wvalid and EXT_AXI_wready;
                else
                    axi_we_axi_reg_amux <= '0';
                end if;
            end if;
        end if;
    end process;

-- ---------------------------------------------------------------------------------
-- Decode the AXI read strobe - used to read/pop the FIFO
--   00010      
-- ---------------------------------------------------------------------------------
    U_AXI_WE_STROBE_2 : process(EXT_AXI_CLK)
    begin
        if(rising_edge(EXT_AXI_CLK)) then
            if(EXT_AXI_RESETN = '0') then
                axi_pop_vmm1 <= '0';
                axi_pop_vmm2 <= '0';
            else
                axi_we_axi_reg(0) <= '0';  -- vmm1                                                                                 
                if (axi_addr_read = X"0010") then  -- kjohns addresses are 0x44A10000 to 0x44A1FFF 
                    axi_pop_vmm1 <= EXT_AXI_rvalid and EXT_AXI_rready;
                elsif (axi_addr_read = X"0018") then
                    axi_pop_vmm2 <= EXT_AXI_rvalid and EXT_AXI_rready;
                end if;
            end if;
        end if;
    end process;



-- ---------------------------------------------------------------------------------
-- AXI Bus Read  -> Decode the AXI read address
-- ---------------------------------------------------------------------------------
    U_AXI_READ_DECODE : process(axi_addr_read,
                                axi_rdata_ls_vmm1, axi_rdata_rcnt_vmm1, axi_rdata_ls_vmm2, axi_rdata_rcnt_vmm2,
                                axi_reg, axi_reg_amux,
                                DETECTOR_ID, DS2411_low, DS2411_high,
                                user_reg_1, user_reg_2, user_reg_3, user_reg_4, user_reg_5,
                                xadc
                                )

    begin
        if (axi_addr_read = X"0000") then  -- 2048 (32 bit) locations: 4000-0000
            EXT_AXI_rdata <= X"C0FFEE00";
        elsif (axi_addr_read = X"0004") then
            EXT_AXI_rdata <= X"C0FFEE01";
        elsif (axi_addr_read = X"0008") then
            EXT_AXI_rdata <= X"C0FFEE02";
        elsif (axi_addr_read = X"000C") then
            EXT_AXI_rdata <= X"C0FFEE03";
        elsif (axi_addr_read = X"0010") then
            EXT_AXI_rdata <= axi_rdata_ls_vmm1;  -- Returns the popped FIFO value (vmm1)
        elsif (axi_addr_read = X"0014") then
            EXT_AXI_rdata <= axi_rdata_rcnt_vmm1;  -- Returns the FIFO count (vmm1)
        elsif (axi_addr_read = X"0018") then
            EXT_AXI_rdata <= axi_rdata_ls_vmm2;
        elsif (axi_addr_read = X"001C") then
            EXT_AXI_rdata <= axi_rdata_rcnt_vmm2;
            
        elsif (axi_addr_read = X"00F8") then
            EXT_AXI_rdata <= xadc;
        elsif (axi_addr_read = X"00FC") then
            EXT_AXI_rdata <= x"00" & b"000" & axi_reg(59)(20 downto 16) & DETECTOR_ID(7 downto 0) & axi_reg(59)(7 downto 0);
        elsif (axi_addr_read = X"0100") then  -- reset reg
            EXT_AXI_rdata <= axi_reg(60);
        elsif (axi_addr_read = X"0104") then
            EXT_AXI_rdata <= user_reg_1(31 downto 0);
        elsif (axi_addr_read = X"0108") then
            EXT_AXI_rdata <= user_reg_2(31 downto 0);
        elsif (axi_addr_read = X"010C") then
            EXT_AXI_rdata <= user_reg_3(31 downto 0);
        elsif (axi_addr_read = X"0110") then
            EXT_AXI_rdata <= user_reg_4(31 downto 0);
        elsif (axi_addr_read = X"0114") then
            EXT_AXI_rdata <= user_reg_5(31 downto 0);
        elsif (axi_addr_read = X"0118") then
            EXT_AXI_rdata <= DS2411_low;
        elsif (axi_addr_read = X"011C") then
            EXT_AXI_rdata <= DS2411_high;
--        elsif (axi_addr_read = X"0140") then
--          EXT_AXI_rdata(0) <= reading_fin_flag;
        elsif (axi_addr_read = X"0144") then  -- reg 77
       --   EXT_AXI_rdata <= (others => '0')                      ;
          EXT_AXI_rdata <= x"0000000" & b"000" & read_data;
        elsif (axi_addr_read = X"014C") then  -- reg 79
          EXT_AXI_rdata <= bcid_captured & num_ext_trig;
--          EXT_AXI_rdata <= X"12345678";
-- nathan
--        elsif (axi_addr_read = X"0150") then  --reg 80 0x14d/4 -4
--         EXT_AXI_rdata <= (others => '0');
       --  elsif (axi_addr_read = X"0150") then  --reg 80 0x14d/4 -4 
         --  EXT_AXI_rdata <= (others => '0')                      ;
--          EXT_AXI_rdata(0) <=  read_data;                
          
            
        elsif (axi_addr_read = X"0200") then
            EXT_AXI_rdata <= std_logic_vector(resize(unsigned(axi_reg_amux), 32));
            
        else
            EXT_AXI_rdata <= (others => '0');  -- reduce the number of cases.  This is really don't care!
        end if;
        
    end process;






    U_STATUS_WRITE : process(EXT_AXI_CLK)
    begin
        if(rising_edge(EXT_AXI_CLK)) then
            if(EXT_AXI_RESETN = '0') then
                axi_reg(0) <= x"01234567";
                axi_reg(1) <= x"11111111";
                axi_reg(2) <= x"22222222";
                axi_reg(3) <= x"33333333";
                axi_reg(4) <= x"FEDCBA98";
                axi_reg(5) <= x"55555555";
                axi_reg(6) <= x"66666666";
                axi_reg(7) <= x"77777777";
                axi_reg(8) <= x"88888888";
                axi_reg(9) <= x"99999999";

                axi_reg_amux <= "0000";

                axi_reg <= (others => (others => '0'));

            else
--nathan changed 79 to 80
                for i in 0 to 80 loop
                    if(axi_we_axi_reg(I) = '1') then
                        axi_reg(i) <= EXT_AXI_wdata_v;
                    end if;
                end loop;

                if (axi_we_axi_reg_amux = '1') then
                    axi_reg_amux <= EXT_AXI_wdata_v(axi_reg_amux'left downto axi_reg_amux'right);
                end if;
            end if;
        end if;
    end process;



-------------------------------------------------------------
-- Connections from axi registers to control / settings / status signals
-------------------------------------------------------------


    vmm_cfg_sel    <= axi_reg(55);
    vmm_2display   <= vmm_cfg_sel(16 downto 12);
    mmfeID         <= vmm_cfg_sel(11 downto 8);
    vmm_cfg_en_vec <= vmm_cfg_sel(7 downto 0);

    clk_tp_period_dutycycle_cnt <= axi_reg(56);
--    clk_tp_period_cnt               <= clk_tp_period_dutycycle_cnt( 31 downto 16);
--    clk_tp_dutycycle_cnt            <= clk_tp_period_dutycycle_cnt( 15 downto 0);

    readout_runlength  <= axi_reg(57);
    ext_trigger_in_sel <= readout_runlength(26);
    axi_data_to_use    <= readout_runlength(25);
    int_trig           <= readout_runlength(24);
    vmm_ro_i           <= readout_runlength(23 downto 16);
    pulses             <= readout_runlength(15 downto 0);

--    axi_reg_amux                    <= axi_reg( 58);

    control     <= axi_reg(59);
    vmm_load    <= control(3);
    start       <= control(2);
    reset_new   <= control(1);
    vmm_gbl_rst <= control(0);

    reset_old <= axi_reg(60)(0);        --already in place

--    user_reg_1( 31 downto 0)        <= axi_reg_61( 31 downto 0);
--    user_reg_2( 31 downto 0)        <= axi_reg_62( 31 downto 0);
--    user_reg_3( 31 downto 0)        <= axi_reg_63( 31 downto 0);
--    user_reg_4( 31 downto 0)        <= axi_reg_64( 31 downto 0);
--    user_reg_5( 31 downto 0)        <= axi_reg_65( 31 downto 0);
--    user_reg_1( 31 downto 0)        <= x"00000" & b"00" & reset & vmm_gbl_rst & vmm_cfg_en_vec;
--    user_reg_2( 31 downto 0)        <= x"000" & b"00" & start & int_trig & pulses;
--    user_reg_3( 31 downto 0)        <= x"000" & b"000" & vmm_2display & mmfeID & vmm_ro_i;


    user_reg_1(31 downto 0) <= axi_reg(55);
    user_reg_2(31 downto 0) <= axi_reg(57);
    user_reg_3(31 downto 0) <= axi_reg(59);
    user_reg_4(31 downto 0) <= axi_reg(64)(31 downto 0);
    user_reg_5(31 downto 0) <= axi_reg(65)(31 downto 0);

--    axi_data_to_use                 <= axi_reg( 65)( 0);
--    ext_trigger_in_sel              <= axi_reg( 65)( 1);

    acq_rst_term_count      <= axi_reg(68)(31 downto 0);
    acq_rst_hold_term_count <= axi_reg(69)(31 downto 0);
--      := x"00080000"; -- 40 @ 40MHz @ 200MHz

    delay_count <= axi_reg(74)(19 downto 0);      -- ANN NEEDS TO CHANGE THE GUI

--    axi_reg( 66)( 31 downto 0)        <= DS2411_low( 31 downto 0);
--    axi_reg( 67)( 31 downto 0)        <= DS2411_high( 31 downto 0);


    ext_trigger_sim <= axi_reg(78)(0);
    reading_fin_flag <= axi_reg(76)(0);
    ext_trig_w_pulse <= axi_reg(75)(0);  --option to send pulse with ext_trig
-- connect to _ID inputs
--    DETECTOR_ID <=  DETECTOR_ID_7 & DETECTOR_ID_6 & DETECTOR_ID_5 & DETECTOR_ID_4 & 
--                    DETECTOR_ID_3 & DETECTOR_ID_2 & DETECTOR_ID_1 & DETECTOR_ID_0;

    -- Connect amux to outputs 
    MuxAddr0   <= axi_reg_amux(0);
    MuxAddr1   <= axi_reg_amux(1);
    MuxAddr2   <= axi_reg_amux(2);
    MuxAddr3_p <= axi_reg_amux(3);
    MuxAddr3_n <= not axi_reg_amux(3);

    --bill led
    LED_BANK_16 <= LED(5);              -- 84
    LED_BANK_13 <= LED(4);              -- 85
    LED_BANK_15 <= LED(3);              -- 86
    LED_BANK_34 <= LED(2);              -- 87
    LED_BANK_35 <= LED(1);              -- 88
    LED_BANK_14 <= LED(0);              -- 89

    LED(2 downto 0) <= vmm_cfg_en_vec(2 downto 0);
    LED(5 downto 3) <= vmm_2display(2 downto 0);

    
end STRUCTURE;



