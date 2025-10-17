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
    generic (
        data_width   : positive := 32
    );
    port (
        in_d1, in_d2 : in std_logic_vector(data_width - 1 downto 0);
        shamt        : in std_logic_vector(4 downto 0);
        alu_ctrl     : in std_logic_vector(3 downto 0);

        zero         : out std_logic;   -- flag for branch determination
        out_d        : out std_logic_vector(data_width - 1 downto 0));
end alu;

architecture Behavioral of alu is

constant zero_c : std_logic_vector(data_width - 1 downto 0) := (others => '0');
signal d        : std_logic_vector(data_width - 1 downto 0);

begin

    process(in_d1, in_d2, shamt, alu_ctrl)
    begin
        case alu_ctrl is
            when "0001" =>      -- Addition
                d <= std_logic_vector(signed(in_d1) + signed(in_d2));

            when "0010" =>      -- Subtraction
                d <= std_logic_vector(signed(in_d1) - signed(in_d2));

            when "0011" =>      -- Bitwise AND
                d <= in_d1 AND in_d2;

            when "0100" =>      -- Bitwise OR
                d <= in_d1 OR in_d2;

            when "0101" =>      -- XOR
                d <= in_d1 XOR in_d2;

            when "0110" =>      -- Logical Shift Left
                d <= std_logic_vector(shift_left(unsigned(in_d1), to_integer(unsigned(shamt))));

            when "0111" =>      -- Logical Shift Right
                d <= std_logic_vector(shift_right(unsigned(in_d1), to_integer(unsigned(shamt))));

            when "1000" =>      -- Arithmetic Shift Right
                d <= std_logic_vector(shift_right(signed(in_d1), to_integer(signed(shamt))));

            when "1001" =>      -- Branch if not equal (bneq)
                d <= (others => '0') when in_d1 /= in_d2 else (others => '1');

            when "1010" =>      -- beqz, lw, sw, lh, sh
                d <= in_d1;

            when "1011" =>      -- Branch if < 0
                d <= (others => '0') when signed(in_d1) < signed(zero_c) else (others => '1');

            when "1100" =>      -- Branch if > 0
                d <= (others => '0') when signed(in_d1) > signed(zero_c) else (others => '1');

            when "1101" =>      -- Branch if 1 < 2
                d <= (others => '0') when signed(in_d1) < signed(in_d2) else (others => '1');

            when "1110" =>      -- Branch if 1 > 2
                d <= (others => '0') when signed(in_d1) > signed(in_d2) else (others => '1');

            when others =>
                d <= zero_c;
        end case;
    end process;

zero <= '1' when d = zero_c else '0';
out_d <= d;

end Behavioral;
