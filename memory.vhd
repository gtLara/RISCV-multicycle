-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use ieee.numeric_std.all;

entity memory is
    generic (
        number_of_words : natural := 3008; -- número de words que a sua memória é capaz de armazenar
        MD_DATA_WIDTH   : natural := 32; -- tamanho da palavra em bits
        MD_ADDR_WIDTH   : natural := 12 -- tamanho do endereco da memoria de dados em bits
    );
    port (
        clk                 : in std_logic;
        mem_write, mem_read : in std_logic; --sinais do controlador
        write_data_mem      : in std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
        adress_mem          : in std_logic_vector(MD_ADDR_WIDTH - 1 downto 0);
        read_data_mem       : out std_logic_vector(MD_DATA_WIDTH - 1 downto 0)
    );
    end memory;

architecture comportamental of memory is
        --alocar espaço para a memoria e iniciar com 0
        type data_mem is array (0 to number_of_words - 1) of std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
        signal ram  : data_mem := (others => (others => '0'));
        signal ram_addr : std_logic_vector(MD_ADDR_WIDTH - 1 downto 0);

        file program : text open read_mode is "program.txt"; -- cria arquivo

        begin

        load: process(set) -- processo de carregamento de programa armazenado
            variable counter : integer := 0;
            variable current_read_line : line;
            variable current_read_instruction : std_logic_vector(31 downto 0);

            -- carrega linha e salva instrucao em endereco correspondente ao numero da linha
            begin
                while(not endfile(program)) loop
                    readline(program, current_read_line);
                    read(current_read_line, current_read_instruction);
                    ram(counter) <= current_read_instruction;
                    counter := counter + 1;
                end loop;
        end process load;

        ram_addr <= adress_mem(MD_ADDR_WIDTH - 1 downto 0);
        process (clk)
        begin
            if (rising_edge(clk)) then
                if (mem_write = '1') then
                    ram(to_integer(unsigned(ram_addr))) <= write_data_mem;
                end if;
            end if;
        end process;
        read_data_mem <= ram(to_integer(unsigned(ram_addr))) when (mem_read = '1');
end comportamental;
