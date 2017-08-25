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
-- Temporary package until we
-- migrate acq_pulse_level_sync
-- to another package
use work.acq_core_pkg.all;

entity wb_tim_rcv_core is
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
end wb_tim_rcv_core;

architecture rtl of wb_tim_rcv_core is

  -----------------------------
  -- General Constants
  -----------------------------
  constant c_periph_addr_size               : natural := 3+2;

  constant c_dmtd_navg_width                : natural := 32;

  -- Pulse 2 Level module
  constant c_p2l_num_inputs                 : natural := 2;
  constant c_p2l_dmtd_freq_a_valid_idx      : natural := 0;
  constant c_p2l_dmtd_freq_b_valid_idx      : natural := 1;
  constant c_p2l_with_pulse_sync            : t_acq_bool_array(c_p2l_num_inputs-1 downto 0) :=
                                                (false, false);
  constant c_p2l_with_pulse2level           : t_acq_bool_array(c_p2l_num_inputs-1 downto 0) :=
                                                (true, true);

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
  signal dmtd_phase_meas                    : std_logic_vector(31 downto 0);
  signal dmtd_phase_meas_p                  : std_logic;

  -- Frequency signals
  signal freq_dmtd_a                        : std_logic_vector(g_freq_meas_counter_bits-1 downto 0);
  signal freq_dmtd_a_valid                  : std_logic;
  signal freq_dmtd_b                        : std_logic_vector(g_freq_meas_counter_bits-1 downto 0);
  signal freq_dmtd_b_valid                  : std_logic;

  -- Pulse/level converter signals
  signal p2l_clk_in                         : std_logic_vector(c_p2l_num_inputs-1 downto 0);
  signal p2l_rst_in_n                       : std_logic_vector(c_p2l_num_inputs-1 downto 0);
  signal p2l_clk_out                        : std_logic_vector(c_p2l_num_inputs-1 downto 0);
  signal p2l_rst_out_n                      : std_logic_vector(c_p2l_num_inputs-1 downto 0);

  signal p2l_pulse                          : std_logic_vector(c_p2l_num_inputs-1 downto 0);
  signal p2l_clr                            : std_logic_vector(c_p2l_num_inputs-1 downto 0);

  signal p2l_pulse_synched                  : std_logic_vector(c_p2l_num_inputs-1 downto 0);
  signal p2l_level_synched                  : std_logic_vector(c_p2l_num_inputs-1 downto 0);

  signal freq_dmtd_a_valid_clr              : std_logic;
  signal freq_dmtd_b_valid_clr              : std_logic;
  signal freq_dmtd_a_valid_lvl              : std_logic;
  signal freq_dmtd_b_valid_lvl              : std_logic;

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
    wb_adr_i                                : in  std_logic_vector(2 downto 0);
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
    wb_adr_i                                => wb_slv_adp_out.adr(2 downto 0),
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

  -- From Wishbone Register Assignments
  dmtd_phase_meas_navg                      <= regs_out.phase_meas_ctl1_navg_o(dmtd_phase_meas_navg'length-1 downto 0);
  dmtd_a_deglitch_threshold                 <= regs_out.dmtd_a_ctl_deglitcher_thres_o;
  dmtd_b_deglitch_threshold                 <= regs_out.dmtd_b_ctl_deglitcher_thres_o;

  freq_dmtd_a_valid_clr                     <= regs_out.f_dmtd_a_valid_load_o;
  freq_dmtd_b_valid_clr                     <= regs_out.f_dmtd_b_valid_load_o;

  -- To Wishbone Register Assignments
  regs_in.dmtd_a_ctl_reserved1_i            <= (others => '0');
  regs_in.dmtd_b_ctl_reserved1_i            <= (others => '0');
  regs_in.phase_meas_val_i                  <= dmtd_phase_meas;
  regs_in.f_dmtd_a_freq_i                   <= freq_dmtd_a;
  regs_in.f_dmtd_a_valid_i                  <= freq_dmtd_a_valid_lvl;
  regs_in.f_dmtd_b_freq_i                   <= freq_dmtd_b;
  regs_in.f_dmtd_b_valid_i                  <= freq_dmtd_b_valid_lvl;

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
    phase_meas_o                            => dmtd_phase_meas,
    phase_meas_p_o                          => dmtd_phase_meas_p
  );

  phase_meas_o                              <= dmtd_phase_meas;
  phase_meas_p_o                            <= dmtd_phase_meas_p;

  ------------------------------------------------------------------------------
  -- Frequency measurement
  -----------------------------------------------------------------------------
  cmp_frequency_meter_a_clk : gc_frequency_meter
  generic map (
    g_with_internal_timebase                => true,
    g_clk_sys_freq                          => g_clk_sys_freq,
    g_counter_bits                          => 28
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    clk_in_i                                => dmtd_a_clk_i,
    rst_n_i                                 => sys_rst_n_i,
    pps_p1_i                                => '0', -- unused when g_with_internal_timebase = true
    freq_o                                  => freq_dmtd_a,
    freq_valid_o                            => freq_dmtd_a_valid
  );

  freq_dmtd_a_o                             <= freq_dmtd_a;
  freq_dmtd_a_valid_o                       <= freq_dmtd_a_valid;

  cmp_frequency_meter_b_clk : gc_frequency_meter
  generic map (
    g_with_internal_timebase                => true,
    g_clk_sys_freq                          => g_clk_sys_freq,
    g_counter_bits                          => g_freq_meas_counter_bits
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    clk_in_i                                => dmtd_b_clk_i,
    rst_n_i                                 => sys_rst_n_i,
    pps_p1_i                                => '0', -- unused when g_with_internal_timebase = true
    freq_o                                  => freq_dmtd_b,
    freq_valid_o                            => freq_dmtd_b_valid
  );

  freq_dmtd_b_o                             <= freq_dmtd_b;
  freq_dmtd_b_valid_o                       <= freq_dmtd_b_valid;

  ------------------------------------------------------------------------------
  -- Pulse to Level and Synchronizer circuits from Frequency valid
  ------------------------------------------------------------------------------

  cmp_pulse_level_sync : acq_pulse_level_sync
  generic map (
    g_num_inputs                            => c_p2l_num_inputs,
    g_with_pulse_sync                       => c_p2l_with_pulse_sync,
    g_with_pulse2level                      => c_p2l_with_pulse2level
  )
  port map
  (
    clk_in_i                                => p2l_clk_in,
    rst_in_n_i                              => p2l_rst_in_n,
    clk_out_i                               => p2l_clk_out,
    rst_out_n_i                             => p2l_rst_out_n,

    pulse_i                                 => p2l_pulse,
    clr_i                                   => p2l_clr,

    pulse_synched_o                         => p2l_pulse_synched,
    level_synched_o                         => p2l_level_synched
  );

  -- DMTD Freq A
  p2l_clk_in(c_p2l_dmtd_freq_a_valid_idx)   <= sys_clk_i;
  p2l_rst_in_n(c_p2l_dmtd_freq_a_valid_idx) <= sys_rst_n_i;
  p2l_clk_out(c_p2l_dmtd_freq_a_valid_idx)  <= sys_clk_i;
  p2l_rst_out_n(c_p2l_dmtd_freq_a_valid_idx)
                                            <= sys_rst_n_i;

  p2l_pulse(c_p2l_dmtd_freq_a_valid_idx)    <= freq_dmtd_a_valid;
  p2l_clr(c_p2l_dmtd_freq_a_valid_idx)      <= freq_dmtd_a_valid_clr;

  freq_dmtd_a_valid_lvl                     <= p2l_level_synched(c_p2l_dmtd_freq_a_valid_idx);

  -- DMTD Freq B
  p2l_clk_in(c_p2l_dmtd_freq_b_valid_idx)   <= sys_clk_i;
  p2l_rst_in_n(c_p2l_dmtd_freq_b_valid_idx) <= sys_rst_n_i;
  p2l_clk_out(c_p2l_dmtd_freq_b_valid_idx)  <= sys_clk_i;
  p2l_rst_out_n(c_p2l_dmtd_freq_b_valid_idx)
                                            <= sys_rst_n_i;

  p2l_pulse(c_p2l_dmtd_freq_b_valid_idx)    <= freq_dmtd_b_valid;
  p2l_clr(c_p2l_dmtd_freq_b_valid_idx)      <= freq_dmtd_b_valid_clr;

  freq_dmtd_b_valid_lvl                     <= p2l_level_synched(c_p2l_dmtd_freq_b_valid_idx);

end rtl;
