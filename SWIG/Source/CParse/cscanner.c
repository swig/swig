/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * scanner.c
 *
 * SWIG tokenizer.
 * ----------------------------------------------------------------------------- */

char cvsroot_cscanner_c[] = "$Header$";

#include "cparse.h"
#include "parser.h"
#include <string.h>
#include <ctype.h>

#define  YYBSIZE  8192

typedef struct InFile {
  DOHFile *f;
  int     line_number;
  char   *in_file;
  struct InFile *prev;
} InFile;

static InFile  *in_head;

DOHFile *LEX_in = 0;
static DOHString     *header = 0;
static DOHString     *comment = 0;
DOHString            *scanner_ccode = 0;            /* String containing C code */
static char          *yybuffer = 0;

static char    yytext[YYBSIZE];
static int     yylen = 0;
int            cparse_line = 1;
char          *cparse_file;
int            cparse_start_line = 0;

static  int    comment_start;
static  int    scan_init  = 0;
static  int    num_brace = 0;
static  int    last_brace = 0;
static  int    last_id = 0;
static  int    rename_active = 0;
static  int    swigtemplate_active = 0;
        int    cparse_cplusplus = 0;
static  int    expanding_macro = 0;
/* -----------------------------------------------------------------------------
 * Swig_cparse_cplusplus()
 * ----------------------------------------------------------------------------- */

void
Swig_cparse_cplusplus(int v) {
  cparse_cplusplus = v;
}

/* ----------------------------------------------------------------------
 * locator()
 *
 * Support for locator strings.   These are strings of the form
 * @filename,line,id@ emitted by the SWIG preprocessor.  They
 * are primarily used for macro line number reporting 
 * ---------------------------------------------------------------------- */
#if 1

/* we just use the locator to mark when active/deactive the linecounting */

static void
scanner_locator(String *loc) {
  if (Equal(loc,"@SWIG@"))  {    
    /* End locator. */
    if (expanding_macro) --expanding_macro;
  } else {
    /* Begin locator. */
    ++expanding_macro;
  }
}

#else

typedef struct Locator {
  char           *filename;
  int             line_number;
  struct Locator *next;
} Locator;

static Locator *locs = 0;
  
static void
scanner_locator(String *loc) {
  int c;
  Locator *l;
  Seek(loc,1,SEEK_SET);
  c = Getc(loc);
  if (c == '@') {
    /* Empty locator.  We pop the last location off */
    if (locs) {
      cparse_file = locs->filename;
      cparse_line = locs->line_number;
      l = locs->next;
      free(locs);
      locs = l;
    }
    /*    Printf(stderr,"location: %s:%d\n",cparse_file,cparse_line);*/
    return;
  }

  /* We're going to push a new location */
  l = (Locator *) malloc(sizeof(Locator));
  l->filename = cparse_file;
  l->line_number = cparse_line;
  l->next = locs;
  locs = l;
  
  /* Now, parse the new location out of the locator string */
  {
    String *fn = NewStringEmpty();
    Putc(c,fn);
    
    while ((c = Getc(loc)) != EOF) {
      if ((c == '@') || (c == ',')) break;
      Putc(c,fn);
    }

    cparse_file = Swig_copy_string(Char(fn));
    Clear(fn);
  
    cparse_line = 1;
    /* Get the line number */
    while ((c = Getc(loc)) != EOF) {
      if ((c == '@') || (c == ',')) break;
      Putc(c,fn);
    }

    cparse_line = atoi(Char(fn));
    Clear(fn);

    /* Get the rest of it */
    while (( c= Getc(loc)) != EOF) {
      if (c == '@') break;
      Putc(c,fn);
    }
    /*  Printf(stderr,"location: %s:%d\n",cparse_file,cparse_line); */
    Delete(fn);
  }
}
#endif

/* ----------------------------------------------------------------------------
 * scanner_init()
 *
 * Initialize buffers
 * ------------------------------------------------------------------------- */

void scanner_init() {
  yybuffer = (char *) malloc(YYBSIZE);
  scan_init = 1;
  header = NewStringEmpty();
  comment = NewStringEmpty();
  scanner_ccode = NewStringEmpty();
}

