LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY present_shake IS
PORT(  clk_50M,sw0_f,SW1_f,SW2_f,SW3_f:IN STD_LOGIC;
       sw0_L,SW1_L,SW2_L,SW3_L:OUT STD_LOGIC);
END present_shake;

ARCHITECTURE behav OF present_shake IS

SIGNAL key0_reg1,key1_reg1,key2_reg1,key3_reg1,key0_reg2,key1_reg2,key2_reg2,key3_reg2:STD_LOGIC;
BEGIN
PROCESS(clk_50M)
VARIABLE count : integer RANGE 0 TO 500000;
BEGIN
		IF rising_edge(clk_50M) THEN
			count := count + 1;
			IF(count = 500000) THEN
				count := 0;
				key0_reg1<=sw0_f;
				key1_reg1<=sw1_f;
				key2_reg1<=sw2_f;
				key3_reg1<=sw3_f;
			END IF;
			key0_reg2<=key0_reg1;
			key1_reg2<=key1_reg1;
			key2_reg2<=key2_reg1;
			key3_reg2<=key3_reg1;
			sw0_L<=key0_reg2 AND (NOT key0_reg1);  --Ïû¶¶
			sw1_L<=key1_reg2 AND (NOT key1_reg1);
			sw2_L<=key2_reg2 AND (NOT key2_reg1);
			sw3_L<=key3_reg2 AND (NOT key3_reg1);
		END IF;
END PROCESS;
END BEHAV;
