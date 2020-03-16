--时钟模块代码说明：
---整个模块有4个进程：调校时间的闪烁进程、时钟的状态切换、时间输出进程、闹钟逻辑进程
-----(1)闪烁进程，通过标志位的 scan_flag 的取反，进行显示和不显示的切换，从而达到闪烁的效果
-----(2)时钟的状态切换:共有4个状态，通过SW3按键可以在4个状态之间切换
-----(3)时间输出进程，通过各自时间的 temp 信号的改变，赋予相应的输出，输送到译码器
-----(4)时钟逻辑进程，即时间24小时制的VHDL逻辑表示
---功能描述：
-----(1)按SW3进行功能切换，随着按SW3，状态依次是：时间正常显示、时的修改、分的修改、秒的修改
-----(2)在时分秒的修改状态下，按SW1为加，SW2为减

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY clock IS
	PORT(
            clk : IN std_logic;                  --开发板的时钟频率
			SW1,SW2,SW3 : IN std_logic;          --按键SW1用于增加时间，SW2用于减少时间，SW3用于切换状态
			D0,D1,D2,D3,D4,D5: OUT std_logic_vector(3 DOWNTO 0)  --输送给黄泽健或周松毅
		);
END ENTITY;

ARCHITECTURE behav OF clock IS

	--时钟时分秒表示形式：h1h2-m1m2-s1s2，共6个数字，每个数字均用4位BCD码表示
	SIGNAL h1 : std_logic_vector(3 DOWNTO 0) := "0010";				
	SIGNAL h2 : std_logic_vector(3 DOWNTO 0) := "0011";
	SIGNAL m1 : std_logic_vector(3 DOWNTO 0) := "0101";
	SIGNAL m2 : std_logic_vector(3 DOWNTO 0) := "1001";
	SIGNAL s1 : std_logic_vector(3 DOWNTO 0) := "0101";
	SIGNAL s2 : std_logic_vector(3 DOWNTO 0) := "0000";

	--时钟显示寄存器		
	SIGNAL h1_temp : std_logic_vector(3 DOWNTO 0);				
	SIGNAL h2_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL m1_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL m2_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL s1_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL s2_temp : std_logic_vector(3 DOWNTO 0);
		
	SIGNAL scan_flag : std_logic;				    --产生调整时间时闪烁的标志
	SIGNAL C_flag : integer RANGE 0 TO 3 := 0;		--时钟状态的标志
	
