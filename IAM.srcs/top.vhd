----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:16:12 PM
-- Design Name:
-- Module Name: top - Behavioral
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

entity top is
    generic (
        mux_n       : positive := 2;                         -- # of mux inputs
        reg_i_width : positive := 5;                         -- 2^5 = 32 registers
        magic_width : positive := 16;                        -- actual addressable range of PC/instr mem/data mem
        addr_width  : positive := 32;                        -- fake 32 bit addressable range masked by magic width
        data_width  : positive := 32;                        -- 32-bit
        alignment   : std_logic_vector(3 downto 0) := "0100" -- byte alignment
    );
    port (
        clk         : in std_logic;
        rst         : in std_logic
    );
end top;

architecture Behavioral of top is

-- fetch sigs -----------------------------------------------------------------
-- pc, pc + 4, instr[31:0] | to id
signal pc_if                  : std_logic_vector(addr_width - 1 downto 0);
signal pc_p4_if               : std_logic_vector(addr_width - 1 downto 0);
signal instr_if               : std_logic_vector(data_width - 1 downto 0);

-- if_id sigs -----------------------------------------------------------------
-- decode
signal pc_if_id               : std_logic_vector(addr_width - 1 downto 0);
signal pc_p4_if_id            : std_logic_vector(addr_width - 1 downto 0);
signal instr_if_id            : std_logic_vector(data_width - 1 downto 0);

-- decode sigs ----------------------------------------------------------------
-- w reg, ctrl_unit flags, instr[20:0], pc, pc + 4, reg data 1/2, jump/branch addr out | to ex
signal w_reg_id               : std_logic_vector(9 downto 0);
signal ctrl_flags_id          : std_logic_vector(11 downto 0);
signal instr_25_0_id          : std_logic_vector(25 downto 0);
signal pc_id                  : std_logic_vector(addr_width - 1 downto 0);
signal pc_p4_id               : std_logic_vector(addr_width - 1 downto 0);
signal reg_d_1_id             : std_logic_vector(data_width - 1 downto 0);
signal reg_d_2_id             : std_logic_vector(data_width - 1 downto 0);

-- id_ex sigs ----------------------------------------------------------------
-- execute
signal ctrl_flags_id_ex       : std_logic_vector(11 downto 0);
signal instr_25_0_id_ex       : std_logic_vector(25 downto 0);
signal pc_id_ex               : std_logic_vector(addr_width - 1 downto 0);
signal reg_d_1_id_ex          : std_logic_vector(data_width - 1 downto 0);
signal reg_d_2_id_ex          : std_logic_vector(data_width - 1 downto 0);
signal jump_branch_addr_id_ex : std_logic_vector(addr_width - 1 downto 0);

-- execute sigs ---------------------------------------------------------------
-- alu zero flag, ctrl_unit flags, branch/j addr, pc, alu computation, reg data 2, w reg | to mem
signal alu_z_ex               : std_logic;
signal ctrl_flags_ex          : std_logic_vector(5 downto 0);
signal branch_addr_ex         : std_logic_vector(addr_width - 1 downto 0);
signal jump_addr_ex           : std_logic_vector(addr_width - 1 downto 0);
signal pc_ex                  : std_logic_vector(addr_width - 1 downto 0);
signal alu_ex                 : std_logic_vector(data_width - 1 downto 0);
signal fw_mm_w_d_ex           : std_logic_vector(data_width - 1 downto 0);
signal w_reg_ex               : std_logic_vector(reg_i_width - 1 downto 0);

-- ex_mem sigs ----------------------------------------------------------------
-- mem
signal alu_z_ex_mm            : std_logic;
signal ctrl_flags_ex_mm       : std_logic_vector(5 downto 0); -- mem_r 5, branch 4, jump 3, mem_to_reg 2, mem_w 1, reg_w 0
signal pc_ex_mm               : std_logic_vector(addr_width - 1 downto 0);
signal branch_addr_ex_mm      : std_logic_vector(addr_width - 1 downto 0);
signal jump_addr_ex_mm        : std_logic_vector(addr_width - 1 downto 0);
signal alu_ex_mm              : std_logic_vector(data_width - 1 downto 0);
signal fw_mm_w_d_ex_mm        : std_logic_vector(data_width - 1 downto 0);
signal w_reg_ex_mm            : std_logic_vector(reg_i_width - 1 downto 0);

-- memory sigs ----------------------------------------------------------------
-- ctrl_unit branch/j flags, branch/j address | to if
signal branch_mm              : natural range 0 to mux_n - 1;
signal jump_mm                : natural range 0 to mux_n - 1;
signal return_addr_mm         : std_logic_vector(addr_width - 1 downto 0);

-- mem r data, alu computation, w reg
signal mem_to_reg_mm          : std_logic;
signal reg_w_mm               : std_logic;
signal mem_r_d_mm             : std_logic_vector(data_width - 1 downto 0);
signal alu_mm                 : std_logic_vector(data_width - 1 downto 0);
signal w_reg_mm               : std_logic_vector(reg_i_width - 1 downto 0);

