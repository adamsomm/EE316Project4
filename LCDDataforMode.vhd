library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity LCDDataSelect is
  port (
    clk      : in std_logic;
    reset    : in std_logic;
    busy     : in std_logic := '0';
    data_in  : in std_logic_vector(127 downto 0);
    data_out : out std_logic_vector(7 downto 0) := (others => '0')
  );
end LCDDataSelect;

architecture Behavioral of LCDDataSelect is
  type data2lcd is array (0 to 4, 0 to 79) of std_logic_vector(8 downto 0);
  constant lcd_chars : data2lcd := (
  ('1' & X"47", '1' & X"41", '1' & X"4D", '1' & X"45", '1' & X"20", '1' & X"4F", '1' & X"56", '1' & X"45", '1' & X"52", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20"), --"GAME OVER" - done 11

  ('1' & X"57", '1' & X"65", '1' & X"6C", '1' & X"20", '1' & X"64", '1' & X"6F", '1' & X"6E", '1' & X"65", '1' & X"21", '1' & X"20", '1' & X"59",
  '1' & X"6F", '1' & X"75", '1' & X"20", '1' & X"68", '1' & X"61", '1' & X"76", '1' & X"65", '1' & X"20", '1' & X"73", '1' & X"6F", '1' & X"6C",
  '1' & X"76", '1' & X"65", '1' & X"64", '1' & X"20", '1' & WINCOUNThex, '1' & X"20", '1' & X"70", '1' & X"75", '1' & X"7A", '1' & X"7A", '1' & X"6C",
  '1' & X"65", '1' & X"73", '1' & X"20", '1' & X"6F", '1' & X"75", '1' & X"74", '1' & X"20", '1' & X"6F", '1' & X"66", '1' & GAMECOUNThex), -- "Well done! You have solved N puzzles out of M" - 43

  ('1' & X"53", '1' & X"6F", '1' & X"72", '1' & X"79", '1' & X"21", '1' & X"20", '1' & X"54", '1' & X"68", '1' & X"65", '1' & X"20", '1' & X"63",
  '1' & X"6F", '1' & X"72", '1' & X"72", '1' & X"65", '1' & X"63", '1' & X"74", '1' & X"20", '1' & X"77", '1' & X"6F", '1' & X"72", '1' & X"64",
  '1' & X"20", '1' & X"77", '1' & X"61", '1' & X"73", '1' & X"20",
  '1' & data(127 downto 120), '1' & data(119 downto 112), '1' & data(111 downto 104), '1' & data(103 downto 96), '1' & data(95 downto 88),
  '1' & data(87 downto 80), '1' & data(79 downto 72), '1' & data(71 downto 64), '1' & data(63 downto 56), '1' & data(55 downto 48), '1' & data(47 downto 40),
  '1' & data(39 downto 32), '1' & data(31 downto 24), '1' & data(23 downto 16), '1' & data(15 downto 8), '1' & data(7 downto 0),
  '1' & X"2E", '1' & X"20", '1' & X"59", '1' & X"6F", '1' & X"75", '1' & X"20", '1' & X"68", '1' & X"61", '1' & X"76", '1' & X"65", '1' & X"20", '1' & X"73",
  '1' & X"6F", '1' & X"6C", '1' & X"76", '1' & X"65", '1' & X"64", '1' & X"20", '1' & WINCOUNThex, '1' & X"20", '1' & X"70", '1' & X"75", '1' & X"7A", '1' & X"7A", '1' & X"6C",
  '1' & X"65", '1' & X"73", '1' & X"20", '1' & X"6F", '1' & X"75", '1' & X"74", '1' & X"20", '1' & X"6F", '1' & X"66", '1' & X"20", '1' & GAMECOUNThex), -- "Sorry! The correct word was XXXXXXXXXXXXXXXX. You have solved N puzzles out of M" - 79

  ('1' & data(127 downto 120), '1' & data(119 downto 112), '1' & data(111 downto 104), '1' & data(103 downto 96), '1' & data(95 downto 88),
  '1' & data(87 downto 80), '1' & data(79 downto 72), '1' & data(71 downto 64), '1' & data(63 downto 56), '1' & data(55 downto 48), '1' & data(47 downto 40),
  '1' & data(39 downto 32), '1' & data(31 downto 24), '1' & data(23 downto 16), '1' & data(15 downto 8), '1' & data(7 downto 0)), -- word - XXXXXXXXXXXXXXXX - done 16

  ('1' & X"4E", '1' & X"65", '1' & X"77", '1' & X"20", '1' & X"47", '1' & X"61", '1' & X"6D", '1' & X"65", '1' & X"3F", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20"), -- "New Game?" - done 11 
  ('0' & X"01", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20", '1' & X"20")--clear
  );

  signal LCD_EN         : std_logic := '0';
  signal LCD_RS         : std_logic := '0';
  signal RS             : std_logic := '0';
  signal LCD_RW         : std_logic := '0';
  signal LCD_BL         : std_logic := '1';
  signal data           : std_logic_vector(7 downto 0);
  signal counter        : integer := 0;
  signal LCD_DATA       : std_logic_vector(3 downto 0);
  signal byteSel        : integer range 1 to 89 := 1;
  signal oldBusy        : std_logic;
  signal dataCount      : integer range 1 to 6         := 1;
  signal prevDataCount  : integer range 1 to 6         := 1;
  signal MODE           : std_logic_vector(2 downto 0) := "000";
  signal scroll_counter : integer                      := 0;
  signal scroll_delay   : integer                      := 2500; -- Adjust for smoother or faster scroll
  signal GAMECOUNT      : integer                      := 0;
  signal WINCOUNT       : integer                      := 0;
  signal WINCOUNThex    : std_logic_vector(7 downto 0) := "00";
  signal GAMECOUNThex   : std_logic_vector(7 downto 0) := "00";

begin

  LCD_RW   <= '0';
  LCD_BL   <= '1';
  data_out <= LCD_DATA & LCD_BL & LCD_EN & LCD_RW & LCD_RS;

  process (clk, reset)
  begin
    if (reset = '1') then
      byteSel        <= 1;
      dataCount      <= 1;
      prevDataCount  <= 1;
      oldBusy        <= '0';
      LCD_RS         <= '0';
      scroll_counter <= 0;
    elsif rising_edge(clk) then
      oldBusy <= busy;
      case prevDataCount is
        when 1 =>
          LCD_EN   <= '0';
          LCD_DATA <= data(7 downto 4);
          LCD_RS   <= RS;
        when 2 =>
          LCD_EN   <= '1';
          LCD_DATA <= data(7 downto 4);
          LCD_RS   <= RS;
        when 3 =>
          LCD_EN   <= '0';
          LCD_DATA <= data(7 downto 4);
          LCD_RS   <= RS;
        when 4 =>
          LCD_EN   <= '0';
          LCD_DATA <= data(3 downto 0);
          LCD_RS   <= RS;
        when 5 =>
          LCD_EN   <= '1';
          LCD_DATA <= data(3 downto 0);
          LCD_RS   <= RS;
        when 6 =>
          LCD_EN   <= '0';
          LCD_DATA <= data(3 downto 0);
          LCD_RS   <= RS;
        when others =>
          LCD_EN   <= '0';
          LCD_DATA <= data(7 downto 4);
          LCD_RS   <= RS;
      end case;

      if oldBusy = '1' and busy = '0' then
        if dataCount < 6 then
          dataCount <= dataCount + 1;
        else
          dataCount <= 1;
        end if;
        prevDataCount <= dataCount;
        if dataCount = 1 and prevDataCount = 6 then
          if byteSel < 25 then
            byteSel <= byteSel + 1;
            --LCD_RS <= RS; bad, updates 1 cycle late 
          elsif byteSel > 25 and MODE = ("110" or "101") then --win or lose
            byteSel <= byteSel + 1;
            if MODE = "101" and byteSel > 88 then
              byteSel <= 89;
              if scroll_counter < scroll_delay then
                scroll_counter <= scroll_counter + 1;
                data           <= X"00";
                RS             <= '0';
              else
                scroll_counter <= 0; -- Reset counter
                byteSel        <= 89;
              end if;
            elsif MODE = "110" and byteSel > 52 then
              byteSel <= 89;
              if scroll_counter < scroll_delay then
                scroll_counter <= scroll_counter + 1;
                data           <= X"00";
                RS             <= '0';
              else
                scroll_counter <= 0; -- Reset counter
                byteSel        <= 89;
              end if;
            end if;
          else
            byteSel <= 9; -- Reset to 1 (back to the start)
          end if;

        end if;
      end if;
    end if;
  end process;
  process (MODE, byteSel)
    variable mode_index : integer := 0;
  begin
    case MODE is
      when "111"  => mode_index  := 1; -- game over 
      when "110"  => mode_index  := 0; -- win
      when "101"  => mode_index  := 3; -- loss
      when "001"  => mode_index  := 2; -- active game
      when "000"  => mode_index  := 5; -- New Game
      when others => mode_index := 4;
    end case;
    -- Select data based on byteSel value
    case byteSel is
        -- Initialization commands
      when 1 => data <= X"30";
        RS             <= '0'; -- 4 bit mode select
      when 2 => data <= X"30";
        RS             <= '0'; -- 4 bit mode select
      when 3 => data <= X"30";
        RS             <= '0'; -- 4 bit mode select
      when 4 => data <= X"02";
        RS             <= '0'; -- Initialize 4-bit mode
      when 5 => data <= X"28";
        RS             <= '0';
      when 6 => data <= X"01";
        RS             <= '0';
      when 7 => data <= X"0E";
        RS             <= '0';
      when 8 => data <= X"06";
        RS             <= '0';
      when 9 => data <= X"80";
        RS             <= '0';

        -- Display messages (reverse order from 127 downto 0)
      when 10 to 88 =>
        RS   <= lcd_chars(mode_index, byteSel - 10)(8);
        data <= lcd_chars(mode_index, byteSel - 10)(7 downto 0);
      when 89 =>
        RS   <= '0';
        data <= X"18";

      when others => data <= X"28";
        RS                  <= '0'; -- Default command
    end case;
  end process;

  process (WINCOUNT, GAMECOUNT)
  begin
    WINCOUNThex  <= std_logic_vector(to_unsigned(30 + WINCOUNT, WINCOUNThex'length));
    GAMECOUNThex <= std_logic_vector(to_unsigned(30 + GAMECOUNT, GAMECOUNThex'length));
  end process;

end Behavioral;
