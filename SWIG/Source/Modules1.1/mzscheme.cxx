/******************************************************************************
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
 *****************************************************************************/

static char cvsroot[] = "$Header$";

/***********************************************************************
 * $Header$
 *
 * mzscheme.cxx
 *
 * Definitions for adding functions to Mzscheme 101
 ***********************************************************************/

#include "mod11.h"
#include "mzscheme.h"

static char *mzscheme_usage = (char*)"\
\n\
Mzscheme Options (available with -mzscheme)\n\
-help           - Print this help\n\
-prefix name    - Set a prefix to be appended to all names\n\
\n"
;

static char *prefix=0;
static char *module=0;
static char *mzscheme_path=(char*)"mzscheme";
static String *init_func_def = 0;

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;

// ---------------------------------------------------------------------
// MZSCHEME::main()
//
// Parse arguments.
// ---------------------------------------------------------------------

void
MZSCHEME::main (int argc, char *argv[])
{
  int i;

  SWIG_library_directory(mzscheme_path);

  // Look for certain command line options
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp (argv[i], "-help") == 0) {
	fputs (mzscheme_usage, stderr);
	SWIG_exit (0);
      }
      else if (strcmp (argv[i], "-prefix") == 0) {
	if (argv[i + 1]) {
	  prefix = new char[strlen(argv[i + 1]) + 2];
	  strcpy(prefix, argv[i + 1]);
	  Swig_mark_arg (i);
	  Swig_mark_arg (i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      }
    }
  }

  // If a prefix has been specified make sure it ends in a '_'

  if (prefix) {
    if (prefix[strlen (prefix)] != '_') {
      prefix[strlen (prefix) + 1] = 0;
      prefix[strlen (prefix)] = '_';
    }
  } else
    prefix = (char*)"swig_";

  // Add a symbol for this module

  Preprocessor_define ((void *) "SWIGMZSCHEME",0);

  // Set name of typemaps

  SWIG_typemap_lang("mzscheme");

  // Read in default typemaps */
  SWIG_config_file("mzscheme.i");
}

// --------------------------------------------------------------------
// MZSCHEME::top()
// --------------------------------------------------------------------

void
MZSCHEME::top(Node *n)
{

  /* Initialize all of the output files */
  String *outfile = Getattr(n,"outfile");

  f_runtime = NewFile(outfile,"w");
  if (!f_runtime) {
    Printf(stderr,"*** Can't open '%s'\n", outfile);
    SWIG_exit(EXIT_FAILURE);
  }
  f_init = NewString("");
  f_header = NewString("");
  f_wrappers = NewString("");

  /* Register file targets with the SWIG file handler */
  Swig_register_filebyname("header",f_header);
  Swig_register_filebyname("wrapper",f_wrappers);
  Swig_register_filebyname("runtime",f_runtime);
  Swig_register_filebyname("init",f_init);


  init_func_def = NewString("");

  Printf(f_runtime, "/* -*- buffer-read-only: t -*- vi: set ro: */\n");
  Swig_banner (f_runtime);

  if (NoInclude) {
    Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
  }

  set_module(Char(Getname(n)));

  Language::top(n);

  SwigType_emit_type_table (f_runtime, f_wrappers);
  Printf(f_init, "Scheme_Object *scheme_reload(Scheme_Env *env) {\n");
  Printf (f_init, "\tSWIG_RegisterTypes(swig_types, swig_types_initial);\n");
  Printf(f_init, "%s\n", Char(init_func_def));
  Printf (f_init, "\treturn scheme_void;\n}\n");
  Printf(f_init, "Scheme_Object *scheme_initialize(Scheme_Env *env) {\n");
  Printf(f_init, "\treturn scheme_reload(env);\n");
  Printf (f_init, "}\n");

  /* Close all of the files */
  Dump(f_header,f_runtime);
  Dump(f_wrappers,f_runtime);
  Wrapper_pretty_print(f_init,f_runtime);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_init);
  Close(f_runtime);
  Delete(f_runtime);

}

// ---------------------------------------------------------------------
// MZSCHEME::set_module(char *mod_name)
//
// Sets the module name.
// Does nothing if it's already set (so it can be overridden as a command
// line option).
//
//----------------------------------------------------------------------

