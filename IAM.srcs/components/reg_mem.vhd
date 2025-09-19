----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: reg_mem - Behavioral
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

entity reg_mem is
    generic (
        data_width : positive := 32
    );
    port (
        reg_w          : in std_logic;  -- flag from ctrl_unit
        r_reg1, r_reg2 : in std_logic_vector(4 downto 0);   -- inst[25:21] & inst[20:16]
        w_reg          : in std_logic_vector(4 downto 0);   -- from mem_wb pipeline reg
        w_d            : in std_logic_vector(data_width - 1 downto 0);

        r_d1, r_d2     : out std_logic_vector(data_width - 1 downto 0));
end reg_mem;

architecture Behavioral of reg_mem is

type reg is array(0 to 31) of std_logic_vector(data_width - 1 downto 0);
signal reg_array : reg := (others => (others => '0'));

begin

process(reg_w, w_d, w_reg)
begin
    if reg_w = '1' and w_reg /= "00000" then -- protecting the $zero register
        reg_array(to_integer(unsigned(w_reg))) <= w_d;
    end if;
end process;

r_d1 <= reg_array(to_integer(unsigned(r_reg1)));
r_d2 <= reg_array(to_integer(unsigned(r_reg2)));

end Behavioral;
