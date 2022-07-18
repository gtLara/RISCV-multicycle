library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity tb_interruption_handler is
end tb_interruption_handler;

architecture tb of tb_interruption_handler is

--------------------------------------------------------------------------
-- Declaracao de controle ------------------------------------------------
--------------------------------------------------------------------------
    component interruption_handler is

        port(
                clk : in std_ulogic;
                ack : in std_ulogic;
                interruption_requests : in std_ulogic_vector(2 - 1 downto 0);
                original_instruction_address : in std_logic_vector(11 downto 0);
                interruption_enable_write : in std_ulogic_vector(2 - 1 downto 0);

                sc_rar : in std_logic;

                interruption_enable_read : out std_ulogic_vector(2 - 1 downto 0);
                return_address : out std_logic_vector(11 downto 0);
                isr_address : out std_ulogic_vector(11 downto 0));

    end component;

--------------------------------------------------------------------------
-- Declaracao de sinais de TB --------------------------------------------
--------------------------------------------------------------------------

    constant clock_frequency : integer := 10e6; -- 10Mhz
    constant clock_period : time := 1000 ms / clock_frequency;

    signal clk : std_ulogic := '0';
    signal ack : std_ulogic := '0';
    signal interruption_requests : std_ulogic_vector(2 - 1 downto 0);
    signal original_instruction_address : std_logic_vector(11 downto 0);
    signal interruption_enable_write : std_ulogic_vector(2 - 1 downto 0) := "11";

    signal sc_rar : std_logic := '1';

    -- outputs

    signal interruption_enable_read : std_ulogic_vector(2 - 1 downto 0);
    signal return_address : std_logic_vector(11 downto 0);
    signal isr_address : std_ulogic_vector(11 downto 0);


--------------------------------------------------------------------------
-- Início de arquitetura -------------------------------------------------
--------------------------------------------------------------------------

    begin

    u_interruption_handler: interruption_handler
                            port map(
                                    clk => clk,
                                    ack => ack,
                                    interruption_requests => interruption_requests,
                                    original_instruction_address => original_instruction_address,
                                    interruption_enable_write => interruption_enable_write,

                                    sc_rar => sc_rar,

                                    interruption_enable_read => interruption_enable_read,
                                    return_address => return_address,
                                    isr_address => isr_address
                                    );

    clk <= not clk after clock_period / 2;


    testbench: process

    begin

        wait for clock_period;

        interruption_requests <= "01";
        original_instruction_address <= "000000000010";
        interruption_enable_write <= "11";
        sc_rar <= '1';

        wait for clock_period;

        ack <= '1';

        wait for clock_period;

        ack <= '0';
        original_instruction_address <= "000000000010";
        interruption_enable_write <= "11";
        sc_rar <= '0';

        wait for clock_period;

        interruption_requests <= "10";
        original_instruction_address <= "000000000010";
        interruption_enable_write <= "11";
        sc_rar <= '1';

        wait for clock_period;

        interruption_requests <= "11";
        original_instruction_address <= "000000000010";
        interruption_enable_write <= "11";
        sc_rar <= '1';

        wait for clock_period;

        interruption_requests <= "11";
        original_instruction_address <= "000000000010";
        interruption_enable_write <= "10";
        sc_rar <= '1';

        wait for clock_period;

        wait for clock_period;

        wait for clock_period;

        wait for clock_period;

        wait for clock_period;

        wait for clock_period;

    end process testbench;

end tb;
