-------------------------------------------------------------------------------
-- Title      : Timing Subsystem
-- Project    : Timing Receiver
-- URL        : https://github.com/lnls-dig/timing-receiver-gw
-------------------------------------------------------------------------------
-- File       : wb_tim_subsys.vhd
-- Author(s)  : Lucas Russo <lerwys@gmail.com>
-- Company    : CNPEM (LNSS-DIG)
-- Created    : 2017-09-01
-- Last update: 2017-09-01
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Timing subsystem module containing timing related modules
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

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- General common cores
use work.gencores_pkg.all;
-- Timing cores
use work.tim_rcv_pkg.all;
-- Timing Receiver
use work.tim_rcv_core_pkg.all;
-- Endpoint cores
use work.tim_endpoint_pkg.all;
-- IFC wishbone cores
use work.ifc_wishbone_pkg.all;
-- IFC Common cores
use work.ifc_common_pkg.all;

entity wb_tim_subsys is
generic
(
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_with_extra_wb_reg                       : boolean := false;
  -- System clock frequency in Hz
  g_clk_sys_freq                            : natural := 62500000; -- in Hz
  -- Number of bits for frequency counter
  g_freq_meas_counter_bits                  : natural := 28;
  -- Number of bits for DMTD counter bits
  g_dmtd_counter_bits                       : natural := 14
);
port
(
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
end wb_tim_subsys;

architecture rtl of wb_tim_subsys is

  -----------------------------
  -- Crossbar component constants
  -----------------------------
  -- Internal crossbar layout
  -- 0 -> Timing Receiver core
  -- Number of slaves
  constant c_slaves                         : natural := 1;
  -- Number of masters
  constant c_masters                        : natural := 1;            -- Top master.

  -- Slave indexes
  constant c_slv_tim_rcv_core_id            : natural := 0;

  -- Timing Subsystem
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
  (
    c_slv_tim_rcv_core_id => f_sdb_embed_device(c_xwb_tim_rcv_core_regs_sdb,
                                                        x"00000000")    -- Timing Receiver Core Interface regs
  );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well.
  constant c_sdb_address                    : t_wishbone_address := x"00006000";

  -----------------------------
  -- Wishbone slave adapter signals/structures
  -----------------------------

  -- Extra Wishbone registering stage
  signal cbar_slave_in_reg0                 : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_out_reg0                : t_wishbone_slave_out_array(c_masters-1 downto 0);

  -----------------------------
  -- Wishbone crossbar signals
  -----------------------------
  -- Crossbar master/slave arrays
  signal cbar_slave_in                      : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_out                     : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_in                     : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_out                    : t_wishbone_master_out_array(c_slaves-1 downto 0);

  -----------------------------
  -- Clock/Reset signals
  -----------------------------

begin

  -----------------------------
  -- Insert extra Wishbone registering stage for ease timing.
  -- It effectively cuts the bandwidth in half!
  -----------------------------
  gen_with_extra_wb_reg : if g_with_extra_wb_reg generate

    cmp_register_link : xwb_register_link -- puts a register of delay between crossbars
    port map (
      clk_sys_i                             => clk_sys_i,
      rst_n_i                               => rst_n_i,
      slave_i                               => cbar_slave_in_reg0(0),
      slave_o                               => cbar_slave_out_reg0(0),
      master_i                              => cbar_slave_out(0),
      master_o                              => cbar_slave_in(0)
    );

    cbar_slave_in_reg0(0).adr               <= wb_adr_i;
    cbar_slave_in_reg0(0).dat               <= wb_dat_i;
    cbar_slave_in_reg0(0).sel               <= wb_sel_i;
    cbar_slave_in_reg0(0).we                <= wb_we_i;
    cbar_slave_in_reg0(0).cyc               <= wb_cyc_i;
    cbar_slave_in_reg0(0).stb               <= wb_stb_i;

    wb_dat_o                                <= cbar_slave_out_reg0(0).dat;
    wb_ack_o                                <= cbar_slave_out_reg0(0).ack;
    wb_err_o                                <= cbar_slave_out_reg0(0).err;
    wb_rty_o                                <= cbar_slave_out_reg0(0).rty;
    wb_stall_o                              <= cbar_slave_out_reg0(0).stall;

  end generate;

  gen_without_extra_wb_reg : if not g_with_extra_wb_reg generate

    -- External master connection
    cbar_slave_in(0).adr                    <= wb_adr_i;
    cbar_slave_in(0).dat                    <= wb_dat_i;
    cbar_slave_in(0).sel                    <= wb_sel_i;
    cbar_slave_in(0).we                     <= wb_we_i;
    cbar_slave_in(0).cyc                    <= wb_cyc_i;
    cbar_slave_in(0).stb                    <= wb_stb_i;

    wb_dat_o                                <= cbar_slave_out(0).dat;
    wb_ack_o                                <= cbar_slave_out(0).ack;
    wb_err_o                                <= cbar_slave_out(0).err;
    wb_rty_o                                <= cbar_slave_out(0).rty;
    wb_stall_o                              <= cbar_slave_out(0).stall;

  end generate;

  -----------------------------
  -- Timing Subsystem Crossbar for Wishbone interfaces modules
  -----------------------------

  -- The Internal Wishbone B.4 crossbar
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
    clk_sys_i                               => clk_sys_i,
    rst_n_i                                 => rst_n_i,
    -- Master connections (INTERCON is a slave)
    slave_i                                 => cbar_slave_in,
    slave_o                                 => cbar_slave_out,
    -- Slave connections (INTERCON is a master)
    master_i                                => cbar_master_in,
    master_o                                => cbar_master_out
  );

  -----------------------------
  -- Timing Receiver Core
  -----------------------------

  cmp_xwb_tim_rcv_core : xwb_tim_rcv_core
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
    sys_rst_n_i                             => rst_n_i,
    dmtd_rst_n_i                            => rst_dmtd_n_i,

    -- System clock
    sys_clk_i                               => clk_sys_i,
    -- Input clocks
    dmtd_a_clk_i                            => clk_ref_i,
    dmtd_b_clk_i                            => clk_si57x_i,
    dmtd_clk_i                              => clk_dmtd_i,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                => cbar_master_out(c_slv_tim_rcv_core_id),
    wb_slv_o                                => cbar_master_in(c_slv_tim_rcv_core_id),

    -----------------------------
    -- Tag Signals Interface
    -----------------------------
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
    freq_dmtd_b_valid_o                     => freq_dmtd_b_valid_o
  );

  -- Unused for now
  phy8_o                                    <= c_dummy_phy8_from_tr;
  phy16_o                                   <= c_dummy_phy16_from_tr;

  -- LEDs
  led_act_o                                 <= '0';
  led_link_o                                <= '0';
  link_ok_o                                 <= '0';

  -- SFP
  sfp_scl_o                                 <= '0';
  sfp_sda_o                                 <= '0';

end rtl;
