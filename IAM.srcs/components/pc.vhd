----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: pc - Behavioral
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

entity PC is
    generic (
        addr_width  : positive := 32
    );
    port (
        rst    : in std_logic;
        pc_in  : in std_logic_vector(addr_width - 1 downto 0);

        pc_out : out std_logic_vector(addr_width - 1 downto 0)
    );
end PC;

architecture Behavioral of PC is

begin

process(rst, pc_in)
begin
    pc_out(addr_width - 1 downto 0) <= pc_in when rst /= '1' else (others => '0');
end process;

end Behavioral;
