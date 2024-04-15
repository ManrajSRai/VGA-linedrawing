LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY debouncer IS
    PORT(
        clk      : IN  std_logic;
        btn_in   : IN  std_logic_vector(3 downto 0); -- Input for 4 buttons
        btn_out  : OUT std_logic_vector(3 downto 0)
    );
END debouncer;

ARCHITECTURE Behavioral OF debouncer IS
    TYPE counter_array IS ARRAY (0 TO 3) OF UNSIGNED(15 DOWNTO 0);
    TYPE btn_reg_array IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL counter : counter_array := (OTHERS => (OTHERS => '0'));
    SIGNAL btn_reg : btn_reg_array := (OTHERS => (OTHERS => '0'));
BEGIN

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            FOR i IN 0 TO 3 LOOP
                btn_reg(i) <= btn_reg(i)(0) & btn_in(i);

                IF btn_reg(i)(1) = btn_reg(i)(0) THEN
                    IF counter(i) /=  to_unsigned(60000,16) THEN
                        counter(i) <= counter(i) + 1;
                    ELSIF btn_reg(i) = "11" THEN
                        btn_out(i) <= '1';
                    ELSE
                        btn_out(i) <= '0';
                    END IF;
                ELSE
                    counter(i) <= (OTHERS => '0');
                END IF;
            END LOOP;
        END IF;
    END PROCESS;

END Behavioral;