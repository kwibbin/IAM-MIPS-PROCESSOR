----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: hazard_ctrl - Behavioral
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
--    use case:
--        reg being used the instr after the same reg is receiving data from a mem read
--        branch & jump preventing unwanted instructions from being processed
--
--    clocked to track timing of output closures
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_ctrl is
    generic (
        reg_i_width : positive := 5
    );
    port (
        clk        : in std_logic;
        rst        : in std_logic;

        -- from id
        opcode     : in std_logic_vector(5 downto 0);
        rs_rt_id   : in std_logic_vector(reg_i_width * 2 - 1 downto 0);
        func       : in std_logic_vector(5 downto 0);

        -- from ex
        mem_r      : in std_logic; -- only lw and lh
        rs_rt_ex   : in std_logic_vector(reg_i_width * 2 - 1 downto 0);

        -- prevent pc from moving | to if
        pc_hold    : out natural;

        -- prevent queued machine code from propagating | to if/id
        if_id_hold : out natural;

        -- sel line for mux to pick ctrl_unit flags or 0x000 | to id
        nop_ctrl   : out natural
    );
end hazard_ctrl;

architecture Behavioral of hazard_ctrl is

type var_pkg is record
    pc_hold_pkg    : natural;
    if_id_hold_pkg : natural;
    nop_ctrl_pkg   : natural;
    timer_pkg      : natural range 0 to 2; -- 3 range for lw/lh hazards - ex (1) -> mm (2) -> wb (3, done); only need 2 for branch/jump hazards
end record;

signal out_data_pkg : var_pkg;

function resolve_outputs(
        operating_mode : natural; -- 3 for lw/lh, 2 for branch/jump, 1 for timer hold 0 for no hazard
        in_pkg         : var_pkg
    ) return var_pkg is
        variable pkg   : var_pkg;
    begin
        case operating_mode is
            when 0 =>
                pkg.pc_hold_pkg    := 0;
                pkg.if_id_hold_pkg := 0;
                pkg.nop_ctrl_pkg   := 0;
                pkg.timer_pkg      := 0; -- no hazard

            when 1 =>
                pkg.pc_hold_pkg    := in_pkg.pc_hold_pkg;
                pkg.if_id_hold_pkg := in_pkg.if_id_hold_pkg;
                pkg.nop_ctrl_pkg   := in_pkg.nop_ctrl_pkg;
                pkg.timer_pkg      := in_pkg.timer_pkg - 1; -- reduce timer every clock cycle

            when 2 =>
                pkg.pc_hold_pkg    := 1;
                pkg.if_id_hold_pkg := 1;
                pkg.nop_ctrl_pkg   := 1;
                pkg.timer_pkg      := 1; -- branch/jump

            when 3 =>
                pkg.pc_hold_pkg    := 1;
                pkg.if_id_hold_pkg := 1;
                pkg.nop_ctrl_pkg   := 1;
                pkg.timer_pkg      := 2; -- lw/lh

            when others =>
                pkg.pc_hold_pkg    := 0;
                pkg.if_id_hold_pkg := 0;
                pkg.nop_ctrl_pkg   := 0;
                pkg.timer_pkg      := 0;

        end case;

        return pkg;

end function;

function check_branch_jump(
        opcode_f : std_logic_vector(5 downto 0);
        func_f   : std_logic_vector(5 downto 0)
    ) return std_logic is
        variable en : std_logic;
    begin
        case opcode_f is
            -- r type
            when "000000" =>
                if func_f = "001001" then -- jr
                    en := '1';
                else
                    en := '0';
                end if;

            -- i type
            when "000010" => -- beq
                en := '1';
            when "000011" => -- bneq
                en := '1';
            when "000100" => -- beqz
                en := '1';
            when "000101" => -- bltz
                en := '1';
            when "000110" => -- bgtz
                en := '1';
            when "000111" => -- blt
                en := '1';
            when "001000" => -- bgt
                en := '1';

            -- j type
            when "111110" => -- jal
                en := '1';
            when "111111" => -- j
                en := '1';

            when others =>
                en := '0';
        end case;

        return en;

end function;

alias rs_id : std_logic_vector(reg_i_width - 1 downto 0) is rs_rt_id(reg_i_width * 2 - 1 downto reg_i_width);
alias rt_id : std_logic_vector(reg_i_width - 1 downto 0) is rs_rt_id(reg_i_width - 1 downto 0);

alias rs_ex : std_logic_vector(reg_i_width - 1 downto 0) is rs_rt_ex(reg_i_width * 2 - 1 downto reg_i_width);
alias rt_ex : std_logic_vector(reg_i_width - 1 downto 0) is rs_rt_ex(reg_i_width - 1 downto 0);

signal branch_jump_en : std_logic := '0';

begin

process(out_data_pkg)
begin
    -- pkg -> outputs
    pc_hold    <= out_data_pkg.pc_hold_pkg;
    if_id_hold <= out_data_pkg.if_id_hold_pkg;
    nop_ctrl   <= out_data_pkg.nop_ctrl_pkg;
end process;

process(clk, rst)
begin
    if rst = '1' then
            branch_jump_en <= '0';
            out_data_pkg <= resolve_outputs(0, out_data_pkg);

    elsif rising_edge(clk) then
        if out_data_pkg.timer_pkg = 0 then
            if (rs_id = rs_ex or rt_id = rt_ex) and mem_r = '1' then
                out_data_pkg <= resolve_outputs(3, out_data_pkg);

            elsif branch_jump_en = '1' then
                out_data_pkg <= resolve_outputs(2, out_data_pkg);

            else
                out_data_pkg <= resolve_outputs(0, out_data_pkg);

            end if;

        else
            out_data_pkg <= resolve_outputs(1, out_data_pkg);

        end if;

        branch_jump_en <= check_branch_jump(opcode, func); -- set branch status for next

    end if;
end process;

end Behavioral;
