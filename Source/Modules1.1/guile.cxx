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
 * Definitions for adding functions to Guile
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
      // Silent recognition (no side effects) of "-with-smobs" is here
      // as a convenience to users.  This will be removed after 1.3a4
      // release.  --ttn, 2000/07/20 13:01:07.
      else if (strcmp (argv[i], "-with-smobs") == 0) {
	Swig_mark_arg (i);
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

    Printf (ttn_hack, "%%include guile/typemaps.i\n");
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

  Printf (f_header, "/* Implementation : GUILE */\n\n");

  // Write out directives and declarations

  if (NoInclude) {
    Printf(f_header, "#define SWIG_NOINCLUDE\n");
  }
  if (Swig_insert_file ("guiledec.swg", f_header) == -1) {
    Printf (stderr, "SWIG : Fatal error.  ");
    Printf (stderr, "Unable to locate 'guiledec.swg' in SWIG library.\n");
    SWIG_exit (1);
  }
  if (!NoInclude) {
    // Write out function definitions
    if (Swig_insert_file ("guile.swg", f_header) == -1) {
      Printf (stderr, "SWIG : Fatal error.  ");
      Printf (stderr, "Unable to locate 'guile.swg' in SWIG library.\n");
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
    Printf (f_init, "extern void\nSWIG_init (void)\n{\n");
    break;
  default:
    /* Other linkage; we make the SWIG_init function static */
    Printf (f_init, "static void\nSWIG_init (void)\n{\n");
    break;
  }
  Printf (f_init, "\tSWIG_Guile_Init();\n");
}

// ---------------------------------------------------------------------
// GUILE::close(void)
//
// Wrap things up.  Close initialization function.
// ---------------------------------------------------------------------

void
GUILE::emit_linkage (char *module_name)
{
  DOHString *module_func = NewString("");

  Printv(module_func,module_name,0);
  Replace(module_func,"-", "_", DOH_REPLACE_ANY);

  switch (linkage) {
  case GUILE_LSTYLE_SIMPLE:
    Printf (f_init, "\n/* Linkage: simple */\n");
    break;
  case GUILE_LSTYLE_LTDLMOD:
    Printf (f_init, "\n/* Linkage: ltdlmod */\n");
    Replace(module_func,"/", "_", DOH_REPLACE_ANY);
    Insert(module_func,0, "scm_init");
    Append(module_func,"_module");
    /* TODO */
    break;
  case GUILE_LSTYLE_HOBBIT:
    Printf (f_init, "\n/* Linkage: hobbit */\n");
    Replace(module_func,"/", "_slash_", DOH_REPLACE_ANY);
    Insert(module_func,0, "scm_init_");
    Printf (f_init, "SCM\n%s (void)\n{\n", module_func);
    {
      DOHString *mod = NewString(module_name);
      Replace(mod,"/", " ", DOH_REPLACE_ANY);
      Printf (f_init, "    scm_register_module_xxx (\"%s\", (void *) SWIG_init);\n",
               mod);
      Printf (f_init, "    return SCM_UNSPECIFIED;\n");
      Delete(mod);
    }
    Printf (f_init, "}\n");
    break;
  default:
    abort();                            // for now
  }
  Delete(module_func);
}

void
GUILE::close (void)
{
  emit_ptr_equivalence (f_wrappers,f_init);
  Printf (f_init, "}\n\n");
  char module_name[256];

  if (!module)
    sprintf(module_name, "swig");
  else {
    if (package)
      sprintf(module_name,"%s/%s", package,module);
    else
      strcpy(module_name,module);
  }
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
		    Wrapper *f, DOHString_or_char *proc_name,
		    int num_scheme_parm)
{
  /* Pointers are smobs */
  Printf(f->code, "    if (SWIG_Guile_GetPtr_Str(s_%d,(void **) &_arg%d", parm, parm);
  if (t->type == T_VOID)
    Printf(f->code, ", (char *) 0)) {\n");
  else
    Printv(f->code, ", \"", DataType_manglestr(t), "\")) {\n", 0);
  /* Raise exception */
  Printv(f->code,
	 tab8,
         "scm_wrong_type_arg(\"",proc_name, "\", ",
	 0);
  Printf(f->code,"%d, s_%d);\n", num_scheme_parm, parm);
  Printv(f->code, tab4, "}\n", 0);
}

// ----------------------------------------------------------------------
// GUILE::create_function(char *name, char *iname, DataType *d,
//                             ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

static void
mreplace (DOHString *s, DOHString_or_char *argnum, DOHString_or_char *arg, DOHString_or_char *proc_name)
{
  Replace(s,"$argnum",argnum, DOH_REPLACE_ANY);
  Replace(s,"$arg",   arg, DOH_REPLACE_ANY);
  Replace(s,"$name",  proc_name, DOH_REPLACE_ANY);
}

static void
throw_unhandled_guile_type_error (DataType *d)
{
  fflush (stdout);
  Printf (stderr, "ERROR: Unhandled GUILE type error.\n");
  Printf (stderr, "        type %d\n", d->type);
  Printf (stderr, "        name %s\n", d->name);
  Printf (stderr, "  is_pointer %d\n", d->is_pointer);
  Printf (stderr, "implicit_ptr %d\n", d->implicit_ptr);
  Printf (stderr, "is_reference %d\n", d->is_reference);
  Printf (stderr, "      status %d\n", d->status);
  /*  Printf (stderr, "   qualifier %s\n", (d->qualifier ? d->qualifier : ""));
      Printf (stderr, "    arraystr %s\n", (d->arraystr ? d->arraystr : ""));*/
  Printf (stderr, "          id %d\n", d->id);

  Printf (stderr, "\n\nBAILING...\n"); // for now -ttn
  abort();                              // for now -ttn
}

void
GUILE::create_function (char *name, char *iname, DataType *d, ParmList *l)
{
  Parm *p;
  DOHString *proc_name = 0;
  char source[256], target[256], argnum[256], arg[256];
  char  *tm;
  Wrapper *f;
  DOHString *cleanup;
  DOHString *outarg;

  f = NewWrapper();
  outarg = NewString("");
  cleanup = NewString("");

  // Make a wrapper name for this
  char * wname = new char [strlen (prefix) + strlen (iname) + 2];
  sprintf (wname, "%s%s", prefix, iname);

  // Build the name for scheme.
  proc_name = NewString(iname);
  Replace(proc_name,"_", "-", DOH_REPLACE_ANY);

  // Now write the wrapper function itself....this is pretty ugly

  Printv(f->def, "static SCM\n", wname," (", 0);

  int i = 0;
  int first_arg = 1;
  for (p = ParmList_first(l); p != 0; ++i, p = ParmList_next(l)) {
    DataType *pt = Parm_Gettype(p);

    if (Parm_Getignore(p))
      continue;
    if ((pt->type != T_VOID) || (pt->is_pointer)) {
      if (!first_arg)
	Printf(f->def,", ");
      Printf(f->def,"SCM s_%d", i);
      first_arg = 0;
    }
  }

  Printf(f->def, ")\n{\n");

  // Define the scheme name in C

  Printv(f->def, "#define SCHEME_NAME \"", proc_name, "\"\n", 0);

  // Declare return variable and arguments

  int pcount = emit_args (d, l, f);
  int numargs = 0;
  int numopt = 0;

  Wrapper_add_local (f,"gswig_result", "SCM gswig_result");

  // Now write code to extract the parameters (this is super ugly)

  i = 0;
  int j = 0;
  for (i = 0; i < pcount; ++i) {
    Parm *p = ParmList_get(l,i);
    DataType *pt = Parm_Gettype(p);
    char     *pn = Parm_Getname(p);

    // Produce names of source and target
    sprintf(source,"s_%d",i);
    sprintf(target,"%s",Parm_Getlname(p));
    sprintf(argnum,"%d",i);
    strcpy(arg,pn);

    // Handle parameter types.

    if (Parm_Getignore(p))
      Printv(f->code, "/* ", pn, " ignored... */\n", 0);
    else {
      ++numargs;
      if ((tm = typemap_lookup ((char*)"in", typemap_lang,
                                pt, pn, source, target, f))) {
	Printv(f->code,tm,"\n",0);
        mreplace (f->code, argnum, arg, proc_name);
      }
      else if (pt->is_pointer)
        get_pointer (iname, i, pt, f, proc_name, numargs);
      else {
        throw_unhandled_guile_type_error (pt);
      }
      ++j;
    }

    // Check if there are any constraints.

    if ((tm = typemap_lookup ((char*)"check", typemap_lang,
                              pt, pn, source, target, f))) {
      Printv(f->code,tm,"\n",0);
      mreplace (f->code, argnum, arg, proc_name);
    }

    // Pass output arguments back to the caller.

    if ((tm = typemap_lookup ((char*)"argout", typemap_lang,
                              pt, pn, source, target, f))) {
      Printv(outarg,tm,"\n",0);
      mreplace (outarg, argnum, arg, proc_name);
    }

    // Free up any memory allocated for the arguments.

    if ((tm = typemap_lookup ((char*)"freearg", typemap_lang,
                              pt, pn, source, target, f))) {
      Printv(cleanup, tm, "\n", 0);
      mreplace (cleanup, argnum, arg, proc_name);
    }
  }

  // Now write code to make the function call
  Printv(f->code, tab4, "gh_defer_ints();\n", 0);
  emit_func_call (name, d, l, f);
  Printv(f->code, tab4, "gh_allow_ints();\n", 0);

  // Now have return value, figure out what to do with it.

  if (d->type == T_VOID)
    Printv(f->code, tab4, "gswig_result = GH_UNSPECIFIED;\n", 0);
  else if ((tm = typemap_lookup ((char*)"out", typemap_lang,
                                 d, name, (char*)"result", (char*)"gswig_result", f))) {
    Printv(f->code,tm,"\n",0);
    mreplace (f->code, argnum, arg, proc_name);
  }
  else if (d->is_pointer) {
    /* MK: I would like to use SWIG_Guile_MakePtr here to save one type
       look-up. */
    Printv(f->code, tab4,
           "gswig_result = SWIG_Guile_MakePtr_Str (",
           "result, ",
           "\"", DataType_manglestr(d), "\", ",
           "\"", DataType_str(d,0), "\"",
           ");\n",
	   0);
  }
  else {
    throw_unhandled_guile_type_error (d);
  }

  // Dump the argument output code
  Printv(f->code,outarg,0);

  // Dump the argument cleanup code
  Printv(f->code,cleanup,0);

  // Look for any remaining cleanup

  if (NewObject) {
    if ((tm = typemap_lookup ((char*)"newfree", typemap_lang,
                              d, iname, (char*)"result", (char*)"", f))) {
      Printv(f->code,tm,"\n",0);
      mreplace (f->code, argnum, arg, proc_name);
    }
  }

  // Free any memory allocated by the function being wrapped..

  if ((tm = typemap_lookup ((char*)"ret", typemap_lang,
                            d, name, (char*)"result", (char*)"", f))) {
    Printv(f->code,tm,"\n",0);
    mreplace (f->code, argnum, arg, proc_name);
  }

  // Wrap things up (in a manner of speaking)

  Printv(f->code, tab4, "return gswig_result;\n", 0);

  // Undefine the scheme name

  Printf(f->code, "#undef SCHEME_NAME\n");
  Printf(f->code, "}\n");

  Wrapper_print (f, f_wrappers);

  if (numargs > 10) {
    // Guile would complain: too many args
    Printf(stderr,
            "%s : Line %d. Warning. Too many arguments in Guile wrapper "
            "for function %s (max. 10).\n",
            input_file, line_number, name);
  }
  else {
    // Now register the function
    Printf (f_init, "\t gh_new_procedure(\"%s\", %s, %d, %d, 0);\n",
             proc_name, wname, numargs-numopt, numopt);
  }
  Delete(proc_name);
  Delete(outarg);
  Delete(cleanup);
  DelWrapper(f);
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
  DOHString *proc_name;
  char  var_name[256];
  char  *tm;


  // evaluation function names

  sprintf (var_name, "%svar_%s", prefix, iname);

  // Build the name for scheme.
  proc_name = NewString(iname);
  Replace(proc_name,"_", "-",DOH_REPLACE_ANY);

  if ((t->type != T_USER) || (t->is_pointer)) {

    Printf (f_wrappers, "SCM %s(SCM s_0) {\n", var_name);

    if (!(Status & STAT_READONLY) && t->type == T_CHAR && t->is_pointer==1) {
      Printf (f_wrappers, "\t char *_temp;\n");
      Printf (f_wrappers, "\t int  _len;\n");
    }
    Printf (f_wrappers, "\t SCM gswig_result;\n");

    // Check for a setting of the variable value

    Printf (f_wrappers, "\t if (s_0 != GH_NOT_PASSED) {\n");

    // Yup. Extract the type from s_0 and set variable value

    if (Status & STAT_READONLY) {
      Printf (f_wrappers, "\t\t scm_misc_error(\"%s\", "
	       "\"Unable to set %s. Variable is read only.\", SCM_EOL);\n",
	       proc_name, proc_name);
    }
    else if ((tm = typemap_lookup ((char*)"varin", typemap_lang,
                                   t, name, (char*)"s_0", name))) {
      Printf (f_wrappers, "%s\n", tm);
    }
    else if (t->is_pointer) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
        Printf (f_wrappers, "\t\t _temp = gh_scm2newstr(s_0, &_len);\n");
        Printf (f_wrappers, "\t\t if (%s) { free(%s);}\n", name, name);
        Printf (f_wrappers, "\t\t %s = (char *) "
                 "malloc((_len+1)*sizeof(char));\n", name);
        Printf (f_wrappers, "\t\t strncpy(%s,_temp,_len);\n", name);
        Printf (f_wrappers, "\t\t %s[_len] = 0;\n", name);
      } else {
        // Set the value of a pointer
        /* MK: I would like to use SWIG_Guile_GetPtr here */
        Printf (f_wrappers, "\t if (SWIG_Guile_GetPtr_Str(s_0, "
                 "(void **) &%s, ", name);
        if (t->type == T_VOID)
          Printf (f_wrappers, "(char *) 0)) {\n");
        else
          Printf (f_wrappers, "\"%s\")) {\n", DataType_manglestr(t));
	/* Raise exception */
	Printf(f_wrappers, "\tscm_wrong_type_arg(\"%s\", "
		"%d, s_0);\n", proc_name, 1);
        Printf (f_wrappers, "\t}\n");
      }
    }
    else {
      throw_unhandled_guile_type_error (t);
    }
    Printf (f_wrappers, "\t}\n");

    // Now return the value of the variable (regardless
    // of evaluating or setting)

    if ((tm = typemap_lookup ((char*)"varout", typemap_lang,
                              t, name, name, (char*)"gswig_result"))) {
      Printf (f_wrappers, "%s\n", tm);
    }
    else if (t->is_pointer) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
        Printf (f_wrappers, "\t gswig_result = gh_str02scm(%s);\n", name);
      } else {
        // Is an ordinary pointer type.
        /* MK: I would like to use SWIG_Guile_MakePtr here to save one type
           look-up. */
        Printf (f_wrappers, "\t gswig_result = SWIG_Guile_MakePtr_Str ("
                 "%s, \"%s\", \"%s\");\n", name, DataType_manglestr(t),
                 DataType_str(t,0));
      }
    }
    else {
      throw_unhandled_guile_type_error (t);
    }
    Printf (f_wrappers, "\t return gswig_result;\n");
    Printf (f_wrappers, "}\n");

    // Now add symbol to the Guile interpreter

    Printf (f_init, "\t gh_new_procedure(\"%s\", %s, 0, 1, 0);\n",
             proc_name, var_name);

  } else {
    Printf (stderr, "%s : Line %d. ** Warning. Unable to link with "
             " type %s (ignored).\n",
             input_file, line_number, DataType_str(t,0));
  }
  Delete(proc_name);
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
  DOHString *proc_name;
  char   var_name[256];
  DOHString *rvalue;
  char   *tm;

  Status = STAT_READONLY;      // Enable readonly mode.

  // Make a static variable;

  sprintf (var_name, "%sconst_%s", prefix, name);

  // Build the name for scheme.
  proc_name = NewString(name);
  Replace(proc_name,"_", "-", DOH_REPLACE_ANY);

  if ((type->type == T_USER) && (!type->is_pointer)) {
    Printf (stderr, "%s : Line %d.  Unsupported constant value.\n",
             input_file, line_number);
    return;
  }

  // See if there's a typemap

  if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
    rvalue = NewStringf("\"%s\"", value);
  } else if ((type->type == T_CHAR) && (type->is_pointer == 0)) {
    rvalue = NewStringf("\'%s\'", value);
  } else {
    rvalue = NewString(value);
  }
  if ((tm = typemap_lookup ((char*)"const", typemap_lang, type, name,
                            Char(rvalue), name))) {
    Printf (f_init, "%s\n", tm);
  } else {
    // Create variable and assign it a value

    Printf (f_header, "static %s %s = ", DataType_lstr(type,0), var_name);
    if ((type->type == T_CHAR) && (type->is_pointer <= 1)) {
      Printf (f_header, "\"%s\";\n", value);
    } else {
      Printf (f_header, "%s;\n", value);
    }

    // Now create a variable declaration

    link_variable (var_name, name, type);
    Status = OldStatus;
  }
  Delete(proc_name);
  Delete(rvalue);
}

