--
-- VMM registers and configuration
-- this block handles the 1616 bit serial configuration
-- streams
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.vmm_pkg.all;

entity vmm_cfg is
  port
    (
      clk_ila     : in std_logic;
      clk200      : in std_logic;
      vmm_clk_200 : in std_logic;
      EXT_AXI_CLK : in std_logic;

      clk100      : in std_logic;
      vmm_clk_100 : in std_logic;

      clk10      : in std_logic;
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
--        vmm_ena_vmm_cfg_sm          : out   std_logic;                     -- sys_init_sm_acq_en
      vmm_ena_vmm_cfg_sm_vec_o : out std_logic_vector(7 downto 0) := (others => '0');



      vmm_ckdt_en_vec : out std_logic_vector(7 downto 0);
      vmm_ckdt        : in  std_logic;

      vmm_ckart_en : out std_logic;
      vmm_ckart    : in  std_logic;

      vmm_cktk_daq_en_vec : out std_logic_vector(7 downto 0);  --from daq 
      vmm_cktk_cfg_sr_en  : out std_logic;  --from config module

      vmm_cktk : in std_logic;

      vmm_cktp_en : out std_logic;
      vmm_cktp    : in  std_logic;

      vmm_ckbc_en        : out std_logic;
      vmm_ckbc           : in  std_logic;
      reset_bcid_counter : out std_logic;

      vmm_data1_vec : in std_logic_vector(7 downto 0);
      vmm_data0_vec : in std_logic_vector(7 downto 0);
      vmm_art_vec   : in std_logic_vector(7 downto 0);
      turn_counter  : in std_logic_vector(15 downto 0);

      wr_en : buffer std_logic;

      vmm_rd_en : buffer std_logic_vector(7 downto 0);

      vmm_din_vec       : out    array_8x32bit;  --from daq
      dt_cntr_intg0_vec : out    array_Int_8;    --from daq
      dt_cntr_intg1_vec : out    array_Int_8;    --from daq
      vmm_data_buf_vec  : out    array_8x38bit;  --from daq
      vmm_dout_vec      : out    array_8x32bit;  --from daq
      rr_state          : buffer std_logic_vector(7 downto 0);
      din               : buffer std_logic_vector(31 downto 0);

      vmm_ro          : in  std_logic_vector(7 downto 0);
      vmm_configuring : out std_logic;
      rst_state       : out std_logic_vector(2 downto 0);

      LEDx  : out std_logic_vector(2 downto 0);
      testX : in  std_logic;
--nathan changed type to 81
      axi_reg : in array_81x32bit;      --axi config data

      vmm_cfg_sel : in std_logic_vector(31 downto 0);

      -- AXI bus interface to the FIFO --
      axi_clk : in std_logic;

      --     signals from the round robin data fifo
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
      acq_rst_term_count      : in  std_logic_vector(31 downto 0) := x"00080000";  -- 40 @ 40MHz @ 200MHz;
      acq_rst_hold_term_count : in  std_logic_vector(31 downto 0) := x"00080000";  -- 40 @ 40MHz @ 200MHz

      acq_rst_from_data0_o : out std_logic_vector(7 downto 0);
--    vmm_acq_rst_running         : out std_logic_vector( 7 downto 0);
--    acq_rst_term_count          : out array_8x32bit;
      dt_state             : out array_8x4bit;
      acq_rst_counter      : out array_8x32bit;

      acq_rst_from_ext_trig : in std_logic;
      fifo_rst_from_ext_trig : in std_logic
      );

end vmm_cfg;

architecture rtl of vmm_cfg is


  component vmm_global_reset
    port(
      clk                 : in  std_logic;
      rst                 : in  std_logic;  -- reset
      gbl_rst             : in  std_logic;  -- from control register. a pulse
      vmm_wen             : out std_logic;  -- these will be ored with same from other sm
      vmm_ena             : out std_logic;  -- these will be ored with same from other sm
      vmm_gbl_rst_running : out std_logic  -- will be anded with same from other while running sm
      );
  end component;


  component vmm_acq_reset
    port(
      clk                 : in  std_logic;
      rst                 : in  std_logic;  -- reset
      acq_rst             : in  std_logic;  -- from control register. a pulse
      vmm_wen             : out std_logic;  -- these will be ored with same from other sm
      vmm_ena             : out std_logic;  -- these will be ored with same from other sm
      vmm_acq_rst_running : out std_logic  -- will be anded with same from other while running sm
      );
  end component;


