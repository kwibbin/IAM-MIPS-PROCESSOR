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
    port (
        clk        : in std_logic;

        pc_enc_if  : in std_logic_vector(7 downto 0);
        opcode_if  : in std_logic_vector(5 downto 0);

        z          : in std_logic;
        branch_ex  : in std_logic;
        pc_enc_ex  : in std_logic_vector(7 downto 0);

        pred_hold  : out natural range 0 to 1;
        pred_flush : out natural range 0 to 1
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
signal bht : bht_store := (others => "01"); -- initialize to weak not-taken

begin

branch_if <= check_branch(opcode_if);
pc_i_if   <= to_integer(unsigned(pc_enc_if));
pc_i_ex   <= to_integer(unsigned(pc_enc_ex));

-- holds the pc when a branch not-taken is predicted
pipeline_stall : process(clk, branch_if, pc_i_if)
begin
    if rising_edge(clk) then
        if branch_if = '1' and pipeline_timer = 0 then
            if bht(pc_i_if) = "10" or bht(pc_i_if) = "11" then
                pred_hold <= 1;
                pipeline_timer <= 2;
            else
                pred_hold <= 0;
                pipeline_timer <= pipeline_timer;
            end if;
        elsif pipeline_timer /= 0 then
            pred_hold <= 1;
            pipeline_timer <= pipeline_timer - 1;
        end if;
    end if;
end process pipeline_stall;

-- retroactively update bht depending on ex branch alu result
bht_control : process(clk, z, pc_i_ex)
begin
    if rising_edge(clk) and branch_ex = '1' then
        if bht_timer = 0 then
            -- branch taken, trend towards strong taken prediction
            if (bht(pc_i_ex) = "00" or bht(pc_i_ex) = "01" or bht(pc_i_ex) = "10") and z = '1' then
                bht(pc_i_ex) <= std_logic_vector(unsigned(bht(pc_i_ex)) + "01");

                if bht(pc_i_ex) = "00" or bht(pc_i_ex) = "01" then -- flush if not-taken was predicted
                    pred_flush <= 1;
                    bht_timer  <= 1;
                else
                    pred_flush <= 0;
                    bht_timer  <= bht_timer;
                end if;
            end if;

            -- branch not taken, trend towards weak not taken prediction
            if (bht(pc_i_ex) = "01" or bht(pc_i_ex) = "10" or bht(pc_i_ex) = "11") and z = '0' then
                bht(pc_i_ex) <= std_logic_vector(unsigned(bht(pc_i_ex)) - "01");
                pred_flush <= 0;
                bht_timer <= bht_timer;
            end if;

        else -- bht_timer active, flushing pipeline, avoid updating bht
            pred_flush <= 1;
            bht_timer  <= bht_timer - 1;
        end if;
    end if;
end process bht_control;

end Behavioral;