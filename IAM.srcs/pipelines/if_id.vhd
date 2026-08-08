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
--      fetch -> decode pipeline register
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity if_id is
    generic (
        mux_n           : positive := 2;
        addr_width      : positive := 32;
        data_width      : positive := 32;
        alignment       : std_logic_vector(3 downto 0) := "0100"
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;

        -- fetch
        pc_if           : in std_logic_vector(addr_width - 1 downto 0);
        pc_next_if      : in std_logic_vector(addr_width - 1 downto 0);
        instr_if        : in std_logic_vector(data_width - 1 downto 0);
        pred_taken_if   : in std_logic;

        -- decode
        pc_id           : out std_logic_vector(addr_width - 1 downto 0);
        pc_next_id      : out std_logic_vector(addr_width - 1 downto 0);
        instr_id        : out std_logic_vector(data_width - 1 downto 0);
        pred_taken_id   : out std_logic
    );
end if_id;

architecture Behavioral of if_id is



begin

if_id_pipeline_reg : process(clk, rst)
begin
    if rst = '1' then
        pc_id          <= (others => '0');
        pc_next_id     <= (others => '0');
        instr_id       <= (others => '0');
        pred_taken_id  <= '0';
    end if;
    if rising_edge(clk) then
        pc_id          <= pc_if;
        pc_next_id     <= pc_next_if;
        instr_id       <= instr_if;
        pred_taken_id  <= pred_taken_if;
    end if;
end process if_id_pipeline_reg;

end Behavioral;