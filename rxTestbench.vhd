library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopLevel_tb is
end;

architecture bench of TopLevel_tb is
  -- Clock period for 250 MHz clock (4 ns period)
  constant clk_period : time := 8 ns;

  -- PS/2 clock period (typically 10-16.7 kHz, ~60-100 us)
  constant ps2_clk_period : time := 60 us;

  -- Signals
  signal iCLK : std_logic := '0';
  signal reset : std_logic := '1';
  signal ps2_clk : std_logic := '1'; -- PS/2 clock (idle high)
  signal ps2_data : std_logic := '1'; -- PS/2 data (idle high)
  signal LCDsda : std_logic;
  signal LCDscl : std_logic;
  signal Sevsda : std_logic;
  signal Sevscl : std_logic;
  signal RX_in : std_logic;
  signal regPulse : std_logic;
  signal TX_out : std_logic;

  -- Test data: Simulate key presses (e.g., keycode for 'A' is 0x1C, keycode for 'B' is 0x32)
  constant keycode_A : std_logic_vector(7 downto 0) := x"1C"; -- Keycode for 'A'
  constant keycode_B : std_logic_vector(7 downto 0) := x"32"; -- Keycode for 'B'
  signal parity_bit : std_logic;

begin

  -- Instantiate the TopLevel entity
  TopLevel_inst : entity work.TopLevel
  port map (
    iCLK => iCLK,
    reset => reset,
    ps2_clk => ps2_clk,
    ps2_data => ps2_data,
    LCDsda => LCDsda,
    LCDscl => LCDscl,
    Sevsda => Sevsda,
    Sevscl => Sevscl,
    RX_in => RX_in,
    regPulse => regPulse,
    TX_out => TX_out
  );

  -- Clock generation process (250 MHz)
  clk_process : process
  begin
    while now < 1000 ms loop -- Simulate for 1000 ms
      iCLK <= '0';
      wait for clk_period / 2;
      iCLK <= '1';
      wait for clk_period / 2;
    end loop;
    wait;
  end process;

  -- Reset generation process
  reset_process : process
  begin
    reset <= '1';
    wait for 100 ns; -- Hold reset for 100 ns
    reset <= '0';
    wait;
  end process;

  -- PS/2 Keyboard Simulation Process
  ps2_process : process
    procedure send_ps2_byte(data : in std_logic_vector(7 downto 0)) is
    begin
      -- Calculate parity bit (odd parity)
      parity_bit <= not (data(0) xor data(1) xor data(2) xor data(3) xor
                         data(4) xor data(5) xor data(6) xor data(7));

      -- Start bit (0)
      ps2_data <= '0';
      wait for ps2_clk_period / 2;
      ps2_clk <= '0';
      wait for ps2_clk_period / 2;
      ps2_clk <= '1';

      -- Data bits (LSB first)
      for i in 0 to 7 loop
        ps2_data <= data(i);
        wait for ps2_clk_period / 2;
        ps2_clk <= '0';
        wait for ps2_clk_period / 2;
        ps2_clk <= '1';
      end loop;

      -- Parity bit
      ps2_data <= parity_bit;
      wait for ps2_clk_period / 2;
      ps2_clk <= '0';
      wait for ps2_clk_period / 2;
      ps2_clk <= '1';

      -- Stop bit (1)
      ps2_data <= '1';
      wait for ps2_clk_period / 2;
      ps2_clk <= '0';
      wait for ps2_clk_period / 2;
      ps2_clk <= '1';

      -- Wait for a short time before next transmission
      wait for ps2_clk_period * 2;
    end procedure;
  begin
    wait for 200 ns; -- Wait for reset to complete

    -- Simulate first key press (send keycode for 'A')
    send_ps2_byte(keycode_A);

    -- Simulate first key release (send break code 0xF0 followed by keycode for 'A')
    send_ps2_byte(x"F0"); -- Break code
    send_ps2_byte(keycode_A); -- Keycode for 'A'

    -- Wait for a short time between key presses
    wait for ps2_clk_period * 10;

    -- Simulate second key press (send keycode for 'B')
    send_ps2_byte(keycode_B);

    -- Simulate second key release (send break code 0xF0 followed by keycode for 'B')
    send_ps2_byte(x"F0"); -- Break code
    send_ps2_byte(keycode_B); -- Keycode for 'B'

    wait;
  end process;

end;