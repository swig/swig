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
     -module name    - Set base name of module (not implemented) \n\
     -prefix name    - Set a prefix to be appended to all name\n\
\n"
;

static  char   *mzscheme_path = (char*)"mzscheme";
static  char   *prefix = 0;
static  char   *module = 0;
static  char   *package = (char*)"";
static  int    linkage = 0;

static  DOHString *init_func_def = 0;

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
    prefix = (char*)"swig_";

  // Add a symbol for this module

  Preprocessor_define ((void *) "SWIGMZSCHEME",0);

  // Set name of typemaps

  typemap_lang = (char*)"mzscheme";
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

  init_func_def = NewString("");

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
  Swig_banner (f_header);

  Printf (f_header, "/* Implementation : MZSCHEME */\n\n");
  Printf (f_header, "#include <stdio.h>\n");
  Printf (f_header, "#include <string.h>\n");
  Printf (f_header, "#include <stdlib.h>\n");

  // insert mzscheme.swg

  if (!NoInclude) {
    if (Swig_insert_file ("mzscheme.swg", f_header) == -1) {
      Printf (stderr, "SWIG : Fatal error.  ");
      Printf (stderr, "Unable to locate 'mzscheme.swg' in SWIG library.\n");
      SWIG_exit (1);
    }
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
      Printf(f_init,"\t %s();\n",InitNames[i]);
      i++;
    }
  }
#endif /* OLD_STYLE_WILL_GO_AWAY */

  Printf (f_init, "static void\nSWIG_init (void)\n{\n");
}

// ---------------------------------------------------------------------
// MZSCHEME::close(void)
//
// Wrap things up.  Close initialization function.
// ---------------------------------------------------------------------

void
MZSCHEME::close (void)
{
  Printf (f_init, "}\n\n");

  Printf(f_init, "Scheme_Object *scheme_reload(Scheme_Env *env) {\n");
  Printf(f_init, "%s\n", init_func_def);
  Printf (f_init, "\treturn scheme_void;\n}\n");
  Printf(f_init, "Scheme_Object *scheme_initialize(Scheme_Env *env) {\n");
  Printf(f_init, "\treturn scheme_reload(env);\n");
  Printf (f_init, "}\n");
}

// ----------------------------------------------------------------------
// MZSCHEME::get_pointer(int parm, DataType *t)
//
// Emits code to get a pointer from a parameter and do type checking.
// parm is the parameter number.   This function is only used
// in create_function().
// ----------------------------------------------------------------------

void
MZSCHEME::get_pointer (DOHString_or_char *name, int parm, DataType *t,
		       Wrapper *f)
{
  Printf(f->code,"    if (!swig_get_c_pointer(argv[%d],\"%s\", (void **) &_arg%d))\n", parm, t->print_mangle(), parm);
  Printf(f->code,"        scheme_wrong_type(\"%s\", \"%s\", %d, argc, argv);\n", name, t->print_mangle(), parm);
}

// ----------------------------------------------------------------------
// MZSCHEME::create_function(char *name, char *iname, DataType *d,
//                             ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

static void
mreplace (DOHString *s, DOHString_or_char *argnum, DOHString_or_char *arg, DOHString_or_char *proc_name)
{
  Replace(s,"$argnum", argnum, DOH_REPLACE_ANY);
  Replace(s,"$arg",    arg, DOH_REPLACE_ANY);
  Replace(s,"$name",   proc_name, DOH_REPLACE_ANY);
}

static void
throw_unhandled_mzscheme_type_error (DataType *d)
{
  fflush (stdout);
  Printf (stderr, "ERROR: Unhandled MZSCHEME type error.\n");
  Printf (stderr, "        type %d\n", d->type);
  Printf (stderr, "        name %s\n", d->name);
  Printf (stderr, "  is_pointer %d\n", d->is_pointer);
  Printf (stderr, "implicit_ptr %d\n", d->implicit_ptr);
  Printf (stderr, "is_reference %d\n", d->is_reference);
  Printf (stderr, "      status %d\n", d->status);
  Printf (stderr, "   qualifier %s\n", (d->qualifier ? d->qualifier : ""));
  Printf (stderr, "    arraystr %s\n", (d->arraystr ? d->arraystr : ""));
  Printf (stderr, "          id %d\n", d->id);

  Printf (stderr, "\n\nBAILING...\n"); // for now -ttn
  abort();                              // for now -ttn
}

