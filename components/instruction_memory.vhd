library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD_UNSIGNED.all;
use ieee.NUMERIC_STD.all;

library STD;
use STD.TEXTIO.ALL;

entity memory is

    port(
            clk : in std_logic;
            we : in std_logic;
            set : in std_logic; -- sinal para carregamento de progrma
            address : in std_logic_vector(11 downto 0);
            write_data : in std_logic_vector(31 downto 0);
            data : out std_logic_vector(31 downto 0));

end memory;

architecture memory_arc of memory is

    type ram_32x32 is array (0 to 4095) of std_logic_vector(31 downto 0); -- 32 palavras  de 32 bits cada
    signal mem: ram_32x32;

    file program : text open read_mode is "program.txt"; -- cria arquivo


    begin

    load: process(set) -- processo de carregamento de programa armazenado

        variable counter : integer := 0;
        variable current_read_line : line;
        variable current_read_data : std_logic_vector(31 downto 0);

        begin

        -- carrega linha e salva instrucao em endereco correspondente ao numero da linha

            while(not endfile(program)) loop
                readline(program, current_read_line);
                read(current_read_line, current_read_data);
                mem(counter) <= current_read_data;
                counter := counter + 1;
            end loop;

    end process load;

    read: process(address, clk) -- processo de leitura de instrucao
    begin

        data <= mem(to_integer(unsigned(address)));

    end process read;

    write: process(address, clk, write_data) -- processo de leitura de instrucao
    begin

        if to_integer(address) < 4096 then
            data <= mem(to_integer(unsigned(address)));
        end if;

    end process write;

end memory_arc;
