library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.ALL;
use ieee.std_logic_unsigned.all;
entity seg is
port(clk_50M,rst_n,en:in std_logic;
	OMS0,OMS1,OSEC0,OSEC1,OMIN0,OMIN1 :STD_LOGIC_VECTOR(3 DOWNTO 0);
    ds_stcp,ds_shcp,ds_data:out std_logic);
end seg;
architecture behav of seg is
 
constant SEG_NUM0:std_logic_vector(7 downto 0):= x"c0";                 --数码管显示数字0的八段码，以下同理
constant SEG_NUM1:std_logic_vector(7 downto 0):= x"f9";                 
constant SEG_NUM2:std_logic_vector(7 downto 0):= x"a4";
constant SEG_NUM3:std_logic_vector(7 downto 0):= x"b0";
constant SEG_NUM4:std_logic_vector(7 downto 0):= x"99";
constant SEG_NUM5:std_logic_vector(7 downto 0):= x"92";
constant SEG_NUM6:std_logic_vector(7 downto 0):= x"82";
constant SEG_NUM7:std_logic_vector(7 downto 0):= x"F8";
constant SEG_NUM8:std_logic_vector(7 downto 0):= x"80";
constant SEG_NUM9:std_logic_vector(7 downto 0):= x"90";
constant SEG_NUMan:std_logic_vector(7 downto 0):= x"FF";
constant SEG_WE0:std_logic_vector(7 downto 0):= "11111110";
constant SEG_WE1:std_logic_vector(7 downto 0):= "11111101";
constant SEG_WE2:std_logic_vector(7 downto 0):= "11111011";
constant SEG_WE3:std_logic_vector(7 downto 0):= "11110111";
constant SEG_WE4:std_logic_vector(7 downto 0):= "11101111";
constant SEG_WE5:std_logic_vector(7 downto 0):= "11011111";

signal clk_50M1:std_logic;                                       --时钟信号
signal clk_50M_div_2:std_logic;                                  --二分频时钟
signal seg_num:std_logic_vector(3 downto 0);                           --读取idis_data中的数据，存储一位十六进制数
signal seg_duan:std_logic_vector(7 downto 0);                     
 --数码管中的八段码，用于显示数码管
signal seg_wei:std_logic_vector(7 downto 0);                          
--八个数码管的亮暗标志，决定哪个数码管亮
signal cnt_4:std_logic_vector(8 downto 0);                          
 --计数器，用于决定每段时间做什么事情
signal ds_stcpr:std_logic;                                            
--输出存储器锁存时钟
signal ds_shcpr:std_logic;                                           
 --数据输入时钟
signal ds_datar:std_logic;                                           
 --串行数据输入

begin
process(en)                                         --模块使能端口，高定平有效
begin
   if en='1' then
   clk_50M1<=clk_50M;
   else clk_50M1<=clk_50M1;
 end if;
 end process;
 
 process(clk_50M1,rst_n)                                        --二分频
 begin
   if rst_n='0' then
   clk_50M_div_2<='0';
   elsif rising_edge(clk_50M1) then
   clk_50M_div_2<=not clk_50M_div_2;
   end if;
 end process;
 
 process(clk_50M_div_2,rst_n)                                    --cnt_4计数
 begin
   if rst_n='0' then
   cnt_4<="000000000";
   elsif rising_edge(clk_50M_div_2) then
   cnt_4<=cnt_4+"000000001";
   end if;
 end process;
 
 process(clk_50M_div_2,rst_n)                                             