void
MZSCHEME::create_function (char *name, char *iname, DataType *d, ParmList *l)
{
  Parm *p;
  char   source[256], target[256], argnum[256], arg[256];
  char  *tm;
  Wrapper *f;
  DOHString *cleanup = 0;
  DOHString *proc_name = 0;
  int need_len = 0;
  int need_tempc = 0;
  DOHString *outarg = 0;
  int argout_set = 0;

  f = NewWrapper();
  outarg = NewString("");
  cleanup = NewString("");

  // Make a wrapper name for this
  char * wname = Swig_name_wrapper (iname);

  // Build the name for Scheme.
  proc_name = NewString(iname);
  Replace(proc_name,"_","-",DOH_REPLACE_ANY);

  // writing the function wrapper function
  Printv(f->def,
	 "static Scheme_Object *", wname, " (",
	 "int argc, Scheme_Object **argv",
	 ")\n{",
	 0);

  // Declare return variable and arguments
  // number of parameters
  // they are called _arg0, _arg1, ...
  // the return value is called _result

  int pcount = emit_args (d, l, f);
  int numargs = 0;
  int numopt = 0;

  // adds local variables : type name
  Wrapper_add_local (f,(char*)"char *", (char*)"_tempc",0);
  Wrapper_add_local (f,(char*)"int",    (char*)"_len",0);
  Wrapper_add_local (f,(char*)"Scheme_Object *", (char*)"swig_result",0);

  // Now write code to extract the parameters (this is super ugly)

  int i = 0;
  for (i = 0; i < pcount; ++i) {
    Parm &p = (*l)[i];

    // Produce names of source and target

    sprintf(source,"argv[%d]",i);
    sprintf(target,"_arg%d",i);
    sprintf(argnum,"%d",i);
    strcpy(arg,p.name);

    // Handle parameter types.

    if (p.ignore)
      Printv(f->code, "/* ", p.name, " ignored... */\n", 0);
    else {
      ++numargs;
      if ((tm = typemap_lookup ((char*)"in", typemap_lang,
				p.t, p.name, source, target, f))) {
	Printv(f->code, tm, "\n", 0);
	mreplace (f->code, argnum, arg, proc_name);
      }
      // no typemap found
      // assume it's a Scheme_Object containing the C pointer
      else if (p.t->is_pointer) {
        get_pointer (proc_name, i, p.t, f);
      }
      // no typemap found and not a pointer
      else throw_unhandled_mzscheme_type_error (p.t);
    }

    // Check if there are any constraints.

    if ((tm = typemap_lookup ((char*)"check", typemap_lang,
			      p.t, p.name, source, target, f))) {
      // Yep.  Use it instead of the default
      Printv(f->code,tm,"\n", 0);
      mreplace (f->code, argnum, arg, proc_name);
    }

    // Pass output arguments back to the caller.

    if ((tm = typemap_lookup ((char*)"argout", typemap_lang,
                              p.t, p.name, source, target, f))) {
      // Yep.  Use it instead of the default
      Printv(outarg, tm, "\n", 0);
      mreplace (outarg, argnum, arg, proc_name);
      argout_set = 1;
    }

    // Free up any memory allocated for the arguments.
    if ((tm = typemap_lookup ((char*)"freearg", typemap_lang,
                              p.t, p.name, source, target, f))) {
      // Yep.  Use it instead of the default
      Printv(cleanup, tm, "\n", 0);
      mreplace (cleanup, argnum, arg, proc_name);
    }
  }

  // Now write code to make the function call

  emit_func_call (name, d, l, f);

  // Now have return value, figure out what to do with it.

  if (d->type == T_VOID) {
    if(!argout_set)
      Printv(f->code, tab4, "swig_result = scheme_void;\n", 0);
  }

  else if ((tm = typemap_lookup ((char*)"out", typemap_lang,
                                 d, name, (char*)"_result", (char*)"swig_result", f))) {
    Printv(f->code, tm, "\n", 0);
    mreplace (f->code, argnum, arg, proc_name);
  }
  // no typemap found and not void then create a Scheme_Object holding
  // the C pointer and return it
  else if (d->is_pointer) {
    Printv(f->code,
	   tab4,
	   "swig_result = swig_make_c_pointer(",
	   "_result, \"",
	   d->print_mangle(),
	   "\");\n",
	   0);
  }
  else {
    throw_unhandled_mzscheme_type_error (d);
  }

  // Dump the argument output code
  Printv(f->code, outarg,0);

  // Dump the argument cleanup code
  Printv(f->code, cleanup, 0);

  // Look for any remaining cleanup

  if (NewObject) {
    if ((tm = typemap_lookup ((char*)"newfree", typemap_lang,
                              d, iname, (char*)"_result", (char*)"", f))) {
      Printv(f->code,tm,"\n",0);
      mreplace (f->code, argnum, arg, proc_name);
    }
  }

  // Free any memory allocated by the function being wrapped..

  if ((tm = typemap_lookup ((char*)"ret", typemap_lang,
                            d, name, (char*)"_result", (char*)"", f))) {
    // Yep.  Use it instead of the default
    Printv(f->code,tm,"\n",0);
    mreplace (f->code, argnum, arg, proc_name);
  }

  // returning multiple values
  if(argout_set) {
    if(d->type == T_VOID) {
      Wrapper_add_local(f,(char*)"int", (char*)"_lenv", (char*)"0");
      Wrapper_add_local(f,(char*)"Scheme_Object *", (char*)"_values[MAXVALUES]",0);
      Printv(f->code, tab4, "swig_result = scheme_values(_lenv, _values);\n", 0);
    }
    else {
      Wrapper_add_local(f,(char*)"int", (char*)"_lenv", (char*)"1");
      Wrapper_add_local(f,(char*)"Scheme_Object *",(char*) "_values[MAXVALUES]",0);
      Printv(f->code, tab4, "_values[0] = swig_result;\n", 0);
      Printv(f->code, tab4, "swig_result = scheme_values(_lenv, _values);\n", 0);
    }
  }

  // Wrap things up (in a manner of speaking)

  Printv(f->code, tab4, "return swig_result;\n", "}\n", 0);

  Wrapper_print(f,f_wrappers);

  // Now register the function
  /*  Printv(init_func_def,
	 "scheme_add_global(\"", proc_name,
	 "\", scheme_make_prim_w_arity(", wname,
	 ", \"", proc_name, "\", ", numargs, ", ", numargs,
	 "), env);\n",
	 0);
  */

  Printf(init_func_def,"scheme_add_global(\"%s\", scheme_make_prim_w_arity(%s, \"%s\", %d, %d), env);\n",
	 proc_name, wname, proc_name, numargs, numargs);

  Delete(proc_name);
  Delete(outarg);
  Delete(cleanup);
  DelWrapper(f);
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
  DOHString *proc_name;
  char  var_name[256];
  char  *tm;
  char  *argnum = "0";
  char  *arg = "argv[0]";

  // evaluation function names

  sprintf (var_name, "_wrap_%svar_%s", prefix, iname);

  // Build the name for scheme.
  proc_name = NewString(iname);
  Replace(proc_name,"_","-",DOH_REPLACE_ANY);

  if ((t->type != T_USER) || (t->is_pointer)) {

    Printf (f_wrappers, "static Scheme_Object *%s(int argc, Scheme_Object** argv) {\n", var_name);

    if ((t->type == T_CHAR) || (t->is_pointer)){
      Printf (f_wrappers, "\t char *_temp, _ptemp[128];\n");
      Printf (f_wrappers, "\t int  _len;\n");
    }
    Printf (f_wrappers, "\t Scheme_Object *swig_result;\n");

    // Check for a setting of the variable value

    Printf (f_wrappers, "\t if (argc) {\n");

    // Yup. Extract the type from argv[0] and set variable value

//      if (Status & STAT_READONLY) {
//        Printf (f_wrappers, "\t\t GSWIG_ASSERT(0,\"Unable to set %s.  "
//                 "Variable is read only.\", argv[0]);\n", iname);
//      }
    if (Status & STAT_READONLY) {
      Printf (f_wrappers, "\t\t scheme_signal_error(\"Unable to set %s.  "
               "Variable is read only.\");\n", iname);
    }
    else if ((tm = typemap_lookup ((char*)"varin", typemap_lang,
                                   t, name, (char*)"argv[0]", name))) {
      DOHString *tm2 = NewString(tm);
      mreplace(tm2, argnum, arg, proc_name);
      Printf(f_wrappers, "%s\n", tm2);
      Delete(tm2);
    }
    else if (t->is_pointer) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
        Printf (f_wrappers, "\t\t _temp = SCHEME_STR_VAL(argv[0]);\n");
        Printf (f_wrappers, "\t\t _len = SCHEME_STRLEN_VAL(argv[0]);\n");
        Printf (f_wrappers, "\t\t if (%s) { free(%s);}\n", name, name);
        Printf (f_wrappers, "\t\t %s = (char *) "
                 "malloc((_len+1)*sizeof(char));\n", name);
        Printf (f_wrappers, "\t\t strncpy(%s,_temp,_len);\n", name);
      } else {
        // Set the value of a pointer
	Printf(f_wrappers, "\t\tif (!swig_get_c_pointer(argv[0], \"%s\", (void **) &_arg0))\n",
		t->print_mangle());
	Printf(f_wrappers, "\t\t\tscheme_wrong_type(\"%s\", %s, 0, argc, argv", \
		var_name, t->print_mangle());
      }
    }
    else {
      throw_unhandled_mzscheme_type_error (t);
    }
    Printf (f_wrappers, "\t}\n");

    // Now return the value of the variable (regardless
    // of evaluating or setting)

    if ((tm = typemap_lookup ((char*)"varout", typemap_lang,
                              t, name, name, (char*)"swig_result"))) {
      Printf (f_wrappers, "%s\n", tm);
    }
    else if (t->is_pointer) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
        Printf (f_wrappers, "\t swig_result = scheme_make_string(%s);\n", name);
      } else {
        // Is an ordinary pointer type.
	Printf(f_wrappers, "\tswig_result = swig_make_c_pointer(%s, \"%s\");\n",
		name, t->print_mangle());
      }
    }
    else {
      throw_unhandled_mzscheme_type_error (t);
    }
    Printf (f_wrappers, "\t return swig_result;\n");
    Printf (f_wrappers, "}\n");

    // Now add symbol to the MzScheme interpreter

    Printv(init_func_def,
	   "scheme_add_global(\"", proc_name,
	   "\", scheme_make_prim_w_arity(", var_name,
	   ", \"", proc_name, "\", 0, 1), env);\n",
	   0);

  } else {
    Printf (stderr, "%s : Line %d. ** Warning. Unable to link with "
             " type %s (ignored).\n",
             input_file, line_number, t->print_type());
  }
  Delete(proc_name);
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
  DOHString *proc_name;
  char   var_name[256];
  DOHString *rvalue;
  char   *tm;

  Status = STAT_READONLY;      // Enable readonly mode.

  // Make a static variable;

  sprintf (var_name, "_wrap_const_%s", name);

  // Build the name for scheme.
  proc_name = NewString(name);
  Replace(proc_name,"_","-",DOH_REPLACE_ANY);

  if ((type->type == T_USER) && (!type->is_pointer)) {
    Printf (stderr, "%s : Line %d.  Unsupported constant value.\n",
             input_file, line_number);
    return;
  }

  // See if there's a typemap
  rvalue = NewString(value);
  if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
    rvalue = NewStringf("\"%s\"", value);
  } else if ((type->type == T_CHAR) && (type->is_pointer == 0)) {
    rvalue = NewStringf("\'%s\'", value);
  } else {
    rvalue = NewString(value);
  }
  if ((tm = typemap_lookup ((char*)"const", typemap_lang, type, name,
                            Char(rvalue), name))) {
    // Yep.  Use it instead of the default
    Printf (f_init, "%s\n", tm);
  } else {
    // Create variable and assign it a value

    Printf (f_header, "static %s %s = ", type->print_type(), var_name);
    if ((type->type == T_CHAR) && (type->is_pointer <= 1)) {
      Printf (f_header, "\"%s\";\n", value);
    } else {
      Printf (f_header, "%s;\n", value);
    }

    // Now create a variable declaration

    link_variable (var_name, name, type);
    Status = OldStatus;
  }
}

