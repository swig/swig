/* -----------------------------------------------------------------------------
 * scanner.cxx
 *
 *     SWIG1.1 tokenizer.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "internal.h"
#include "parser.h"
#include <string.h>
#include <ctype.h>

extern "C" {
  #include "swig.h"
}

#define  YYBSIZE  8192

struct InFile {
  DOHFile *f;
  int     line_number;
  char   *in_file;
  int     extern_mode;
  int     force_extern;
  int     inline_mode;
  struct InFile *prev;
};

InFile  *in_head;

DOHFile *LEX_in = 0;
static DOHString     *header = 0;
static DOHString     *comment = 0;
       DOHString     *CCode = 0;            // String containing C code
static char           *yybuffer = 0;

static char    yytext[YYBSIZE];
static int     yylen = 0;
int            line_number = 1;
char          *input_file;
int            start_line = 0;
static  int    comment_start;
static  int    scan_init  = 0;
static  int    num_brace = 0;
static  int    last_brace = 0;
extern  int    Error;


/**************************************************************
 * scanner_init()
 *
 * Initialize buffers
 **************************************************************/

void scanner_init() {
  yybuffer = (char *) malloc(YYBSIZE);
  scan_init = 1;
  header = NewString("");
  comment = NewString("");
  CCode = NewString("");
}

/**************************************************************
 * scanner_file(FILE *f)
 *
 * Start reading from new file
 **************************************************************/
void scanner_file(DOHFile *f) {
  InFile *in;

  in = (InFile *) malloc(sizeof(InFile));
  in->f = f;
  in->in_file = input_file;
  in->extern_mode = WrapExtern;
  in->force_extern = ForceExtern;
  in->inline_mode = 0;
  if (!in_head) in->prev = 0;
  else in->prev = in_head;
  in_head = in;
  LEX_in = f;
  line_number = 1;
}

/**************************************************************
 * scanner_close()
 *
 * Close current input file and go to next
 **************************************************************/

void scanner_close() {
  InFile *p;
  if (!in_head) return;
  if (in_head->inline_mode) {
    Delete(LEX_in);
  }
  p = in_head->prev;
  if (p != 0) {
    LEX_in = p->f;
    line_number = p->line_number;
    input_file = p->in_file;
    WrapExtern = p->extern_mode;
    ForceExtern = p->force_extern;
    Inline = p->inline_mode;
  } else {
    LEX_in = 0;
  }
  free(in_head);
  in_head = p;
}

/**************************************************************
 * char nextchar()
 *
 * gets next character from input.
 * If we're in inlining mode, we actually retrieve a character
 * from inline_yybuffer instead.
 **************************************************************/

char nextchar() {
    int c = 0;

    while (LEX_in) {
      c = Getc(LEX_in);
      if (c == EOF) {
	scanner_close();
      } else {
	break;
      }
    }
    if (!LEX_in) return 0;
    if (yylen >= YYBSIZE) {
      Printf(stderr,"** FATAL ERROR.  Buffer overflow in scanner.cxx.\nReport this to swig-dev@cs.uchicago.edu.\n");
      SWIG_exit (EXIT_FAILURE);
    }
    yytext[yylen] = c;
    yylen++;
    if (c == '\n') {
      line_number++;
    }
    return(c);
}

void retract(int n) {
  int i;
  for (i = 0; i < n; i++) {
    yylen--;
    if (yylen >= 0) {
      Ungetc(yytext[yylen],LEX_in);
      if (yytext[yylen] == '\n') {
	line_number--;
      }
    }
  }
  if (yylen < 0) yylen = 0;
}

/**************************************************************
 * start_inline(char *text, int line)
 *
 * This grabs a chunk of text and tries to inline it into
 * the current file.  (This is kind of wild, but cool when
 * it works).
 *
 * If we're already in inlining mode, we will save the code
 * as a new fragment.
 **************************************************************/

