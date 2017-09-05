-------------------------------------------------------------------------------
-- Title      : Timing Receiver Wrapper for AFC
-- Project    : Timing Receiver
-- URL        : https://github.com/lnls-dig/timing-receiver-gw
-------------------------------------------------------------------------------
-- File       : xtr_board_afc.vhd
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
-- PHY types
use work.tim_endpoint_pkg.all;
-- Platform Xilinx
use work.tr_xilinx_pkg.all;
-- Board Common
use work.xtr_board_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity xtr_board_afc is
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
  wb_slv_o                                  : out t_wishbone_slave_out;
  wb_slv_i                                  : in  t_wishbone_slave_in := cc_dummy_slave_in;

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
end entity xtr_board_afc;

architecture struct of xtr_board_afc is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

  -- Number of top level clocks
  constant c_num_tlvl_clks                  : natural := 4; -- clk_62m5, clk_125m, clk_200m, clk_dmtd
  constant c_clk_62m5_id                    : natural := 0;
  constant c_clk_125m_id                    : natural := 1;
  constant c_clk_200m_id                    : natural := 2;
  constant c_clk_dmtd_id                    : natural := 3;

  constant c_num_pcie_clks                  : natural := 1; -- clk_62m
  constant c_clk_pcie_id                    : natural := 0;

  constant c_num_si57x_clks                 : natural := 1; -- clk_si57x
  constant c_clk_si57x_id                   : natural := 0;

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  signal clk_125m_ibufgds                   : std_logic;
  signal clk_125m_bufg                      : std_logic;

  -- PLLs, clocks
  signal clk_sys                            : std_logic;
  signal clk_pll_62m5                       : std_logic;
  signal clk_ref_125m                       : std_logic;
  signal clk_pll_200m                       : std_logic;
  signal clk_pll_dmtd                       : std_logic;
  signal clk_si57x                          : std_logic;
  signal clk_ref                            : std_logic;
  signal pll_locked                         : std_logic;

  -- Reset logic
  signal areset_edge_ppulse                 : std_logic;
  signal rst_62m5_n                         : std_logic;
  signal rst_ref_125m_n                     : std_logic;
  signal rst_200m_n                         : std_logic;
  signal rst_dmtd_n                         : std_logic;
  signal rst_62m5                           : std_logic;
  signal rst_ref_125m                       : std_logic;
  signal rst_200m                           : std_logic;
  signal rst_dmtd                           : std_logic;
  signal rstlogic_arst_n                    : std_logic;
  signal rstlogic_clk_in                    : std_logic_vector(c_num_tlvl_clks-1 downto 0);
  signal rstlogic_rst_out                   : std_logic_vector(c_num_tlvl_clks-1 downto 0);

  -- Reset logic for PCIe
  signal rst_62m5_pcie_n                    : std_logic;
  signal rstlogic_arst_pcie_n               : std_logic;
  signal rstlogic_clk_pcie_in               : std_logic_vector(c_num_pcie_clks-1 downto 0);
  signal rstlogic_rst_pcie_out              : std_logic_vector(c_num_pcie_clks-1 downto 0);

  -- Reset logic for Si57x
  signal rst_si57x_n                        : std_logic;
  signal rstlogic_arst_si57x_n              : std_logic;
  signal rstlogic_clk_si57x_in              : std_logic_vector(c_num_si57x_clks-1 downto 0);
  signal rstlogic_rst_si57x_out             : std_logic_vector(c_num_si57x_clks-1 downto 0);

  signal phy8_to_tr                         : t_phy_8bits_to_tr;
  signal phy8_from_tr                       : t_phy_8bits_from_tr;
  signal phy16_to_tr                        : t_phy_16bits_to_tr;
  signal phy16_from_tr                      : t_phy_16bits_from_tr;

