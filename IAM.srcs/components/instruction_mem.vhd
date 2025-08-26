----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: instruction_mem - Behavioral
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

entity instruction_mem is
    Port (
        clk   : in std_logic;
        pc    : in std_logic_vector(31 downto 0);
        instr : out std_logic_vector(31 downto 0)
    );
end instruction_mem;

architecture Behavioral of instruction_mem is

    constant addr_range : positive := 16383;  -- 64KB / 4-byte word = 16K words
    type mem_arr is array(0 to addr_range) of std_logic_vector(7 downto 0);
    signal instr_ROM : mem_arr := (

    others => (others => '0')
    );

    signal instr_buff : std_logic_vector(31 downto 0);   -- byte aligned

begin

    process(clk)
    begin
        if rising_edge(clk) then
            instr_buff(31 downto 24) <= instr_ROM(to_integer(unsigned(pc)));
            instr_buff(23 downto 16) <= instr_ROM(to_integer(unsigned(pc) + 1));
            instr_buff(15 downto 8)  <= instr_ROM(to_integer(unsigned(pc) + 2));
            instr_buff(7 downto 0)   <= instr_ROM(to_integer(unsigned(pc) + 3));
        end if;
    end process;

    instr <= instr_buff;

end Behavioral;
