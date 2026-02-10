----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 10/30/25 08:51:13 PM
-- Design Name:
-- Module Name: components_utils - Behavioral
-- Project Name: IAM
-- Target Devices: Basys3 Artix 7 - XC7A35T-1CPG236C
-- Tool Versions: Vivado 2025.1
-- Description:
--      helper functions for the components
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package pc_helper is
    -- determine branch or jump hazard
    function check_branch_jump (
        opcode_fn : std_logic_vector(5 downto 0);
        func_fn   : std_logic_vector(5 downto 0)
    ) return std_logic;

    -- determine branch
    function check_branch (
        opcode_fn : std_logic_vector(5 downto 0)
    ) return std_logic;
end package pc_helper;

package body pc_helper is
    function check_branch_jump (
        opcode_fn : std_logic_vector(5 downto 0);
        func_fn   : std_logic_vector(5 downto 0)
    ) return std_logic is
        variable en : std_logic;
    begin
        case opcode_fn is
            -- r type
            when "000000" =>
                if func_fn = "001001" then -- jr
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


    function check_branch (
        opcode_fn : std_logic_vector(5 downto 0)
    ) return std_logic is
        variable branch : std_logic;
    begin
        case opcode_fn is
            when "000010" => -- beq
                branch := '1';
            when "000011" => -- bneq
                branch := '1';
            when "000100" => -- beqz
                branch := '1';
            when "000101" => -- bltz
                branch := '1';
            when "000110" => -- bgtz
                branch := '1';
            when "000111" => -- blt
                branch := '1';
            when "001000" => -- bgt
                branch := '1';
            when others =>
                branch := '0';
        end case;

        return branch;

    end function;
end package body pc_helper;



package cond_logic_helpers is
    -- calculate branch or jump hazard
    function check_pc_branch_jump(
        branch_mm  : natural range 0 to 1;
        jump_mm    : natural range 0 to 1;
        pred_hold  : natural range 0 to 1
    ) return natural;
end package cond_logic_helpers;

package body cond_logic_helpers is
    function check_pc_branch_jump(
        branch_mm  : natural range 0 to 1;
        jump_mm    : natural range 0 to 1;
        pred_hold  : natural range 0 to 1
    ) return natural is
        variable mux_sel : natural range 0 to 2;
    begin

        if branch_mm = 1 or jump_mm = 1 then
            mux_sel := 2;
        elsif pred_hold = 1 then
            mux_sel := 1;
        else
            mux_sel := 0;
        end if;

        return mux_sel;

    end function;
end package body cond_logic_helpers;