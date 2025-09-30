----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: write_back - Behavioral
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

entity write_back is
    generic (
        mux_n         : positive := 2;
        reg_i_width   : positive := 5;
        data_width    : positive := 32
    );
    port (
        clk           : in std_logic;
        rst           : in std_logic;

        mem_to_reg_mm : in std_logic;
        reg_w_mm      : in std_logic;
        mem_r_d_mm    : in std_logic_vector(data_width - 1 downto 0);
        alu_mm        : in std_logic_vector(data_width - 1 downto 0);
        w_reg_mm      : in std_logic_vector(reg_i_width - 1 downto 0);

        -- ctrl_unit flag, w data, w reg  | to id
        reg_w_wb      : out std_logic;
        w_d_wb        : out std_logic_vector(data_width - 1 downto 0);
        w_reg_wb      : out std_logic_vector(reg_i_width - 1 downto 0)
    );
end write_back;

architecture Behavioral of write_back is

signal resolved_wb_sel : natural range 0 to mux_n - 1;
signal reg_d_packed  : std_logic_vector(data_width * mux_n - 1 downto 0);

begin

process(mem_to_reg_mm)
begin
    resolved_wb_sel <= 1 when mem_to_reg_mm = '1' else 0;
end process;

reg_w_wb <= reg_w_mm;
w_reg_wb <= w_reg_mm;

reg_d_packed <= mem_r_d_mm & alu_mm;

jump_mux : entity work.mux(Behavioral)
    generic map (
        in_n      => mux_n,
        out_width => data_width
    )
    port map (
        sel   => resolved_wb_sel, -- mem_to_reg
        in_d  => reg_d_packed,

        out_d => w_d_wb
    );

end Behavioral;