-- components are here
  component fifo_round_robin
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      rd_clk        : in  std_logic;
      din           : in  std_logic_vector(31 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector(31 downto 0);
      full          : out std_logic;
      almost_full   : out std_logic;
      empty         : out std_logic;
      almost_empty  : out std_logic;
--        rd_data_count   : OUT STD_LOGIC_VECTOR( 10 DOWNTO 0);
--        wr_data_count   : OUT STD_LOGIC_VECTOR( 10 DOWNTO 0)
      rd_data_count : out std_logic_vector(9 downto 0);
      wr_data_count : out std_logic_vector(9 downto 0);
          prog_full : OUT STD_LOGIC

      );
  end component;


  component vmm_daq is
    port
      (
        vmm_clk_200 : in std_logic;
        reset       : in std_logic;
        vmmNumber   : in std_logic_vector(2 downto 0);

        vmm_data0    : in std_logic;
        vmm_data1    : in std_logic;
        vmm_art      : in std_logic;
        turn_counter : in std_logic_vector(15 downto 0);

        vmm_cktk_daq_en : out std_logic;
        vmm_ckdt_en     : out std_logic;

        vmm_ckdt  : in std_logic;
        vmm_ckart : in std_logic;

        din           : out std_logic_vector(31 downto 0);
        dt_cntr_intg0 : out integer;
        dt_cntr_intg1 : out integer;
        vmm_data_buf  : out std_logic_vector(37 downto 0);

        rd_clk        : in  std_logic;
        empty         : out std_logic;
        rd_data_count : out std_logic_vector(9 downto 0);
        wr_data_count : out std_logic_vector(9 downto 0);
        rd_en         : in  std_logic;
        dout          : out std_logic_vector(31 downto 0);

        acq_rst_from_data0 : out std_logic;

        acq_rst_term_count      : in  std_logic_vector(31 downto 0);
        acq_rst_hold_term_count : in  std_logic_vector(31 downto 0);
        dt_state_o              : out std_logic_vector(3 downto 0)  := (others => '0');
        acq_rst_counter_o       : out std_logic_vector(31 downto 0) := (others => '0');
        fifo_rst_from_ext_trig  : in std_logic;
--nathan added
        mmfe_id_reg :in std_logic_vector(3 downto 0)
        );

  end component;


---------------------=======================------------------
---------------------=====   Signals    ====------------------
---------------------=======================------------------


  signal probe0 : std_logic_vector(31 downto 0);
  signal probe1 : std_logic_vector(31 downto 0);

  signal testX_i          : std_logic := '0';
  signal vmm_data0_ii     : std_logic := '0';
  signal vmm_data0_ii_ack : std_logic := '0';
  signal dt_cntr          : std_logic_vector(4 downto 0);
  signal dt_cntr_p1       : std_logic_vector(4 downto 0);
  signal dt_cntr_p2       : std_logic_vector(4 downto 0);
  signal dt_cntr_p3       : std_logic_vector(4 downto 0);
  signal dt_cntr_p4       : std_logic_vector(4 downto 0);
