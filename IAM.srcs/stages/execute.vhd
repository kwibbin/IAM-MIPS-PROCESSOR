----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/27/2025 09:15:06 PM
-- Design Name:
-- Module Name: execute - Behavioral
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

entity execute is
    generic (
        mux_n         : positive := 2;
        data_width    : positive := 32;
        reg_i_width   : positive := 5
    );
    port (
        clk           : in std_logic;
        rst           : in std_logic;

        ctrl_flags    : in std_logic_vector(11 downto 0);
        instr_20_0    : in std_logic_vector(20 downto 0);
        pc_in         : in std_logic_vector(data_width - 1 downto 0);
        reg_d_1       : in std_logic_vector(data_width - 1 downto 0);
        reg_d_2       : in std_logic_vector(data_width - 1 downto 0);
        branch_offset : in std_logic_vector(data_width - 1 downto 0);

        alu_z         : out std_logic;
        write_reg     : out std_logic_vector(reg_i_width - 1 downto 0);
        branch_addr   : out std_logic_vector(data_width - 1 downto 0);
        jump_addr     : out std_logic_vector(data_width - 1 downto 0);
        pc_out        : out std_logic_vector(data_width - 1 downto 0);
        alu_out       : out std_logic_vector(data_width - 1 downto 0);
        read_d_2      : out std_logic_vector(data_width - 1 downto 0)
    );
end execute;

architecture Behavioral of execute is

signal shifted_branch_offset : std_logic_vector(data_width - 1 downto 0);

signal alu_mux_d             : std_logic_vector(data_width * mux_n - 1 downto 0);
signal alu_mux_sel           : natural range 0 to mux_n - 1;
signal write_reg_mux_d       : std_logic_vector(reg_i_width * mux_n - 1 downto 0);
signal write_reg_mux_sel     : natural range 0 to mux_n - 1;

signal alu_in_2              : std_logic_vector(data_width - 1 downto 0);
signal alu_ctrl_in           : std_logic_vector(3 downto 0);

begin

process(ctrl_flags)
begin
    if ctrl_flags(0) = '1' then   -- reg_dst
        write_reg_mux_sel <= 1;
    else
        write_reg_mux_sel <= 0;
    end if;
    if ctrl_flags(10) = '1' then -- alu_src
        alu_mux_sel <= 1;
    else
        alu_mux_sel <= 0;
    end if;
end process;

alu_mux_d       <= branch_offset & reg_d_2;
write_reg_mux_d <= instr_20_0(20 downto 16) & instr_20_0(15 downto 11); -- rt concat rd

execute_adder : entity work.adder(Behavioral)
    generic map(
        out_width => data_width
    )
    port map (
        in_d1 => pc_in,
        in_d2 => shifted_branch_offset,
        out_d => branch_addr
    );

alu_ctrl : entity work.alu_ctrl(Behavioral)
    port map(
        alu_op_in => ctrl_flags(8 downto 5),
        func => instr_20_0(5 downto 0),
        alu_op_out => alu_ctrl_in
    );

alu_in_mux : entity work.mux(Behavioral)
    generic map (
        in_n => mux_n,
        out_width => data_width
    )
    port map (
        sel => alu_mux_sel,
        in_d => alu_mux_d,
        out_d => alu_in_2
    );

alu : entity work.alu(Behavioral)
    generic map (
        data_width => data_width
    )
    port map(
        in_d1 => reg_d_1,
        in_d2 => alu_in_2,
        alu_ctrl => alu_ctrl_in,
        zero => alu_z,
        out_d => alu_out
    );

write_reg_mux : entity work.mux(Behavioral)
    generic map (
        in_n => mux_n,
        out_width => reg_i_width
    )
    port map (
        sel => write_reg_mux_sel,
        in_d => write_reg_mux_d,
        out_d => write_reg
    );

pc_out <= pc_in;
read_d_2 <= reg_d_2;
shifted_branch_offset <= std_logic_vector(shift_left(unsigned(branch_offset), 2));
jump_addr <= std_logic_vector(resize(shift_left(unsigned(instr_20_0(15 downto 0)), 2), data_width));

end Behavioral;