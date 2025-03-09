---------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_user_logic is   -- tx_out
  Port ( 
       tx_data                 : in std_logic_vector(7 DOWNTO 0);
       tx_pulse                : in std_logic;
       iclk                    : in std_logic;   
	   tx                      : out std_logic; -- tx_out will be assigned to tx pin of the controller
       rx                      : in std_logic;
       reset                   : in std_logic
	   --LCD_Data                : out std_logic_vector(127 DOWNTO 0);
	   --Mode					   : out std_logic_vector(2 DOWNTO 0);
	   --Seven_seg			   : out std_logic_vector(0 DOWNTO 0)
		 );
end uart_user_logic;

architecture Behavioral of uart_user_logic is
component uart is
    port (
        reset       :in  std_logic;
        txclk       :in  std_logic;
        ld_tx_data  :in  std_logic;
        tx_data     :in  std_logic_vector (7 downto 0);
        tx_enable   :in  std_logic;
        tx_out      :out std_logic;
        tx_empty    :out std_logic;
        rxclk       :in  std_logic;
        uld_rx_data :in  std_logic;
        rx_data     :out std_logic_vector (7 downto 0);
        rx_enable   :in  std_logic;
        rx_in       :in  std_logic;
        rx_empty    :out std_logic
    );
end component;

component Shift_Reg is
	GENERIC (
		CONSTANT sr_depth : integer := 8);     
	port(	
		clock:		in std_logic;
		reset :		in std_logic;
		en: 			in std_logic;
		sr_in:		in std_logic_vector(7 downto 0);
		sr_out:		out std_logic_vector(sr_depth-1 downto 0) :=(others => '0')
	);
end component;

component debounce IS
  GENERIC(
    counter_size  :  INTEGER := 20); --counter size (19 bits gives 10.5ms with 50MHz clock)
  PORT(
    clk     : IN  STD_LOGIC;  --input clock
    button  : IN  STD_LOGIC;  --input signal to be debounced
    result  : OUT STD_LOGIC); --debounced signal
end component;


