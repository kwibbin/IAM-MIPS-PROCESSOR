----------------------------------------------------------------------------------
-- Engineer: kwibbin
-- 
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name: 
-- Module Name: alu - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port (
        in_d1, in_d2 : in std_logic_vector(31 downto 0);
        alu_ctrl     : in std_logic_vector(3 downto 0);
        
        zero         : out std_logic;   -- flag for branch determination
        out_d        : inout std_logic_vector(31 downto 0));
end alu;

architecture Behavioral of alu is    

constant zero_c : signed := x"00000000";

begin

    process(in_d1, in_d2, alu_ctrl)
    begin  
        case alu_ctrl is
            when "0001" =>      -- Addition
                out_d <= std_logic_vector(signed(in_d1) + signed(in_d2));
                             
            when "0010" =>      -- Subtraction
                out_d <= std_logic_vector(signed(in_d1) - signed(in_d2));
                    
            when "0011" =>      -- Bitwise AND
                out_d <= in_d1 AND in_d2;
                    
            when "0100" =>      -- Bitwise OR
                out_d <= in_d1 OR in_d2;
                
            when "0101" =>      -- XOR
                out_d <= in_d1 XOR in_d2;
                    
            when "0110" =>      -- Logical Shift Left
                out_d <= std_logic_vector(shift_left(unsigned(in_d1), to_integer(unsigned(in_d2))));
                    
            when "0111" =>      -- Logical Shift Right
                out_d <= std_logic_vector(shift_right(unsigned(in_d1), to_integer(unsigned(in_d2))));
    
            when "1000" =>      -- Arithmetic Shift Right
                out_d <= std_logic_vector(shift_right(signed(in_d1), to_integer(signed(in_d2))));

            when "1001" =>      -- Branch if not equal (bneq)
                if (in_d1 /= in_d2) then
                    out_d <= (others => '0');
                else
                    out_d <= (others => '1');   -- result doesn't matter, just can't be 0
                end if;
                
            when "1010" =>      -- beqz, lw, sw, lh, sh
                out_d <= in_d1;
                
            when "1011" =>      -- Branch if < 0
                if (signed(in_d1) < zero_c) then
                    out_d <= (others => '0');
                else
                    out_d <= (others => '1');  -- result doesn't matter, just can't be 0
                end if;
            
            when "1100" =>      -- Branch if > 0
                if (signed(in_d1) > zero_c) then
                    out_d <= (others => '0');
                else
                    out_d <= (others => '1');  -- result doesn't matter, just can't be 0
                end if;

            when "1101" =>      -- Branch if 1 < 2
                if (signed(in_d1) < signed(in_d2)) then
                    out_d <= (others => '0');
                else
                    out_d <= (others => '1');  -- result doesn't matter, just can't be 0
                end if;

            when "1110" =>      -- Branch if 1 > 2
                if (signed(in_d1) > signed(in_d2)) then
                    out_d <= (others => '0');
                else
                    out_d <= (others => '1');  -- result doesn't matter, just can't be 0
                end if;
    
            when others =>
                NULL;
        end case;     
    end process;   

zero <= '1' when out_d(31 downto 0) = (x"00000000") else '0';
                             
end Behavioral;