// ----------------------------------------------------------------------
// MZSCHEME::usage_var(char *iname, DataType *t, String &usage)
//
// Produces a usage string for a MzScheme variable.
// ----------------------------------------------------------------------

void
MZSCHEME::usage_var (char *iname, DataType *t, DOHString *usage)
{
  Printv(usage, "(", iname, " [value])", 0);
  if (!((t->type != T_USER) || (t->is_pointer))) {
    Printf(usage," - unsupported");
  }
}

// ---------------------------------------------------------------------------
// MZSCHEME::usage_func(char *iname, DataType *t, ParmList *l, String &usage)
//
// Produces a usage string for a function in MzScheme
// ---------------------------------------------------------------------------

void
MZSCHEME::usage_func (char *iname, DataType *d, ParmList *l, DOHString *usage)
{
  int  i;
  Parm *p;

  // Print the function name.

  Printv(usage,"(",iname,0);

  // Now go through and print parameters

  for (p = l->get_first(); p != 0; p = l->get_next()) {

    if (p->ignore)
      continue;

    // Print the type.  If the parameter has been named, use that as well.

    if ((p->t->type != T_VOID) || (p->t->is_pointer)) {

      // Print the type.
      Printv(usage," <", p->t->name, 0);
      if (p->t->is_pointer) {
	for (int j = 0; j < (p->t->is_pointer - p->t->implicit_ptr); j++) {
	  Putc('*', usage);
	}
      }
      Putc('>',usage);

      // Print the name if it exists.
      if (strlen (p->name) > 0) {
	Printv(usage," ", p->name, 0);
      }
    }
  }
  Putc(')',usage);
}


