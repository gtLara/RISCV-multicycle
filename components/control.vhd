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
        sc_alu_src_A : out std_logic ;
        sc_mem_to_reg : out std_logic ;
        sc_Zext : out std_logic ;
        sc_alu_src_B : out std_logic_vector(1 downto 0);
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
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "01";
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
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "01";
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

                    elsif ( opcode = "0100011" or opcode = "0000011") then -- sw ; lw, lb
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
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "10";
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
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "10";
                    sc_alu_op <= "00";

                -- Next State
                    state <= fetch;

                when branch =>
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '0'; -- nao deveria ser 1? não. PC enable entra em um OR junto com o resultado da branch (dATA_PATH2.png)
                    sc_WE_memory <= '0';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_alu_src_A <= '1';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "00";
                    sc_alu_op <= "10";

                -- Next State
                    state <= fetch;

                when I_execute =>
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
                    sc_alu_src_A <= '1';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "11";
                    sc_alu_op <= "10";

                -- Next State
                    state <= I_writeback;

                when I_writeback =>
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '0';
                    sc_WE_memory <= '0';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '1';
                    sc_WE_register_data_reg <= '0';
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "00";
                    sc_alu_op <= "00";

                -- Next State
                    state <= fetch;

                when R_execute =>
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
                    sc_alu_src_A <= '1';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "00";
                    sc_alu_op <= "10";

                -- Next State
                    state <= R_writeback;

                when R_writeback =>
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '0';
                    sc_WE_memory <= '0';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '1';
                    sc_WE_register_data_reg <= '0';
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "00";
                    sc_alu_op <= "00";

                -- Next State
                    state <= fetch;

                when mem_adr =>
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
                    sc_alu_src_A <= '1';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "11";
                    sc_alu_op <= "00";

                -- Next State
                    if (opcode = "0100011") then
                        state <= sw_mem_write;
                    elsif (opcode = "0000011") then
                        state <= mem_read;
                    end if;

                when sw_mem_write =>
                -- Control Signals
                    sc_IorD <= '1';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '0';
                    sc_WE_memory <= '1';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "00";
                    sc_alu_op <= "00";

                -- Next State
                    state <= fetch;

                when mem_read =>
                -- Control Signals
                    sc_IorD <= '1';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '0';
                    sc_WE_memory <= '0';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '0';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "00";
                    sc_alu_op <= "00";

                -- Next State
                    if (funct3 = "000") then -- lb
                        state <= lb_mem_write;
                    elsif (funct3 = "010") then -- lw
                        state <= lw_mem_write;
                    end if;

                when lb_mem_write =>
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '0';
                    sc_WE_memory <= '1';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '1';
                    sc_Zext <= '1';
                    sc_alu_src_B <= "00";
                    sc_alu_op <= "00";

                -- Next State
                    state <= fetch;

                when lw_mem_write =>
                -- Control Signals
                    sc_IorD <= '0';
                    sc_WE_data <= '0';
                    sc_WE_program_counter <= '0';
                    sc_WE_memory <= '1';
                    sc_WE_instruction_reg <= '0';
                    sc_WE_data_reg <= '0';
                    sc_WE_alu_out_reg <= '0';
                    sc_WE_reg_file <= '0';
                    sc_WE_register_data_reg <= '0';
                    sc_alu_src_A <= '0';
                    sc_mem_to_reg <= '1';
                    sc_Zext <= '0';
                    sc_alu_src_B <= "00";
                    sc_alu_op <= "00";

                -- Next State
                    state <= fetch;

		end case;
		
	 	--Tabela Verdade (ALU Control) 
		case s_alu_op is 
			when "00"=>
		       	sc_alu_control<="010";

			when "01"=>
		       	sc_alu_control<="110";

			when "11"=>		--assumi que para esse caso a preferência é do subtract
		       	sc_alu_control<="110";

			when "10"=>
				if (funct3="000") then

					if (funct7="0000000")
						sc_alu_control<="010";
					
					else 
						sc_alu_control<="110";
					end if;
					
				elsif(funct3="111") then
					sc_alu_control <="000";

				elsif(funct3="110") then
					sc_alu_control <="001";

				elsif(funct3="110") then
					sc_alu_control <="111";
			
				end if;
		end case;
	end if;
end control_arc;
