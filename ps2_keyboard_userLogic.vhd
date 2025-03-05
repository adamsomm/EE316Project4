library ieee;
use ieee.std_logic_1164.all;

entity ps2_keyboard_userLogic is
  port (
    clk          : in std_logic;
    ps2_clk      : in std_logic; -- PS/2 clock input
    ps2_data     : in std_logic; -- PS/2 data input
    final_data   : out std_logic_vector(7 downto 0) -- Processed key code
    newDataPulse : out std_logic := '0';
  );
end ps2_keyboard_userLogic;

architecture behavior of ps2_keyboard_userLogic is

  -- Signals to connect with ps2_keyboard
  signal ps2_code     : std_logic_vector(7 downto 0);
  signal ps2_code_new : std_logic;

  -- Internal signals for managing key press detection
  signal old_data   : std_logic_vector(7 downto 0) := (others => '0');
  signal newFlag    : std_logic                    := '0';
  signal oldnewFlag : std_logic                    := '0';

begin

  -- Instantiate ps2_keyboard
  ps2_keyboard_inst : entity work.ps2_keyboard
    generic map(
      clk_freq              => 125_000_000, -- System clock frequency
      debounce_counter_size => 10 -- Adjusted for 125 MHz (5us debounce)
    )
    port map
    (
      clk          => clk,
      ps2_clk      => ps 2_clk,
      ps2_data     => ps2_data,
      ps2_code_new => ps2_code_new,
      ps2_code     => ps2_code
    );

  -- Process to handle F0 filtering and key press detection
  process (clk)
  begin
    if rising_edge(clk) then
      if ps2_code_new = '1' then
        -- Check for F0 followed by a valid key
        if old_data = x"F0" and ps2_code /= x"F0" then
          final_data   <= ps2_code; -- Update only on valid key
          newDataPulse <= '1';
        else
          newDataPulse <= '0';
        end if;

        -- Update old_data only after checking for F0
        old_data <= ps2_code;
      end if;
    end if;
  end process;

end behavior;