-- mem_wb sigs ----------------------------------------------------------------
-- write back
signal mem_to_reg_mm_wb       : std_logic;
signal reg_w_mm_wb            : std_logic;
signal mem_r_d_mm_wb          : std_logic_vector(data_width - 1 downto 0);
signal alu_mm_wb              : std_logic_vector(data_width - 1 downto 0);
signal w_reg_mm_wb            : std_logic_vector(reg_i_width - 1 downto 0);

-- write back sigs ------------------------------------------------------------
-- ctrl_unit flag, w data, w reg  | to id
signal reg_w_wb               : std_logic;
signal w_d_wb                 : std_logic_vector(data_width - 1 downto 0);
signal w_reg_wb               : std_logic_vector(reg_i_width - 1 downto 0);

-- END SIGNALS ----------------------------------------------------------------

begin

-- fetch
fetch_stage : entity work.fetch(Behavioral)
    generic map(
        mux_n, magic_width, addr_width, data_width, alignment
    )
    port map (
        clk              => clk,
        rst              => rst,

        -- ctrl unit branch/j flags, branch/jump/pc addr | from mem
        branch_mm        => branch_mm,
        jump_mm          => jump_mm,
        branch_j_addr_mm => return_addr_mm,

        -- pc + 4 | from id
        pc_p4_id         => pc_p4_id,

        -- pc, pc + 4, instr[31:0] | to id
        pc_if            => pc_if,
        pc_p4_if         => pc_p4_if,
        instr_if         => instr_if
    );



-- if_id pipeline reg
if_id_reg : entity work.if_id(Behavioral)
    generic map (
        mux_n, addr_width, data_width, alignment
    )
    port map (
        clk      => clk,
        rst      => rst,

        -- fetch in
        pc_if    => pc_if,
        pc_p4_if => pc_p4_if,
        instr_if => instr_if,

        -- decode out
        pc_id    => pc_if_id,
        pc_p4_id => pc_p4_if_id,
        instr_id => instr_if_id
    );



-- decode
decode : entity work.decode(Behavioral)
    generic map (
        magic_width, addr_width, data_width
    )
    port map (
        -- ctrl_unit flag, w register, and w data | from wb
        reg_w_wb            => reg_w_wb,
        w_reg_wb            => w_reg_wb,
        w_d_wb              => w_d_wb,

        -- pc, pc + 4, and instr | from if
        pc_if               => pc_if_id,
        pc_p4_if            => pc_p4_if_id,
        instr_if            => instr_if_id,

        -- w reg, ctrl_unit flags, instr[20:0], pc, pc + 4, reg data 1/2, jump/branch addr out | to ex
        w_reg_id            => w_reg_id,
        ctrl_flags_id       => ctrl_flags_id,
        instr_25_0_id       => instr_25_0_id,
        pc_id               => pc_id,
        pc_p4_id            => pc_p4_id,
        reg_d_1_id          => reg_d_1_id,
        reg_d_2_id          => reg_d_2_id
    );



-- id_ex pipeline reg
id_ex_reg : entity work.id_ex(Behavioral)
    generic map (
        mux_n, addr_width, data_width, alignment
    )
    port map (
        clk                 => clk,
        rst                 => rst,

        -- ctrl_unit flags, instr[20:0], pc, reg_d_1/2, branch/j addr | from id
        ctrl_flags_id       => ctrl_flags_id,
        pc_id               => pc_id,
        reg_d_1_id          => reg_d_1_id,
        reg_d_2_id          => reg_d_2_id,
        instr_25_0_id       => instr_25_0_id,

        -- alu zero flag, ctrl_unit flags, branch/j addr, pc, alu computation, reg data 2, w reg | to mem
        ctrl_flags_ex       => ctrl_flags_id_ex,
        instr_25_0_ex       => instr_25_0_id_ex,
        pc_ex               => pc_id_ex,
        reg_d_1_ex          => reg_d_1_id_ex,
        reg_d_2_ex          => reg_d_2_id_ex,
        jump_branch_addr_ex => jump_branch_addr_id_ex
    );



