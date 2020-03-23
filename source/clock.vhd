--ʱ��ģ�����˵����
---����ģ����4�����̣���Уʱ�����˸���̡�ʱ�ӵ�״̬�л���ʱ��������̡������߼�����
-----(1)��˸���̣�ͨ����־λ�� scan_flag ��ȡ����������ʾ�Ͳ���ʾ���л����Ӷ��ﵽ��˸��Ч��
-----(2)ʱ�ӵ�״̬�л�����:����4��״̬��ͨ��SW3����������4��״̬֮���л�
-----(3)ʱ��������̣�ͨ������ʱ��� temp �źŵĸı䣬������Ӧ����������͵�������
-----(4)ʱ���߼����̣���ʱ��24Сʱ�Ƶ�VHDL�߼���ʾ
---����������
-----(1)��SW3���й����л������Ű�SW3��״̬�����ǣ�ʱ��������ʾ��ʱ���޸ġ��ֵ��޸ġ�����޸�
-----(2)��ʱ������޸�״̬�£���SW1Ϊ�ӣ�SW2Ϊ��

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY clock IS
	PORT(	
            clk : IN std_logic;                  --�������ʱ��Ƶ��
			SW1,SW2,SW3 : IN std_logic;          --����SW1��������ʱ�䣬SW2���ڼ���ʱ�䣬SW3�����л�״̬
			D0,D1,D2,D3,D4,D5: OUT std_logic_vector(3 DOWNTO 0)  --���͸����󽡻�������
			
		);
END ENTITY;

ARCHITECTURE behav OF clock IS

	--ʱ��ʱ�����ʾ��ʽ��h1h2-m1m2-s1s2����6�����֣�ÿ�����־���4λBCD���ʾ
--	SIGNAL h1 : std_logic_vector(3 DOWNTO 0) := "0010";				
--	SIGNAL h2 : std_logic_vector(3 DOWNTO 0) := "0011";
--	SIGNAL m1 : std_logic_vector(3 DOWNTO 0) := "0101";
--	SIGNAL m2 : std_logic_vector(3 DOWNTO 0) := "1001";
--	SIGNAL s1 : std_logic_vector(3 DOWNTO 0) := "0101";
--	SIGNAL s2 : std_logic_vector(3 DOWNTO 0) := "0000";

	--ʱ����ʾ�Ĵ���		
	SIGNAL h1_temp : std_logic_vector(3 DOWNTO 0);				
	SIGNAL h2_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL m1_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL m2_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL s1_temp : std_logic_vector(3 DOWNTO 0);
	SIGNAL s2_temp : std_logic_vector(3 DOWNTO 0);
		
	SIGNAL scan_flag : std_logic;				    --��������ʱ��ʱ��˸�ı�־
	SIGNAL C_flag : integer RANGE 0 TO 3 := 0;		--ʱ��״̬�ı�־
	signal sw1_1,sw1_2,sw1_r, sw2_1,sw2_2,sw2_r, sw3_1,sw3_2,sw3_r:std_logic:='1';
	
