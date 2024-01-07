library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
Port( clk: in std_logic;
      btn: in std_logic_vector(4 downto 0);
      sw: in std_logic_vector(15 downto 0);
      led: out std_logic_vector(15 downto 0);
      an: out std_logic_vector(3 downto 0);
      cat: out std_logic_vector(6 downto 0));
end test_env;


architecture Behavioral of test_env is

component MPG is
   Port ( clock : in STD_LOGIC;
           input : in STD_LOGIC;
          Enable : out STD_LOGIC);
end component;

component SSD is
    Port ( clock : in STD_LOGIC;
           digs : in std_logic_vector (15 downto 0);
           catod : out STD_LOGIC_VECTOR (6 downto 0);
           anod : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component ROM is
    Port ( clock : in STD_LOGIC;
           RST : in STD_LOGIC;
           En : in STD_LOGIC;
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           JumpAdress : std_logic_vector(15 downto 0); 
           BranchAdress : std_logic_vector(15 downto 0);
           instruction : out STD_LOGIC_VECTOR (15 downto 0);
           PCinc : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component ID is
    Port ( RegWr : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (15 downto 0);
           RegDst : in STD_LOGIC;
           CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1: out STD_LOGIC_VECTOR(15 downto 0);
           RD2  : out STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0);
           func : out STD_LOGIC_VECTOR(2 downto 0);
           WD : inout STD_LOGIC_VECTOR(15 downto 0);
           sa : out STD_LOGIC);
end component;


component MainCtrl is
    Port ( Instr : in STD_LOGIC_VECTOR (15 downto 13);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR (1 downto 0);
           MemWrite : out STD_LOGIC;
           MemToReg : out STD_LOGIC;
           RegWr : out STD_LOGIC);
end component;

component EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           ALUSrc : in STD_LOGIC;
           Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           PC_plus : in STD_LOGIC_VECTOR(15 downto 0);
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR(2 downto 0);
           ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
           Zero : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR (15 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0));
end component;


component MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           EN : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR (15 downto 0));
end component;

signal digits, instr, pc, RD1, RD2, ext_imm, func_ext, sa_ext, ALUResIn, ALUResOut,
 WriteData, BrnAdd, MemData, JumpAddress: std_logic_vector(15 downto 0);
signal En, Reset: std_logic;
signal RegDst, ExtOp, ALUSrc, Branch,Jump, MemWrite, MemToReg, RegWr, sa, zero, PCSrc: std_logic;
signal ALUOp : STD_LOGIC_VECTOR (1 downto 0);
signal func, sel: std_logic_vector (2 downto 0);
begin

--------------------------------MIPS_16------------------------------------------------------------------
debouncer1: MPG port map (clock=>clk, input=>btn(0), enable=>En);
debouncer2: MPG port map (clock=>clk, input=>btn(1), enable=>Reset);
Instruction_Fetch: ROM port map (clk, Reset, En, Jump, PCSrc, JumpAddress, BrnAdd, instr, pc);
MainControl: MainCtrl port map (instr(15 downto 13), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemToReg, RegWr);
InstructionDecoder: ID port map (RegWr, instr, RegDst, clk, En, ExtOp, RD1, RD2, ext_imm, func, WriteData, sa);
Execution_unit: EX port map (RD1, RD2, ALUSrc, ext_imm, pc, sa, func, ALUOp, zero, ALUResIn, BrnAdd);
Memory: MEM port map (MemWrite, ALUResIn, RD2, clk, En, MemData, ALUResOut);
display: SSD port map (clock=>clk, digs=>digits,anod=>an,catod=>cat);


  PCSrc <= Branch and zero;
  WriteData <= ALUResOut when MemToReg ='0' else MemData; 
  JumpAddress <= pc(15 downto 13)&instr(12 downto 0);  
  
  
    sel <= sw(7 downto 5);
  MUX8_1: process(sel, instr, pc, RD1, RD2, WriteData, ext_imm, MemData, ALUResOut)
          begin
           case sel is
              when "000" => digits <= instr;
              when "001" => digits <= pc;
              when "010" => digits <= RD1;
              when "011" => digits <= RD2;
              when "100" => digits <= ext_imm;
              when "101" => digits <= ALUResOut;
              when "110" => digits <= MemData;
              when "111" => digits <= WriteData;
           end case;
         end process; 
                
           led(7) <= RegDst;
           led(6) <= ExtOP;
           led(5) <= ALUSrc;
           led(4) <= Branch;
           led(3) <= Jump;
           led(2) <= MemWrite;
           led(1) <= MemToReg;
           led(0) <= RegWr;
           led(9 downto 8) <= ALUOp;
end architecture;