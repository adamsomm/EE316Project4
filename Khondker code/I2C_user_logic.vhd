LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--USE ieee.std_logic_unsigned.all;

ENTITY I2C_user_logic IS
  GENERIC(
    input_clk : INTEGER := 125_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 50_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk        : IN     STD_LOGIC;                   --system clock
	 iReset_n   : IN     STD_LOGIC;  
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);
	 --busy      : INOUT STD_LOGIC);                    --busy output of i2c bus
END I2C_user_logic;

ARCHITECTURE user_logic OF I2C_user_logic IS

TYPE state_type IS(start, write_data, repeat);    --needed states
signal state      : state_type;                   --state machine
signal reset_n    : STD_LOGIC;                    --active low reset
signal i2c_ena    : STD_LOGIC;                    --latch in command
signal i2c_addr   : STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
signal i2c_rw     : STD_LOGIC;                    --'0' is write, '1' is read
signal data_wr    : STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
signal i2c_data_wr: STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
signal i2c_busy   : STD_LOGIC;                    --indicates transaction in progress
signal busy_prev  : STD_LOGIC;                    --indicates transaction in progress previously
signal data_rd    : STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
signal ack_error  : STD_LOGIC;                    --flag if improper acknowledge from slave  
signal Cont 					 : unsigned(27 DOWNTO 0):=X"00000FF";
signal byteSel    : integer range 0 to 12:=0;
signal iData      : STD_LOGIC_VECTOR(15 DOWNTO 0); --address of target slave
signal slave_addr : STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
signal sda1        : STD_LOGIC;                    --serial data output of i2c bus
signal scl1        : STD_LOGIC;                   --serial clock output of i2c bus

attribute S: string;
attribute S of sda1: signal is "TRUE";
attribute S of scl1: signal is "TRUE";
attribute S of i2c_data_wr: signal is "TRUE";


