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
        mux_n             : positive := 2;
        reg_i_width       : positive := 5;
        addr_width        : positive := 16;
        data_width        : positive := 32
    );
    port (
        clk               : in std_logic;
        rst               : in std_logic;

        ctrl_flags_in     : in std_logic_vector(11 downto 0);
        instr_20_0        : in std_logic_vector(20 downto 0);
        pc_in             : in std_logic_vector(addr_width - 1 downto 0);
        reg_d_1           : in std_logic_vector(data_width - 1 downto 0);
        reg_d_2           : in std_logic_vector(data_width - 1 downto 0);
        jump_branch_addr  : in std_logic_vector(addr_width - 1 downto 0);

        alu_z             : out std_logic;
        ctrl_flags_out    : out std_logic_vector(5 downto 0);
        branch_addr       : out std_logic_vector(addr_width - 1 downto 0);
        jump_addr         : out std_logic_vector(addr_width - 1 downto 0);
        pc_out            : out std_logic_vector(addr_width - 1 downto 0);
        alu_out           : out std_logic_vector(data_width - 1 downto 0);
        r_d_2             : out std_logic_vector(data_width - 1 downto 0);
        w_reg             : out std_logic_vector(reg_i_width - 1 downto 0)
    );
end execute;

architecture Behavioral of execute is

signal shft_jump_branch_addr : std_logic_vector(addr_width - 1 downto 0);

signal alu_mux_d             : std_logic_vector(data_width * mux_n - 1 downto 0);
signal alu_mux_sel           : natural range 0 to mux_n - 1;
signal w_reg_mux_d           : std_logic_vector(reg_i_width * mux_n - 1 downto 0);
signal w_reg_mux_sel         : natural range 0 to mux_n - 1;

signal alu_in_2              : std_logic_vector(data_width - 1 downto 0);
signal alu_ctrl_in           : std_logic_vector(3 downto 0);

begin

process(ctrl_flags_in)
begin
    w_reg_mux_sel <= 1 when ctrl_flags_in(0) = '1' else 0; -- reg_dst
    alu_mux_sel <= 1 when ctrl_flags_in(10) = '1' else 0; -- alu_src
end process;

alu_mux_d   <= shft_jump_branch_addr & reg_d_2; -- branch_off 63:32. reg_d_2 31:0
w_reg_mux_d <= instr_20_0(20 downto 16) & instr_20_0(15 downto 11); -- rt 9:5 rd 4:0

execute_adder : entity work.adder(Behavioral)
    generic map(
        out_width => data_width
    )
    port map (
        in_d1 => pc_in,
        in_d2 => shft_jump_branch_addr,
        out_d => branch_addr
    );

alu_ctrl : entity work.alu_ctrl(Behavioral)
    port map(
        alu_op_in  => ctrl_flags_in(8 downto 5),
        func       => instr_20_0(5 downto 0),
        alu_op_out => alu_ctrl_in
    );

alu_in_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_n,
        out_width => data_width
    )
    port map (
        sel   => alu_mux_sel,
        in_d  => alu_mux_d,
        out_d => alu_in_2
    );

alu : entity work.alu(Behavioral)
    generic map (
        data_width => data_width
    )
    port map(
        in_d1    => reg_d_1,
        in_d2    => alu_in_2,
        alu_ctrl => alu_ctrl_in,
        zero     => alu_z,
        out_d    => alu_out
    );

w_reg_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_n,
        out_width => reg_i_width
    )
    port map (
        sel   => w_reg_mux_sel,
        in_d  => w_reg_mux_d,
        out_d => w_reg
    );

pc_out <= pc_in;
r_d_2 <= reg_d_2;
jump_addr <= shft_jump_branch_addr;
shft_jump_branch_addr <= std_logic_vector(shift_left(unsigned(jump_branch_addr), 2));

-- pack necessary ctrl flags
ctrl_flags_out <= ctrl_flags_in(3 downto 1) -- mem_r 5, branch 4, jump 3
                & ctrl_flags_in(4) -- mem_to_reg 2
                & ctrl_flags_in(9) -- mem_w 1
                & ctrl_flags_in(11); -- reg_w 0

end Behavioral;