------------------------------------------------------------------------------
-- Title      : Top design for a simple DDMTD test with PCIe and Acqusition modules
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2017-08-03
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: This design is a simple DDMTD test to compare phases between a
-- stable 20MHz clock reference with an input clock from the FMC connectors
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
-- Meta Package
use work.synthesis_descriptor_pkg.all;
-- AXI cores
use work.pcie_cntr_axi_pkg.all;

entity simple_ddmtd_test is
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
  fmc1_la_p                                  : in std_logic_vector(33 downto 0);
  fmc1_la_n                                  : in std_logic_vector(33 downto 0);
  fmc1_ha_p                                  : in std_logic_vector(23 downto 0);
  fmc1_ha_n                                  : in std_logic_vector(23 downto 0);
  fmc1_hb_p                                  : in std_logic_vector(21 downto 0);
  fmc1_hb_n                                  : in std_logic_vector(21 downto 0);

  -----------------------------
  -- FMC2 XM105 Breakout Board ports
  -----------------------------
  fmc2_clk0_m2c_p_i                          : in std_logic;
  fmc2_clk0_m2c_n_i                          : in std_logic;
  fmc2_clk1_m2c_p_i                          : in std_logic;
  fmc2_clk1_m2c_n_i                          : in std_logic;
  fmc2_la_p                                  : in std_logic_vector(33 downto 0);
  fmc2_la_n                                  : in std_logic_vector(33 downto 0);
  fmc2_ha_p                                  : in std_logic_vector(23 downto 0);
  fmc2_ha_n                                  : in std_logic_vector(23 downto 0);
  fmc2_hb_p                                  : in std_logic_vector(21 downto 0);
  fmc2_hb_n                                  : in std_logic_vector(21 downto 0);

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
end simple_ddmtd_test;

