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

char cvsroot_guile_cxx[] = "$Header$";

/***********************************************************************
 * $Header$
 *
 * guile.cxx
 *
 * Definitions for adding functions to Guile
 ***********************************************************************/

#include "swigmod.h"

#ifndef MACSWIG
#include "swigconfig.h"
#endif
#include <ctype.h>

static const char *guile_usage = (char*)"\
Guile Options (available with -guile)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -prefix name    - Use NAME as prefix [default \"gswig_\"]\n\
     -package name   - Set the path of the module [default NULL]\n\
     -emit-setters   - Emit procedures-with-setters for variables\n\
                       and structure slots.\n\
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


static char   *prefix = (char *) "gswig_";
static char   *module = 0;
static char   *package = 0;
static enum {
  GUILE_LSTYLE_SIMPLE,                // call `SWIG_init()'
  GUILE_LSTYLE_PASSIVE,               // passive linking (no module code)
  GUILE_LSTYLE_MODULE,                // native guile module linking (Guile >= 1.4.1)
  GUILE_LSTYLE_LTDLMOD_1_4,		// old (Guile <= 1.4) dynamic module convention
  GUILE_LSTYLE_HOBBIT                 // use (hobbit4d link)
} linkage = GUILE_LSTYLE_SIMPLE;

static File  *procdoc = 0;
static File  *scmstub = 0;
static String *scmtext;

static enum {
  GUILE_1_4,
  PLAIN,
  TEXINFO
} docformat = GUILE_1_4;

static int	 emit_setters = 0;
static int    struct_member = 0;

static String *beforereturn = 0;
static String *return_nothing_doc = 0;
static String *return_one_doc = 0;
static String *return_multi_doc = 0;

static String *exported_symbols = 0;

class GUILE : public Language {
public:

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main (int argc, char *argv[]) {
    int i, orig_len;

    SWIG_library_directory("guile");
    SWIG_typemap_lang("guile");

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
    Preprocessor_define ("SWIGGUILE 1",0);
    /* Read in default typemaps */
    SWIG_config_file("guile.i");
    allow_overloading();
    
  }

  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */

  virtual int top(Node *n)  {
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
    
    scmtext = NewString("");
    Swig_register_filebyname("scheme", scmtext);
    exported_symbols = NewString("");
    
    Printf(f_runtime, "/* -*- buffer-read-only: t -*- vi: set ro: */\n");
    Swig_banner (f_runtime);
    
    Printf (f_runtime, "/* Implementation : GUILE */\n\n");
    
    /* Write out directives and declarations */
    
    if (NoInclude) {
      Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
    }
    
    module = Swig_copy_string(Char(Getattr(n,"name")));
    
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
    
    Printf(f_wrappers,"#ifdef __cplusplus\nextern \"C\" {\n#endif\n");
    
    SwigType_emit_type_table (f_runtime, f_wrappers);
    
    Printf(f_wrappers,"#ifdef __cplusplus\n}\n#endif\n");
    
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
    return SWIG_OK;
  }
  
