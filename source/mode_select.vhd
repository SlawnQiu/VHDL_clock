LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY mode_select IS
PORT(clk_1k,key:in std_logic;
  mode_out:out std_logic_vector(1 downto 0);
  led0, led1: out std_logic);
END mode_select;

ARCHITECTURE behav OF mode_select IS
SIGNAL FLAG:INTEGER RANGE 0 TO 3;
signal key1,key2:std_logic ;
BEGIN
PROCESS(clk_1k)
	BEGIN
		IF rising_edge(clk_1k) THEN
		    key1 <= key;
		    key2<=key1 and (not key);
			IF(key2='1') THEN
				flag <= flag + 1;    --flag的累加分别对因不同的功能显示
			END IF;
		END IF;
	END PROCESS;
	
PROCESS(clk_1k)
	BEGIN
		IF rising_edge(clk_1k) THEN
			CASE flag IS			--用case语句分别根据flag进入不同的功能
				WHEN 0 => 
					mode_out <= "00";
					led0 <= '0'; led1 <= '0';
				WHEN 1 => 
					mode_out <= "01";
					led0 <= '0'; led1 <= '1';
				WHEN 2 => 
					mode_out <= "10";
					led0 <= '1'; led1 <= '0';
				WHEN 3 => 
					mode_out <= "11";
					led0 <= '1'; led1 <= '1';
			END CASE;
		END IF;
END PROCESS;
END behav;
