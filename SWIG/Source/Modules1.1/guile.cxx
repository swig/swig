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
#ifndef MACSWIG
#include "swigconfig.h"
#endif
#include <ctype.h>

static char *guile_usage = (char*)"\
Guile Options (available with -guile)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -prefix name    - Use NAME as prefix [default \"gswig_\"]\n\
     -package name   - Set the path of the module [default NULL]\n\
     -linkage lstyle - Use linkage protocol LSTYLE [default `module']\n\
     -procdoc file   - Output procedure documentation to FILE\n\
     -procdocformat format - Output procedure documentation in FORMAT;\n\
                             one of `guile-1.4', `plain', `texinfo'\n\
     -scmstub file   - Output Scheme FILE with module declaration and\n\
                       exports; only with `passive' and `simple' linkage\n\
\n\
  When unspecified, the default LSTYLE is `simple'.  For native Guile\n\
  module linking (for Guile versions >=1.5.0), use `module'.  Other\n\
  LSTYLE values are: `passive' for passive linking (no C-level\n\
  module-handling  code), `ltdlmod' for Guile's old dynamic module\n\
  convention (versions <= 1.4), or `hobbit' for hobbit modules.\n\
\n";

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;

// ---------------------------------------------------------------------
// GUILE ()
// ---------------------------------------------------------------------

GUILE::GUILE ()
{
  // Set global vars

  SWIG_typemap_lang("guile");

  // Set class vars

  prefix = (char*)"gswig_";
  module = NULL;
  package = NULL;
  linkage = GUILE_LSTYLE_SIMPLE;
  procdoc = NULL;
  scmstub = NULL;
  docformat = GUILE_1_4;
  emit_setters = 0;
  struct_member = 0;
  before_return = NULL;
  exported_symbols = NewString("");
  scmtext = NewString("");
  Swig_register_filebyname("scheme", scmtext);
}

// ---------------------------------------------------------------------
// GUILE::main()
//
// Parse arguments.
// ---------------------------------------------------------------------

