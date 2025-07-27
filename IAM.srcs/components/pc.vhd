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
  Port (
    clk    : in std_logic;
    rst    : in std_logic; -- active high
    pc_in  : in std_logic_vector(31 downto 0);
    
    pc_out : out std_logic_vector(31 downto 0)
    );
end PC;

architecture Behavioral of PC is

signal pc_buf : std_logic_vector(31 downto 0);

begin

process(clk, rst)
begin
    if rst = '1' then
        pc_buf <= (others => '0');
    elsif rising_edge(clk) then
        pc_buf <= pc_in;
    end if;
end process;

pc_out <= pc_buf;

end Behavioral;
