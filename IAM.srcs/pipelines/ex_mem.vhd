----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: ex_mem - Behavioral
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

entity ex_mem is
    generic (
        reg_i_width       : positive := 5;
        addr_width        : positive := 16;
        data_width        : positive := 32
    );
    port (
        clk               : in std_logic;
        rst               : in std_logic;

        --execute
        alu_z_ex          : in std_logic;
        ctrl_flags_ex     : in std_logic_vector(5 downto 0);
        branch_addr_ex    : in std_logic_vector(addr_width - 1 downto 0);
        jump_addr_ex      : in std_logic_vector(addr_width - 1 downto 0);
        pc_ex             : in std_logic_vector(addr_width - 1 downto 0);
        alu_ex            : in std_logic_vector(data_width - 1 downto 0);
        r_d_2_ex          : in std_logic_vector(data_width - 1 downto 0);
        w_reg_ex          : in std_logic_vector(reg_i_width - 1 downto 0);

        -- mem
        alu_z_mm          : out std_logic;
        ctrl_flags_mm     : out std_logic_vector(5 downto 0); -- mem_r 5, branch 4, jump 3, mem_to_reg 2, mem_w 1, reg_w 0
        branch_addr_mm    : out std_logic_vector(addr_width - 1 downto 0);
        jump_addr_mm      : out std_logic_vector(addr_width - 1 downto 0);
        pc_mm             : out std_logic_vector(addr_width - 1 downto 0);
        alu_mm            : out std_logic_vector(data_width - 1 downto 0);
        r_d_2_mm          : out std_logic_vector(data_width - 1 downto 0);
        w_reg_in_mm       : out std_logic_vector(reg_i_width - 1 downto 0)
    );
end ex_mem;

architecture Behavioral of ex_mem is

begin

ex_mem_pipeline_reg : process(clk)
begin
    if rising_edge(clk) then
        alu_z_mm       <= alu_z_ex;
        ctrl_flags_mm  <= ctrl_flags_ex;
        pc_mm          <= pc_ex;
        branch_addr_mm <= branch_addr_ex;
        jump_addr_mm   <= jump_addr_ex;
        alu_mm         <= alu_ex;
        r_d_2_mm       <= r_d_2_ex;
        w_reg_in_mm    <= w_reg_ex;
    end if;
end process ex_mem_pipeline_reg;


end Behavioral;
