library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity key_debounce is
port( clk,key0,key1,key2,key3: in std_logic;
		key_out_0,key_out_1,key_out_2,key_out_3: out std_logic);
end key_debounce;
architecture behav of key_debounce is
signal counter0,counter1,counter2,counter3:integer range 0 to 500000;
signal df_0_1,df_0_2,df_0,rst_n0:std_logic;
signal df_1_1,df_1_2,df_1,rst_n1:std_logic;
signal df_2_1,df_2_2,df_2,rst_n2:std_logic;
signal df_3_1,df_3_2,df_3,rst_n3:std_logic;
signal temp0,temp1,temp2,temp3:std_logic:='1';
constant timer:integer:=500000;
begin

process(clk)
begin
if clk'event and clk='1' then
df_0_1<=key0;
df_0_2<=df_0_1;

df_1_1<=key1;
df_1_2<=df_1_1;

df_2_1<=key2;
df_2_2<=df_2_1;

df_3_1<=key3;
df_3_2<=df_3_1;
end if;
df_0<=df_0_1 xor df_0_2;
rst_n0<=df_0;

df_1<=df_1_1 xor df_1_2;
rst_n1<=df_1;

df_2<=df_2_1 xor df_2_2;
rst_n2<=df_2;

df_3<=df_3_1 xor df_3_2;
rst_n3<=df_3;
end process;

process(clk,rst_n0)
begin
if rst_n0='1' then
counter0<=0;
elsif clk'event and clk='1' then
counter0<=counter0+1;
if counter0=500000 then  
counter0<=0;
temp0<=key0;
end if;
end if;
end process;

process(clk,rst_n1)
begin
if rst_n1='1' then
counter1<=0;
elsif clk'event and clk='1' then
counter1<=counter1+1;
if counter1=timer then  
counter1<=0;
temp1<=key1;
end if;
end if;
end process;

process(clk,rst_n2)
begin
if rst_n2='1' then
counter2<=0;
elsif clk'event and clk='1' then
counter2<=counter2+1;
if counter2=timer then  
counter2<=0;
temp2<=key2;
end if;
end if;
end process;

process(clk,rst_n3)
begin
if rst_n3='1' then
counter3<=0;
elsif clk'event and clk='1' then
counter3<=counter3+1;
if counter3=timer then  
counter3<=0;
temp3<=key3;
end if;
end if;
end process;
key_out_0<=temp0;
key_out_1<=temp1;
key_out_2<=temp2;
key_out_3<=temp3;
end behav;

