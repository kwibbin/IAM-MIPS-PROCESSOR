----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/28/2025 06:44:06 PM
-- Design Name:
-- Module Name: adder - Behavioral
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

entity adder is
    generic (
        out_width    : positive := 32
    );
    port (
        in_d1, in_d2 : in std_logic_vector(out_width - 1 downto 0);

        out_d        : out std_logic_vector(out_width - 1 downto 0)
    );
end adder;

architecture Behavioral of adder is

begin

process(in_d1, in_d2)
begin
    out_d <= std_logic_vector(unsigned(in_d1) + unsigned(in_d2));
end process;

end Behavioral;
