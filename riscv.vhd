library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;
use ieee.NUMERIC_STD.SHIFT_LEFT;


entity riscv is
    generic(n_peripherals: integer := 2);
    port(
        clk : in std_logic;
        set : in std_logic;
        interruption_requests : in std_ulogic_vector(n_peripherals - 1 downto 0)
        );
end riscv;

architecture riscv_arc of riscv is

-------------------------------------------------------------------------------
-- Declaracao de componentes --------------------------------------------------
-------------------------------------------------------------------------------

    component control is
        port(
        -- in
            opcode : in std_logic_vector(6 downto 0);
            funct3 : in std_logic_vector(2 downto 0);
            funct7 : in std_logic_vector(6 downto 0);
            zero : in std_logic ;
            neg : in std_logic ;
            set : in std_logic ;
            clk : in std_logic ;
            interrupt : in std_logic ;
        -- out
            sc_IorD : out std_logic ;
            sc_WE_data : out std_logic ;
            sc_WE_program_counter : out std_logic ;
            sc_WE_memory : out std_logic ;
            sc_WE_data_reg : out std_logic ;
            sc_WE_instruction_reg : out std_logic ;
            sc_WE_reg_file : out std_logic ;
            sc_alu_src_A : out std_logic ;
            sc_mem_to_reg : out std_logic ;
            sc_pc_src : out std_logic_vector(1 downto 0) ;
            sc_Zext : out std_logic ;
            sc_alu_src_B : out std_logic_vector(1 downto 0) ;
            sc_alu_control : out std_logic_vector(2 downto 0) ;
            sc_rar : out std_logic
            );
    end component;

    component interruption_handler is
        generic(n_peripherals: integer := 2);
        port (
            -- in
                clk : in std_ulogic;
                ack : in std_ulogic;
                interruption_requests : in std_ulogic_vector(n_peripherals - 1 downto 0);
                original_instruction_address : in std_logic_vector(11 downto 0);
                interruption_enable_write : in std_ulogic_vector(n_peripherals - 1 downto 0);
                sc_rar : in std_logic;
            -- out
                interrupt_flag : out std_ulogic;
                interruption_enable_read : out std_ulogic_vector(n_peripherals - 1 downto 0);
                return_address : out std_logic_vector(11 downto 0);
                isr_address : out std_ulogic_vector(11 downto 0)
            );
    end component;

    component ula is
        generic (
            largura_dado : natural := 32
        );

        port (
            entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
            entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
            seletor   : in std_logic_vector(2 downto 0);
            saida     : out std_logic_vector((largura_dado - 1) downto 0);
            zero     : out std_logic;
            negativo     : out std_logic
        );
    end component;

    component register_block is
        generic(size : integer := 32);
        port(
             we : in std_logic;
             next_input : in std_logic_vector(size - 1 downto 0);
             clk : in std_logic;
             last_input : out std_logic_vector(size - 1 downto 0)
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

    component memory is

        port(
                clk : in std_logic;
                we : in std_logic;
                set : in std_logic; -- sinal para carregamento de progrma
                address : in std_logic_vector(11 downto 0);
                write_data: in std_logic_vector(31 downto 0);
                data : out std_logic_vector(31 downto 0));

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

    component shift_left is
        generic(size: integer := 32); -- na verdade é tamanho - 1
        port(
             input: in std_logic_vector(size downto 0);
             output: out std_logic_vector(size downto 0)
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
---- DATAPATH SIGNALS ---------------------------------------------------------
-------------------------------------------------------------------------------

------------------------------
------- Sinais de Controle ---
------------------------------

    signal sc_IorD : std_logic ;
    signal sc_WE_data : std_logic ;
    signal sc_WE_data_reg : std_logic ;
    signal sc_WE_program_counter : std_logic ;
    signal sc_WE_memory : std_logic ;
    signal sc_WE_instruction_reg : std_logic ;
    signal sc_WE_reg_file : std_logic ;
    signal sc_alu_src_A : std_logic ;
    signal sc_mem_to_reg : std_logic ;
    signal sc_pc_src : std_logic_vector(1 downto 0) ;
    signal sc_Zext : std_logic ;
    signal sc_rar : std_logic ;
    signal sc_alu_src_B : std_logic_vector(1 downto 0) ;
    signal sc_alu_control : std_logic_vector(2 downto 0) ;

---------------------------
------- Program Counter ---
---------------------------

-------------- Entrada

-- possui 32 bits para compatibilidade com saída de ALU. truncado na entrada de PC

    signal s_next_instruction_address : std_logic_vector(11 downto 0);

-------------- Saída

    signal s_current_instruction_address : std_logic_vector(11 downto 0);
    signal s_current_instruction_address_ext : std_logic_vector(31 downto 0);

--------------------
-------- Memória ---
--------------------

-------------- Entrada

    signal s_memory_address : std_logic_vector(31 downto 0);

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
    signal s_alu_in_constant : std_logic_vector(31 downto 0) := "00000000000000000000000000000100";
    signal s_alu_in_rs_2 : std_logic_vector(31 downto 0);
    signal s_alu_in_shifted_imm : std_logic_vector(31 downto 0);

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
    signal s_alu_zero_out : std_logic ;
    signal s_alu_neg_out : std_logic ;

-------------------------
-------- ALU Register ---
-------------------------

    signal s_alu_reg_out : std_logic_vector(31 downto 0);

---------------------------------
-------- Interruption Handler ---
---------------------------------

    signal s_interrupt_flag : std_ulogic;
    signal s_isr_address : std_ulogic_vector(11 downto 0);
    signal s_return_address : std_logic_vector(11 downto 0);
    signal s_interruption_enable_write : std_ulogic_vector(1 downto 0) := "11";
    signal s_interruption_enable_read : std_ulogic_vector(1 downto 0);

--------------------------------------------------------------------------
-- Definicao de datapath -------------------------------------------------
--------------------------------------------------------------------------

    begin

--------------------------------------------------------------------------
-- Instanciacao de componentes -------------------------------------------
--------------------------------------------------------------------------

    u_control: control port map(
                                opcode => s_stored_instruction(6 downto 0),
                                funct3 => s_stored_instruction(14 downto 12),
                                funct7 => s_stored_instruction(31 downto 25),
                                zero => s_alu_zero_out,
                                neg => s_alu_neg_out,
                                interrupt => s_interrupt_flag,

                                set => set,
                                clk => clk,

                                sc_IorD => sc_IorD,
                                sc_WE_data => sc_WE_data,
                                sc_WE_data_reg => sc_WE_data_reg,
                                sc_WE_program_counter => sc_WE_program_counter,
                                sc_WE_memory => sc_WE_memory,
                                sc_WE_instruction_reg => sc_WE_instruction_reg,
                                sc_WE_reg_file => sc_WE_reg_file,
                                sc_alu_src_A => sc_alu_src_A,
                                sc_mem_to_reg => sc_mem_to_reg,
                                sc_pc_src => sc_pc_src,
                                sc_Zext => sc_Zext,
                                sc_alu_src_B => sc_alu_src_B,
                                sc_alu_control => sc_alu_control,
                                sc_rar => sc_rar
                               );

    u_interruption_handler: interruption_handler port map (
                clk => clk,
                ack => '0',
                interruption_requests => interruption_requests,
                original_instruction_address => s_current_instruction_address,
                interruption_enable_write => s_interruption_enable_write,
                sc_rar => sc_rar,
                interruption_enable_read => s_interruption_enable_read,
                interrupt_flag => s_interrupt_flag,
                return_address => s_return_address,
                isr_address => s_isr_address
            );

    u_program_counter: pc port map(
                                   clk => clk,
                                   entrada => s_next_instruction_address,
                                   saida => s_current_instruction_address,
                                   we =>  sc_WE_program_counter,
                                   reset => set
                                   );

    u_memory: memory port map(
            clk => clk,
            we => sc_WE_memory,
            set => set, -- sinal para carregamento de programa
            address => s_current_instruction_address,
            write_data => s_alu_in_rs_2,
            data => s_instruction
            );

    u_instruction_register: register_block port map(
                                                    we => sc_WE_instruction_reg,
                                                    next_input => s_instruction,
                                                    clk => clk,
                                                    last_input => s_stored_instruction
                                                   );

    u_data_register: register_block port map(
                                            we => sc_WE_data_reg,
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
                                                              we => '1',
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

    u_left_shifter : shift_left port map(
                                         input => s_alu_in_imm,
                                         output => s_alu_in_shifted_imm
                                         );

    u_alu_B_in_mux: mux41 port map(
                                    dado_ent_0 => s_alu_in_rs_2,
                                    dado_ent_1 => s_alu_in_constant,
                                    dado_ent_2 => s_alu_in_shifted_imm,
                                    dado_ent_3 => s_alu_in_imm,
                                    sele_ent => sc_alu_src_B,
                                    dado_sai => s_alu_B_in
                                  );

    u_alu_A_in_mux: mux21 port map(
                                    dado_ent_0 => s_current_instruction_address_ext,
                                    dado_ent_1 => s_alu_in_rs_1,
                                    sele_ent => sc_alu_src_A,
                                    dado_sai => s_alu_A_in
                                  );


    u_ALU: ula port map(
                        entrada_a => s_alu_A_in,
                        entrada_b => s_alu_B_in,
                        seletor => sc_alu_control,
                        saida => s_alu_out,
                        zero => s_alu_zero_out,
                        negativo => s_alu_neg_out
                        );

    u_write_data_mux: mux21 port map(
                                    dado_ent_1 => s_data_register_output,
                                    dado_ent_0 => s_alu_reg_out,
                                    sele_ent => sc_mem_to_reg,
                                    dado_sai => s_reg_file_write_data
                                  );

    u_ALU_out_register: register_block port map(
                                                we => '1',
                                                next_input => s_alu_out,
                                                clk => clk,
                                                last_input => s_alu_reg_out
                                                );

    u_mux_memory_address: mux21
                                generic map (largura_dado => 32)
                                port map(
                                        dado_ent_0 => s_current_instruction_address_ext,
                                        dado_ent_1 => s_alu_reg_out,
                                        sele_ent => sc_IorD,
                                        dado_sai => s_memory_address
                                      );

    u_mux_instruction_address: mux41
                                    generic map (largura_dado => 12)
                                    port map(
                                            dado_ent_0 => s_alu_out(11 downto 0),
                                            dado_ent_1 => s_alu_reg_out(11 downto 0),
                                            dado_ent_2 => to_stdlogicvector(s_isr_address),
                                            dado_ent_3 => s_return_address,
                                            sele_ent => sc_pc_src,
                                            dado_sai => s_next_instruction_address
                                          );
end riscv_arc;
