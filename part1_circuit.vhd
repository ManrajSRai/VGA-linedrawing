library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity circuit is 
port( SW    : IN  STD_LOGIC_VECTOR(17 downto 0);
        enter : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        clock : IN STD_LOGIC;
        plot     : OUT STD_LOGIC;
        colours:OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        x         :OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        y        :OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END entity; 

architecture Behavioral of circuit is
begin

    process(clock,reset)

    begin
    if reset = '0' then
        plot <= '0';
        colours <= (others =>'0');
        x <= (others =>'0');
        y <= (others =>'0');
    elsif rising_edge(clock) then
        if enter = '0' then
            plot <= '1';
            colours <= SW(2 DOWNTO 0);
            x <= SW(17 DOWNTO 10);
            y <= SW(9 DOWNTO 3);
        else
            plot <= '0';
        end if;
    end if;
    end process;
end Behavioral;