--    signal dt_state                        : std_logic_vector( 7 downto 0) := ( others => '0');

  signal dt_reset : std_logic;
  signal dt_done  : std_logic;

  signal vmm_ckart_en_i : std_logic;
  signal vmm_ckart_i    : std_logic;

  signal art_reset : std_logic;
  signal art_done  : std_logic;
  signal art_data  : std_logic_vector(7 downto 0) := (others => '0');
  signal art_state : std_logic_vector(3 downto 0) := (others => '0');

  signal clk_tk_sync_cnt : std_logic_vector(31 downto 0) := x"00004047";

  signal vmm_empty          : std_logic_vector(7 downto 0) := (others => '1');
  signal vmm_dout_vec_i     : array_8x32bit;
  signal axi_rdata_ls_vmm   : array_8x32bit;
  signal axi_rdata_rcnt_vmm : array_8x32bit;
  signal vmm_rd_data_count  : array_8x10bit;
  signal vmm_wr_data_count  : array_8x10bit;

  signal axi_pop_vmm : std_logic_vector(7 downto 0) := (others => '1');

  signal cktp_i          : std_logic;
  signal ckbc_i          : std_logic;
  signal vmm_ckbc_en_i   : std_logic;
  signal vmm_cktp_en_i   : std_logic;
  signal vmm_clk_token_i : std_logic;

  signal cfg_bit_in_i  : std_logic;
  signal cfg_bit_out_i : std_logic;

  signal cfg_sm_cntr : std_logic_vector(31 downto 0);
  signal cfg_rst_ctr : std_logic_vector(31 downto 0);

  constant cfg_bits     : integer := 1616;  -- the useful bits
  constant cfg_bits_max : integer := 1632;

  signal regs_out : array_64x32bit;
  signal regs_in  : array_64x32bit;

  signal statex    : std_logic_vector(3 downto 0);
  signal bit_cntrx : std_logic_vector(11 downto 0);

  signal vmm_run      : std_logic;
  signal cfg_sr_done  : std_logic;
  signal vmm_rst_done : std_logic;      -- from VMM cfg SM
  signal gbl_rst      : std_logic;
  signal acq_rst      : std_logic;

  -- make two shift registers 1616 bits long.
  -- one for writing to VMM and one for reading from VMM
  signal vmm_cfg_in  : std_logic_vector(cfg_bits_max-1 downto 0);
  signal vmm_cfg_out : std_logic_vector(cfg_bits_max-1 downto 0);

  -- a larger number here will lengthen the time between token pulses
  signal token_cntr : std_logic_vector(4 downto 0);  -- 32 ns pulse every 640 ns

  type   state_t is (s0, s1, s2, s3, s4, s5, s6, s7, s8);
  signal state : state_t;

  signal counter1   : std_logic_vector (31 downto 0) := X"00000000";
  signal ckbc_cntr  : std_logic_vector (0 downto 0)  := (others => '0');
  signal delay_cntr : std_logic_vector (31 downto 0) := X"00000000";

  signal LEDxi : std_logic_vector(2 downto 0);

  signal wr_clk_i      : std_logic                       := '0';
  signal rd_clk_i      : std_logic                       := '0';
  signal wr_data_count : std_logic_vector(10-1 downto 0) := (others => '0');
  signal rd_data_count : std_logic_vector(10-1 downto 0) := (others => '0');
  signal almost_full   : std_logic                       := '0';
  signal almost_empty  : std_logic                       := '1';
  signal rst           : std_logic                       := '0';
  signal prog_full     : std_logic                       := '0';
  signal prog_empty    : std_logic                       := '1';
  signal rd_en         : std_logic                       := '0';
  signal full          : std_logic                       := '0';
  signal empty         : std_logic                       := '1';

  signal dt_cntr_intg : integer := 0;

  signal vmm_gbl_rst_running : std_logic                     := '0';
  signal vmm_gbl_rst_sum_o   : std_logic                     := '0';
  signal vmm_configuring_sm  : std_logic                     := '0';
  signal vmm_gbl_rst_cntr    : std_logic_vector(31 downto 0) := (others => '0');
  signal vmm_gbl_rst_pulse   : std_logic                     := '0';
  signal vmm_gbl_rst_pulse2  : std_logic                     := '0';

  signal acq_rst_from_vmm_fsm     : std_logic                    := '0';
  signal acq_rst_vec              : std_logic_vector(7 downto 0) := (others => '0');
  signal vmm_ena_vmm_cfg_sm       : std_logic                    := '0';
  signal vmm_ena_vmm_cfg_sm_vec   : std_logic_vector(7 downto 0) := (others => '0');
  signal acq_rst_from_data0       : std_logic_vector(7 downto 0) := (others => '0');
  signal acq_rst_from_vmm_fsm_vec : std_logic_vector(7 downto 0) := (others => '0');

  signal VMM_SEL        : unsigned(3 downto 0) := (others => '0');
  signal RR_VMM_PTR     : integer range 0 to 7;
  signal VMM_DATA_READY  : std_logic                     := '0';
  signal RR_PROG_FULL  : std_logic                     := '0';
  signal RR_PAUSE     : std_logic                     := '0';

  signal sync_acq_rst_from_ext_trig : std_logic;

--    signal acq_rst_term_count               :  STD_LOGIC_VECTOR( 31 DOWNTO 0) := x"00080000"; -- 40 @ 40MHz @ 200MHz
--    signal counts_to_acq_reset              :  STD_LOGIC_VECTOR( 31 DOWNTO 0) := x"00080000"; -- 40 @ 40MHz @ 200MHz 



-----------===================================================================================----------------------




begin




--      --=============================--
  U_init_config : process(reset, clk100)
--      --=============================--
  begin
    if rising_edge(clk100) then
      if (reset = '1') then

        -- we can manually assign config data here
        -- currently we use the gui to load data
        
        for i in 0 to 50 loop
          regs_out(i) <= axi_reg(i+4);
        end loop;
      end if;
    end if;
  end process U_init_config;


-- VMM config mux select

--      vmm_vmm_sel <= regs_out(63)(14 downto 12) ;

-- kjohns - we have to add the read in of the do bits later
-- commented out for now
-- the comparison of di and do is also commented out for now
-- and we need to add this back in later
  -- config in
--      process(vmm_clk_int_i, reset)
--      begin -- a load here will reset the 1616 bit word.
--              if (reset = '1') then
--                       vmm_cfg_in <= (others=>'1') ; -- in from VMM
--                       -- need 51 32 bit words for test value 
--              else
--                      if falling_edge(vmm_clk_int_i) then -- we need to watch how the serial stream gets captured
--                              if (vmm_rx_en_int = '1') then
--                                      -- if we send out LSB first
--                                      vmm_cfg_in <= cfg_bit_in & vmm_cfg_in(cfg_bits_max-1 downto 1) ; -- shift -> (only use top 1616)
--                                      -- if we send out MSB first
--                                      --- vmm_cfg_in <= vmm_cfg_in(cfg_bits_max-2 downto 0) & cfg_bit_in ; -- shift <- (only use low 1616)
--                              end if ;
--                      end if ;
--              end if ;
--      end process ;


