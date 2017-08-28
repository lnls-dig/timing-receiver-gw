---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Timing Receiver Core registers
---------------------------------------------------------------------------------------
-- File           : tim_rcv_core_regs_pkg.vhd
-- Author         : auto-generated by wbgen2 from tim_rcv_core.wb
-- Created        : Mon Aug 28 13:38:10 2017
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE tim_rcv_core.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tim_rcv_core_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_tim_rcv_core_in_registers is record
    dmtd_a_ctl_reserved1_i                   : std_logic_vector(15 downto 0);
    dmtd_b_ctl_reserved1_i                   : std_logic_vector(15 downto 0);
    phase_meas_i                             : std_logic_vector(31 downto 0);
    f_dmtd_a_freq_i                          : std_logic_vector(27 downto 0);
    f_dmtd_a_valid_i                         : std_logic;
    f_dmtd_b_freq_i                          : std_logic_vector(27 downto 0);
    f_dmtd_b_valid_i                         : std_logic;
    end record;
  
  constant c_tim_rcv_core_in_registers_init_value: t_tim_rcv_core_in_registers := (
    dmtd_a_ctl_reserved1_i => (others => '0'),
    dmtd_b_ctl_reserved1_i => (others => '0'),
    phase_meas_i => (others => '0'),
    f_dmtd_a_freq_i => (others => '0'),
    f_dmtd_a_valid_i => '0',
    f_dmtd_b_freq_i => (others => '0'),
    f_dmtd_b_valid_i => '0'
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_tim_rcv_core_out_registers is record
      phase_meas_navg_o                        : std_logic_vector(31 downto 0);
      dmtd_a_ctl_deglitcher_thres_o            : std_logic_vector(15 downto 0);
      dmtd_b_ctl_deglitcher_thres_o            : std_logic_vector(15 downto 0);
      f_dmtd_a_valid_o                         : std_logic;
      f_dmtd_a_valid_load_o                    : std_logic;
      f_dmtd_b_valid_o                         : std_logic;
      f_dmtd_b_valid_load_o                    : std_logic;
      end record;
    
    constant c_tim_rcv_core_out_registers_init_value: t_tim_rcv_core_out_registers := (
      phase_meas_navg_o => (others => '0'),
      dmtd_a_ctl_deglitcher_thres_o => (others => '0'),
      dmtd_b_ctl_deglitcher_thres_o => (others => '0'),
      f_dmtd_a_valid_o => '0',
      f_dmtd_a_valid_load_o => '0',
      f_dmtd_b_valid_o => '0',
      f_dmtd_b_valid_load_o => '0'
      );
    function "or" (left, right: t_tim_rcv_core_in_registers) return t_tim_rcv_core_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
    function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
end package;

package body tim_rcv_core_wbgen2_pkg is
function f_x_to_zero (x:std_logic) return std_logic is
begin
if x = '1' then
return '1';
else
return '0';
end if;
end function;
function f_x_to_zero (x:std_logic_vector) return std_logic_vector is
variable tmp: std_logic_vector(x'length-1 downto 0);
begin
for i in 0 to x'length-1 loop
if(x(i) = 'X' or x(i) = 'U') then
tmp(i):= '0';
else
tmp(i):=x(i);
end if; 
end loop; 
return tmp;
end function;
function "or" (left, right: t_tim_rcv_core_in_registers) return t_tim_rcv_core_in_registers is
variable tmp: t_tim_rcv_core_in_registers;
begin
tmp.dmtd_a_ctl_reserved1_i := f_x_to_zero(left.dmtd_a_ctl_reserved1_i) or f_x_to_zero(right.dmtd_a_ctl_reserved1_i);
tmp.dmtd_b_ctl_reserved1_i := f_x_to_zero(left.dmtd_b_ctl_reserved1_i) or f_x_to_zero(right.dmtd_b_ctl_reserved1_i);
tmp.phase_meas_i := f_x_to_zero(left.phase_meas_i) or f_x_to_zero(right.phase_meas_i);
tmp.f_dmtd_a_freq_i := f_x_to_zero(left.f_dmtd_a_freq_i) or f_x_to_zero(right.f_dmtd_a_freq_i);
tmp.f_dmtd_a_valid_i := f_x_to_zero(left.f_dmtd_a_valid_i) or f_x_to_zero(right.f_dmtd_a_valid_i);
tmp.f_dmtd_b_freq_i := f_x_to_zero(left.f_dmtd_b_freq_i) or f_x_to_zero(right.f_dmtd_b_freq_i);
tmp.f_dmtd_b_valid_i := f_x_to_zero(left.f_dmtd_b_valid_i) or f_x_to_zero(right.f_dmtd_b_valid_i);
return tmp;
end function;
end package body;
