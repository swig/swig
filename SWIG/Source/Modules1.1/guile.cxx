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
 * guile.cxx
 *
 * Definitions for adding functions to Guile 3.0
 ***********************************************************************/

#include "mod11.h"
#include "guile.h"

static char *guile_usage = (char*)"\
Guile Options (available with -guile)\n\
     -module name    - Set base name of module\n\
     -prefix name    - Use NAME as prefix [default \"gswig_\"]\n\
     -package name   - Set the path of the module [default NULL]\n\
     -Linkage lstyle - Use linkage protocol LSTYLE [default `ltdlmod']\n\
\n\
  The module option does not create a guile module with a separate name\n\
  space.  It specifies the name of the initialization function and is\n\
  called a module here so that it is compadible with the rest of SWIG.\n\
\n\
  When unspecified, the default LSTYLE is `ltdlmod' for libtool ltdl\n\
  modules.  Other LSTYLE values are: `hobbit' for hobbit modules.\n\
\n\
  WARNING: Guile support is undergoing large changes and is\n\
           likely to be broken.  Please use with care.\n\
\n";

// ---------------------------------------------------------------------
// GUILE ()
// ---------------------------------------------------------------------

GUILE::GUILE ()
{
  // Set global vars

  typemap_lang = (char*)"guile";

  // Set class vars

  prefix = (char*)"gswig_";
  module = NULL;
  package = NULL;
  linkage = GUILE_LSTYLE_SIMPLE;
}

// ---------------------------------------------------------------------
// GUILE::parse_args(int argc, char *argv[])
//
// Parse arguments.
// ---------------------------------------------------------------------

