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

char cvsroot_cpp_c[] = "$Header$";

#include "swig.h"
#include "preprocessor.h"
#include <ctype.h>

static Hash     *cpp = 0;                /* C preprocessor data */
static int       include_all = 0;        /* Follow all includes */
static int       ignore_missing = 0; 
static int       import_all = 0;         /* Follow all includes, but as %import statements */
static int       imported_depth = 0;	 /* Depth of %imported files */
static int       single_include = 1;     /* Only include each file once */
static Hash     *included_files = 0;
static List     *dependencies = 0;
static SwigScanner *id_scan = 0;
static int       error_as_warning = 0;    /* Understand the cpp #error directive as a #warning */

/* Test a character to see if it starts an identifier */
#define isidentifier(c) ((isalpha(c)) || (c == '_') || (c == '$'))

/* Test a character to see if it valid in an identifier (after the first letter) */
#define isidchar(c) ((isalnum(c)) || (c == '_') || (c == '$'))


/* Skip whitespace */
static void
skip_whitespace(String *s, String *out) {
  int c;
  while ((c = StringGetc(s)) != EOF) {
    if (!isspace(c)) {
      StringUngetc(c,s);
      break;
    } else if (out) StringPutc(c,out);
  }
}

/* Skip to a specified character taking line breaks into account */
static int
skip_tochar(String *s, int ch, String *out) {
  int c;
  while ((c = StringGetc(s)) != EOF) {
    if (out) StringPutc(c,out);
    if (c == ch) break;
    if (c == '\\') {
      c = StringGetc(s);
      if ((c != EOF) && (out)) StringPutc(c,out);
    }
  }
  if (c == EOF) return -1;
  return 0;
}

static void
copy_location(const DOH *s1, DOH *s2) {
  Setfile(s2,Getfile((DOH *)s1));
  Setline(s2,Getline((DOH *)s1));
}

static String *cpp_include(String_or_char *fn, int sysfile) {
  String *s = sysfile ? Swig_include_sys(fn) : Swig_include(fn);
  if (s && single_include) {
    String *file = Getfile(s);
    if (Getattr(included_files,file)) {
      Delete(s);
      return 0;
    }
    Setattr(included_files,file,file);
  }
  if (!s) {
    Seek(fn,0,SEEK_SET);
    if (ignore_missing) {
      Swig_warning(WARN_PP_MISSING_FILE,Getfile(fn),Getline(fn),"Unable to find '%s'\n", fn);
    } else {
      Swig_error(Getfile(fn),Getline(fn),"Unable to find '%s'\n", fn);
    }
  } else {
    String *lf;
    Seek(s,0,SEEK_SET);
    if (!dependencies) {
      dependencies = NewList();
    }
    lf = Copy(Swig_last_file());
    Append(dependencies, lf);
    Delete(lf);
  }
  return s;
}

List *Preprocessor_depend(void) {
  return dependencies;
}

/* -----------------------------------------------------------------------------
 * void Preprocessor_cpp_init() - Initialize the preprocessor
 * ----------------------------------------------------------------------------- */
static String *k_args = 0;
static String *k_define = 0;
static String *k_defined = 0;
static String *k_elif = 0;
static String *k_else = 0;
static String *k_endif = 0;
static String *k_expanded = 0;
static String *k_if = 0;
static String *k_ifdef = 0;
static String *k_ifndef = 0;
static String *k_name = 0;
static String *k_swigmacro = 0;
static String *k_symbols = 0;
static String *k_undef = 0;
static String *k_value = 0;
static String *k_varargs = 0;
static String *k_error = 0;
static String *k_warning = 0;
static String *k_line = 0;
static String *k_include = 0;
static String *k_pragma = 0;
static String *k_level = 0;

static String *k_dline = 0;
static String *k_ddefine = 0;
static String *k_dinclude = 0;
static String *k_dimport = 0;
static String *k_dextern = 0;

static String *k_LINE = 0;
static String *k_FILE = 0;

void Preprocessor_init(void) {
  Hash *s;

  k_args = NewString("args");
  k_define = NewString("define");
  k_defined = NewString("defined");
  k_else = NewString("else");
  k_elif = NewString("elif");
  k_endif = NewString("endif");
  k_expanded = NewString("*expanded*");
  k_if = NewString("if");
  k_ifdef = NewString("ifdef");
  k_ifndef = NewString("ifndef");
  k_name = NewString("name");
  k_swigmacro = NewString("swigmacro");
  k_symbols = NewString("symbols");
  k_undef = NewString("undef");
  k_value = NewString("value");
  k_error = NewString("error");
  k_warning = NewString("warning");
  k_pragma = NewString("pragma");
  k_level = NewString("level");
  k_line = NewString("line");
  k_include = NewString("include");
  k_varargs = NewString("varargs");

  k_dinclude = NewString("%include");
  k_dimport = NewString("%import");
  k_dextern = NewString("%extern");
  k_ddefine = NewString("%define");
  k_dline = NewString("%line");


  k_LINE = NewString("__LINE__");
  k_FILE = NewString("__FILE__");

  cpp = NewHash();
  s =   NewHash();
  Setattr(cpp,k_symbols,s);
  Delete(s);
  Preprocessor_expr_init();            /* Initialize the expression evaluator */
  included_files = NewHash();

  id_scan = NewSwigScanner();;

}

void Preprocessor_delete(void) {
  Delete(k_args);
  Delete(k_define);
  Delete(k_defined);
  Delete(k_else);
  Delete(k_elif);
  Delete(k_endif);
  Delete(k_expanded);
  Delete(k_if);
  Delete(k_ifdef);
  Delete(k_ifndef);
  Delete(k_name);
  Delete(k_swigmacro);
  Delete(k_symbols);
  Delete(k_undef);
  Delete(k_value);
  Delete(k_error);
  Delete(k_warning);
  Delete(k_pragma);
  Delete(k_level);
  Delete(k_line);
  Delete(k_include);
  Delete(k_varargs);

  Delete(k_dinclude);
  Delete(k_dimport);
  Delete(k_dextern);
  Delete(k_ddefine);
  Delete(k_dline);


  Delete(k_LINE);
  Delete(k_FILE);
  Delete(cpp);
  Delete(included_files);
  Preprocessor_expr_delete();
  DelSwigScanner(id_scan);

  Delete(dependencies);

  Delete(Swig_last_file());
  Delete(Swig_add_directory(0));
}

