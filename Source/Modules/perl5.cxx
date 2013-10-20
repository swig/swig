/* ----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * perl5.cxx
 *
 * Perl5 language module for SWIG.
 * ------------------------------------------------------------------------- */

#include "swigmod.h"
#include "cparse.h"
static int treduce = SWIG_cparse_template_reduce(0);

#include <ctype.h>

static const char *usage = (char *) "\
Perl5 Options (available with -perl5)\n\
     -compat         - Compatibility mode\n\
     -const          - Wrap constants as constants and not variables (implies -proxy)\n\
     -cppcast        - Enable C++ casting operators\n\
     -nocppcast      - Disable C++ casting operators, useful for generating bugs\n\
     -nopm           - Do not generate the .pm file\n\
     -noproxy        - Don't create proxy classes\n\
     -proxy          - Create proxy classes\n\
     -static         - Omit code related to dynamic loading\n\
\n";

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
static String *namespace_module = 0;

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
static Hash *mangle_seen = 0;
static String *pcode = 0;	/* Perl code associated with each class */
static String *const_stubs = 0;	/* Constant stubs */
static int num_consts = 0;	/* Number of constants */
static String *var_stubs = 0;	/* Variable stubs */
static String *exported = 0;	/* Exported symbols */
static String *pragma_include = 0;
static String *additional_perl_code = 0;	/* Additional Perl code from %perlcode %{ ... %} */

static Hash *operators;
static void add_operator(const char *name, const char *oper, const char *impl) {
  if (!operators)
    operators = NewHash();
  Hash *elt = NewHash();
  Setattr(elt, "name", name);
  Setattr(elt, "oper", oper);
  Setattr(elt, "impl", impl);
  Setattr(operators, name, elt);
}

class PERL5:public Language {
public:

  PERL5():Language () {
    Clear(argc_template_string);
    Printv(argc_template_string, "items", NIL);
    Clear(argv_template_string);
    Printv(argv_template_string, "ST(%d)", NIL);
    /* will need to evaluate the viability of MI directors later */
    director_multiple_inheritance = 0;
    director_language = 1;
    director_prot_ctor_code = Copy(director_ctor_code);
    Replaceall(director_prot_ctor_code, "$nondirector_new", "SWIG_croak(\"$symname is not a public method\");");
    add_operator("__eq__", "==", "sub { $_[0]->__eq__($_[1]) }");
    add_operator("__ne__", "!=", "sub { $_[0]->__ne__($_[1]) }");
    add_operator("__assign__", "=", "sub { $_[0]->__assign__($_[1]) }");	// untested
    add_operator("__str__", "\"\"", "sub { $_[0]->__str__() }");
    add_operator("__plusplus__", "++", "sub { $_[0]->__plusplus__() }");
    add_operator("__minmin__", "--", "sub { $_[0]->__minmin__() }");
    add_operator("__add__", "+", "sub { $_[0]->__add__($_[1]) }");
    add_operator("__sub__", "-",
		 "sub {\n"
		 "    return $_[0]->__sub__($_[1]) unless $_[2];\n"
		 "    return $_[0]->__rsub__($_[1]) if $_[0]->can('__rsub__');\n" "    die(\"reverse subtraction not supported\");\n" "  }");
    add_operator("__mul__", "*", "sub { $_[0]->__mul__($_[1]) }");
    add_operator("__div__", "/", "sub { $_[0]->__div__($_[1]) }");
    add_operator("__mod__", "%", "sub { $_[0]->__mod__($_[1]) }");
    add_operator("__and__", "&", "sub { $_[0]->__and__($_[1]) }");	// untested
    add_operator("__or__", "|", "sub { $_[0]->__or__($_[1]) }");	// untested
    add_operator("__gt__", ">", "sub { $_[0]->__gt__($_[1]) }");
    add_operator("__ge__", ">=", "sub { $_[0]->__ge__($_[1]) }");
    add_operator("__not__", "!", "sub { $_[0]->__not__() }");
    add_operator("__lt__", "<", "sub { $_[0]->__lt__($_[1]) }");
    add_operator("__le__", "<=", "sub { $_[0]->__le__($_[1]) }");
    add_operator("__pluseq__", "+=", "sub { $_[0]->__pluseq__($_[1]) }");
    add_operator("__mineq__", "-=", "sub { $_[0]->__mineq__($_[1]) }");
    add_operator("__neg__", "neg", "sub { $_[0]->__neg__() }");
    add_operator("__deref__", "${}", "sub { \\ $_[0]->__deref__() }");	// smart pointer unwrap
    // TODO: operator bool(), see Examples/test-suite/operbool.i
  } ~PERL5() {
    Delete(director_prot_ctor_code);
    Delete(operators);
  }

  /* Test to see if a type corresponds to a proxy handled class */
  Node *is_shadow(SwigType *t) {
    Node *n;

    n = classLookup(t);
    if (n) {
      if (!Getattr(n, "perl5:proxy")) {
	setclassname(n);
      }
      return Getattr(n, "perl5:proxy");
    }
    return 0;
  }

