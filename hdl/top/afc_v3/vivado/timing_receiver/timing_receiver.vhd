------------------------------------------------------------------------------
-- Title      : Top design for a simple DDMTD test
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2017-08-03
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top-level design of a timing receiver
-------------------------------------------------------------------------------
-- Copyright (c) 2017 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author            Description
-- 2017-08-03  1.0      lucas.russo       Created
-- 2025-02-11  2.0      guilherme.ricioli Use afc_base_acq wrapper
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

library work;
  use work.acq_core_pkg.all;
  use work.afc_base_acq_pkg.all;
  use work.ipcores_pkg.all;
  use work.tr_afc_pkg.all;
  use work.trigger_common_pkg.all;
  use work.wishbone_pkg.all;

entity timing_receiver is
  port (
    -----------------------------------------
    -- Clocking pins
    -----------------------------------------
    sys_clk_p_i                                : in std_logic;
    sys_clk_n_i                                : in std_logic;

    -- DMTD clock
    clk_20m_vcxo_p_i                           : in std_logic;
    clk_20m_vcxo_n_i                           : in std_logic;

    -- Si57x clock
    clk_afc_si57x_p_i                          : in std_logic;
    clk_afc_si57x_n_i                          : in std_logic;

    -- Si57x I2C/OE
    afc_si57x_sda_b                            : inout std_logic;
    afc_si57x_scl_b                            : inout std_logic;
    afc_si57x_oe_o                             : out std_logic;

    -----------------------------------------
    -- Reset Button
    -----------------------------------------
    sys_rst_button_n_i                         : in std_logic;

    -----------------------------------------
    -- UART pins
    -----------------------------------------
    uart_txd_o                                : out std_logic;
    uart_rxd_i                                : in std_logic;

    -----------------------------------------
    -- Trigger pins
    -----------------------------------------
    trig_dir_o                                 : out   std_logic_vector(7 downto 0);
    trig_b                                     : inout std_logic_vector(7 downto 0);

    -----------------------------------------
    -- AFC Diagnostics
    -----------------------------------------
    diag_spi_cs_i                              : in std_logic;
    diag_spi_si_i                              : in std_logic;
    diag_spi_so_o                              : out std_logic;
    diag_spi_clk_i                             : in std_logic;

    -----------------------------------------
    -- ADN4604ASVZ
    -----------------------------------------
    adn4604_vadj2_clk_updt_n_o                 : out std_logic;

    -----------------------------------------
    -- FMC1 XM105 Breakout Board ports
    -----------------------------------------
    fmc1_clk0_m2c_p_i                          : in std_logic;
    fmc1_clk0_m2c_n_i                          : in std_logic;
    fmc1_clk1_m2c_p_i                          : in std_logic;
    fmc1_clk1_m2c_n_i                          : in std_logic;
    fmc1_la_p_i                                : in std_logic_vector(33 downto 0);
    fmc1_la_n_i                                : in std_logic_vector(33 downto 0);
    fmc1_ha_p_i                                : in std_logic_vector(23 downto 0);
    fmc1_ha_n_i                                : in std_logic_vector(23 downto 0);
    fmc1_hb_p_i                                : in std_logic_vector(21 downto 0);
    fmc1_hb_n_i                                : in std_logic_vector(21 downto 0);

    -----------------------------------------
    -- FMC2 XM105 Breakout Board ports
    -----------------------------------------
    fmc2_clk0_m2c_p_i                          : in std_logic;
    fmc2_clk0_m2c_n_i                          : in std_logic;
    fmc2_clk1_m2c_p_i                          : in std_logic;
    fmc2_clk1_m2c_n_i                          : in std_logic;
    fmc2_la_p_i                                : in std_logic_vector(33 downto 0);
    fmc2_la_n_i                                : in std_logic_vector(33 downto 0);
    fmc2_ha_p_i                                : in std_logic_vector(23 downto 0);
    fmc2_ha_n_i                                : in std_logic_vector(23 downto 0);
    fmc2_hb_p_i                                : in std_logic_vector(21 downto 0);
    fmc2_hb_n_i                                : in std_logic_vector(21 downto 0);

    -----------------------------------------
    -- PCIe pins
    -----------------------------------------

    -- DDR3 memory pins
    ddr3_dq_b                                 : inout std_logic_vector(c_DDR_DQ_WIDTH-1 downto 0);
    ddr3_dqs_p_b                              : inout std_logic_vector(c_DDR_DQS_WIDTH-1 downto 0);
    ddr3_dqs_n_b                              : inout std_logic_vector(c_DDR_DQS_WIDTH-1 downto 0);
    ddr3_addr_o                               : out   std_logic_vector(c_DDR_ROW_WIDTH-1 downto 0);
    ddr3_ba_o                                 : out   std_logic_vector(c_DDR_BANK_WIDTH-1 downto 0);
    ddr3_cs_n_o                               : out   std_logic_vector(0 downto 0);
    ddr3_ras_n_o                              : out   std_logic;
    ddr3_cas_n_o                              : out   std_logic;
    ddr3_we_n_o                               : out   std_logic;
    ddr3_reset_n_o                            : out   std_logic;
    ddr3_ck_p_o                               : out   std_logic_vector(c_DDR_CK_WIDTH-1 downto 0);
    ddr3_ck_n_o                               : out   std_logic_vector(c_DDR_CK_WIDTH-1 downto 0);
    ddr3_cke_o                                : out   std_logic_vector(c_DDR_CKE_WIDTH-1 downto 0);
    ddr3_dm_o                                 : out   std_logic_vector(c_DDR_DM_WIDTH-1 downto 0);
    ddr3_odt_o                                : out   std_logic_vector(c_DDR_ODT_WIDTH-1 downto 0);

    -- PCIe transceivers
    pci_exp_rxp_i                             : in  std_logic_vector(c_PCIELANES-1 downto 0);
    pci_exp_rxn_i                             : in  std_logic_vector(c_PCIELANES-1 downto 0);
    pci_exp_txp_o                             : out std_logic_vector(c_PCIELANES-1 downto 0);
    pci_exp_txn_o                             : out std_logic_vector(c_PCIELANES-1 downto 0);

    -- PCI clock and reset signals
    pcie_clk_p_i                              : in std_logic;
    pcie_clk_n_i                              : in std_logic;

    -- General board LEDs
    leds_o                                    : out std_logic_vector(2 downto 0)
  );
