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
    generic (
        data_width : positive := 32;
        addr_width : positive := 16
    );
    port (
        -- clk   : in std_logic;
        pc    : in std_logic_vector(addr_width - 1 downto 0);
        instr : out std_logic_vector(data_width - 1 downto 0)
    );
end instruction_mem;

architecture Behavioral of instruction_mem is

    constant addr_range : natural := 2 ** addr_width - 1;  -- 64KB / 4-byte = 16K words
    type mem_arr is array(0 to addr_range) of std_logic_vector(7 downto 0);
    signal instr_ROM : mem_arr := (
        0 => "00001111",
        1 => "00001111",
        2 => "00001111",
        3 => "00001111",
        4 => "11110000",
        5 => "11110000",
        6 => "11110000",
        7 => "11110000",
        8 => "11111111",
        9 => "11111111",
        10 => "11111111",
        11 => "11111111",

        others => (others => '0')
    );

begin

    process(pc)
    begin
        instr(31 downto 24) <= instr_ROM(to_integer(unsigned(pc)));
        instr(23 downto 16) <= instr_ROM(to_integer(unsigned(pc) + 1));
        instr(15 downto 8)  <= instr_ROM(to_integer(unsigned(pc) + 2));
        instr(7 downto 0)   <= instr_ROM(to_integer(unsigned(pc) + 3));
    end process;

end Behavioral;