BEGIN
	
	--PROCESS(clk)		--��������ʱ��ʱ��˸�ı�־
	--	VARIABLE count : integer RANGE 0 TO 200 := 0;  --������ 10000000 �� 200 ���m�� 1kHz �r�}
	--BEGIN
	--	IF rising_edge(clk) THEN
	--		count := count + 1;
	--		IF count = 200 THEN      --��Ƶ
	--			count := 0;
	--			scan_flag <= NOT scan_flag;
	--		END IF;
	--	END IF;
	--END PROCESS;
	
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
	
	PROCESS(clk)		--ʱ�ӵ�״̬�л�
	
	BEGIN
		IF rising_edge(clk) THEN
		if SW3='0' then
            IF sw3_r = '0' THEN                   
                IF C_flag = 3 THEN
                    C_flag <= 0;
                ELSE
                    C_flag <= C_flag + 1;

                END IF;
            END IF;  
        end if;               
		END IF;
	END PROCESS;
	
	PROCESS(clk)	--�����������������������Ľ���
	BEGIN
		IF clk'EVENT AND clk ='1' THEN		           
            D0 <= s2_temp;
            D1 <= s1_temp;
            D2 <= m2_temp;
            D3 <= m1_temp;		
            D4 <= h2_temp;
            D5 <= h1_temp;						
		END IF;
	END PROCESS;
	
	PROCESS(clk)		--ʱ�ӵĵ��������
	    VARIABLE count_1hz : integer RANGE 0 TO 1000; --������ 50000000 �� 1000 ���m�� 1kHz �r�}
        variable temp:std_logic:='1';
	BEGIN
		IF clk'EVENT AND clk='1' THEN
			CASE C_flag IS
				WHEN 0 =>               --ʱ���������߼�
					count_1hz := count_1hz + 1;
					IF count_1hz = 1 THEN
						count_1hz := 0;
						
						IF s2_temp = "1001" THEN
							s2_temp <= "0000";
							IF s1_temp = "0101" THEN
								s1_temp <= "0000";
								IF m2_temp = "1001" THEN
									m2_temp <= "0000";
									IF m1_temp = "0101" THEN
										m1_temp <= "0000";
								--		IF h1 = "0001" THEN
								--			IF h2 = "1001" THEN
								--				h2 <= "0000";
								--				h1 <= h1 + '1';
								--			ELSE
								--				h2 <= h2 + '1';
								--			END IF;
								--		ELSE
								--			IF h2 >= "0011" THEN
								--				h2 <= "0000";
								--				h1 <= "0000";												
								--			ELSE
								--				h2 <= h2 + '1';
								--			END IF;
								--		END IF;
								--xia mian ba xin hao quan gai cheng temp
										IF h2_temp = "0011" THEN
											h2_temp <= "0000";
											IF h1_temp = "0001" THEN
											h1_temp <= "0000";												
											ELSE
												h1_temp <= h1_temp + '1';
											END IF;
										ELSE 
											h2_temp <= h2_temp + '1';
										End IF;
									ELSE
										m1_temp <= m1_temp + '1';
									END IF;
								ELSE
									m2_temp <= m2_temp + '1';
								END IF;
							ELSE
								s1_temp <= s1_temp + '1';
							END IF;
						ELSE
							s2_temp <= s2_temp + '1';
						END IF;
					END IF;
					
                    --��h1��h2��m1��m2��s1��s2�͵���ʾ�Ĵ���
					--h1_temp <= h1;
					--h2_temp <= h2;
					--m1_temp <= m1;
					--m2_temp <= m2;
					--s1_temp <= s1;
					--s2_temp <= s2;
				
				WHEN 1 =>     --����ʱ��h1h2(ʱ�����е�ʱ)                    
                    --����ʱ��h1h2ʱ��h1h2����˸
					--IF scan_flag='0' THEN
					--	count_1hz := 0;
					--	h1_temp <= "1111";     --�������������յ�1111ʱ�����������ܱ䰵
					--	h2_temp <= "1111";     --�������������յ�1111ʱ�����������ܱ䰵
					--ELSE
					
					--	count_1hz := 0;
					--	h1_temp <= h1;
					--	h2_temp <= h2;
					--END IF;
					
					IF SW1='0'then
                        if sw1_r='0' THEN  
                              --����ʱ�䣬��SW1������,h1h2��ֵ������1
						IF h1_temp="0010" AND h2_temp="0011" THEN
							h1_temp <= "0000";
							h2_temp <= "0000";
						ELSIF h2_temp="1001" THEN
							h1_temp <= h1_temp + '1';
							h2_temp <= "0000";
						ELSE
							h2_temp <= h2_temp + '1';
						end if;
						END IF;
                        
					ELSIF SW2='0'then
						if sw2_r='0' THEN       --����ʱ�䣬��SW2������,h1h2��ֵ�����1
						IF h1_temp="0000" AND h2_temp="0000" THEN
							h1_temp <= "0010";
							h2_temp <= "0011";
						ELSIF h2_temp="0000" THEN
							h1_temp <= h1_temp - '1';
							h2_temp <= "1001";
						ELSE
							h2_temp <= h2_temp - '1';
							end if;
						END IF;
					END IF;
                    
				WHEN 2 =>                  --����ʱ��m1m2(ʱ�����еķ�)
					--h1_temp <= h1;
					--h2_temp <= h2;
                    
                    --����ʱ��m1m2ʱ��m1m2����˸
				--	IF scan_flag='0' THEN
				--		count_1hz := 0;
				--		m1_temp <= "1111";      --�������������յ�1111ʱ�����������ܱ䰵
				--		m2_temp <= "1111";      --�������������յ�1111ʱ�����������ܱ䰵
				--	ELSE
				--		count_1hz := 0;
				---		m1_temp <= m1;
				--		m2_temp <= m2;
				--	END IF;
                    
					IF SW1='0' then
                        if sw1_r='0' THEN            --����ʱ�䣬��SW1������,m1m2��ֵ������1
						IF m1_temp="0101" AND m2_temp="1001" THEN
							m1_temp <= "0000";
							m2_temp <= "0000";
						ELSIF m2_temp="1001" THEN
							m1_temp <= m1_temp + '1';
							m2_temp <= "0000";
						ELSE
							m2_temp <= m2_temp + '1';
						end if;
						END IF;
                        
					ELSIF Sw2='0'then
						if sw2_r='0' THEN          --����ʱ�䣬��SW2������,m1m2��ֵ�����1
						IF m1_temp="0000" AND m2_temp="0000" THEN
							m1_temp <= "0101";
							m2_temp <= "1001";
						ELSIF m2_temp="0000" THEN
							m1_temp <= m1_temp - '1';
							m2_temp <= "1001";
						ELSE
							m2_temp <= m2_temp - '1';
						end if;
						END IF;
					END IF;
                                       
				WHEN 3 =>           --����ʱ��s1s2(ʱ�����е���)
					--m1_temp <= m1;
					--m2_temp <= m2;
                    
                    --����ʱ��s1s2ʱ��s1s2����˸
			--		IF scan_flag='0' THEN
			--			count_1hz := 0;
			--			s1_temp <= "1111";     --�������������յ�1111ʱ�����������ܱ䰵
			--			s2_temp <= "1111";     --�������������յ�1111ʱ�����������ܱ䰵
			--		ELSE
			--			count_1hz := 0;
			--			s1_temp <= s1;
			--			s2_temp <= s2;
			--		END IF;
                    
					IF SW1='0' then
                        if sw1_r='0' THEN            --����ʱ�䣬��SW1������,s1s2��ֵ������1
						IF s1_temp="0101" AND s2_temp="1001" THEN
							s1_temp <= "0000";
							s2_temp <= "0000";
						ELSIF s2_temp="1001" THEN
							s1_temp <= s1_temp + '1';
							s2_temp <= "0000";
						ELSE
							s2_temp <= s2_temp + '1';
						end if;
						END IF;
                        
					ELSIF SW2='0' then
						if sw2_r='0' THEN  
							--����ʱ�䣬��SW2������,s1s2��ֵ�����1
						IF s1_temp="0000" AND s2_temp="0000" THEN
							s1_temp <= "0101";
							s2_temp <= "1001";
						ELSIF s2_temp="0000" THEN
							s1_temp <= s1_temp - '1';
							s2_temp <= "1001";
						ELSE
							s2_temp <= s2_temp - '1';
						end if;
						END IF;                       
					END IF;  
                    
			END CASE;           
		END IF;      
	END PROCESS;
END behav;