void
MZSCHEME::set_module (char *mod_name)
{
  if (module) {
    printf ("module already set (%s), returning\n", module);
    return;
  }

  module = new char [strlen (mod_name) + 1];
  strcpy (module, mod_name);
}

// ----------------------------------------------------------------------
// MZSCHEME::create_function(char *name, char *iname, SwigType *d,
//                             ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

static void
mreplace (String *s, String *argnum, String *arg, String *proc_name)
{
  Replace(s, "$argnum", argnum, DOH_REPLACE_ANY);
  Replace(s, "$arg", arg, DOH_REPLACE_ANY);
  Replace(s, "$name", proc_name, DOH_REPLACE_ANY);
}

static void
throw_unhandled_mzscheme_type_error (SwigType *d)
{
  Printf (stderr, "%s : Line %d. Unable to handle type %s.\n", input_file, line_number, SwigType_str(d,0));
  error_count++;
}

/* Return true iff T is a pointer type */

static int
is_a_pointer (SwigType *t)
{
  return SwigType_ispointer(SwigType_typedef_resolve_all(t));
}

/* Same as Swig_typemap_lookup but fall back to `int' when `enum' is
   requested -- enum handling is somewhat broken in the 1.1 parser.
   But we don't want to change it now since it is deprecated. */

static char *
mzscheme_typemap_lookup(const char *op, SwigType *type, const String_or_char *pname, String_or_char *source,
		     String_or_char *target, Wrapper *f)
{
  char *tm;
  tm = Swig_typemap_lookup((char*) op, type, (char*)pname, source, target, f);
  if (!tm) {
    SwigType *base = SwigType_typedef_resolve_all(type);
    if (strncmp(Char(base), "enum ", 5)==0)
      tm = Swig_typemap_lookup((char*) op, NewSwigType(T_INT), (char*)pname, source, target, f);
  }
  return tm;
}