--cnt_4取不同值时seg_num从idis_data中读取相对应的四位二进制数
 begin
   if rst_n='0' then
   seg_num<="0000";
   elsif rising_edge(clk_50M_div_2) then
    case cnt_4(8 downto 6) is
       when "000"=> seg_num <= OMS0(3 downto 0);
       when "001"=> seg_num <= OMS1(3 downto 0);                                              
       when "010"=> seg_num <= OMIN0(3 downto 0);
       when "011"=> seg_num <= OMIN1(3 downto 0);
	   when "100"=> seg_num <= OSEC0(3 downto 0);
       when "101"=> seg_num <= OSEC1(3 downto 0);
       WHEN OTHERS=>SEG_NUM <="1111";
    end case;
   end if;
 end process;
 
 process(clk_50M_div_2,rst_n)                                             
  --根据seg_num取值的不同来给八位段码seg_duan赋值
 begin
   if rst_n='0' then 
   seg_duan<=x"ff";
   elsif rising_edge(clk_50M_div_2) then
      case seg_num is
            when "0000"=> seg_duan <= SEG_NUM0;                       
  --当seg_num为“0000“时，seg_duan码会让数码管显示0
            when "0001"=> seg_duan <= SEG_NUM1;
            when "0010"=> seg_duan <= SEG_NUM2;
            when "0011"=> seg_duan <= SEG_NUM3;
            when "0100"=> seg_duan <= SEG_NUM4;
            when "0101"=> seg_duan <= SEG_NUM5;
            when "0110"=> seg_duan <= SEG_NUM6;
            when "0111"=> seg_duan <= SEG_NUM7;
            when "1000"=> seg_duan <= SEG_NUM8;
            when "1001"=> seg_duan <= SEG_NUM9;
            when others=> seg_duan <= SEG_NUMan;
      end case;
    end if;
end process;

process(cnt_4)                      --根据cnt_4取不同值时，决定哪位数码管亮
begin
    case cnt_4(8 downto 6) is
        when "000"=> seg_wei <= SEG_WE0;
        when "001"=> seg_wei <= SEG_WE1;
        when "010"=> seg_wei <= SEG_WE2;                                                          
        when "011"=> seg_wei <= SEG_WE3;
		when "100"=> seg_wei <= SEG_WE4;                                                          
        when "101"=> seg_wei <= SEG_WE5;
        when others=> seg_WEI <="11111111";
    end case;
end process;

process(clk_50M_div_2,rst_n)                    --通过cnt_4来确定数据输入时钟
begin
   if rst_n='0' then
   ds_shcpr<='0';
   elsif rising_edge(clk_50M_div_2) then
   if((cnt_4>o"002" and cnt_4<=o"042")or(cnt_4>o"044"and cnt_4 <= o"104") or (cnt_4 > o"106" and cnt_4 <= o"146") or (cnt_4 > o"150" and cnt_4 <= o"210")
            or (cnt_4 > o"212" and cnt_4 <= o"252") or (cnt_4 > o"254" and cnt_4 <= o"314") or (cnt_4 > o"316" and cnt_4 <= o"356")
			or (cnt_4 > o"360" and cnt_4 <= o"420") or (cnt_4 > o"422" and cnt_4 <= o"462") or (cnt_4 > o"464" and cnt_4 <= o"524")
			or (cnt_4 > o"526" and cnt_4 <= o"566"))then
   ds_shcpr<=not ds_shcpr;
   else ds_shcpr<='0';
   end if;
   end if;
 end process;
 