/* -----------------------------------------------------------------------------
 * void Preprocessor_include_all() - Instruct preprocessor to include all files
 * ----------------------------------------------------------------------------- */
void Preprocessor_include_all(int a) {
  include_all = a;
}

void Preprocessor_import_all(int a) {
  import_all = a;
}

void Preprocessor_ignore_missing(int a) {
  ignore_missing = a;
}

void Preprocessor_error_as_warning(int a) {
  error_as_warning = a;
}


/* -----------------------------------------------------------------------------
 * Preprocessor_define()
 *
 * Defines a new C preprocessor symbol.   swigmacro specifies whether or not the macro has
 * SWIG macro semantics.
 * ----------------------------------------------------------------------------- */

 
String_or_char *Macro_vararg_name(String_or_char *str,
                                  String_or_char *line)
{
  String_or_char *argname, *varargname;
  char *s, *dots;

  argname = Copy(str);
  s = Char(argname);
  dots = strchr(s, '.');
  if (!dots) {
    Delete(argname);
    return NULL;
  }
  
  if (strcmp(dots, "...") != 0) {
    Swig_error(Getfile(line), Getline(line),
               "Illegal macro argument name '%s'\n", str);  
    Delete(argname);
    return NULL;
  }
  if (dots == s) {
      varargname = NewString("__VA_ARGS__");
  } else {
    *dots = '\0';
    varargname = NewString(s);
  }
  Delete(argname);
  return varargname;
}

Hash *Preprocessor_define(const String_or_char *_str, int swigmacro)
{
  String *macroname = 0, *argstr = 0, *macrovalue = 0, *file = 0, *s = 0;
  Hash   *macro = 0, *symbols = 0, *m1;
  List   *arglist = 0;
  int c, line;
  int    varargs = 0;
  String_or_char *str = (String_or_char *)_str;

  assert(cpp);
  assert(str);

  /* First make sure that string is actually a string */
  if (DohCheck(str)) {
    s = Copy(str);
    copy_location(str,s);
    str = s;
  } else {
    str = NewString((char *) str);
  }
  Seek(str,0,SEEK_SET);
  line = Getline(str);
  file = Getfile(str);

  /* Skip over any leading whitespace */
  skip_whitespace(str,0);

  /* Now look for a macro name */
  macroname = NewStringEmpty();
  while ((c = StringGetc(str)) != EOF) {
    if (c == '(') {
      argstr = NewStringEmpty();
      copy_location(str,argstr);
      /* It is a macro.  Go extract it's argument string */
      while ((c = StringGetc(str)) != EOF) {
	if (c == ')') break;
	else StringPutc(c,argstr);
      }
      if (c != ')') {
	Swig_error(Getfile(str),Getline(str), "Missing \')\' in macro parameters\n");
	goto macro_error;
      }
      break;
    } else if (isidchar(c) || (c == '%')) {
      StringPutc(c,macroname);
    } else if (isspace(c)) {
      break;
    } else if (c == '\\') {
      c = StringGetc(str);
      if (c != '\n') {
	StringUngetc(c,str);
	StringUngetc('\\',str);
	break;
      }
    } else {
      /*Swig_error(Getfile(str),Getline(str),"Illegal character in macro name\n");
	goto macro_error; */
      StringUngetc(c,str);
      break;
    }
  }
  if (!swigmacro)
    skip_whitespace(str,0);
  macrovalue = NewStringEmpty();
  while ((c = StringGetc(str)) != EOF) {
    StringPutc(c,macrovalue);
  }

  /* If there are any macro arguments, convert into a list */
  if (argstr) {
    String *argname, *varargname;
    arglist = NewList();
    Seek(argstr,0,SEEK_SET);
    argname = NewStringEmpty();
    while ((c = StringGetc(argstr)) != EOF) {
      if (c == ',') {
	varargname = Macro_vararg_name(argname, str);
	if (varargname) {
	  Delete(varargname);
          Swig_error(Getfile(str),Getline(str),"Variable-length macro argument must be last parameter\n");	  
	} else {
	  Append(arglist,argname);
	}
	Delete(argname);
	argname = NewStringEmpty();
      } else if (isidchar(c) || (c == '.')) {
	StringPutc(c,argname);
      } else if (!(isspace(c) || (c == '\\'))) {
	Delete(argname);
	Swig_error(Getfile(str),Getline(str),"Illegal character in macro argument name\n");
	goto macro_error;
      }
    }    
    if (Len(argname)) {
      /* Check for varargs */
      varargname = Macro_vararg_name(argname, str);
      if (varargname) {
	Append(arglist,varargname);
	Delete(varargname);
	varargs = 1;
      } else {
	Append(arglist,argname);
      }
    }
    Delete(argname);
  }

  if (!swigmacro) {
    Replace(macrovalue,"\\\n"," ", DOH_REPLACE_NOQUOTE);
  }

  /* Look for special # substitutions.   We only consider # that appears
     outside of quotes and comments */

  {
    int state = 0;
    char *cc = Char(macrovalue);
    while (*cc) {
      switch(state) {
      case 0:
	if (*cc == '#') *cc = '\001';
	else if (*cc == '/') state = 10;
	else if (*cc == '\'') state = 20;
	else if (*cc == '\"') state = 30;
	break;
      case 10:
	if (*cc == '*') state = 11;
	else if (*cc == '/') state = 15;
	else {
	  state = 0;
	  cc--;
	}
	break;
      case 11:
	if (*cc == '*') state = 12;
	break;
      case 12:
	if (*cc == '/') state = 0;
	else if (*cc != '*') state = 11;
	break;
      case 15:
	if (*cc == '\n') state = 0;
	break;
      case 20:
	if (*cc == '\'') state = 0;
	if (*cc == '\\') state = 21;
	break;
      case 21:
	state = 20;
	break;
      case 30:
	if (*cc == '\"') state = 0;
	if (*cc == '\\') state = 31;
	break;
      case 31:
	state = 30;
	break;
      default:
	break;
      }
      cc++;
    }
  }

  /* Get rid of whitespace surrounding # */
  /*  Replace(macrovalue,"#","\001",DOH_REPLACE_NOQUOTE); */
  while(strstr(Char(macrovalue),"\001 ")) {
    Replace(macrovalue,"\001 ","\001", DOH_REPLACE_ANY);
  }
  while(strstr(Char(macrovalue)," \001")) {
    Replace(macrovalue," \001","\001", DOH_REPLACE_ANY);
  }
  /* Replace '##' with a special token */
  Replace(macrovalue,"\001\001","\002", DOH_REPLACE_ANY);
  /* Replace '#@' with a special token */
  Replace(macrovalue,"\001@","\004", DOH_REPLACE_ANY);
  /* Replace '##@' with a special token */
  Replace(macrovalue,"\002@","\005", DOH_REPLACE_ANY);  

  /* Go create the macro */
  macro = NewHash();
  Setattr(macro,k_name,macroname);

  if (arglist) {
    Setattr(macro,k_args,arglist);
    Delete(arglist);
    if (varargs) {
      Setattr(macro,k_varargs,"1");
    }
  }
  Setattr(macro,k_value,macrovalue);
  Setline(macro,line);
  Setfile(macro,file);
  if (swigmacro) {
    Setattr(macro,k_swigmacro,"1");
  }
  symbols = HashGetAttr(cpp,k_symbols);
  if ((m1 = HashGetAttr(symbols,macroname))) {
    if (!HashCheckAttr(m1,k_value,macrovalue)) {
      Swig_error(Getfile(str),Getline(str),"Macro '%s' redefined,\n",macroname);    
      Swig_error(Getfile(m1),Getline(m1),"previous definition of '%s'.\n",macroname);
      goto macro_error;
    }
  } else {
    Setattr(symbols,macroname,macro);
    Delete(macro);
  }
  
  Delete(macroname);
  Delete(macrovalue);
  
  Delete(str);
  Delete(argstr);
  return macro;

 macro_error:
  Delete(str);
  Delete(argstr);
  Delete(arglist);
  Delete(macroname);
  Delete(macrovalue);
  return 0;
}

