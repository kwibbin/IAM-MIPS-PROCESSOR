----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 07/09/2025 09:15:06 PM
-- Design Name:
-- Module Name: hazard_ctrl - Behavioral
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
--    use cases:
--        reg being used the instr after the same reg is receiving data from a mem read
--        branch & jump preventing unwanted instructions from being processed
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.hzrd_helper.all;

entity hazard_ctrl is
    generic (
        reg_i_width : positive := 5
    );
    port (
        clk        : in std_logic;

        -- from id
        opcode     : in std_logic_vector(5 downto 0);
        rs_rt_id   : in std_logic_vector(reg_i_width * 2 - 1 downto 0);
        func       : in std_logic_vector(5 downto 0);

        -- prevent pc from moving | to if
        pc_hold    : out natural;

        -- prevent queued machine code from propagating | to if/id
        if_id_hold : out natural;

        -- sel line for mux to pick ctrl_unit flags or 0x000 | to id
        nop_ctrl   : out natural
    );
end hazard_ctrl;

architecture Behavioral of hazard_ctrl is

alias rs_id         : std_logic_vector(reg_i_width - 1 downto 0) is rs_rt_id(reg_i_width * 2 - 1 downto reg_i_width);
alias rt_id         : std_logic_vector(reg_i_width - 1 downto 0) is rs_rt_id(reg_i_width - 1 downto 0);

signal mem_r_ex     : natural;
signal rs_ex        : std_logic_vector(reg_i_width - 1 downto 0);
signal rt_ex        : std_logic_vector(reg_i_width - 1 downto 0);
signal opcode_ex    : std_logic_vector(5 downto 0);
signal func_ex      : std_logic_vector(5 downto 0);

signal pc_hold_s    : natural;
signal if_id_hold_s : natural;
signal nop_ctrl_s   : natural;

signal timer        : natural range 0 to 2 := 0;

begin

-- outputs
pc_hold    <= pc_hold_s;
if_id_hold <= if_id_hold_s;
nop_ctrl   <= nop_ctrl_s;

process(clk)
begin
    if rising_edge(clk) then
        -- off-by-one regs to store previous instr details
        mem_r_ex  <= 1 when opcode = "001001" or opcode = "001011" else 0;
        rs_ex     <= rs_id;
        rt_ex     <= rt_id;
        opcode_ex <= opcode;
        func_ex   <= func;

        -- timer resolution
        if timer = 0 then
            if (rs_id = rs_ex or rt_id = rt_ex) and mem_r_ex = 1 then
                timer <= 2; -- load data hazard
            elsif check_branch_jump(opcode_ex, func_ex) then -- from hzrd_helper
                timer <= 1; -- jump or branch control hazard
            else
                timer <= 0; -- no hazard
            end if;
        else
            timer <= timer - 1; -- counter
        end if;
    end if;
end process;

process(opcode, rs_rt_id, func, timer)
begin
    if timer = 0 then
        -- (load data hazard) or (jump/branch control hazard)
        if ((rs_id = rs_ex or rt_id = rt_ex) and mem_r_ex = 1) or (check_branch_jump(opcode_ex, func_ex)) = '1' then
            pc_hold_s    <= 1;
            if_id_hold_s <= 1;
            nop_ctrl_s   <= 1;
        else
            pc_hold_s    <= 0;
            if_id_hold_s <= 0;
            nop_ctrl_s   <= 0;
        end if;
    else
        pc_hold_s    <= pc_hold_s;
        if_id_hold_s <= if_id_hold_s;
        nop_ctrl_s   <= nop_ctrl_s;
    end if;
end process;

end Behavioral;
