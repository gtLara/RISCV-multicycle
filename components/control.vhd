library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity control is
    port(
    -- in
        opcode : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        funct7 : in std_logic_vector(6 downto 0);
        set : in std_logic ;
        clk : in std_logic ;
    -- out
        sc_IorD : out std_logic ;
        sc_WE_data : out std_logic ;
        sc_WE_program_counter : out std_logic ;
        sc_WE_memory : out std_logic ;
        sc_WE_instruction_reg : out std_logic ;
        sc_WE_data_reg : out std_logic ;
        sc_WE_alu_out_reg : out std_logic ;
        sc_WE_reg_file : out std_logic ;
        sc_WE_register_data_reg : out std_logic ;
        sc_PorR : out std_logic ;
        sc_DorP : out std_logic ;
        sc_alu_Bmux : out std_logic_vector(1 downto 0);
        sc_alu_control : out std_logic_vector(2 downto 0)
end entity;

architecture control_arc of control is
begin
   type state_type is (fetch, 
                       decode, 
                       jalr, 
                       jal, 
                       branch, 
                       I_execute, 
                       I_writeback, 
                       R_execute, 
                       R_writeback, 
                       mem_adr, 
                       sw_mem_write,
                       mem_read,
                       lb_mem_write,
                       lw_mem_write
                       );

    signal state : state_type := fetch;

    signal s_alu_op : std_logic_vector(1 downto 0) ;

    process(clk, set)
    begin
        if (set = '1') then -- inicializacao de FSM
            state <= fetch

        elsif rising_edge(clk) then
            case state is
                when fetch =>
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '1';
                    sc_WE_memory <= '0';
                    sc_WE_instruction_reg <= '1';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_PorR <= '0';
                    sc_DorP <= '0';
                    sc_alu_Bmux <= "01";
                    sc_alu_op <= "00";

                -- Next State
                    state <= decode;

                when decode => 
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '0';
                    sc_WE_memory <= '0';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_PorR <= '0';
                    sc_DorP <= '0';
                    sc_alu_Bmux <= "01";
                    sc_alu_op <= "00";

                -- Next State
                    if (opcode = "1100111") then
                        state <= jalr;

                    elsif ( opcode = "1101111") then
                        state <= jal;

                    elsif ( opcode = "1100011") then
                        state <= branch;

                    elsif ( opcode = "0010011") then
                        state <= I_execute;

                    elsif ( opcode = "0110011") then
                        state <= R_execute;

                    elsif ( opcode = "0100011" or opcode = "0000011") then
                        state <= mem_adr;

                    end if;

                when jalr => 
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '1';
                    sc_WE_memory <= '0';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_PorR <= '0';
                    sc_DorP <= '0';
                    sc_alu_Bmux <= "10";
                    sc_alu_op <= "00";

                -- Next State
                    state <= fetch;

                when jal => 
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '1';
                    sc_WE_memory <= '0';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_PorR <= '0';
                    sc_DorP <= '0';
                    sc_alu_Bmux <= "10";
                    sc_alu_op <= "00";

                -- Next State
                    state <= fetch;

                when branch => 
                when I_execute => 
                when I_writeback => 
                when R_execute => 
                when R_writeback => 
                when mem_adr => 
                when sw_mem_write =>
                when mem_read =>
                when lb_mem_write =>
                when lw_mem_write =>

end control_arc;
