library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.genram_pkg.all;

package tim_rcv_core_pkg is

  -- Timing Receiver Core
  constant c_xwb_tim_rcv_core_regs_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                     -- 32-bit port granularity (0100)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"0000000000000FFF",
    product => (
    vendor_id     => x"1000000000001215",     -- LNLS
    device_id     => x"3fc68642",
    version       => x"00000001",
    date          => x"20170822",
    name          => "LNLS_TIM_RCV_REGS  ")));

end tim_rcv_core_pkg;