void
GUILE::main (int argc, char *argv[])
{
  int i, orig_len;

  SWIG_library_directory("guile");

  // Look for certain command line options
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp (argv[i], "-help") == 0) {
	fputs (guile_usage, stderr);
	SWIG_exit (EXIT_SUCCESS);
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
      else if (strcmp (argv[i], "-ldflags") == 0) {
	printf("%s\n", SWIG_GUILE_RUNTIME);
	SWIG_exit (EXIT_SUCCESS);
      }
      else if (strcmp (argv[i], "-Linkage") == 0
	       || strcmp (argv[i], "-linkage") == 0) {
        if (argv[i + 1]) {
          if (0 == strcmp (argv[i + 1], "ltdlmod"))
            linkage = GUILE_LSTYLE_LTDLMOD_1_4;
          else if (0 == strcmp (argv[i + 1], "hobbit"))
            linkage = GUILE_LSTYLE_HOBBIT;
 	  else if (0 == strcmp (argv[i + 1], "simple"))
	    linkage = GUILE_LSTYLE_SIMPLE;
 	  else if (0 == strcmp (argv[i + 1], "passive"))
	    linkage = GUILE_LSTYLE_PASSIVE;
	  else if (0 == strcmp (argv[i + 1], "module"))
	    linkage = GUILE_LSTYLE_MODULE;
          else
            Swig_arg_error ();
          Swig_mark_arg (i);
          Swig_mark_arg (i + 1);
          i++;
        } else {
          Swig_arg_error();
        }
      }
      else if (strcmp (argv[i], "-procdoc") == 0) {
	if (argv[i + 1]) {
	  procdoc = NewFile(argv[i + 1], (char *) "w");
	  Swig_mark_arg (i);
          Swig_mark_arg (i + 1);
	  i++;
	} else {
	  Swig_arg_error();
        }
      }
      else if (strcmp (argv[i], "-procdocformat") == 0) {
	if (strcmp(argv[i+1], "guile-1.4") == 0)
	  docformat = GUILE_1_4;
	else if (strcmp(argv[i+1], "plain") == 0)
	  docformat = PLAIN;
	else if (strcmp(argv[i+1], "texinfo") == 0)
	  docformat = TEXINFO;
	else Swig_arg_error();
	Swig_mark_arg(i);
	Swig_mark_arg(i+1);
	i++;
      }
      else if (strcmp (argv[i], "-emit-setters") == 0) {
	emit_setters = 1;
	Swig_mark_arg (i);
      }
      else if (strcmp (argv[i], "-scmstub") == 0) {
	if (argv[i + 1]) {
	  scmstub = NewFile(argv[i + 1], (char *) "w");
	  Swig_mark_arg (i);
          Swig_mark_arg (i + 1);
	  i++;
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

  /* Add a symbol for this module */
  Preprocessor_define ((void *) "SWIGGUILE",0);

  /* Read in default typemaps */
  SWIG_config_file("guile.i");
}

// --------------------------------------------------------------------
// GUILE::top()
// --------------------------------------------------------------------

void
GUILE::top(Node *n)
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

  Printf(f_runtime, "/* -*- buffer-read-only: t -*- vi: set ro: */\n");
  Swig_banner (f_runtime);

  Printf (f_runtime, "/* Implementation : GUILE */\n\n");

  /* Write out directives and declarations */

  if (NoInclude) {
    Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
  }
  set_module(Char(Getattr(n,"name")));

  if (CPlusPlus) {
    Printf(f_runtime, "extern \"C\" {\n\n");
  }

  switch (linkage) {
  case GUILE_LSTYLE_SIMPLE:
    /* Simple linkage; we have to export the SWIG_init function. The user can
       rename the function by a #define. */
    Printf (f_runtime, "extern void\nSWIG_init (void)\n;\n");
    Printf (f_init, "extern void\nSWIG_init (void)\n{\n");
    break;
  default:
    /* Other linkage; we make the SWIG_init function static */
    Printf (f_runtime, "static void\nSWIG_init (void)\n;\n");
    Printf (f_init, "static void\nSWIG_init (void)\n{\n");
    break;
  }
  Printf (f_init, "\tSWIG_Guile_Init();\n");
  if (CPlusPlus) {
    Printf(f_runtime, "\n}\n");
  }

  Language::top(n);
  
  /* Close module */
  SwigType_emit_type_table (f_runtime, f_wrappers);

  Printf (f_init, "SWIG_Guile_RegisterTypes(swig_types, swig_types_initial);\n");
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
  
  if (procdoc) {
    Delete(procdoc);
    procdoc = NULL;
  }
  if (scmstub) {
    Delete(scmstub);
    scmstub = NULL;
  }

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
// GUILE::set_module(char *mod_name)
//
// Sets the module name.
// Does nothing if it's already set (so it can be overridden as a command
// line option).
//
//----------------------------------------------------------------------

void
GUILE::set_module (char *mod_name)
{
  if (module) return;

  module = new char [strlen (mod_name) + 1];
  strcpy (module, mod_name);
}

void
GUILE::emit_linkage (char *module_name)
{
  DOHString *module_func = NewString("");

  if (CPlusPlus) {
    Printf(f_init, "extern \"C\" {\n\n");
  }

  Printv(module_func,module_name,0);
  Replace(module_func,"-", "_", DOH_REPLACE_ANY);

  switch (linkage) {
  case GUILE_LSTYLE_SIMPLE:
    Printf (f_init, "\n/* Linkage: simple */\n");
    break;
  case GUILE_LSTYLE_PASSIVE:
    Printf (f_init, "\n/* Linkage: passive */\n");
    Replace(module_func,"/", "_", DOH_REPLACE_ANY);
    Insert(module_func,0, "scm_init_");
    Append(module_func,"_module");

    Printf (f_init, "SCM\n%s (void)\n{\n", module_func);
    Printf (f_init, "  SWIG_init();\n");
    Printf (f_init, "  return SCM_UNSPECIFIED;\n");
    Printf (f_init, "}\n");
    break;
  case GUILE_LSTYLE_LTDLMOD_1_4:
    Printf (f_init, "\n/* Linkage: ltdlmod */\n");
    Replace(module_func,"/", "_", DOH_REPLACE_ANY);
    Insert(module_func,0, "scm_init_");
    Append(module_func,"_module");
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
  case GUILE_LSTYLE_MODULE:
    Printf (f_init, "\n/* Linkage: module */\n");
    Replace(module_func,"/", "_", DOH_REPLACE_ANY);
    Insert(module_func,0, "scm_init_");
    Append(module_func,"_module");

    Printf (f_init, "static void SWIG_init_helper(void *data)\n");
    Printf (f_init, "{\n    SWIG_init();\n");
    if (Len(exported_symbols) > 0)
      Printf (f_init, "    scm_c_export(%sNULL);",
	      exported_symbols);
    Printf (f_init, "\n}\n\n");
    
    Printf (f_init, "SCM\n%s (void)\n{\n", module_func);
    {
      DOHString *mod = NewString(module_name);
      Replace(mod,"/", " ", DOH_REPLACE_ANY);
      Printf(f_init, "    SCM module = scm_c_define_module(\"%s\",\n", mod);
      Printf(f_init, "      SWIG_init_helper, NULL);\n");
      Printf(f_init, "    return SCM_UNSPECIFIED;\n");
      Delete(mod);
    }
    Printf (f_init, "}\n");
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

  if (scmstub) {
    /* Emit Scheme stub if requested */
    DOHString *mod = NewString(module_name);
    Replace(mod, "/", " ", DOH_REPLACE_ANY);
    Printf (scmstub, ";;; -*- buffer-read-only: t -*- vi: set ro: */\n");
    Printf (scmstub, ";;; Automatically generated by SWIG; do not edit.\n\n");
    if (linkage == GUILE_LSTYLE_SIMPLE
	|| linkage == GUILE_LSTYLE_PASSIVE)
      Printf (scmstub, "(define-module (%s))\n\n", mod);
    Delete(mod);
    Printf (scmstub, "%s", scmtext);
    if ((linkage == GUILE_LSTYLE_SIMPLE
	|| linkage == GUILE_LSTYLE_PASSIVE)
	&& Len(exported_symbols) > 0) {
      DOHString *ex = NewString(exported_symbols);
      Replace(ex, ", ", "\n        ", DOH_REPLACE_ANY);
      Replace(ex, "\"", "", DOH_REPLACE_ANY);
      Chop(ex);
      Printf(scmstub, "\n(export %s)\n", ex);
      Delete(ex);
    }
  }
  
  Delete(module_func);
  if (CPlusPlus) {
    Printf(f_init, "\n}\n");
  }
}

/* Return true iff T is a pointer type */

static int
is_a_pointer (SwigType *t)
{
  return SwigType_ispointer(SwigType_typedef_resolve_all(t));
}

/* Lookup a typemap, replace all relevant parameters and write it to
   the given generalized file. Return 0 if no typemap found. */

static int
guile_do_typemap(DOHFile *file, const char *op,
		 SwigType *type, const String_or_char *arg, const String_or_char *lname,
		 String_or_char *source, String_or_char *target,
		 int argnum, DOHString *name, Wrapper *f,
		 int nonewline_p)
{
  String *tm;
  if ((tm = Swig_typemap_lookup(op, type, (char *)arg, (char *)lname,
				 source, target, f))) {
    String *s = tm;
    char argnum_s[10];
    sprintf(argnum_s, "%d", argnum);
    Replace(s,"$argnum", argnum_s, DOH_REPLACE_ANY);
    Replace(s,"$arg",    arg,      DOH_REPLACE_ANY);
    Replace(s,"$name",   name,     DOH_REPLACE_ANY);
    if (nonewline_p)
      Printv(file, s, 0);
    else Printv(file, s, "\n", 0);
    Delete(s);
    return 1;
  }
  else return 0;
}

/* Lookup a documentation typemap, replace all relevant parameters and
   write it to the given generalized file, providing a sensible
   default value. */

static void
guile_do_doc_typemap(DOHFile *file, const char *op,
		     SwigType *type, const String_or_char *arg, const String_or_char *lname,
		     int argnum, DOHString *name, Wrapper *f)
{
  if (!guile_do_typemap(file, op, type, arg, lname,
			NULL, NULL, argnum, name, f, 1)) {
    /* FIXME: Can't we provide this default via a typemap as well? */
    String *s = NewString(SwigType_str(type, 0));
    Chop(s);
    if (arg) Printf(file, "(%s <%s>)", arg, s);
    else Printf(file, "<%s>", s);
    Delete(s);
  }
}

/* Report an error handling the given type. */

static void
throw_unhandled_guile_type_error (SwigType *d)
{
  Printf (stderr, "%s : Line %d. Unable to handle type %s.\n",input_file, line_number, SwigType_str(d,0));
  error_count++;
}


/* Write out procedure documentation */

void
GUILE::write_doc(const String *proc_name,
		 const String *signature,
		 const String *doc)
{
  switch (docformat) {
  case GUILE_1_4:
    Printv(procdoc, "\f\n", 0);
    Printv(procdoc, "(", signature, ")\n", 0);
    Printv(procdoc, doc, "\n", 0);
    break;
  case PLAIN:
    Printv(procdoc, "\f", proc_name, "\n\n", 0);
    Printv(procdoc, "(", signature, ")\n", 0);
    Printv(procdoc, doc, "\n\n", 0);
    break;
  case TEXINFO:
    Printv(procdoc, "\f", proc_name, "\n", 0);
    Printv(procdoc, "@deffn primitive ", signature, "\n", 0);
    Printv(procdoc, doc, "\n", 0);
    Printv(procdoc, "@end deffn\n\n", 0);
    break;
  }
}


// ----------------------------------------------------------------------
// GUILE::create_function(char *name, char *iname, SwigType *d,
//                             ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

void
GUILE::create_function (char *name, char *iname, SwigType *d, ParmList *l)
{
  Parm *p;
  DOHString *proc_name = 0;
  char source[256], target[256], wname[256];
  Wrapper *f = NewWrapper();;
  String *cleanup = NewString("");
  String *outarg = NewString("");
  String *signature = NewString("");
  String *returns = NewString("");
  int returns_list = 0;
  String *tmp = NewString("");
  String *tm;
  int i;
  int numargs = 0;
  int numreq = 0;

  // Make a wrapper name for this
  {
    String *n = Swig_name_mangle(iname);
    strcpy(wname, Char(Swig_name_wrapper(n)));
  }
  // Build the name for scheme.
  proc_name = NewString(iname);
  Replace(proc_name,"_", "-", DOH_REPLACE_ANY);

  /* Emit locals etc. into f->code; figure out which args to ignore */
  emit_args (d, l, f);

  /* Attach the standard typemaps */
  emit_attach_parmmaps(l,f);

  /* Get number of required and total arguments */
  numargs = emit_num_arguments(l);
  numreq  = emit_num_required(l);

  /* Declare return variable */

  Wrapper_add_local (f,"gswig_result", "SCM gswig_result");
  Wrapper_add_local (f,"gswig_list_p", "int gswig_list_p = 0");

  if (procdoc)
    guile_do_doc_typemap(returns, "outdoc", d, "", NULL,
			 0, proc_name, f);

  /* Open prototype and signature */

  Printv(f->def, "static SCM\n", wname," (", 0);
  Printv(signature, proc_name, 0);

  /* Now write code to extract the parameters */

  for (i = 0, p = l; i < numargs; i++) {
    while (Getattr(p,"tmap:ignore")) {
      p = Getattr(p,"tmap:ignore:next");
    }

    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");
    String   *ln = Getattr(p,"lname");
    int opt_p = (i >= numreq);

    // Produce names of source and target
    sprintf(source,"s_%d",i);
    sprintf(target,"%s", Char(ln));

    if (i!=0) Printf(f->def,", ");
    Printf(f->def,"SCM s_%d", i);
    if (opt_p) {
      Printf(f->code,"    if (s_%d != GH_NOT_PASSED) {\n", i);
    }
    if ((tm = Getattr(p,"tmap:in"))) {
      Replace(tm,"$source",source,DOH_REPLACE_ANY); /* Deprecated */
      Replace(tm,"$target",target,DOH_REPLACE_ANY); /* Deprecated */
      Replace(tm,"$input",source,DOH_REPLACE_ANY);
      Setattr(p,"emit:input", source);
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:in:next");
    } else {
      throw_unhandled_guile_type_error (pt);
      p = nextSibling(p);
    }

    /* DB: need to fix this part to work with multi-arg maps */
    if (procdoc) {
      /* Add to signature */
      Printf(signature, " ");
      guile_do_doc_typemap(signature, "indoc", pt, pn, ln,
			   numargs, proc_name, f);
    }
    if (opt_p)
      Printf(f->code,"    }\n");
  }

  /* Insert constraint checking code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:check"))) {
      Replace(tm,"$target",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
  /* Pass output arguments back to the caller. */

  /* Insert argument output code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:argout"))) {
      Replace(tm,"$source",Getattr(p,"lname"),DOH_REPLACE_ANY);   /* Deprecated */
      Replace(tm,"$target",Getattr(p,"lname"),DOH_REPLACE_ANY);   /* Deprecated */
      Replace(tm,"$arg",Getattr(p,"emit:input"), DOH_REPLACE_ANY);
      Replace(tm,"$input",Getattr(p,"emit:input"), DOH_REPLACE_ANY);
      Printv(outarg,tm,"\n",0);
      p = Getattr(p,"tmap:argout:next");
    } else {
      p = nextSibling(p);
    }
  }
#ifdef BROKEN
  if (procdoc) {
    /* Document output arguments */
    Clear(tmp);
    if (guile_do_typemap(tmp, "argoutdoc", pt, pn, ln,
			 source, target, numargs, proc_name, f, 1)) {
      if (Len(returns) == 0) { /* unspecified -> singleton */
	Printv(returns, tmp, 0);
      }
      else { /* append to list */
	Printv(returns, " ", tmp, 0);
	returns_list = 1;
      }
    }
  }
#endif

  /* Insert cleanup code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:freearg"))) {
      Replace(tm,"$target",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Printv(cleanup,tm,"\n",0);
      p = Getattr(p,"tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Close prototype */

  Printf(f->def, ")\n{\n");

  /* Define the scheme name in C. This define is used by several Guile
     macros. */
  Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", 0);

  // Now write code to make the function call
  Printv(f->code, tab4, "gh_defer_ints();\n", 0);
  emit_func_call (name, d, l, f);
  Printv(f->code, tab4, "gh_allow_ints();\n", 0);

  // Now have return value, figure out what to do with it.

  if (guile_do_typemap(f->code, "out", d, name, (char*)"result",
		       (char*)"result", (char*)"gswig_result",
		       0, proc_name, f, 0)) {
    /* nothing */
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
    guile_do_typemap(f->code, "newfree", d, iname, (char*)"result",
		     (char*)"result", (char*)"", 0, proc_name, f, 0);
  }

  // Free any memory allocated by the function being wrapped..

  guile_do_typemap(f->code, "ret", d, name, (char*)"result",
		   (char*)"result", (char*)"", 0, proc_name, f, 0);

  // Wrap things up (in a manner of speaking)

  if (before_return)
    Printv(f->code, before_return, "\n", 0);
  Printv(f->code, "return gswig_result;\n", 0);

  // Undefine the scheme name

  Printf(f->code, "#undef FUNC_NAME\n");
  Printf(f->code, "}\n");

  Wrapper_print (f, f_wrappers);

  if (numargs > 10) {
    int i;
    /* gh_new_procedure would complain: too many args */
    /* Build a wrapper wrapper */
    Printv(f_wrappers, "static SCM\n", wname,"_rest (SCM rest)\n", 0);
    Printv(f_wrappers, "{\n", 0);
    Printf(f_wrappers, "SCM arg[%d];\n", numargs);
    Printf(f_wrappers, "SWIG_Guile_GetArgs (arg, rest, %d, %d, \"%s\");\n",
	   numreq, numargs-numreq, proc_name);
    Printv(f_wrappers, "return ", wname, "(", 0);
    Printv(f_wrappers, "arg[0]", 0);
    for (i = 1; i<numargs; i++)
      Printf(f_wrappers, ", arg[%d]", i);
    Printv(f_wrappers, ");\n", 0);
    Printv(f_wrappers, "}\n", 0);
    /* Register it */
    Printf (f_init, "gh_new_procedure(\"%s\", (swig_guile_proc) %s_rest, 0, 0, 1);\n",
             proc_name, wname, numreq, numargs-numreq);
  }
  else if (emit_setters && struct_member && strlen(Char(proc_name))>3) {
    int len = Len(proc_name);
    const char *pc = Char(proc_name);
    /* MEMBER-set and MEMBER-get functions. */
    int is_setter = (pc[len - 3] == 's');
    if (is_setter) {
      Printf(f_init, "SCM setter = ");
      struct_member = 2; /* have a setter */
    }
    else Printf(f_init, "SCM getter = ");
    Printf (f_init, "gh_new_procedure(\"%s\", (swig_guile_proc) %s, %d, %d, 0);\n",
	    proc_name, wname, numreq, numargs-numreq);
    if (!is_setter) {
      /* Strip off "-get" */
      char *pws_name = (char*) malloc(sizeof(char) * (len - 3));
      strncpy(pws_name, pc, len - 3);
      pws_name[len - 4] = 0;
      if (struct_member==2) { 
	/* There was a setter, so create a procedure with setter */
	Printf (f_init, "gh_define(\"%s\", "
		"scm_make_procedure_with_setter(getter, setter));\n",
		pws_name);
      }
      else {
	/* There was no setter, so make an alias to the getter */
	Printf (f_init, "gh_define(\"%s\", getter);\n",
		pws_name);
      }
      Printf (exported_symbols, "\"%s\", ", pws_name);
      free(pws_name);
    }
  }
  else {
    /* Register the function */
    Printf (f_init, "gh_new_procedure(\"%s\", (swig_guile_proc) %s, %d, %d, 0);\n",
	    proc_name, wname, numreq, numargs-numreq);
  }
  Printf (exported_symbols, "\"%s\", ", proc_name);
  if (procdoc) {
    String *returns_text = NewString("");
    Printv(returns_text, "Returns ", 0);
    if (Len(returns)==0) Printv(returns_text, "unspecified", 0);
    else if (returns_list) Printv(returns_text, "list (", returns, ")", 0);
    else Printv(returns_text, returns, 0);
    write_doc(proc_name, signature, returns_text);
    Delete(returns_text);
  }

  Delete(proc_name);
  Delete(outarg);
  Delete(cleanup);
  Delete(signature);
  Delete(returns);
  Delete(tmp);
  DelWrapper(f);
}

// -----------------------------------------------------------------------
// GUILE::link_variable(char *name, char *iname, SwigType *d)
//
// Create a link to a C variable.
// This creates a single function PREFIX_var_VARNAME().
// This function takes a single optional argument.   If supplied, it means
// we are setting this variable to some value.  If omitted, it means we are
// simply evaluating this variable.  Either way, we return the variables
// value.
// -----------------------------------------------------------------------

void
GUILE::link_variable (char *name, char *iname, SwigType *t)
{
  DOHString *proc_name;
  char  var_name[256];
  char  *tm;
  Wrapper *f;

  f = NewWrapper();
  // evaluation function names

  strcpy(var_name, Char(Swig_name_wrapper(name))); 

  // Build the name for scheme.
  proc_name = NewString(iname);
  Replace(proc_name,"_", "-",DOH_REPLACE_ANY);

  if ((SwigType_type(t) != T_USER) || (is_a_pointer(t))) {

    Printf (f->def, "static SCM\n%s(SCM s_0)\n{\n", var_name);

    /* Define the scheme name in C. This define is used by several Guile
       macros. */
    Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", 0);

    Wrapper_add_local (f, "gswig_result", "SCM gswig_result");

    if (!ReadOnly) {
      /* Check for a setting of the variable value */
      Printf (f->code, "if (s_0 != GH_NOT_PASSED) {\n");
      if (guile_do_typemap(f->code, "varin",
			   t, name, name, (char*) "s_0", name, 1, name, f, 0)) {
	/* nothing */
      }
      else {
	throw_unhandled_guile_type_error (t);
      }
      Printf (f->code, "}\n");
    }

    // Now return the value of the variable (regardless
    // of evaluating or setting)

    if (guile_do_typemap (f->code, "varout",
			  t, name, name, name, (char*)"gswig_result",
			  0, name, f, 1)) {
      /* nothing */
    }
    else {
      throw_unhandled_guile_type_error (t);
    }
    Printf (f->code, "\nreturn gswig_result;\n");
    Printf (f->code, "#undef FUNC_NAME\n");
    Printf (f->code, "}\n");

    Wrapper_print (f, f_wrappers);

    // Now add symbol to the Guile interpreter

    if (!emit_setters
	|| ReadOnly) {
      /* Read-only variables become a simple procedure returning the
	 value; read-write variables become a simple procedure with
	 an optional argument. */
      Printf (f_init, "\t gh_new_procedure(\"%s\", (swig_guile_proc) %s, 0, %d, 0);\n",
	      proc_name, var_name, ReadOnly ? 0 : 1);
    }
    else {
      /* Read/write variables become a procedure with setter. */
      Printf (f_init, "\t{ SCM p = gh_new_procedure(\"%s\", (swig_guile_proc) %s, 0, 1, 0);\n",
	      proc_name, var_name);
      Printf (f_init, "\t  gh_define(\"%s\", "
	      "scm_make_procedure_with_setter(p, p)); }\n",
	      proc_name);
    }
    Printf (exported_symbols, "\"%s\", ", proc_name);

    if (procdoc) {
      /* Compute documentation */
      String *signature = NewString("");
      String *doc = NewString("");

      if (ReadOnly) {
	Printv(signature, proc_name, 0);
	Printv(doc, "Returns constant ", 0);
	guile_do_doc_typemap(doc, "varoutdoc", t, NULL, "",
			     0, proc_name, f);
      }
      else {
	Printv(signature, proc_name,
	       " #:optional ", 0);
	guile_do_doc_typemap(signature, "varindoc", t, "new-value", "",
			     1, proc_name, f);
	Printv(doc, "If NEW-VALUE is provided, "
	       "set C variable to this value.\n", 0);
	Printv(doc, "Returns variable value ", 0);
	guile_do_doc_typemap(doc, "varoutdoc", t, NULL, "",
			     0, proc_name, f);
      }
      write_doc(proc_name, signature, doc);
      Delete(signature);
      Delete(doc);
    }

  } else {
    Printf (stderr, "%s : Line %d. ** Warning. Unable to link with "
             " type %s (ignored).\n",
             input_file, line_number, SwigType_str(t,0));
  }
  Delete(proc_name);
  DelWrapper(f);
}

// -----------------------------------------------------------------------
// GUILE::declare_const(char *name, char *iname, SwigType *type, char *value)
//
// We create a read-only variable.
// ------------------------------------------------------------------------

void
GUILE::declare_const (char *name, char *iname, SwigType *type, char *value)
{
  int OldReadOnly = ReadOnly;
  DOHString *proc_name;
  char   var_name[256];
  DOHString *rvalue;
  char   *tm;
  Wrapper *f;
  SwigType *nctype;

  f = NewWrapper();
  ReadOnly = 1;     // Enable readonly mode.

  // Make a static variable;

  sprintf (var_name, "%sconst_%s", prefix, name);

  // Strip const qualifier from type if present

  nctype = NewString(type);
  if (SwigType_isconst(nctype)) {
    Delete(SwigType_pop(nctype));
  }
  
  // Build the name for scheme.
  proc_name = NewString(iname);
  Replace(proc_name,"_", "-", DOH_REPLACE_ANY);

  if ((SwigType_type(nctype) == T_USER) && (!is_a_pointer(nctype))) {
    Printf (stderr, "%s : Line %d.  Unsupported constant value.\n",
             input_file, line_number);
    return;
  }

  // See if there's a typemap

  if (SwigType_type(nctype) == T_STRING) {
    rvalue = NewStringf("\"%s\"", value);
  } else if (SwigType_type(nctype) == T_CHAR) {
    rvalue = NewStringf("\'%s\'", value);
  } else {
    rvalue = NewString(value);
  }
  if (guile_do_typemap(f_header, "const", nctype, name, name,
		       Char(rvalue), name, 0, name, f, 0)) {
    /* nothing */
  } else {
    // Create variable and assign it a value
    Printf (f_header, "static %s %s = %s;\n", SwigType_lstr(nctype,0),
	    var_name, rvalue);
  }
  // Now create a variable declaration
  link_variable (var_name, iname, nctype);
  ReadOnly = OldReadOnly;
  Delete(nctype);
  Delete(proc_name);
  Delete(rvalue);
  DelWrapper(f);
}

void GUILE::cpp_variable(char *name, char *iname, SwigType *t)
{
  if (emit_setters) {
    struct_member = 1;
    Printf(f_init, "{\n");
    Language::cpp_variable(name, iname, t);
    Printf(f_init, "}\n");
    struct_member = 0;
  }
  else {
    /* Only emit traditional VAR-get and VAR-set procedures */
    Language::cpp_variable(name, iname, t);
  }
}

void GUILE::pragma(char *lang, char *cmd, char *value)
{
  if (strcmp(lang,(char*)"guile") == 0) {
    if (strcmp(cmd, (char*)"beforereturn")==0) {
      if (before_return)
	Delete(before_return);
      before_return = value ? NewString(value) : NULL;
    }
  }
}

void
GUILE::import_start(char *modname) {
}

void 
GUILE::import_end() {
}


int GUILE::validIdentifier(String *s) {
  char *c = Char(s);
  while (*c) {
    if (!(isalnum(*c) || (*c == '_') || (*c == '-'))) return 0;
    c++;
  }
  return 1;
}