void
GUILE::parse_args (int argc, char *argv[])
{
  int i, orig_len;

  sprintf (LibDir, "%s", "guile");

  // Look for certain command line options
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp (argv[i], "-help") == 0) {
	fputs (guile_usage, stderr);
	SWIG_exit (0);
      }
      else if (strcmp (argv[i], "-prefix") == 0) {
	if (argv[i + 1]) {
	  prefix = new char[strlen (argv[i + 1]) + 2];
	  strcpy (prefix, argv[i + 1]);
	  Swig_mark_arg (i);
	  Swig_mark_arg (i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      }
      else if (strcmp (argv[i], "-package") == 0) {
	if (argv[i + 1]) {
	  package = new char[strlen (argv[i + 1]) + 2];
	  strcpy (package, argv [i + 1]);
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
      /* Bogus upcase requirement due to top-level parsing not respecting
         language specification.  Top-level should stop when it sees "-guile"
         or other languages.  */
      else if (strcmp (argv[i], "-Linkage") == 0) {
        if (argv[i + 1]) {
          if (0 == strcmp (argv[i + 1], "ltdlmod"))
            linkage = GUILE_LSTYLE_LTDLMOD;
          else if (0 == strcmp (argv[i + 1], "hobbit"))
            linkage = GUILE_LSTYLE_HOBBIT;
          else
            Swig_arg_error ();
          Swig_mark_arg (i);
          Swig_mark_arg (i + 1);
          i += 2;
        } else {
          Swig_arg_error();
        }
      }
    }
  }

  // Make sure `prefix' ends in an underscore

  orig_len = strlen (prefix);
  if (prefix[orig_len - 1] != '_') {
    prefix[1 + orig_len] = 0;
    prefix[orig_len] = '_';
  }

  // Add a symbol for this module

  Preprocessor_define ((void *) "SWIGGUILE",0);
}

// --------------------------------------------------------------------
// GUILE::parse()
//
// Parse the input file
// --------------------------------------------------------------------

void
GUILE::parse ()
{
  printf ("Generating wrappers for Guile\n");

  // Print out GUILE specific headers

  headers();

  // Run the parser

#ifdef SICK_AND_WRONG
  {                                     // ttn hack
    char *tmp_file_name = "TMPSWIG";
    char *orig_input_file = input_file;
    FILE *ttn_hack = fopen (tmp_file_name, "w");

    fprintf (ttn_hack, "%%include guile/typemaps.i\n");
    fclose (ttn_hack);
    input_file = tmp_file_name;
    yyparse();
    remove (tmp_file_name);
    input_file = orig_input_file;
  }
#endif /* SICK_AND_WRONG */
  yyparse();
}

// ---------------------------------------------------------------------
// GUILE::set_module(char *mod_name)
//
// Sets the module name.
// Does nothing if it's already set (so it can be overridden as a command
// line option).
//
//----------------------------------------------------------------------

void
GUILE::set_module (char *mod_name, char **)
{
  if (module) {
    printf ("module already set (%s), returning\n", module);
    return;
  }

  module = new char [strlen (mod_name) + 1];
  strcpy (module, mod_name);
}

// ---------------------------------------------------------------------
// GUILE::set_init(char *iname)
//
// Sets the initialization function name.
// Does nothing if it's already set
//
//----------------------------------------------------------------------

void
GUILE::set_init (char *iname)
{
  abort ();                             // for now -ttn
  set_module (iname, 0);
}

// ---------------------------------------------------------------------
// GUILE::headers(void)
//
// Generate the appropriate header files for GUILE interface.
// ----------------------------------------------------------------------

void
GUILE::headers (void)
{
  Swig_banner (f_header);

  fprintf (f_header, "/* Implementation : GUILE */\n\n");

  // Write out directives and declarations

  if (NoInclude) {
    fprintf(f_header, "#define SWIG_NOINCLUDE\n");
  }
  if (Swig_insert_file ("guiledec.swg", f_header) == -1) {
    fprintf (stderr, "SWIG : Fatal error.  ");
    fprintf (stderr, "Unable to locate 'guiledec.swg' in SWIG library.\n");
    SWIG_exit (1);
  }
  if (!NoInclude) {
    // Write out function definitions
    if (Swig_insert_file ("guile.swg", f_header) == -1) {
      fprintf (stderr, "SWIG : Fatal error.  ");
      fprintf (stderr, "Unable to locate 'guile.swg' in SWIG library.\n");
      SWIG_exit (1);
    }
  }
}

// --------------------------------------------------------------------
// GUILE::initialize()
//
// Output initialization code that registers functions with the
// interface.
// ---------------------------------------------------------------------

void
GUILE::initialize (void)
{
  switch (linkage) {
  case GUILE_LSTYLE_SIMPLE:
    /* Simple linkage; we have to export the SWIG_init function. The user can
       rename the function by a #define. */
    fprintf (f_init, "extern void\nSWIG_init (void)\n{\n");
    break;
  default:
    /* Other linkage; we make the SWIG_init function static */
    fprintf (f_init, "static void\nSWIG_init (void)\n{\n");
    break;
  }
  fprintf (f_init, "\tSWIG_Guile_Init();\n");
}

// ---------------------------------------------------------------------
// GUILE::close(void)
//
// Wrap things up.  Close initialization function.
// ---------------------------------------------------------------------

void
GUILE::emit_linkage (String &module_name)
{
  String module_func ("");

  module_func = "";
  module_func << module_name;
  module_func.replace ("-", "_");

  switch (linkage) {
  case GUILE_LSTYLE_SIMPLE:
    fprintf (f_init, "\n/* Linkage: simple */\n");
    break;
  case GUILE_LSTYLE_LTDLMOD:
    fprintf (f_init, "\n/* Linkage: ltdlmod */\n");
    module_func.replace ("/", "_");
    "scm_init" >> module_func;
    module_func << "_module";
    /* TODO */
    break;
  case GUILE_LSTYLE_HOBBIT:
    fprintf (f_init, "\n/* Linkage: hobbit */\n");
    module_func.replace ("/", "_slash_");
    "scm_init_" >> module_func;
    fprintf (f_init, "SCM\n%s (void)\n{\n", module_func.get());
    {
      String mod = "";
      mod << module_name;
      mod.replace ("/", " ");
      fprintf (f_init, "    scm_register_module_xxx (\"%s\", (void *) SWIG_init);\n",
               mod.get());
      fprintf (f_init, "    return SCM_UNSPECIFIED;\n");
    }
    fprintf (f_init, "}\n");
    break;
  default:
    abort();                            // for now
  }
}

void
GUILE::close (void)
{
  emit_ptr_equivalence (f_init);
  fprintf (f_init, "}\n\n");

  String module_name ("");
  if (package)
    module_name << package << "/" << module;
  else
    module_name << module;

  emit_linkage (module_name);
}

// ----------------------------------------------------------------------
// GUILE::get_pointer(int parm, DataType *t)
//
// Emits code to get a pointer from a parameter and do type checking.
// parm is the parameter number.   This function is only used
// in create_function().
// ----------------------------------------------------------------------

void
GUILE::get_pointer (char *iname, int parm, DataType *t,
		    WrapperFunction &f, const String &proc_name,
		    int num_scheme_parm)
{
  /* Pointers are smobs */
  f.code << tab4 << "if (SWIG_Guile_GetPtr_Str(s_" << parm << ", "
         << "(void **) &_arg" << parm;
  if (t->type == T_VOID)
    f.code << ", (char *) 0)) {\n";
  else
    f.code << ", \"" << t->print_mangle() << "\")) {\n";
  /* Raise exception */
  f.code << tab8
         << "scm_wrong_type_arg(\"" << proc_name << "\", "
         << num_scheme_parm << ", s_" << parm << ");\n";
  f.code << tab4 << "}\n";
}

// ----------------------------------------------------------------------
// GUILE::create_function(char *name, char *iname, DataType *d,
//                             ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

static void
mreplace (String &s, String &argnum, String &arg, String &proc_name)
{
  s.replace ("$argnum", argnum.get());
  s.replace ("$arg",    arg.get());
  s.replace ("$name",   proc_name.get());
}

static void
throw_unhandled_guile_type_error (DataType *d)
{
  fflush (stdout);
  fprintf (stderr, "ERROR: Unhandled GUILE type error.\n");
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
GUILE::create_function (char *name, char *iname, DataType *d, ParmList *l)
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

  String outarg;
  int have_build = 0;
  String build;

  // Make a wrapper name for this
  char * wname = new char [strlen (prefix) + strlen (iname) + 2];
  sprintf (wname, "%s%s", prefix, iname);

  // Build the name for scheme.
  proc_name = "";
  proc_name << iname;
  proc_name.replace ("_", "-");

  // Now write the wrapper function itself....this is pretty ugly

  f.def << "static SCM\n" << wname <<" (";

  int i = 0;
  int first_arg = 1;
  for (p = l->get_first(); p != 0; ++i, p = l->get_next()) {
    if (p->ignore)
      continue;
    if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
      if (!first_arg)
        f.def << ", ";
      f.def << "SCM s_" << i;
      first_arg = 0;
    }
  }

  f.def << ")\n{\n";

  // Define the scheme name in C

  f.def << "#define SCHEME_NAME \"" << proc_name << "\"\n";

  // Declare return variable and arguments

  int pcount = emit_args (d, l, f);
  int numargs = 0;
  int numopt = 0;

  f.add_local ((char*)"SCM",    (char*)"gswig_result");

  // Now write code to extract the parameters (this is super ugly)

  i = 0;
  int j = 0;
  for (i = 0; i < pcount; ++i) {
    Parm &p = (*l)[i];

    // Produce names of source and target
    source = "";
    target = "";
    argnum = "";
    arg    = "";

    source << "s_" << i;
    target << "_arg" << i;
    argnum << i;
    arg << p.name;

    // Handle parameter types.

    if (p.ignore)
      f.code << "/* " << p.name << " ignored... */\n";
    else {
      ++numargs;
      if ((tm = typemap_lookup ((char*)"in", typemap_lang,
                                p.t, p.name, source.get(), target.get(), &f))) {
	f.code << tm << "\n";
        mreplace (f.code, argnum, arg, proc_name);
      }
      else if (p.t->is_pointer)
        get_pointer (iname, i, p.t, f, proc_name, numargs);
      else {
        throw_unhandled_guile_type_error (p.t);
      }
      ++j;
    }

    // Check if there are any constraints.

    if ((tm = typemap_lookup ((char*)"check", typemap_lang,
                              p.t, p.name, source.get(), target.get(), &f))) {
      f.code << tm << "\n";
      mreplace (f.code, argnum, arg, proc_name);
    }

    // Pass output arguments back to the caller.

    if ((tm = typemap_lookup ((char*)"argout", typemap_lang,
                              p.t, p.name, source.get(), target.get(), &f))) {
      outarg << tm << "\n";
      mreplace (outarg, argnum, arg, proc_name);
    }

    // Free up any memory allocated for the arguments.

    if ((tm = typemap_lookup ((char*)"freearg", typemap_lang,
                              p.t, p.name, source.get(), target.get(), &f))) {
      cleanup << tm << "\n";
      mreplace (cleanup, argnum, arg, proc_name);
    }
  }

  // Now write code to make the function call

  f.code << tab4 << "gh_defer_ints();\n";
  emit_func_call (name, d, l, f);
  f.code << tab4 << "gh_allow_ints();\n";

  // Now have return value, figure out what to do with it.

  if (d->type == T_VOID)
    f.code << tab4 << "gswig_result = GH_UNSPECIFIED;\n";
  else if ((tm = typemap_lookup ((char*)"out", typemap_lang,
                                 d, name, (char*)"_result", (char*)"gswig_result", &f))) {
    f.code << tm << "\n";
    mreplace (f.code, argnum, arg, proc_name);
  }
  else if (d->is_pointer) {
    /* MK: I would like to use SWIG_Guile_MakePtr here to save one type
       look-up. */
    f.code << tab4
           << "gswig_result = SWIG_Guile_MakePtr_Str ("
           << "_result, "
           << "\"" << d->print_mangle() << "\", "
           << "\"" << d->print_type() << "\""
           << ");\n";
  }
  else {
    throw_unhandled_guile_type_error (d);
  }

  // Dump the argument output code
  f.code << outarg;

  // Dump the argument cleanup code
  f.code << cleanup;

  // Look for any remaining cleanup

  if (NewObject) {
    if ((tm = typemap_lookup ((char*)"newfree", typemap_lang,
                              d, iname, (char*)"_result", (char*)"", &f))) {
      f.code << tm << "\n";
      mreplace (f.code, argnum, arg, proc_name);
    }
  }

  // Free any memory allocated by the function being wrapped..

  if ((tm = typemap_lookup ((char*)"ret", typemap_lang,
                            d, name, (char*)"_result", (char*)"", &f))) {
    f.code << tm << "\n";
    mreplace (f.code, argnum, arg, proc_name);
  }

  // Wrap things up (in a manner of speaking)

  f.code << tab4 << "return gswig_result;\n";

  // Undefine the scheme name

  f.code << "#undef SCHEME_NAME\n";

  f.code << "}\n";

  f.print (f_wrappers);

  if (numargs > 10) {
    // Guile would complain: too many args
    fprintf(stderr,
            "%s : Line %d. Warning. Too many arguments in Guile wrapper "
            "for function %s (max. 10).\n",
            input_file, line_number, name);
  }
  else {
    // Now register the function
    fprintf (f_init, "\t gh_new_procedure(\"%s\", %s, %d, %d, 0);\n",
             proc_name.get(), wname, numargs-numopt, numopt);
  }
}