-- map vmm cfg to reg_in registers
-- a continuous assignment
  U_map_config : process(clk200, reset, vmm_cfg_in, cfg_sr_done, regs_in)
  begin
    if (reset = '1') then
      regs_in <= (others => (others => '0'));
    else
      for i in 0 to 50 loop
        regs_in(i) <= vmm_cfg_in((((I+1)*32)-1) downto (i*32));
      end loop;
    end if;
  end process U_map_config;


-- send out most significant bit
--      cfg_bit_out <= vmm_cfg_out(cfg_bits-1) ; -- send out bit 1616

  -- compare the two 1616 bit strings
--      comp_vectr : entity work.comp_vect
--      generic map(max_bits => cfg_bits) 
--      port map(A => vmm_cfg_out(cfg_bits-1 downto 0), -- tx stream. hi 16 unused
--                              B => vmm_cfg_in(cfg_bits_max-1 downto 16), -- rx stream. low 16 unused -- changed to 17 by SAJONES, change back to 16
--                              res => vect_eq -- 1=equal
--                              ) ;



----------------=======================================------------
--------------- vmm configuration shift register output------------
----------------=======================================------------


-- map output reg to vmm cfg
-- this is really a continuous assignment....
  vmmcfgout_gen :
  for i in 0 to (cfg_bits_max/32)-1 generate  -- 0 to 50 is 51x32=1632
    vmm_cfg_out(((i*32)+32)-1 downto (i*32)) <= regs_out(i);
  end generate;


  vmm_cfg_sr_inst : entity work.vmm_cfg_sr
    generic map(cfg_bits => cfg_bits)   -- for test use default of 32 not 1616
    port map(
      clk                => vmm_cktk,   -- main clock
      rst                => reset,      -- reset
      load_en            => '0',  -- vmm_load_en_pulse, -- load word to be sent
      run                => vmm_run,    -- start state machine cfg bit
      vmm_cfg_out        => vmm_cfg_out(cfg_bits-1 downto 0),  -- only the low 1616 of 1632
      cfg_bit_out        => cfg_bit_out_i,   -- serial out
      vmm_cktk_cfg_sr_en => vmm_cktk_cfg_sr_en,
      vmm_ena            => vmm_ena_cfg_sr,  -- or with cfg sm
      vmm_wen            => vmm_wen_cfg_sr,  -- or with cfg sm
      statex             => statex,
      bit_cntrx          => bit_cntrx
      );



-- Need to add capability to load all vmm's sequentially .. 
--One method would be Yes, you are absolutely right� and I'm part bonehead also� I put off doing the dance until later. Boy it sure would be so much simpler if we had separate memory for each vmm configuration. But we don't, so next best is that we do a dance� which would be mostly a gui thing�

--Currently, I believe:
--1.    We load the config registers from the original default vmm setup page I did not muck with this. 
--2.    then whichever vmms are selected, all get configured in parallel. 
--3.    There is a register that keeps track of which vmm are configured, including which are reset, for controlling the ENA, and working the acq_rst. 
--4.    There is no 1:1 page to vmm, unless you want to spend all that time setting them all up that way, and have the dance routine going. I suggest have an option switch available 
--5.    I thought there was a bug here, but no more� The question was, what if more than one page is selected, which one goes to memory? Either just the first one, or the dance selected page. 
--6.    So we have to automate the process to cycle through the configuration load process one at a time   

--We also need to change the code a bit more to have a separate board reset, and vmm configuration; individual gbl_rst to each vmm is already separated out�

--I think the dance should be:
--1.    Read the config select register.
--2.    Loop For each set bit, read the associated vmm page into the config memory
--3.    Run the configuration for that single vmm (note this is different than the config in parallel process) we will just need to have some kind of mode switch which blocks the multi-select value and replaces it with a single select value. 
--Bill

--
-- ==================================================================== --
---------    System Reset, VMM Load, Global and Acquisition Reset
-- ==================================================================== --
--


  config_vmm_fsm : process(vmm_clk_200)
