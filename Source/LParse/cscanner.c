/* ----------------------------------------------------------------------------- 
 * cscanner.c
 *
 *     C Scanner that is roughly compatible with the SWIG1.1 scanner.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "lparse.h"

#define yylval lparse_yylval

#include "lyacc.h"
#include <stdarg.h>

static int map[][2] = {
  { SWIG_TOKEN_LPAREN, LPAREN },
  { SWIG_TOKEN_RPAREN, RPAREN },
  { SWIG_TOKEN_SEMI, SEMI },  
  { SWIG_TOKEN_COMMA, COMMA },
  { SWIG_TOKEN_STAR, STAR }, 
  { SWIG_TOKEN_LBRACE, LBRACE },
  { SWIG_TOKEN_RBRACE, RBRACE },
  { SWIG_TOKEN_EQUAL, EQUAL }, 
  { SWIG_TOKEN_EQUALTO, EQUALTO },
  { SWIG_TOKEN_NOTEQUAL, NOTEQUAL },
  { SWIG_TOKEN_PLUS, PLUS },
  { SWIG_TOKEN_MINUS, MINUS },
  { SWIG_TOKEN_AND, AND },
  { SWIG_TOKEN_LAND, LAND },
  { SWIG_TOKEN_OR, OR},
  { SWIG_TOKEN_LOR, LOR},
  { SWIG_TOKEN_XOR, XOR},
  { SWIG_TOKEN_LESSTHAN, LESSTHAN },
  { SWIG_TOKEN_GREATERTHAN, GREATERTHAN },
  { SWIG_TOKEN_LTEQUAL, LTEQUAL},
  { SWIG_TOKEN_GTEQUAL, GTEQUAL},
  { SWIG_TOKEN_NOT, NOT },
  { SWIG_TOKEN_LNOT, LNOT },
  { SWIG_TOKEN_LBRACKET, LBRACKET },
  { SWIG_TOKEN_RBRACKET, RBRACKET },
  { SWIG_TOKEN_SLASH, SLASH },
  { SWIG_TOKEN_BACKSLASH, -1 },
  { SWIG_TOKEN_ENDLINE, -1},
  { SWIG_TOKEN_STRING, STRING },
  { SWIG_TOKEN_POUND, -1 },
  { SWIG_TOKEN_PERCENT, -1 },
  { SWIG_TOKEN_COLON, COLON },
  { SWIG_TOKEN_DCOLON, DCOLON },
  { SWIG_TOKEN_LSHIFT, LSHIFT },
  { SWIG_TOKEN_RSHIFT, RSHIFT },
  { SWIG_TOKEN_ID, ID},
  { SWIG_TOKEN_FLOAT, NUM_FLOAT},
  { SWIG_TOKEN_DOUBLE, NUM_FLOAT},
  { SWIG_TOKEN_INT, NUM_INT},
  { SWIG_TOKEN_UINT, NUM_UNSIGNED},
  { SWIG_TOKEN_LONG, NUM_LONG},
  { SWIG_TOKEN_ULONG, NUM_ULONG},
  { SWIG_TOKEN_CHAR, CHARCONST},
  { SWIG_TOKEN_PERIOD, PERIOD},
  { SWIG_TOKEN_AT, -1},
  { SWIG_TOKEN_DOLLAR, -1},
  { SWIG_TOKEN_CODEBLOCK, HBLOCK},
  { SWIG_TOKEN_ILLEGAL, SWIG_TOKEN_ILLEGAL},
  { SWIG_TOKEN_LAST, -1},
  {0,0},
};

static int           remap[SWIG_MAXTOKENS];
static int           cscan_init = 0;
static int           cplusplus_mode = 1;
static int           objc_mode = 0;
static int           strict_type = 0;

static SwigScanner  *cscanner = 0;

/* -----------------------------------------------------------------------------
 * lparse_init()
 * 
 * Initialize the parser
 * ----------------------------------------------------------------------------- */

