library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Used this resource to figure out the line drawing algorithm
-- https://uomustansiriyah.edu.iq/media/lectures/6/6_2020_12_19!10_52_38_PM.pdf



entity circuit is
    port(
        SW        : in  std_logic_vector(17 downto 0);
        key_input : in  std_logic_vector(3 downto 0);
        clock     : in  std_logic;
        plot      : out std_logic;
        colours   : out std_logic_vector(2 downto 0);
        x         : out std_logic_vector(7 downto 0);
        y         : out std_logic_vector(6 downto 0)
    );
end circuit;

architecture Behavioral of circuit is
    type state_type is (Idle, Reset, ClearScreen, PlotDot, StartLine, PlotLine, StartTriangle, 
	 PlotHypotenuse, StartHorizontal, PlotVertical, PlotHorizontal);
	 
    signal state, next_state: state_type := Idle;
    signal x0, y0, x1, y1, dx, dy: unsigned(7 downto 0);
    signal err: signed(9 downto 0);
    signal x_temp, y_temp, clear_x, clear_y: unsigned(8 downto 0);
    signal line_colours: std_logic_vector(2 downto 0);
begin
    process(clock)
    begin
        if rising_edge(clock) then
            state <= next_state;

            case state is
                when Idle =>
                    plot <= '0';
                    if key_input(3) = '0' then
                        next_state <= Reset;
                    elsif key_input(0) = '0' then
                        next_state <= PlotDot;
                    elsif key_input(1) = '0' then
                        next_state <= StartLine;
                    elsif key_input(2) = '0' then
                        next_state <= StartTriangle;
                    else
                        next_state <= Idle;
                    end if;

                when Reset =>
                    plot <= '0';
                    colours <= (others => '0');
                    x <= (others => '0');
                    y <= (others => '0');
                    clear_x <= (others => '0');
                    clear_y <= (others => '0');
                    next_state <= ClearScreen;

                when ClearScreen =>
                    plot <= '1';
                    colours <= "000"; -- Set colour to black for clearing
                    x <= std_logic_vector(clear_x(7 downto 0));
                    y <= std_logic_vector(clear_y(6 downto 0));

                    -- Increment clear_x, and reset and increment clear_y at screen width
                    if clear_x < "10100000" then -- x < 160
                        clear_x <= clear_x + 1;
                    elsif clear_y < "1111000" then -- y < 120
                        clear_x <= (others => '0');
                        clear_y <= clear_y + 1;
                    else
                        next_state <= Idle; -- Return to Idle once screen is cleared
                    end if;

                when PlotDot =>
                    colours <= SW(2 downto 0);
                    x <= SW(17 downto 10);
                    y <= SW(9 downto 3);
                    plot <= '1';
                    next_state <= Idle;

                when StartLine =>
                    x0 <= unsigned(SW(17 downto 10));
                    y0 <= ('0' & unsigned(SW(9 downto 3)));
                    x1 <= "01010000"; -- Fixed point x1 = 80
                    y1 <= "00111100"; -- Fixed point y1 = 60
                    line_colours <= SW(2 downto 0);

                    -- Calculate dx and dy
                    if x1 >= x0 then
                        dx <= x1 - x0;
                    else
                        dx <= x0 - x1;
                    end if;

                    if y1 >= y0 then
                        dy <= y1 - y0;
                    else
                        dy <= y0 - y1;
                    end if;

                    -- Initialize error term
                    err <= ("00" & ((signed(dx) - signed(dy))));

                    -- Set initial point for drawing
                    x_temp <= "0" & x0;
                    y_temp <= "0" & y0;

                    next_state <= PlotLine;

                when PlotLine =>
                    plot <= '1';
                    colours <= line_colours;
                    x <= std_logic_vector(x_temp(7 downto 0));
                    y <= std_logic_vector(y_temp(6 downto 0));

                    if x_temp(7 downto 0) = x1 and y_temp(6 downto 0) = y1 then
                        next_state <= Idle;  -- Finish line drawing
                    else
                        if err < 0 then
                            if x_temp(7 downto 0) < x1 then
                                x_temp <= x_temp + 1;
                            elsif x_temp(7 downto 0) > x1 then
                                x_temp <= x_temp - 1;
                            end if;
                            err <= resize((err + signed(2 * dy)),10);
                        else
                            if y_temp(6 downto 0) < y1 then
                                y_temp <= y_temp + 1;
                            elsif y_temp(6 downto 0) > y1 then
                                y_temp <= y_temp - 1;
                            end if;
                            err <= resize((err - signed(2 * dx)), 10);
                        end if;

                        next_state <= PlotLine;  -- Continue drawing
                    end if;
					
					 when StartTriangle =>
                    x0 <= unsigned(SW(17 downto 10));
                    y0 <= ('0' & unsigned(SW(9 downto 3)));
                    x1 <= "01010000"; -- Fixed point x1 = 80
                    y1 <= "00111100"; -- Fixed point y1 = 60
                    line_colours <= SW(2 downto 0);

                    -- Calculate dx and dy
                    if x1 >= x0 then
                        dx <= x1 - x0;
                    else
                        dx <= x0 - x1;
                    end if;

                    if y1 >= y0 then
                        dy <= y1 - y0;
                    else
                        dy <= y0 - y1;
                    end if;

                    -- Initialize error term
                    err <= ("00" & ((signed(dx) - signed(dy))));

                    -- Set initial point for drawing
                    x_temp <= "0" & x0;
                    y_temp <= "0" & y0;

                    next_state <= PlotHypotenuse;

                when PlotHypotenuse =>
                    plot <= '1';
                    colours <= line_colours;
                    x <= std_logic_vector(x_temp(7 downto 0));
                    y <= std_logic_vector(y_temp(6 downto 0));

                    if x_temp(7 downto 0) = x1 and y_temp(6 downto 0) = y1 then
                        next_state <= StartHorizontal;  -- Finish line drawing
								
                    else
								--If err < 0 then we move in the x, else move in y
                        if err < 0 then
									 
									 --Based of relative position to middle, move left or right
                            if x_temp(7 downto 0) < x1 then
                                x_temp <= x_temp + 1;
                            elsif x_temp(7 downto 0) > x1 then
                                x_temp <= x_temp - 1;
                            end if;
                            err <= resize((err + signed(2 * dy)),10);
                        else
									 --Based of relative position to middle, move up or down
                            if y_temp(6 downto 0) < y1 then
                                y_temp <= y_temp + 1;
                            elsif y_temp(6 downto 0) > y1 then
                                y_temp <= y_temp - 1;
                            end if;
									 
									 --Update the error value
                            err <= resize((err - signed(2 * dx)), 10);
                        end if;

                        next_state <= PlotHypotenuse;  -- Continue drawing
                    end if;
						  
					when StartHorizontal =>
						 x_temp <= "001010000"; -- Starting point x = 80
						 y_temp <= "000111100"; -- Starting point y = 60
						 next_state <= PlotHorizontal;

					when PlotHorizontal =>
						 plot <= '1';
						 colours <= line_colours; -- Use the colour from your SW input
						 x <= std_logic_vector(x_temp(7 downto 0));
						 y <= std_logic_vector(y_temp(6 downto 0)); -- y fixed at 60

						 if x_temp(7 downto 0) /= unsigned(SW(17 downto 10)) then -- Check if x_temp has reached x_input
							  if x_temp(7 downto 0) < unsigned(SW(17 downto 10)) then
									x_temp <= x_temp + 1; -- Increment x_temp towards x_input
							  else
									x_temp <= x_temp - 1; -- Decrement x_temp towards x_input
							  end if;
							  next_state <= PlotHorizontal; -- Continue drawing horizontal line
						 else
							  next_state <= PlotVertical; -- Start drawing vertical line
						 end if;

					when PlotVertical =>
						 plot <= '1';
						 colours <= line_colours; -- Use the colour from your SW input
						 x <= std_logic_vector(x_temp(7 downto 0)); -- x fixed at x_input
						 y <= std_logic_vector(y_temp(6 downto 0));

						 if y_temp(6 downto 0) /= unsigned(SW(9 downto 3)) then -- Check if y_temp has reached y_input
							  if y_temp(6 downto 0) < unsigned(SW(9 downto 3)) then
									y_temp <= y_temp + 1; -- Increment y_temp towards y_input
							  else
									y_temp <= y_temp - 1; -- Decrement y_temp towards y_input
							  end if;
							  next_state <= PlotVertical; -- Continue drawing vertical line
						 else
							  next_state <= Idle; -- Drawing complete, return to Idle
						 end if;


                when others =>
                    next_state <= Idle;
            end case;
        end if;
    end process;
end Behavioral;