// -----------------------------------------------------------------------
// GUILE::link_variable(char *name, char *iname, DataType *d)
//
// Create a link to a C variable.
// This creates a single function PREFIX_var_VARNAME().
// This function takes a single optional argument.   If supplied, it means
// we are setting this variable to some value.  If omitted, it means we are
// simply evaluating this variable.  Either way, we return the variables
// value.
// -----------------------------------------------------------------------

void
GUILE::link_variable (char *name, char *iname, DataType *t)
{
  String proc_name;
  char  var_name[256];
  char  *tm;
  char  *tm2 = typemap_lookup ((char*)"varout", (char*)"guile", t, name, name, (char*)"scmresult");

  // evaluation function names

  sprintf (var_name, "%svar_%s", prefix, iname);

  // Build the name for scheme.
  proc_name = "";
  proc_name << iname;
  proc_name.replace ("_", "-");

  if ((t->type != T_USER) || (t->is_pointer)) {

    fprintf (f_wrappers, "SCM %s(SCM s_0) {\n", var_name);

    if (!(Status & STAT_READONLY) && t->type == T_CHAR && t->is_pointer==1) {
      fprintf (f_wrappers, "\t char *_temp;\n");
      fprintf (f_wrappers, "\t int  _len;\n");
    }
    fprintf (f_wrappers, "\t SCM gswig_result;\n");

    // Check for a setting of the variable value

    fprintf (f_wrappers, "\t if (s_0 != GH_NOT_PASSED) {\n");

    // Yup. Extract the type from s_0 and set variable value

    if (Status & STAT_READONLY) {
      fprintf (f_wrappers, "\t\t scm_misc_error(\"%s\", "
	       "\"Unable to set %s. Variable is read only.\", SCM_EOL);\n",
	       proc_name.get(), proc_name.get());
    }
    else if ((tm = typemap_lookup ((char*)"varin", typemap_lang,
                                   t, name, (char*)"s_0", name))) {
      fprintf (f_wrappers, "%s\n", tm);
    }
    else if (t->is_pointer) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
        fprintf (f_wrappers, "\t\t _temp = gh_scm2newstr(s_0, &_len);\n");
        fprintf (f_wrappers, "\t\t if (%s) { free(%s);}\n", name, name);
        fprintf (f_wrappers, "\t\t %s = (char *) "
                 "malloc((_len+1)*sizeof(char));\n", name);
        fprintf (f_wrappers, "\t\t strncpy(%s,_temp,_len);\n", name);
        fprintf (f_wrappers, "\t\t %s[_len] = 0;\n", name);
      } else {
        // Set the value of a pointer
        /* MK: I would like to use SWIG_Guile_GetPtr here */
        fprintf (f_wrappers, "\t if (SWIG_Guile_GetPtr_Str(s_0, "
                 "(void **) &%s, ", name);
        if (t->type == T_VOID)
          fprintf (f_wrappers, "(char *) 0)) {\n");
        else
          fprintf (f_wrappers, "\"%s\")) {\n", t->print_mangle());
	/* Raise exception */
	fprintf(f_wrappers, "\tscm_wrong_type_arg(\"%s\", "
		"%d, s_0);\n", proc_name.get(), 1);
        fprintf (f_wrappers, "\t}\n");
      }
    }
    else {
      throw_unhandled_guile_type_error (t);
    }
    fprintf (f_wrappers, "\t}\n");

    // Now return the value of the variable (regardless
    // of evaluating or setting)

    if ((tm = typemap_lookup ((char*)"varout", typemap_lang,
                              t, name, name, (char*)"gswig_result"))) {
      fprintf (f_wrappers, "%s\n", tm);
    }
    else if (t->is_pointer) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
        fprintf (f_wrappers, "\t gswig_result = gh_str02scm(%s);\n", name);
      } else {
        // Is an ordinary pointer type.
        /* MK: I would like to use SWIG_Guile_MakePtr here to save one type
           look-up. */
        fprintf (f_wrappers, "\t gswig_result = SWIG_Guile_MakePtr_Str ("
                 "%s, \"%s\", \"%s\");\n", name, t->print_mangle(),
                 t->print_type());
      }
    }
    else {
      throw_unhandled_guile_type_error (t);
    }
    fprintf (f_wrappers, "\t return gswig_result;\n");
    fprintf (f_wrappers, "}\n");

    // Now add symbol to the Guile interpreter

    fprintf (f_init, "\t gh_new_procedure(\"%s\", %s, 0, 1, 0);\n",
             proc_name.get(), var_name);

  } else {
    fprintf (stderr, "%s : Line %d. ** Warning. Unable to link with "
             " type %s (ignored).\n",
             input_file, line_number, t->print_type());
  }
}

