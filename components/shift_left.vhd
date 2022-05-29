library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

-- extensor de sinais, extende sinal de tamanho generico para 32 bits

entity shift_left is
    generic(size: integer := 32); -- na verdade é tamanho - 1
    port(
         input: in std_logic_vector(size downto 0);
         output: out std_logic_vector(size downto 0));
end shift_left;

architecture shift_left_arc of shift_left is
    begin
        output <= std_logic_vector(unsigned(input) sll 2);
end shift_left_arc;
