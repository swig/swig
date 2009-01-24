/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * scanner.c
 *
 * This file implements a general purpose C/C++ compatible lexical scanner.
 * This scanner isn't intended to be plugged directly into a parser built
 * with yacc. Rather, it contains a lot of generic code that could be used
 * to easily construct yacc-compatible scanners.
 * ----------------------------------------------------------------------------- */

char cvsroot_scanner_c[] = "$Id$";

#include "swig.h"
#include <ctype.h>

extern String *cparse_file;
extern int     cparse_start_line;

struct Scanner {
  String *text;			/* Current token value */
  List   *scanobjs;		/* Objects being scanned */
  String *str;			/* Current object being scanned */
  char   *idstart;		/* Optional identifier start characters */
  int     nexttoken;		/* Next token to be returned */
  int     start_line;		/* Starting line of certain declarations */
  int     line;
  int     yylen;	        /* Length of text pushed into text */
  String *file;
  String *error;                /* Last error message (if any) */
  int     error_line;           /* Error line number */
  int     freeze_line;          /* Suspend line number updates */
};

/* -----------------------------------------------------------------------------
 * NewScanner()
 *
 * Create a new scanner object
 * ----------------------------------------------------------------------------- */

Scanner *NewScanner(void) {
  Scanner *s;
  s = (Scanner *) malloc(sizeof(Scanner));
  s->line = 1;
  s->file = 0;
  s->nexttoken = -1;
  s->start_line = 1;
  s->yylen = 0;
  s->idstart = NULL;
  s->scanobjs = NewList();
  s->text = NewStringEmpty();
  s->str = 0;
  s->error = 0;
  s->freeze_line = 0;
  return s;
}

/* -----------------------------------------------------------------------------
 * DelScanner()
 *
 * Delete a scanner object.
 * ----------------------------------------------------------------------------- */

void DelScanner(Scanner * s) {
  assert(s);
  Delete(s->scanobjs);
  Delete(s->text);
  Delete(s->file);
  Delete(s->error);
  Delete(s->str);
  free(s->idstart);
  free(s);
}

/* -----------------------------------------------------------------------------
 * Scanner_clear()
 *
 * Clear the contents of a scanner object.
 * ----------------------------------------------------------------------------- */

void Scanner_clear(Scanner * s) {
  assert(s);
  Delete(s->str);
  Clear(s->text);
  Clear(s->scanobjs);
  Delete(s->error);
  s->error = 0;
  s->line = 1;
  s->nexttoken = -1;
  s->start_line = 0;
  s->yylen = 0;
}

/* -----------------------------------------------------------------------------
 * Scanner_push()
 *
 * Push some new text into the scanner.  The scanner will start parsing this text
 * immediately before returning to the old text.
 * ----------------------------------------------------------------------------- */

void Scanner_push(Scanner * s, String *txt) {
  assert(s && txt);
  Push(s->scanobjs, txt);
  if (s->str) {
    Setline(s->str,s->line);
    Delete(s->str);
  }
  s->str = txt;
  DohIncref(s->str);
  s->line = Getline(txt);
}

/* -----------------------------------------------------------------------------
 * Scanner_pushtoken()
 *
 * Push a token into the scanner.  This token will be returned on the next
 * call to Scanner_token().
 * ----------------------------------------------------------------------------- */

void Scanner_pushtoken(Scanner * s, int nt, const_String_or_char_ptr val) {
  assert(s);
  assert((nt >= 0) && (nt < SWIG_MAXTOKENS));
  s->nexttoken = nt;
  if (val != s->text) {
    Clear(s->text);
    Append(s->text,val);
  }
}

/* -----------------------------------------------------------------------------
 * Scanner_set_location()
 *
 * Set the file and line number location of the scanner.
 * ----------------------------------------------------------------------------- */

void Scanner_set_location(Scanner * s, String *file, int line) {
  Setline(s->str, line);
  Setfile(s->str, file);
  s->line = line;
}

/* -----------------------------------------------------------------------------
 * Scanner_file()
 *
 * Get the current file.
 * ----------------------------------------------------------------------------- */

String *Scanner_file(Scanner * s) {
  return Getfile(s->str);
}

