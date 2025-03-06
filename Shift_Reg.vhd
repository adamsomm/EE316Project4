library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use ieee.std_logic_unsigned.all;

entity Shift_Reg is
	GENERIC (
		CONSTANT sr_depth : integer := 8);     
	port(	
		clock:		in std_logic;
		reset :		in std_logic;
		en: 			in std_logic;
		sr_in:		in std_logic_vector(3 downto 0);
		sr_out:		out std_logic_vector(sr_depth-1 downto 0) :=(others => '0')
	);
end Shift_Reg;

----------------------------------------------------

architecture behv of Shift_Reg is
	signal sr : std_logic_vector(sr_depth - 1 downto 0) := (others => '0');


	 
begin

	process(clock)
	begin
		if (rising_edge(clock)) then
			if reset = '1' then
				sr <= (others => '0');
			elsif en = '1' then
				sr <= sr_in & sr(sr_depth-1 downto 4);
			end if;
		end if;
	end process;
	
	sr_out <= sr;

end behv;