static void 
lparse_init() {
  int i = 0;
  if (cscan_init) return;
  while (map[i][0]) {
    remap[map[i][0]] = map[i][1];
    i++;
  }
  cscanner = NewSwigScanner();
  SwigScanner_idstart(cscanner,"$%@");
  cscan_init = 1;
}

/* -----------------------------------------------------------------------------
 * LParse_push()
 *
 * Push some text into the scanner.
 * ----------------------------------------------------------------------------- */
void
LParse_push(DOH *str) {
  assert(str);
  lparse_init();
  SwigScanner_push(cscanner, str);
}

/* ----------------------------------------------------------------------------- 
 * LParse_file()
 *
 * Return the current filename
 * ----------------------------------------------------------------------------- */

DOH *
LParse_file() {
  return SwigScanner_get_file(cscanner);
}

/* -----------------------------------------------------------------------------
 * LParse_line()
 *
 * Return the current line number
 * ----------------------------------------------------------------------------- */

int 
LParse_line() {
  return SwigScanner_get_line(cscanner);
}

/* -----------------------------------------------------------------------------
 * LParse_set_location()
 *
 * Set the file and line number of the scanner.
 * ----------------------------------------------------------------------------- */

void 
LParse_set_location(DOH *file, int line) {
  SwigScanner_set_location(cscanner,file,line);
}

/* -----------------------------------------------------------------------------
 * LParse_strict_type()
 *
 * Set the value of the strict type handling flag.
 * ----------------------------------------------------------------------------- */

int 
LParse_strict_type(int i) {
  int old = strict_type;
  strict_type = i;
  return old;
}

/* -----------------------------------------------------------------------------
 * LParse_cplusplus()
 *
 * Enable or disable C++ keywords.
 * ----------------------------------------------------------------------------- */

int
LParse_cplusplus(int i) {
  int old = cplusplus_mode;
  cplusplus_mode = i;
  return old;
}

/* -----------------------------------------------------------------------------
 * LParse_objc()
 *
 * Enable or disable objective-C keywords.
 * ----------------------------------------------------------------------------- */
int
LParse_objc(int i) {
  int old = objc_mode;
  objc_mode = i;
  return old;
}

static DOH *macro_name = 0;
static DOH *macro_file = 0;
static int macro_line = 0;

/* -----------------------------------------------------------------------------
 * LParse_macro_location()
 *
 * Set the location of a macro when parsing macro text.
 * ----------------------------------------------------------------------------- */
 
void
LParse_macro_location(DOH *name, DOH *file, int line) {
  macro_name = name;
  macro_file = file;
  macro_line = line;
}

/* -----------------------------------------------------------------------------
 * LParse_error()
 *
 * Report an error.
 * ----------------------------------------------------------------------------- */

void
LParse_error(DOH *file, int line, char *fmt, ...) {
  va_list ap;
  va_start(ap,fmt);
  if (!file) {
    file = SwigScanner_get_file(cscanner);
    line = SwigScanner_get_line(cscanner);
  }
  if (macro_name) {
    Printf(stderr,"%s:%d In macro %s at ", macro_file, macro_line, macro_name);
  }
  if (line > 0) {
    Printf(stderr,"%s:%d ", file, line);
  } else {
    Printf(stderr,"%s:EOF ",file);
  }
  vPrintf(stderr,fmt,ap);
  va_end(ap);
  macro_name = 0;
}

/* -----------------------------------------------------------------------------
 * LParse_skip_balanced()
 *
 * Skip over text enclosed in balanced characters (), [], <>, etc...
 * ----------------------------------------------------------------------------- */

DOH * 
LParse_skip_balanced(int startchar, int endchar) {
  DOH *file;
  int line;
  file = SwigScanner_get_file(cscanner);
  line = SwigScanner_get_line(cscanner);
  if (SwigScanner_skip_balanced(cscanner, startchar, endchar) == -1)
    LParse_error(file,line,"Missing \'%c\'.  Reached the end of input.\n", endchar);
  return Copy(SwigScanner_text(cscanner));  
}

