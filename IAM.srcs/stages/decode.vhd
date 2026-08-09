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
--      decode stage of 5-stage mips processor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.cond_logic_helpers.check_flush;

entity decode is
    generic (
        mux_n          : positive := 2;
        reg_i_width    : positive := 5;
        magic_width    : positive := 16;
        addr_width     : positive := 32;
        data_width     : positive := 32
    );
    port (
        clk            : in std_logic;

        -- ctrl_unit flag, w register, and w data | from wb
        reg_w_wb       : in std_logic;
        w_reg_wb       : in std_logic_vector(4 downto 0);
        w_d_wb         : in std_logic_vector(data_width - 1 downto 0);

        -- pc, predicted next pc, instr, branch prediction | from if
        pc_if          : in std_logic_vector(addr_width - 1 downto 0);
        pc_next_if     : in std_logic_vector(addr_width - 1 downto 0);
        instr_if       : in std_logic_vector(data_width - 1 downto 0);
        pred_taken_if  : in std_logic;

        -- misprediction flag | from ex
        mispredict_ex  : in std_logic;

        -- hazard ctrl flag, predicted next pc | to if
        pc_hold_id     : out natural range 0 to 1;
        pc_next_id     : out std_logic_vector(addr_width - 1 downto 0);

        -- hazard ctrl flag | to if/id
        if_id_hold_id  : out natural range 0 to 1;

        -- ctrl_unit flags, instr[25:0], pc, reg data 1/2, branch prediction | to ex
        ctrl_flags_id  : out std_logic_vector(11 downto 0);
        instr_25_0_id  : out std_logic_vector(25 downto 0);
        pc_id          : out std_logic_vector(addr_width - 1 downto 0);
        reg_d_1_id     : out std_logic_vector(data_width - 1 downto 0);
        reg_d_2_id     : out std_logic_vector(data_width - 1 downto 0);
        pred_taken_id  : out std_logic
    );
end decode;

architecture Behavioral of decode is

signal nop_ctrl       : natural range 0 to 1 := 0; -- controls NOP injections
signal flush_id       : natural range 0 to 1; -- nop_ctrl or a misprediction in ex
signal ctrl_flags_buf : std_logic_vector(11 downto 0); -- temp ctrl flags storage
constant nop          : std_logic_vector(11 downto 0) := x"000";
signal mux_packed_d   : std_logic_vector(23 downto 0);

alias opcode          : std_logic_vector(5 downto 0) is instr_if(data_width - 1 downto 26);
alias rs              : std_logic_vector(reg_i_width - 1 downto 0) is instr_if(25 downto 21);
alias rt              : std_logic_vector(reg_i_width - 1 downto 0) is instr_if(20 downto 16);
alias func            : std_logic_vector(5 downto 0) is instr_if(5 downto 0);

begin

pc_id          <= pc_if;
instr_25_0_id  <= instr_if(25 downto 0);
mux_packed_d   <= nop & ctrl_flags_buf;

-- the instruction sitting here when ex reports a misprediction was fetched off
-- the wrong path, so it gets NOP'd out the same way a hazard bubble does
flush_id       <= check_flush(mispredict_ex, nop_ctrl);

-- a flushed instruction must not carry its prediction forward; ex would read it
-- back as a misprediction and redirect the pc a second time
pred_taken_id  <= pred_taken_if when flush_id = 0 else '0';

-- to if
pc_next_id <= pc_next_if;

ctrl_unit : entity work.ctrl_unit(Behavioral)
    port map (
        instr_if   => instr_if,

        reg_dst    => ctrl_flags_buf(0),
        jump       => ctrl_flags_buf(1),
        branch     => ctrl_flags_buf(2),
        mem_r      => ctrl_flags_buf(3),
        mem_to_reg => ctrl_flags_buf(4),
        alu_op     => ctrl_flags_buf(8 downto 5),
        mem_w      => ctrl_flags_buf(9),
        alu_src    => ctrl_flags_buf(10),
        reg_w      => ctrl_flags_buf(11)
    );

reg_file : entity work.reg_mem(Behavioral)
    port map (
        clk       => clk,

        reg_w     => reg_w_wb,
        w_reg     => w_reg_wb,
        w_d       => w_d_wb,

        r_reg1    => rs,
        r_reg2    => rt,

        r_d1      => reg_d_1_id,
        r_d2      => reg_d_2_id
    );

hzrd_unit : entity work.hazard_ctrl(Behavioral)
    generic map (
        reg_i_width
    )
    port map (
        clk        => clk,

        -- from id
        opcode     => opcode,
        rs_rt_id   => rs & rt,
        func       => func,

        pc_hold    => pc_hold_id,
        if_id_hold => if_id_hold_id,
        nop_ctrl   => nop_ctrl
    );

nop_ctrl_hazard_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_n,
        out_width => 12
    )
    port map (
        sel   => flush_id,
        in_d  => mux_packed_d,

        out_d => ctrl_flags_id
    );

end Behavioral;