// ---------------------------------------------------------------------------
// MZSCHEME::usage_returns(char *iname, DataType *t, ParmList *l, String &usage)
//
// Produces a usage string for a function in MzScheme
// ---------------------------------------------------------------------------

void
MZSCHEME::usage_returns (char *iname, DataType *d, ParmList *l, DOHString *usage)
{
  Parm *p;
  DOHString *param;
  int have_param = 0, j;

  param = NewString("");
  
  Clear(usage);
  Printf(usage,"returns ");

  // go through and see if any are output.

  for (p = l->get_first(); p != 0; p = l->get_next()) {

    if (strcmp (p->name,"BOTH") && strcmp (p->name,"OUTPUT"))
      continue;

    // Print the type.  If the parameter has been named, use that as well.

    if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
      ++have_param;

      // Print the type.
      Printv(param," $",p->t->name, 0);
      if (p->t->is_pointer) {
	for (j = 0; j < (p->t->is_pointer - p->t->implicit_ptr - 1); j++) {
	  Putc('*',param);
	}
      }
      Printf(param,"# ");
    }
  }

  // See if we stick on the function return type.
  if (d->type != T_VOID || have_param == 0) {
    ++have_param;
    if (d->type == T_VOID)
      Insert(param,0," unspecified");
    else {
      Insert(param,0,"# ");
      Insert(param,0,d->print_type());
      Insert(param,0," $");
    }
  }

  // Kill extra white space.
  // Sorry. Not implemented: param.strip();
  Replace(param,"$", "<", DOH_REPLACE_ANY);
  Replace(param,"#", ">", DOH_REPLACE_ANY);
  Replace(param,"><", "> <", DOH_REPLACE_ANY);

  // If there are multiple return values put them in a list.
  if (have_param > 1) {
    Insert(param,0,"(");
    Append(param,")");
  }
  Printv(usage,param,0);
  Delete(param);
}


// ----------------------------------------------------------------------
// MZSCHEME::usage_const(char *iname, DataType *type, char *value, String &usage)
//
// Produces a usage string for a MzScheme constant
// ----------------------------------------------------------------------

void
MZSCHEME::usage_const (char *iname, DataType *, char *value, DOHString *usage)
{
  Printv(usage,"(", iname, " ", value, ")", 0);
}
