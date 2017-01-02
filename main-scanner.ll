%{
#include "main-parser.hh"

static yy::location loc;
%}

%option noyywrap nounput batch debug
%option caseless

%{
  // Code run each time yylex is called.
//  loc.step ();
%}

%s B

DECNUM		[0-9]+
WS		[ \t]+
LETTER		[_a-zA-Z]
HEXNUM		[a-fA-F0-9]+

%%
R		{ return yy::parser::make_REGISTER(loc); }


adcs		{ return yy::parser::make_ADCS(loc); }
adds		{ return yy::parser::make_ADDS(loc); }
ands		{ return yy::parser::make_ANDS(loc); }
asrs		{ return yy::parser::make_ASRS(loc); }
bics		{ return yy::parser::make_BICS(loc); }
cmp		{ return yy::parser::make_CMP(loc); }
cmn		{ return yy::parser::make_CMN(loc); }
eors		{ return yy::parser::make_EORS(loc); }
ldr		{ return yy::parser::make_LDR(loc); }
lsls		{ return yy::parser::make_LSLS(loc); }
lsrs		{ return yy::parser::make_LSRS(loc); }
movs		{ return yy::parser::make_MOVS(loc); }
muls		{ return yy::parser::make_MULS(loc); }
mvns		{ return yy::parser::make_MVNS(loc); }
orrs		{ return yy::parser::make_ORRS(loc); }
rors		{ return yy::parser::make_RORS(loc); }
rsbs		{ return yy::parser::make_RSBS(loc); }
sbcs		{ return yy::parser::make_SBCS(loc); }
str		{ return yy::parser::make_STR(loc); }
subs		{ return yy::parser::make_SUBS(loc); }
tst		{ return yy::parser::make_TST(loc); }

b               { BEGIN(B); yymore(); return yy::parser::make_B(loc); } // Conditional branch, begin "B" start-condition

<B>{ // Conditions for branch inside "B" start-condition
eq		{ BEGIN(INITIAL); return yy::parser::make_EQ(loc); }
ne		{ BEGIN(INITIAL); return yy::parser::make_NE(loc); }
cs		{ BEGIN(INITIAL); return yy::parser::make_CS(loc); }
hs		{ BEGIN(INITIAL); return yy::parser::make_HS(loc); }
cc		{ BEGIN(INITIAL); return yy::parser::make_CC(loc); }
lo		{ BEGIN(INITIAL); return yy::parser::make_LO(loc); }
mi		{ BEGIN(INITIAL); return yy::parser::make_MI(loc); }
pl		{ BEGIN(INITIAL); return yy::parser::make_PL(loc); }
vs		{ BEGIN(INITIAL); return yy::parser::make_VS(loc); }
vc		{ BEGIN(INITIAL); return yy::parser::make_VC(loc); }
hi		{ BEGIN(INITIAL); return yy::parser::make_HI(loc); }
ls		{ BEGIN(INITIAL); return yy::parser::make_LS(loc); }
ge		{ BEGIN(INITIAL); return yy::parser::make_GE(loc); }
lt		{ BEGIN(INITIAL); return yy::parser::make_LT(loc); }
gt		{ BEGIN(INITIAL); return yy::parser::make_GT(loc); }
le		{ BEGIN(INITIAL); return yy::parser::make_LE(loc); }
al		{ BEGIN(INITIAL); return yy::parser::make_AL(loc); }
}

<B>{LETTER}+	{ BEGIN(INITIAL); return yy::parser::make_LABEL(yytext, loc); } // Match labels begining with a 'b'
<INITIAL>[_ac-zAC-Z]{LETTER}*	{ return yy::parser::make_LABEL(yytext, loc); } // Match labels not begining with a 'b'

0x{HEXNUM}	{ return yy::parser::make_HEXADECIMAL(std::stoul(yytext, nullptr, 0), loc); }
{DECNUM}	{ return yy::parser::make_NUMBER(atoi(yytext), loc);}

,		{ return yy::parser::make_COMMA(loc); }
\.		{ return yy::parser::make_DOT(loc); }
:		{ return yy::parser::make_COLON(loc); }
=		{ return yy::parser::make_EQUAL(loc); }
#		{ return yy::parser::make_HASH(loc); }

{WS}		{ return yy::parser::make_WHITESPACE(loc); }
\n		{ return yy::parser::make_NEWLINE(loc); }
<<EOF>>		{ return yy::parser::make_END(loc); }
%%
