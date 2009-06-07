/* -*- mode: c++; c-basic-offset: 2; indent-tabs-mode: nil; -*-
 *  vim:expandtab:shiftwidth=2:tabstop=8:smarttab:
 */

/* ----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * perl5.cxx
 *
 * Perl5 language module for SWIG.
 * ------------------------------------------------------------------------- */

char cvsroot_perl5_cxx[] = "$Id$";

#include "swigmod.h"
#include "cparse.h"
static int treduce = SWIG_cparse_template_reduce(0);

#include <ctype.h>

static const char *usage = (char *) "\
Perl5 Options (available with -perl5)\n\
     -static         - Omit code related to dynamic loading\n\
     -nopm           - Do not generate the .pm file\n\
     -proxy          - Create proxy classes\n\
     -noproxy        - Don't create proxy classes\n\
     -const          - Wrap constants as constants and not variables (implies -proxy)\n\
     -nocppcast      - Disable C++ casting operators, useful for generating bugs\n\
     -cppcast        - Enable C++ casting operators\n\
     -compat         - Compatibility mode\n\n";

static int compat = 0;

static int no_pmfile = 0;

static int export_all = 0;

/*
 * pmfile
 *   set by the -pm flag, overrides the name of the .pm file
 */
static String *pmfile = 0;

/*
 * module
 *   set by the %module directive, e.g. "Xerces". It will determine
 *   the name of the .pm file, and the dynamic library, and the name
 *   used by any module wanting to %import the module.
 */
static String *module = 0;

/*
 * namespace_module
 *   the fully namespace qualified name of the module. It will be used
 *   to set the package namespace in the .pm file, as well as the name
 *   of the initialization methods in the glue library. This will be
 *   the same as module, above, unless the %module directive is given
 *   the 'package' option, e.g. %module(package="Foo::Bar") "baz"
 */
static String       *namespace_module = 0;

/*
 * dest_package
 *   an optional namespace to put all classes into. Specified by using
 *   the %module(package="Foo::Bar") "baz" syntax
 */
static String       *dest_package = 0;

static String *constant_tab = 0;

static File *f_begin = 0;
static File *f_runtime = 0;
static File *f_header = 0;
static File *f_wrappers = 0;
static File *f_init = 0;
static File *f_pm = 0;
static String *pm;		/* Package initialization code */

static int staticoption = 0;

// controlling verbose output
static int          verbose = 0;

/* The following variables are used to manage Perl5 classes */

static int blessed = 1;		/* Enable object oriented features */
static int do_constants = 0;	/* Constant wrapping */
static List *classlist = 0;	/* List of classes */

static Node *CurrentClass = 0;    /* class currently being processed */
#define ClassName       Getattr(CurrentClass, "sym:name")
static Hash *mangle_seen = 0;

static String *pcode = 0;	/* Perl code associated with each class */
						  /* static  String   *blessedmembers = 0;     *//* Member data associated with each class */
static String *const_stubs = 0;	/* Constant stubs */
static int num_consts = 0;	/* Number of constants */
static String *var_stubs = 0;	/* Variable stubs */
static String *exported = 0;	/* Exported symbols */
static String *pragma_include = 0;
static String *additional_perl_code = 0;	/* Additional Perl code from %perlcode %{ ... %} */
static Hash *operators = 0;
static int have_operators = 0;

class PERL5:public Language {
public:

  PERL5():Language () {
    Clear(argc_template_string);
    Printv(argc_template_string, "items", NIL);
    Clear(argv_template_string);
    Printv(argv_template_string, "ST(%d)", NIL);
  }

