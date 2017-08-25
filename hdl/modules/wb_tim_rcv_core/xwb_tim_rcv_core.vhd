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

entity xwb_tim_rcv_core is
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
end xwb_tim_rcv_core;

architecture rtl of xwb_tim_rcv_core is

begin

  cmp_wb_tim_rcv_core : wb_tim_rcv_core
  generic map
  (
    g_interface_mode                          => g_interface_mode,
    g_address_granularity                     => g_address_granularity,
    g_dmtd_counter_bits                       => g_dmtd_counter_bits
  )
  port map
  (
    sys_rst_n_i                               => sys_rst_n_i,
    dmtd_rst_n_i                              => dmtd_rst_n_i,

    -- System clock
    sys_clk_i                                 => sys_clk_i,
    -- Input clocks
    dmtd_a_clk_i                              => dmtd_a_clk_i,
    dmtd_b_clk_i                              => dmtd_b_clk_i,
    dmtd_clk_i                                => dmtd_clk_i,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  => wb_slv_i.adr,
    wb_dat_i                                  => wb_slv_i.dat,
    wb_dat_o                                  => wb_slv_o.dat,
    wb_sel_i                                  => wb_slv_i.sel,
    wb_we_i                                   => wb_slv_i.we,
    wb_cyc_i                                  => wb_slv_i.cyc,
    wb_stb_i                                  => wb_slv_i.stb,
    wb_ack_o                                  => wb_slv_o.ack,
    wb_err_o                                  => wb_slv_o.err,
    wb_rty_o                                  => wb_slv_o.rty,
    wb_stall_o                                => wb_slv_o.stall,

    -----------------------------
    -- Tag Signals Interface
    -----------------------------
    tag_a_o                                   => tag_a_o,
    tag_a_p_o                                 => tag_a_p_o,
    tag_b_o                                   => tag_b_o,
    tag_b_p_o                                 => tag_b_p_o,

    phase_raw_o                               => phase_raw_o,
    phase_raw_p_o                             => phase_raw_p_o,
    phase_meas_o                              => phase_meas_o,
    phase_meas_p_o                            => phase_meas_p_o
  );

end rtl;