// ----------------------------------------------------------------------
// GUILE::usage_var(char *iname, DataType *t, String &usage)
//
// Produces a usage string for a Guile variable.
// ----------------------------------------------------------------------

void
GUILE::usage_var (char *iname, DataType *t, DOHString *usage)
{

  Printv(usage, "(", iname, " [value])", 0);
  if (!((t->type != T_USER) || (t->is_pointer))) {
    Printf(usage," - unsupported");
  }
}

// ---------------------------------------------------------------------------
// GUILE::usage_func(char *iname, DataType *t, ParmList *l, String &usage)
//
// Produces a usage string for a function in Guile
// ---------------------------------------------------------------------------

void
GUILE::usage_func (char *iname, DataType *d, ParmList *l, DOHString *usage)
{

  Parm *p;

  // Print the function name.

  Printv(usage,"(",iname,0);

  // Now go through and print parameters

  for (p = ParmList_first(l); p != 0; p = ParmList_next(l)) {
    DataType *pt = Parm_Gettype(p);
    char     *pn = Parm_Getname(p);

    if (Parm_Getignore(p))
      continue;

    // Print the type.  If the parameter has been named, use that as well.

    if ((pt->type != T_VOID) || (pt->is_pointer)) {

      // Print the type.
      Printv(usage, " <", pt->name, 0);
      if (pt->is_pointer) {
	for (int j = 0; j < (pt->is_pointer - pt->implicit_ptr); j++) {
	  Putc('*', usage);
	}
      }
      Putc('>',usage);

      // Print the name if it exists.
      if (strlen (pn) > 0) {
	Printv(usage," ", pn, 0);
      }
    }
  }
  Putc(')', usage);
}