/* -----------------------------------------------------------------------------
 * Scanner_line()
 *
 * Get the current line number
 * ----------------------------------------------------------------------------- */
int Scanner_line(Scanner * s) {
  return s->line;
}

/* -----------------------------------------------------------------------------
 * Scanner_start_line()
 *
 * Get the line number on which the current token starts
 * ----------------------------------------------------------------------------- */
int Scanner_start_line(Scanner * s) {
  return s->start_line;
}

/* -----------------------------------------------------------------------------
 * Scanner_idstart()
 *
 * Change the set of additional characters that can be used to start an identifier.
 * ----------------------------------------------------------------------------- */

void Scanner_idstart(Scanner * s, const char *id) {
  free(s->idstart);
  s->idstart = Swig_copy_string(id);
}

/* -----------------------------------------------------------------------------
 * nextchar()
 * 
 * Returns the next character from the scanner or 0 if end of the string.
 * ----------------------------------------------------------------------------- */
static char nextchar(Scanner * s) {
  int nc;
  if (!s->str)
    return 0;
  while ((nc = Getc(s->str)) == EOF) {
    Delete(s->str);
    s->str = 0;
    Delitem(s->scanobjs, 0);
    if (Len(s->scanobjs) == 0)
      return 0;
    s->str = Getitem(s->scanobjs, 0);
    if (s->str) {
      s->line = Getline(s->str);
      DohIncref(s->str);
    }
  }
  if ((nc == '\n') && (!s->freeze_line)) 
    s->line++;
  Putc(nc,s->text);
  return (char)nc;
}

/* -----------------------------------------------------------------------------
 * set_error() 
 *
 * Sets error information on the scanner.
 * ----------------------------------------------------------------------------- */

static void set_error(Scanner *s, int line, const_String_or_char_ptr msg) {
  s->error_line = line;
  s->error = NewString(msg);
}

/* -----------------------------------------------------------------------------
 * Scanner_errmsg()
 * Scanner_errline()
 *
 * Returns error information (if any)
 * ----------------------------------------------------------------------------- */

String *
Scanner_errmsg(Scanner *s) {
  return s->error;
}

int
Scanner_errline(Scanner *s) {
  return s->error_line;
}

/* -----------------------------------------------------------------------------
 * Scanner_freeze_line()
 *
 * Freezes the current line number.
 * ----------------------------------------------------------------------------- */

void
Scanner_freeze_line(Scanner *s, int val) {
  s->freeze_line = val;
}

/* -----------------------------------------------------------------------------
 * retract()
 *
 * Retract n characters
 * ----------------------------------------------------------------------------- */
static void retract(Scanner * s, int n) {
  int i, l;
  char *str;

  str = Char(s->text);
  l = Len(s->text);
  assert(n <= l);
  for (i = 0; i < n; i++) {
    if (str[l - 1] == '\n') {
      if (!s->freeze_line) s->line--;
    }
    Seek(s->str, -1, SEEK_CUR);
    Delitem(s->text, DOH_END);
  }
}

/* -----------------------------------------------------------------------------
 * get_escape()
 * 
 * Get escape sequence.  Called when a backslash is found in a string
 * ----------------------------------------------------------------------------- */

static void get_escape(Scanner *s) {
  int result = 0;
  int state = 0;
  int c;

  while (1) {
    c = nextchar(s);
    if (c == 0)
      break;
    switch (state) {
    case 0:
      if (c == 'n') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\n");
	return;
      }
      if (c == 'r') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\r");
	return;
      }
      if (c == 't') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\t");
	return;
      }
      if (c == 'a') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\a");
	return;
      }
      if (c == 'b') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\b");
	return;
      }
      if (c == 'f') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\f");
	return;
      }
      if (c == '\\') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\\");
	return;
      }
      if (c == 'v') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\v");
	return;
      }
      if (c == 'e') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\033");
	return;
      }
      if (c == '\'') {
	Delitem(s->text, DOH_END);
	Append(s->text,"\'");
	return;
      }
      if (c == '\"') {
	Delitem(s->text, DOH_END);	
	Append(s->text,"\"");
	return;
      }
      if (c == '\n') {
	Delitem(s->text, DOH_END);
	return;
      }
      if (isdigit(c)) {
	state = 10;
	result = (c - '0');
	Delitem(s->text, DOH_END);
      } else if (c == 'x') {
	state = 20;
	Delitem(s->text, DOH_END);
      } else {
	char tmp[3];
	tmp[0] = '\\';
	tmp[1] = (char)c;
	tmp[2] = 0;
	Delitem(s->text, DOH_END);
	Append(s->text, tmp);
	return;
      }
      break;
    case 10:
      if (!isdigit(c)) {
	retract(s,1);
	Putc((char)result,s->text);
	return;
      }
      result = (result << 3) + (c - '0');
      Delitem(s->text, DOH_END);
      break;
    case 20:
      if (!isxdigit(c)) {
	retract(s,1);
	Putc((char)result, s->text);
	return;
      }
      if (isdigit(c))
	result = (result << 4) + (c - '0');
      else
	result = (result << 4) + (10 + tolower(c) - 'a');
      Delitem(s->text, DOH_END);
      break;
    }
  }
  return;
}

