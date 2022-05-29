library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity brancher is
    port(
    -- in
        funct3 : in std_logic_vector(2 downto 0);
        neg: in std_logic ;
        zero : in std_logic ;
    -- out
      	s_branch_taken : out std_logic
	);
end brancher;

architecture brancher_arc of brancher is

    signal s_beq : std_logic ;
    signal s_bne : std_logic ;
    signal s_blt : std_logic ;
    signal s_bge : std_logic ;

    begin

    process(funct3, neg, zero)
        begin

        s_beq <= (not funct3(2)) and (not funct3(1)) and (not funct3(0)) and zero;

        s_bne <= (not funct3(2)) and (not funct3(1)) and (funct3(0)) and (not zero);

        s_blt <= (funct3(2)) and (not funct3(1)) and (not funct3(0)) and neg;

        s_bge <= (funct3(2)) and (not funct3(1)) and (funct3(0)) and (not neg or zero);

        s_branch_taken <= s_beq or s_bne or s_blt or s_bge;

    end process;
end brancher_arc;
