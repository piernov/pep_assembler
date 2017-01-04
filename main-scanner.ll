/**
 * (subset of) ARM v7-M Thumb UAL scanner
 *
 * piernov <piernov@piernov.org>
 */

%{
#include "main-parser.hh"
%}

%option noyywrap nounput batch
%option caseless

%s B

DECNUM		[0-9]+
WS		[ \t]+
LETTER		[_a-zA-Z]
HEXNUM		[a-fA-F0-9]+

%%
R		{ return yy::parser::make_REGISTER(); }


adcs		{ return yy::parser::make_ADCS(); }
adds		{ return yy::parser::make_ADDS(); }
ands		{ return yy::parser::make_ANDS(); }
asrs		{ return yy::parser::make_ASRS(); }
bics		{ return yy::parser::make_BICS(); }
cmp		{ return yy::parser::make_CMP(); }
cmn		{ return yy::parser::make_CMN(); }
eors		{ return yy::parser::make_EORS(); }
ldr		{ return yy::parser::make_LDR(); }
lsls		{ return yy::parser::make_LSLS(); }
lsrs		{ return yy::parser::make_LSRS(); }
movs		{ return yy::parser::make_MOVS(); }
muls		{ return yy::parser::make_MULS(); }
mvns		{ return yy::parser::make_MVNS(); }
orrs		{ return yy::parser::make_ORRS(); }
rors		{ return yy::parser::make_RORS(); }
rsbs		{ return yy::parser::make_RSBS(); }
sbcs		{ return yy::parser::make_SBCS(); }
str		{ return yy::parser::make_STR(); }
subs		{ return yy::parser::make_SUBS(); }
tst		{ return yy::parser::make_TST(); }

b               { BEGIN(B); yymore(); return yy::parser::make_B(); } // Conditional branch, begin "B" start-condition

<B>{ // Conditions for branch inside "B" start-condition
eq		{ BEGIN(INITIAL); return yy::parser::make_EQ(); }
ne		{ BEGIN(INITIAL); return yy::parser::make_NE(); }
cs		{ BEGIN(INITIAL); return yy::parser::make_CS(); }
hs		{ BEGIN(INITIAL); return yy::parser::make_HS(); }
cc		{ BEGIN(INITIAL); return yy::parser::make_CC(); }
lo		{ BEGIN(INITIAL); return yy::parser::make_LO(); }
mi		{ BEGIN(INITIAL); return yy::parser::make_MI(); }
pl		{ BEGIN(INITIAL); return yy::parser::make_PL(); }
vs		{ BEGIN(INITIAL); return yy::parser::make_VS(); }
vc		{ BEGIN(INITIAL); return yy::parser::make_VC(); }
hi		{ BEGIN(INITIAL); return yy::parser::make_HI(); }
ls		{ BEGIN(INITIAL); return yy::parser::make_LS(); }
ge		{ BEGIN(INITIAL); return yy::parser::make_GE(); }
lt		{ BEGIN(INITIAL); return yy::parser::make_LT(); }
gt		{ BEGIN(INITIAL); return yy::parser::make_GT(); }
le		{ BEGIN(INITIAL); return yy::parser::make_LE(); }
al		{ BEGIN(INITIAL); return yy::parser::make_AL(); }
}

<B>{LETTER}+	{ BEGIN(INITIAL); return yy::parser::make_LABEL(yytext); } // Match labels begining with a 'b'
<INITIAL>[_ac-zAC-Z]{LETTER}*	{ return yy::parser::make_LABEL(yytext); } // Match labels not begining with a 'b'

0x{HEXNUM}	{ return yy::parser::make_HEXADECIMAL(std::stoul(yytext, nullptr, 0)); }
{DECNUM}	{ return yy::parser::make_NUMBER(atoi(yytext));}

,		{ return yy::parser::make_COMMA(); }
\.		{ return yy::parser::make_DOT(); }
:		{ return yy::parser::make_COLON(); }
=		{ return yy::parser::make_EQUAL(); }
#		{ return yy::parser::make_HASH(); }
\[		{ return yy::parser::make_LBRACKET(); }
\]		{ return yy::parser::make_RBRACKET(); }

{WS}		{ return yy::parser::make_WHITESPACE(); }
\n		{ return yy::parser::make_NEWLINE(); }
<<EOF>>		{ return yy::parser::make_END(); }
%%
