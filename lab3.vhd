library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(
    CLOCK_50            : in  std_logic;
    KEY                 : in  std_logic_vector(3 downto 0);
    SW                  : in  std_logic_vector(17 downto 0);
    VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
    VGA_HS              : out std_logic;
    VGA_VS              : out std_logic;
    VGA_BLANK           : out std_logic;
    VGA_SYNC            : out std_logic;
    VGA_CLK             : out std_logic
  );
end lab3;

architecture rtl of lab3 is
  -- Component from the Verilog file: vga_adapter.v
  component vga_adapter
    generic(RESOLUTION : string);
    port(
      resetn                                       : in  std_logic;
      clock                                        : in  std_logic;
      colour                                       : in  std_logic_vector(2 downto 0);
      x                                            : in  std_logic_vector(7 downto 0);
      y                                            : in  std_logic_vector(6 downto 0);
      plot                                         : in  std_logic;
      VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
      VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic
    );
  end component;

  component circuit
    port(
      SW       : in  std_logic_vector(17 downto 0);
      key_input: in  std_logic_vector(3 downto 0);
      clock    : in  std_logic;
      plot     : out std_logic;
      colours  : out std_logic_vector(2 downto 0);
      x        : out std_logic_vector(7 downto 0);
      y        : out std_logic_vector(6 downto 0)
    );
  end component;

  component debouncer
    port(
      clk     : in  std_logic;
      btn_in  : in  std_logic_vector(3 downto 0);
      btn_out : out std_logic_vector(3 downto 0)
    );
  end component;

  signal debounced_keys : std_logic_vector(3 downto 0);
  signal plot           : std_logic;
  signal colour         : std_logic_vector(2 downto 0);
  signal x              : std_logic_vector(7 downto 0);
  signal y              : std_logic_vector(6 downto 0);

begin
  -- Includes the vga adapter, which should be in your project
  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(
      resetn    => debounced_keys(3),
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
      VGA_CLK   => VGA_CLK
    );

  pre_circuit: circuit
    port map(
      SW        => SW,
      key_input => debounced_keys,
      clock     => CLOCK_50,
      plot      => plot,
      colours   => colour,
      x         => x,
      y         => y
    );

  debouncer_instance : debouncer
    port map(
      clk     => CLOCK_50,
      btn_in  => KEY,
      btn_out => debounced_keys
    );

  -- Rest of your code goes here, as well as possibly additional files

end rtl;