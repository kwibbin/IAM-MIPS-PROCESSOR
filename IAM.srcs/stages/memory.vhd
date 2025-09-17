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
        reg_i_width    : positive := 5;
        addr_width     : positive := 16;
        data_width     : positive := 32
    );
    port (
        clk            : in std_logic;
        rst            : in std_logic;

        -- alu zero flag, ctrl_unit flags, branch/j addr, pc, alu computation, reg data 2, w reg | from ex
        alu_z_ex       : in std_logic;
        ctrl_flags_ex  : in std_logic_vector(5 downto 0); -- mem_r 5, branch 4, jump 3, mem_to_reg 2, mem_w 1, reg_w 0
        branch_addr_ex : in std_logic_vector(addr_width - 1 downto 0);
        jump_addr_ex   : in std_logic_vector(addr_width - 1 downto 0);
        pc_ex          : in std_logic_vector(addr_width - 1 downto 0);
        alu_ex         : in std_logic_vector(data_width - 1 downto 0);
        r_d_2_ex       : in std_logic_vector(data_width - 1 downto 0);
        w_reg_ex       : in std_logic_vector(reg_i_width - 1 downto 0);

        -- ctrl_unit branch/j flags, branch/j address | to if
        branch_mm      : out std_logic;
        jump_mm        : out std_logic;
        return_addr_mm : out std_logic_vector(addr_width - 1 downto 0);

        -- mem r data, alu computation, w reg
        mem_r_d_mm     : out std_logic_vector(data_width - 1 downto 0);
        alu_mm         : out std_logic_vector(data_width - 1 downto 0);
        w_reg_mm       : out std_logic_vector(reg_i_width - 1 downto 0);

        -- ctrl_unit flags | 2 & 0 to wb | 3 & 1 to if
        ctrl_flags_mm  : out std_logic_vector(3 downto 0)
    );
end memory;

architecture Behavioral of memory is

signal resolved_branch  : natural range 0 to mux_n - 1;
signal resolved_jump    : natural range 0 to mux_n - 1;
signal pc_branch_addr   : std_logic_vector(addr_width - 1 downto 0);

signal pc_branch_packed : std_logic_vector(addr_width * mux_n - 1 downto 0);
signal mux1_jump_packed : std_logic_vector(addr_width * mux_n - 1 downto 0);

signal branch_en        : std_logic;

begin

process(alu_z_ex, ctrl_flags_ex(3), ctrl_flags_ex(4))
begin
    resolved_branch <= 1 when alu_z_ex = '1' and ctrl_flags_ex(4) = '1' else 0; -- branch 4
    resolved_jump <= 1 when ctrl_flags_ex(3) = '1' else 0; --jump 3
end process;

pc_branch_packed <= branch_addr_ex & pc_ex;
mux1_jump_packed <= jump_addr_ex & pc_branch_addr;

branch_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_n,
        out_width => addr_width
    )
    port map (
        sel   => resolved_branch,
        in_d  => pc_branch_packed,

        out_d => pc_branch_addr
    );

jump_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_n,
        out_width => addr_width
    )
    port map (
        sel   => resolved_jump,
        in_d  => mux1_jump_packed,

        out_d => return_addr_mm
    );

data_mem : entity work.data_memory(Behavioral)
    generic map(
        data_width => data_width
    )
    port map(
        mem_w => ctrl_flags_ex(1),
        mem_r => ctrl_flags_ex(5),
        addr  => alu_ex(addr_width - 1 downto 0),
        w_d   => r_d_2_ex,

        r_d   => mem_r_d_mm
    );

w_reg_mm      <= w_reg_ex;
alu_mm        <= alu_ex;
branch_en     <= '1' when alu_z_ex = '1' and ctrl_flags_ex(4) = '1' else '0';
branch_mm     <= ctrl_flags_ex(1);
jump_mm       <= ctrl_flags_ex(3);
ctrl_flags_mm <= ctrl_flags_ex(3)  -- jump 3
                & ctrl_flags_ex(2)  -- mem_to_reg 2
                & branch_en         -- branch_en 1
                & ctrl_flags_ex(0); -- reg_w 0

end Behavioral;
