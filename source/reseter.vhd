library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reseter is
port(clk,reset_in:in std_logic;           --按键按下时为0
     reset_out:out std_logic:='0');
      end reseter;

architecture behav of reseter is

begin

PROCESS(clk,reset_in) 
  VARIABLE COUNT1 :INTEGER RANGE 0 TO 1000000; 
BEGIN 
IF reset_in='0' THEN 
   IF RISING_EDGE(clk) THEN
    IF COUNT1<1000000 THEN COUNT1:=COUNT1+1; 
    ELSE COUNT1:=COUNT1; END IF; 
    IF COUNT1<=999999 THEN reset_out<='1'; 
    ELSE reset_out<='0'; END IF; 
  END IF; 
ELSE COUNT1:=0;
     reset_out<='1';
END IF; 
END PROCESS ;
end behav;