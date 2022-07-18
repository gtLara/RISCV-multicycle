library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;
use ieee.NUMERIC_STD_UNSIGNED.all;

entity interruption_enable_reg is -- registrador generalizado

    generic(n_peripherals: integer := 2);
    port(
         we : in std_logic;
         next_input : in std_ulogic_vector(n_peripherals - 1 downto 0);
         clk : in std_logic;
         last_input : out std_ulogic_vector(n_peripherals - 1 downto 0)
        );

end interruption_enable_reg;

architecture interruption_enable_reg_arc of interruption_enable_reg is

    signal stored_signal: std_ulogic_vector(n_peripherals - 1 downto 0) := (others => '0');

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

end interruption_enable_reg_arc;
