/****************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 ****************************************************************************/

static char cvsroot[] = "$Header$";

#include "swigcore.h"

struct Scanner {
  DOH           *text;                    /* Current token value */
  DOH           *scanobjs;                /* Objects being scanned */
  DOH           *str;                     /* Current object being scanned */
  char          *idstart;                 /* Optional identifier start characters */
  int            nexttoken;               /* Next token to be returned */
  int            start_line;              /* Starting line of certain declarations */
  int            string_start;
  int            line;
  int            yylen;                   /* Length of text pushed into text */
  DOH           *file; 
};

#include <ctype.h>

/* -----------------------------------------------------------------------------
 * $Header$
 *
 * scanner.c
 *
 * A generic C-based lexical scanner.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * Scanner *NewScanner() - Create a new scanner object. 
 * ----------------------------------------------------------------------------- */
Scanner *NewScanner() 
{
  Scanner *s;
  s = (Scanner *) malloc(sizeof(Scanner));
  s->line = 1;
  s->file = 0;
  s->nexttoken = -1;
  s->start_line = 1;
  s->string_start = 0;
  s->yylen = 0;
  s->idstart = "";
  s->scanobjs = NewList();
  s->text = NewString("");
  s->str = 0;
  return s;
}

/* -----------------------------------------------------------------------------
 * DelScanner(Scanner *s) -  Delete a Scanner object
 * ----------------------------------------------------------------------------- */
void DelScanner(Scanner *s)
{
  assert(s);
  Delete(s->scanobjs);
  Delete(s->text);
  Delete(s->file);
  free(s);
}

/* -----------------------------------------------------------------------------
 * Scanner_clear(Scanner *s) - Clear a scanner object
 * ----------------------------------------------------------------------------- */
void Scanner_clear(Scanner *s) {
  assert(s);
  Delete(s->str);
  Clear(s->text);
  Clear(s->scanobjs);
  s->line = 1;
  s->nexttoken = -1;
  s->start_line = 0;
  s->string_start = 0;
  s->yylen = 0;
}

/* -----------------------------------------------------------------------------
 * Scanner_push(Scanner *s, DOH *txt) - Push text into the scanner
 * ----------------------------------------------------------------------------- */

void Scanner_push(Scanner *s, DOH *txt)
{
  assert(s && txt);
  Push(s->scanobjs,txt);
  if (s->str) Delete(s->str);
  s->str = txt;
  Incref(s->str);
  s->line = Getline(txt);
}
/* -----------------------------------------------------------------------------
 * Scanner_pushtoken(Scanner *s, int nt)
 *
 * Set the next processing token.
 * ----------------------------------------------------------------------------- */

void Scanner_pushtoken(Scanner *s, int nt) {
  assert(s);
  assert((nt >= 0) && (nt < MAXTOKENS));
  s->nexttoken = nt;
}

/* -----------------------------------------------------------------------------
 * Scanner_set_location(Scanner *s, DOH *file, int line)
 * ----------------------------------------------------------------------------- */
void
Scanner_set_location(Scanner *s, DOH *file, int line)
{
  Setline(s->str,line);
  Setfile(s->str,file);
}

/* -----------------------------------------------------------------------------
 * Scanner_get_file(Scanner *s) - Get current file
 * ----------------------------------------------------------------------------- */

DOH *
Scanner_get_file(Scanner *s) {
  return Getfile(s->str);
}

int
Scanner_get_line(Scanner *s) {
  return Getline(s->str);
}

/* -----------------------------------------------------------------------------
 * char nextchar(Scanner *s) 
 * 
 * Returns the next character from the scanner or 0 if end of the string.
 * ----------------------------------------------------------------------------- */
static char
nextchar(Scanner *s)
{
  char c[2] = {0,0};
  int nc;
  if (!s->str) return 0;
  while ((nc = Getc(s->str)) == EOF) {
    Delete(s->str);
    s->str = 0;
    Delitem(s->scanobjs,0);
    if (Len(s->scanobjs) == 0) return 0;
    s->str = Getitem(s->scanobjs,0);
    s->line = Getline(s->str);
    if (s->str)
      Incref(s->str);
  }
  if (nc == '\n') s->line++;
  c[0] = (char) nc;
  c[1] = 0;
  Append(s->text,c);
  return c[0];
}

/* -----------------------------------------------------------------------------
 * void retract(Scanner *s, int n)
 *
 * Retract n characters
 * ----------------------------------------------------------------------------- */