void
MZSCHEME::create_function (char *name, char *iname, SwigType *d, ParmList *l)
{
  Parm *p;
  Wrapper *f = NewWrapper();
  String *proc_name = NewString("");
  String *source = NewString("");
  String *target = NewString("");
  String *argnum = NewString("");
  String *arg = NewString("");
  String *cleanup = NewString("");
  String *outarg = NewString("");
  String *build = NewString("");
  SwigType *t;
  char  *tm;
  int argout_set = 0;
  int i = 0;

  // Make a wrapper name for this
  char *wname = Char(Swig_name_wrapper(iname));

  // Build the name for Scheme.
  Printv(proc_name, iname,0);
  Replace(proc_name, "_", "-", DOH_REPLACE_ANY);

  // writing the function wrapper function
  Printv(f->def, "static Scheme_Object *",  wname, " (", 0);
  Printv(f->def, "int argc, Scheme_Object **argv", 0);
  Printv(f->def, ")\n{", 0);

  /* Define the scheme name in C. This define is used by several
     macros. */
  Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", 0);

  // Declare return variable and arguments
  // number of parameters
  // they are called arg0, arg1, ...
  // the return value is called result

  /* pcount = */ emit_args(d, l, f);
  int numargs = 0;

  // adds local variables
  Wrapper_add_local(f, "_len", "int _len");
  Wrapper_add_local(f, "lenv", "int lenv = 1");
  Wrapper_add_local(f, "values", "Scheme_Object *values[MAXVALUES]");

  // Now write code to extract the parameters (this is super ugly)

  for(p = l; p; p = nextSibling(p)) {
    // Produce names of source and target
    Clear(source);
    Clear(target);
    Clear(argnum);
    Clear(arg);
    Printf(source, "argv[%d]", i);
    Printf(target, "arg%d", i);
    Printf(argnum, "%d", i);
    Printv(arg, Getname(p),0);

    // Handle parameter types.

    if (Getignore(p))
      Printv(f->code, "/* ", Char(Getname(p)), " ignored... */\n", 0);
    else {
      ++numargs;
      if ((tm = mzscheme_typemap_lookup ("in",
				     Gettype(p), Getname(p), source, target, f))) {
	Printv(f->code, tm, "\n", 0);
	mreplace (f->code, argnum, arg, proc_name);
      }
      // no typemap found
      // check if typedef and resolve
      else throw_unhandled_mzscheme_type_error (Gettype(p));
    }

    // Check if there are any constraints.

    if ((tm = mzscheme_typemap_lookup ("check", 
				   Gettype(p), Getname(p), source, target, f))) {
      // Yep.  Use it instead of the default
      Printv(f->code, tm, "\n", 0);
      mreplace (f->code, argnum, arg, proc_name);
    }

    // Pass output arguments back to the caller.

    if ((tm = mzscheme_typemap_lookup ("argout", 
				   Gettype(p), Getname(p), source, target, f))) {
      // Yep.  Use it instead of the default
      Printv(outarg, tm, "\n",0);
      mreplace (outarg, argnum, arg, proc_name);
      argout_set = 1;
    }

    // Free up any memory allocated for the arguments.
    if ((tm = mzscheme_typemap_lookup ("freearg",
				   Gettype(p), Getname(p), source, target, f))) {
      // Yep.  Use it instead of the default
      Printv(cleanup, tm, "\n",0);
      mreplace (cleanup, argnum, arg, proc_name);
    }
    i++;
  }

  // Now write code to make the function call

  emit_func_call (name, d, l, f);

  // Now have return value, figure out what to do with it.

  if ((tm = mzscheme_typemap_lookup ("out",
				      d, name, (char*)"result", (char*)"values[0]", f))) {
    Printv(f->code, tm, "\n",0);
    mreplace (f->code, argnum, arg, proc_name);
  }
  else {
    throw_unhandled_mzscheme_type_error (d);
  }

  // Dump the argument output code
  Printv(f->code, Char(outarg),0);

  // Dump the argument cleanup code
  Printv(f->code, Char(cleanup),0);

  // Look for any remaining cleanup

  if (NewObject) {
    if ((tm = mzscheme_typemap_lookup ("newfree",
				   d, iname, (char*)"result", (char*)"", f))) {
      Printv(f->code, tm, "\n",0);
      mreplace (f->code, argnum, arg, proc_name);
    }
  }

  // Free any memory allocated by the function being wrapped..

  if ((tm = mzscheme_typemap_lookup ("ret",
				 d, name, (char*)"result", (char*)"", f))) {
    // Yep.  Use it instead of the default
    Printv(f->code, tm, "\n",0);
    mreplace (f->code, argnum, arg, proc_name);
  }

  // Wrap things up (in a manner of speaking)

  Printv(f->code, tab4, "return swig_package_values(lenv, values);\n", 0);
  Printf(f->code, "#undef FUNC_NAME\n");
  Printv(f->code, "}\n",0);

  Wrapper_print(f, f_wrappers);

  // Now register the function
  char temp[256];
  sprintf(temp, "%d", numargs);
  Printv(init_func_def, "scheme_add_global(\"", proc_name,
	 "\", scheme_make_prim_w_arity(", wname,
	 ", \"", proc_name, "\", ", temp, ", ", temp,
	 "), env);\n",0);

  Delete(proc_name);
  Delete(source);
  Delete(target);
  Delete(argnum);
  Delete(arg);
  Delete(outarg);
  Delete(cleanup);
  Delete(build);
  DelWrapper(f);
}

// -----------------------------------------------------------------------
// MZSCHEME::link_variable(char *name, char *iname, SwigType *d)
//
// Create a link to a C variable.
// This creates a single function _wrap_swig_var_varname().
// This function takes a single optional argument.   If supplied, it means
// we are setting this variable to some value.  If omitted, it means we are
// simply evaluating this variable.  Either way, we return the variables
// value.
// -----------------------------------------------------------------------