  void emit_linkage (char *module_name) {
    String *module_func = NewString("");
    
    if (CPlusPlus) {
      Printf(f_init, "extern \"C\" {\n\n");
    }
    
    Printv(module_func,module_name,NIL);
    Replaceall(module_func,"-", "_");
    
    switch (linkage) {
    case GUILE_LSTYLE_SIMPLE:
      Printf (f_init, "\n/* Linkage: simple */\n");
      break;
    case GUILE_LSTYLE_PASSIVE:
      Printf (f_init, "\n/* Linkage: passive */\n");
      Replaceall(module_func,"/", "_");
      Insert(module_func,0, "scm_init_");
      Append(module_func,"_module");
      
      Printf (f_init, "SCM\n%s (void)\n{\n", module_func);
      Printf (f_init, "  SWIG_init();\n");
      Printf (f_init, "  return SCM_UNSPECIFIED;\n");
      Printf (f_init, "}\n");
      break;
    case GUILE_LSTYLE_LTDLMOD_1_4:
      Printf (f_init, "\n/* Linkage: ltdlmod */\n");
      Replaceall(module_func,"/", "_");
      Insert(module_func,0, "scm_init_");
      Append(module_func,"_module");
      Printf (f_init, "SCM\n%s (void)\n{\n", module_func);
      {
	String *mod = NewString(module_name);
	Replaceall(mod,"/", " ");
	Printf (f_init, "    scm_register_module_xxx (\"%s\", (void *) SWIG_init);\n",
		mod);
	Printf (f_init, "    return SCM_UNSPECIFIED;\n");
	Delete(mod);
      }
      Printf (f_init, "}\n");
      break;
    case GUILE_LSTYLE_MODULE:
      Printf (f_init, "\n/* Linkage: module */\n");
      Replaceall(module_func,"/", "_");
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
	String *mod = NewString(module_name);
	Replaceall(mod,"/", " ");
	Printf(f_init, "    SCM module = scm_c_define_module(\"%s\",\n", mod);
	Printf(f_init, "      SWIG_init_helper, NULL);\n");
	Printf(f_init, "    return SCM_UNSPECIFIED;\n");
	Delete(mod);
      }
      Printf (f_init, "}\n");
      break;
    case GUILE_LSTYLE_HOBBIT:
      Printf (f_init, "\n/* Linkage: hobbit */\n");
      Replaceall(module_func,"/", "_slash_");
      Insert(module_func,0, "scm_init_");
      Printf (f_init, "SCM\n%s (void)\n{\n", module_func);
      {
	String *mod = NewString(module_name);
	Replaceall(mod,"/", " ");
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
      String *mod = NewString(module_name);
      Replaceall(mod, "/", " ");
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
	String *ex = NewString(exported_symbols);
	Replaceall(ex, ", ", "\n        ");
	Replaceall(ex, "\"", "");
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

  int is_a_pointer (SwigType *t) {
    return SwigType_ispointer(SwigType_typedef_resolve_all(t));
  }

  /* Report an error handling the given type. */

  void throw_unhandled_guile_type_error (SwigType *d) {
    Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		 "Unable to handle type %s.\n", SwigType_str(d,0));
  }
  
  /* Write out procedure documentation */

  void write_doc(const String *proc_name,
		 const String *signature,
		 const String *doc,
		 const String *signature2 = NULL)  {
    switch (docformat) {
    case GUILE_1_4:
      Printv(procdoc, "\f\n", NIL);
      Printv(procdoc, "(", signature, ")\n", NIL);
      if (signature2)
	Printv(procdoc, "(", signature2, ")\n", NIL);
      Printv(procdoc, doc, "\n", NIL);
      break;
    case PLAIN:
      Printv(procdoc, "\f", proc_name, "\n\n", NIL);
      Printv(procdoc, "(", signature, ")\n", NIL);
      if (signature2)
	Printv(procdoc, "(", signature2, ")\n", NIL);
      Printv(procdoc, doc, "\n\n", NIL);
      break;
    case TEXINFO:
      Printv(procdoc, "\f", proc_name, "\n", NIL);
      Printv(procdoc, "@deffn primitive ", signature, "\n", NIL);
      if (signature2)
	Printv(procdoc, "@deffnx primitive ", signature2, "\n", NIL);
      Printv(procdoc, doc, "\n", NIL);
      Printv(procdoc, "@end deffn\n\n", NIL);
      break;
    }
  }

  /* returns false if the typemap is an empty string */
  bool handle_documentation_typemap(String *output,
				    const String *maybe_delimiter,
				    Parm *p,
				    const String *typemap,
				    const String *default_doc)
  {
    String *tmp = NewString("");
    String *tm;
    if (!(tm = Getattr(p, typemap))) {
      Printf(tmp, "%s", default_doc);
      tm = tmp;
    }
    bool result = (Len(tm) > 0);
    if (maybe_delimiter && Len(output) > 0 && Len(tm) > 0) {
      Printv(output, maybe_delimiter, NIL);
    }
    String *pn = Getattr(p,"name");
    String *pt = Getattr(p,"type");
    Replaceall(tm, "$name", pn); // legacy for $parmname
    Replaceall(tm, "$type", SwigType_str(pt,0));
    /* $NAME is like $name, but marked-up as a variable. */
    String *ARGNAME = NewString("");
    if (docformat == TEXINFO)
      Printf(ARGNAME, "@var{%s}", pn);
    else Printf(ARGNAME, "%(upper)s", pn);
    Replaceall(tm, "$NAME", ARGNAME);
    Replaceall(tm, "$PARMNAME", ARGNAME);
    Printv(output,tm,NIL);
    Delete(tmp);
    return result;
  } 
    
  /* ------------------------------------------------------------
   * functionWrapper()
   * Create a function declaration and register it with the interpreter.
   * ------------------------------------------------------------ */

  virtual int functionWrapper(Node *n) {
    String *iname = Getattr(n,"sym:name");
    SwigType *d = Getattr(n,"type");
    ParmList *l = Getattr(n,"parms");
    Parm *p;
    String *proc_name = 0;
    char source[256], target[256];
    Wrapper *f = NewWrapper();;
    String *cleanup = NewString("");
    String *outarg = NewString("");
    String *signature = NewString("");
    String *doc_body = NewString("");
    String *returns = NewString("");
    int num_results = 1;
    String *tmp = NewString("");
    String *tm;
    int i;
    int numargs = 0;
    int numreq = 0;
    String *overname = 0;
    int args_passed_as_array = 0;
    
    // Make a wrapper name for this
    String *wname = Swig_name_wrapper(iname);
    if (Getattr(n,"sym:overloaded")) {
      overname = Getattr(n,"sym:overname");
      args_passed_as_array = 1;
    } else {
      if (!addSymbol(iname,n)) return SWIG_ERROR;
    }
    if (overname) {
      Append(wname, overname);
    }
    Setattr(n,"wrap:name",wname);
    
    // Build the name for scheme.
    proc_name = NewString(iname);
    Replaceall(proc_name,"_", "-");
    
    /* Emit locals etc. into f->code; figure out which args to ignore */
    emit_args (d, l, f);
    
    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);
    Setattr(n,"wrap:parms",l);
    
    /* Get number of required and total arguments */
    numargs = emit_num_arguments(l);
    numreq  = emit_num_required(l);
    
    /* Declare return variable */
    
    Wrapper_add_local (f,"gswig_result", "SCM gswig_result");
    Wrapper_add_local (f,"gswig_list_p", "int gswig_list_p = 0");
    
    /* Get the output typemap so we can start generating documentation.  Don't
       worry, the returned string is saved as 'tmap:out' */
    
    Swig_typemap_lookup_new("out",n,"result",0);
    
    if ((tm = Getattr(n,"tmap:out:doc"))) {
      Printv(returns,tm,NIL);
      if (Len(tm) > 0) num_results = 1;
      else num_results = 0;
    } else {
      String *s = SwigType_str(d,0);
      Chop(s);
      Printf(returns,"<%s>",s);
      Delete(s);
      num_results = 1;
    }
    
    /* Open prototype and signature */
    
    Printv(f->def, "static SCM\n", wname," (", NIL);
    if (args_passed_as_array) {
      Printv(f->def, "int argc, SCM *argv", NIL);
    }
    Printv(signature, proc_name, NIL);
    
    /* Now write code to extract the parameters */
    
    for (i = 0, p = l; i < numargs; i++) {

      while (checkAttribute(p,"tmap:in:numinputs","0")) {
	p = Getattr(p,"tmap:in:next");
      }
      
      SwigType *pt = Getattr(p,"type");
      String   *ln = Getattr(p,"lname");
      int opt_p = (i >= numreq);
      
      // Produce names of source and target
      if (args_passed_as_array)
	sprintf(source, "argv[%d]", i);
      else
	sprintf(source,"s_%d",i);
      sprintf(target,"%s", Char(ln));
      
      if (!args_passed_as_array) {
	if (i!=0) Printf(f->def,", ");
	Printf(f->def,"SCM s_%d", i);
      }
      if (opt_p) {
	Printf(f->code,"    if (%s != GH_NOT_PASSED) {\n", source);
      }
      if ((tm = Getattr(p,"tmap:in"))) {
	Replaceall(tm,"$source",source);
	Replaceall(tm,"$target",target);
	Replaceall(tm,"$input",source);
	Setattr(p,"emit:input", source);
	Printv(f->code,tm,"\n",NIL);
	
	if (procdoc) {
	  /* Add to signature (arglist) */
	  handle_documentation_typemap(signature, " ", p, "tmap:in:arglist",
				       "$name");
	  /* Document the type of the arg in the documentation body */
	  handle_documentation_typemap(doc_body, ", ", p, "tmap:in:doc",
				       "$NAME is of type <$type>");
	}
	p = Getattr(p,"tmap:in:next");
      } else {
	throw_unhandled_guile_type_error (pt);
	p = nextSibling(p);
      }
      if (opt_p)
	Printf(f->code,"    }\n");
    }
    if (Len(doc_body) > 0)
      Printf(doc_body, ".\n");
    
    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
	Replaceall(tm,"$target",Getattr(p,"lname"));
	Printv(f->code,tm,"\n",NIL);
	p = Getattr(p,"tmap:check:next");
      } else {
	p = nextSibling(p);
      }
    }
    /* Pass output arguments back to the caller. */
    
    /* Insert argument output code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:argout"))) {
	Replaceall(tm,"$source",Getattr(p,"lname"));
	Replaceall(tm,"$target",Getattr(p,"lname"));
	Replaceall(tm,"$arg",Getattr(p,"emit:input"));
	Replaceall(tm,"$input",Getattr(p,"emit:input"));
	Printv(outarg,tm,"\n",NIL);
	if (procdoc) {
	  if (handle_documentation_typemap(returns, ", ",
					   p, "tmap:argout:doc",
					   "$NAME (of type $type)")) {
	    /* A documentation typemap that is not the empty string
	       indicates that a value is returned to Scheme. */
	    num_results++;
	  }
	}
	p = Getattr(p,"tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }
    
    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:freearg"))) {
	Replaceall(tm,"$target",Getattr(p,"lname"));
	Printv(cleanup,tm,"\n",NIL);
	p = Getattr(p,"tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }
    
    /* Close prototype */
    
    Printf(f->def, ")\n{\n");
    
    /* Define the scheme name in C. This define is used by several Guile
       macros. */
    Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", NIL);
    
    // Now write code to make the function call
    Printv(f->code, tab4, "gh_defer_ints();\n", NIL);
    emit_action(n,f);
    Printv(f->code, tab4, "gh_allow_ints();\n", NIL);
    
    // Now have return value, figure out what to do with it.
    
    if ((tm = Getattr(n,"tmap:out"))) {
      Replaceall(tm,"$result","gswig_result");
      Replaceall(tm,"$target","gswig_result");
      Replaceall(tm,"$source","result");
      Printv(f->code,tm,"\n",NIL);
    }
    else {
      throw_unhandled_guile_type_error (d);
    }
    
    // Dump the argument output code
    Printv(f->code,outarg,NIL);
    
    // Dump the argument cleanup code
    Printv(f->code,cleanup,NIL);
    
    // Look for any remaining cleanup
    
    if (Getattr(n,"feature:new")) {
      if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
	Replaceall(tm,"$source","result");
	Printv(f->code,tm,"\n",NIL);
      }
    }
    
    // Free any memory allocated by the function being wrapped..
    if ((tm = Swig_typemap_lookup_new("ret",n,"result",0))) {
      Replaceall(tm,"$source","result");
      Printv(f->code,tm,"\n",NIL);
    }
    
    // Wrap things up (in a manner of speaking)
    
    if (beforereturn)
      Printv(f->code, beforereturn, "\n", NIL);
    Printv(f->code, "return gswig_result;\n", NIL);
    
    // Undefine the scheme name
    
    Printf(f->code, "#undef FUNC_NAME\n");
    Printf(f->code, "}\n");
    
    Wrapper_print (f, f_wrappers);
    
    if (!Getattr(n, "sym:overloaded")) {
    if (numargs > 10) {
      int i;
      /* gh_new_procedure would complain: too many args */
      /* Build a wrapper wrapper */
      Printv(f_wrappers, "static SCM\n", wname,"_rest (SCM rest)\n", NIL);
      Printv(f_wrappers, "{\n", NIL);
      Printf(f_wrappers, "SCM arg[%d];\n", numargs);
      Printf(f_wrappers, "SWIG_Guile_GetArgs (arg, rest, %d, %d, \"%s\");\n",
	     numreq, numargs-numreq, proc_name);
      Printv(f_wrappers, "return ", wname, "(", NIL);
      Printv(f_wrappers, "arg[0]", NIL);
      for (i = 1; i<numargs; i++)
	Printf(f_wrappers, ", arg[%d]", i);
      Printv(f_wrappers, ");\n", NIL);
      Printv(f_wrappers, "}\n", NIL);
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
    }
    else { /* overloaded function; don't export the single methods */
      if (!Getattr(n,"sym:nextSibling")) {
	/* Emit overloading dispatch function */

	int maxargs;
	String *dispatch = Swig_overload_dispatch(n,"return %s(argc,argv);",&maxargs);
	
	/* Generate a dispatch wrapper for all overloaded functions */

	Wrapper *df      = NewWrapper();
	String  *dname   = Swig_name_wrapper(iname);

	Printv(df->def,	
	       "static SCM\n", dname,
	       "(SCM rest)\n{\n",
	       NIL);
	Printf(df->code, "SCM argv[%d];\n", maxargs);
	Printf(df->code, "int argc = SWIG_Guile_GetArgs (argv, rest, %d, %d, \"%s\");\n", 
	       0, maxargs, proc_name);
	Printv(df->code,dispatch,"\n",NIL);
	Printf(df->code,"scm_misc_error(\"%s\", \"No matching method for generic function `%s'\", SCM_EOL);\n", proc_name, iname);
	Printv(df->code,"}\n",NIL);
	Wrapper_print(df,f_wrappers);
	Printf(f_init, "gh_new_procedure(\"%s\", (swig_guile_proc) %s, 0, 0, 1);\n",
	       proc_name, dname);
	DelWrapper(df);
	Delete(dispatch);
	Delete(dname);
      }
    }
    Printf (exported_symbols, "\"%s\", ", proc_name);
    if (procdoc) {
      String *returns_text = NewString("");
      if (num_results == 0) Printv(returns_text, return_nothing_doc, NIL);
      else if (num_results == 1) Printv(returns_text, return_one_doc, NIL);
      else Printv(returns_text, return_multi_doc, NIL);
      /* Substitute documentation variables */
      static const char *numbers[] = {"zero", "one", "two", "three",
			       "four", "five", "six", "seven",
			       "eight", "nine", "ten", "eleven",
			       "twelve"};
      if (num_results <= 12)
	Replaceall(returns_text, "$num_values", numbers[num_results]);
      else {
	String *num_results_str = NewStringf("%d", num_results);
	Replaceall(returns_text, "$num_values", num_results_str);
	Delete(num_results_str);
      }
      Replaceall(returns_text, "$values", returns);
      Printf(doc_body, "\n%s", returns_text);
      write_doc(proc_name, signature, doc_body);
      Delete(returns_text);
    }
    
    Delete(proc_name);
    Delete(outarg);
    Delete(cleanup);
    Delete(signature);
    Delete(doc_body);
    Delete(returns);
    Delete(tmp);
    DelWrapper(f);
    return SWIG_OK;
  }
  
  /* ------------------------------------------------------------
   * variableWrapper()
   *
   * Create a link to a C variable.
   * This creates a single function PREFIX_var_VARNAME().
   * This function takes a single optional argument.   If supplied, it means
   * we are setting this variable to some value.  If omitted, it means we are
   * simply evaluating this variable.  Either way, we return the variables
   * value.
   * ------------------------------------------------------------ */

  virtual int variableWrapper(Node *n) {

    char *name  = GetChar(n,"name");
    char *iname = GetChar(n,"sym:name");
    SwigType *t = Getattr(n,"type");
    
    String *proc_name;
    char  var_name[256];
    Wrapper *f;
    String  *tm;
    
    if (!addSymbol(iname,n)) return SWIG_ERROR;
    
    f = NewWrapper();
    // evaluation function names
    
    strcpy(var_name, Char(Swig_name_wrapper(iname))); 
    
    // Build the name for scheme.
    proc_name = NewString(iname);
    Replaceall(proc_name,"_", "-");
    
    if (1 || (SwigType_type(t) != T_USER) || (is_a_pointer(t))) {
      
      Printf (f->def, "static SCM\n%s(SCM s_0)\n{\n", var_name);
      
      /* Define the scheme name in C. This define is used by several Guile
	 macros. */
      Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", NIL);
      
      Wrapper_add_local (f, "gswig_result", "SCM gswig_result");
      
      if (!Getattr(n,"feature:immutable")) {
	/* Check for a setting of the variable value */
	Printf (f->code, "if (s_0 != GH_NOT_PASSED) {\n");
	if ((tm = Swig_typemap_lookup_new("varin",n,name,0))) {
	  Replaceall(tm,"$source","s_0");
	  Replaceall(tm,"$input","s_0");
	  Replaceall(tm,"$target",name);
	  Printv(f->code,tm,"\n",NIL);
	}
	else {
	  throw_unhandled_guile_type_error (t);
	}
	Printf (f->code, "}\n");
      }
      
      // Now return the value of the variable (regardless
      // of evaluating or setting)
      
      if ((tm = Swig_typemap_lookup_new("varout",n,name,0))) {
	Replaceall(tm,"$source",name);
	Replaceall(tm,"$target","gswig_result");
	Replaceall(tm,"$result", "gswig_result");
	Printv(f->code,tm,"\n",NIL);
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
	  || Getattr(n,"feature:immutable")) {
	/* Read-only variables become a simple procedure returning the
	   value; read-write variables become a simple procedure with
	   an optional argument. */
	Printf (f_init, "\t gh_new_procedure(\"%s\", (swig_guile_proc) %s, 0, %d, 0);\n",
		proc_name, var_name, Getattr(n,"feature:immutable") ? 0 : 1);
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
	String *signature2 = NULL;
	String *doc = NewString("");
	
	if (Getattr(n,"feature:immutable")) {
	  Printv(signature, proc_name, NIL);
	  Printv(doc, "Returns constant ", NIL);
	  if ((tm = Getattr(n,"tmap:varout:doc"))) {
	    Printv(doc,tm,NIL);
	  } else {
	    String *s = SwigType_str(t,0);
	    Chop(s);
	    Printf(doc,"<%s>",s);
	    Delete(s);
	  }
	}
	else if (emit_setters) {
	  Printv(signature, proc_name, NIL);
	  signature2 = NewString("");
	  Printv(signature2, "set! (", proc_name, ") ", NIL);
	  handle_documentation_typemap(signature2, NIL, n, "tmap:varin:arglist",
				       "new-value");
	  Printv(doc, "Get or set the value of the C variable, \n", NIL);
	  Printv(doc, "which is of type ", NIL);
	  handle_documentation_typemap(doc, NIL, n, "tmap:varout:doc",
				       "$1_type");
	  Printv(doc, ".");
	}
	else {
	  Printv(signature, proc_name,
		 " #:optional ", NIL);
	  if ((tm = Getattr(n,"tmap:varin:doc"))) {
	    Printv(signature,tm,NIL);
	  } else {
	    String *s = SwigType_str(t,0);
	    Chop(s);
	    Printf(signature,"new-value <%s>",s);
	    Delete(s);
	  }
	  
	  Printv(doc, "If NEW-VALUE is provided, "
		 "set C variable to this value.\n", NIL);
	  Printv(doc, "Returns variable value ", NIL);
	  if ((tm = Getattr(n,"tmap:varout:doc"))) {
	    Printv(doc,tm,NIL);
	  } else {
	    String *s = SwigType_str(t,0);
	    Chop(s);
	    Printf(doc,"<%s>",s);
	    Delete(s);
	  }
	}
	write_doc(proc_name, signature, doc, signature2);
	Delete(signature);
	if (signature2) Delete(signature2);
	Delete(doc);
      }
      
    } else {
      Swig_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number,
		   "Unsupported variable type %s (ignored).\n", SwigType_str(t,0));
    }
    Delete(proc_name);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   *
   * We create a read-only variable.
   * ------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    char *name      = GetChar(n,"name");
    char *iname     = GetChar(n,"sym:name");
    SwigType *type  = Getattr(n,"type");
    String   *value = Getattr(n,"value");
    
    String *proc_name;
    char   var_name[256];
    String *rvalue;
    Wrapper *f;
    SwigType *nctype;
    String   *tm;
    
    f = NewWrapper();
    
    // Make a static variable;
    
    sprintf (var_name, "%sconst_%s", prefix, iname);
    
    // Strip const qualifier from type if present
    
    nctype = NewString(type);
    if (SwigType_isconst(nctype)) {
      Delete(SwigType_pop(nctype));
    }
    
    // Build the name for scheme.
    proc_name = NewString(iname);
    Replaceall(proc_name,"_", "-");
    
    if ((SwigType_type(nctype) == T_USER) && (!is_a_pointer(nctype))) {
      Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number,
		   "Unsupported constant value.\n");
      return SWIG_NOWRAP;
    }
    
    // See if there's a typemap
    
    if (SwigType_type(nctype) == T_STRING) {
      rvalue = NewStringf("\"%s\"", value);
    } else if (SwigType_type(nctype) == T_CHAR) {
      rvalue = NewStringf("\'%s\'", value);
    } else {
      rvalue = NewString(value);
    }
    
    if ((tm = Swig_typemap_lookup_new("constant",n,name,0))) {
      Replaceall(tm,"$source",rvalue);
      Replaceall(tm,"$value",rvalue);
      Replaceall(tm,"$target",name);
      Printv(f_header,tm,"\n",NIL);
    } else {
      // Create variable and assign it a value
      Printf (f_header, "static %s = %s;\n", SwigType_lstr(nctype,var_name),
	      rvalue);
    }
    {
      /* Hack alert: will cleanup later -- Dave */
      Node *n = NewHash();
      Setattr(n,"name",var_name);
      Setattr(n,"sym:name",iname);
      Setattr(n,"type", nctype);
      Setattr(n,"feature:immutable", "1");
      variableWrapper(n);
      Delete(n);
    }
    Delete(nctype);
    Delete(proc_name);
    Delete(rvalue);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   * ------------------------------------------------------------ */
  virtual int membervariableHandler(Node *n) {
    if (emit_setters) {
      struct_member = 1;
      Printf(f_init, "{\n");
      Language::membervariableHandler(n);
      Printf(f_init, "}\n");
      struct_member = 0;
    }
    else {
      /* Only emit traditional VAR-get and VAR-set procedures */
      Language::membervariableHandler(n);
    }
    return SWIG_OK;
  }
  
  /* ------------------------------------------------------------
   * pragmaDirective()
   * ------------------------------------------------------------ */

  virtual int pragmaDirective(Node *n)
  {
    if (!ImportMode) {
      String *lang = Getattr(n,"lang");
      String *cmd = Getattr(n,"name");
      String *value = Getattr(n,"value");
      
#     define store_pragma(PRAGMANAME)			\
        if (Strcmp(cmd, #PRAGMANAME) == 0) {		\
	  if (PRAGMANAME) Delete(PRAGMANAME);		\
	  PRAGMANAME = value ? NewString(value) : NULL;	\
	}
      
      if (Strcmp(lang,"guile") == 0) {
	store_pragma(beforereturn)
	  store_pragma(return_nothing_doc)
	  store_pragma(return_one_doc)
	  store_pragma(return_multi_doc);
#     undef store_pragma
      }
    }
    return Language::pragmaDirective(n);
  }

  /* ------------------------------------------------------------
   * validIdentifier()
   * ------------------------------------------------------------ */

  virtual int validIdentifier(String *s) {
    char *c = Char(s);
    /* Check whether we have an R5RS identifier.  Guile supports a
       superset of R5RS identifiers, but it's probably a bad idea to use
       those. */
    /* <identifier> --> <initial> <subsequent>* | <peculiar identifier> */
    /* <initial> --> <letter> | <special initial> */
    if (!(isalpha(*c) || (*c == '!') || (*c == '$') || (*c == '%')
	  || (*c == '&') || (*c == '*') || (*c == '/') || (*c == ':')
	  || (*c == '<') || (*c == '=') || (*c == '>') || (*c == '?')
	  || (*c == '^') || (*c == '_') || (*c == '~'))) {
      /* <peculiar identifier> --> + | - | ... */
      if ((strcmp(c, "+") == 0)
	  || strcmp(c, "-") == 0
	  || strcmp(c, "...") == 0) return 1;
      else return 0;
    }
    /* <subsequent> --> <initial> | <digit> | <special subsequent> */
    while (*c) {
      if (!(isalnum(*c) || (*c == '!') || (*c == '$') || (*c == '%')
	    || (*c == '&') || (*c == '*') || (*c == '/') || (*c == ':')
	    || (*c == '<') || (*c == '=') || (*c == '>') || (*c == '?')
	    || (*c == '^') || (*c == '_') || (*c == '~') || (*c == '+')
	    || (*c == '-') || (*c == '.') || (*c == '@'))) return 0;
      c++;
    }
    return 1;
  }
};

/* -----------------------------------------------------------------------------
 * swig_guile()    - Instantiate module
 * ----------------------------------------------------------------------------- */

extern "C" Language *
swig_guile(void) {
  return new GUILE();
}
