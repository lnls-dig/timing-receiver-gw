-------------------------------------------------------------------------------
-- Title      : Timing Receiver GTP Wrapper
-- Project    : Timing Receiver
-- URL        : https://github.com/lnls-dig/timing-receiver-gw
-------------------------------------------------------------------------------
-- File       : tr_gtp_wrapper.vhd
-- Author(s)  : Lucas Russo <lerwys@gmail.com>
-- Company    : CNPEM (LNSS-DIG)
-- Created    : 2017-09-06
-- Last update: 2017-09-06
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Artix-7 GTP wrapper for Timing Receiver
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tr_gtp_wrapper is
generic
(
  -- simulation setting for gt secureip model
  g_example_sim_gtreset_speedup             : string    := "true";
  -- set to 1 for simulation
  g_example_simulation                      : integer   := 0;
  --period of the stable clock driving this state-machine, unit is [ns]
  g_stable_sys_clk_period                   : integer   := 8;
  -- set to 1 to use chipscope to drive resets
  g_example_use_chipscope                   : integer   := 0
);
port (

  clk_sys_i                                 : in std_logic;
  rst_n_i                                   : in std_logic;

  -----------------------------------------------------------------------------
  -- External pins
  -----------------------------------------------------------------------------
  -- Dedicated reference 125 MHz clock for the GTP transceiver
  clk_gtp_p_i                               : in std_logic;
  clk_gtp_n_i                               : in std_logic;

  pad_txn_o                                 : out std_logic;
  pad_txp_o                                 : out std_logic;

  pad_rxn_i                                 : in std_logic := '0';
  pad_rxp_i                                 : in std_logic := '0';

  -----------------------------------------------------------------------------
  -- TX path, synchronous to tx_usr_clk_o
  -----------------------------------------------------------------------------
  tx_usr_clk_o                              : out std_logic;
  tx_usr_clk2_o                             : out std_logic;

  -- 16b/20b coded
  tx_data_i                                 : in std_logic_vector(19 downto 0);

  tx_rst_i                                  : in std_logic;
  tx_user_rdy_i                             : in std_logic;
  tx_fsm_rst_done_o                         : out std_logic;

  -----------------------------------------------------------------------------
  -- RX path, synchronous to rx_usr_clk_o
  -----------------------------------------------------------------------------
  rx_usr_clk_o                              : out std_logic;
  rx_usr_clk2_o                             : out std_logic;

  rx_dly_srst_i                             : in std_logic;
  rx_rst_done_o                             : out std_logic;

  -- 16b/20b coded
  rx_data_o                                 : out std_logic_vector(19 downto 0);

  rx_rst_i                                  : in std_logic;
  rx_user_rdy_i                             : in std_logic;
  rx_fsm_rst_done_o                         : out std_logic;

  -----------------------------------------------------------------------------
  -- GTP PLL
  -----------------------------------------------------------------------------
  gtp_pll_lock_o                            : out std_logic;
  gtp_pll_rst_i                             : in std_logic
);
end entity tr_gtp_wrapper;

