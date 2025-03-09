library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity TopLevel is
  port (
    iCLK     : in std_logic;
    reset    : in std_logic;
    ps2_clk  : in std_logic; -- PS/2 clock input
    ps2_data : in std_logic; -- PS/2 data input
    LCDsda   : inout std_logic;
    LCDscl   : inout std_logic;
    Sevsda   : inout std_logic;
    Sevscl   : inout std_logic;
    TX_in    : in std_logic;
    RX_out   : out std_logic
    -- Add other ports as needed - uart
  );
end TopLevel;

architecture Behavioral of TopLevel is
  -- Component declarations
  component ps2_keyboard_to_ascii
    generic (
      clk_freq : INTEGER := 125_000_000;
      ps2_debounce_counter_size : INTEGER := 10 
    );
    port (
      clk : in STD_LOGIC;
      ps2_clk : in STD_LOGIC;
      ps2_data : in STD_LOGIC;
      ascii_new : out STD_LOGIC;
      ascii_code : out STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  end component;

  component reset_delay
    port (
      iCLK   : in std_logic;
      oRESET : out std_logic
      -- Add other ports as needed
    );
  end component;

  component SevenSeg_I2C
    generic (
      input_clk : integer := 125_000_000; --input clock speed from user logic in Hz
      bus_clk   : integer := 400_000); --speed the i2c bus (scl) will run at in Hz
    port (
      clk    : in std_logic;
      reset  : in std_logic;
      dataIn : in std_logic_vector (15 downto 0) := X"0001";
      sda    : inout std_logic;
      scl    : inout std_logic
    );
  end component;

  component LCD_I2C_user_logic
    generic (
    input_clk : integer := 125_000_000; --input clock speed from user logic in Hz
    bus_clk   : integer := 50_000); --speed the i2c bus (scl) will run at in Hz
  port (
    clk   : in std_logic;
    reset : in std_logic;
    mode  : in std_logic_vector(2 downto 0);
    data_in : in std_logic_vector(127 downto 0);
    scl : inout std_logic;
    sda : inout std_logic
      -- Add other ports as needed
    );
  end component;

  -- Signal declarations
  signal internal_reset : std_logic;
  signal reset_d        : std_logic;
  signal reset_Mode     : std_logic := '0';
  signal olduartSeven   : std_logic := '0';
  signal uartSeven      : std_logic :='0';
  signal oldmode        : std_logic_vector(2 downto 0);
  signal mode           : std_logic_vector(2 downto 0) := "101";
  signal data_s         : std_logic_vector(15 downto 0) := X"0006";
  signal LCD_data       : std_logic_vector(127 downto 0) := X"48616E675F5F5F5F4D616E2020202020";
  signal uart_datai     : std_logic_vector(7 downto 0);
  signal uart_pulse     : std_logic;
  

begin
  internal_reset <= reset or reset_d;
    -- Component instantiations
    ps2_keyboard_to_ascii_inst : ps2_keyboard_to_ascii
  generic map (
    clk_freq => 125_000_000,
    ps2_debounce_counter_size => 10
  )
  port map (
    clk => iCLK,
    ps2_clk => ps2_clk,
    ps2_data => ps2_data,
    ascii_new => uart_pulse,
    ascii_code => uart_datai
  );


  reset_delay_inst : reset_delay
  port map
  (
    iCLK   => iCLK,
    oRESET => reset_d
    -- Map other ports as needed
  );

  SevenSeg_I2C_inst : SevenSeg_I2C
  generic map(
    input_clk => 125_000_000,
    bus_clk   => 400_000
  )
  port map
  (
    clk   => iCLK,
    reset => internal_reset,
    dataIn=> data_s,
    sda   => Sevsda,
    scl   => Sevscl
  );

  LCD_I2C_user_logic_inst : LCD_I2C_user_logic
  generic map(
    input_clk => 125_000_000,
    bus_clk   => 50_000
  )
  port map
  (
    clk   => iCLK,
    reset => internal_reset,
    mode  => mode, -- 3 bit data from uart user logic
    data_in => LCD_data, --3 bit data from uart user logic
    scl => LCDscl,
    sda => LCDsda
  );
  -- Process declaration for seven segment incrementing logic based on uart
  process (iCLK, internal_reset)
  begin
    olduartSeven <= uartSeven;
    oldMode      <= mode;
    if oldMode /= mode then
      reset_Mode <= '1';
    end if;
    if internal_reset = '1' or reset_Mode = '1' then
      data_s       <= X"0006";
      olduartSeven <= '0';
    elsif rising_edge(iCLK) then
      if uartSeven = '1' and olduartSeven = '0' then
        case data_s is
          when X"0000" => data_s <= X"0006";
          when others => data_s <= data_s - 1;
        end case;
      end if;
    end if;
  end process;
end Behavioral;
