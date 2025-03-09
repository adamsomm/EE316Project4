LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--USE ieee.std_logic_unsigned.all;

ENTITY SevenSeg_I2C IS
  GENERIC(
    input_clk : INTEGER := 125_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 50_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk        : IN     STD_LOGIC;                   --system clock
	 reset   : IN     STD_LOGIC;  
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC
	 --busy      : INOUT STD_LOGIC
	 );                    --busy output of i2c bus
END SevenSeg_I2C;

ARCHITECTURE user_logic OF SevenSeg_I2C IS

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
        
PROCESS(clk, reset)
BEGIN  
if reset = '0' then
    	  state <= start;
		  byteSel <= 0;
	  	  Cont <= X"000FFFF";
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
	  	     Cont <= X"000FFFF";             
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

------------------------------------------------------------------------------------
----Code by: Zachary Rauen
----Date: 1/8/15
----Last Modified: 1/15/15
----
----Description: This takes in 16 bit data and displays them on an external display
---- using GPIO and I2C communication.
----
----Version: 2.1
------------------------------------------------------------------------------------
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use IEEE.numeric_std.all;

--entity SevenSeg_I2C is
--  generic (
--    input_clk : integer := 125_000_000; --input clock speed from user logic in Hz
--    bus_clk   : integer := 50_000); --speed the i2c bus (scl) will run at in Hz
--  port (
--    clk : in std_logic;
--    reset: in std_logic;
--    --dataIn : in STD_LOGIC_VECTOR (15 downto 0):= X"0001";
--    sda : inout std_logic;
--    scl : inout std_logic);
--end SevenSeg_I2C;

--architecture Behavioral of SevenSeg_I2C is

--  component i2c_master is
--    generic (
--      input_clk : integer := 125_000_000; --input clock speed from user logic in Hz
--      bus_clk   : integer := 500_000); --speed the i2c bus (scl) will run at in Hz
--    -- ADC runs at 400,000, lcd at 100k max 
--    port (
--      clk       : in std_logic; --system clock
--      reset_n   : in std_logic; --active low reset
--      ena       : in std_logic; --latch in command
--      addr      : in std_logic_vector(6 downto 0); --address of target slave
--      rw        : in std_logic; --'0' is write, '1' is read
--      data_wr   : in std_logic_vector(7 downto 0); --data to write to slave
--      busy      : out std_logic; --indicates transaction in progress
--      data_rd   : out std_logic_vector(7 downto 0); --data read from slave
--      ack_error : buffer std_logic; --flag if improper acknowledge from slave
--      sda       : inout std_logic; --serial data output of i2c bus
--      scl       : inout std_logic); --serial clock output of i2c bus
--  end component;

--  -- -----------------------------------------------------------------------------------------------------------------------------------

--  signal LCD_Data : std_logic_vector(7 downto 0) := (others => '0');

--  signal cont        : unsigned(27 downto 0)        := X"00FFFFF";
--  signal slave_addr  : std_logic_vector(6 downto 0) := "1110001"; -- 0x27 in 7-bit
--  signal i2c_addr    : std_logic_vector(6 downto 0);
--  signal i2c_rw      : std_logic                    := '0';
--  signal i2c_ena     : std_logic                    := '0';
--  signal i2c_data_wr : std_logic_vector(7 downto 0) := (others => '0');
--  type state_type is (start, write);
--  signal state   : state_type := start;
--  signal rst     : std_logic  := '0';
--  signal reset_M : std_logic;
--  signal reset_D : std_logic := '0';
--  signal busy    : std_logic;
--  signal byteChoice : integer range 1 to 13 := 1;
--  signal dataOut : std_logic_vector(7 downto 0);
--  signal oldbusy : std_logic;
--  signal dataIn  : std_logic_vector(15 downto 0) := X"1111";
--  -- -----------------------------------------------------------------------------------------------------------------------------------
--begin
--  reset_M <= not reset or not rst; -- active low
--  reset_D <= not reset_M; -- active high
--  i2c_rw  <= '0';

--  inst_i2cMaster : i2c_master
--  generic map(
--    input_clk => 125_000_000, --input clock speed from user logic in Hz
--    bus_clk   => 50_000) --speed the i2c bus (scl) will run at in Hz
--  port map
--  (
--    clk       => clk, --system clock
--    reset_n   => reset_M, --active low reset
--    ena       => i2c_ena, --latch in command
--    addr      => i2c_addr, --address of target slave
--    rw        => i2c_rw, --'0' is write, '1' is read (I am writing data ABCD)
--    data_wr   => i2c_data_wr, --data to write to slave
--    busy      => busy, --indicates transaction in progress
--    data_rd   => open, --data read from slave (e.g. a sensor)
--    ack_error => open, --flag if improper acknowledge from slave
--    sda       => sda, --serial data output of i2c bus
--    scl       => scl
--  );

--  process (clk, reset)
--  begin
--    if reset = '1' then
--      rst         <= '1';
--      cont        <= X"00FFFFF";
--      i2c_addr    <= slave_addr;
--      i2c_data_wr <= (others => '0');
--      i2c_ena     <= '0';
--      state       <= start;
--      byteChoice  <= 1;
--    elsif rising_edge(clk) then
--        oldbusy <= busy;
--      case state is
--        when start =>
--          if (cont /= X"0000000") then
--            cont  <= cont - 1;
--            rst   <= '1';
--            state <= start;
--          else
--            rst      <= '0';
--            i2c_ena  <= '1';
--            i2c_addr <= slave_addr;
--            state    <= write;
--          end if;
--        when write =>
--          i2c_data_wr <= dataOut;
--          state       <= write;
--          if oldbusy = '1' and busy = '0' then
--            if byteChoice < 13 then
--              byteChoice <= byteChoice + 1;
--            else
--              byteChoice <= 1;
--            end if;
--          end if;
--        when others =>
--          state <= start;

--      end case;
--    end if;
--  end process;

--  process (byteChoice, clk)
--  begin
--    case byteChoice is
--      when 1      => dataOut      <= x"76";
--      when 2      => dataOut      <= x"76";
--      when 3      => dataOut      <= x"76";
--      when 4      => dataOut      <= x"7A";
--      when 5      => dataOut      <= x"FF";
--      when 6      => dataOut      <= x"77";
--      when 7      => dataOut      <= x"00";
--      when 8      => dataOut      <= x"79";
--      when 9      => dataOut      <= x"00";
--      when 10     => dataOut     <= x"0" & dataIn(15 downto 12);
--      when 11     => dataOut     <= x"0" & dataIn(11 downto 8);
--      when 12     => dataOut     <= x"0" & dataIn(7 downto 4);
--      when 13     => dataOut     <= x"0" & dataIn(3 downto 0);
--      when others => dataOut <= x"76";
--    end case;
--  end process;

--end Behavioral;
