library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
		 
end lab3;

architecture rtl of lab3 is

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;
  
  component circuit
  port(SW    : in  STD_LOGIC_VECTOR(17 downto 0);
		enter : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		clock : IN STD_LOGIC;
		plot 	: OUT STD_LOGIC;
		colours:OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		x		 :OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		y	    :OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
  end component;
  
  signal p_done : STD_LOGIC;
  signal c_sig : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal x_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal y_sig : STD_LOGIC_VECTOR(6 DOWNTO 0);
  
  signal plot : STD_LOGIC;
  signal colour : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal x : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal y : STD_LOGIC_VECTOR(6 DOWNTO 0);
  
  
begin

  -- includes the vga adapter, which should be in your project 

  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => x,
             y         => y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);
				 
	pre_circuit: circuit
	port map(SW => SW,
				enter => KEY(0),
				reset => KEY(3),
				clock => CLOCK_50,
				plot => plot,
				colours => colour,
				x => x,
				y => y);
								 

  -- rest of your code goes here, as well as possibly additional files

end RTL;
