------------------------------------------------------------------------------
-- Title      : Timing Receiver Core
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2017-08-22
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Timing Receiver Core
-------------------------------------------------------------------------------
-- Copyright (c) 2017 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2017-08-22  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- General common cores
use work.gencores_pkg.all;
-- Genrams cores
use work.genram_pkg.all;
-- Timing receiver cores
use work.tim_rcv_core_pkg.all;
-- Timing Receiver regs
use work.tim_rcv_core_wbgen2_pkg.all;
-- Timing cores
use work.tim_rcv_pkg.all;
-- IFC wishbone cores
use work.ifc_wishbone_pkg.all;
-- IFC Common cores
use work.ifc_common_pkg.all;

entity wb_tim_rcv_core is
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
end wb_tim_rcv_core;

architecture rtl of wb_tim_rcv_core is

  -----------------------------
  -- General Constants
  -----------------------------
  constant c_periph_addr_size               : natural := 2+2;

  constant c_dmtd_navg_width                : natural := 32;

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------

  -- Reset signals
  signal sys_rst_n                          : std_logic;
  signal dmtd_rst_n                         : std_logic;

  -- Registers Signals
  signal regs_in                            : t_tim_rcv_core_in_registers;
  signal regs_out                           : t_tim_rcv_core_out_registers;

  -- Wishbone slave adapter signals/structures
  signal wb_slv_adp_out                     : t_wishbone_master_out;
  signal wb_slv_adp_in                      : t_wishbone_master_in;
  signal resized_addr                       : std_logic_vector(c_wishbone_address_width-1 downto 0);

  -- DMTD signals
  signal dmtd_a_deglitch_threshold          : std_logic_vector(15 downto 0);
  signal dmtd_b_deglitch_threshold          : std_logic_vector(15 downto 0);
  signal dmtd_phase_meas_navg               : std_logic_vector(c_dmtd_navg_width-1 downto 0);

  ------------------------------------------------------------------------------
  -- Components
  ------------------------------------------------------------------------------
  component dmtd_phase_meas_full
  generic (
    -- Number of bits for averages
    g_navg_bits           : integer := 12;
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

    -- DMTD signals
    dmtd_a_deglitch_threshold_i : in std_logic_vector(15 downto 0);
    dmtd_b_deglitch_threshold_i : in std_logic_vector(15 downto 0);

    -- tag signals
    tag_a_o        : out std_logic_vector(g_counter_bits-1 downto 0);
    tag_a_p_o      : out std_logic;
    tag_b_o        : out std_logic_vector(g_counter_bits-1 downto 0);
    tag_b_p_o      : out std_logic;

    navg_i         : in  std_logic_vector(g_navg_bits-1 downto 0);
    phase_raw_o    : out std_logic_vector(g_counter_bits-1 downto 0);
    phase_raw_p_o  : out std_logic;
    phase_meas_o   : out std_logic_vector(31 downto 0);
    phase_meas_p_o : out std_logic
  );
  end component;

  component tim_rcv_core_regs
  port (
    rst_n_i                                 : in  std_logic;
    clk_sys_i                               : in  std_logic;
    wb_adr_i                                : in  std_logic_vector(1 downto 0);
    wb_dat_i                                : in  std_logic_vector(31 downto 0);
    wb_dat_o                                : out std_logic_vector(31 downto 0);
    wb_cyc_i                                : in  std_logic;
    wb_sel_i                                : in  std_logic_vector(3 downto 0);
    wb_stb_i                                : in  std_logic;
    wb_we_i                                 : in  std_logic;
    wb_ack_o                                : out std_logic;
    wb_stall_o                              : out std_logic;
    regs_i                                  : in  t_tim_rcv_core_in_registers;
    regs_o                                  : out t_tim_rcv_core_out_registers
  );
  end component;