  /* Test to see if a type corresponds to something wrapped with a shadow class */
  Node *is_shadow(SwigType *t) {
    Node *n;
    n = classLookup(t);
    /*  Printf(stdout,"'%s' --> '%x'\n", t, n); */
    if (n) {
      if (!Getattr(n, "perl5:proxy")) {
	setclassname(n);
      }
      return Getattr(n, "perl5:proxy");
    }
    return 0;
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {
    int i = 1;
    int cppcast = 1;

    SWIG_library_directory("perl5");

    for (i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-package") == 0) {
	  Printv(stderr,
		 "*** -package is no longer supported\n*** use the directive '%module A::B::C' in your interface file instead\n*** see the Perl section in the manual for details.\n", NIL);
	  SWIG_exit(EXIT_FAILURE);
	} else if (strcmp(argv[i], "-interface") == 0) {
	  Printv(stderr,
		 "*** -interface is no longer supported\n*** use the directive '%module A::B::C' in your interface file instead\n*** see the Perl section in the manual for details.\n", NIL);
	  SWIG_exit(EXIT_FAILURE);
	} else if (strcmp(argv[i], "-exportall") == 0) {
	  export_all = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i], "-static") == 0) {
	  staticoption = 1;
	  Swig_mark_arg(i);
	} else if ((strcmp(argv[i], "-shadow") == 0) || ((strcmp(argv[i], "-proxy") == 0))) {
	  blessed = 1;
	  Swig_mark_arg(i);
	} else if ((strcmp(argv[i], "-noproxy") == 0)) {
	  blessed = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i], "-const") == 0) {
	  do_constants = 1;
	  blessed = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i], "-nopm") == 0) {
	  no_pmfile = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i], "-pm") == 0) {
	  Swig_mark_arg(i);
	  i++;
	  pmfile = NewString(argv[i]);
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-v") == 0) {
	    Swig_mark_arg(i);
	    verbose++;
	} else if (strcmp(argv[i], "-cppcast") == 0) {
	  cppcast = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i], "-nocppcast") == 0) {
	  cppcast = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i], "-compat") == 0) {
	  compat = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i], "-help") == 0) {
	  fputs(usage, stdout);
	}
      }
    }

    if (cppcast) {
      Preprocessor_define((DOH *) "SWIG_CPLUSPLUS_CAST", 0);
    }

    Preprocessor_define("SWIGPERL 1", 0);
    // SWIGPERL5 is deprecated, and no longer documented.
    Preprocessor_define("SWIGPERL5 1", 0);
    SWIG_typemap_lang("perl5");
    SWIG_config_file("perl5.swg");
    allow_overloading();
  }

  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */

  virtual int top(Node *n) {

    /* Initialize all of the output files */
    String *outfile = Getattr(n, "outfile");

    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    classlist = NewList();

    pm = NewString("");
    var_stubs = NewString("");
    const_stubs = NewString("");
    exported = NewString("");
    pragma_include = NewString("");
    additional_perl_code = NewString("");

    constant_tab = NewString("static swig_constant_info swig_constants[] = {\n");

    Swig_banner(f_begin);

    Printf(f_runtime, "\n");
    Printf(f_runtime, "#define SWIGPERL\n");
    Printf(f_runtime, "#define SWIG_CASTRANK_MODE\n");
    Printf(f_runtime, "\n");

    // Is the imported module in another package?  (IOW, does it use the
    // %module(package="name") option and it's different than the package
    // of this module.)
    Node *mod = Getattr(n, "module");
    Node *options = Getattr(mod, "options");
    module = Copy(Getattr(n,"name"));

    if (verbose > 0) {
      fprintf(stdout, "top: using module: %s\n", Char(module));
    }

    dest_package = options ? Getattr(options, "package") : 0;
    if (dest_package) {
      namespace_module = Copy(dest_package);
      if (verbose > 0) {
	fprintf(stdout, "top: Found package: %s\n",Char(dest_package));
      }
    } else {
      namespace_module = Copy(module);
      if (verbose > 0) {
	fprintf(stdout, "top: No package found\n");
      }
    }
    String *underscore_module = Copy(module);
    Replaceall(underscore_module,":","_");

    if (verbose > 0) {
      fprintf(stdout, "top: using namespace_module: %s\n", Char(namespace_module));
    }

    /* Create a .pm file
     * Need to strip off any prefixes that might be found in
     * the module name */

    if (no_pmfile) {
      f_pm = NewString(0);
    } else {
      if (pmfile == NULL) {
	char *m = Char(module) + Len(module);
	while (m != Char(module)) {
	  if (*m == ':') {
	    m++;
	    break;
	  }
	  m--;
	}
	pmfile = NewStringf("%s.pm", m);
      }
      String *filen = NewStringf("%s%s", SWIG_output_directory(), pmfile);
      if ((f_pm = NewFile(filen, "w", SWIG_output_files())) == 0) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen);
      filen = NULL;
      Swig_register_filebyname("pm", f_pm);
      Swig_register_filebyname("perl", f_pm);
    }
    {
      String *boot_name = NewStringf("boot_%s", underscore_module);
      Printf(f_header,"#define SWIG_init    %s\n\n", boot_name);
      Printf(f_header,"#define SWIG_name   \"%s::%s\"\n", module, boot_name);
      Printf(f_header,"#define SWIG_prefix \"%s::\"\n", module);
      Delete(boot_name);
    }

    Swig_banner_target_lang(f_pm, "#");
    Printf(f_pm, "\n");

    Printf(f_pm, "package %s;\n", module);

    /* 
     * If the package option has been given we are placing our
     *   symbols into some other packages namespace, so we do not
     *   mess with @ISA or require for that package
     */
    if (dest_package) {
      Printf(f_pm,"use base qw(DynaLoader);\n");
    } else {
      Printf(f_pm,"use base qw(Exporter);\n");
      if (!staticoption) {
	Printf(f_pm,"use base qw(DynaLoader);\n");
      }
    }

    Printf(f_wrappers, "#ifdef __cplusplus\nextern \"C\" {\n#endif\n");

    /* emit wrappers */
    Language::top(n);

    /* Dump out variable wrappers */

    SwigType_emit_type_table(f_runtime, f_wrappers);

    Printf(constant_tab, "{0,0,0,0,0,0}\n};\n");
    Printv(f_wrappers, constant_tab, NIL);

    Printf(f_wrappers, "#ifdef __cplusplus\n}\n#endif\n");

    Printf(f_init, "\t ST(0) = &PL_sv_yes;\n");
    Printf(f_init, "\t XSRETURN(1);\n");
    Printf(f_init, "}\n");

    if (!staticoption) {
      Printf(f_pm,"bootstrap %s;\n", module);
    } else {
      Printf(f_pm,"boot_%s();\n", underscore_module);
    }

    /* 
     * If the package option has been given we are placing our
     *   symbols into some other packages namespace, so we do not
     *   mess with @EXPORT
     */
    if (!dest_package) {
      Printf(f_pm,"@EXPORT = qw(%s);\n", exported);
    }

    Printf(f_pm, "%s", pragma_include);

    if (blessed) {

      /* Emit package code for different classes */
      Printf(f_pm, "%s", pm);

      if (num_consts > 0) {
	/* Emit constant stubs */
	Printf(f_pm, "\n# ------- CONSTANT STUBS -------\n\n");
	Printf(f_pm, "package %s;\n\n", namespace_module);
	Printf(f_pm, "%s", const_stubs);
      }

      /* Emit variable stubs */

      Printf(f_pm, "\n# ------- VARIABLE STUBS --------\n\n");
      Printf(f_pm, "package %s;\n\n", namespace_module);
      Printf(f_pm, "%s", var_stubs);
    }

    /* Add additional Perl code at the end */
    Printf(f_pm, "%s", additional_perl_code);

    Printf(f_pm, "1;\n");
    Close(f_pm);
    Delete(f_pm);
    Delete(dest_package);
    Delete(underscore_module);

    /* Close all of the files */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Close(f_begin);
    Delete(f_runtime);
    Delete(f_begin);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * importDirective(Node *n)
   * ------------------------------------------------------------ */

  virtual int importDirective(Node *n) {
    if (blessed) {
      String *modname = Getattr(n, "module");
      if (modname) {
	Printf(f_pm, "require %s;\n", modname);
      }
    }
    return Language::importDirective(n);
  }

  /* ------------------------------------------------------------
   * functionWrapper()
   * ------------------------------------------------------------ */

  virtual int functionWrapper(Node *n) {
    String *name = Getattr(n, "name");
    String *iname = Getattr(n, "sym:name");
    String *pname = Getattr(n, "perl5:name");
    SwigType *d = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    ParmList *outer = Getattr(n, "perl5:implicits");
    String *overname = 0;

    Parm *p;
    int i;
    Wrapper *f;
    char source[256], temp[256];
    String *tm;
    String *cleanup, *outarg;
    int num_saved = 0;
    int num_arguments, num_required, num_implicits;
    int varargs = 0;

    if (Getattr(n, "sym:overloaded")) {
      overname = Getattr(n, "sym:overname");
    } else {
      if (!addSymbol(iname, n))
	return SWIG_ERROR;
    }
    if (!pname)
      pname = iname;

    f = NewWrapper();

    String *wname = Swig_name_wrapper(iname);
    if (overname) {
      Append(wname, overname);
    }
    Setattr(n, "wrap:name", wname);
    if(GetFlag(n, "perl5:instancevariable")) {
      int addfail = 1;
      Printv(f->def,
          "SWIGCLASS_STATIC int ", wname, "(pTHX_ SV *sv, MAGIC *mg) {\n",
          NIL);
      Wrapper_add_local(f, "argvi", "int argvi = 0");
      emit_parameter_variables(l, f);
      emit_return_variable(n, d, f);
      emit_attach_parmmaps(l, f);

      /* recover self pointer */
      tm = Getattr(l, "tmap:in");
      Replaceall(tm, "SWIG_ConvertPtr", "SWIG_Perl_ConvertMg"); /* HACK */
      Replaceall(tm, "$input", "mg");
      Replaceall(tm, "$disown", "0"); /* TODO: verify this */
      emit_action_code(n, f->code, tm);
      l = nextSibling(l);

      if (SwigType_type(d) == T_VOID) {
        Setattr(n, "perl5:setter", wname);
        tm = Getattr(l, "tmap:in");
        if (!tm) {
          Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to set an attribute of type %s.\n",
              SwigType_str(Getattr(l, "type"), 0));
          return SWIG_NOWRAP;
        }
        Replaceall(tm, "$input", "sv");
        Replaceall(tm, "$disown", "0"); /* TODO: verify this */
        emit_action_code(n, f->code, tm);
        emit_action_code(n, f->code, Getattr(n, "wrap:action"));
        addfail = 1;
      } else {
        Setattr(n, "perl5:getter", wname);
        Swig_director_emit_dynamic_cast(n, f);
        String *actioncode = emit_action(n);
        SwigType *t = Getattr(n, "type");
        tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode);
        if(!tm) {
          Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to get an attribute of type %s.\n",
              SwigType_str(t, 0), name);
          return SWIG_NOWRAP;
        }
        Wrapper_add_local(f, "dest", "SV *dest");
        Replaceall(tm, "$result", "dest");
        //Replaceall(tm, "$source", "result");
        //Replaceall(tm, "$target", "ST(argvi)");
        //Replaceall(tm, "$result", "ST(argvi)");
        Replaceall(tm, "$owner", "0");
        Printv(f->code,
            tm, "\n",
            "SvSetSV(sv, dest);\n", NIL);
      }
      Append(f->code,
          "return 0;\n");
      if (addfail) {
        Append(f->code,
            "fail:\n"
            "croak(Nullch);\n"
            "return 0;\n");
      }
      Append(f->code,
          "}");
      Wrapper_print(f, f_wrappers);
      return SWIG_OK;
    }
    cleanup = NewString("");
    outarg = NewString("");
    Printv(f->def, "XS(", wname, ") {\n", "{\n",	/* scope to destroy C++ objects before croaking */
	   NIL);

    num_implicits = 0;
    if (outer) {
      Parm *tail;
      for(Parm *cur = outer; cur; cur = nextSibling(cur)) {
        tail = cur;
        num_implicits++;
      }
      /* link the outer with inner parms */
      set_nextSibling(tail, l);
    }

    emit_parameter_variables(l, f);
    emit_attach_parmmaps(l, f);
    Setattr(n, "wrap:parms", l);

    num_arguments = emit_num_arguments(l);
    num_required = emit_num_required(l);
    varargs = emit_isvarargs(l);

    Wrapper_add_local(f, "argvi", "int argvi = 0");

    /* Check the number of arguments */
    if (!varargs) {
      Printf(f->code, "    if ((items < %d) || (items > %d)) {\n",
        num_required + num_implicits, num_arguments + num_implicits);
    } else {
      Printf(f->code, "    if (items < %d) {\n",
        num_required + num_implicits);
    }
    Printf(f->code,
        "        SWIG_croak(\"Usage: %s\");\n"
        "}\n",
        usage_func(Char(pname), d, outer));

    if (num_implicits) {
      /* TODO: support implicits of types other than SVs */
      Parm *p = outer;
      for (i = 0; i < num_implicits; i++) {
        String *vname = Getattr(p, "name");
        String *vdecl = SwigType_str(Getattr(p, "type"), vname);
        Wrapper_add_local(f, vname, vdecl);
        Delete(vdecl);
        Printf(f->code, "%s = ST(%d);\n", vname, i++);
        p = nextSibling(p);
      }
      if (l)
        Printf(f->code, "ax += %d;\n", num_implicits);
    }
    /* Write code to extract parameters. */
    i = 0;
    for (i = 0, p = l; i < num_arguments; i++) {

      /* Skip ignored arguments */

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");

      /* Produce string representation of source and target arguments */
      sprintf(source, "ST(%d)", i);
      String *target = Getattr(p, "lname");

      if (i >= num_required) {
	Printf(f->code, "    if (items > %d) {\n", i);
      }
      if ((tm = Getattr(p, "tmap:in"))) {
	Replaceall(tm, "$target", target);
	Replaceall(tm, "$source", source);
	Replaceall(tm, "$input", source);
	Setattr(p, "emit:input", source);	/* Save input location */

	if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:in:disown"))) {
	  Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
	} else {
	  Replaceall(tm, "$disown", "0");
	}

	Printf(f->code, "%s\n", tm);
	p = Getattr(p, "tmap:in:next");
      } else {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
	p = nextSibling(p);
      }
      if (i >= num_required) {
	Printf(f->code, "    }\n");
      }
    }

    if (varargs) {
      if (p && (tm = Getattr(p, "tmap:in"))) {
	sprintf(source, "ST(%d)", i);
	Replaceall(tm, "$input", source);
	Setattr(p, "emit:input", source);
	Printf(f->code, "if (items >= %d) {\n", i);
	Printv(f->code, tm, "\n", NIL);
	Printf(f->code, "}\n");
      }
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:check"))) {
	Replaceall(tm, "$target", Getattr(p, "lname"));
	Printv(f->code, tm, "\n", NIL);
	p = Getattr(p, "tmap:check:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    for (i = 0, p = l; p; i++) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
	Replaceall(tm, "$source", Getattr(p, "lname"));
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(cleanup, tm, "\n", NIL);
	p = Getattr(p, "tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    num_saved = 0;
    for (i = 0, p = l; p; i++) {
      if ((tm = Getattr(p, "tmap:argout"))) {
	SwigType *t = Getattr(p, "type");
	Replaceall(tm, "$source", Getattr(p, "lname"));
	Replaceall(tm, "$target", "ST(argvi)");
	Replaceall(tm, "$result", "ST(argvi)");

	String *in = Getattr(p, "emit:input");
	if (in) {
	  sprintf(temp, "_saved[%d]", num_saved);
	  Replaceall(tm, "$arg", temp);
	  Replaceall(tm, "$input", temp);
	  Printf(f->code, "_saved[%d] = %s;\n", num_saved, in);
	  num_saved++;
	}
	Printv(outarg, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* If there were any saved arguments, emit a local variable for them */
    if (num_saved) {
      sprintf(temp, "_saved[%d]", num_saved);
      Wrapper_add_localv(f, "_saved", "SV *", temp, NIL);
    }

    if (num_implicits && l)
      Printf(f->code, "ax -= %d;\n", num_implicits);

    /* Now write code to make the function call */

    Swig_director_emit_dynamic_cast(n, f);
    String *actioncode = emit_action(n);

    if ((tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode))) {
      SwigType *t = Getattr(n, "type");
      Replaceall(tm, "$source", "result");
      Replaceall(tm, "$target", "ST(argvi)");
      Replaceall(tm, "$result", "ST(argvi)");
      Replaceall(tm, "$owner", GetFlag(n, "feature:new") ?
          "SWIG_OWNER" : "0");
      /* TODO: this NewPointerObjP stuff is a hack */
      if (blessed && Equal(nodeType(n), "constructor"))
        Replaceall(tm, "NewPointerObj", "NewPointerObjP");
      Printf(f->code, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(d, 0), name);
    }
    emit_return_variable(n, d, f);

    /* If there were any output args, take care of them. */

    Printv(f->code, outarg, NIL);

    /* If there was any cleanup, do that. */

    Printv(f->code, cleanup, NIL);

    if (GetFlag(n, "feature:new")) {
      if ((tm = Swig_typemap_lookup("newfree", n, "result", 0))) {
	Replaceall(tm, "$source", "result");
	Printf(f->code, "%s\n", tm);
      }
    }

    if ((tm = Swig_typemap_lookup("ret", n, "result", 0))) {
      Replaceall(tm, "$source", "result");
      Printf(f->code, "%s\n", tm);
    }

    Printv(f->code, "XSRETURN(argvi);\n", "fail:\n", cleanup, "SWIG_croak_null();\n" "}\n" "}\n", NIL);

    /* Add the dXSARGS last */

    Wrapper_add_local(f, "dXSARGS", "dXSARGS");

    /* Substitute the cleanup code */
    Replaceall(f->code, "$cleanup", cleanup);
    Replaceall(f->code, "$symname", iname);

    /* Dump the wrapper function */

    Wrapper_print(f, f_wrappers);

    /* Now register the function */

    if (!Getattr(n, "sym:overloaded")) {
      /* TODO: would be very cool to use newXSproto here, but for now
       * let's just make it work using the current call signature
       * checks. */
      Printf(f_init, "newXS(\"%s::%s\", %s, __FILE__);\n",
          namespace_module, pname, wname);
    } else if (!Getattr(n, "sym:nextSibling")) {
      /* Generate overloaded dispatch function */
      int maxargs;
      String *dispatch = Swig_overload_dispatch_cast(n, "++PL_markstack_ptr; SWIG_CALLXS(%s); return;", &maxargs);

      /* Generate a dispatch wrapper for all overloaded functions */

      Wrapper *df = NewWrapper();
      String *dname = Swig_name_wrapper(iname);

      Printv(df->def, "XS(", dname, ") {\n", NIL);

      Wrapper_add_local(df, "dXSARGS", "dXSARGS");
      if (num_implicits) {
        Printf(df->code, "ax += %d;\n", num_implicits);
        Printf(df->code, "items -= %d;\n", num_implicits);
      }
      Printv(df->code, dispatch, "\n", NIL);
      Printf(df->code, "croak(\"No matching function for overloaded '%s'\");\n", pname);
      Printf(df->code, "XSRETURN(0);\n");
      Printv(df->code, "}\n", NIL);
      Wrapper_print(df, f_wrappers);
      Printf(f_init, "newXS(\"%s::%s\", %s, __FILE__);\n",
          namespace_module, pname, dname);
      DelWrapper(df);
      Delete(dispatch);
      Delete(dname);
    }
    if (!Getattr(n, "sym:nextSibling")) {
      if (export_all) {
	Printf(exported, "%s ", iname);
      }
    }
    Delete(cleanup);
    Delete(outarg);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * variableWrapper()
   * ------------------------------------------------------------ */
  virtual int variableWrapper(Node *n) {
    String *name = Getattr(n, "name");
    String *iname = Getattr(n, "sym:name");
    String *pname = Getattr(n, "perl5:name");
    String *type = Getattr(n, "type");
    Wrapper *f;
    String *getf, *setf;
    String *tm;
    String *tmp;

    if (!addSymbol(iname, n))
      return SWIG_ERROR;

    if (!pname)
      pname = iname;

    if (is_assignable(n)) {
      /* emit setter */
      f = NewWrapper();

      tmp = Swig_name_set(iname);
      setf = Swig_name_wrapper(tmp);
      Delete(tmp);
      Setattr(n, "wrap:name", setf);
      Printv(f->def,
          "SWIGCLASS_STATIC int ", setf, "(pTHX_ SV *sv, MAGIC *mg) {\n",
          NIL);
      tm = Swig_typemap_lookup("varin", n, name, f);
      if (!tm) {
        Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number,
            "Unable to set variable of type %s.\n",
            SwigType_str(type, 0));
        return SWIG_NOWRAP;
      }
      Replaceall(tm, "$source", "sv");
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$input", "sv");
      emit_action_code(n, f->code, tm);
      Append(f->code,
          "  return 0;\n"
          "fail:\n"
          "  croak(Nullch);\n"
          "  return 0;\n"
          "}\n");
      Wrapper_print(f, f_wrappers);
      Delete(f);
    } else {
      setf = NewString("0");
    }
    {
      /* emit getter */
      int addfail;
      tmp = Swig_name_get(iname);
      getf = Swig_name_wrapper(tmp);
      Delete(tmp);
      f = NewWrapper();
      Setattr(n, "wrap:name", getf);
      Printv(f->def,
          "SWIGCLASS_STATIC int ", getf, "(pTHX_ SV *sv, MAGIC *mg) {\n",
          NIL);
      tm = Swig_typemap_lookup("varout", n, name, f);
      if (!tm) {
        Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number,
            "Unable to read variable of type %s\n",
            SwigType_str(type, 0));
        return SWIG_NOWRAP;
      }
      Replaceall(tm, "$target", "sv");
      Replaceall(tm, "$result", "sv");
      Replaceall(tm, "$source", name);
      addfail = emit_action_code(n, f->code, tm);
      Append(f->code, "  return 0;\n");
      if (addfail) {
        Append(f->code,
            "fail:\n"
            "  croak(Nullch);\n"
            "  return 0;\n");
      }
      Append(f->code, "}\n");
      Wrapper_print(f, f_wrappers);
      Delete(f);
    }

    {
      String *vtbl = NewStringf("_swig_perl_vtbl_%s", iname);

      Printf(f_wrappers,
        "MGVTBL %s = SWIG_Perl_VTBL(%s, %s);\n",
        vtbl, getf, setf);

      Setattr(n, "perl5:vtbl", vtbl);

      Printf(f_init,
          "SWIG_Perl_WrapVar(get_sv(\"%s::%s\", TRUE | GV_ADDMULTI), &%s, 0);\n",
          namespace_module, pname, vtbl);
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *name = Getattr(n, "name");
    String *iname = Getattr(n, "sym:name");
    String *pname = Getattr(n, "perl5:name");
    SwigType *type = Getattr(n, "type");
    String *rawval = Getattr(n, "rawval");
    String *value = rawval ? rawval : Getattr(n, "value");
    String *tm;

    if (!addSymbol(iname, n))
      return SWIG_ERROR;

    if (!pname)
      pname = iname;
    Swig_require("perl5constantWrapper", n, "*sym:name", NIL);
    Setattr(n, "sym:name", pname);

    /* Special hook for member pointer */
    if (SwigType_type(type) == T_MPOINTER) {
      String *wname = Swig_name_wrapper(iname);
      Printf(f_wrappers, "static %s = %s;\n", SwigType_str(type, wname), value);
      value = Char(wname);
    }

    if ((tm = Swig_typemap_lookup("consttab", n, name, 0))) {
      Replaceall(tm, "$source", value);
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$value", value);
      Printf(constant_tab, "%s,\n", tm);
    } else if ((tm = Swig_typemap_lookup("constcode", n, name, 0))) {
      Replaceall(tm, "$source", value);
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$value", value);
      Printf(f_init, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number, "Unsupported constant value.\n");
      Swig_restore(n);
      return SWIG_NOWRAP;
    }

    if (blessed) {
      if (is_shadow(type)) {
	Printv(var_stubs,
	       "\nmy %__", iname, "_hash;\n",
	       "tie %__", iname, "_hash,\"", is_shadow(type), "\", $",
	       module, "::", iname, ";\n", "$", iname, "= \\%__", iname, "_hash;\n", "bless $", iname, ", ", is_shadow(type), ";\n", NIL);
      } else if (do_constants) {
	Printv(const_stubs, "sub ", name, " () { $", module, "::", name, " }\n", NIL);
	num_consts++;
      }
    }
    if (export_all) {
      if (do_constants && !is_shadow(type)) {
	Printf(exported, "%s ", name);
      } else {
	Printf(exported, "$%s ", iname);
      }
    }
    Swig_restore(n);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * usage_func()
   * ------------------------------------------------------------ */
  char *usage_func(char *iname, SwigType *, ParmList *l) {
    static String *temp = 0;
    Parm *p;
    int i;

    if (!temp)
      temp = NewString("");
    Clear(temp);
    Printf(temp, "%s(", iname);

    /* Now go through and print parameters */
    p = l;
    i = 0;
    while (p != 0) {
      SwigType *pt = Getattr(p, "type");
      String *pn = Getattr(p, "name");
      if (!checkAttribute(p,"tmap:in:numinputs","0")) {
        if (i > 0) Append(temp, ",");
	/* If parameter has been named, use that.   Otherwise, just print a type  */
	if (SwigType_type(pt) != T_VOID) {
	  if (Len(pn) > 0) {
	    Printf(temp, "%s", pn);
	  } else {
	    Printf(temp, "%s", SwigType_str(pt, 0));
	  }
	}
	i++;
      }
      p = nextSibling(p);
    }
    Printf(temp, ");");
    return Char(temp);
  }

  /* ------------------------------------------------------------
   * nativeWrapper()
   * ------------------------------------------------------------ */

  virtual int nativeWrapper(Node *n) {
    String *iname = Getattr(n, "sym:name");
    String *wname = Getattr(n, "wrap:name");

    if (!addSymbol(iname, n))
      return SWIG_ERROR;

    /* %native, used to drop hand coded XS directly into .i files, does
     * not apply to classes, thus no "perl5:name" attribute will ever be
     * present. */
    Printf(f_init, "newXS(\"%s::%s\", %s, __FILE__);\n",
        namespace_module, iname, wname);

    if (export_all)
      Printf(exported, "%s ", iname);
    return SWIG_OK;
  }

/* ----------------------------------------------------------------------------
 *                      OBJECT-ORIENTED FEATURES
 *
 * These extensions provide a more object-oriented interface to C++
 * classes and structures.    The code here is based on extensions
 * provided by David Fletcher and Gary Holt.
 *
 * I have generalized these extensions to make them more general purpose
 * and to resolve object-ownership problems.
 *
 * The approach here is very similar to the Python module :
 *       1.   All of the original methods are placed into a single
 *            package like before except that a 'c' is appended to the
 *            package name.
 *
 *       2.   All methods and function calls are wrapped with a new
 *            perl function.   While possibly inefficient this allows
 *            us to catch complex function arguments (which are hard to
 *            track otherwise).
 *
 *       3.   Classes are represented as tied-hashes in a manner similar
 *            to Gary Holt's extension.   This allows us to access
 *            member data.
 *
 *       4.   Stand-alone (global) C functions are modified to take
 *            tied hashes as arguments for complex datatypes (if
 *            appropriate).
 *
 *       5.   Global variables involving a class/struct is encapsulated
 *            in a tied hash.
 *
 * ------------------------------------------------------------------------- */


  void setclassname(Node *n) {
    String *symname = Getattr(n, "sym:name");
    String *fullname;
    String *actualpackage;
    Node *clsmodule = Getattr(n, "module");

    if (!clsmodule) {
      /* imported module does not define a module name.   Oh well */
      return;
    }

    /* Do some work on the class name */
    if (verbose > 0) {
      String *modulename = Getattr(clsmodule, "name");
      fprintf(stdout, "setclassname: Found sym:name: %s\n", Char(symname));
      fprintf(stdout, "setclassname: Found module: %s\n", Char(modulename));
      fprintf(stdout, "setclassname: No package found\n");
    }

    if (dest_package) {
      fullname = NewStringf("%s::%s", namespace_module, symname);
    } else {
      actualpackage = Getattr(clsmodule,"name");

      if (verbose > 0) {
	fprintf(stdout, "setclassname: Found actualpackage: %s\n", Char(actualpackage));
      }
      if ((!compat) && (!Strchr(symname,':'))) {
	fullname = NewStringf("%s::%s",actualpackage,symname);
      } else {
	fullname = NewString(symname);
      }
    }
    if (verbose > 0) {
      fprintf(stdout, "setclassname: setting proxy: %s\n", Char(fullname));
    }
    Setattr(n, "perl5:proxy", fullname);
  }

  /* ------------------------------------------------------------
   * classDeclaration()
   * ------------------------------------------------------------ */
  virtual int classDeclaration(Node *n) {
    /* Do some work on the class name */
    if (!Getattr(n, "feature:onlychildren")) {
      if (blessed) {
	setclassname(n);
	Append(classlist, n);
      }
    }

    return Language::classDeclaration(n);
  }

  /* ------------------------------------------------------------
   * classHandler()
   * ------------------------------------------------------------ */

  virtual int classHandler(Node *n) {
    String *name = 0; /* Real name of C/C++ class */
    String *fullclassname = 0;

    Node *outer_class = CurrentClass;
    CurrentClass = n;
    Setattr(n, "perl5:memberVariables", NewList());

    if (blessed) {
      have_operators = 0;
      operators = NewHash();

      if (!addSymbol(ClassName, n))
	return SWIG_ERROR;

      /* Use the fully qualified name of the Perl class */
      if (!compat) {
	fullclassname = NewStringf("%s::%s", namespace_module, ClassName);
      } else {
	fullclassname = NewString(ClassName);
      }
      name = Getattr(n, "name");
      pcode = NewString("");
      // blessedmembers = NewString("");
    }

    /* Emit all of the members */
    int rv = Language::classHandler(n);
    if(rv != SWIG_OK) return rv;


    /* Finish the rest of the class */
    if (blessed) {
      Printv(pm, "\n",
          "############# Class : ", fullclassname, " ##############\n",
          "package ", fullclassname, ";\n", NIL);

      /* tell interpreter about class inheritance */
      List *baselist = Getattr(n, "bases");
      if (baselist && Len(baselist)) {
        int begun = 0;
        for (Iterator b = First(baselist); b.item; b = Next(b)) {
          String *bname = Getattr(b.item, "perl5:proxy");
          if (!bname)
            continue;
          Printv(pm, (begun ? ", '" : "use base '"), bname, "'", NIL);
          begun = 1;
        }
        if (begun) Append(pm, ";\n");
      }

      /* tell interpreter about class attributes */
      {
        SwigType *ct = Copy(name);
        String *mang;

        SwigType_add_pointer(ct);
        mang = SwigType_manglestr(ct);
        /* mangle_seen is to avoid emitting type information for types
         * SwigType_remember_clientdata does not consider to be
         * different, it's a hack.  I think the problem this workaround
         * is needed for is in typesys/symbol management. */
        if (!mangle_seen) mangle_seen = NewHash();
        if (!Getattr(mangle_seen, mang)) {

        /* declare attribute bindings */
        int nattr = 0;
        int nfield = 0;
        List *bases = Getattr(n, "bases");
        if(bases) bases = Copy(bases);
        else      bases = NewList();
        Insert(bases, 0, n);
        Printv(pm, "use fields (", NIL);
        for (int i = Len(bases); i > 0; i--) {
          Node *iclass = Getitem(bases, i - 1);
          for (Iterator j = First(Getattr(iclass,
              "perl5:memberVariables")); j.item; j = Next(j)) {
            Node *ch = j.item;
            /* XS side */
            String *vtbl = Getattr(ch, "perl5:vtbl");
            if(vtbl) {
              vtbl = Copy(vtbl);
            } else {
              String *getf = Getattr(ch, "perl5:getter");
              if (!getf) continue;
              String *setf = Getattr(ch, "perl5:setter");
              vtbl = NewStringf("SWIG_Perl_VTBL(%s, %s)",
                  getf, setf ? setf : "0");
            }
            String *chn = Getattr(ch, "sym:name");
            if (nattr == 0) {
              Printv(f_wrappers, "static swig_perl_type_ext_var "
                  "_swigt_ext_var_", mang, "[] = {\n", NIL);
            } else {
              Append(f_wrappers, ",\n");
            }
            Printf(f_wrappers,
                "  { \"%s\", %s }", chn, vtbl);
            Delete(vtbl);
            nattr++;
            /* Perl side */
            if (iclass == n || Strncmp(chn, "_", 1) == 0) {
              /* fields.pm handles leading underscore a bit special */
              if (nfield)
                Append(pm, ", ");
              Printf(pm, "'%s'", chn);
              nfield++;
            }
          }
        }
        Append(pm, ");\n");
        if (nattr) {
          Printf(f_wrappers, "\n};\n"
            "static swig_perl_type_ext _swigt_ext_%s = "
            "SWIG_Perl_TypeExt(\"%s\", %d, _swigt_ext_var_%s);\n\n",
            mang, fullclassname, nattr, mang);
        } else {
          Printf(f_wrappers,
            "static swig_perl_type_ext _swigt_ext_%s = "
            "SWIG_Perl_TypeExt(\"%s\", 0, 0);\n\n",
            mang, fullclassname);
        }
        Delete(bases);
        String *tmp = NewStringf("&_swigt_ext_%s", mang);
        SwigType_remember_clientdata(ct, tmp);
        Setattr(mangle_seen, mang, "1");
        Delete(mang);
        Delete(ct);
      }}

      if (have_operators) {
	Printf(pm, "use overload\n");
	Iterator ki;
	for (ki = First(operators); ki.key; ki = Next(ki)) {
	  char *name = Char(ki.key);
	  //        fprintf(stderr,"found name: <%s>\n", name);
	  if (strstr(name, "__eq__")) {
	    Printv(pm, tab4, "\"==\" => sub { $_[0]->__eq__($_[1])},\n",NIL);
	  } else if (strstr(name, "__ne__")) {
	    Printv(pm, tab4, "\"!=\" => sub { $_[0]->__ne__($_[1])},\n",NIL);
	    // there are no tests for this in operator_overload_runme.pl
	    // it is likely to be broken
	    //	  } else if (strstr(name, "__assign__")) {
	    //	    Printv(pm, tab4, "\"=\" => sub { $_[0]->__assign__($_[1])},\n",NIL);
	  } else if (strstr(name, "__str__")) {
	    Printv(pm, tab4, "'\"\"' => sub { $_[0]->__str__()},\n",NIL);
	  } else if (strstr(name, "__plusplus__")) {
	    Printv(pm, tab4, "\"++\" => sub { $_[0]->__plusplus__()},\n",NIL);
	  } else if (strstr(name, "__minmin__")) {
	    Printv(pm, tab4, "\"--\" => sub { $_[0]->__minmin__()},\n",NIL);
	  } else if (strstr(name, "__add__")) {
	    Printv(pm, tab4, "\"+\" => sub { $_[0]->__add__($_[1])},\n",NIL);
	  } else if (strstr(name, "__sub__")) {
	    Printv(pm, tab4, "\"-\" => sub {  if( not $_[2] ) { $_[0]->__sub__($_[1]) }\n",NIL);
	    Printv(pm, tab8, "elsif( $_[0]->can('__rsub__') ) { $_[0]->__rsub__($_[1]) }\n",NIL);
	    Printv(pm, tab8, "else { die(\"reverse subtraction not supported\") }\n",NIL);
	    Printv(pm, tab8, "},\n",NIL);
	  } else if (strstr(name, "__mul__")) {
	    Printv(pm, tab4, "\"*\" => sub { $_[0]->__mul__($_[1])},\n",NIL);
	  } else if (strstr(name, "__div__")) {
	    Printv(pm, tab4, "\"/\" => sub { $_[0]->__div__($_[1])},\n",NIL);
	  } else if (strstr(name, "__mod__")) {
	    Printv(pm, tab4, "\"%\" => sub { $_[0]->__mod__($_[1])},\n",NIL);
	    // there are no tests for this in operator_overload_runme.pl
	    // it is likely to be broken
	    //	  } else if (strstr(name, "__and__")) {
	    //	    Printv(pm, tab4, "\"&\" => sub { $_[0]->__and__($_[1])},\n",NIL);

	    // there are no tests for this in operator_overload_runme.pl
	    // it is likely to be broken
	    //	  } else if (strstr(name, "__or__")) {
	    //	    Printv(pm, tab4, "\"|\" => sub { $_[0]->__or__($_[1])},\n",NIL);
	  } else if (strstr(name, "__gt__")) {
	    Printv(pm, tab4, "\">\" => sub { $_[0]->__gt__($_[1])},\n",NIL);
          } else if (strstr(name, "__ge__")) {
            Printv(pm, tab4, "\">=\" => sub { $_[0]->__ge__($_[1])},\n",NIL);
	  } else if (strstr(name, "__not__")) {
	    Printv(pm, tab4, "\"!\" => sub { $_[0]->__not__()},\n",NIL);
	  } else if (strstr(name, "__lt__")) {
	    Printv(pm, tab4, "\"<\" => sub { $_[0]->__lt__($_[1])},\n",NIL);
          } else if (strstr(name, "__le__")) {
            Printv(pm, tab4, "\"<=\" => sub { $_[0]->__le__($_[1])},\n",NIL);
	  } else if (strstr(name, "__pluseq__")) {
	    Printv(pm, tab4, "\"+=\" => sub { $_[0]->__pluseq__($_[1])},\n",NIL);
	  } else if (strstr(name, "__mineq__")) {
	    Printv(pm, tab4, "\"-=\" => sub { $_[0]->__mineq__($_[1])},\n",NIL);
	  } else if (strstr(name, "__neg__")) {
	    Printv(pm, tab4, "\"neg\" => sub { $_[0]->__neg__()},\n",NIL);
	  } else {
	    fprintf(stderr,"Unknown operator: %s\n", name);
	  }
	}
	Printv(pm, tab4,
               "\"=\" => sub { my $class = ref($_[0]); $class->new($_[0]) },\n", NIL);
	Printv(pm, tab4, "\"fallback\" => 1;\n", NIL);
      }
      // make use strict happy
      Printv(pm, "use vars qw(%OWNER);\n", NIL);

      /* Dump out a hash table containing the pointers that we own */
      Printf(pm, "%%OWNER = ();\n");

      /* Dump out the package methods */
      Printv(pm, pcode, NIL);
      Delete(pcode);

      /* bind core swig class methods */
      Printf(f_init, "newXS(\"%s::%s::this\", SWIG_Perl_This, __FILE__);\n",
          namespace_module, ClassName);
      Printf(f_init, "newXS(\"%s::%s::DISOWN\", SWIG_Perl_Disown, __FILE__);\n",
          namespace_module, ClassName);
      Printf(f_init, "newXS(\"%s::%s::ACQUIRE\", SWIG_Perl_Acquire, __FILE__);\n",
          namespace_module, ClassName);

      Delete(operators);
      operators = 0;
    }
    CurrentClass = outer_class; 
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionCommon()
   *
   * Just hoisting the common bits of member function wrapping into a
   * common place to ease code consistency and readability
   * ------------------------------------------------------------ */
  virtual int memberfunctionCommon(Node *n, int shadow = 1) {
    if (blessed) {
      String *symname = Getattr(n, "sym:name");
      String *pname;
      String *pfunc = 0;

      if(shadow)
        pfunc = Getattr(n, "feature:shadow");
      pname = NewStringf("%s%s",
          pfunc ? "_swig_" : "",
          Equal(nodeType(n), "constructor") &&
            Equal(symname, ClassName) ? "new" : symname);
      if(pfunc) {
        String *pname_ref = NewStringf("do { \\&%s }", pname);
        Replaceall(pfunc, "$action", pname_ref);
        Delete(pname_ref);
        Append(pcode, pfunc);
      }
      Setattr(n, "perl5:name", NewStringf("%s::%s", ClassName, pname));
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    memberfunctionCommon(n);
    if (blessed && !Getattr(n, "sym:nextSibling")) {
      String *symname = Getattr(n, "sym:name");

      if (Strstr(symname, "__eq__")) {
	DohSetInt(operators, "__eq__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__ne__")) {
	DohSetInt(operators, "__ne__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__assign__")) {
	DohSetInt(operators, "__assign__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__str__")) {
	DohSetInt(operators, "__str__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__add__")) {
	DohSetInt(operators, "__add__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__sub__")) {
	DohSetInt(operators, "__sub__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__mul__")) {
	DohSetInt(operators, "__mul__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__div__")) {
	DohSetInt(operators, "__div__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__mod__")) {
	DohSetInt(operators, "__mod__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__and__")) {
	DohSetInt(operators, "__and__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__or__")) {
	DohSetInt(operators, "__or__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__not__")) {
	DohSetInt(operators, "__not__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__gt__")) {
	DohSetInt(operators, "__gt__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__ge__")) {
	DohSetInt(operators, "__ge__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__lt__")) {
	DohSetInt(operators, "__lt__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__le__")) {
	DohSetInt(operators, "__le__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__neg__")) {
	DohSetInt(operators, "__neg__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__plusplus__")) {
	DohSetInt(operators, "__plusplus__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__minmin__")) {
	DohSetInt(operators, "__minmin__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__mineq__")) {
	DohSetInt(operators, "__mineq__", 1);
	have_operators = 1;
      } else if (Strstr(symname, "__pluseq__")) {
	DohSetInt(operators, "__pluseq__", 1);
	have_operators = 1;
      }
    }
    return Language::memberfunctionHandler(n);
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   *
   * Adds an instance member.
   * ----------------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    Append(Getattr(CurrentClass, "perl5:memberVariables"), n);
    Setattr(n, "perl5:instancevariable", "1");
    return Language::membervariableHandler(n);
  }

  /* ------------------------------------------------------------
   * constructorDeclaration()
   *
   * Emits a blessed constructor for our class.    In addition to our construct
   * we manage a Perl hash table containing all of the pointers created by
   * the constructor.   This prevents us from accidentally trying to free
   * something that wasn't necessarily allocated by malloc or new
   * ------------------------------------------------------------ */

  virtual int constructorHandler(Node *n) {
    memberfunctionCommon(n);
    if (blessed) {
      String *type = NewString("SV");
      SwigType_add_pointer(type);
      Parm *p = NewParm(type, "proto");
      Delete(type);
      Setattr(n, "perl5:implicits", p);
      Delete(p);
    }
    return Language::constructorHandler(n);
  }

  /* ------------------------------------------------------------ 
   * destructorHandler()
   * ------------------------------------------------------------ */

  virtual int destructorHandler(Node *n) {
    memberfunctionCommon(n);
    Setattr(n, "perl5:destructor", n);
    return Language::destructorHandler(n);
  }

  /* ------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int staticmemberfunctionHandler(Node *n) {
    memberfunctionCommon(n);
    if (blessed && !GetFlag(n, "allocate:smartpointeraccess")) {
      /* proto is probably only appropriate if directors are enabled */
      String *type = NewString("SV");
      SwigType_add_pointer(type);
      Parm *p = NewParm(type, "proto");
      Delete(type);
      Setattr(n, "perl5:implicits", p);
      Delete(p);
    }
    return Language::staticmemberfunctionHandler(n);
  }

  /* ------------------------------------------------------------
   * staticmembervariableHandler()
   * ------------------------------------------------------------ */

  virtual int staticmembervariableHandler(Node *n) {
    memberfunctionCommon(n, 0);
    Append(Getattr(CurrentClass, "perl5:memberVariables"), n);
    return Language::staticmembervariableHandler(n);
  }

  /* ------------------------------------------------------------
   * memberconstantHandler()
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
    memberfunctionCommon(n, 0);
    return Language::memberconstantHandler(n);
  }

  /* ------------------------------------------------------------
   * pragma()
   *
   * Pragma directive.
   *
   * %pragma(perl5) code="String"              # Includes a string in the .pm file
   * %pragma(perl5) include="file.pl"          # Includes a file in the .pm file
   * ------------------------------------------------------------ */

  virtual int pragmaDirective(Node *n) {
    String *lang;
    String *code;
    String *value;
    if (!ImportMode) {
      lang = Getattr(n, "lang");
      code = Getattr(n, "name");
      value = Getattr(n, "value");
      if (Strcmp(lang, "perl5") == 0) {
	if (Strcmp(code, "code") == 0) {
	  /* Dump the value string into the .pm file */
	  if (value) {
	    Printf(pragma_include, "%s\n", value);
	  }
	} else if (Strcmp(code, "include") == 0) {
	  /* Include a file into the .pm file */
	  if (value) {
	    FILE *f = Swig_include_open(value);
	    if (!f) {
	      Printf(stderr, "%s : Line %d. Unable to locate file %s\n", input_file, line_number, value);
	    } else {
	      char buffer[4096];
	      while (fgets(buffer, 4095, f)) {
		Printf(pragma_include, "%s", buffer);
	      }
	    }
	    fclose(f);
	  }
	} else {
	  Printf(stderr, "%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
	}
      }
    }
    return Language::pragmaDirective(n);
  }

  /* ------------------------------------------------------------
   * perlcode()     - Output perlcode code into the shadow file
   * ------------------------------------------------------------ */

  String *perlcode(String *code, const String *indent) {
    String *out = NewString("");
    String *temp;
    char *t;
    if (!indent)
      indent = "";

    temp = NewString(code);

    t = Char(temp);
    if (*t == '{') {
      Delitem(temp, 0);
      Delitem(temp, DOH_END);
    }

    /* Split the input text into lines */
    List *clist = DohSplitLines(temp);
    Delete(temp);
    int initial = 0;
    String *s = 0;
    Iterator si;
    /* Get the initial indentation */

    for (si = First(clist); si.item; si = Next(si)) {
      s = si.item;
      if (Len(s)) {
	char *c = Char(s);
	while (*c) {
	  if (!isspace(*c))
	    break;
	  initial++;
	  c++;
	}
	if (*c && !isspace(*c))
	  break;
	else {
	  initial = 0;
	}
      }
    }
    while (si.item) {
      s = si.item;
      if (Len(s) > initial) {
	char *c = Char(s);
	c += initial;
	Printv(out, indent, c, "\n", NIL);
      } else {
	Printv(out, "\n", NIL);
      }
      si = Next(si);
    }
    Delete(clist);
    return out;
  }

  /* ------------------------------------------------------------
   * insertDirective()
   * 
   * Hook for %insert directive.
   * ------------------------------------------------------------ */

  virtual int insertDirective(Node *n) {
    String *code = Getattr(n, "code");
    String *section = Getattr(n, "section");

    if ((!ImportMode) && (Cmp(section, "perl") == 0)) {
      Printv(additional_perl_code, code, NIL);
    } else {
      Language::insertDirective(n);
    }
    return SWIG_OK;
  }

  String *runtimeCode() {
    String *s = NewString("");
    String *shead = Swig_include_sys("perlhead.swg");
    if (!shead) {
      Printf(stderr, "*** Unable to open 'perlhead.swg'\n");
    } else {
      Append(s, shead);
      Delete(shead);
    }
    String *serrors = Swig_include_sys("perlerrors.swg");
    if (!serrors) {
      Printf(stderr, "*** Unable to open 'perlerrors.swg'\n");
    } else {
      Append(s, serrors);
      Delete(serrors);
    }
    String *srun = Swig_include_sys("perlrun.swg");
    if (!srun) {
      Printf(stderr, "*** Unable to open 'perlrun.swg'\n");
    } else {
      Append(s, srun);
      Delete(srun);
    }
    return s;
  }

  String *defaultExternalRuntimeFilename() {
    return NewString("swigperlrun.h");
  }
};

/* -----------------------------------------------------------------------------
 * swig_perl5()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_perl5() {
  return new PERL5();
}
extern "C" Language *swig_perl5(void) {
  return new_swig_perl5();
}