architecture struct of tr_gtp_wrapper is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- Clock/Resets
  signal gtp_ref_clk                        : std_logic;
  signal gtp_ref_clk_unbuf                  : std_logic;
  signal tx_usr_clk                         : std_logic;
  signal tx_usr_clk2                        : std_logic;
  signal tx_out_clk                         : std_logic;
  signal rx_usr_clk                         : std_logic;
  signal rx_usr_clk2                        : std_logic;
  signal rx_out_clk                         : std_logic;

  signal gtp_data_valid_in                  : std_logic;

  -- DRP signals
  signal drp_lock_det_clk                   : std_logic;
  signal drp_addr                           : std_logic_vector(8 downto 0);
  signal drp_di                             : std_logic_vector(15 downto 0);
  signal drp_do                             : std_logic_vector(15 downto 0);
  signal drp_en                             : std_logic;
  signal drp_rdy                            : std_logic;
  signal drp_we                             : std_logic;

  -- RX buffer bypass
  signal rx_ph_monitor                      : std_logic;
  signal rx_ph_slip_monitor                 : std_logic;
  signal rx_ph_dly_rst                      : std_logic;

  -- RX slip/equalizer
  signal rx_slide                           : std_logic;
  signal rx_lpmhf_hold                      : std_logic;
  signal rx_lpmlf_hold                      : std_logic;

  -- TX align
  signal tx_ph_align                        : std_logic;
  signal tx_ph_align_en                     : std_logic;

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------

  component gtp_wrap_rtx_GT_USRCLK_SOURCE
  port
  (
    Q0_CLK0_GTREFCLK_PAD_N_IN               : in   std_logic;
    Q0_CLK0_GTREFCLK_PAD_P_IN               : in   std_logic;
    Q0_CLK0_GTREFCLK_OUT                    : out  std_logic;

    GT0_TXUSRCLK_OUT                        : out std_logic;
    GT0_TXUSRCLK2_OUT                       : out std_logic;
    GT0_TXOUTCLK_IN                         : in  std_logic;
    GT0_RXUSRCLK_OUT                        : out std_logic;
    GT0_RXUSRCLK2_OUT                       : out std_logic;
    GT0_RXOUTCLK_IN                         : in  std_logic;
    DRPCLK_IN                               : in  std_logic;
    DRPCLK_OUT                              : out std_logic;
    GT0_REFCLK_OUT                          : out std_logic
  );
  end component;

  component gtp_wrap_rtx_init
  generic
  (
    -- Simulation attributes
    EXAMPLE_SIM_GTRESET_SPEEDUP             : string    := "FALSE";    -- Set to 1 to speed up sim reset
    EXAMPLE_SIMULATION                      : integer   := 0;          -- Set to 1 for simulation
    STABLE_CLOCK_PERIOD                     : integer   := 20;    --Period of the stable clock driving this state-machine, unit is [ns]
    EXAMPLE_USE_CHIPSCOPE                   : integer   := 0           -- Set to 1 to use Chipscope to drive resets
  );
  port
  (
      SYSCLK_IN                             : in   std_logic;
      SOFT_RESET_IN                         : in   std_logic;
      DONT_RESET_ON_DATA_ERROR_IN           : in   std_logic;
      GT0_TX_FSM_RESET_DONE_OUT             : out  std_logic;
      GT0_RX_FSM_RESET_DONE_OUT             : out  std_logic;
      GT0_DATA_VALID_IN                     : in   std_logic;

      --_________________________________________________________________________
      --_________________________________________________________________________
      --GT0  (X0Y0)
      --____________________________CHANNEL PORTS________________________________
      ---------------------------- Channel - DRP Ports  --------------------------
      GT0_DRPADDR_IN                        : in   std_logic_vector(8 downto 0);
      GT0_DRPCLK_IN                         : in   std_logic;
      GT0_DRPDI_IN                          : in   std_logic_vector(15 downto 0);
      GT0_DRPDO_OUT                         : out  std_logic_vector(15 downto 0);
      GT0_DRPEN_IN                          : in   std_logic;
      GT0_DRPRDY_OUT                        : out  std_logic;
      GT0_DRPWE_IN                          : in   std_logic;
      --------------------- RX Initialization and Reset Ports --------------------
      GT0_RXUSERRDY_IN                      : in   std_logic;
      -------------------------- RX Margin Analysis Ports ------------------------
      GT0_EYESCANDATAERROR_OUT              : out  std_logic;
      ------------------------- Receive Ports - CDR Ports ------------------------
      GT0_RXCDRLOCK_OUT                     : out  std_logic;
      ------------------ Receive Ports - FPGA RX Interface Ports -----------------
      GT0_RXDATA_OUT                        : out  std_logic_vector(19 downto 0);
      GT0_RXUSRCLK_IN                       : in   std_logic;
      GT0_RXUSRCLK2_IN                      : in   std_logic;
      ------------------------ Receive Ports - RX AFE Ports ----------------------
      GT0_GTPRXN_IN                         : in   std_logic;
      GT0_GTPRXP_IN                         : in   std_logic;
      ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
      GT0_RXPHMONITOR_OUT                   : out  std_logic_vector(4 downto 0);
      GT0_RXPHSLIPMONITOR_OUT               : out  std_logic_vector(4 downto 0);
      GT0_RXDLYSRESET_IN                    : in std_logic;
      GT0_RXPHDLYRESET_IN                   : in std_logic;
      -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
      GT0_RXSLIDE_IN                        : in std_logic;
      -------------------- Receive Ports - RX Equalizer Ports -------------------
      GT0_RXLPMHFHOLD_IN                    : in   std_logic;
      GT0_RXLPMLFHOLD_IN                    : in   std_logic;
      --------------- Receive Ports - RX Fabric Output Control Ports -------------
      GT0_RXOUTCLK_OUT                      : out  std_logic;
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      GT0_GTRXRESET_IN                      : in   std_logic;
      -------------- Receive Ports -RX Initialization and Reset Ports ------------
      GT0_RXRESETDONE_OUT                   : out  std_logic;
      --------------------- TX Initialization and Reset Ports --------------------
      GT0_GTTXRESET_IN                      : in   std_logic;
      GT0_TXUSERRDY_IN                      : in   std_logic;
      ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
      GT0_TXDATA_IN                         : in   std_logic_vector(19 downto 0);
      GT0_TXUSRCLK_IN                       : in   std_logic;
      GT0_TXUSRCLK2_IN                      : in   std_logic;
      ------------------ Transmit Ports - TX Buffer Bypass Ports -----------------
      GT0_TXPHALIGN_IN                      : in   std_logic;
      GT0_TXPHALIGNDONE_OUT                 : out  std_logic;
      GT0_TXPHALIGNEN_IN                    : in   std_logic;
      --------------- Transmit Ports - TX Configurable Driver Ports --------------
      GT0_GTPTXN_OUT                        : out  std_logic;
      GT0_GTPTXP_OUT                        : out  std_logic;
      ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
      GT0_TXOUTCLK_OUT                      : out  std_logic;
      GT0_TXOUTCLKFABRIC_OUT                : out  std_logic;
      GT0_TXOUTCLKPCS_OUT                   : out  std_logic;
      ------------- Transmit Ports - TX Initialization and Reset Ports -----------
      GT0_TXRESETDONE_OUT                   : out  std_logic;


      --____________________________COMMON PORTS________________________________
      ----------------- Common Block - GTPE2_COMMON Clocking Ports ---------------
      GT0_GTREFCLK0_IN                      : in   std_logic;
      -------------------------- Common Block - PLL Ports ------------------------
      GT0_PLL0LOCK_OUT                      : out  std_logic;
      GT0_PLL0LOCKDETCLK_IN                 : in   std_logic;
      GT0_PLL0RESET_IN                      : in   std_logic
  );
  end component;

