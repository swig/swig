/* -----------------------------------------------------------------------------
 * cpp.c
 *
 *     An implementation of a C preprocessor plus some support for additional
 *     SWIG directives.
 *
 *         - SWIG directives such as %include, %extern, and %import are handled
 *         - A new macro %define ... %enddef can be used for multiline macros
 *         - No preprocessing is performed in %{ ... %} blocks
 *         - Lines beginning with %# are stripped down to #... and passed through.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "preprocessor.h"
#include <ctype.h>

static DOHHash  *cpp = 0;                /* C preprocessor data */
static int       include_all = 0;        /* Follow all includes */
static int       single_include = 1;     /* Only include each file once */
static int       silent_errors = 0;
static DOHHash  *included_files = 0;

/* Handle an error */

static void cpp_error(DOHString *file, int line, char *fmt, ...) {
  va_list ap;
  if (silent_errors) return;
  va_start(ap,fmt);
  if (line > 0) {
    Printf(stderr,"%s:%d ", file, line);
  } else {
    Printf(stderr,"%s:EOF ",file);
  }
  vPrintf(stderr,fmt,ap);
  va_end(ap);
}

/* Test a character to see if it starts an identifier */
static int
isidentifier(char c) {
  if ((isalpha(c)) || (c == '_') || (c == '$')) return 1;
  else return 0;
}

/* Test a character to see if it valid in an identifier (after the first letter) */
static int
isidchar(char c) {
  if ((isalnum(c)) || (c == '_') || (c == '$')) return 1;
  else return 0;
}

/* Skip whitespace */
static void
skip_whitespace(DOH *s, DOH *out) {
  int c;
  while ((c = Getc(s)) != EOF) {
    if (!isspace(c)) {
      Ungetc(c,s);
      break;
    } else if (out) Putc(c,out);
  }
}

/* Skip to a specified character taking line breaks into account */
static int
skip_tochar(DOHFile *s, int ch, DOHFile *out) {
  int c;
  while ((c = Getc(s)) != EOF) {
    if (out) Putc(c,out);
    if (c == ch) break;
    if (c == '\\') {
      c = Getc(s);
      if ((c != EOF) && (out)) Putc(c,out);
    }
  }
  if (c == EOF) return -1;
  return 0;
}

static void
copy_location(DOH *s1, DOH *s2) {
  Setfile(s2,Getfile(s1));
  Setline(s2,Getline(s1));
}

static DOHString *cpp_include(DOHString_or_char *fn) {
  DOHString *s;
  if (single_include) {
    if (Getattr(included_files,fn)) return 0;
    Setattr(included_files,fn,fn);
  }
  s = Swig_include(fn);
  if (!s) {
    Seek(fn,0,SEEK_SET);
    cpp_error(Getfile(fn),Getline(fn),"Unable to find '%s'\n", fn);
  } else {
    Seek(s,0,SEEK_SET);
  }
  return s;
}

/* -----------------------------------------------------------------------------
 * void Preprocessor_cpp_init() - Initialize the preprocessor
 * ----------------------------------------------------------------------------- */
void Preprocessor_init() {
  DOHHash *s;
  cpp = NewHash();
  s =   NewHash();
  Setattr(cpp,"symbols",s);
  Preprocessor_expr_init();            /* Initialize the expression evaluator */
  included_files = NewHash();
}
/* -----------------------------------------------------------------------------
 * void Preprocessor_include_all() - Instruct preprocessor to include all files
 * ----------------------------------------------------------------------------- */
void Preprocessor_include_all(int a) {
  include_all = a;
}

/* -----------------------------------------------------------------------------
 * Preprocessor_define()
 *
 * Defines a new C preprocessor symbol.   swigmacro specifies whether or not the macro has
 * SWIG macro semantics.
 * ----------------------------------------------------------------------------- */

