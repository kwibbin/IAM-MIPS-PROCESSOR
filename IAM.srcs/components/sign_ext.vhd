----------------------------------------------------------------------------------
-- Engineer: kwibbin
-- 
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name: 
-- Module Name: sign_ext - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity sign_ext is
    Port (
        in_d16  : in std_logic_vector(15 downto 0); -- instr[15:0] (imm field)
        out_d32 : out std_logic_vector(31 downto 0)
    );
end sign_ext;

architecture Behavioral of sign_ext is

begin

    out_d32 <= std_logic_vector(resize(signed(in_d16), 32));

end Behavioral;
