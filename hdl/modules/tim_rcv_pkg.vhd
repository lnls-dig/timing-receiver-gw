library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.wb_stream_pkg.all;
use work.wb_stream_generic_pkg.all;

package tim_rcv_pkg is

  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------

  component wb_tim_rcv_core
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
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
    phase_meas_p_o                            : out std_logic
  );
  end component;

  component xwb_tim_rcv_core
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
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
    phase_meas_p_o                            : out std_logic
  );
  end component;

end tim_rcv_pkg;
