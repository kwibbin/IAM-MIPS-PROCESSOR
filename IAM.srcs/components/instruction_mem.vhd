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
    -- branch prediction test; see instr_mem_ex/branch_pred.txt
    --
    -- the bht starts at weak not-taken and the btb starts empty, so a branch has
    -- to run more than once before it can ever be predicted taken. the loop below
    -- runs its branch 3 times to walk every predictor state:
    --
    --   pass 1  btb miss     -> predict nt, resolves taken     -> mispredict
    --   pass 2  btb hit, 10  -> predict t,  resolves taken     -> correct, no bubble
    --   pass 3  btb hit, 11  -> predict t,  resolves not taken -> mispredict, recover to pc + 4
    --
    -- expected end state: $1 = 0, $2 = 3, $3 = 7, $4 = 0, $5 = 5
    -- $4 is the flush canary: it is only ever written from a wrong path, so a
    -- non-zero $4 means a mispredicted instruction was allowed to retire
    signal instr_ROM : mem_arr := (
        --  0x0 | 04010003 | addi $1, $0, 3   loop counter
        0 => "00000100",
        1 => "00000001",
        2 => "00000000",
        3 => "00000011",

        --  0x4 | 04020000 | addi $2, $0, 0   iteration counter
        4 => "00000100",
        5 => "00000010",
        6 => "00000000",
        7 => "00000000",

        --  0x8 | 04040000 | addi $4, $0, 0   flush canary
        8 => "00000100",
        9 => "00000100",
        10 => "00000000",
        11 => "00000000",

        -- 0xC | 04420001 | addi $2, $2, 1   LOOP:
        12 => "00000100",
        13 => "01000010",
        14 => "00000000",
        15 => "00000001",

        -- 0x10 | 0421ffff | addi $1, $1, -1  negative imm, exercises sign extension
        16 => "00000100",
        17 => "00100001",
        18 => "11111111",
        19 => "11111111",

        -- 0x14 | 1820fffe | bgtz $1, -2      backwards to LOOP, target 20 - 8 = 12
        20 => "00011000",
        21 => "00100000",
        22 => "11111111",
        23 => "11111110",

        -- 0x18 | 04030007 | addi $3, $0, 7   loop exit lands here
        24 => "00000100",
        25 => "00000011",
        26 => "00000000",
        27 => "00000111",

        -- 0x1C | 08000002 | beq $0, $0, 2    always taken, forward, target 28 + 8 = 36
        28 => "00001000",
        29 => "00000000",
        30 => "00000000",
        31 => "00000010",

        -- 0x20 | 04040009 | addi $4, $0, 9   SHOULD GET FLUSHED, never reachable otherwise
        32 => "00000100",
        33 => "00000100",
        34 => "00000000",
        35 => "00001001",

        -- 0x24 | 04050005 | addi $5, $0, 5   end marker
        36 => "00000100",
        37 => "00000101",
        38 => "00000000",
        39 => "00000101",

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