void start_inline(char *text, int line) {
  InFile *in;

  in = (InFile *) malloc(sizeof(InFile));
  in->f = NewString(text);
  Seek(in->f,0,SEEK_SET);
  in->in_file = Swig_copy_string(input_file);
  in->line_number = line;
  in->extern_mode = WrapExtern;
  in->force_extern = ForceExtern;
  in->inline_mode = 1;
  in->prev = in_head;
  in_head = in;
  LEX_in = in->f;
  line_number = line;
  Inline = 1;
}

/**************************************************************
 * yycomment(char *, int line)
 *
 * Inserts a comment into a documentation entry.
 **************************************************************/

void yycomment(char *, int, int) {
}

/**************************************************************
 * void skip_brace(void)
 *
 * Found a {.
 * Skip all characters until we find a matching closed }.
 *
 * This function is used to skip over inlined C code and other
 * garbage found in interface files.
 ***************************************************************/

void skip_brace(void) {

  char c;
  Clear(CCode);
  Putc('{',CCode);
  while (num_brace > last_brace) {
    if ((c = nextchar()) == 0) {
      Printf(stderr,"%s : Line %d.  Missing '}'. Reached end of input.\n",
	      input_file, line_number);
      FatalError();
      return;
    }
    Putc(c,CCode);
    if (c == '{') num_brace++;
    if (c == '}') num_brace--;
    yylen = 0;
  }
}


/**************************************************************
 * void skip_template(void)
 *
 * Found a <.
 * Skip all characters until we find a matching closed >.
 *
 * This function is used to skip over C++ templated types
 * and objective-C protocols.
 ***************************************************************/

void skip_template(void) {

  char c;
  Clear(CCode);
  Putc('<',CCode);
  int  num_lt = 1;
  while (num_lt > 0) {
    if ((c = nextchar()) == 0) {
      Printf(stderr,"%s : Line %d.  Missing '>'. Reached end of input.\n",
	      input_file, line_number);
      FatalError();
      return;
    }
    Putc(c,CCode);
    if (c == '<') num_lt++;
    if (c == '>') num_lt--;
    yylen = 0;
  }
}

/**************************************************************
 * void skip_to_end(void)
 *
 * Skips to the @end directive in a Objective-C definition
 **************************************************************/

void skip_to_end(void) {
  char c;
  int  state = 0;
  yylen = 0;
  while ((c = nextchar())){
    switch(state) {
    case 0:
      if (c == '@') state = 1;
      else yylen = 0;
      break;
    case 1:
      if (isspace(c)) {
	if (strncmp(yytext,"@end",4) == 0) return;
	else {
	  yylen = 0;
	  state = 0;
	}
      } else {
	state = 1;
      }
      break;
    }
  }
  Printf(stderr,"%s : EOF. Missing @end. Reached end of input.\n",
	  input_file);
  FatalError();
  return;
}

/**************************************************************
 * void skip_decl(void)
 *
 * This tries to skip over an entire declaration.   For example
 *
 *  friend ostream& operator<<(ostream&, const char *s);
 *
 * or
 *  friend ostream& operator<<(ostream&, const char *s) { };
 *
 **************************************************************/

void skip_decl(void) {
  char c;
  int  done = 0;
  while (!done) {
    if ((c = nextchar()) == 0) {
      Printf(stderr,"%s : Line %d.  Missing semicolon. Reached end of input.\n",
	      input_file, line_number);
      FatalError();
      return;
    }
    if (c == '{') {
      last_brace = num_brace;
      num_brace++;
      break;
    }
    yylen = 0;
    if (c == ';') done = 1;
  }
  if (!done) {
    while (num_brace > last_brace) {
      if ((c = nextchar()) == 0) {
	Printf(stderr,"%s : Line %d.  Missing '}'. Reached end of input.\n",
		input_file, line_number);
	FatalError();
	return;
      }
      if (c == '{') num_brace++;
      if (c == '}') num_brace--;
      yylen = 0;
    }
  }
}

