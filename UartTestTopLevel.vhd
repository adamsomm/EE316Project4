library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartTestTopLevel is
  port (
    iclk     : in std_logic;
    reset    : in std_logic;
    tx       : out std_logic;
    rx       : in std_logic;
    ps2_clk  : in std_logic;
    ps2_data : in std_logic
   -- uart_pulse: in std_logic
  );
end UartTestTopLevel;

architecture behavior of UartTestTopLevel is
  component uart_user_logic
    port (
      tx_data   : in std_logic_vector(7 downto 0);
      tx_pulse  : in std_logic;
      iclk      : in std_logic;
      tx        : out std_logic;
      rx        : in std_logic;
      reset     : in std_logic
--      LCD_Data  : out std_logic_vector(127 downto 0);
--      Mode      : out std_logic_vector(2 downto 0);
--      Seven_seg : out std_logic
    );
  end component;
  component ps2_keyboard_to_ascii
    generic (
      clk_freq                  : integer := 125_000_000;
      ps2_debounce_counter_size : integer := 10
    );
    port (
      clk        : in std_logic;
      ps2_clk    : in std_logic;
      ps2_data   : in std_logic;
      ascii_new_pulse  : out std_logic;
      ascii_code : out std_logic_vector(7 downto 0)
    );
  end component;

  signal uart_data : std_logic_vector(7 downto 0);
  signal uart_pulse : std_logic;
begin

  -- Instantiate the Unit Under Test (UUT)
  uart_user_logic_inst : uart_user_logic
  port map
  (
    tx_data  => uart_data,
    tx_pulse => uart_pulse,
    iclk     => iclk,
    tx       => tx,
    rx       => rx,
    reset   => reset
    --   LCD_Data  => LCD_Data,
    --   Mode      => Mode,
    --   Seven_seg => Seven_seg
  );

  ps2_keyboard_to_ascii_inst : ps2_keyboard_to_ascii
  generic map(
    clk_freq                  => 125_000_000,
    ps2_debounce_counter_size => 10
  )
  port map
  (
    clk        => iclk,
    ps2_clk    => ps2_clk,
    ps2_data   => ps2_data,
    ascii_new_pulse  => uart_pulse,
    ascii_code => uart_data
  );
end architecture behavior;