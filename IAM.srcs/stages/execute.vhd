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
--      execute stage of 5-stage mips processor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity execute is
    generic (
        reg_i_width         : positive := 5;
        addr_width          : positive := 32;
        data_width          : positive := 32
    );
    port (
        -- ctrl_unit flags, instr[25:0], pc, reg_d_1/2, branch/j addr | from id
        ctrl_flags_id       : in std_logic_vector(11 downto 0);
        instr_25_0_id       : in std_logic_vector(25 downto 0);
        pc_id               : in std_logic_vector(addr_width - 1 downto 0);
        reg_d_1_id          : in std_logic_vector(data_width - 1 downto 0);
        reg_d_2_id          : in std_logic_vector(data_width - 1 downto 0);
        jump_branch_addr_id : in std_logic_vector(addr_width - 1 downto 0);

        -- ctrl_unit flag, reg file w reg | from mm
        reg_w_mm            : in std_logic;
        w_reg_mm            : in std_logic_vector(4 downto 0);
        w_d_mm              : in std_logic_vector(data_width - 1 downto 0);

        -- ctrl unit flag, reg file w reg, w data | from wb
        reg_w_wb            : in std_logic;
        w_reg_wb            : in std_logic_vector(4 downto 0);
        w_d_wb              : in std_logic_vector(data_width - 1 downto 0);

        -- alu zero flag, ctrl_unit flags, branch/j addr, pc, alu calculation, reg data 2, forwarding data, w reg | to mem
        alu_z_ex            : out std_logic;
        ctrl_flags_ex       : out std_logic_vector(5 downto 0);
        branch_addr_ex      : out std_logic_vector(addr_width - 1 downto 0);
        jump_addr_ex        : out std_logic_vector(addr_width - 1 downto 0);
        pc_ex               : out std_logic_vector(addr_width - 1 downto 0);
        alu_ex              : out std_logic_vector(data_width - 1 downto 0);
        fw_mm_w_d_ex        : out std_logic_vector(data_width - 1 downto 0);
        w_reg_ex            : out std_logic_vector(reg_i_width - 1 downto 0)
    );
end execute;

architecture Behavioral of execute is

constant mux_2_n             : positive := 2;
constant mux_3_n             : positive := 3;
constant mux_4_n             : positive := 4;

signal shft_jump_branch_addr : std_logic_vector(addr_width - 1 downto 0);

signal w_reg_mux_d           : std_logic_vector(reg_i_width * mux_2_n - 1 downto 0);
signal w_reg_mux_sel         : natural range 0 to mux_2_n - 1;

signal alu_ctrl              : std_logic_vector(3 downto 0);

-- forwarding unit sigs
signal fw_d_1_sel            : natural range 0 to mux_3_n - 1;
signal fw_d_2_sel            : natural range 0 to mux_4_n - 1;
signal fw_w_d_sel            : natural range 0 to mux_3_n - 1;
signal fw_1_d                : std_logic_vector(data_width * mux_3_n - 1 downto 0);
signal fw_2_d                : std_logic_vector(data_width * mux_4_n - 1 downto 0);
signal fw_w_d                : std_logic_vector(data_width * mux_3_n - 1 downto 0);
signal fw_alu_1_d            : std_logic_vector(data_width - 1 downto 0);
signal fw_alu_2_d            : std_logic_vector(data_width - 1 downto 0);

alias rs                     : std_logic_vector(reg_i_width - 1 downto 0) is instr_25_0_id(25 downto 21);
alias rt                     : std_logic_vector(reg_i_width - 1 downto 0) is instr_25_0_id(20 downto 16);
alias rd                     : std_logic_vector(reg_i_width - 1 downto 0) is instr_25_0_id(15 downto 11);
alias shamt                  : std_logic_vector(4 downto 0) is instr_25_0_id(10 downto 6);
alias func                   : std_logic_vector(5 downto 0) is instr_25_0_id(5 downto 0);

begin

process(ctrl_flags_id)
begin
    w_reg_mux_sel <= 0 when ctrl_flags_id(0) = '1' else 1; -- reg_dst
end process;

shft_jump_branch_addr <= std_logic_vector(shift_left(unsigned(jump_branch_addr_id), 2));

-- forwarding unit driven packed data
-- wb data 95:64, mm data 63:32, reg 1 read data 31:0
fw_1_d <= w_d_wb & w_d_mm & reg_d_1_id;

-- (branch offset or imm) << 2 127:96, wb data 95:64, mm data 63:32, reg 2 read data 31:0
fw_2_d <= shft_jump_branch_addr & w_d_wb & w_d_mm & reg_d_2_id;

-- wb data 95:64, mm data 63:32, reg 2 read data 31:0
fw_w_d <= w_d_wb & w_d_mm & reg_d_2_id;

-- rt 9:5 rd 4:0
w_reg_mux_d <= rt & rd;

pc_ex         <= pc_id;
jump_addr_ex  <= shft_jump_branch_addr;

-- pack necessary ctrl flags
ctrl_flags_ex <= ctrl_flags_id(3 downto 1) -- mem_r 5, branch 4, jump 3
               & ctrl_flags_id(4) -- mem_to_reg 2
               & ctrl_flags_id(9) -- mem_w 1
               & ctrl_flags_id(11); -- reg_w 0

execute_adder : entity work.adder(Behavioral)
    generic map(
        out_width => addr_width
    )
    port map (
        in_d1 => pc_id,
        in_d2 => shft_jump_branch_addr,

        out_d => branch_addr_ex
    );

alu_ctrl_unit : entity work.alu_ctrl(Behavioral)
    port map(
        alu_op_in  => ctrl_flags_id(8 downto 5),
        func       => func,

        alu_op_out => alu_ctrl
    );

fw_unit : entity work.forwarding_unit(Behavioral)
        port map(
            jump_ex    => ctrl_flags_id(1),
            alu_src_ex => ctrl_flags_id(10),
            reg_d_1_ex => rs,
            reg_d_2_ex => rt,

            reg_w_mm   => reg_w_mm,
            w_reg_mm   => w_reg_mm,

            reg_w_wb   => reg_w_wb,
            w_reg_wb   => w_reg_wb,

            fw_d_1_sel => fw_d_1_sel,
            fw_d_2_sel => fw_d_2_sel,
            fw_w_d_sel => fw_w_d_sel
        );

fw_d_1_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_3_n,
        out_width => data_width
    )
    port map (
        sel   => fw_d_1_sel,
        in_d  => fw_1_d,

        out_d => fw_alu_1_d
    );

fw_d_2_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_4_n,
        out_width => data_width
    )
    port map (
        sel   => fw_d_2_sel,
        in_d  => fw_2_d,

        out_d => fw_alu_2_d
    );

fw_w_d_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_3_n,
        out_width => data_width
    )
    port map (
        sel   => fw_w_d_sel,
        in_d  => fw_w_d,

        out_d => fw_mm_w_d_ex
    );

alu : entity work.alu(Behavioral)
    generic map (
        data_width => data_width
    )
    port map(
        in_d1    => fw_alu_1_d,
        in_d2    => fw_alu_2_d,
        shamt    => shamt,
        alu_ctrl => alu_ctrl,

        zero     => alu_z_ex,
        out_d    => alu_ex
    );

w_reg_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_2_n,
        out_width => reg_i_width
    )
    port map (
        sel   => w_reg_mux_sel,
        in_d  => w_reg_mux_d,

        out_d => w_reg_ex
    );

end Behavioral;