/* This function is called when a backslash is found in a string */
static void get_escape() {
  int result = 0;
  int state = 0;
  char  c;

  while(1) {
    c = nextchar();
    if (c == 0) break;
    switch(state) {
    case 0:
      if (c == 'n') {
	yytext[yylen-1] = '\n';
	return;
      }
      if (c == 'r') {
	yytext[yylen-1] = '\r';
	return;
      }
      if (c == 't') {
	yytext[yylen-1] = '\t';
	return;
      }
      if (c == 'a') {
	yytext[yylen-1] = '\a';
	return;
      }
      if (c == 'b') {
	yytext[yylen-1] = '\b';
	return;
      }
      if (c == 'f') {
	yytext[yylen-1] = '\f';
	return;
      }
      if (c == '\\') {
	yytext[yylen-1] = '\\';
	return;
      }
      if (c == 'v') {
	yytext[yylen-1] = '\v';
	return;
      }
      if (c == 'e') {
	yytext[yylen-1] = '\033';
	return;
      }
      if (c == '\'') {
	yytext[yylen-1] = '\'';
	return;
      }
      if (c == '\"') {
	yytext[yylen-1] = '\"';
	return;
      }
      if (c == '\n') {
	yylen--;
	return;
      }
      if (c == '0') {
	state = 10;
      }
      else if (c == 'x') {
	state = 20;
      } else {
	yytext[yylen-1] = '\\';
	yytext[yylen] = c;
	yylen++;
	return;
      }
      break;
    case 10:
      if (!isdigit(c)) {
	retract(1);
	yytext[yylen-1] = (char) result;
	return;
      }
      result = (result << 3) + (c - '0');
      yylen--;
      break;
    case 20:
      if (!isxdigit(c)) {
	retract(1);
	yytext[yylen-1] = (char) result;
	return;
      }
      if (isdigit(c))
	result = (result << 4) + (c - '0');
      else
	result = (result << 4) + (10 + tolower(c) - 'a');
      yylen--;
      break;
    }
  }
  return;
}

/**************************************************************
 * int yylook()
 *
 * Lexical scanner.
 * See Aho,Sethi, and Ullman,  pg. 106
 **************************************************************/

