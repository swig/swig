#define TTN_NEW_CODE // WARNING! this is still unstable

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

static char *guile_usage = "\
Guile Options (available with -guile)\n\
     -module name    - Set base name of module\n\
     -prefix name    - Set a prefix to be appended to all name\n\
     -package name   - Set the path of the module\n\
\n\
  The module option does not create a guile module with a separate name\n\
  space.  It specifies the name of the initialization function and is \n\
  called a module here so that it is compadible with the rest of SWIG.\n\
\n";

// ---------------------------------------------------------------------
// GUILE ()
// ---------------------------------------------------------------------

GUILE::GUILE ()
{
  prefix = NULL;
  module = NULL;
  package = "swig";
  guile_path = "guile";
}

// ---------------------------------------------------------------------
// GUILE::parse_args(int argc, char *argv[])
//
// Parse arguments.
// ---------------------------------------------------------------------

void
GUILE::parse_args (int argc, char *argv[])
{
  int i;

  sprintf (LibDir, "%s", guile_path);

  // Look for certain command line options
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp (argv[i], "-help") == 0) {
	fputs (guile_usage, stderr);
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
      else if (strcmp (argv[i], "-package") == 0) {
	if (argv[i + 1]) {
	  package = new char[strlen (argv[i + 1]) + 2];
	  strcpy(package, argv [i + 1]);
	  Swig_mark_arg (i);
	  Swig_mark_arg (i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      }
      else if (strcmp(argv[i],"-module") == 0) {
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
    prefix = "gswig_";

  // Add a symbol for this module

  Preprocessor_define ((void *) "SWIGGUILE",0);

  // Set name of typemaps

  typemap_lang = "guile";
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
  emit_banner (f_header);

  fprintf (f_header, "/* Implementation : GUILE */\n\n");
  fprintf (f_header, "#define SWIGGUILE\n");
  fprintf (f_header, "#include <stdio.h>\n");
  fprintf (f_header, "#include <string.h>\n");
  fprintf (f_header, "#include <stdlib.h>\n");

  // Write out hex conversion functions

  if (!NoInclude) {
    if (Swig_insert_file ("guile.swg", f_header) == -1) {
      fprintf (stderr, "SWIG : Fatal error.  ");
      fprintf (stderr, "Unable to locate 'guile.swg' in SWIG library.\n");
      SWIG_exit (1);
    }
    // <DB> I Removed a call to emit_hex() here.  The pointer type-checking code
    // should be included into guile.swg instead </DB>
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
// GUILE::initialize()
//
// Output initialization code that registers functions with the
// interface.
// ---------------------------------------------------------------------
void
GUILE::initialize (void)
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
// GUILE::close(void)
//
// Wrap things up.  Close initialization function.
// ---------------------------------------------------------------------

void
GUILE::close (void)
{
  String module_name;
  String module_func;

  emit_ptr_equivalence (f_init);
  fprintf (f_init, "}\n\n");

  module_name = "";
  module_name << package << " " << module;

  // First turn any '_' into spaces
  module_name.replace ("_", " ");

  // Now strip the extra space.
  module_name.strip();

  // Build the module function name.
  module_func = "";
  module_func << module_name;
  module_func.replace (" ", "_");
  module_func.replace ("-", "_");
  "scm_" >> module_func;
  module_func << "_module";

  fprintf (f_init, "void %s(void)\n{\n", module_func.get());
  fprintf (f_init, "    scm_register_module_xxx(\"%s\",SWIG_init);\n",
           module_name.get());
  fprintf (f_init, "}\n");
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
		    WrapperFunction &f)
{
  // Pointers are read as hex-strings with encoded type information
  f.code << tab4 << "_tempc = gh_scm2newstr (s_" << parm << ", &_len);\n";
  f.code << tab4 << "if (SWIG_GetPtr (_tempc, (void **) &_arg" << parm;
  if (t->type == T_VOID)
    f.code << ", (char *) 0)) {\n";
  else
    f.code << ", \"" << t->print_mangle() << "\")) {\n";

#ifdef TTN_NEW_CODE
  f.code << tab4 << "}\n";
#else /* !TTN_NEW_CODE */

  // Now emit code according to the level of strictness desired

  switch(TypeStrict) {
  case 0: // No type checking
    f.code << tab4 << "}\n";
    break;
  case 1: // Warning message only
    f.code << tab8
	   << "fprintf(stderr,\"Warning : type mismatch in argument "
           << parm+1
	   << " of "
	   << iname
	   << ". Expected "
	   << t->print_mangle()
	   << ", received %%s\\n\", _tempc);\n"
           << tab4 << "}\n";
    break;
  case 2: // Super strict mode.
    f.code << tab8
	   << "GSWIG_ASSERT(0,\"Type error in argument "
           << parm+1
	   << " of "
	   << iname
	   << ". Expected "
	   << t->print_mangle()
	   << ".  Received %s\", s_"
	   << parm
	   << ");\n"
	   << tab4 << "}\n";
    break;

  default :
    fprintf(stderr,"Unknown strictness level\n");
    break;
  }
#endif /* !TTN_NEW_CODE */

  f.code << tab4 << "free(_tempc);\n";
}

// ----------------------------------------------------------------------
// GUILE::create_function(char *name, char *iname, DataType *d,
//                             ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

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
  int need_len = 0;
  int need_tempc = 0;

  String outarg;
  int have_build = 0;
  String build;

  // Make a wrapper name for this
  char * wname = name_wrapper (iname, prefix);

  // Build the name for scheme.
  proc_name = "";
  proc_name << iname;
  proc_name.replace ("_", "-");

  // Now write the wrapper function itself....this is pretty ugly

  f.def << "static SCM\n" << wname <<" (";

  int i = 0;
  for (p = l->get_first(); p != 0; ++i, p = l->get_next()) {
    if (p->ignore)
      continue;
    if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
      if (i > 0)
        f.def << ", ";
      f.def << "SCM s_" << i;
    }
  }

  f.def << ")\n{";

  // Declare return variable and arguments

  int pcount = emit_args (d, l, f);
  int numargs = 0;
  int numopt = 0;

  f.add_local ("int",    "_len");
  f.add_local ("char *", "_tempc");
  f.add_local ("SCM",    "gswig_result");

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

    // If this parameter is not being ignored, then check if there is
    // an input type map.
    if (p.ignore)
      f.code << "// " << p.name << " ignored...\n";
    else {
      ++numargs;
      if ((tm = typemap_lookup ("in", typemap_lang,
                                p.t, p.name, source, target, &f))) {
	// Yep.  Use it instead of the default
	f.code << tm << "\n";
	f.code.replace ("$argnum", argnum);
	f.code.replace ("$arg",    arg);
	f.code.replace ("$name",   proc_name);
      }
      else {
	if (p.t->is_pointer)
	  // Argument is a pointer type.   Special case is for char *
	  // since that is usually a string.
	  get_pointer (iname, i, p.t, f);
      }
      ++j;
    }

    // Check if there are any constraints.

    if ((tm = typemap_lookup ("check", typemap_lang,
                              p.t, p.name, source, target, &f))) {
      // Yep.  Use it instead of the default
      f.code << tm << "\n";
      f.code.replace ("$argnum", argnum);
      f.code.replace ("$arg",    arg);
      f.code.replace ("$name",   proc_name);
    }

    // Pass output arguments back to the caller.

    if ((tm = typemap_lookup ("argout", typemap_lang,
                              p.t, p.name, source, target, &f))) {
      // Yep.  Use it instead of the default
      outarg << tm << "\n";
      outarg.replace ("$argnum", argnum);
      outarg.replace ("$arg",    arg);
      outarg.replace ("$name",   proc_name);
    }

    // Free up any memory allocated for the arguments.

    if ((tm = typemap_lookup ("freearg", typemap_lang,
                              p.t, p.name, source, target, &f))) {
      // Yep.  Use it instead of the default
      cleanup << tm << "\n";
      cleanup.replace ("$argnum", argnum);
      cleanup.replace ("$arg",    arg);
      cleanup.replace ("$name",   proc_name);
    }
  }

  // Now write code to make the function call

  f.code << tab4 << "gh_defer_ints();\n";
  emit_func_call (name, d, l, f);
  f.code << tab4 << "gh_allow_ints();\n";

  // Now have return value, figure out what to do with it.

  if ((d->type != T_VOID) || (d->is_pointer)) {
    if ((tm = typemap_lookup ("out", typemap_lang,
                              d, name, "_result", "gswig_result", &f))) {
      // Yep.  Use it instead of the default
      f.code << tm << "\n";
      f.code.replace ("$argnum", argnum);
      f.code.replace ("$arg",    arg);
      f.code.replace ("$name",   proc_name);
    } else {
      if (d->is_pointer) {
        // Is a pointer return type

        f.add_local ("char", "_ptemp[128]");
        f.code << tab4
               << "SWIG_MakePtr (_ptemp, _result,\""
               << d->print_mangle()
               << "\");\n";
        f.code << tab4
               << "gswig_result = gh_str02scm (_ptemp);\n";
      }
    }
  }
  else {
    // Some void type.
    f.code << tab4 << "gswig_result = GH_UNSPECIFIED;\n";
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
      f.code.replace ("$argnum", argnum);
      f.code.replace ("$arg",    arg);
      f.code.replace ("$name",   proc_name);
    }
  }

  // Free any memory allocated by the function being wrapped..

  if ((tm = typemap_lookup ("ret", typemap_lang,
                            d, name, "_result", "", &f))) {
    // Yep.  Use it instead of the default
    f.code << tm << "\n";
    f.code.replace ("$argnum", argnum);
    f.code.replace ("$arg",    arg);
    f.code.replace ("$name",   proc_name);
  }

  // Wrap things up (in a manner of speaking)

  f.code << tab4 << "return gswig_result;\n";
  f.code << "}\n";

  f.print (f_wrappers);

  // Now register the function
  fprintf (f_init, "\t gh_new_procedure(\"%s\", %s, %d, %d, 0);\n",
           proc_name.get(), wname, numargs-numopt, numopt);
}

// -----------------------------------------------------------------------
// GUILE::link_variable(char *name, char *iname, DataType *d)
//
// Create a link to a C variable.
// This creates a single function _wrap_gswig_var_varname().
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
  char  *tm2 = typemap_lookup ("varout", "guile", t, name, name, "scmresult");

  // evaluation function names

  sprintf (var_name, "_wrap_%svar_%s", prefix, iname);

  // Build the name for scheme.
  proc_name = "";
  proc_name << iname;
  proc_name.replace ("_", "-");

  if ((t->type != T_USER) || (t->is_pointer)) {

    fprintf (f_wrappers, "SCM %s(SCM s_0) {\n", var_name);

    if ((t->type == T_CHAR) || (t->is_pointer)){
      fprintf (f_wrappers, "\t char *_temp, _ptemp[128];\n");
      fprintf (f_wrappers, "\t int  _len;\n");
    }
    fprintf (f_wrappers, "\t SCM gswig_result;\n");

    // Check for a setting of the variable value

    fprintf (f_wrappers, "\t if (s_0 != GH_NOT_PASSED) {\n");

    // Yup. Extract the type from s_0 and set variable value
    if (Status & STAT_READONLY) {
      fprintf (f_wrappers, "\t\t GSWIG_ASSERT(0,\"Unable to set %s.  "
               "Variable is read only.\", s_0);\n", iname);
    } else {
      if ((tm = typemap_lookup ("varin", typemap_lang,
                                t, name, "s_0", name))) {
        // Yep.  Use it instead of the default
        fprintf (f_wrappers, "%s\n", tm);
      } else {
        if (!t->is_pointer) {

          switch(t->type) {
            // Signed Integer

          case T_INT:  case T_SINT:
          case T_SHORT: case T_SSHORT:
          case T_LONG: case T_SLONG:
          case T_SCHAR:
            fprintf (f_wrappers, "\t\t %s = %s gh_scm2long(s_0);\n",
                     name, t->print_cast());
            break;

            // Unsigned integer

          case T_UINT:
          case T_USHORT:
          case T_ULONG:
          case T_UCHAR:
            fprintf (f_wrappers, "\t\t %s = %s gh_scm2ulong(s_0);\n",
                     name, t->print_cast());
            break;

            // Floating point

          case T_FLOAT:
          case T_DOUBLE:
            fprintf (f_wrappers, "\t\t %s = %s gh_scm2double(s_0);\n",
                     name, t->print_cast());
            break;

            // Character value

          case T_CHAR:
            fprintf (f_wrappers, "\t\t %s = gh_scm2char(s_0);\n", name);
            break;

            // Unknown value

          default:
            fprintf (stderr, "Line %d.  Error, unsupported data-type.\n",
                     line_number);
            break;
          }
        } else {

          // Have some sort of pointer type here, Process it differently

          if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
            fprintf (f_wrappers, "\t\t _temp = gh_scm2newstr(s_0, &_len);\n");
            fprintf (f_wrappers, "\t\t if (%s) { free(%s);}\n", name, name);
            fprintf (f_wrappers, "\t\t %s = (char *) "
                     "malloc((_len+1)*sizeof(char));\n", name);
            fprintf (f_wrappers, "\t\t strncpy(%s,_temp,_len);\n", name);
            fprintf (f_wrappers, "\t\t %s[_len] = 0;\n", name);
          } else {
            // Set the value of a pointer
            fprintf (f_wrappers, "\t\t _temp = gh_scm2newstr(s_0,&_len);\n");
            fprintf (f_wrappers, "\t if (SWIG_GetPtr(_temp, (void **) &%s,",
                     name);
            if (t->type == T_VOID)
              fprintf (f_wrappers, "(char *) 0)) {\n");
            else
              fprintf (f_wrappers, "\"%s\")) {\n", t->print_mangle());

#ifdef TTN_NEW_CODE
            fprintf (f_wrappers, "\t}\n");
#else /* !TTN_NEW_CODE */

            // Now emit code according to the level of strictness desired

            switch(TypeStrict) {
            case 0: // No type checking
              fprintf(f_wrappers,"\t}\n");
              break;
            case 1: // Warning message only
              fprintf(f_wrappers,
                      "\t fprintf(stderr,\"Warning : type mismatch "
		      "in variable %s. Expected %s, received %%s\\n\", "
		      "_temp);\n", name, t->print_mangle());
              fprintf(f_wrappers,"\t }\n");
              break;
            case 2: // Super strict mode.

	      fprintf(f_wrappers,"\t\t GSWIG_ASSERT(0,\"Type error in "
		      "variable %s. Expected %s.\", s_0);\n",
		      name,t->print_mangle());
              fprintf(f_wrappers,"\t}\n");
              break;

            default :
              fprintf(stderr,"Unknown strictness level\n");
              break;
            }
#endif /* !TTN_NEW_CODE */

          }
        }
      }
    }
    fprintf (f_wrappers, "\t}\n");

    // Now return the value of the variable (regardless
    // of evaluating or setting)

    if ((tm = typemap_lookup ("varout", typemap_lang,
                              t, name, name, "gswig_result"))) {
      // Yep.  Use it instead of the default
      fprintf (f_wrappers, "%s\n", tm);
    } else {
      if (!t->is_pointer) {
        /* Return variable by value */

        switch(t->type) {

          // Signed Integer

        case T_INT: case T_SINT:
        case T_SHORT: case T_SSHORT:
        case T_LONG: case T_SLONG:
        case T_SCHAR:
          fprintf (f_wrappers,
                   "\t gswig_result = gh_long2scm((long) %s);\n",
                   name);
          break;

          // Unsigned integer

        case T_UINT:
        case T_USHORT:
        case T_ULONG:
        case T_UCHAR:
          fprintf (f_wrappers,
                   "\t gswig_result = gh_ulong2scm((unsigned long) %s);\n",
                   name);
          break;

          // Floats

        case T_DOUBLE:
        case T_FLOAT:
          fprintf (f_wrappers,
                   "\t gswig_result = gh_double2scm((double) %s);\n",
                   name);
          break;
        case T_CHAR:
          fprintf (f_wrappers, "\t gswig_result = gh_char2scm(%s);\n", name);
          break;
        default :
          /* Unknown type */
          break;
        }
      } else {

        // Is a pointer return type

        if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
          fprintf (f_wrappers, "\t gswig_result = gh_str02scm(%s);\n", name);
        } else {
          // Is an ordinary pointer type.
          fprintf (f_wrappers, "\t  SWIG_MakePtr(_ptemp, %s,\"%s\");\n",
                   name, t->print_mangle());
          fprintf (f_wrappers, "\t gswig_result = gh_str02scm(_ptemp);\n");
        }
      }
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