/* ----------------------------------------------------------------------------
 * scanner_file(FILE *f)
 *
 * Start reading from new file
 * ------------------------------------------------------------------------- */
void scanner_file(DOHFile *f) {
  InFile *in;

  in = (InFile *) malloc(sizeof(InFile));
  in->f = f;
  in->in_file = cparse_file;
  in->line_number = 1;
  if (!in_head) in->prev = 0;
  else in->prev = in_head;
  in_head = in;
  LEX_in = f;
  cparse_line = 1;
}

/* ----------------------------------------------------------------------------
 * scanner_close()
 *
 * Close current input file and go to next
 * ------------------------------------------------------------------------- */

void scanner_close() {
  InFile *p;
  if (!in_head) return;
  Delete(LEX_in);
  p = in_head->prev;
  if (p != 0) {
    LEX_in = p->f;
    cparse_line = p->line_number;
    cparse_file = p->in_file;
  } else {
    LEX_in = 0;
  }
  free(in_head);
  in_head = p;
}

/* ----------------------------------------------------------------------------
 * char nextchar()
 *
 * gets next character from input.
 * If we're in inlining mode, we actually retrieve a character
 * from inline_yybuffer instead.
 * ------------------------------------------------------------------------- */

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
      Printf(stderr,"** FATAL ERROR.  Buffer overflow in scanner.c.\nPlease report to the SWIG developers.\n");
      exit (EXIT_FAILURE);
    }
    yytext[yylen] = c;
    yylen++;
    if (c == '\n') {
      if (!expanding_macro) cparse_line++;
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
	if (!expanding_macro)  cparse_line--;
      }
    }
  }
  if (yylen < 0) yylen = 0;
}

/* ----------------------------------------------------------------------------
 * start_inline(char *text, int line)
 *
 * This grabs a chunk of text and tries to inline it into
 * the current file.  (This is kind of wild, but cool when
 * it works).
 *
 * If we're already in inlining mode, we will save the code
 * as a new fragment.
 * ------------------------------------------------------------------------- */

void start_inline(char *text, int line) {
  InFile *in;

  if (!in_head) return;
  /* Save current state */
  in_head->line_number = cparse_line;
  in_head->in_file = cparse_file;

  in = (InFile *) malloc(sizeof(InFile));
  in->f = NewString(text);
  Seek(in->f,0,SEEK_SET);
  in->in_file = Swig_copy_string(cparse_file);
  in->line_number = line;
  in->prev = in_head;
  in_head = in;
  LEX_in = in->f;
  cparse_line = line;
}

/* ----------------------------------------------------------------------------
 * yycomment(char *, int line)
 *
 * Inserts a comment into a documentation entry.
 * ------------------------------------------------------------------------- */

/*
void yycomment(char *a, int b, int c) {
}
*/

/* -----------------------------------------------------------------------------
 * skip_balanced()
 *
 * Skips a piece of code enclosed in begin/end symbols such as '{...}' or
 * (...).  Ignores symbols inside comments or strings.
 * ----------------------------------------------------------------------------- */

void
skip_balanced(int startchar, int endchar) {
    char c;
    int  num_levels = 1;
    int  state = 0;
    char temp[2] = {0,0};
    int  start_line = cparse_line;

    Clear(scanner_ccode);
    Putc(startchar,scanner_ccode);
    temp[0] = (char) startchar;
    while (num_levels > 0) {
      c = nextchar();
      if (c == 0) {
	  Swig_error(cparse_file, start_line, "Missing '%c'. Reached end of input.\n", endchar);
	  return;
      }
      Putc(c,scanner_ccode);
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
      yylen = 0;
    }
    if (endchar == '}') num_brace--;
    return;
}

/* ----------------------------------------------------------------------------
 * void skip_decl(void)
 *
 * This tries to skip over an entire declaration.   For example
 *
 *  friend ostream& operator<<(ostream&, const char *s);
 *
 * or
 *  friend ostream& operator<<(ostream&, const char *s) { };
 *
 * ------------------------------------------------------------------------- */

