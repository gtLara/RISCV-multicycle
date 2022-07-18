library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD_UNSIGNED.all;
use ieee.NUMERIC_STD.all;

entity interruption_handler is

    generic(n_peripherals: integer := 2);
    port(
            clk : in std_ulogic;
            ack : in std_ulogic;
            interruption_requests : in std_ulogic_vector(n_peripherals - 1 downto 0);
            original_instruction_address : in std_logic_vector(11 downto 0);
            interruption_enable_write : in std_ulogic_vector(n_peripherals - 1 downto 0);

            sc_rar : in std_logic;

            interruption_enable_read : out std_ulogic_vector(n_peripherals - 1 downto 0);
            return_address : out std_logic_vector(11 downto 0);
            isr_address : out std_ulogic_vector(11 downto 0));

end interruption_handler;

architecture interruption_handler_arc of interruption_handler is

-------------------------------------------------------------------------------
---- Declaraco de Componentes -------------------------------------------------
-------------------------------------------------------------------------------

    component register_block is -- registrador generalizado

        generic(size : integer := 12);
        port(
             we : in std_logic;
             next_input : in std_logic_vector(size - 1 downto 0);
             clk : in std_logic;
             last_input : out std_logic_vector(size - 1 downto 0)
            );

    end component;

    component lookup_table is
        port(
            -- in
                current_interruption : in std_ulogic_vector(1 downto 0);
            -- out
                isr_address : out std_ulogic_vector(11 downto 0)
        );
    end component;

    component interrupt_ctl is

        generic (
            RESET_ACTIVE_LEVEL : std_ulogic := '1' --# Asynch. reset control level
        );
        port (
            --# {{clocks|}}
            Clock : in std_ulogic; --# System clock
            Reset : in std_ulogic; --# Asynchronous reset

            --# {{control|}}
            Int_mask    : in std_ulogic_vector;  --# Set bits correspond to active interrupts
            Int_request : in std_ulogic_vector;  --# Controls used to activate new interrupts
            Pending     : out std_ulogic_vector; --# Set bits indicate which interrupts are pending
            Current     : out std_ulogic_vector; --# Single set bit for the active interrupt

            Interrupt     : out std_ulogic; --# Flag indicating when an interrupt is pending
            Acknowledge   : in std_ulogic;  --# Clear the active interupt
            Clear_pending : in std_ulogic   --# Clear all pending interrupts
        );

    end component;

    component interruption_enable_reg is -- registrador generalizado

        generic(n_peripherals: integer := 2);
        port(
             we : in std_logic;
             next_input : in std_ulogic_vector(n_peripherals - 1 downto 0);
             clk : in std_logic;
             last_input : out std_ulogic_vector(n_peripherals - 1 downto 0)
            );

    end component;


-------------------------------------------------------------------------------
---- Declaracao de Sinais ------------------------------------------------------
-------------------------------------------------------------------------------

    signal s_ier_out : std_ulogic_vector(n_peripherals-1 downto 0) ;

    signal s_current_interruption : std_ulogic_vector(n_peripherals-1 downto 0) ;
    signal s_pending_interruptions : std_ulogic_vector(n_peripherals-1 downto 0) ;
    signal s_interrupt : std_ulogic ;

    begin

-------------------------------------------------------------------------------
-- Instanciacao de componentes ------------------------------------------------
-------------------------------------------------------------------------------

    u_priority_handler: interrupt_ctl
                        port map(
                                  Clock => clk,
                                  Reset => '0',

                                  Int_mask => s_ier_out,
                                  Int_request => interruption_requests,
                                  Pending => s_pending_interruptions,
                                  Current => s_current_interruption,

                                  Interrupt => s_interrupt,
                                  Acknowledge => ack,
                                  Clear_pending => '0'
                                );

    u_interruption_enable_reg: interruption_enable_reg
                        port map(
                                 we => '1',
                                 next_input => interruption_enable_write,
                                 clk => clk,
                                 last_input => s_ier_out
                                );

    u_lookup_table: lookup_table
                        port map(
                            -- in
                                current_interruption => s_current_interruption,
                            -- out
                                isr_address => isr_address
                                );

    u_return_address_reg: register_block
                        port map(
                             we => sc_rar,
                             next_input => original_instruction_address,
                             clk => clk,
                             last_input => return_address
                            );

    interruption_enable_read <= s_ier_out;

end interruption_handler_arc;
