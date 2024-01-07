library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity ROM is
    Port ( clock : in STD_LOGIC;
           RST : in STD_LOGIC;
           En : in STD_LOGIC;
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           JumpAdress : in std_logic_vector(15 downto 0); 
           BranchAdress : in std_logic_vector(15 downto 0);
           instruction : out STD_LOGIC_VECTOR (15 downto 0);
           PCinc : out STD_LOGIC_VECTOR (15 downto 0));
end ROM;

architecture Behavioral of ROM is
       
type tROM is array(0 to 31) of std_logic_vector(15 downto 0);
signal RomArr: tROM := (
      b"000_000_000_001_0_001",  --  x"0011"  add $1, $0, $0   -> initializeaza $1(contorul buclei) cu valoarea 0
      b"001_000_100_0000111",    --  x"2207"  addi $4, $0, 7   -> initialeaza $4 cu valoarea 7(nr de elemente tabloului din memorie)
      b"000_000_000_101_0_001",  --  x"0051"  add $5 $0, $0    -> initializeaza $5(variabila sum) cu 0 
      b"001_000_110_0000011",    --  x"2303"  addi $6, $0, 3   -> initializeaza $6 cu valoarea 3(ca scad trei din fiecare element din tablou)
      b"100_001_100_0000110",    --  x"8606"  beq $1, $4, 6   -> compara valoriile dintre $1(i) si $4(nr elemente), daca sunt egele face salt la instr 11 
      b"010_001_011_0000000",    --  x"4580"  lw $3, 0($1)     -> ia primul element din mem al cui adresa e valoarea in $1 si il pune in $3 
      b"000_011_000_011_1_011",  --  x"0C3b"  sll $3, $3, 1    -> face shiftare la stanga cu o pozitie si pune rezultat in $3
      b"000_011_110_011_0_010",  --  x"0F32"  sub $3, $6, $3   -> $3 = $3 - $6 face scadere
      b"000_101_011_101_0_001",  --  x"15d1"  add $5, $5, $3   -> $5 = $5 + $3 adauga la variabila sum  
      b"001_001_001_0000001",    -- x"2481"  addi $1, $1, 1    -> i = i+1 incrementeaza contorul buclei
      b"111_0000000000100",      -- x"E004"  j 4               -> face salt la begin loop (instr 4)
      b"011_000_101_0001010",    -- x"628A"  sw $5, 10($0)     -> pune variabila sum in mem
      b"010_000_111_0001010",    -- x"434A"  lw $7, 10($0)     -> il ia la $7 ca sa verifica daca a scris ok in mem
      others => x"0000"
      ); 
signal cnt: std_logic_vector(15 downto 0) := (others=>'0');
signal add: std_logic_vector(15 downto 0) := (others=>'0');
signal Mux1Output: std_logic_vector(15 downto 0) := (others=>'0');
signal Mux2Output: std_logic_vector(15 downto 0) := (others=>'0');
begin

   counter: process(clock)
      begin
        if rising_edge(clock) then
           if RST = '1' then 
               cnt<= x"0000";
           else if En = '1' then
               cnt <= Mux2Output;
        end if;
      end if;
    end if;
      end process;
      
     add <= cnt+x"0001";
      
     Mux1Output <= add when PCSrc = '0' else BranchAdress;
     Mux2Output <= Mux1Output when Jump = '0' else JumpAdress;
                  
     instruction <= RomArr(conv_integer(cnt));
     PCinc <= add;
      
end Behavioral;
