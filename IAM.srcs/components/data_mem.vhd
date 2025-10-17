----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: data_mem - Behavioral
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
use IEEE.numeric_std.all;


entity data_memory is
    generic (
        magic_width : positive := 16;
        addr_width  : positive := 32;
        data_width  : positive := 32
    );
    port (
        clk    : in std_logic;

        mem_w  : in std_logic;
        mem_r  : in std_logic;

        addr   : in std_logic_vector(magic_width - 1 downto 0);
        w_d    : in std_logic_vector(data_width - 1 downto 0);

        r_d    : out std_logic_vector(data_width - 1 downto 0)
    );
end data_memory;

architecture Behavioral of data_memory is

constant addr_range : natural := 2 ** magic_width - 1;  -- 64KB / 4-byte word = 16K words
type memory_type is array(0 to addr_range) of std_logic_vector(7 downto 0);
signal memory : memory_type := (

others => (others => '0'));

signal r_d_buff : std_logic_vector(31 downto 0);

begin

process(clk, mem_w, mem_r, addr, w_d)
begin
    if rising_edge(clk) then
        if mem_w = '1' then
            memory(to_integer(unsigned(addr)))     <= w_d(31 downto 24);
            memory(to_integer(unsigned(addr) + 1)) <= w_d(23 downto 16);
            memory(to_integer(unsigned(addr) + 2)) <= w_d(15 downto 8);
            memory(to_integer(unsigned(addr) + 3)) <= w_d(7 downto 0);
        end if;
        if mem_r = '1' then
            r_d_buff(31 downto 24) <= memory(to_integer(unsigned(addr)));
            r_d_buff(23 downto 16) <= memory(to_integer(unsigned(addr) + 1));
            r_d_buff(15 downto 8)  <= memory(to_integer(unsigned(addr) + 2));
            r_d_buff(7 downto 0)   <= memory(to_integer(unsigned(addr) + 3));
        else
            r_d_buff(data_width - 1 downto 0) <= (others => '0');
        end if;
    end if;
end process;

r_d <= r_d_buff;

end Behavioral;
