/*
 *  OBJC.cxx
 *  Module file for Objective-C support
 */

#include "swigmod.h"
#include <limits.h>		// for INT_MAX
#include "cparse.h"
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
  bool enum_constant_flag;	// Flag for when wrapping an enum or constant
  bool static_flag;		// Flag for when wrapping a static functions or member variables
  bool variable_wrapper_flag;	// Flag for when wrapping a nonstatic member variable
  bool wrapping_member_flag;	// Flag for when wrapping a member variable/enum/const
  bool global_variable_flag;	// Flag for when wrapping a global variable

  String *ocpp_h_code;		// Code for Objective-C++ header
  String *proxy_h_code;		// Code for Objective-C proxy header
  String *proxy_m_code;		// Code for Objective-C proxy implementation

  String *proxy_class_name;	// Name of the proxy class
  String *variable_name;	// Name of a variable being wrapped
  String *proxy_class_decl;
  String *proxy_class_def;
  String *destructor_call;	// C++ destructor call if any
  String *enum_code;
  String *proxy_class_constants_code;
  String *proxy_global_constants_code;

  enum EnumFeature { SimpleEnum, ProperEnum };

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
      enum_constant_flag(false),
      static_flag(false),
      variable_wrapper_flag(false),
      wrapping_member_flag(false),
      global_variable_flag(false),
      proxy_flag(true),
      proxy_class_name(NULL),
      destructor_call(NULL), proxy_class_constants_code(NULL), enum_code(NULL), proxy_global_constants_code(NULL), variable_name(NULL), proxy_class_def(NULL),
      proxy_class_decl(NULL), ocpp_h_code(NULL), proxy_h_code(NULL), proxy_m_code(NULL) {
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

    Printf(f_runtime, "\n#define SWIGOBJC\n");
    Printf(f_runtime, "\n");

    Swig_name_register((char *) "wrapper", (char *) "ObjCPP_%f");

    Printf(f_wrappers, "#include \"%s\"\n\n", file_h);

    Printf(f_wrappers, "\n#ifdef __cplusplus\n");
    Printf(f_wrappers, "extern \"C\" {\n");
    Printf(f_wrappers, "#endif\n\n");

    // Initialize members
    ocpp_h_code = NewString("");
    proxy_h_code = NewString("");
    proxy_m_code = NewString("");
    proxy_class_decl = NewString("");
    proxy_class_def = NewString("");
    swig_types_hash = NewHash();
    proxy_global_constants_code = NewString("");

    // Emit code for children
    Language::top(n);


    // Generate proxy code
    if (proxy_flag) {
      String *proxy_h = NewStringf("%sProxy.h", modulename);
      f_proxy_h = NewFile(proxy_h, "w", SWIG_output_files());
      if (!f_proxy_h) {
	FileErrorDisplay(f_proxy_h);
	SWIG_exit(EXIT_FAILURE);
      }

      String *proxy_m = NewStringf("%sProxy.m", modulename);
      f_proxy_m = NewFile(proxy_m, "w", SWIG_output_files());
      if (!f_proxy_m) {
	FileErrorDisplay(f_proxy_m);
	SWIG_exit(EXIT_FAILURE);
      }

      emitBanner(f_proxy_h);
      Printf(f_proxy_h, "\n#import <Foundation/Foundation.h>\n");
      Printf(f_proxy_m, "#include \"%s\"\n\n", file_h);
      Printf(f_proxy_m, "#include \"%s\"\n\n", proxy_h);
      Printv(f_proxy_h, proxy_global_constants_code, proxy_h_code, NIL);
      Printv(f_proxy_m, proxy_m_code, NIL);

      Delete(proxy_h);
      proxy_h = NULL;
      Delete(proxy_m);
      proxy_m = NULL;

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
      Printf(f_wrappers, "#ifdef __cplusplus\n");
      Printf(f_wrappers, "}\n");
      Printf(f_wrappers, "#endif\n");

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
      Printf(f_ocpp_h, "\n#import <Foundation/Foundation.h>\n");
      Printf(f_ocpp_h, "\n#ifdef __cplusplus\n");
      Printf(f_ocpp_h, "extern \"C\" {\n");
      Printf(f_ocpp_h, "#endif\n\n");
      Printv(f_ocpp_h, ocpp_h_code, NIL);
      Printf(f_ocpp_h, "\n#ifdef __cplusplus\n");
      Printf(f_ocpp_h, "}\n");
      Printf(f_ocpp_h, "#endif\n");

			
			// Output a Objective-C type wrapper class for each SWIG type
			for (Iterator swig_type = First(swig_types_hash); swig_type.key; swig_type = Next(swig_type)) {
				emitTypeWrapperClass(swig_type.key, swig_type.item);
			}
			
      Dump(f_header, f_runtime);
      Dump(f_wrappers, f_runtime);
      Wrapper_pretty_print(f_init, f_runtime);

      Dump(f_runtime, f_ocpp_mm);

      Delete(file_h);
      file_h = NULL;
      Delete(file_mm);
      file_mm = NULL;
      Delete(ocpp_h_code);
      ocpp_h_code = NULL;

      Delete(swig_types_hash);
      swig_types_hash = NULL;
      Delete(proxy_class_def);
      proxy_class_def = NULL;
      Delete(proxy_class_decl);
      proxy_class_decl = NULL;
      Delete(proxy_global_constants_code);
      proxy_global_constants_code = NULL;

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
	enum_name = NewStringf("%s", symname);
      }
    }

    return enum_name;
  }

	/*----------------------------------------------------------------------
   * decodeEnumFeature()
   * Decode the possible enum features, which are one of:
   *   %objcenum(simple)
   *   %objcenum(proper)
   *--------------------------------------------------------------------*/

  EnumFeature decodeEnumFeature(Node *n) {
    EnumFeature enum_feature = SimpleEnum;
    String *feature = Getattr(n, "feature:objc:enum");
    if (feature) {
      if (Cmp(feature, "simple") == 0)
	enum_feature = SimpleEnum;
      else if (Cmp(feature, "proper") == 0)
	enum_feature = ProperEnum;
    }
    return enum_feature;
  }


  /* -----------------------------------------------------------------------
   * enumValue()
   * This method will return a string with an enum value to use in Objective-C generated
   * code. If the %objcconst feature is not used, the string will contain the intermediary
   * method call to obtain the enum value. The intermediary methods to obtain
   * the enum value will be generated. Otherwise the C/C++ enum value will be used if there
   * is one and hopefully it will compile as Objective-C code - e.g. 20 as in: enum E{e=20};
   * The %objcconstvalue feature overrides all other ways to generate the constant value.
   * The caller must delete memory allocated for the returned string.
   * ------------------------------------------------------------------------ */

  String *enumValue(Node *n) {
    String *symname = Getattr(n, "sym:name");

    // Check for the %objcconstvalue feature
    String *value = Getattr(n, "feature:objc:constvalue");

    if (!value) {
      // The %objcconst feature determines how the constant value is obtained
      int const_feature_flag = GetFlag(n, "feature:objc:const");

      if (const_feature_flag) {
	// Use the C syntax to make a true Objective-C constant and hope that it compiles as Objective-C code
	value = Getattr(n, "enumvalue") ? Copy(Getattr(n, "enumvalue")) : Copy(Getattr(n, "enumvalueex"));
      } else {
	// Get the enumvalue from a PINVOKE call
	if (!getCurrentClass() || !cparse_cplusplus || !proxy_flag) {
	  // Strange hack to change the name
	  Setattr(n, "name", Getattr(n, "value"));	/* for wrapping of enums in a namespace when emit_action is used */
	  constantWrapper(n);
	  value = NewStringf("%s()", Swig_name_get(symname));
	} else {
	  memberconstantHandler(n);
	  value = NewStringf("%s()", Swig_name_get(Swig_name_member(proxy_class_name, symname)));
	}
      }
    }
    return value;
  }


  /* -----------------------------------------------------------------------------
   * substituteClassname()
   *
   * Substitute $objcclassname with the proxy class name for classes/structs/unions that SWIG knows about.
   * Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the Objective-C class name. Note that the $&objcclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - objctype typemap
   * Outputs:
   *   tm - objctype typemap with $objcclassname substitution
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

  String *makeParameterName(Node *n, Parm *p, int arg_num, bool setter) {

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

    if (setter && Cmp(arg, "self") != 0) {
      // Note that for setters the parameter name is always set but sometimes includes C++ 
      // scope resolution, so we need to strip off the scope resolution to make a valid name.
      Delete(arg);
      arg = NewString("value");	//Swig_scopename_last(pn);
    }

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
    String *func_name = NULL;
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

    /* Change function name for global variables */
    if (proxy_flag && global_variable_flag) {
      // Capitalize the first letter in the variable to create a objcBean type getter/setter function name
      func_name = NewString("");
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(variable_name)) == 0);
      if (setter_flag)
	Printf(func_name, "set");
      else
	Printf(func_name, "get");
      Putc(toupper((int) *Char(variable_name)), func_name);
      Printf(func_name, "%s", Char(variable_name) + 1);
    } else {
      func_name = Copy(Getattr(n, "sym:name"));
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

    Printf(function_decl, "%s %s(", return_type, func_name);

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

	String *arg = makeParameterName(n, p, i, true);

	// Use typemaps to transform type used in Objective-C proxy function to the one used in intermediate code.
	if ((tm = Getattr(p, "tmap:objcin"))) {
	  addThrows(n, "tmap:objcin", p);
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
      addThrows(n, "tmap:objcout", n);
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

    if (wrapping_member_flag && !enum_constant_flag) {
      // For wrapping member variables
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(Swig_name_member(proxy_class_name, variable_name))) == 0);
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
      if (!(variable_wrapper_flag && i == 0) || static_flag) {
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

	String *arg = makeParameterName(n, p, i, setter_flag);

	if (gencomma) {
	  Printf(imcall, ", ");
	}
	// Use typemaps to transform type used in Objective-C proxy function to type used in low level ocpp accessor
	if ((tm = Getattr(p, "tmap:objcin"))) {
	  addThrows(n, "tmap:objcin", p);
	  substituteClassname(pt, tm);
	  Replaceall(tm, "$objcinput", arg);
	  Printv(imcall, tm, NIL);
	} else {
	  Swig_warning(WARN_NONE, input_file, line_number, "No objcin typemap defined for %s\n", SwigType_str(pt, 0));
	}

	/* Add parameter to proxy function */
	if (gencomma >= 2)
	  Printf(function_decl, " %s: ", arg);
	else
	  Printf(function_decl, ":");

	gencomma = 2;

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
      addThrows(n, "tmap:objcout", n);
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
	addThrows(n, "tmap:in", p);
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
	addThrows(n, "tmap:check", p);
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
	addThrows(n, "tmap:freearg", p);
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
	addThrows(n, "tmap:argout", p);
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

    // Get any Objective-C exception classes in the throws typemap
    ParmList *throw_parm_list = NULL;
    if ((throw_parm_list = Getattr(n, "throws"))) {
      Swig_typemap_attach_parms("throws", throw_parm_list, f);
      for (p = throw_parm_list; p; p = nextSibling(p)) {
	if ((tm = Getattr(p, "tmap:throws"))) {
	  addThrows(n, "tmap:throws", p);
	}
      }
    }
    // Now write code to make the low level function call
    if (!native_function_flag) {
      String *actioncode = emit_action(n);

      // Handle exception classes specified in the "except" feature's "throws" attribute
      addThrows(n, "feature:except", n);

      // Return value if necessary
      if ((tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode))) {
	addThrows(n, "tmap:out", n);
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
	addThrows(n, "tmap:newfree", n);
	Replaceall(tm, "$source", "result");	/* deprecated */
	Printf(f->code, "%s\n", tm);
      }
    }

    /* See if there is any return cleanup code */
    if (!native_function_flag) {
      if ((tm = Swig_typemap_lookup("ret", n, "result", 0))) {
	addThrows(n, "tmap:ret", n);
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

    // Substitute the cleanup code
    Replaceall(f->code, "$cleanup", cleanup);

    // Substitute the function name
    Replaceall(f->code, "$symname", symname);

    /* Contract macro modification */
    Replaceall(f->code, "SWIG_contract_assert(", "SWIG_contract_assert($null, ");

    if (!is_void_return)
      Replaceall(f->code, "$null", "0");
    else
      Replaceall(f->code, "$null", "");

    // Dump the function out
    if (!native_function_flag) {
      Wrapper_print(f, f_wrappers);
    }

    if (!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
      Setattr(n, "ocppfuncname", wname);
      proxyGlobalFunctionHandler(n);
    }

    /* 
     * Generate the proxy class getters/setters for public member variables.
     * Not for enums and constants.
     */
    if (proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Capitalize the first letter in the variable to create getter/setter function name
      bool getter_flag = Cmp(symname, Swig_name_set(Swig_name_member(proxy_class_name, variable_name))) != 0;

      String *getter_setter_name = NewString("");
      if (!getter_flag)
	Printf(getter_setter_name, "set");
      else
	Printf(getter_setter_name, "get");
      Putc(toupper((int) *Char(variable_name)), getter_setter_name);
      Printf(getter_setter_name, "%s", Char(variable_name) + 1);

      String *ocppfunctname = NewStringf("ObjCPP_%s", symname);

      Setattr(n, "proxyfuncname", getter_setter_name);
      Setattr(n, "ocppfuncname", ocppfunctname);

      proxyClassFunctionHandler(n);
      Delete(getter_setter_name);
      Delete(ocppfunctname);
    }
    // Tidy up
    Delete(ocpp_return_type);
    Delete(wname);
    Delete(overloaded_name);
    DelWrapper(f);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * constructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *function_decl = NewString("");
    String *function_def = NewString("");
    String *ocpp_return_type = NewString("");

    Language::constructorHandler(n);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Objective-C
    if (Getattr(n, "overload:ignore"))
      return SWIG_OK;

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *mangled_overname = Swig_name_construct(overloaded_name);
      String *imcall = NewString("");

      tm = Getattr(n, "tmap:ocpptype");	// typemaps were attached earlier to the node
      Printf(ocpp_return_type, "%s", tm);

      Printf(function_decl, "- (id)init");

      Printv(imcall, "ObjCPP_", mangled_overname, "(", NIL);

      /* Attach the non-standard typemaps to the parameter list */
      Swig_typemap_attach_parms("in", l, NULL);
      Swig_typemap_attach_parms("ocpptype", l, NULL);
      Swig_typemap_attach_parms("objctype", l, NULL);
      Swig_typemap_attach_parms("objcin", l, NULL);

      emit_mark_varargs(l);

      int gencomma = 0;

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

	SwigType *pt = Getattr(p, "type");
	String *param_type = NewString("");

	/* Get the Objective-C parameter type */
	if ((tm = Getattr(p, "tmap:objctype"))) {
	  substituteClassname(pt, tm);
	  Printf(param_type, "%s", tm);
	} else {
	  Swig_warning(WARN_NONE, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(pt, 0));
	}

	if (gencomma)
	  Printf(imcall, ", ");

	String *arg = makeParameterName(n, p, i, false);

	// Use typemaps to transform type used in Objective-C wrapper function (in proxy class) to type used in intermediary code
	if ((tm = Getattr(p, "tmap:objcin"))) {
	  addThrows(n, "tmap:objcin", p);
	  substituteClassname(pt, tm);
	  Replaceall(tm, "$objcinput", arg);
	  Printv(imcall, tm, NIL);
	} else {
	  Swig_warning(WARN_NONE, input_file, line_number, "No objcin typemap defined for %s\n", SwigType_str(pt, 0));
	}

	/* Add parameter to proxy function */
	if (gencomma >= 2)
	  Printf(function_decl, " %s: ", arg);
	else {
	  String *func_name = NewString("With");
	  Putc(toupper((int) *Char(arg)), func_name);
	  Printf(func_name, "%s", Char(arg) + 1);
	  Printf(function_decl, "%s:", func_name);
	  Delete(func_name);
	}

	gencomma = 2;

	Printf(function_decl, " (%s)%s", param_type, arg);
	Delete(arg);
	Delete(param_type);
	p = Getattr(p, "tmap:in:next");
      }

      Printf(imcall, ")");
      Printv(function_def, function_decl, NIL);
      Printf(function_decl, ";");

      /* Insert the objcconstruct typemap, doing the replacement for $directorconnect, as needed */
      Hash *attributes = NewHash();
      String *construct_tm = Copy(typemapLookup("objcconstruct", Getattr(n, "name"),
						WARN_NONE, attributes));
      if (construct_tm) {
	Printv(function_def, " ", construct_tm, "\n", NIL);
      }

      Replaceall(function_def, "$imcall", imcall);

      Printv(proxy_class_decl, function_decl, NIL);
      Printv(proxy_class_def, function_def, NIL);

      Delete(ocpp_return_type);
      Delete(construct_tm);
      Delete(attributes);
      Delete(overloaded_name);
      Delete(imcall);
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * destructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int destructorHandler(Node *n) {
    Language::destructorHandler(n);
    String *symname = Getattr(n, "sym:name");

    if (proxy_flag) {
      Printv(destructor_call, Swig_name_destroy(symname), "(swigCPtr)", NIL);
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    variable_wrapper_flag = true;
    Language::membervariableHandler(n);
    wrapping_member_flag = false;
    variable_wrapper_flag = false;
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmembervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    static_flag = true;
    Language::staticmembervariableHandler(n);
    wrapping_member_flag = false;
    static_flag = false;
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberconstantHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberconstantHandler(Node *n) {
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    Language::memberconstantHandler(n);
    wrapping_member_flag = false;
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

  /* -----------------------------------------------------------------------
   * variableWrapper()
   * ----------------------------------------------------------------------- */

  virtual int variableWrapper(Node *n) {
    variable_wrapper_flag = true;
    Language::variableWrapper(n);	/* Default to functions */
    variable_wrapper_flag = false;
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {

    variable_name = Getattr(n, "sym:name");
    global_variable_flag = true;
    int ret = Language::globalvariableHandler(n);
    global_variable_flag = false;
    return ret;
  }

  /* ----------------------------------------------------------------------
   * memberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *imfunctname = Swig_name_member(proxy_class_name, overloaded_name);
      String *ocppfunctname = NewStringf("ObjCPP_%s", imfunctname);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "ocppfuncname", ocppfunctname);
      proxyClassFunctionHandler(n);
      Delete(imfunctname);
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
      String *imfunctname = Swig_name_member(proxy_class_name, overloaded_name);
      String *ocppfunctname = NewStringf("ObjCPP_%s", imfunctname);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "ocppfuncname", ocppfunctname);
      proxyClassFunctionHandler(n);
      Delete(imfunctname);
      Delete(overloaded_name);
    }

    static_flag = false;

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * enumDeclaration()
   *
   * C/C++ enums can be mapped in one of 4 ways, depending on the objc:enum feature specified:
   * 1) Simple enums - simple constant within the proxy (Class or global)
   * 2) Proper enums - proper Objective-C/C enum. This is just copy-paste of the enum declaration.
   * Anonymous enums always default to 1)
   * ---------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {

    if (!ImportMode) {
      if (getCurrentClass() && (cplus_mode != PUBLIC))
	return SWIG_NOWRAP;

      enum_code = NewString("");
      String *symname = Getattr(n, "sym:name");
      String *constants_code = (proxy_flag && is_wrapping_class())? proxy_class_constants_code : proxy_global_constants_code;
      EnumFeature enum_feature = decodeEnumFeature(n);
      String *typemap_lookup_type = Getattr(n, "name");

      if ((enum_feature != SimpleEnum) && symname && typemap_lookup_type) {
	// Copy-paste the C/C++ enum as an Objective-C enum
	Printf(enum_code, "enum %s {", symname);

      } else {
	// Wrap C++ enum with integers - just indicate start of enum with a comment, no comment for anonymous enums of any sort
	if (symname && !Getattr(n, "unnamedinstance"))
	  Printf(constants_code, "\n  // %s \n", symname);
      }

      // Emit each enum item
      Language::enumDeclaration(n);

      if ((enum_feature != SimpleEnum) && symname && typemap_lookup_type) {
	Replaceall(enum_code, "$objcclassname", symname);
	// Copy-paste the C/C++ enum as a proper Objective-C enum
	// Finish the enum declaration
	Printf(enum_code, "};\n\n");
      } else {
	// Wrap C++ enum with simple constant
	Printf(enum_code, "\n");
      }
      if (proxy_flag && is_wrapping_class())
	Printv(proxy_class_constants_code, enum_code, NIL);
      else
	Printv(proxy_global_constants_code, enum_code, NIL);

      Delete(enum_code);
      enum_code = NULL;
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * enumvalueDeclaration()
   * ---------------------------------------------------------------------- */

  virtual int enumvalueDeclaration(Node *n) {
    if (getCurrentClass() && (cplus_mode != PUBLIC))
      return SWIG_NOWRAP;

    Swig_require("enumvalueDeclaration", n, "*name", "?value", NIL);
    String *symname = Getattr(n, "sym:name");
    String *value = Getattr(n, "value");
    String *name = Getattr(n, "name");
    String *tmpValue;
    String *tm;
    SwigType *t = Getattr(n, "type");

    // Strange hack from parent method
    if (value)
      tmpValue = NewString(value);
    else
      tmpValue = NewString(name);

    // Note that this is used in enumValue() amongst other places
    Setattr(n, "value", tmpValue);

    {
      EnumFeature enum_feature = decodeEnumFeature(parentNode(n));

      // The %objcconst feature determines how the constant value is obtained
      int const_feature_flag = GetFlag(n, "feature:objc:const");

      if ((enum_feature != SimpleEnum) && Getattr(parentNode(n), "sym:name") && !Getattr(parentNode(n), "unnamedinstance")) {
	// Wrap (non-anonymous) C/C++ enum with a proper Objective-C enum
	// Emit the enum item.
	if (!Getattr(n, "_last"))	// Only the first enum item has this attribute set
	  Printf(enum_code, ",\n");

	Printf(enum_code, "  %s", symname);

	// Check for the %objcconstvalue feature
	String *value = Getattr(n, "feature:objc:constvalue");
	// Note that the enum value must be a true constant and cannot be set from an intermediatory call, thus no support for %objcconst(0)
	value = value ? value : Getattr(n, "enumvalue");
	if (value) {
	  Printf(enum_code, " = %s", value);
	}
      } else {
	// Wrap C/C++ enums with constant integers
	String *return_type = NewString("");

	if ((tm = Swig_typemap_lookup("objctype", n, "", 0))) {
	  String *objctypeout = Getattr(n, "tmap:objctype:out");	// the type in the objctype typemap's out attribute overrides the type in the typemap
	  if (objctypeout)
	    tm = objctypeout;
	  substituteClassname(t, tm);
	  Printf(return_type, "%s", tm);
	}
	// Simple integer constants
	// Note these are always generated for anonymous enums, no matter what enum_feature is specified
	const char *const_static = const_feature_flag ? "const" : "static";
	String *value = enumValue(n);
	Printf(enum_code, "  %s %s %s = %s;\n", const_static, return_type, symname, value);
	Delete(value);
      }

      // Add the enum value to the comma separated list being constructed in the enum declaration.
      String *enumvalues = Getattr(parentNode(n), "enumvalues");
      if (!enumvalues)
	Setattr(parentNode(n), "enumvalues", Copy(symname));
      else
	Printv(enumvalues, ", ", symname, NIL);
    }

    Delete(tmpValue);
    Swig_restore(n);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * constantWrapper()
   * Used for wrapping constants - #define or %constant.
   * Also for inline initialised const static primitive type member variables (short, int, double, enums etc).
   * Objective-C static const variables are generated for these.
   * If the %objcconst(1) feature is used then the C constant value is used to initialise the Objective-C const variable.
   * If not, method is generated to get the C constant value for initialisation of the Objective-C const variable.
   * However, if the %objcconstvalue feature is used, it overrides all other ways to generate the initialisation.
   * Also note that this method might be called for wrapping enum items (when the enum is using %objcconst(0)).
   * ------------------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    String *return_type = NewString("");
    String *constants_code = NewString("");

    if (!addSymbol(symname, n))
      return SWIG_ERROR;

    bool is_enum_item = (Cmp(nodeType(n), "enumitem") == 0);

    // The %objcconst feature determines how the constant value is obtained
    int const_feature_flag = GetFlag(n, "feature:objc:const");

    /* Adjust the enum type for the Swig_typemap_lookup.
     * We want the same objctype typemap for all the enum items so we use the enum type (parent node). */
    if (is_enum_item) {
      t = Getattr(parentNode(n), "enumtype");
      Setattr(n, "type", t);
    }

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("objctype", l, NULL);

    /* Get Objective-C return types */
    bool classname_substituted_flag = false;

    if ((tm = Swig_typemap_lookup("objctype", n, "", 0))) {
      String *objctypeout = Getattr(n, "tmap:objctype:out");	// the type in the objctype typemap's out attribute overrides the type in the typemap
      if (objctypeout)
	tm = objctypeout;
      classname_substituted_flag = substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_NONE, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(t, 0));
    }

    // Add the stripped quotes back in
    String *new_value = NewString("");
    Swig_save("constantWrapper", n, "value", NIL);
    if (SwigType_type(t) == T_STRING) {
      Printf(new_value, "@\"%s\"", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    } else if (SwigType_type(t) == T_CHAR) {
      Printf(new_value, "\'%s\'", Copy(Getattr(n, "value")));	//character pointer ??
      Setattr(n, "value", new_value);
    }

    const String *outattributes = Getattr(n, "tmap:objctype:outattributes");
    if (outattributes)
      Printf(constants_code, "  %s\n", outattributes);
    const String *itemname = (proxy_flag && wrapping_member_flag) ? variable_name : symname;

    Printf(constants_code, "  %s %s %s = ", (const_feature_flag ? "const" : "static"), return_type, itemname);

    // Check for the %objcconstvalue feature
    String *value = Getattr(n, "feature:objc:constvalue");

    if (value) {
      Printf(constants_code, "%s;\n", value);
    } else if (!const_feature_flag) {
      // Default enum and constant handling will work with any type of C constant and initialises the Objective-C variable from C through a method call.

      if (classname_substituted_flag) {
	if (SwigType_isenum(t)) {
	  // This handles wrapping of inline initialised const enum static member variables (not when wrapping enum items - ignored later on)
	  Printf(constants_code, "(%s)%s();\n", return_type, Swig_name_get(symname));
	} else {
	  // This handles function pointers using the %constant directive
	  Printf(constants_code, "new %s(%s(), false);\n", return_type, Swig_name_get(symname));
	}
      } else
	Printf(constants_code, "%s();\n", Swig_name_get(symname));

      // Each constant and enum value is wrapped with a separate function call
      SetFlag(n, "feature:immutable");
      enum_constant_flag = true;
      variableWrapper(n);
      enum_constant_flag = false;
    } else {
      // Alternative constant handling will use the C syntax to make a true Objective-C constant and hope that it compiles as Objective-C code
      Printf(constants_code, "%s;\n", Getattr(n, "value"));
    }

    // Emit the generated code to appropriate place
    // Enums only emit the intermediate methods, so no proxy wrapper methods needed
    if (!is_enum_item) {
      if (proxy_flag && wrapping_member_flag) {
	Printv(proxy_global_constants_code, constants_code, NIL);	//for now writing everything globally
	Printv(proxy_h_code, proxy_global_constants_code, NIL);
      } else {
	Printv(proxy_global_constants_code, constants_code, NIL);
	Printv(proxy_h_code, proxy_global_constants_code, NIL);
      }
    }
    // Cleanup
    Swig_restore(n);
    Delete(new_value);
    Delete(return_type);
    Delete(constants_code);
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
   * emitTypeWrapperClass()
   * ----------------------------------------------------------------------------- */
	
  void emitTypeWrapperClass(String *classname, SwigType *type) {
   
		String *swigtypeh = NewString("");
		String *swigtypem = NewString("");
		String *fileh = NewStringf("%s%s.h", SWIG_output_directory(), classname);
    String *filem = NewStringf("%s%s.m", SWIG_output_directory(), classname);
    File *fh_swigtype = NewFile(fileh, "w", SWIG_output_files());
		File *fm_swigtype = NewFile(filem, "w", SWIG_output_files());

    if (!fh_swigtype) {
      FileErrorDisplay(fileh);
      SWIG_exit(EXIT_FAILURE);
    }		
   	
		if (!fm_swigtype) {
      FileErrorDisplay(filem);
      SWIG_exit(EXIT_FAILURE);
    }
		
    // Start writing out the type wrapper class file
    emitBanner(fh_swigtype);
				
    // Pure Objective-C baseclass and interfaces
    const String *pure_baseclass = typemapLookup("objcbase", type, WARN_NONE);
    const String *pure_interfaces = typemapLookup("objcinterfaces", type, WARN_NONE);
		
		Printf(swigtypeh, "#include \<Foundation/Foundation.h\>\n\n", fileh);

		Printv(swigtypeh, typemapLookup("objcimports", type, WARN_NONE),	// Import statements
					 "\n", typemapLookup("objcclassinterface", type, WARN_NONE),	// Class modifiers
					 " $objcclassname",	// Class name and base class
					 *Char(pure_baseclass) ? " : " : "", pure_baseclass, *Char(pure_interfaces) ?	// Interfaces
					 ", " : "", pure_interfaces, typemapLookup("objcinterface", type, WARN_NONE),	// main body of class
					 typemapLookup("objccode", type, WARN_NONE),	// extra Objective-C code
					 "@end\n", "\n", NIL);
		
		Printf(swigtypem, "#include \"%s\"\n\n", fileh);
		
    Printv(swigtypem, typemapLookup("objcimports", type, WARN_NONE),	// Import statements
					 typemapLookup("objcclassimplementation", type, WARN_NONE),	// Class modifiers
					 " $objcclassname", typemapLookup("objcbody", type, WARN_NONE),	// main body of class
					 typemapLookup("objccode", type, WARN_NONE),	// extra Objective-C code
					 "@end\n", "\n", NIL);
		
		
    Replaceall(swigtypeh, "$objcclassname", classname);
		Replaceall(swigtypem, "$objcclassname", classname);

    Printv(fh_swigtype, swigtypeh, NIL);
		Printv(fm_swigtype, swigtypem, NIL);

    Close(fh_swigtype);
    Delete(swigtypeh);
		
		Close(fm_swigtype);
    Delete(swigtypem);

		Delete(fileh);
    fileh = NULL;
		
		Delete(filem);
    filem = NULL;
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
      pure_baseclass = "";
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
    //Printv(proxy_class_decl, typemapLookup("objcimports", typemap_lookup_type, WARN_NONE),	// Import statements
	  // "\n", NIL);		// This would be needed when we decide upon a separate file for each class.

    // Class attributes
    const String *objcattributes = typemapLookup("objcattributes", typemap_lookup_type, WARN_NONE);
    if (objcattributes && *Char(objcattributes))
      Printf(proxy_class_def, "%s\n", objcattributes);

    Printv(proxy_class_decl, "\n", typemapLookup("objcclassinterface", typemap_lookup_type, WARN_NONE),	// Class modifiers
	   " $objcclassname",	// Class name and base class
	   (*Char(wanted_base) || *Char(pure_interfaces)) ? " : " : "", wanted_base, (*Char(wanted_base) && *Char(pure_interfaces)) ?	// Interfaces
	   ", " : "", pure_interfaces, derived ? typemapLookup("objcinterface_derived", typemap_lookup_type, WARN_NONE) :	// main body of class
	   typemapLookup("objcinterface", typemap_lookup_type, WARN_NONE),	// main body of class
	   NIL);

    Printv(proxy_class_def, typemapLookup("objcclassimplementation", typemap_lookup_type, WARN_NONE),	// Class modifiers
	   " $objcclassname", derived ? typemapLookup("objcbody_derived", typemap_lookup_type, WARN_NONE) :	// main body of class
	   typemapLookup("objcbody", typemap_lookup_type, WARN_NONE),	// main body of class
	   "\n", NIL);

    // C++ destructor is wrapped by the dealloc method
    // Note that the method name is specified in a typemap attribute called methodname
    String *destruct = NewString("");
    const String *tm = NULL;
    attributes = NewHash();
    String *destruct_methodname = NewString("dealloc");
    tm = typemapLookup("objcdestruct", typemap_lookup_type, WARN_NONE, attributes);

    // Emit the dealloc method
    if (tm) {
      // dealloc method
      Printv(destruct, tm, NIL);
      if (*Char(destructor_call))
	Replaceall(destruct, "$imcall", destructor_call);
      else
	Replaceall(destruct, "$imcall",
		   "[NSException raise:@\"UnsupportedOperationException\" format: @\"%@\", @\"C++ destructor does not have public access\"]");
      if (*Char(destruct)) {
	Printv(proxy_class_decl, "- (void)", destruct_methodname, ";", "\n", NIL);
	Printv(proxy_class_def, "- (void)", destruct_methodname, " ", destruct, "\n\n", NIL);
      }
    }
    // Emit extra user code
    Printv(proxy_class_def, typemapLookup("objccode", typemap_lookup_type, WARN_NONE),	// extra Objective-C code
	   NIL);

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

      destructor_call = NewString("");
      proxy_class_constants_code = NewString("");

      proxyClassHandler(n);
      Printv(proxy_h_code, proxy_class_decl, NIL);
      Printv(proxy_m_code, proxy_class_def, NIL);

      Clear(proxy_class_def);
      Clear(proxy_class_decl);
    }

    Language::classHandler(n);

    if (proxy_flag) {

      // Write out all the constants
      if (Len(proxy_class_constants_code) != 0)
	Printv(proxy_h_code, proxy_class_constants_code, NIL);

      Printv(proxy_h_code, proxy_class_decl, NIL);
      Printv(proxy_m_code, proxy_class_def, NIL);

      Printv(proxy_h_code, "\n@end\n\n", NIL);
      Printv(proxy_m_code, "\n@end\n\n", NIL);

      Delete(proxy_class_name);
      proxy_class_name = NULL;
      Delete(destructor_call);
      destructor_call = NULL;
      Delete(proxy_class_constants_code);
      proxy_class_constants_code = NULL;
    }

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * addThrows()
   *
   * Adds exception classes to a throws list. The throws list is the list of classes
   * that will form the Objective-C throws clause. Mainly for checked exceptions.
   * ----------------------------------------------------------------------------- */

  void addThrows(Node *n, const String *attribute, Node *parameter) {
    // Get the comma separated exception classes for the throws clause - held in typemap/feature's "throws" attribute
    String *throws_attribute = NewStringf("%s:throws", attribute);
    String *throws = Getattr(parameter, throws_attribute);

    if (throws && Len(throws) > 0) {
      String *throws_list = Getattr(n, "objc:throwslist");
      if (!throws_list) {
	throws_list = NewList();
	Setattr(n, "objc:throwslist", throws_list);
      }
      // Put the exception classes in the throws clause into a temporary List
      List *temp_classes_list = Split(throws, ',', INT_MAX);

      // Add the exception classes to the node throws list, but don't duplicate if already in list
      if (temp_classes_list && Len(temp_classes_list) > 0) {
	for (Iterator cls = First(temp_classes_list); cls.item; cls = Next(cls)) {
	  String *exception_class = NewString(cls.item);
	  Replaceall(exception_class, " ", "");	// remove spaces
	  Replaceall(exception_class, "\t", "");	// remove tabs
	  if (Len(exception_class) > 0) {
	    // $objcclassname substitution
	    SwigType *pt = Getattr(parameter, "type");
	    substituteClassname(pt, exception_class);

	    // Don't duplicate the Objective-C exception class in the throws clause
	    bool found_flag = false;
	    for (Iterator item = First(throws_list); item.item; item = Next(item)) {
	      if (Strcmp(item.item, exception_class) == 0)
		found_flag = true;
	    }
	    if (!found_flag)
	      Append(throws_list, exception_class);
	  }
	  Delete(exception_class);
	}
      }
      Delete(temp_classes_list);
    }
    Delete(throws_attribute);
  }

  /* -----------------------------------------------------------------------------
   * generateThrowsClause()
   *
   * Generates throws clause for checked exception
   * ----------------------------------------------------------------------------- */

  void generateThrowsClause(Node *n, String *code) {
    // Add the throws clause into code
    List *throws_list = Getattr(n, "objc:throwslist");
    if (throws_list) {
      Iterator cls = First(throws_list);
      Printf(code, " throws %s", cls.item);
      while ((cls = Next(cls)).item)
	Printf(code, ", %s", cls.item);
    }
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
