----------------------------------------------------------------------------------
-- Engineer: kwibbin
-- 
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name: 
-- Module Name: shift_reg - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity shift_reg is
    Port (
        in_d  : in std_logic_vector(31 downto 0);
        out_d : out std_logic_vector(31 downto 0)
    );
end shift_reg;

architecture Behavioral of shift_reg is

begin

    out_d <= std_logic_vector(shift_left(unsigned(in_d), 2));

end Behavioral;
