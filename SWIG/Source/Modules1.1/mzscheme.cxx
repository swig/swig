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

static char *mzscheme_usage = "\
\n\
Mzscheme Options (available with -mzscheme)\n\
     -help           - Print this help\n\
     -module name    - Set base name of module (not implemented) \n\
     -prefix name    - Set a prefix to be appended to all name\n\
\n"
;


// ---------------------------------------------------------------------
// MZSCHEME ()
// ---------------------------------------------------------------------

MZSCHEME::MZSCHEME ()
{
  prefix = NULL;
  module = NULL;
  package = "";
  linkage = 0;
  mzscheme_path = "mzscheme";
  init_func_def = "";
}

// ---------------------------------------------------------------------
// MZSCHEME::parse_args(int argc, char *argv[])
//
// Parse arguments.
// ---------------------------------------------------------------------

void
MZSCHEME::parse_args (int argc, char *argv[])
{
  int i;

  sprintf (LibDir, "%s", mzscheme_path);

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
      else if (strcmp (argv[i], "-module") == 0) {
	if (argv[i + 1]) {
	  set_module (argv[i + 1], 0);
	  Swig_mark_arg (i);
	  Swig_mark_arg (i + 1);
	  ++i;
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
    prefix = "swig_";

  // Add a symbol for this module

  Preprocessor_define ((void *) "SWIGMZSCHEME",0);

  // Set name of typemaps

  typemap_lang = "mzscheme";
}

// --------------------------------------------------------------------
// MZSCHEME::parse()
//
// Parse the input file
// --------------------------------------------------------------------

void
MZSCHEME::parse ()
{
  printf ("Generating wrappers for Mzscheme\n");

  // Print out MZSCHEME specific headers

  headers();

  // Run the parser

  yyparse();

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
MZSCHEME::set_module (char *mod_name, char **)
{
  if (module) {
    printf ("module already set (%s), returning\n", module);
    return;
  }

  module = new char [strlen (mod_name) + 1];
  strcpy (module, mod_name);
}

// ---------------------------------------------------------------------
// MZSCHEME::set_init(char *iname)
//
// Sets the initialization function name.
// Does nothing if it's already set
//
//----------------------------------------------------------------------

void
MZSCHEME::set_init (char *iname)
{
  abort ();                             // for now -ttn
  set_module (iname, 0);
}

// ---------------------------------------------------------------------
// MZSCHEME::headers(void)
//
// Generate the appropriate header files for MZSCHEME interface.
// ----------------------------------------------------------------------

void
MZSCHEME::headers (void)
{
  emit_banner (f_header);

  fprintf (f_header, "/* Implementation : MZSCHEME */\n\n");
  fprintf (f_header, "#include <stdio.h>\n");
  fprintf (f_header, "#include <string.h>\n");
  fprintf (f_header, "#include <stdlib.h>\n");

  // Write out hex conversion functions

  if (!NoInclude) {
    if (Swig_insert_file ("mzscheme.swg", f_header) == -1) {
      fprintf (stderr, "SWIG : Fatal error.  ");
      fprintf (stderr, "Unable to locate 'mzscheme.swg' in SWIG library.\n");
      SWIG_exit (1);
    }
    // <DB> I Removed a call to emit_hex() here.  The pointer
    // type-checking code should be included into guile.swg instead </DB>
  } else {
    fprintf (f_header, "#ifdef __cplusplus\n");
    fprintf (f_header, "extern \"C\" {\n");
    fprintf (f_header, "#endif\n");
    fprintf (f_header, "extern void SWIG_MakePtr(char *, void *, char *);\n");
    fprintf (f_header, "extern void SWIG_RegisterMapping(char *, char *, void *(*)(void *));\n");
    fprintf (f_header, "extern char *SWIG_GetPtr(char *, void **, char *);\n");
    fprintf (f_header, "#ifdef __cplusplus\n");
    fprintf (f_header, "}\n");
    fprintf (f_header, "#endif\n");
  }
}

// --------------------------------------------------------------------
// MZSCHEME::initialize()
//
// Output initialization code that registers functions with the
// interface.
// ---------------------------------------------------------------------

void
MZSCHEME::initialize (void)
{
  int i;

#ifdef OLD_STYLE_WILL_GO_AWAY
  if (InitNames) {
    i = 0;
    while (InitNames[i]) {
      fprintf(f_init,"\t %s();\n",InitNames[i]);
      i++;
    }
  }
#endif /* OLD_STYLE_WILL_GO_AWAY */

  fprintf (f_init, "static void\nSWIG_init (void)\n{\n");
}

// ---------------------------------------------------------------------
// MZSCHEME::close(void)
//
// Wrap things up.  Close initialization function.
// ---------------------------------------------------------------------

void
MZSCHEME::close (void)
{
  //  emit_ptr_equivalence (f_init);
  fprintf (f_init, "}\n\n");

  fprintf(f_init, "Scheme_Object *scheme_reload(Scheme_Env *env) {\n");
  fprintf(f_init, "%s\n", init_func_def.get());
  fprintf (f_init, "\treturn scheme_void;\n}\n");
  fprintf(f_init, "Scheme_Object *scheme_initialize(Scheme_Env *env) {\n");
  fprintf(f_init, "\treturn scheme_reload(env);\n");
  fprintf (f_init, "}\n");
}

// ----------------------------------------------------------------------
// MZSCHEME::get_pointer(int parm, DataType *t)
//
// Emits code to get a pointer from a parameter and do type checking.
// parm is the parameter number.   This function is only used
// in create_function().
// ----------------------------------------------------------------------

void
MZSCHEME::get_pointer (char *iname, int parm, DataType *t,
		       WrapperFunction &f)
{
  // Pointers are read as hex-strings with encoded type information
  f.code << tab4 << "_tempc = SCHEME_STR_VAL(argv[" << parm << "]);\n";
//  f.code << tab4 << "_len = SCHEME_STRLEN_VAL(argv[" << parm << "]);\n";
  f.code << tab4 << "if (SWIG_GetPtr (_tempc, (void **) &_arg" << parm;
  if (t->type == T_VOID)
    f.code << ", (char *) 0)) {\n";
  else
    f.code << ", \"" << t->print_mangle() << "\")) {\n";

  f.code << tab8 << "scheme_signal_error(\"couldn't get pointer\");\n";

  f.code << tab4 << "}\n";
  //  f.code << tab4 << "free(_tempc);\n";
}

// ----------------------------------------------------------------------
// MZSCHEME::create_function(char *name, char *iname, DataType *d,
//                             ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

static void
mreplace (String &s, String &argnum, String &arg, String &proc_name)
{
  s.replace ("$argnum", argnum);
  s.replace ("$arg",    arg);
  s.replace ("$name",   proc_name);
}

static void
throw_unhandled_mzscheme_type_error (DataType *d)
{
  fflush (stdout);
  fprintf (stderr, "ERROR: Unhandled MZSCHEME type error.\n");
  fprintf (stderr, "        type %d\n", d->type);
  fprintf (stderr, "        name %s\n", d->name);
  fprintf (stderr, "  is_pointer %d\n", d->is_pointer);
  fprintf (stderr, "implicit_ptr %d\n", d->implicit_ptr);
  fprintf (stderr, "is_reference %d\n", d->is_reference);
  fprintf (stderr, "      status %d\n", d->status);
  fprintf (stderr, "   qualifier %s\n", (d->qualifier ? d->qualifier : ""));
  fprintf (stderr, "    arraystr %s\n", (d->arraystr ? d->arraystr : ""));
  fprintf (stderr, "          id %d\n", d->id);

  fprintf (stderr, "\n\nBAILING...\n"); // for now -ttn
  abort();                              // for now -ttn
}

void
MZSCHEME::create_function (char *name, char *iname, DataType *d, ParmList *l)
{
  Parm *p;
  String proc_name;
  String source;
  String target;
  String argnum;
  String arg;
  char  *tm;
  WrapperFunction f;
  String cleanup;
  int need_len = 0;
  int need_tempc = 0;

  String outarg;
  int have_build = 0;
  String build;

  int argout_set = 0;

  // Make a wrapper name for this
  char * wname = name_wrapper (iname, prefix);

  // Build the name for Scheme.
  proc_name = "";
  proc_name << iname;
  proc_name.replace ("_", "-");

  // writing the function wrapper function
  f.def << "static Scheme_Object *" << wname << " (";
  f.def << "int argc, Scheme_Object **argv";
  f.def << ")\n{";

  // Declare return variable and arguments
  // number of parameters
  // they are called _arg0, _arg1, ...
  // the return value is called _result

  int pcount = emit_args (d, l, f);
  int numargs = 0;
  int numopt = 0;

  // adds local variables : type name
  f.add_local ("int",    "_len");
  f.add_local ("char *", "_tempc");
  f.add_local ("Scheme_Object *", "swig_result");

  // Now write code to extract the parameters (this is super ugly)

  int i = 0;
  for (i = 0; i < pcount; ++i) {
    Parm &p = (*l)[i];

    // Produce names of source and target
    source = "";
    target = "";
    argnum = "";
    arg    = "";

    source << "argv[" << i << "]";
    target << "_arg" << i;
    argnum << i;
    arg << p.name;

    // Handle parameter types.

    if (p.ignore)
      f.code << "/* " << p.name << " ignored... */\n";
    else {
      ++numargs;
      if ((tm = typemap_lookup ("in", typemap_lang,
				p.t, p.name, source, target, &f))) {
	f.code << tm << "\n";
	mreplace (f.code, argnum, arg, proc_name);
      }
      // no typemap found
      // assume it's a pointer string and try to put it's pointer value
      // in _tempc
      else if (p.t->is_pointer) {
        get_pointer (iname, i, p.t, f);
      }
      // no typemap found and not a pointer
      else throw_unhandled_mzscheme_type_error (p.t);
    }

    // Check if there are any constraints.

    if ((tm = typemap_lookup ("check", typemap_lang,
			      p.t, p.name, source, target, &f))) {
      // Yep.  Use it instead of the default
      f.code << tm << "\n";
      mreplace (f.code, argnum, arg, proc_name);
    }

    // Pass output arguments back to the caller.

    if ((tm = typemap_lookup ("argout", typemap_lang,
                              p.t, p.name, source, target, &f))) {
      // Yep.  Use it instead of the default
      outarg << tm << "\n";
      mreplace (outarg, argnum, arg, proc_name);
      argout_set = 1;
    }

    // Free up any memory allocated for the arguments.
    if ((tm = typemap_lookup ("freearg", typemap_lang,
                              p.t, p.name, source, target, &f))) {
      // Yep.  Use it instead of the default
      cleanup << tm << "\n";
      mreplace (cleanup, argnum, arg, proc_name);
    }
  }

  // Now write code to make the function call

  emit_func_call (name, d, l, f);

  // Now have return value, figure out what to do with it.

  if (d->type == T_VOID)
    f.code << tab4 << "swig_result = scheme_void;\n";
  else if ((tm = typemap_lookup ("out", typemap_lang,
                                 d, name, "_result", "swig_result", &f))) {
    f.code << tm << "\n";
    mreplace (f.code, argnum, arg, proc_name);
  }
  // no typemap found and not void then put a pointer string in _ptemp
  // convert it to a Scheme string and return it.
  else if (d->is_pointer) {
    f.add_local ("char", "_ptemp[128]");
    f.code << tab4
           << "SWIG_MakePtr (_ptemp, _result,\""
           << d->print_mangle()
           << "\");\n";
    f.code << tab4
           << "swig_result = scheme_make_string(_ptemp);\n";
  }
  else {
    throw_unhandled_mzscheme_type_error (d);
  }

  // Dump the argument output code
  f.code << outarg;

  // Dump the argument cleanup code
  f.code << cleanup;

  // Look for any remaining cleanup

  if (NewObject) {
    if ((tm = typemap_lookup ("newfree", typemap_lang,
                              d, iname, "_result", "", &f))) {
      f.code << tm << "\n";
      mreplace (f.code, argnum, arg, proc_name);
    }
  }

  // Free any memory allocated by the function being wrapped..

  if ((tm = typemap_lookup ("ret", typemap_lang,
                            d, name, "_result", "", &f))) {
    // Yep.  Use it instead of the default
    f.code << tm << "\n";
    mreplace (f.code, argnum, arg, proc_name);
  }

  // returning multiple values
  if(argout_set) {
    if(d->type == T_VOID) {
      f.add_local("int", "_lenv", "0");
      f.add_local("Scheme_Object", "*_values[MAXVALUES]");
      f.code << tab4 << "swig_result = scheme_values(_lenv, _values);";
    }
    else {
      f.add_local("int", "_lenv", "1");
      f.add_local("Scheme_Object", "*_values[MAXVALUES]");
      f.code << tab4 << "_values[0] = swig_result;\n";
      f.code << tab4 << "swig_result = scheme_values(_lenv, _values);\n";
    }
  }

  // Wrap things up (in a manner of speaking)

  f.code << tab4 << "return swig_result;\n";
  f.code << "}\n";

  f.print (f_wrappers);

  // Now register the function
  init_func_def << "scheme_add_global(\"" << proc_name.get() << \
    "\", scheme_make_prim_w_arity(" << wname << \
    ", \"" << proc_name.get() << "\", " << numargs << ", " << numargs << \
    "), env);\n";
}

// -----------------------------------------------------------------------
// MZSCHEME::link_variable(char *name, char *iname, DataType *d)
//
// Create a link to a C variable.
// This creates a single function _wrap_swig_var_varname().
// This function takes a single optional argument.   If supplied, it means
// we are setting this variable to some value.  If omitted, it means we are
// simply evaluating this variable.  Either way, we return the variables
// value.
// -----------------------------------------------------------------------

void
MZSCHEME::link_variable (char *name, char *iname, DataType *t)
{
  String proc_name;
  char  var_name[256];
  char  *tm;
  String tm2;
  String argnum = "0";
  String arg = "argv[0]";

  // evaluation function names

  sprintf (var_name, "_wrap_%svar_%s", prefix, iname);

  // Build the name for scheme.
  proc_name = "";
  proc_name << iname;
  proc_name.replace ("_", "-");

  if ((t->type != T_USER) || (t->is_pointer)) {

    fprintf (f_wrappers, "static Scheme_Object *%s(int argc, Scheme_Object** argv) {\n", var_name);

    if ((t->type == T_CHAR) || (t->is_pointer)){
      fprintf (f_wrappers, "\t char *_temp, _ptemp[128];\n");
      fprintf (f_wrappers, "\t int  _len;\n");
    }
    fprintf (f_wrappers, "\t Scheme_Object *swig_result;\n");

    // Check for a setting of the variable value

    fprintf (f_wrappers, "\t if (argc) {\n");

    // Yup. Extract the type from argv[0] and set variable value

//      if (Status & STAT_READONLY) {
//        fprintf (f_wrappers, "\t\t GSWIG_ASSERT(0,\"Unable to set %s.  "
//                 "Variable is read only.\", argv[0]);\n", iname);
//      }
    if (Status & STAT_READONLY) {
      fprintf (f_wrappers, "\t\t scheme_signal_error(\"Unable to set %s.  "
               "Variable is read only.\");\n", iname);
    }
    else if ((tm = typemap_lookup ("varin", typemap_lang,
                                   t, name, "argv[0]", name))) {
      tm2 = tm;
      mreplace(tm2, argnum, arg, proc_name);
      fprintf (f_wrappers, "%s\n", tm2.get());
    }
    else if (t->is_pointer) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
        fprintf (f_wrappers, "\t\t _temp = SCHEME_STR_VAL(argv[0]);\n");
        fprintf (f_wrappers, "\t\t _len = SCHEME_STRLEN_VAL(argv[0]);\n");
        fprintf (f_wrappers, "\t\t if (%s) { free(%s);}\n", name, name);
        fprintf (f_wrappers, "\t\t %s = (char *) "
                 "malloc((_len+1)*sizeof(char));\n", name);
        fprintf (f_wrappers, "\t\t strncpy(%s,_temp,_len);\n", name);
        fprintf (f_wrappers, "\t\t %s[_len] = 0;\n", name);
      } else {
        // Set the value of a pointer
        fprintf (f_wrappers, "\t\t _temp = SCHEME_STR_VAL(argv[0]);\n");
//        fprintf (f_wrappers, "\t\t _len = SCHEME_STRLEN_VAL(argv[0]);\n");
        fprintf (f_wrappers, "\t\t if (SWIG_GetPtr(_temp, (void **) &%s,",
                 name);
        if (t->type == T_VOID)
          fprintf (f_wrappers, "(char *) 0)) {\n");
        else
          fprintf (f_wrappers, "\"%s\")) {\n", t->print_mangle());

	fprintf(f_wrappers, "\t\t\t scheme_signal_error(\"couldn't get pointer\");\n");
        fprintf (f_wrappers, "\t\t}\n");
      }
    }
    else {
      throw_unhandled_mzscheme_type_error (t);
    }
    fprintf (f_wrappers, "\t}\n");

    // Now return the value of the variable (regardless
    // of evaluating or setting)

    if ((tm = typemap_lookup ("varout", typemap_lang,
                              t, name, name, "swig_result"))) {
      fprintf (f_wrappers, "%s\n", tm);
    }
    else if (t->is_pointer) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
        fprintf (f_wrappers, "\t swig_result = scheme_make_string(%s);\n", name);
      } else {
        // Is an ordinary pointer type.
        fprintf (f_wrappers, "\t SWIG_MakePtr(_ptemp, %s,\"%s\");\n",
                 name, t->print_mangle());
        fprintf (f_wrappers, "\t swig_result = scheme_make_string(_ptemp);\n");
      }
    }
    else {
      throw_unhandled_mzscheme_type_error (t);
    }
    fprintf (f_wrappers, "\t return swig_result;\n");
    fprintf (f_wrappers, "}\n");

    // Now add symbol to the MzScheme interpreter

    init_func_def << "scheme_add_global(\"" << proc_name.get() << \
      "\", scheme_make_prim_w_arity(" << var_name << \
      ", \"" << proc_name.get() << "\", " << 0 << ", " << 1 << "), env);\n";

  } else {
    fprintf (stderr, "%s : Line %d. ** Warning. Unable to link with "
             " type %s (ignored).\n",
             input_file, line_number, t->print_type());
  }
}

