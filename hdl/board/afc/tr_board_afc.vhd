-------------------------------------------------------------------------------
-- Title      : Timing Receiver Wrapper for AFC
-- Project    : Timing Receiver
-- URL        : https://github.com/lnls-dig/timing-receiver-gw
-------------------------------------------------------------------------------
-- File       : tr_board_afc.vhd
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
-- changes/board/spec/xwrc_board_spec.vhd

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
-- Board AFC
use work.tr_afc_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity tr_board_afc is
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
end entity tr_board_afc;

architecture struct of tr_board_afc is

  -- External WB interface
  signal wb_slv_out                       : t_wishbone_slave_out;
  signal wb_slv_in                        : t_wishbone_slave_in;

begin

  -- Map top-level signals to internal records
  wb_slv_in.cyc                           <= wb_cyc_i;
  wb_slv_in.stb                           <= wb_stb_i;
  wb_slv_in.adr                           <= wb_adr_i;
  wb_slv_in.sel                           <= wb_sel_i;
  wb_slv_in.we                            <= wb_we_i;
  wb_slv_in.dat                           <= wb_dat_i;

  wb_ack_o                                  <= wb_slv_out.ack;
  wb_err_o                                  <= wb_slv_out.err;
  wb_rty_o                                  <= wb_slv_out.rty;
  wb_stall_o                                <= wb_slv_out.stall;
  wb_dat_o                                  <= wb_slv_out.dat;

  cmp_xtr_board_afc : xtr_board_afc
  generic map (
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity,
    -- Select reference clock source
    g_ref_clock_input                       => g_ref_clock_input,
    -- System clock frequency in Hz
    g_clk_sys_freq                          => g_clk_sys_freq,
    -- Number of bits for frequency counter
    g_freq_meas_counter_bits                => g_freq_meas_counter_bits,
    -- Number of bits for DMTD counter bits
    g_dmtd_counter_bits                     => g_dmtd_counter_bits,
    -- Set to TRUE will speed up some initialization
    g_simulation                            => g_simulation
  )
  port map (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------
    -- Reset input (active low, can be async)
    areset_n_i                              => areset_n_i,
    -- Optional reset input active low with rising edge detection. Does not
    -- reset PLLs.
    areset_edge_n_i                         => areset_edge_n_i,

    -- 125 MHz general clock
    clk_125m_p_i                            => clk_125m_p_i,
    clk_125m_n_i                            => clk_125m_n_i,

    -- DMTD clock
    clk_20m_vcxo_p_i                        => clk_20m_vcxo_p_i,
    clk_20m_vcxo_n_i                        => clk_20m_vcxo_n_i,

    -- Si57x clock
    clk_si57x_p_i                           => clk_si57x_p_i,
    clk_si57x_n_i                           => clk_si57x_n_i,

    -- GTP clock
    clk_125m_gtp_n_i                        => clk_125m_gtp_n_i,
    clk_125m_gtp_p_i                        => clk_125m_gtp_p_i,

    -- Optional External Reference clock (if g_ref_clock_input = "EXT")
    clk_ext_ref_p_i                         => clk_ext_ref_p_i,
    clk_ext_ref_n_i                         => clk_ext_ref_n_i,

    -- 62.5MHz sys clock output
    clk_sys_62m5_o                          => clk_sys_62m5_o,
    -- 125MHz ref clock output
    clk_ref_125m_o                          => clk_ref_125m_o,
    -- 200MHz clock output
    clk_200m_o                              => clk_200m_o,
    -- DMTD 62.x offset clock
    clk_dmtd_o                              => clk_dmtd_o,
    -- Si57x clock output
    clk_si57x_o                             => clk_si57x_o,
    -- active low reset outputs, synchronous to 62m5
    rst_sys_62m5_n_o                        => rst_sys_62m5_n_o,
    -- active low reset output, synchronous to clocks 62m5 for PCIe
    rst_62m5_pcie_n_o                       => rst_62m5_pcie_n_o,
    -- active low reset outputs, synchronous to 125m
    rst_ref_125m_n_o                        => rst_ref_125m_n_o,
    -- active low reset output, synchronous to clocks 200m
    rst_200m_n_o                            => rst_200m_n_o,
    -- active low reset output, synchronous to clocks dmtd
    rst_dmtd_n_o                            => rst_dmtd_n_o,
    -- active low reset output, synchronous to clock si57x
    rst_si57x_n_o                           => rst_si57x_n_o,

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver and SFP management info
    ---------------------------------------------------------------------------
    sfp_txp_o                               => sfp_txp_o,
    sfp_txn_o                               => sfp_txn_o,
    sfp_rxp_i                               => sfp_rxp_i,
    sfp_rxn_i                               => sfp_rxn_i,
    sfp_det_i                               => sfp_det_i,
    sfp_sda_i                               => sfp_sda_i,
    sfp_sda_o                               => sfp_sda_o,
    sfp_scl_i                               => sfp_scl_i,
    sfp_scl_o                               => sfp_scl_o,
    sfp_rate_select_o                       => sfp_rate_select_o,
    sfp_tx_fault_i                          => sfp_tx_fault_i,
    sfp_tx_disable_o                        => sfp_tx_disable_o,
    sfp_los_i                               => sfp_los_i,

    ---------------------------------------------------------------------------
    -- External WB interface
    ---------------------------------------------------------------------------
    wb_slv_o                                => wb_slv_out,
    wb_slv_i                                => wb_slv_in,

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
    -- Buttons, LEDs and PPS output
    ---------------------------------------------------------------------------
    led_act_o                               => led_act_o,
    led_link_o                              => led_link_o,
    btn1_i                                  => btn1_i,
    btn2_i                                  => btn2_i,
    -- Link ok indication
    link_ok_o                               => link_ok_o
  );

end architecture struct;
