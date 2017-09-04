-------------------------------------------------------------------------------
-- Title      : Timing Endpoint Package
-- Project    : Timing Receiver
-- URL        : https://github.com/lnls-dig/timing-receiver-gw
-------------------------------------------------------------------------------
-- File       : tim_endpoint_pkg.vhd
-- Author(s)  : Lucas Russo <lerwys@gmail.com>
-- Company    : CNPEM (LNSS-DIG)
-- Created    : 2017-09-01
-- Last update: 2017-09-01
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Timing Endpoint Package containing types definitions and component
-- declarations
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
-- Based on Whitte Rabbit endpoint_pkg.vhd file available at:
-- https://www.ohwr.org/projects/wr-cores/repository/revisions/master/
-- changes/modules/wr_endpoint/endpoint_pkg.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wishbone_pkg.all;

package tim_endpoint_pkg is

  function f_tr_pcs_data_width(pcs_16 : boolean) return integer;
  function f_tr_pcs_k_width(pcs_16 : boolean) return integer;
  function f_tr_pcs_bts_width(pcs_16 : boolean) return integer;
  function f_tr_pcs_clock_rate(pcs_16 : boolean) return integer;

  -----------------------------
  -- Phy i/f types
  -----------------------------
  -- 8-bit Serdes
  type t_phy_8bits_to_tr is record
    ref_clk        : std_logic;
    tx_disparity   : std_logic;
    tx_enc_err     : std_logic;
    rx_data        : std_logic_vector(7 downto 0);
    rx_clk         : std_logic;
    rx_k           : std_logic_vector(0 downto 0);
    rx_enc_err     : std_logic;
    rx_bitslide    : std_logic_vector(3 downto 0);
    rdy            : std_logic;
    sfp_tx_fault   : std_logic;
    sfp_los        : std_logic;
  end record;

  type t_phy_8bits_from_tr is record
    rst            : std_logic;
    loopen         : std_logic;
    tx_data        : std_logic_vector(7 downto 0);
    tx_k           : std_logic_vector(0 downto 0);
    loopen_vec     : std_logic_vector(2 downto 0);
    tx_prbs_sel    : std_logic_vector(2 downto 0);
    sfp_tx_disable : std_logic;
  end record;

  constant c_dummy_phy8_to_tr : t_phy_8bits_to_tr :=
    ('0', '0', '0', (others=>'0'), '0', (others=>'0'), '0',
    (others=>'0'), '0', '0', '0');
  constant c_dummy_phy8_from_tr : t_phy_8bits_from_tr :=
    ('0', '0', (others=>'0'), (others=>'0'), (others=>'0'),
    (others=>'0'), '0');

  -- 16-bit Serdes
  type t_phy_16bits_to_tr is record
    ref_clk        : std_logic;
    tx_disparity   : std_logic;
    tx_enc_err     : std_logic;
    rx_data        : std_logic_vector(15 downto 0);
    rx_clk         : std_logic;
    rx_k           : std_logic_vector(1 downto 0);
    rx_enc_err     : std_logic;
    rx_bitslide    : std_logic_vector(4 downto 0);
    rdy            : std_logic;
    sfp_tx_fault   : std_logic;
    sfp_los        : std_logic;
  end record;
  type t_phy_16bits_from_tr is record
    rst            : std_logic;
    loopen         : std_logic;
    tx_data        : std_logic_vector(15 downto 0);
    tx_k           : std_logic_vector(1 downto 0);
    loopen_vec     : std_logic_vector(2 downto 0);
    tx_prbs_sel    : std_logic_vector(2 downto 0);
    sfp_tx_disable : std_logic;
  end record;

  constant c_dummy_phy16_to_tr : t_phy_16bits_to_tr :=
    ('0', '0', '0', (others=>'0'), '0', (others=>'0'), '0',
    (others=>'0'), '0', '0', '0');
  constant c_dummy_phy16_from_tr : t_phy_16bits_from_tr :=
    ('0', '0', (others=>'0'), (others=>'0'), (others=>'0'),
    (others=>'0'), '0');

end tim_endpoint_pkg;

package body tim_endpoint_pkg is

  function f_tr_pcs_data_width(pcs_16 : boolean)
    return integer is
  begin
    if (pcs_16) then
      return 16;
    else
      return 8;
    end if;
  end function;

  function f_tr_pcs_k_width(pcs_16 : boolean)
    return integer is
  begin
    if (pcs_16) then
      return 2;
    else
      return 1;
    end if;
  end function;

  function f_tr_pcs_bts_width(pcs_16 : boolean)
    return integer is
  begin
    if (pcs_16) then
      return 5;
    else
      return 4;
    end if;
  end function;

  function f_tr_pcs_clock_rate(pcs_16 : boolean)
    return integer is
  begin
    if (pcs_16) then
      return 62500000;
    else
      return 125000000;
    end if;
  end function;

end package body tim_endpoint_pkg;