int yylook(void) {

    int      state;
    char     c = 0;

    state = 0;
    yylen = 0;
    while(1) {

/*	printf("State = %d\n", state);   */
	switch(state) {

	case 0 :
	  if((c = nextchar()) == 0) return (0);

	  /* Process delimeters */

	  if (c == '\n') {
	    state = 0;
	    yylen = 0;
	  } else if (isspace(c)) {
	    state = 0;
	    yylen = 0;
	  }

	  else if ((isalpha(c)) || (c == '_') || (c == '$')) state = 7;

	  /* Look for single character symbols */

	  else if (c == '(') return (LPAREN);
	  else if (c == ')') return (RPAREN);
	  else if (c == ';') return (SEMI);
	  else if (c == ',') return (COMMA);
	  else if (c == '*') return (STAR);
	  else if (c == '}') {
	    num_brace--;
	    if (num_brace < 0) {
	      Printf(stderr,"%s : Line %d. Error. Extraneous '}' (Ignored)\n",
		      input_file, line_number);
	      state = 0;
	      num_brace = 0;
	    } else {
	      return (RBRACE);
	    }
	  }
	  else if (c == '{') {
	    last_brace = num_brace;
	    num_brace++;
	    return (LBRACE);
	  }
	  else if (c == '=') return (EQUAL);
	  else if (c == '+') return (PLUS);
          else if (c == '-') return (MINUS);
	  else if (c == '&') return (AND);
	  else if (c == '|') return (OR);
	  else if (c == '^') return (XOR);
          else if (c == '<') state = 60;
	  else if (c == '>') state = 61;
	  else if (c == '~') return (NOT);
          else if (c == '!') return (LNOT);
	  else if (c == '\\') {
	    state = 99;
	  }
  	  else if (c == '[') return (LBRACKET);
	  else if (c == ']') return (RBRACKET);

	  /* Look for multi-character sequences */

	  else if (c == '/') state = 1;    // Comment (maybe)
	  else if (c == '\"') state = 2;   // Possibly a string
	  else if (c == '#') state = 3;    // CPP
	  else if (c == '%') state = 4;    // Directive
	  else if (c == '@') state = 4;    // Objective C keyword
	  else if (c == ':') state = 5;    // maybe double colon
	  else if (c == '0') state = 83;   // An octal or hex value
	  else if (c == '\'') state = 9;   // A character constant
	  else if (c == '.') state = 100;  // Maybe a number, maybe just a period
	  else if (c == '`') {
	    state = 200; // Back-tick type
	    yylen = 0;
	  }
	  else if (isdigit(c)) state = 8;  // A numerical value

	  else state = 99;
	  break;
	case 1:  /*  Comment block */
	  if ((c = nextchar()) == 0) return(0);
	  if (c == '/') {
	    comment_start = line_number;
	    Clear(comment);
	    Printf(comment,"  ");
	    state = 10;        // C++ style comment
	  } else if (c == '*') {
	    comment_start = line_number;
	    Clear(comment);
	    Printf(comment,"  ");
	    state = 11;   // C style comment
	  } else {
	    retract(1);
	    return(SLASH);
	  }
	  break;
	case 10:  /* C++ style comment */
	  if ((c = nextchar()) == 0) {
	    Printf(stderr,"%s : EOF. Unterminated comment detected.\n",input_file);
	    FatalError();
	    return 0;
	  }
	  if (c == '\n') {
	    Putc(c,comment);
	    // Add the comment to documentation
	    //	    yycomment(Char(comment),comment_start, column_start);
	    yylen = 0;
	    state = 0;
	  } else {
	    state = 10;
	    Putc(c,comment);
	    yylen = 0;
	  }
	  break;
	case 11: /* C style comment block */
	  if ((c = nextchar()) == 0) {
	    Printf(stderr,"%s : EOF. Unterminated comment detected.\n", input_file);
	    FatalError();
	    return 0;
	  }
	  if (c == '*') {
	    state = 12;
	  } else {
	    Putc(c,comment);
	    yylen = 0;
	    state = 11;
	  }
	  break;
	case 12: /* Still in C style comment */
	  if ((c = nextchar()) == 0) {
	    Printf(stderr,"%s : EOF. Unterminated comment detected.\n", input_file);
	    FatalError();
	    return 0;
	  }
	  if (c == '*') {
	    Putc(c,comment);
	    state = 12;
	  } else if (c == '/') {
	    Printf(comment,"  \n");
	    //	    yycomment(Char(comment),comment_start,column_start);
	    yylen = 0;
	    state = 0;
	  } else {
	    Putc('*',comment);
	    Putc(c,comment);
	    yylen = 0;
	    state = 11;
	  }
	  break;

	case 2: /* Processing a string */
	  if ((c = nextchar()) == 0) {
	    Printf(stderr,"%s : EOF. Unterminated string detected.\n", input_file);
	    FatalError();
	    return 0;
	  }
	  if (c == '\"') {
	    yytext[yylen-1] = 0;
	    yylval.id = Swig_copy_string(yytext+1);
	    return(STRING);
	  } else if (c == '\\') {
	    yylen--;
	    get_escape();
	    break;
	  } else state = 2;
	  break;

	case 3: /* a CPP directive */
	  if (( c= nextchar()) == 0) return 0;
	  if (c == '\n') {
	    retract(1);
	    yytext[yylen] = 0;
	    yylval.id = yytext;
	    return(POUND);
	  }
	  break;

	case 4: /* A wrapper generator directive (maybe) */
	  if (( c= nextchar()) == 0) return 0;
	  if (c == '{') {
	    state = 40;   /* Include block */
	    Clear(header);
	    start_line = line_number;
	  }
	  else if ((isalpha(c)) || (c == '_')) state = 7;
	  else {
	    retract(1);
	    state = 99;
	  }
	  break;

	case 40: /* Process an include block */
	  if ((c = nextchar()) == 0) {
	    Printf(stderr,"%s : EOF. Unterminated include block detected.\n", input_file);
	    FatalError();
	    return 0;
	  }
	  yylen = 0;
	  if (c == '%') state = 41;
	  else {
	    Putc(c,header);
	    yylen = 0;
	    state = 40;
	  }
	  break;
	case 41: /* Still processing include block */
	  if ((c = nextchar()) == 0) {
	    Printf(stderr,"%s : EOF. Unterminated include block detected.\n", input_file);
	    FatalError();
	    return 0;
	  }
	  if (c == '}') {
	    yylval.id = Char(header);
	    return(HBLOCK);
	  } else {
	    Putc('%',header);
	    Putc(c,header);
	    yylen = 0;
	    state = 40;
	  }
	  break;

	case 5: /* Maybe a double colon */

	  if (( c= nextchar()) == 0) return 0;
	  if ( c == ':') return DCOLON;
	  else {
	    retract(1);
	    return COLON;
	  }


	case 60: /* shift operators */
	  if ((c = nextchar()) == 0) return (0);
	  if (c == '<') return LSHIFT;
	  else {
	    retract(1);
	    return LESSTHAN;
	  }
	  break;
	case 61:
	  if ((c = nextchar()) == 0) return (0);
	  if (c == '>') return RSHIFT;
	  else {
	    retract(1);
            return GREATERTHAN;
	  }
	  break;
	case 7: /* Identifier */
	  if ((c = nextchar()) == 0) return(0);
	  if (isalnum(c) || (c == '_') || (c == '.') || (c == '$')) {
	    state = 7;
	  } else {
	    retract(1);
	    return(ID);
	  }
	  break;
	case 8: /* A numerical digit */
	  if ((c = nextchar()) == 0) return(0);
	  if (c == '.') {state = 81;}
	  else if ((c == 'e') || (c == 'E')) {state = 86;}
	  else if ((c == 'f') || (c == 'F')) {
             yytext[yylen] = 0;
	     yylval.id = Swig_copy_string(yytext);
	     return(NUM_FLOAT);
	  }
	  else if (isdigit(c)) { state = 8;}
	  else if ((c == 'l') || (c == 'L')) {
	    state = 87;
	  } else if ((c == 'u') || (c == 'U')) {
	    state = 88;
	  } else {
	      retract(1);
	      yytext[yylen] = 0;
	      yylval.id = Swig_copy_string(yytext);
	      return(NUM_INT);
	    }
	  break;
	case 81: /* A floating pointer number of some sort */
	  if ((c = nextchar()) == 0) return(0);
	  if (isdigit(c)) state = 81;
	  else if ((c == 'e') || (c == 'E')) state = 82;
          else if ((c == 'f') || (c == 'F') || (c == 'l') || (c == 'L')) {
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_FLOAT);
	  } else {
	    retract(1);
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_FLOAT);
	  }
	  break;
	case 82:
	  if ((c = nextchar()) == 0) return(0);
	  if ((isdigit(c)) || (c == '-') || (c == '+')) state = 86;
	  else {
	    retract(2);
	    yytext[yylen-1] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_INT);
	  }
	  break;
	case 83:
	  /* Might be a hexidecimal or octal number */
	  if ((c = nextchar()) == 0) return(0);
	  if (isdigit(c)) state = 84;
	  else if ((c == 'x') || (c == 'X')) state = 85;
	  else if (c == '.') state = 81;
	  else if ((c == 'l') || (c == 'L')) {
	    state = 87;
	  } else if ((c == 'u') || (c == 'U')) {
	    state = 88;
	  } else {
	    retract(1);
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_INT);
	  }
	  break;
	case 84:
	  /* This is an octal number */
	  if ((c = nextchar()) == 0) return (0);
	  if (isdigit(c)) state = 84;
	  else if ((c == 'l') || (c == 'L')) {
	    state = 87;
	  } else if ((c == 'u') || (c == 'U')) {
	    state = 88;
	  } else {
	    retract(1);
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_INT);
	  }
	  break;
	case 85:
	  /* This is an hex number */
	  if ((c = nextchar()) == 0) return (0);
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
	    retract(1);
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_INT);
	  }
	  break;

	case 86:
	  /* Rest of floating point number */

	  if ((c = nextchar()) == 0) return (0);
	  if (isdigit(c)) state = 86;
          else if ((c == 'f') || (c == 'F') || (c == 'l') || (c == 'L')) {
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_FLOAT);
	  } else {
	    retract(1);
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_FLOAT);
	  }
	  /* Parse a character constant. ie. 'a' */
	  break;

	case 87 :
	  /* A long integer of some sort */
	  if ((c = nextchar()) == 0) return (0);
	  if ((c == 'u') || (c == 'U')) {
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_ULONG);
	  } else {
	    retract(1);
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_LONG);
	  }

	case 88:
	  /* An unsigned integer of some sort */
	  if ((c = nextchar()) == 0) return (0);
	  if ((c == 'l') || (c == 'L')) {
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_ULONG);
	  } else {
	    retract(1);
	    yytext[yylen] = 0;
	    yylval.id = Swig_copy_string(yytext);
	    return(NUM_UNSIGNED);
	  }

	case 9:
	  if ((c = nextchar()) == 0) return (0);
	  if (c == '\\') {
	    yylen--;
	    get_escape();
	  } else if (c == '\'') {
	    yytext[yylen-1] = 0;
	    yylval.id = Swig_copy_string(yytext+1);
	    return(CHARCONST);
	  }
	  break;

	case 100:
	  if ((c = nextchar()) == 0) return (0);
	  if (isdigit(c)) state = 81;
	  else {
	    retract(1);
	    return(PERIOD);
	  }
	  break;
	case 200:
	  if ((c = nextchar()) == 0) return (0);
	  if (c == '`') {
	    yytext[yylen-1] = 0;
	    yylval.type = NewString(yytext);
	    return(TYPE_RAW);
	  }
	  break;

	default:
	  if (!Error) {
	    Printf(stderr,"%s : Line %d ::Illegal character '%c'=%d.\n",input_file, line_number,c,c);
	    FatalError();
	  }
	  state = 0;
  	  Error = 1;
	  return(ILLEGAL);
	}
    }
}

