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

    -- determine jump; branches are resolved by the predictor now, so the
    -- hazard unit only has to care about the unconditional control transfers
    function check_jump (
        opcode_fn : std_logic_vector(5 downto 0);
        func_fn   : std_logic_vector(5 downto 0)
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


    function check_jump (
        opcode_fn : std_logic_vector(5 downto 0);
        func_fn   : std_logic_vector(5 downto 0)
    ) return std_logic is
        variable jump : std_logic;
    begin
        case opcode_fn is
            -- r type
            when "000000" =>
                if func_fn = "001001" then -- jr
                    jump := '1';
                else
                    jump := '0';
                end if;

            -- j type
            when "111110" => -- jal
                jump := '1';
            when "111111" => -- j
                jump := '1';

            when others =>
                jump := '0';
        end case;

        return jump;

    end function;
end package body pc_helper;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package cond_logic_helpers is
    -- fetch next pc mux select; 2 misprediction recovery, 1 resolved jump, 0 predicted pc + 4
    function next_pc_sel(
        mispredict_ex : std_logic;
        jump_mm       : natural range 0 to 1
    ) return natural;

    -- decode ctrl flag mux select; 1 replaces the ctrl flags with a NOP
    function check_flush(
        mispredict_ex : std_logic;
        nop_ctrl_id   : natural range 0 to 1
    ) return natural;
end package cond_logic_helpers;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package body cond_logic_helpers is
    function next_pc_sel(
        mispredict_ex : std_logic;
        jump_mm       : natural range 0 to 1
    ) return natural is
        variable mux_sel : natural range 0 to 2;
    begin

        -- a mispredict resolves in ex, one stage ahead of the jump redirect
        -- out of mem, so it takes priority over anything still in flight
        if mispredict_ex = '1' then
            mux_sel := 2;
        elsif jump_mm = 1 then
            mux_sel := 1;
        else
            mux_sel := 0;
        end if;

        return mux_sel;

    end function;


    function check_flush(
        mispredict_ex : std_logic;
        nop_ctrl_id   : natural range 0 to 1
    ) return natural is
        variable mux_sel : natural range 0 to 1;
    begin

        if mispredict_ex = '1' or nop_ctrl_id = 1 then
            mux_sel := 1;
        else
            mux_sel := 0;
        end if;

        return mux_sel;

    end function;
end package body cond_logic_helpers;
