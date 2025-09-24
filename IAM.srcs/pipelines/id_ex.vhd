----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: id_ex - Behavioral
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

entity id_ex is
    generic (
        mux_n               : positive := 2;
        addr_width          : positive := 16;
        data_width          : positive := 32;
        alignment           : std_logic_vector(3 downto 0) := "0100"
    );
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;

        -- decode
        ctrl_flags_id       : in std_logic_vector(11 downto 0);
        instr_20_0_id       : in std_logic_vector(20 downto 0);
        reg_d_1_id          : in std_logic_vector(data_width - 1 downto 0);
        reg_d_2_id          : in std_logic_vector(data_width - 1 downto 0);
        pc_id               : in std_logic_vector(addr_width - 1 downto 0);

        -- execute
        ctrl_flags_ex       : out std_logic_vector(11 downto 0);
        instr_20_0_ex       : out std_logic_vector(20 downto 0);
        reg_d_1_ex          : out std_logic_vector(data_width - 1 downto 0);
        reg_d_2_ex          : out std_logic_vector(data_width - 1 downto 0);
        pc_ex               : out std_logic_vector(addr_width - 1 downto 0);
        jump_branch_addr_ex : out std_logic_vector(addr_width - 1 downto 0)
    );
end id_ex;

architecture Behavioral of id_ex is

begin

id_ex_pipeline_reg : process(clk, rst)
begin
    if rising_edge(clk) then
        if rst = '1' then
            ctrl_flags_ex       <= (others => '0');
            instr_20_0_ex       <= (others => '0');
            pc_ex               <= (others => '0');
            reg_d_1_ex          <= (others => '0');
            reg_d_2_ex          <= (others => '0');
            jump_branch_addr_ex <= (others => '0');

        else
            ctrl_flags_ex       <= ctrl_flags_id;
            instr_20_0_ex       <= instr_20_0_id(20 downto 0);
            pc_ex               <= pc_id;
            reg_d_1_ex          <= reg_d_1_id;
            reg_d_2_ex          <= reg_d_2_id;
            jump_branch_addr_ex <= instr_20_0_id(15 downto 0);

        end if;
    end if;
end process id_ex_pipeline_reg;


end Behavioral;