// ---------------------------------------------------------------------------
// GUILE::usage_returns(char *iname, DataType *t, ParmList *l, String &usage)
//
// Produces a usage string for a function in Guile
// ---------------------------------------------------------------------------

void
GUILE::usage_returns (char *iname, DataType *d, ParmList *l, DOHString *usage)
{
  Parm *p;
  DOHString *param;
  int have_param = 0, j;

  Clear(usage);
  Printf(usage,"returns ");
  param = NewString("");

  // go through and see if any are output.

  for (p = ParmList_first(l); p != 0; p = ParmList_next(l)) {
    DataType *pt = Parm_Gettype(p);
    char     *pn = Parm_Getname(p);

    if (strcmp (pn,"BOTH") && strcmp (pn,"OUTPUT"))
      continue;

    // Print the type.  If the parameter has been named, use that as well.

    if ((pt->type != T_VOID) || (pt->is_pointer)) {
      ++have_param;

      // Print the type.
      Printv(param," $", pt->name, 0);
      if (pt->is_pointer) {
	for (j = 0; j < (pt->is_pointer - pt->implicit_ptr - 1); j++) {
	  Putc('*', param);
	}
      }
      Printf(param,"# ");
    }
  }

  // See if we stick on the function return type.
  if (d->type != T_VOID || have_param == 0) {
    ++have_param;
    if (d->type == T_VOID)
      Insert(param,0," unspecified ");
    else {
      Insert(param,0,"# ");
      Insert(param,0, DataType_str(d,0));
      Insert(param,0," $");
    }
  }

  // Kill extra white space.
  //  param.strip();   - DB: Not supported right now
  Replace(param,"$",  "<", DOH_REPLACE_ANY);
  Replace(param,"#",  ">", DOH_REPLACE_ANY);
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
// GUILE::usage_const(char *iname, DataType *type, char *value, String &usage)
//
// Produces a usage string for a Guile constant
// ----------------------------------------------------------------------

void
GUILE::usage_const (char *iname, DataType *, char *value, DOHString *usage)
{
  Printv(usage, "(", iname, " ", value, ")", 0);
}