/* -----------------------------------------------------------------------------
 * look()
 *
 * Return the raw value of the next token.
 * ----------------------------------------------------------------------------- */

static int look(Scanner * s) {
  int state;
  int c = 0;

  state = 0;
  Clear(s->text);
  s->start_line = s->line;
  Setfile(s->text, Getfile(s->str));
  while (1) {
    switch (state) {
    case 0:
      if ((c = nextchar(s)) == 0)
	return (0);

      /* Process delimiters */

      if (c == '\n') {
	return SWIG_TOKEN_ENDLINE;
      } else if (!isspace(c)) {
	retract(s, 1);
	state = 1000;
	Clear(s->text);
	Setline(s->text, s->line);
	Setfile(s->text, Getfile(s->str));
      }
      break;

    case 1000:
      if ((c = nextchar(s)) == 0)
	return (0);
      if (c == '%')
	state = 4;		/* Possibly a SWIG directive */

      /* Look for possible identifiers */

      else if ((isalpha(c)) || (c == '_') ||
	       (s->idstart && strchr(s->idstart, c)))
	state = 7;

      /* Look for single character symbols */

      else if (c == '(')
	return SWIG_TOKEN_LPAREN;
      else if (c == ')')
	return SWIG_TOKEN_RPAREN;
      else if (c == ';')
	return SWIG_TOKEN_SEMI;
      else if (c == ',')
	return SWIG_TOKEN_COMMA;
      else if (c == '*')
	state = 220;
      else if (c == '}')
	return SWIG_TOKEN_RBRACE;
      else if (c == '{')
	return SWIG_TOKEN_LBRACE;
      else if (c == '=')
	state = 33;
      else if (c == '+')
	state = 200;
      else if (c == '-')
	state = 210;
      else if (c == '&')
	state = 31;
      else if (c == '|')
	state = 32;
      else if (c == '^')
	state = 230;
      else if (c == '<')
	state = 60;
      else if (c == '>')
	state = 61;
      else if (c == '~')
	return SWIG_TOKEN_NOT;
      else if (c == '!')
	state = 3;
      else if (c == '\\')
	return SWIG_TOKEN_BACKSLASH;
      else if (c == '[')
	return SWIG_TOKEN_LBRACKET;
      else if (c == ']')
	return SWIG_TOKEN_RBRACKET;
      else if (c == '@')
	return SWIG_TOKEN_AT;
      else if (c == '$')
	state = 75;
      else if (c == '#')
	return SWIG_TOKEN_POUND;
      else if (c == '?')
	return SWIG_TOKEN_QUESTION;

      /* Look for multi-character sequences */

      else if (c == '/') {
	state = 1;		/* Comment (maybe)  */
	s->start_line = s->line;
      }
      else if (c == '\"') {
	state = 2;		/* Possibly a string */
	s->start_line = s->line;
	Clear(s->text);
      }

      else if (c == ':')
	state = 5;		/* maybe double colon */
      else if (c == '0')
	state = 83;		/* An octal or hex value */
      else if (c == '\'') {
	s->start_line = s->line;
	Clear(s->text);
	state = 9;		/* A character constant */
      } else if (c == '`') {
	s->start_line = s->line;
	Clear(s->text);
	state = 900;
      }

      else if (c == '.')
	state = 100;		/* Maybe a number, maybe just a period */
      else if (isdigit(c))
	state = 8;		/* A numerical value */
      else
	state = 99;		/* An error */
      break;

    case 1:			/*  Comment block */
      if ((c = nextchar(s)) == 0)
	return (0);
      if (c == '/') {
	state = 10;		/* C++ style comment */
	Clear(s->text);
	Setline(s->text, Getline(s->str));
	Setfile(s->text, Getfile(s->str));
	Append(s->text, "//");
      } else if (c == '*') {
	state = 11;		/* C style comment */
	Clear(s->text);
	Setline(s->text, Getline(s->str));
	Setfile(s->text, Getfile(s->str));
	Append(s->text, "/*");
      } else if (c == '=') {
	return SWIG_TOKEN_DIVEQUAL;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_SLASH;
      }
      break;
    case 10:			/* C++ style comment */
      if ((c = nextchar(s)) == 0) {
	Swig_error(cparse_file, cparse_start_line, "Unterminated comment\n");
	return SWIG_TOKEN_ERROR;
      }
      if (c == '\n') {
	retract(s,1);
	return SWIG_TOKEN_COMMENT;
      } else {
	state = 10;
      }
      break;
    case 11:			/* C style comment block */
      if ((c = nextchar(s)) == 0) {
	Swig_error(cparse_file, cparse_start_line, "Unterminated comment\n");
	return SWIG_TOKEN_ERROR;
      }
      if (c == '*') {
	state = 12;
      } else {
	state = 11;
      }
      break;
    case 12:			/* Still in C style comment */
      if ((c = nextchar(s)) == 0) {
	Swig_error(cparse_file, cparse_start_line, "Unterminated comment\n");
	return SWIG_TOKEN_ERROR;
      }
      if (c == '*') {
	state = 12;
      } else if (c == '/') {
	return SWIG_TOKEN_COMMENT;
      } else {
	state = 11;
      }
      break;

    case 2:			/* Processing a string */
      if ((c = nextchar(s)) == 0) {
	Swig_error(cparse_file, cparse_start_line, "Unterminated string\n");
	return SWIG_TOKEN_ERROR;
      }
      if (c == '\"') {
	Delitem(s->text, DOH_END);
	return SWIG_TOKEN_STRING;
      } else if (c == '\\') {
	Delitem(s->text, DOH_END);
	get_escape(s);
      } else
	state = 2;
      break;

    case 3:			/* Maybe a not equals */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_LNOT;
      else if (c == '=')
	return SWIG_TOKEN_NOTEQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_LNOT;
      }
      break;

    case 31:			/* AND or Logical AND or ANDEQUAL */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_AND;
      else if (c == '&')
	return SWIG_TOKEN_LAND;
      else if (c == '=')
	return SWIG_TOKEN_ANDEQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_AND;
      }
      break;

    case 32:			/* OR or Logical OR */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_OR;
      else if (c == '|')
	return SWIG_TOKEN_LOR;
      else if (c == '=')
	return SWIG_TOKEN_OREQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_OR;
      }
      break;

    case 33:			/* EQUAL or EQUALTO */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_EQUAL;
      else if (c == '=')
	return SWIG_TOKEN_EQUALTO;
      else {
	retract(s, 1);
	return SWIG_TOKEN_EQUAL;
      }
      break;

    case 4:			/* A wrapper generator directive (maybe) */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_PERCENT;
      if (c == '{') {
	state = 40;		/* Include block */
	Clear(s->text);
	Setline(s->text, Getline(s->str));
	Setfile(s->text, Getfile(s->str));
	s->start_line = s->line;
      } else if (s->idstart && strchr(s->idstart, '%') &&
	         ((isalpha(c)) || (c == '_'))) {
	state = 7;
      } else if (c == '=') {
	return SWIG_TOKEN_MODEQUAL;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_PERCENT;
      }
      break;

    case 40:			/* Process an include block */
      if ((c = nextchar(s)) == 0) {
	Swig_error(cparse_file, cparse_start_line, "Unterminated block\n");
	return SWIG_TOKEN_ERROR;
      }
      if (c == '%')
	state = 41;
      break;
    case 41:			/* Still processing include block */
      if ((c = nextchar(s)) == 0) {
	set_error(s,s->start_line,"Unterminated code block");
	return 0;
      }
      if (c == '}') {
	Delitem(s->text, DOH_END);
	Delitem(s->text, DOH_END);
	Seek(s->text,0,SEEK_SET);
	return SWIG_TOKEN_CODEBLOCK;
      } else {
	state = 40;
      }
      break;

    case 5:			/* Maybe a double colon */

      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_COLON;
      if (c == ':')
	state = 50;
      else {
	retract(s, 1);
	return SWIG_TOKEN_COLON;
      }
      break;

    case 50:			/* DCOLON, DCOLONSTAR */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_DCOLON;
      else if (c == '*')
	return SWIG_TOKEN_DCOLONSTAR;
      else {
	retract(s, 1);
	return SWIG_TOKEN_DCOLON;
      }
      break;

    case 60:			/* shift operators */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_LESSTHAN;
      if (c == '<')
	state = 240;
      else if (c == '=')
	return SWIG_TOKEN_LTEQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_LESSTHAN;
      }
      break;
    case 61:
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_GREATERTHAN;
      if (c == '>')
	state = 250;
      else if (c == '=')
	return SWIG_TOKEN_GTEQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_GREATERTHAN;
      }
      break;
    case 7:			/* Identifier */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_ID;
      if (isalnum(c) || (c == '_') || (c == '$')) {
	state = 7;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_ID;
      }
      break;

    case 75:			/* Special identifier $ */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_DOLLAR;
      if (isalnum(c) || (c == '_') || (c == '*') || (c == '&')) {
	state = 7;
      } else {
	retract(s,1);
	if (Len(s->text) == 1) return SWIG_TOKEN_DOLLAR;
	return SWIG_TOKEN_ID;
      }
      break;

    case 8:			/* A numerical digit */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_INT;
      if (c == '.') {
	state = 81;
      } else if ((c == 'e') || (c == 'E')) {
	state = 82;
      } else if ((c == 'f') || (c == 'F')) {
	Delitem(s->text, DOH_END);
	return SWIG_TOKEN_FLOAT;
      } else if (isdigit(c)) {
	state = 8;
      } else if ((c == 'l') || (c == 'L')) {
	state = 87;
      } else if ((c == 'u') || (c == 'U')) {
	state = 88;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_INT;
      }
      break;
    case 81:			/* A floating pointer number of some sort */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_DOUBLE;
      if (isdigit(c))
	state = 81;
      else if ((c == 'e') || (c == 'E'))
	state = 820;
      else if ((c == 'f') || (c == 'F')) {
	Delitem(s->text, DOH_END);
	return SWIG_TOKEN_FLOAT;
      } else if ((c == 'l') || (c == 'L')) {
	Delitem(s->text, DOH_END);
	return SWIG_TOKEN_DOUBLE;
      } else {
	retract(s, 1);
	return (SWIG_TOKEN_DOUBLE);
      }
      break;
    case 82:
      if ((c = nextchar(s)) == 0) {
	retract(s, 1);
	return SWIG_TOKEN_INT;
      }
      if ((isdigit(c)) || (c == '-') || (c == '+'))
	state = 86;
      else {
	retract(s, 2);
	return (SWIG_TOKEN_INT);
      }
      break;
    case 820:
      /* Like case 82, but we've seen a decimal point. */
      if ((c = nextchar(s)) == 0) {
	retract(s, 1);
	return SWIG_TOKEN_DOUBLE;
      }
      if ((isdigit(c)) || (c == '-') || (c == '+'))
	state = 86;
      else {
	retract(s, 2);
	return (SWIG_TOKEN_DOUBLE);
      }
      break;
    case 83:
      /* Might be a hexadecimal or octal number */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_INT;
      if (isdigit(c))
	state = 84;
      else if ((c == 'x') || (c == 'X'))
	state = 85;
      else if (c == '.')
	state = 81;
      else if ((c == 'l') || (c == 'L')) {
	state = 87;
      } else if ((c == 'u') || (c == 'U')) {
	state = 88;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_INT;
      }
      break;
    case 84:
      /* This is an octal number */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_INT;
      if (isdigit(c))
	state = 84;
      else if ((c == 'l') || (c == 'L')) {
	state = 87;
      } else if ((c == 'u') || (c == 'U')) {
	state = 88;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_INT;
      }
      break;
    case 85:
      /* This is an hex number */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_INT;
      if (isxdigit(c))
	state = 85;
      else if ((c == 'l') || (c == 'L')) {
	state = 87;
      } else if ((c == 'u') || (c == 'U')) {
	state = 88;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_INT;
      }
      break;

    case 86:
      /* Rest of floating point number */

      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_DOUBLE;
      if (isdigit(c))
	state = 86;
      else if ((c == 'f') || (c == 'F')) {
	Delitem(s->text, DOH_END);
	return SWIG_TOKEN_FLOAT;
      } else if ((c == 'l') || (c == 'L')) {
	Delitem(s->text, DOH_END);
	return SWIG_TOKEN_DOUBLE;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_DOUBLE;
      }
      break;

    case 87:
      /* A long integer of some sort */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_LONG;
      if ((c == 'u') || (c == 'U')) {
	return SWIG_TOKEN_ULONG;
      } else if ((c == 'l') || (c == 'L')) {
	state = 870;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_LONG;
      }
      break;

      /* A long long integer */

    case 870:
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_LONGLONG;
      if ((c == 'u') || (c == 'U')) {
	return SWIG_TOKEN_ULONGLONG;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_LONGLONG;
      }

      /* An unsigned number */
    case 88:

      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_UINT;
      if ((c == 'l') || (c == 'L')) {
	state = 880;
      } else {
	retract(s, 1);
	return SWIG_TOKEN_UINT;
      }
      break;

      /* Possibly an unsigned long long or unsigned long */
    case 880:
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_ULONG;
      if ((c == 'l') || (c == 'L'))
	return SWIG_TOKEN_ULONGLONG;
      else {
	retract(s, 1);
	return SWIG_TOKEN_ULONG;
      }

      /* A character constant */
    case 9:
      if ((c = nextchar(s)) == 0) {
	Swig_error(cparse_file, cparse_start_line, "Unterminated character constant\n");
	return SWIG_TOKEN_ERROR;
      }
      if (c == '\'') {
	Delitem(s->text, DOH_END);
	return (SWIG_TOKEN_CHAR);
      } else if (c == '\\') {
	Delitem(s->text, DOH_END);
	get_escape(s);
      }
      break;

      /* A period or maybe a floating point number */

    case 100:
      if ((c = nextchar(s)) == 0)
	return (0);
      if (isdigit(c))
	state = 81;
      else {
	retract(s, 1);
	return SWIG_TOKEN_PERIOD;
      }
      break;

    case 200:			/* PLUS, PLUSPLUS, PLUSEQUAL */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_PLUS;
      else if (c == '+')
	return SWIG_TOKEN_PLUSPLUS;
      else if (c == '=')
	return SWIG_TOKEN_PLUSEQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_PLUS;
      }
      break;

    case 210:			/* MINUS, MINUSMINUS, MINUSEQUAL, ARROW */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_MINUS;
      else if (c == '-')
	return SWIG_TOKEN_MINUSMINUS;
      else if (c == '=')
	return SWIG_TOKEN_MINUSEQUAL;
      else if (c == '>')
	state = 211;
      else {
	retract(s, 1);
	return SWIG_TOKEN_MINUS;
      }
      break;

    case 211:			/* ARROW, ARROWSTAR */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_ARROW;
      else if (c == '*')
	return SWIG_TOKEN_ARROWSTAR;
      else {
	retract(s, 1);
	return SWIG_TOKEN_ARROW;
      }
      break;


    case 220:			/* STAR, TIMESEQUAL */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_STAR;
      else if (c == '=')
	return SWIG_TOKEN_TIMESEQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_STAR;
      }
      break;

    case 230:			/* XOR, XOREQUAL */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_XOR;
      else if (c == '=')
	return SWIG_TOKEN_XOREQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_XOR;
      }
      break;

    case 240:			/* LSHIFT, LSEQUAL */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_LSHIFT;
      else if (c == '=')
	return SWIG_TOKEN_LSEQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_LSHIFT;
      }
      break;

    case 250:			/* RSHIFT, RSEQUAL */
      if ((c = nextchar(s)) == 0)
	return SWIG_TOKEN_RSHIFT;
      else if (c == '=')
	return SWIG_TOKEN_RSEQUAL;
      else {
	retract(s, 1);
	return SWIG_TOKEN_RSHIFT;
      }
      break;


      /* An illegal character */

      /* Reverse string */
    case 900:
      if ((c = nextchar(s)) == 0) {
	Swig_error(cparse_file, cparse_start_line, "Unterminated character constant\n");
	return SWIG_TOKEN_ERROR;
      }
      if (c == '`') {
	Delitem(s->text, DOH_END);
	return (SWIG_TOKEN_RSTRING);
      }
      break;

    default:
      return SWIG_TOKEN_ILLEGAL;
    }
  }
}

