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
--      fetch stage of 5-stage mips processor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.cond_logic_helpers.check_pc_branch_jump;

entity fetch is
    generic (
        mux_n            : positive := 2;
        magic_width      : positive := 16;
        addr_width       : positive := 32;
        data_width       : positive := 32;
        alignment        : std_logic_vector(3 downto 0) := "0100"
    );
    port (
        clk              : in std_logic;
        rst              : in std_logic;

        -- hazard ctrl flag, branch pred en, branch pred pc, pc + 4, pc | from id
        pc_hold_id       : in natural range 0 to 1;
        pred_branch_id   : in natural range 0 to 1;
        pred_pc_id       : in std_logic_vector(addr_width - 1 downto 0);
        pc_p4_id         : in std_logic_vector(addr_width - 1 downto 0);
        pc_id            : in std_logic_vector(addr_width - 1 downto 0);

        -- alu zero flag, pc_ex [9:2] | from ex
        alu_z_ex         : in std_logic;
        branch_ex        : in std_logic;
        pc_enc_ex        : in std_logic_vector(7 downto 0);

        -- ctrl unit branch/j flags, branch/jump/pc addr | from mem
        branch_mm        : in natural range 0 to 1;
        jump_mm          : in natural range 0 to 1;
        branch_j_addr_mm : in std_logic_vector(addr_width - 1 downto 0);

        -- hzrd hold early release indicator for branch or jump events | to if/id
        hold_release_if  : out natural range 0 to 1;

        -- branch pred en, branch pred pc, pc, pc + 4, instr[31:0] | to id
        pred_branch_if   : out natural range 0 to 1;
        pred_pc_if       : out std_logic_vector(addr_width - 1 downto 0);
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

mux_sel <= check_pc_branch_jump(branch_mm, jump_mm, pred_branch_id);
hold_release_if <= 1 when branch_mm = 1 or jump_mm = 1 else 0;

pc_if <= pc_s;
mux_packed_d <= branch_j_addr_mm & pc_p4_id & pred_pc_id;

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

branch_prediction : entity work.branch_pred(Behavioral)
    port map (
        clk         => clk,

        pc_if       => pc_s,

        z           => alu_z_ex,
        branch_ex   => branch_ex,
        pc_enc_ex   => pc_enc_ex,

        pred_branch => pred_branch_if,
        pred_pc     => pred_pc_if
    );

end Behavioral;