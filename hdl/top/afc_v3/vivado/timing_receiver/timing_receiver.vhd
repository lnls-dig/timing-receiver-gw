------------------------------------------------------------------------------
-- Title      : Top design for a simple DDMTD test with PCIe and Acqusition modules
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
-- Date        Version  Author          Description
-- 2017-08-03  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Memory core generator
use work.gencores_pkg.all;
-- Custom Wishbone Modules
use work.ifc_wishbone_pkg.all;
-- Custom common cores
use work.ifc_common_pkg.all;
-- Wishbone stream modules and interface
use work.wb_stream_generic_pkg.all;
-- Genrams
use work.genram_pkg.all;
-- Data Acquisition core
use work.acq_core_pkg.all;
-- IP cores constants
use work.ipcores_pkg.all;
-- Trigger package
use work.trigger_pkg.all;
-- Timing Receiver Modules
use work.tim_rcv_pkg.all;
-- Meta Package
use work.synthesis_descriptor_pkg.all;
-- AXI cores
use work.pcie_cntr_axi_pkg.all;
-- Xilinx package
use work.tr_xilinx_pkg.all;
-- AFC package
use work.tr_afc_pkg.all;
-- TR Common package
use work.xtr_board_pkg.all;

entity timing_receiver is
port(
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

  rs232_txd_o                                : out std_logic;
  rs232_rxd_i                                : in std_logic;

  -----------------------------------------
  -- Trigger pins
  -----------------------------------------

  trig_dir_o                                 : out   std_logic_vector(7 downto 0);
  trig_b                                     : inout std_logic_vector(7 downto 0);

  -----------------------------
  -- AFC Diagnostics
  -----------------------------

  diag_spi_cs_i                              : in std_logic;
  diag_spi_si_i                              : in std_logic;
  diag_spi_so_o                              : out std_logic;
  diag_spi_clk_i                             : in std_logic;

  -----------------------------
  -- ADN4604ASVZ
  -----------------------------
  adn4604_vadj2_clk_updt_n_o                 : out std_logic;

  -----------------------------
  -- FMC1 XM105 Breakout Board ports
  -----------------------------
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

  -----------------------------
  -- FMC2 XM105 Breakout Board ports
  -----------------------------
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
  ddr3_dq_b                                 : inout std_logic_vector(c_ddr_dq_width-1 downto 0);
  ddr3_dqs_p_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
  ddr3_dqs_n_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
  ddr3_addr_o                               : out   std_logic_vector(c_ddr_row_width-1 downto 0);
  ddr3_ba_o                                 : out   std_logic_vector(c_ddr_bank_width-1 downto 0);
  ddr3_cs_n_o                               : out   std_logic_vector(0 downto 0);
  ddr3_ras_n_o                              : out   std_logic;
  ddr3_cas_n_o                              : out   std_logic;
  ddr3_we_n_o                               : out   std_logic;
  ddr3_reset_n_o                            : out   std_logic;
  ddr3_ck_p_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
  ddr3_ck_n_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
  ddr3_cke_o                                : out   std_logic_vector(c_ddr_cke_width-1 downto 0);
  ddr3_dm_o                                 : out   std_logic_vector(c_ddr_dm_width-1 downto 0);
  ddr3_odt_o                                : out   std_logic_vector(c_ddr_odt_width-1 downto 0);

  -- PCIe transceivers
  pci_exp_rxp_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_rxn_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_txp_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_txn_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);

  -- PCI clock and reset signals
  pcie_clk_p_i                              : in std_logic;
  pcie_clk_n_i                              : in std_logic;

  -- General board LEDs
  leds_o                                    : out std_logic_vector(2 downto 0)
);
end timing_receiver;