// -----------------------------------------------------------------------
// MZSCHEME::declare_const(char *name, char *iname, DataType *type, char *value)
//
// Makes a constant.   Not sure how this is really supposed to work.
// I'm going to fake out SWIG and create a variable instead.
// ------------------------------------------------------------------------

void
MZSCHEME::declare_const (char *name, char *, DataType *type, char *value)
{
  int OldStatus = Status;      // Save old status flags
  String proc_name;
  char   var_name[256];
  String rvalue;
  char   *tm;

  Status = STAT_READONLY;      // Enable readonly mode.

  // Make a static variable;

  sprintf (var_name, "_wrap_const_%s", name);

  // Build the name for scheme.
  proc_name = "";
  proc_name = name;
  proc_name.replace ("_", "-");

  if ((type->type == T_USER) && (!type->is_pointer)) {
    fprintf (stderr, "%s : Line %d.  Unsupported constant value.\n",
             input_file, line_number);
    return;
  }

  // See if there's a typemap

  rvalue = value;
  if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
    rvalue << "\"";
    "\"" >> rvalue;
  }
  if ((type->type == T_CHAR) && (type->is_pointer == 0)) {
    rvalue << "'";
    "'" >> rvalue;
  }
  if ((tm = typemap_lookup ("const", typemap_lang, type, name,
                            rvalue.get(), name))) {
    // Yep.  Use it instead of the default
    fprintf (f_init, "%s\n", tm);
  } else {
    // Create variable and assign it a value

    fprintf (f_header, "static %s %s = ", type->print_type(), var_name);
    if ((type->type == T_CHAR) && (type->is_pointer <= 1)) {
      fprintf (f_header, "\"%s\";\n", value);
    } else {
      fprintf (f_header, "%s;\n", value);
    }

    // Now create a variable declaration

    link_variable (var_name, name, type);
    Status = OldStatus;
  }
}