-- execute
execute : entity work.execute(Behavioral)
    generic map (
        reg_i_width, addr_width, data_width
    )
    port map (
        -- ctrl_unit flags, instr[20:0], pc, reg_d_1/2, branch/j addr | from id
        ctrl_flags_id       => ctrl_flags_id_ex,
        instr_25_0_id       => instr_25_0_id_ex,
        pc_id               => pc_id_ex,
        reg_d_1_id          => reg_d_1_id_ex,
        reg_d_2_id          => reg_d_2_id_ex,
        jump_branch_addr_id => jump_branch_addr_id_ex,

        -- ctrl_unit flag, reg file w reg | from mm
        reg_w_mm            => reg_w_mm,
        w_reg_mm            => w_reg_mm,
        w_d_mm              => alu_mm,

        -- reg file w reg | from wb
        reg_w_wb            => reg_w_wb,
        w_reg_wb            => w_reg_wb,
        w_d_wb              => w_d_wb,

        -- alu zero flag, ctrl_unit flags, branch/j addr, pc, alu computation, reg data 2, w reg | to mem
        alu_z_ex            => alu_z_ex,
        ctrl_flags_ex       => ctrl_flags_ex,
        branch_addr_ex      => branch_addr_ex,
        jump_addr_ex        => jump_addr_ex,
        pc_ex               => pc_ex,
        alu_ex              => alu_ex,
        fw_mm_w_d_ex        => fw_mm_w_d_ex,
        w_reg_ex            => w_reg_ex
    );



-- ex_mem pipeline reg
ex_mem_reg : entity work.ex_mem(Behavioral)
    generic map (
        reg_i_width, addr_width, data_width
    )
    port map (
        clk            => clk,
        rst            => rst,

        --execute
        alu_z_ex       => alu_z_ex,
        ctrl_flags_ex  => ctrl_flags_ex,
        branch_addr_ex => branch_addr_ex,
        jump_addr_ex   => jump_addr_ex,
        pc_ex          => pc_ex,
        alu_ex         => alu_ex,
        fw_mm_w_d_ex   => fw_mm_w_d_ex,
        w_reg_ex       => w_reg_ex,

        -- mem
        alu_z_mm       => alu_z_ex_mm,
        ctrl_flags_mm  => ctrl_flags_ex_mm,-- mem_r 5, branch 4, jump 3, mem_to_reg 2, mem_w 1, reg_w 0
        pc_mm          => pc_ex_mm,
        branch_addr_mm => branch_addr_ex_mm,
        jump_addr_mm   => jump_addr_ex_mm,
        alu_mm         => alu_ex_mm,
        fw_mm_w_d_mm   => fw_mm_w_d_ex_mm,
        w_reg_in_mm    => w_reg_ex_mm
    );



-- mem
memory : entity work.memory(Behavioral)
    generic map (
        mux_n, reg_i_width, magic_width, addr_width, data_width
    )
    port map (
        -- alu zero flag, ctrl_unit flags, branch/j addr, pc, alu computation, reg data 2, w reg | from ex
        alu_z_ex       => alu_z_ex_mm,
        ctrl_flags_ex  => ctrl_flags_ex_mm,-- mem_r 5, branch 4, jump 3, mem_to_reg 2, mem_w 1, reg_w 0
        branch_addr_ex => branch_addr_ex_mm,
        jump_addr_ex   => jump_addr_ex_mm,
        pc_ex          => pc_ex_mm,
        alu_ex         => alu_ex_mm,
        fw_mm_w_d_ex   => fw_mm_w_d_ex_mm,
        w_reg_ex       => w_reg_ex_mm,

        -- ctrl_unit branch/j flags, branch/j address | to if
        branch_mm      => branch_mm,
        jump_mm        => jump_mm,
        return_addr_mm => return_addr_mm,

        -- mem r data, alu computation, w reg
        mem_to_reg_mm  => mem_to_reg_mm,
        reg_w_mm       => reg_w_mm,
        mem_r_d_mm     => mem_r_d_mm,
        alu_mm         => alu_mm,
        w_reg_mm       => w_reg_mm
    );



-- mem_wb pipeline reg
mem_wb_reg : entity work.mem_wb(Behavioral)
    generic map (
        reg_i_width, addr_width, data_width
    )
    port map (
        clk           => clk,
        rst           => rst,

        -- mem
        mem_to_reg_mm => mem_to_reg_mm,
        reg_w_mm      => reg_w_mm,
        mem_r_d_mm    => mem_r_d_mm,
        alu_mm        => alu_mm,
        w_reg_mm      => w_reg_mm,

        -- write back
        mem_to_reg_wb => mem_to_reg_mm_wb,
        reg_w_wb      => reg_w_mm_wb,
        mem_r_d_wb    => mem_r_d_mm_wb,
        alu_wb        => alu_mm_wb,
        w_reg_wb      => w_reg_mm_wb
    );



-- write back
write_back : entity work.write_back(Behavioral)
        generic map (
            mux_n, reg_i_width, data_width
    )
    port map (
        -- ctrl_unit flags, mem r data, alu computation, w reg | from mem
        mem_to_reg_mm => mem_to_reg_mm_wb,
        reg_w_mm      => reg_w_mm_wb,
        mem_r_d_mm    => mem_r_d_mm_wb,
        alu_mm        => alu_mm_wb,
        w_reg_mm      => w_reg_mm_wb,

        -- ctrl_unit flag, w data, w reg  | to id
        reg_w_wb      => reg_w_wb,
        w_d_wb        => w_d_wb,
        w_reg_wb      => w_reg_wb
    );



end Behavioral;