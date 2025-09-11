----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: memory - Behavioral
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

entity memory is
    generic (
        mux_n          : positive := 2;
        data_width     : positive := 32;
        reg_i_width    : positive := 5
    );
    port (
        clk            : in std_logic;
        rst            : in std_logic;

        alu_z          : in std_logic;
        ctrl_flags_in  : in std_logic_vector(5 downto 0); -- mem_r 5, branch 4, jump 3, mem_to_reg 2, mem_w 1, reg_w 0
        pc             : in std_logic_vector(data_width - 1 downto 0);
        branch_addr    : in std_logic_vector(data_width - 1 downto 0);
        jump_addr      : in std_logic_vector(data_width - 1 downto 0);
        mem_alu_in     : in std_logic_vector(data_width - 1 downto 0);
        r_d_2          : in std_logic_vector(data_width - 1 downto 0);
        w_reg_in       : in std_logic_vector(reg_i_width - 1 downto 0);

        ctrl_flags_out : out std_logic_vector(3 downto 0);
        mem_r_d        : out std_logic_vector(data_width - 1 downto 0);
        mem_alu_out    : out std_logic_vector(data_width - 1 downto 0);
        return_addr    : out std_logic_vector(data_width - 1 downto 0);
        w_reg_out      : out std_logic_vector(reg_i_width - 1 downto 0)

    );
end memory;

architecture Behavioral of memory is

signal resolved_branch  : natural range 0 to mux_n - 1;
signal resolved_jump    : natural range 0 to mux_n - 1;
signal pc_branch_addr   : std_logic_vector(data_width - 1 downto 0);

signal pc_branch_packed : std_logic_vector(data_width * mux_n - 1 downto 0);
signal mux1_jump_packed : std_logic_vector(data_width * mux_n - 1 downto 0);

signal branch_en        : std_logic;

begin

process(alu_z, ctrl_flags_in(4))
begin
    if alu_z = '1' and ctrl_flags_in(4) = '1' then --branch 4
        resolved_branch <= 1;
    else
        resolved_branch <= 0;
    end if;
    if ctrl_flags_in(3) = '1' then --jump 3
        resolved_jump <= 1;
    else
        resolved_jump <= 0;
    end if;
end process;

pc_branch_packed <= branch_addr & pc;
mux1_jump_packed <= jump_addr & pc_branch_addr;

branch_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_n,
        out_width => data_width
    )
    port map (
        sel   => resolved_branch,
        in_d  => pc_branch_packed,
        out_d => pc_branch_addr
    );

jump_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_n,
        out_width => data_width
    )
    port map (
        sel   => resolved_jump,
        in_d  => mux1_jump_packed,
        out_d => return_addr
    );

data_mem : entity work.data_memory(Behavioral)
    generic map(
        data_width => data_width
    )
    port map(
        mem_w => ctrl_flags_in(1),
        mem_r => ctrl_flags_in(5),
        addr  => mem_alu_in,
        w_d   => r_d_2,
        r_d   => mem_r_d
    );
branch_en <= '1' when alu_z = '1' and ctrl_flags_in(4) = '1' else '0';

w_reg_out      <= w_reg_in;
mem_alu_out    <= mem_alu_in;
ctrl_flags_out <= ctrl_flags_in(3)  -- jump 3
                & ctrl_flags_in(2)  -- mem_to_reg 2
                & branch_en         -- branch_en 1
                & ctrl_flags_in(0); -- reg_w 0

end Behavioral;
