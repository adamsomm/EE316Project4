lIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity SevenSeg_I2C is
PORT(
    clk       : IN         STD_LOGIC;                    --system clock
    reset     : IN         STD_LOGIC;
	--iData     : IN         STD_LOGIC_vector(15 downto 0);
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
end SevenSeg_I2C;

ARCHITECTURE logic OF SevenSeg_I2C IS

component i2c_master IS
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
    busy      : OUT    STD_LOGIC;	 				 --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END component;

TYPE machine IS(start, ready, data_valid, busy_high, repeat); --needed states
signal state		: machine := start;
signal statebuffer  : machine := start;
signal i2c_busy     : STD_LOGIC;                    --indicates transaction in progress
signal busy_prev	: STD_LOGIC;
signal data_rd  	: STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
signal i2c_ena   	: STD_LOGIC;                    --latch in command
signal i2c_addr     : STD_LOGIC_VECTOR(7 DOWNTO 0); --address of target slave
signal i2c_rw       : STD_LOGIC;                    --'0' is write, '1' is read
signal byteSel      : integer range 0 to 12 := 0;
signal data_wr		: std_logic_vector(7 downto 0);
signal ack_error	: std_logic;
signal SvnSeg_addr     : STD_LOGIC_VECTOR(7 DOWNTO 0); 
signal LCD_addr     : STD_LOGIC_VECTOR(7 DOWNTO 0); 
signal ADC_addr     : STD_LOGIC_VECTOR(7 DOWNTO 0); 
signal iData        : std_logic_vector(15 downto 0) := X"1111";

begin

state <= statebuffer;
SvnSeg_addr <= x"71";
LCD_addr <= x"27";
ADC_addr <= x"90";

inst_i2c_master : i2c_master
port map(
	 clk     	=> clk,           
    reset_n 	=> reset,     
    ena     	=> i2c_ena,
    addr    	=> svnSeg_addr(6 downto 0),
    rw      	=> '0',
    data_wr 	=> data_wr,
    busy      	=> i2c_busy,                 --indicates transaction in progress
    data_rd   => data_rd,
    ack_error => ack_error,
    sda       => sda,
    scl       => scl
);

process(clk,reset)
begin  

if reset = '0' then 
    statebuffer <= start;
    byteSel <= 0;
elsif(rising_edge(clk)) then
	CASE state is
		when start =>
            i2c_ena <= '0';
            statebuffer <= ready;
				
        when ready => 
            if i2c_busy = '0' then
              i2c_ena <= '1';
             statebuffer <= data_valid;
            end if; 
				
        when data_valid => 
             if i2c_busy = '1' then
              i2c_ena <= '0';
             statebuffer <= busy_high;
            end if;
				
        when busy_high =>
            if i2c_busy = '0' then
             statebuffer <= repeat;
            end if;
				
        when repeat =>
            if byteSel < 12 then
                byteSel <= byteSel + 1;
            else
                byteSel <= 9;
            end if;
            stateBuffer <= start;
				
  end case;
end if;  
end process;


process(byteSel)
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
		when 11 => data_wr <= X"0"&iData(7 downto 4);
		when 12 => data_wr <= X"0"&iData(3 downto 0);
		when others => data_wr <= X"76";
	end case;
end process;
end logic;