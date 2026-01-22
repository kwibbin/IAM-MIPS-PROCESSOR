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
--      custom implementation of an inferred single-port ROM module in BRAM
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_mem is
    generic (
        magic_width : positive := 16;
        addr_width  : positive := 32;
        data_width  : positive := 32
    );
    port (
        pc    : in std_logic_vector(magic_width - 1 downto 0);

        instr : out std_logic_vector(data_width - 1 downto 0)
    );
end instruction_mem;

architecture Behavioral of instruction_mem is

    constant addr_range : natural := 2 ** magic_width - 1;  -- 64KB / 4-byte = 16K words
    type mem_arr is array(0 to addr_range) of std_logic_vector(7 downto 0);
    signal instr_ROM : mem_arr := (
        -- addi $1, $0, 4
        0 => "00000100",
        1 => "00000001",
        2 => "00000000",
        3 => "00000100",

        -- beq $1, $2, 0d12
        4 => "00001000",
        5 => "00100010",
        6 => "00000000",
        7 => "00001100",

        -- addi $1, $0, 4
        8 => "00000100",
        9 => "00000001",
        10 => "00000000",
        11 => "00000100",

        -- beq $1, $2, 0d4
        12 => "00001000",
        13 => "00100010",
        14 => "00000000",
        15 => "00000100",

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
