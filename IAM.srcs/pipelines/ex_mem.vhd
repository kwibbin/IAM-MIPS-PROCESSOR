----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: ex_mem - Behavioral
-- Project Name: IAM
-- Target Devices: Basys3 Artix 7 - XC7A35T-1CPG236C
-- Tool Versions: Vivado 2025.1
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ex_mem is
--  Port ( );
end ex_mem;

architecture Behavioral of ex_mem is

begin

-- alu_mux_d       <= branch_offset & reg_d_2; -- branch_off 63:32. reg_d_2 31:0
-- write_reg_mux_d <= instr_20_0(20 downto 16) & instr_20_0(15 downto 11); -- rt 9:5 rd 4:0

-- pack necessary ctrl flags
-- ctrl_flags_out <= ctrl_flags_in(3 downto 1) -- mem_r 5, branch 4, jump 3
--                 & ctrl_flags_in(4) -- mem_to_reg 2
--                 & ctrl_flags_in(9) -- mem_w 1
--                 & ctrl_flags_in(11); -- reg_w 0

end Behavioral;
