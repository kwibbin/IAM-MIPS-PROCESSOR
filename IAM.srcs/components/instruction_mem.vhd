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
        -- -- predict nt, actually taken.
        -- -- beq $0, $0, 128
        -- 0 => "00001000",
        -- 1 => "00000000",
        -- 2 => "00000000",
        -- 3 => "00100000",
        -- -- predict nt, actually taken.
        0 => "00000000",
        1 => "00000000",
        2 => "00000000",
        3 => "00000000",

        -- SHOULD GET FLUSHED
        -- addi $2, $0, 2
        4 => "00000100",
        5 => "00000010",
        6 => "00000000",
        7 => "00000010",
        -- addi $3, $0, 4
        8 => "00000100",
        9 => "00000011",
        10 => "00000000",
        11 => "00001000",
        -- SHOULD GET FLUSHED

        -- Should set reg 1
        -- addi $1, $0, 4
        12 => "00000100",
        13 => "00000001",
        14 => "00000000",
        15 => "00000100",
        -- Should set reg 1

        -- predict t, actually nt.
        -- bneq $0, $0, 1
        16 => "00001100",
        17 => "00000000",
        18 => "00000000",
        19 => "00000001",
        -- predict t, actually nt.

        -- Increment reg 1; should happen after bneq flush
        -- addi $1, $0, 4
        20 => "00000100",
        21 => "00000001",
        22 => "00000000",
        23 => "00000001",
        -- Increment reg 1; should happen after bneq flush

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