/* -----------------------------------------------------------------------------
 * LParse_skip_semi()
 *
 * Skip to the next semi-colon
 * ----------------------------------------------------------------------------- */

void
LParse_skip_semi() {
  int t, line;
  DOH   *file;
  int lparse_yylex();

  line = SwigScanner_get_line(cscanner);
  file = SwigScanner_get_file(cscanner);
  while ((t = lparse_yylex())) {
    if (t == SEMI) return;
  }
  LParse_error(file,line,"Missing semicolon. Reached the end of input.\n");
}

/* -----------------------------------------------------------------------------
 * LParse_skip_decl()
 *
 * Skip the current declaration (terminated by either a semicolon or }
 * ----------------------------------------------------------------------------- */

void
LParse_skip_decl() {
  int t, line, level = 0;
  DOH *file;
  int lparse_yylex();

  line = SwigScanner_get_line(cscanner);
  file = SwigScanner_get_file(cscanner);
  while ((t = lparse_yylex())) {
    if ((t == SEMI) && (level == 0)) return;
    if (t == LBRACE) level++;
    if (t == RBRACE) {
      level--;
      if (level <= 0) return;
    }
  }
  if (level) {
    LParse_error(file,line,"Missing \'}\'.  Reached the end of input.\n");
  } else {
    LParse_error(file,line,"Missing semicolon. Reached the end of input.\n");
  }
}

/* -----------------------------------------------------------------------------
 * yylex1()
 *
 * Get next token.
 * ----------------------------------------------------------------------------- */