begin  -- architecture struct

  cmp_ibufgds_clk_125m : IBUFGDS
  generic map (
    DIFF_TERM                               => FALSE,
    IBUF_LOW_PWR                            => TRUE,
    IOSTANDARD                              => "DEFAULT"
  )
  port map (
    O                                       => clk_125m_ibufgds,
    I                                       => clk_125m_p_i,
    IB                                      => clk_125m_n_i
  );

  cmp_bufg_clk_125m : BUFG
  port map (
    O                                       => clk_125m_bufg,
    I                                       => clk_125m_ibufgds
  );

  -----------------------------------------------------------------------------
  -- Platform-dependent part (PHY, PLLs, buffers, etc)
  -----------------------------------------------------------------------------
  cmp_xtr_platform : xtr_platform_xilinx
  generic map (
    g_fpga_family                           => "artix7",
    g_ref_clock_input                       => g_ref_clock_input,
    g_simulation                            => g_simulation
  )
  port map (
    areset_n_i                              => areset_n_i,

    -- Clocks
    clk_125m_i                              => clk_125m_bufg,
    clk_20m_vcxo_p_i                        => clk_20m_vcxo_p_i,
    clk_20m_vcxo_n_i                        => clk_20m_vcxo_n_i,
    clk_si57x_p_i                           => clk_si57x_p_i,
    clk_si57x_n_i                           => clk_si57x_n_i,
    clk_125m_gtp_n_i                        => clk_125m_gtp_n_i,
    clk_125m_gtp_p_i                        => clk_125m_gtp_p_i,
    clk_ext_ref_p_i                         => clk_ext_ref_p_i,
    clk_ext_ref_n_i                         => clk_ext_ref_n_i,

    -- Transceiver
    sfp_txn_o                               => sfp_txn_o,
    sfp_txp_o                               => sfp_txp_o,
    sfp_rxn_i                               => sfp_rxn_i,
    sfp_rxp_i                               => sfp_rxp_i,
    sfp_tx_fault_i                          => sfp_tx_fault_i,
    sfp_los_i                               => sfp_los_i,
    sfp_tx_disable_o                        => sfp_tx_disable_o,

    -- Output Clocks/Resets
    clk_62m5_sys_o                          => clk_pll_62m5,
    clk_125m_ref_o                          => clk_ref_125m,
    clk_200m_o                              => clk_pll_200m,
    clk_62m5_dmtd_o                         => clk_pll_dmtd,
    clk_si57x_o                             => clk_si57x,
    pll_locked_o                            => pll_locked,

    -- PHY interface
    phy8_o                                  => phy8_to_tr,
    phy8_i                                  => phy8_from_tr
  );

  clk_sys_62m5_o                            <= clk_pll_62m5;
  clk_ref_125m_o                            <= clk_ref_125m;
  clk_200m_o                                <= clk_pll_200m;
  clk_dmtd_o                                <= clk_pll_dmtd;
  clk_si57x_o                               <= clk_si57x;

  -----------------------------------------------------------------------------
  -- Reset logic
  -----------------------------------------------------------------------------
  -- Detect when areset_edge_n_i goes high (end of reset) and use this edge to
  -- generate rstlogic_arst_n. This is needed to connect optional reset like PCIe
  -- reset. When board runs standalone, we need to ignore PCIe reset being
  -- constantly low.
  cmp_arst_edge: gc_sync_ffs
    generic map (
      g_sync_edge                           => "positive")
    port map (
      clk_i                                 => clk_pll_62m5,
      rst_n_i                               => '1',
      data_i                                => areset_edge_n_i,
      ppulse_o                              => areset_edge_ppulse);

  -- logic AND of all async reset sources (active low)
  rstlogic_arst_n <= pll_locked and areset_n_i and (not areset_edge_ppulse);

  -- concatenation of all clocks required to have synced resets
  rstlogic_clk_in(c_clk_62m5_id)            <= clk_pll_62m5;
  rstlogic_clk_in(c_clk_125m_id)            <= clk_ref_125m;
  rstlogic_clk_in(c_clk_200m_id)            <= clk_pll_200m;
  rstlogic_clk_in(c_clk_dmtd_id)            <= clk_pll_dmtd;

  cmp_sys_reset : gc_reset
  generic map (
    g_clocks                                => c_num_tlvl_clks
  )
  port map (
    free_clk_i                              => clk_125m_bufg,
    locked_i                                => rstlogic_arst_n,
    clks_i                                  => rstlogic_clk_in,
    rstn_o                                  => rstlogic_rst_out
  );

  -- distribution of resets (already synchronized to their clock domains)
  rst_62m5_n                                <= rstlogic_rst_out(c_clk_62m5_id);
  rst_ref_125m_n                            <= rstlogic_rst_out(c_clk_125m_id);
  rst_200m_n                                <= rstlogic_rst_out(c_clk_200m_id);
  rst_dmtd_n                                <= rstlogic_rst_out(c_clk_dmtd_id);

  rst_sys_62m5_n_o                          <= rst_62m5_n;
  rst_ref_125m_n_o                          <= rst_ref_125m_n;
  rst_200m_n_o                              <= rst_200m_n;
  rst_dmtd_n_o                              <= rst_dmtd_n;

  rst_62m5                                  <= not (rst_62m5_n);
  rst_ref_125m                              <= not (rst_ref_125m_n);
  rst_200m                                  <= not (rst_200m_n);
  rst_dmtd                                  <= not (rst_dmtd_n);

  -----------------------------------------------------------------------------
  -- Reset logic for PCIe
  -----------------------------------------------------------------------------

  -- For PCIe we have a slightly different logic in the sense that while it's still
  -- synchronous to sys_clk, we don't want to reset it when PCIe logic reset
  -- is asserted. This would incur retraining the PCIe link and loosing it for
  -- of couple seconds. This is undesirable when performing this logic reset from
  -- software

  -- logic AND of all async reset sources (active low)
  rstlogic_arst_pcie_n <= pll_locked and areset_n_i;

  -- concatenation of all clocks required to have synced resets
  rstlogic_clk_pcie_in(c_clk_pcie_id)       <= clk_pll_62m5;

  cmp_sys_pcie_reset : gc_reset
  generic map (
    g_clocks                                => c_num_pcie_clks
  )
  port map (
    free_clk_i                              => clk_125m_bufg,
    locked_i                                => rstlogic_arst_pcie_n,
    clks_i                                  => rstlogic_clk_pcie_in,
    rstn_o                                  => rstlogic_rst_pcie_out
  );

  -- distribution of resets (already synchronized to their clock domains)
  rst_62m5_pcie_n                           <= rstlogic_rst_pcie_out(c_clk_pcie_id);
  rst_62m5_pcie_n_o                         <= rst_62m5_pcie_n;

  -----------------------------------------------------------------------------
  -- Reset logic for Si57x
  -----------------------------------------------------------------------------
  -- logic AND of all async reset sources (active low)
  rstlogic_arst_si57x_n <= pll_locked and areset_n_i;

  -- concatenation of all clocks required to have synced resets
  rstlogic_clk_si57x_in(c_clk_si57x_id)     <= clk_si57x;

  cmp_si57x_reset : gc_reset
  generic map (
    g_clocks                                => c_num_si57x_clks
  )
  port map (
    free_clk_i                              => clk_125m_bufg,
    locked_i                                => rstlogic_arst_si57x_n,
    clks_i                                  => rstlogic_clk_si57x_in,
    rstn_o                                  => rstlogic_rst_si57x_out
  );

  -- distribution of resets (already synchronized to their clock domains)
  rst_si57x_n                               <= rstlogic_rst_si57x_out(c_clk_si57x_id);
  rst_si57x_n_o                             <= rst_si57x_n;

  -----------------------------------------------------------------------------
  -- The common board Timing Receiver core with GTP
  -----------------------------------------------------------------------------
  cmp_xtr_board_common : xtr_board_common
  generic map (
    g_interface_mode                        => PIPELINED,
    g_address_granularity                   => BYTE,
    g_pcs_16bit                             => FALSE,
    g_clk_sys_freq                          => g_clk_sys_freq,
    g_freq_meas_counter_bits                => g_freq_meas_counter_bits,
    g_dmtd_counter_bits                     => g_dmtd_counter_bits,
    g_simulation                            => g_simulation
  )
  port map (
    -- Clocks
    clk_sys_i                               => clk_pll_62m5,
    clk_dmtd_i                              => clk_pll_dmtd,
    clk_ref_i                               => clk_ref,
    clk_si57x_i                             => clk_si57x,
    rst_n_i                                 => rst_62m5_n,
    rst_dmtd_n_i                            => rst_dmtd_n,
    rst_ref_n_i                             => rst_ref_125m_n,
    rst_si57x_n_i                           => rst_si57x_n,

    -- PHY
    phy8_o                                  => phy8_from_tr,
    phy8_i                                  => phy8_to_tr,

    -- SFP
    sfp_scl_o                               => sfp_scl_o,
    sfp_scl_i                               => sfp_scl_i,
    sfp_sda_o                               => sfp_sda_o,
    sfp_sda_i                               => sfp_sda_i,
    sfp_det_i                               => sfp_det_i,

    -- Wishbone
    wb_slv_i                                => wb_slv_i,
    wb_slv_o                                => wb_slv_o,

    -- Tag Signals Interface
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

    -- LEDs/Buttons
    led_act_o                               => led_act_o,
    led_link_o                              => led_link_o,
    btn1_i                                  => btn1_i,
    btn2_i                                  => btn2_i,
    link_ok_o                               => link_ok_o
  );

  sfp_rate_select_o <= '1';

end architecture struct;
