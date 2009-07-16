/*
 *  OBJC.cxx
 *  Module file for Objective-C support
 */

#include "swigmod.h"
#include <ctype.h>


class OBJC:public Language {
protected:
  static const char *usage;
  const String *empty_string;

  Hash *swig_types_hash;
  File *f_ocpp_h;
  File *f_ocpp_mm;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  File *f_proxy_h;
  File *f_proxy_m;

  bool proxy_flag;		// Flag for generating proxy classes
  bool native_function_flag;	// Flag for when wrapping a native function
  bool static_flag;		// Flag for when wrapping a static functions or member variables
  bool variable_wrapper_flag;	// Flag for when wrapping a nonstatic member variable

  String *ocpp_h_code;		// Code for Objective-C++ header
  String *proxy_h_code;		// Code for Objective-C proxy header
  String *proxy_m_code;		// Code for Objective-C proxy implementation

  String *proxy_class_name;	// Name of the proxy class
  String *variable_name;	// Name of a variable being wrapped
  String *proxy_class_decl;
  String *proxy_class_def;

public:
   OBJC():empty_string(NewString("")),
      swig_types_hash(NULL),
      f_ocpp_h(NULL),
      f_ocpp_mm(NULL),
      f_proxy_h(NULL),
      f_proxy_m(NULL),
      f_runtime(NULL),
      f_header(NULL),
      f_wrappers(NULL),
      f_init(NULL),
      native_function_flag(false),
      static_flag(false),
      variable_wrapper_flag(false),
      proxy_flag(true),
      proxy_class_name(NULL), variable_name(NULL), proxy_class_def(NULL), proxy_class_decl(NULL), ocpp_h_code(NULL), proxy_h_code(NULL), proxy_m_code(NULL) {
  } virtual void main(int argc, char *argv[]) {
    SWIG_library_directory("objc");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if ((strcmp(argv[i], "-noproxy") == 0)) {
	  Swig_mark_arg(i);
	  proxy_flag = false;
	} else if (strcmp(argv[i], "-help") == 0) {
	  Printf(stdout, "%s\n", usage);
	}
      }
    }

    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGOBJC 1", 0);

    // Add typemap definitions
    SWIG_typemap_lang("objc");

    // Set config file
    SWIG_config_file("objc.swg");

    allow_overloading();
  }


  /* -----------------------------------------------------------------------------
   * emitBanner()
   * ----------------------------------------------------------------------------- */

  void emitBanner(File *f) {
    Printf(f, "/* ----------------------------------------------------------------------------\n");
    Swig_banner_target_lang(f, " *");
    Printf(f, " * ----------------------------------------------------------------------------- */\n\n");
  }

  /* -----------------------------------------------------------------------------
   * top()
   * ----------------------------------------------------------------------------- */

  virtual int top(Node *n) {
    // Get the module name
    String *modulename = Getattr(n, "name");

    String *file_h = NewStringf("%sWrapper.h", modulename);
    String *file_mm = NewStringf("%sWrapper.mm", modulename);

    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    // Register file targets with the SWIG file handler
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    Printf(f_runtime, "\n");
    Printf(f_runtime, "#define SWIGOBJC\n");
    Printf(f_runtime, "\n");

    Swig_name_register((char *) "wrapper", (char *) "ObjCPP_%f");

    Printf(f_wrappers, "#include \"%s\"\n\n", file_h);
    Printf(f_wrappers, "extern \"C\" {\n");

    // Initialize members
    ocpp_h_code = NewString("");
    proxy_h_code = NewString("");
    proxy_m_code = NewString("");
    proxy_class_decl = NewString("");
    proxy_class_def = NewString("");
    swig_types_hash = NewHash();

    // Emit code for children
    Language::top(n);


    // Generate proxy code
    if (proxy_flag) {
      String *file_proxy_h = NewStringf("%sProxy.h", modulename);
      f_proxy_h = NewFile(file_proxy_h, "w", SWIG_output_files());
      if (!f_proxy_h) {
	FileErrorDisplay(f_proxy_h);
	SWIG_exit(EXIT_FAILURE);
      }

      String *file_proxy_m = NewStringf("%sProxy.m", modulename);
      f_proxy_m = NewFile(file_proxy_m, "w", SWIG_output_files());
      if (!f_proxy_m) {
	FileErrorDisplay(f_proxy_m);
	SWIG_exit(EXIT_FAILURE);
      }

      emitBanner(f_proxy_h);
      Printf(f_proxy_m, "#include \"%s\"\n\n", file_h);
      Printf(f_proxy_m, "#include \"%s\"\n\n", file_proxy_h);
      Printv(f_proxy_h, proxy_h_code, NIL);
      Printv(f_proxy_m, proxy_m_code, NIL);

      Delete(file_proxy_h);
      file_proxy_h = NULL;
      Delete(file_proxy_m);
      file_proxy_m = NULL;

      Delete(proxy_h_code);
      proxy_h_code = NULL;
      Delete(proxy_h_code);
      proxy_h_code = NULL;
      Close(f_proxy_m);
      Delete(f_proxy_m);
      Close(f_proxy_h);
      Delete(f_proxy_h);
    }
    // Generate low level accessors
    {
      Printf(f_wrappers, "}\n");
      f_ocpp_h = NewFile(file_h, "w", SWIG_output_files());
      if (!f_ocpp_h) {
	FileErrorDisplay(f_ocpp_h);
	SWIG_exit(EXIT_FAILURE);
      }
      f_ocpp_mm = NewFile(file_mm, "w", SWIG_output_files());
      if (!f_ocpp_mm) {
	FileErrorDisplay(f_ocpp_mm);
	SWIG_exit(EXIT_FAILURE);
      }

      Swig_banner(f_ocpp_h);
      Printf(f_ocpp_h, "\n#ifdef __cplusplus\n");
      Printf(f_ocpp_h, "extern \"C\" {\n");
      Printf(f_ocpp_h, "#endif\n\n");
      Printv(f_ocpp_h, ocpp_h_code, NIL);
      Printf(f_ocpp_h, "\n#ifdef __cplusplus\n");
      Printf(f_ocpp_h, "}\n");
      Printf(f_ocpp_h, "#endif\n");

      Dump(f_header, f_ocpp_mm);
      Dump(f_wrappers, f_ocpp_mm);
      Wrapper_pretty_print(f_init, f_ocpp_mm);

      Delete(file_h);
      file_h = NULL;
      Delete(file_mm);
      file_mm = NULL;
      Delete(ocpp_h_code);
      ocpp_h_code = NULL;

      Delete(swig_types_hash);
      swig_types_hash = NULL;
      Delete(f_header);
      Delete(f_wrappers);
      Delete(f_init);
      Delete(f_runtime);
      Close(f_ocpp_mm);
      Delete(f_ocpp_mm);
      Close(f_ocpp_h);
      Delete(f_ocpp_h);
    }

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * nativeWrapper()
   * ----------------------------------------------------------------------------- */

  virtual int nativeWrapper(Node *n) {
    String *wrapname = Getattr(n, "wrap:name");

    if (!addSymbol(wrapname, n))
      return SWIG_ERROR;

    if (Getattr(n, "type")) {
      Swig_save("nativeWrapper", n, "name", NIL);
      Setattr(n, "name", wrapname);
      native_function_flag = true;
      functionWrapper(n);
      Swig_restore(n);
      native_function_flag = false;
    } else {
      Printf(stderr, "%s : Line %d. No return type for %%native method %s.\n", input_file, line_number, Getattr(n, "wrap:name"));
    }

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * getEnumName()
   * ----------------------------------------------------------------------------- */

  String *getEnumName(SwigType *t) {
    Node *enum_name = NULL;
    Node *n = enumLookup(t);
    if (n) {
      String *symname = Getattr(n, "sym:name");
      if (symname) {
	// Add in class scope when referencing enum if not a global enum
	String *scopename_prefix = Swig_scopename_prefix(Getattr(n, "name"));
	String *proxyname = 0;
	if (scopename_prefix) {
	  proxyname = getProxyName(scopename_prefix);
	}
	if (proxyname)
	  enum_name = NewStringf("%s.%s", proxyname, symname);
	else
	  enum_name = NewStringf("%s", symname);
	Delete(scopename_prefix);
      }
    }

    return enum_name;
  }


  /* -----------------------------------------------------------------------------
   * substituteClassname()
   *
   * Substitute $objcclassname with the proxy class name for classes/structs/unions that SWIG knows about.
   * Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the C# class name. Note that the $&objcclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - cstype typemap
   * Outputs:
   *   tm - cstype typemap with $objcclassname substitution
   * Return:
   *   substitution_performed - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteClassname(SwigType *pt, String *tm) {
    bool substitution_performed = false;
    SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$objcclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteClassnameSpecialVariable(classnametype, tm, "$objcclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$*objcclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      substituteClassnameSpecialVariable(classnametype, tm, "$*objcclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$&objcclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteClassnameSpecialVariable(classnametype, tm, "$&objcclassname");
      substitution_performed = true;
      Delete(classnametype);
    }

    Delete(strippedtype);
    Delete(type);

    return substitution_performed;
  }

  /* -----------------------------------------------------------------------------
   * substituteClassnameSpecialVariable()
   * ----------------------------------------------------------------------------- */

  void substituteClassnameSpecialVariable(SwigType *classnametype, String *tm, const char *classnamespecialvariable) {
    if (SwigType_isenum(classnametype)) {
      String *enumname = getEnumName(classnametype);
      if (enumname)
	Replaceall(tm, classnamespecialvariable, enumname);
      else
	Replaceall(tm, classnamespecialvariable, NewStringf("int"));
    } else {
      String *classname = getProxyName(classnametype);
      if (classname) {
	Replaceall(tm, classnamespecialvariable, classname);	// getProxyName() works for pointers to classes too
      } else {			// use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
	String *descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(classnametype));
	Replaceall(tm, classnamespecialvariable, descriptor);

	// Add to hash table so that the type wrapper classes can be created later
	Setattr(swig_types_hash, descriptor, classnametype);
	Delete(descriptor);
      }
    }
  }

  /* -----------------------------------------------------------------------------
   * makeParameterName()
   *
   * Inputs: 
   *   n - Node
   *   p - parameter node
   *   arg_num - parameter argument number
   *   setter  - set this flag when wrapping variables
   * Return:
   *   arg - a unique parameter name
   * ----------------------------------------------------------------------------- */

  String *makeParameterName(Node *n, Parm *p, int arg_num) {

    String *arg = 0;
    String *pn = Getattr(p, "name");

    // Use C parameter name unless it is a duplicate or an empty parameter name
    int count = 0;
    ParmList *plist = Getattr(n, "parms");
    while (plist) {
      if ((Cmp(pn, Getattr(plist, "name")) == 0))
	count++;
      plist = nextSibling(plist);
    }
    String *wrn = pn ? Swig_name_warning(p, 0, pn, 0) : 0;
    arg = (!pn || (count > 1) || wrn) ? NewStringf("arg%d", arg_num) : Copy(pn);

    return arg;
  }


  /* -----------------------------------------------------------------------------
   * proxyGlobalFunctionHandler()
   *
   * C global functions are mapped to Objective-C global functions.
   * ----------------------------------------------------------------------------- */

  void proxyGlobalFunctionHandler(Node *n) {
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *ocpp_function_name = Getattr(n, "ocppfuncname");
    String *proxy_function_name = Getattr(n, "proxyfuncname");
    String *tm;
    Parm *p;
    Parm *last_parm = 0;
    int i;
    String *imcall = NewString("");
    String *return_type = NewString("");
    String *function_def = NewString("");
    String *function_decl = NewString("");

    bool setter_flag = false;

    if (!proxy_flag)
      return;

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Objective-C
    if (Getattr(n, "overload:ignore"))
      return;

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("objctype", l, NULL);
    Swig_typemap_attach_parms("objcin", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("objctype", n, "", 0))) {
      String *objctypeout = Getattr(n, "tmap:objctype:out");	// the type in the objctype typemap's out attribute overrides the type in the typemap
      if (objctypeout)
	tm = objctypeout;
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_NONE, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(t, 0));
    }

    /* Start generating the proxy function */
    const String *outattributes = Getattr(n, "tmap:objctype:outattributes");
    if (outattributes)
      Printf(function_decl, "  %s\n", outattributes);
    const String *objcattributes = Getattr(n, "feature:objc:attributes");
    if (objcattributes)
      Printf(function_decl, "  %s\n", objcattributes);

    if (static_flag)
      Printf(function_decl, "static ");

    Printf(function_decl, "%s %s(", return_type, proxy_function_name);

    Printv(imcall, "$ocppfuncname(", NIL);

    emit_mark_varargs(l);

    int gencomma = !static_flag;

    /* Output each parameter */
    for (i = 0, p = l; p; i++) {

      /* Ignored varargs */
      if (checkAttribute(p, "varargs:ignore", "1")) {
	p = nextSibling(p);
	continue;
      }

      /* Ignored parameters */
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
	continue;
      }

      /* Ignore the 'this' argument for variable wrappers */
      if (!(variable_wrapper_flag && i == 0)) {
	SwigType *pt = Getattr(p, "type");
	String *param_type = NewString("");
	if (setter_flag)
	  last_parm = p;

	/* Get the Objective-C parameter type */
	if ((tm = Getattr(p, "tmap:objctype"))) {
	  substituteClassname(t, tm);
	  const String *inattributes = Getattr(p, "tmap:objctype:inattributes");
	  Printf(param_type, "%s%s", inattributes ? inattributes : empty_string, tm);
	} else {
	  Swig_warning(WARN_NONE, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(pt, 0));
	}

	String *arg = makeParameterName(n, p, i);

	// Use typemaps to transform type used in Objective-C proxy function to the one used in intermediate code.
	if ((tm = Getattr(p, "tmap:objcin"))) {
	  substituteClassname(pt, tm);
	  Replaceall(tm, "$objcinput", arg);
	  Printv(imcall, tm, NIL);
	} else {
	  Swig_warning(WARN_NONE, input_file, line_number, "No objcin typemap defined for %s\n", SwigType_str(pt, 0));
	}

	/* Add parameter to proxy function */
	if (gencomma >= 2)
	  Printf(function_decl, ", ");
	gencomma = 2;
	Printf(function_decl, "%s %s", param_type, arg);

	Delete(arg);
	Delete(param_type);
      }
      p = Getattr(p, "tmap:in:next");
    }

    Printf(imcall, ")");
    Printf(function_decl, ")");
    Printv(function_def, function_decl, NIL);
    Printf(function_decl, ";\n");

    // Transform return type used in low level accessor to type used in Objective-C proxy function 
    if ((tm = Swig_typemap_lookup("objcout", n, "", 0))) {
      if (GetFlag(n, "feature:new"))
	Replaceall(tm, "$owner", "true");
      else
	Replaceall(tm, "$owner", "false");
      substituteClassname(t, tm);
      Replaceall(imcall, "$ocppfuncname", ocpp_function_name);
      Replaceall(tm, "$imcall", imcall);
    } else {
      Swig_warning(WARN_NONE, input_file, line_number, "No objcout typemap defined for %s\n", SwigType_str(t, 0));
    }

    Printf(function_def, " %s\n\n", tm ? (const String *) tm : empty_string);
    Printv(proxy_h_code, function_decl, NIL);
    Printv(proxy_m_code, function_def, NIL);

    Delete(function_decl);
    Delete(function_def);
    Delete(return_type);
    Delete(imcall);
  }


  /* -----------------------------------------------------------------------------
   * proxyClassFunctionHandler()
   *
   * Function called for creating an Objective-C proxy function around a c++ function 
   * Used for static and non-static C++ class function and C global functions.
   * C++ class static functions map to Objective-C "+" functions.
   * C++ class non-static functions map to Objective-C "-" functions.
   * ----------------------------------------------------------------------------- */

  void proxyClassFunctionHandler(Node *n) {
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *ocpp_function_name = Getattr(n, "ocppfuncname");
    String *proxy_function_name = Getattr(n, "proxyfuncname");
    String *tm;
    Parm *p;
    Parm *last_parm = 0;
    int i;
    String *imcall = NewString("");
    String *return_type = NewString("");
    String *function_def = NewString("");
    String *function_decl = NewString("");

    bool setter_flag = false;

    if (!proxy_flag)
      return;

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Objective-C
    if (Getattr(n, "overload:ignore"))
      return;

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("objctype", l, NULL);
    Swig_typemap_attach_parms("objcin", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("objctype", n, "", 0))) {
      String *objctypeout = Getattr(n, "tmap:objctype:out");	// the type in the objctype typemap's out attribute overrides the type in the typemap
      if (objctypeout)
	tm = objctypeout;
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_NONE, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(t, 0));
    }

    /* Start generating the proxy function */
    const String *outattributes = Getattr(n, "tmap:objctype:outattributes");
    if (outattributes)
      Printf(function_decl, "  %s\n", outattributes);
    const String *objcattributes = Getattr(n, "feature:objc:attributes");
    if (objcattributes)
      Printf(function_decl, "  %s\n", objcattributes);

    if (static_flag)
      Printf(function_decl, "+ ");
    else
      Printf(function_decl, "- ");

    Printf(function_decl, "(%s)%s", return_type, proxy_function_name);

    Printv(imcall, "$ocppfuncname(", NIL);

    if (!static_flag)
      Printf(imcall, "swigCPtr");

    emit_mark_varargs(l);

    int gencomma = !static_flag;

    /* Output each parameter, this essentially completes the function name for objective-c function */
    for (i = 0, p = l; p; i++) {
      /* Ignored varargs */
      if (checkAttribute(p, "varargs:ignore", "1")) {
	p = nextSibling(p);
	continue;
      }

      /* Ignored parameters */
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
	continue;
      }

      /* Ignore the 'this' argument for variable wrappers */
      if (!(variable_wrapper_flag && i == 0)) {
	SwigType *pt = Getattr(p, "type");
	String *param_type = NewString("");
	if (setter_flag)
	  last_parm = p;

	/* Get the Objective-C parameter type */
	if ((tm = Getattr(p, "tmap:objctype"))) {
	  substituteClassname(pt, tm);
	  const String *inattributes = Getattr(p, "tmap:objctype:inattributes");
	  Printf(param_type, "%s%s", inattributes ? inattributes : empty_string, tm);
	} else {
	  Swig_warning(WARN_NONE, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(pt, 0));
	}

	String *arg = makeParameterName(n, p, i);

	if (gencomma) {
	  Printf(imcall, ", ");
	}
	// Use typemaps to transform type used in Objective-C proxy function to type used in low level ocpp accessor
	if ((tm = Getattr(p, "tmap:objcin"))) {
	  substituteClassname(pt, tm);
	  Replaceall(tm, "$objcinput", arg);
	  Printv(imcall, tm, NIL);
	} else {
	  Swig_warning(WARN_NONE, input_file, line_number, "No objcin typemap defined for %s\n", SwigType_str(pt, 0));
	}

	/* Add parameter to proxy function */
	if (i == 0)
	  Printf(function_decl, ":");
	else
	  Printf(function_decl, " %s: ", arg);

	Printf(function_decl, " (%s)%s", param_type, arg);

	Delete(arg);
	Delete(param_type);
      }
      p = Getattr(p, "tmap:in:next");
    }

    Printf(imcall, ")");
    Printv(function_def, function_decl, NIL);
    Printf(function_decl, ";\n");

    // Transform return type used in low level accessor to type used in Objective-C proxy function 
    if ((tm = Swig_typemap_lookup("objcout", n, "", 0))) {
      if (GetFlag(n, "feature:new"))
	Replaceall(tm, "$owner", "true");
      else
	Replaceall(tm, "$owner", "false");
      substituteClassname(t, tm);
      Replaceall(imcall, "$ocppfuncname", ocpp_function_name);
      Replaceall(tm, "$imcall", imcall);
    } else {
      Swig_warning(WARN_NONE, input_file, line_number, "No objcout typemap defined for %s\n", SwigType_str(t, 0));
    }

    Printf(function_def, " %s\n\n", tm ? (const String *) tm : empty_string);
    Printv(proxy_h_code, function_decl, NIL);
    Printv(proxy_m_code, function_def, NIL);

    Delete(function_decl);
    Delete(function_def);
    Delete(return_type);
    Delete(imcall);
  }


  /* -----------------------------------------------------------------------------
   * functionWrapper()
   * ----------------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");

    String *cleanup = NewString("");
    String *outarg = NewString("");
    String *ocpp_return_type = NewString("");
    String *tm;
    Parm *p;
    int i;
    int num_arguments = 0;
    int num_required = 0;
    bool is_void_return;
    String *overloaded_name = getOverloadedName(n);

    if (!Getattr(n, "sym:overloaded")) {
      if (!addSymbol(Getattr(n, "sym:name"), n))
	return SWIG_ERROR;
    }

    Wrapper *f = NewWrapper();
    String *wname = Swig_name_wrapper(overloaded_name);

    Swig_typemap_attach_parms("ocpptype", l, f);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("ocpptype", n, "", 0))) {
      String *ocpptypeout = Getattr(n, "tmap:ocpptype:out");	// the type in the ocpptype typemap's out attribute overrides the type in the typemap
      if (ocpptypeout)
	tm = ocpptypeout;
      Printf(ocpp_return_type, "%s", tm);
    } else {
      Swig_warning(WARN_NONE, input_file, line_number, "No ocpptype typemap defined for %s\n", SwigType_str(t, 0));
    }

    is_void_return = (Cmp(ocpp_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f, "oresult", ocpp_return_type, "oresult", NIL);

    Printv(f->def, ocpp_return_type, " ", wname, "(", NIL);
    Printv(ocpp_h_code, ocpp_return_type, " ", wname, "(", NIL);

    // Emit all of the local variables for holding arguments.
    emit_parameter_variables(l, f);

    // Attach the standard typemaps
    emit_attach_parmmaps(l, f);

    // Parameter overloading
    Setattr(n, "wrap:parms", l);
    Setattr(n, "wrap:name", wname);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Objective-C
    if (Getattr(n, "sym:overloaded")) {
      // Emit warnings for the few cases that can't be overloaded in Objective-C and give up on generating wrapper
      Swig_overload_check(n);
      if (Getattr(n, "overload:ignore"))
	return SWIG_OK;
    }
    // Get number of required and total arguments
    num_arguments = emit_num_arguments(l);
    num_required = emit_num_required(l);
    int gencomma = 0;

    // Now walk the function parameter list and generate code to get arguments
    for (i = 0, p = l; i < num_arguments; i++) {

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *ln = Getattr(p, "lname");
      String *ocpp_param_type = NewString("");
      String *arg = NewString("");

      Printf(arg, "o%s", ln);

      if ((tm = Getattr(p, "tmap:ocpptype"))) {
	const String *inattributes = Getattr(p, "tmap:ocpptype:inattributes");
	Printf(ocpp_param_type, "%s%s", inattributes ? inattributes : empty_string, tm);
      } else {
	Swig_warning(WARN_NONE, input_file, line_number, "No ocpptype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      // Add parameter to the objcpp function
      Printv(f->def, gencomma ? ", " : "", ocpp_param_type, " ", arg, NIL);
      Printv(ocpp_h_code, gencomma ? ", " : "", ocpp_param_type, " ", arg, NIL);

      gencomma = 1;

      // Get typemap for this argument
      if ((tm = Getattr(p, "tmap:in"))) {
	Replaceall(tm, "$source", arg);	/* deprecated */
	Replaceall(tm, "$target", ln);	/* deprecated */
	Replaceall(tm, "$arg", arg);	/* deprecated? */
	Replaceall(tm, "$input", arg);
	Setattr(p, "emit:input", arg);
	Printf(f->code, "%s\n", tm);
	p = Getattr(p, "tmap:in:next");
      } else {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
	p = nextSibling(p);
      }
      Delete(ocpp_param_type);
      Delete(arg);
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:check"))) {
	Replaceall(tm, "$target", Getattr(p, "lname"));	/* deprecated */
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));	/* deprecated? */
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(f->code, tm, "\n", NIL);
	p = Getattr(p, "tmap:check:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
	Replaceall(tm, "$source", Getattr(p, "emit:input"));	/* deprecated */
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));	/* deprecated? */
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(cleanup, tm, "\n", NIL);
	p = Getattr(p, "tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
	Replaceall(tm, "$source", Getattr(p, "emit:input"));	/* deprecated */
	Replaceall(tm, "$target", Getattr(p, "lname"));	/* deprecated */
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));	/* deprecated? */
	Replaceall(tm, "$result", "jresult");
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(outarg, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }

    // Now write code to make the low level function call
    if (!native_function_flag) {
      String *actioncode = emit_action(n);

      // Return value if necessary
      if ((tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode))) {
	Replaceall(tm, "$source", "result");	/* deprecated */
	Replaceall(tm, "$target", "oresult");	/* deprecated */
	Replaceall(tm, "$result", "oresult");
	if (GetFlag(n, "feature:new"))
	  Replaceall(tm, "$owner", "1");
	else
	  Replaceall(tm, "$owner", "0");
	Printf(f->code, "%s", tm);
	if (Len(tm))
	  Printf(f->code, "\n");
      } else {
	Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(t, 0), Getattr(n, "name"));
      }
      emit_return_variable(n, t, f);
    }

    /* Output argument output code */
    Printv(f->code, outarg, NIL);

    /* Output cleanup code */
    Printv(f->code, cleanup, NIL);

    /* Look to see if there is any newfree cleanup code */
    if (GetFlag(n, "feature:new")) {
      if ((tm = Swig_typemap_lookup("newfree", n, "result", 0))) {
	Replaceall(tm, "$source", "result");	/* deprecated */
	Printf(f->code, "%s\n", tm);
      }
    }

    /* See if there is any return cleanup code */
    if (!native_function_flag) {
      if ((tm = Swig_typemap_lookup("ret", n, "result", 0))) {
	Replaceall(tm, "$source", "result");	/* deprecated */
	Printf(f->code, "%s\n", tm);
      }
    }
    // Finish the ocpp header code and wrapper function definition
    Printf(ocpp_h_code, ");\n");
    Printf(f->def, ") {");

    if (!is_void_return)
      Printv(f->code, "    return oresult;\n", NIL);

    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code, "$cleanup", cleanup);

    /* Substitute the function name */
    Replaceall(f->code, "$symname", symname);

    // Dump the function out
    if (!native_function_flag) {
      Wrapper_print(f, f_wrappers);
    }
    // Tidy up
    Delete(ocpp_return_type);
    Delete(wname);
    DelWrapper(f);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * getOverloadedName()
   * ----------------------------------------------------------------------------- */

  String *getOverloadedName(Node *n) {
    String *overloaded_name = NewStringf("%s", Getattr(n, "sym:name"));

    if (Getattr(n, "sym:overloaded")) {
      Printv(overloaded_name, Getattr(n, "sym:overname"), NIL);
    }

    return overloaded_name;
  }

  /* ----------------------------------------------------------------------
   * memberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *wname = Swig_name_wrapper(overloaded_name);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "ocppfuncname", wname);
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node *n) {

    static_flag = true;
    Language::staticmemberfunctionHandler(n);

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *wname = Swig_name_wrapper(overloaded_name);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "ocppfuncname", wname);
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    static_flag = false;

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * globalfunctionHandler()
   * ----------------------------------------------------------------------------- */
  virtual int globalfunctionHandler(Node *n) {
    Language::globalfunctionHandler(n);

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *wname = Swig_name_wrapper(overloaded_name);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "ocppfuncname", wname);
      proxyGlobalFunctionHandler(n);
      Delete(overloaded_name);
    }
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * getProxyName()
   *
   * Test to see if a type corresponds to something wrapped with a proxy class
   * Return NULL if not otherwise the proxy class name
   * ----------------------------------------------------------------------------- */

  String *getProxyName(SwigType *t) {
    if (proxy_flag) {
      Node *n = classLookup(t);
      if (n) {
	return Getattr(n, "sym:name");
      }
    }
    return NULL;
  }


  /* -----------------------------------------------------------------------------
   * typemapLookup()
   * ----------------------------------------------------------------------------- */

  const String *typemapLookup(const String *op, String *type, int warning, Node *typemap_attributes = NULL) {
    String *tm = NULL;
    const String *code = NULL;

    if ((tm = Swig_typemap_search(op, type, NULL, NULL))) {
      code = Getattr(tm, "code");
      if (typemap_attributes)
	Swig_typemap_attach_kwargs(tm, op, typemap_attributes);
    }

    if (!code) {
      code = empty_string;
      if (warning != WARN_NONE)
	Swig_warning(warning, input_file, line_number, "No %s typemap defined for %s\n", op, type);
    }

    return code ? code : empty_string;
  }

  /* -----------------------------------------------------------------------------
   * proxyClassHandler()
   * ----------------------------------------------------------------------------- */

  void proxyClassHandler(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n, "name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;
    String *typemap_lookup_type = Getattr(n, "classtypeobj");

    // Inheritance from pure Objective-C classes
    Node *attributes = NewHash();
    const String *pure_baseclass = typemapLookup("objcbase", typemap_lookup_type, WARN_NONE, attributes);
    bool purebase_replace = GetFlag(attributes, "tmap:objcbase:replace") ? true : false;
    bool purebase_notderived = GetFlag(attributes, "tmap:objcbase:notderived") ? true : false;
    Delete(attributes);

    // C++ inheritance
    if (!purebase_replace) {
      List *baselist = Getattr(n, "bases");
      if (baselist) {
	Iterator base = First(baselist);
	while (base.item && GetFlag(base.item, "feature:ignore")) {
	  base = Next(base);
	}
	if (base.item) {
	  c_baseclassname = Getattr(base.item, "name");
	  baseclass = Copy(getProxyName(c_baseclassname));
	  if (baseclass)
	    c_baseclass = SwigType_namestr(Getattr(base.item, "name"));
	  base = Next(base);
	  /* Warn about multiple inheritance for additional base class(es) */
	  while (base.item) {
	    if (GetFlag(base.item, "feature:ignore")) {
	      base = Next(base);
	      continue;
	    }
	    String *proxyclassname = SwigType_str(Getattr(n, "classtypeobj"), 0);
	    String *baseclassname = SwigType_str(Getattr(base.item, "name"), 0);
	    Swig_warning(WARN_NONE, input_file, line_number,
			 "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in Objective-C.\n", proxyclassname, baseclassname);
	    base = Next(base);
	  }
	}
      }
    }

    bool derived = baseclass && getProxyName(c_baseclassname);
    if (derived && purebase_notderived)
      pure_baseclass = empty_string;
    const String *wanted_base = baseclass ? baseclass : pure_baseclass;

    if (purebase_replace) {
      wanted_base = pure_baseclass;
      derived = false;
      Delete(baseclass);
      baseclass = NULL;
      if (purebase_notderived)
	Swig_error(input_file, line_number, "The objcbase typemap for proxy %s must contain just one of the 'replace' or 'notderived' attributes.\n",
		   typemap_lookup_type);
    } else if (Len(pure_baseclass) > 0 && Len(baseclass) > 0) {
      Swig_warning(WARN_NONE, input_file, line_number,
		   "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in Objective-C. "
		   "Perhaps you need one of the 'replace' or 'notderived' attributes in the objcbase typemap?\n", typemap_lookup_type, pure_baseclass);
    }
    // Pure Objective-C interfaces
    const String *pure_interfaces = typemapLookup(derived ? "objcinterfaces_derived" : "objcinterfaces", typemap_lookup_type, WARN_NONE);
    // Start writing the proxy class
    Printv(proxy_class_def, typemapLookup("objcimports", typemap_lookup_type, WARN_NONE),	// Import statements
	   "\n", NIL);

    // Class attributes
    const String *objcattributes = typemapLookup("objcattributes", typemap_lookup_type, WARN_NONE);
    if (objcattributes && *Char(objcattributes))
      Printf(proxy_class_def, "%s\n", objcattributes);

    Printv(proxy_class_decl, typemapLookup("objcclassinterface", typemap_lookup_type, WARN_NONE),	// Class modifiers
	   " $objcclassname",	// Class name and base class
	   (*Char(wanted_base) || *Char(pure_interfaces)) ? " : " : "", wanted_base, (*Char(wanted_base) && *Char(pure_interfaces)) ?	// Interfaces
	   ", " : "", pure_interfaces, derived ? typemapLookup("objcbody_derived", typemap_lookup_type, WARN_NONE) :	// main body of class
	   typemapLookup("objcbody", typemap_lookup_type, WARN_NONE),	// main body of class
	   "\n", NIL);

    Printv(proxy_class_def, typemapLookup("objcclassimplementation", typemap_lookup_type, WARN_NONE),	// Class modifiers
	   " $objcclassname", NIL);

    // Emit extra user code
    Printv(proxy_class_def, typemapLookup("objccode", typemap_lookup_type, WARN_NONE),	// extra Objective-C code
	   "\n", NIL);

    // Substitute various strings into the above template
    Replaceall(proxy_class_decl, "$objcclassname", proxy_class_name);
    Replaceall(proxy_class_def, "$objcclassname", proxy_class_name);

    Delete(baseclass);
  }


  /* -----------------------------------------------------------------------------
   * classHandler()
   * ----------------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {
    if (proxy_flag) {
      proxy_class_name = NewString(Getattr(n, "sym:name"));
      if (!addSymbol(proxy_class_name, n))
	return SWIG_ERROR;

      Clear(proxy_class_def);
      Clear(proxy_class_decl);
      proxyClassHandler(n);
      Printv(proxy_h_code, proxy_class_decl, NIL);
      Printv(proxy_m_code, proxy_class_def, NIL);
    }

    Language::classHandler(n);

    if (proxy_flag) {
      Printv(proxy_h_code, "@end\n\n", NIL);
      Printv(proxy_m_code, "@end\n\n", NIL);
      Delete(proxy_class_name);
      proxy_class_name = NULL;
    }

    return SWIG_OK;
  }


};

/* -----------------------------------------------------------------------------
 * swig_objc()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_objc() {
  return new OBJC();
}

extern "C" Language *swig_objc() {
  return new_swig_objc();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *OBJC::usage = (char *) "\
Objective-C Options (available with -objc)\n\
-noproxy        - Generate the low-level functional interface instead\n\
of proxy classes\n\
\n";