architecture rtl of timing_receiver is

  -- Top crossbar layout
  -- Number of slaves
  constant c_slaves                         : natural := 9;
  -- Acq_Core 1, Acq_Core 2,
  -- TRIG Iface, TRIG MUX 1, TRIG MUX 2,
  -- AFC MGMT,
  -- Peripherals, AFC diagnostics,
  -- Repo URL, SDB synthesis top, general-cores, infra-cores, wr-cores

  -- Slaves indexes
  constant c_slv_acq_core_0_id              : natural := 0;
  constant c_slv_acq_core_1_id              : natural := 1;
  constant c_slv_periph_id                  : natural := 2;
  constant c_slv_afc_diag_id                : natural := 3;
  constant c_slv_trig_iface_id              : natural := 4;
  constant c_slv_trig_mux_0_id              : natural := 5;
  constant c_slv_trig_mux_1_id              : natural := 6;
  constant c_slv_tim_subsys_id              : natural := 7;
  constant c_slv_afc_mgmt_id                : natural := 8;

  -- Not accounted iun the number of slaves as these are special
  constant c_slv_sdb_repo_url_id            : natural := 9;
  constant c_slv_sdb_top_syn_id             : natural := 10;
  constant c_slv_sdb_gen_cores_id           : natural := 11;
  constant c_slv_sdb_infra_cores_id         : natural := 12;
  constant c_slv_sdb_wr_cores_id            : natural := 13;

  -- Number of masters
  constant c_masters                        : natural := 2;            -- RS232-Syscon, PCIe

  -- Master indexes
  constant c_ma_pcie_id                     : natural := 0;
  constant c_ma_rs232_syscon_id             : natural := 1;

  constant c_acq_fifo_size                  : natural := 1024;

  constant c_acq_addr_width                 : natural := c_ddr_addr_width;
  constant c_acq_ddr_addr_res_width         : natural := 32;
  constant c_acq_ddr_addr_diff              : natural := c_acq_ddr_addr_res_width-c_ddr_addr_width;

  -- Acquisition core channel indexes
  constant c_acq_phase_raw_id               : natural := 0;
  constant c_acq_phase_meas_id              : natural := 1;
  constant c_acq_freq_id                    : natural := 2;

  -- DDR3 Width
  constant c_acq_pos_ddr3_width             : natural := 32;

  -- Number of acquisition cores (FMC1, FMC2)
  constant c_acq_num_cores                  : natural := 2;
  -- Type of DDR3 core interface
  constant c_ddr_interface_type             : string := "AXIS";

  -- Acquisition core IDs
  constant c_acq_core_0_id                  : natural := 0;
  constant c_acq_core_1_id                  : natural := 1;

  -- Number of channels per acquisition core
  constant c_acq_num_channels               : natural := 3; -- Phase raw / Phase meas / Freq meas
  constant c_acq_width_u64                  : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(64, c_acq_chan_cmplt_width_log2);
  constant c_acq_width_u128                 : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(128, c_acq_chan_cmplt_width_log2);
  constant c_acq_width_u256                 : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(256, c_acq_chan_cmplt_width_log2);
  constant c_acq_num_atoms_u1               : unsigned(c_acq_num_atoms_width_log2-1 downto 0) :=
                                                to_unsigned(1, c_acq_num_atoms_width_log2);
  constant c_acq_num_atoms_u2               : unsigned(c_acq_num_atoms_width_log2-1 downto 0) :=
                                                to_unsigned(2, c_acq_num_atoms_width_log2);
  constant c_acq_num_atoms_u4               : unsigned(c_acq_num_atoms_width_log2-1 downto 0) :=
                                                to_unsigned(4, c_acq_num_atoms_width_log2);
  constant c_acq_num_atoms_u8               : unsigned(c_acq_num_atoms_width_log2-1 downto 0) :=
                                                to_unsigned(8, c_acq_num_atoms_width_log2);
  constant c_acq_atom_width_u16              : unsigned(c_acq_atom_width_log2-1 downto 0) :=
                                                to_unsigned(16, c_acq_atom_width_log2);
  constant c_acq_atom_width_u32             : unsigned(c_acq_atom_width_log2-1 downto 0) :=
                                                to_unsigned(32, c_acq_atom_width_log2);
  constant c_acq_atom_width_u64             : unsigned(c_acq_atom_width_log2-1 downto 0) :=
                                                to_unsigned(64, c_acq_atom_width_log2);
  constant c_acq_atom_width_u128            : unsigned(c_acq_atom_width_log2-1 downto 0) :=
                                                to_unsigned(128, c_acq_atom_width_log2);

  constant c_facq_channels                  : t_facq_chan_param_array(c_acq_num_channels-1 downto 0) :=
  (
    c_acq_phase_raw_id    => (width => c_acq_width_u64, num_atoms => c_acq_num_atoms_u2, atom_width => c_acq_atom_width_u32),
    c_acq_phase_meas_id   => (width => c_acq_width_u64, num_atoms => c_acq_num_atoms_u2, atom_width => c_acq_atom_width_u32),
    c_acq_freq_id         => (width => c_acq_width_u64, num_atoms => c_acq_num_atoms_u2, atom_width => c_acq_atom_width_u32)
  );

  -- Trigger
  constant c_trig_sync_edge                 : string   := "positive";
  constant c_trig_trig_num                  : positive := 8; -- 8 MLVDS triggers
  constant c_trig_intern_num                : positive := 3; -- 2 (Phase raw / Phase meas / Freq meas)
  constant c_trig_rcv_intern_num            : positive := 2; -- 2 Extra internal triggers
  constant c_trig_num_mux_interfaces        : natural  := c_acq_num_cores;
  constant c_trig_out_resolver              : string := "fanout";
  constant c_trig_in_resolver               : string := "or";
  constant c_trig_with_input_sync           : boolean := true;
  constant c_trig_with_output_sync          : boolean := true;

  -- Trigger RCV intern IDs
  constant c_trig_rcv_intern_chan_1_id      : natural := 0; -- Internal Channel 1
  constant c_trig_rcv_intern_chan_2_id      : natural := 1; -- Internal Channel 2

  -- Trigger core IDs
  constant c_trig_mux_0_id                  : natural := 0;
  constant c_trig_mux_1_id                  : natural := 1;

  -- GPIO num pinscalc
  constant c_leds_num_pins                  : natural := 3;
  constant c_with_leds_heartbeat            : t_boolean_array(c_leds_num_pins-1 downto 0) :=
                                                (2 => false,  -- Red LED
                                                 1 => true,   -- Green LED
                                                 0 => false); -- Blue LED
  constant c_buttons_num_pins               : natural := 8;

  -- Counter width. It willl count up to 2^32 clock cycles
  constant c_counter_width                  : natural := 32;

  -- TICs counter period. 100MHz clock -> msec granularity
  constant c_tics_cntr_period               : natural := 100000;

  -- Number of reset clock cycles (FF)
  constant c_button_rst_width               : natural := 255;

  -- DMTD constants
  constant c_clk_sys_freq                   : natural := 62500000;
  constant c_dmtd_freq_meas_counter_bits    : natural := 28;
  constant c_dmtd_counter_bits              : natural := 14;

  -- General peripherals layout. UART, LEDs (GPIO), Buttons (GPIO) and Tics counter
  constant c_periph_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000400");

  -- AFC MGMT
  constant c_afc_mgmt_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000400");

  -- Timing Subsystem
  constant c_tim_subsys_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"0000FFFF", x"00006000");

  -- WB SDB (Self describing bus) layout
  constant c_layout : t_sdb_record_array(c_slaves+5-1 downto 0) :=
  (
     c_slv_acq_core_0_id       => f_sdb_embed_device(c_xwb_acq_core_sdb,         x"00330000"),   -- Data Acquisition control port
     c_slv_acq_core_1_id       => f_sdb_embed_device(c_xwb_acq_core_sdb,         x"00360000"),   -- Data Acquisition control port
     c_slv_periph_id           => f_sdb_embed_bridge(c_periph_bridge_sdb,        x"00370000"),   -- General peripherals control port
     c_slv_afc_diag_id         => f_sdb_embed_device(c_xwb_afc_diag_sdb,         x"00380000"),   -- AFC Diagnostics control port
     c_slv_trig_iface_id       => f_sdb_embed_device(c_xwb_trigger_iface_sdb,    x"00390000"),   -- Trigger Interface port
     c_slv_trig_mux_0_id       => f_sdb_embed_device(c_xwb_trigger_mux_sdb,      x"00400000"),   -- Trigger Mux 1 port
     c_slv_trig_mux_1_id       => f_sdb_embed_device(c_xwb_trigger_mux_sdb,      x"00410000"),   -- Trigger Mux 2 port
     c_slv_tim_subsys_id     => f_sdb_embed_bridge(c_tim_subsys_bridge_sdb,
                                                                                 x"00420000"),   -- Timing Receiver port
     c_slv_afc_mgmt_id         => f_sdb_embed_bridge(c_afc_mgmt_bridge_sdb,
                                                                                 x"00430000"),   -- AFC MGMT
     c_slv_sdb_repo_url_id     => f_sdb_embed_repo_url(c_sdb_repo_url),
     c_slv_sdb_top_syn_id      => f_sdb_embed_synthesis(c_sdb_top_syn_info),
     c_slv_sdb_gen_cores_id    => f_sdb_embed_synthesis(c_sdb_general_cores_syn_info),
     c_slv_sdb_infra_cores_id  => f_sdb_embed_synthesis(c_sdb_infra_cores_syn_info),
     c_slv_sdb_wr_cores_id     => f_sdb_embed_synthesis(c_sdb_wr_cores_syn_info)
  );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well
  constant c_sdb_address                    : t_wishbone_address := x"00000000";

  -- Crossbar master/slave arrays
  signal cbar_slave_i                       : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_o                       : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_i                      : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_o                      : t_wishbone_master_out_array(c_slaves-1 downto 0);
  signal acq_core_slave_i                   : t_wishbone_slave_in_array (c_acq_num_cores-1 downto 0);
  signal acq_core_slave_o                   : t_wishbone_slave_out_array(c_acq_num_cores-1 downto 0);

  -- PCIe signals
  signal wb_ma_pcie_rst                     : std_logic;
  signal wb_ma_pcie_rstn                    : std_logic;

  -- PCIe Debug signals
  signal dbg_app_addr                       : std_logic_vector(31 downto 0);
  signal dbg_app_cmd                        : std_logic_vector(2 downto 0);
  signal dbg_app_en                         : std_logic;
  signal dbg_app_wdf_data                   : std_logic_vector(c_ddr_payload_width-1 downto 0);
  signal dbg_app_wdf_end                    : std_logic;
  signal dbg_app_wdf_wren                   : std_logic;
  signal dbg_app_wdf_mask                   : std_logic_vector(c_ddr_payload_width/8-1 downto 0);
  signal dbg_app_rd_data                    : std_logic_vector(c_ddr_payload_width-1 downto 0);
  signal dbg_app_rd_data_end                : std_logic;
  signal dbg_app_rd_data_valid              : std_logic;
  signal dbg_app_rdy                        : std_logic;
  signal dbg_app_wdf_rdy                    : std_logic;
  signal dbg_ddr_ui_clk                     : std_logic;
  signal dbg_ddr_ui_reset                   : std_logic;

  -- To/From Acquisition Core
  signal acq_chan_array                     : t_facq_chan_array2d(c_acq_num_cores-1 downto 0, c_acq_num_channels-1 downto 0);

  signal ddr_aximm_clk                      : std_logic;
  signal ddr_aximm_rstn                     : std_logic;
  signal ddr_aximm_r_ma_in                  : t_aximm_r_master_in;
  signal ddr_aximm_r_ma_out                 : t_aximm_r_master_out;
  signal ddr_aximm_w_ma_in                  : t_aximm_w_master_in;
  signal ddr_aximm_w_ma_out                 : t_aximm_w_master_out;

  signal dbg_ddr_rb_data                    : std_logic_vector(c_ddr_payload_width-1 downto 0);
  signal dbg_ddr_rb_addr                    : std_logic_vector(c_acq_addr_width-1 downto 0);
  signal dbg_ddr_rb_valid                   : std_logic;

  -- Clocks and resets signals
  signal rst_sys_pcie_n                     : std_logic;
  signal rst_sys_n                          : std_logic;
  signal rst_sys                            : std_logic;
  signal rst_ref_125m_n                     : std_logic;
  signal rst_200m_n                         : std_logic;
  signal rst_si57x_n                        : std_logic;
  signal rst_si57x                          : std_logic;

  signal rs232_rstn                         : std_logic;

  -- System clocks
  signal clk_sys                            : std_logic;
  signal clk_ref_125m                       : std_logic;
  signal clk_si57x                          : std_logic;
  signal clk_200m                           : std_logic;

  -- DMTD clocks
  signal clk_dmtd                           : std_logic;
  signal clk_dmtd_a                         : std_logic;
  signal clk_dmtd_b                         : std_logic;
  signal rst_dmtd_n                         : std_logic;
  signal rst_dmtd_a_n                       : std_logic;
  signal rst_dmtd_b_n                       : std_logic;

  -- FS clocks
  signal fs_clk_array                       : std_logic_vector(c_acq_num_cores-1 downto 0);
  signal fs_rst_n_array                     : std_logic_vector(c_acq_num_cores-1 downto 0);
  signal fs_ce_array                        : std_logic_vector(c_acq_num_cores-1 downto 0);

  -- Trigger
  signal trig_core_slave_i                  : t_wishbone_slave_in_array (c_trig_num_mux_interfaces-1 downto 0);
  signal trig_core_slave_o                  : t_wishbone_slave_out_array(c_trig_num_mux_interfaces-1 downto 0);
  signal trig_ref_clk                       : std_logic;
  signal trig_ref_rst_n                     : std_logic;

  signal trig_rcv_intern                    : t_trig_channel_array2d(c_trig_num_mux_interfaces-1 downto 0, c_trig_rcv_intern_num-1 downto 0);
  signal trig_pulse_transm                  : t_trig_channel_array2d(c_trig_num_mux_interfaces-1 downto 0, c_trig_intern_num-1 downto 0);
  signal trig_pulse_rcv                     : t_trig_channel_array2d(c_trig_num_mux_interfaces-1 downto 0, c_trig_intern_num-1 downto 0);

  signal trig_fmc1_channel_1                : t_trig_channel;
  signal trig_fmc1_channel_2                : t_trig_channel;
  signal trig_fmc2_channel_1                : t_trig_channel;
  signal trig_fmc2_channel_2                : t_trig_channel;

  signal trig_dir_int                       : std_logic_vector(7 downto 0);
  signal trig_dbg                           : std_logic_vector(7 downto 0);

  -- GPIO LED signals
  signal gpio_slave_led_o                   : t_wishbone_slave_out;
  signal gpio_slave_led_i                   : t_wishbone_slave_in;
  signal gpio_leds_out_int                  : std_logic_vector(c_leds_num_pins-1 downto 0);
  signal heartbeat_dmtd_leds_out_int        : std_logic_vector(c_leds_num_pins-1 downto 0);
  signal heartbeat_dmtd_led_int             : std_logic;
  signal heartbeat_dmtd_b_leds_out_int      : std_logic_vector(c_leds_num_pins-1 downto 0);
  signal heartbeat_dmtd_b_led_int           : std_logic;
  signal gpio_leds_in_int                   : std_logic_vector(c_leds_num_pins-1 downto 0) := (others => '0');

  signal buttons_dummy                      : std_logic_vector(7 downto 0) := (others => '0');

  -- GPIO Button signals
  signal gpio_slave_button_o                : t_wishbone_slave_out;
  signal gpio_slave_button_i                : t_wishbone_slave_in;

  -- AFC diagnostics signals
  signal dbg_spi_clk                        : std_logic;
  signal dbg_spi_valid                      : std_logic;
  signal dbg_en                             : std_logic;
  signal dbg_addr                           : std_logic_vector(7 downto 0);
  signal dbg_serial_data                    : std_logic_vector(31 downto 0);
  signal dbg_spi_data                       : std_logic_vector(31 downto 0);

  -- DMTD signals
  signal dmtd_tag_a                         : std_logic_vector(c_dmtd_counter_bits-1 downto 0);
  signal dmtd_tag_a_valid                   : std_logic;
  signal dmtd_tag_b                         : std_logic_vector(c_dmtd_counter_bits-1 downto 0);
  signal dmtd_tag_b_valid                   : std_logic;
  signal dmtd_phase_raw                     : std_logic_vector(c_dmtd_counter_bits-1 downto 0);
  signal dmtd_phase_raw_valid               : std_logic;
  signal dmtd_phase_meas                    : std_logic_vector(31 downto 0);
  signal dmtd_phase_meas_valid              : std_logic;
  signal dmtd_freq_a                        : std_logic_vector(c_dmtd_freq_meas_counter_bits-1 downto 0);
  signal dmtd_freq_a_valid                  : std_logic;
  signal dmtd_freq_b                        : std_logic_vector(c_dmtd_freq_meas_counter_bits-1 downto 0);
  signal dmtd_freq_b_valid                  : std_logic;


  -- Chipscope control signals
  signal CONTROL0                           : std_logic_vector(35 downto 0);
  signal CONTROL1                           : std_logic_vector(35 downto 0);
  signal CONTROL2                           : std_logic_vector(35 downto 0);
  signal CONTROL3                           : std_logic_vector(35 downto 0);
  signal CONTROL4                           : std_logic_vector(35 downto 0);

  -- Chipscope ILA 0 signals
  signal TRIG_ILA0_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 1 signals
  signal TRIG_ILA1_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 2 signals
  signal TRIG_ILA2_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 3 signals
  signal TRIG_ILA3_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 4 signals
  signal TRIG_ILA4_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_3                        : std_logic_vector(31 downto 0);

  signal trig_ila0_probe                    : std_logic_vector(63 downto 0);
  signal trig_vio0_probe                    : std_logic_vector(63 downto 0);

  ---------------------------
  --      Components       --
  ---------------------------

  component ila_4096_depth_64_width
  port (
    clk                                     : in std_logic;
    probe0                                  : in std_logic_vector(63 downto 0)
  );
  end component;

  component vio_64_width
  port (
    clk                                     : in std_logic;
    probe_out0                              : out std_logic_vector(63 downto 0)
  );
  end component;

  -- Xilinx Chipscope Controller
  component chipscope_icon_1_port
  port (
    CONTROL0                                : inout std_logic_vector(35 downto 0)
  );
  end component;

  component chipscope_icon_4_port
  port (
    CONTROL0                                : inout std_logic_vector(35 downto 0);
    CONTROL1                                : inout std_logic_vector(35 downto 0);
    CONTROL2                                : inout std_logic_vector(35 downto 0);
    CONTROL3                                : inout std_logic_vector(35 downto 0)
  );
  end component;

  component chipscope_ila
  port (
    control                                 : inout std_logic_vector(35 downto 0);
    clk                                     : in std_logic;
    trig0                                   : in std_logic_vector(31 downto 0);
    trig1                                   : in std_logic_vector(31 downto 0);
    trig2                                   : in std_logic_vector(31 downto 0);
    trig3                                   : in std_logic_vector(31 downto 0)
  );
  end component;

