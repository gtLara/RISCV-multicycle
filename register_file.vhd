library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;
use ieee.NUMERIC_STD_UNSIGNED.all;

entity register_file is -- registrador de 32 palavras

    port(
         rs_1, rs_2, rd : in std_logic_vector(4 downto 0);
         clk : in std_logic;
         we : in std_logic;
         write_data : in std_logic_vector(31 downto 0);
         rs_1_data, rs_2_data : out std_logic_vector(31 downto 0)
        );

end register_file;

architecture register_arc of register_file is

    -- cria vetor de zeros para registrador 0

    constant zeros : std_logic_vector(0 to 31) := (others => '0');

    -- cria memoria ram

    type ram_memory is array (31 downto 0) of std_logic_vector(31 downto 0); -- 32 registradores de 32 bits cada

    signal mem: ram_memory := (others => (others => '0'));

    begin

        -- processo de escrita
        write: process(clk) -- o processo é sensivel apenas ao clock
        begin

        if rising_edge(clk) then  -- opera apenas nas subidas de clock
            if (we = '1') then  -- armazena dados apenas se write enable
                if ( to_integer(rd) /= 0 ) then -- se endereco for zero, nao escreve

                mem(to_integer(rd)) <= write_data; -- armazena dados

                end if;
            end if;
        end if; -- o sintetizador induz memoria por meio da ausencia de clausulas catch all

        end process write;

        -- processo de leitura

        read: process(rs_1, rs_2, rd, clk,    -- sensivel a todos os sinais
                      we, write_data)
        begin
            if( to_integer(rs_1) = 0 ) then
                rs_1_data <= zeros;

            else
                rs_1_data <= mem(to_integer(rs_1));
            end if;

            if( to_integer(rs_2) = 0 ) then
                rs_2_data <= zeros;

            else
                rs_2_data <= mem(to_integer(rs_2));
            end if;

        end process read;

end register_arc;