COMPONENT i2c_master IS
  GENERIC(
    input_clk : INTEGER := 125_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 50_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END COMPONENT;  

--component OBUF
-- port(I: in STD_LOGIC; O: out STD_LOGIC);
--end component;

--component OBUFT
--port(I: in STD_LOGIC; T: in STD_LOGIC; O: out STD_LOGIC);
--end component;
  
BEGIN

	iData <= X"ABCD";
   slave_addr <= "1110001";
	--busy <= i2c_busy;
    
process(byteSel, iData)
 begin
    case byteSel is
       when 0  => data_wr <= X"76";
       when 1  => data_wr <= X"76";
       when 2  => data_wr <= X"76";
       when 3  => data_wr <= X"7A";
       when 4  => data_wr <= X"FF";
       when 5  => data_wr <= X"77";
       when 6  => data_wr <= X"00";
       when 7  => data_wr <= X"79";
       when 8  => data_wr <= X"00";
       when 9  => data_wr <= X"0"&iData(15 downto 12);
       when 10 => data_wr <= X"0"&iData(11 downto 8);
       when 11 => data_wr <= X"0"&iData(7  downto 4);
       when 12 => data_wr <= X"0"&iData(3  downto 0);
       when others => data_wr <= X"76";
   end case;
end process;

--i2c_data_wr <= data_wr;                    --data to be written
      
Inst_i2c_master: i2c_master
  GENERIC MAP(
    input_clk => 125_000_000,       --input clock speed from user logic in Hz
    bus_clk   => 50_000)           --speed the i2c bus (scl) will run at in Hz
  PORT MAP(
    clk       => clk,
    reset_n   => reset_n,
    ena       => i2c_ena,
    addr      => i2c_addr,
    rw        => i2c_rw,
    data_wr   => i2c_data_wr,
    busy      => i2c_busy,                    
    data_rd   => data_rd,
    ack_error => ack_error,
    sda       => sda1,
    scl       => scl1
    ); 
    

          
  scl <= scl1;
  sda <= sda1; 
  
-- Usda: OBUFT port map (I => '0', T => sda1, O => sda);
-- Uscl: OBUFT port map (I => '0', T => scl1, O => scl);   
        
PROCESS(clk, iReset_n)
BEGIN  
if iReset_n = '0' then
    	  state <= start;
		  byteSel <= 0;
	  	  Cont <= X"0000FFF";
		  reset_n <= '0';
		  i2c_ena <= '0';			
ELSIF(clk'EVENT AND clk = '1') THEN
 CASE state IS 
  WHEN start =>
	  IF Cont /= X"0000000" THEN                         
		  Cont <= Cont - 1;	
		  state <= start;
	  ELSE
		  reset_n <= '1';
        i2c_ena <= '1';                               --initiate the transaction
        i2c_addr <= slave_addr;                       --set the address of the slave
        i2c_rw <= '0';                                --command 0 is a write
        i2c_data_wr <= data_wr;                       --data to be written 
	     state <= write_data; 	      
	  END IF;	
	  
  WHEN write_data =>                                --state for conducting this transaction
       i2c_data_wr <= data_wr;    
       busy_prev <= i2c_busy;                        --capture the value of the previous i2c busy signal	  
  IF(busy_prev = '1' AND i2c_busy = '0') THEN       --i2c busy just went low 
        if byteSel < 12 then
        	  byteSel <= byteSel + 1;
        else	 
           byteSel <=0;
           i2c_ena <= '0';
	  	     Cont <= X"0000FFF";             
           state <= repeat;
        end if; 
--       i2c_data_wr <= data_wr;    		  
  END IF; 
	WHEN repeat => 
	  	  IF Cont /= X"0000000" THEN                         
		  Cont <= Cont - 1;	
		  Else	  		  
	      state <= start; 
	      END IF;         
  WHEN OTHERS => NULL;

  END CASE;   
END IF;  
END PROCESS;         
END user_logic;  
 

--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--use IEEE.numeric_std.all;
----USE ieee.std_logic_unsigned.all;
--
--ENTITY I2C_user_logic IS
--  GENERIC(
--    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
--    bus_clk   : INTEGER := 50_000);   --speed the i2c bus (scl) will run at in Hz
--  PORT(
--    clk        : IN     STD_LOGIC;                   --system clock
--	 iReset_n   : IN     STD_LOGIC;  
--    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
--    scl       : INOUT  STD_LOGIC;
--	 busy      : INOUT STD_LOGIC);                    --busy output of i2c bus
--END I2C_user_logic;
--
--ARCHITECTURE user_logic OF I2C_user_logic IS
--
--TYPE state_type IS(start, write_data, repeat);    --needed states
--signal state      : state_type;                   --state machine
--signal reset_n    : STD_LOGIC;                    --active low reset
--signal i2c_ena    : STD_LOGIC;                    --latch in command
--signal i2c_addr   : STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
--signal i2c_rw     : STD_LOGIC;                    --'0' is write, '1' is read
--signal data_wr    : STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
--signal i2c_data_wr: STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
--signal i2c_busy   : STD_LOGIC;                    --indicates transaction in progress
--signal busy_prev  : STD_LOGIC;                    --indicates transaction in progress previously
--signal data_rd    : STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
--signal ack_error  : STD_LOGIC;                    --flag if improper acknowledge from slave  
--signal Cont 					 : unsigned(27 DOWNTO 0):=X"00000FF";
--signal byteSel    : integer range 0 to 12:=0;
--signal iData      : STD_LOGIC_VECTOR(15 DOWNTO 0); --address of target slave
--signal slave_addr : STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
--signal sda1        : STD_LOGIC;                    --serial data output of i2c bus
--signal scl1        : STD_LOGIC;                   --serial clock output of i2c bus
--
--attribute S: string;
--attribute S of sda1: signal is "TRUE";
--attribute S of scl1: signal is "TRUE";
--attribute S of i2c_data_wr: signal is "TRUE";
--
--
--COMPONENT i2c_master IS
--  GENERIC(
--    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
--    bus_clk   : INTEGER := 50_000);   --speed the i2c bus (scl) will run at in Hz
--  PORT(
--    clk       : IN     STD_LOGIC;                    --system clock
--    reset_n   : IN     STD_LOGIC;                    --active low reset
--    ena       : IN     STD_LOGIC;                    --latch in command
--    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
--    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
--    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
--    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
--    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
--    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
--    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
--    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
--END COMPONENT;  
--
----component OBUF
---- port(I: in STD_LOGIC; O: out STD_LOGIC);
----end component;
--
----component OBUFT
----port(I: in STD_LOGIC; T: in STD_LOGIC; O: out STD_LOGIC);
----end component;
--  
--BEGIN
--
--	iData <= X"ABCD";
--   slave_addr <= "1110001";
--	busy <= i2c_busy;
--    
--process(byteSel, iData)
-- begin
--    case byteSel is
--       when 0  => data_wr <= X"76";
--       when 1  => data_wr <= X"76";
--       when 2  => data_wr <= X"76";
--       when 3  => data_wr <= X"7A";
--       when 4  => data_wr <= X"FF";
--       when 5  => data_wr <= X"77";
--       when 6  => data_wr <= X"00";
--       when 7  => data_wr <= X"79";
--       when 8  => data_wr <= X"00";
--       when 9  => data_wr <= X"0"&iData(15 downto 12);
--       when 10 => data_wr <= X"0"&iData(11 downto 8);
--       when 11 => data_wr <= X"0"&iData(7  downto 4);
--       when 12 => data_wr <= X"0"&iData(3  downto 0);
--       when others => data_wr <= X"76";
--   end case;
--end process;
--
----i2c_data_wr <= data_wr;                    --data to be written
--      
--Inst_i2c_master: i2c_master
--  GENERIC MAP(
--    input_clk => 50_000_000,       --input clock speed from user logic in Hz
--    bus_clk   => 50_000)           --speed the i2c bus (scl) will run at in Hz
--  PORT MAP(
--    clk       => clk,
--    reset_n   => reset_n,
--    ena       => i2c_ena,
--    addr      => i2c_addr,
--    rw        => i2c_rw,
--    data_wr   => i2c_data_wr,
--    busy      => i2c_busy,                    
--    data_rd   => data_rd,
--    ack_error => ack_error,
--    sda       => sda1,
--    scl       => scl1
--    ); 
--    
--
--          
--  scl <= scl1;
--  sda <= sda1; 
--  
---- Usda: OBUFT port map (I => '0', T => sda1, O => sda);
---- Uscl: OBUFT port map (I => '0', T => scl1, O => scl);   
--        
--PROCESS(clk, iReset_n)
--BEGIN  
--if iReset_n = '0' then
--    	  state <= start;
--		  byteSel <= 0;
--	  	  Cont <= X"000FFFF";
--		  reset_n <= '0';
--		  i2c_ena <= '0';			
--ELSIF(clk'EVENT AND clk = '1') THEN
-- CASE state IS 
--  WHEN start =>
--	  IF Cont /= X"0000000" THEN                         
--		  Cont <= Cont - 1;	
--		  state <= start;
--	  ELSE
--		  reset_n <= '1';
--        i2c_ena <= '1';                               --initiate the transaction
--        i2c_addr <= slave_addr;                       --set the address of the slave
--        i2c_rw <= '0';                                --command 0 is a write
--        i2c_data_wr <= data_wr;                       --data to be written 
--	     state <= write_data; 	      
--	  END IF;	
--	  
--  WHEN write_data =>                                --state for conducting this transaction
--       i2c_data_wr <= data_wr;    
--       busy_prev <= i2c_busy;                        --capture the value of the previous i2c busy signal	  
--  IF(busy_prev = '1' AND i2c_busy = '0') THEN       --i2c busy just went low 
--        if byteSel < 12 then
--        	  byteSel <= byteSel + 1;
--        else	 
--           byteSel <= 7;
--           i2c_ena <= '0';
--	  	     Cont <= X"0000FFF";             
--           state <= repeat;
--        end if; 
----       i2c_data_wr <= data_wr;    		  
--  END IF; 
--	WHEN repeat => 
--	  	  IF Cont /= X"0000000" THEN                         
--		  Cont <= Cont - 1;	
--		  Else	  		  
--	      state <= start; 
--	      END IF;         
--  WHEN OTHERS => NULL;
--
--  END CASE;   
--END IF;  
--END PROCESS;         
--END user_logic;  
-- 