DOHHash *Preprocessor_define(DOHString_or_char *str, int swigmacro)
{
  DOHString *macroname = 0, *argstr = 0, *macrovalue = 0, *file = 0, *s = 0;
  DOHHash   *macro = 0, *symbols = 0, *m1;
  DOHList   *arglist = 0;
  int c, line;

  assert(cpp);
  assert(str);

  /* First make sure that string is actually a string */
  if (DohCheck(str)) {
    s = Copy(str);
    copy_location(str,s);
    str = s;
  } else {
    str = NewString((char *) str);
    Seek(str,0,SEEK_SET);
  }
  line = Getline(str);
  file = Getfile(str);

  /*     Printf(stdout,"%s:%d '%s'\n", file,line,str); */

  /* Skip over any leading whitespace */
  skip_whitespace(str,0);

  /* Now look for a macro name */
  macroname = NewString("");
  while ((c = Getc(str)) != EOF) {
    if (c == '(') {
      argstr = NewString("");
      copy_location(str,argstr);
      /* It is a macro.  Go extract it's argument string */
      while ((c = Getc(str)) != EOF) {
	if (c == ')') break;
	else Putc(c,argstr);
      }
      if (c != ')') {
	cpp_error(Getfile(str),Getline(str), "Missing \')\' in macro parameters\n");
	goto macro_error;
      }
      break;
    } else if (isidchar(c)) {
      Putc(c,macroname);
    } else if (isspace(c)) {
      break;
    } else {
      cpp_error(Getfile(str),Getline(str),"Illegal character in macro name\n");
      goto macro_error;
    }
  }
  if (!swigmacro)
    skip_whitespace(str,0);
  macrovalue = NewString("");
  while ((c = Getc(str)) != EOF) {
    Putc(c,macrovalue);
  }

  /* If there are any macro arguments, convert into a list */
  if (argstr) {
    DOH *argname;
    arglist = NewList();
    Seek(argstr,0,SEEK_SET);
    argname = NewString("");
    while ((c = Getc(argstr)) != EOF) {
      if (c == ',') {
	Append(arglist,argname);
	Delete(argname);
	argname = NewString("");
      } else if (isidchar(c)) {
	Putc(c,argname);
      } else if (!isspace(c)) {
	cpp_error(Getfile(str),Getline(str),"Illegal character in macro name\n");
	goto macro_error;
      }
    }
    if (Len(argname)) {
      Append(arglist,argname);
      Delete(argname);
    }
  }

  if (!swigmacro) {
    Replace(macrovalue,"\\\n"," ", DOH_REPLACE_NOQUOTE);
  }
  /* Get rid of whitespace surrounding # */
  Replace(macrovalue,"#","\001",DOH_REPLACE_NOQUOTE);
  while(strstr(Char(macrovalue),"\001 ")) {
    Replace(macrovalue,"\001 ","\001", DOH_REPLACE_NOQUOTE);
  }
  while(strstr(Char(macrovalue)," \001")) {
    Replace(macrovalue," \001","\001", DOH_REPLACE_NOQUOTE);
  }
  /* Replace '##' with a special token */
  Replace(macrovalue,"\001\001","\002", DOH_REPLACE_NOQUOTE);

  /* Go create the macro */
  macro = NewHash();
  Setattr(macro,"name", macroname);
  Delete(macroname);
  if (arglist) {
    Setattr(macro,"args",arglist);
    Delete(arglist);
  }
  Setattr(macro,"value",macrovalue);
  Delete(macrovalue);
  Setline(macro,line);
  Setfile(macro,file);
  if (swigmacro) {
    Setattr(macro,"swigmacro","1");
  }
  symbols = Getattr(cpp,"symbols");
  if ((m1 = Getattr(symbols,macroname))) {
    if (Cmp(Getattr(m1,"value"),macrovalue))
      cpp_error(Getfile(str),Getline(str),"Macro '%s' redefined. Previous definition in \'%s\', Line %d\n", macroname, Getfile(m1), Getline(m1));
  }
  Setattr(symbols,macroname,macro);
  Delete(str);
  Delete(argstr);
  return macro;

 macro_error:
  Delete(str);
  Delete(argstr);
  return 0;
}

/* -----------------------------------------------------------------------------
 * Preprocessor_undef()
 *
 * Undefines a macro.
 * ----------------------------------------------------------------------------- */
void Preprocessor_undef(DOHString_or_char *str)
{
  DOH *symbols;
  assert(cpp);
  symbols = Getattr(cpp,"symbols");
  Delattr(symbols,str);
}

/* -----------------------------------------------------------------------------
 * find_args()
 *
 * Isolates macro arguments and returns them in a list.   For each argument,
 * leading and trailing whitespace is stripped (ala K&R, pg. 230).
 * ----------------------------------------------------------------------------- */
