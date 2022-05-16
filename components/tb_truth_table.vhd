library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity tb_truth_table is
end tb_truth_table;

architecture tb of tb_truth_table is

--------------------------------------------------------------------------
-- Declaracao de truth table ---------------------------------------------
--------------------------------------------------------------------------

    component truth_table is
        port(
            funct3 : in std_logic_vector(2 downto 0);
            funct7 : in std_logic_vector(6 downto 0);
            s_alu_op : std_logic_vector(1 downto 0) ;

            sc_alu_control : out std_logic_vector(2 downto 0)

            );
    end component;

--------------------------------------------------------------------------
-- Declaracao de sinais de TB --------------------------------------------
--------------------------------------------------------------------------

    constant tempin : time := 100 ns ;

    signal funct3 : std_logic_vector(2 downto 0) := "010";
    signal funct7 : std_logic_vector(6 downto 0) := "0100100";
    signal s_alu_op : std_logic_vector(1 downto 0) := "11";
    signal sc_alu_control : std_logic_vector(2 downto 0);

--------------------------------------------------------------------------
-- Início de arquitetura -------------------------------------------------
--------------------------------------------------------------------------

    begin

--------------------------------------------------------------------------
-- Instanciação de tabela de verdade -------------------------------------
--------------------------------------------------------------------------


    uut: truth_table port map(
                            funct3 => funct3,
                            funct7 => funct7,
                            s_alu_op => s_alu_op,
                            sc_alu_control => sc_alu_control
                            );

    testbench: process

    begin

        wait for tempin;

        funct3 <= "000";
        funct7 <= "0000000";
        s_alu_op <= "10";

        wait for tempin;

        funct3 <= "110";
        funct7 <= "0000000";
        s_alu_op <= "10";

        wait for tempin;

        funct3 <= "001";
        funct7 <= "0000000";
        s_alu_op <= "10";

    end process testbench;

end tb;