begin

 -- Output User Clocks
  rx_usr_clk_o                              <= rx_usr_clk;
  rx_usr_clk2_o                             <= rx_usr_clk2;
  tx_usr_clk_o                              <= tx_usr_clk;
  tx_usr_clk2_o                             <= tx_usr_clk2;

  -----------------------------------------------------------------------------
  -- GTP CLK
  -----------------------------------------------------------------------------
  cmp_gtp_usrclk_source : gtp_wrap_rtx_GT_USRCLK_SOURCE
  port map
  (
    Q0_CLK0_GTREFCLK_PAD_P_IN               => clk_gtp_p_i,
    Q0_CLK0_GTREFCLK_PAD_N_IN               => clk_gtp_n_i,
    Q0_CLK0_GTREFCLK_OUT                    => gtp_ref_clk_unbuf,

    GT0_TXUSRCLK_OUT                        => tx_usr_clk,
    GT0_TXUSRCLK2_OUT                       => tx_usr_clk2,
    GT0_TXOUTCLK_IN                         => tx_out_clk,
    GT0_RXUSRCLK_OUT                        => rx_usr_clk,
    GT0_RXUSRCLK2_OUT                       => rx_usr_clk2,
    GT0_RXOUTCLK_IN                         => rx_out_clk,
    DRPCLK_IN                               => '0',
    DRPCLK_OUT                              => drp_clk,
    GT0_REFCLK_OUT                          => gtp_ref_clk
  );

  cmp_gtp_wrap_rtx_init : gtp_wrap_rtx_init
  generic map
  (
    EXAMPLE_SIM_GTRESET_SPEEDUP             => g_example_sim_gtreset_speedup,
    EXAMPLE_SIMULATION                      => g_example_simulation,
    STABLE_CLOCK_PERIOD                     => g_stable_sys_clk_period,
    EXAMPLE_USE_CHIPSCOPE                   => g_example_use_chipscope
  )
  port map
  (
    SYSCLK_IN                               => clk_sys_i,
    SOFT_RESET_IN                           => '0',
    DONT_RESET_ON_DATA_ERROR_IN             => '0',
    GT0_TX_FSM_RESET_DONE_OUT               => tx_fsm_rst_done_o,
    GT0_RX_FSM_RESET_DONE_OUT               => rx_fsm_rst_done_o,
    GT0_DATA_VALID_IN                       => gtp_data_valid_in,

    --GT0  (X0Y0)
    ---------------------------- Channel - DRP Ports  --------------------------
    GT0_DRPADDR_IN                          => drp_addr,
    GT0_DRPCLK_IN                           => drp_clk,
    GT0_DRPDI_IN                            => drp_di,
    GT0_DRPDO_OUT                           => drp_do,
    GT0_DRPEN_IN                            => drp_en,
    GT0_DRPRDY_OUT                          => drp_rdy,
    GT0_DRPWE_IN                            => drp_we,
    --------------------- RX Initialization and Reset Ports --------------------
    GT0_RXUSERRDY_IN                        => rx_user_rdy_i,
    -------------------------- RX Margin Analysis Ports ------------------------
    GT0_EYESCANDATAERROR_OUT                => open,
    ------------------------- Receive Ports - CDR Ports ------------------------
    GT0_RXCDRLOCK_OUT                       => open,
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    GT0_RXDATA_OUT                          => rx_data_o,
    GT0_RXUSRCLK_IN                         => rx_usr_clk,
    GT0_RXUSRCLK2_IN                        => rx_usr_clk2,
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    GT0_GTPRXN_IN                           => pad_rxn_i,
    GT0_GTPRXP_IN                           => pad_rxp_i,
    ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
    GT0_RXPHMONITOR_OUT                     => rx_ph_monitor,
    GT0_RXPHSLIPMONITOR_OUT                 => rx_ph_slip_monitor,
    GT0_RXDLYSRESET_IN                      => rx_dly_srst_i,
    GT0_RXPHDLYRESET_IN                     => rx_ph_dly_rst,
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    GT0_RXSLIDE_IN                          => rx_slide,
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    GT0_RXLPMHFHOLD_IN                      => rx_lpmhf_hold,
    GT0_RXLPMLFHOLD_IN                      => rx_lpmlf_hold,
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    GT0_RXOUTCLK_OUT                        => rx_out_clk,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    GT0_GTRXRESET_IN                        => rx_rst_i,
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    GT0_RXRESETDONE_OUT                     => rx_rst_done_o,
    --------------------- TX Initialization and Reset Ports --------------------
    GT0_GTTXRESET_IN                        => tx_rst_i,
    GT0_TXUSERRDY_IN                        => tx_user_rdy_i,
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GT0_TXDATA_IN                           => tx_data_i,
    GT0_TXUSRCLK_IN                         => tx_usr_clk,
    GT0_TXUSRCLK2_IN                        => tx_usr_clk2,
    ------------------ Transmit Ports - TX Buffer Bypass Ports -----------------
    GT0_TXPHALIGN_IN                        => tx_ph_align,
    GT0_TXPHALIGNDONE_OUT                   => open,
    GT0_TXPHALIGNEN_IN                      => tx_ph_align_en,
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    GT0_GTPTXN_OUT                          => pad_txn_o,
    GT0_GTPTXP_OUT                          => pad_txp_o,
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    GT0_TXOUTCLK_OUT                        => tx_out_clk,
    GT0_TXOUTCLKFABRIC_OUT                  => open,
    GT0_TXOUTCLKPCS_OUT                     => open
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    GT0_TXRESETDONE_OUT                     => open,

    --__________________________COMMON PORTS________________________________

    ----------------- Common Block - GTPE2_COMMON Clocking Ports ---------------
    GT0_GTREFCLK0_IN                        => gtp_ref_clk_unbuf,
    -------------------------- Common Block - PLL Ports ------------------------
    GT0_PLL0LOCK_OUT                        => gtp_pll_lock_o,
    GT0_PLL0LOCKDETCLK_IN                   => drp_lock_det_clk,
    GT0_PLL0RESET_IN                        => gtp_pll_rst_i
  );

  drp_lock_det_clk                          <= drp_clk;

  -- Unused signals
  gtp_data_valid_in                         <= '0';
  rx_ph_monitor                             <= '0';
  rx_ph_slip_monitor                        <= '0';
  rx_ph_dly_rst                             <= '0';
  rx_slide                                  <= '0';
  rx_lpmhf_hold                             <= '0';
  rx_lpmlf_hold                             <= '0';

  tx_ph_align                               <= '0';
  tx_ph_align_en                            <= '0';

end architecture struct;