/* -----------------------------------------------------------------------------
 * Scanner_token()
 *
 * Real entry point to return the next token. Returns 0 if at end of input.
 * ----------------------------------------------------------------------------- */

int Scanner_token(Scanner * s) {
  int t;
  Delete(s->error);
  if (s->nexttoken >= 0) {
    t = s->nexttoken;
    s->nexttoken = -1;
    return t;
  }
  s->start_line = 0;
  t = look(s);
  if (!s->start_line) {
    Setline(s->text,s->line);
  } else {
    Setline(s->text,s->start_line);
  }
  return t;
}

/* -----------------------------------------------------------------------------
 * Scanner_text()
 *
 * Return the lexene associated with the last returned token.
 * ----------------------------------------------------------------------------- */

String *Scanner_text(Scanner * s) {
  return s->text;
}

/* -----------------------------------------------------------------------------
 * Scanner_skip_line()
 *
 * Skips to the end of a line
 * ----------------------------------------------------------------------------- */

void Scanner_skip_line(Scanner * s) {
  char c;
  int done = 0;
  Clear(s->text);
  Setfile(s->text, Getfile(s->str));
  Setline(s->text, s->line);
  while (!done) {
    if ((c = nextchar(s)) == 0)
      return;
    if (c == '\\') {
      c = nextchar(s);
    } else if (c == '\n') {
      done = 1;
    }
  }
  return;
}

