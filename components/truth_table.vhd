library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity truth_table is
    port(
    -- in
        opcode : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        funct7 : in std_logic_vector(6 downto 0);
        s_alu_op : std_logic_vector(1 downto 0) ;
        set : in std_logic ;
        clk : in std_logic ;
	
    -- out
      	sc_alu_control : out std_logic_vector(2 downto 0)
end entity;

architecture truth_tabel_arc of truth_table is
begin
    process(clk, set)
    begin
        if rising_edge(clk) then            	
	 	--Tabela Verdade (ALU Control) 
		case s_alu_op is 
			when "00"=>
		       	sc_alu_control<="010"; --soma

			when "01"=>
		       	sc_alu_control<="110"; --subtração

			when "11"=>	       --assumi que para esse caso a preferência é do subtract vide Harris
		       	sc_alu_control<="110"; --subtração

			when "10"=>
				case funct3  is   

					when "000"=>
						if funct7 = "0000000" then 
							sc_alu_control<="010"; --add
						else 
							sc_alu_control<="110"; --sub
						end if;
					when "111" =>
						sc_alu_control <="000";  --and
					when "110" =>
						sc_alu_control <="001"; --or
					when "010" =>
						sc_alu_control <="111";  --slt
				end case
		end case

	end if 
end control_arc;