static void
retract(Scanner *s, int n) {
  int i, l;
  char *str;
  
  str = Char(s->text);
  l = Len(s->text);
  assert(n <= l);
  for (i = 0; i < n; i++) {
    if (str[l-1] == '\n') {
      s->line--;
    }
    /*    //    Ungetc(str[l-1],s->str); */
    Seek(s->str,-1, SEEK_CUR);
    Delitem(s->text,DOH_END);
  }
}

/* -----------------------------------------------------------------------------
 * int look(Scanner *s)
 *
 * Get the next token.
 * ----------------------------------------------------------------------------- */

static int
look(Scanner *s) 
{
    int      state;
    char     c = 0;

    state = 0;
    Clear(s->text);
    Setline(s->text, Getline(s->str));
    Setfile(s->text, Getfile(s->str));
    while(1) {
	switch(state) {
	case 0 :
	    if((c = nextchar(s)) == 0) return(0);
      
	    /* Process delimeters */

	    if (c == '\n') {
		return TOKEN_ENDLINE;
	    } else if (!isspace(c)) {
	      retract(s,1);
	      state = 1000;
	      Clear(s->text);
	      Setline(s->text, Getline(s->str));
	      Setfile(s->text, Getfile(s->str));
	    }
	    break;

	case 1000:
	  if ((c = nextchar(s)) == 0) return (0);
	  if (c == '%') state = 4;         /* Possibly a SWIG directive */

	    /* Look for possible identifiers */

	    else if ((isalpha(c)) || (c == '_') || (strchr(s->idstart,c))) state = 7;
      
	    /* Look for single character symbols */
      
	    else if (c == '(') return TOKEN_LPAREN;
	    else if (c == ')') return TOKEN_RPAREN;
	    else if (c == ';') return TOKEN_SEMI;
	    else if (c == ',') return TOKEN_COMMA;
	    else if (c == '*') return TOKEN_STAR;
	    else if (c == '}') return TOKEN_RBRACE;
	    else if (c == '{') return TOKEN_LBRACE;
	    else if (c == '=') state = 33;
	    else if (c == '+') return TOKEN_PLUS;
	    else if (c == '-') return TOKEN_MINUS;
	    else if (c == '&') state = 31;
	    else if (c == '|') state = 32;
	    else if (c == '^') return TOKEN_XOR;
	    else if (c == '<') state = 60;
	    else if (c == '>') state = 61;
	    else if (c == '~') return TOKEN_NOT;
	    else if (c == '!') state = 3;
	    else if (c == '\\') return TOKEN_BACKSLASH;
	    else if (c == '[') return TOKEN_LBRACKET;
	    else if (c == ']') return TOKEN_RBRACKET;
	    else if (c == '@') return TOKEN_AT;
	    else if (c == '$') return TOKEN_DOLLAR;
	    else if (c == '#') return TOKEN_POUND;

	    /* Look for multi-character sequences */
	  
	    else if (c == '/') state = 1;    /* Comment (maybe)  */
	    else if (c == '\"') {
		state = 2;   /* Possibly a string */
		s->string_start = s->line;
	    }

	    else if (c == ':') state = 5;     /* maybe double colon */
	    else if (c == '0') state = 83;    /* An octal or hex value */
	    else if (c == '\'') {
		s->string_start = s->line;
		state = 9;    /* A character constant */
	    }
	    else if (c == '.') state = 100;   /* Maybe a number, maybe just a period */
	    else if (isdigit(c)) state = 8;   /* A numerical value */
	    else state = 99;                  /* An error */
	    break;

	case 1:  /*  Comment block */
	    if ((c = nextchar(s)) == 0) return(0);
	    if (c == '/') {
		state = 10;         /* C++ style comment */
		Clear(s->text);
		Setline(s->text, Getline(s->str));
		Setfile(s->text, Getfile(s->str));

		Append(s->text,"  ");
	    } else if (c == '*') {
		state = 11;    /* C style comment */
		Clear(s->text);
		Setline(s->text, Getline(s->str));
		Setfile(s->text, Getfile(s->str));
		Append(s->text,"  ");
	    } else {
		retract(s,1);
		return TOKEN_SLASH;
	    }
	    break;
	case 10:  /* C++ style comment */
	    if ((c = nextchar(s)) == 0) {
		/*	add_error(0,"Unterminated comment",comment_start); */
		return 0;
	    }
	    if (c == '\n') {
		return TOKEN_ENDLINE;
	    } else {
		state = 10;
	    }
	    break;
	case 11: /* C style comment block */
	    if ((c = nextchar(s)) == 0) {
		/* add_error(0,"Unterminated comment",comment_start); */
		return 0;
	    }
	    if (c == '*') {
		state = 12;
	    } else {
		state = 11;
	    }
	    break;
	case 12: /* Still in C style comment */
	    if ((c = nextchar(s)) == 0) {
		/*	add_error(0,"Unterminated comment",comment_start); */
		return 0;
	    }
	    if (c == '*') {
		state = 12;
	    } else if (c == '/') {
		Clear(s->text);
		state = 0;
	    } else {
		state = 11;
	    }
	    break;
      
	case 2: /* Processing a string */
	    if ((c = nextchar(s)) == 0) {
		/*	add_error(0,"Unterminated string", string_start); */
		return 0;
	    }
	    if (c == '\"') {
		return TOKEN_STRING;
	    } else if (c == '\\') {
		state = 21;             /* Possibly an escape sequence. */
		break;
	    } else state = 2;
	    break;
	case 21: /* An escape sequence. get next character, then go
		    back to processing strings */
	    if ((c = nextchar(s)) == 0) return 0;
	    state = 2;
	    break;

	case 3: /* Maybe a not equals */
	    if ((c = nextchar(s)) == 0) return TOKEN_LNOT;
	    else if (c == '=') return TOKEN_NOTEQUAL;
	    else {
		retract(s,1);
		return TOKEN_LNOT;
	    }
	    break;

	case 31: /* AND or Logical AND */
	    if ((c = nextchar(s)) == 0) return TOKEN_AND;
	    else if (c == '&') return TOKEN_LAND;
	    else {
		retract(s,1);
		return TOKEN_AND;
	    }
	    break;

	case 32: /* OR or Logical OR */
	    if ((c = nextchar(s)) == 0) return TOKEN_OR;
	    else if (c == '|') return TOKEN_LOR;
	    else {
		retract(s,1);
		return TOKEN_OR;
	    }
	    break;

	case 33: /* EQUAL or EQUALTO */
	    if ((c = nextchar(s)) == 0) return TOKEN_EQUAL;
	    else if (c == '=') return TOKEN_EQUALTO;
	    else {
		retract(s,1);
		return TOKEN_EQUAL;
	    }
	    break;

	case 4: /* A wrapper generator directive (maybe) */
	    if (( c= nextchar(s)) == 0) return TOKEN_PERCENT;
	    if (c == '{') {
		state = 40;   /* Include block */
		Clear(s->text);
		Setline(s->text, Getline(s->str));
		Setfile(s->text, Getfile(s->str));
		s->start_line = s->line;
	    }
	    else if (strchr(s->idstart,'%') && ((isalpha(c)) || (c == '_'))) state = 7;
	    else {
		retract(s,1);
		return TOKEN_PERCENT;
	    }
	    break;
	  
	case 40: /* Process an include block */
	    if ((c = nextchar(s)) == 0) {
		/* add_error(0,"Unterminated code block.", start_line); */
		return 0;
	    }
	    if (c == '%') state = 41;
	    break;
	case 41: /* Still processing include block */
	    if ((c = nextchar(s)) == 0) {
		/*	add_error(0,"Unterminated code block.", start_line); */
		return 0;
	    }
	    if (c == '}') {
		Delitem(s->text,DOH_END);
		Delitem(s->text,DOH_END);
		return TOKEN_CODEBLOCK;
	    } else {
		state = 40;
	    }
	    break;

	case 5: /* Maybe a double colon */

	    if (( c = nextchar(s)) == 0) return TOKEN_COLON;
	    if ( c == ':') return TOKEN_DCOLON;
	    else {
		retract(s,1);
		return TOKEN_COLON;
	    }
	    break;

	case 60: /* shift operators */
	    if ((c = nextchar(s)) == 0) return TOKEN_LESSTHAN;
	    if (c == '<') return TOKEN_LSHIFT;
	    else if (c == '=') return TOKEN_LTEQUAL;
	    else {
		retract(s,1);
		return TOKEN_LESSTHAN;
	    }
	    break;
	case 61: 
	    if ((c = nextchar(s)) == 0) return TOKEN_GREATERTHAN;
	    if (c == '>') return TOKEN_RSHIFT;
	    else if (c == '=') return TOKEN_GTEQUAL;
	    else {
		retract(s,1);
		return TOKEN_GREATERTHAN;
	    }
	    break;
	case 7: /* Identifier */
	    if ((c = nextchar(s)) == 0) return TOKEN_ID;
	    if (isalnum(c) || (c == '_') || (c == '$')) {
		state = 7;
	    } else {
		retract(s,1);
		return TOKEN_ID;
	    }
	    break;
	case 8: /* A numerical digit */
	    if ((c = nextchar(s)) == 0) return TOKEN_INT;
	    if (c == '.') {state = 81;}
	    else if ((c == 'e') || (c == 'E')) {state = 86;}
	    else if ((c == 'f') || (c == 'F')) {
		Delitem(s->text,DOH_END);
		return TOKEN_FLOAT;
	    } else if (isdigit(c)) { state = 8;}
	    else if ((c == 'l') || (c == 'L')) {
		state = 87;
	    } else if ((c == 'u') || (c == 'U')) {
		state = 88;
	    } else {
		retract(s,1);
		return TOKEN_INT;
	    }
	    break;
	case 81: /* A floating pointer number of some sort */
	    if ((c = nextchar(s)) == 0) return TOKEN_DOUBLE;
	    if (isdigit(c)) state = 81;
	    else if ((c == 'e') || (c == 'E')) state = 82;
	    else if ((c == 'f') || (c == 'F') || (c == 'l') || (c == 'L')) {
		Delitem(s->text,DOH_END);
		return TOKEN_FLOAT;
	    } else {
		retract(s,1);
		return(TOKEN_DOUBLE);
	    }
	    break;
	case 82:
	    if ((c = nextchar(s)) == 0) {
		retract(s,1);
		return TOKEN_INT;
	    }
	    if ((isdigit(c)) || (c == '-') || (c == '+')) state = 86;
	    else {
		retract(s,2);
		return(TOKEN_INT);
	    }
	    break;
	case 83:
	    /* Might be a hexidecimal or octal number */
	    if ((c = nextchar(s)) == 0) return TOKEN_INT;
	    if (isdigit(c)) state = 84;
	    else if ((c == 'x') || (c == 'X')) state = 85;
	    else if (c == '.') state = 81;
	    else if ((c == 'l') || (c == 'L')) {
		state = 87;
	    } else if ((c == 'u') || (c == 'U')) {
		state = 88;
	    } else {
		retract(s,1);
		return TOKEN_INT;
	    }
	    break;
	case 84:
	    /* This is an octal number */
	    if ((c = nextchar(s)) == 0) return TOKEN_INT;
	    if (isdigit(c)) state = 84;
	    else if ((c == 'l') || (c == 'L')) {
		state = 87;
	    } else if ((c == 'u') || (c == 'U')) {
		state = 88;
	    } else {
		retract(s,1);
		return TOKEN_INT;
	    }
	    break;
	case 85:
	    /* This is an hex number */
	    if ((c = nextchar(s)) == 0) return TOKEN_INT;
	    if ((isdigit(c)) || (c=='a') || (c=='b') || (c=='c') ||
		(c=='d') || (c=='e') || (c=='f') || (c=='A') ||
		(c=='B') || (c=='C') || (c=='D') || (c=='E') ||
		(c=='F'))
		state = 85;
	    else if ((c == 'l') || (c == 'L')) {
		state = 87;
	    } else if ((c == 'u') || (c == 'U')) {
		state = 88;
	    } else {
		retract(s,1);
		return TOKEN_INT;
	    }
	    break;

	case 86:
	    /* Rest of floating point number */
      
	    if ((c = nextchar(s)) == 0) return TOKEN_DOUBLE;
	    if (isdigit(c)) state = 86;
	    else if ((c == 'f') || (c == 'F')) {
		Delitem(s->text,DOH_END);
		return TOKEN_FLOAT;
	    } else if ((c == 'l') || (c == 'L')) {
		Delitem(s->text,DOH_END);
		return TOKEN_DOUBLE;
	    } else {
		retract(s,1);
		return TOKEN_DOUBLE;
	    }
	    break;

	case 87 :
	    /* A long integer of some sort */
	    if ((c = nextchar(s)) == 0) return TOKEN_LONG;
	    if ((c == 'u') || (c == 'U')) {
		return TOKEN_ULONG;
	    } else {
		retract(s,1);
		return TOKEN_LONG;
	    } 

	    /* An unsigned number */
	case 88:

	    if ((c = nextchar(s)) == 0) return TOKEN_UINT;
	    if ((c == 'l') || (c == 'L')) {
		return TOKEN_ULONG;
	    } else {
		retract(s,1);
		return TOKEN_UINT;
	    } 
      
	    /* A character constant */
	case 9:
	    if ((c = nextchar(s)) == 0) {
		/* add_error(0,"Unterminated character constant", string_start); */
		return 0;
	    }
	    if (c == '\'') {
		return(TOKEN_CHAR);
	    } else if (c == '\\') state = 91;
	    break;

	case 91:
	    if ((c = nextchar(s)) == 0) {
		/* add_error(0,"Unterminated character constant", string_start); */
		return 0;
	    }
	    state = 9;
	    break;

	    /* A period or maybe a floating point number */

	case 100:
	    if ((c = nextchar(s)) == 0) return (0);
	    if (isdigit(c)) state = 81;
	    else {
		retract(s,1);
		return TOKEN_PERIOD;
	    }
	    break;
      
	    /* An illegal character */
	default:
	  return TOKEN_ILLEGAL;
	}
    }
}