static DOHList *
find_args(DOHString *s)
{
  DOHList   *args;
  DOHString *str;
  int   c, level;

  /* Create a new list */
  args = NewList();
  copy_location(s,args);

  /* First look for a '(' */
  skip_whitespace(s,0);

  /* Now see if the next character is a '(' */
  c = Getc(s);
  if (c != '(') {
    /* Not a macro, bail out now! */
    cpp_error(Getfile(s),Getline(s),"Missing macro arguments\n");
    return args;
  }
  c = Getc(s);
  /* Okay.  This appears to be a macro so we will start isolating arguments */
  while (c != EOF) {
    if (isspace(c)) {
      skip_whitespace(s,0);                    /* Skip leading whitespace */
      c = Getc(s);
    }
    str = NewString("");
    copy_location(s,str);
    level = 0;
    while (c != EOF) {
      if (c == '\"') {
	Putc(c,str);
	skip_tochar(s,'\"',str);
	c = Getc(s);
	continue;
      } else if (c == '\'') {
	Putc(c,str);
	skip_tochar(s,'\'',str);
	c = Getc(s);
	continue;
      }
      if ((c == ',') && (level == 0)) break;
      if ((c == ')') && (level == 0)) break;
      Putc(c,str);
      if (c == '(') level++;
      if (c == ')') level--;
      c = Getc(s);
    }
    if (level > 0) {
      goto unterm;
    }
    Chop(str);
    if (Len(args) || Len(str))
      Append(args,str);
    Delete(str);

    /*    if (Len(str) && (c != ')'))
	  Append(args,str); */

    if (c == ')') return args;
    c = Getc(s);
  }
 unterm:
  cpp_error(Getfile(args),Getline(args),"Unterminated macro call.\n");
  return args;
}

/* -----------------------------------------------------------------------------
 * DOH *get_filename(DOH *str)
 *
 * Read a filename from str.   A filename can be enclose in quotes, angle brackets,
 * or bare.
 * ----------------------------------------------------------------------------- */

static DOHString *
get_filename(DOHString *str) {
  DOHString *fn;
  int  c;

  skip_whitespace(str,0);
  fn = NewString("");
  copy_location(str,fn);
  c = Getc(str);
  if (c == '\"') {
    while (((c = Getc(str)) != EOF) && (c != '\"')) Putc(c,fn);
  } else if (c == '<') {
    while (((c = Getc(str)) != EOF) && (c != '>'))  Putc(c,fn);
  } else {
    Putc(c,fn);
    while (((c = Getc(str)) != EOF) && (!isspace(c))) Putc(c,fn);
    if (isspace(c)) Ungetc(c,str);
  }
  Seek(fn,0,SEEK_SET);
  return fn;
}

/* -----------------------------------------------------------------------------
 * expand_macro()
 *
 * Perform macro expansion and return a new string.  Returns NULL if some sort
 * of error occurred.
 * ----------------------------------------------------------------------------- */

DOH *expanded_value = 0;

static DOHString *
expand_macro(DOHString_or_char *name, DOHList *args)
{
  DOH *symbols, *ns, *macro, *margs, *mvalue, *temp, *tempa, *e;
  DOH *Preprocessor_replace(DOH *);
  int i, l;

  symbols = Getattr(cpp,"symbols");
  if (!symbols) return 0;

  /* See if the name is actually defined */
  macro = Getattr(symbols,name);
  if (!macro) return 0;
  if (Getattr(macro,"*expanded*")) {
    ns = NewString("");
    Printf(ns,"%s",name);
    if (args) {
      Putc('(',ns);
      for (i = 0; i < Len(args); i++) {
	Printf(ns,"%s",Getitem(args,i));
	if (i < (Len(args) -1)) Putc(',',ns);
      }
      Putc(')',ns);
    }
    return ns;
  }

  /* Get macro arguments and value */
  mvalue = Getattr(macro,"value");
  assert(mvalue);
  margs = Getattr(macro,"args");

  /* If there are arguments, see if they match what we were given */
  if ((margs) && (Len(margs) != Len(args))) {
    if (Len(margs) > 1)
      cpp_error(Getfile(args),Getline(args),"Macro '%s' expects %d arguments\n", name, Len(margs));
    else if (Len(margs) == 1)
      cpp_error(Getfile(args),Getline(args),"Macro '%s' expects 1 argument\n", name);
    else
      cpp_error(Getfile(args),Getline(args),"Macro '%s' expects no arguments\n", name);
    return 0;
  }

  /* Copy the macro value */
  ns = Copy(mvalue);
  copy_location(mvalue,ns);

  /* Tag the macro as being expanded.   This is to avoid recursion in
     macro expansion */

  if (!expanded_value) {
    expanded_value = NewString("");
    DohIntern(expanded_value);
  }
  Setattr(macro,"*expanded*",expanded_value);

  temp = NewString("");
  tempa = NewString("");
  if (margs) {
    l = Len(margs);
    for (i = 0; i < l; i++) {
      DOH *arg, *aname;
      arg = Getitem(args,i);           /* Get an argument value */
      aname = Getitem(margs,i);        /* Get macro argument name */
      if (strstr(Char(ns),"\001")) {
	/* Try to replace a quoted version of the argument */
	Clear(temp);
	Clear(tempa);
	Printf(temp,"\001%s", aname);
	Printf(tempa,"\"%s\"",arg);
	Replace(ns, temp, tempa, DOH_REPLACE_ANY);
      }
      Replace(ns, aname, arg, DOH_REPLACE_ID);
    }
  }
  Replace(ns,"\002","",DOH_REPLACE_ANY);    /* Get rid of concatenation tokens */
  Replace(ns,"\001","#",DOH_REPLACE_ANY);   /* Put # back (non-standard C) */


  /* Expand this macro even further */
  e = Preprocessor_replace(ns);

  Delete(ns);
  Delattr(macro,"*expanded*");
  if (Getattr(macro,"swigmacro")) {
    DOHString *g;
    DOHString *f = NewString("");
    Printf(f,"%%macro %s, \"%s\", %d {\n", name, Getfile(macro), Getline(macro));
    Seek(e,0,SEEK_SET);
    copy_location(macro,e);
    g = Preprocessor_parse(e);
    Printf(f,"%s\n", g);
    Printf(f,"}\n");
    Delete(g);
    Delete(e);
    e = f;
  }
  Delete(temp);
  Delete(tempa);
  return e;
}

