%language "c++"
%skeleton "lalr1.cc" /* -*- C++ -*- */
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.assert

//%define parse.trace
%define parse.error verbose

%locations

%code requires // *.hh
{
#include <string>
#include <bitset>
#include <iomanip>
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
%token EQUAL COMMA DOT COLON
%token <int> NUMBER HEXADECIMAL
%token WHITESPACE NEWLINE
%token S

%token ADC ADD AND ASR B BIC CMP CMN EOR LDR LSL
%token LSR MOV MUL MVN ORR ROR SBC STR SUB TST

%type <int> number
%type <int> register
%type <int> immediate

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

number
   : NUMBER
	{ $$ = $1; }
   | HEXADECIMAL
	{ $$ = $1; }
   ;

immediate
   : EQUAL number
	{ $$ = $2; }
   ;

instruction
   : LSL S WHITESPACE indent register separator register separator immediate
	{
		int op = ($9 << 6) + ($7 << 3) + $5;
		int a = op >> 8;
		int b = op & 0xFF;
		std::cout << "0x" << std::hex << std::setfill('0') << std::setw(2) << a << " ";
		std::cout << "0x" << std::hex << std::setfill('0') << std::setw(2) << b << std::endl;
	}
   | LSR S WHITESPACE indent register separator register separator immediate
   ;

line
   : indent instruction
   | LABEL
   ;

program
   : indent // Empty or whitespaces
   | line
   | line NEWLINE program
   ;

%%

// Mandatory error function
void yy::parser::error(const yy::parser::location_type& loc, const std::string& msg) {
	std::cerr << loc << ": " << msg << std::endl;
}

int main(int argc, char **argv) {
	Translator translator;
	yy::parser parser(translator);
	
	return parser.parse();
}
