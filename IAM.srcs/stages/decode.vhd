----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: decode - Behavioral
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

entity decode is
    generic (
        magic_width         : positive := 16;
        addr_width          : positive := 32;
        data_width          : positive := 32
    );
    port (
        -- ctrl_unit flag, w register, and w data | from wb
        reg_w_wb            : in std_logic;
        w_reg_wb            : in std_logic_vector(4 downto 0);
        w_d_wb              : in std_logic_vector(data_width - 1 downto 0);

        -- pc, pc + 4, and instr | from if
        pc_if               : in std_logic_vector(addr_width - 1 downto 0);
        pc_p4_if            : in std_logic_vector(addr_width - 1 downto 0);
        instr_if            : in std_logic_vector(data_width - 1 downto 0);

        -- pc + 4 | to if
        pc_p4_id            : out std_logic_vector(addr_width - 1 downto 0);

        -- w reg, ctrl_unit flags, instr[20:0], pc, pc + 4, reg data 1/2, jump/branch addr out | to ex
        w_reg_id            : out std_logic_vector(9 downto 0);
        ctrl_flags_id       : out std_logic_vector(11 downto 0);
        instr_25_0_id       : out std_logic_vector(25 downto 0);
        pc_id               : out std_logic_vector(addr_width - 1 downto 0);
        reg_d_1_id          : out std_logic_vector(data_width - 1 downto 0);
        reg_d_2_id          : out std_logic_vector(data_width - 1 downto 0)
    );
end decode;

architecture Behavioral of decode is

begin

process(pc_if, instr_if)
begin
    pc_id               <= pc_if;
    w_reg_id            <= instr_if(20 downto 11);
    instr_25_0_id       <= instr_if(25 downto 0);
end process;

-- to if
pc_p4_id <= pc_p4_if;

ctrl_unit : entity work.ctrl_unit(Behavioral)
    port map(
        -- opcode     => instr_if(31 downto 26),
        instr_if   => instr_if,

        reg_dst    => ctrl_flags_id(0),
        jump       => ctrl_flags_id(1),
        branch     => ctrl_flags_id(2),
        mem_r      => ctrl_flags_id(3),
        mem_to_reg => ctrl_flags_id(4),
        alu_op     => ctrl_flags_id(8 downto 5),
        mem_w      => ctrl_flags_id(9),
        alu_src    => ctrl_flags_id(10),
        reg_w      => ctrl_flags_id(11)
    );

reg_file : entity work.reg_mem(Behavioral)
    port map(
        reg_w     => reg_w_wb,
        r_reg1    => instr_if(25 downto 21),
        r_reg2    => instr_if(20 downto 16),
        w_reg     => w_reg_wb,
        w_d       => w_d_wb,

        r_d1      => reg_d_1_id,
        r_d2      => reg_d_2_id
    );

end Behavioral;