-- cfg_sm_cntr is the state machine counter

  begin
    if rising_edge(vmm_clk_200) then
      if(reset = '1') then

        reset_bcid_counter <= '0';

        cfg_sm_cntr          <= (others => '0');  -- state machine time in state counter
        vmm_configuring_sm   <= '0';  -- flag to activate the configuration IO switch
        gbl_rst              <= '0';    -- starts the vmm gbl_rst process
        vmm_run              <= '0';    -- starts the vmm configuration process
        acq_rst_from_vmm_fsm <= '0';    -- acq rst
        vmm_ena_vmm_cfg_sm   <= '0';    -- enable ENA

      else
        if(vmm_load = '1') then
          state <= s0;

          cfg_sm_cntr          <= (others => '0');  -- state machine time in state counter
          vmm_configuring_sm   <= '0';  -- flag to activate the configuration IO switch
          gbl_rst              <= '0';  -- starts the vmm gbl_rst process
          vmm_run              <= '0';  -- starts the vmm configuration process
--                reset_bcid_counter <= '0';
          acq_rst_from_vmm_fsm <= '0';  -- acq rst
          vmm_ena_vmm_cfg_sm   <= '0';  -- enable ENA
        else

----            if( reset = '1') then
--              if( vmm_load = '1') then
--                      state <= s0 ;
--                      cfg_sm_cntr <= (others =>'0');   -- state machine time in state counter
--            vmm_configuring_sm <= '0';       -- flag to activate the configuration IO switch
--                      gbl_rst <= '0' ;                 -- starts the vmm gbl_rst process
--                      vmm_run <= '0' ;                 -- starts the vmm configuration process
--            reset_bcid_counter <= '0';
--            acq_rst_from_vmm_fsm <= '0';     -- acq rst
--                      vmm_ena_vmm_cfg_sm <= '0' ;      -- enable ENA            
--        else  


          case state is
            when s0 =>                  -- initialize and do the global reset
              LEDxi <= b"000";
              if(cfg_sm_cntr = x"00000000") then
                gbl_rst              <= '1';  -- start the vmm gbl_rst process
                vmm_configuring_sm   <= '1';  -- activate the configuration IO switch
                vmm_run              <= '0';  -- no vmm configuration process
                acq_rst_from_vmm_fsm <= '0';  -- no acq rst
                vmm_ena_vmm_cfg_sm   <= '0';  -- no enable ENA                          
                reset_bcid_counter   <= '0';  -- no bcid reset 
                cfg_sm_cntr          <= cfg_sm_cntr + '1';  -- incr counter
                
              else
                
                if(cfg_sm_cntr = x"00000040") then  -- at cfg_sm_cntr = 40, turn the global reset start off                              
                  gbl_rst            <= '0';  -- reset the vmm gbl_rst process starter
                  vmm_configuring_sm <= '1';  -- continue the configuration IO switch
                  cfg_sm_cntr        <= cfg_sm_cntr + '1';    -- incr counter
                else
                  if(cfg_sm_cntr = x"00100000") then  -- at cfg_cm_cntr = 100000, go to the next state and also reset the counter 
                    state              <= s1;
                    cfg_sm_cntr        <= (others => '0');
                    vmm_configuring_sm <= '1';  -- continue the configuration IO switch
                  else
                    cfg_sm_cntr        <= cfg_sm_cntr + '1';  -- otherwise, just increment the counter 
                    vmm_configuring_sm <= '1';  -- continue the configuration IO switch
                  end if;
                end if;
              end if;

              --  the config state follows the same form as the global reset
              --  in this case vmm_run turns the config on
              --  and the same cfg_cm_cntr are used to turn it off and then wait to go
              --  to state s2
            when s1 =>                  -- send the config bits
              LEDxi <= b"001";          -- diagnostic
              if(cfg_sm_cntr = x"00000000") then
                vmm_configuring_sm <= '1';  -- continue the configuration IO switch
                vmm_run            <= '1';  -- start the vmm configuration process
                cfg_sm_cntr        <= cfg_sm_cntr + '1';  -- increment the counter 
              else
                if(cfg_sm_cntr = x"00000040") then
                  vmm_configuring_sm <= '1';  -- continue the configuration IO switch
                  vmm_run            <= '0';  -- reset the vmm configuration process start
                  cfg_sm_cntr        <= cfg_sm_cntr + '1';  -- increment the counter 
                else
                  if(cfg_sm_cntr = x"00100000") then  -- give the configuration time to finish
                    state              <= s2;
                    vmm_configuring_sm <= '1';  -- continue the configuration IO switch
                    cfg_sm_cntr        <= (others => '0');
                  else
                    cfg_sm_cntr        <= cfg_sm_cntr + '1';
                    vmm_configuring_sm <= '1';  -- continue the configuration IO switch
                  end if;
                end if;
              end if;

              -- and then we do the configuration again in the same way as in s1
            when s2 =>
              LEDxi              <= b"010";
              vmm_configuring_sm <= '1';  -- continue the configuration IO switch
              if(cfg_sm_cntr = x"00000000") then
                vmm_run     <= '1';     -- cfg run
                cfg_sm_cntr <= cfg_sm_cntr + '1';
              else
                if(cfg_sm_cntr = x"00000040") then
                  vmm_run     <= '0';   -- cfg run
                  cfg_sm_cntr <= cfg_sm_cntr + '1';
                else
                  if(cfg_sm_cntr = x"00100000") then
                    state       <= s3;
                    cfg_sm_cntr <= (others => '0');
                  else
                    cfg_sm_cntr <= cfg_sm_cntr + '1';
                  end if;
                end if;
              end if;
              
            when s3 =>  -- now wait -- can probably delete this state
              LEDxi              <= b"011";
              vmm_configuring_sm <= '1';  -- continue the configuration IO switch
              if(cfg_sm_cntr = x"00010000") then
                state       <= s4;
                cfg_sm_cntr <= (others => '0');
              else
                cfg_sm_cntr <= cfg_sm_cntr + '1';
              end if;
              
            when s4 =>                  -- do the acquisition reset
              LEDxi <= b"100";
              if(cfg_sm_cntr = x"00000000") then
                vmm_configuring_sm <= '0';  --indicate in configuration sm sequence done
                cfg_sm_cntr        <= cfg_sm_cntr + '1';
              else
                vmm_configuring_sm <= '0';  --indicate configuration sm sequence done
                if(cfg_sm_cntr = x"00000002") then
                  acq_rst_from_vmm_fsm <= '1';  -- acq rst
                  reset_bcid_counter   <= '1';
                  cfg_sm_cntr          <= cfg_sm_cntr + '1';
                else
                  if(cfg_sm_cntr = x"00000040") then
                    acq_rst_from_vmm_fsm <= '0';
                    reset_bcid_counter   <= '0';
                    cfg_sm_cntr          <= cfg_sm_cntr + '1';
                  else
                    if(cfg_sm_cntr = x"00100000") then
                      state       <= s5;
                      cfg_sm_cntr <= (others => '0');
                    else
                      cfg_sm_cntr <= cfg_sm_cntr + '1';
                    end if;
                  end if;
                end if;
              end if;
              
            when s5 =>  --  now set ena high - clear tk sync so can re-sync
              LEDxi              <= b"101";
              vmm_configuring_sm <= '0';  --indicate configuration sm sequence done
              if(cfg_sm_cntr = x"00000400") then
                state              <= s5;
                vmm_ena_vmm_cfg_sm <= '1';
              else
                cfg_sm_cntr <= cfg_sm_cntr + '1';
              end if;
              
            when others =>
              state                <= s1;
              vmm_run              <= '0';  -- cfg run
              acq_rst_from_vmm_fsm <= '0';  -- acq rst
              vmm_ena_vmm_cfg_sm   <= '0';  -- enable ENA
              cfg_sm_cntr          <= (others => '0');
          end case;
        end if;
      end if;
    end if;
  end process config_vmm_fsm;

  LEDx <= LEDxi;