/* -----------------------------------------------------------------------------
 * DOH *Preprocessor_replace(DOH *s)
 *
 * Performs a macro substitution on a string s.  Returns a new string with
 * substitutions applied.   This function works by walking down s and looking
 * for identifiers.   When found, a check is made to see if they are macros
 * which are then expanded.
 * ----------------------------------------------------------------------------- */

DOH *
Preprocessor_replace(DOH *s)
{
  DOH   *ns, *id, *symbols, *m;
  int   c, i, state = 0;

  assert(cpp);
  symbols = Getattr(cpp,"symbols");

  ns = NewString("");
  copy_location(s,ns);
  Seek(s,0,SEEK_SET);
  id = NewString("");

  /* Try to locate identifiers in s and replace them with macro replacements */
  while ((c = Getc(s)) != EOF) {
    switch (state) {
    case 0:
      if (isidentifier(c)) {
	Clear(id);
	copy_location(s,id);
	Putc(c,id);
	state = 1;
      } else if (c == '\"') {
	Putc(c,ns);
	skip_tochar(s,'\"',ns);
      } else if (c == '\'') {
	Putc(c,ns);
	skip_tochar(s,'\'',ns);
      } else if (c == '/') {
	Putc(c,ns);
	state = 10;
      } else {
	Putc(c,ns);
      }
      break;
    case 1:  /* An identifier */
      if (isidchar(c)) {
	Putc(c,id);
	state = 1;
      } else {
	/* We found the end of a valid identifier */
	Ungetc(c,s);
	/* See if this is the special "defined" macro */
	if (Cmp(id,"defined") == 0) {
	  DOH *args;
	  /* See whether or not a paranthesis has been used */
	  skip_whitespace(s,0);
	  c = Getc(s);
	  if (c == '(') {
	    Seek(s,-1,SEEK_CUR);
	    args = find_args(s);
	  } else {
	    DOH *arg = 0;
	    args = NewList();
	    arg = NewString("");
	    while ((c = Getc(s)) != EOF) {
	      if (!isidchar(c)) {
		Seek(s,-1,SEEK_CUR);
		break;
	      }
	      Putc(c,arg);
	    }
	    Append(args,arg);
	    Delete(arg);
	  }
	  if (!args) {
	    cpp_error(Getfile(id),Getline(id),"No arguments given to defined()\n");
	    state = 0;
	    break;
	  }
	  for (i = 0; i < Len(args); i++) {
	    DOH *o = Getitem(args,i);
	    if (!Getattr(symbols,o)) {
	      break;
	    }
	  }
	  if (i < Len(args)) Putc('0',ns);
	  else Putc('1',ns);
	  Delete(args);
	  state = 0;
	  break;
	}
	if (Cmp(id,"__LINE__") == 0) {
	  Printf(ns,"%d",Getline(s));
	  state = 0;
	  break;
	}
	if (Cmp(id,"__FILE__") == 0) {
	  Printf(ns,"\"%s\"",Getfile(s));
	  state = 0;
	  break;
	}
	/* See if the macro is defined in the preprocessor symbol table */
	if ((m = Getattr(symbols,id))) {
	  DOH *args = 0;
	  DOH *e;
	  /* See if the macro expects arguments */
	  if (Getattr(m,"args")) {
	    /* Yep.  We need to go find the arguments and do a substitution */
	    args = find_args(s);
	  } else {
	    args = 0;
	  }
	  e = expand_macro(id,args);
	  if (e) {
	    Printf(ns,"%s",e);
	  }
	  Delete(e);
	  Delete(args);
	} else {
	  Printf(ns,"%s",id);
	}
	state = 0;
      }
      break;
    case 10:
      if (c == '/') state = 11;
      else if (c == '*') state = 12;
      else {
	Ungetc(c,s);
	state = 0;
	break;
      }
      Putc(c,ns);
      break;
    case 11:
      Putc(c,ns);
      if (c == '\n') state = 0;
      break;
    case 12:
      Putc(c,ns);
      if (c == '*') state = 13;
      break;
    case 13:
      Putc(c,ns);
      if (c == '/') state = 0;
      else if (c != '*') state = 12;
      break;
    default:
      state = 0;
      break;
    }
  }

  /* Identifier at the end */
  if (state == 1) {
    /* See if this is the special "defined" macro */
    if (Cmp(id,"defined") == 0) {
      cpp_error(Getfile(id),Getline(id),"No arguments given to defined()\n");
    } else if ((m = Getattr(symbols,id))) {
	DOH *e;
	/* Yes.  There is a macro here */
	/* See if the macro expects arguments */
	if (Getattr(m,"args")) {
	  cpp_error(Getfile(id),Getline(id),"Macro arguments expected.\n");
	}
	e = expand_macro(id,0);
	Printf(ns,"%s",e);
	Delete(e);
    } else {
      Printf(ns,"%s",id);
    }
  }
  Delete(id);
  return ns;
}