/* -----------------------------------------------------------------------------
 * int Scanner_token(Scanner *s)
 *
 * Return the next token or 0 if at the end of the string
 * ----------------------------------------------------------------------------- */

int
Scanner_token(Scanner *s)
{
    int t;
    Clear(s->text);
    if (s->nexttoken >= 0) {
	t = s->nexttoken;
	s->nexttoken = -1;
	return t;
    }
    t = look(s);
    return t;
}

/* -----------------------------------------------------------------------------
 * DOH *Scanner_text(Scanner *s)
 *
 * Return the text associated with the last token returned.
 * ----------------------------------------------------------------------------- */
DOH *
Scanner_text(Scanner *s)
{
    return s->text;
}

/* -----------------------------------------------------------------------------
 * void Scanner_skip_line(Scanner *s)
 *
 * Skips to the end of a line
 * ----------------------------------------------------------------------------- */

void
Scanner_skip_line(Scanner *s)
{
    char c;
    int done = 0;
    Clear(s->text);
    Setfile(s->text,Getfile(s->str));
    Setline(s->text,Getline(s->str));
    while (!done) {
	if ((c = nextchar(s)) == 0) return;
	if (c == '\\') c = nextchar(s);
	else if (c == '\n') done = 1;
    }
    return;
}

/* -----------------------------------------------------------------------------
 * void Scanner_skip_balanced(Scanner *s, int start, int end)
 *
 * Skips a piece of code enclosed in begin/end symbols such as '{...}' or
 * (...).  Ignores symbols inside comments or strings.
 * ----------------------------------------------------------------------------- */

