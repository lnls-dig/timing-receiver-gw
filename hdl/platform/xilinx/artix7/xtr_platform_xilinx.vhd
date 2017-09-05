-------------------------------------------------------------------------------
-- Title      : Platform-dependent components needed for Timing Receiver on Xilinx
-- Project    : Timing Receiver
-- URL        : https://github.com/lnls-dig/timing-receiver-gw
-------------------------------------------------------------------------------
-- File       : xtr_platform_xilinx.vhd
-- Author(s)  : Lucas Russo <lerwys@gmail.com>
-- Company    : CNPEM (LNSS-DIG)
-- Created    : 2017-09-04
-- Last update: 2017-09-04
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- This module instantiates platform-specific modules that are needed by the
-- Timing Receiver to interface hardware on Xilinx FPGA. In particular it
-- contains:
-- * PHY
-- * PLLs
-- * buffers
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
-- changes/platform/xilinx/xwrc_platform_xilinx.vhd

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.tim_endpoint_pkg.all;
use work.gencores_pkg.all;
use work.tr_xilinx_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity xtr_platform_xilinx is
generic
(
  -- Define the family/model of Xilinx FPGA
  -- (supported: for now only artix7)
  g_fpga_family                             : string  := "artix7";
  -- Select reference clock source
  g_ref_clock_input                         : string := "EXT";
  -- Set to TRUE will speed up some initialization processes
  g_simulation                              : integer := 0
);
port (
  ---------------------------------------------------------------------------
  -- Clocks/resets
  ---------------------------------------------------------------------------
  -- Reset input (active low, can be async)
  areset_n_i                                : in std_logic;

  -- 125 MHz general clock
  clk_125m_i                                : in std_logic;

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

  ---------------------------------------------------------------------------
  -- SFP
  ---------------------------------------------------------------------------
  sfp_txn_o                                 : out std_logic;
  sfp_txp_o                                 : out std_logic;
  sfp_rxn_i                                 : in  std_logic;
  sfp_rxp_i                                 : in  std_logic;
  sfp_tx_fault_i                            : in  std_logic := '0';
  sfp_los_i                                 : in  std_logic := '0';
  sfp_tx_disable_o                          : out std_logic;

  ---------------------------------------------------------------------------
  --Interface to TR Core
  ---------------------------------------------------------------------------
  -- PLL outputs
  -- 62.5MHz sys clock output
  clk_62m5_sys_o                            : out std_logic;
  -- 125MHz ref clock output
  clk_125m_ref_o                            : out std_logic;
  -- 200MHz clock output
  clk_200m_o                                : out std_logic;
  -- 62.5m DMTD clock output
  clk_62m5_dmtd_o                           : out std_logic;
  -- Si57x clock output
  clk_si57x_o                               : out std_logic;
  -- Locked status
  pll_locked_o                              : out std_logic;

  ---------------------------------------------------------------------------
  --Interface to TR Core
  ---------------------------------------------------------------------------
  phy8_o                                    : out t_phy_8bits_to_tr;
  phy8_i                                    : in  t_phy_8bits_from_tr  := c_dummy_phy8_from_tr;
  phy16_o                                   : out t_phy_16bits_to_tr;
  phy16_i                                   : in  t_phy_16bits_from_tr := c_dummy_phy16_from_tr
);
end entity xtr_platform_xilinx;

architecture rtl of xtr_platform_xilinx is

  -----------------------------------------------------------------------------
  -- Signals declaration
  -----------------------------------------------------------------------------

  signal pll_arst                           : std_logic := '0';

  signal clk_sys_62m5                       : std_logic;
  signal clk_ref_125m                       : std_logic;
  signal clk_200m                           : std_logic;
  signal clk_dmtd_62m5                      : std_logic;
  signal clk_si57x                          : std_logic;

  signal clk_ext_ref_ibufds                 : std_logic;
  signal clk_ext_ref_bufg                   : std_logic;

  signal phy8_out                           : t_phy_8bits_to_tr := c_dummy_phy8_to_tr;
  signal phy16_out                          : t_phy_16bits_to_tr := c_dummy_phy16_to_tr;

begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- Check for unsupported features and/or misconfiguration
  -----------------------------------------------------------------------------
  gen_unknown_clock_input : if (g_ref_clock_input /= "EXT" and
        g_ref_clock_input /= "MGT") generate
    assert FALSE
      report "[xtr_platform_xilinx]: [" & g_ref_clock_input & "] is not supported"
      severity Failure;
  end generate;

  gen_unknown_fpga : if (g_fpga_family /= "artix7") generate
    assert FALSE
      report "Xilinx FPGA family [" & g_fpga_family & "] is not supported"
      severity Failure;
  end generate;

  -----------------------------------------------------------------------------
  -- Clock PLLs
  -----------------------------------------------------------------------------

  -- active high async reset for PLLs
  pll_arst <= not areset_n_i;

  gen_artix7_default_plls : if (g_fpga_family = "artix7") generate

    signal clk_20m_vcxo_ibufds              : std_logic;
    signal clk_20m_vcxo_bufg                : std_logic;

    signal pll_sys_locked                   : std_logic;
    signal pll_dmtd_locked                  : std_logic;

    signal clk_si57x_ibufds                 : std_logic;
    signal clk_si57x_bufg                   : std_logic;

  begin  --gen_artix7_default_pll

    -----------------------------------------------------------------------------
    -- System PLLs
    -----------------------------------------------------------------------------
    cmp_pll_sys_inst : sys_pll
    generic map (
      -- 125.0 MHz input clock
      g_clkin_period                        => 8.000,
      g_divclk_divide                       => 1,
      g_clkbout_mult_f                      => 8.000,

      -- 100 MHz output clock
      g_clk0_divide_f                       => 16.000,
      -- 200 MHz output clock
      g_clk1_divide                         => 5
    )
    port map (
      rst_i                                 => pll_arst,
      clk_i                                 => clk_125m_i,
      clk0_o                                => clk_sys_62m5,
      clk1_o                                => clk_200m,
      clk2_o                                => open,
      locked_o                              => pll_sys_locked
    );

    clk_62m5_sys_o                          <= clk_sys_62m5;
    clk_200m_o                              <= clk_200m;
    pll_locked_o                            <= pll_sys_locked and pll_dmtd_locked;

    -----------------------------------------------------------------------------
    -- DMTD PLL
    -----------------------------------------------------------------------------
    cmp_ibufds_gte2_20m_vcxo : IBUFDS_GTE2
    port map (
      O                                     => clk_20m_vcxo_ibufds,
      ODIV2                                 => open,
      I                                     => clk_20m_vcxo_p_i,
      IB                                    => clk_20m_vcxo_n_i,
      CEB                                   => '0'
    );

    cmp_gte2_2m_vcxo_bufg : BUFG
    port map(
      O                                     => clk_20m_vcxo_bufg,
      I                                     => clk_20m_vcxo_ibufds
    );

     -- Obtain core locking and generate necessary clocks
    cmp_dmtd_pll_inst : sys_pll
    generic map (
      -- 20 MHz input clock
      g_clkin_period                        => 50.000,
      g_divclk_divide                       => 1,
      g_clkbout_mult_f                      => 50.000,

      -- 62.x MHz DMTD clock
      g_clk0_divide_f                       => 16.125,
      -- 125 MHz reference clock
      g_clk1_divide                         => 8
    )
    port map (
      rst_i                                 => pll_arst,
      clk_i                                 => clk_20m_vcxo_bufg,
      clk0_o                                => clk_dmtd_62m5,
      clk1_o                                => open,
      locked_o                              => pll_dmtd_locked
    );

    clk_62m5_dmtd_o                         <= clk_dmtd_62m5;

    -----------------------------------------------------------------------------
    -- Reference Clocks
    -----------------------------------------------------------------------------
    -- Generate external reference clock or not
    gen_ref_clock_input_ext : if (g_ref_clock_input = "EXT") generate

      cmp_ibufds_ext_ref_clk : IBUFDS
      generic map (
        DIFF_TERM                           => TRUE
      )
      port map (
        O                                   => clk_ext_ref_ibufds,
        I                                   => clk_ext_ref_p_i,
        IB                                  => clk_ext_ref_n_i
      );

      cmp_ext_fmc2_clk_bufg : BUFG
      port map(
        O                                   => clk_ext_ref_bufg,
        I                                   => clk_ext_ref_ibufds
      );

      clk_ref_125m                          <= clk_ext_ref_bufg;

    end generate;

    gen_ref_clock_input_mgt : if (g_ref_clock_input = "MGT") generate
      clk_ref_125m                          <= phy8_out.rx_clk;
    end generate;

    clk_125m_ref_o                          <= clk_ref_125m;

    ----------------------------------------------------------------------
    --                      Si57x Clock generation                      --
    ----------------------------------------------------------------------

    cmp_ibufds_gte2_si57x : IBUFDS_GTE2
    port map (
      O                                       => clk_si57x_ibufds,
      ODIV2                                   => open,
      I                                       => clk_si57x_p_i,
      IB                                      => clk_si57x_n_i,
      CEB                                     => '0'
    );

    cmp_gte2_si57x_bufg : BUFG
    port map(
      O                                       => clk_si57x_bufg,
      I                                       => clk_si57x_ibufds
    );

    clk_si57x                                 <= clk_si57x_bufg;
    clk_si57x_o                               <= clk_si57x;

  end generate;

  -----------------------------------------------------------------------------
  -- Transceiver PHY
  -----------------------------------------------------------------------------

  gen_phy_artix7 : if (g_fpga_family = "artix7") generate

    --signal clk_125m_gtp_buf : std_logic;
    --
    --signal ch0_phy8_out, ch1_phy8_out : t_phy_8bits_to_tr;
    --
    --signal ch0_sfp_txn, ch0_sfp_txp : std_logic;
    --signal ch1_sfp_txn, ch1_sfp_txp : std_logic;
    --signal ch0_sfp_rxn, ch0_sfp_rxp : std_logic;
    --signal ch1_sfp_rxn, ch1_sfp_rxp : std_logic;

  begin

    --cmp_ibufgds_gtp : IBUFGDS
    --  generic map (
    --    DIFF_TERM    => TRUE,
    --    IBUF_LOW_PWR => TRUE,
    --    IOSTANDARD   => "DEFAULT")
    --  port map (
    --    O  => clk_125m_gtp_buf,
    --    I  => clk_125m_gtp_p_i,
    --    IB => clk_125m_gtp_n_i);


    --cmp_gtp : wr_gtp_phy_spartan6
    --  generic map (
    --    g_simulation => g_simulation,
    --    g_enable_ch0 => g_gtp_enable_ch0,
    --    g_enable_ch1 => g_gtp_enable_ch1)
    --  port map (
    --    gtp_clk_i          => clk_125m_gtp_buf,
    --    ch0_ref_clk_i      => clk_125m_pllref_buf,
    --    ch0_tx_data_i      => phy8_i.tx_data,
    --    ch0_tx_k_i         => phy8_i.tx_k(0),
    --    ch0_tx_disparity_o => ch0_phy8_out.tx_disparity,
    --    ch0_tx_enc_err_o   => ch0_phy8_out.tx_enc_err,
    --    ch0_rx_data_o      => ch0_phy8_out.rx_data,
    --    ch0_rx_rbclk_o     => ch0_phy8_out.rx_clk,
    --    ch0_rx_k_o         => ch0_phy8_out.rx_k(0),
    --    ch0_rx_enc_err_o   => ch0_phy8_out.rx_enc_err,
    --    ch0_rx_bitslide_o  => ch0_phy8_out.rx_bitslide,
    --    ch0_rst_i          => phy8_i.rst,
    --    ch0_loopen_i       => phy8_i.loopen,
    --    ch0_loopen_vec_i   => phy8_i.loopen_vec,
    --    ch0_tx_prbs_sel_i  => phy8_i.tx_prbs_sel,
    --    ch0_rdy_o          => ch0_phy8_out.rdy,
    --    ch1_ref_clk_i      => clk_125m_pllref_buf,
    --    ch1_tx_data_i      => phy8_i.tx_data,
    --    ch1_tx_k_i         => phy8_i.tx_k(0),
    --    ch1_tx_disparity_o => ch1_phy8_out.tx_disparity,
    --    ch1_tx_enc_err_o   => ch1_phy8_out.tx_enc_err,
    --    ch1_rx_data_o      => ch1_phy8_out.rx_data,
    --    ch1_rx_rbclk_o     => ch1_phy8_out.rx_clk,
    --    ch1_rx_k_o         => ch1_phy8_out.rx_k(0),
    --    ch1_rx_enc_err_o   => ch1_phy8_out.rx_enc_err,
    --    ch1_rx_bitslide_o  => ch1_phy8_out.rx_bitslide,
    --    ch1_rst_i          => phy8_i.rst,
    --    ch1_loopen_i       => phy8_i.loopen,
    --    ch1_loopen_vec_i   => phy8_i.loopen_vec,
    --    ch1_tx_prbs_sel_i  => phy8_i.tx_prbs_sel,
    --    ch1_rdy_o          => ch1_phy8_out.rdy,
    --    pad_txn0_o         => ch0_sfp_txn,
    --    pad_txp0_o         => ch0_sfp_txp,
    --    pad_rxn0_i         => ch0_sfp_rxn,
    --    pad_rxp0_i         => ch0_sfp_rxp,
    --    pad_txn1_o         => ch1_sfp_txn,
    --    pad_txp1_o         => ch1_sfp_txp,
    --    pad_rxn1_i         => ch1_sfp_rxn,
    --    pad_rxp1_i         => ch1_sfp_rxp
    --    );

    --gen_gtp_ch0 : if (g_gtp_enable_ch0 = 1) generate
    --  ch0_phy8_out.ref_clk      <= clk_125m_pllref_buf;
    --  ch0_phy8_out.sfp_tx_fault <= sfp_tx_fault_i;
    --  ch0_phy8_out.sfp_los      <= sfp_los_i;
    --  phy8_o                    <= ch0_phy8_out;
    --  sfp_txp_o                 <= ch0_sfp_txp;
    --  sfp_txn_o                 <= ch0_sfp_txn;
    --  ch0_sfp_rxp               <= sfp_rxp_i;
    --  ch0_sfp_rxn               <= sfp_rxn_i;
    --end generate gen_gtp_ch0;

    --gen_gtp_ch1 : if (g_gtp_enable_ch1 = 1) generate
    --  ch1_phy8_out.ref_clk      <= clk_125m_pllref_buf;
    --  ch1_phy8_out.sfp_tx_fault <= sfp_tx_fault_i;
    --  ch1_phy8_out.sfp_los      <= sfp_los_i;
    --  phy8_o                    <= ch1_phy8_out;
    --  sfp_txp_o                 <= ch1_sfp_txp;
    --  sfp_txn_o                 <= ch1_sfp_txn;
    --  ch1_sfp_rxp               <= sfp_rxp_i;
    --  ch1_sfp_rxn               <= sfp_rxn_i;
    --end generate gen_gtp_ch1;

    sfp_tx_disable_o                        <= '0';

    phy16_o                                 <= phy16_out;
    phy8_o                                  <= phy8_out;

    sfp_txp_o                               <= '0';
    sfp_txn_o                               <= '1';

  end generate;

end architecture rtl;
