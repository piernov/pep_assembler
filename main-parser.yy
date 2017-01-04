/**
 * (subset of) ARM v7-M Thumb UAL parser
 *
 * piernov <piernov@piernov.org>
 */

%language "c++" // Declares a C++ Bison parser
%skeleton "lalr1.cc" // Using the C++ skeleton
%defines
%define api.token.constructor
%define api.value.type variant

//%define parse.assert
//%define parse.trace
//%define parse.error verbose

%code requires // *.hh
{
#include <string>
#include <memory>
#include "translator.h"

// Tell Flex the lexer's prototype ...
# define YY_DECL \
  yy::parser::symbol_type yylex(Translator &translator)
}

%code
{
// ... and declare it for the parser's sake.
YY_DECL;
}

%param { Translator& translator }

%define api.token.prefix {TOK_}
%token END  0  "end of file"

// Any string which could be a label
%token <std::string> LABEL

// Register prefix 'r'
%token REGISTER

// Punctuation
%token EQUAL COMMA DOT COLON HASH LBRACKET RBRACKET

// Numbers in decimal/hexadecimal bases
%token <int> NUMBER HEXADECIMAL

// Whitespaces
%token WHITESPACE NEWLINE

// Instructions
%token ADCS ADDS ANDS ASRS BICS CMP CMN EORS LDR LSLS LSRS
%token MOVS MULS MVNS ORRS RORS RSBS SBCS STR SUBS TST
%token B

// Conditions
%token EQ NE CS HS CC LO MI PL VS VC HI LS GE LT GT LE AL

%type <int> number
%type <int> register
%type <int> immediate
%type <uint16_t> instruction
%type <uint8_t> condition
%type <std::string> label

%start program

%%

// Indentation, either nothing or a series of whitespaces
// Does not handle tabulations for now
indent
   : // Empty
   | indent WHITESPACE
   ;

// Instructions' parameters separator
separator
   : COMMA indent
   ;

// Register-type instruction's parameter
register
   : REGISTER NUMBER
	{ $$ = $2; } // Keep the register number
   ;

// Conditions for conditional branching instruction B
// See A7.3 in ARM v7-M Architecture Reference Manual
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

// Numbers in decimal/hexadecimal bases
number
   : NUMBER
	{ $$ = $1; }
   | HEXADECIMAL
	{ $$ = $1; }
   ;

// Immediate-type instructions parameter, '#' symbol followed by a number (decimal/hexadecimal)
immediate
   : HASH number
	{ $$ = $2; }
   ;

// Label string for declaration and usage
label
   : B LABEL // Match label beginning with a B, workaround for conflict with the B instruction
	{ $$ = $2; }
   | LABEL // Match label not beginning with a B
	{ $$ = $1; }
   ;

// Instructions supported by our architecture
// Translate them to machine code
// Does not check the immediate size yet, programmer's responsibility
instruction
// Class A — Shift, add, sub, mov
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
//   | ADDS WHITESPACE indent register separator register separator immediate // IMM3, apparently removed from the list of instructions to be implemented…
//	{ $$ = (3 << 11) + (2 << 9) + ($8 << 6) + ($6 << 3) + $4; }
   | MOVS WHITESPACE indent register separator immediate // IMM8
	{ $$ = (1 << 13) + (0 << 11) + ($4 << 8) + $6; }

// Class B — Data processing
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


// Class C — Load/Store
   | LDR WHITESPACE indent register separator LBRACKET register separator immediate RBRACKET // IMM5 offset
	{ $$ = (3 << 13) + (1 << 11) + ($9 << 6) + ($7 << 3) + $4; }
   | LDR WHITESPACE indent register separator LBRACKET register RBRACKET // No offset = 0
	{ $$ = (3 << 13) + (1 << 11) + ($7 << 3) + $4; }
   | STR WHITESPACE indent register separator LBRACKET register separator immediate RBRACKET // IMM5 offset
	{ $$ = (3 << 13) + (0 << 11) + ($9 << 6) + ($7 << 3) + $4; }
   | STR WHITESPACE indent register separator LBRACKET register RBRACKET // No offset = 0
	{ $$ = (3 << 13) + (0 << 11) + ($7 << 3) + $4; }

// Class D — Branch
   | B condition WHITESPACE indent label // Conditional branch
	{ $$ = (13 << 12) + ($2 << 8) + translator.generateOffset($5); }
   | B WHITESPACE indent immediate // IMM11 Unconditional branch
	{ $$ = (24 << 11) + $4; }
   ;

line
   : // Empty line
   | instruction
	{ translator.addInstruction($1); }
   | label COLON // Label declaration
	{ translator.addLabel($1); }
   ;

program
   : indent line indent // A program line can have leading/trailing whitespaces
   | program NEWLINE indent line indent // One instruction/label declaration per line
   ;

%%

// Error reporting function
void yy::parser::error(const std::string& msg) {
	std::cerr << msg << std::endl;
}

int main(int argc, char **argv) {
	std::shared_ptr<Printer> printer = std::make_shared<LogisimPrinter>(); // Printer class to use for generating the machine code
	Translator translator(printer);
	yy::parser parser(translator);
	
	auto ret = parser.parse(); // Actually parse the standard input
	if (!ret) {
		ret = translator.fillBranchOffsets(); // Generate branch instruction's offset for post-declared labels
		translator.printAll(); // And print the resulting machine code to standard output
	}
	return ret;
}