--rst_state( 2 downto 0) <= state;


----------------=================================================------------
---------------- Generate secondary independent vmm global reset ------------
----------------=================================================------------


  vmm_gbl_rst_pulse_sm : process(vmm_clk_200, reset, vmm_gbl_rst, vmm_gbl_rst_cntr, vmm_gbl_rst_pulse, vmm_gbl_rst_pulse2)
  begin
    if rising_edge(vmm_clk_200) then
      if((reset = '1') or (vmm_gbl_rst = '0')) then
        vmm_gbl_rst_cntr  <= (others => '0');
        vmm_gbl_rst_pulse <= '0';
      else
        if(vmm_gbl_rst_cntr = x"00100000") then
          vmm_gbl_rst_cntr   <= x"00100000";
          vmm_gbl_rst_pulse  <= '0';
          vmm_gbl_rst_pulse2 <= '0';
        else
          if(vmm_gbl_rst_cntr = x"00000040") then
            vmm_gbl_rst_cntr   <= vmm_gbl_rst_cntr + '1';
            vmm_gbl_rst_pulse  <= '0';
            vmm_gbl_rst_pulse2 <= '1';
          else
            if(vmm_gbl_rst_cntr = x"00000004") then
              vmm_gbl_rst_cntr   <= vmm_gbl_rst_cntr + '1';
              vmm_gbl_rst_pulse  <= '1';
              vmm_gbl_rst_pulse2 <= '1';
            else
              if(vmm_gbl_rst_cntr = x"00000002") then
                vmm_gbl_rst_cntr   <= vmm_gbl_rst_cntr + '1';
                vmm_gbl_rst_pulse  <= '0';
                vmm_gbl_rst_pulse2 <= '1';
              else
                vmm_gbl_rst_cntr <= vmm_gbl_rst_cntr + '1';
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process vmm_gbl_rst_pulse_sm;