// ----------------------------------------------------------------------
// MZSCHEME::usage_var(char *iname, DataType *t, String &usage)
//
// Produces a usage string for a Guile variable.
// ----------------------------------------------------------------------

void
MZSCHEME::usage_var (char *iname, DataType *t, String &usage)
{
  char temp[1024], *c;

  usage << "(" << iname << " [value])";
  if (!((t->type != T_USER) || (t->is_pointer))) {
    usage << " - unsupported";
  }
}

// ---------------------------------------------------------------------------
// MZSCHEME::usage_func(char *iname, DataType *t, ParmList *l, String &usage)
//
// Produces a usage string for a function in Guile
// ---------------------------------------------------------------------------

void
MZSCHEME::usage_func (char *iname, DataType *d, ParmList *l, String &usage)
{
  char temp[1024];
  char *c;
  int  i;
  Parm *p;

  // Print the function name.

  usage << "(" << iname;

  // Now go through and print parameters

  for (p = l->get_first(); p != 0; p = l->get_next()) {

    if (p->ignore)
      continue;

    // Print the type.  If the parameter has been named, use that as well.

    if ((p->t->type != T_VOID) || (p->t->is_pointer)) {

      // Print the type.
      usage << " <" << p->t->name;
      if (p->t->is_pointer) {
	for (int j = 0; j < (p->t->is_pointer - p->t->implicit_ptr); j++) {
	  usage << "*";
	}
      }
      usage << ">";

      // Print the name if it exists.
      if (strlen (p->name) > 0) {
        usage << " " << p->name;
      }
    }
  }
  usage << ")";
}


