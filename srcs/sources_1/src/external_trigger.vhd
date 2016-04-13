----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/28/2015 09:00:17 AM
-- Design Name: 
-- Module Name: external_trigger - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

--edited by A. Wang to implement VMM synchronization


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity external_trigger is
  port (clk_40                  : in  std_logic;
        reset_bcid_counter      : in  std_logic;
        ext_trigger_in          : in  std_logic;
        ext_trigger_en          : in  std_logic;
        reading_fin             : in  std_logic;
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
        --ann added set of signals for trigger sync
        num_ext_trig_o          : out std_logic_vector (19 downto 0);  --goes
                                                                       --to axi_reg_79
        acq_rst_from_ext_trig_o : out std_logic;                       
        vmm_cktk_ext_trig_en_o  : out std_logic;
        read_data_o             : out std_logic;  -- goes to axi_reg_78
        fifo_rst_from_ext_trig_o : out std_logic 
        );

end external_trigger;


architecture Behavioral of external_trigger is

-- signals are here

  constant bcid_offset         : std_logic_vector (11 downto 0) := x"716";  --x"005";
  --jh added first '0' to x"0FA0"; decleration because of synth error...
  constant busy_width          : std_logic_vector (15 downto 0) := x"0FA0";  -- time busy is set (1 ms) busy_width = f_clk / (1/t_desired) --kg changed to 1/10 what it was
  constant fifo_drain_length   : std_logic_vector (15 downto 0) := x"1F40";  --8000 ticks,
                                                                             --200 microsec
--  constant trigger_gui_pass_length : std_logic_vector (15 downto 0) := x"FFFD";  
  constant trigger_gui_pass_length : std_logic_vector (15 downto 0) := x"3E80";  
  constant trigger_pulse_width : std_logic_vector (3 downto 0)  := x"A";  --trigger pulse width of 250ns. trigger_pulse_width = t_desired / t_clk
  signal   trigger             : std_logic;
  signal   trigger_pulse       : std_logic;
  signal   busy                : std_logic := '0';
  signal   busy_from_acq_rst   : std_logic                      := '0';
  signal   busy_count          : std_logic_vector (15 downto 0);
  signal   trigger_pulse_count : std_logic_vector(3 downto 0);
  signal   trigger_was_low     : std_logic;  --flag to check that ext_trigger has been low after busy is done. This eliminates problem of trigger
                                             -- pulse firing again once busy goes low if ext_trigger never goes low.

  signal reset_bcid_counter_i    : std_logic;
  signal ext_trigger_in_i        : std_logic;
  signal ext_trigger_en_i        : std_logic;
  signal ext_trigger_pulse       : std_logic;
  signal ext_trigger_pulse_i     : std_logic;
  signal busy_from_ext_trigger   : std_logic;
  signal busy_from_ext_trigger_i : std_logic;
  signal bcid_counter            : std_logic_vector(11 downto 0);
  signal bcid_counter_i          : std_logic_vector(11 downto 0);
  signal bcid_captured           : std_logic_vector(11 downto 0);
  signal bcid_captured_i         : std_logic_vector(11 downto 0);
  signal bcid_corrected          : std_logic_vector(11 downto 0);
  signal bcid_corrected_i        : std_logic_vector(11 downto 0);
  signal turn_counter            : std_logic_vector(15 downto 0);
  signal turn_counter_i          : std_logic_vector(15 downto 0);
  signal turn_counter_captured   : std_logic_vector(15 downto 0);
  signal turn_counter_captured_i : std_logic_vector(15 downto 0);
  --ann
  signal reading_fin_i : std_logic;
  signal num_ext_trig            : std_logic_vector(19 downto 0);
  signal acq_rst_from_ext_trig   : std_logic := '0';
  signal vmm_cktk_ext_trig_en    : std_logic := '1';
  signal read_data               : std_logic := '0';
  signal fifo_rst                : std_logic := '0';
  signal acq_rst_length     : std_logic_vector(15 downto 0) := x"000A";  -- how long acquistion reset is
  signal acq_rst_length_ctr : std_logic_vector(15 downto 0) := x"0000";


  attribute keep                                  : string;
  attribute mark_debug                            : string;
  attribute keep of reset_bcid_counter_i          : signal is "true";
  attribute keep of ext_trigger_in_i              : signal is "true";
  attribute keep of ext_trigger_en_i              : signal is "true";
  attribute keep of ext_trigger_pulse_i           : signal is "true";
  attribute keep of busy_from_ext_trigger_i       : signal is "true";
  attribute keep of bcid_counter_i                : signal is "true";
  attribute keep of bcid_captured_i               : signal is "true";
  attribute keep of bcid_corrected_i              : signal is "true";
  attribute keep of turn_counter_i                : signal is "true";
  attribute keep of turn_counter_captured_i       : signal is "true";
  attribute mark_debug of reset_bcid_counter_i    : signal is "true";
  attribute mark_debug of ext_trigger_in_i        : signal is "true";
  attribute mark_debug of ext_trigger_pulse_i     : signal is "true";
  attribute mark_debug of busy_from_ext_trigger_i : signal is "true";
  attribute mark_debug of bcid_counter_i          : signal is "true";
  attribute mark_debug of bcid_captured_i         : signal is "true";
  attribute mark_debug of bcid_corrected_i        : signal is "true";
  attribute mark_debug of turn_counter_i          : signal is "true";
  attribute mark_debug of turn_counter_captured_i : signal is "true";
  --ann
  attribute mark_debug of num_ext_trig            : signal is "true";
  attribute mark_debug of acq_rst_from_ext_trig   : signal is "true";
  attribute mark_debug of vmm_cktk_ext_trig_en    : signal is "true";
  attribute mark_debug of busy_from_acq_rst       : signal is "true";
  attribute mark_debug of read_data               : signal is "true";
  attribute mark_debug of fifo_rst                : signal is "true";
  attribute mark_debug of reading_fin_i           : signal is "true";
  signal probe0_i : std_logic_vector(3 downto 0);
