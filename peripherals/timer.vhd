library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
 
entity timer is
   port(
    --in
      clk : in std_logic;
      set : in std_logic;
      we : in std_logic;
      data_in : in std_logic_vector(31 downto 0);
    --out
      sample : out std_logic;
      data_out : out std_logic_vector(31 downto 0));
end entity timer;

architecture timer_arc of timer is

   signal cnt : unsigned(31 downto 0) := (others => '0');

begin
    -- Carry generation
    do_timer: process (clk, set)
    begin
        if (set='1') then
            cnt <= (others => '0');
            sample <= '0';
        elsif rising_edge(clk) then
            if (we='1') then
                if (unsigned(data_in) > cnt) then
                    cnt <= cnt+1;
                    sample <= '0';
                else
                    sample <= '1';
                end if;
            end if;
        end if; 
        data_out <= std_logic_vector(cnt);
    end process do_timer;
end architecture timer_arc; 
