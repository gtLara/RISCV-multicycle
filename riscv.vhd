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

-------------------------------------------------------------------------------
-- Declaracao de componentes --------------------------------------------------
-------------------------------------------------------------------------------

    component ula is
        generic (
            largura_dado : natural := 32
        );

        port (
            entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
            entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
            seletor   : in std_logic_vector(2 downto 0);
            saida     : out std_logic_vector((largura_dado - 1) downto 0)
        );
    end component;

    component register_block is

        port(
             we : in std_logic;
             next_input : in std_logic_vector(31 downto 0);
             clk : in std_logic;
             last_input : out std_logic_vector(31 downto 0)
            );

    end component;

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

    component mux41 is
        generic (
            largura_dado : natural := 32
        );
        port (
            dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector((largura_dado - 1) downto 0);
            sele_ent                                       : in std_logic_vector(1 downto 0);
            dado_sai                                       : out std_logic_vector((largura_dado - 1) downto 0)
        );
    end component;

    component instruction_memory is

        port(
                set : in std_logic; -- sinal para carregamento de progrma
                address : in std_logic_vector(11 downto 0);
                instruction : out std_logic_vector(31 downto 0));

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

    component register_file is
        port(
             rs_1, rs_2, rd : in std_logic_vector(4 downto 0);
             clk : in std_logic;
             we : in std_logic;
             write_data : in std_logic_vector(31 downto 0);
             rs_1_data, rs_2_data : out std_logic_vector(31 downto 0)
            );
    end component;

    component signex is
        generic(size: integer := 11); -- na verdade é tamanho - 1
        port(
             signex_in: in std_logic_vector(size downto 0);
             signex_out: out std_logic_vector(31 downto 0)
         );
    end component;

    component register_data_register is
        port(
             we : in std_logic;
             rs_1_input : in std_logic_vector(31 downto 0);
             rs_2_input : in std_logic_vector(31 downto 0);
             clk : in std_logic;
             rs_1_output : out std_logic_vector(31 downto 0);
             rs_2_output : out std_logic_vector(31 downto 0)
            );
    end component;

-------------------------------------------------------------------------------
-- Declaracao de sinais -------------------------------------------------------
-------------------------------------------------------------------------------

    ---------------
    -- Control ----
    ---------------

    signal sc_IorD : std_logic := '1';
    signal sc_WE_data : std_logic := '1';
    signal sc_WE_program_counter : std_logic := '1';
    signal sc_WE_instruction_reg : std_logic := '1';
    signal sc_WE_data_reg : std_logic := '1';
    signal sc_WE_alu_out_reg : std_logic := '1';
    signal sc_WE_reg_file : std_logic := '1';
    signal sc_WE_register_data_reg : std_logic := '1';
    signal sc_PorR : std_logic := '0';
    signal sc_DorP : std_logic := '0';
    signal sc_alu_Bmux : std_logic_vector(1 downto 0);
    signal sc_alu_control : std_logic_vector(2 downto 0);

-------------------------------------------------------------------------------
---- DATAPATH SIGNALS ---------------------------------------------------------
-------------------------------------------------------------------------------

---------------------------
------- Program Counter ---
---------------------------

-------------- Entrada

-- possui 32 bits para compatibilidade com saída de ALU. truncado na entrada de PC

    signal s_next_instruction_address : std_logic_vector(31 downto 0);

-------------- Saída

    signal s_current_instruction_address : std_logic_vector(11 downto 0);
    signal s_current_instruction_address_ext : std_logic_vector(31 downto 0);

--------------------
-------- Memória ---
--------------------

-------------- Entrada

    signal s_memory_address : std_logic_vector(11 downto 0);

-------------- Saída

    signal s_instruction : std_logic_vector(31 downto 0);

-------------------------------------------
-------- Instruction Address Register -----
-------------------------------------------

-------------- Entrada ( já declarada )

    -- signal s_instruction : std_logic_vector(31 downto 0);

-------------- Saída

    signal s_stored_instruction : std_logic_vector(31 downto 0);

--------------------------
-------- Data Register ---
--------------------------

-------------- Saída

    signal s_data_register_output : std_logic_vector(31 downto 0);

--------------------------
-------- Register File ---
--------------------------

-------------- Entrada

    signal s_reg_file_write_data : std_logic_vector(31 downto 0);

-------------- Saída

    signal s_rs_1_data : std_logic_vector(31 downto 0);
    signal s_rs_2_data : std_logic_vector(31 downto 0);

----------------
-------- ALU ---
----------------

