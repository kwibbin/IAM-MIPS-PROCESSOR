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

package hzrd_helper is
    -- calculate branch or jump hazard
    function check_branch_jump(
        opcode_f : std_logic_vector(5 downto 0);
        func_f   : std_logic_vector(5 downto 0)
    ) return std_logic;
end package hzrd_helper;

package body hzrd_helper is
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
end package body hzrd_helper;