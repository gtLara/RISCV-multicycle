library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;
use ieee.NUMERIC_STD_UNSIGNED.all;

entity register_block is -- registrador generalizado

    port(
         we : in std_logic;
         next_input : in std_logic_vector(31 downto 0);
         clk : in std_logic;
         last_input : out std_logic_vector(31 downto 0)
        );

end register_block;

architecture register_arc of register_block is

    signal stored_signal: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

    begin
        -- processo de escrita
        write: process(clk) -- o processo é sensivel apenas ao clock
        begin

        if rising_edge(clk) then  -- opera apenas nas subidas de clock
            if we = '1' then

                stored_signal <= next_input; -- armazena dados

            end if;
        end if; -- o sintetizador induz memoria por meio da ausencia de clausulas catch all

        end process write;

        -- processo de leitura

        read: process(clk, next_input) -- sensivel a todos os sinais

        begin

            last_input <= stored_signal;

        end process read;

end register_arc;
