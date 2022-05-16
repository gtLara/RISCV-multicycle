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
            set : in std_logic ;
            sc_IorD : in std_logic ;
            sc_WE_data : in std_logic ;
            sc_WE_program_counter : in std_logic ;
            sc_WE_memory : in std_logic ;
            sc_WE_instruction_reg : in std_logic ;
            sc_WE_data_reg : in std_logic ;
            sc_WE_alu_out_reg : in std_logic ;
            sc_WE_reg_file : in std_logic ;
            sc_WE_register_data_reg : in std_logic ;
            sc_alu_src_A : in std_logic ;
            sc_mem_to_reg : in std_logic ;
            sc_alu_src_B : in std_logic_vector(1 downto 0);
            sc_alu_control : in std_logic_vector(2 downto 0)
            );
    end component;

--------------------------------------------------------------------------
-- Declaracao de sinais de TB --------------------------------------------
--------------------------------------------------------------------------

    constant clock_frequency : integer := 10e6; -- 10Mhz
    constant clock_period : time := 1000 ms /clock_frequency;

    signal clk : std_logic := '0';
    signal set : std_logic := '1';

    signal sc_IorD : std_logic ;
    signal sc_WE_data : std_logic ;
    signal sc_WE_program_counter : std_logic ;
    signal sc_WE_memory : std_logic ;
    signal sc_WE_instruction_reg : std_logic ;
    signal sc_WE_data_reg : std_logic ;
    signal sc_WE_alu_out_reg : std_logic ;
    signal sc_WE_reg_file : std_logic ;
    signal sc_WE_register_data_reg :  std_logic ;
    signal sc_alu_src_A : std_logic ;
    signal sc_mem_to_reg : std_logic ;
    signal sc_alu_src_B : std_logic_vector(1 downto 0);
    signal sc_alu_control : std_logic_vector(2 downto 0);


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
                        sc_IorD => sc_IorD,
                        sc_WE_data => sc_WE_data,
                        sc_WE_program_counter => sc_WE_program_counter,
                        sc_WE_memory => sc_WE_memory,
                        sc_WE_instruction_reg => sc_WE_instruction_reg,
                        sc_WE_data_reg => sc_WE_data_reg,
                        sc_WE_alu_out_reg => sc_WE_alu_out_reg,
                        sc_WE_reg_file => sc_WE_reg_file,
                        sc_WE_register_data_reg => sc_WE_register_data_reg,
                        sc_alu_src_A => sc_alu_src_A,
                        sc_mem_to_reg => sc_mem_to_reg,
                        sc_alu_src_B => sc_alu_src_B,
                        sc_alu_control => sc_alu_control
                        );

    clk <= not clk after clock_period / 2; 

    testbench: process

        -- fetch

        begin
        set <= '0' ;
        sc_IorD <= '1' ; 
        sc_WE_data <=  '0' ;
        sc_WE_program_counter <= '0' ;
        sc_WE_memory <= '0' ;
        sc_WE_instruction_reg <= '0' ;
        sc_WE_data_reg <= '0' ;
        sc_WE_alu_out_reg <= '0' ;
        sc_WE_reg_file <= '0' ;
        sc_WE_register_data_reg <= '0' ;
        sc_alu_src_A <= '0' ;
        sc_mem_to_reg <= '0' ;
        sc_alu_src_B <= "00" ;
        sc_alu_control <= "000" ;

        wait for clock_period;

        -- instruction decode

        sc_IorD <= '0' ; 
        sc_WE_data <=  '0' ;
        sc_WE_program_counter <= '0' ;
        sc_WE_memory <= '0' ;
        sc_WE_instruction_reg <= '1' ;
        sc_WE_data_reg <= '0' ;
        sc_WE_alu_out_reg <= '0' ;
        sc_WE_reg_file <= '0' ;
        sc_WE_register_data_reg <= '0' ;
        sc_alu_src_A <= '0' ;
        sc_mem_to_reg <= '0' ;
        sc_alu_src_B <= "00" ;
        sc_alu_control <= "000" ;

        wait for clock_period;

        -- execute

        sc_IorD <= '0' ; 
        sc_WE_data <=  '0' ;
        sc_WE_program_counter <= '0' ;
        sc_WE_memory <= '0' ;
        sc_WE_instruction_reg <= '1' ;
        sc_WE_data_reg <= '0' ;
        sc_WE_alu_out_reg <= '0' ;
        sc_WE_reg_file <= '0' ;
        sc_WE_register_data_reg <= '1' ;
        sc_alu_src_A <= '0' ;
        sc_mem_to_reg <= '0' ;
        sc_alu_src_B <= "00" ;
        sc_alu_control <= "000" ;

        wait for clock_period;

        -- memory

        sc_IorD <= '0' ; 
        sc_WE_data <=  '0' ;
        sc_WE_program_counter <= '0' ;
        sc_WE_memory <= '0' ;
        sc_WE_instruction_reg <= '0' ;
        sc_WE_data_reg <= '1' ;
        sc_WE_alu_out_reg <= '1' ;
        sc_WE_reg_file <= '0' ;
        sc_WE_register_data_reg <= '0' ;
        sc_alu_src_A <= '0' ;
        sc_mem_to_reg <= '0' ;
        sc_alu_src_B <= "00" ;
        sc_alu_control <= "000" ;

        wait for clock_period;

        -- write_back

        sc_IorD <= '0' ; 
        sc_WE_data <=  '0' ;
        sc_WE_program_counter <= '0' ;
        sc_WE_memory <= '0' ;
        sc_WE_instruction_reg <= '0' ;
        sc_WE_data_reg <= '0' ;
        sc_WE_alu_out_reg <= '0' ;
        sc_WE_reg_file <= '1' ;
        sc_WE_register_data_reg <= '0' ;
        sc_alu_src_A <= '1' ;
        sc_mem_to_reg <= '0' ;
        sc_alu_src_B <= "01" ;
        sc_alu_control <= "000" ;

    end process testbench;

end tb;
