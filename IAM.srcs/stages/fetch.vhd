----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: fetch - Behavioral
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
--     Includes PC, Instr Mem, 2x1 Mux, Adder, & AND gate
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fetch is
    generic (
        mux_n            : positive := 2;
        magic_width      : positive := 16;
        addr_width       : positive := 32;
        data_width       : positive := 32;
        alignment        : std_logic_vector(3 downto 0) := "0100"
    );
    port (
        rst              : in std_logic;

        -- ctrl unit branch/j flags, branch/jump/pc addr | from mem
        branch_mm        : in natural range 0 to 1;
        jump_mm          : in natural range 0 to 1;
        branch_j_addr_mm : in std_logic_vector(addr_width - 1 downto 0);

        -- hazard ctrl flag, pc + 4, pc | from id
        pc_hold_id       : in natural range 0 to 1;
        pc_p4_id         : in std_logic_vector(addr_width - 1 downto 0);
        pc_hold          : in std_logic_vector(addr_width - 1 downto 0);

        -- pc, pc + 4, instr[31:0] | to id
        pc_if            : out std_logic_vector(addr_width - 1 downto 0);
        pc_p4_if         : out std_logic_vector(addr_width - 1 downto 0);
        instr_if         : out std_logic_vector(data_width - 1 downto 0)
    );
end fetch;

architecture Behavioral of fetch is


constant mux_3_n    : positive := 3;
signal mux_sel      : natural range 0 to mux_3_n - 1;
signal mux_packed_d : std_logic_vector(addr_width * mux_3_n - 1 downto 0);
signal mux_out      : std_logic_vector(addr_width - 1 downto 0);
signal pc_s         : std_logic_vector(addr_width - 1 downto 0);

begin

process(branch_mm, jump_mm, pc_hold_id)
begin
    if pc_hold_id = 1 then
        mux_sel <= 2;
    elsif branch_mm = 1 or jump_mm = 1 then
        mux_sel <= 1;
    else
        mux_sel <= 0;
    end if;
end process;

mux_packed_d <= pc_hold & branch_j_addr_mm & pc_p4_id;

fetch_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_3_n,
        out_width => addr_width
    )
    port map (
        sel   => mux_sel,
        in_d  => mux_packed_d,

        out_d => mux_out
    );

fetch_pc : entity work.pc(Behavioral)
    generic map (
        addr_width  => addr_width
    )
    port map (
        rst    => rst,
        pc_in  => mux_out,

        pc_out => pc_s
    );

fetch_instr_mem : entity work.instruction_mem(Behavioral)
    generic map(
        magic_width => magic_width,
        addr_width  => addr_width,
        data_width  => data_width
    )
    port map (
        pc    => pc_s(magic_width - 1 downto 0),

        instr => instr_if
    );

fetch_adder : entity work.adder(Behavioral)
    generic map(
        out_width => addr_width
    )
    port map (
        in_d1 => pc_s,
        in_d2 => std_logic_vector(resize(unsigned(alignment), addr_width)),
        out_d => pc_p4_if
    );

pc_if <= pc_s;

end Behavioral;