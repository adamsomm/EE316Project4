library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity LCDDataSelect is
  port (
    clk      : in std_logic;
    reset    : in std_logic                      := '0';
    busy     : in std_logic                      := '0';
    data_in  : in std_logic_vector(127 downto 0) := X"68656C6C6F68656C6C6F68656C6C6F6F";
    data_out : out std_logic_vector(7 downto 0)  := (others => '0')
  );
end LCDDataSelect;

architecture Behavioral of LCDDataSelect is

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
  signal MODE           : std_logic_vector(2 downto 0) := "001";
  signal scroll_counter : integer                      := 0;
  signal scroll_delay   : integer                      := 2500; -- Adjust for smoother or faster scroll
  signal GAMECOUNT      : integer                      := 0;
  signal WINCOUNT       : integer                      := 0;
  signal WINCOUNThex    : std_logic_vector(7 downto 0) := X"00";
  signal GAMECOUNThex   : std_logic_vector(7 downto 0) := X"00";
  signal MODEprev       : std_logic_vector(2 downto 0);

  --  type GameOver is array (0 to 9) of std_logic_vector(8 downto 0);
  --  constant lcd_GameOver : GameOver := (
  --  ('0' & X"01", '1' & X"47", '1' & X"41", '1' & X"4D", '1' & X"45", '1' & X"20", '1' & X"4F", '1' & X"56", '1' & X"45", '1' & X"52") --"GAME OVER" - done 9
  --  );

  --  type Win is array (0 to 42) of std_logic_vector(8 downto 0);
  --  constant lcd_Win : Win := (
  --  ('1' & X"57", '1' & X"65", '1' & X"6C", '1' & X"20", '1' & X"64", '1' & X"6F", '1' & X"6E", '1' & X"65", '1' & X"21", '1' & X"20", '1' & X"59",
  --  '1' & X"6F", '1' & X"75", '1' & X"20", '1' & X"68", '1' & X"61", '1' & X"76", '1' & X"65", '1' & X"20", '1' & X"73", '1' & X"6F", '1' & X"6C",
  --  '1' & X"76", '1' & X"65", '1' & X"64", '1' & X"20", '1' & WINCOUNThex, '1' & X"20", '1' & X"70", '1' & X"75", '1' & X"7A", '1' & X"7A", '1' & X"6C",
  --  '1' & X"65", '1' & X"73", '1' & X"20", '1' & X"6F", '1' & X"75", '1' & X"74", '1' & X"20", '1' & X"6F", '1' & X"66", '1' & GAMECOUNThex) -- "Well done! You have solved N puzzles out of M" - 43
  --  );
  --  type Loss is array (0 to 78) of std_logic_vector(8 downto 0);
  --  constant lcd_Loss : Loss := (
  --  ('1' & X"53", '1' & X"6F", '1' & X"72", '1' & X"79", '1' & X"21", '1' & X"20", '1' & X"54", '1' & X"68", '1' & X"65", '1' & X"20", '1' & X"63",
  --  '1' & X"6F", '1' & X"72", '1' & X"72", '1' & X"65", '1' & X"63", '1' & X"74", '1' & X"20", '1' & X"77", '1' & X"6F", '1' & X"72", '1' & X"64",
  --  '1' & X"20", '1' & X"77", '1' & X"61", '1' & X"73", '1' & X"20",
  --  '1' & data_in(127 downto 120), '1' & data_in(119 downto 112), '1' & data_in(111 downto 104), '1' & data_in(103 downto 96), '1' & data_in(95 downto 88),
  --  '1' & data_in(87 downto 80), '1' & data_in(79 downto 72), '1' & data_in(71 downto 64), '1' & data_in(63 downto 56), '1' & data_in(55 downto 48), '1' & data_in(47 downto 40),
  --  '1' & data_in(39 downto 32), '1' & data_in(31 downto 24), '1' & data_in(23 downto 16), '1' & data_in(15 downto 8), '1' & data_in(7 downto 0),
  --  '1' & X"2E", '1' & X"20", '1' & X"59", '1' & X"6F", '1' & X"75", '1' & X"20", '1' & X"68", '1' & X"61", '1' & X"76", '1' & X"65", '1' & X"20", '1' & X"73",
  --  '1' & X"6F", '1' & X"6C", '1' & X"76", '1' & X"65", '1' & X"64", '1' & X"20", '1' & WINCOUNThex, '1' & X"20", '1' & X"70", '1' & X"75", '1' & X"7A", '1' & X"7A", '1' & X"6C",
  --  '1' & X"65", '1' & X"73", '1' & X"20", '1' & X"6F", '1' & X"75", '1' & X"74", '1' & X"20", '1' & X"6F", '1' & X"66", '1' & X"20", '1' & GAMECOUNThex) -- "Sorry! The correct word was XXXXXXXXXXXXXXXX. You have solved N puzzles out of M" - 79
  --  );
  ----  type Active is array (0 to 16) of std_logic_vector(8 downto 0);
  ----  constant lcd_Active : Active := (
  ----  ('0' & X"01", '1' & data_in(127 downto 120), '1' & data_in(119 downto 112), '1' & data_in(111 downto 104), '1' & data_in(103 downto 96), '1' & data_in(95 downto 88),
  ----  '1' & data_in(87 downto 80), '1' & data_in(79 downto 72), '1' & data_in(71 downto 64), '1' & data_in(63 downto 56), '1' & data_in(55 downto 48), '1' & data_in(47 downto 40),
  ----  '1' & data_in(39 downto 32), '1' & data_in(31 downto 24), '1' & data_in(23 downto 16), '1' & data_in(15 downto 8), '1' & data_in(7 downto 0)) -- word - XXXXXXXXXXXXXXXX - done 16
  ----  );
  --  type newGame is array (0 to 9) of std_logic_vector(8 downto 0);
  --  constant lcd_newGame : newGame := (
  --  ('0' & X"01", '1' & X"4E", '1' & X"65", '1' & X"77", '1' & X"20", '1' & X"47", '1' & X"61", '1' & X"6D", '1' & X"65", '1' & X"3F") -- "New Game?" - done 11 
  --  );

  type Active is array (0 to 15) of std_logic_vector(8 downto 0);
  signal lcd_Active : Active := (others => (others => '0')); -- Correct signal declaration