process(clk_50M_div_2,rst_n)                    --通过cnt_4来确定串行数据输入
begin
  if rst_n='0' then
  ds_datar<='0';
  elsif rising_edge(clk_50M_div_2) then
  case(cnt_4) is
            when o"002"|o"106" | o"212"|o"316"|o"422"|O"526"=> ds_datar <= seg_duan(7);
            when o"004"|o"110" | o"214"|o"320"|o"424"|o"530"=> ds_datar <= seg_duan(6);
            when o"006"|o"112" | o"216"|o"322"|o"426"|o"532"=> ds_datar <= seg_duan(5);
            when o"010"|o"114" | o"220"|o"324"|o"430"|O"534"=> ds_datar<= seg_duan(4);
            when o"012"|o"116" | o"222"|o"326"|o"432"|o"536"=> ds_datar <= seg_duan(3);
            when o"014"|o"120" | o"224"|o"330"|o"434"|o"540"=> ds_datar <= seg_duan(2);
            when o"016"|o"122" | o"226"|o"332"|o"436"|o"542"=> ds_datar <= seg_duan(1);
            when o"020"|o"124" | o"230"|o"334"|o"440"|o"544"=> ds_datar <= seg_duan(0);
            when o"022"|o"126" | o"232"|o"336"|o"442"|o"546"=> ds_datar <= seg_wei(0);
            when o"024"|o"130" | o"234"|o"340"|o"444"|o"550"=> ds_datar <= seg_wei(1);
            when o"026"|o"132" | o"236"|o"342"|o"446"|o"552"=> ds_datar <= seg_wei(2);
            when o"030"|o"134" | o"240"|o"344"|o"450"|o"554"=> ds_datar <= seg_wei(3);
            when o"032"|o"136" | o"242"|o"346"|o"452"|o"556"=> ds_datar <= seg_wei(4);
            when o"034"|o"140" | o"244"|o"350"|o"454"|o"560"=> ds_datar <= seg_wei(5);
            when o"036"|o"142" | o"246"|o"352"|o"456"|o"562"=> ds_datar <= seg_wei(6);
            when o"040"|o"144" | o"250"|o"354"|o"460"|o"564"=> ds_datar <= seg_wei(7);
            
            when o"044" |o"150" |o"254" |o"360"|o"464"=> ds_datar <= '1';
            when o"046" |o"152" |o"256" |o"362"|o"466"=> ds_datar <= '1';
            when o"050" |o"154" |o"260" |o"364"|o"470"=> ds_datar <= '1';
            when o"052" |o"156" |o"262" |o"366"|o"472"=> ds_datar <= '1';
            when o"054" |o"160" |o"264" |o"370"|o"474"=> ds_datar <= '1';
            when o"056" |o"162" |o"266" |o"372"|o"476"=> ds_datar <= '1';
            when o"060" |o"164" |o"270" |o"374"|o"500"=> ds_datar <= '1';
            when o"062" |o"166" |o"272" |o"376"|o"502"=> ds_datar <= '1';
            when o"064" |o"170" |o"274" |o"400"|O"504"=> ds_datar <= '1' ;
            when o"066" |o"172" |o"276" |o"402"|O"506"=> ds_datar <= '1';
            when o"070" |o"174" |o"300" |o"404"|O"510"=> ds_datar <= '1';
            when o"072" |o"176" |o"302" |o"406"|o"512"=> ds_datar <= '1';
            when o"074" |o"200" |o"304" |o"410"|o"514"=> ds_datar <= '1';
            when o"076" |o"202" |o"306" |o"412"|o"516"=> ds_datar <= '1';
            when o"100" |o"204" |o"310" |o"414"|o"520"=> ds_datar <= '1';
            when o"102" |o"206" |o"312" |o"416"|o"522"=> ds_datar <= '1';
            when others=> ds_datar <= seg_duan(0);
  end case;
  end if;
 end process;
 
process(clk_50M_div_2,rst_n)                                       
 --通过cnt_4来确定并行输出时钟，16位数据并行输出一次
 begin
    if rst_n='0' then
    ds_stcpr<='0';
    elsif rising_edge(clk_50M_div_2) then
    if((cnt_4=o"002")or(cnt_4=o"043")or(cnt_4=o"105")or(cnt_4=o"147")or(cnt_4=o"211")or(cnt_4=o"253")or(cnt_4=o"315")
	     or(cnt_4=o"357")or(cnt_4=o"421")or(cnt_4=o"463")or(cnt_4=o"525")) then
    ds_stcpr <= '0';
    elsif((cnt_4=o"042")or(cnt_4=o"104")or(cnt_4=o"146")or(cnt_4=o"210")or(cnt_4=o"252")or(cnt_4=o"314")or(cnt_4=o"356")
	     or(cnt_4=o"420")or(cnt_4=o"462")or(cnt_4=o"524")or(cnt_4=o"566"))then 
    ds_stcpr<='1';
    end if;
    end if;
 end process;
 
process(ds_shcpr,ds_stcpr,ds_datar)                     --信号赋值给接口
 begin
 ds_shcp<=ds_shcpr;
 ds_stcp<=ds_stcpr;
 ds_data<=ds_datar;
 end process; 
 end behav;