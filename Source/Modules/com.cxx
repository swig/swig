/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * com.cxx
 *
 * COM module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_com_cxx[] = "$Id$";

#include "swigmod.h"
#include "cparse.h"

typedef struct {
  unsigned long Data1;
  unsigned short Data2;
  unsigned short Data3;
  unsigned char Data4[8];
} GUID, UUID;

class COM:public Language {
  static const char *usage;
  const String *empty_string;

  Hash *swig_types_hash;
  List *filenames_list;

  File *f_runtime;
  File *f_header;
  File *f_module;
  File *f_deffile;
  File *f_wrappers;
  File *f_proxy;
  File *f_proxy_forward_defs;
  File *f_vtables;
  File *f_vtable_defs;
  File *f_factory;

  bool proxy_flag;		// Flag for generating proxy classes
  bool dllexports_flag;
  bool deffile_flag;
  bool enum_constant_flag;	// Flag for when wrapping an enum or constant
  bool static_flag;		// Flag for when wrapping a static functions or member variables
  bool variable_wrapper_flag;	// Flag for when wrapping a nonstatic member variable
  bool member_func_flag;
  String *proxy_class_def;
  String *proxy_class_forward_def;
  String *proxy_class_code;
  String *proxy_class_name;
  String *proxy_class_constants_code;
  String *clsid_list;
  List *proxy_class_member_functions;
  int guid_counter;
  GUID *proxy_iid;
  GUID *proxy_clsid;

  String *module_class_vtable_code;
  String *proxy_class_vtable_code;
  String *proxy_class_vtable_defs;

  String *module_class_name;	// module class name
  String *module_class_code;

public:

  /* -----------------------------------------------------------------------------
   * COM()
   * ----------------------------------------------------------------------------- */

