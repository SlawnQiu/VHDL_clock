--����ģ�����˵����
---��ģ��ֻ��ʾʱ�ͷ֣�����ʾ�롣ԭ��������ʾ��Ĳ��ָ�Ϊ��ʾ�����Ƿ���
---����ģ����4�����̣���Уʱ�����˸���̡����ӵ�״̬�л�������������̡������߼�����
-----(1)��˸���̣�ͨ����־λ�� scan_flag ��ȡ����������ʾ�Ͳ���ʾ���л����Ӷ��ﵽ��˸��Ч��
-----(2)���ӵ�״̬�л�:����4��״̬��ͨ��SW3����������4��״̬֮���л�
-----(3)����ʱ��������̣�ͨ������ʱ��� temp �źŵĸı䣬������Ӧ����������͵�������
-----(4)�����߼����̣���ʱ��24ʱ�Ƶ�VHDL�߼���ʾ
---����������
-----(1)����SW3���Խ���״̬�л�������Ϊ����ʱ��������ʾ��ʱ���޸ġ��ֵ��޸ġ����ӵĿ���
-----(2)��ʱ�ֵ��޸�״̬�£���SW1Ϊ�ӣ�SW2Ϊ��
-----(3)�����ӵĿ����£���SW1��SW2����ʹ���ӿ����
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY AlarmClock IS
	PORT(
            clk : IN std_logic;               --�������ʱ��Ƶ��
			SW1,SW2,SW3 : IN std_logic;       --����SW1��������ʱ�䣬SW2���ڼ���ʱ�䣬SW3�����л�״̬
			D6,D7,D8,D9,D10,D11: OUT std_logic_vector(3 DOWNTO 0);  --���͸����󽡻�������
			BEEP_ENABLE: OUT STD_LOGIC			-- For enabling comparator
		);
END ENTITY;

ARCHITECTURE behav OF AlarmClock IS

   --����ʱ����ʾ��ʱ+�֣�A_h1A_h2-A_m1A_m2
	SIGNAL A_h1 : std_logic_vector(3 DOWNTO 0) := "0000";			
	SIGNAL A_h2 : std_logic_vector(3 DOWNTO 0) := "0000";   
	SIGNAL A_m1 : std_logic_vector(3 DOWNTO 0) := "0000";  
	SIGNAL A_m2 : std_logic_vector(3 DOWNTO 0) := "0000"; 

    --������ʾ�Ĵ���
--	SIGNAL A_h1_temp : std_logic_vector(3 DOWNTO 0);
--	SIGNAL A_h2_temp : std_logic_vector(3 DOWNTO 0);
--	SIGNAL A_m1_temp : std_logic_vector(3 DOWNTO 0);
--	SIGNAL A_m2_temp : std_logic_vector(3 DOWNTO 0);    
	
    
        --��ʾ���ӿ��ص��ź�
        --�������������յ�1110ʱ�����������һλ�������ʾ���������
	CONSTANT r_on : std_logic_vector(3 DOWNTO 0) := "1110"; 
        --�������������յ�1111ʱ������������λ����ܲ���ʾ�κζ���
	CONSTANT r_off : std_logic_vector(3 DOWNTO 0) := "1111";   
	
	
	SIGNAL r_state : std_logic_vector(3 DOWNTO 0):="1111";    --���忪�ص���ʾ��ռ��λ�����
	SIGNAL scan_flag : std_logic;		          --������������ʱ��˸�ı�־
	SIGNAL A_flag : integer RANGE 0 TO 3 := 0;	  --����״̬�ı�־
	SIGNAL r_SW : std_logic :='0';		          --���忪�ص�״̬λ
	signal sw1_1,sw1_2,sw1_r, sw2_1,sw2_2,sw2_r, sw3_1,sw3_2,sw3_r:std_logic:='1';	
	
BEGIN

process(clk)
	begin
	if rising_edge(clk) then
	sw1_1<=SW1;
	sw1_2<=sw1_1;
	sw1_r<=sw1_1 xnor sw1_2;
	end if;
	end process;
	
	process(clk)
	begin
	if rising_edge(clk) then
	sw2_1<=SW2;
	sw2_2<=sw2_1;
	sw2_r<=sw2_1 xnor sw2_2;
	end if;
	end process;
	
	process(clk)
	begin
	if rising_edge(clk) then
	sw3_1<=SW3;
	sw3_2<=sw3_1;
	sw3_r<=sw3_1 xnor sw3_2;
	end if;
	end process;
	
