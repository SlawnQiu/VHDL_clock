LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY mode_select IS
PORT(clk_1k,key:in std_logic;
  mode_out:out std_logic_vector(1 downto 0));
END mode_select;

ARCHITECTURE behav OF mode_select IS
SIGNAL FLAG:INTEGER RANGE 0 TO 3;
BEGIN
PROCESS(clk_1k)
	BEGIN
		IF rising_edge(clk_1k) THEN
			IF(key='0') THEN
				flag <= flag + 1;    --flag的累加分别对因不同的功能显示
			END IF;
		END IF;
	END PROCESS;
	
PROCESS(clk_1k)
	BEGIN
		IF rising_edge(clk_1k) THEN
			CASE flag IS			--用case语句分别根据flag进入不同的功能
				WHEN 0 => mode_out <= "00";
				WHEN 1 => mode_out <= "01";
				WHEN 2 => mode_out <= "10";
				WHEN 3 => mode_out <= "11";
			END CASE;
		END IF;
END PROCESS;
END behav;
