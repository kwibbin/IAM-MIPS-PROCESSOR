----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: forwarding_unit - Behavioral
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
--      forwarding unit resolves certain types of data hazards by bridging the
--      data lines from later stages to earlier stages that require the data
--      earlier than what can be made available traditionally
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity forwarding_unit is
    port (
        -- 2 ctrl_unit flags, r reg 1 and 2 | from ex
        jump_ex    : in std_logic;
        alu_src_ex : in std_logic;
        reg_d_1_ex : in std_logic_vector(4 downto 0);
        reg_d_2_ex : in std_logic_vector(4 downto 0);

        -- ctrl_unit flag, reg file w reg | from mm
        reg_w_mm   : in std_logic;
        w_reg_mm   : in std_logic_vector(4 downto 0);

        -- reg file w reg | from wb
        reg_w_wb   : in std_logic;
        w_reg_wb   : in std_logic_vector(4 downto 0);

        -- mux sel lines | to ex
        fw_d_1_sel : out natural range 0 to 2; -- 3 sel opts, for alu in d 1
        fw_d_2_sel : out natural range 0 to 3; -- 4 sel opts, for alu in d 2
        fw_w_d_sel : out natural range 0 to 2  -- 3 sel opts, for d mem w d
    );
end forwarding_unit;

architecture Behavioral of forwarding_unit is

begin

    forwarding : process(jump_ex, alu_src_ex, reg_d_1_ex, reg_d_2_ex, w_reg_mm, reg_w_mm, w_reg_wb, reg_w_wb)
    begin

        if jump_ex = '0' then -- forwarding is irrelevant when jumping
            -- fw_d_1_sel
            if reg_w_mm = '1' and reg_d_1_ex = w_reg_mm then
                fw_d_1_sel <= 1; -- alu out from mm
            elsif reg_w_wb = '1' and reg_d_1_ex = w_reg_wb then
                fw_d_1_sel <= 2; -- alu out or d mem out from wb
            else
                fw_d_1_sel <= 0; -- r_d_1
            end if;

            -- fw_d_2_sel and fw_w_d_sel
            if alu_src_ex = '1' then
                fw_d_2_sel <= 3;
                if reg_w_mm = '1' and reg_d_2_ex = w_reg_mm then
                    fw_w_d_sel <= 1;
                elsif reg_w_wb = '1' and reg_d_2_ex = w_reg_wb then
                    fw_w_d_sel <= 2;
                else
                    fw_w_d_sel <= 0;
                end if;
            elsif alu_src_ex = '0' then
                fw_w_d_sel <= 0;
                if reg_w_mm = '1' and reg_d_2_ex = w_reg_mm then
                    fw_d_2_sel <= 1;
                elsif reg_w_wb = '1' and reg_d_2_ex = w_reg_wb then
                    fw_d_2_sel <= 2;
                else
                    fw_d_2_sel <= 0;
                end if;
            end if;

        else -- standard jump case
            fw_d_1_sel <= 0; -- read d 1
            fw_d_2_sel <= 2; -- sign ext imm
            fw_w_d_sel <= 0; -- read d 2
        end if;

    end process;

end Behavioral;