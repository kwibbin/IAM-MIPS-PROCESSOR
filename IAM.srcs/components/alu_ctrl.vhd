----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: alu_ctrl - Behavioral
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


entity alu_ctrl is
  Port (
    alu_op_in  : in  std_logic_vector(3 downto 0);  -- "flag" from ctrl_unit
    func       : in  std_logic_vector(5 downto 0);  -- Inst[5:0]
    alu_op_out : out std_logic_vector(3 downto 0)); -- operating mode for alu
end alu_ctrl;

architecture Behavioral of alu_ctrl is

begin
    process(alu_op_in, func) is
    begin
        case alu_op_in is
            when "1111" =>  -- filter in r-type instructinos
                case func is
                    when "000001" =>    -- add
                        alu_op_out <= "0001";
                    when "000010" =>    -- sub
                        alu_op_out <= "0010";
                    when "000011" =>    -- and
                        alu_op_out <= "0011";
                    when "000100" =>    -- or
                        alu_op_out <= "0100";
                    when "000101" =>    -- xor
                        alu_op_out <= "0101";
                    when "000110" =>    -- sll
                        alu_op_out <= "0110";
                    when "000111" =>    -- srl
                        alu_op_out <= "0111";
                    when "001000" =>    -- sra
                        alu_op_out <= "1000";
                    when "001001" =>    -- jr
                        alu_op_out <= "0001";   -- doesn't matter
                    when others =>      -- how
                        alu_op_out <= "0000";
                 end case;
            when others =>
                -- I and J type instructions are assigned their "alu_op_out" from
                -- the ctrl_unit and passed straight through this alu_ctrl
                alu_op_out <= alu_op_in;
         end case;
    end process;


end Behavioral;
