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
        generic(n_peripherals: integer := 2);
        port(
            clk : in std_logic;
            set : in std_logic;
            interruption_requests : in std_ulogic_vector(n_peripherals - 1 downto 0)
            );
    end component;

--------------------------------------------------------------------------
-- Declaracao de sinais de TB --------------------------------------------
--------------------------------------------------------------------------

    constant clock_frequency : integer := 10e6; -- 10Mhz
    constant clock_period : time := 1000 ms /clock_frequency;

    signal clk : std_logic := '0';
    signal set : std_logic := '1';
    signal interruption_requests : std_ulogic_vector(1 downto 0) := "00";

--------------------------------------------------------------------------
-- Início de arquitetura -------------------------------------------------
--------------------------------------------------------------------------

    begin

--------------------------------------------------------------------------
-- Instanciação de processador -------------------------------------------
--------------------------------------------------------------------------

    uut: riscv port map(
                        clk  => clk,
                        set => set,
                        interruption_requests => interruption_requests
                        );

    clk <= not clk after clock_period / 2;

    testbench: process

        begin
        set <= '0';

        wait for clock_period;
        interruption_requests <= "01";
        wait for clock_period;
        interruption_requests <= "00";

    end process testbench;

end tb;
