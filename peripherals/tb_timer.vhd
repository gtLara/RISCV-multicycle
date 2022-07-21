library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity tb_timer is
end tb_timer;

architecture tb of tb_timer is

--------------------------------------------------------------------------
-- Declaracao de timer ------------------------------------------------
--------------------------------------------------------------------------

    component timer is
       port(
        --in
          clk : in std_logic;
          set : in std_logic;
          we : in std_logic;
          data_in : in std_logic_vector(31 downto 0);
        --out
          sample : out std_logic;
          data_out : out std_logic_vector(31 downto 0));
    end component;

--------------------------------------------------------------------------
-- Declaracao de sinais de TB --------------------------------------------
--------------------------------------------------------------------------

    constant clock_frequency : integer := 10e6; -- 10Mhz
    constant clock_period : time := 1000 ms /clock_frequency;

    signal clk : std_logic := '0';
    signal set : std_logic := '1';
    signal we : std_logic := '1';
    signal data_in : std_logic_vector(31 downto 0) := "00000000000000000000000000000111";

    -- outputs

    signal sample : std_logic;
    signal data_out : std_logic_vector(31 downto 0);

--------------------------------------------------------------------------
-- Início de arquitetura -------------------------------------------------
--------------------------------------------------------------------------

    begin

    clk <= not clk after clock_period / 2;

    uut: timer port map(
                        --in
                        clk => clk,
                        set => set,
                        we => we,
                        data_in => data_in,
                        --out
                        sample => sample,
                        data_out => data_out
                       );

    testbench: process

    begin

    set <= '0';

    wait for clock_period;

    end process testbench;

end tb;