end timing_receiver;

architecture rtl of timing_receiver is

  -----------------------------------------------------------------------------
  -- General constants
  -----------------------------------------------------------------------------

  constant c_DIVCLK_DIVIDE                   : natural := 1;
  constant c_CLKBOUT_MULT_F                  : natural := 8;
  constant c_CLK0_DIVIDE_F                   : natural := 8; -- 125 MHz
  constant c_CLK1_DIVIDE                     : natural := 5; -- Must be 200 MHz
  constant c_SYS_CLOCK_FREQ                  : natural := 125000000; -- 125 MHz

  constant c_NUM_USER_IRQ                    : natural := 0;

  constant c_AFC_SI57x_I2C_FREQ              : natural := 400000;
  constant c_AFC_SI57x_INIT_OSC              : boolean := true;
  constant c_AFC_SI57x_INIT_RFREQ_VALUE      : std_logic_vector(37 downto 0) := "00" & x"2bc0af3b8";
  constant c_AFC_SI57x_INIT_N1_VALUE         : std_logic_vector(6 downto 0) := "0000111";
  constant c_AFC_SI57x_INIT_HS_VALUE         : std_logic_vector(2 downto 0) := "000";

  -----------------------------------------------------------------------------
  -- AFC Si57x signals
  -----------------------------------------------------------------------------

  signal afc_si57x_ext_wr                    : std_logic;
  signal afc_si57x_ext_rfreq_value           : std_logic_vector(37 downto 0);
  signal afc_si57x_ext_n1_value              : std_logic_vector(6 downto 0);
  signal afc_si57x_ext_hs_value              : std_logic_vector(2 downto 0);
  signal afc_si57x_sta_reconfig_done         : std_logic;

  -----------------------------------------------------------------------------
  -- Acquisition signals
  -----------------------------------------------------------------------------

  constant c_ACQ_FIFO_FC_SIZE                : natural := 1024;

  -- Acquisition channel indexes
  constant c_ACQ_PHASE_RAW_ID                : natural := 0;
  constant c_ACQ_PHASE_MEAS_ID               : natural := 1;
  constant c_ACQ_FREQ_MEAS_ID                : natural := 2;
  constant c_ACQ_NUM_CHANNELS                : natural := 3;

  -- Number of acquisition cores (FMC1, FMC2)
  constant c_ACQ_NUM_CORES                   : natural := 2;

  constant c_ACQ_MULTISHOT_RAM_SIZE          : t_property_value_array(c_ACQ_NUM_CORES-1 downto 0) := (2048, 2048);

  -- Acquisition core IDs
  constant c_ACQ_CORE_0_ID                   : natural := 0;
  constant c_ACQ_CORE_1_ID                   : natural := 1;


  constant c_ACQ_WIDTH_U64                   : unsigned(c_ACQ_CHAN_CMPLT_WIDTH_LOG2-1 downto 0)  := to_unsigned(64, c_ACQ_CHAN_CMPLT_WIDTH_LOG2);
  constant c_ACQ_NUM_ATOMS_U2                : unsigned(c_ACQ_NUM_ATOMS_WIDTH_LOG2-1 downto 0)   := to_unsigned(2, c_ACQ_NUM_ATOMS_WIDTH_LOG2);
  constant c_ACQ_ATOM_WIDTH_U32              : unsigned(c_ACQ_ATOM_WIDTH_LOG2-1 downto 0)        := to_unsigned(32, c_ACQ_ATOM_WIDTH_LOG2);

  constant c_FACQ_CHANNELS                   : t_facq_chan_param_array(c_ACQ_NUM_CHANNELS-1 downto 0) :=
  (
    c_ACQ_PHASE_RAW_ID  => (width => c_ACQ_WIDTH_U64, num_atoms => c_ACQ_NUM_ATOMS_U2, atom_width => c_ACQ_ATOM_WIDTH_U32),
    c_ACQ_PHASE_MEAS_ID => (width => c_ACQ_WIDTH_U64, num_atoms => c_ACQ_NUM_ATOMS_U2, atom_width => c_ACQ_ATOM_WIDTH_U32),
    c_ACQ_FREQ_MEAS_ID  => (width => c_ACQ_WIDTH_U64, num_atoms => c_ACQ_NUM_ATOMS_U2, atom_width => c_ACQ_ATOM_WIDTH_U32)
  );

  signal acq_chan_array                      : t_facq_chan_array2d(c_ACQ_NUM_CORES-1 downto 0, c_ACQ_NUM_CHANNELS-1 downto 0);

  -- Acquisition clocks
  signal fs_clk_array                        : std_logic_vector(c_ACQ_NUM_CORES-1 downto 0);
  signal fs_rst_n_array                      : std_logic_vector(c_ACQ_NUM_CORES-1 downto 0);
  signal fs_ce_array                         : std_logic_vector(c_ACQ_NUM_CORES-1 downto 0);

  -----------------------------------------------------------------------------
  -- Trigger signals
  -----------------------------------------------------------------------------

  constant c_TRIG_MUX_SYNC_EDGE              : string := "positive";
  constant c_TRIG_MUX_INTERN_NUM             : positive := c_ACQ_NUM_CHANNELS;
  constant c_TRIG_MUX_OUT_RESOLVER           : string := "fanout";
  constant c_TRIG_MUX_IN_RESOLVER            : string := "or";
  constant c_TRIG_MUX_WITH_INPUT_SYNC        : boolean := true;
  constant c_TRIG_MUX_WITH_OUTPUT_SYNC       : boolean := true;

  -- Trigger RCV intern IDs
  constant c_TRIG_RCV_INTERN_CHAN_0_ID       : natural := 0; -- Internal Channel 1
  constant c_TRIG_RCV_INTERN_CHAN_1_ID       : natural := 1; -- Internal Channel 2
  constant c_TRIG_MUX_RCV_INTERN_NUM         : positive := 2; -- 2 FMCs

  -- Trigger core IDs
  constant c_TRIG_MUX_0_ID                   : natural := 0;
  constant c_TRIG_MUX_1_ID                   : natural := 1;
  constant c_TRIG_MUX_NUM_CORES              : natural := c_ACQ_NUM_CORES;

  signal trig_rcv_intern                     : t_trig_channel_array2d(c_TRIG_MUX_NUM_CORES-1 downto 0, c_TRIG_MUX_RCV_INTERN_NUM-1 downto 0);
  signal trig_pulse_transm                   : t_trig_channel_array2d(c_TRIG_MUX_NUM_CORES-1 downto 0, c_TRIG_MUX_INTERN_NUM-1 downto 0);
  signal trig_pulse_rcv                      : t_trig_channel_array2d(c_TRIG_MUX_NUM_CORES-1 downto 0, c_TRIG_MUX_INTERN_NUM-1 downto 0);

  signal trig_fmc1_channel_1                 : t_trig_channel;
  signal trig_fmc1_channel_2                 : t_trig_channel;
  signal trig_fmc2_channel_1                 : t_trig_channel;
  signal trig_fmc2_channel_2                 : t_trig_channel;

  -----------------------------------------------------------------------------
  -- User signals
  -----------------------------------------------------------------------------

  constant c_SLV_TIM_SUBSYS_ID               : natural := 0;
  constant c_USER_NUM_CORES                  : natural := 1;

  -- Timing Subsystem
  constant c_TIM_SUBSYS_BRIDGE_SDB           : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"0000FFFF", x"00006000");

  -- WB SDB (Self Describing Bus) layout
  constant c_USER_SDB_RECORD_ARRAY           : t_sdb_record_array(c_USER_NUM_CORES-1 downto 0) :=
  (
     c_SLV_TIM_SUBSYS_ID  => f_sdb_auto_bridge(c_TIM_SUBSYS_BRIDGE_SDB, true)
  );

  signal clk_sys_125m                        : std_logic;

  signal pcb_rev_id                          : std_logic_vector(3 downto 0);

  -- FIXME: 5 downto 6
  signal irq_user                            : std_logic_vector(c_NUM_USER_IRQ+5 downto 6) := (others => '0');

  signal user_wb_in                          : t_wishbone_master_in_array(c_USER_NUM_CORES-1 downto 0);
  signal user_wb_out                         : t_wishbone_master_out_array(c_USER_NUM_CORES-1 downto 0);

  -----------------------------------------------------------------------------
  -- cmp_xtr_board_afc signals
  -----------------------------------------------------------------------------

  constant c_REF_CLOCK_INPUT                 : string := "EXT";

  -- DMTD constants
  constant c_CLK_SYS_FREQ                    : natural := 62500000; -- 62.5 MHz
  constant c_FREQ_MEAS_COUNTER_BITS          : natural := 28;
  constant c_DMTD_COUNTER_BITS               : natural := 14;

  -- Clocks and resets signals
  signal rst_sys_62m5_n                      : std_logic;
  signal rst_ref_125m_n                      : std_logic;
  signal rst_si57x_n                         : std_logic;

  -- System clocks
  signal clk_sys_62m5                        : std_logic;
  signal clk_ref_125m                        : std_logic;
  signal clk_si57x                           : std_logic;

  -- DMTD clocks
  signal clk_dmtd                            : std_logic;
  signal clk_dmtd_a                          : std_logic;
  signal clk_dmtd_b                          : std_logic;
  signal rst_dmtd_n                          : std_logic;
  signal rst_dmtd_a_n                        : std_logic;
  signal rst_dmtd_b_n                        : std_logic;

  -- DMTD signals
  signal dmtd_tag_a                          : std_logic_vector(c_DMTD_COUNTER_BITS-1 downto 0);
  signal dmtd_tag_a_p                        : std_logic;
  signal dmtd_tag_b                          : std_logic_vector(c_DMTD_COUNTER_BITS-1 downto 0);
  signal dmtd_tag_b_p                        : std_logic;
  signal dmtd_phase_raw                      : std_logic_vector(c_DMTD_COUNTER_BITS-1 downto 0);
  signal dmtd_phase_raw_p                    : std_logic;
  signal dmtd_phase_meas                     : std_logic_vector(31 downto 0);
  signal dmtd_phase_meas_p                   : std_logic;
  signal dmtd_freq_a                         : std_logic_vector(c_FREQ_MEAS_COUNTER_BITS-1 downto 0);
  signal dmtd_freq_a_valid                   : std_logic;
  signal dmtd_freq_b                         : std_logic_vector(c_FREQ_MEAS_COUNTER_BITS-1 downto 0);
  signal dmtd_freq_b_valid                   : std_logic;

  -----------------------------------------------------------------------------
  -- ILA signals
  -----------------------------------------------------------------------------

  signal probe0                              : std_logic_vector(63 downto 0);

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------

  component ila_4096_depth_64_width
    port (
      clk     : in std_logic;
      probe0  : in std_logic_vector(63 downto 0)
    );
  end component;