-- need to hook up vmm_ena_vmm_cfg_sm_vec to the enables for all the clocks and I/O
-- Note some clocks and IO are needed to configure -- cktk, ena, wen, di, do, 200 mhz 
-- bill


  vmm_gbl_rst_state : process(vmm_clk_200, reset, vmm_cfg_en_vec, vmm_ena_vmm_cfg_sm_vec, vmm_ena_vmm_cfg_sm, vmm_gbl_rst_pulse2)
  begin
    if rising_edge(vmm_clk_200) then
      if(reset = '1') then
        vmm_ena_vmm_cfg_sm_vec <= (others => '0');
      else
        for I in 0 to 7 loop
                                                 -- acq_rst_from_vmm_fsm momentary over vmm_ena_vmm_cfg_sm   vmm_ena_vmm_cfg_sm_vec( I)
          if(vmm_cfg_en_vec(I) = '1') then       -- If vmm config is set in gui
            if(acq_rst_from_vmm_fsm = '1') then  --   and if config is happening
              vmm_ena_vmm_cfg_sm_vec(I) <= '1';  --     set the vmm enabled flag for this vmm
            elsif vmm_gbl_rst_pulse2 = '1' then
              vmm_ena_vmm_cfg_sm_vec(I) <= '0';  --       clear the vmm enabled flag for this vmm
--ann 
            elsif state = s0 then
              vmm_ena_vmm_cfg_sm_vec(I) <= '0';
              --else                                                    --   else 
              --    if( vmm_gbl_rst_pulse2 = '1') then                  --     if gbl_rst is happening
              --        vmm_ena_vmm_cfg_sm_vec( I) <= '0';              --       clear the vmm enabled flag for this vmm
              --    end if;
            end if;
          end if;
        end loop;
      end if;
    end if;
  end process vmm_gbl_rst_state;

  acq_rst_from_vmm_fsm_o   <= acq_rst_from_vmm_fsm;
  vmm_ena_vmm_cfg_sm_o     <= vmm_ena_vmm_cfg_sm;
  vmm_ena_vmm_cfg_sm_vec_o <= vmm_ena_vmm_cfg_sm_vec;

----------------=======================================------------
---------------    vmm global and acquisition reset     -----------
----------------=======================================------------


--vmm_cfg_rst_inst: entity work.vmm_cfg_rst
--      port map(   
--        clk            => vmm_clk_100, -- main clock
--        rst            => reset, -- reset
--        gbl_rst        => vmm_gbl_rst_sum_o, -- input
--              acq_rst        => acq_rst, -- input
--      vmm_ena        => vmm_ena_cfg_rst, -- or with cfg sm
--              vmm_wen        => vmm_wen_cfg_rst, -- or with cfg sm
--              rst_state      => rst_state,
--              cfg_rst_ctr_e  => cfg_rst_ctr,
--              done           => vmm_rst_done -- pulse
--      );                      



  vmm_gbl_rst_sum_o <= gbl_rst or vmm_gbl_rst_pulse;  -- global resets, either from sys init or from independent gbl_rst
  vmm_gbl_rst_sum   <= vmm_gbl_rst_sum_o;

  vmm_configuring <= vmm_configuring_sm or vmm_gbl_rst_pulse2;  -- let the vmm switch know we are configuring something 





  vmm_global_reset_inst : vmm_global_reset
    port map(clk                 => vmm_clk_100,        -- main clock
             rst                 => reset,              -- reset
             gbl_rst             => vmm_gbl_rst_sum_o,  -- input from sys_init or global_reset
             vmm_wen             => vmm_wen_gbl_rst,    -- out to config switch
             vmm_ena             => vmm_ena_gbl_rst,    -- out to config switch
             vmm_gbl_rst_running => vmm_gbl_rst_running  -- will be anded with same from other while running sm
             );                      




-- gate acquisition reset from ext_trig on a 10 MHz clock
-- otherwise jitter problem since external trigger module runs on 40 MHz
-- and acquisition reset runs on 100 MHz
  process(clk10)
  begin
    if rising_edge(clk10) then
      sync_acq_rst_from_ext_trig <= acq_rst_from_ext_trig;
    end if;
  end process;
  
  GEN_ACQ_RST :
  for I in 0 to 7 generate
  begin
    vmm_acq_reset_inst : vmm_acq_reset
      port map(
        clk     => vmm_clk_100,         -- main clock
        rst     => reset,               -- reset
        acq_rst => acq_rst_from_vmm_fsm_vec(I) or sync_acq_rst_from_ext_trig,  -- input
        -- ann added ext_trig
--        acq_rst => acq_rst_from_vmm_fsm_vec(I) or acq_rst_from_data0(I) or acq_rst_from_ext_trig,  -- input
        -- REMOVED ACQ_RST_FROM_DATA0
        vmm_wen             => vmm_wen_acq_rst(I),     -- or with cfg sm
        vmm_ena             => vmm_ena_acq_rst(I),     -- or with cfg sm
        vmm_acq_rst_running => vmm_acq_rst_running(I)  -- will be anded with same from other while running sm
        );  
  end generate GEN_ACQ_RST;

  acq_rst_from_data0_o <= acq_rst_from_data0;


