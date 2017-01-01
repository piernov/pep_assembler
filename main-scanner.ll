%{
//#include <stdio.h>
//#include "main.tab.h"
#include "main-parser.hh"

static yy::location loc;
%}

%option noyywrap nounput batch debug
%option caseless

%{
  // Code run each time yylex is called.
//  loc.step ();
%}

DECNUM		[0-9]+
WS		[ \t]+
LETTER		[_a-zA-Z]+
HEXNUM		[a-fA-F0-9]+

%%
R		{ return yy::parser::make_REGISTER(loc); }
S		{ return yy::parser::make_S(loc); }


adc		{ return yy::parser::make_ADC(loc); }
add		{ return yy::parser::make_ADD(loc); }
and		{ return yy::parser::make_AND(loc); }
asr		{ return yy::parser::make_ASR(loc); }
b		{ return yy::parser::make_B(loc); }
bic		{ return yy::parser::make_BIC(loc); }
cmp		{ return yy::parser::make_CMP(loc); }
cmn		{ return yy::parser::make_CMN(loc); }
eor		{ return yy::parser::make_EOR(loc); }
ldr		{ return yy::parser::make_LDR(loc); }
lsl		{ return yy::parser::make_LSL(loc); }
lsr		{ return yy::parser::make_LSR(loc); }
mov		{ return yy::parser::make_MOV(loc); }
mul		{ return yy::parser::make_MUL(loc); }
mvn		{ return yy::parser::make_MVN(loc); }
orr		{ return yy::parser::make_ORR(loc); }
ror		{ return yy::parser::make_ROR(loc); }
sbc		{ return yy::parser::make_SBC(loc); }
str		{ return yy::parser::make_STR(loc); }
sub		{ return yy::parser::make_SUB(loc); }
tst		{ return yy::parser::make_TST(loc); }

{LETTER}:	{ std::string str(yytext); str.pop_back(); return yy::parser::make_LABEL(str, loc); }


0x{HEXNUM}	{ return yy::parser::make_HEXADECIMAL(std::stoul(yytext, nullptr, 0), loc); }
{DECNUM}	{ return yy::parser::make_NUMBER(atoi(yytext), loc);}

,		{ return yy::parser::make_COMMA(loc); }
\.		{ return yy::parser::make_DOT(loc); }
:		{ return yy::parser::make_COLON(loc); }
=		{ return yy::parser::make_EQUAL(loc); }

{WS}		{ return yy::parser::make_WHITESPACE(loc); }
\n		{ return yy::parser::make_NEWLINE(loc); }
<<EOF>>		{ return yy::parser::make_END(loc); }
%%
