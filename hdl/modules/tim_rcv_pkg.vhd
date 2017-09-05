library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.wb_stream_pkg.all;
use work.wb_stream_generic_pkg.all;
use work.tim_endpoint_pkg.all;

package tim_rcv_pkg is

  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------

  component wb_tim_rcv_core
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_clk_sys_freq                            : natural := 62500000; -- in Hz
    g_freq_meas_counter_bits                  : natural := 28;
    g_dmtd_counter_bits                       : natural := 14
  );
  port
  (
    sys_rst_n_i                               : in std_logic;
    dmtd_rst_n_i                              : in std_logic;

    -- System clock
    sys_clk_i                                 : in std_logic;
    -- Input clocks
    dmtd_a_clk_i                              : in std_logic;
    dmtd_b_clk_i                              : in std_logic;
    dmtd_clk_i                                : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

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

    -----------------------------
    -- Tag Signals Interface
    -----------------------------
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
    freq_dmtd_b_valid_o                       : out std_logic
  );
  end component;

  component xwb_tim_rcv_core
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_clk_sys_freq                            : natural := 62500000; -- in Hz
    g_freq_meas_counter_bits                  : natural := 28;
    g_dmtd_counter_bits                       : natural := 14
  );
  port
  (
    sys_rst_n_i                               : in std_logic;
    dmtd_rst_n_i                              : in std_logic;

    -- System clock
    sys_clk_i                                 : in std_logic;
    -- Input clocks
    dmtd_a_clk_i                              : in std_logic;
    dmtd_b_clk_i                              : in std_logic;
    dmtd_clk_i                                : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                  : in t_wishbone_slave_in;
    wb_slv_o                                  : out t_wishbone_slave_out;

    -----------------------------
    -- Tag Signals Interface
    -----------------------------
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
    freq_dmtd_b_valid_o                       : out std_logic
  );
  end component;

  component wb_tim_subsys
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_with_extra_wb_reg                       : boolean := false;
    -- System clock frequency in Hz
    g_clk_sys_freq                            : natural := 62500000; -- in Hz
    -- Number of bits for frequency counter
    g_freq_meas_counter_bits                  : natural := 28;
    -- Number of bits for DMTD counter bits
    g_dmtd_counter_bits                       : natural := 14
  );
  port
  (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------
    -- system reference clock (any frequency <= f(clk_ref_i))
    clk_sys_i                                 : in std_logic;
    -- DDMTD offset clock (125.x MHz)
    clk_dmtd_i                                : in std_logic;
    -- Timing reference (125 MHz)
    clk_ref_i                                 : in std_logic;
    -- Si57x clock to be disciplined
    clk_si57x_i                               : in std_logic;
    -- Clocy system reset
    rst_n_i                                   : in std_logic;
    -- Si57x domain reset
    rst_si57x_n_i                             : in std_logic;
    -- DMTD domain reset
    rst_dmtd_n_i                              : in std_logic;
    -- Reference clock domain reset
    rst_ref_n_i                               : in std_logic;

    ---------------------------------------------------------------------------
    -- PHY I/f
    ---------------------------------------------------------------------------
    phy8_o                                    : out t_phy_8bits_from_tr;
    phy8_i                                    : in  t_phy_8bits_to_tr := c_dummy_phy8_to_tr;
    phy16_o                                   : out t_phy_16bits_from_tr;
    phy16_i                                   : in  t_phy_16bits_to_tr := c_dummy_phy16_to_tr;

    ---------------------------------------------------------------------------
    -- SFP management info
    ---------------------------------------------------------------------------
    sfp_scl_o                                 : out std_logic;
    sfp_scl_i                                 : in  std_logic := '1';
    sfp_sda_o                                 : out std_logic;
    sfp_sda_i                                 : in  std_logic := '1';
    sfp_det_i                                 : in  std_logic := '0';

    ---------------------------------------------------------------------------
    --External WB interface
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

    -----------------------------
    -- Tag Signals Interface
    -----------------------------
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
    -- Buttons, LEDs
    ---------------------------------------------------------------------------
    led_act_o                                 : out std_logic;
    led_link_o                                : out std_logic;
    btn1_i                                    : in  std_logic := '1';
    btn2_i                                    : in  std_logic := '1';
    -- Link ok indication
    link_ok_o                                 : out std_logic
  );
  end component;

  component xwb_tim_subsys
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_with_extra_wb_reg                       : boolean := false;
    -- System clock frequency in Hz
    g_clk_sys_freq                            : natural := 62500000; -- in Hz
    -- Number of bits for frequency counter
    g_freq_meas_counter_bits                  : natural := 28;
    -- Number of bits for DMTD counter bits
    g_dmtd_counter_bits                       : natural := 14
  );
  port
  (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------
    -- system reference clock (any frequency <= f(clk_ref_i))
    clk_sys_i                                 : in std_logic;
    -- DDMTD offset clock (125.x MHz)
    clk_dmtd_i                                : in std_logic;
    -- Timing reference (125 MHz)
    clk_ref_i                                 : in std_logic;
    -- Si57x clock to be disciplined
    clk_si57x_i                               : in std_logic;
    -- Clocy system reset
    rst_n_i                                   : in std_logic;
    -- Si57x domain reset
    rst_si57x_n_i                             : in std_logic;
    -- DMTD domain reset
    rst_dmtd_n_i                              : in std_logic;
    -- Reference clock domain reset
    rst_ref_n_i                               : in std_logic;

    ---------------------------------------------------------------------------
    -- PHY I/f
    ---------------------------------------------------------------------------
    phy8_o                                    : out t_phy_8bits_from_tr;
    phy8_i                                    : in  t_phy_8bits_to_tr := c_dummy_phy8_to_tr;
    phy16_o                                   : out t_phy_16bits_from_tr;
    phy16_i                                   : in  t_phy_16bits_to_tr := c_dummy_phy16_to_tr;

    ---------------------------------------------------------------------------
    -- SFP management info
    ---------------------------------------------------------------------------
    sfp_scl_o                                 : out std_logic;
    sfp_scl_i                                 : in  std_logic := '1';
    sfp_sda_o                                 : out std_logic;
    sfp_sda_i                                 : in  std_logic := '1';
    sfp_det_i                                 : in  std_logic := '0';

    ---------------------------------------------------------------------------
    --External WB interface
    ---------------------------------------------------------------------------
    wb_slv_i                                  : in  t_wishbone_slave_in := cc_dummy_slave_in;
    wb_slv_o                                  : out t_wishbone_slave_out;

    -----------------------------
    -- Tag Signals Interface
    -----------------------------
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
    -- Buttons, LEDs
    ---------------------------------------------------------------------------
    led_act_o                                 : out std_logic;
    led_link_o                                : out std_logic;
    btn1_i                                    : in  std_logic := '1';
    btn2_i                                    : in  std_logic := '1';
    -- Link ok indication
    link_ok_o                                 : out std_logic
  );
  end component;

end tim_rcv_pkg;
