----------------------------------------------------------------------------------
-- Engineer: kwibbin
--
-- Create Date: 11/24/2025 06:12:46 PM
-- Design Name:
-- Module Name: branch_pred - Behavioral
-- Project Name: IAM
-- Target Devices: Basys3 Artix 7 - XC7A35T-1CPG236C
-- Tool Versions: Vivado 2025.2
-- Description:
--      decode stage of 5-stage mips processor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.pc_helper.all;

entity branch_pred is
    generic (
        addr_width  : positive := 32;
        alignment   : std_logic_vector(3 downto 0) := "0100"
    );
    port (
        clk         : in std_logic;

        pc_if       : in std_logic_vector(addr_width - 1 downto 0);

        z           : in std_logic;
        branch_ex   : in std_logic;
        pc_enc_ex   : in std_logic_vector(7 downto 0);

        pred_branch : out natural range 0 to 1;
        pred_pc     : out std_logic_vector(addr_width - 1 downto 0)
    );
end branch_pred;

architecture Behavioral of branch_pred is

signal branch_if      : std_logic;
signal pc_i_if        : natural;
signal pc_i_ex        : natural;
signal pipeline_timer : natural range 0 to 2 := 0;
signal bht_timer      : natural range 0 to 1 := 0;

-- 2^8, taking pc[9:2]; different PCs with the same 9:2 range is only somewhat likely,
-- accepting the possibility of a minor program inefficiency in favor of saving space.
constant store_size : positive := 256;
-- bht (branch history table) with strong not-taken (00), weak not-taken (01), weak taken (10), and strong taken (11)
type bht_store is array(0 to store_size - 1) of std_logic_vector(1 downto 0);
signal bht        : bht_store := (others => "01"); -- initialize to weak not-taken
signal bht_next   : bht_store := (others => "01"); -- async bht "predictor" for single-cycle timing resolution
signal bht_status : std_logic_vector(1 downto 0);

alias opcode_if : std_logic_vector(5 downto 0) is pc_if(addr_width - 1 downto 26);
alias pc_enc_if : std_logic_vector(7 downto 0) is pc_if(9 downto 2);

begin

branch_if <= check_branch(opcode_if); -- from pc_helper
pc_i_if   <= to_integer(unsigned(pc_enc_if));
pc_i_ex   <= to_integer(unsigned(pc_enc_ex));

-- update bht depending on ex branch alu result
bht_control : process(bht, z, branch_ex, pc_i_ex) begin
    if branch_ex = '1' then
        if bht(pc_i_ex) /= "11" and z = '1' then -- branch taken, trend towards strong taken prediction
            bht_next(pc_i_ex) <= std_logic_vector(unsigned(bht(pc_i_ex)) + "01");
        elsif bht(pc_i_ex) /= "00" and z = '0' then -- branch not taken, trend towards weak not taken prediction
            bht_next(pc_i_ex) <= std_logic_vector(unsigned(bht(pc_i_ex)) - "01");
        end if;
    end if;
end process bht_control;

-- synchronous bht assignment to preserve state for next cycle
bht_sync : process(clk) begin
    if rising_edge(clk) then
        bht <= bht_next;
    end if;
end process bht_sync;

bht_status <= bht_next(pc_i_if);
-- determine next instr
stage_next_instr : process(clk, branch_if, pc_i_if) begin
    if rising_edge(clk) then
        if branch_if = '1' and (bht_status = "10" or bht_status = "11") then
            pred_branch <= 1;
            pred_pc <= std_logic_vector(unsigned(pc_if) + resize(unsigned(alignment), addr_width));
        else
            pred_branch <= 0;
            pred_pc <= (others => '0');
        end if;
    end if;
end process stage_next_instr;

end Behavioral;