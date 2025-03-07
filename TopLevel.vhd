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
    -- Add other ports as needed - uart
  );
end TopLevel;

architecture Behavioral of TopLevel is
  -- Component declarations
  component ps2_Keyboard_userLogic
    port (
      clk          : in std_logic;
      ps2_clk      : in std_logic; -- PS/2 clock input
      ps2_data     : in std_logic; -- PS/2 data input
      final_data   : out std_logic_vector(7 downto 0); -- Processed key code
      newDataPulse : out std_logic := '0'
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
      clk   : in std_logic;
      reset : in std_logic;
      dataIn : in STD_LOGIC_VECTOR (15 downto 0):= X"0001";
      sda : inout std_logic;
      scl : inout std_logic
    );
  end component;

  component LCD_I2C_user_logic
    generic (
      input_clk : integer := 50_000_000; --input clock speed from user logic in Hz
      bus_clk   : integer := 50_000); --speed the i2c bus (scl) will run at in Hz
    port (
      clk   : in std_logic; --system clock
      reset : in std_logic;
      iData     : IN         STD_LOGIC_vector(127 downto 0);
      sda : inout std_logic; --serial data output of i2c bus
      scl : inout std_logic
      -- Add other ports as needed
    );
  end component;

  -- Signal declarations
  signal internal_reset : std_logic;
  signal reset_d        : std_logic;

begin
  internal_reset <= reset or reset_d
    -- Component instantiations
    ps2_keyboard_userLogic_inst : ps2_keyboard_userLogic
    port map
    (
      clk      => iCLK,
      ps2_clk  => ps2_clk,
      ps2_data => ps2_data,
      final_data =>,
      newDataPulse =>
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
    input_clk => input_clk,
    bus_clk   => bus_clk
  )
  port map
  (
    clk   => clk,
    reset => internal_reset,
    sda   => Sevensda,
    scl   => Sevenscl
  );

  LCD_I2C_user_logic_inst : LCD_I2C_user_logic
  generic map(
    input_clk => input_clk,
    bus_clk   => bus_clk
  )
  port map
  (
    clk   => iCLK,
    reset => internal_reset,
    mode = >,
    data_in = >,
    scl => LCDscl,
    sda => LCDsda
  );
  -- Process declarations
  
end Behavioral;