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
        addr_width       : positive := 16;
        data_width       : positive := 32
    );
    port (
        clk              : in std_logic;
        rst              : in std_logic;

        reg_w            : in std_logic;  -- ctrl unit flag from wb
        w_reg            : in std_logic_vector(4 downto 0); -- either instr[20:16] or instr[15:11] from wb
        w_d              : in std_logic_vector(data_width - 1 downto 0); -- write data from wb
        pc_in            : in std_logic_vector(addr_width - 1 downto 0);
        pc_p4_in         : in std_logic_vector(addr_width - 1 downto 0);
        instr            : in std_logic_vector(data_width - 1 downto 0);

        ctrl_flags       : out std_logic_vector(11 downto 0);
        instr_20_0       : out std_logic_vector(20 downto 0);
        pc_out           : out std_logic_vector(addr_width - 1 downto 0);
        pc_p4_out        : out std_logic_vector(addr_width - 1 downto 0);
        reg_d_1          : out std_logic_vector(data_width - 1 downto 0);
        reg_d_2          : out std_logic_vector(data_width - 1 downto 0);
        jump_branch_addr : out std_logic_vector(addr_width - 1 downto 0)
    );
end decode;

architecture Behavioral of decode is

begin

ctrl_unit : entity work.ctrl_unit(Behavioral)
    port map(
        opcode     => instr(31 downto 26),

        reg_dst    => ctrl_flags(0),
        jump       => ctrl_flags(1),
        branch     => ctrl_flags(2),
        mem_r      => ctrl_flags(3),
        mem_to_reg => ctrl_flags(4),
        alu_op     => ctrl_flags(8 downto 5),
        mem_w      => ctrl_flags(9),
        alu_src    => ctrl_flags(10),
        reg_w      => ctrl_flags(11)
    );

reg_file : entity work.reg_mem(Behavioral)
    port map(
        reg_w     => reg_w,
        r_reg1    => instr(25 downto 21),
        r_reg2    => instr(20 downto 16),
        w_reg     => w_reg,
        w_d       => w_d,

        r_d1      => reg_d_1,
        r_d2      => reg_d_2
    );

pc_out           <= pc_in;
pc_p4_out        <= pc_p4_in;
instr_20_0       <= instr(20 downto 0);
jump_branch_addr <= instr(addr_width - 1 downto 0);

end Behavioral;