// -----------------------------------------------------------------------
// GUILE::declare_const(char *name, char *iname, DataType *type, char *value)
//
// Makes a constant.   Not sure how this is really supposed to work.
// I'm going to fake out SWIG and create a variable instead.
// ------------------------------------------------------------------------

void
GUILE::declare_const (char *name, char *, DataType *type, char *value)
{
  int OldStatus = Status;      // Save old status flags
  String proc_name;
  char   var_name[256];
  String rvalue;
  char   *tm;

  Status = STAT_READONLY;      // Enable readonly mode.

  // Make a static variable;

  sprintf (var_name, "%sconst_%s", prefix, name);

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
  if ((tm = typemap_lookup ((char*)"const", typemap_lang, type, name,
                            rvalue.get(), name))) {
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
// GUILE::usage_var(char *iname, DataType *t, String &usage)
//
// Produces a usage string for a Guile variable.
// ----------------------------------------------------------------------

void
GUILE::usage_var (char *iname, DataType *t, String &usage)
{
  char temp[1024], *c;

  usage << "(" << iname << " [value])";
  if (!((t->type != T_USER) || (t->is_pointer))) {
    usage << " - unsupported";
  }
}

// ---------------------------------------------------------------------------
// GUILE::usage_func(char *iname, DataType *t, ParmList *l, String &usage)
//
// Produces a usage string for a function in Guile
// ---------------------------------------------------------------------------

void
GUILE::usage_func (char *iname, DataType *d, ParmList *l, String &usage)
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
// GUILE::usage_returns(char *iname, DataType *t, ParmList *l, String &usage)
//
// Produces a usage string for a function in Guile
// ---------------------------------------------------------------------------

void
GUILE::usage_returns (char *iname, DataType *d, ParmList *l, String &usage)
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
// GUILE::usage_const(char *iname, DataType *type, char *value, String &usage)
//
// Produces a usage string for a Guile constant
// ----------------------------------------------------------------------

void
GUILE::usage_const (char *iname, DataType *, char *value, String &usage)
{
  usage << "(" << iname << " " << value << ")";
}