int 
Scanner_skip_balanced(Scanner *s, int startchar, int endchar)
{
    char c;
    int  num_levels = 1;
    int  l;
    int  state = 0;
    char temp[2] = {0,0};
    l = s->line;
    temp[0] = (char) startchar;
    Clear(s->text);
    Setfile(s->text,Getfile(s->str));
    Setline(s->text,Getline(s->str));

    Append(s->text,temp);
    while (num_levels > 0) {
	if ((c = nextchar(s)) == 0) {
	    return -1;
	}
	switch(state) {
	case 0:
	    if (c == startchar) num_levels++;
	    else if (c == endchar) num_levels--;
	    else if (c == '/') state = 10;
	    else if (c == '\"') state = 20;
	    else if (c == '\'') state = 30;
	    break;
	case 10:
	    if (c == '/') state = 11;
	    else if (c == '*') state = 12;
	    else state = 0;
	    break;
	case 11:
	    if (c == '\n') state = 0;
	    else state = 11;
	    break;
	case 12:
	    if (c == '*') state = 13;
	    break;
	case 13:
	    if (c == '*') state = 13;
	    else if (c == '/') state = 0;
	    else state = 12;
	    break;
	case 20:
	    if (c == '\"') state = 0;
	    else if (c == '\\') state = 21;
	    break;
	case 21:
	    state = 20;
	    break;
	case 30:
	    if (c == '\'') state = 0;
	    else if (c == '\\') state = 31;
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




