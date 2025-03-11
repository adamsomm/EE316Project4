library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Shift_Reg is
    GENERIC (
        sr_depth : integer := 135;  -- Depth of the shift register
        input_width : integer := 8   -- Width of the input data
    );
    port(
        clock:  in std_logic;
        reset:  in std_logic;
        en:     in std_logic;
        sr_in:  in std_logic_vector(input_width - 1 downto 0);
        sr_out: out std_logic_vector(sr_depth - 1 downto 0)
    );
end Shift_Reg;

architecture behv of Shift_Reg is
    signal sr : std_logic_vector(sr_depth - 1 downto 0) := (others => '0');
begin

    process(clock)
    begin
        if (rising_edge(clock)) then
            if reset = '1' then
                sr <= (others => '0');  -- Synchronous reset
            elsif en = '1' then
                sr <= sr(sr_depth - input_width - 1 downto 0) & sr_in;  -- Shift toward MSB
            end if;
        end if;
    end process;

    sr_out <= sr;  -- Output the shift register value

end behv;