  /* Test to see if a type corresponds to a director handled class */
  Node *is_directortype(SwigType *t) {
    Node *n;

    n = classLookup(t);
    return n && Swig_directorclass(n) ? n : 0;
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
    String *f_director = NewString("");
    String *f_director_h = NewString("");

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
    Swig_register_filebyname("director", f_director);
    Swig_register_filebyname("director_h", f_director_h);

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

    if (options) {
      if (Getattr(options, "directors"))
	allow_directors();
      if (Getattr(options, "dirprot"))
	allow_dirprot();
    }

    /* Create a .pm file
     * Need to strip off any prefixes that might be found in
     * the module name */

    if (no_pmfile) {
      f_pm = NewString(0);
    } else {
      if (!pmfile) {
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

    /* TODO: shouldn't perlrun.swg handle this itself? */
    if (directorsEnabled()) {
      Append(f_runtime, "#define SWIG_DIRECTORS\n");
      Swig_insert_file("director.swg", f_runtime);
    }

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
    Delete(f_pm);
    Delete(dest_package);
    Delete(underscore_module);

    /* Close all of the files */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    if (directorsEnabled()) {
      if(Len(f_director_h) > 0) {
	String *outfile_h = Getattr(n, "outfile_h");
	File *f_hdr = NewFile(outfile_h, "w", SWIG_output_files());

	if (!f_hdr) {
	  FileErrorDisplay(outfile_h);
	  SWIG_exit(EXIT_FAILURE);
	}

	Swig_banner(f_hdr);
	Printf(f_hdr, "#ifndef SWIG_%s_WRAP_H_\n", module);
	Printf(f_hdr, "#define SWIG_%s_WRAP_H_\n", module);
	Dump(f_director_h, f_hdr);
	Printf(f_hdr, "#endif /* SWIG_%s_WRAP_H_ */\n", module);

	String *filename = Swig_file_filename(outfile_h);
	Printf(f_begin, "#include \"%s\"\n\n", filename);
	Delete(filename);
      }
      if(Len(f_director) > 0) {
	Printf(f_begin, "/* ---------------------------------------------------\n");
	Printf(f_begin, " * C++ director class methods\n");
	Printf(f_begin, " * --------------------------------------------------- */\n");
	Printf(f_begin, "\n");
	Dump(f_director, f_begin);
      }
      Delete(f_director_h);
      Delete(f_director);
    }
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
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
    String *overname = 0;

    Parm *p;
    int i;
    Wrapper *f;
    char source[256], temp[256];
    String *tm;
    String *cleanup, *outarg;
    int num_saved = 0;
    int num_arguments, num_required;
    int varargs = 0;
    int dir_catch = 0;
    int need_proto = GetFlag(n, "perl5:addproto") ? 1 : 0;
    int is_implicit = 0;

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
    if (getCurrentClass() &&
        GetFlag(getCurrentClass(), "perl5:directordisown")) {
      Setattr(getCurrentClass(), "perl5:disowner", wname);
      is_implicit = 1;
    } else if (GetFlag(n, "perl5:destructor")) {
      is_implicit = 1;
    }
    if(is_implicit) {
      Printv(f->def, "SWIGCLASS_STATIC void ", wname, "(MAGIC *mg) {\n", NIL);
      emit_parameter_variables(l, f);
      emit_return_variable(n, d, f);
      emit_attach_parmmaps(l, f);
      tm = Getattr(l, "tmap:in");
      Replaceall(tm, "$input", "mg");
      Replaceall(tm, "$disown", "SWIG_POINTER_PERLMG");
      emit_action_code(n, f->code, tm);
      l = nextSibling(l);
      String *actioncode = emit_action(n);
      Append(f->code, actioncode);

      Append(f->code, "fail:\n"	/* this actually can't ever fail in this context */
	     "  return;\n" "}");
      Wrapper_print(f, f_wrappers);
      DelWrapper(f);
      return SWIG_OK;
    }
    if (GetFlag(n, "perl5:instancevariable")) {
      int addfail = 1;
      Printv(f->def, "SWIGCLASS_STATIC int ", wname, "(pTHX_ SV *sv, MAGIC *mg) {\n", NIL);
      Wrapper_add_local(f, "argvi", "int argvi = 0");
      emit_parameter_variables(l, f);
      emit_return_variable(n, d, f);
      emit_attach_parmmaps(l, f);

      /* recover self pointer */
      tm = Getattr(l, "tmap:in");
      Replaceall(tm, "$input", "mg");
      Replaceall(tm, "$disown", "SWIG_POINTER_PERLMG");
      emit_action_code(n, f->code, tm);
      l = nextSibling(l);

      if (SwigType_type(d) == T_VOID) {
	Setattr(n, "perl5:setter", wname);
	tm = Getattr(l, "tmap:in");
	if (!tm) {
	  Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to set an attribute of type %s.\n", SwigType_str(Getattr(l, "type"), 0));
	  return SWIG_NOWRAP;
	}
	Replaceall(tm, "$input", "sv");
	Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
	Swig_director_emit_dynamic_cast(n, f);
	emit_action_code(n, f->code, tm);
	emit_action_code(n, f->code, Getattr(n, "wrap:action"));
	addfail = 1;
      } else {
	Setattr(n, "perl5:getter", wname);
	Swig_director_emit_dynamic_cast(n, f);
	String *actioncode = emit_action(n);
	SwigType *t = Getattr(n, "type");
	tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode);
	if (!tm) {
	  Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to get an attribute of type %s.\n", SwigType_str(t, 0), name);
	  return SWIG_NOWRAP;
	}
	Wrapper_add_local(f, "dest", "SV *dest");
	Replaceall(tm, "$result", "dest");
	//Replaceall(tm, "$source", Swig_cresult_name());
	//Replaceall(tm, "$target", "ST(argvi)");
	//Replaceall(tm, "$result", "ST(argvi)");
	Replaceall(tm, "$owner", "0");
	Printv(f->code, tm, "\n", "SvSetSV(sv, dest);\n", NIL);
      }
      Append(f->code, "return 0;\n");
      if (addfail) {
	Append(f->code, "fail:\n" "croak(Nullch);\n" "return 0;\n");
      }
      Append(f->code, "}");
      Wrapper_print(f, f_wrappers);
      DelWrapper(f);
      return SWIG_OK;
    }
    cleanup = NewString("");
    outarg = NewString("");
    Printv(f->def, "XS(", wname, ") {\n", "{\n",	/* scope to destroy C++ objects before croaking */
	   NIL);

    emit_parameter_variables(l, f);
    emit_attach_parmmaps(l, f);
    Setattr(n, "wrap:parms", l);

    num_arguments = emit_num_arguments(l) + need_proto;
    num_required = emit_num_required(l) + need_proto;
    varargs = emit_isvarargs(l);

    Wrapper_add_local(f, "argvi", "int argvi = 0");

    /* Check the number of arguments */
    if (!varargs) {
      Printf(f->code, "    if ((items < %d) || (items > %d)) {\n", num_required, num_arguments);
    } else {
      Printf(f->code, "    if (items < %d) {\n", num_required);
    }
    {
      String *usage = usage_func(n);
      Printf(f->code, "        SWIG_croak(\"Usage: %s\");\n" "}\n", usage);
      Delete(usage);
    }

    /* Write code to extract parameters. */
    for (i = need_proto, p = l; i < num_arguments; i++) {

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

    if (is_member_director(n) && !is_smart_pointer()) {
      Wrapper_add_local(f, "upcall", "bool upcall");
      Printf(f->code, "{\n");
      Printf(f->code, "  Swig::Director *director = dynamic_cast<Swig::Director *>(arg1);\n");
      Printf(f->code, "  if (director) {\n");
      Printf(f->code, "    upcall = SvSTASH(SvRV(ST(0))) == SvSTASH(SvRV(director->getSelf()));\n");
      Printf(f->code, "  } else {\n");
      Printv(f->code, "    ", ((dirprot_mode() && !is_public(n)) ? "SWIG_croak(\"accessing protected member\")" : "upcall = false"), ";\n", NIL);
      Printf(f->code, "  }\n");
      Printf(f->code, "}\n");
    }
    if (getCurrentClass() && Swig_directorclass(getCurrentClass())) {
      Swig_require("perl5:functionWrapper", n, "?catchlist", NIL);
      /* TODO: the type system doesn't know about the DirectorException
       * class, so this is cheating. */
      SwigType *ct = NewString("Swig::DirectorException");
      Parm *catchlist = NewParm(ct, 0, n);
      Delete(ct);
      set_nextSibling(catchlist, Getattr(n, "catchlist"));
      Setattr(n, "catchlist", catchlist);
      dir_catch = 1;
    }

    /* Now write code to make the function call */

    Swig_director_emit_dynamic_cast(n, f);
    String *actioncode = emit_action(n);

    if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode))) {
      Replaceall(tm, "$source", Swig_cresult_name());
      Replaceall(tm, "$target", "ST(argvi)");
      Replaceall(tm, "$result", "ST(argvi)");
      Replaceall(tm, "$owner", GetFlag(n, "feature:new") ? "SWIG_POINTER_OWN" : "0");
      /* TODO: this NewPointerObjP stuff is a hack */
      if (blessed && Equal(nodeType(n), "constructor")) {
	Replaceall(tm, "NewPointerObj", "NewPointerObjP");
      }
      Printf(f->code, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(d, 0), name);
    }
    if (dir_catch)
      Swig_restore(n);
    emit_return_variable(n, d, f);