begin

  ----------------------------------------------------------------------
  --                        AFC Base Acq core                         --
  ----------------------------------------------------------------------

  cmp_afc_base_acq : afc_base_acq
    generic map (
      g_DIVCLK_DIVIDE               => c_DIVCLK_DIVIDE,
      g_CLKBOUT_MULT_F              => c_CLKBOUT_MULT_F,
      g_CLK0_DIVIDE_F               => c_CLK0_DIVIDE_F,
      g_CLK1_DIVIDE                 => c_CLK1_DIVIDE,
      g_SYS_CLOCK_FREQ              => c_SYS_CLOCK_FREQ,
      g_AFC_SI57x_I2C_FREQ          => c_AFC_SI57x_I2C_FREQ,
      g_AFC_SI57x_INIT_OSC          => c_AFC_SI57x_INIT_OSC,
      g_AFC_SI57x_INIT_RFREQ_VALUE  => c_AFC_SI57x_INIT_RFREQ_VALUE,
      g_AFC_SI57x_INIT_N1_VALUE     => c_AFC_SI57x_INIT_N1_VALUE,
      g_AFC_SI57x_INIT_HS_VALUE     => c_AFC_SI57x_INIT_HS_VALUE,
      g_WITH_VIC                    => false,
      g_WITH_UART_MASTER            => true,
      g_WITH_TRIGGER                => true,
      g_WITH_SPI                    => false,
      g_WITH_AFC_SI57x              => true,
      g_WITH_BOARD_I2C              => true,
      g_ACQ_NUM_CORES               => c_ACQ_NUM_CORES,
      g_TRIG_MUX_NUM_CORES          => c_TRIG_MUX_NUM_CORES,
      g_USER_NUM_CORES              => c_USER_NUM_CORES,
      g_ACQ_NUM_CHANNELS            => c_ACQ_NUM_CHANNELS,
      g_ACQ_MULTISHOT_RAM_SIZE      => c_ACQ_MULTISHOT_RAM_SIZE,
      g_ACQ_FIFO_FC_SIZE            => c_ACQ_FIFO_FC_SIZE,
      g_FACQ_CHANNELS               => c_FACQ_CHANNELS,
      g_TRIG_MUX_SYNC_EDGE          => c_TRIG_MUX_SYNC_EDGE,
      g_TRIG_MUX_INTERN_NUM         => c_TRIG_MUX_INTERN_NUM,
      g_TRIG_MUX_RCV_INTERN_NUM     => c_TRIG_MUX_RCV_INTERN_NUM,
      g_TRIG_MUX_OUT_RESOLVER       => c_TRIG_MUX_OUT_RESOLVER,
      g_TRIG_MUX_IN_RESOLVER        => c_TRIG_MUX_IN_RESOLVER,
      g_TRIG_MUX_WITH_INPUT_SYNC    => c_TRIG_MUX_WITH_INPUT_SYNC,
      g_TRIG_MUX_WITH_OUTPUT_SYNC   => c_TRIG_MUX_WITH_OUTPUT_SYNC,
      g_USER_SDB_RECORD_ARRAY       => c_USER_SDB_RECORD_ARRAY,
      g_WITH_AUX_CLK                => false,
      g_NUM_USER_IRQ                => c_NUM_USER_IRQ
    )
    port map (
      sys_clk_p_i                   => sys_clk_p_i,
      sys_clk_n_i                   => sys_clk_n_i,
      aux_clk_p_i                   => '0',
      aux_clk_n_i                   => '1',
      afc_fp2_clk1_p_i              => '0',
      afc_fp2_clk1_n_i              => '1',
      sys_rst_button_n_i            => sys_rst_button_n_i,
      uart_rxd_i                    => uart_rxd_i,
      uart_txd_o                    => uart_txd_o,
      trig_dir_o                    => trig_dir_o,
      trig_b                        => trig_b,
      diag_spi_cs_i                 => diag_spi_cs_i,
      diag_spi_si_i                 => diag_spi_si_i,
      diag_spi_so_o                 => diag_spi_so_o,
      diag_spi_clk_i                => diag_spi_clk_i,
      adn4604_vadj2_clk_updt_n_o    => adn4604_vadj2_clk_updt_n_o,
      afc_si57x_scl_b               => afc_si57x_scl_b,
      afc_si57x_sda_b               => afc_si57x_sda_b,
      afc_si57x_oe_o                => afc_si57x_oe_o,
      ddr3_dq_b                     => ddr3_dq_b,
      ddr3_dqs_p_b                  => ddr3_dqs_p_b,
      ddr3_dqs_n_b                  => ddr3_dqs_n_b,
      ddr3_addr_o                   => ddr3_addr_o,
      ddr3_ba_o                     => ddr3_ba_o,
      ddr3_cs_n_o                   => ddr3_cs_n_o,
      ddr3_ras_n_o                  => ddr3_ras_n_o,
      ddr3_cas_n_o                  => ddr3_cas_n_o,
      ddr3_we_n_o                   => ddr3_we_n_o,
      ddr3_reset_n_o                => ddr3_reset_n_o,
      ddr3_ck_p_o                   => ddr3_ck_p_o,
      ddr3_ck_n_o                   => ddr3_ck_n_o,
      ddr3_cke_o                    => ddr3_cke_o,
      ddr3_dm_o                     => ddr3_dm_o,
      ddr3_odt_o                    => ddr3_odt_o,
      pci_exp_rxp_i                 => pci_exp_rxp_i,
      pci_exp_rxn_i                 => pci_exp_rxn_i,
      pci_exp_txp_o                 => pci_exp_txp_o,
      pci_exp_txn_o                 => pci_exp_txn_o,
      pcie_clk_p_i                  => pcie_clk_p_i,
      pcie_clk_n_i                  => pcie_clk_n_i,
      leds_o                        => leds_o,
      board_i2c_scl_b               => open,
      board_i2c_sda_b               => open,
      spi_sclk_o                    => open,
      spi_cs_n_o                    => open,
      spi_mosi_o                    => open,
      spi_miso_i                    => '0',
      pcb_rev_id_i                  => pcb_rev_id,
      clk_sys_o                     => clk_sys_125m,
      rst_sys_n_o                   => open,
      clk_aux_o                     => open,
      rst_aux_n_o                   => open,
      clk_aux_raw_o                 => open,
      rst_aux_raw_n_o               => open,
      clk_200mhz_o                  => open,
      rst_200mhz_n_o                => open,
      clk_pcie_o                    => open,
      rst_pcie_n_o                  => open,
      clk_user2_o                   => open,
      rst_user2_n_o                 => open,
      clk_user3_o                   => open,
      rst_user3_n_o                 => open,
      clk_trig_ref_o                => open,
      rst_trig_ref_n_o              => open,
      clk_fp2_clk1_p_o              => open,
      clk_fp2_clk1_n_o              => open,
      irq_user_i                    => irq_user,
      fs_clk_array_i                => fs_clk_array,
      fs_ce_array_i                 => fs_ce_array,
      fs_rst_n_array_i              => fs_rst_n_array,
      acq_chan_array_i              => acq_chan_array,
      trig_rcv_intern_i             => trig_rcv_intern,
      trig_pulse_transm_i           => trig_pulse_transm,
      trig_pulse_rcv_o              => trig_pulse_rcv,
      trig_dbg_o                    => open,
      trig_dbg_data_sync_o          => open,
      trig_dbg_data_degliteched_o   => open,
      afc_si57x_ext_wr_i            => afc_si57x_ext_wr,
      afc_si57x_ext_rfreq_value_i   => afc_si57x_ext_rfreq_value,
      afc_si57x_ext_n1_value_i      => afc_si57x_ext_n1_value,
      afc_si57x_ext_hs_value_i      => afc_si57x_ext_hs_value,
      afc_si57x_sta_reconfig_done_o => afc_si57x_sta_reconfig_done,
      afc_si57x_oe_i                => '1',
      afc_si57x_addr_i              => "10101010",
      user_wb_o                     => user_wb_out,
      user_wb_i                     => user_wb_in
    );  -- cmp_afc_base_acq

  pcb_rev_id <= (others => '0');

  ----------------------------------------------------------------------
  --                       Timing Receiver core                       --
  ----------------------------------------------------------------------

  cmp_xtr_board_afc : xtr_board_afc
    generic map (
      g_INTERFACE_MODE          => PIPELINED,
      g_ADDRESS_GRANULARITY     => BYTE,
      g_REF_CLOCK_INPUT         => c_REF_CLOCK_INPUT,
      g_CLK_SYS_FREQ            => c_CLK_SYS_FREQ,
      g_FREQ_MEAS_COUNTER_BITS  => c_FREQ_MEAS_COUNTER_BITS,
      g_DMTD_COUNTER_BITS       => c_DMTD_COUNTER_BITS,
      g_SIMULATION              => 0
    )
    port map (
      areset_n_i                => sys_rst_button_n_i,
      areset_edge_n_i           => '1',
      clk_125m_i                => clk_sys_125m,
      clk_20m_vcxo_p_i          => clk_20m_vcxo_p_i,
      clk_20m_vcxo_n_i          => clk_20m_vcxo_n_i,
      clk_si57x_p_i             => clk_afc_si57x_p_i,
      clk_si57x_n_i             => clk_afc_si57x_n_i,
      clk_125m_gtp_p_i          => '0',
      clk_125m_gtp_n_i          => '1',
      clk_ext_ref_p_i           => fmc1_clk1_m2c_p_i,
      clk_ext_ref_n_i           => fmc1_clk1_m2c_n_i,
      clk_sys_62m5_o            => clk_sys_62m5,
      clk_ref_125m_o            => clk_ref_125m,
      clk_200m_o                => open,
      clk_dmtd_o                => clk_dmtd,
      clk_si57x_o               => clk_si57x,
      rst_sys_62m5_n_o          => rst_sys_62m5_n,
      rst_62m5_pcie_n_o         => open,
      rst_ref_125m_n_o          => rst_ref_125m_n,
      rst_200m_n_o              => open,
      rst_dmtd_n_o              => rst_dmtd_n,
      rst_si57x_n_o             => rst_si57x_n,
      sfp_txp_o                 => open,
      sfp_txn_o                 => open,
      sfp_rxp_i                 => '0',
      sfp_rxn_i                 => '0',
      sfp_det_i                 => '1',
      sfp_sda_i                 => '0',
      sfp_sda_o                 => open,
      sfp_scl_i                 => '0',
      sfp_scl_o                 => open,
      sfp_rate_select_o         => open,
      sfp_tx_fault_i            => '0',
      sfp_tx_disable_o          => open,
      sfp_los_i                 => '0',
      wb_slv_i                  => user_wb_out(c_SLV_TIM_SUBSYS_ID),
      wb_slv_o                  => user_wb_in(c_SLV_TIM_SUBSYS_ID),
      tag_a_o                   => dmtd_tag_a,
      tag_a_p_o                 => dmtd_tag_a_p,
      tag_b_o                   => dmtd_tag_b,
      tag_b_p_o                 => dmtd_tag_b_p,
      phase_raw_o               => dmtd_phase_raw,
      phase_raw_p_o             => dmtd_phase_raw_p,
      phase_meas_o              => dmtd_phase_meas,
      phase_meas_p_o            => dmtd_phase_meas_p,
      freq_dmtd_a_o             => dmtd_freq_a,
      freq_dmtd_a_valid_o       => dmtd_freq_a_valid,
      freq_dmtd_b_o             => dmtd_freq_b,
      freq_dmtd_b_valid_o       => dmtd_freq_b_valid,
      led_act_o                 => open,
      led_link_o                => open,
      btn1_i                    => '1',
      btn2_i                    => '1',
      link_ok_o                 => open
    ); -- cmp_xtr_board_afc

  clk_dmtd_a                                <= clk_ref_125m;
  clk_dmtd_b                                <= clk_si57x;
  rst_dmtd_a_n                              <= rst_ref_125m_n;
  rst_dmtd_b_n                              <= rst_si57x_n;

  ----------------------------------------------------------------------
  --                           Acquisition                            --
  ----------------------------------------------------------------------

  fs_clk_array   <= (others => clk_sys_62m5);
  fs_ce_array    <= (others => '1');
  fs_rst_n_array <= (others => rst_sys_62m5_n);

  --------------------
  -- DMTD 1 data, Phase Raw
  --------------------
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_PHASE_RAW_ID).val(to_integer(c_FACQ_CHANNELS(c_ACQ_PHASE_RAW_ID).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dmtd_phase_raw), 64));
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_PHASE_RAW_ID).dvalid  <= dmtd_phase_raw_p;
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_PHASE_RAW_ID).trig    <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_ACQ_PHASE_RAW_ID).pulse;

  --------------------
  -- DMTD 1 data, Phase Meas
  --------------------
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_PHASE_MEAS_ID).val(to_integer(c_FACQ_CHANNELS(c_ACQ_PHASE_MEAS_ID).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dmtd_phase_meas), 64));
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_PHASE_MEAS_ID).dvalid <= dmtd_phase_meas_p;
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_PHASE_MEAS_ID).trig   <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_ACQ_PHASE_MEAS_ID).pulse;

  --------------------
  -- DMTD 1 data, Freq Meas
  --------------------
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_FREQ_MEAS_ID).val(to_integer(c_FACQ_CHANNELS(c_ACQ_FREQ_MEAS_ID).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dmtd_freq_a), 64));
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_FREQ_MEAS_ID).dvalid  <= dmtd_freq_a_valid;
  acq_chan_array(c_ACQ_CORE_0_ID, c_ACQ_FREQ_MEAS_ID).trig    <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_ACQ_FREQ_MEAS_ID).pulse;

  -- FIXME: For now, this acquisition core is the same as the other, but
  -- it's placed here so can use another FMC and use this core for it.
  --------------------
  -- DMTD 2 data, Phase Raw
  --------------------
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_PHASE_RAW_ID).val(to_integer(c_FACQ_CHANNELS(c_ACQ_PHASE_RAW_ID).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dmtd_phase_raw), 64));
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_PHASE_RAW_ID).dvalid  <= dmtd_phase_raw_p;
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_PHASE_RAW_ID).trig    <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_ACQ_PHASE_RAW_ID).pulse;

  --------------------
  -- DMTD 2 data, Phase Meas
  --------------------
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_PHASE_MEAS_ID).val(to_integer(c_FACQ_CHANNELS(c_ACQ_PHASE_MEAS_ID).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dmtd_phase_meas), 64));
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_PHASE_MEAS_ID).dvalid <= dmtd_phase_meas_p;
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_PHASE_MEAS_ID).trig   <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_ACQ_PHASE_MEAS_ID).pulse;

  --------------------
  -- DMTD 2 data, Freq Meas
  --------------------
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_FREQ_MEAS_ID).val(to_integer(c_FACQ_CHANNELS(c_ACQ_FREQ_MEAS_ID).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dmtd_freq_b), 64));
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_FREQ_MEAS_ID).dvalid  <= dmtd_freq_b_valid;
  acq_chan_array(c_ACQ_CORE_1_ID, c_ACQ_FREQ_MEAS_ID).trig    <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_ACQ_FREQ_MEAS_ID).pulse;

  ----------------------------------------------------------------------
  --                             Trigger                              --
  ----------------------------------------------------------------------

  -- Assign FMCs trigger pulses to trigger channel interfaces
  trig_fmc1_channel_1.pulse <= '0';
  trig_fmc1_channel_2.pulse <= '0';

  trig_fmc2_channel_1.pulse <= '0';
  trig_fmc2_channel_2.pulse <= '0';

  -- Assign intern triggers to trigger module
  trig_rcv_intern(c_TRIG_MUX_0_ID, c_TRIG_RCV_INTERN_CHAN_0_ID) <= trig_fmc1_channel_1;
  trig_rcv_intern(c_TRIG_MUX_0_ID, c_TRIG_RCV_INTERN_CHAN_1_ID) <= trig_fmc1_channel_2;
  trig_rcv_intern(c_TRIG_MUX_1_ID, c_TRIG_RCV_INTERN_CHAN_0_ID) <= trig_fmc2_channel_1;
  trig_rcv_intern(c_TRIG_MUX_1_ID, c_TRIG_RCV_INTERN_CHAN_1_ID) <= trig_fmc2_channel_2;

  ----------------------------------------------------------------------
  --                            Analyser                              --
  ----------------------------------------------------------------------

  cmp_vivado_ila : ila_4096_depth_64_width
  port map (
  	clk    => clk_sys_62m5,
  	probe0 => probe0
  );

  probe0(13 downto 0)   <= dmtd_phase_raw;
  probe0(15 downto 14)  <= (others => '0');
  probe0(16)            <= dmtd_phase_raw_p;
  probe0(17)            <= '0';
  probe0(31 downto 18)  <= dmtd_phase_meas(13 downto 0);
  probe0(32)            <= dmtd_phase_meas_p;
  probe0(46 downto 33)  <= dmtd_tag_a;
  probe0(47)            <= dmtd_tag_a_p;
  probe0(61 downto 48)  <= dmtd_tag_b;
  probe0(62)            <= dmtd_tag_b_p;
  probe0(63)            <= '0';

end rtl;