begin

  ----------------------------------------------------------------------
  --                        Wishbone Modules                          --
  ----------------------------------------------------------------------

  -- The top-most Wishbone B.4 crossbar
  cmp_interconnect : xwb_sdb_crossbar
  generic map(
    g_num_masters                           => c_masters,
    g_num_slaves                            => c_slaves,
    g_registered                            => true,
    g_wraparound                            => true, -- Should be true for nested buses
    g_layout                                => c_layout,
    g_sdb_addr                              => c_sdb_address
  )
  port map(
    clk_sys_i                               => clk_sys,
    rst_n_i                                 => rst_sys_n,
    -- Master connections (INTERCON is a slave)
    slave_i                                 => cbar_slave_i,
    slave_o                                 => cbar_slave_o,
    -- Slave connections (INTERCON is a master)
    master_i                                => cbar_master_i,
    master_o                                => cbar_master_o
  );

  ----------------------------------------------------------------------
  --                            PCIe Core                             --
  ----------------------------------------------------------------------

  cmp_xwb_pcie_cntr : xwb_pcie_cntr
  generic map (
    g_ma_interface_mode                       => PIPELINED,
    g_ma_address_granularity                  => BYTE,
    g_simulation                              => "FALSE"
  )
  port map (
    -- DDR3 memory pins
    ddr3_dq_b                                 => ddr3_dq_b,
    ddr3_dqs_p_b                              => ddr3_dqs_p_b,
    ddr3_dqs_n_b                              => ddr3_dqs_n_b,
    ddr3_addr_o                               => ddr3_addr_o,
    ddr3_ba_o                                 => ddr3_ba_o,
    ddr3_cs_n_o                               => ddr3_cs_n_o,
    ddr3_ras_n_o                              => ddr3_ras_n_o,
    ddr3_cas_n_o                              => ddr3_cas_n_o,
    ddr3_we_n_o                               => ddr3_we_n_o,
    ddr3_reset_n_o                            => ddr3_reset_n_o,
    ddr3_ck_p_o                               => ddr3_ck_p_o,
    ddr3_ck_n_o                               => ddr3_ck_n_o,
    ddr3_cke_o                                => ddr3_cke_o,
    ddr3_dm_o                                 => ddr3_dm_o,
    ddr3_odt_o                                => ddr3_odt_o,

    -- PCIe transceivers
    pci_exp_rxp_i                             => pci_exp_rxp_i,
    pci_exp_rxn_i                             => pci_exp_rxn_i,
    pci_exp_txp_o                             => pci_exp_txp_o,
    pci_exp_txn_o                             => pci_exp_txn_o,

    -- Necessity signals
    ddr_clk_i                                 => clk_200m,   --200 MHz DDR core clock (connect through BUFG or PLL)
    ddr_rst_i                                 => rst_sys,
    pcie_clk_p_i                              => pcie_clk_p_i, --100 MHz PCIe Clock (connect directly to input pin)
    pcie_clk_n_i                              => pcie_clk_n_i, --100 MHz PCIe Clock
    pcie_rst_n_i                              => rst_sys_pcie_n, -- PCIe core reset

    -- DDR memory controller interface --
    ddr_aximm_sl_aclk_o                       => ddr_aximm_clk,
    ddr_aximm_sl_aresetn_o                    => ddr_aximm_rstn,
    ddr_aximm_r_sl_i                          => ddr_aximm_r_ma_out,
    ddr_aximm_r_sl_o                          => ddr_aximm_r_ma_in,
    ddr_aximm_w_sl_i                          => ddr_aximm_w_ma_out,
    ddr_aximm_w_sl_o                          => ddr_aximm_w_ma_in,

    -- Wishbone interface --
    wb_clk_i                                  => clk_sys,
    -- Reset wishbone interface with the same reset as the other
    -- modules, including a reset coming from the PCIe itself.
    wb_rst_i                                  => rst_sys,
    wb_ma_i                                   => cbar_slave_o(c_ma_pcie_id),
    wb_ma_o                                   => cbar_slave_i(c_ma_pcie_id),
    -- Additional exported signals for instantiation
    wb_ma_pcie_rst_o                          => wb_ma_pcie_rst
  );

  wb_ma_pcie_rstn                             <= not wb_ma_pcie_rst;

  ----------------------------------------------------------------------
  --                            RS232 Core                            --
  ----------------------------------------------------------------------
  cmp_xwb_rs232_syscon : xwb_rs232_syscon
  generic map (
    g_ma_interface_mode                       => PIPELINED,
    g_ma_address_granularity                  => BYTE
  )
  port map(
    -- WISHBONE common
    wb_clk_i                                  => clk_sys,
    wb_rstn_i                                 => rst_sys_n,

    -- External ports
    rs232_rxd_i                               => rs232_rxd_i,
    rs232_txd_o                               => rs232_txd_o,

    -- Reset to FPGA logic
    rstn_o                                    => rs232_rstn,

    -- WISHBONE master
    wb_master_i                               => cbar_slave_o(c_ma_rs232_syscon_id),
    wb_master_o                               => cbar_slave_i(c_ma_rs232_syscon_id)
  );

  ----------------------------------------------------------------------
  --                      Peripherals Core                            --
  ----------------------------------------------------------------------

  cmp_xwb_dbe_periph : xwb_dbe_periph
  generic map(
    -- NOT used!
    --g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    -- NOT used!
    --g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_cntr_period                             => c_tics_cntr_period,
    g_num_leds                                => c_leds_num_pins,
    g_with_led_heartbeat                      => c_with_leds_heartbeat,
    g_num_buttons                             => c_buttons_num_pins
  )
  port map(
    clk_sys_i                                 => clk_sys,
    rst_n_i                                   => rst_sys_n,

    -- UART
    --uart_rxd_i                                => uart_rxd_i,
    --uart_txd_o                                => uart_txd_o,
    uart_rxd_i                                => '1',
    uart_txd_o                                => open,

    -- LEDs
    led_out_o                                 => gpio_leds_out_int,
    led_in_i                                  => gpio_leds_in_int,
    led_oen_o                                 => open,

    -- Buttons
    button_out_o                              => open,
    --button_in_i                               => buttons_i,
    button_in_i                               => buttons_dummy,
    button_oen_o                              => open,

    -- Wishbone
    slave_i                                   => cbar_master_o(c_slv_periph_id),
    slave_o                                   => cbar_master_i(c_slv_periph_id)
  );

  -- LED Red, LED Green, LED Blue
  leds_o <= heartbeat_dmtd_b_leds_out_int or
            gpio_leds_out_int or
            heartbeat_dmtd_leds_out_int;

  ----------------------------------------------------------------------
  --                            Clocks Heartbeat                      --
  ----------------------------------------------------------------------

  -- Heartbeat module controls the Blue LED
  cmp_blue_led : heartbeat
  port map
  (
    clk_i                                   => clk_dmtd,
    rst_n_i                                 => rst_dmtd_n,

    heartbeat_o                             => heartbeat_dmtd_led_int
  );

  heartbeat_dmtd_leds_out_int <= "00" & heartbeat_dmtd_led_int;

  -- Heartbeat module controls the Red LED
  cmp_red_led : heartbeat
  port map
  (
    clk_i                                   => clk_dmtd_b,
    rst_n_i                                 => rst_dmtd_b_n,

    heartbeat_o                             => heartbeat_dmtd_b_led_int
  );

  heartbeat_dmtd_b_leds_out_int <= heartbeat_dmtd_b_led_int & "00";

  ----------------------------------------------------------------------
  --                         Timing Receiver Core                     --
  ----------------------------------------------------------------------

  cmp_xtr_board_afc : xtr_board_afc
  generic map
  (
    g_interface_mode                          => PIPELINED,
    g_address_granularity                     => BYTE,
    g_ref_clock_input                         => "EXT",
    g_clk_sys_freq                            => c_clk_sys_freq,
    g_freq_meas_counter_bits                  => c_dmtd_freq_meas_counter_bits,
    g_dmtd_counter_bits                       => c_dmtd_counter_bits,
    g_simulation                              => 0
  )
  port map
  (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------
    -- Reset input (active low, can be async)
    areset_n_i                                => sys_rst_button_n_i,
    -- Optional reset input active low with rising edge detection. Does not
    -- reset PLLs.
    areset_edge_n_i                           => wb_ma_pcie_rstn,

    -- 125 MHz general clock
    clk_125m_p_i                              => sys_clk_p_i,
    clk_125m_n_i                              => sys_clk_n_i,

    -- DMTD clock
    clk_20m_vcxo_p_i                          => clk_20m_vcxo_p_i,
    clk_20m_vcxo_n_i                          => clk_20m_vcxo_n_i,

    -- Si57x clock
    clk_si57x_p_i                             => clk_afc_si57x_p_i,
    clk_si57x_n_i                             => clk_afc_si57x_n_i,

    ---- GTP clock
    clk_125m_gtp_p_i                          => '0',
    clk_125m_gtp_n_i                          => '1',

    -- Optional External Reference clock (if g_ref_clock_input = "EXT")
    clk_ext_ref_p_i                           => fmc1_clk1_m2c_p_i,
    clk_ext_ref_n_i                           => fmc1_clk1_m2c_n_i,

    -- 62.5MHz sys clock output
    clk_sys_62m5_o                            => clk_sys,
    -- 125MHz ref clock output
    clk_ref_125m_o                            => clk_ref_125m,
    -- 200MHz clock output
    clk_200m_o                                => clk_200m,
    -- DMTD 62.x offset clock
    clk_dmtd_o                                => clk_dmtd,
    -- Si57x clock output
    clk_si57x_o                               => clk_si57x,
    -- active low reset outputs, synchronous to 62m5
    rst_sys_62m5_n_o                          => rst_sys_n,
    -- active low reset output, synchronous to clocks 62m5 for PCIe
    rst_62m5_pcie_n_o                         => rst_sys_pcie_n,
    -- active low reset outputs, synchronous to 125m
    rst_ref_125m_n_o                          => rst_ref_125m_n,
    -- active low reset output, synchronous to clocks 200m
    rst_200m_n_o                              => rst_200m_n,
    -- active low reset output, synchronous to clocks dmtd
    rst_dmtd_n_o                              => rst_dmtd_n,
    -- active low reset output, synchronous to clock si57x
    rst_si57x_n_o                             => rst_si57x_n,

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver and SFP management info
    ---------------------------------------------------------------------------
    sfp_txp_o                                 => open,
    sfp_txn_o                                 => open,
    sfp_rxp_i                                 => '0',
    sfp_rxn_i                                 => '0',
    sfp_det_i                                 => '1',
    sfp_sda_i                                 => '0',
    sfp_sda_o                                 => open,
    sfp_scl_i                                 => '0',
    sfp_scl_o                                 => open,
    sfp_rate_select_o                         => open,
    sfp_tx_fault_i                            => '0',
    sfp_tx_disable_o                          => open,
    sfp_los_i                                 => '0',

    ---------------------------------------------------------------------------
    -- External WB interface
    ---------------------------------------------------------------------------
    wb_slv_i                                 => cbar_master_o(c_slv_tim_subsys_id),
    wb_slv_o                                 => cbar_master_i(c_slv_tim_subsys_id),

    ---------------------------------------------------------------------------
    -- Tag Signals Interface
    ---------------------------------------------------------------------------
    tag_a_o                                   => dmtd_tag_a,
    tag_a_p_o                                 => dmtd_tag_a_valid,
    tag_b_o                                   => dmtd_tag_b,
    tag_b_p_o                                 => dmtd_tag_b_valid,

    phase_raw_o                               => dmtd_phase_raw,
    phase_raw_p_o                             => dmtd_phase_raw_valid,
    phase_meas_o                              => dmtd_phase_meas,
    phase_meas_p_o                            => dmtd_phase_meas_valid,

    freq_dmtd_a_o                             => dmtd_freq_a,
    freq_dmtd_a_valid_o                       => dmtd_freq_a_valid,
    freq_dmtd_b_o                             => dmtd_freq_b,
    freq_dmtd_b_valid_o                       => dmtd_freq_b_valid,

    ---------------------------------------------------------------------------
    -- Buttons, LEDs and PPS output
    ---------------------------------------------------------------------------
    led_act_o                                 => open,
    led_link_o                                => open,
    btn1_i                                    => '1',
    btn2_i                                    => '1',
    -- Link ok indication
    link_ok_o                                 => open
  );

  rst_sys                                   <= not (rst_sys_n);

  clk_dmtd_a                                <= clk_ref_125m;
  clk_dmtd_b                                <= clk_si57x;
  rst_dmtd_a_n                              <= rst_ref_125m_n;
  rst_dmtd_b_n                              <= rst_si57x_n;

  ----------------------------------------------------------------------
  --                      AFC Diagnostics                             --
  ----------------------------------------------------------------------

  cmp_xwb_afc_diag : xwb_afc_diag
  generic map(
    g_interface_mode                          => PIPELINED,
    g_address_granularity                     => BYTE
  )
  port map(
    sys_clk_i                                 => clk_sys,
    sys_rst_n_i                               => rst_sys_n,

    -- Fast SPI clock. Same as Wishbone clock.
    spi_clk_i                                 => clk_sys,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                  => cbar_master_o(c_slv_afc_diag_id),
    wb_slv_o                                  => cbar_master_i(c_slv_afc_diag_id),

    dbg_spi_clk_o                             => dbg_spi_clk,
    dbg_spi_valid_o                           => dbg_spi_valid,
    dbg_en_o                                  => dbg_en,
    dbg_addr_o                                => dbg_addr,
    dbg_serial_data_o                         => dbg_serial_data,
    dbg_spi_data_o                            => dbg_spi_data,

    -----------------------------
    -- SPI interface
    -----------------------------

    spi_cs                                    => diag_spi_cs_i,
    spi_si                                    => diag_spi_si_i,
    spi_so                                    => diag_spi_so_o,
    spi_clk                                   => diag_spi_clk_i
  );

  ----------------------------------------------------------------------
  --                      Acquisition Core                            --
  ----------------------------------------------------------------------

  --------------------
  -- DMTD 1 data, Phase Raw
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_phase_raw_id).val       <= std_logic_vector(resize(signed(dmtd_phase_raw), 64));
  acq_chan_array(c_acq_core_0_id, c_acq_phase_raw_id).dvalid    <= dmtd_phase_raw_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_phase_raw_id).trig      <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_phase_raw_id).pulse;

  --------------------
  -- DMTD 1 data, Phase Meas
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_phase_meas_id).val      <= std_logic_vector(resize(signed(dmtd_phase_meas), 64));
  acq_chan_array(c_acq_core_0_id, c_acq_phase_meas_id).dvalid   <= dmtd_phase_meas_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_phase_meas_id).trig     <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_phase_meas_id).pulse;

  --------------------
  -- DMTD 1 data, Freq Meas
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_freq_id).val            <= std_logic_vector(resize(signed(dmtd_freq_a), 64));
  acq_chan_array(c_acq_core_0_id, c_acq_freq_id).dvalid         <= dmtd_freq_a_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_freq_id).trig           <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_freq_id).pulse;

  -- FIXME: For now, this acquisition core is the same as the other, but
  -- it's placed here so can use another FMC and use this core for it.
  --------------------
  -- DMTD 2 data, Phase Raw
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_phase_raw_id).val       <= std_logic_vector(resize(signed(dmtd_phase_raw), 64));
  acq_chan_array(c_acq_core_1_id, c_acq_phase_raw_id).dvalid    <= dmtd_phase_raw_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_phase_raw_id).trig      <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_phase_raw_id).pulse;

  --------------------
  -- DMTD 2 data, Phase Meas
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_phase_meas_id).val      <= std_logic_vector(resize(signed(dmtd_phase_meas), 64));
  acq_chan_array(c_acq_core_1_id, c_acq_phase_meas_id).dvalid   <= dmtd_phase_meas_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_phase_meas_id).trig     <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_phase_meas_id).pulse;

  --------------------
  -- DMTD 2 data, Freq Meas
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_freq_id).val            <= std_logic_vector(resize(signed(dmtd_freq_b), 64));
  acq_chan_array(c_acq_core_1_id, c_acq_freq_id).dvalid         <= dmtd_freq_b_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_freq_id).trig           <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_freq_id).pulse;

  cmp_xwb_facq_core_mux : xwb_facq_core_mux
  generic map
  (
    g_interface_mode                          => PIPELINED,
    g_address_granularity                     => BYTE,
    g_acq_addr_width                          => c_acq_addr_width,
    g_acq_num_channels                        => c_acq_num_channels,
    g_facq_channels                           => c_facq_channels,
    g_ddr_payload_width                       => c_ddr_payload_width,
    g_ddr_dq_width                            => c_ddr_dq_width,
    g_ddr_addr_width                          => c_ddr_addr_width,
    --g_multishot_ram_size                      => 2048,
    g_fifo_fc_size                            => c_acq_fifo_size,
    --g_sim_readback                            => false
    g_acq_num_cores                           => c_acq_num_cores,
    g_ddr_interface_type                      => c_ddr_interface_type,
    g_max_burst_size                          => c_ddr_datamover_bpm_burst_size
  )
  port map
  (
    fs_clk_array_i                            => fs_clk_array,
    fs_ce_array_i                             => fs_ce_array,
    fs_rst_n_array_i                          => fs_rst_n_array,

    -- Clock signals for Wishbone
    sys_clk_i                                 => clk_sys,
    sys_rst_n_i                               => rst_sys_n,

    -- From DDR3 Controller
    ext_clk_i                                 => ddr_aximm_clk,
    ext_rst_n_i                               => ddr_aximm_rstn,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                  => acq_core_slave_i,
    wb_slv_o                                  => acq_core_slave_o,

    -----------------------------
    -- External Interface
    -----------------------------
    acq_chan_array_i                           => acq_chan_array,

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_array_o                         => open,
    dpram_valid_array_o                        => open,

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_array_o                           => open,
    ext_valid_array_o                          => open,
    ext_addr_array_o                           => open,
    ext_sof_array_o                            => open,
    ext_eof_array_o                            => open,
    ext_dreq_array_o                           => open,
    ext_stall_array_o                          => open,

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_array_i                => (others => '0'),
    dbg_ddr_rb_rdy_array_o                    => open,
    dbg_ddr_rb_data_array_o                   => open,
    dbg_ddr_rb_addr_array_o                   => open,
    dbg_ddr_rb_valid_array_o                  => open,

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    -- AXIMM Read Channel
    ddr_aximm_r_ma_i                          => ddr_aximm_r_ma_in,
    ddr_aximm_r_ma_o                          => ddr_aximm_r_ma_out,
    -- AXIMM Write Channel
    ddr_aximm_w_ma_i                          => ddr_aximm_w_ma_in,
    ddr_aximm_w_ma_o                          => ddr_aximm_w_ma_out
  );

  fs_clk_array   <= (others => clk_sys);
  fs_ce_array    <= (others => '1');
  fs_rst_n_array <= (others => rst_sys_n);

  -- c_slv_acq_core_*_id is Wishbone slave index
  -- c_acq_core_*_id is Acquisition core index
  acq_core_slave_i <= cbar_master_o(c_slv_acq_core_1_id) &
                      cbar_master_o(c_slv_acq_core_0_id);
  cbar_master_i(c_slv_acq_core_0_id) <= acq_core_slave_o(c_acq_core_0_id);
  cbar_master_i(c_slv_acq_core_1_id) <= acq_core_slave_o(c_acq_core_1_id);

  ----------------------------------------------------------------------
  --                          Trigger                                 --
  ----------------------------------------------------------------------
  trig_ref_clk <= clk_sys;
  trig_ref_rst_n <= rst_sys_n;

  cmp_xwb_trigger : xwb_trigger
  generic map (
    g_address_granularity                     => BYTE,
    g_interface_mode                          => PIPELINED,
    g_sync_edge                               => c_trig_sync_edge,
    g_trig_num                                => c_trig_trig_num,
    g_intern_num                              => c_trig_intern_num,
    g_rcv_intern_num                          => c_trig_rcv_intern_num,
    g_num_mux_interfaces                      => c_trig_num_mux_interfaces,
    g_out_resolver                            => c_trig_out_resolver,
    g_in_resolver                             => c_trig_in_resolver,
    g_with_input_sync                         => c_trig_with_input_sync,
    g_with_output_sync                        => c_trig_with_output_sync
  )
  port map (
    clk_i                                     => clk_sys,
    rst_n_i                                   => rst_sys_n,

    ref_clk_i                                 => trig_ref_clk,
    ref_rst_n_i                               => trig_ref_rst_n,

    fs_clk_array_i                            => fs_clk_array,
    fs_rst_n_array_i                          => fs_rst_n_array,

    wb_slv_trigger_iface_i                    => cbar_master_o(c_slv_trig_iface_id),
    wb_slv_trigger_iface_o                    => cbar_master_i(c_slv_trig_iface_id),

    wb_slv_trigger_mux_i                      => trig_core_slave_i,
    wb_slv_trigger_mux_o                      => trig_core_slave_o,

    trig_dir_o                                => trig_dir_int,
    trig_rcv_intern_i                         => trig_rcv_intern,
    trig_pulse_transm_i                       => trig_pulse_transm,
    trig_pulse_rcv_o                          => trig_pulse_rcv,
    trig_b                                    => trig_b,
    trig_dbg_o                                => trig_dbg
  );

  trig_core_slave_i <= cbar_master_o(c_slv_trig_mux_1_id) &
                       cbar_master_o(c_slv_trig_mux_0_id);
  cbar_master_i(c_slv_trig_mux_0_id)    <= trig_core_slave_o(c_trig_mux_0_id);
  cbar_master_i(c_slv_trig_mux_1_id)    <= trig_core_slave_o(c_trig_mux_1_id);

  -- Assign FMCs trigger pulses to trigger channel interfaces
  trig_fmc1_channel_1.pulse <= '0';
  trig_fmc1_channel_2.pulse <= '0';

  trig_fmc2_channel_1.pulse <= '0';
  trig_fmc2_channel_2.pulse <= '0';

  -- Assign intern triggers to trigger module
  trig_rcv_intern(c_trig_mux_0_id, c_trig_rcv_intern_chan_1_id) <= trig_fmc1_channel_1;
  trig_rcv_intern(c_trig_mux_0_id, c_trig_rcv_intern_chan_2_id) <= trig_fmc1_channel_2;
  trig_rcv_intern(c_trig_mux_1_id, c_trig_rcv_intern_chan_1_id) <= trig_fmc2_channel_1;
  trig_rcv_intern(c_trig_mux_1_id, c_trig_rcv_intern_chan_2_id) <= trig_fmc2_channel_2;

  trig_dir_o <= trig_dir_int;

  ----------------------------------------------------------------------
  --                            AFC MGMT                              --
  ----------------------------------------------------------------------

  cmp_afc_mgmt : xwb_afc_mgmt
  generic map(
    g_address_granularity                    => BYTE,
    g_interface_mode                         => PIPELINED
  )
  port map (
    sys_clk_i                                => clk_sys,
    sys_rst_n_i                              => rst_sys_n,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_slv_i                                 => cbar_master_o(c_slv_afc_mgmt_id),
    wb_slv_o                                 => cbar_master_i(c_slv_afc_mgmt_id),

    -----------------------------
    -- External ports
    -----------------------------

    -- Si57x clock gen
    si57x_scl_pad_b                          => afc_si57x_scl_b,
    si57x_sda_pad_b                          => afc_si57x_sda_b,
    si57x_oe_o                               => afc_si57x_oe_o
  );

  ----------------------------------------------------------------------
  --                            Analyser                              --
  ----------------------------------------------------------------------
  cmp_vivado_ila : ila_4096_depth_64_width
  port map (
  	clk    => clk_sys,
  	probe0 => trig_ila0_probe
  );

  trig_ila0_probe(13 downto 0)  <= dmtd_phase_raw;
  trig_ila0_probe(15 downto 14) <= (others => '0');
  trig_ila0_probe(16)           <= dmtd_phase_raw_valid;
  trig_ila0_probe(17)           <= '0';
  trig_ila0_probe(31 downto 18) <= dmtd_phase_meas(13 downto 0);
  trig_ila0_probe(32)           <= dmtd_phase_meas_valid;
  trig_ila0_probe(46 downto 33) <= dmtd_tag_a;
  trig_ila0_probe(47)           <= dmtd_tag_a_valid;
  trig_ila0_probe(61 downto 48) <= dmtd_tag_b;
  trig_ila0_probe(62)           <= dmtd_tag_b_valid;
  trig_ila0_probe(63)           <= '0';

  --TRIG_ILA0_0(c_dmtd_counter_bits-1 downto 0)
  --                                          <= dmtd_phase_raw;
  --TRIG_ILA0_0(TRIG_ILA0_0'length-1 downto c_dmtd_counter_bits)
  --                                          <= (others => '0');

  --TRIG_ILA0_1(0)                            <= dmtd_phase_raw_valid;
  --TRIG_ILA0_1(31 downto 1)                  <= (others => '0');

  --TRIG_ILA0_2(31 downto 0)                  <= dmtd_phase_meas;

  --TRIG_ILA0_3(0)                            <= dmtd_phase_meas_valid;
  --TRIG_ILA0_3(31 downto 1)                  <= (others => '0');

  ----------------------------------------------------------------------
  --                                 VIO                              --
  ----------------------------------------------------------------------
  --cmp_vivado_vio : vio_64_width
  --port map (
  --  clk                                          => clk_sys,
  --  probe_out0                                   => trig_vio0_probe
  --);

  ----------------------------------------------------------------------
  --                      Triggers Chipscope                          --
  ----------------------------------------------------------------------
  --cmp_chipscope_icon_0 : chipscope_icon_1_port
  --port map (
  --  CONTROL0                                => CONTROL0
  --);

  --cmp_chipscope_ila_0 : chipscope_ila
  --port map (
  --  CONTROL                                => CONTROL0,
  --  CLK                                    => fs_clk_array(0),
  --  TRIG0                                  => TRIG_ILA0_0,
  --  TRIG1                                  => TRIG_ILA0_1,
  --  TRIG2                                  => TRIG_ILA0_2,
  --  TRIG3                                  => TRIG_ILA0_3
  --);

  --TRIG_ILA0_0(31 downto 30)                 <= (others => '0');
  --TRIG_ILA0_0(29 downto 12)                 <= trig_pulse_transm(c_trig_mux_0_id, 0 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 1 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 2 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 3 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 4 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 5 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 6 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 7 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 8 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 9 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 10).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 11).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 12).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 13).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 14).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 15).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 16).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 17).pulse;

  --TRIG_ILA0_0(11 downto 8)                  <= trig_rcv_intern(c_trig_mux_0_id, c_trig_rcv_intern_chan_1_id).pulse &
  --                                             trig_rcv_intern(c_trig_mux_0_id, c_trig_rcv_intern_chan_2_id).pulse &
  --                                             trig_rcv_intern(c_trig_mux_1_id, c_trig_rcv_intern_chan_1_id).pulse &
  --                                             trig_rcv_intern(c_trig_mux_1_id, c_trig_rcv_intern_chan_2_id).pulse;
  --TRIG_ILA0_0(7 downto 0)                   <= trig_dir_int;

  --TRIG_ILA0_1(31 downto 26)                 <= (others => '0');
  --TRIG_ILA0_1(25 downto 18)                 <= trig_dbg;
  --TRIG_ILA0_1(17 downto 0)                  <= trig_pulse_transm(c_trig_mux_1_id, 0 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 1 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 2 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 3 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 4 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 5 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 6 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 7 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 8 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 9 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 10).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 11).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 12).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 13).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 14).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 15).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 16).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 17).pulse;
  --TRIG_ILA0_2 (31 downto 18)                <= (others => '0');
  --TRIG_ILA0_2 (17 downto 0)                 <= trig_pulse_rcv(c_trig_mux_0_id, 0 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 1 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 2 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 3 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 4 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 5 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 6 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 7 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 8 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 9 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 10).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 11).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 12).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 13).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 14).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 15).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 16).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 17).pulse;
  --TRIG_ILA0_3 (31 downto 18)                <= (others => '0');
  --TRIG_ILA0_3 (17 downto 0)                 <= trig_pulse_rcv(c_trig_mux_1_id, 0 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 1 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 2 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 3 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 4 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 5 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 6 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 7 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 8 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 9 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 10).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 11).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 12).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 13).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 14).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 15).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 16).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 17).pulse;

  ----------------------------------------------------------------------
  --                      DSP Chipscope                               --
  ----------------------------------------------------------------------

  ---- Chipscope Analysis
  --cmp_chipscope_icon_13 : chipscope_icon_13_port
  --port map (
  --   CONTROL0                               => CONTROL0,
  --   CONTROL1                               => CONTROL1,
  --   CONTROL2                               => CONTROL2,
  --   CONTROL3                               => CONTROL3,
  --   CONTROL4                               => CONTROL4,
  --   CONTROL5                               => CONTROL5,
  --   CONTROL6                               => CONTROL6,
  --   CONTROL7                               => CONTROL7,
  --   CONTROL8                               => CONTROL8,
  --   CONTROL9                               => CONTROL9,
  --   CONTROL10                              => CONTROL10,
  --   CONTROL11                              => CONTROL11,
  --   CONTROL12                              => CONTROL12
  --);

  ----------------------------------------------------------------------
  --                AFC Diagnostics Chipscope                         --
  ----------------------------------------------------------------------

  ---- Xilinx Chipscope
  --cmp_chipscope_icon_1 : chipscope_icon_1_port
  --port map (
  --  CONTROL0                                => CONTROL0
  --);

  --cmp_chipscope_ila_0 : chipscope_ila
  --port map (
  --  CONTROL                                => CONTROL0,
  --  CLK                                    => clk_sys,
  --  TRIG0                                  => TRIG_ILA0_0,
  --  TRIG1                                  => TRIG_ILA0_1,
  --  TRIG2                                  => TRIG_ILA0_2,
  --  TRIG3                                  => TRIG_ILA0_3
  --);

  --TRIG_ILA0_0(c_dmtd_counter_bits-1 downto 0)
  --                                          <= dmtd_phase_raw;
  --TRIG_ILA0_0(TRIG_ILA0_0'length-1 downto c_dmtd_counter_bits)
  --                                          <= (others => '0');

  --TRIG_ILA0_1(0)                            <= dmtd_phase_raw_valid;
  --TRIG_ILA0_1(31 downto 1)                  <= (others => '0');

  --TRIG_ILA0_2(31 downto 0)                  <= dmtd_phase_meas;

  --TRIG_ILA0_3(0)                            <= dmtd_phase_meas_valid;
  --TRIG_ILA0_3(31 downto 1)                  <= (others => '0');

  --cmp_chipscope_ila_1_ddr_acq : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL1,
  --  CLK                                     => ddr_aximm_clk,
  --  TRIG0                                   => TRIG_ILA1_0,
  --  TRIG1                                   => TRIG_ILA1_1,
  --  TRIG2                                   => TRIG_ILA1_2,
  --  TRIG3                                   => TRIG_ILA1_3
  --);

  --TRIG_ILA1_0                               <= memc_wr_data(207 downto 192) &
  --                                               memc_wr_data(143 downto 128);
  --TRIG_ILA1_1                               <= memc_wr_data(79 downto 64) &
  --                                               memc_wr_data(15 downto 0);

  --TRIG_ILA1_2                               <= memc_cmd_addr_resized;
  --TRIG_ILA1_3(31 downto 30)                 <= (others => '0');
  --TRIG_ILA1_3(27 downto 0)                  <= ddr_aximm_rstn &
  --                                               rst_200m_n &
  --                                               memc_cmd_instr & -- std_logic_vector(2 downto 0);
  --                                               memc_cmd_en &
  --                                               memc_cmd_rdy &
  --                                               memc_wr_end &
  --                                               memc_wr_mask(15 downto 0) & -- std_logic_vector(31 downto 0);
  --                                               memc_wr_en &
  --                                               memc_wr_rdy &
  --                                               memarb_acc_req &
  --                                               memarb_acc_gnt;

  --cmp_chipscope_ila_2_generic : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL2,
  --  CLK                                     => clk_sys,
  --  TRIG0                                   => TRIG_ILA2_0,
  --  TRIG1                                   => TRIG_ILA2_1,
  --  TRIG2                                   => TRIG_ILA2_2,
  --  TRIG3                                   => TRIG_ILA2_3
  --);

  --TRIG_ILA2_0(5 downto 0)                   <= rst_sys &
  --                                              rst_sys_n &
  --                                              rst_button_sys_n &
  --                                              rst_button_sys &
  --                                              rst_button_sys_pp &
  --                                              sys_rst_button_n_i;

  --TRIG_ILA2_0(31 downto 6)                  <= (others => '0');
  --TRIG_ILA2_1                               <= (others => '0');
  --TRIG_ILA2_2                               <= (others => '0');
  --TRIG_ILA2_3                               <= (others => '0');

  ---- The clocks to/from peripherals are derived from the bus clock.
  ---- Therefore we don't have to worry about synchronization here, just
  ---- keep in mind that the data/ss lines will appear longer than normal
  --cmp_chipscope_ila_3_pcie : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL3,
  --  CLK                                     => clk_sys, -- Wishbone clock
  --  TRIG0                                   => TRIG_ILA3_0,
  --  TRIG1                                   => TRIG_ILA3_1,
  --  TRIG2                                   => TRIG_ILA3_2,
  --  TRIG3                                   => TRIG_ILA3_3
  --);

  --TRIG_ILA3_0                               <= wb_ma_pcie_dat_in(31 downto 0);
  --TRIG_ILA3_1                               <= wb_ma_pcie_dat_out(31 downto 0);
  --TRIG_ILA3_2(31 downto wb_ma_pcie_addr_out'left + 1) <= (others => '0');
  --TRIG_ILA3_2(wb_ma_pcie_addr_out'left downto 0)
  --                                          <= wb_ma_pcie_addr_out(wb_ma_pcie_addr_out'left downto 0);
  --TRIG_ILA3_3(31 downto 5)                  <= (others => '0');
  --TRIG_ILA3_3(4 downto 0)                   <= wb_ma_pcie_ack_in &
  --                                              wb_ma_pcie_we_out &
  --                                              wb_ma_pcie_stb_out &
  --                                              wb_ma_pcie_sel_out &
  --                                              wb_ma_pcie_cyc_out;

  --cmp_chipscope_ila_3_pcie_ddr_read : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL3,
  --  CLK                                     => ddr_aximm_clk, -- DDR3 controller clk
  --  TRIG0                                   => TRIG_ILA3_0,
  --  TRIG1                                   => TRIG_ILA3_1,
  --  TRIG2                                   => TRIG_ILA3_2,
  --  TRIG3                                   => TRIG_ILA3_3
  --);

  --TRIG_ILA3_0                               <= dbg_app_rd_data(207 downto 192) &
  --                                              dbg_app_rd_data(143 downto 128);
  --TRIG_ILA3_1                               <= dbg_app_rd_data(79 downto 64) &
  --                                              dbg_app_rd_data(15 downto 0);

  --TRIG_ILA3_2                               <= dbg_app_addr;

  --TRIG_ILA3_3(31 downto 11)                 <= (others => '0');
  --TRIG_ILA3_3(10 downto 0)                  <=  dbg_app_rd_data_end &
  --                                               dbg_app_rd_data_valid &
  --                                               dbg_app_cmd & -- std_logic_vector(2 downto 0);
  --                                               dbg_app_en &
  --                                               dbg_app_rdy &
  --                                               dbg_arb_req &
  --                                               dbg_arb_gnt;

  --cmp_chipscope_ila_5_pcie_ddr_write : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL4,
  --  CLK                                     => ddr_aximm_clk, -- DDR3 controller clk
  --  TRIG0                                   => TRIG_ILA4_0,
  --  TRIG1                                   => TRIG_ILA4_1,
  --  TRIG2                                   => TRIG_ILA4_2,
  --  TRIG3                                   => TRIG_ILA4_3
  --);

  --TRIG_ILA4_0                               <= dbg_app_wdf_data(207 downto 192) &
  --                                               dbg_app_wdf_data(143 downto 128);
  --TRIG_ILA4_1                               <= dbg_app_wdf_data(79 downto 64) &
  --                                               dbg_app_wdf_data(15 downto 0);

  --TRIG_ILA4_2                               <= dbg_app_addr;
  --TRIG_ILA4_3(31 downto 30)                 <= (others => '0');
  --TRIG_ILA4_3(29 downto 0)                  <= ddr_aximm_rstn &
  --                                               rst_200m_n &
  --                                               dbg_app_cmd & -- std_logic_vector(2 downto 0);
  --                                               dbg_app_en &
  --                                               dbg_app_rdy &
  --                                               dbg_app_wdf_end &
  --                                               dbg_app_wdf_mask(15 downto 0) & -- std_logic_vector(31 downto 0);
  --                                               dbg_app_wdf_wren &
  --                                               dbg_app_wdf_rdy &
  --                                               dbg_arb_req &
  --                                               dbg_arb_gnt;

end rtl;