component btn_debounce_toggle is
GENERIC (
	CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");  
    Port ( BTN_I 	: in  STD_LOGIC;
           CLK 		: in  STD_LOGIC;
           BTN_O 	: out  STD_LOGIC;
           TOGGLE_O : out  STD_LOGIC;
		   PULSE_O  : out STD_LOGIC);
end component;

TYPE state_type IS (IDLE,TRANSMISSION, RECEIVER);
signal state : state_type;

-- UART SIGNALS
--signal reset : std_logic := '0';
signal txclk : std_logic;
signal ld_tx_data : std_logic;
signal tx_enable : std_logic;
signal tx_out : std_logic;
signal tx_empty : std_logic;
signal rxclk : std_logic;
signal uld_rx_data : std_logic;
signal rx_data    : std_logic_vector(7 DOWNTO 0);
signal rx_enable : std_logic;
signal rx_in    : std_logic;
signal rx_empty : std_logic;


signal Mode					   :  std_logic_vector(2 DOWNTO 0);
signal Seven_seg			   :  std_logic_vector(0 DOWNTO 0);
signal LCD_data                : std_logic_vector(127 downto 0);

-- SHIFT REGISTER SIGNALS --
signal sr_in0	  : std_logic_vector(7 DOWNTO 0);
signal sr_in1	  :std_logic_vector(7 DOWNTO 0);
signal sr_in2    : std_logic_vector(7 DOWNTO 0);
signal sr_in3    : std_logic_vector(7 DOWNTO 0);
signal sr_in4    : std_logic_vector(7 DOWNTO 0);
signal sr_in5    : std_logic_vector(7 DOWNTO 0);
signal sr_in6    : std_logic_vector(7 DOWNTO 0);
signal sr_in7    : std_logic_vector(7 DOWNTO 0);
signal sr_in8    : std_logic_vector(7 DOWNTO 0);
signal sr_in9    : std_logic_vector(7 DOWNTO 0);
signal sr_in10   : std_logic_vector(7 DOWNTO 0);
signal sr_in11   : std_logic_vector(7 DOWNTO 0);
signal sr_in12   : std_logic_vector(7 DOWNTO 0);
signal sr_in13   : std_logic_vector(7 DOWNTO 0);
signal sr_in14   : std_logic_vector(7 DOWNTO 0);
signal sr_in15   : std_logic_vector(7 DOWNTO 0);
signal sr_in16   : std_logic_vector(7 DOWNTO 0);

-- Clock divider signals
signal clk_div   : std_logic := '0';
signal div_cnt   : integer := 0;
constant DIV_MAX : integer := 2604;  -- Adjust this constant if needed

signal shiftcount       : integer range 0 to 16;
signal rx_empty_db      : std_logic;
signal shift_trig       : std_logic;
signal old_shift_trig   : std_logic;
signal uartconcat       : std_logic_vector(7 downto 0);

begin

-- CLOCK ENABLER FOR TXCLK and RXCLK --

--Inst_clk_en :process(iCLK)
--	begin
--	if rising_edge(iCLK) then
--		if (clk_cnt = 13020) then --49999999
--			clk_cnt <= 0;
--			clk_en <= '1';
--		else
--			clk_cnt <= clk_cnt + 1;
--			clk_en <= '0';
--		end if;
--	end if;
--	end process;
-- Clock divider signals

-- Clock divider process
process(iclk)
begin
    if rising_edge(iclk) then
        if div_cnt = DIV_MAX then
            div_cnt <= 0;
            clk_div <= not clk_div;  -- Toggle divided clock
        else
            div_cnt <= div_cnt + 1;
        end if;
    end if;
end process;


process(iclk, shift_trig, old_shift_trig)
begin
	old_shift_trig <= shift_trig;
	
	if shift_trig = '1' and old_shift_trig = '0' then
		shiftcount <= shiftcount + 1;
		if shiftcount = 17 then
			LCD_Data <= sr_in16 & sr_in15 & sr_in14 & sr_in13 & sr_in12 & sr_in11 & sr_in10 & sr_in9 & sr_in8 & sr_in7 & sr_in6 & sr_in5 & sr_in4 & sr_in3 & sr_in2 & sr_in1;
			Mode <= sr_in0(2 DOWNTO 0);
			Seven_seg <= sr_in0(3 DOWNTO 3);
		end if;
	end if;
end process;

uart_master_inst : uart
    port map(
        reset       => reset,
        txclk       => clk_div,
        ld_tx_data  => '1',
        tx_data     => tx_data,
        tx_enable   => tx_pulse,
        tx_out      => tx,
        tx_empty    => tx_empty,
        rxclk       => clk_div,
        uld_rx_data => '1',
        rx_data     => rx_data,
        rx_enable   => rx_enable,
        rx_in       => rx_in,
        rx_empty    => rx_empty
    );

debouncer_inst : btn_debounce_toggle
	PORT MAP(
    BTN_I => rx_empty,
    CLK => iclk,
    BTN_O => open, 
    TOGGLE_O => open,
    PULSE_O => shift_trig
    );
	 
shift_register_inst0 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => rx_data,
		sr_out => sr_in0
		);
	  
shift_register_inst1 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in0,
		sr_out => sr_in1
		);

shift_register_inst2 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in1,
		sr_out => sr_in2
		);

shift_register_inst3 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in2,
		sr_out => sr_in3
		);

shift_register_inst4 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in3,
		sr_out => sr_in4
		);

shift_register_inst5 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in4,
		sr_out => sr_in5
		);		
		
shift_register_inst6 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in5,
		sr_out => sr_in6
		);		
		
shift_register_inst7 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in6,
		sr_out => sr_in7
		);		
		
shift_register_inst8 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in7,
		sr_out => sr_in8
		);		
		
shift_register_inst9 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in8,
		sr_out => sr_in9
		);		
		
shift_register_inst10 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in9,
		sr_out => sr_in10
		);		
		
shift_register_inst11 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in10,
		sr_out => sr_in11
		);		
		
shift_register_inst12 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in11,
		sr_out => sr_in12
		);		
		
shift_register_inst13 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in12,
		sr_out => sr_in13
		);		
		
shift_register_inst14 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in13,
		sr_out => sr_in14
		);		
		
shift_register_inst15 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in14,
		sr_out => sr_in15
		);		
		
shift_register_inst16 : Shift_Reg 
	  PORT MAP(
	   clock => iclk,
		reset => reset,
		en => rx_empty, 			
		sr_in => sr_in15,
		sr_out => sr_in16
		);		
	
end Behavioral;
