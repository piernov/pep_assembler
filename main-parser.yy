%language "c++"
%skeleton "lalr1.cc" /* -*- C++ -*- */
%defines
%define api.token.constructor
%define api.value.type variant
//%define parse.assert

//%define parse.trace
//%define parse.error verbose

%locations

%code requires // *.hh
{
#include <string>
#include <memory>
#include "translator.h"

// Tell Flex the lexer's prototype ...
# define YY_DECL \
  yy::parser::symbol_type yylex (Translator &translator)
}

%code
{
// ... and declare it for the parser's sake.
YY_DECL;
}

%param { Translator& translator }

%define api.token.prefix {TOK_}
%token END  0  "end of file"
%token <std::string> LABEL
%token REGISTER
%token EQUAL COMMA DOT COLON HASH LBRACKET RBRACKET
%token <int> NUMBER HEXADECIMAL
%token WHITESPACE NEWLINE

%token ADCS ADDS ANDS ASRS BICS CMP CMN EORS LDR LSLS LSRS
%token MOVS MULS MVNS ORRS RORS RSBS SBCS STR SUBS TST

%token B
%token EQ NE CS HS CC LO MI PL VS VC HI LS GE LT GT LE AL

%type <int> number
%type <int> register
%type <int> immediate
%type <uint16_t> instruction
%type <uint8_t> condition
%type <std::string> label

%start program

%%

indent
   : // Empty
   | indent WHITESPACE
   ;

separator
   : COMMA indent
   ;

register
   : REGISTER NUMBER
	{ $$ = $2; }
   ;

// See A7.3
condition
   : EQ
	{ $$ = 0; }
   | NE
	{ $$ = 1; }
   | CS
	{ $$ = 2; }
   | CC
	{ $$ = 3; }
   | MI
	{ $$ = 4; }
   | PL
	{ $$ = 5; }
   | VS
	{ $$ = 6; }
   | VC
	{ $$ = 7; }
   | HI
	{ $$ = 8; }
   | LS
	{ $$ = 9; }
   | GE
	{ $$ = 10; }
   | LT
	{ $$ = 11; }
   | GT
	{ $$ = 12; }
   | LE
	{ $$ = 13; }

/** Undefined for B
   | AL
	{ $$ = 14; }
 */
   ;

number
   : NUMBER
	{ $$ = $1; }
   | HEXADECIMAL
	{ $$ = $1; }
   ;

immediate
   : HASH number
	{ $$ = $2; }
   ;

label
   : B LABEL
	{ $$ = $2; }
   | LABEL
	{ $$ = $1; }
   ;

instruction
// Class A
   : LSLS WHITESPACE indent register separator register separator immediate // IMM5
	{ $$ = (0 << 11) + ($8 << 6) + ($6 << 3) + $4; }
   | LSRS WHITESPACE indent register separator register separator immediate // IMM5
	{ $$ = (1 << 11) + ($8 << 6) + ($6 << 3) + $4; }
   | ASRS WHITESPACE indent register separator register separator immediate // IMM5
	{ $$ = (2 << 11) + ($8 << 6) + ($6 << 3) + $4; }
   | ADDS WHITESPACE indent register separator register separator register
	{ $$ = (3 << 11) + (0 << 9) + ($8 << 6) + ($6 << 3) + $4; }
   | SUBS WHITESPACE indent register separator register separator register
	{ $$ = (3 << 11) + (1 << 9) + ($8 << 6) + ($6 << 3) + $4; }
//   | ADDS WHITESPACE indent register separator register separator immediate // IMM3
//	{ $$ = (3 << 11) + (2 << 9) + ($8 << 6) + ($6 << 3) + $4; }
   | MOVS WHITESPACE indent register separator immediate // IMM8
	{ $$ = (1 << 13) + (0 << 11) + ($4 << 8) + $6; }

// Class B
   | ANDS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (0 << 6) + ($6 << 3) + $4; }
   | EORS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (1 << 6) + ($6 << 3) + $4; }
   | LSLS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (2 << 6) + ($6 << 3) + $4; }
   | LSRS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (3 << 6) + ($6 << 3) + $4; }
   | ASRS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (4 << 6) + ($6 << 3) + $4; }
   | ADCS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (5 << 6) + ($6 << 3) + $4; }
   | SBCS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (6 << 6) + ($6 << 3) + $4; }
   | RORS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (7 << 6) + ($6 << 3) + $4; }
   | TST WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (8 << 6) + ($6 << 3) + $4; }
   | RSBS WHITESPACE indent register separator register separator immediate // IMM0
	{ $$ = (16 << 10) + (9 << 6) + ($6 << 3) + $4; }
   | CMP WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (10 << 6) + ($6 << 3) + $4; }
   | CMN WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (11 << 6) + ($6 << 3) + $4; }
   | ORRS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (12 << 6) + ($6 << 3) + $4; }
   | MULS WHITESPACE indent register separator register separator register // $5 == $9
	{ $$ = (16 << 10) + (13 << 6) + ($6 << 3) + $4; }
   | BICS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (14 << 6) + ($6 << 3) + $4; }
   | MVNS WHITESPACE indent register separator register
	{ $$ = (16 << 10) + (15 << 6) + ($6 << 3) + $4; }


// Class C
   | LDR WHITESPACE indent register separator LBRACKET register separator immediate RBRACKET // IMM5
	{ $$ = (3 << 13) + (1 << 11) + ($9 << 6) + ($7 << 3) + $4; }
   | LDR WHITESPACE indent register separator LBRACKET register RBRACKET // No offset
	{ $$ = (3 << 13) + (1 << 11) + ($7 << 3) + $4; }
   | STR WHITESPACE indent register separator LBRACKET register separator immediate RBRACKET // IMM5
	{ $$ = (3 << 13) + (0 << 11) + ($9 << 6) + ($7 << 3) + $4; }
   | STR WHITESPACE indent register separator LBRACKET register RBRACKET // No offset
	{ $$ = (3 << 13) + (0 << 11) + ($7 << 3) + $4; }

// Class D
   | B condition WHITESPACE indent label
	{ $$ = (13 << 12) + ($2 << 8) + translator.generateOffset($5); }
   | B WHITESPACE indent immediate // IMM11 Unconditional branch
	{ $$ = (24 << 11) + $4; }
   ;

line
   :
   | instruction
	{ translator.addInstruction($1); }
   | label COLON
	{ printf("Label: %s\n", $1.c_str()); translator.addLabel($1); }
   ;

program
   : indent line indent
   | program NEWLINE indent line indent
   ;

%%

// Mandatory error function
void yy::parser::error(const yy::parser::location_type& loc, const std::string& msg) {
	std::cerr << loc << ": " << msg << std::endl;
}

int main(int argc, char **argv) {
	std::shared_ptr<Printer> printer = std::make_shared<HexPrinter>();
	Translator translator(printer);
	yy::parser parser(translator);
	
	auto ret = parser.parse();
	if (!ret)
		ret = translator.fillBranchOffsets();
	translator.printAll();
	return ret;
}
