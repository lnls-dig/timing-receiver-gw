library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.genram_pkg.all;

package tr_afc_pkg is

  component tr_board_afc
  generic(
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    -- Select reference clock source
    g_ref_clock_input                         : string := "EXT";
    -- System clock frequency in Hz
    g_clk_sys_freq                            : natural := 62500000; -- in Hz
    -- Number of bits for frequency counter
    g_freq_meas_counter_bits                  : natural := 28;
    -- Number of bits for DMTD counter bits
    g_dmtd_counter_bits                       : natural := 14;
    -- Set to TRUE will speed up some initialization processes
    g_simulation                              : integer := 0
  );
  port (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------
    -- Reset input (active low, can be async)
    areset_n_i                                : in  std_logic;
    -- Optional reset input active low with rising edge detection. Does not
    -- reset PLLs.
    areset_edge_n_i                           : in  std_logic := '1';

    -- 125 MHz general clock
    clk_125m_p_i                              : in std_logic;
    clk_125m_n_i                              : in std_logic;

    -- DMTD clock
    clk_20m_vcxo_p_i                          : in std_logic;
    clk_20m_vcxo_n_i                          : in std_logic;

    -- Si57x clock
    clk_si57x_p_i                             : in std_logic;
    clk_si57x_n_i                             : in std_logic;

    -- GTP clock
    clk_125m_gtp_n_i                          : in  std_logic;
    clk_125m_gtp_p_i                          : in  std_logic;

    -- Optional External Reference clock (if g_ref_clock_input = "EXT")
    clk_ext_ref_p_i                           : in std_logic := '0';
    clk_ext_ref_n_i                           : in std_logic := '0';

    -- 62.5MHz sys clock output
    clk_sys_62m5_o                            : out std_logic;
    -- 125MHz ref clock output
    clk_ref_125m_o                            : out std_logic;
    -- 200MHz clock output
    clk_200m_o                                : out std_logic;
    -- DMTD 62.x offset clock
    clk_dmtd_o                                : out std_logic;
    -- Si57x clock output
    clk_si57x_o                               : out std_logic;
    -- active low reset outputs, synchronous to 62m5
    rst_sys_62m5_n_o                          : out std_logic;
    -- active low reset output, synchronous to clocks 62m5 for PCIe
    rst_62m5_pcie_n_o                         : out std_logic;
    -- active low reset outputs, synchronous to 125m
    rst_ref_125m_n_o                          : out std_logic;
    -- active low reset output, synchronous to clocks 200m
    rst_200m_n_o                              : out std_logic;
    -- active low reset output, synchronous to clocks dmtd
    rst_dmtd_n_o                              : out std_logic;
    -- active low reset output, synchronous to clock si57x
    rst_si57x_n_o                             : out std_logic;

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver and SFP management info
    ---------------------------------------------------------------------------
    sfp_txp_o                                 : out std_logic;
    sfp_txn_o                                 : out std_logic;
    sfp_rxp_i                                 : in  std_logic;
    sfp_rxn_i                                 : in  std_logic;
    sfp_det_i                                 : in  std_logic := '1';
    sfp_sda_i                                 : in  std_logic;
    sfp_sda_o                                 : out std_logic;
    sfp_scl_i                                 : in  std_logic;
    sfp_scl_o                                 : out std_logic;
    sfp_rate_select_o                         : out std_logic;
    sfp_tx_fault_i                            : in  std_logic := '0';
    sfp_tx_disable_o                          : out std_logic;
    sfp_los_i                                 : in  std_logic := '0';

    ---------------------------------------------------------------------------
    -- External WB interface
    ---------------------------------------------------------------------------
    wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb_we_i                                   : in  std_logic := '0';
    wb_cyc_i                                  : in  std_logic := '0';
    wb_stb_i                                  : in  std_logic := '0';
    wb_ack_o                                  : out std_logic;
    wb_err_o                                  : out std_logic;
    wb_rty_o                                  : out std_logic;
    wb_stall_o                                : out std_logic;

    ---------------------------------------------------------------------------
    -- Tag Signals Interface
    ---------------------------------------------------------------------------
    tag_a_o                                   : out std_logic_vector(g_dmtd_counter_bits-1 downto 0);
    tag_a_p_o                                 : out std_logic;
    tag_b_o                                   : out std_logic_vector(g_dmtd_counter_bits-1 downto 0);
    tag_b_p_o                                 : out std_logic;

    phase_raw_o                               : out std_logic_vector(g_dmtd_counter_bits-1 downto 0);
    phase_raw_p_o                             : out std_logic;
    phase_meas_o                              : out std_logic_vector(31 downto 0);
    phase_meas_p_o                            : out std_logic;

    freq_dmtd_a_o                             : out std_logic_vector(g_freq_meas_counter_bits-1 downto 0);
    freq_dmtd_a_valid_o                       : out std_logic;
    freq_dmtd_b_o                             : out std_logic_vector(g_freq_meas_counter_bits-1 downto 0);
    freq_dmtd_b_valid_o                       : out std_logic;

    ---------------------------------------------------------------------------
    -- Buttons, LEDs and PPS output
    ---------------------------------------------------------------------------
    led_act_o                                 : out std_logic;
    led_link_o                                : out std_logic;
    btn1_i                                    : in  std_logic := '1';
    btn2_i                                    : in  std_logic := '1';
    -- Link ok indication
    link_ok_o                                 : out std_logic
  );
  end component;

  component xtr_board_afc
  generic(
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    -- Select reference clock source
    g_ref_clock_input                         : string := "EXT";
    -- System clock frequency in Hz
    g_clk_sys_freq                            : natural := 62500000; -- in Hz
    -- Number of bits for frequency counter
    g_freq_meas_counter_bits                  : natural := 28;
    -- Number of bits for DMTD counter bits
    g_dmtd_counter_bits                       : natural := 14;
    -- Set to TRUE will speed up some initialization processes
    g_simulation                              : integer := 0
  );
  port (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------
    -- Reset input (active low, can be async)
    areset_n_i                                : in  std_logic;
    -- Optional reset input active low with rising edge detection. Does not
    -- reset PLLs.
    areset_edge_n_i                           : in  std_logic := '1';

    -- 125 MHz general clock
    clk_125m_p_i                              : in std_logic;
    clk_125m_n_i                              : in std_logic;

    -- DMTD clock
    clk_20m_vcxo_p_i                          : in std_logic;
    clk_20m_vcxo_n_i                          : in std_logic;

    -- Si57x clock
    clk_si57x_p_i                             : in std_logic;
    clk_si57x_n_i                             : in std_logic;

    -- GTP clock
    clk_125m_gtp_n_i                          : in  std_logic;
    clk_125m_gtp_p_i                          : in  std_logic;

    -- Optional External Reference clock (if g_ref_clock_input = "EXT")
    clk_ext_ref_p_i                           : in std_logic := '0';
    clk_ext_ref_n_i                           : in std_logic := '0';

    -- 62.5MHz sys clock output
    clk_sys_62m5_o                            : out std_logic;
    -- 125MHz ref clock output
    clk_ref_125m_o                            : out std_logic;
    -- 200MHz clock output
    clk_200m_o                                : out std_logic;
    -- DMTD 62.x offset clock
    clk_dmtd_o                                : out std_logic;
    -- Si57x clock output
    clk_si57x_o                               : out std_logic;
    -- active low reset outputs, synchronous to 62m5
    rst_sys_62m5_n_o                          : out std_logic;
    -- active low reset output, synchronous to clocks 62m5 for PCIe
    rst_62m5_pcie_n_o                         : out std_logic;
    -- active low reset outputs, synchronous to 125m
    rst_ref_125m_n_o                          : out std_logic;
    -- active low reset output, synchronous to clocks 200m
    rst_200m_n_o                              : out std_logic;
    -- active low reset output, synchronous to clocks dmtd
    rst_dmtd_n_o                              : out std_logic;
    -- active low reset output, synchronous to clock si57x
    rst_si57x_n_o                             : out std_logic;

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver and SFP management info
    ---------------------------------------------------------------------------
    sfp_txp_o                                 : out std_logic;
    sfp_txn_o                                 : out std_logic;
    sfp_rxp_i                                 : in  std_logic;
    sfp_rxn_i                                 : in  std_logic;
    sfp_det_i                                 : in  std_logic := '1';
    sfp_sda_i                                 : in  std_logic;
    sfp_sda_o                                 : out std_logic;
    sfp_scl_i                                 : in  std_logic;
    sfp_scl_o                                 : out std_logic;
    sfp_rate_select_o                         : out std_logic;
    sfp_tx_fault_i                            : in  std_logic := '0';
    sfp_tx_disable_o                          : out std_logic;
    sfp_los_i                                 : in  std_logic := '0';

    ---------------------------------------------------------------------------
    -- External WB interface
    ---------------------------------------------------------------------------
    wb_slv_o                                  : out t_wishbone_slave_out;
    wb_slv_i                                  : in  t_wishbone_slave_in := cc_dummy_slave_in;

    ---------------------------------------------------------------------------
    -- Tag Signals Interface
    ---------------------------------------------------------------------------
    tag_a_o                                   : out std_logic_vector(g_dmtd_counter_bits-1 downto 0);
    tag_a_p_o                                 : out std_logic;
    tag_b_o                                   : out std_logic_vector(g_dmtd_counter_bits-1 downto 0);
    tag_b_p_o                                 : out std_logic;

    phase_raw_o                               : out std_logic_vector(g_dmtd_counter_bits-1 downto 0);
    phase_raw_p_o                             : out std_logic;
    phase_meas_o                              : out std_logic_vector(31 downto 0);
    phase_meas_p_o                            : out std_logic;

    freq_dmtd_a_o                             : out std_logic_vector(g_freq_meas_counter_bits-1 downto 0);
    freq_dmtd_a_valid_o                       : out std_logic;
    freq_dmtd_b_o                             : out std_logic_vector(g_freq_meas_counter_bits-1 downto 0);
    freq_dmtd_b_valid_o                       : out std_logic;

    ---------------------------------------------------------------------------
    -- Buttons, LEDs and PPS output
    ---------------------------------------------------------------------------
    led_act_o                                 : out std_logic;
    led_link_o                                : out std_logic;
    btn1_i                                    : in  std_logic := '1';
    btn2_i                                    : in  std_logic := '1';
    -- Link ok indication
    link_ok_o                                 : out std_logic
  );
  end component;

end tr_afc_pkg;