begin

  LCD_RW   <= '0';
  LCD_BL   <= '1';
  data_out <= LCD_DATA & LCD_BL & LCD_EN & LCD_RW & LCD_RS;

  process (clk)
  begin
    if rising_edge(clk) then

      lcd_Active(0)  <= '1' & data_in(127 downto 120);
      lcd_Active(1)  <= '1' & data_in(119 downto 112);
      lcd_Active(2)  <= '1' & data_in(111 downto 104);
      lcd_Active(3)  <= '1' & data_in(103 downto 96);
      lcd_Active(4)  <= '1' & data_in(95 downto 88);
      lcd_Active(5)  <= '1' & data_in(87 downto 80);
      lcd_Active(6)  <= '1' & data_in(79 downto 72);
      lcd_Active(7)  <= '1' & data_in(71 downto 64);
      lcd_Active(8)  <= '1' & data_in(63 downto 56);
      lcd_Active(9)  <= '1' & data_in(55 downto 48);
      lcd_Active(10) <= '1' & data_in(47 downto 40);
      lcd_Active(11) <= '1' & data_in(39 downto 32);
      lcd_Active(12) <= '1' & data_in(31 downto 24);
      lcd_Active(13) <= '1' & data_in(23 downto 16);
      lcd_Active(14) <= '1' & data_in(15 downto 8);
      lcd_Active(15) <= '1' & data_in(7 downto 0);
    end if;
  end process;
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
        MODEprev      <= MODE;
        if MODEprev /= MODE then
          byteSel <= 6;
        end if;
        if dataCount = 1 and prevDataCount = 6 then
          if byteSel < 25 then
            byteSel <= byteSel + 1;
            --LCD_RS <= RS; bad, updates 1 cycle late 
            --          elsif byteSel > 25 and MODE = ("110" or "101") then --win or lose
            --            byteSel <= byteSel + 1;
            --            if MODE = "101" and byteSel > 88 then
            --              byteSel <= 89;
            --              if scroll_counter < scroll_delay then
            --                scroll_counter <= scroll_counter + 1;
            --                data           <= X"00";
            --                RS             <= '0';
            --              else
            --                scroll_counter <= 0; -- Reset counter
            --                byteSel        <= 89;
            --              end if;
            --            elsif MODE = "110" and byteSel > 52 then
            --              byteSel <= 89;
            --              if scroll_counter < scroll_delay then
            --                scroll_counter <= scroll_counter + 1;
            --                data           <= X"00";
            --                RS             <= '0';
            --              else
            --                scroll_counter <= 0; -- Reset counter
            --                byteSel        <= 89;
            --              end if;
            --            end if;
          else
            byteSel <= 9; -- Reset to 1 (back to the start)
          end if;

        end if;
      end if;
    end if;
  end process;
  process (MODE, byteSel)
  begin
    -- Select data based on byteSel value
    case byteSel is
        -- Initialization commands
      when 1 =>
        data <= X"30";
        RS   <= '0'; -- 4 bit mode select
      when 2 =>
        data <= X"30";
        RS   <= '0'; -- 4 bit mode select
      when 3 =>
        data <= X"30";
        RS   <= '0'; -- 4 bit mode select
      when 4 =>
        data <= X"02";
        RS   <= '0'; -- Initialize 4-bit mode
      when 5 =>
        data <= X"28";
        RS   <= '0';
      when 6 =>
        data <= X"01";
        RS   <= '0';
      when 7 =>
        data <= X"0E";
        RS   <= '0';
      when 8 =>
        data <= X"06";
        RS   <= '0';
      when 9 =>
        data <= X"80";
        RS   <= '0';

        -- Display messages (reverse order from 127 downto 0)
      when 10 to 88 =>
        case MODE is
            --          when "111" => -- game over
            --            RS   <= lcd_GameOver(byteSel - 10)(8);
            --            data <= lcd_GameOver(byteSel - 10)(7 downto 0);
            --          when "110" => -- win
            --            RS   <= lcd_Win(byteSel - 10)(8);
            --            data <= lcd_Win(byteSel - 10)(7 downto 0);
            --          when "101" => -- loss
            --            RS   <= lcd_Loss(byteSel - 10)(8);
            --            data <= lcd_Loss(byteSel - 10)(7 downto 0);
          when "001" => -- word
            RS   <= lcd_Active(byteSel - 10)(8);
            data <= lcd_Active(byteSel - 10)(7 downto 0);
          when "000" => -- new game
            --            RS   <= lcd_newGame(byteSel - 10)(8);
            --            data <= lcd_newGame(byteSel - 10)(7 downto 0);
          when others =>
            RS   <= lcd_Active(byteSel - 10)(8);
            data <= lcd_Active(byteSel - 10)(7 downto 0);
        end case;

      when 89 =>
        RS   <= '0';
        data <= X"18";

      when others =>
        data <= X"28";
        RS   <= '0'; -- Default command
    end case;
  end process;
  process (WINCOUNT, GAMECOUNT)
  begin
    WINCOUNThex  <= std_logic_vector(to_unsigned(48 + WINCOUNT, WINCOUNThex'length));
    GAMECOUNThex <= std_logic_vector(to_unsigned(48 + GAMECOUNT, GAMECOUNThex'length));
  end process;

end Behavioral;
