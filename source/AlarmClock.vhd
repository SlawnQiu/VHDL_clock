--闹钟模块代码说明：
---本模块只显示时和分，不显示秒。原本用于显示秒的部分改为显示闹钟是否开启
---整个模块有4个进程：调校时间的闪烁进程、闹钟的状态切换、闹钟输出进程、闹钟逻辑进程
-----(1)闪烁进程，通过标志位的 scan_flag 的取反，进行显示和不显示的切换，从而达到闪烁的效果
-----(2)闹钟的状态切换:共有4个状态，通过SW3按键可以在4个状态之间切换
-----(3)闹钟时间输出进程，通过各自时间的 temp 信号的改变，赋予相应的输出，输送到译码器
-----(4)闹钟逻辑进程，即时间24时制的VHDL逻辑表示
---功能描述：
-----(1)按下SW3可以修改闹铃时间，依次为闹钟时间正常显示、时的修改、分的修改、闹钟的开关
-----(2)在时分的修改状态下，按SW1为加，SW2为减
-----(3)在闹钟的开关下，按SW1或SW2可以使闹钟开或关
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY AlarmClock IS
	PORT(
            clk : IN std_logic;               --开发板的时钟频率
			SW1,SW2,SW3 : IN std_logic;       --按键SW1用于增加时间，SW2用于减少时间，SW3用于切换状态
			D6,D7,D8,D9,D10,D11: OUT std_logic_vector(3 DOWNTO 0);  --输送给黄泽健或周松毅
			BEEP_ENABLE: OUT STD_LOGIC			-- For enabling comparator
		);
END ENTITY;

ARCHITECTURE behav OF AlarmClock IS

   --闹钟时间显示：时+分：A_h1A_h2-A_m1A_m2
	SIGNAL A_h1 : std_logic_vector(3 DOWNTO 0) := "0000";			
	SIGNAL A_h2 : std_logic_vector(3 DOWNTO 0) := "0000";   
	SIGNAL A_m1 : std_logic_vector(3 DOWNTO 0) := "0000";  
	SIGNAL A_m2 : std_logic_vector(3 DOWNTO 0) := "0000"; 

    --闹钟显示寄存器
	SIGNAL A_h1_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL A_h2_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL A_m1_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL A_m2_temp : std_logic_vector(3 DOWNTO 0);    
	
    
        --表示闹钟开关的信号
        --当黄泽健译码器收到1110时，会控制其中一位数码管显示出特殊符号
	CONSTANT r_on : std_logic_vector(3 DOWNTO 0) := "1110"; 
        --当黄泽健译码器收到1111时，会控制最后两位数码管不显示任何东西
	CONSTANT r_off : std_logic_vector(3 DOWNTO 0) := "1111";   
	
	
	SIGNAL r_state : std_logic_vector(3 DOWNTO 0);    --闹铃开关的显示，占两位数码管
	SIGNAL scan_flag : std_logic;		          --产生调整闹钟时闪烁的标志
	SIGNAL A_flag : integer RANGE 0 TO 3 := 0;	  --闹铃状态的标志
	SIGNAL r_SW : std_logic :='0';		          --闹铃开关的状态位	
	