// ---------------------------------------------------------------------------
// MZSCHEME::usage_returns(char *iname, DataType *t, ParmList *l, String &usage)
//
// Produces a usage string for a function in Guile
// ---------------------------------------------------------------------------

void
MZSCHEME::usage_returns (char *iname, DataType *d, ParmList *l, String &usage)
{
  Parm *p;
  String param;
  int have_param = 0, j;

  usage = "returns ";
  param = "";

  // go through and see if any are output.

  for (p = l->get_first(); p != 0; p = l->get_next()) {

    if (strcmp (p->name,"BOTH") && strcmp (p->name,"OUTPUT"))
      continue;

    // Print the type.  If the parameter has been named, use that as well.

    if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
      ++have_param;

      // Print the type.
      param << " $" << p->t->name;
      if (p->t->is_pointer) {
	for (j = 0; j < (p->t->is_pointer - p->t->implicit_ptr - 1); j++) {
	  param << "*";
	}
      }
      param << "# ";
    }
  }

  // See if we stick on the function return type.
  if (d->type != T_VOID || have_param == 0) {
    ++have_param;
    if (d->type == T_VOID)
      " unspecified " >> param;
    else {
      "# " >> param;
      d->print_type() >> param;
      " $" >> param;
    }
  }

  // Kill extra white space.
  param.strip();
  param.replace ("$",  "<");
  param.replace ("#",  ">");
  param.replace ("><", "> <");

  // If there are multiple return values put them in a list.
  if (have_param > 1) {
    "(" >> param;
    param << ")";
  }

  usage << param;
}


// ----------------------------------------------------------------------
// MZSCHEME::usage_const(char *iname, DataType *type, char *value, String &usage)
//
// Produces a usage string for a Guile constant
// ----------------------------------------------------------------------

void
MZSCHEME::usage_const (char *iname, DataType *, char *value, String &usage)
{
  usage << "(" << iname << " " << value << ")";
}