--    signal probe1_i : STD_LOGIC_VECTOR(11 DOWNTO 0); 
--    signal probe2_i : STD_LOGIC_VECTOR(11 DOWNTO 0); 
--    signal probe3_i : STD_LOGIC_VECTOR(11 DOWNTO 0); 
--    signal probe4_i : STD_LOGIC_VECTOR(15 DOWNTO 0);
--    signal probe5_i : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin

  ext_trigger_pulse     <= trigger_pulse;
  busy_from_ext_trigger <= busy;

  process (clk_40, reset_bcid_counter, ext_trigger_in, ext_trigger_en)
  begin
    if (ext_trigger_en = '1') then
      if (reset_bcid_counter = '1') then
        --  this comes from the state machine that starts the bc clock
        bcid_counter    <= x"000";
        turn_counter    <= x"0000";
        busy            <= '0';
        trigger_pulse   <= '0';
        trigger_was_low <= '1';
        num_ext_trig    <= x"00000"; 
        
      elsif (rising_edge (clk_40)) then
        --stops BCID counter whenever cyclic soft reset is happening or we have
        --an ext trig
        if busy_from_acq_rst = '0' and busy = '0' then
          bcid_counter <= bcid_counter + '1';  
        end if;
        if (acq_rst_from_ext_trig = '1') then  --set soft reset length
          acq_rst_length_ctr <= acq_rst_length_ctr + '1';
        end if;
        if (acq_rst_length_ctr = acq_rst_length) then
          acq_rst_from_ext_trig <= '0';
          acq_rst_length_ctr    <= (others => '0');

        --sets busy low after soft reset finishes
        elsif acq_rst_from_ext_trig = '0' and (busy_from_acq_rst = '1')then
          busy_from_acq_rst    <= '0';
          fifo_rst             <= '0';
          vmm_cktk_ext_trig_en <= '1';
--          bcid_counter         <= bcid_counter + '1';
        elsif acq_rst_from_ext_trig = '0' and (busy = '1') and (reading_fin = '1') and (read_data = '0') then
          busy  <= '0';
          fifo_rst             <= '0';  --maybe take this out
          vmm_cktk_ext_trig_en <= '1';
--          bcid_counter         <= bcid_counter + '1';
        elsif (bcid_counter = x"fff" and busy = '0' and ext_trigger_in = '0') then  
          --so if 4095 and also not busy from an external trigger
          acq_rst_from_ext_trig <= '1';        --acquistion reset every 4096
          fifo_rst              <= '1';
          turn_counter          <= turn_counter + '1';
          busy_from_acq_rst     <= '1';
          bcid_counter          <= x"000";     --BCID counter reset
          vmm_cktk_ext_trig_en  <= '0';        --disables CKTK 
        end if;

        if (busy = '0') then
          --  here comes an external trigger and we were waiting for one
          if (ext_trigger_in = '1' and trigger_was_low = '1') then
