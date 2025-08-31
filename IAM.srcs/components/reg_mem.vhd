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
        clk                    : in std_logic;  -- for synchronous writes
        reg_wr                 : in std_logic;  -- flag from ctrl_unit
        read_reg1, read_reg2   : in std_logic_vector(4 downto 0);   -- inst[25:21] & inst[20:16]
        write_reg              : in std_logic_vector(4 downto 0);   -- from mem_wb pipeline reg
        write_d                : in std_logic_vector(data_width - 1 downto 0);

        read_d1, read_d2       : out std_logic_vector(data_width - 1 downto 0));
end reg_mem;

architecture Behavioral of reg_mem is

type reg is array(0 to 31) of std_logic_vector(data_width - 1 downto 0);
signal reg_array : reg := (others => (others => '0'));

begin

process(clk, reg_wr, write_d, write_reg)
begin
    if rising_edge(clk) then
        if reg_wr = '1' then
            reg_array(to_integer(unsigned(write_reg))) <= write_d;
        end if;
    end if;
end process;

read_d1 <= reg_array(to_integer(unsigned(read_reg1)));
read_d2 <= reg_array(to_integer(unsigned(read_reg2)));

end Behavioral;