/* -----------------------------------------------------------------------------
 * int check_id(DOH *s)
 *
 * Checks the string s to see if it contains any unresolved identifiers.  This
 * function contains the heuristic that determines whether or not a macro
 * definition passes through the preprocessor as a constant declaration.
 * ----------------------------------------------------------------------------- */
static int
check_id(DOH *s)
{
  int c, state = 0;
  Seek(s,0,SEEK_SET);
  while ((c = Getc(s)) != EOF) {
    switch(state) {

    case 0:
      if (isdigit(c)) state = 1;
      else if (isidentifier(c)) return 1;
      else if (c == '\"') skip_tochar(s,'\"',0);
      else if (c == '\'') skip_tochar(s,'\'',0);
      else if (c == '/') state = 3;
      break;
    case 1:
      if (isspace(c)) state = 0;
      break;
    case 3:
      if (c == '*') state = 10;
      else if (c == '/') state = 20;
      else {
	Ungetc(c,s);
	state = 0;
      }
      break;
    case 10:
      if (c == '*') state = 11;
      break;
    case 11:
      if (c == '/') state = 0;
      else if (c != '*') state = 10;
      break;
    case 20:
      if (c == '\n') state = 0;
      break;
    }
  }
  return 0;
}

/* addline().  Utility function for adding lines to a chunk */
static void
addline(DOH *s1, DOH *s2, int allow)
{
  if (allow) {
    Append(s1,s2);
  } else {
    char *c = Char(s2);
    while (*c) {
      if (*c == '\n') Putc('\n',s1);
      c++;
    }
  }
}

static void add_chunk(DOH *ns, DOH *chunk, int allow) {
  DOH *echunk;
  Seek(chunk,0,SEEK_SET);
  if (allow) {
    echunk = Preprocessor_replace(chunk);
    addline(ns,echunk,allow);
    Delete(echunk);
  } else {
    addline(ns,chunk,0);
  }
  Clear(chunk);
}

/* -----------------------------------------------------------------------------
 * DOH *Preprocessor_parse(DOH *s)
 *
 * Parses the string s.  Returns a new string containing the preprocessed version.
 *
 * Parsing rules :
 *       1.  Lines starting with # are C preprocessor directives
 *       2.  Macro expansion inside strings is not allowed
 *       3.  All code inside false conditionals is changed to blank lines
 *       4.  Code in %{, %} is not parsed because it may need to be
 *           included inline (with all preprocessor directives included).
 * ----------------------------------------------------------------------------- */