  COM():empty_string(NewString("")),
      proxy_flag(true),
      deffile_flag(true),
      dllexports_flag(true),
      enum_constant_flag(false),
      proxy_class_vtable_code(NewString("")),
      proxy_class_vtable_defs(NewString("")),
      clsid_list(NewString("")),
      guid_counter(0) {
    /* Empty for now */
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

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("com");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-help") == 0) {
	  Printf(stdout, "%s\n", usage);
	} else if ((strcmp(argv[i], "-nodllexports") == 0)) {
	  Swig_mark_arg(i);
          dllexports_flag = false;
          deffile_flag = false;
	} else if (strcmp(argv[i], "-nodeffile") == 0) {
	  Swig_mark_arg(i);
          deffile_flag = false;
	}
      }
    }
    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGCOM 1", 0);

    // Add typemap definitions
    SWIG_typemap_lang("com");
    SWIG_config_file("com.swg");

    allow_overloading(1 /* FIXME: temporary */);
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {

    /* Initialize all of the output files */
    String *outfile = Getattr(n, "outfile");
    String *outfile_h = Getattr(n, "outfile_h");

    if (!outfile) {
      Printf(stderr, "Unable to determine outfile\n");
      SWIG_exit(EXIT_FAILURE);
    }

    f_runtime = NewFile(outfile, "w");
    if (!f_runtime) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }

    f_header = NewString("");
    f_wrappers = NewString("");
    f_proxy = NewString("");
    f_proxy_forward_defs = NewString("");
    f_vtables = NewString("");
    f_vtable_defs = NewString("");
    f_factory = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("factory", f_factory);

    swig_types_hash = NewHash();
    filenames_list = NewList();

    /* FIXME: do it as it is done in other targets */
    module_class_name = Copy(Getattr(n, "name"));

    module_class_code = NewString("");
    proxy_class_def = NewString("");
    proxy_class_forward_def = NewString("");
    proxy_class_code = NewString("");

    GUID typelib_guid;
    generateGUID(&typelib_guid);
    GUID module_iid;
    generateGUID(&module_iid);
    GUID module_clsid;
    generateGUID(&module_clsid);

    module_class_vtable_code = NewString("");

    Printf(module_class_vtable_code, "GUID IID_%s = ", module_class_name);
    formatGUID(module_class_vtable_code, &module_iid, true);
    Printf(module_class_vtable_code, ";\n\n");

    Printf(module_class_vtable_code, "GUID CLSID_%s = ", module_class_name);
    formatGUID(module_class_vtable_code, &module_clsid, true);
    Printf(module_class_vtable_code, ";\n\n");

    Printf(module_class_vtable_code, "HRESULT SWIGSTDCALL _wrap%sQueryInterface(void *that, REFIID iid, "
        "void ** ppvObject) {\n", module_class_name);

    Printf(module_class_vtable_code, "  if (SWIGIsEqual(iid, &IID_IUnknown) ||\n"
        "      SWIGIsEqual(iid, &IID_IDispatch) ||\n"
        "      SWIGIsEqual(iid, &IID_%s)", module_class_name);

    Printf(module_class_vtable_code, ") {\n"
        "    /* FIXME: This could be more elegant */\n"
        "    SWIGAddRef1(that);\n"
        "    *ppvObject = that;\n"
        "    return S_OK;\n"
        "  }\n\n");

    Printf(module_class_vtable_code, "  return E_NOINTERFACE;\n}\n\n");

    Printf(module_class_vtable_code, "extern SWIG_funcptr _wrap%s_vtable[];\n\n", module_class_name);

    Printf(module_class_vtable_code,
        "void * SWIGSTDCALL _wrap_new_%s() {\n"
        "  SWIGWrappedObject *res = new SWIGWrappedObject;\n"
        "  res->vtable = _wrap%s_vtable;\n"
        "  res->SWIGWrappedObject_vtable = NULL;\n"
        "  res->cPtr = NULL;\n"
        "  res->cMemOwn = 0;\n"
        "  res->refCount = 0;\n"
        "  /* GetTypeInfoOfGuid */\n"
        "  ((HRESULT (SWIGSTDCALL *)(ITypeLib *, GUID *, ITypeInfo **)) (((SWIGIUnknown *) SWIG_typelib)->vtable[6]))(SWIG_typelib, &IID_%s, &res->typeInfo);\n"
        "  return (void *) res;\n"
        "};\n\n",
        module_class_name, module_class_name, module_class_name);

    Printf(module_class_vtable_code, "SWIG_funcptr _wrap%s_vtable[] = "
        "{\n  (SWIG_funcptr) _wrap%sQueryInterface,"
        "\n  (SWIG_funcptr) SWIGAddRef1,"
        "\n  (SWIG_funcptr) SWIGRelease1,"
        "\n  (SWIG_funcptr) SWIGGetTypeInfoCount,"
        "\n  (SWIG_funcptr) SWIGGetTypeInfo,"
        "\n  (SWIG_funcptr) SWIGGetIDsOfNames,"
        "\n  (SWIG_funcptr) SWIGInvoke",
        module_class_name, module_class_name);

    Printf(clsid_list, "static char * SWIG_tlb_guid_string = \"{");
    formatGUID(clsid_list, &typelib_guid, false);
    Printf(clsid_list, "}\";\n\n");

    Printf(clsid_list, "static SWIGClassDescription_t SWIGClassDescription[] = {\n");
    Printf(clsid_list, "  { (SWIG_funcptr) _wrap_new_%s, CLSID_%s, \"{", module_class_name, module_class_name);
    formatGUID(clsid_list, &module_clsid, false);
    Printf(clsid_list,  "}\" },\n");

    /* Emit code */
    Language::top(n);

    /* Insert guard element; IID_IUnknown could in fact be any GUID */
    Printf(clsid_list, "  { NULL, IID_IUnknown, NULL } /* guard element */\n");

    Printf(clsid_list, "};\n\n");

    Printv(module_class_vtable_code, "\n};\n\n", NIL);

    // Output a COM type wrapper class for each SWIG type
    for (Iterator swig_type = First(swig_types_hash); swig_type.key; swig_type = Next(swig_type)) {
      emitTypeWrapperClass(swig_type.key, swig_type.item);
    }

    /* Generate DEF file */
    if (deffile_flag) {
      String *filen = NewStringf("%s%s.def", SWIG_output_directory(), module_class_name);
      f_deffile = NewFile(filen, "w");
      if (!f_deffile) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      // Append(filenames_list, Copy(filen));
      Delete(filen);
      filen = NULL;

      Printf(f_deffile, "LIBRARY %s\n", module_class_name);

      Printf(f_deffile, "EXPORTS\n"
          "  DllGetClassObject PRIVATE\n"
          "  DllCanUnloadNow PRIVATE\n"
          "  DllRegisterServer PRIVATE\n"
          "  DllUnregisterServer PRIVATE\n"
          "  DllMain\n");
    }

    /* Generate the IDL file containing the module class and proxy classes */
    {
      String *filen = NewStringf("%s%s.idl", SWIG_output_directory(), module_class_name);
      f_module = NewFile(filen, "w");
      if (!f_module) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      // Append(filenames_list, Copy(filen));
      Delete(filen);
      filen = NULL;

      // Banner for the IDL file
      emitBanner(f_module);

      // Standard imports
      Printf(f_module, "[\n  uuid(");
      formatGUID(f_module, &typelib_guid, false);
      Printf(f_module, ")\n]\nlibrary %sTLB {\n\n", module_class_name);

      // Import IDispatch
      Printf(f_module, "  importlib(\"stdole32.tlb\");\n\n");

      Printv(f_module, f_proxy_forward_defs, "\n", NIL);

      // Interface for module class
      Printf(f_module, "  [\n    object,\n    local,\n    uuid(");
      formatGUID(f_module, &module_iid, false);
      Printf(f_module, "),\n    dual\n  ]\n  interface %s : IDispatch {\n", module_class_name);

      // Add the wrapper methods
      Printv(f_module, module_class_code, NIL);

      Printf(f_module, "  };\n\n");

      Printv(f_module, "  [\n    uuid(", NIL);
      formatGUID(f_module, &module_clsid, false);
      Printv(f_module, ")\n  ]\n  coclass ", module_class_name, "Impl {\n"
          "    interface ", module_class_name, ";\n  };\n\n", NIL);

      // Add the proxy code
      Printv(f_module, f_proxy, NIL);

      Printf(f_module, "};\n");
    }

    /* Close all of the files */
    Dump(f_header, f_runtime);
    Delete(f_header);
    Printv(f_runtime, f_vtable_defs, "\n", NIL);
    Delete(f_vtable_defs);
    Dump(f_wrappers, f_runtime);
    Delete(f_wrappers);
    // Vtable for the module class
    Printv(f_runtime, module_class_vtable_code, NIL);
    Dump(f_vtables, f_runtime);
    Delete(f_vtables);
    Dump(clsid_list, f_runtime);
    Delete(clsid_list);
    if (dllexports_flag)
      Dump(f_factory, f_runtime);
    Delete(f_factory);
    Delete(f_runtime);
    Delete(f_module);
    if (deffile_flag) {
      Delete(f_deffile);
    }
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * emitBanner()
   * ----------------------------------------------------------------------------- */

  void emitBanner(File *f) {
    Printf(f, "/* ----------------------------------------------------------------------------\n");
    Printf(f, " * This file was automatically generated by SWIG (http://www.swig.org).\n");
    Printf(f, " * Version %s\n", Swig_package_version());
    Printf(f, " *\n");
    Printf(f, " * Do not make changes to this file unless you know what you are doing--modify\n");
    Printf(f, " * the SWIG interface file instead.\n");
    Printf(f, " * ----------------------------------------------------------------------------- */\n\n");
  }

  /* -----------------------------------------------------------------------------
   * functionWrapper()
   * ----------------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *c_return_type = NewString("");
    bool is_void_return;
    int num_arguments = 0;
    int num_required = 0;

    /* FIXME */
    String *overloaded_name = Copy(symname);

    // A new wrapper function object
    Wrapper *f = NewWrapper();

    // Make a wrapper name for this function
    String *wname = Swig_name_wrapper(overloaded_name);

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("ctype", l, f);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("ctype", n, "", 0))) {
      String *ctypeout = Getattr(n, "tmap:ctype:out");	// the type in the ctype typemap's out attribute overrides the type in the typemap
      if (ctypeout)
	tm = ctypeout;
      Printf(c_return_type, "%s", tm);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(t, 0));
    }

    is_void_return = (Cmp(c_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f, "jresult", c_return_type, "jresult", NIL);

    Printv(f->def, c_return_type, " SWIGSTDCALL ", wname, "(", NIL);

    // Emit all of the local variables for holding arguments.
    emit_parameter_variables(l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l, f);

    // Parameter overloading
    Setattr(n, "wrap:parms", l);
    Setattr(n, "wrap:name", wname);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required = emit_num_required(l);
    int gencomma = 0;

    /* There are no global or static member functions in COM - thus they need fake 'this' arguments */
    // FIXME: this should include static member functions too
    if ((!is_wrapping_class() || static_flag) && !enum_constant_flag) {
      Printv(f->def, "void *SWIG_ignored", NIL);
      gencomma = 1;
    }


    // Now walk the function parameter list and generate code to get arguments
    for (i = 0, p = l; i < num_arguments; i++) {

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *ln = Getattr(p, "lname");
      String *c_param_type = NewString("");
      String *arg = NewString("");

      Printf(arg, "j%s", ln);

      /* Get the ctype types of the parameter */
      if ((tm = Getattr(p, "tmap:ctype"))) {
	Printv(c_param_type, tm, NIL);
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      // Add parameter to C function
      Printv(f->def, gencomma ? ", " : "", c_param_type, " ", arg, NIL);

      gencomma = 1;

      // Get typemap for this argument
      if ((tm = Getattr(p, "tmap:in"))) {
	// FIXME: canThrow(n, "in", p);
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
      Delete(c_param_type);
      Delete(arg);
    }

    String *null_attribute = 0;
    // Now write code to make the function call
    /* FIXME: if (!native_function_flag) */ {
      if (Cmp(nodeType(n), "constant") == 0) {
        // Wrapping a constant hack
        Swig_save("functionWrapper", n, "wrap:action", NIL);

        // below based on Swig_VargetToFunction()
        SwigType *ty = Swig_wrapped_var_type(Getattr(n, "type"), use_naturalvar_mode(n));
        Setattr(n, "wrap:action", NewStringf("result = (%s) %s;", SwigType_lstr(ty, 0), Getattr(n, "value")));
      }

      // FIXME: Swig_director_emit_dynamic_cast(n, f);
      String *actioncode = emit_action(n);

      if (Cmp(nodeType(n), "constant") == 0)
        Swig_restore(n);

      /* Return value if necessary  */
      if ((tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode))) {
	// FIXME: canThrow(n, "out", n);
	Replaceall(tm, "$source", "result");	/* deprecated */
	Replaceall(tm, "$target", "jresult");	/* deprecated */
	Replaceall(tm, "$result", "jresult");

        if (GetFlag(n, "feature:new"))
          Replaceall(tm, "$owner", "1");
        else
          Replaceall(tm, "$owner", "0");

        /* FIXME: see if this is needed and works as it should */
        substituteClassname(t, tm);

	Printf(f->code, "%s", tm);
	null_attribute = Getattr(n, "tmap:out:null");
	if (Len(tm))
	  Printf(f->code, "\n");
      } else {
	Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(t, 0), Getattr(n, "name"));
      }
      emit_return_variable(n, t, f);
    }

    Printf(f->def, ") {");

    if (!is_void_return)
      Printv(f->code, "    return jresult;\n", NIL);
    Printf(f->code, "}\n");

    Wrapper_print(f, f_wrappers);

    if (!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
      moduleClassFunctionHandler(n);
      Printf(module_class_vtable_code, ",\n  (SWIG_funcptr) %s", wname);
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);

    if (proxy_flag) {
      // FIXME: String *overloaded_name = getOverloadedName(n);
      String *overloaded_name = Getattr(n, "sym:name");
      String *intermediary_function_name = Swig_name_member(getNSpace(), proxy_class_name, overloaded_name);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "imfuncname", intermediary_function_name);
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * moduleClassFunctionHandler()
   * ----------------------------------------------------------------------------- */

  int moduleClassFunctionHandler(Node *n) {
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    String *return_type = NewString("");
    String *function_code = NewString("");
    Parm *p;
    int i;
    String *func_name = NULL;

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("comtype", l, NULL);
    Swig_typemap_attach_parms("comin", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("comtype", n, "", 0))) {
      String *comtypeout = Getattr(n, "tmap:comtype:out");	// the type in the comtype typemap's out attribute overrides the type in the typemap
      if (comtypeout)
	tm = comtypeout;
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No comtype typemap defined for %s\n", SwigType_str(t, 0));
    }

    /* FIXME: ... */
    func_name = Getattr(n, "sym:name");

    Printf(function_code, "  %s %s(", return_type, func_name);

    /* Get number of required and total arguments */
    int num_arguments = emit_num_arguments(l);
    int num_required = emit_num_required(l);

    int gencomma = 0;

    /* Output each parameter */
    for (i = 0, p = l; i < num_arguments; i++) {

      /* Ignored parameters */
      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *param_type = NewString("");

      /* Get the COM parameter type */
      if ((tm = Getattr(p, "tmap:comtype"))) {
	substituteClassname(pt, tm);
	Printf(param_type, "%s", tm);
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No comtype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      /* FIXME: get the real argument name, it is important in the IDL */
      String *arg = NewStringf("arg%d", i);

      /* Add parameter to module class function */
      if (gencomma >= 2)
	Printf(function_code, ", ");
      gencomma = 2;
      Printf(function_code, "%s %s", param_type, arg);

      p = Getattr(p, "tmap:in:next");
      Delete(arg);
      Delete(param_type);
    }

    Printf(function_code, ");\n");

    Printv(module_class_code, function_code, NIL);
    Delete(function_code);
    Delete(return_type);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * emitProxyClassDefAndCPPCasts()
   * ----------------------------------------------------------------------------- */

  void emitProxyClassDefAndCPPCasts(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n, "name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;
    String *typemap_lookup_type = Getattr(n, "classtypeobj");
    bool feature_director = Swig_directorclass(n) ? true : false;

    Node *attributes = NewHash();

    const String *pure_baseclass = NewString("");

    // C++ inheritance
    // FIXME: if (!purebase_replace) {
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
            Swig_warning(WARN_CSHARP_MULTIPLE_INHERITANCE, input_file, line_number,
                         "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in C#.\n", proxyclassname, baseclassname);
            base = Next(base);
          }
        }
      }
    // FIXME: }

    const String *wanted_base = baseclass ? baseclass : pure_baseclass;
    bool derived = baseclass && getProxyName(c_baseclassname);

    if (!Getattr(n, "abstract")) {
      Printv(proxy_class_def, "  [\n    uuid(", NIL);
      formatGUID(proxy_class_def, proxy_clsid, false);
      Printv(proxy_class_def, ")\n  ]\n  coclass $comclassnameImpl {\n"
          "    interface $comclassname;\n  };\n\n", NIL);
    }

    Printv(proxy_class_forward_def, "  interface $comclassname;\n", NIL);
    Printv(proxy_class_def, "  [\n    object,\n    local,\n    uuid(", NIL);
    formatGUID(proxy_class_def, proxy_iid, false);
