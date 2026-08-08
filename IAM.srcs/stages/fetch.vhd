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

use work.cond_logic_helpers.next_pc_sel;

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

        -- hazard ctrl flag, predicted next pc, pc | from id
        pc_hold_id       : in natural range 0 to 1;
        pc_next_id       : in std_logic_vector(addr_width - 1 downto 0);
        pc_id            : in std_logic_vector(addr_width - 1 downto 0);

        -- alu zero flag, ctrl_unit branch flag, pc_ex[9:2], branch target | from ex
        alu_z_ex         : in std_logic;
        branch_ex        : in std_logic;
        pc_enc_ex        : in std_logic_vector(7 downto 0);
        branch_addr_ex   : in std_logic_vector(addr_width - 1 downto 0);

        -- misprediction flag and the pc to resume from | from ex
        mispredict_ex    : in std_logic;
        recover_pc_ex    : in std_logic_vector(addr_width - 1 downto 0);

        -- ctrl unit jump flag, jump/pc addr | from mem
        jump_mm          : in natural range 0 to 1;
        branch_j_addr_mm : in std_logic_vector(addr_width - 1 downto 0);

        -- pc, predicted next pc, instr[31:0], branch prediction | to id
        pc_if            : out std_logic_vector(addr_width - 1 downto 0);
        pc_next_if       : out std_logic_vector(addr_width - 1 downto 0);
        instr_if         : out std_logic_vector(data_width - 1 downto 0);
        pred_taken_if    : out std_logic
    );
end fetch;

architecture Behavioral of fetch is

constant mux_3_n    : positive := 3;
signal mux_sel      : natural range 0 to mux_3_n - 1;
signal mux_packed_d : std_logic_vector(addr_width * mux_3_n - 1 downto 0);
signal mux_out      : std_logic_vector(addr_width - 1 downto 0);
signal pc_actual    : std_logic_vector(addr_width - 1 downto 0);
signal pc_p4        : std_logic_vector(addr_width - 1 downto 0);

begin

mux_sel <= next_pc_sel(mispredict_ex, jump_mm);

-- recovery 2, resolved jump 1, predicted next pc 0
mux_packed_d <= recover_pc_ex & branch_j_addr_mm & pc_next_id;

-- the instruction at pc_actual is the one being fetched; the prediction only
-- decides where the *following* fetch goes, so it must not disturb this address
pc_if <= pc_actual;

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

        pc_out => pc_actual
    );

branch_prediction : entity work.branch_pred(Behavioral)
    generic map (
        addr_width     => addr_width
    )
    port map (
        clk            => clk,
        rst            => rst,

        pc_if          => pc_actual,
        pc_p4_if       => pc_p4,

        branch_ex      => branch_ex,
        z_ex           => alu_z_ex,
        pc_enc_ex      => pc_enc_ex,
        branch_addr_ex => branch_addr_ex,

        pred_pc        => pc_next_if,
        pred_taken     => pred_taken_if
    );

fetch_instr_mem : entity work.instruction_mem(Behavioral)
    generic map(
        magic_width => magic_width,
        addr_width  => addr_width,
        data_width  => data_width
    )
    port map (
        pc    => pc_actual(magic_width - 1 downto 0),

        instr => instr_if
    );

fetch_adder : entity work.adder(Behavioral)
    generic map(
        out_width => addr_width
    )
    port map (
        in_d1 => pc_actual,
        in_d2 => std_logic_vector(resize(unsigned(alignment), addr_width)),
        out_d => pc_p4
    );

end Behavioral;