DOH *
Preprocessor_parse(DOH *s)
{
  DOH   *ns;             /* New string containing the preprocessed text */
  DOH   *chunk, *symbols, *sval, *decl;
  DOH   *id = 0, *value = 0, *comment = 0;
  int    i, state, val, e, c;
  int    start_line = 0;
  int    allow = 1;
  int    level = 0;
  int    mask = 0;
  int    start_level = 0;
  int    cpp_lines = 0;
  int    cond_lines[256];

  ns = NewString("");        /* Return result */

  decl = NewString("");
  id = NewString("");
  value = NewString("");
  comment = NewString("");
  chunk = NewString("");
  copy_location(s,chunk);
  copy_location(s,ns);
  symbols = Getattr(cpp,"symbols");

  state = 0;
  while ((c = Getc(s)) != EOF) {
    switch(state) {
    case 0:        /* Initial state - in first column */
      /* Look for C preprocessor directives.   Otherwise, go directly to state 1 */
      if (c == '#') {
	add_chunk(ns,chunk,allow);
	copy_location(s,chunk);
	cpp_lines = 1;
	state = 40;
      } else if (isspace(c)) {
	Putc(c,chunk);
	skip_whitespace(s,chunk);
      } else {
	state = 1;
	Ungetc(c,s);
      }
      break;
    case 1:       /* Non-preprocessor directive */
      /* Look for SWIG directives */
      if (c == '%') {
	state = 100;
	break;
      }
      Putc(c,chunk);
      if (c == '\n') state = 0;
      else if (c == '\"') {
	start_line = Getline(s);
	if (skip_tochar(s,'\"',chunk) < 0) {
	  cpp_error(Getfile(s),-1,"Unterminated string constant starting at line %d\n",start_line);
	}
      } else if (c == '\'') {
	start_line = Getline(s);
	if (skip_tochar(s,'\'',chunk) < 0) {
	  cpp_error(Getfile(s),-1,"Unterminated character constant starting at line %d\n",start_line);
	}
      }
      else if (c == '/') state = 30;  /* Comment */
      break;

    case 30:      /* Possibly a comment string of some sort */
      start_line = Getline(s);
      Putc(c,chunk);
      if (c == '/') state = 31;
      else if (c == '*') state = 32;
      else state = 1;
      break;
    case 31:
      Putc(c,chunk);
      if (c == '\n') state = 0;
      break;
    case 32:
      Putc(c,chunk);
      if (c == '*') state = 33;
      break;
    case 33:
      Putc(c,chunk);
      if (c == '/') state = 1;
      else if (c != '*') state = 32;
      break;

    case 40:   /* Start of a C preprocessor directive */
      if (c == '\n') {
	Putc('\n',chunk);
	state = 0;
      } else if (isspace(c)) {
	state = 40;
      } else {
	/* Got the start of a preprocessor directive */
	Ungetc(c,s);
	Clear(id);
	copy_location(s,id);
	state = 41;
      }
      break;

    case 41:  /* Build up the name of the preprocessor directive */
      if ((isspace(c) || (!isalpha(c)))) {
	Clear(value);
	Clear(comment);
	if (c == '\n') {
	  Ungetc(c,s);
	  state = 50;
	}
	else state = 42;
	copy_location(s,value);
	break;
      }
      Putc(c,id);
      break;

    case 42: /* Strip any leading space before preprocessor value */
      if (isspace(c)) {
	if (c == '\n') {
	  Ungetc(c,s);
	  state = 50;
	}
	break;
      }
      state = 43;
      /* no break intended here */

    case 43:
      /* Get preprocessor value */
      if (c == '\n') {
	Ungetc(c,s);
	state = 50;
      } else if (c == '/') {
	state = 45;
      } else {
	Putc(c,value);
	if (c == '\\') state = 44;
      }
      break;

    case 44:
      if (c == '\n') cpp_lines++;
      Putc(c,value);
      state = 43;
      break;

      /* States 45-48 are used to remove, but retain comments from macro values.  The comments
         will be placed in the output in an alternative form */

    case 45:
      if (c == '/') state = 46;
      else if (c == '*') state = 47;
      else {
	Putc('/',value);
	Putc(c,value);
	state = 43;
      }
      break;
    case 46:
      if (c == '\n') {
	Ungetc(c,s);
	cpp_lines++;
	state = 50;
      } else Putc(c,comment);
      break;
    case 47:
      if (c == '*') state = 48;
      else Putc(c,comment);
      break;
    case 48:
      if (c == '/') state = 43;
      else if (c == '*') Putc(c,comment);
      else {
	Putc('*',comment);
	Putc(c,comment);
	state = 47;
      }
      break;
    case 50:
      /* Check for various preprocessor directives */
      Chop(value);
      if (Cmp(id,"define") == 0) {
	if (allow) {
	  DOH *m, *v, *v1;
	  Seek(value,0,SEEK_SET);
	  m = Preprocessor_define(value,0);
	  if ((m) && !(Getattr(m,"args"))) {
	    v = Copy(Getattr(m,"value"));
	    if (Len(v)) {
	      silent_errors = 1;
	      v1 = Preprocessor_replace(v);
	      silent_errors = 0;
	      if (!check_id(v1)) {
		if (Len(comment) == 0)
		  Printf(ns,"%%constant %s %s;\n", Getattr(m,"name"), v1);
		else
		  Printf(ns,"%%constant %s %s; /*%s*/\n", Getattr(m,"name"),v1,comment);
		cpp_lines--;
	      }
	      Delete(v1);
	    }
	    Delete(v);
	  }
	  Delete(m);
	}
      } else if (Cmp(id,"undef") == 0) {
	if (allow) Preprocessor_undef(value);
      } else if (Cmp(id,"ifdef") == 0) {
	cond_lines[level] = Getline(id);
	level++;
	if (allow) {
	  start_level = level;
	  /* See if the identifier is in the hash table */
	  if (!Getattr(symbols,value)) allow = 0;
	  mask = 1;
	}
      } else if (Cmp(id,"ifndef") == 0) {
	cond_lines[level] = Getline(id);
	level++;
	if (allow) {
	  start_level = level;
	  /* See if the identifier is in the hash table */
	  if (Getattr(symbols,value)) allow = 0;
	  mask = 1;
	}
      } else if (Cmp(id,"else") == 0) {
	if (level <= 0) {
	  cpp_error(Getfile(s),Getline(id),"Misplaced #else.\n");
	} else {
	  cond_lines[level-1] = Getline(id);
	  if (allow) {
	    allow = 0;
	    mask = 0;
	  } else if (level == start_level) {
	    allow = 1;
	  }
	}
      } else if (Cmp(id,"endif") == 0) {
	level--;
	if (level < 0) {
	  cpp_error(Getfile(id),Getline(id),"Extraneous #endif ignored.\n");
	  level = 0;
	} else {
	  if (level < start_level) {
	    allow = 1;
	    start_level--;
	  }
	}
      } else if (Cmp(id,"if") == 0) {
	cond_lines[level] = Getline(id);
	level++;
	if (allow) {
	  start_level = level;
	  sval = Preprocessor_replace(value);
	  Seek(sval,0,SEEK_SET);
	  /*	  Printf(stdout,"Evaluating '%s'\n", sval); */
  	  val = Preprocessor_expr(sval,&e);
  	  if (e) {
  	    Seek(value,0,SEEK_SET);
	    /* cpp_error(Getfile(value),Getline(value),"Could not evaluate '%s'\n", value); */
  	    allow = 0;
  	  } else {
  	    if (val == 0)
  	      allow = 0;
  	  }
  	  mask = 1;
  	}
      } else if (Cmp(id,"elif") == 0) {
  	if (level == 0) {
  	  cpp_error(Getfile(s),Getline(id),"Misplaced #elif.\n");
  	} else {
  	  cond_lines[level-1] = Getline(id);
  	  if (allow) {
  	    allow = 0;
  	    mask = 0;
  	  } else if (level == start_level) {
  	    sval = Preprocessor_replace(value);
  	    Seek(sval,0,SEEK_SET);
  	    val = Preprocessor_expr(sval,&e);
  	    if (e) {
  	      Seek(value,0,SEEK_SET);
  	      /*      cpp_error(Getfile(value),Getline(value),"Could not evaluate '%s'\n", value);  */
  	      allow = 0;
  	    } else {
  	      if (val)
  		allow = 1*mask;
  	      else
  		allow = 0;
  	    }
  	  }
  	}
      } else if (Cmp(id,"line") == 0) {
      } else if (Cmp(id,"include") == 0) {
  	if ((include_all) && (allow)) {
  	  DOH *s1, *s2, *fn;
  	  Seek(value,0,SEEK_SET);
  	  fn = get_filename(value);
	  s1 = cpp_include(fn);
	  if (s1) {
  	    Printf(ns,"%%includefile \"%s\" {\n", Swig_last_file());
  	    s2 = Preprocessor_parse(s1);
  	    addline(ns,s2,allow);
  	    Printf(ns,"\n}\n");
	    Delete(s2);
  	  }
	  Delete(s1);
 	  Delete(fn);
  	}
      } else if (Cmp(id,"pragma") == 0) {
      } else if (Cmp(id,"level") == 0) {
	cpp_error(Getfile(s),Getline(id),"cpp debug: level = %d, startlevel = %d\n", level, start_level);
      }
      for (i = 0; i < cpp_lines; i++)
  	Putc('\n',ns);
      state = 0;
      break;

        /* Swig directives  */
    case 100:
      /* %{,%} block  */
      if (c == '{') {
  	start_line = Getline(s);
  	add_chunk(ns,chunk,allow);
  	copy_location(s,chunk);
  	Putc('%',chunk);
  	Putc(c,chunk);
  	state = 105;
      }
      /* %#cpp -  an embedded C preprocessor directive (we strip off the %)  */
      else if (c == '#') {
  	Putc(c,chunk);
  	state = 0;
      } else if (isidentifier(c)) {
  	Clear(decl);
  	Putc('%',decl);
  	Putc(c,decl);
  	state = 110;
      } else {
  	Putc(c,chunk);
  	state = 1;
      }
      break;

    case 105:
      Putc(c,chunk);
      if (c == '%')
  	state = 106;
      break;

    case 106:
      Putc(c,chunk);
      if (c == '}') {
  	state = 1;
	addline(ns,chunk,allow);
	Clear(chunk);
	copy_location(s,chunk);
      } else {
  	state = 105;
      }
      break;

    case 110:
      if (!isidchar(c)) {
  	Ungetc(c,s);
  	/* Look for common Swig directives  */
  	if ((Cmp(decl,"%include") == 0) || (Cmp(decl,"%import") == 0) || (Cmp(decl,"%extern") == 0)) {
  	  /* Got some kind of file inclusion directive  */
  	  if (allow) {
  	    DOH *s1, *s2, *fn;
  	    fn = get_filename(s);
	    s1 = cpp_include(fn);
	    if (s1) {
  	      add_chunk(ns,chunk,allow);
  	      copy_location(s,chunk);
  	      Printf(ns,"%sfile \"%s\" {\n", decl, Swig_last_file());
	      if ((Cmp(decl,"%import") == 0) || (Cmp(decl,"%extern") == 0)) {
		Preprocessor_define("WRAPEXTERN 1", 0);
	      }
  	      s2 = Preprocessor_parse(s1);
	      if ((Cmp(decl,"%import") == 0) || (Cmp(decl,"%extern") == 0)) {
		Preprocessor_undef("WRAPEXTERN");
	      }
  	      addline(ns,s2,allow);
  	      Printf(ns,"\n}\n");
	      Delete(s2);
	      Delete(s1);
  	    }
	    Delete(fn);
  	  }
  	  state = 1;
  	} else if (Cmp(decl,"%line") == 0) {
  	  /* Got a line directive  */
  	  state = 1;
  	} else if (Cmp(decl,"%define") == 0) {
  	  /* Got a define directive  */
  	  add_chunk(ns,chunk,allow);
  	  copy_location(s,chunk);
  	  Clear(value);
  	  copy_location(s,value);
  	  state = 150;
  	} else {
  	  Printf(chunk,"%s", decl);
  	  state = 1;
  	}
      } else {
  	Putc(c,decl);
      }
      break;

        /* Searching for the end of a %define statement  */
    case 150:
      Putc(c,value);
      if (c == '%') {
  	int i = 0;
  	char *d = "enddef\n";
  	for (i = 0; i < 7; i++) {
  	  c = Getc(s);
  	  Putc(c,value);
  	  if (c != d[i]) break;
  	}
  	if (i == 7) {
  	  /* Got the macro  */
  	  for (i = 0; i < 8; i++) {
  	    Delitem(value,DOH_END);
  	  }
  	  if (allow) {
  	    Seek(value,0,SEEK_SET);
  	    Preprocessor_define(value,1);
  	  }
  	  Putc('\n',ns);
  	  addline(ns,value,0);
  	  state = 0;
  	}
      }
      break;
    default :
      Printf(stderr,"cpp: Invalid parser state %d\n", state);
      abort();
      break;
    }
  }
  while (level > 0) {
    cpp_error(Getfile(s),-1,"Missing #endif for conditional starting on line %d\n", cond_lines[level-1]);
    level--;
  }
  if (state == 150) {
    Seek(value,0,SEEK_SET);
    cpp_error(Getfile(s),-1,"Missing %%enddef for macro starting on line %d\n",Getline(value));
  }
  if ((state >= 105) && (state < 107)) {
    cpp_error(Getfile(s),-1,"Unterminated %%{ ... %%} block starting on line %d\n", start_line);
  }
  if ((state >= 30) && (state < 40)) {
    cpp_error(Getfile(s),-1,"Unterminated comment starting on line %d\n", start_line);
  }
  add_chunk(ns,chunk,allow);
  copy_location(s,chunk);

  /*  DelScope(scp); */
  Delete(decl);
  Delete(id);
  Delete(value);
  Delete(comment);
  Delete(chunk);

  /*  fprintf(stderr,"cpp: %d\n", Len(Getattr(cpp,"symbols"))); */
  return ns;
}