/* -----------------------------------------------------------------------------
 * Scanner_skip_balanced()
 *
 * Skips a piece of code enclosed in begin/end symbols such as '{...}' or
 * (...).  Ignores symbols inside comments or strings.
 * ----------------------------------------------------------------------------- */

int Scanner_skip_balanced(Scanner * s, int startchar, int endchar) {
  char c;
  int num_levels = 1;
  int l;
  int state = 0;
  char temp[2] = { 0, 0 };
  l = s->line;
  temp[0] = (char) startchar;
  Clear(s->text);
  Setfile(s->text, Getfile(s->str));
  Setline(s->text, s->line);

  Append(s->text, temp);
  while (num_levels > 0) {
    if ((c = nextchar(s)) == 0) {
      return -1;
    }
    switch (state) {
    case 0:
      if (c == startchar)
	num_levels++;
      else if (c == endchar)
	num_levels--;
      else if (c == '/')
	state = 10;
      else if (c == '\"')
	state = 20;
      else if (c == '\'')
	state = 30;
      break;
    case 10:
      if (c == '/')
	state = 11;
      else if (c == '*')
	state = 12;
      else
	state = 0;
      break;
    case 11:
      if (c == '\n')
	state = 0;
      else
	state = 11;
      break;
    case 12:
      if (c == '*')
	state = 13;
      break;
    case 13:
      if (c == '*')
	state = 13;
      else if (c == '/')
	state = 0;
      else
	state = 12;
      break;
    case 20:
      if (c == '\"')
	state = 0;
      else if (c == '\\')
	state = 21;
      break;
    case 21:
      state = 20;
      break;
    case 30:
      if (c == '\'')
	state = 0;
      else if (c == '\\')
	state = 31;
      break;
    case 31:
      state = 30;
      break;
    default:
      break;
    }
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Scanner_isoperator()
 *
 * Returns 0 or 1 depending on whether or not a token corresponds to a C/C++
 * operator.
 * ----------------------------------------------------------------------------- */

int
Scanner_isoperator(int tokval) {
  if (tokval >= 100) return 1;
  return 0;
}
