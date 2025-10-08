----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: mem_wb - Behavioral
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

entity mem_wb is
    generic (
        reg_i_width   : positive := 5;
        addr_width    : positive := 32;
        data_width    : positive := 32
        );
    port (
        clk           : in std_logic;
        rst           : in std_logic;

        -- mem
        mem_to_reg_mm : in std_logic;
        reg_w_mm      : in std_logic;
        mem_r_d_mm    : in std_logic_vector(data_width - 1 downto 0);
        alu_mm        : in std_logic_vector(data_width - 1 downto 0);
        w_reg_mm      : in std_logic_vector(reg_i_width - 1 downto 0);

        -- write back
        mem_to_reg_wb : out std_logic;
        reg_w_wb      : out std_logic;
        mem_r_d_wb    : out std_logic_vector(data_width - 1 downto 0);
        alu_wb        : out std_logic_vector(data_width - 1 downto 0);
        w_reg_wb      : out std_logic_vector(reg_i_width - 1 downto 0)
    );
end mem_wb;

architecture Behavioral of mem_wb is

begin

mem_wb_pipeline_reg : process(clk, rst)
begin
    if rising_edge(clk) then
        if rst = '1' then
            mem_to_reg_wb <= '0';
            reg_w_wb      <= '0';
            mem_r_d_wb    <= (others => '0');
            alu_wb        <= (others => '0');
            w_reg_wb      <= (others => '0');

        else
            mem_to_reg_wb <= mem_to_reg_mm;
            reg_w_wb      <= reg_w_mm;
            mem_r_d_wb    <= mem_r_d_mm;
            alu_wb        <= alu_mm;
            w_reg_wb      <= w_reg_mm;

        end if;
    end if;
end process mem_wb_pipeline_reg;

end Behavioral;
