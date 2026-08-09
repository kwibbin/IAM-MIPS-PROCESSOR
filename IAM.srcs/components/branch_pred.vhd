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
--      dynamic branch predictor for the fetch stage of the 5-stage mips
--      processor; a 2 bit bht supplies the taken/not taken decision and a btb
--      supplies the target, both indexed by pc[9:2] and both written when a
--      branch resolves in ex.
--
--      the prediction is a function of the fetch pc alone. it must never look
--      at the instruction word coming out of instruction memory: that word is
--      addressed by the pc being predicted for, so reading it here would close
--      a combinational loop through the rom. the btb exists to break that loop;
--      it remembers the target of a branch instead of re-deriving it from the
--      immediate.
--
--      pred_pc is the address to fetch *next*. the pc handed to instruction
--      memory this cycle is untouched, otherwise a predicted taken branch would
--      replace itself with its own target and never enter the pipeline.
--
--      a cold index simply predicts not taken (btb miss), and index aliasing
--      can predict taken on a non-branch. both cases are corrected by the
--      misprediction recovery in ex.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity branch_pred is
    generic (
        addr_width     : positive := 32
    );
    port (
        clk            : in std_logic;
        rst            : in std_logic;

        -- pc being fetched, and the sequential pc that follows it | from if
        pc_if          : in std_logic_vector(addr_width - 1 downto 0);
        pc_p4_if       : in std_logic_vector(addr_width - 1 downto 0);

        -- ctrl_unit branch flag, alu zero flag, pc[9:2], branch target | from ex
        branch_ex      : in std_logic;
        z_ex           : in std_logic;
        pc_enc_ex      : in std_logic_vector(7 downto 0);
        branch_addr_ex : in std_logic_vector(addr_width - 1 downto 0);

        -- next pc to fetch and the prediction that produced it | to if
        pred_pc        : out std_logic_vector(addr_width - 1 downto 0);
        pred_taken     : out std_logic
    );
end branch_pred;

architecture Behavioral of branch_pred is

-- 2^8, taking pc[9:2]; different PCs with the same 9:2 range is only somewhat likely,
-- accepting the possibility of a minor program inefficiency in favor of saving space.
constant store_size : positive := 256;

-- bht (branch history table) with strong not-taken (00), weak not-taken (01), weak taken (10), and strong taken (11)
type bht_store is array(0 to store_size - 1) of std_logic_vector(1 downto 0);
-- btb (branch target buffer), holds the target resolved in ex for each branch
type btb_store is array(0 to store_size - 1) of std_logic_vector(addr_width - 1 downto 0);

signal bht          : bht_store := (others => "01"); -- initialize to weak not-taken
signal btb          : btb_store := (others => (others => '0'));
signal btb_valid    : std_logic_vector(store_size - 1 downto 0) := (others => '0');

signal i_if         : natural range 0 to store_size - 1;
signal i_ex         : natural range 0 to store_size - 1;
signal pred_taken_s : std_logic;

alias pc_enc_if     : std_logic_vector(7 downto 0) is pc_if(9 downto 2);

begin

i_if <= to_integer(unsigned(pc_enc_if));
i_ex <= to_integer(unsigned(pc_enc_ex));

-- predict taken only on a btb hit; the msb of the counter is the taken/not taken decision
pred_taken_s <= '1' when rst = '0' and btb_valid(i_if) = '1' and bht(i_if)(1) = '1' else '0';
pred_taken   <= pred_taken_s;
pred_pc      <= btb(i_if) when pred_taken_s = '1' else pc_p4_if;

-- update both stores from the branch resolving in ex
bht_btb_update : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            bht       <= (others => "01");
            btb_valid <= (others => '0');
        elsif branch_ex = '1' then
            -- the target is valid whether or not the branch was taken
            btb(i_ex)       <= branch_addr_ex;
            btb_valid(i_ex) <= '1';

            -- saturating 2 bit counter
            if z_ex = '1' then -- branch taken, trend towards strong taken prediction
                if bht(i_ex) /= "11" then
                    bht(i_ex) <= std_logic_vector(unsigned(bht(i_ex)) + 1);
                end if;
            else -- branch not taken, trend towards strong not taken prediction
                if bht(i_ex) /= "00" then
                    bht(i_ex) <= std_logic_vector(unsigned(bht(i_ex)) - 1);
                end if;
            end if;
        end if;
    end if;
end process bht_btb_update;

end Behavioral;
