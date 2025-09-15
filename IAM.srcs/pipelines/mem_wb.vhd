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
            reg_i_width : positive := 5;
            addr_width  : positive := 16;
            data_width  : positive := 32
        );
    port (
        -- generic
        clk               : std_logic;
        rst               : std_logic;

        -- mem
        ctrl_flags_mm  : in std_logic_vector(3 downto 0);
        mem_r_d_mm     : in std_logic_vector(data_width - 1 downto 0);
        mem_alu_mm     : in std_logic_vector(data_width - 1 downto 0);
        w_reg_mm       : in std_logic_vector(reg_i_width - 1 downto 0);

        -- write back
        ctrl_flags_wb  : out std_logic_vector(1 downto 0); -- mem_to_reg 1, reg_w 0
        mem_r_d_wb     : out std_logic_vector(data_width - 1 downto 0);
        wb_alu_wb      : out std_logic_vector(data_width - 1 downto 0);
        w_reg_wb       : out std_logic_vector(reg_i_width - 1 downto 0)
    );
end mem_wb;

architecture Behavioral of mem_wb is

begin

mem_wb_pipeline_reg : process(clk)
begin
    if rising_edge(clk) then
        ctrl_flags_wb <= ctrl_flags_mm(2) & ctrl_flags_mm(0);
        mem_r_d_wb    <= mem_r_d_mm;
        wb_alu_wb     <= mem_alu_mm;
        w_reg_wb      <= w_reg_mm;
    end if;
end process mem_wb_pipeline_reg;

end Behavioral;
