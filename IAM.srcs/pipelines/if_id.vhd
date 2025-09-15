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
        mux_n        : positive := 2;
        addr_width   : positive := 16;
        data_width   : positive := 32;
        alignment    : std_logic_vector(3 downto 0) := "0100"
    );
    port (
        -- generics
        clk      : std_logic;
        rst      : std_logic;

        -- fetch
        pc_ft    : in std_logic_vector(addr_width - 1 downto 0);
        pc_p4_ft : in std_logic_vector(addr_width - 1 downto 0);
        instr_ft : in std_logic_vector(addr_width - 1 downto 0);

        -- write back
        reg_w_wb : in std_logic;
        w_reg_wb : in std_logic_vector(4 downto 0);
        w_d_wb   : in std_logic_vector(data_width - 1 downto 0);

        -- decode
        reg_w_dc : out std_logic;
        w_reg_dc : out std_logic_vector(4 downto 0);
        w_d_dc   : out std_logic_vector(data_width - 1 downto 0);
        pc_dc    : out std_logic_vector(data_width - 1 downto 0);
        pc_p4_dc : out std_logic_vector(data_width - 1 downto 0);
        instr_dc : out std_logic_vector(data_width - 1 downto 0)
    );
end if_id;

architecture Behavioral of if_id is



begin

if_id_pipeline_reg : process(clk)
begin
    if rising_edge(clk) then
        -- write back -> decode
        reg_w_dc <= reg_w_wb;
        w_reg_dc <= w_reg_wb;
        w_d_dc   <= w_d_wb;

        -- fetch -> decode
        pc_dc    <= pc_ft;
        pc_p4_dc <= pc_p4_ft;
        instr_dc <= instr_ft;
    end if;
end process if_id_pipeline_reg;

end Behavioral;