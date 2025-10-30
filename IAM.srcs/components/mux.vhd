----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: mux - Behavioral
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
--      computes conditional data bridges based on computed select modes
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
    generic (
        in_n : positive := 2;
        out_width : positive := 32
    );
    port (
        sel   : in natural range 0 to in_n - 1;
        in_d  : in std_logic_vector(in_n * out_width - 1 downto 0);

        out_d : out std_logic_vector(out_width - 1 downto 0)
    );
end mux;

architecture Behavioral of mux is

begin

process(in_d, sel)
begin
    out_d <= in_d((sel + 1) * out_width - 1 downto sel * out_width);
end process;

end Behavioral;
