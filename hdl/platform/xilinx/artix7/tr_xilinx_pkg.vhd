library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.genram_pkg.all;
use work.tim_endpoint_pkg.all;

package tr_xilinx_pkg is

  ---------------------------------------------------------------------------
  -- Components
  ---------------------------------------------------------------------------

  -- Xilinx PLL
  component sys_pll is
  generic(
    g_clkin_period                          : real := 5.000;
    g_divclk_divide                         : integer := 1;
    g_clkbout_mult_f                        : real := 5.000;

    -- Reference jitter
    g_ref_jitter                            : real := 0.010;

    -- 100 MHz output clock
    g_clk0_divide_f                         : real := 10.000;
    -- 200 MHz output clock
    g_clk1_divide                           : integer := 5;
    -- 200 MHz output clock
    g_clk2_divide                           : integer := 5
  );
  port(
    rst_i                                   : in std_logic := '0';
    clk_i                                   : in std_logic := '0';
    clk0_o                                  : out std_logic;
    clk1_o                                  : out std_logic;
    clk2_o                                  : out std_logic;
    locked_o                                : out std_logic
  );
  end component;

  component xtr_platform_xilinx
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
  port
  (
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
  end component;

end tr_xilinx_pkg;
