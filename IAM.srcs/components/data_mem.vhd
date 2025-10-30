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
--      custom implementation of data memory that infers a dual-port RAM in BRAM
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

constant addr_range : natural := (2 ** magic_width - 1) / 4;  -- 64KB / 4-byte word = 16K words; so 2^14 addressible range
type memory_type is array(0 to addr_range) of std_logic_vector(data_width - 1 downto 0);
signal memory : memory_type := (

others => (others => '0'));

signal r_d_buff : std_logic_vector(31 downto 0);

begin

process(clk, mem_w, mem_r, addr, w_d)
begin
    if rising_edge(clk) then
        if mem_w = '1' then
            memory(to_integer(unsigned(addr(13 downto 0)))) <= w_d;
        end if;
        if mem_r = '1' then
            r_d_buff <= memory(to_integer(unsigned(addr)));
        else
            r_d_buff <= (others => '0');
        end if;
    end if;
end process;

r_d <= r_d_buff;

end Behavioral;
