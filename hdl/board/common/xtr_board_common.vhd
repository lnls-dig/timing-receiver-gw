-------------------------------------------------------------------------------
-- Title      : Common Timing Receiver Core Wrapper
-- Project    : Timing Receiver
-- URL        : https://github.com/lnls-dig/timing-receiver-gw
-------------------------------------------------------------------------------
-- File       : xtr_board_common.vhd
-- Author(s)  : Lucas Russo <lerwys@gmail.com>
-- Company    : CNPEM (LNSS-DIG)
-- Created    : 2017-09-01
-- Last update: 2017-09-01
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level wrapper for Timing Receiver core including all of the
-- module needed to operate the core on the AFC board.
-- http://ohwr.org/projects/afc
-------------------------------------------------------------------------------
-- Copyright (c) 2017 CNPEM
-------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
--
-- Based on: https://www.ohwr.org/projects/wr-cores/repository/revisions/master/
-- changes/board/common/xwrc_board_common.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- General common cores
use work.gencores_pkg.all;
-- Timing cores
use work.tim_rcv_pkg.all;
-- Endpoint cores
use work.tim_endpoint_pkg.all;
-- IFC wishbone cores
use work.ifc_wishbone_pkg.all;
-- IFC Common cores
use work.ifc_common_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity xtr_board_common is
generic (
  g_interface_mode                          : t_wishbone_interface_mode      := PIPELINED;
  g_address_granularity                     : t_wishbone_address_granularity := BYTE;
  g_pcs_16bit                               : boolean                        := FALSE;
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
  -- Buttons, LEDs
  ---------------------------------------------------------------------------
  led_act_o                                 : out std_logic;
  led_link_o                                : out std_logic;
  btn1_i                                    : in  std_logic := '1';
  btn2_i                                    : in  std_logic := '1';
  -- Link ok indication
  link_ok_o                                 : out std_logic
);
end entity xtr_board_common;

architecture struct of xtr_board_common is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- link state
  signal link_ok                            : std_logic;

begin  -- architecture struct

  -----------------------------------------------------------------------------
  -- The Timing Receiver Subsystem
  -----------------------------------------------------------------------------
  cmp_xwb_tim_subsys : xwb_tim_subsys
  generic map
  (
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity,
    g_clk_sys_freq                          => g_clk_sys_freq,
    g_freq_meas_counter_bits                => g_freq_meas_counter_bits,
    g_dmtd_counter_bits                     => g_dmtd_counter_bits
  )
  port map
  (
    clk_sys_i                               => clk_sys_i,
    clk_dmtd_i                              => clk_dmtd_i,
    clk_ref_i                               => clk_ref_i,
    clk_si57x_i                             => clk_si57x_i,
    rst_n_i                                 => rst_n_i,
    rst_si57x_n_i                           => rst_si57x_n_i,
    rst_dmtd_n_i                            => rst_dmtd_n_i,
    rst_ref_n_i                             => rst_ref_n_i,

    ---------------------------------------------------------------------------
    -- Wishbone Control Interface signals
    ---------------------------------------------------------------------------
    wb_slv_i                                => wb_slv_i,
    wb_slv_o                                => wb_slv_o,

    ---------------------------------------------------------------------------
    -- PHY I/f
    ---------------------------------------------------------------------------
    phy8_o                                  => phy8_o,
    phy8_i                                  => phy8_i,
    phy16_o                                 => phy16_o,
    phy16_i                                 => phy16_i,

    ---------------------------------------------------------------------------
    -- Tag Signals Interface
    ---------------------------------------------------------------------------
    tag_a_o                                 => tag_a_o,
    tag_a_p_o                               => tag_a_p_o,
    tag_b_o                                 => tag_b_o,
    tag_b_p_o                               => tag_b_p_o,

    phase_raw_o                             => phase_raw_o,
    phase_raw_p_o                           => phase_raw_p_o,
    phase_meas_o                            => phase_meas_o,
    phase_meas_p_o                          => phase_meas_p_o,

    freq_dmtd_a_o                           => freq_dmtd_a_o,
    freq_dmtd_a_valid_o                     => freq_dmtd_a_valid_o,
    freq_dmtd_b_o                           => freq_dmtd_b_o,
    freq_dmtd_b_valid_o                     => freq_dmtd_b_valid_o,

    ---------------------------------------------------------------------------
    -- Buttons, LEDs
    ---------------------------------------------------------------------------
    led_act_o                               => led_act_o,
    led_link_o                              => led_link_o,
    btn1_i                                  => btn1_i,
    btn2_i                                  => btn2_i,
    link_ok_o                               => link_ok
  );

  link_ok_o                                 <= link_ok;

end architecture struct;
