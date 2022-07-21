library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity lookup_table is
    port(
        -- in
            current_interruption : in std_ulogic_vector(1 downto 0);
        -- out
            isr_address : out std_ulogic_vector(11 downto 0)
	);
end entity;

architecture lookup_table_arc of lookup_table is
begin
    process(current_interruption)
    begin
		case current_interruption is

			when "01"=>
                isr_address <= "000000011111"; -- gpio

			when "10"=>
                isr_address <= "000000111111"; -- timer

			when others =>
                isr_address  <=  "UUUUUUUUUUUU";  -- deadcase
		end case;

     end process;
end lookup_table_arc;
