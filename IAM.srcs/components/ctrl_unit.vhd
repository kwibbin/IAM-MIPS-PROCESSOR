----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: ctrl_unit - Behavioral
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

entity ctrl_unit is
    port (
        -- opcode  : in std_logic_vector(5 downto 0);
        instr_if   : in std_logic_vector(31 downto 0);

        reg_dst    : out std_logic;
        jump       : out std_logic;
        branch     : out std_logic;
        mem_r      : out std_logic;
        mem_to_reg : out std_logic;
        alu_op     : out std_logic_vector(3 downto 0);
        mem_w      : out std_logic;
        alu_src    : out std_logic;
        reg_w      : out std_logic
    );
end ctrl_unit;

architecture Behavioral of ctrl_unit is

begin

    process(instr_if)
    begin
        if instr_if /= x"00000000" then -- skip NOPs, reserved for debugging
            case instr_if(31 downto 26) is
                when "000000" => -- add sub and or xor sll srl sra jr
                    reg_dst    <= '1';
                    jump       <= '0';
                    branch     <= '0';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "1111";
                    mem_w      <= '0';
                    alu_src    <= '0';
                    reg_w      <= '1';

                    when "000001" => -- addi
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '0';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "0001";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '1';

                    when "000010" => -- beq
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '1';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "0010";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "000011" => -- bneq
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '1';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "1001";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "000100" => -- beqz
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '1';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "1010";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "000101" => -- bltz
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '1';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "1011";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "000110" => -- bgtz
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '1';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "1100";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "000111" => -- blt
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '1';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "1101";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "001000" => -- bgt
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '1';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "1110";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "001001" => -- lw
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '0';
                    mem_r      <= '1';
                    mem_to_reg <= '1';
                    alu_op     <= "0000";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '1';

                    when "001010" => -- sw
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '0';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "0000";
                    mem_w      <= '1';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "001011" => -- lh
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '0';
                    mem_r      <= '1';
                    mem_to_reg <= '1';
                    alu_op     <= "0000";
                    mem_w      <= '0';
                    alu_src    <= '1';
                    reg_w      <= '1';

                    when "001100" => -- sh
                    reg_dst    <= '0';
                    jump       <= '0';

                    branch     <= '0';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "0000";
                    mem_w      <= '1';
                    alu_src    <= '1';
                    reg_w      <= '0';

                    when "111111" => -- j
                    reg_dst    <= '0';
                    jump       <= '1';
                    branch     <= '0';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "0000";
                    mem_w      <= '0';
                    alu_src    <= '0';
                    reg_w      <= '0';

                    when "111110" => -- jal
                    reg_dst    <= '0';
                    jump       <= '1';
                    branch     <= '0';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "0000";
                    mem_w      <= '0';
                    alu_src    <= '0';
                    reg_w      <= '0';

                    when others =>
                    reg_dst    <= '0';
                    jump       <= '0';
                    branch     <= '0';
                    mem_r      <= '0';
                    mem_to_reg <= '0';
                    alu_op     <= "0000";
                    mem_w      <= '0';
                    alu_src    <= '0';
                    reg_w      <= '0';

            end case;
        else -- NOP
            reg_dst    <= '0';
            jump       <= '0';
            branch     <= '0';
            mem_r      <= '0';
            mem_to_reg <= '0';
            alu_op     <= "0000";
            mem_w      <= '0';
            alu_src    <= '0';
            reg_w      <= '0';
        end if;
    end process;

end Behavioral;