static int check_typedef = 0;

void scanner_check_typedef() {
  check_typedef = 1;
}

void scanner_ignore_typedef() {
  check_typedef = 0;
}


/**************************************************************
 * int yylex()
 *
 * Gets the lexene and returns tokens.
 *************************************************************/

extern "C" int yylex(void) {

    int   l;

    if (!scan_init) {
      scanner_init();
      //      if (LEX_in == NULL) LEX_in = stdin;
      //      scanner_file(LEX_in);
    }

    l = yylook();

    /* We got some sort of non-white space object.  We set the start_line
       variable unless it has already been set */

    if (!start_line) {
      start_line = line_number;
    }

    /* Copy the lexene */

    yytext[yylen] = 0;

    switch(l) {

      case ID:

	if (yytext[0] != '%') {
	  /* Look for keywords now */
	  
	  if (strcmp(yytext,"int") == 0) {
	    yylval.type = NewSwigType(T_INT);
	    return(TYPE_INT);
	  }
	  if (strcmp(yytext,"double") == 0) {
	    yylval.type = NewSwigType(T_DOUBLE);
	    return(TYPE_DOUBLE);
	  }
	  if (strcmp(yytext,"void") == 0) {
	    yylval.type = NewSwigType(T_VOID);
	    return(TYPE_VOID);
	  }
	  if (strcmp(yytext,"char") == 0) {
	    yylval.type = NewSwigType(T_CHAR);
	    return(TYPE_CHAR);
	  }
	  if (strcmp(yytext,"short") == 0) {
	    yylval.type = NewSwigType(T_SHORT);
	    return(TYPE_SHORT);
	  }
	  if (strcmp(yytext,"long") == 0) {
	    yylval.type = NewSwigType(T_LONG);
	    return(TYPE_LONG);
	  }
	  if (strcmp(yytext,"float") == 0) {
	    yylval.type = NewSwigType(T_FLOAT);
	    return(TYPE_FLOAT);
	  }
	  if (strcmp(yytext,"signed") == 0) {
	    yylval.type = NewSwigType(T_INT);
	    return(TYPE_SIGNED);
	  }
	  if (strcmp(yytext,"unsigned") == 0) {
	    yylval.type = NewSwigType(T_UINT);
	    return(TYPE_UNSIGNED);
	  }
	  if (strcmp(yytext,"bool") == 0) {
	    yylval.type = NewSwigType(T_BOOL);
	    return(TYPE_BOOL);
	  }
	  // C++ keywords
	  
	  if (CPlusPlus) {
	    if (strcmp(yytext,"class") == 0) return(CLASS);
	    if (strcmp(yytext,"private") == 0) return(PRIVATE);
	    if (strcmp(yytext,"public") == 0) return(PUBLIC);
	    if (strcmp(yytext,"protected") == 0) return(PROTECTED);
	    if (strcmp(yytext,"friend") == 0) return(FRIEND);
	    if (strcmp(yytext,"virtual") == 0) return(VIRTUAL);
	    if (strcmp(yytext,"operator") == 0) return(OPERATOR);
	    if (strcmp(yytext,"throw") == 0) return(THROW);
	    if (strcmp(yytext,"inline") == 0) return(yylex());
	    if (strcmp(yytext,"mutable") == 0) return(yylex());
	    if (strcmp(yytext,"template") == 0) return(TEMPLATE);
	  }
	  
	  // Objective-C keywords
	  if ((ObjC) && (yytext[0] == '@')) {
	    if (strcmp(yytext,"@interface") == 0) return (OC_INTERFACE);
	    if (strcmp(yytext,"@end") == 0) return (OC_END);
	    if (strcmp(yytext,"@public") == 0) return (OC_PUBLIC);
	    if (strcmp(yytext,"@private") == 0) return (OC_PRIVATE);
	    if (strcmp(yytext,"@protected") == 0) return (OC_PROTECTED);
	    if (strcmp(yytext,"@class") == 0) return(OC_CLASS);
	    if (strcmp(yytext,"@implementation") == 0) return(OC_IMPLEMENT);
	    if (strcmp(yytext,"@protocol") == 0) return(OC_PROTOCOL);
	  }
	  
	  // Misc keywords
	  
	  if (strcmp(yytext,"extern") == 0) return(EXTERN);
	  if (strcmp(yytext,"const") == 0) return(CONST);
	  if (strcmp(yytext,"static") == 0) return(STATIC);
	  if (strcmp(yytext,"struct") == 0) return(STRUCT);
	  if (strcmp(yytext,"union") == 0) return(UNION);
	  if (strcmp(yytext,"enum") == 0) return(ENUM);
	  if (strcmp(yytext,"sizeof") == 0) return(SIZEOF);
	  
	  if (strcmp(yytext,"typedef") == 0) {
	    yylval.ivalue = 0;
	    return(TYPEDEF);
	  }
	  
	  // Ignored keywords
	  
	  if (strcmp(yytext,"volatile") == 0) return(yylex());
	  
	  // SWIG directives
	} else {
	  if (strcmp(yytext,"%module") == 0) return(MODULE);
	  if (strcmp(yytext,"%init") == 0)  return(INIT);
	  if (strcmp(yytext,"%wrapper") == 0) return(WRAPPER);
	  if (strcmp(yytext,"%runtime") == 0) return(RUNTIME);
	  if (strcmp(yytext,"%header") == 0) return(HEADER);
	  if (strcmp(yytext,"%insert") == 0) return(INSERT);
	  if (strcmp(yytext,"%readonly") == 0) return(READONLY);
	  if (strcmp(yytext,"%readwrite") == 0) return(READWRITE);
	  if (strcmp(yytext,"%name") == 0) return(NAME);
	  if (strcmp(yytext,"%rename") == 0) return(RENAME);
	  if (strcmp(yytext,"%includefile") == 0) return(INCLUDE);
	  if (strcmp(yytext,"%externfile") == 0) return(WEXTERN);
	  if (strcmp(yytext,"%val") == 0) {
	    Printf(stderr,"%s:%d %%val directive deprecated (ignored).\n", input_file, line_number);
	    return (yylex());
	  }
	  if (strcmp(yytext,"%out") == 0) {
	    Printf(stderr,"%s:%d %%out directive deprecated (ignored).\n", input_file, line_number);
	    return(yylex());
	  }
	  if (strcmp(yytext,"%constant") == 0) return(CONSTANT);
	  if (strcmp(yytext,"%macro") == 0) return(SWIGMACRO);

	  if (strcmp(yytext,"%section") == 0) {
	    yylval.ivalue = line_number;
	    return(SECTION);
	  }
	  if (strcmp(yytext,"%subsection") == 0) {
	    yylval.ivalue = line_number;
	    return(SUBSECTION);
	  }
	  if (strcmp(yytext,"%subsubsection") == 0) {
	    yylval.ivalue = line_number;
	    return (SUBSUBSECTION);
	  }
	  if (strcmp(yytext,"%title") == 0) {
	    yylval.ivalue = line_number;
	    return(TITLE);
	  }
	  if (strcmp(yytext,"%style") == 0) return(STYLE);
	  if (strcmp(yytext,"%localstyle") == 0) return(LOCALSTYLE);
	  if (strcmp(yytext,"%typedef") == 0) {
	    yylval.ivalue = 1;
	    return(TYPEDEF);
	  }
	  if (strcmp(yytext,"%text") == 0) return(TEXT);
	  if (strcmp(yytext,"%native") == 0) return(NATIVE);
	  if (strcmp(yytext,"%disabledoc") == 0) return(DOC_DISABLE);
	  if (strcmp(yytext,"%enabledoc") == 0) return(DOC_ENABLE);
	  if (strcmp(yytext,"%pragma") == 0) return(PRAGMA);
	  if (strcmp(yytext,"%addmethods") == 0) return(ADDMETHODS);
	  if (strcmp(yytext,"%inline") == 0) return(INLINE);
	  if (strcmp(yytext,"%typemap") == 0) return(TYPEMAP);
	  if (strcmp(yytext,"%except") == 0) return(EXCEPT);
	  if (strcmp(yytext,"%importfile") == 0) return(IMPORT);
	  if (strcmp(yytext,"%echo") == 0) return(ECHO);
	  if (strcmp(yytext,"%new") == 0) return(NEW);
	  if (strcmp(yytext,"%apply") == 0) return(APPLY);
	  if (strcmp(yytext,"%clear") == 0) return(CLEAR);
	  if (strcmp(yytext,"%doconly") == 0) return(DOCONLY);
	  if (strcmp(yytext,"%types") == 0) return(TYPES);
	}
	  // Have an unknown identifier, as a last step, we'll
	// do a typedef lookup on it.

	if (check_typedef) {
	  if (SwigType_istypedef(yytext)) {
	    yylval.type = NewString(yytext);
	    return(TYPE_TYPEDEF);
	  }
	}

	yylval.id = Swig_copy_string(yytext);
	return(ID);
      default:
	return(l);
    }
}

// --------------------------------------------------------------
// scanner_clear_start()
//
// Clears the start of a declaration
// --------------------------------------------------------------

void scanner_clear_start() {
  start_line = 0;
}