BEGIN
	
	PROCESS(clk)		--产生调整闹钟时闪烁的标志
		VARIABLE count : integer RANGE 0 TO 200 := 0; 
	BEGIN
		IF rising_edge(clk) THEN
			count := count + 1;
			IF count = 200 THEN
				count := 0;
				scan_flag <= NOT scan_flag;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(clk)		--闹钟显示的状态切换
	BEGIN
		IF rising_edge(clk) THEN
            IF SW3 = '0' THEN
                IF A_flag = 3 THEN
                    A_flag <= 0;
                ELSE
                    A_flag <= A_flag + 1;
                END IF;   
            END IF;                
		END IF;
	END PROCESS;
	
	PROCESS(clk)	--输出到黄泽健译码器的进程
	BEGIN
		IF clk'EVENT AND clk ='1' THEN
				D8 <= A_m2_temp;
				D9 <= A_m1_temp;
				D10 <= A_h2_temp;
				D11 <= A_h1_temp;
				D6 <= r_state;
                D7 <= r_state;   --默认D11和D10相同             
				BEEP_ENABLE <= NOT r_state(0);
		END IF;
	END PROCESS;
		
	PROCESS(clk)		--闹铃时间的调整
	BEGIN
		IF rising_edge(clk) THEN
			CASE A_flag IS
				WHEN 0 =>
					A_h1_temp <= A_h1;
					A_h2_temp <= A_h2;
					A_m1_temp <= A_m1;
					A_m2_temp <= A_m2;
                    
					IF r_SW ='1' THEN       --闹铃的状态为"开"
						r_state <= r_on;
					ELSE
						r_state <= r_off;
					END IF;
                    
				WHEN 1 =>   --调整闹钟设定时间A_h1、A_h2(时分秒中的时)             
                --调整时间A_h1、A_h2时，A_h1、A_h2会闪烁
					IF scan_flag='0' THEN
						A_h1_temp <= "1111";  --当黄泽健译码器收到1111时，会控制数码管变暗
						A_h2_temp <= "1111";  --当黄泽健译码器收到1111时，会控制数码管变暗
					ELSE
						A_h1_temp <= A_h1;
						A_h2_temp <= A_h2;
					END IF;
					
					IF SW1='0' THEN        --调整时间，当SW1被按下,A_h1A_h2的值会增加1
						IF A_h1="0010" AND A_h2="0011" THEN
							A_h1 <= "0000";
							A_h2 <= "0000";
						ELSIF A_h2="1001" THEN
							A_h1 <= A_h1 + '1';
							A_h2 <= "0000";
						ELSE
							A_h2 <= A_h2 + '1';
						END IF;
                        
					ELSIF SW2='0' THEN      --调整时间，当SW2被按下,A_h1A_h2的值会减少1
						IF A_h1="0000" AND A_h2="0000" THEN
							A_h1 <= "0010";
							A_h2 <= "0011";
						ELSIF A_h2="0000" THEN
							A_h1 <= A_h1 - '1';
							A_h2 <= "1001";
						ELSE
							A_h2 <= A_h2 - '1';
						END IF;
					END IF;
                    
				WHEN 2 =>     --调整闹钟设定时间A_m1、A_m2(时分秒中的分)
					A_h1_temp <= A_h1;
					A_h2_temp <= A_h2;
                    
                   --调整时间A_m1、A_m2时，A_m1、A_m2会闪烁
					IF scan_flag='0' THEN
						A_m1_temp <= "1111";    --当黄泽健译码器收到1111时，会控制数码管变暗
						A_m2_temp <= "1111";    --当黄泽健译码器收到1111时，会控制数码管变暗
					ELSE
						A_m1_temp <= A_m1;
						A_m2_temp <= A_m2;
					END IF;
                    
					IF SW1='0' THEN         --调整时间，当SW1被按下，A_m1A_m2的值会增加1
						IF A_m1="0101" AND A_m2="1001" THEN
							A_m1 <= "0000";
							A_m2 <= "0000";
						ELSIF A_m2="1001" THEN
							A_m1 <= A_m1 + '1';
							A_m2 <= "0000";
						ELSE
							A_m2 <= A_m2 + '1';
						END IF;
                        
					ELSIF SW2='0' THEN        --调整时间，当SW2被按下，A_m1A_m2的值会减少1
						IF A_m1="0000" AND A_m2="0000" THEN
							A_m1 <= "0101";
							A_m2 <= "1001";
						ELSIF A_m2="0000" THEN
							A_m1 <= A_m1 - '1';
							A_m2 <= "1001";
						ELSE
							A_m2 <= A_m2 - '1';
						END IF;
					END IF;
                    
				WHEN 3 =>          --闹铃开关的设置             
					A_m1_temp <= A_h1;
					A_m2_temp <= A_h2;
                    
					IF scan_flag='0' THEN
						r_state <= "1111";    
					ELSE
						IF r_SW='1' THEN
							r_state <= r_on;    --此时r_state为1110 
						ELSE
							r_state <= r_off;   --此时r_state为1111
						END IF;
					END IF;
					
					IF SW1='0' THEN       
						r_SW <= NOT r_SW;     --按下SW1可以使闹铃开关打开或关闭 
					ELSIF SW2='0' THEN    
						r_SW <= NOT r_SW;     --按下SW2可以使闹铃开关打开或关闭
					END IF;
			END CASE;
		END IF;
	END PROCESS;
END behav;