BEGIN
	
	PROCESS(clk)		--产生调整时间时闪烁的标志
		VARIABLE count : integer RANGE 0 TO 10000000 := 0;
	BEGIN
		IF rising_edge(clk) THEN
			count := count + 1;
			IF count = 10000000 THEN      --分频
				count := 0;
				scan_flag <= NOT scan_flag;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(clk)		--时钟的状态切换
	BEGIN
		IF rising_edge(clk) THEN
            IF SW3 = '0' THEN                   
                IF C_flag = 3 THEN
                    C_flag <= 0;
                ELSE
                    C_flag <= C_flag + 1;
                END IF;
            END IF;                 
		END IF;
	END PROCESS;
	
	PROCESS(clk)	--输出到黄泽健译码器进行译码的进程
	BEGIN
		IF clk'EVENT AND clk ='1' THEN		           
            D0 <= h1_temp;
            D1 <= h2_temp;
            D2 <= m1_temp;
            D3 <= m2_temp;		
            D4 <= s1_temp;
            D5 <= s2_temp;						
		END IF;
	END PROCESS;
	
	PROCESS(clk)		--时钟的调整与进行
	    VARIABLE count_1hz : integer RANGE 0 TO 50000000;
        
	BEGIN
		IF clk'EVENT AND clk='1' THEN
			CASE C_flag IS
				WHEN 0 =>               --时分秒运行逻辑
					count_1hz := count_1hz + 1;
					IF count_1hz = 50000000 THEN
						count_1hz := 0;
						IF s2 >= "1001" THEN
							s2 <= "0000";
							IF s1 >= "0101" THEN
								s1 <= "0000";
								IF m2 >= "1001" THEN
									m2 <= "0000";
									IF m1 >= "0101" THEN
										m1 <= "0000";
										IF h1 <= "0001" THEN
											IF h2 >= "1001" THEN
												h2 <= "0000";
												h1 <= h1 + '1';
											ELSE
												h2 <= h2 + '1';
											END IF;
										ELSE
											IF h2 >= "0011" THEN
												h2 <= "0000";
												h1 <= "0000";												
											ELSE
												h2 <= h2 + '1';
											END IF;
										END IF;
									ELSE
										m1 <= m1 + '1';
									END IF;
								ELSE
									m2 <= m2 + '1';
								END IF;
							ELSE
								s1 <= s1 + '1';
							END IF;
						ELSE
							s2 <= s2 + '1';
						END IF;
					END IF;
					
                    --把h1、h2、m1、m2、s1、s2送到显示寄存器
					h1_temp <= h1;
					h2_temp <= h2;
					m1_temp <= m1;
					m2_temp <= m2;
					s1_temp <= s1;
					s2_temp <= s2;
				
				WHEN 1 =>     --调整时间h1h2(时分秒中的时)                    
                    --调整时间h1h2时，h1h2会闪烁
					IF scan_flag='0' THEN
						count_1hz := 0;
						h1_temp <= "1111";     --当黄泽健译码器收到1111时，会控制数码管变暗
						h2_temp <= "1111";     --当黄泽健译码器收到1111时，会控制数码管变暗
					ELSE
						count_1hz := 0;
						h1_temp <= h1;
						h2_temp <= h2;
					END IF;
					
					IF SW1='0' THEN          --调整时间，当SW1被按下,h1h2的值会增加1
						IF h1="0010" AND h2="0011" THEN
							h1 <= "0000";
							h2 <= "0000";
						ELSIF h2="1001" THEN
							h1 <= h1 + '1';
							h2 <= "0000";
						ELSE
							h2 <= h2 + '1';
						END IF;
                        
					ELSIF SW2='0' THEN       --调整时间，当SW2被按下,h1h2的值会减少1
						IF h1="0000" AND h2="0000" THEN
							h1 <= "0010";
							h2 <= "0011";
						ELSIF h2="0000" THEN
							h1 <= h1 - '1';
							h2 <= "1001";
						ELSE
							h2 <= h2 - '1';
						END IF;
					END IF;
                    
				WHEN 2 =>                  --调整时间m1m2(时分秒中的分)
					h1_temp <= h1;
					h2_temp <= h2;
                    
                    --调整时间m1m2时，m1m2会闪烁
					IF scan_flag='0' THEN
						count_1hz := 0;
						m1_temp <= "1111";      --当黄泽健译码器收到1111时，会控制数码管变暗
						m2_temp <= "1111";      --当黄泽健译码器收到1111时，会控制数码管变暗
					ELSE
						count_1hz := 0;
						m1_temp <= m1;
						m2_temp <= m2;
					END IF;
                    
					IF SW1='0' THEN            --调整时间，当SW1被按下,m1m2的值会增加1
						IF m1="0101" AND m2="1001" THEN
							m1 <= "0000";
							m2 <= "0000";
						ELSIF m2="1001" THEN
							m1 <= m1 + '1';
							m2 <= "0000";
						ELSE
							m2 <= m2 + '1';
						END IF;
                        
					ELSIF SW2='0' THEN          --调整时间，当SW2被按下,m1m2的值会减少1
						IF m1="0000" AND m2="0000" THEN
							m1 <= "0101";
							m2 <= "1001";
						ELSIF m2="0000" THEN
							m1 <= m1 - '1';
							m2 <= "1001";
						ELSE
							m2 <= m2 - '1';
						END IF;
					END IF;
                                       
				WHEN 3 =>           --调整时间s1s2(时分秒中的秒)
					m1_temp <= m1;
					m2_temp <= m2;
                    
                    --调整时间s1s2时，s1s2会闪烁
					IF scan_flag='0' THEN
						count_1hz := 0;
						s1_temp <= "1111";     --当黄泽健译码器收到1111时，会控制数码管变暗
						s2_temp <= "1111";     --当黄泽健译码器收到1111时，会控制数码管变暗
					ELSE
						count_1hz := 0;
						s1_temp <= s1;
						s2_temp <= s2;
					END IF;
                    
					IF SW1='0' THEN            --调整时间，当SW1被按下,s1s2的值会增加1
						IF s1="0101" AND s2="1001" THEN
							s1 <= "0000";
							s2 <= "0000";
						ELSIF s2="1001" THEN
							s1 <= s1 + '1';
							s2 <= "0000";
						ELSE
							s2 <= s2 + '1';
						END IF;
                        
					ELSIF SW2='0' THEN         --调整时间，当SW2被按下,s1s2的值会减少1
						IF s1="0000" AND s2="0000" THEN
							s1 <= "0101";
							s2 <= "1001";
						ELSIF s2="0000" THEN
							s1 <= s1 - '1';
							s2 <= "1001";
						ELSE
							s2 <= s2 - '1';
						END IF;                       
					END IF;  
                    
			END CASE;           
		END IF;      
	END PROCESS;
END behav;