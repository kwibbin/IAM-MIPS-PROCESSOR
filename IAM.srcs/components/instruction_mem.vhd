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
        -- addi $2, $0, 4
        4 => "00000100",
        5 => "00000010",
        6 => "00000000",
        7 => "00000100",
        -- addi $3, $0, 4
        8 => "00000100",
        9 => "00000011",
        10 => "00000000",
        11 => "00000100",
        -- addi $1, $0, 4

        -- NOPS
        12 => "00000000",
        13 => "00000000",
        14 => "00000000",
        15 => "00000000",

        16 => "00000000",
        17 => "00000000",
        18 => "00000000",
        19 => "00000000",

        20 => "00000000",
        21 => "00000000",
        22 => "00000000",
        23 => "00000000",

        -- DATA MEM TEST
        -- sw $1, 4($0)
        24 => "00101000",
        25 => "00000001",
        26 => "00000000",
        27 => "00000100",
        -- DATA MEM TEST

        -- FW TEST
        -- addi $1, $1, 6
        28 => "00000100",
        29 => "00100001",
        30 => "00000000",
        31 => "00000110",
        -- addi $1, $1, 6
        32 => "00000100",
        33 => "00100001",
        34 => "00000000",
        35 => "00000110",
        -- FW TEST

        -- HZRD TEST
        -- lw $2, 4($0)
        36 => "00100100",
        37 => "00000010",
        38 => "00000000",
        39 => "00000100",
        -- addi $2, $2, 4
        40 => "00000100",
        41 => "01000010",
        42 => "00000000",
        43 => "00000100",
        -- HZRD TEST


        -- 00000100 00000001 00000000 00000100 ----------- addi $1, $0, 4
        -- 00101000 00000001 00000000 00000100 ----------- sw $1, 4($0)

        -- x => "00000000",

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