architecture rtl of simple_ddmtd_test is

  -- Top crossbar layout
  -- Number of slaves
  constant c_slaves                         : natural := 13;
  -- Acq_Core 1, Acq_Core 2,
  -- TRIG Iface, TRIG MUX 1, TRIG MUX 2,
  -- FMC active clock
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
  constant c_slv_active_clk_id              : natural := 7;
  constant c_slv_sdb_repo_url_id            : natural := 8;
  constant c_slv_sdb_top_syn_id             : natural := 9;
  constant c_slv_sdb_gen_cores_id           : natural := 10;
  constant c_slv_sdb_infra_cores_id         : natural := 11;
  constant c_slv_sdb_wr_cores_id            : natural := 12;

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
  constant c_acq_phase_meas_id              : natural := 0;

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
  constant c_acq_num_channels               : natural := 1; -- Phase meas
  constant c_acq_width_u64                  : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(64, c_acq_chan_cmplt_width_log2);
  constant c_acq_width_u128                 : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(128, c_acq_chan_cmplt_width_log2);
  constant c_acq_width_u256                 : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(256, c_acq_chan_cmplt_width_log2);
  constant c_acq_num_atoms_u1               : unsigned(c_acq_num_atoms_width_log2-1 downto 0) :=
                                                to_unsigned(1, c_acq_num_atoms_width_log2);
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
    c_acq_phase_meas_id   => (width => c_acq_width_u64, num_atoms => c_acq_num_atoms_u1, atom_width => c_acq_atom_width_u64)
  );

  -- Trigger
  constant c_trig_sync_edge                 : string   := "positive";
  constant c_trig_trig_num                  : positive := 8; -- 8 MLVDS triggers
  constant c_trig_intern_num                : positive := 1; -- 1
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

  -- Number of top level clocks
  constant c_num_tlvl_clks                  : natural := 3; -- CLK_SYS and CLK_200 MHz and CLK_300 MHz
  constant c_clk_sys_id                     : natural := 0;
  constant c_clk_200mhz_id                  : natural := 1;
  constant c_clk_300mhz_id                  : natural := 2;

  constant c_num_dmtd_clks                  : natural := 2; -- CLK_DMTD and CLK_DMTD_DIV2
  constant c_clk_dmtd_id                    : natural := 0;
  constant c_clk_dmtd_div2_id               : natural := 1;

  constant c_dmtd_deglitch_thres            : natural := 1;
  constant c_dmtd_counter_bits              : natural := 14;
  constant c_dmtd_navg_width                : natural := 12;

  -- General peripherals layout. UART, LEDs (GPIO), Buttons (GPIO) and Tics counter
  constant c_periph_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000400");

  -- FMC active clock. Si57x + AD9510
  constant c_fmc_active_clk_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000300");

  -- WB SDB (Self describing bus) layout
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
  (
     c_slv_acq_core_0_id       => f_sdb_embed_device(c_xwb_acq_core_sdb,         x"00330000"),   -- Data Acquisition control port
     c_slv_acq_core_1_id       => f_sdb_embed_device(c_xwb_acq_core_sdb,         x"00360000"),   -- Data Acquisition control port
     c_slv_periph_id           => f_sdb_embed_bridge(c_periph_bridge_sdb,        x"00370000"),   -- General peripherals control port
     c_slv_afc_diag_id         => f_sdb_embed_device(c_xwb_afc_diag_sdb,         x"00380000"),   -- AFC Diagnostics control port
     c_slv_trig_iface_id       => f_sdb_embed_device(c_xwb_trigger_iface_sdb,    x"00390000"),   -- Trigger Interface port
     c_slv_trig_mux_0_id       => f_sdb_embed_device(c_xwb_trigger_mux_sdb,      x"00400000"),   -- Trigger Mux 1 port
     c_slv_trig_mux_1_id       => f_sdb_embed_device(c_xwb_trigger_mux_sdb,      x"00410000"),   -- Trigger Mux 2 port
     c_slv_active_clk_id       => f_sdb_embed_bridge(c_fmc_active_clk_bridge_sdb,
                                                                                 x"00420000"),   -- FMC Active clock
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
  signal wb_ma_pcie_ack_in                  : std_logic;
  signal wb_ma_pcie_dat_in                  : std_logic_vector(63 downto 0);
  signal wb_ma_pcie_addr_out                : std_logic_vector(28 downto 0);
  signal wb_ma_pcie_dat_out                 : std_logic_vector(63 downto 0);
  signal wb_ma_pcie_we_out                  : std_logic;
  signal wb_ma_pcie_stb_out                 : std_logic;
  signal wb_ma_pcie_sel_out                 : std_logic;
  signal wb_ma_pcie_cyc_out                 : std_logic;

  signal wb_ma_pcie_rst                     : std_logic;
  signal wb_ma_pcie_rstn                    : std_logic;
  signal wb_ma_pcie_rstn_sync               : std_logic;

  signal wb_ma_sladp_pcie_ack_in            : std_logic;
  signal wb_ma_sladp_pcie_dat_in            : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_addr_out          : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_dat_out           : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_we_out            : std_logic;
  signal wb_ma_sladp_pcie_stb_out           : std_logic;
  signal wb_ma_sladp_pcie_sel_out           : std_logic_vector(3 downto 0);
  signal wb_ma_sladp_pcie_cyc_out           : std_logic;

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

  signal dbg_arb_req                        : std_logic_vector(1 downto 0);
  signal dbg_arb_gnt                        : std_logic_vector(1 downto 0);

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
  signal locked_sys                         : std_logic;
  signal locked_dmtd                        : std_logic;
  signal clk_sys_pcie_rstn                  : std_logic;
  signal clk_sys_pcie_rst                   : std_logic;
  signal clk_sys_rstn                       : std_logic;
  signal clk_sys_rst                        : std_logic;
  signal clk_200mhz_rst                     : std_logic;
  signal clk_200mhz_rstn                    : std_logic;
  signal clk_300mhz_rst                     : std_logic;
  signal clk_300mhz_rstn                    : std_logic;
  signal clk_dmtd_rstn                      : std_logic;
  signal clk_dmtd_rst                       : std_logic;
  signal clk_dmtd_div2_rstn                 : std_logic;
  signal clk_dmtd_div2_rst                  : std_logic;

  signal rst_button_sys_pp                  : std_logic;
  signal rst_button_sys                     : std_logic;
  signal rst_button_sys_n                   : std_logic;

  -- "c_num_tlvl_clks" clocks
  signal reset_clks_sys                     : std_logic_vector(c_num_tlvl_clks-1 downto 0);
  signal reset_rstn_sys                     : std_logic_vector(c_num_tlvl_clks-1 downto 0);
  signal reset_clks_dmtd                    : std_logic_vector(c_num_dmtd_clks-1 downto 0);
  signal reset_rstn_dmtd                    : std_logic_vector(c_num_dmtd_clks-1 downto 0);

  signal rs232_rstn                         : std_logic;

  -- System clocks
  signal clk_sys                            : std_logic;
  signal clk_200mhz                         : std_logic;
  signal clk_300mhz                         : std_logic;

  -- DMTD clocks
  signal clk_dmtd                           : std_logic;
  signal clk_dmtd_div2                      : std_logic;

   -- Global Clock Single ended
  signal sys_clk_gen                        : std_logic;
  signal sys_clk_gen_bufg                   : std_logic;

  signal dmtd_clk_gen                       : std_logic;
  signal clk_20m_vcxo_ibufds                : std_logic;
  signal clk_20m_vcxo_bufg                  : std_logic;

  signal clk_afc_si57x_ibufds               : std_logic;
  signal clk_afc_si57x_bufg                 : std_logic;
  signal clk_afc_si57x                      : std_logic;

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
  signal heartbeat_leds_out_int             : std_logic_vector(c_leds_num_pins-1 downto 0);
  signal heartbeat_led_int                  : std_logic;
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
  --FIXME. hardcoded value
  signal dmtd_navg                          : std_logic_vector(c_dmtd_navg_width-1 downto 0) := std_logic_vector(to_unsigned(10, c_dmtd_navg_width));
  signal dmtd_phase_raw                     : std_logic_vector(c_dmtd_counter_bits-1 downto 0);
  signal dmtd_phase_raw_valid               : std_logic;
  signal dmtd_phase_meas                    : std_logic_vector(31 downto 0);
  signal dmtd_phase_meas_valid              : std_logic;

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

  ---------------------------
  --      Components       --
  ---------------------------

  component ila_4096_depth_64_width
  port (
    clk                                     : in std_logic;
    probe0                                  : in std_logic_vector(63 downto 0)
  );
  end component;

  -- Clock generation
  component clk_gen is
  port(
    sys_clk_p_i                             : in std_logic;
    sys_clk_n_i                             : in std_logic;
    sys_clk_o                               : out std_logic;
    sys_clk_bufg_o                          : out std_logic
  );
  end component;

  -- Xilinx PLL
  component sys_pll is
  generic(
    g_clkin_period                          : real := 5.000;
    g_divclk_divide                         : integer := 1;
    g_clkbout_mult_f                        : real := 5.000;

    -- Reference jitter
    g_ref_jitter                            : real := 0.010;

    -- 100 MHz output clock
    g_clk0_divide_f                         : real := 10.000;
    -- 200 MHz output clock
    g_clk1_divide                           : integer := 5;
    -- 200 MHz output clock
    g_clk2_divide                           : integer := 5
  );
  port(
    rst_i                                   : in std_logic := '0';
    clk_i                                   : in std_logic := '0';
    clk0_o                                  : out std_logic;
    clk1_o                                  : out std_logic;
    clk2_o                                  : out std_logic;
    locked_o                                : out std_logic
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

  component dmtd_phase_meas_full
  generic (
    -- DDMTD deglitcher threshold (in clk_dmtd_i) clock cycles
    g_deglitcher_threshold: integer;
    -- Phase tag counter size (see dmtd_with_deglitcher.vhd for explanation)
    g_counter_bits        : integer := 14);
  port (
    -- resets
    rst_sys_n_i  : in std_logic;
    rst_dmtd_n_i : in std_logic;

    -- system clock
    clk_sys_i  : in std_logic;
    -- Input clocks
    clk_a_i    : in std_logic;
    clk_b_i    : in std_logic;
    clk_dmtd_i : in std_logic;

    en_i : in std_logic;

    -- tag signals
    tag_a_o        : out std_logic_vector(g_counter_bits-1 downto 0);
    tag_a_p_o      : out std_logic;
    tag_b_o        : out std_logic_vector(g_counter_bits-1 downto 0);
    tag_b_p_o      : out std_logic;

    navg_i         : in  std_logic_vector(11 downto 0);
    phase_raw_o    : out std_logic_vector(g_counter_bits-1 downto 0);
    phase_raw_p_o  : out std_logic;
    phase_meas_o   : out std_logic_vector(31 downto 0);
    phase_meas_p_o : out std_logic
  );
  end component;

  -- Xilinx Chipscope Logic Analyser
  -- Functions
  -- Generate dummy (0) values
  function f_zeros(size : integer)
      return std_logic_vector is
  begin
      return std_logic_vector(to_unsigned(0, size));
  end f_zeros;

begin

  ----------------------------------------------------------------------
  --                      System Clock generation                     --
  ----------------------------------------------------------------------

  -- Clock generation for system clock
  cmp_clk_sys_gen : clk_gen
  port map (
    sys_clk_p_i                             => sys_clk_p_i,
    sys_clk_n_i                             => sys_clk_n_i,
    sys_clk_o                               => sys_clk_gen,
    sys_clk_bufg_o                          => sys_clk_gen_bufg
  );

   -- Obtain core locking and generate necessary clocks
  cmp_pll_sys_inst : sys_pll
  generic map (
    -- 125.0 MHz input clock
    g_clkin_period                          => 8.000,
    g_divclk_divide                         => 1,
    g_clkbout_mult_f                        => 8.000,

    -- 100 MHz output clock
    g_clk0_divide_f                         => 16.000,
    -- 200 MHz output clock
    g_clk1_divide                           => 5,
    -- 300 MHz output clock
    g_clk2_divide                           => 3
  )
  port map (
    rst_i                                   => '0',
    clk_i                                   => sys_clk_gen_bufg,
    --clk_i                                   => sys_clk_gen,
    clk0_o                                  => clk_sys,     -- 100MHz locked clock
    clk1_o                                  => clk_200mhz,  -- 200MHz locked clock
    clk2_o                                  => clk_300mhz,  -- 300MHz locked clock
    locked_o                                => locked_sys        -- '1' when the PLL has locked
  );

  -- Reset synchronization. Hold reset line until few locked cycles have passed.
  cmp_sys_reset : gc_reset
  generic map(
    g_clocks                                => c_num_tlvl_clks    -- CLK_SYS & CLK_200 & CLK_300
  )
  port map(
    free_clk_i                              => sys_clk_gen_bufg,
    locked_i                                => locked_sys,
    clks_i                                  => reset_clks_sys,
    rstn_o                                  => reset_rstn_sys
  );

  reset_clks_sys(c_clk_sys_id)              <= clk_sys;
  reset_clks_sys(c_clk_200mhz_id)           <= clk_200mhz;
  reset_clks_sys(c_clk_300mhz_id)           <= clk_300mhz;

  -- Reset for PCIe core. Caution when resetting the PCIe core after the
  -- initialization. The PCIe core needs to retrain the link and the PCIe
  -- host (linux OS, likely) will not be able to do that automatically,
  -- probably.
  clk_sys_pcie_rstn                         <= reset_rstn_sys(c_clk_sys_id) and rst_button_sys_n;
  clk_sys_pcie_rst                          <= not clk_sys_pcie_rstn;
  -- Reset for all other modules
  clk_sys_rstn                              <= reset_rstn_sys(c_clk_sys_id) and rst_button_sys_n and
                                                  rs232_rstn and wb_ma_pcie_rstn_sync;
  clk_sys_rst                               <= not clk_sys_rstn;
  -- Reset synchronous to clk200mhz
  clk_200mhz_rstn                           <= reset_rstn_sys(c_clk_200mhz_id);
  clk_200mhz_rst                            <=  not(reset_rstn_sys(c_clk_200mhz_id));
  -- Reset synchronous to clk300mhz
  clk_300mhz_rstn                           <= reset_rstn_sys(c_clk_300mhz_id);
  clk_300mhz_rst                            <=  not(reset_rstn_sys(c_clk_300mhz_id));

  -- Generate button reset synchronous to each clock domain
  -- Detect button positive edge of clk_sys
  cmp_button_sys_ffs : gc_sync_ffs
  port map (
    clk_i                                   => clk_sys,
    rst_n_i                                 => '1',
    data_i                                  => sys_rst_button_n_i,
    npulse_o                                => rst_button_sys_pp
  );

  -- Generate the reset signal based on positive edge
  -- of synched gc
  cmp_button_sys_rst : gc_extend_pulse
  generic map (
    g_width                                 => c_button_rst_width
  )
  port map(
    clk_i                                   => clk_sys,
    rst_n_i                                 => '1',
    pulse_i                                 => rst_button_sys_pp,
    extended_o                              => rst_button_sys
  );

  rst_button_sys_n                          <= not rst_button_sys;

  ----------------------------------------------------------------------
  --                      DMTD Clock generation                     --
  ----------------------------------------------------------------------

  cmp_ibufds_gte2_20m_vcxo : IBUFDS_GTE2
  port map (
    O                                       => clk_20m_vcxo_ibufds,
    ODIV2                                   => open,
    I                                       => clk_20m_vcxo_p_i,
    IB                                      => clk_20m_vcxo_n_i,
    CEB                                     => '0'
  );

  cmp_gte2_2m_vcxo_bufg : BUFG
  port map(
    O                                       => clk_20m_vcxo_bufg,
    I                                       => clk_20m_vcxo_ibufds
  );

   -- Obtain core locking and generate necessary clocks
  cmp_dmtd_pll_inst : sys_pll
  generic map (
    -- 20 MHz input clock
    g_clkin_period                          => 50.000,
    g_divclk_divide                         => 1,
    g_clkbout_mult_f                        => 57.500,

    -- 62.x MHz DMTD clock
    g_clk0_divide_f                         => 18.5,
    -- DMTD clock / 2
    g_clk1_divide                           => 37
  )
  port map (
    rst_i                                   => '0',
    clk_i                                   => clk_20m_vcxo_bufg,
    clk0_o                                  => clk_dmtd,
    clk1_o                                  => clk_dmtd_div2,
    locked_o                                => locked_dmtd      -- '1' when the PLL has locked
  );

  -- Reset synchronization. Hold reset line until few locked cycles have passed.
  cmp_dmtd_reset : gc_reset
  generic map(
    g_clocks                                => c_num_dmtd_clks    -- CLK_SYS & CLK_200
  )
  port map(
    free_clk_i                              => clk_20m_vcxo_bufg,
    locked_i                                => locked_dmtd,
    clks_i                                  => reset_clks_dmtd,
    rstn_o                                  => reset_rstn_dmtd
  );

  reset_clks_dmtd(c_clk_dmtd_id)            <= clk_dmtd;
  reset_clks_dmtd(c_clk_dmtd_div2_id)       <= clk_dmtd_div2;

  -- Reset synchronous to clk_dmtd
  clk_dmtd_rstn                             <= reset_rstn_dmtd(c_clk_dmtd_id);
  clk_dmtd_rst                              <=  not(reset_rstn_dmtd(c_clk_dmtd_id));
  -- Reset synchronous to clk_dmtd_div2
  clk_dmtd_div2_rstn                        <= reset_rstn_dmtd(c_clk_dmtd_div2_id);
  clk_dmtd_div2_rst                         <=  not(reset_rstn_dmtd(c_clk_dmtd_div2_id));

  ----------------------------------------------------------------------
  --                      Si57x Clock generation                      --
  ----------------------------------------------------------------------

  cmp_ibufds_gte2_si57x : IBUFDS_GTE2
  port map (
    O                                       => clk_afc_si57x_ibufds,
    ODIV2                                   => open,
    I                                       => clk_afc_si57x_n_i,
    IB                                      => clk_afc_si57x_p_i,
    CEB                                     => '0'
  );

  cmp_gte2_si57x_bufg : BUFG
  port map(
    O                                       => clk_afc_si57x_bufg,
    I                                       => clk_afc_si57x_ibufds
  );

  clk_afc_si57x <= clk_afc_si57x_bufg;

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
    rst_n_i                                 => clk_sys_rstn,
    -- Master connections (INTERCON is a slave)
    slave_i                                 => cbar_slave_i,
    slave_o                                 => cbar_slave_o,
    -- Slave connections (INTERCON is a master)
    master_i                                => cbar_master_i,
    master_o                                => cbar_master_o
  );

  -- The LM32 is master 0+1
  --lm32_rstn                                 <= clk_sys_rstn;

  --cmp_lm32 : xwb_lm32
  --generic map(
  --  g_profile                               => "medium_icache_debug"
  --) -- Including JTAG and I-cache (no divide)
  --port map(
  --  clk_sys_i                               => clk_sys,
  --  rst_n_i                                 => lm32_rstn,
  --  irq_i                                   => lm32_interrupt,
  --  dwb_o                                   => cbar_slave_i(0), -- Data bus
  --  dwb_i                                   => cbar_slave_o(0),
  --  iwb_o                                   => cbar_slave_i(1), -- Instruction bus
  --  iwb_i                                   => cbar_slave_o(1)
  --);

  -- Interrupt '0' is Button(0).
  -- Interrupts 31 downto 1 are disabled

  --lm32_interrupt <= (0 => not buttons_i(0), others => '0');

  ----------------------------------
  --         PCIe Core            --
  ----------------------------------

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
    ddr_clk_i                                 => clk_200mhz,   --200 MHz DDR core clock (connect through BUFG or PLL)
    ddr_rst_i                                 => clk_sys_rst,
    pcie_clk_p_i                              => pcie_clk_p_i, --100 MHz PCIe Clock (connect directly to input pin)
    pcie_clk_n_i                              => pcie_clk_n_i, --100 MHz PCIe Clock
    pcie_rst_n_i                              => clk_sys_pcie_rstn, -- PCIe core reset

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
    wb_rst_i                                  => clk_sys_rst,
    wb_ma_i                                   => cbar_slave_o(c_ma_pcie_id),
    wb_ma_o                                   => cbar_slave_i(c_ma_pcie_id),
    -- Additional exported signals for instantiation
    wb_ma_pcie_rst_o                          => wb_ma_pcie_rst
  );

  wb_ma_pcie_rstn                             <= not wb_ma_pcie_rst;

  cmp_pcie_reset_synch : reset_synch
  port map
  (
    clk_i                                    => clk_sys,
    arst_n_i                                 => wb_ma_pcie_rstn,
    rst_n_o                                  => wb_ma_pcie_rstn_sync
  );

  ----------------------------------
  --         RS232 Core            --
  ----------------------------------
  cmp_xwb_rs232_syscon : xwb_rs232_syscon
  generic map (
    g_ma_interface_mode                       => PIPELINED,
    g_ma_address_granularity                  => BYTE
  )
  port map(
    -- WISHBONE common
    wb_clk_i                                  => clk_sys,
    wb_rstn_i                                 => clk_sys_rstn,

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
    rst_n_i                                   => clk_sys_rstn,

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
  leds_o <= gpio_leds_out_int or heartbeat_leds_out_int;

  ----------------------------------------------------------------------
  --                            DMTD Test                             --
  ----------------------------------------------------------------------

  -- Heartbeat module controls the Blue LED
  cmp_blue_led : heartbeat
  port map
  (
    clk_i                                   => clk_dmtd,
    rst_n_i                                 => clk_dmtd_rstn,

    heartbeat_o                             => heartbeat_led_int
  );

  heartbeat_leds_out_int <= "00" & heartbeat_led_int;

  -- Phase measurement itself
  cmp_dmtd_phase_meas : dmtd_phase_meas_full
  generic map (
    -- DDMTD deglitcher threshold (in clk_dmtd_i) clock cycles
    g_deglitcher_threshold                 => c_dmtd_deglitch_thres,
    -- Phase tag counter size (see dmtd_with_deglitcher.vhd for explanation)
    g_counter_bits                         => c_dmtd_counter_bits
  )
  port map (
    -- resets
    rst_sys_n_i                            => clk_sys_rstn,
    rst_dmtd_n_i                           => clk_dmtd_rstn,

    -- system clock
    clk_sys_i                              => clk_sys,
    -- Input clocks
    clk_a_i                                => clk_afc_si57x,
    clk_b_i                                => clk_sys,
    clk_dmtd_i                             => clk_dmtd,

    en_i                                   => std_logic'('1'),

    -- tag signals
    tag_a_o                                => dmtd_tag_a,
    tag_a_p_o                              => dmtd_tag_a_valid,
    tag_b_o                                => dmtd_tag_b,
    tag_b_p_o                              => dmtd_tag_b_valid,

    navg_i                                 => dmtd_navg,
    phase_raw_o                            => dmtd_phase_raw,
    phase_raw_p_o                          => dmtd_phase_raw_valid,
    phase_meas_o                           => dmtd_phase_meas,
    phase_meas_p_o                         => dmtd_phase_meas_valid
  );

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
    sys_rst_n_i                               => clk_sys_rstn,

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
  -- DMTD 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_phase_meas_id).val      <= std_logic_vector(resize(unsigned(dmtd_phase_raw), 64));
  acq_chan_array(c_acq_core_0_id, c_acq_phase_meas_id).dvalid   <= dmtd_phase_raw_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_phase_meas_id).trig     <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_phase_meas_id).pulse;

  --------------------
  -- DMTD 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_phase_meas_id).val      <= std_logic_vector(resize(unsigned(dmtd_phase_meas), 64));
  acq_chan_array(c_acq_core_1_id, c_acq_phase_meas_id).dvalid   <= dmtd_phase_meas_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_phase_meas_id).trig     <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_phase_meas_id).pulse;

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
    sys_rst_n_i                               => clk_sys_rstn,

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
  fs_rst_n_array <= (others => clk_sys_rstn);

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
  trig_ref_rst_n <= clk_sys_rstn;

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
    rst_n_i                                   => clk_sys_rstn,

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
  --                            Active Clock                          --
  ----------------------------------------------------------------------

  cmp_fmc_active_clk : xwb_fmc_active_clk
  generic map(
    g_address_granularity                    => BYTE,
    g_interface_mode                         => PIPELINED,
    g_with_extra_wb_reg                      => false
  )
  port map (
    sys_clk_i                                => clk_sys,
    sys_rst_n_i                              => clk_sys_rstn,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_slv_i                                 => cbar_master_o(c_slv_active_clk_id),
    wb_slv_o                                 => cbar_master_i(c_slv_active_clk_id),

    -----------------------------
    -- External ports
    -----------------------------

    -- Si571 clock gen
    si571_scl_pad_b                          => afc_si57x_scl_b,
    si571_sda_pad_b                          => afc_si57x_sda_b,
    fmc_si571_oe_o                           => afc_si57x_oe_o,

    -- AD9510 clock distribution PLL
    spi_ad9510_cs_o                          => open,
    spi_ad9510_sclk_o                        => open,
    spi_ad9510_mosi_o                        => open,
    spi_ad9510_miso_i                        => '0',

    fmc_pll_function_o                       => open,
    fmc_pll_status_i                         => '0',

    -- AD9510 clock copy
    fmc_fpga_clk_p_i                         => '0',
    fmc_fpga_clk_n_i                         => '1',

    -- Clock reference selection (TS3USB221)
    fmc_clk_sel_o                            => open,

    -----------------------------
    -- General ADC output signals and status
    -----------------------------

    -- General board status
    fmc_pll_status_o                         => open,

    -- fmc_fpga_clk_*_i bypass signals
    fmc_fpga_clk_p_o                         => open,
    fmc_fpga_clk_n_o                         => open
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
  --                                               clk_200mhz_rstn &
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

  --TRIG_ILA2_0(5 downto 0)                   <= clk_sys_rst &
  --                                              clk_sys_rstn &
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
  --                                               clk_200mhz_rstn &
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