static int
yylex1(void) {
    int   l, l1;
    DOH   *text;
    char  *yytext = 0;
    int   lparse_yylex();

    assert(cscan_init);
    l = SwigScanner_token(cscanner);
    if (!l) return 0;
    l1 = remap[l];
    if (l1 == -1) return lparse_yylex();
    
    text = SwigScanner_text(cscanner);
    yylval.tok.line = Getline(text);
    yylval.tok.filename = Getfile(text);
    yylval.tok.data = 0;
    yylval.tok.ivalue = 0;
    yytext = Char(text);
    if (l1 == SWIG_TOKEN_ILLEGAL) {
      LParse_error(0,0,"Illegal character '%s'\n", text);
      return yylex1();
    }
    if (l1 == STRING) {
      yylval.tok.text = NewString(yytext+1);
      Delitem(yylval.tok.text,DOH_END);
    }
    if ((l1 == HBLOCK) || (l1 == NUM_INT) || (l1 == NUM_FLOAT) || (l1 == NUM_UNSIGNED) || (l1 == NUM_LONG) || (l1 == NUM_ULONG))  {
      yylval.tok.text = NewString(yytext);
    }
    if (l1 == ID) {
      /* Look for keywords now */
      if (strcmp(yytext,"int") == 0) return(TYPE_INT);
      if (strcmp(yytext,"double") == 0) return(TYPE_DOUBLE);
      if (strcmp(yytext,"void") == 0) return(TYPE_VOID);
      if (strcmp(yytext,"char") == 0) return(TYPE_CHAR);
      if (strcmp(yytext,"short") == 0) 	return(TYPE_SHORT);
      if (strcmp(yytext,"long") == 0) 	return(TYPE_LONG);
      if (strcmp(yytext,"float") == 0) 	return(TYPE_FLOAT);
      if (strcmp(yytext,"signed") == 0) return(TYPE_SIGNED);
      if (strcmp(yytext,"unsigned") == 0) return(TYPE_UNSIGNED);
      if (strcmp(yytext,"bool") == 0) return(TYPE_BOOL);

      /* C++ keywords */

      if (cplusplus_mode) {
	if (strcmp(yytext,"class") == 0) {
	  yylval.tok.text = NewString(yytext);
	  return(CLASS);
	}
	if (strcmp(yytext,"private") == 0) return(PRIVATE);
	if (strcmp(yytext,"public") == 0) return(PUBLIC);
	if (strcmp(yytext,"protected") == 0) return(PROTECTED);
	if (strcmp(yytext,"friend") == 0) return(FRIEND);
	if (strcmp(yytext,"virtual") == 0) return(lparse_yylex());
	if (strcmp(yytext,"operator") == 0) return(OPERATOR);
	if (strcmp(yytext,"throw") == 0) return(THROW);
	if (strcmp(yytext,"inline") == 0) return(lparse_yylex());
	if (strcmp(yytext,"template") == 0) return(TEMPLATE);
      }
      /* Objective-C keywords */

      if (objc_mode) {
	if (strcmp(yytext,"@interface") == 0) return (OC_INTERFACE);
	if (strcmp(yytext,"@end") == 0) return (OC_END);
	if (strcmp(yytext,"@public") == 0) return (OC_PUBLIC);
	if (strcmp(yytext,"@private") == 0) return (OC_PRIVATE);
	if (strcmp(yytext,"@protected") == 0) return (OC_PROTECTED);
	if (strcmp(yytext,"@class") == 0) return(OC_CLASS);
	if (strcmp(yytext,"@implementation") == 0) return(OC_IMPLEMENT);
	if (strcmp(yytext,"@protocol") == 0) return(OC_PROTOCOL);
      }
      
      /* Misc keywords */
      if (strcmp(yytext,"static") == 0) return(STATIC);
      if (strcmp(yytext,"extern") == 0) return(EXTERN);
      if (strcmp(yytext,"const") == 0) return(CONST);
      if (strcmp(yytext,"typedef") == 0) return(TYPEDEF);
      if (strcmp(yytext,"struct") == 0) {
	yylval.tok.text = NewString(yytext);
	return(STRUCT);
      }
      if (strcmp(yytext,"union") == 0) {
	yylval.tok.text = NewString(yytext);
	return(UNION);
      }
      if (strcmp(yytext,"enum") == 0) return(ENUM);
      if (strcmp(yytext,"sizeof") == 0) return(SIZEOF);
      
      /* Ignored keywords  */
      if (strcmp(yytext,"volatile") == 0) return(lparse_yylex());

      /* SWIG directives */
      if (yytext[0] == '%') {
	if (strcmp(yytext,"%module") == 0) return(MODULE);
	if (strcmp(yytext,"%constant") == 0) return (CONSTANT);
	if (strcmp(yytext,"%file") == 0) return(FILEDIRECTIVE);
	if (strcmp(yytext,"%insert") == 0) return (INSERT);
	if (strcmp(yytext,"%macro") == 0) return(MACRO);
	if (strcmp(yytext,"%pragma") == 0) return(PRAGMA);
	if (strcmp(yytext,"%addmethods") == 0) return(ADDMETHODS);
	if (strcmp(yytext,"%inline") == 0) return(INLINE);
	if (strcmp(yytext,"%typemap") == 0) return(TYPEMAP);
	if (strcmp(yytext,"%except") == 0) return(EXCEPT);
	if (strcmp(yytext,"%echo") == 0) return(ECHO);
	if (strcmp(yytext,"%apply") == 0) return(APPLY);
	if (strcmp(yytext,"%clear") == 0) return(CLEAR);
	if (strcmp(yytext,"%scope") == 0) return(SCOPE);
      }
      /* Have an unknown identifier, as a last step, we'll */
      /* do a typedef lookup on it. */
      yylval.tok.text = NewString(yytext);
      /*      if (strict_type && LParse_typedef_check(yylval.tok.text)) {
	return TYPE_TYPEDEF;
	}*/
      return(ID);
    }
    return(l1);
}

/* -----------------------------------------------------------------------------
 * lparse_yylex()
 *
 * main entry point for the parser
 * ----------------------------------------------------------------------------- */

int
lparse_yylex() {
  int t;
  t = yylex1();
  /*   printf("%d\n",t); */
  return t;
}

