LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY mux2 IS
PORT(  di_s1_1,di_s2_1,di_m1_1,di_m2_1,di_h1_1,di_h2_1,
       di_s1_2,di_s2_2,di_m1_2,di_m2_2,di_h1_2,di_h2_2,
	   di_s1_3,di_s2_3,di_m1_3,di_m2_3,di_h1_3,di_h2_3,
	   di_s1_4,di_s2_4,di_m1_4,di_m2_4,di_h1_4,di_h2_4:in std_logic_vector(3 downto 0);
	   clk_1k:in std_logic;
	   mode_out:in std_logic_vector(1 downto 0);
	   do_s1,do_s2,do_m1,do_m2,do_h1,do_h2:out std_logic_vector(3 downto 0));
END mux2;

ARCHITECTURE behav OF mux2 IS
BEGIN
PROCESS(clk_1k)
BEGIN
    if rising_edge(clk_1k) then
        IF mode_out="00" THEN
				do_s1 <= di_s1_1;
				do_s2 <= di_s2_1;
				do_m1 <= di_m1_1;
				do_m2 <= di_m2_1;
				do_h1 <= di_h1_1;
				do_h2 <= di_h2_1;
		ELSIF mode_out="01" THEN
				do_s1 <= di_s1_2;
				do_s2 <= di_s2_2;
				do_m1 <= di_m1_2;
				do_m2 <= di_m2_2;
				do_h1 <= di_h1_2;
				do_h2 <= di_h2_2;
				
			ELSIF mode_out="10" THEN
				do_s1 <= di_s1_3;
				do_s2 <= di_s2_3;
				do_m1 <= di_m1_3;
				do_m2 <= di_m2_3;
				do_h1 <= di_h1_3;
				do_h2 <= di_h2_3;
			else
				do_s1 <= di_s1_4;
				do_s2 <= di_s2_4;
				do_m1 <= di_m1_4;
				do_m2 <= di_m2_4;
				do_h1 <= di_h1_4;
				do_h2 <= di_h2_4;
			END IF;		
end if;
END PROCESS;
END behav;