--          if (ext_trigger_in = '1' and trigger_was_low = '1')then
            -- generate a trigger pulse and busy
            trigger_pulse         <= '1';
            busy                  <= '1';
            trigger_was_low       <= '0';
            fifo_rst              <= '0';
            bcid_captured         <= bcid_counter;
            turn_counter_captured <= turn_counter;
            num_ext_trig          <= num_ext_trig + '1';  --ann
            -- if not busy and no external trigger, continue to wait            
          elsif (ext_trigger_in = '0') then
            trigger_was_low <= '1';
          end if;
        else
          -- here we are in the busy state
          -- keep busy high until the busy width is reached
          -- tell microblaze that data is ready
          if (busy_count = fifo_drain_length) then
            read_data <= '1';
          -- after data is read, send resets
          elsif (reading_fin = '1' and read_data = '1') then
--          elsif (busy_count > trigger_gui_pass_length) then
            -- reading_fin_i is the rising edge of the signal set by the GUI to
            -- say that it's done reading
            read_data <= '0';
            acq_rst_from_ext_trig <= '1';
            bcid_counter          <= x"000";
            vmm_cktk_ext_trig_en  <= '0';        --disables CKTK 
            turn_counter          <= turn_counter + '1';
            trigger_was_low       <= '1';
          end if;
          if (trigger_pulse_count >= trigger_pulse_width - '1') then
            trigger_pulse <= '0';
          end if;
        end if;
      end if;
    end if;
    
  end process;

  --time for trigger_pulse
  process (clk_40)
  begin
    if clk_40 = '1' and clk_40'event then
      if trigger_pulse = '0' or reset_bcid_counter = '1' then
        trigger_pulse_count <= x"0";
      elsif trigger_pulse = '1' then
        trigger_pulse_count <= trigger_pulse_count + '1';
      end if;
    end if;
  end process;

  --time for busy
  process (clk_40)
  begin
    if clk_40 = '1' and clk_40'event then
      if busy = '0' or reset_bcid_counter = '1' then
        busy_count <= x"0000";
      elsif busy = '1' then
        busy_count <= busy_count + '1';
      end if;
    end if;
  end process;

--  need to account for bc counter boundaries
  bcid_corrected_m1 <= bcid_corrected - b"000000000001";
  bcid_corrected_m2 <= bcid_corrected - b"000000000010";
  bcid_corrected_m3 <= bcid_corrected - b"000000000011";
  bcid_corrected_m4 <= bcid_corrected - b"000000000100";
  bcid_corrected_m5 <= bcid_corrected - b"000000000101";
  bcid_corrected_p1 <= bcid_corrected + b"000000000001";
  bcid_corrected_p2 <= bcid_corrected + b"000000000010";
  bcid_corrected_p3 <= bcid_corrected + b"000000000011";
  bcid_corrected_p4 <= bcid_corrected + b"000000000100";
  bcid_corrected_p5 <= bcid_corrected + b"000000000101";

  reset_bcid_counter_i    <= reset_bcid_counter;
  ext_trigger_in_i        <= ext_trigger_in;
  ext_trigger_en_i        <= ext_trigger_en;
  ext_trigger_pulse_i     <= ext_trigger_pulse;
  ext_trigger_pulse_o     <= ext_trigger_pulse;
  busy_from_ext_trigger_i <= busy_from_ext_trigger;
  busy_from_ext_trigger_o <= busy_from_ext_trigger;
  busy_from_acq_rst_o     <= busy_from_acq_rst;
  bcid_counter_i          <= bcid_counter;
  bcid_counter_o          <= bcid_counter;
  bcid_captured_i         <= bcid_captured;
  bcid_captured_o         <= bcid_captured;
  bcid_corrected_i        <= bcid_corrected;
  bcid_corrected_o        <= bcid_corrected;
  turn_counter_i          <= turn_counter;
  turn_counter_o          <= turn_counter;
  turn_counter_captured_i <= turn_counter_captured;
  turn_counter_captured_o <= turn_counter_captured;
  num_ext_trig_o          <= num_ext_trig;           --ann
  acq_rst_from_ext_trig_o <= acq_rst_from_ext_trig;  --ann
  vmm_cktk_ext_trig_en_o  <= vmm_cktk_ext_trig_en;   --ann
  read_data_o             <= read_data;   --ann
  fifo_rst_from_ext_trig_o <= fifo_rst;   --ann
  reading_fin_i <= reading_fin;         --actually not sure that this is necessary
-- assign probes
--        probe0_i <= reset_bcid_counter_i & ext_trigger_in_i & ext_trigger_pulse_i & busy_from_ext_trigger_i ;

--ila_ext_trig_inst : ila_ext_trig
--    PORT MAP (
--        clk => clk_40,

--        probe0 => probe0_i,
--        probe1 => bcid_counter_i,
--        probe2 => bcid_captured_i,
--        probe3 => bcid_corrected_i,
--        probe4 => turn_counter_i,
--        probe5 => turn_counter_captured_i
--    );            
end Behavioral;
