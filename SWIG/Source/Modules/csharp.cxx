/* -----------------------------------------------------------------------------
 * csharp.cxx
 *
 *     CSharp wrapper module.
 *
 * Author(s) : William Fulton
 *             Neil Cawse
 *
 * Copyright (C) 1999-2002.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

char cvsroot_csharp_cxx[] = "$Header$";

#include <limits.h> // for INT_MAX
#include "swigmod.h"
#include <ctype.h>


class CSHARP : public Language {
  static const char *usage;
  const  String *empty_string;
  const  String *public_string;
  const  String *protected_string;

  Hash   *swig_types_hash;
  File   *f_runtime;
  File   *f_header;
  File   *f_wrappers;
  File   *f_init;

  bool   proxy_flag; // Flag for generating proxy classes
  bool   native_function_flag;     // Flag for when wrapping a native function
  bool   enum_constant_flag; // Flag for when wrapping an enum or constant
  bool   static_flag; // Flag for when wrapping a static functions or member variables
  bool   variable_wrapper_flag; // Flag for when wrapping a nonstatic member variable
  bool   wrapping_member_flag; // Flag for when wrapping a member variable/enum/const
  bool   global_variable_flag; // Flag for when wrapping a global variable
  bool   old_variable_names;      // Flag for old style variable names in the intermediary class
  bool   generate_property_declaration_flag; // Flag for generating properties

  String *imclass_name;  // intermediary class name
  String *module_class_name;  // module class name
  String *imclass_class_code; // intermediary class code
  String *proxy_class_def;
  String *proxy_class_code;
  String *module_class_code;
  String *proxy_class_name;
  String *variable_name; //Name of a variable being wrapped
  String *proxy_class_constants_code;
  String *module_class_constants_code;
  String *enum_code;
  String *dllimport; // DllImport attribute name
  String *namespce; // Optional namespace name
  String *imclass_imports; //intermediary class imports from %pragma
  String *module_imports; //module imports from %pragma
  String *imclass_baseclass; //inheritance for intermediary class class from %pragma
  String *module_baseclass; //inheritance for module class from %pragma
  String *imclass_interfaces; //interfaces for intermediary class class from %pragma
  String *module_interfaces; //interfaces for module class from %pragma
  String *imclass_class_modifiers; //class modifiers for intermediary class overriden by %pragma
  String *module_class_modifiers; //class modifiers for module class overriden by %pragma
  String *upcasts_code; //C++ casts for inheritance hierarchies C++ code
  String *imclass_cppcasts_code; //C++ casts up inheritance hierarchies intermediary class code
  String *destructor_call; //C++ destructor call if any

  enum EnumFeature { SimpleEnum, TypeunsafeEnum, TypesafeEnum, ProperEnum };

  public:

  /* -----------------------------------------------------------------------------
   * CSHARP()
   * ----------------------------------------------------------------------------- */

  CSHARP() : 
    empty_string(NewString("")),
    public_string(NewString("public")),
    protected_string(NewString("protected")),

    swig_types_hash(NULL),
    f_runtime(NULL),
    f_header(NULL),
    f_wrappers(NULL),
    f_init(NULL),

    proxy_flag(true),
    native_function_flag(false),
    enum_constant_flag(false),
    static_flag(false),
    variable_wrapper_flag(false),
    wrapping_member_flag(false),
    global_variable_flag(false),
    old_variable_names (false),
    generate_property_declaration_flag(false),

    imclass_name(NULL),
    module_class_name(NULL),
    imclass_class_code(NULL),
    proxy_class_def(NULL),
    proxy_class_code(NULL),
    module_class_code(NULL),
    proxy_class_name(NULL),
    variable_name(NULL),
    proxy_class_constants_code(NULL),
    module_class_constants_code(NULL),
    enum_code(NULL),
    dllimport(NULL),
    namespce(NULL),
    imclass_imports(NULL),
    module_imports(NULL),
    imclass_baseclass(NULL),
    module_baseclass(NULL),
    imclass_interfaces(NULL),
    module_interfaces(NULL),
    imclass_class_modifiers(NULL),
    module_class_modifiers(NULL),
    upcasts_code(NULL),
    imclass_cppcasts_code(NULL),
    destructor_call(NULL)

    {
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
        return Getattr(n,"sym:name");
      }
    }
    return NULL;
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("csharp");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i],"-dllimport") == 0) {
          if (argv[i+1]) {
            dllimport = NewString("");
            Printf(dllimport, argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if (strcmp(argv[i],"-namespace") == 0) {
          if (argv[i+1]) {
            namespce = NewString("");
            Printf(namespce, argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if ((strcmp(argv[i],"-noproxy") == 0)) {
          Swig_mark_arg(i);
          proxy_flag = false;
        } else if (strcmp(argv[i],"-oldvarnames") == 0) {
          Swig_mark_arg(i);
	  old_variable_names = true;
        } else if (strcmp(argv[i],"-help") == 0) {
          Printf(stdout,"%s\n", usage);
        }
      }
    }

    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGCSHARP 1",0);

    // Add typemap definitions
    SWIG_typemap_lang("csharp");
    SWIG_config_file("csharp.swg");

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {

    // Get any options set in the module directive
    Node* optionsnode = Getattr( Getattr(n,"module"), "options");

    if (optionsnode) {
        if (Getattr(optionsnode,"imclassname"))
          imclass_name = Copy(Getattr(optionsnode,"imclassname"));
    }

    /* Initialize all of the output files */
    String *outfile = Getattr(n,"outfile");

    f_runtime = NewFile(outfile,"w");
    if (!f_runtime) {
      Printf(stderr,"Unable to open %s\n", outfile);
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

    swig_types_hash = NewHash();

    // Make the intermediary class and module class names. The intermediary class name can be set in the module directive.
    if (!imclass_name) {
      imclass_name = NewStringf("%sPINVOKE", Getattr(n,"name"));
      module_class_name = Copy(Getattr(n,"name"));
    } else {
      // Rename the module name if it is the same as intermediary class name - a backwards compatibility solution
      if (Cmp(imclass_name, Getattr(n,"name")) == 0)
        module_class_name = NewStringf("%sModule", Getattr(n,"name"));
      else
        module_class_name = Copy(Getattr(n,"name"));
    }

    imclass_class_code = NewString("");
    proxy_class_def = NewString("");
    proxy_class_code = NewString("");
    module_class_constants_code = NewString("");
    imclass_baseclass = NewString("");
    imclass_interfaces = NewString("");
    imclass_class_modifiers = NewString("");
    module_class_code = NewString("");
    module_baseclass = NewString("");
    module_interfaces = NewString("");
    module_imports = NewString("");
    module_class_modifiers = NewString("");
    imclass_imports = NewString("");
    imclass_cppcasts_code = NewString("");
    upcasts_code = NewString("");
    if (!namespce) namespce = NewString("");
    if (!dllimport) dllimport = Copy(module_class_name);

    Swig_banner(f_runtime);               // Print the SWIG banner message

    String *wrapper_name = NewString("");

    Printf(wrapper_name, "CSharp_%%f", imclass_name);
    Swig_name_register((char*)"wrapper", Char(wrapper_name));
    if (old_variable_names) {
      Swig_name_register((char*)"set", (char*)"set_%v");
      Swig_name_register((char*)"get", (char*)"get_%v");
    }

    Delete(wrapper_name);

    Printf(f_wrappers,"\n#ifdef __cplusplus\n");
    Printf(f_wrappers,"extern \"C\" {\n");
    Printf(f_wrappers,"#endif\n\n");

    /* Emit code */
    Language::top(n);

    // Generate the intermediary class
    {
      String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), imclass_name);
      File *f_im = NewFile(filen,"w");
      if(!f_im) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the intermediary class file
      emitBanner(f_im);

      if(Len(namespce) > 0)
        Printf(f_im, "namespace %s {\n", namespce);

      if(imclass_imports)
        Printf(f_im, "%s\n", imclass_imports);

      if (Len(imclass_class_modifiers) > 0)
        Printf(f_im, "%s ", imclass_class_modifiers);
      Printf(f_im, "%s ", imclass_name);

      if (imclass_baseclass && *Char(imclass_baseclass))
          Printf(f_im, ": %s ", imclass_baseclass);
      if (Len(imclass_interfaces) > 0)
        Printv(f_im, "implements ", imclass_interfaces, " ", NIL);
      Printf(f_im, "{\n");

      // Add the intermediary class methods
      Replaceall(imclass_class_code, "$module", module_class_name);
      Replaceall(imclass_class_code, "$dllimport", dllimport);
      Printv(f_im, imclass_class_code, NIL);
      Printv(f_im, imclass_cppcasts_code, NIL);

      // Finish off the class
      Printf(f_im, "}\n");
      Printf(f_im, Len(namespce) > 0 ?  "\n}\n" : "");
      Close(f_im);
    }

    // Generate the C# module class
    {
      String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), module_class_name);
      File *f_module = NewFile(filen,"w");
      if(!f_module) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the module class file
      emitBanner(f_module);

      if(Len(namespce) > 0)
        Printf(f_module, "namespace %s {\n", namespce);

      if(module_imports)
        Printf(f_module, "%s\n", module_imports);

      if (Len(module_class_modifiers) > 0)
        Printf(f_module, "%s ", module_class_modifiers);
      Printf(f_module, "%s ", module_class_name);

      if (module_baseclass && *Char(module_baseclass))
          Printf(f_module, ": %s ", module_baseclass);
      if (Len(module_interfaces) > 0)
        Printv(f_module, "implements ", module_interfaces, " ", NIL);
      Printf(f_module, "{\n");

      Replaceall(module_class_code, "$module", module_class_name);
      Replaceall(module_class_constants_code, "$module", module_class_name);

      Replaceall(module_class_code, "$dllimport", dllimport);
      Replaceall(module_class_constants_code, "$dllimport", dllimport);

      // Add the wrapper methods
      Printv(f_module, module_class_code, NIL);

      // Write out all the global constants
      Printv(f_module, module_class_constants_code, NIL);

      // Finish off the class
      Printf(f_module, "}\n");
      Printf(f_module, Len(namespce) > 0 ?  "\n}\n" : "");

      Close(f_module);
    }

    if(upcasts_code)
      Printv(f_wrappers,upcasts_code,NIL);

    Printf(f_wrappers,"#ifdef __cplusplus\n");
    Printf(f_wrappers,"}\n");
    Printf(f_wrappers,"#endif\n");

    // Output a C# type wrapper class for each SWIG type
    for (Iterator swig_type = First(swig_types_hash); swig_type.key; swig_type = Next(swig_type)) {
      emitTypeWrapperClass(swig_type.key, swig_type.item);
    }

    Delete(swig_types_hash); swig_types_hash = NULL;
    Delete(imclass_name); imclass_name = NULL;
    Delete(imclass_class_code); imclass_class_code = NULL;
    Delete(proxy_class_def); proxy_class_def = NULL;
    Delete(proxy_class_code); proxy_class_code = NULL;
    Delete(module_class_constants_code); module_class_constants_code = NULL;
    Delete(imclass_baseclass); imclass_baseclass = NULL;
    Delete(imclass_interfaces); imclass_interfaces = NULL;
    Delete(imclass_class_modifiers); imclass_class_modifiers = NULL;
    Delete(module_class_name); module_class_name = NULL;
    Delete(module_class_code); module_class_code = NULL;
    Delete(module_baseclass); module_baseclass = NULL;
    Delete(module_interfaces); module_interfaces = NULL;
    Delete(module_imports); module_imports = NULL;
    Delete(module_class_modifiers); module_class_modifiers = NULL;
    Delete(imclass_imports); imclass_imports = NULL;
    Delete(imclass_cppcasts_code); imclass_cppcasts_code = NULL;
    Delete(upcasts_code); upcasts_code = NULL;
    Delete(namespce); namespce = NULL;

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

  /* -----------------------------------------------------------------------------
   * emitBanner()
   * ----------------------------------------------------------------------------- */

  void emitBanner(File *f) {
    Printf(f, "/* ----------------------------------------------------------------------------\n");
    Printf(f, " * This file was automatically generated by SWIG (http://www.swig.org).\n");
    Printf(f, " * Version %s\n", PACKAGE_VERSION);
    Printf(f, " *\n");
    Printf(f, " * Do not make changes to this file unless you know what you are doing--modify\n");
    Printf(f, " * the SWIG interface file instead.\n");
    Printf(f, " * ----------------------------------------------------------------------------- */\n\n");
  }

  /* ----------------------------------------------------------------------
   * nativeWrapper()
   * ---------------------------------------------------------------------- */

  virtual int nativeWrapper(Node *n) {
    String *wrapname = Getattr(n,"wrap:name");

    if (!addSymbol(wrapname,n)) return SWIG_ERROR;

    if (Getattr(n,"type")) {
      Swig_save("nativeWrapper",n,"name",NIL);
      Setattr(n,"name", wrapname);
      native_function_flag = true;
      functionWrapper(n);
      Swig_restore(n);
      native_function_flag = false;
    } else {
      Printf(stderr,"%s : Line %d. No return type for %%native method %s.\n", input_file, line_number, Getattr(n,"wrap:name"));
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   * ---------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    String   *symname = Getattr(n,"sym:name");
    SwigType *t = Getattr(n,"type");
    ParmList *l = Getattr(n,"parms");
    String    *tm;
    Parm      *p;
    int       i;
    String    *c_return_type = NewString("");
    String    *im_return_type = NewString("");
    String    *cleanup = NewString("");
    String    *outarg = NewString("");
    String    *body = NewString("");
    String    *im_outattribute = 0;
    int       num_arguments = 0;
    int       num_required = 0;
    bool      is_void_return;
    String    *overloaded_name = getOverloadedName(n);

    if (!Getattr(n,"sym:overloaded")) {
      if (!addSymbol(Getattr(n,"sym:name"),n)) return SWIG_ERROR;
    }

    /*
       The rest of this function deals with generating the intermediary class wrapper function (that wraps
       a c/c++ function) and generating the PInvoke c code. Each C# wrapper function has a 
       matching PInvoke c function call.
       */

    // A new wrapper function object
    Wrapper *f = NewWrapper();

    // Make a wrapper name for this function
    String *wname = Swig_name_wrapper(overloaded_name);

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("ctype", l, f);
    Swig_typemap_attach_parms("imtype", l, f);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("ctype",n,"",0))) {
      String *ctypeout = Getattr(n,"tmap:ctype:out"); // the type in the ctype typemap's out attribute overrides the type in the typemap
      if (ctypeout)
        tm = ctypeout;
      Printf(c_return_type,"%s", tm);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CTYPE_UNDEF, input_file, line_number, 
          "No ctype typemap defined for %s\n", SwigType_str(t,0));
    }

    if ((tm = Swig_typemap_lookup_new("imtype",n,"",0))) {
      String *imtypeout = Getattr(n,"tmap:imtype:out"); // the type in the imtype typemap's out attribute overrides the type in the typemap
      if (imtypeout)
        tm = imtypeout;
      Printf(im_return_type,"%s", tm);
      im_outattribute = Getattr(n,"tmap:imtype:outattributes");
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF, input_file, line_number, 
          "No imtype typemap defined for %s\n", SwigType_str(t,0));
    }

    is_void_return = (Cmp(c_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f,"jresult", c_return_type, "jresult",NIL);

    Printv(f->def, " SWIGEXPORT ", c_return_type, " SWIGSTDCALL ", wname, "(", NIL);

    // Emit all of the local variables for holding arguments.
    emit_args(t,l,f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);

    // Parameter overloading
    Setattr(n,"wrap:parms",l);
    Setattr(n,"wrap:name", wname);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in C#
    if (Getattr(n,"sym:overloaded")) {
      // Emit warnings for the few cases that can't be overloaded in C# and give up on generating wrapper
        Swig_overload_check(n);
        if (Getattr(n, "overload:ignore"))
          return SWIG_OK;
    }

    Printv(imclass_class_code, 
           "\n  [DllImport(\"", dllimport, "\", EntryPoint=\"CSharp_", overloaded_name, "\")]\n", NIL);

    if (im_outattribute)
      Printf(imclass_class_code, "  %s\n", im_outattribute);

    Printf(imclass_class_code, "  public static extern %s %s(", im_return_type, overloaded_name);


    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);
    int gencomma = 0;

    // Now walk the function parameter list and generate code to get arguments
    for (i = 0, p=l; i < num_arguments; i++) {

      while (checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *ln = Getattr(p,"lname");
      String   *im_param_type = NewString("");
      String   *c_param_type = NewString("");
      String   *arg = NewString("");

      Printf(arg,"j%s", ln);

      /* Get the ctype types of the parameter */
      if ((tm = Getattr(p,"tmap:ctype"))) {
        Printv(c_param_type, tm, NIL);
      } else {
        Swig_warning(WARN_CSHARP_TYPEMAP_CTYPE_UNDEF, input_file, line_number, 
            "No ctype typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Get the intermediary class parameter types of the parameter */
      if ((tm = Getattr(p,"tmap:imtype"))) {
        String *inattributes = Getattr(p,"tmap:imtype:inattributes");
        Printf(im_param_type, "%s%s", inattributes ? (const String *)inattributes : empty_string, tm);
      } else {
        Swig_warning(WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF, input_file, line_number, 
            "No imtype typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Add parameter to intermediary class method */
      if(gencomma) Printf(imclass_class_code, ", ");
      Printf(imclass_class_code, "%s %s", im_param_type, arg);

      // Add parameter to C function
      Printv(f->def, gencomma?", ":"", c_param_type, " ", arg, NIL);

      gencomma = 1;
      
      // Get typemap for this argument
      if ((tm = Getattr(p,"tmap:in"))) {
        canThrow(n, "in", p);
        Replaceall(tm,"$source",arg); /* deprecated */
        Replaceall(tm,"$target",ln); /* deprecated */
        Replaceall(tm,"$arg",arg); /* deprecated? */
        Replaceall(tm,"$input", arg);
        Setattr(p,"emit:input", arg);
        Printf(f->code,"%s\n", tm);
        p = Getattr(p,"tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, 
            "Unable to use type %s as a function argument.\n",SwigType_str(pt,0));
        p = nextSibling(p);
      }
      Delete(im_param_type);
      Delete(c_param_type);
      Delete(arg);
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
        canThrow(n, "check", p);
        Replaceall(tm,"$target",Getattr(p,"lname")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(f->code,tm,"\n",NIL);
        p = Getattr(p,"tmap:check:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:freearg"))) {
        canThrow(n, "freearg", p);
        Replaceall(tm,"$source",Getattr(p,"emit:input")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(cleanup,tm,"\n",NIL);
        p = Getattr(p,"tmap:freearg:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:argout"))) {
        canThrow(n, "argout", p);
        Replaceall(tm,"$source",Getattr(p,"emit:input")); /* deprecated */
        Replaceall(tm,"$target",Getattr(p,"lname")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$result","jresult");
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(outarg,tm,"\n",NIL);
        p = Getattr(p,"tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

    // Get any C# exception classes in the throws typemap
    ParmList *throw_parm_list = NULL;
    if ((throw_parm_list = Getattr(n,"throws"))) {
      Swig_typemap_attach_parms("throws", throw_parm_list, f);
      for (p = throw_parm_list; p; p=nextSibling(p)) {
        if ((tm = Getattr(p,"tmap:throws"))) {
          canThrow(n, "throws", p);
        }
      }
    }

    if (Cmp(nodeType(n), "constant") == 0) {
      // Wrapping a constant hack
      Swig_save("functionWrapper",n,"wrap:action",NIL);

      // below based on Swig_VargetToFunction()
      SwigType *ty = Swig_wrapped_var_type(Getattr(n,"type"));
      Setattr(n,"wrap:action", NewStringf("result = (%s) %s;\n", SwigType_lstr(ty,0), Getattr(n, "value")));
    }

    // Now write code to make the function call
    if(!native_function_flag)
      emit_action(n,f);

    if (Cmp(nodeType(n), "constant") == 0)
      Swig_restore(n);

    /* Return value if necessary  */
    String *null_attribute = 0;
    if(!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
        canThrow(n, "out", n);
        Replaceall(tm,"$source", "result"); /* deprecated */
        Replaceall(tm,"$target", "jresult"); /* deprecated */
        Replaceall(tm,"$result","jresult");
        Printf(f->code,"%s", tm);
        null_attribute = Getattr(n, "tmap:out:null");
        if (Len(tm))
          Printf(f->code,"\n");
      } else {
        Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
            "Unable to use return type %s in function %s.\n", SwigType_str(t,0), Getattr(n,"name"));
      }
    }

    /* Output argument output code */
    Printv(f->code,outarg,NIL);

    /* Output cleanup code */
    Printv(f->code,cleanup,NIL);

    /* Look to see if there is any newfree cleanup code */
    if (Getattr(n,"feature:new")) {
      if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
        canThrow(n, "newfree", n);
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* See if there is any return cleanup code */
    if(!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
        canThrow(n, "ret", n);
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* Finish C function and intermediary class function definitions */
    Printf(imclass_class_code, ")");
    Printf(imclass_class_code, ";\n");

    Printf(f->def,") {");

    if(!is_void_return)
      Printv(f->code, "    return jresult;\n", NIL);
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code,"$cleanup",cleanup);

    /* Contract macro modification */
    if (Replaceall(f->code, "SWIG_contract_assert(", "SWIG_contract_assert($null, ") > 0) {
      Setattr(n,"csharp:canthrow","1");
    }

    if(!null_attribute)
      Replaceall(f->code,"$null","0");
    else
      Replaceall(f->code,"$null",null_attribute);

    /* Dump the function out */
    if(!native_function_flag) {
      Wrapper_print(f,f_wrappers);

      // Handle %csexception which sets the canthrow attribute
      if (Getattr(n,"feature:except:canthrow"))
        Setattr(n,"csharp:canthrow","1");

      // A very simple check (it is not foolproof) to help typemap/feature writers for
      // throwing C# exceptions from unmanaged code. It checks for the common methods which
      // set a pending C# exception... the 'canthrow' typemap/feature attribute must be set
      // so that code which checks for pending exceptions is added in the C# proxy method.
      if (!Getattr(n,"csharp:canthrow")) {
        if(Strstr(f->code, "SWIG_exception")) {
          Swig_warning(WARN_CSHARP_CANTHROW, input_file, line_number, 
              "Unmanaged code contains a call to SWIG_exception and C# code does not handle pending exceptions via the canthrow attribute.\n");
        } else if(Strstr(f->code, "SWIG_CSharpSetPendingException")) {
          Swig_warning(WARN_CSHARP_CANTHROW, input_file, line_number, 
              "Unmanaged code contains a call to a SWIG_CSharpSetPendingException method and C# code does not handle pending exceptions via the canthrow attribute.\n");
        }
      }
    }

    if(!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
      moduleClassFunctionHandler(n);
    }

    /* 
     * Generate the proxy class properties for public member variables.
     * Not for enums and constants.
     */
    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Capitalize the first letter in the variable in the getter/setter function name
      bool getter_flag = Cmp(symname, Swig_name_set(Swig_name_member(proxy_class_name, variable_name))) != 0;

      String *getter_setter_name = NewString("");
      if(!getter_flag)
        Printf(getter_setter_name,"set");
      else 
        Printf(getter_setter_name,"get");
      Putc(toupper((int) *Char(variable_name)), getter_setter_name);
      Printf(getter_setter_name, "%s", Char(variable_name)+1);

      Setattr(n,"proxyfuncname", getter_setter_name);
      Setattr(n,"imfuncname", symname);

      proxyClassFunctionHandler(n);
      Delete(getter_setter_name);
    }

    Delete(c_return_type);
    Delete(im_return_type);
    Delete(cleanup);
    Delete(outarg);
    Delete(body);
    Delete(overloaded_name);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * variableWrapper()
   * ----------------------------------------------------------------------- */

  virtual int variableWrapper(Node *n) {
    Language::variableWrapper(n);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {

    generate_property_declaration_flag = true;
    variable_name = Getattr(n,"sym:name");
    global_variable_flag = true;
    int ret = Language::globalvariableHandler(n);
    global_variable_flag = false;
    generate_property_declaration_flag = false;

    Printf(module_class_code, "\n  }\n\n");

    return ret;
  }

  /* ----------------------------------------------------------------------
   * enumDeclaration()
   *
   * C/C++ enums can be mapped in one of 4 ways, depending on the cs:enum feature specified:
   * 1) Simple enums - simple constant within the proxy class or module class
   * 2) Typeunsafe enums - simple constant in a C# class (class named after the c++ enum name)
   * 3) Typesafe enum - typesafe enum pattern (class named after the c++ enum name)
   * 4) Proper enums - proper C# enum
   * Anonymous enums always default to 1)
   * ---------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {

    if (!ImportMode) {
      if (getCurrentClass() && (cplus_mode != PUBLIC)) return SWIG_NOWRAP;

      enum_code = NewString("");
      String *symname = Getattr(n,"sym:name");
      String *constants_code = (proxy_flag && is_wrapping_class()) ? proxy_class_constants_code : module_class_constants_code;
      EnumFeature enum_feature = decodeEnumFeature(n);
      String *typemap_lookup_type = Getattr(n,"name");

      if ((enum_feature != SimpleEnum) && symname && typemap_lookup_type) {
        // Wrap (non-anonymous) C/C++ enum within a typesafe, typeunsafe or proper C# enum

        // Pure C# baseclass and interfaces
        const String *pure_baseclass = typemapLookup("csbase", typemap_lookup_type, WARN_NONE);
        const String *pure_interfaces = typemapLookup("csinterfaces", typemap_lookup_type, WARN_NONE);

        // Class attributes
        const String *csattributes = typemapLookup("csattributes", typemap_lookup_type, WARN_NONE);
        if (csattributes && *Char(csattributes))
          Printf(enum_code, "%s\n", csattributes);

        // Emit the enum
        Printv(enum_code,
            typemapLookup("csclassmodifiers", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers (enum modifiers really)
            " ",
            symname,
            (*Char(pure_baseclass) || *Char(pure_interfaces)) ?
            " : " : 
            "",
            pure_baseclass,
            ((*Char(pure_baseclass)) && *Char(pure_interfaces)) ? // Interfaces
            ", " :
            "",
            pure_interfaces,
            " {\n",
            NIL);
      } else {
        // Wrap C++ enum with integers - just indicate start of enum with a comment, no comment for anonymous enums of any sort
        if (symname && !Getattr(n,"unnamedinstance"))
          Printf(constants_code, "  // %s \n", symname);
      }

      // Emit each enum item
      Language::enumDeclaration(n);

      if ((enum_feature != SimpleEnum) && symname && typemap_lookup_type) {
        // Wrap (non-anonymous) C/C++ enum within a typesafe, typeunsafe or proper C# enum
        // Finish the enum declaration
        // Typemaps are used to generate the enum definition in a similar manner to proxy classes.
        Printv(enum_code,
            (enum_feature == ProperEnum) ? 
            "\n" :
            typemapLookup("csbody", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF), // main body of class
            typemapLookup("cscode", typemap_lookup_type, WARN_NONE), // extra C# code
            "}",
            NIL);

        Replaceall(enum_code, "$csclassname", symname);

        // Substitute $enumvalues - intended usage is for typesafe enums
        if (Getattr(n,"enumvalues"))
          Replaceall(enum_code, "$enumvalues", Getattr(n,"enumvalues"));
        else
          Replaceall(enum_code, "$enumvalues", "");

        if (proxy_flag && is_wrapping_class()) {
          // Enums defined within the C++ class are defined within the proxy class

          // Add extra indentation
          Replaceall(enum_code, "\n", "\n  ");
          Replaceall(enum_code, "  \n", "\n");

          Printv(proxy_class_constants_code, "  ", enum_code, "\n\n", NIL);
        } else {
          // Global enums are defined in their own file
          String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), symname);
          File *f_enum = NewFile(filen,"w");
          if(!f_enum) {
            Printf(stderr,"Unable to open %s\n", filen);
            SWIG_exit(EXIT_FAILURE);
          } 
          Delete(filen); filen = NULL;

          // Start writing out the enum file
          emitBanner(f_enum);

          if(Len(namespce) > 0)
            Printf(f_enum, "namespace %s {\n", namespce);

          Printv(f_enum,
              typemapLookup("csimports", typemap_lookup_type, WARN_NONE), // Import statements
              "\n",
              enum_code,
              "\n",
              NIL);

          Printf(f_enum, Len(namespce) > 0 ?  "\n}\n" : "");
          Close(f_enum);
        }
      } else {
        // Wrap C++ enum with simple constant
        Printf(enum_code, "\n");
        if (proxy_flag && is_wrapping_class())
          Printv(proxy_class_constants_code, enum_code, NIL);
        else
          Printv(module_class_constants_code, enum_code, NIL);
      }

      Delete(enum_code); enum_code = NULL;
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * enumvalueDeclaration()
   * ---------------------------------------------------------------------- */

  virtual int enumvalueDeclaration(Node *n) {
    if (getCurrentClass() && (cplus_mode != PUBLIC)) return SWIG_NOWRAP;

    Swig_require("enumvalueDeclaration",n,"*name", "?value",NIL);
    String *symname = Getattr(n,"sym:name");
    String *value = Getattr(n,"value");
    String *name  = Getattr(n,"name");
    String *tmpValue;

    // Strange hack from parent method
    if (value)
      tmpValue = NewString(value);
    else
      tmpValue = NewString(name);
    // Note that this is used in enumValue() amongst other places
    Setattr(n, "value", tmpValue);

    {
      EnumFeature enum_feature = decodeEnumFeature(parentNode(n));

      if ((enum_feature == ProperEnum) && Getattr(parentNode(n),"sym:name") && !Getattr(parentNode(n),"unnamedinstance")) {
        // Wrap (non-anonymous) C/C++ enum with a proper C# enum
        // Emit the enum item.
        if (!Getattr(n,"_last")) // Only the first enum item has this attribute set
          Printf(enum_code, ",\n");
        Printf(enum_code, "  %s", symname);

        // Check for the %csconstvalue feature
        String *value = Getattr(n,"feature:cs:constvalue");

        // Note that the enum value must be a true constant and cannot be set from a PINVOKE call, thus no support for %csconst(0)
        value = value ? value : Getattr(n,"enumvalue");
        if (value) {
          Printf(enum_code, " = %s", value);
        }
      } else {
        // Wrap C/C++ enums with constant integers or use the typesafe enum pattern
        const String *parent_name = Getattr(parentNode(n),"name");
        String *typemap_lookup_type = parent_name ? Copy(parent_name) : NewString("int");
        const String *tm = typemapLookup("cstype", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF);
        String *return_type = Copy(tm);
        Delete(typemap_lookup_type); typemap_lookup_type = NULL;

        // The %csconst feature determines how the constant value is obtained
        String *const_feature = Getattr(n,"feature:cs:const");
        bool const_feature_flag = const_feature && Cmp(const_feature, "0") != 0;

        if ((enum_feature == TypesafeEnum) && Getattr(parentNode(n),"sym:name") && !Getattr(parentNode(n),"unnamedinstance")) {
          // Wrap (non-anonymouse) enum using the typesafe enum pattern
          if (Getattr(n,"enumvalue")) {
            String *value = enumValue(n);
            Printf(enum_code, "  public static readonly %s %s = new %s(\"%s\", %s);\n", return_type, symname, return_type, symname, value);
            Delete(value);
          } else {
            Printf(enum_code, "  public static readonly %s %s = new %s(\"%s\");\n", return_type, symname, return_type, symname);
          }
        } else {
          // Simple integer constants
          // Note these are always generated for anonymous enums, no matter what enum_feature is specified
          // Code generated is the same for SimpleEnum and TypeunsafeEnum -> the class it is generated into is determined later
          const char *const_readonly = const_feature_flag ? "const" : "static readonly";
          String *value = enumValue(n);
          Printf(enum_code, "  public %s %s %s = %s;\n", const_readonly, return_type, symname, value);
          Delete(value);
        }
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
   * C# static const variables are generated for these.
   * If the %csconst(1) feature is used then the C constant value is used to initialise the C# const variable.
   * If not, a PINVOKE method is generated to get the C constant value for initialisation of the C# const variable.
   * However, if the %csconstvalue feature is used, it overrides all other ways to generate the initialisation.
   * Also note that this method might be called for wrapping enum items (when the enum is using %csconst(0)).
   * ------------------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *symname = Getattr(n,"sym:name");
    SwigType *t     = Getattr(n,"type");
    ParmList  *l    = Getattr(n,"parms");
    String *tm;
    String *return_type = NewString("");
    String *constants_code = NewString("");

    if (!addSymbol(symname,n)) return SWIG_ERROR;

    bool is_enum_item = (Cmp(nodeType(n), "enumitem") == 0);

    // The %csconst feature determines how the constant value is obtained
    String *const_feature = Getattr(n,"feature:cs:const");
    bool const_feature_flag = const_feature && Cmp(const_feature, "0") != 0;

    /* Adjust the enum type for the Swig_typemap_lookup.
     * We want the same jstype typemap for all the enum items so we use the enum type (parent node). */
    if (is_enum_item) {
      t = Getattr(parentNode(n),"enumtype");
      Setattr(n,"type", t);
    }

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("cstype", l, NULL);

    /* Get C# return types */
    bool classname_substituted_flag = false;
    
    if ((tm = Swig_typemap_lookup_new("cstype",n,"",0))) {
      String *cstypeout = Getattr(n,"tmap:cstype:out"); // the type in the cstype typemap's out attribute overrides the type in the typemap
      if (cstypeout)
        tm = cstypeout;
      classname_substituted_flag = substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, 
          "No cstype typemap defined for %s\n", SwigType_str(t,0));
    }

    // Add the stripped quotes back in
    String *new_value = NewString("");
    Swig_save("constantWrapper",n,"value",NIL);
    if(SwigType_type(t) == T_STRING) {
      Printf(new_value, "\"%s\"", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    }
    else if(SwigType_type(t) == T_CHAR) {
      Printf(new_value, "\'%s\'", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    }

    const String *outattributes = Getattr(n,"tmap:cstype:outattributes");
    if (outattributes)
      Printf(constants_code, "  %s\n", outattributes);
    const String *itemname = (proxy_flag && wrapping_member_flag) ? variable_name : symname;
    Printf(constants_code, "  public %s %s %s = ", (const_feature_flag ? "const" : "static readonly"), return_type, itemname);

    // Check for the %csconstvalue feature
    String *value = Getattr(n,"feature:cs:constvalue");

    if (value) {
      Printf(constants_code, "%s;\n", value);
    } else if (!const_feature_flag) {
      // Default enum and constant handling will work with any type of C constant and initialises the C# variable from C through a PINVOKE call.

      if(classname_substituted_flag) {
        if (SwigType_isenum(t)) {
          // This handles wrapping of inline initialised const enum static member variables (not when wrapping enum items - ignored later on)
          Printf(constants_code, "(%s)%s.%s();\n", return_type, imclass_name, Swig_name_get(symname));
        } else {
          // This handles function pointers using the %constant directive
          Printf(constants_code, "new %s(%s.%s(), false);\n", return_type, imclass_name, Swig_name_get(symname));
        }
      } else
        Printf(constants_code, "%s.%s();\n", imclass_name, Swig_name_get(symname));

      // Each constant and enum value is wrapped with a separate PInvoke function call
      enum_constant_flag = true;
      variableWrapper(n);
      enum_constant_flag = false;
    } else {
      // Alternative constant handling will use the C syntax to make a true C# constant and hope that it compiles as C# code
      Printf(constants_code, "%s;\n", Getattr(n,"value"));
    }

    // Emit the generated code to appropriate place
    // Enums only emit the intermediate and PINVOKE methods, so no proxy or module class wrapper methods needed
    if (!is_enum_item) {
      if(proxy_flag && wrapping_member_flag)
        Printv(proxy_class_constants_code, constants_code, NIL);
      else
        Printv(module_class_constants_code, constants_code, NIL);
    }

    // Cleanup
    Swig_restore(n);
    Delete(new_value);
    Delete(return_type);
    Delete(constants_code);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * insertDirective()
   * ----------------------------------------------------------------------------- */

  virtual int insertDirective(Node *n) {
    String *code = Getattr(n,"code");
    Replaceall(code, "$module", module_class_name);
    Replaceall(code, "$dllimport", dllimport);
    return Language::insertDirective(n);
  }

  /* -----------------------------------------------------------------------------
   * pragmaDirective()
   *
   * Valid Pragmas:
   * imclassbase            - base (extends) for the intermediary class
   * imclassclassmodifiers  - class modifiers for the intermediary class
   * imclasscode            - text (C# code) is copied verbatim to the intermediary class
   * imclassimports         - import statements for the intermediary class
   * imclassinterfaces      - interface (implements) for the intermediary class
   *
   * modulebase              - base (extends) for the module class
   * moduleclassmodifiers    - class modifiers for the module class
   * modulecode              - text (C# code) is copied verbatim to the module class
   * moduleimports           - import statements for the module class
   * moduleinterfaces        - interface (implements) for the module class
   *
   * ----------------------------------------------------------------------------- */

  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n,"lang");
      String *code = Getattr(n,"name");
      String *value = Getattr(n,"value");

      if(Strcmp(lang, "csharp") == 0) {

        String *strvalue = NewString(value);
        Replaceall(strvalue,"\\\"", "\"");

        if(Strcmp(code, "imclassbase") == 0) {
          Delete(imclass_baseclass);
          imclass_baseclass = Copy(strvalue);
        } 
        else if(Strcmp(code, "imclassclassmodifiers") == 0) {
          Delete(imclass_class_modifiers);
          imclass_class_modifiers = Copy(strvalue);
        } 
        else if(Strcmp(code, "imclasscode") == 0) {
          Printf(imclass_class_code, "%s\n", strvalue);
        } 
        else if(Strcmp(code, "imclassimports") == 0) {
          Delete(imclass_imports);
          imclass_imports = Copy(strvalue);
        } 
        else if(Strcmp(code, "imclassinterfaces") == 0) {
          Delete(imclass_interfaces);
          imclass_interfaces = Copy(strvalue);
        } 
        else if(Strcmp(code, "modulebase") == 0) {
          Delete(module_baseclass);
          module_baseclass = Copy(strvalue);
        } 
        else if(Strcmp(code, "moduleclassmodifiers") == 0) {
          Delete(module_class_modifiers);
          module_class_modifiers = Copy(strvalue);
        } 
        else if(Strcmp(code, "modulecode") == 0) {
          Printf(module_class_code, "%s\n", strvalue);
        } 
        else if(Strcmp(code, "moduleimports") == 0) {
          Delete(module_imports);
          module_imports = Copy(strvalue);
        } 
        else if(Strcmp(code, "moduleinterfaces") == 0) {
          Delete(module_interfaces);
          module_interfaces = Copy(strvalue);
        } else {
          Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
        }
        Delete(strvalue);
      }
    }
    return Language::pragmaDirective(n);
  }

  /* -----------------------------------------------------------------------------
   * emitProxyClassDefAndCPPCasts()
   * ----------------------------------------------------------------------------- */

  void emitProxyClassDefAndCPPCasts(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n,"name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;
    String *typemap_lookup_type = Getattr(n,"classtypeobj");

    /* Deal with inheritance */
    List *baselist = Getattr(n,"bases");
    if (baselist) {
      Iterator base = First(baselist);
      c_baseclassname = Getattr(base.item,"name");
      baseclass = Copy(getProxyName(c_baseclassname));
      if (baseclass){
        c_baseclass = SwigType_namestr(Getattr(base.item,"name"));
      }
      base = Next(base);
      if (base.item) {
        Swig_warning(WARN_CSHARP_MULTIPLE_INHERITANCE, input_file, line_number, 
            "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in C#.\n", typemap_lookup_type, Getattr(base.item,"name"));
      }
    }

    bool derived = baseclass && getProxyName(c_baseclassname);
    if (!baseclass)
      baseclass = NewString("");

    // Inheritance from pure C# classes
    const String *pure_baseclass = typemapLookup("csbase", typemap_lookup_type, WARN_NONE);
    if (Len(pure_baseclass) > 0 && Len(baseclass) > 0) {
      Swig_warning(WARN_CSHARP_MULTIPLE_INHERITANCE, input_file, line_number, 
          "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in C#.\n", typemap_lookup_type, pure_baseclass);
      pure_baseclass = empty_string;
    }

    // Pure C# interfaces
    const String *pure_interfaces = typemapLookup(derived ? "csinterfaces_derived" : "csinterfaces", typemap_lookup_type, WARN_NONE);
    // Start writing the proxy class
    Printv(proxy_class_def,
        typemapLookup("csimports", typemap_lookup_type, WARN_NONE), // Import statements
        "\n",
        NIL);

    // Class attributes
    const String *csattributes = typemapLookup("csattributes", typemap_lookup_type, WARN_NONE);
    if (csattributes && *Char(csattributes))
      Printf(proxy_class_def, "%s\n", csattributes);

    Printv(proxy_class_def,
        typemapLookup("csclassmodifiers", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " $csclassname",       // Class name and base class
        (derived || *Char(pure_baseclass) || *Char(pure_interfaces)) ?
        " : " : 
        "",
        baseclass, // Note only one of these base classes should ever be set as multiple inheritance is not permissible
        pure_baseclass,
        ((derived || *Char(pure_baseclass)) && *Char(pure_interfaces)) ? // Interfaces
        ", " :
        "",
        pure_interfaces,
        " {",
        derived ?
        typemapLookup("csbody_derived", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF) : // main body of class
        typemapLookup("csbody", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF), // main body of class
        NIL);

    // C++ destructor is wrapped by the Dispose method
    // Note that the method name is specified in a typemap attribute called methodname
    String *destruct = NewString("");
    const String *tm = NULL;
    Node *attributes = NewHash();
    String *destruct_methodname = NULL;
    if (derived) {
      tm = typemapLookup("csdestruct_derived", typemap_lookup_type, WARN_NONE, attributes);
      destruct_methodname = Getattr(attributes, "tmap:csdestruct_derived:methodname");
    } else {
      tm = typemapLookup("csdestruct", typemap_lookup_type, WARN_NONE, attributes);
      destruct_methodname = Getattr(attributes, "tmap:csdestruct:methodname");
    }
    if (!destruct_methodname) {
      Swig_error(input_file, line_number, 
          "No methodname attribute defined in csdestruct%s typemap for %s\n", (derived ? "_derived" : ""), proxy_class_name);
    }

    // Emit the Finalize and Dispose methods
    if (tm) {
      // Finalize method
      if (*Char(destructor_call)) {
        Printv(proxy_class_def, 
            typemapLookup("csfinalize", typemap_lookup_type, WARN_NONE),
            NIL);
      }
      // Dispose method
      Printv(destruct, tm, NIL);
      if (*Char(destructor_call))
        Replaceall(destruct, "$imcall", destructor_call);
      else
        Replaceall(destruct, "$imcall", "throw new MethodAccessException(\"C++ destructor does not have public access\")");
      if (*Char(destruct))
        Printv(proxy_class_def, "\n  public ", derived ? "override" : "virtual", " void ", destruct_methodname, "() ", destruct, "\n", NIL);
    }
    Delete(attributes);
    Delete(destruct);

    // Emit extra user code
    Printv(proxy_class_def, 
        typemapLookup("cscode", typemap_lookup_type, WARN_NONE), // extra C# code
        "\n",
        NIL);

    // Substitute various strings into the above template
    Replaceall(proxy_class_code, "$csclassname", proxy_class_name);
    Replaceall(proxy_class_def,  "$csclassname", proxy_class_name);

    Replaceall(proxy_class_def,  "$module", module_class_name);
    Replaceall(proxy_class_code, "$module", module_class_name);

    Replaceall(proxy_class_def,  "$dllimport", dllimport);
    Replaceall(proxy_class_code, "$dllimport", dllimport);

    // Add code to do C++ casting to base class (only for classes in an inheritance hierarchy)
    if(derived){
      Printv(imclass_cppcasts_code,"\n  [DllImport(\"", dllimport, "\", EntryPoint=\"CSharp_", proxy_class_name ,"Upcast", "\")]\n", NIL);
      Printf(imclass_cppcasts_code,"  public static extern IntPtr $csclassnameUpcast(IntPtr objectRef);\n");

      Replaceall(imclass_cppcasts_code, "$csclassname", proxy_class_name);

      Printv(upcasts_code,
          "SWIGEXPORT $cbaseclass * SWIGSTDCALL CSharp_$imclazznameUpcast",
          "($cclass *objectRef) {\n",
          "    return ($cbaseclass *)objectRef;\n"
          "}\n",
          "\n",
          NIL); 

      Replaceall(upcasts_code, "$cbaseclass",  c_baseclass);
      Replaceall(upcasts_code, "$imclazzname", proxy_class_name);
      Replaceall(upcasts_code, "$cclass",      c_classname);
    }
    Delete(baseclass);
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {

    File *f_proxy = NULL;
    if (proxy_flag) {
      proxy_class_name = NewString(Getattr(n,"sym:name"));

      if (!addSymbol(proxy_class_name,n)) return SWIG_ERROR;

      if (Cmp(proxy_class_name, imclass_name) == 0) {
        Printf(stderr, "Class name cannot be equal to intermediary class name: %s\n", proxy_class_name);
        SWIG_exit(EXIT_FAILURE);
      }

      if (Cmp(proxy_class_name, module_class_name) == 0) {
        Printf(stderr, "Class name cannot be equal to module class name: %s\n", proxy_class_name);
        SWIG_exit(EXIT_FAILURE);
      }

      String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), proxy_class_name);
      f_proxy = NewFile(filen,"w");
      if(!f_proxy) {
        Printf(stderr, "Unable to create proxy class file: %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the proxy class file
      emitBanner(f_proxy);

      if(Len(namespce) > 0)
        Printf(f_proxy, "namespace %s {\n", namespce);

      Clear(proxy_class_def);
      Clear(proxy_class_code);

      destructor_call = NewString("");
      proxy_class_constants_code = NewString("");
    }

    Language::classHandler(n);

    if (proxy_flag) {

      emitProxyClassDefAndCPPCasts(n);

      Replaceall(proxy_class_def, "$module", module_class_name);
      Replaceall(proxy_class_code, "$module", module_class_name);
      Replaceall(proxy_class_constants_code, "$module", module_class_name);

      Replaceall(proxy_class_def, "$dllimport", dllimport);
      Replaceall(proxy_class_code, "$dllimport", dllimport);
      Replaceall(proxy_class_constants_code, "$dllimport", dllimport);

      Printv(f_proxy, proxy_class_def, proxy_class_code, NIL);

      // Write out all the constants
      if (Len(proxy_class_constants_code) != 0 )
        Printv(f_proxy, proxy_class_constants_code, NIL);

      Printf(f_proxy, "}\n");
      Printf(f_proxy, Len(namespce) > 0 ?  "\n}\n" : "");
      Close(f_proxy);
      f_proxy = NULL;

      Delete(proxy_class_name); proxy_class_name = NULL;
      Delete(destructor_call); destructor_call = NULL;
      Delete(proxy_class_constants_code); proxy_class_constants_code = NULL;
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *intermediary_function_name = Swig_name_member(proxy_class_name, overloaded_name);
      Setattr(n,"proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n,"imfuncname", intermediary_function_name);
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
      String *intermediary_function_name = Swig_name_member(proxy_class_name, overloaded_name);
      Setattr(n,"proxyfuncname", Getattr(n,"sym:name"));
      Setattr(n,"imfuncname", intermediary_function_name);
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    static_flag = false;

    return SWIG_OK;
  }


  /* -----------------------------------------------------------------------------
   * proxyClassFunctionHandler()
   *
   * Function called for creating a C# wrapper function around a c++ function in the 
   * proxy class. Used for both static and non-static C++ class functions.
   * C++ class static functions map to C# static functions.
   * Two extra attributes in the Node must be available. These are "proxyfuncname" - 
   * the name of the C# class proxy function, which in turn will call "imfuncname" - 
   * the intermediary (PInvoke) function name in the intermediary class.
   * ----------------------------------------------------------------------------- */

  void proxyClassFunctionHandler(Node *n) {
    SwigType  *t = Getattr(n,"type"); 
    ParmList  *l = Getattr(n,"parms");
    String    *intermediary_function_name = Getattr(n,"imfuncname");
    String    *proxy_function_name = Getattr(n,"proxyfuncname");
    String    *tm;
    Parm      *p;
    Parm      *last_parm = 0;
    int       i;
    String    *imcall = NewString("");
    String    *return_type = NewString("");
    String    *function_code = NewString("");
    bool      setter_flag = false;

    if(!proxy_flag) return;

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in C#
    if (Getattr(n, "overload:ignore")) return;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("cstype", l, NULL);
    Swig_typemap_attach_parms("csin", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("cstype",n,"",0))) {
      // Note that in the case of polymorphic (covariant) return types, the method's return type is changed to be the base of the C++ return type
      SwigType *covariant = Getattr(n,"covariant");
      String *cstypeout = Getattr(n,"tmap:cstype:out"); // the type in the cstype typemap's out attribute overrides the type in the typemap
      if (cstypeout)
        tm = cstypeout;
      substituteClassname(covariant ? covariant : t, tm);
      Printf(return_type, "%s", tm);
      if (covariant)
        Swig_warning(WARN_CSHARP_COVARIANT_RET, input_file, line_number, 
          "Covariant return types not supported in C#. Proxy method will return %s.\n", SwigType_str(covariant,0));
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, 
          "No cstype typemap defined for %s\n", SwigType_str(t,0));
    }

    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Properties
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(Swig_name_member(proxy_class_name, variable_name))) == 0);
    }

    /* Start generating the proxy function */
    const String *outattributes = Getattr(n,"tmap:cstype:outattributes");
    if (outattributes)
      Printf(function_code, "  %s\n", outattributes);
    const String *csattributes = Getattr(n,"feature:cs:attributes");
    if (csattributes)
      Printf(function_code, "  %s\n", csattributes);
    const String *methodmods = Getattr(n,"feature:cs:methodmodifiers");
    if (methodmods) {
      Printf(function_code, "  %s ", methodmods);
    } else {
      methodmods = (!is_public(n) ? protected_string : public_string);
      Printf(function_code, "  %s ", methodmods);
      if (Getattr(n,"override"))
	Printf(function_code, "override ");
      else if (checkAttribute(n, "storage", "virtual"))
	Printf(function_code, "virtual ");
      if (Getattr(n, "hides"))
	Printf(function_code, "new ");
    }
    if (static_flag)
      Printf(function_code, "static ");

    Printf(function_code, "%s %s(", return_type, proxy_function_name);

    Printv(imcall, imclass_name, ".", intermediary_function_name, "(", NIL);
    if (!static_flag)
      Printf(imcall, "swigCPtr");

    emit_mark_varargs(l);

    int gencomma = !static_flag;

    /* Output each parameter */
    for (i = 0, p=l; p; i++) {

      /* Ignored varargs */
      if (checkAttribute(p,"varargs:ignore","1")) {
        p = nextSibling(p);
        continue;
      }

      /* Ignored parameters */
      if (checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
        continue;
      }

      /* Ignore the 'this' argument for variable wrappers */
      if (!(variable_wrapper_flag && i==0)) 
      {
        SwigType *pt = Getattr(p,"type");
        String   *param_type = NewString("");
        last_parm = p;

        /* Get the C# parameter type */
        if ((tm = Getattr(p,"tmap:cstype"))) {
          substituteClassname(pt, tm);
          String *inattributes = Getattr(p,"tmap:cstype:inattributes");
          Printf(param_type, "%s%s", inattributes ? (const String *)inattributes : empty_string, tm);
        } else {
          Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, 
              "No cstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(imcall, ", ");

        String *arg = makeParameterName(n, p, i, setter_flag);

        // Use typemaps to transform type used in C# wrapper function (in proxy class) to type used in PInvoke function (in intermediary class)
        if ((tm = Getattr(p,"tmap:csin"))) {
          substituteClassname(pt, tm);
          Replaceall(tm, "$csinput", arg);
          Printv(imcall, tm, NIL);
        } else {
          Swig_warning(WARN_CSHARP_TYPEMAP_CSIN_UNDEF, input_file, line_number, 
              "No csin typemap defined for %s\n", SwigType_str(pt,0));
        }

        /* Add parameter to proxy function */
        if (gencomma >= 2)
          Printf(function_code, ", ");
        gencomma = 2;
        Printf(function_code, "%s %s", param_type, arg);

        Delete(arg);
        Delete(param_type);
      }
      p = Getattr(p,"tmap:in:next");
    }

    Printf(imcall, ")");
    Printf(function_code, ")");

    // Transform return type used in PInvoke function (in intermediary class) to type used in C# wrapper function (in proxy class)
    if ((tm = Swig_typemap_lookup_new("csout",n,"",0))) {
      if (Getattr(n,"feature:new"))
        Replaceall(tm,"$owner","true");
      else
        Replaceall(tm,"$owner","false");
      substituteClassname(t, tm);
      Replaceall(tm, "$imcall", imcall);
      excodeSubstitute(n, tm, "csout", n);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, 
          "No csout typemap defined for %s\n", SwigType_str(t,0));
    }

    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Properties
      if (generate_property_declaration_flag) { // Ensure the declaration is generated just once should the property contain both a set and get
	// Get the C# variable type - obtained differently depending on whether a setter is required.
	String *variable_type = return_type;
	if (setter_flag) {
	  p = last_parm; // (last parameter is the only parameter for properties)
	  SwigType *pt = Getattr(p,"type");
	  if ((tm = Getattr(p,"tmap:cstype"))) {
	    substituteClassname(pt, tm);
	    variable_type = tm;
	  } else {
	    Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, 
		"No csvarin typemap defined for %s\n", SwigType_str(pt,0));
	  }
	}
        const String *csattributes = Getattr(n,"feature:cs:attributes");
        if (csattributes)
          Printf(proxy_class_code, "  %s\n", csattributes);
	const String *methodmods = Getattr(n,"feature:cs:methodmodifiers");
	if (!methodmods)
	  methodmods = (!is_public(n) ? protected_string : public_string);
	Printf(proxy_class_code, "  %s %s%s %s {", methodmods, static_flag ? "static " : "", variable_type, variable_name);
      }
      generate_property_declaration_flag = false;


      if(setter_flag) {
        // Setter method
        Swig_typemap_attach_parms("csvarin", l, NULL);
        p = last_parm; // (last parameter is the only parameter for properties)
        SwigType *pt = Getattr(p,"type");
        if ((tm = Getattr(p,"tmap:csvarin"))) {
          substituteClassname(pt, tm);
          Replaceall(tm, "$imcall", imcall);
          excodeSubstitute(n, tm, "csvarin", p);
          Printf(proxy_class_code, "%s", tm);
        } else {
          Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, 
              "No csvarin typemap defined for %s\n", SwigType_str(pt,0));
        }
      } else {
        // Getter method
        if ((tm = Swig_typemap_lookup_new("csvarout",n,"",0))) {
          if (Getattr(n,"feature:new"))
            Replaceall(tm,"$owner","true");
          else
            Replaceall(tm,"$owner","false");
          substituteClassname(t, tm);
          Replaceall(tm, "$imcall", imcall);
          excodeSubstitute(n, tm, "csvarout", n);
          Printf(proxy_class_code, "%s", tm);
        } else {
          Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, 
              "No csvarout typemap defined for %s\n", SwigType_str(t,0));
        }
      }
    } else {
      // Normal function call
      Printf(function_code, " %s\n\n", tm ? (const String *)tm : empty_string);
      Printv(proxy_class_code, function_code, NIL);
    }

    Delete(function_code);
    Delete(return_type);
    Delete(imcall);
  }

  /* ----------------------------------------------------------------------
   * constructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {

    ParmList *l = Getattr(n,"parms");
    String    *tm;
    Parm      *p;
    int       i;
    String    *function_code = NewString("");

    Language::constructorHandler(n);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in C#
    if (Getattr(n, "overload:ignore"))
      return SWIG_OK;

    if(proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *mangled_overname = Swig_name_construct(overloaded_name);
      String *imcall = NewString("");

      const String *csattributes = Getattr(n,"feature:cs:attributes");
      if (csattributes)
        Printf(function_code, "  %s\n", csattributes);
      const String *methodmods = Getattr(n,"feature:cs:methodmodifiers");
      methodmods = methodmods ? methodmods : (!is_public(n) ? protected_string : public_string);
      Printf(function_code, "  %s %s(", methodmods, proxy_class_name);
      Printv(imcall, imclass_name, ".", mangled_overname, "(", NIL);

      /* Attach the non-standard typemaps to the parameter list */
      Swig_typemap_attach_parms("in", l, NULL);
      Swig_typemap_attach_parms("cstype", l, NULL);
      Swig_typemap_attach_parms("csin", l, NULL);

      emit_mark_varargs(l);

      int gencomma = 0;

      /* Output each parameter */
      for (i = 0, p=l; p; i++) {

        /* Ignored varargs */
        if (checkAttribute(p,"varargs:ignore","1")) {
          p = nextSibling(p);
          continue;
        }

        /* Ignored parameters */
        if (checkAttribute(p,"tmap:in:numinputs","0")) {
          p = Getattr(p,"tmap:in:next");
          continue;
        }

        SwigType *pt = Getattr(p,"type");
        String   *param_type = NewString("");

        /* Get the C# parameter type */
        if ((tm = Getattr(p,"tmap:cstype"))) {
          substituteClassname(pt, tm);
          String *inattributes = Getattr(p,"tmap:cstype:inattributes");
          Printf(param_type, "%s%s", inattributes ? (const String *)inattributes : empty_string, tm);
        } else {
          Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, 
              "No cstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(imcall, ", ");

        String *arg = makeParameterName(n, p, i, false);

        // Use typemaps to transform type used in C# wrapper function (in proxy class) to type used in PInvoke function (in intermediary class)
        if ((tm = Getattr(p,"tmap:csin"))) {
          substituteClassname(pt, tm);
          Replaceall(tm, "$csinput", arg);
          Printv(imcall, tm, NIL);
        } else {
          Swig_warning(WARN_CSHARP_TYPEMAP_CSIN_UNDEF, input_file, line_number, 
              "No csin typemap defined for %s\n", SwigType_str(pt,0));
        }

        /* Add parameter to proxy function */
        if(gencomma)
          Printf(function_code, ", ");
        Printf(function_code, "%s %s", param_type, arg);
        ++gencomma;

        Delete(arg);
        Delete(param_type);
        p = Getattr(p,"tmap:in:next");
      }

      Printf(imcall, ")");

      Printf(function_code, ")");

      Node *attributes = NewHash();
      Printv(function_code, " ", typemapLookup("csconstruct", Getattr(n,"name"), WARN_CSHARP_TYPEMAP_CSCONSTRUCT_UNDEF, attributes), NIL);
      Replaceall(function_code, "$imcall", imcall);
      excodeSubstitute(n, function_code, "csconstruct", attributes);
      Printv(proxy_class_code, function_code, "\n", NIL);

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
    String *symname = Getattr(n,"sym:name");

    if(proxy_flag) {
      Printv(destructor_call, imclass_name, ".", Swig_name_destroy(symname), "(swigCPtr)", NIL);
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {

    generate_property_declaration_flag = true;
    variable_name = Getattr(n,"sym:name");
    wrapping_member_flag = true;
    variable_wrapper_flag = true;
    Language::membervariableHandler(n);
    wrapping_member_flag = false;
    variable_wrapper_flag = false;
    generate_property_declaration_flag = false;

    Printf(proxy_class_code, "\n  }\n\n");

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmembervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {

    bool static_const_member_flag = (Getattr(n, "value") == 0);

    generate_property_declaration_flag = true;
    variable_name = Getattr(n,"sym:name");
    wrapping_member_flag = true;
    static_flag = true;
    Language::staticmembervariableHandler(n);
    wrapping_member_flag = false;
    static_flag = false;
    generate_property_declaration_flag = false;

    if(static_const_member_flag)
      Printf(proxy_class_code, "\n  }\n\n");

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberconstantHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberconstantHandler(Node *n) {
    variable_name = Getattr(n,"sym:name");
    wrapping_member_flag = true;
    Language::memberconstantHandler(n);
    wrapping_member_flag = false;
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * getOverloadedName()
   * ----------------------------------------------------------------------------- */

  String *getOverloadedName(Node *n) {

    /* A C# HandleRef is used for all classes in the SWIG intermediary class.
     * The intermediary class methods are thus mangled when overloaded to give
     * a unique name. */
    String *overloaded_name = NewStringf("%s", Getattr(n,"sym:name"));

    if (Getattr(n,"sym:overloaded")) {
      Printv(overloaded_name, Getattr(n,"sym:overname"), NIL);
    }

    return overloaded_name;
  }

  /* -----------------------------------------------------------------------------
   * moduleClassFunctionHandler()
   * ----------------------------------------------------------------------------- */

  void moduleClassFunctionHandler(Node *n) {
    SwigType  *t = Getattr(n,"type");
    ParmList  *l = Getattr(n,"parms");
    String    *tm;
    Parm      *p;
    Parm      *last_parm = 0;
    int       i;
    String    *imcall = NewString("");
    String    *return_type = NewString("");
    String    *function_code = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;
    String    *overloaded_name = getOverloadedName(n);
    String    *func_name = NULL;
    bool      setter_flag = false;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("cstype", l, NULL);
    Swig_typemap_attach_parms("csin", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("cstype",n,"",0))) {
      String *cstypeout = Getattr(n,"tmap:cstype:out"); // the type in the cstype typemap's out attribute overrides the type in the typemap
      if (cstypeout)
        tm = cstypeout;
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, 
          "No cstype typemap defined for %s\n", SwigType_str(t,0));
    }

    /* Change function name for global variables */
    if (proxy_flag && global_variable_flag) {
      // Capitalize the first letter in the variable to create the getter/setter function name
      func_name = NewString("");
      setter_flag = (Cmp(Getattr(n,"sym:name"), Swig_name_set(variable_name)) == 0);
      if(setter_flag)
        Printf(func_name,"set");
      else 
        Printf(func_name,"get");
      Putc(toupper((int) *Char(variable_name)), func_name);
      Printf(func_name, "%s", Char(variable_name)+1);
    } else {
      func_name = Copy(Getattr(n,"sym:name"));
    }

    /* Start generating the function */
    const String *outattributes = Getattr(n,"tmap:cstype:outattributes");
    if (outattributes)
      Printf(function_code, "  %s\n", outattributes);
    const String *csattributes = Getattr(n,"feature:cs:attributes");
    if (csattributes)
      Printf(function_code, "  %s\n", csattributes);
    const String *methodmods = Getattr(n,"feature:cs:methodmodifiers");
    methodmods = methodmods ? methodmods : (!is_public(n) ? protected_string : public_string);
    Printf(function_code, "  %s static %s %s(", methodmods, return_type, func_name);
    Printv(imcall, imclass_name, ".", overloaded_name, "(", NIL);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);

    int gencomma = 0;

    /* Output each parameter */
    for (i = 0, p=l; i < num_arguments; i++) {

      /* Ignored parameters */
      while (checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *param_type = NewString("");
      last_parm = p;

      /* Get the C# parameter type */
      if ((tm = Getattr(p,"tmap:cstype"))) {
        substituteClassname(pt, tm);
        String *inattributes = Getattr(p,"tmap:cstype:inattributes");
        Printf(param_type, "%s%s", inattributes ? (const String *)inattributes : empty_string, tm);
      } else {
        Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, 
            "No cstype typemap defined for %s\n", SwigType_str(pt,0));
      }

      if (gencomma)
        Printf(imcall, ", ");

      String *arg = makeParameterName(n, p, i, setter_flag);

      // Use typemaps to transform type used in C# wrapper function (in proxy class) to type used in PInvoke function (in intermediary class)
      if ((tm = Getattr(p,"tmap:csin"))) {
        substituteClassname(pt, tm);
        Replaceall(tm, "$csinput", arg);
        Printv(imcall, tm, NIL);
      } else {
        Swig_warning(WARN_CSHARP_TYPEMAP_CSIN_UNDEF, input_file, line_number, 
            "No csin typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Add parameter to module class function */
      if (gencomma >= 2)
        Printf(function_code, ", ");
      gencomma = 2;
      Printf(function_code, "%s %s", param_type, arg);

      p = Getattr(p,"tmap:in:next");
      Delete(arg);
      Delete(param_type);
    }

    Printf(imcall, ")");
    Printf(function_code, ")");

    // Transform return type used in PInvoke function (in intermediary class) to type used in C# wrapper function (in module class)
    if ((tm = Swig_typemap_lookup_new("csout",n,"",0))) {
      if (Getattr(n,"feature:new"))
        Replaceall(tm,"$owner","true");
      else
        Replaceall(tm,"$owner","false");
      substituteClassname(t, tm);
      Replaceall(tm, "$imcall", imcall);
      excodeSubstitute(n, tm, "csout", n);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, 
          "No csout typemap defined for %s\n", SwigType_str(t,0));
    }

    if (proxy_flag && global_variable_flag) {
      // Properties
      if (generate_property_declaration_flag) { // Ensure the declaration is generated just once should the property contain both a set and get
	// Get the C# variable type - obtained differently depending on whether a setter is required.
	String *variable_type = return_type;
	if (setter_flag) {
	  p = last_parm; // (last parameter is the only parameter for properties)
	  SwigType *pt = Getattr(p,"type");
	  if ((tm = Getattr(p,"tmap:cstype"))) {
	    substituteClassname(pt, tm);
	    variable_type = tm;
	  } else {
	    Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, 
		"No csvarin typemap defined for %s\n", SwigType_str(pt,0));
	  }
	}
        const String *csattributes = Getattr(n,"feature:cs:attributes");
        if (csattributes)
          Printf(module_class_code, "  %s\n", csattributes);
	const String *methodmods = Getattr(n,"feature:cs:methodmodifiers");
	if (!methodmods)
	  methodmods = (!is_public(n) ? protected_string : public_string);
	Printf(module_class_code, "  %s static %s %s {", methodmods, variable_type, variable_name);
      }
      generate_property_declaration_flag = false;

      if(setter_flag) {
        // Setter method
        Swig_typemap_attach_parms("csvarin", l, NULL);
        p = last_parm; // (last parameter is the only parameter for properties)
        SwigType *pt = Getattr(p,"type");
        if ((tm = Getattr(p,"tmap:csvarin"))) {
          substituteClassname(pt, tm);
          Replaceall(tm, "$imcall", imcall);
          excodeSubstitute(n, tm, "csvarin", p);
          Printf(module_class_code, "%s", tm);
        } else {
          Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, 
              "No csvarin typemap defined for %s\n", SwigType_str(pt,0));
        }
      } else {
        // Getter method
        if ((tm = Swig_typemap_lookup_new("csvarout",n,"",0))) {
          if (Getattr(n,"feature:new"))
            Replaceall(tm,"$owner","true");
          else
            Replaceall(tm,"$owner","false");
          substituteClassname(t, tm);
          Replaceall(tm, "$imcall", imcall);
          excodeSubstitute(n, tm, "csvarout", n);
          Printf(module_class_code, "%s", tm);
        } else {
          Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, 
              "No csvarout typemap defined for %s\n", SwigType_str(t,0));
        }
      }
    } else {
      // Normal function call
      Printf(function_code, " %s\n\n", tm ? (const String *)tm : empty_string);
      Printv(module_class_code, function_code, NIL);
    }

    Delete(function_code);
    Delete(return_type);
    Delete(imcall);
    Delete(func_name);
  }

  /*----------------------------------------------------------------------
   * decodeEnumFeature()
   * Decode the possible enum features, which are one of:
   *   %csenum(simple)
   *   %csenum(typeunsafe) - default
   *   %csenum(typesafe)
   *   %csenum(proper)
   *--------------------------------------------------------------------*/

  EnumFeature decodeEnumFeature(Node *n) {
      EnumFeature enum_feature = TypeunsafeEnum;
      String *feature = Getattr(n,"feature:cs:enum");
      if (feature) {
        if (Cmp(feature, "simple") == 0)
          enum_feature = SimpleEnum;
        else if (Cmp(feature, "typesafe") == 0)
          enum_feature = TypesafeEnum;
        else if (Cmp(feature, "proper") == 0)
          enum_feature = ProperEnum;
      }
      return enum_feature;
  }

  /* -----------------------------------------------------------------------
   * enumValue()
   * This method will return a string with an enum value to use in C# generated
   * code. If the %csconst feature is not used, the string will contain the intermediary
   * class call to obtain the enum value. The intermediary class and PINVOKE methods to obtain
   * the enum value will be generated. Otherwise the C/C++ enum value will be used if there
   * is one and hopefully it will compile as C# code - e.g. 20 as in: enum E{e=20};
   * The %csconstvalue feature overrides all other ways to generate the constant value.
   * The caller must delete memory allocated for the returned string.
   * ------------------------------------------------------------------------ */

  String *enumValue(Node *n) {
    String *symname = Getattr(n,"sym:name");

    // Check for the %csconstvalue feature
    String *value = Getattr(n,"feature:cs:constvalue");

    if (!value) {
      // The %csconst feature determines how the constant value is obtained
      String *const_feature = Getattr(n,"feature:cs:const");
      bool const_feature_flag = const_feature && Cmp(const_feature, "0") != 0;

      if (const_feature_flag) {
        // Use the C syntax to make a true C# constant and hope that it compiles as C# code
        value = Getattr(n,"enumvalue") ? Copy(Getattr(n,"enumvalue")) : Copy(Getattr(n,"enumvalueex"));
      } else {
        // Get the enumvalue from a PINVOKE call
        if (!getCurrentClass()) {
          // Strange hack to change the name
          Setattr(n,"name",Getattr(n,"value")); /* for wrapping of enums in a namespace when emit_action is used */
          constantWrapper(n);
          value = NewStringf("%s.%s()", imclass_name, Swig_name_get(symname));
        } else {
          memberconstantHandler(n);
          value = NewStringf("%s.%s()", imclass_name, Swig_name_get(Swig_name_member(proxy_class_name, symname)));
        }
      }
    }
    return value;
  }

  /* -----------------------------------------------------------------------------
   * getEnumName()
   * ----------------------------------------------------------------------------- */

  String *getEnumName(SwigType *t) {
    Node *enum_name = NULL;
    Node *n = enumLookup(t);
    if (n) {
      String *symname = Getattr(n,"sym:name");
      if (symname) {
        // Add in class scope when referencing enum if not a global enum
        String *scopename_prefix = Swig_scopename_prefix(Getattr(n,"name"));
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
   * Substitute $csclassname with the proxy class name for classes/structs/unions that SWIG knows about.
   * Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the C# class name. Note that the $&csclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - cstype typemap
   * Outputs:
   *   tm - cstype typemap with $csclassname substitution
   * Return:
   *   substitution_performed - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteClassname(SwigType *pt, String *tm) {
    bool substitution_performed = false;
    SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$csclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteClassnameSpecialVariable(classnametype, tm, "$csclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$*csclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      substituteClassnameSpecialVariable(classnametype, tm, "$*csclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$&csclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteClassnameSpecialVariable(classnametype, tm, "$&csclassname");
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
        Replaceall(tm, classnamespecialvariable, classname); // getProxyName() works for pointers to classes too
      }
      else { // use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
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
   *   setter  - set this flag when wrapping member variables
   * Return:
   *   arg - a unique parameter name
   * ----------------------------------------------------------------------------- */

  String *makeParameterName(Node *n, Parm *p, int arg_num, bool setter) {

    String *arg = 0;
    String *pn = Getattr(p,"name");
    if (setter) {
      // Note that in C# property setter names must always be called 'value'
      arg = NewString("value");
    } else {
      // Use C parameter name unless it is a duplicate or an empty parameter name
      int count = 0;
      ParmList *plist = Getattr(n,"parms");
      while (plist) {
        if ((Cmp(pn, Getattr(plist,"name")) == 0))
          count++;
        plist = nextSibling(plist);
      }
      arg = (!pn || (count > 1)) ? NewStringf("arg%d",arg_num) : Copy(pn);
    }

    return arg;
  }

  /* -----------------------------------------------------------------------------
   * emitTypeWrapperClass()
   * ----------------------------------------------------------------------------- */

  void emitTypeWrapperClass(String *classname, SwigType *type) {
    String *swigtype = NewString("");
    String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), classname);
    File *f_swigtype = NewFile(filen,"w");
    if(!f_swigtype) {
      Printf(stderr,"Unable to open %s\n", filen);
      SWIG_exit(EXIT_FAILURE);
    } 
    Delete(filen); filen = NULL;

    // Start writing out the type wrapper class file
    emitBanner(f_swigtype);

    if(Len(namespce) > 0)
      Printf(f_swigtype, "namespace %s {\n", namespce);

    // Pure C# baseclass and interfaces
    const String *pure_baseclass = typemapLookup("csbase", type, WARN_NONE);
    const String *pure_interfaces = typemapLookup("csinterfaces", type, WARN_NONE);

    // Emit the class
    Printv(swigtype,
        typemapLookup("csimports", type, WARN_NONE), // Import statements
        "\n",
        NIL);

    // Class attributes
    const String *csattributes = typemapLookup("csattributes", type, WARN_NONE);
    if (csattributes && *Char(csattributes))
      Printf(swigtype, "%s\n", csattributes);

    Printv(swigtype,
        typemapLookup("csclassmodifiers", type, WARN_CSHARP_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " $csclassname",       // Class name and base class
        (*Char(pure_baseclass) || *Char(pure_interfaces)) ?
        " : " : 
        "",
        pure_baseclass,
        ((*Char(pure_baseclass)) && *Char(pure_interfaces)) ? // Interfaces
        ", " :
        "",
        pure_interfaces,
        " {",
        typemapLookup("csbody", type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF), // main body of class
        typemapLookup("cscode", type, WARN_NONE), // extra C# code
        "}\n",
        Len(namespce) > 0 ?
          "\n}\n" :
          "",
        NIL);

    Replaceall(swigtype, "$csclassname", classname);
    Replaceall(swigtype, "$module", module_class_name);
    Replaceall(swigtype, "$dllimport", dllimport);
    Printv(f_swigtype, swigtype, NIL);

    Close(f_swigtype);
    Delete(swigtype);
  }

  /* -----------------------------------------------------------------------------
   * typemapLookup()
   * ----------------------------------------------------------------------------- */

  const String *typemapLookup(const String *op, String *type, int warning, Node *typemap_attributes=NULL) {
    String *tm = NULL;
    const String *code = NULL;

    if((tm = Swig_typemap_search(op, type, NULL, NULL))) {
      code = Getattr(tm,"code");
      if (typemap_attributes)
        Swig_typemap_attach_kwargs(tm,op,typemap_attributes);
    }

    if (!code) {
      code = empty_string;
      if (warning != WARN_NONE)
        Swig_warning(warning, input_file, line_number, "No %s typemap defined for %s\n", op, type);
    }

    return code ? code : empty_string;
  }

  /* -----------------------------------------------------------------------------
   * canThrow()
   * Determine whether the code in the typemap can throw a C# exception.
   * If so, note it for later when excodeSubstitute() is called.
   * ----------------------------------------------------------------------------- */

  void canThrow(Node *n, const String *typemap, Node *parameter) {
    String *canthrow_attribute = NewStringf("tmap:%s:canthrow", typemap);
    String *canthrow = Getattr(parameter,canthrow_attribute);
    if (canthrow)
      Setattr(n,"csharp:canthrow", "1");
    Delete(canthrow_attribute);
  }

  /* -----------------------------------------------------------------------------
   * excodeSubstitute()
   * If a method can throw a C# exception, additional exception code is added to
   * check for the pending exception so that it can then throw the exception. The
   * $excode special variable is replaced by the exception code in the excode
   * typemap attribute.
   * ----------------------------------------------------------------------------- */

  void excodeSubstitute(Node *n, String *code, const String *typemap, Node *parameter) {
    String *excode_attribute = NewStringf("tmap:%s:excode", typemap);
    String *excode = Getattr(parameter, excode_attribute);
    if (Getattr(n,"csharp:canthrow")) {
      int count = Replaceall(code, "$excode", excode);
      if (count < 1 || !excode) {
        Swig_warning(WARN_CSHARP_EXCODE, input_file, line_number, 
          "C# exception may not be thrown - no $excode or excode attribute in '%s' typemap.\n", typemap);
      }
    } else {
      Replaceall(code, "$excode", empty_string);
    }
    Delete(excode_attribute);
  }

};   /* class CSHARP */

/* -----------------------------------------------------------------------------
 * swig_csharp()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language * new_swig_csharp() {
  return new CSHARP();
}
extern "C" Language * swig_csharp(void) {
  return new_swig_csharp();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *CSHARP::usage = (char*)"\
C# Options (available with -csharp)\n\
     -dllimport <dl> - Override DllImport attribute name to <dl>\n\
     -namespace <nm> - Generate wrappers into C# namespace <nm>\n\
     -noproxy        - Generate the low-level functional interface instead\n\
                       of proxy classes\n\
     -oldvarnames    - old intermediary method names for variable wrappers\n\
\n";