/* -----------------------------------------------------------------------------
 * Preprocessor_undef()
 *
 * Undefines a macro.
 * ----------------------------------------------------------------------------- */
void Preprocessor_undef(const String_or_char *str)
{
  Hash *symbols;
  assert(cpp);
  symbols = HashGetAttr(cpp,k_symbols);
  Delattr(symbols,str);
}

/* -----------------------------------------------------------------------------
 * find_args()
 *
 * Isolates macro arguments and returns them in a list.   For each argument,
 * leading and trailing whitespace is stripped (ala K&R, pg. 230).
 * ----------------------------------------------------------------------------- */
static List *
find_args(String *s)
{
  List   *args;
  String *str;
  int   c, level;
  long  pos;

  /* Create a new list */
  args = NewList();
  copy_location(s,args);

  /* First look for a '(' */
  pos = Tell(s);
  skip_whitespace(s,0);

  /* Now see if the next character is a '(' */
  c = StringGetc(s);
  if (c != '(') {
    /* Not a macro, bail out now! */
    Seek(s,pos, SEEK_SET);
    Delete(args);
    return 0;
  }
  c = StringGetc(s);
  /* Okay.  This appears to be a macro so we will start isolating arguments */
  while (c != EOF) {
    if (isspace(c)) {
      skip_whitespace(s,0);                    /* Skip leading whitespace */
      c = StringGetc(s);
    }
    str = NewStringEmpty();
    copy_location(s,str);
    level = 0;
    while (c != EOF) {
      if (c == '\"') {
	StringPutc(c,str);
	skip_tochar(s,'\"',str);
	c = StringGetc(s);
	continue;
      } else if (c == '\'') {
	StringPutc(c,str);
	skip_tochar(s,'\'',str);
	c = StringGetc(s);
	continue;
      }
      if ((c == ',') && (level == 0)) break;
      if ((c == ')') && (level == 0)) break;
      StringPutc(c,str);
      if (c == '(') level++;
      if (c == ')') level--;
      c = StringGetc(s);
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
    c = StringGetc(s);
  }
 unterm:
  Swig_error(Getfile(args),Getline(args),"Unterminated macro call.\n");
  return args;
}

/* -----------------------------------------------------------------------------
 * DOH *get_filename(DOH *str)
 *
 * Read a filename from str.   A filename can be enclose in quotes, angle brackets,
 * or bare.
 * ----------------------------------------------------------------------------- */

static String *
get_filename(String *str, int* sysfile) {
  String *fn;
  int  c;

  skip_whitespace(str,0);
  fn = NewStringEmpty();
  copy_location(str,fn);
  c = StringGetc(str);
  *sysfile = 0;
  if (c == '\"') {
    while (((c = StringGetc(str)) != EOF) && (c != '\"')) StringPutc(c,fn);
  } else if (c == '<') {
    *sysfile = 1;
    while (((c = StringGetc(str)) != EOF) && (c != '>'))  StringPutc(c,fn);
  } else {
    StringPutc(c,fn);
    while (((c = StringGetc(str)) != EOF) && (!isspace(c))) StringPutc(c,fn);
    if (isspace(c)) StringUngetc(c,str);
  }
#if defined(_WIN32) || defined(MACSWIG)
  /* accept Unix path separator on non-Unix systems */
  Replaceall(fn, "/", SWIG_FILE_DELIMETER);
#endif
#if defined(__CYGWIN__)
  /* accept Windows path separator in addition to Unix path separator */
  Replaceall(fn, "\\", SWIG_FILE_DELIMETER);
#endif
  Seek(fn,0,SEEK_SET);
  return fn;
}

static String *
get_options(String *str) {

  int  c;
  skip_whitespace(str,0);
  c = StringGetc(str);
  if (c == '(') {
    String *opt;
    int     level = 1;
    opt = NewString("(");
    while (((c = StringGetc(str)) != EOF)) {
      StringPutc(c,opt);
      if (c == ')') {
	level--;
	if (!level) return opt;
      }
      if (c == '(') level++;
    }
    Delete(opt);
    return 0;
  } else {
    StringUngetc(c,str);
    return 0;
  }
}
/* -----------------------------------------------------------------------------
 * expand_macro()
 *
 * Perform macro expansion and return a new string.  Returns NULL if some sort
 * of error occurred.
 * ----------------------------------------------------------------------------- */

static String *
expand_macro(String *name, List *args)
{
  String *ns;
  DOH *symbols, *macro, *margs, *mvalue, *temp, *tempa, *e;
  DOH *Preprocessor_replace(DOH *);
  int i, l;
  int isvarargs = 0;

  symbols = HashGetAttr(cpp,k_symbols);
  if (!symbols) return 0;

  /* See if the name is actually defined */
  macro = HashGetAttr(symbols,name);
  if (!macro) return 0;
  if (HashGetAttr(macro,k_expanded)) {
    ns = NewStringEmpty();
    StringAppend(ns,name);
    if (args) {
      if (Len(args))
	StringPutc('(',ns);
      for (i = 0; i < Len(args); i++) {
	StringAppend(ns,Getitem(args,i));
	if (i < (Len(args) -1)) StringPutc(',',ns);
      }
      if (i)
	StringPutc(')',ns);
    }
    return ns;
  }

  /* Get macro arguments and value */
  mvalue = HashGetAttr(macro,k_value);
  assert(mvalue);
  margs = HashGetAttr(macro,k_args);

  if (args && HashGetAttr(macro,k_varargs)) {
    isvarargs = 1;
    /* Variable length argument macro.  We need to collect all of the extra arguments into a single argument */
    if (Len(args) >= (Len(margs)-1)) {
      int i;
      int vi, na;
      String *vararg = NewStringEmpty();
      vi = Len(margs)-1;
      na = Len(args);
      for (i = vi; i < na; i++) {
	StringAppend(vararg,Getitem(args,i));
	if ((i+1) < na) {
	  StringAppend(vararg,",");
	}
      }
      /* Remove arguments */
      for (i = vi; i < na; i++) {
	Delitem(args,vi);
      }
      Append(args,vararg);
      Delete(vararg);
    }
  }
  /* If there are arguments, see if they match what we were given */
  if (args && (margs) && (Len(margs) != Len(args))) {
    if (Len(margs) > (1+isvarargs))
      Swig_error(Getfile(args),Getline(args),"Macro '%s' expects %d arguments\n", name, Len(margs)-isvarargs);
    else if (Len(margs) == (1+isvarargs))
      Swig_error(Getfile(args),Getline(args),"Macro '%s' expects 1 argument\n", name);
    else
      Swig_error(Getfile(args),Getline(args),"Macro '%s' expects no arguments\n", name);
    return 0;
  }

  /* If the macro expects arguments, but none were supplied, we leave it in place */
  if (!args && (margs) && Len(margs) > 0) {
    return NewString(name);
  }

  /* Copy the macro value */
  ns = Copy(mvalue);
  copy_location(mvalue,ns);

  /* Tag the macro as being expanded.   This is to avoid recursion in
     macro expansion */

  temp = NewStringEmpty();
  tempa = NewStringEmpty();
  if (args && margs) {
    l = Len(margs);
    for (i = 0; i < l; i++) {
      DOH *arg, *aname;
      String *reparg;
      arg = Getitem(args,i);           /* Get an argument value */
      reparg = Preprocessor_replace(arg);
      aname = Getitem(margs,i);        /* Get macro argument name */
      if (strstr(StringChar(ns),"\001")) {
	/* Try to replace a quoted version of the argument */
	Clear(temp);
	Clear(tempa);
	Printf(temp,"\001%s", aname);
	Printf(tempa,"\"%s\"",arg);
	Replace(ns, temp, tempa, DOH_REPLACE_ID_END);
      }
      if (strstr(StringChar(ns),"\002")) {
	/* Look for concatenation tokens */
	Clear(temp);
	Clear(tempa);
	Printf(temp,"\002%s",aname);
	StringAppend(tempa,"\002\003");
	Replace(ns, temp, tempa, DOH_REPLACE_ID_END);
	Clear(temp);
	Clear(tempa);
	Printf(temp,"%s\002",aname);
	StringAppend(tempa,"\003\002");
	Replace(ns,temp,tempa, DOH_REPLACE_ID_BEGIN);
      }

      /* Non-standard macro expansion.   The value `x` is replaced by a quoted
	 version of the argument except that if the argument is already quoted
	 nothing happens */

      if (strstr(StringChar(ns),"`")) {
	String *rep;
	char *c;
	Clear(temp);
	Printf(temp,"`%s`",aname);
	c = Char(arg);
	if (*c == '\"') {
	  rep = arg;
	} else {
	  Clear(tempa);
	  Printf(tempa,"\"%s\"",arg);
	  rep = tempa;
	}
	Replace(ns,temp,rep, DOH_REPLACE_ANY);
      }

      /* Non-standard mangle expansions.  
	 The #@Name is replaced by mangle_arg(Name). */
      if (strstr(StringChar(ns),"\004")) {
	String* marg = Swig_string_mangle(arg);
	Clear(temp);
	Printf(temp,"\004%s", aname);
	Replace(ns, temp, marg, DOH_REPLACE_ID_END);
	Delete(marg);
      }
      if (strstr(StringChar(ns),"\005")) {
	String* marg = Swig_string_mangle(arg);
	Clear(temp);
	Clear(tempa);
	Printf(temp,"\005%s", aname);
	Printf(tempa,"\"%s\"", marg);
	Replace(ns, temp, tempa, DOH_REPLACE_ID_END);
	Delete(marg);
      }

      if (isvarargs && i == l-1 && Len(arg) == 0) {
	/* Zero length varargs macro argument.   We search for commas that might appear before and nuke them */
	char *a, *s, *t, *name;
        int namelen;
	s = StringChar(ns);
        name = Char(aname);
        namelen = Len(aname);
	a = strstr(s,name);
	while (a) {
	  char ca = a[namelen+1];
          if (!isidchar(ca)) {
          /* Matched the entire vararg name, not just a prefix */
	    t = a-1;
	    if (*t == '\002') {
	      t--;
	      while (t >= s) {
		if (isspace((int) *t)) t--;
		else if (*t == ',') {
		  *t = ' ';
		} else break;
	      }
	    }
	  }
	  a = strstr(a+namelen,name);
	}
      }
      /*      Replace(ns, aname, arg, DOH_REPLACE_ID); */
      Replace(ns, aname, reparg, DOH_REPLACE_ID);   /* Replace expanded args */
      Replace(ns, "\003", arg, DOH_REPLACE_ANY);    /* Replace unexpanded arg */
      Delete(reparg);
    }
  }
  Replace(ns,"\002","",DOH_REPLACE_ANY);    /* Get rid of concatenation tokens */
  Replace(ns,"\001","#",DOH_REPLACE_ANY);   /* Put # back (non-standard C) */
  Replace(ns,"\004","#@",DOH_REPLACE_ANY);   /* Put # back (non-standard C) */

  /* Expand this macro even further */
  Setattr(macro,k_expanded,"1"); 

  e = Preprocessor_replace(ns);

  Delattr(macro,k_expanded);
  Delete(ns);

  if (HashGetAttr(macro,k_swigmacro)) {
    String *g;
    String *f = NewStringEmpty();
    Seek(e,0,SEEK_SET);
    copy_location(macro,e);
    g = Preprocessor_parse(e);

    /* Drop the macro in place, but with a marker around it */
#if 0
    Printf(f,"/*@%s,%d,%s@*/%s/*@@*/", Getfile(macro), Getline(macro), name, g);
#else
    Append(f,g);
#endif
    /*    Printf(f," }\n"); */
    Delete(g);
    Delete(e);
    e = f;
  }
  Delete(temp);
  Delete(tempa);
  return e;
}

/* -----------------------------------------------------------------------------
 * evaluate_args()
 *
 * Evaluate the arguments of a macro 
 * ----------------------------------------------------------------------------- */

List *evaluate_args(List *x) {
  Iterator i;
  String *Preprocessor_replace(String *);
  List *nl = NewList();

  for (i = First(x); i.item; i = Next(i)) {
    Append(nl,Preprocessor_replace(i.item));
  }
  return nl;
}

/* -----------------------------------------------------------------------------
 * DOH *Preprocessor_replace(DOH *s)
 *
 * Performs a macro substitution on a string s.  Returns a new string with
 * substitutions applied.   This function works by walking down s and looking
 * for identifiers.   When found, a check is made to see if they are macros
 * which are then expanded.
 * ----------------------------------------------------------------------------- */

/* #define SWIG_PUT_BUFF  */

DOH *
Preprocessor_replace(DOH *s)
{
  DOH   *ns, *symbols, *m;
  int   c, i, state = 0;

  String   *id = NewStringEmpty();
  
  assert(cpp);
  symbols = HashGetAttr(cpp,k_symbols);

  ns = NewStringEmpty();
  copy_location(s,ns);
  Seek(s,0,SEEK_SET);

  /* Try to locate identifiers in s and replace them with macro replacements */
  while ((c = StringGetc(s)) != EOF) {
    switch (state) {
    case 0:
      if (isidentifier(c) || (c == '%')) {
	Clear(id);
	StringPutc(c,id);
	state = 1;
      } else if (c == '\"') {
	StringPutc(c,ns);
	skip_tochar(s,'\"',ns);
      } else if (c == '\'') {
	StringPutc(c,ns);
	skip_tochar(s,'\'',ns);
      } else if (c == '/') {
	StringPutc(c,ns);
	state = 10;
      } else {
	StringPutc(c,ns);
      }
      break;
    case 1:  /* An identifier */
      if (isidchar(c)) {
	StringPutc(c,id);
	state = 1;
      } else {
	/* We found the end of a valid identifier */
	StringUngetc(c,s);
	/* See if this is the special "defined" macro */
	if (StringEqual(k_defined,id)) {
	  DOH *args = 0;
	  /* See whether or not a paranthesis has been used */
	  skip_whitespace(s,0);
	  c = StringGetc(s);
	  if (c == '(') {
	    StringUngetc(c,s);
	    args = find_args(s);
	  } else if (isidchar(c)) {
	    DOH *arg = NewStringEmpty();
	    args = NewList();
	    StringPutc(c,arg);
	    while (((c = StringGetc(s)) != EOF)) {
	      if (!isidchar(c)) {
		StringUngetc(c,s);
		break;
	      }
	      StringPutc(c,arg);
	    }
	    if (Len(arg)) Append(args,arg);
	    Delete(arg);
	  } else {
	    Seek(s,-1,SEEK_CUR);
	  }
	  if ((!args) || (!Len(args))) {
	    /* This is not a defined() macro. */
	    StringAppend(ns,id);
	    state = 0;
	    break;
	  }
	  for (i = 0; i < Len(args); i++) {
	    DOH *o = Getitem(args,i);
	    if (!HashGetAttr(symbols,o)) {
	      break;
	    }
	  }
	  if (i < Len(args)) StringPutc('0',ns);
	  else StringPutc('1',ns);
	  Delete(args);
	  state = 0;
	  break;
	}
	if (StringEqual(k_LINE,id)) {
	  Printf(ns,"%d",Getline(s));
	  state = 0;
	  break;
	}
	if (StringEqual(k_FILE,id)) {
	  String *fn = Copy(Getfile(s));
	  Replaceall(fn,"\\","\\\\");
	  Printf(ns,"\"%s\"",fn);
	  Delete(fn);
	  state = 0;
	  break;
	}
	/* See if the macro is defined in the preprocessor symbol table */
	if ((m = HashGetAttr(symbols,id))) {
	  DOH *args = 0;
	  DOH *e;
	  /* See if the macro expects arguments */
	  if (HashGetAttr(m,k_args)) {
	    /* Yep.  We need to go find the arguments and do a substitution */
	    args = find_args(s);
	    if (!Len(args)) {
	      Delete(args);
	      args = 0;
	    }
	  } else {
	    args = 0;
	  }	  
	  e = expand_macro(id,args);
	  if (e) {
	    StringAppend(ns,e);
	  }
	  Delete(e);
	  Delete(args);
	} else {
	  StringAppend(ns,id);
	}
	state = 0;
      }
      break;
    case 10:
      if (c == '/') state = 11;
      else if (c == '*') state = 12;
      else {
	StringUngetc(c,s);
	state = 0;
	break;
      }
      StringPutc(c,ns);
      break;
    case 11:
      StringPutc(c,ns);
      if (c == '\n') state = 0;
      break;
    case 12:
      StringPutc(c,ns);
      if (c == '*') state = 13;
      break;
    case 13:
      StringPutc(c,ns);
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
    if (StringEqual(k_defined,id)) {
      Swig_error(Getfile(s),Getline(s),"No arguments given to defined()\n");
    } else if ((m = HashGetAttr(symbols,id))) {
	DOH *e;
	/* Yes.  There is a macro here */
	/* See if the macro expects arguments */
	/*	if (Getattr(m,"args")) {
	  Swig_error(Getfile(id),Getline(id),"Macro arguments expected.\n");
	  } */
	e = expand_macro(id,0);
	StringAppend(ns,e);
	Delete(e);
    } else {
      StringAppend(ns,id);
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
  int c;
  int hastok = 0;
  SwigScanner *scan = id_scan;

  Seek(s,0,SEEK_SET);

  SwigScanner_clear(scan);
  s = Copy(s);
  Seek(s,SEEK_SET,0);
  SwigScanner_push(scan,s);
  while ((c = SwigScanner_token(scan))) {
    hastok = 1;
    if ((c == SWIG_TOKEN_ID) || (c == SWIG_TOKEN_LBRACE) || (c == SWIG_TOKEN_RBRACE)) return 1;
  }
  if (!hastok) return 1;
  return 0;
}

/* addline().  Utility function for adding lines to a chunk */
static void
addline(DOH *s1, DOH *s2, int allow)
{
  if (allow) {
    StringAppend(s1,s2);
  } else {
    char *c = Char(s2);
    while (*c) {
      if (*c == '\n') StringPutc('\n',s1);
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

/*
  push/pop_imported(): helper functions for defining and undefining
  SWIGIMPORTED (when %importing a file).
 */
static void
push_imported() {
  if (imported_depth == 0) {
    Preprocessor_define("SWIGIMPORTED 1", 0);
  }
  ++imported_depth;
}

static void
pop_imported() {
  --imported_depth;
  if (imported_depth == 0) {
    Preprocessor_undef("SWIGIMPORTED");
  }
}


/* -----------------------------------------------------------------------------
 * Preprocessor_parse()
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

String *
Preprocessor_parse(String *s)
{
  String  *ns;             /* New string containing the preprocessed text */
  String  *chunk, *decl;
  Hash    *symbols;
  String  *id = 0, *value = 0, *comment = 0;
  int    i, state, e, c;
  int    start_line = 0;
  int    allow = 1;
  int    level = 0;
  int    dlevel = 0;
  int    mask = 0;
  int    start_level = 0;
  int    cpp_lines = 0;
  int    cond_lines[256];

  /* Blow away all carriage returns */
  Replace(s,"\015","",DOH_REPLACE_ANY); 

  ns = NewStringEmpty();        /* Return result */

  decl = NewStringEmpty();
  id = NewStringEmpty();
  value = NewStringEmpty();
  comment = NewStringEmpty();
  chunk = NewStringEmpty();
  copy_location(s,chunk);
  copy_location(s,ns);
  symbols = HashGetAttr(cpp,k_symbols);

  state = 0;
  while ((c = StringGetc(s)) != EOF) {
    switch(state) {
    case 0:        /* Initial state - in first column */
      /* Look for C preprocessor directives.   Otherwise, go directly to state 1 */
      if (c == '#') {
	add_chunk(ns,chunk,allow);
	copy_location(s,chunk);
	cpp_lines = 1;
	state = 40;
      } else if (isspace(c)) {
	StringPutc(c,chunk);
	skip_whitespace(s,chunk);
      } else {
	state = 1;
	StringUngetc(c,s);
      }
      break;
    case 1:       /* Non-preprocessor directive */
      /* Look for SWIG directives */
      if (c == '%') {
	state = 100;
	break;
      }
      StringPutc(c,chunk);
      if (c == '\n') state = 0;
      else if (c == '\"') {
	start_line = Getline(s);
	if (skip_tochar(s,'\"',chunk) < 0) {
	  Swig_error(Getfile(s),-1,"Unterminated string constant starting at line %d\n",start_line);
	}
      } else if (c == '\'') {
	start_line = Getline(s);
	if (skip_tochar(s,'\'',chunk) < 0) {
	  Swig_error(Getfile(s),-1,"Unterminated character constant starting at line %d\n",start_line);
	}
      }
      else if (c == '/') state = 30;  /* Comment */
      break;

    case 30:      /* Possibly a comment string of some sort */
      start_line = Getline(s);
      StringPutc(c,chunk);
      if (c == '/') state = 31;
      else if (c == '*') state = 32;
      else state = 1;
      break;
    case 31:
      StringPutc(c,chunk);
      if (c == '\n') state = 0;
      break;
    case 32:
      StringPutc(c,chunk);
      if (c == '*') state = 33;
      break;
    case 33:
      StringPutc(c,chunk);
      if (c == '/') state = 1;
      else if (c != '*') state = 32;
      break;

    case 40:   /* Start of a C preprocessor directive */
      if (c == '\n') {
	StringPutc('\n',chunk);
	state = 0;
      } else if (isspace(c)) {
	state = 40;
      } else {
	/* Got the start of a preprocessor directive */
	StringUngetc(c,s);
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
	  StringUngetc(c,s);
	  state = 50;
	} else {
	  state = 42;
	  if (!isspace(c)) {
	    StringUngetc(c,s);
	  }
	}

	copy_location(s,value);
	break;
      }
      StringPutc(c,id);
      break;

    case 42: /* Strip any leading space before preprocessor value */
      if (isspace(c)) {
	if (c == '\n') {
	  StringUngetc(c,s);
	  state = 50;
	}
	break;
      }
      state = 43;
      /* no break intended here */

    case 43:
      /* Get preprocessor value */
      if (c == '\n') {
	StringUngetc(c,s);
	state = 50;
      } else if (c == '/') {
	state = 45;
      } else if (c == '\"') {
	StringPutc(c,value);
	skip_tochar(s,'\"',value);
      } else if (c == '\'') {
	StringPutc(c,value);
	skip_tochar(s,'\'',value);
      } else {
	StringPutc(c,value);
	if (c == '\\') state = 44;
      }
      break;

    case 44:
      if (c == '\n') {
	StringPutc(c,value);
	cpp_lines++;
      } else {
	StringUngetc(c,s);
      }
      state = 43;
      break;

      /* States 45-48 are used to remove, but retain comments from macro values.  The comments
         will be placed in the output in an alternative form */

    case 45:
      if (c == '/') state = 46;
      else if (c == '*') state = 47;
      else if (c == '\n') {
	StringPutc('/',value);
	StringUngetc(c,s);
	cpp_lines++;
	state = 50;
      } else {
	StringPutc('/',value);
	StringPutc(c,value);
	state = 43;
      }
      break;
    case 46:
      if (c == '\n') {
	StringUngetc(c,s);
	cpp_lines++;
	state = 50;
      } else StringPutc(c,comment);
      break;
    case 47:
      if (c == '*') state = 48;
      else StringPutc(c,comment);
      break;
    case 48:
      if (c == '/') state = 43;
      else if (c == '*') StringPutc(c,comment);
      else {
	StringPutc('*',comment);
	StringPutc(c,comment);
	state = 47;
      }
      break;
    case 50:
      /* Check for various preprocessor directives */
      Chop(value);
      if (StringEqual(id,k_define)) {
	if (allow) {
	  DOH *m, *v, *v1;
	  Seek(value,0,SEEK_SET);
	  m = Preprocessor_define(value,0);
	  if ((m) && !(HashGetAttr(m,k_args))) {
	    v = Copy(HashGetAttr(m,k_value));
	    if (Len(v)) {
	      Swig_error_silent(1);
	      v1 = Preprocessor_replace(v);
	      Swig_error_silent(0);
	      /*	      Printf(stdout,"checking '%s'\n", v1); */
	      if (!check_id(v1)) {
		if (Len(comment) == 0)
		  Printf(ns,"%%constant %s = %s;\n", HashGetAttr(m,k_name), v1);
		else
		  Printf(ns,"%%constant %s = %s; /*%s*/\n", HashGetAttr(m,k_name),v1,comment);
		cpp_lines--;
	      }
	      Delete(v1);
	    }
	    Delete(v);
	  }
	}
      } else if (StringEqual(id,k_undef)) {
	if (allow) Preprocessor_undef(value);
      } else if (StringEqual(id,k_ifdef)) {
	cond_lines[level] = Getline(id);
	level++;
	if (allow) {
	  start_level = level;
	  /* See if the identifier is in the hash table */
	  if (!HashGetAttr(symbols,value)) allow = 0;
	  mask = 1;
	}
      } else if (StringEqual(id,k_ifndef)) {
	cond_lines[level] = Getline(id);
	level++;
	if (allow) {
	  start_level = level;
	  /* See if the identifier is in the hash table */
	  if (HashGetAttr(symbols,value)) allow = 0;
	  mask = 1;
	}
      } else if (StringEqual(id,k_else)) {
	if (level <= 0) {
	  Swig_error(Getfile(s),Getline(id),"Misplaced #else.\n");
	} else {
	  cond_lines[level-1] = Getline(id);
	  if (allow) {
	    allow = 0;
	    mask = 0;
	  } else if (level == start_level) {
	    allow = 1*mask;
	  }
	}
      } else if (StringEqual(id,k_endif)) {
	level--;
	if (level < 0) {
	  Swig_error(Getfile(id),Getline(id),"Extraneous #endif.\n");
	  level = 0;
	} else {
	  if (level < start_level) {
	    allow = 1;
	    start_level--;
	  }
	}
      } else if (StringEqual(id,k_if)) {
	cond_lines[level] = Getline(id);
	level++;
	if (allow) {
	  int val;
	  String *sval = Preprocessor_replace(value);
	  start_level = level;
	  Seek(sval,0,SEEK_SET);
	  /*	  Printf(stdout,"Evaluating '%s'\n", sval); */
  	  val = Preprocessor_expr(sval,&e);
  	  if (e) {
	    char * msg = Preprocessor_expr_error();
  	    Seek(value,0,SEEK_SET);
	    Swig_warning(WARN_PP_EVALUATION,Getfile(value),Getline(value),"Could not evaluate '%s'\n", value);
	    if (msg)
	      Swig_warning(WARN_PP_EVALUATION,Getfile(value),Getline(value),"Error: '%s'\n", msg);
  	    allow = 0;
  	  } else {
  	    if (val == 0)
  	      allow = 0;
  	  }
  	  mask = 1;
  	}
      } else if (StringEqual(id,k_elif)) {
  	if (level == 0) {
  	  Swig_error(Getfile(s),Getline(id),"Misplaced #elif.\n");
  	} else {
  	  cond_lines[level-1] = Getline(id);
  	  if (allow) {
  	    allow = 0;
  	    mask = 0;
  	  } else if (level == start_level) {
	    int val;
  	    String *sval = Preprocessor_replace(value);
  	    Seek(sval,0,SEEK_SET);
  	    val = Preprocessor_expr(sval,&e);
  	    if (e) {
	      char * msg = Preprocessor_expr_error();
  	      Seek(value,0,SEEK_SET);
  	      Swig_warning(WARN_PP_EVALUATION,Getfile(value),Getline(value),"Could not evaluate '%s'\n", value);
	      if (msg)
		Swig_warning(WARN_PP_EVALUATION,Getfile(value),Getline(value),"Error: '%s'\n", msg);
  	      allow = 0;
  	    } else {
  	      if (val)
  		allow = 1*mask;
  	      else
  		allow = 0;
  	    }
  	  }
  	}
      } else if (StringEqual(id,k_warning)) {
	if (allow) {
	  Swig_warning(WARN_PP_CPP_WARNING,Getfile(s),Getline(id),"%s\n", value);
	}
      } else if (StringEqual(id,k_error)) {
	if (allow) {
	  if (error_as_warning) {
	    Swig_warning(WARN_PP_CPP_WARNING,Getfile(s),Getline(id),"%s\n", value);
	  } else {
	    Swig_error(Getfile(s),Getline(id),"%s\n",value);
	  }
	}
      } else if (StringEqual(id,k_line)) {
      } else if (StringEqual(id,k_include)) {
  	if (((include_all) || (import_all)) && (allow)) {
  	  String *s1, *s2, *fn;
	  char *dirname; int sysfile = 0;
	  if (include_all && import_all) {
	    Swig_warning(WARN_PP_INCLUDEALL_IMPORTALL,Getfile(s),Getline(id),"Both includeall and importall are defined: using includeall");
	    import_all = 0;
	  }
  	  Seek(value,0,SEEK_SET);
  	  fn = get_filename(value, &sysfile);
	  s1 = cpp_include(fn, sysfile);
	  if (s1) {
	    if (include_all) 
	      Printf(ns,"%%includefile \"%s\" [\n", Swig_last_file());
	    else if (import_all) {
	      Printf(ns,"%%importfile \"%s\" [\n", Swig_last_file());
	      push_imported();
	    }

	    /* See if the filename has a directory component */
	    dirname = Swig_file_dirname(Swig_last_file());
	    if (sysfile || !strlen(dirname)) dirname = 0;
	    if (dirname) {
	      dirname[strlen(dirname)-1] = 0;   /* Kill trailing directory delimeter */
	      Swig_push_directory(dirname);
	    }
  	    s2 = Preprocessor_parse(s1);
  	    addline(ns,s2,allow);
  	    Printf(ns,"\n]");
	    if (dirname) {
	      Swig_pop_directory();
	    }
	    if (import_all) {
	      pop_imported();
	    }
	    Delete(s2);
  	  }
	  Delete(s1);
 	  Delete(fn);
  	}
      } else if (StringEqual(id,k_pragma)) {
	if (Strncmp(value,"SWIG ",5) == 0) {
	  char *c = Char(value)+5;
	  while (*c && (isspace((int)*c))) c++;
	  if (*c) {
	    if (strncmp(c,"nowarn=",7) == 0) {
	      Swig_warnfilter(c+7,1);
	    }
	    else if (strncmp(c,"erroraswarn=",7) == 0) {
	      error_as_warning = atoi(c+12);
	    }
	  }
	}
      } else if (StringEqual(id,k_level)) {
	Swig_error(Getfile(s),Getline(id),"cpp debug: level = %d, startlevel = %d\n", level, start_level);
      }
      for (i = 0; i < cpp_lines; i++)
  	StringPutc('\n',ns);
      state = 0;
      break;

        /* Swig directives  */
    case 100:
      /* %{,%} block  */
      if (c == '{') {
  	start_line = Getline(s);
  	add_chunk(ns,chunk,allow);
  	copy_location(s,chunk);
  	StringPutc('%',chunk);
  	StringPutc(c,chunk);
  	state = 105;
      }
      /* %#cpp -  an embedded C preprocessor directive (we strip off the %)  */
      else if (c == '#') {
	add_chunk(ns,chunk,allow);
  	StringPutc(c,chunk);
  	state = 107;
      } else if (isidentifier(c)) {
  	Clear(decl);
  	StringPutc('%',decl);
  	StringPutc(c,decl);
  	state = 110;
      } else {
	StringPutc('%',chunk);
  	StringPutc(c,chunk);
  	state = 1;
      }
      break;

    case 105:
      StringPutc(c,chunk);
      if (c == '%')
  	state = 106;
      break;

    case 106:
      StringPutc(c,chunk);
      if (c == '}') {
  	state = 1;
	addline(ns,chunk,allow);
	Clear(chunk);
	copy_location(s,chunk);
      } else {
  	state = 105;
      }
      break;
      
    case 107:
      StringPutc(c,chunk);
      if (c == '\n') {
	addline(ns,chunk,allow);
	Clear(chunk);
	state = 0;
      } else if (c == '\\') {
	state = 108;
      }
      break;

    case 108:
      StringPutc(c,chunk);
      state = 107;
      break;

    case 110:
      if (!isidchar(c)) {
  	StringUngetc(c,s);
  	/* Look for common Swig directives  */
  	if (StringEqual(decl,k_dinclude) || StringEqual(decl,k_dimport) || StringEqual(decl,k_dextern)) {
  	  /* Got some kind of file inclusion directive  */
  	  if (allow) {
  	    DOH *s1, *s2, *fn, *opt; int sysfile = 0;

	    if (StringEqual(decl,k_dextern)) {
	      Swig_warning(WARN_DEPRECATED_EXTERN, Getfile(s),Getline(s),"%%extern is deprecated. Use %%import instead.\n");
	      Clear(decl);
	      StringAppend(decl,"%%import");
	    }
	    opt = get_options(s);
  	    fn = get_filename(s, &sysfile);
	    s1 = cpp_include(fn, sysfile);
	    if (s1) {
	      char *dirname;
  	      add_chunk(ns,chunk,allow);
  	      copy_location(s,chunk);
  	      Printf(ns,"%sfile%s \"%s\" [\n", decl, opt, Swig_last_file());
	      if (StringEqual(decl,k_dimport)) {
		push_imported();
	      }
	      dirname = Swig_file_dirname(Swig_last_file());
	      if (sysfile || !strlen(dirname)) dirname = 0;
	      if (dirname) {
		dirname[strlen(dirname)-1] = 0;   /* Kill trailing directory delimeter */
		Swig_push_directory(dirname);
	      }
  	      s2 = Preprocessor_parse(s1);
	      if (dirname) {
		Swig_pop_directory();
	      }
	      if (StringEqual(decl,k_dimport)) {
		pop_imported();
	      }
  	      addline(ns,s2,allow);
  	      StringAppend(ns,"\n]");
	      Delete(s2);
	      Delete(s1);
  	    }
	    Delete(fn);
  	  }
  	  state = 1;
  	} else if (StringEqual(decl,k_dline)) {
  	  /* Got a line directive  */
  	  state = 1;
  	} else if (StringEqual(decl,k_ddefine)) {
  	  /* Got a define directive  */
	  dlevel++;	  
  	  add_chunk(ns,chunk,allow);
  	  copy_location(s,chunk);
  	  Clear(value);
  	  copy_location(s,value);
  	  state = 150;
  	} else {
  	  StringAppend(chunk,decl);
  	  state = 1;
  	}
      } else {
  	StringPutc(c,decl);
      }
      break;

        /* Searching for the end of a %define statement  */
    case 150:
      StringPutc(c,value);
      if (c == '%') {
  	const char *ed = "enddef";
  	const char *df = "define";
	char statement[7];
  	int i = 0;
  	for (i = 0; i < 6; ) {
  	  c = StringGetc(s);
  	  StringPutc(c,value);
	  statement[i++] = c;
  	  if (strncmp(statement, ed, i) && strncmp(statement, df, i)) break;
  	}
	c = StringGetc(s);
	StringUngetc(c,s);
  	if ((i == 6) && (isspace(c))) {
	  if (strncmp(statement, df, i) == 0) {
	    ++dlevel;
	  } else {
	    if (strncmp(statement, ed, i) == 0) {
	      --dlevel;
	      if (!dlevel) {	
		/* Got the macro  */
		for (i = 0; i < 7; i++) {
		  Delitem(value,DOH_END);
		}
		if (allow) {
		  Seek(value,0,SEEK_SET);
		  Preprocessor_define(value,1);
		}
		StringPutc('\n',ns);
		addline(ns,value,0);
		state = 0;
	      }
	    }
	  }
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
    Swig_error(Getfile(s),-1,"Missing #endif for conditional starting on line %d\n", cond_lines[level-1]);
    level--;
  }
  if (state == 150) {
    Seek(value,0,SEEK_SET);
    Swig_error(Getfile(s),-1,"Missing %%enddef for macro starting on line %d\n",Getline(value));
  }
  if ((state >= 105) && (state < 107)) {
    Swig_error(Getfile(s),-1,"Unterminated %%{ ... %%} block starting on line %d\n", start_line);
  }
  if ((state >= 30) && (state < 40)) {
    Swig_error(Getfile(s),-1,"Unterminated comment starting on line %d\n", start_line);
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




