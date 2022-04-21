library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity tb_riscv is
end tb_riscv;

architecture tb of tb_riscv is

--------------------------------------------------------------------------
-- Declaracao de processador ---------------------------------------------
--------------------------------------------------------------------------

    component riscv is
        port(
            clk : in std_logic;
            set : in std_logic
            );
    end component;

--------------------------------------------------------------------------
-- Declaracao de sinais de TB --------------------------------------------
--------------------------------------------------------------------------

    constant clock_frequency : integer := 10e6; -- 10Mhz
    constant clock_period : time := 1000 ms /clock_frequency;

    signal clk : std_logic := '0';
    signal set : std_logic := '1';


--------------------------------------------------------------------------
-- Início de arquitetura -------------------------------------------------
--------------------------------------------------------------------------

    begin

--------------------------------------------------------------------------
-- Instanciação de processador -------------------------------------------
--------------------------------------------------------------------------


    uut: riscv port map(
                        clk  => clk,
                        set => set
                        );

    clk <= not clk after clock_period / 2;

    testbench: process

        begin
        set <= '0';
        wait for clock_period;

    end process testbench;

end tb;
