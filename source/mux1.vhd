LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY mux1 IS
PORT(  SW1,SW2,SW3:IN STD_LOGIC;
       SW1_1,SW2_1,SW3_1,SW1_2,SW2_2,SW3_2,SW1_3,SW2_3,SW3_3,SW1_4,SW2_4,SW3_4:OUT STD_LOGIC;
	   mode_out:in std_logic_vector(1 downto 0));
END mux1;

ARCHITECTURE behav OF mux1 IS
BEGIN
PROCESS(mode_out)
BEGIN
    IF mode_out="00" THEN
				SW1_1 <= SW1;
				SW2_1 <= SW2;
				SW3_1 <= SW3;
		ELSIF mode_out="01" THEN
				SW1_2 <= SW1;
				SW2_2 <= SW2;
				SW3_2 <= SW3;
				
			ELSIF mode_out="10" THEN
				SW1_3 <= SW1;
				SW2_3 <= SW2;
				SW3_3 <= SW3;
			else
				SW1_4 <= SW1;
				SW2_4 <= SW2;
				SW3_4 <= SW3;
			END IF;		
END PROCESS;
END behav;