----------------============================------------
---------------    VMM Data Acquisitions     -----------
----------------============================------------

  GEN_DAQ :
  for I in 0 to 7 generate
  begin
    vmm_daq_inst : vmm_daq
      port map(
        vmm_clk_200 => vmm_clk_200,
        reset       => reset,
        vmmNumber   => std_logic_vector(to_unsigned(I, 3)),

        vmm_data0    => vmm_data0_vec(I),
        vmm_data1    => vmm_data1_vec(I),
        vmm_art      => vmm_art_vec(I),
        turn_counter => turn_counter,

        vmm_cktk_daq_en => vmm_cktk_daq_en_vec(I),
        vmm_ckdt_en     => vmm_ckdt_en_vec(I),

        vmm_ckdt  => vmm_ckdt,
        vmm_ckart => vmm_ckart,

        din           => vmm_din_vec(I),
        dt_cntr_intg0 => dt_cntr_intg0_vec(I),
        dt_cntr_intg1 => dt_cntr_intg1_vec(I),
        vmm_data_buf  => vmm_data_buf_vec(I),

        rd_clk        => vmm_clk_200,
        empty         => vmm_empty(I),
        rd_data_count => vmm_rd_data_count(I),
        wr_data_count => vmm_wr_data_count(I),
        rd_en         => vmm_rd_en(I),
        dout          => vmm_dout_vec_i(I),

        acq_rst_from_data0      => acq_rst_from_data0(I),
        acq_rst_term_count      => acq_rst_term_count,
        acq_rst_hold_term_count => acq_rst_hold_term_count,

        dt_state_o        => dt_state (I),
        acq_rst_counter_o => acq_rst_counter(I),
        fifo_rst_from_ext_trig => fifo_rst_from_ext_trig,
        --nathan
        mmfe_id_reg => axi_reg(80)(3 downto 0)
--        mmfe_id_reg => axi_reg(80)(3 downto 0)

        );            
  end generate GEN_DAQ;








--control output assignments
  vmm_ckart_en <= '1';
  vmm_cktp_en  <= '1';
  vmm_ckbc_en  <= '1';

--clock input assignments
  vmm_ckart_i <= vmm_ckart;

--data input assignments
  cfg_bit_in_i <= cfg_bit_in;
  testX_i      <= testX;

-- data output assignments
  cfg_bit_out  <= cfg_bit_out_i;
  vmm_dout_vec <= vmm_dout_vec_i;


----------------=======================================------------
---------------      VMM Round Robin Data Colection     -----------
----------------=======================================------------

---- pull data from daq (if available) in round robin style
----  U_Round_Robin : process(EXT_AXI_CLK, reset, vmm_dout_vec_i, vmm_empty)

  U_Round_Robin : process(vmm_clk_200)
  begin
    if rising_edge(vmm_clk_200) then
       if VMM_DATA_READY = '1' then
        VMM_SEL <= VMM_SEL + 1;
      else
        VMM_SEL <= VMM_SEL + 2;
      end if;  
          
      din <= vmm_dout_vec_i(RR_VMM_PTR);
      wr_en  <= VMM_DATA_READY;
    end if;
  end process U_Round_Robin;
  
   U_Round_Robin_Read_Enable : process(RR_VMM_PTR,VMM_DATA_READY)
  begin
       vmm_rd_en <= (others => '0');
       vmm_rd_en(RR_VMM_PTR) <= VMM_DATA_READY;
  end process;
  RR_PAUSE<= '1' WHEN (RR_PROG_FULL = '1' AND VMM_SEL(0) = '0') ELSE '0';
  RR_VMM_PTR     <= to_integer(VMM_SEL(3 downto 1));
  VMM_DATA_READY <= '1' when ((vmm_empty(RR_VMM_PTR) = '0') and (vmm_ro(RR_VMM_PTR) = '1') AND RR_PAUSE = '0') else '0';
  
  fifo_round_robin_inst : fifo_round_robin
    port map (
      rst         => reset or fifo_rst_from_ext_trig,
      wr_clk      => vmm_clk_200,
      rd_clk      => EXT_AXI_CLK,  --vmm_clk_200, --nathan
      din         => din,
      wr_en       => wr_en,
      rd_en       => rr_data_fifo_rd_en,
      dout        => rr_data_fifo_dout,
      full        => open,
      almost_full => OPEN,

      empty => rr_data_fifo_empty,

      rd_data_count => rr_rd_data_count,
      wr_data_count => rr_wr_data_count,
      almost_empty  => open,
      prog_full => RR_PROG_FULL
      );

end rtl;