    /* If there were any output args, take care of them. */

    Printv(f->code, outarg, NIL);

    /* If there was any cleanup, do that. */

    Printv(f->code, cleanup, NIL);

    if (GetFlag(n, "feature:new")) {
      if ((tm = Swig_typemap_lookup("newfree", n, Swig_cresult_name(), 0))) {
	Replaceall(tm, "$source", Swig_cresult_name());
	Printf(f->code, "%s\n", tm);
      }
    }

    if ((tm = Swig_typemap_lookup("ret", n, Swig_cresult_name(), 0))) {
      Replaceall(tm, "$source", Swig_cresult_name());
      Printf(f->code, "%s\n", tm);
    }

    if (GetFlag(n, "feature:new") && is_directortype(d)) {
      Append(f->code, "  {\n");
      Append(f->code, "    Swig::Director *director = dynamic_cast<Swig::Director *>(result);\n");
      Append(f->code, "    if (director) director->setSelf(ST(0));\n");
      Append(f->code, "  }\n");
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
      Printf(f_init, "newXS((char *)\"%s::%s\", %s, (char *)__FILE__);\n", namespace_module, pname, wname);
    } else if (!Getattr(n, "sym:nextSibling")) {
      /* Generate overloaded dispatch function */
      /* TODO: this is overly complicated by the lies about the argument count for need_proto */
      int maxargs;
      String *dispatch = Swig_overload_dispatch_cast(n,
	need_proto
	  ? "ax--; items++; PUSHMARK(MARK); SWIG_CALLXS(%s); return;"
	  : "PUSHMARK(MARK); SWIG_CALLXS(%s); return;",
	  &maxargs);

      /* Generate a dispatch wrapper for all overloaded functions */

      Wrapper *df = NewWrapper();
      String *dname = Swig_name_wrapper(iname);

      Printv(df->def, "XS(", dname, ") {\n", NIL);

      Wrapper_add_local(df, "dXSARGS", "dXSARGS");
      if (need_proto)
	Printv(df->code, "ax++; items--;\n", NIL);
      Printv(df->code, dispatch, "\n", NIL);
      if (need_proto)
	Printv(df->code, "ax--; items++;\n", NIL);
      Printf(df->code, "croak(\"No matching function for overloaded '%s'\");\n", pname);
      Printf(df->code, "XSRETURN(0);\n");
      Printv(df->code, "}\n", NIL);
      Wrapper_print(df, f_wrappers);
      Printf(f_init, "newXS((char *)\"%s::%s\", %s, (char *)__FILE__);\n", namespace_module, pname, dname);
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

      tmp = Swig_name_set(NSPACE_TODO, iname);
      setf = Swig_name_wrapper(tmp);
      Delete(tmp);
      Setattr(n, "wrap:name", setf);
      Printv(f->def, "SWIGCLASS_STATIC int ", setf, "(pTHX_ SV *sv, MAGIC *mg) {\n", NIL);
      tm = Swig_typemap_lookup("varin", n, name, f);
      if (!tm) {
	Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number, "Unable to set variable of type %s.\n", SwigType_str(type, 0));
	DelWrapper(f);
	return SWIG_NOWRAP;
      }
      Replaceall(tm, "$source", "sv");
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$input", "sv");
      emit_action_code(n, f->code, tm);
      Append(f->code, "  return 0;\n" "fail:\n" "  croak(Nullch);\n" "  return 0;\n" "}\n");
      Wrapper_print(f, f_wrappers);
      DelWrapper(f);
    } else {
      setf = NewString("0");
    }
    {
      /* emit getter */
      int addfail;
      tmp = Swig_name_get(NSPACE_TODO, iname);
      getf = Swig_name_wrapper(tmp);
      Delete(tmp);
      f = NewWrapper();
      Setattr(n, "wrap:name", getf);
      Printv(f->def, "SWIGCLASS_STATIC int ", getf, "(pTHX_ SV *sv, MAGIC *mg) {\n", NIL);
      tm = Swig_typemap_lookup("varout", n, name, f);
      if (!tm) {
	Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number, "Unable to read variable of type %s\n", SwigType_str(type, 0));
	DelWrapper(f);
	return SWIG_NOWRAP;
      }
      Replaceall(tm, "$target", "sv");
      Replaceall(tm, "$result", "sv");
      Replaceall(tm, "$source", name);
      addfail = emit_action_code(n, f->code, tm);
      Append(f->code, "  return 0;\n");
      if (addfail) {
	Append(f->code, "fail:\n" "  croak(Nullch);\n" "  return 0;\n");
      }
      Append(f->code, "}\n");
      Wrapper_print(f, f_wrappers);
      DelWrapper(f);
    }

    {
      String *vtbl = NewStringf("_swig_perl_vtbl_%s", iname);

      Printf(f_wrappers, "MGVTBL %s = SWIG_Perl_VTBL(%s, %s);\n", vtbl, getf, setf);

      Setattr(n, "perl5:vtbl", vtbl);

      Printf(f_init, "SWIG_Perl_WrapVar(get_sv(\"%s::%s\", TRUE | GV_ADDMULTI), &%s, 0);\n", namespace_module, pname, vtbl);
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
	/* TODO: this should use newXS() to avoid the global scalar */
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
  String *usage_func(Node *n) {
    ParmList *p = Getattr(n, "parms");
    String *pcall = 0;
    String *pname = 0;

    pname = Getattr(n, "perl5:name");
    if (!pname)
      pname = Getattr(n, "sym:name");

    pcall = NewStringf("%s::%s(", namespace_module, pname);
    if (getCurrentClass()) {
      String *classname = Getattr(getCurrentClass(), "sym:name");
      if (GetFlag(n, "perl5:addproto")) {
	/* class method, change the last "::" to "->" */
	String *src = NewStringf("%s::", classname);
	String *dst = NewStringf("%s->", classname);
	Replace(pcall, src, dst, DOH_REPLACE_FIRST);
	Delete(src);
	Delete(dst);
      } else if (p && GetFlag(p, "hidden") && Equal(Getattr(p, "name"), "self")) {
	String *src = NewStringf("%s::", classname);
	String *dst = NewStringf("[%s::%s object]->",
				 namespace_module, classname);
	pcall = NewStringf("%s(", pname);
	Replace(pcall, src, dst, DOH_REPLACE_FIRST);
	p = nextSibling(p);
	Delete(src);
	Delete(dst);
      }
    }

    /* Now go through and print parameters */
    for (int i = 0; p; p = nextSibling(p)) {
      SwigType *pt = Getattr(p, "type");
      String *pn = Getattr(p, "name");
      if (checkAttribute(p, "tmap:in:numinputs", "0"))
	continue;

      if (i > 0)
	Append(pcall, ",");
      /* If parameter has been named, use that.   Otherwise, just print a type  */
      if (SwigType_type(pt) != T_VOID) {
	if (Len(pn) > 0) {
	  Append(pcall, pn);
	} else {
	  Append(pcall, SwigType_str(pt, 0));
	}
      }
      i = 1;
    }
    Append(pcall, ");");
    return pcall;
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
    Printf(f_init, "newXS((char *)\"%s::%s\", %s, (char *)__FILE__);\n", namespace_module, iname, wname);

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
    String *name = 0;		/* Real name of C/C++ class */
    String *fullclassname = 0;
    String *outer_nc = 0;

    Setattr(n, "perl5:memberVariables", NewList());

    if (blessed) {

      String *classname = Getattr(n, "sym:name");
      if (!addSymbol(classname, n))
	return SWIG_ERROR;

      /* Use the fully qualified name of the Perl class */
      if (!compat) {
	fullclassname = NewStringf("%s::%s", namespace_module, classname);
      } else {
	fullclassname = NewString(classname);
      }

      outer_nc = none_comparison;
      none_comparison = NewStringf("strNE(SvPV_nolen(ST(0)), \"%s\") && " "sv_derived_from(ST(0), \"%s\")", fullclassname, fullclassname);

      name = Getattr(n, "name");
      pcode = NewString("");
      // blessedmembers = NewString("");
    }

    /* Emit all of the members */
    int rv = Language::classHandler(n);

    if (rv != SWIG_OK)
      return rv;


    /* Finish the rest of the class */
    if (blessed) {
      Printv(pm, "\n", "############# Class : ", fullclassname, " ##############\n", "package ", fullclassname, ";\n", NIL);

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
	if (begun)
	  Append(pm, ";\n");
      }

      /* tell interpreter about class attributes */
      {
	SwigType *ct = Copy(name);
	String *mang;

	SwigType_add_pointer(ct);
	mang = SwigType_manglestr(ct);
	/* mangle_seen is to avoid emitting type information for types SwigType_remember_clientdata does not consider to be different, it's a hack.  I
	 * think the problem this workaround is needed for is in typesys/symbol management. */
	if (!mangle_seen)
	  mangle_seen = NewHash();
	if (!Getattr(mangle_seen, mang)) {
	  /* declare attribute bindings */
	  int nattr = 0;
	  int nfield = 0;
	  List *bases = Getattr(n, "bases");

	  if (bases)
	    bases = Copy(bases);
	  else
	    bases = NewList();
	  Insert(bases, 0, n);
	  Printv(pm, "use fields (", NIL);
	  for (int i = Len(bases); i > 0; i--) {
	    Node *iclass = Getitem(bases, i - 1);

	    for (Iterator j = First(Getattr(iclass, "perl5:memberVariables")); j.item; j = Next(j)) {
	      Node *ch = j.item;

	      /* XS side */
	      String *vtbl = Getattr(ch, "perl5:vtbl");
	      if (vtbl) {
		vtbl = Copy(vtbl);
	      } else {
		String *getf = Getattr(ch, "perl5:getter");
		String *setf = Getattr(ch, "perl5:setter");

		if (!getf)
		  continue;
		vtbl = NewStringf("SWIG_Perl_VTBL(%s, %s)", getf, setf ? setf : "0");
	      }
	      String *chn = Getattr(ch, "sym:name");
	      if (nattr == 0) {
		Printv(f_wrappers, "static swig_perl_type_ext_var _swigt_ext_var_", mang, "[] = {\n", NIL);
	      } else {
		Append(f_wrappers, ",\n");
	      }
	      Printv(f_wrappers, "  { \"", chn, "\", ", vtbl, " }", NIL);
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
	  {
	    Node *destroy = Getattr(n, "perl5:destructor");
	    String *disowner = Getattr(n, "perl5:disowner");
	    if (nattr)
	      Append(f_wrappers, "\n};\n");
	    Printf(f_wrappers, "static swig_perl_type_ext _swigt_ext_%s = SWIG_Perl_TypeExt(\"%s\", %s, %s, %d, ",
		   mang, fullclassname,
		   destroy ? Getattr(destroy, "wrap:name") : "0",
		   disowner ? disowner : "0",
		   nattr);
	    if (nattr)
	      Printf(f_wrappers, "_swigt_ext_var_%s);\n\n", mang);
	    else
	      Printf(f_wrappers, "0);\n\n");
	  }
	  Delete(bases);
	  {
	    String *tmp = NewStringf("&_swigt_ext_%s", mang);
	    SwigType_remember_clientdata(ct, tmp);
	    Delete(tmp);
	  }
	  Setattr(mangle_seen, mang, "1");
	  Delete(mang);
	  Delete(ct);
	}
      }

      List *opers = Getattr(n, "perl5:operators");
      if (opers) {
	int assign = 0;
	int deref = 0;
	Printf(pm, "use overload\n");
	for (Iterator ki = First(opers); ki.item; ki = Next(ki)) {
	  String *name = Getattr(ki.item, "name");
	  Printf(pm, "  '%s' => %s,\n", Getattr(ki.item, "oper"), Getattr(ki.item, "impl"));
	  if (Strcmp(name, "__assign__") == 0) {
	    assign = 1;
	  } else if (Strcmp(name, "__deref__") == 0) {
	    deref = 1;
	  }
	}
	if (!assign)
	  Append(pm, "  '=' => sub { ref($_[0])->new($_[0]) },\n");
	if (!deref)
	  Append(pm, "  '${}' => sub { \\ ( $_[0]->_swig_this ) },\n");
	Append(pm, "  'fallback' => 1;\n");
      }

      /* Dump out the package methods */
      Printv(pm, pcode, NIL);
      Delete(pcode);

      /* bind core swig class methods */
      String *classname = Getattr(n, "sym:name");
      Printf(f_init, "newXS((char *)\"%s::%s::_swig_this\", SWIG_Perl_This, (char *)__FILE__);\n", namespace_module, classname);
      Printf(f_init, "newXS((char *)\"%s::%s::_swig_own\", SWIG_Perl_Own, (char *)__FILE__);\n", namespace_module, classname);

      Delete(none_comparison);
      none_comparison = outer_nc;
    }
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

      if (shadow)
	pfunc = Getattr(n, "feature:shadow");
      String *classname = Getattr(getCurrentClass(), "sym:name");
      pname = NewStringf("%s%s", pfunc ? "_swig_" : "", Equal(nodeType(n), "constructor") && Equal(symname, classname) ? "new" : symname);
      if (pfunc) {
	String *pname_ref = NewStringf("do { \\&%s }", pname);
	Replaceall(pfunc, "$action", pname_ref);
	Delete(pname_ref);
	Append(pcode, pfunc);
      }
      Setattr(n, "perl5:name", NewStringf("%s::%s", classname, pname));
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    memberfunctionCommon(n);
    if (blessed && !Getattr(n, "sym:nextSibling")) {
      Hash *oper = Getattr(operators, Getattr(n, "sym:name"));

      if (oper) {
	List *class_oper = Getattr(getCurrentClass(), "perl5:operators");
	if (!class_oper) {
	  class_oper = NewList();
	  Setattr(getCurrentClass(), "perl5:operators", class_oper);
	}
	Append(class_oper, oper);
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
    Append(Getattr(getCurrentClass(), "perl5:memberVariables"), n);
    SetFlag(n, "perl5:instancevariable");
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
    if (blessed && !Swig_directorclass(getCurrentClass()))
      SetFlag(n, "perl5:addproto");
    return Language::constructorHandler(n);
  }

  /* ------------------------------------------------------------ 
   * destructorHandler()
   * ------------------------------------------------------------ */

  virtual int destructorHandler(Node *n) {
    memberfunctionCommon(n);
    Setattr(getCurrentClass(), "perl5:destructor", n);
    SetFlag(n, "perl5:destructor");
    return Language::destructorHandler(n);
  }

  /* ------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int staticmemberfunctionHandler(Node *n) {
    memberfunctionCommon(n);
    if (blessed && !GetFlag(n, "allocate:smartpointeraccess"))
      SetFlag(n, "perl5:addproto");
    return Language::staticmemberfunctionHandler(n);
  }

  /* ------------------------------------------------------------
   * staticmembervariableHandler()
   * ------------------------------------------------------------ */

  virtual int staticmembervariableHandler(Node *n) {
    memberfunctionCommon(n, 0);
    Append(Getattr(getCurrentClass(), "perl5:memberVariables"), n);
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
   * a (sloppy) crack at directors
   * ------------------------------------------------------------ */

  virtual int classDirector(Node *n) {
    return Language::classDirector(n);
  }

  virtual int classDirectorInit(Node *n) {
    String *decl = Swig_director_declaration(n);
    Printv(Swig_filebyname("director_h"), decl, "\n  public:\n", NIL);
    Delete(decl);
    return Language::classDirectorInit(n);
  }

  virtual int classDirectorConstructors(Node *n) {
    return Language::classDirectorConstructors(n);
  }

  virtual int classDirectorConstructor(Node *n) {
    ParmList *parms = Getattr(n, "parms");
    String *mdecl = NewStringf("");
    String *mdefn = NewStringf("");
    String *signature;
    String *name = NewStringf("SwigDirector_%s", Getattr(parentNode(n), "sym:name"));

    {
      /* resolve the function signature */
      String *type = NewString("SV");
      SwigType_add_pointer(type);
      Parm *p = NewParm(type, "proto", n);
      Delete(type);
      set_nextSibling(p, Getattr(n, "parms"));
      Setattr(n, "parms", p);
      signature = Swig_method_decl(Getattr(n, "type"), Getattr(n, "decl"), "$name", p, 0, 0);
    }
    {
      /* prep method decl */
      String *target = Copy(signature);
      Replaceall(target, "$name", name);
      Printf(mdecl, "    %s;\n", target);
      Delete(target);
    }
    {
      /* prep method defn */
      String *qname;
      String *target;
      String *scall;
      qname = NewStringf("%s::%s", name, name);
      target = Copy(signature);
      Replaceall(target, "$name", qname);
      Delete(qname);
      scall = Swig_csuperclass_call(0, Getattr(parentNode(n), "classtype"), parms);
      Printf(mdefn, "%s : %s, Swig::Director() {\n" "}\n", target, scall);
      Delete(target);
      Delete(scall);
    }
    Dump(mdecl, Swig_filebyname("director_h"));
    Dump(mdefn, Swig_filebyname("director"));
    Delete(signature);
    Delete(mdecl);
    Delete(mdefn);
    return Language::classDirectorConstructor(n);
  }

  virtual int classDirectorDefaultConstructor(Node *n) {
    return Language::classDirectorDefaultConstructor(n);
  }

  virtual int classDirectorDestructor(Node *n) {
    return Language::classDirectorDestructor(n);
  }

  virtual int classDirectorMethods(Node *n) {
    return Language::classDirectorMethods(n);
  }

  virtual int classDirectorMethod(Node *n, Node *parent, String *super) {
    int status = SWIG_OK;
    String *name = Getattr(n, "name");
    String *decl = Getattr(n, "decl");
    String *type = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");

    String *target = Swig_method_decl(Getattr(n, "conversion_operator") ? 0 : Getattr(n, "classDirectorMethods:type"),
				      decl, "$name", l, 0, 0);
    String *mdecl;
    String *mdefn;

    {
      /* build method declaration */
      ParmList *throws = Getattr(n, "throws");

      if (throws || Getattr(n, "throw")) {
	String *tm;
	String *tmp;
	bool needComma = false;

	Append(target, " throw(");
	Swig_typemap_attach_parms("throws", throws, 0);
	while (throws) {
	  tm = Getattr(throws, "tmap:throws");
	  if (tm) {
	    tmp = SwigType_str(Getattr(throws, "type"), NULL);
	    if (needComma)
	      Append(target, ", ");
	    else
	      needComma = true;
	    Append(target, tmp);
	    Delete(tmp);
	    Delete(tm);
	  }
	  throws = nextSibling(throws);
	}
	Append(target, ")");
      }

      mdecl = NewStringf("    virtual %s;\n", target);
      Replaceall(mdecl, "$name", name);

      if (dirprot_mode() && !is_public(n))
	if (Cmp(Getattr(n, "storage"), "virtual") || Cmp(Getattr(n, "value"), "0")) {
	  /* expose protected methods via an extra public inline method */
	  String *upcall = Swig_method_call(super, l);
	  String *pname = NewStringf("%sSwigPublic", name);
	  String *pdecl = NewStringf("    virtual %s", target);

	  Replaceall(pdecl, "$name", pname);
	  Printf(pdecl, " { %s%s; }\n", (SwigType_type(type) != T_VOID ? "return " : ""), upcall);
	  Append(mdecl, pdecl);

	  Delete(pdecl);
	  Delete(pname);
	  Delete(upcall);
	}
    }

    {
      /* build method definition */
      String *tm;
      Wrapper *w = NewWrapper();
      String *qname = NewStringf("SwigDirector_%s::%s", Swig_class_name(parent), name);
      int pc = 0;
      int outputs = SwigType_type(type) != T_VOID ? 1 : 0;
      String *tmp;

      Printf(w->def, "%s {", target);
      Replaceall(w->def, "$name", qname);

      if (GetFlag(n, "feature:ignore")) {
	String *upcall = Swig_method_call(super, l);

	Printf(w->code, "%s%s;\n", (SwigType_type(type) != T_VOID ? "return " : ""), upcall);
	Delete(upcall);
      } else {
	Swig_director_parms_fixup(l);
	Swig_typemap_attach_parms("in", l, 0);
        Swig_typemap_attach_parms("directorin", l, 0);
        Swig_typemap_attach_parms("directorargout", l, 0);

        Wrapper_add_local(w, "SP", "dSP");
        Printf(w->code, "  av[%d] = this->Swig::Director::getSelf();\n", pc++);

        for (ParmList *p = l; p;) {
	  if (checkAttribute(p, "tmap:in:numinputs", "0")) {
	    p = Getattr(p, "tmap:in:next");
	    continue;
	  }

	  if (Getattr(p, "tmap:directorargout") != 0)
	    outputs++;

	  if ((tm = Getattr(p, "tmap:directorin")) != 0) {
	    String *input = NewStringf("av[%d]", pc++);
	    Replaceall(tm, "$input", input);
	    Replaceall(tm, "$owner", "0");
	    Printf(w->code, "  %s\n", tm);
	    Printf(w->code, "  sv_2mortal(%s);\n", input);
	    p = Getattr(p, "tmap:directorin:next");
	    Delete(input);
	    continue;
	  }

	  if (SwigType_type(type) == T_VOID) {
	    p = nextSibling(p);
	    continue;
	  }

	  Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file, line_number,
		       "Unable to use type %s as a function argument in director method %s::%s (skipping method).\n",
		       SwigType_str(Getattr(p, "type"), 0), Swig_class_name(parent), target);
	  status = SWIG_NOWRAP;
	}

	Append(w->code, "  ENTER;\n");
	Append(w->code, "  SAVETMPS;\n");
	Append(w->code, "  PUSHMARK(SP);\n");

	tmp = NewStringf("SV *av[%d]", pc);
	Wrapper_add_local(w, "av", tmp);
	for (int i = 0; i < pc; i++)
	  Printf(w->code, "  XPUSHs(av[%d]);\n", i);
	Delete(tmp);
	Append(w->code, "  PUTBACK;\n");

	if (outputs) {
	  Wrapper_add_local(w, "c_count", "I32 c_count");
	  Printf(w->code, "c_count = call_method(\"%s\", G_EVAL | G_SCALAR);\n", name);
	} else {
	  Printf(w->code, "call_method(\"%s\", G_EVAL | G_VOID);\n", name);
	}

	{
	  String *tm;
	  if ((tm = Swig_typemap_lookup("director:except", n, Swig_cresult_name(), 0))) {
	    /* no op */
	  } else if ((tm = Getattr(n, "feature:director:except"))) {
	    tm = Copy(tm);
	  } else {
	    tm = NewString("if ($error) Swig::DirectorMethodException::raise($error);");
	  }
	  Replaceall(tm, "$error", "err");
	  Append(w->code, "if (SvTRUE(ERRSV)) {\n");
	  Append(w->code, "  SV *err = newSVsv(ERRSV);\n");
	  Append(w->code, "  FREETMPS;\n");
	  Append(w->code, "  LEAVE;\n");
	  Append(w->code, tm);
	  Append(w->code, "}\n");
	}

	if (outputs) {
	  int outnum = 0;
	  Wrapper_add_local(w, "ax", "I32 ax");
	  Append(w->code, "  SPAGAIN;\n");
	  Append(w->code, "  SP -= c_count;\n");
	  Append(w->code, "  ax = (SP - PL_stack_base) + 1;\n");
	  if (SwigType_type(type) != T_VOID) {
	    String *tm = Swig_typemap_lookup("directorout", n, Swig_cresult_name(), w);
	    if (tm) {
	      String *tmp = NewStringf("ST(%d)", outnum++);
	      Replaceall(tm, "$result", "c_result");
	      Replaceall(tm, "$input", tmp);
	      //if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:out:disown"))) {
	      //  Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
	      //} else {
	      Replaceall(tm, "$disown", "0");
	      Delete(tmp);
	      Printf(w->code, "{\n%s\n}\n", tm);
	      //}
	    } else {
	      Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number,
			   "Unable to use return type %s in director method %s::%s (skipping method).\n", SwigType_str(type, 0), Swig_class_name(parent), target);
	      status = SWIG_ERROR;
	    }
	  }

	  for (ParmList *p = l; p;) {
	    tm = Getattr(p, "tmap:directorargout");
	    if (tm) {
	      String *input = NewStringf("ST(%d)", outnum++);
	      Replaceall(tm, "$input", input);
	      Replaceall(tm, "$result", Getattr(p, "name"));
	      Printf(w->code, "%s\n", tm);
	      p = Getattr(p, "tmap:directorargout:next");
	    } else {
	      p = nextSibling(p);
	    }
	  }
	  Append(w->code, "PUTBACK;\n");
	}
	Append(w->code, "  FREETMPS;\n" "  LEAVE;\n");
	if (SwigType_type(type) != T_VOID) {
	  String *rval = SwigType_lstr(type, "c_result");
	  String *cast = SwigType_str(type, 0);

	  Wrapper_add_local(w, "c_result", rval);
	  Printf(w->code, "return (%s) %sc_result;\n", cast, SwigType_isreference(type) ? "*" : "");
	  Delete(cast);
	  Delete(rval);
	} else {
	  Printf(w->code, "return;\n");
	}
      }

      Printf(w->code, "}");

      mdefn = NewString("");
      Wrapper_print(w, mdefn);
      Delete(qname);
      DelWrapper(w);
    }

    if (status == SWIG_OK) {
      Dump(mdecl, Swig_filebyname("director_h"));
      /* needed for special_variables.cpptest */
      Replaceall(mdefn, "$symname", Getattr(n, "sym:name"));
      Dump(mdefn, Swig_filebyname("director"));
    }
    Delete(mdefn);
    Delete(mdecl);
    Delete(target);
    return status;
  }

  virtual int classDirectorEnd(Node *n) {
    Printf(Swig_filebyname("director_h"), "};\n");
    return Language::classDirectorEnd(n);
  }

  virtual int classDirectorDisown(Node *n) {
    int rv;
    Swig_save("perl5classDirectorDisown", n, "perl5:directordisown", NIL);
    SetFlag(n, "perl5:directordisown");
    rv = Language::classDirectorDisown(n);
    Swig_restore(n);
    return rv;
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
	      Swig_error(input_file, line_number, "Unable to locate file %s\n", value);
	    } else {
	      char buffer[4096];
	      while (fgets(buffer, 4095, f)) {
		Printf(pragma_include, "%s", buffer);
	      }
	      fclose(f);
	    }
	  }
	} else {
	  Swig_error(input_file, line_number, "Unrecognized pragma.\n");
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
    List *clist = SplitLines(temp);
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