void
MZSCHEME::link_variable (char *name, char *iname, SwigType *t)
{
  String *proc_name = NewString("");
  char  var_name[256];
  char  *tm;
  String *tm2 = NewString("");;
  String *argnum = NewString("0");
  String *arg = NewString("argv[0]");
  Wrapper *f;

  f = NewWrapper();

  // evaluation function names

  strcpy(var_name, Char(Swig_name_wrapper(iname)));

  // Build the name for scheme.
  Printv(proc_name, iname,0);
  Replace(proc_name, "_", "-", DOH_REPLACE_ANY);

  if ((SwigType_type(t) != T_USER) || (is_a_pointer(t))) {

    Printf (f->def, "static Scheme_Object *%s(int argc, Scheme_Object** argv) {\n", var_name);
    Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", 0);

    Wrapper_add_local (f, "swig_result", "Scheme_Object *swig_result");

    if (!ReadOnly) {
      /* Check for a setting of the variable value */
      Printf (f->code, "if (argc) {\n");
      if ((tm = mzscheme_typemap_lookup ("varin",
					 t, name, (char*)"argv[0]", name,0))) {
	Printv(tm2, tm,0);
	mreplace(tm2, argnum, arg, proc_name);
	Printv(f->code, tm2, "\n",0);
      }
      else {
	throw_unhandled_mzscheme_type_error (t);
      }
      Printf (f->code, "}\n");
    }
    
    // Now return the value of the variable (regardless
    // of evaluating or setting)

    if ((tm = mzscheme_typemap_lookup ("varout",
				       t, name, name, (char*)"swig_result",0))) {
      Printf (f->code, "%s\n", tm);
    }
    else {
      throw_unhandled_mzscheme_type_error (t);
    }
    Printf (f->code, "\nreturn swig_result;\n");
    Printf (f->code, "#undef FUNC_NAME\n");
    Printf (f->code, "}\n");

    Wrapper_print (f, f_wrappers);

    // Now add symbol to the MzScheme interpreter

    Printv(init_func_def,
	   "scheme_add_global(\"",
	   proc_name,
	   "\", scheme_make_prim_w_arity(",
	   var_name,
	   ", \"",
	   proc_name,
	   "\", ",
	   "0",
	   ", ",
	   "1",
	   "), env);\n",0);

  } else {
    Printf (stderr, "%s : Line %d. ** Warning. Unable to link with "
	    " type %s (ignored).\n",
	    input_file, line_number, SwigType_manglestr(t));
  }
  Delete(proc_name);
  Delete(argnum);
  Delete(arg);
  Delete(tm2);
  DelWrapper(f);
}

// -----------------------------------------------------------------------
// MZSCHEME::declare_const(char *name, char *iname, SwigType *type, char *value)
//
// Makes a constant.   Not sure how this is really supposed to work.
// I'm going to fake out SWIG and create a variable instead.
// ------------------------------------------------------------------------

void
MZSCHEME::declare_const (char *name, char *iname, SwigType *type, char *value)
{
  int OldReadOnly = ReadOnly;      // Save old status flags
  String *var_name = NewString("");
  String *proc_name = NewString("");
  String *rvalue = NewString("");
  String *temp = NewString("");
  char   *tm;

  ReadOnly = 1;     // Enable readonly mode.

  // Make a static variable;

  Printf (var_name, "_wrap_const_%s", Swig_name_mangle(iname));

  // Build the name for scheme.
  Printv(proc_name, iname,0);
  Replace(proc_name, "_", "-", DOH_REPLACE_ANY);

  if ((SwigType_type(type) == T_USER) && (!is_a_pointer(type))) {
    fprintf (stderr, "%s : Line %d.  Unsupported constant value.\n",
	     input_file, line_number);
    return;
  }

  // See if there's a typemap

  Printv(rvalue, value,0);
  if ((SwigType_type(type) == T_CHAR) && (is_a_pointer(type) == 1)) {
    temp = Copy(rvalue);
    Clear(rvalue);
    Printv(rvalue, "\"", temp, "\"",0);
  }
  if ((SwigType_type(type) == T_CHAR) && (is_a_pointer(type) == 0)) {
    Delete(temp);
    temp = Copy(rvalue);
    Clear(rvalue);
    Printv(rvalue, "'", temp, "'",0);
  }
  if ((tm = mzscheme_typemap_lookup ("const", type, name,
				 rvalue, name,0))) {
    // Yep.  Use it instead of the default
    Printf (f_init, "%s\n", tm);
  } else {
    // Create variable and assign it a value

    Printf (f_header, "static %s %s = ", SwigType_str(type,0), var_name);
    if ((SwigType_type(type) == T_STRING)) {
      Printf (f_header, "\"%s\";\n", value);
    } else if (SwigType_type(type) == T_CHAR) {
      Printf (f_header, "\'%s\';\n", value);
    } else {
      Printf (f_header, "%s;\n", value);
    }

    // Now create a variable declaration

    link_variable (Char(var_name), iname, type);
    ReadOnly = OldReadOnly;
  }
  Delete(proc_name);
  Delete(rvalue);
  Delete(temp);
}

void
MZSCHEME::import_start(char *modname) {
}

void 
MZSCHEME::import_end() {
}
