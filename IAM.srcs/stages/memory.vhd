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
--      memory stage of 5-stage mips processor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory is
    generic (
        mux_n          : positive := 2;
        reg_i_width    : positive := 5;
        magic_width    : positive := 16;
        addr_width     : positive := 32;
        data_width     : positive := 32
    );
    port (
        clk            : in std_logic;

        -- ctrl_unit flags, j addr, pc, alu calculation, forwarding data, w reg | from ex
        ctrl_flags_ex  : in std_logic_vector(5 downto 0); -- mem_r 5, branch 4, jump 3, mem_to_reg 2, mem_w 1, reg_w 0
        jump_addr_ex   : in std_logic_vector(addr_width - 1 downto 0);
        pc_ex          : in std_logic_vector(addr_width - 1 downto 0);
        alu_ex         : in std_logic_vector(data_width - 1 downto 0);
        fw_mm_w_d_ex   : in std_logic_vector(data_width - 1 downto 0);
        w_reg_ex       : in std_logic_vector(reg_i_width - 1 downto 0);

        -- ctrl_unit j flag, j address | to if
        jump_mm        : out natural range 0 to mux_n - 1;
        return_addr_mm : out std_logic_vector(addr_width - 1 downto 0);

        -- ctrl unit flags, mem r data, alu calculation, w reg | to wb
        mem_to_reg_mm  : out std_logic;
        reg_w_mm       : out std_logic;
        mem_r_d_mm     : out std_logic_vector(data_width - 1 downto 0);
        alu_mm         : out std_logic_vector(data_width - 1 downto 0);
        w_reg_mm       : out std_logic_vector(reg_i_width - 1 downto 0)
    );
end memory;

architecture Behavioral of memory is

signal resolved_jump    : natural range 0 to mux_n - 1;

signal mux1_jump_packed : std_logic_vector(addr_width * mux_n - 1 downto 0);

alias addr              : std_logic_vector(magic_width - 1 downto 0) is alu_ex(magic_width - 1 downto 0);

begin

-- branches are resolved in ex against the prediction; only the unconditional
-- jumps still redirect the pc from here
process(ctrl_flags_ex(3))
begin
    resolved_jump <= 1 when ctrl_flags_ex(3) = '1' else 0; --jump 3
end process;

mux1_jump_packed <= jump_addr_ex & pc_ex;

process(alu_ex, w_reg_ex, ctrl_flags_ex)
begin
    alu_mm        <= alu_ex;
    w_reg_mm      <= w_reg_ex;
    mem_to_reg_mm <= ctrl_flags_ex(2);
    reg_w_mm      <= ctrl_flags_ex(0);
end process;

-- to if
jump_mm <= resolved_jump;

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
        magic_width => magic_width,
        addr_width => addr_width,
        data_width => data_width
    )
    port map(
        clk   => clk,

        mem_w => ctrl_flags_ex(1),
        mem_r => ctrl_flags_ex(5),

        addr  => addr,
        w_d   => fw_mm_w_d_ex,

        r_d   => mem_r_d_mm
    );

end Behavioral;
