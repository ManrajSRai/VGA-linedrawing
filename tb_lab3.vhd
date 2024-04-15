library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_lab3 is
end tb_lab3;

architecture behavior of tb_lab3 is

	component lab3
	port(
		CLOCK_50            : in  STD_LOGIC;
		KEY                 : in  STD_LOGIC_VECTOR(3 downto 0);
		SW                  : in  STD_LOGIC_VECTOR(17 downto 0);
		VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR(9 downto 0);
		VGA_HS              : out STD_LOGIC;
		VGA_VS              : out STD_LOGIC;
		VGA_BLANK           : out STD_LOGIC;
		VGA_SYNC            : out STD_LOGIC;
		VGA_CLK             : out STD_LOGIC);
	end component;
	
	signal CLOCK_50 : STD_LOGIC := '0';
	signal KEY : STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
	signal SW : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
	signal VGA_R : STD_LOGIC_VECTOR(9 downto 0);
	signal VGA_G : STD_LOGIC_VECTOR(9 downto 0);
	signal VGA_B : STD_LOGIC_VECTOR(9 downto 0);
	signal VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : STD_LOGIC;
	
	signal colour:STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal x		:STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal y		:STD_LOGIC_VECTOR(6 DOWNTO 0);

-- Based on the following video, used to make testbench. 
-- https://www.youtube.com/watch?v=1PiqMRXQCAw
 begin
	uut: lab3
	port map(
		CLOCK_50 => CLOCK_50, KEY => KEY, SW => SW, VGA_R => VGA_R, VGA_G => VGA_G, VGA_B => VGA_B, VGA_HS => VGA_HS, VGA_VS => VGA_VS,
		VGA_BLANK => VGA_BLANK, VGA_SYNC => VGA_SYNC, VGA_CLK => VGA_CLK);
	
	
 	clock_OnOff :process
    	begin 
        CLOCK_50 <= '0'; 
        wait for 10 ns;--50Mhz is 20ns
        CLOCK_50 <= '1'; 
        wait for 10 ns;
    	end process;
	
	test_Process: process
	begin 
	
	-- Test reset
	KEY(3)<= '0';
	wait for 20 ns;
	KEY(3)<= '1';
	wait for 20 ns;
	
	-- 3 testcases
	SW(2 DOWNTO 0) <= "010";
	SW(9 DOWNTO 3) <= "0111110";
	SW(17 DOWNTO 10) <= "00001111";
	KEY(0) <= '0';
	wait for 20 ns;
	KEY(0) <= '1';
	wait for 20 ns;
	
	SW(2 DOWNTO 0) <= "110";
	SW(9 DOWNTO 3) <= "0001100";
	SW(17 DOWNTO 10) <= "01101101";
	KEY(0) <= '0';
	wait for 20 ns;
	KEY(0) <= '1';
	wait for 20 ns;

	KEY(3)<= '0';
	wait for 20 ns;
	KEY(3)<= '1';
	wait for 20 ns;
	
	SW(2 DOWNTO 0) <= "111";
	SW(9 DOWNTO 3) <= "1111111";
	SW(17 DOWNTO 10) <= "11111111";
	KEY(0) <= '1';
	wait for 20 ns;

	-- reset at end
	KEY(3)<= '0';
	wait for 20 ns;
	KEY(3)<= '1';
	wait;
	end process;
	
end behavior;
	