library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity tb_control is
end tb_control;

architecture tb of tb_control is

--------------------------------------------------------------------------
-- Declaracao de truth table ---------------------------------------------
--------------------------------------------------------------------------

    component control is
        port(
            opcode : in std_logic_vector(6 downto 0);
            funct3 : in std_logic_vector(2 downto 0);
            funct7 : in std_logic_vector(6 downto 0);
            set : in std_logic ;
            clk : in std_logic ;

            sc_IorD : out std_logic ;
            sc_WE_data : out std_logic ;
            sc_WE_program_counter : out std_logic ;
            sc_WE_memory : out std_logic ;
            sc_WE_instruction_reg : out std_logic ;
            sc_WE_data_reg : out std_logic ;
            sc_WE_alu_out_reg : out std_logic ;
            sc_WE_reg_file : out std_logic ;
            sc_WE_register_data_reg : out std_logic ;
            sc_alu_src_A : out std_logic ;
            sc_mem_to_reg : out std_logic ;
            sc_Zext : out std_logic ;
            sc_alu_src_B : out std_logic_vector(1 downto 0);
            sc_alu_control : out std_logic_vector(2 downto 0)
            );
    end component;

--------------------------------------------------------------------------
-- Declaracao de sinais de TB --------------------------------------------
--------------------------------------------------------------------------

    constant clock_frequency : integer := 10e6; -- 10Mhz
    constant clock_period : time := 1000 ms /clock_frequency;

    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);

    signal clk : std_logic := '0';
    signal set : std_logic := '0';

    -- outputs

    signal sc_IorD : std_logic ;
    signal sc_WE_data : std_logic ;
    signal sc_WE_program_counter : std_logic ;
    signal sc_WE_memory : std_logic ;
    signal sc_WE_instruction_reg : std_logic ;
    signal sc_WE_data_reg : std_logic ;
    signal sc_WE_alu_out_reg : std_logic ;
    signal sc_WE_reg_file : std_logic ;
    signal sc_WE_register_data_reg : std_logic ;
    signal sc_alu_src_A : std_logic ;
    signal sc_mem_to_reg : std_logic ;
    signal sc_Zext : std_logic ;
    signal sc_alu_src_B : std_logic_vector(1 downto 0);
    signal sc_alu_control : std_logic_vector(2 downto 0);


--------------------------------------------------------------------------
-- Início de arquitetura -------------------------------------------------
--------------------------------------------------------------------------

    begin

--------------------------------------------------------------------------
-- Instanciação de tabela de verdade -------------------------------------
--------------------------------------------------------------------------


    uut: control port map(
                            opcode => opcode,
                            funct3 => funct3,
                            funct7 => funct7,
                            set => set,
                            clk => clk,

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
                            sc_Zext => sc_Zext,
                            sc_alu_src_B => sc_alu_src_B,
                            sc_alu_control => sc_alu_control
                         );

    clk <= not clk after clock_period / 2;

    testbench: process

    begin

        wait for clock_period; -- fetch

        opcode <= "0110011";
        funct3 <= "000";
        funct7 <= "0000000";

        wait for clock_period; -- decode

        wait for clock_period; -- execute

        wait for clock_period; -- memory

        wait for clock_period; -- write back

        opcode <= "0010011";
        funct3 <= "000";
        funct7 <= "0000000";

        wait for clock_period; -- fetch

        wait for clock_period; -- decode

        wait for clock_period; -- execute

        wait for clock_period; -- memory

        wait for clock_period; -- write back

        wait for clock_period; -- nop

    end process testbench;

end tb;
