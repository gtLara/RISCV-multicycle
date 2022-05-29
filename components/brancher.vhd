library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity brancher is
    port(
    -- in
        funct3 : in std_logic_vector(2 downto 0);
        negative : in std_logic ;
        zero : in std_logic ;
    -- out
      	s_branch_taken : out std_logic
	);
end entity;

architecture brancher_arc of brancher is
begin
    process(negative, zero)
    begin
        -- code goes here
    end process;
end brancher_arc;
