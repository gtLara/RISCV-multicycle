library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;
use ieee.NUMERIC_STD_UNSIGNED.all;

entity register_data_register is -- registrador generalizado
    port(
         we : in std_logic;
         rs_1_input : in std_logic_vector(31 downto 0);
         rs_2_input : in std_logic_vector(31 downto 0);
         clk : in std_logic;
         rs_1_output : out std_logic_vector(31 downto 0);
         rs_2_output : out std_logic_vector(31 downto 0)
        );
end register_data_register;

architecture register_arc of register_data_register is

    signal rs_1_stored_signal: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal rs_2_stored_signal: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

    begin
        -- processo de escrita
        write: process(clk) -- o processo é sensivel apenas ao clock
        begin
        if rising_edge(clk) then  -- opera apenas nas subidas de clock
            if we = '1' then
                rs_1_stored_signal <= rs_1_input; -- armazena dados
                rs_2_stored_signal <= rs_2_input; -- armazena dados
            end if;
        end if; -- o sintetizador induz memoria por meio da ausencia de clausulas catch all
        end process write;

        -- processo de leitura
        read: process(clk, rs_1_input, rs_2_input) -- sensivel a todos os sinais
        begin
            rs_1_output <= rs_1_stored_signal;
            rs_2_output <= rs_2_stored_signal;
        end process read;
end register_arc;