void skip_decl(void) {
  char c;
  int  done = 0;  
  int start_line = cparse_line;

  while (!done) {
    if ((c = nextchar()) == 0) {
      if (!Swig_error_count()) {
	Swig_error(cparse_file,start_line - 1,"Missing semicolon. Reached end of input.\n");
      }
      
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
	if (!Swig_error_count()) {
	  Swig_error(cparse_file,start_line - 1,"Missing '}'. Reached end of input.\n");
	}
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
  int c;

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
      if (isdigit(c)) {
	state = 10;
	result = (c-'0');
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

/* ----------------------------------------------------------------------------
 * int yylook()
 *
 * Lexical scanner.
 * See Aho,Sethi, and Ullman,  pg. 106
 * ------------------------------------------------------------------------- */

int yylook(void) {

    int      state;
    int      c = 0;

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
	    /*	    last_id = 0;*/
	  } else if (isspace(c) || (c=='\\')) {
	    state = 0;
	    yylen = 0;
	    /*	    last_id = 0; */
	  }

	  else if ((isalpha(c)) || (c == '_')) state = 7;
	  else if (c == '$') state = 75;

	  /* Look for single character symbols */

	  else if (c == '(') return (LPAREN);
	  else if (c == ')') return (RPAREN);
	  else if (c == ';') {
	    swigtemplate_active = 0;
	    return (SEMI);
	  }
	  
	  else if (c == ',') return (COMMA);
	  else if (c == '*') return (STAR);
	  else if (c == '}') {
	    num_brace--;
	    if (num_brace < 0) {
	      Swig_error(cparse_file, cparse_line, "Syntax error. Extraneous '}'\n");
	      state = 0;
	      num_brace = 0;
	    } else {
	      return (RBRACE);
	    }
	  }
	  else if (c == '{') {
	    cparse_start_line = cparse_line;
	    last_brace = num_brace;
	    num_brace++;
	    return (LBRACE);
	  }
	  else if (c == '=') return (EQUAL);
	  else if (c == '+') return (PLUS);
          else if (c == '-') return (MINUS);
	  else if (c == '&') {
	    state = 300;
	  } 
	  else if (c == '|') {
	    state = 301;
	  }
	  else if (c == '^') return (XOR);
          else if (c == '<') state = 60;
	  else if (c == '>') state = 61;
	  else if (c == '~') {
	    return (NOT);
	  }
          else if (c == '!') return (LNOT);
	  else if (c == '\\') {
	    state = 99;
	  }
  	  else if (c == '[') return (LBRACKET);
	  else if (c == ']') return (RBRACKET);

	  /* Look for multi-character sequences */

	  else if (c == '/') state = 1;    /* Comment (maybe) */
	  else if (c == '\"') state = 2;   /* Possibly a string */
	  else if (c == '#') state = 3;    /* CPP */
	  else if (c == '%') state = 4;    /* Directive */
	  else if (c == '@') state = 4;    /* Objective C keyword */
	  else if (c == ':') state = 5;    /* maybe double colon */
	  else if (c == '0') state = 83;   /* An octal or hex value */
	  else if (c == '\'') state = 9;   /* A character constant */
	  else if (c == '.') state = 100;  /* Maybe a number, maybe just a period */
	  else if (c == '`') {
	    state = 200; /* Back-tick type */
	    yylen = 0;
	  }
	  else if (isdigit(c)) state = 8;  /* A numerical value */

	  else state = 99;
	  break;
	case 1:  /*  Comment block */
	  if ((c = nextchar()) == 0) return(0);
	  if (c == '/') {
	    comment_start = cparse_line;
	    Clear(comment);
	    state = 10;        /* C++ style comment */
	  } else if (c == '*') {
	    comment_start = cparse_line;
	    Clear(comment);
	    state = 12;   /* C style comment */
	  } else {
	    retract(1);
	    return(SLASH);
	  }
	  break;
	case 300: /* & or && */
	  if ((c = nextchar()) == 0) return(AND);
	  if (c == '&') return(LAND);
	  else {
	    retract(1);
	    return(AND);
	  }

	case 301: /* | or || */
	  if ((c = nextchar()) == 0) return(OR);
	  if (c == '|') return(LOR);
	  else {
	    retract(1);
	    return(OR);
	  }
	case 10:  /* C++ style comment */
	  if ((c = nextchar()) == 0) {
	    Swig_error(cparse_file,-1, "Unterminated comment detected.\n");
	    return 0;
	  }
	  if (c == '\n') {
	    Putc(c,comment);
	    /* Add the comment to documentation */
	    /*	    yycomment(Char(comment),comment_start, column_start);*/
	    yylen = 0;
	    state = 0;
	  } else {
	    state = 10;
	    Putc(c,comment);
	    yylen = 0;
	  }
	  break;

	case 12: /* C style comment block */
	  if ((c = nextchar()) == 0) {
	    Swig_error(cparse_file,-1,"Unterminated comment detected.\n");
	    return 0;
	  }
	  if (c == '*') {
	    state = 13;
	  } else {
	    Putc(c,comment);
	    yylen = 0;
	    state = 12;
	  }
	  break;
	case 13: /* Still in C style comment */
	  if ((c = nextchar()) == 0) {
	    Swig_error(cparse_file,-1,"Unterminated comment detected.\n");
	    return 0;
	  }
	  if (c == '*') {
	    Putc(c,comment);
	    state = 13;
	  } else if (c == '/') {
	    /* Look for locator markers */
	    char *loc = Char(comment);
	    if (loc && (strncmp(loc,"@SWIG",4) == 0)&& (*(loc+Len(comment)-1) == '@')) {
	      /* Locator */
	      scanner_locator(comment);
	      yylen = 0;
	      state = 0;
	    } else {
	      yylen = 0;
	      state = 0;
	    }
	  } else {
	    Putc('*',comment);
	    Putc(c,comment);
	    yylen = 0;
	    state = 12;
	  }
	  break;

	case 2: /* Processing a string */
	  if ((c = nextchar()) == 0) {
	    Swig_error(cparse_file,-1, "Unterminated string detected.\n");
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
	    cparse_start_line = cparse_line;
	  } else if ((isalpha(c)) || (c == '_')) state = 7;
	  else if (c == '}') {
	    Swig_error(cparse_file,cparse_line, "Misplaced %%}.\n");
	    return 0;
	  } else {
	    retract(1);
	    return(MODULO);
	  }
	  break;

	case 40: /* Process an include block */
	  if ((c = nextchar()) == 0) {
	    Swig_error(cparse_file,-1, "Unterminated include block detected.\n");
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
	    Swig_error(cparse_file,-1, "Unterminated include block detected.\n");
	    return 0;
	  }
	  if (c == '}') {
	    yylval.str = NewString(header);
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
	  if ( c == ':') {
	    state = 51;
	  } else {
	    retract(1);
	    return COLON;
	  }
	  break;
	case 51: /* Maybe a ::*, ::~, or :: */
	  if (( c = nextchar()) == 0) return 0;
	  if (c == '*') {
	    return DSTAR;
	  } else if (c == '~') {
	    return DCNOT;
	  } else if (isspace(c)) {
	    /* Keep scanning ahead.  Might be :: * or :: ~ */
	  } else {
	    retract(1);
	    if (!last_id) {
	      retract(2);
	      return NONID;
	    } else {
	      return DCOLON;
	    }
	  }
	  break;

	case 60: /* shift operators */
	  if ((c = nextchar()) == 0) return (0);
	  if (c == '<') return LSHIFT;
	  else {
	    retract(1);
	    return LESSTHAN;
	  }
	case 61:
	  if ((c = nextchar()) == 0) return (0);
	  if (c == '>') return RSHIFT;
	  else {
	    retract(1);
            return GREATERTHAN;
	  }
	case 7: /* Identifier */
	  if ((c = nextchar()) == 0) return(0);
	  if (isalnum(c) || (c == '_') || (c == '.') || (c == '$')) {
	    state = 7;
	  } else {
	    retract(1);
	    return(ID);
	  }
	  break;
	case 75: /* Special identifier $*/
	  if ((c = nextchar()) == 0) return(0);
	  if (isalnum(c) || (c == '_') || (c == '*') || (c == '&')) {
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
	     return(NUM_FLOAT);
	  }
	  else if (isdigit(c)) { state = 8;}
	  else if ((c == 'l') || (c == 'L')) {
	    state = 87;
	  } else if ((c == 'u') || (c == 'U')) {
	    state = 88;
	  } else {
	      retract(1);
	      return(NUM_INT);
	    }
	  break;
	case 81: /* A floating pointer number of some sort */
	  if ((c = nextchar()) == 0) return(0);
	  if (isdigit(c)) state = 81;
	  else if ((c == 'e') || (c == 'E')) state = 82;
          else if ((c == 'f') || (c == 'F') || (c == 'l') || (c == 'L')) {
	    return(NUM_FLOAT);
	  } else {
	    retract(1);
	    return(NUM_FLOAT);
	  }
	  break;
	case 82:
	  if ((c = nextchar()) == 0) return(0);
	  if ((isdigit(c)) || (c == '-') || (c == '+')) state = 86;
	  else {
	    retract(2);
	    yytext[yylen-1] = 0;
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
	    return(NUM_INT);
	  }
	  break;

	case 86:
	  /* Rest of floating point number */

	  if ((c = nextchar()) == 0) return (0);
	  if (isdigit(c)) state = 86;
          else if ((c == 'f') || (c == 'F') || (c == 'l') || (c == 'L')) {
	    return(NUM_FLOAT);
	  } else {
	    retract(1);
	    return(NUM_FLOAT);
	  }
	  /* Parse a character constant. ie. 'a' */
	  break;

	case 87 :
	  /* A long integer of some sort */
	  if ((c = nextchar()) == 0) return (NUM_LONG);
	  if ((c == 'u') || (c == 'U')) {
	    return(NUM_ULONG);
	  } else if ((c == 'l') || (c == 'L')) {
	    state = 870;
	  } else {
	    retract(1);
	    return(NUM_LONG);
	  }
	  break;

	case 870:
	  if ((c = nextchar()) == 0) return (NUM_LONGLONG);
	  if ((c == 'u') || (c == 'U')) {
	    return (NUM_ULONGLONG);
	  } else {
	    retract(1);
	    return(NUM_LONGLONG);
	  }

	case 88:
	  /* An unsigned integer of some sort */
	  if ((c = nextchar()) == 0) return (NUM_UNSIGNED);
	  if ((c == 'l') || (c == 'L')) {
	    state = 880;
	  } else {
	    retract(1);
	    return(NUM_UNSIGNED);
	  }
	  break;

	case 880:
	  if ((c = nextchar()) == 0) return (NUM_ULONG);
	  if ((c == 'l') || (c == 'L')) return (NUM_ULONGLONG);
	  else {
	    retract(1);
	    return(NUM_ULONG);
	  }
	  
	case 9:
	  if ((c = nextchar()) == 0) return (0);
	  if (c == '\\') {
	    yylen--;
	    get_escape();
	  } else if (c == '\'') {
	    yytext[yylen-1] = 0;
	    yylval.str = NewString(yytext+1);
	    if (yylen == 2) {
	      Swig_error(cparse_file, cparse_line, "Empty character constant\n");
	    }
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
	  Swig_error(cparse_file, cparse_line, "Illegal character '%c'=%d.\n",c,c);
	  state = 0;
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

void scanner_last_id(int x) {
  /*  printf("Setting last_id = %d\n", x); */
  last_id = x;
}

void scanner_clear_rename() {
  rename_active = 0;
}

static int next_token = 0;
void scanner_next_token(int tok) {
  next_token = tok;
}

/* ----------------------------------------------------------------------------
 * int yylex()
 *
 * Gets the lexene and returns tokens.
 * ------------------------------------------------------------------------- */

int yylex(void) {

    int   l;

    if (!scan_init) {
      scanner_init();
    }

    if (next_token) {
      l = next_token;
      next_token = 0;
      return l;
    }
    /*    Printf(stdout,"%d\n", last_id);*/
    l = yylook();

    if (l == NONID) {
      last_id = 1;
    } else {
      last_id = 0;
    }
    /*
    yytext[yylen]= 0;
    Printf(stdout,"%d  '%s' %d\n", l, yytext, last_id);
    */

    /* We got some sort of non-white space object.  We set the start_line
       variable unless it has already been set */

    if (!cparse_start_line) {
      cparse_start_line = cparse_line;
    }

    /* Copy the lexene */

    yytext[yylen] = 0;
    switch(l) {

    case NUM_INT:
    case NUM_FLOAT:
    case NUM_ULONG:
    case NUM_LONG:
    case NUM_UNSIGNED:
    case NUM_LONGLONG:
    case NUM_ULONGLONG:
      if (l == NUM_INT) yylval.dtype.type = T_INT;
      if (l == NUM_FLOAT) yylval.dtype.type = T_DOUBLE;
      if (l == NUM_ULONG) yylval.dtype.type = T_ULONG;
      if (l == NUM_LONG) yylval.dtype.type = T_LONG;
      if (l == NUM_UNSIGNED) yylval.dtype.type = T_UINT;
      if (l == NUM_LONGLONG) yylval.dtype.type = T_LONGLONG;
      if (l == NUM_ULONGLONG) yylval.dtype.type = T_ULONGLONG;
      yylval.dtype.val = NewString(yytext);
      yylval.dtype.bitfield = 0;
      yylval.dtype.throws = 0;
      return(l);
      
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
	  if (strcmp(yytext,"wchar_t") == 0) {
	    yylval.type = NewSwigType(T_WCHAR);
	    return(TYPE_WCHAR);
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

          /* Non ISO (Windows) C extensions */
	  if (strcmp(yytext,"__int8") == 0) {
	    yylval.type = NewString(yytext);
	    return(TYPE_NON_ISO_INT8);
	  }
	  if (strcmp(yytext,"__int16") == 0) {
	    yylval.type = NewString(yytext);
	    return(TYPE_NON_ISO_INT16);
	  }
	  if (strcmp(yytext,"__int32") == 0) {
	    yylval.type = NewString(yytext);
	    return(TYPE_NON_ISO_INT32);
	  }
	  if (strcmp(yytext,"__int64") == 0) {
	    yylval.type = NewString(yytext);
	    return(TYPE_NON_ISO_INT64);
	  }

	  /* C++ keywords */
	  if (cparse_cplusplus) {
	    if (strcmp(yytext,"and") == 0) return(LAND);
	    if (strcmp(yytext,"or") == 0) return(LOR);
	    if (strcmp(yytext,"not") == 0) return(LNOT);
	    if (strcmp(yytext,"class") == 0) return(CLASS);
	    if (strcmp(yytext,"private") == 0) return(PRIVATE);
	    if (strcmp(yytext,"public") == 0) return(PUBLIC);
	    if (strcmp(yytext,"protected") == 0) return(PROTECTED);
	    if (strcmp(yytext,"friend") == 0) return(FRIEND);
	    if (strcmp(yytext,"virtual") == 0) return(VIRTUAL);
	    if (strcmp(yytext,"operator") == 0) {
	      String *s = NewString("operator");
	      int c;
	      int state = 0;
	      int sticky = 0;
	      int isconversion = 0;
	      int count = 0;
	      int start_template = 0;
	      int end_template = 0;
	      while ((c = nextchar())) {
		if (((c == '(') || (c == ';')) && state) {
		  retract(1);
		  break;
		}
		if ((c == '<') && !start_template) {
		  int fcount = 1;
		  char c = nextchar();
		  while (isspace((int)c)) {c = nextchar(); ++fcount;}
		  if (isalpha((int)c)|| c == ':') {
		    start_template = count;
		  }
		  retract(fcount);
		}
		if ((c == '>') && start_template) end_template = count;
		count++;
		if (!isspace(c)) {
		  if ((!state) && (isalpha(c))) {
		    isconversion = 1;
		  }
		  
		  if (!state && !sticky) Putc(' ',s);
		  Putc(c,s);
		  sticky = 0;
		  state = 1;
		} else {
		  if (!sticky) Putc(' ',s);
		  sticky = 1;
		}
	      }
	      Chop(s);
	      if (swigtemplate_active && start_template && end_template) {
		/* 
		   Manage the case:

		     %template(foo) operator()<int>;
		   
		   ie, don't count <int> as part of the operator.		   
		*/
		int len = Len(s);
		char *end = Char(s);
		int tlen = end_template - start_template + 1;
		int nlen = len - tlen;
		if (nlen) {
		  String *ns = 0;		
		  while (isspace((int)end[--nlen]));
		  ns = NewStringWithSize(s, nlen + 1);
		  retract(count - start_template);
		  Delete(s);
		  s = ns;
		  count = start_template;
		  isconversion = 0;
		}
	      }
	      
	      yylval.str = s;
	      while(Replaceall(s,"[ ", "["));
	      if (isconversion) {
		String *ns = Swig_symbol_string_qualify(s,0);
		yylval.str = ns;
	      }
	      if (isconversion && !rename_active) {
		char *t = Char(s) + 9;
		if (!((strcmp(t,"new") == 0) 
		      || (strcmp(t,"delete") == 0) 
		      || (strcmp(t,"new[]") == 0) 
		      || (strcmp(t,"delete[]") == 0)
		      || (strcmp(t,"and") == 0)
		      || (strcmp(t,"and_eq") == 0)
		      || (strcmp(t,"bitand") == 0)
		      || (strcmp(t,"bitor") == 0)
		      || (strcmp(t,"compl") == 0)
		      || (strcmp(t,"not") == 0)
		      || (strcmp(t,"not_eq") == 0)
		      || (strcmp(t,"or") == 0)
		      || (strcmp(t,"or_eq") == 0)
		      || (strcmp(t,"xor") == 0)
		      || (strcmp(t,"xor_eq") == 0)
		      )) {
		  /*		  retract(strlen(t));*/
		  retract(count);
		  return COPERATOR;
		}
	      }
	      return(OPERATOR);
	    }
	    if (strcmp(yytext,"throw") == 0) return(THROW);
	    if (strcmp(yytext,"try") == 0) return (yylex());
	    if (strcmp(yytext,"catch") == 0) return (CATCH);
	    if (strcmp(yytext,"inline") == 0) return(yylex());
	    if (strcmp(yytext,"mutable") == 0) return(yylex());
	    if (strcmp(yytext,"restrict") == 0) return(yylex());
	    if (strcmp(yytext,"explicit") == 0) return(EXPLICIT);
	    if (strcmp(yytext,"export") == 0) return(yylex());
	    if (strcmp(yytext,"typename") == 0) return (TYPENAME);
	    if (strcmp(yytext,"template") == 0) {
	      yylval.ivalue = cparse_line;
	      return(TEMPLATE);
	    }
	    if (strcmp(yytext,"delete") == 0) {
	      return(DELETE_KW);
	    }
	    if (strcmp(yytext,"using") == 0) {
	      return(USING);
	    }
	    if (strcmp(yytext,"namespace") == 0) {
	      return(NAMESPACE);
	    }
	  } else {
	    if (strcmp(yytext,"class") == 0) {
	      Swig_warning(WARN_PARSE_CLASS_KEYWORD,cparse_file,cparse_line, "class keyword used, but not in C++ mode.\n");
	    }
	    if (strcmp(yytext,"complex") == 0) {
	      yylval.type = NewSwigType(T_COMPLEX);
	      return(TYPE_COMPLEX);
	    }
	  }
	  
	  /* Objective-C keywords */
#ifdef OBJECTIVEC
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
#endif
	  
	  /* Misc keywords */
	  
	  if (strcmp(yytext,"extern") == 0) return(EXTERN);
	  if (strcmp(yytext,"const") == 0) return(CONST_QUAL);
	  if (strcmp(yytext,"static") == 0) return(STATIC);
	  if (strcmp(yytext,"struct") == 0) return(STRUCT);
	  if (strcmp(yytext,"union") == 0) return(UNION);
	  if (strcmp(yytext,"enum") == 0) return(ENUM);
	  if (strcmp(yytext,"sizeof") == 0) return(SIZEOF);
	  
	  if (strcmp(yytext,"typedef") == 0) {
	    yylval.ivalue = 0;
	    return(TYPEDEF);
	  }
	  
	  /* Ignored keywords */
	  
	  if (strcmp(yytext,"volatile") == 0) return(VOLATILE);
	  if (strcmp(yytext,"register") == 0) return(REGISTER);
	  if (strcmp(yytext,"inline") == 0)   return(yylex());
	  if (strcmp(yytext,"restrict") == 0) return(yylex());
	  
	  /* SWIG directives */
	} else {
	  if (strcmp(yytext,"%module") == 0) return(MODULE);
	  if (strcmp(yytext,"%insert") == 0) return(INSERT);
	  if (strcmp(yytext,"%name") == 0) return(NAME);
	  if (strcmp(yytext,"%rename") == 0) {
	    rename_active = 1;
	    return(RENAME);
	  }
	  if (strcmp(yytext,"%namewarn") == 0) {
	    rename_active = 1;
	    return (NAMEWARN);
	  }
	  if (strcmp(yytext,"%includefile") == 0) return(INCLUDE);
	  if (strcmp(yytext,"%val") == 0) {
	    Swig_warning(WARN_DEPRECATED_VAL, cparse_file, cparse_line, "%%val directive deprecated (ignored).\n");
	    return (yylex());
	  }
	  if (strcmp(yytext,"%out") == 0) {
	    Swig_warning(WARN_DEPRECATED_OUT, cparse_file, cparse_line, "%%out directive deprecated (ignored).\n");
	    return(yylex());
	  }
	  if (strcmp(yytext,"%constant") == 0) return(CONSTANT);
	  if (strcmp(yytext,"%typedef") == 0) {
	    yylval.ivalue = 1;
	    return(TYPEDEF);
	  }
	  if (strcmp(yytext,"%native") == 0) return(NATIVE);
	  if (strcmp(yytext,"%pragma") == 0) return(PRAGMA);
	  if (strcmp(yytext,"%extend") == 0) return(EXTEND);
	  if (strcmp(yytext,"%fragment") == 0) return(FRAGMENT);
	  if (strcmp(yytext,"%inline") == 0) return(INLINE);
	  if (strcmp(yytext,"%typemap") == 0) return(TYPEMAP);
	  if (strcmp(yytext,"%feature") == 0) return(FEATURE);
	  if (strcmp(yytext,"%except") == 0) return(EXCEPT);
	  if (strcmp(yytext,"%importfile") == 0) return(IMPORT);
	  if (strcmp(yytext,"%echo") == 0) return(ECHO);
	  if (strcmp(yytext,"%apply") == 0) return(APPLY);
	  if (strcmp(yytext,"%clear") == 0) return(CLEAR);
	  if (strcmp(yytext,"%types") == 0) return(TYPES);
	  if (strcmp(yytext,"%parms") == 0) return(PARMS);
	  if (strcmp(yytext,"%varargs") == 0) return(VARARGS);
	  if (strcmp(yytext,"%template") == 0) {
	    swigtemplate_active = 1;
	    return (SWIGTEMPLATE);
	  }
	  
	  if (strcmp(yytext,"%warn") == 0) return(WARN);
	}
	/* Have an unknown identifier, as a last step, we'll do a typedef lookup on it. */

        /* Need to fix this */
	if (check_typedef) {
	  if (SwigType_istypedef(yytext)) {
	    yylval.type = NewString(yytext);
	    return(TYPE_TYPEDEF);
	  }
	}
	yylval.id = Swig_copy_string(yytext);
	last_id = 1;
	return(ID);
    case POUND:
      return yylex();
    default:
      return(l);
    }
}