begin

  sys_rst_n                                 <= sys_rst_n_i;
  dmtd_rst_n                                <= dmtd_rst_n_i;

  -----------------------------
  -- Slave adapter for Wishbone Register Interface
  -----------------------------
  cmp_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => true,
    g_master_mode                           => PIPELINED,
    g_master_granularity                    => WORD,
    g_slave_use_struct                      => false,
    g_slave_mode                            => g_interface_mode,
    g_slave_granularity                     => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_n,
    master_i                                => wb_slv_adp_in,
    master_o                                => wb_slv_adp_out,
    sl_adr_i                                => resized_addr,
    sl_dat_i                                => wb_dat_i,
    sl_sel_i                                => wb_sel_i,
    sl_cyc_i                                => wb_cyc_i,
    sl_stb_i                                => wb_stb_i,
    sl_we_i                                 => wb_we_i,
    sl_dat_o                                => wb_dat_o,
    sl_ack_o                                => wb_ack_o,
    sl_rty_o                                => wb_rty_o,
    sl_err_o                                => wb_err_o,
    sl_int_o                                => open,
    sl_stall_o                              => wb_stall_o
  );

  resized_addr(c_periph_addr_size-1 downto 0)
                                            <= wb_adr_i(c_periph_addr_size-1 downto 0);
  resized_addr(c_wishbone_address_width-1 downto c_periph_addr_size)
                                            <= (others => '0');

  -----------------------------
  -- Timing Register Wishbone Interface.
  -----------------------------
  cmp_tim_rcv_core_regs : tim_rcv_core_regs
  port map(
    rst_n_i                                 => sys_rst_n,
    clk_sys_i                               => sys_clk_i,
    wb_adr_i                                => wb_slv_adp_out.adr(1 downto 0),
    wb_dat_i                                => wb_slv_adp_out.dat,
    wb_dat_o                                => wb_slv_adp_in.dat,
    wb_cyc_i                                => wb_slv_adp_out.cyc,
    wb_sel_i                                => wb_slv_adp_out.sel,
    wb_stb_i                                => wb_slv_adp_out.stb,
    wb_we_i                                 => wb_slv_adp_out.we,
    wb_ack_o                                => wb_slv_adp_in.ack,
    wb_stall_o                              => wb_slv_adp_in.stall,
    regs_i                                  => regs_in,
    regs_o                                  => regs_out
  );

  -- Unused wishbone signals
  wb_slv_adp_in.int                         <= '0';
  wb_slv_adp_in.err                         <= '0';
  wb_slv_adp_in.rty                         <= '0';

  dmtd_phase_meas_navg                      <= regs_out.phase_meas_ctl1_navg_o(dmtd_phase_meas_navg'length-1 downto 0);
  dmtd_a_deglitch_threshold                 <= regs_out.dmtd_a_ctl_deglitcher_thres_o;
  dmtd_b_deglitch_threshold                 <= regs_out.dmtd_b_ctl_deglitcher_thres_o;

  regs_in.dmtd_a_ctl_reserved1_i            <= (others => '0');
  regs_in.dmtd_b_ctl_reserved1_i            <= (others => '0');

  ------------------------------------------------------------------------------
  -- Phase measurement
  -----------------------------------------------------------------------------
  cmp_dmtd_phase_meas : dmtd_phase_meas_full
  generic map (
    g_navg_bits                             => c_dmtd_navg_width,
    -- Phase tag counter size (see dmtd_with_deglitcher.vhd for explanation)
    g_counter_bits                          => g_dmtd_counter_bits
  )
  port map (
    -- resets
    rst_sys_n_i                             => sys_rst_n,
    rst_dmtd_n_i                            => dmtd_rst_n,

    -- system clock
    clk_sys_i                               => sys_clk_i,
    -- Input clocks
    clk_a_i                                 => dmtd_a_clk_i,
    clk_b_i                                 => dmtd_b_clk_i,
    clk_dmtd_i                              => dmtd_clk_i,

    en_i                                    => std_logic'('1'),

    -- DMTD signals
    dmtd_a_deglitch_threshold_i             => dmtd_a_deglitch_threshold,
    dmtd_b_deglitch_threshold_i             => dmtd_b_deglitch_threshold,

    -- tag signals
    tag_a_o                                 => tag_a_o,
    tag_a_p_o                               => tag_a_p_o,
    tag_b_o                                 => tag_b_o,
    tag_b_p_o                               => tag_b_p_o,

    navg_i                                  => dmtd_phase_meas_navg,
    phase_raw_o                             => phase_raw_o,
    phase_raw_p_o                           => phase_raw_p_o,
    phase_meas_o                            => phase_meas_o,
    phase_meas_p_o                          => phase_meas_p_o
  );

end rtl;
