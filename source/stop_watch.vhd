LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY STOP_WATCH IS
	PORT(
			CLK : IN STD_LOGIC;
			SW1, SW2, SW3 : IN STD_LOGIC;
			OMS0, OMS1, OSEC0, OSEC1, OMIN0, OMIN1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
END ENTITY;

ARCHITECTURE BEHAV OF STOP_WATCH IS
	
TYPE MODE IS (STOP, RUN, PAUSE);	
SIGNAL MS0, MS1, SEC0, SEC1, MIN0, MIN1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL COUNT10 : INTEGER RANGE 0 TO 9;
SIGNAL STATE : MODE := STOP;
SIGNAL TMP, TMP1, SW1_DROP, SW2_DROP : STD_LOGIC;
BEGIN

PROCESS(CLK)
BEGIN
IF CLK'EVENT AND CLK='1' THEN
	TMP <= SW1;
END IF;
END PROCESS;
SW1_DROP <= '0' WHEN (SW1='0' AND TMP ='1') ELSE '1';

PROCESS(CLK)
BEGIN
IF CLK'EVENT AND CLK='1' THEN
	TMP1 <= SW2;
END IF;
END PROCESS;
SW2_DROP <= '0' WHEN (SW2='0' AND TMP1 ='1') ELSE '1';

PROCESS(CLK)		--STATE CHANGE PROCESS
BEGIN
IF RISING_EDGE(CLK) THEN
	CASE STATE IS
		WHEN RUN =>
			IF SW1_DROP = '0' THEN
				STATE <= PAUSE;
			END IF;
		WHEN PAUSE =>
			IF SW1_DROP = '0' THEN
				STATE <= RUN;
			ELSIF SW2_DROP = '0' THEN
				STATE <= STOP;
			END IF;
		WHEN STOP =>
			IF SW1_DROP = '0' THEN
				STATE <= RUN;
			END IF;
		WHEN OTHERS => NULL;
	END CASE;
END IF;
END PROCESS;

PROCESS(CLK)		--COUNT-STOP
	--VARIABLE COUNT10 : INTEGER RANGE 0 TO 9 := 0;
BEGIN
IF RISING_EDGE(CLK) THEN
CASE STATE IS
	WHEN STOP =>
	MS0 <= "0000";
	MS1 <= "0000";
	SEC0 <= "0000";
	SEC1 <= "0000";
	MIN0 <= "0000";
	MIN1 <= "0000";
	WHEN RUN =>
	IF COUNT10 = 9 THEN
		COUNT10 <= 0;
		IF MS0 = "1001" THEN
			MS0 <= "0000";
			IF MS1 = "1001" THEN
				MS1 <= "0000";
					IF SEC0 = "1001" THEN
						SEC0 <= "0000";
						IF SEC1 = "0101" THEN
							SEC1 <= "0000";
							IF MIN0 = "1001" THEN
								MIN0 <= "0000";
								IF MIN1 = "1001" THEN
									MIN1 <= "0000";
								ELSE
									MIN1 <= MIN1 + 1;
								END IF;
							ELSE
								MIN0 <= MIN0 + 1;
							END IF;
						ELSE
							SEC1 <= SEC1 + 1;
						END IF;
					ELSE
						SEC0 <= SEC0 + 1;
					END IF;
			ELSE
				MS1 <= MS1 + 1;
			END IF;
		ELSE
			MS0 <= MS0 + 1;
		END IF;
	ELSE
		COUNT10 <= COUNT10 + 1;
	END IF;
	WHEN OTHERS => NULL;
END CASE;
END IF;
END PROCESS;

PROCESS(CLK,MS0,MS1,SEC0,SEC1,MIN0,MIN1)
BEGIN
	OMS0 <= MS0;
	OMS1 <= MS1;
	OSEC0 <= SEC0;
	OSEC1 <= SEC1;
	OMIN0 <= MIN0;
	OMIN1 <= MIN1;
END PROCESS;

END BEHAV;