-------------- Entrada A

    ------------------- Entradas Mux A

    signal s_alu_in_imm : std_logic_vector(31 downto 0);
    signal s_alu_in_constant : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
    signal s_alu_in_rs_2 : std_logic_vector(31 downto 0);
    signal s_alu_in_dead : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

    -------------------- Saída Mux A

    signal s_alu_A_in : std_logic_vector(31 downto 0);

-------------- Entrada B

    -------------------- Entradas Mux B

    signal s_alu_in_rs_1 : std_logic_vector(31 downto 0);
    signal s_alu_in_program_counter : std_logic_vector(31 downto 0);

    -------------------- Saída Mux B

    signal s_alu_B_in : std_logic_vector(31 downto 0);

 ------------ Saída ALU

    signal s_alu_out : std_logic_vector(31 downto 0);

--------------------------------------------------------------------------
-- Definicao de datapath -------------------------------------------------
--------------------------------------------------------------------------

    begin

--------------------------------------------------------------------------
-- Instanciacao de componentes -------------------------------------------
--------------------------------------------------------------------------

    u_program_counter: pc port map(
                                   clk => clk,
                                   entrada => s_next_instruction_address(11 downto 0),
                                   saida => s_current_instruction_address,
                                   we =>  sc_WE_program_counter,
                                   reset => set
                                   );

    u_instruction_memory: instruction_memory port map(
            set => set, -- sinal para carregamento de programa
            address => s_current_instruction_address,
            instruction => s_instruction
            );

    u_instruction_register: register_block port map(
                                                    we => sc_WE_instruction_reg,
                                                    next_input => s_instruction,
                                                    clk => clk,
                                                    last_input => s_stored_instruction
                                                   );

    u_data_register: register_block port map(
                                            we => sc_WE_instruction_reg,
                                            next_input => s_stored_instruction,
                                            clk => clk,
                                            last_input => s_data_register_output
                                            );

    u_register_file: register_file port map(
                                             rs_1 => s_stored_instruction(19 downto 15),
                                             rs_2 => s_stored_instruction(24 downto 20),
                                             rd => s_stored_instruction(11 downto 7),
                                             clk => clk,
                                             we => sc_WE_reg_file,
                                             write_data => s_reg_file_write_data,
                                             rs_1_data => s_rs_1_data,
                                             rs_2_data => s_rs_2_data
                                            );

    u_register_data_register: register_data_register port map(
                                                              we => sc_WE_register_data_reg,
                                                              rs_1_input => s_rs_1_data,
                                                              rs_2_input => s_rs_2_data,
                                                              clk => clk,
                                                              rs_1_output => s_alu_in_rs_1,
                                                              rs_2_output => s_alu_in_rs_2
                                                             );


    u_sign_extender_imm: signex port map(
                                     signex_in => s_stored_instruction(31 downto 20),
                                     signex_out => s_alu_in_imm
                                    );

    u_sign_extender_pc: signex port map(
                                     signex_in => s_current_instruction_address,
                                     signex_out => s_current_instruction_address_ext
                                    );

    u_alu_B_in_mux: mux41 port map(
                                    dado_ent_0 => s_alu_in_imm,
                                    dado_ent_1 => s_alu_in_constant,
                                    dado_ent_2 => s_alu_in_rs_2,
                                    dado_ent_3 => s_alu_in_dead,
                                    sele_ent => sc_alu_Bmux,
                                    dado_sai => s_alu_A_in
                                  );

    u_alu_A_in_mux: mux21 port map(
                                    dado_ent_0 => s_alu_in_rs_1,
                                    dado_ent_1 => s_current_instruction_address_ext,
                                    sele_ent => sc_PorR,
                                    dado_sai => s_alu_A_in
                                  );


    u_ALU: ula port map(
                        entrada_a => s_alu_A_in,
                        entrada_b => s_alu_B_in,
                        seletor   => sc_alu_control,
                        saida     => s_alu_out
                        );

    u_write_data_mux: mux21 port map(
                                    dado_ent_0 => s_next_instruction_address,
                                    dado_ent_1 => s_data_register_output,
                                    sele_ent => sc_DorP,
                                    dado_sai => s_reg_file_write_data
                                  );

    u_ALU_out_register: register_block port map(
                                                we => sc_WE_alu_out_reg,
                                                next_input => s_alu_out,
                                                clk => clk,
                                                last_input => s_next_instruction_address
                                                );

    u_mux_memory_address: mux21
                                generic map (largura_dado => 12)
                                port map(
                                        dado_ent_0 => s_next_instruction_address(11 downto 0),
                                        dado_ent_1 => s_current_instruction_address,
                                        sele_ent => sc_IorD,
                                        dado_sai => s_memory_address
                                      );
end riscv_arc;
