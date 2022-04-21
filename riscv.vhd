library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;


entity riscv is
    port(
        clk : in std_logic;
        set : in std_logic
        );
end riscv;

architecture riscv_arc of riscv is

--------------------------------------------------------------------------
-- Declaracao de componentes ---------------------------------------------
--------------------------------------------------------------------------

    component pc is
        generic (
            PC_WIDTH : natural := 12
        );
        port (
            entrada : in std_logic_vector (PC_WIDTH - 1 downto 0);
            saida   : out std_logic_vector(PC_WIDTH - 1 downto 0);
            clk     : in std_logic;
            we      : in std_logic;
            reset   : in std_logic
        );
    end component;

    component mux21 is
        generic (
            largura_dado : natural := 32
        );
        port (
            dado_ent_0, dado_ent_1 : in std_logic_vector((largura_dado - 1) downto 0);
            sele_ent               : in std_logic;
            dado_sai               : out std_logic_vector((largura_dado - 1) downto 0)
        );
    end component;

    component memory is
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
    end component;


    component somador is
        generic (
            largura_dado : natural := 12
        );

        port (
            entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
            entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
            saida     : out std_logic_vector((largura_dado - 1) downto 0)
        );
    end component;

--------------------------------------------------------------------------
-- Declaracao de sinais --------------------------------------------------
--------------------------------------------------------------------------
    ---------------
    -- Instrucao --
    ---------------

    signal s_instruction : std_logic_vector(31 downto 0) := "00000000000000011010111110000011";

    -- parsing de instrucao

    -- imediato

    signal s_immediate : std_logic_vector(11 downto 0) := s_instruction(31 downto 20);

    -- endereços de registradores

    signal s_rs1 : std_logic_vector(4 downto 0) := s_instruction(19 downto 15);
    signal s_rs2 : std_logic_vector(4 downto 0) := s_instruction(24 downto 20);
    signal s_rd : std_logic_vector(4 downto 0) := s_instruction(11 downto 7);

    -- opcode e functs (controle)

    signal s_opcode : std_logic_vector(6 downto 0) := s_instruction(6 downto 0);
    signal s_funct7 : std_logic_vector(6 downto 0) := s_instruction(31 downto 25);
    signal s_funct3 : std_logic_vector(2 downto 0) := s_instruction(14 downto 12);

    ---------------
    -- Control ----
    ---------------

    signal sc_IorD : std_logic;
    signal sc_WE_data : std_logic;
    signal sc_WE_instruction_reg : std_logic;
    signal sc_WE_data_reg : std_logic;
    signal sc_WE_reg_file : std_logic;
    signal sc_WE_register_data_reg : std_logic;
    signal sc_PoR : std_logic;
    signal sc_alu_Bmux : std_logic_vector(1 downto 0);

    -----------------------
    -- Datapath signals ---
    -----------------------

    signal s_next_instruction_address : std_logic_vector(11 downto 0) := "000000000000";
    signal s_current_instruction_address : std_logic_vector(11 downto 0) := "000000000000";
    signal s_memory_data : std_logic_vector(31 downto 0);

    -- dead

    signal d_we : std_logic := '1';
    signal d_reset : std_logic := '0';
    signal d_mem : std_logic := '0';
    signal d_mem_vec : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal d_adder : std_logic_vector(11 downto 0) := "000000000100";


--------------------------------------------------------------------------
-- Definicao de datapath -------------------------------------------------
--------------------------------------------------------------------------

    begin

--------------------------------------------------------------------------
-- Instanciacao de componentes -------------------------------------------
--------------------------------------------------------------------------

    u_program_counter: pc port map(
                                   clk => clk,
                                   entrada => s_next_instruction_address,
                                   saida => s_current_instruction_address,
                                   we =>  d_we,
                                   reset => set
                                   );

    u_pc_adder: somador port map(
                                entrada_a => s_current_instruction_address,
                                entrada_b => d_adder,
                                saida => s_next_instruction_address
                                );

    -- u_memory: memory port map(
     --                        clk => clk,
       --                      mem_write => sc_WE_data,
         --                    mem_read => d_mem,
           --                  write_data_mem => d_mem_vec,
             --                adress_mem => s_current_instruction_address,
               --              read_data_mem => s_memory_data
                 --            );

end riscv_arc;