--	PROCESS(clk)		--������������ʱ��˸�ı�־
--		VARIABLE count : integer RANGE 0 TO 200 := 0; 
--	BEGIN
--		IF rising_edge(clk) THEN
--			count := count + 1;
--			IF count = 200 THEN
--				count := 0;
--				scan_flag <= NOT scan_flag;
--			END IF;
--		END IF;
--	END PROCESS;
	
	PROCESS(clk)		--������ʾ��״̬�л�
	BEGIN
		IF rising_edge(clk) THEN
            IF SW3 = '0' then
             IF sw3_r = '0' THEN 
                IF A_flag = 3 THEN
                    A_flag <= 0;
                ELSE
                    A_flag <= A_flag + 1;
                END IF;  
             END IF; 
            END IF;                
		END IF;
	END PROCESS;
	
	PROCESS(clk)	--����������������Ľ���
	BEGIN
		IF clk'EVENT AND clk ='1' THEN
				D8 <= A_m2;
				D9 <= A_m1;
				D10 <= A_h2;
				D11 <= A_h1;
				D6 <= r_state;
                D7 <= r_state;   --Ĭ��D11��D10��ͬ             
				BEEP_ENABLE <= NOT r_state(0);
		END IF;
	END PROCESS;
		
	PROCESS(clk)		--����ʱ��ĵ���
	BEGIN
		IF rising_edge(clk) THEN
			CASE A_flag IS
				WHEN 0 =>
			--		A_h1_temp <= A_h1;
			--		A_h2_temp <= A_h2;
			--		A_m1_temp <= A_m1;
			--		A_m2_temp <= A_m2;
                    
					IF r_SW ='1' THEN       --�����״̬Ϊ"��"
						r_state <= r_on;
					ELSE
						r_state <= r_off;
					END IF;
                    
				WHEN 1 =>   --���������趨ʱ��A_h1��A_h2(ʱ�����е�ʱ)             
                --����ʱ��A_h1��A_h2ʱ��A_h1��A_h2����˸
		--			IF scan_flag='0' THEN
		--				A_h1_temp <= "1111";  --�������������յ�1111ʱ�����������ܱ䰵
		--				A_h2_temp <= "1111";  --�������������յ�1111ʱ�����������ܱ䰵
		--			ELSE
		--				A_h1_temp <= A_h1;
		--				A_h2_temp <= A_h2;
		--			END IF;
					
					IF SW1='0' THEN        --����ʱ�䣬��SW1������,A_h1A_h2��ֵ������1
                         IF sw1_r = '0' THEN 
						IF A_h1="0010" AND A_h2="0011" THEN
							A_h1 <= "0000";
							A_h2 <= "0000";
						ELSIF A_h2="1001" THEN
							A_h1 <= A_h1 + '1';
							A_h2 <= "0000";
						ELSE
							A_h2 <= A_h2 + '1';
							end if;
						END IF;
                        
					ELSIF SW2='0' THEN      --����ʱ�䣬��SW2������,A_h1A_h2��ֵ�����1
					 IF sw2_r = '0' THEN 
						IF A_h1="0000" AND A_h2="0000" THEN
							A_h1 <= "0010";
							A_h2 <= "0011";
						ELSIF A_h2="0000" THEN
							A_h1 <= A_h1 - '1';
							A_h2 <= "1001";
						ELSE
							A_h2 <= A_h2 - '1';
							end if;
						END IF;
					END IF;
                    
				WHEN 2 =>     --���������趨ʱ��A_m1��A_m2(ʱ�����еķ�)
		--			A_h1_temp <= A_h1;
		--			A_h2_temp <= A_h2;
                    
                   --����ʱ��A_m1��A_m2ʱ��A_m1��A_m2����˸
		--			IF scan_flag='0' THEN
		--				A_m1_temp <= "1111";    --�������������յ�1111ʱ�����������ܱ䰵
		--				A_m2_temp <= "1111";    --�������������յ�1111ʱ�����������ܱ䰵
		--			ELSE
		--				A_m1_temp <= A_m1;
		--				A_m2_temp <= A_m2;
		--			END IF;
                    
					IF SW1='0' THEN         --����ʱ�䣬��SW1�����£�A_m1A_m2��ֵ������1
                         IF sw1_r = '0' THEN 
						IF A_m1="0101" AND A_m2="1001" THEN
							A_m1 <= "0000";
							A_m2 <= "0000";
						ELSIF A_m2="1001" THEN
							A_m1 <= A_m1 + '1';
							A_m2 <= "0000";
						ELSE
							A_m2 <= A_m2 + '1';
							end if;
						END IF;
                        
					ELSIF SW2='0' THEN
					 IF sw2_r = '0'   THEN        --����ʱ�䣬��SW2�����£�A_m1A_m2��ֵ�����1
						IF A_m1="0000" AND A_m2="0000" THEN
							A_m1 <= "0101";
							A_m2 <= "1001";
						ELSIF A_m2="0000" THEN
							A_m1 <= A_m1 - '1';
							A_m2 <= "1001";
						ELSE
							A_m2 <= A_m2 - '1';
						END IF;
						end if;
					END IF;
                    
				WHEN 3 =>          --���忪�ص�����             
	--				A_m1_temp <= A_h1;
	--				A_m2_temp <= A_h2;
                    
	--				IF scan_flag='0' THEN
	--					r_state <= "1111";    
	--				ELSE
						IF r_SW='1' THEN
							r_state <= r_on;    --��ʱr_stateΪ1110 
						ELSE
							r_state <= r_off;   --��ʱr_stateΪ1111
						END IF;
	--				END IF;
					
					IF SW1='0' THEN     
						 IF sw1_r = '0' THEN   
						r_SW <= NOT r_SW;     --����SW1����ʹ���忪�ش򿪻�ر� 
						end if;
					ELSIF SW2='0' then
						 IF sw2_r = '0' THEN     
						r_SW <= NOT r_SW;     --����SW2����ʹ���忪�ش򿪻�ر�
						end if;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
END behav;