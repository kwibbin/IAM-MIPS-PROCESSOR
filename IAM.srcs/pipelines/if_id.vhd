----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: if_id - Behavioral
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

entity if_id is
    generic (
        mux_n         : positive := 2;
        addr_width    : positive := 32;
        data_width    : positive := 32;
        alignment     : std_logic_vector(3 downto 0) := "0100"
    );
    port (
        clk           : in std_logic;
        rst           : in std_logic;
        if_id_hold_id : in natural range 0 to 1;

        -- fetch
        pc_if         : in std_logic_vector(addr_width - 1 downto 0);
        pc_p4_if      : in std_logic_vector(addr_width - 1 downto 0);
        instr_if      : in std_logic_vector(data_width - 1 downto 0);

        -- decode
        pc_id         : out std_logic_vector(addr_width - 1 downto 0);
        pc_p4_id      : out std_logic_vector(addr_width - 1 downto 0);
        instr_id      : out std_logic_vector(data_width - 1 downto 0)
    );
end if_id;

architecture Behavioral of if_id is



begin

if_id_pipeline_reg : process(clk, rst)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pc_id    <= (others => '0');
            pc_p4_id <= (others => '0');
            instr_id <= (others => '0');

        elsif if_id_hold_id /= 1 then
            pc_id    <= pc_if;
            pc_p4_id <= pc_p4_if;
            instr_id <= instr_if;

        end if;
    end if;
end process if_id_pipeline_reg;

end Behavioral;