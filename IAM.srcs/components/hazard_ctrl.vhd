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

        -- from id
        opcode     : in std_logic_vector(5 downto 0);
        rs_rt_id   : in std_logic_vector(reg_i_width * 2 - 1 downto 0);
        func       : in std_logic_vector(5 downto 0);

        -- prevent pc from moving | to if
        pc_hold    : out natural;

        -- prevent queued machine code from propagating | to if/id
        if_id_hold : out natural;

        -- sel line for mux to pick ctrl_unit flags or 0x000 | to id
        nop_ctrl   : out natural
    );
end hazard_ctrl;

architecture Behavioral of hazard_ctrl is

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

alias rs_id         : std_logic_vector(reg_i_width - 1 downto 0) is rs_rt_id(reg_i_width * 2 - 1 downto reg_i_width);
alias rt_id         : std_logic_vector(reg_i_width - 1 downto 0) is rs_rt_id(reg_i_width - 1 downto 0);

signal rs_ex        : std_logic_vector(reg_i_width - 1 downto 0);
signal rt_ex        : std_logic_vector(reg_i_width - 1 downto 0);

signal pc_hold_s    : natural;
signal if_id_hold_s : natural;
signal nop_ctrl_s   : natural;

signal timer        : natural range 0 to 2 := 0;

signal mem_r_ex     : natural;

begin

pc_hold    <= pc_hold_s;
if_id_hold <= if_id_hold_s;
nop_ctrl   <= nop_ctrl_s;

process(clk)
begin
    if rising_edge(clk) then
        -- delayed FFs
        mem_r_ex <= 1 when opcode = "001001" or opcode = "001011" else 0;
        rs_ex     <= rs_id;
        rt_ex     <= rt_id;
    end if;
end process;

process(opcode, rs_rt_id, func)
begin
    if timer = 0 then
        if (rs_id = rs_ex or rt_id = rt_ex) and mem_r_ex = 1 then
            pc_hold_s    <= 1;
            if_id_hold_s <= 1;
            nop_ctrl_s   <= 1;
            timer        <= 2; -- no hazard

        elsif check_branch_jump(opcode, func) then
            pc_hold_s    <= 1;
            if_id_hold_s <= 1;
            nop_ctrl_s   <= 1;
            timer        <= 1; -- no hazard

        else
            pc_hold_s    <= 0;
            if_id_hold_s <= 0;
            nop_ctrl_s   <= 0;
            timer        <= 0; -- no hazard

        end if;

    else
        pc_hold_s    <= pc_hold_s;
        if_id_hold_s <= if_id_hold_s;
        nop_ctrl_s   <= nop_ctrl_s;
        timer        <= timer - 1; -- no hazard

    end if;

end process;

end Behavioral;