/*
    Printv(proxy_class_def, ")\n  ]\n  interface $comclassname",
        *Char(wanted_base) ? " : " : "",
        *Char(wanted_base) ? wanted_base : "", " {", NIL);
 */
    Printv(proxy_class_def, "),\n    dual\n  ]\n  interface $comclassname : ",
        *Char(wanted_base) ? wanted_base : "IDispatch", " {", NIL);

    Delete(attributes);

    // FIXME: temporary
    Printv(proxy_class_def, typemapLookup("combody", typemap_lookup_type, WARN_NONE),
	   NIL);

    // Emit extra user code
    Printv(proxy_class_def, typemapLookup("comcode", typemap_lookup_type, WARN_NONE),
	   NIL);

    // Substitute various strings into the above template
    Replaceall(proxy_class_code, "$comclassname", proxy_class_name);
    Replaceall(proxy_class_def, "$comclassname", proxy_class_name);
    Replaceall(proxy_class_forward_def, "$comclassname", proxy_class_name);

    Replaceall(proxy_class_def, "$module", module_class_name);
    Replaceall(proxy_class_code, "$module", module_class_name);

    Delete(baseclass);
  }

  /* ----------------------------------------------------------------------
   * generateGUID()
   * ---------------------------------------------------------------------- */

  void generateGUID(GUID *result) {
    GUID temp = { 0x4ec3e0ed, 0x3cb2, 0x4f1a, 0x81, 0x85, 0x73, 0xfa, 0xdc, 0xc5, 0x75, guid_counter++ };
    *result = temp;
  }

  /* ----------------------------------------------------------------------
   * formatGUID()
   * ---------------------------------------------------------------------- */

  void formatGUID(File *output, GUID *input, bool cFormat) {
    if (cFormat) {
      Printf(output,
          "{ 0x%08x, 0x%04x, 0x%04x, { 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x}}",
          input->Data1, input->Data2, input->Data3, input->Data4[0], input->Data4[1],
          input->Data4[2], input->Data4[3], input->Data4[4], input->Data4[5], input->Data4[6], input->Data4[7]);
    } else {
      Printf(output,
          "%08X-%04X-%04X-%04X-%02X%02X%02X%02X%02X%02X",
          input->Data1, input->Data2, input->Data3, (((int) input->Data4[0]) << 8) | input->Data4[1],
          input->Data4[2], input->Data4[3], input->Data4[4], input->Data4[5], input->Data4[6], input->Data4[7]);
    }
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {
    if (proxy_flag) {
      proxy_class_name = NewString(Getattr(n, "sym:name"));
      List *bases = NULL;

      if (!addSymbol(proxy_class_name, n))
	return SWIG_ERROR;

/* FIXME */
#if 0
      if (Cmp(proxy_class_name, imclass_name) == 0) {
	Printf(stderr, "Class name cannot be equal to intermediary class name: %s\n", proxy_class_name);
	SWIG_exit(EXIT_FAILURE);
      }
#endif

      if (Cmp(proxy_class_name, module_class_name) == 0) {
	Printf(stderr, "Class name cannot be equal to module class name: %s\n", proxy_class_name);
	SWIG_exit(EXIT_FAILURE);
      }

      Clear(proxy_class_def);
      Clear(proxy_class_code);
      Clear(proxy_class_forward_def);
      Clear(proxy_class_vtable_code);
      Clear(proxy_class_vtable_defs);

      proxy_iid = new GUID;
      generateGUID(proxy_iid);
      Setattr(n, "wrap:iid", proxy_iid);

      Printf(proxy_class_vtable_code, "GUID IID_%s = ", proxy_class_name);
      formatGUID(proxy_class_vtable_code, proxy_iid, true);
      Printf(proxy_class_vtable_code, ";\n\n");

      if (!Getattr(n, "abstract")) {
        /* Generate class object */
        proxy_clsid = new GUID;
        generateGUID(proxy_clsid);

        Printf(proxy_class_vtable_code, "GUID CLSID_%s = ", proxy_class_name);
        formatGUID(proxy_class_vtable_code, proxy_clsid, true);
        Printf(proxy_class_vtable_code, ";\n\n");

        Printf(clsid_list, "  { (SWIG_funcptr) _wrap_new_%s, CLSID_%s, \"{", proxy_class_name, proxy_class_name);
        formatGUID(clsid_list, proxy_clsid, false);
        Printf(clsid_list,  "}\" },\n");
      }

      Printf(proxy_class_vtable_code, "HRESULT SWIGSTDCALL _wrap%sQueryInterface1(void *that, REFIID iid, "
          "void ** ppvObject) {\n", proxy_class_name);

      /* Look if the requested interface is ISWIGWrappedObject */
      Printf(proxy_class_vtable_code,
          "  if (iid == IID_ISWIGWrappedObject) {\n"
          "    /* FIXME: This could be more elegant */\n"
          "    SWIGAddRef1(that);\n"
          /* Address of current object, incremented by the size of a pointer */
          "    *ppvObject = (void *) ((void **)that + 1);\n"
          "    return S_OK;\n"
          "  }\n\n");

      Printf(proxy_class_vtable_code, "  if (SWIGIsEqual(iid, &IID_IUnknown) ||\n"
        "      SWIGIsEqual(iid, &IID_IDispatch) ||\n"
        "      SWIGIsEqual(iid, &IID_%s)", proxy_class_name);

      bases = Getattr(n, "bases");

      /* Iterate through the ancestors */
      while (bases) {
        Iterator base = First(bases);

        Printf(proxy_class_vtable_code, " ||\n      iid == IID_%s", Getattr(base.item, "sym:name"));

        /* Get next base */
        bases = Getattr(base.item, "bases");
      }

      Printf(proxy_class_vtable_code, ") {\n"
          "    /* FIXME: This could be more elegant */\n"
          "    SWIGAddRef1(that);\n"
          "    *ppvObject = that;\n"
          "    return S_OK;\n"
          "  }\n\n");

      Printf(proxy_class_vtable_code, "  return E_NOINTERFACE;\n}\n\n");

      bases = NULL;

      Printf(proxy_class_vtable_code, "HRESULT SWIGSTDCALL _wrap%sQueryInterface2(void *that, REFIID iid, "
          "void ** ppvObject) {\n", proxy_class_name);

      Printf(proxy_class_vtable_code,
          "  return _wrap%sQueryInterface1((void *) ((void **) that - 1), iid, ppvObject);\n", proxy_class_name);

      Printf(proxy_class_vtable_code, "}\n\n");

      Printf(proxy_class_vtable_code, "SWIG_funcptr _wrap%sSWIGWrappedObject_vtable[] = "
          "{\n  (SWIG_funcptr) _wrap%sQueryInterface2,"
          "\n  (SWIG_funcptr) SWIGAddRef2,"
          "\n  (SWIG_funcptr) SWIGRelease2,"
          "\n  (SWIG_funcptr) SWIGGetCPtr"
          "\n};\n\n",
          proxy_class_name, proxy_class_name);

      Printf(proxy_class_vtable_code, "SWIG_funcptr _wrap%svtable[] = "
          "{\n  (SWIG_funcptr) _wrap%sQueryInterface1,"
          "\n  (SWIG_funcptr) SWIGAddRef1,"
          "\n  (SWIG_funcptr) SWIGRelease1,"
          "\n  (SWIG_funcptr) SWIGGetTypeInfoCount,"
          "\n  (SWIG_funcptr) SWIGGetTypeInfo,"
          "\n  (SWIG_funcptr) SWIGGetIDsOfNames,"
          "\n  (SWIG_funcptr) SWIGInvoke",
          proxy_class_name, proxy_class_name);

      bases = Getattr(n, "bases");

      if (!bases) {
        proxy_class_member_functions = NewList();
        Setattr(n, "wrap:member_functions", proxy_class_member_functions);
      } else {
        Iterator base = First(bases);

        List *base_member_functions = Getattr(base.item, "wrap:member_functions");
        Setattr(n, "wrap:member_functions", Copy(base_member_functions));

        for (Iterator func = First(base_member_functions); func.item; func = Next(func)) {
          Printf(proxy_class_vtable_code, ",\n  (SWIG_funcptr)%s", func.item);
        }
      }

      // FIXME: destructor_call = NewString("");
      proxy_class_constants_code = NewString("");
    }

    Language::classHandler(n);

    if (proxy_flag) {

      emitProxyClassDefAndCPPCasts(n);

      Replaceall(proxy_class_def, "$module", module_class_name);
      Replaceall(proxy_class_code, "$module", module_class_name);
      Replaceall(proxy_class_constants_code, "$module", module_class_name);
      // FIXME: Replaceall(proxy_class_def, "$imclassname", imclass_name);
      // FIXME: Replaceall(proxy_class_code, "$imclassname", imclass_name);
      // FIXME: Replaceall(proxy_class_constants_code, "$imclassname", imclass_name);
      // FIXME: Replaceall(proxy_class_def, "$dllimport", dllimport);
      // FIXME: Replaceall(proxy_class_code, "$dllimport", dllimport);
      // FIXME: Replaceall(proxy_class_constants_code, "$dllimport", dllimport);

      Printv(f_proxy_forward_defs, proxy_class_forward_def, NIL);
      Printv(f_proxy, proxy_class_def, proxy_class_code, NIL);

      // Write out all the constants
      if (Len(proxy_class_constants_code) != 0)
	Printv(f_proxy, proxy_class_constants_code, NIL);

      Printf(f_proxy, "  };\n");

      Printv(proxy_class_vtable_code, "\n};\n\n", NIL);

      Printf(proxy_class_vtable_code, "void * SWIGSTDCALL SWIG_wrap%s(void *arg) {\n"
          "  SWIGWrappedObject *res = new SWIGWrappedObject;\n"
          "  res->vtable = _wrap%svtable;\n"
          "  res->SWIGWrappedObject_vtable = _wrap%sSWIGWrappedObject_vtable;\n"
          "  res->cPtr = arg;\n"
          "  res->cMemOwn = 0;\n"
          "  res->refCount = 0;\n"
          "  /* GetTypeInfoOfGuid */\n"
          "  ((HRESULT (SWIGSTDCALL *)(ITypeLib *, GUID *, ITypeInfo **)) (((SWIGIUnknown *) SWIG_typelib)->vtable[6]))(SWIG_typelib, &IID_%s, &res->typeInfo);\n"
          "  return (void *) res;\n"
          "}\n\n",
          proxy_class_name, proxy_class_name, proxy_class_name, proxy_class_name);

      Printf(proxy_class_vtable_defs, "void * SWIGSTDCALL SWIG_wrap%s(void *arg);\n", proxy_class_name);

      Printv(f_vtables, proxy_class_vtable_code, NIL);
      Printv(f_vtable_defs, proxy_class_vtable_defs, NIL);

      Delete(proxy_class_name);
      proxy_class_name = NULL;
      Delete(proxy_class_constants_code);
      proxy_class_constants_code = NULL;
      delete proxy_iid;
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node *n) {

    static_flag = true;
    member_func_flag = true;
    Language::staticmemberfunctionHandler(n);

    if (proxy_flag) {
      // FIXME: String *overloaded_name = getOverloadedName(n);
      String *overloaded_name = Getattr(n, "sym:name");
      String *intermediary_function_name = Swig_name_member(getNSpace(), proxy_class_name, overloaded_name);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "imfuncname", intermediary_function_name);
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    static_flag = false;
    member_func_flag = false;

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * proxyClassFunctionHandler()
   *
   * Function called for creating a COM wrapper function around a c++ function in the 
   * proxy class. Used for both static and non-static C++ class functions.
   * C++ class static functions map to member functions of the objects and/or to
   * member functions of the module class (TODO).
   * ----------------------------------------------------------------------------- */

  void proxyClassFunctionHandler(Node *n) {
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *intermediary_function_name = Getattr(n, "imfuncname");
    String *proxy_function_name = Getattr(n, "proxyfuncname");
    String *tm;
    Parm *p;
    int i;
    String *return_type = NewString("");
    String *function_code = NewString("");
    bool setter_flag = false;
    String *pre_code = NewString("");
    String *post_code = NewString("");

    if (!proxy_flag)
      return;

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in COM
    if (Getattr(n, "overload:ignore"))
      return;

    // Don't generate proxy method for additional explicitcall method used in directors
    if (GetFlag(n, "explicitcall"))
      return;

    if (!Getattr(n, "override")) {
      String *wname = Getattr(n, "wrap:name");
      Printf(proxy_class_vtable_code, ",\n  (SWIG_funcptr)%s", wname);
      Append(proxy_class_member_functions, wname);
    }

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("comtype", l, NULL);
    // FIXME: Swig_typemap_attach_parms("javain", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("comtype", n, "", 0))) {
      // Note that in the case of polymorphic (covariant) return types, the method's return type is changed to be the base of the C++ return type
      SwigType *covariant = Getattr(n, "covariant");
      substituteClassname(covariant ? covariant : t, tm);
      Printf(return_type, "%s", tm);
      if (covariant)
	Swig_warning(WARN_CSHARP_COVARIANT_RET, input_file, line_number,
		     "Covariant return types not supported in COM. Proxy method will return %s.\n", SwigType_str(covariant, 0));
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF, input_file, line_number, "No comstype typemap defined for %s\n", SwigType_str(t, 0));
    }

    /* Start generating the proxy function */
    Printf(function_code, "    %s %s(", return_type, proxy_function_name);

    emit_mark_varargs(l);

    // FIXME: int gencomma = !static_flag;
    int gencomma = 1;

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
      if (!(variable_wrapper_flag && i == 0) || static_flag) {
	SwigType *pt = Getattr(p, "type");
	String *param_type = NewString("");

	/* Get the COM parameter type */
	if ((tm = Getattr(p, "tmap:comtype"))) {
	  substituteClassname(pt, tm);
	  Printf(param_type, "%s", tm);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF, input_file, line_number, "No comtype typemap defined for %s\n", SwigType_str(pt, 0));
	}

	// FIXME: String *arg = makeParameterName(n, p, i, setter_flag);
        String *arg = NewStringf("arg%d", i);

	/* Add parameter to proxy function */
	if (gencomma >= 2)
	  Printf(function_code, ", ");
	gencomma = 2;
	Printf(function_code, "%s %s", param_type, arg);

	Delete(arg);
	Delete(param_type);
      }
      p = Getattr(p, "tmap:in:next");
    }

    Printf(function_code, ")");

    // FIXME: generateThrowsClause(n, function_code);
    Printv(function_code, ";\n", NIL);

    if (!Getattr(n, "override")) {
      Printv(proxy_class_code, function_code, NIL);
    }

    Delete(pre_code);
    Delete(post_code);
    Delete(function_code);
    Delete(return_type);
  }

  /* -----------------------------------------------------------------------------
   * emitTypeWrapperClass()
   * ----------------------------------------------------------------------------- */

  void emitTypeWrapperClass(String *classname, SwigType *type) {
    Clear(proxy_class_def);
    Clear(proxy_class_forward_def);

    proxy_iid = new GUID;
    generateGUID(proxy_iid);

    Printv(proxy_class_forward_def, "  interface $comclassname;\n", NIL);

    Printv(proxy_class_def, "  [\n    object,\n    local,\n    uuid(", NIL);
    formatGUID(proxy_class_def, proxy_iid, false);
    Printv(proxy_class_def, ")\n  ]\n  interface $comclassname {\n",
           typemapLookup("combody", type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF),
	   typemapLookup("comcode", type, WARN_NONE),
           "  };\n\n", NIL);

    Replaceall(proxy_class_forward_def, "$comclassname", classname);
    Replaceall(proxy_class_def, "$comclassname", classname);
    Replaceall(proxy_class_forward_def, "$module", module_class_name);
    Replaceall(proxy_class_def, "$module", module_class_name);

    Printf(f_vtable_defs, "void * (SWIGSTDCALL * SWIG_wrap%s)(void *) = SWIG_wrap_opaque;\n", classname);

    Printv(f_proxy_forward_defs, proxy_class_forward_def, NIL);
    Printv(f_proxy, proxy_class_def, NIL);

    delete proxy_iid;
  }

  /* -----------------------------------------------------------------------------
   * typemapLookup()
   * ----------------------------------------------------------------------------- */

  const String *typemapLookup(const String *op, String *type, int warning, Node *typemap_attributes = NULL) {
    String *tm = NULL;
    const String *code = NULL;

/*
    This code doesn't compile with the latest SWIG any more as Swig_typemap_search() doesn't exist now,
    but it doesn't matter anyhow as it is removed by the later commits, so just comment it out in this one.

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
*/
    return code ? code : empty_string;
  }

  /* -----------------------------------------------------------------------------
   * substituteClassname()
   *
   * Substitute $comclassname with the proxy class name for classes/structs/unions that SWIG knows about.
   * Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the COM class name. Note that the $&comclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - comtype typemap
   * Outputs:
   *   tm - comtype typemap with $comclassname substitution
   * Return:
   *   substitution_performed - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteClassname(SwigType *pt, String *tm) {
    bool substitution_performed = false;
    SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$comclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteClassnameSpecialVariable(classnametype, tm, "$comclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$*comclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      substituteClassnameSpecialVariable(classnametype, tm, "$*comclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$&comclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteClassnameSpecialVariable(classnametype, tm, "$&comclassname");
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
      // FIXME: String *enumname = getEnumName(classnametype);
      String *enumname = classnametype;
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


};				/* class COM */

/* -----------------------------------------------------------------------------
 * swig_com()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_com() {
  return new COM();
}
extern "C" Language *swig_com(void) {
  return new_swig_com();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *COM::usage = (char *) "\
COM Options (available with -com)\n\
     -nodeffile      - Do not generate DEF file\n\
     -nodllexports   - Do not generate DllGetClassObject and DllCanUnloadNow\n\
                       (implicates -nodeffile)\n\
\n";
