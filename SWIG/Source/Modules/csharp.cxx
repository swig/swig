/* -----------------------------------------------------------------------------
 * csharp.cxx
 *
 *     CSharp wrapper module.
 *
 * Author(s) : Neil Cawse
 *             William Fulton
 *
 * Copyright (C) 1999-2002.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

char cvsroot_csharp_cxx[] = "$Header$";

#include <limits.h> // for INT_MAX
#include "swigmod.h"
#ifndef MACSWIG
#include "swigconfig.h"
#endif
#include <ctype.h>

class CSHARP : public Language {
  static const char *usage;
  const  String *empty_string;

  Hash   *swig_types_hash;
  File   *f_runtime;
  File   *f_header;
  File   *f_wrappers;
  File   *f_init;

  bool   proxy_flag; // Flag for generating shadow classes
  bool   have_default_constructor_flag;
  bool   native_function_flag;     // Flag for when wrapping a native function
  bool   enum_constant_flag; // Flag for when wrapping an enum or constant
  bool   static_flag; // Flag for when wrapping a static functions or member variables
  bool   variable_wrapper_flag; // Flag for when wrapping a nonstatic member variable
  bool   wrapping_member_flag; // Flag for when wrapping a member variable/enum/const
  bool   global_variable_flag; // Flag for when wrapping a global variable

  String *jniclass_name;  // JNI class name
  String *module_class_name;  // module class name
  String *jniclass_class_code; // JNI class csharp code - that is the native methods
  String *shadow_classdef;
  String *shadow_code;
  String *module_class_code;
  String *shadow_classname;
  String *variable_name; //Name of a variable being wrapped
  String *shadow_constants_code;
  String *module_constants_code;
  String *package; // Package name
  String *jnipackage; // JNI package name
  String *jniclass_imports; //jniclass imports from %pragma
  String *module_imports; //module imports from %pragma
  String *jniclass_baseclass; //inheritance for jniclass class from %pragma
  String *module_baseclass; //inheritance for module class from %pragma
  String *jniclass_interfaces; //interfaces for jniclass class from %pragma
  String *module_interfaces; //interfaces for module class from %pragma
  String *jniclass_class_modifiers; //class modifiers for jniclass class overriden by %pragma
  String *module_class_modifiers; //class modifiers for module class overriden by %pragma
  String *wrapper_conversion_code; //C++ casts for inheritance hierarchies JNI code
  String *jniclass_cppcasts_code; //C++ casts up inheritance hierarchies JNI class csharp code
  String *destructor_call; //Destructor (delete) call if any
  String *outfile;

  enum type_additions {none, pointer, reference};

  public:

  /* -----------------------------------------------------------------------------
   * CSHARP()
   * ----------------------------------------------------------------------------- */

  CSHARP() : 
    empty_string(NewString("")),

    swig_types_hash(NULL),
    f_runtime(NULL),
    f_header(NULL),
    f_wrappers(NULL),
    f_init(NULL),

    proxy_flag(true),
    have_default_constructor_flag(false),
    native_function_flag(false),
    enum_constant_flag(false),
    static_flag(false),
    variable_wrapper_flag(false),
    wrapping_member_flag(false),
    global_variable_flag(false),

    jniclass_name(NULL),
    module_class_name(NULL),
    jniclass_class_code(NULL),
    shadow_classdef(NULL),
    shadow_code(NULL),
    module_class_code(NULL),
    shadow_classname(NULL),
    variable_name(NULL),
    shadow_constants_code(NULL),
    module_constants_code(NULL),
    package(NULL),
    jnipackage(NULL),
    jniclass_imports(NULL),
    module_imports(NULL),
    jniclass_baseclass(NULL),
    module_baseclass(NULL),
    jniclass_interfaces(NULL),
    module_interfaces(NULL),
    jniclass_class_modifiers(NULL),
    module_class_modifiers(NULL),
    wrapper_conversion_code(NULL),
    jniclass_cppcasts_code(NULL),
    destructor_call(NULL),
    outfile(NULL)

    {
    }

  /* -----------------------------------------------------------------------------
   * is_shadow()
   *
   * Test to see if a type corresponds to something wrapped with a shadow/proxy class
   * Return NULL if not otherwise the shadow name
   * ----------------------------------------------------------------------------- */

  String *is_shadow(SwigType *t) {
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
        if (strcmp(argv[i],"-package") == 0) {
          if (argv[i+1]) {
            package = NewString("");
            Printf(package, argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if ((strcmp(argv[i],"-shadow") == 0) || ((strcmp(argv[i],"-proxy") == 0))) {
          Printf(stderr,"Deprecated command line option: %s. Proxy classes are now generated by default.\n", argv[i]);
          Swig_mark_arg(i);
          proxy_flag = true;
        } else if ((strcmp(argv[i],"-noproxy") == 0)) {
          Swig_mark_arg(i);
          proxy_flag = false;
        } else if (strcmp(argv[i],"-jnic") == 0) {
          Swig_mark_arg(i);
          Printf(stderr,"Deprecated command line option: -jnic. C JNI calling convention now used when -c++ not specified.\n");
        } else if (strcmp(argv[i],"-nofinalize") == 0) {
          Swig_mark_arg(i);
          Printf(stderr,"Deprecated command line option: -nofinalize. Use the new javafinalize typemaps instead.\n");
        } else if (strcmp(argv[i],"-jnicpp") == 0) {
          Swig_mark_arg(i);
          Printf(stderr,"Deprecated command line option: -jnicpp. C++ JNI calling convention now used when -c++ specified.\n");
        } else if (strcmp(argv[i],"-help") == 0) {
          Printf(stderr,"%s\n", usage);
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

    /* Initialize all of the output files */
    outfile = Getattr(n,"outfile");

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

    // Make the JNI class and module class names. The jniclassname can be set in the module directive.
    Node* optionsnode = Getattr( Getattr(n,"module") ,"options");
    if (optionsnode)
        if (Getattr(optionsnode,"jniclassname"))
          jniclass_name = Copy(Getattr(optionsnode,"jniclassname"));
    if (!jniclass_name) {
      jniclass_name = NewStringf("%sPINVOKE", Getattr(n,"name"));
      module_class_name = Copy(Getattr(n,"name"));
    } else {
      // Rename the module name if it is the same as JNI class name - a backwards compatibility solution
      if (Cmp(jniclass_name, Getattr(n,"name")) == 0)
        module_class_name = NewStringf("%sModule", Getattr(n,"name"));
      else
        module_class_name = Copy(Getattr(n,"name"));
    }


    jniclass_class_code = NewString("");
    shadow_classdef = NewString("");
    shadow_code = NewString("");
    module_constants_code = NewString("");
    jniclass_baseclass = NewString("");
    jniclass_interfaces = NewString("");
    jniclass_class_modifiers = NewString(""); // package access only to the JNI class by default
    module_class_code = NewString("");
    module_baseclass = NewString("");
    module_interfaces = NewString("");
    module_imports = NewString("");
    module_class_modifiers = NewString("public");
    jniclass_imports = NewString("");
    jniclass_cppcasts_code = NewString("");
    wrapper_conversion_code = NewString("");
    if (!package) package = NewString("");
    jnipackage = NewString("");

    Swig_banner(f_runtime);               // Print the SWIG banner message

    if (NoInclude) {
      Printf(f_runtime,"#define SWIG_NOINCLUDE\n");
    }

    String *wrapper_name = NewString("");

    if(Len(package)) {
      Printv(jnipackage, package, NIL);
      Replaceall(jnipackage,".","_");
      Append(jnipackage, "_");
    }
    //Printf(wrapper_name, "Cil_%s%s_%%f", Char(jnipackage), jniclass_name);
    //Printf(wrapper_name, "%%f", jniclass_name);
    Printf(wrapper_name, "CSharp_%%f", jniclass_name);
    Swig_name_register((char*)"wrapper", Char(wrapper_name));
    Swig_name_register((char*)"set", (char*)"set_%v");
    Swig_name_register((char*)"get", (char*)"get_%v");
    Swig_name_register((char*)"member", (char*)"%c_%m");

    Delete(wrapper_name);

    Printf(f_wrappers,"\n#ifdef __cplusplus\n");
    Printf(f_wrappers,"extern \"C\" {\n");
    Printf(f_wrappers,"#endif\n\n");

    /* Emit code */
    Language::top(n);

    // Generate the CSharp JNI class
    {
      String *filen = NewStringf("%s%s.cs", Swig_file_dirname(outfile), jniclass_name);
      File *f_java = NewFile(filen,"w");
      if(!f_java) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the Java JNI class
      if(Len(package) > 0)
        Printf(f_java, "//package %s;\n\n", package);

      emitBanner(f_java);
      if(jniclass_imports)
        Printf(f_java, "%s\n", jniclass_imports);

      if (Len(jniclass_class_modifiers) > 0)
        Printf(f_java, "%s ", jniclass_class_modifiers);
      Printf(f_java, "class %s ", jniclass_name);

      if (jniclass_baseclass && *Char(jniclass_baseclass))
          Printf(f_java, ": %s ", jniclass_baseclass);
      if (Len(jniclass_interfaces) > 0)
        Printv(f_java, "implements ", jniclass_interfaces, " ", NIL);
      Printf(f_java, "{\n");

      // Add the native methods
      Printv(f_java, jniclass_class_code, NIL);
      Printv(f_java, jniclass_cppcasts_code, NIL);

      // Finish off the Java class
      Printf(f_java, "}\n");
      Close(f_java);
    }

    // Generate the Java module class
    {
      String *filen = NewStringf("%s%s.cs", Swig_file_dirname(outfile), module_class_name);
      File *f_module = NewFile(filen,"w");
      if(!f_module) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the Java module class
      if(Len(package) > 0)
        Printf(f_module, "//package %s;\n\n", package);

      emitBanner(f_module);
      if(module_imports)
        Printf(f_module, "%s\n", module_imports);

      if (Len(module_class_modifiers) > 0)
        Printf(f_module, "%s ", module_class_modifiers);
      Printf(f_module, "class %s ", module_class_name);

      if (module_baseclass && *Char(module_baseclass))
          Printf(f_module, ": %s ", module_baseclass);
      if (Len(module_interfaces) > 0)
        Printv(f_module, "implements ", module_interfaces, " ", NIL);
      Printf(f_module, "{\n");

      // Add the wrapper methods
      Printv(f_module, module_class_code, NIL);

      // Write out all the enums constants
      if (Len(module_constants_code) != 0 )
        Printv(f_module, "  // enums and constants\n", module_constants_code, NIL);

      // Finish off the Java class
      Printf(f_module, "}\n");
      Close(f_module);
    }

    if(wrapper_conversion_code)
      Printv(f_wrappers,wrapper_conversion_code,NIL);

    Printf(f_wrappers,"#ifdef __cplusplus\n");
    Printf(f_wrappers,"}\n");
    Printf(f_wrappers,"#endif\n");

    // Output a Java class for each SWIG type
    for (String *swig_type = Firstkey(swig_types_hash); swig_type; swig_type = Nextkey(swig_types_hash)) {
      emitJavaClass(swig_type, Getattr(swig_types_hash, swig_type));
    }

    Delete(swig_types_hash); swig_types_hash = NULL;
    Delete(jniclass_name); jniclass_name = NULL;
    Delete(jniclass_class_code); jniclass_class_code = NULL;
    Delete(shadow_classdef); shadow_classdef = NULL;
    Delete(shadow_code); shadow_code = NULL;
    Delete(module_constants_code); module_constants_code = NULL;
    Delete(jniclass_baseclass); jniclass_baseclass = NULL;
    Delete(jniclass_interfaces); jniclass_interfaces = NULL;
    Delete(jniclass_class_modifiers); jniclass_class_modifiers = NULL;
    Delete(module_class_name); module_class_name = NULL;
    Delete(module_class_code); module_class_code = NULL;
    Delete(module_baseclass); module_baseclass = NULL;
    Delete(module_interfaces); module_interfaces = NULL;
    Delete(module_imports); module_imports = NULL;
    Delete(module_class_modifiers); module_class_modifiers = NULL;
    Delete(jniclass_imports); jniclass_imports = NULL;
    Delete(jniclass_cppcasts_code); jniclass_cppcasts_code = NULL;
    Delete(wrapper_conversion_code); wrapper_conversion_code = NULL;
    Delete(package); package = NULL;
    Delete(jnipackage); jnipackage = NULL;

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
    Printf(f, " * Version: %s\n", PACKAGE_VERSION);
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
    String    *jnirettype = NewString("");
    String    *javarettype = NewString("");
    String    *cleanup = NewString("");
    String    *outarg = NewString("");
    String    *body = NewString("");
    String    *javaParameterSignature = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;
    bool      is_void_return;
    String    *overloaded_name = getOverloadedName(n);

    if (!Getattr(n,"sym:overloaded")) {
      if (!addSymbol(Getattr(n,"sym:name"),n)) return SWIG_ERROR;
    }

    /* 
       Generate the java class wrapper function ie the java shadow class. Only done for public
       member variables. That is this generates the getters/setters for member variables.
       Not for enums and constants.
       */

    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Capitalize the first letter in the variable to create a JavaBean type getter/setter function name
      bool getter_flag = Cmp(symname, Swig_name_set(Swig_name_member(shadow_classname, variable_name))) != 0;

      String *getter_setter_name = NewString("");
      if(!getter_flag)
        Printf(getter_setter_name,"set");
      else 
        Printf(getter_setter_name,"get");
      Putc(toupper((int) *Char(variable_name)), getter_setter_name);
      Printf(getter_setter_name, "%s", Char(variable_name)+1);

      Setattr(n,"java:shadowfuncname", getter_setter_name);
      Setattr(n,"java:funcname", symname);

      javaShadowFunctionHandler(n);
      Delete(getter_setter_name);
    }

    /*
       The rest of this function deals with generating the java wrapper function (that wraps
       a c/c++ function) and generating the JNI c code. Each java wrapper function has a 
       matching JNI c function call.
       */

    // A new wrapper function object
    Wrapper *f = NewWrapper();

    // Make a wrapper name for this function
    String *wname = Swig_name_wrapper(overloaded_name);

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("jni", l, f);
    Swig_typemap_attach_parms("jtype", l, f);

    /* Get Java return types */
    if ((tm = Swig_typemap_lookup_new("jni",n,"",0))) {
      Printf(jnirettype,"%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
          "No jni typemap defined for %s\n", SwigType_str(t,0));
    }

    if ((tm = Swig_typemap_lookup_new("jtype",n,"",0))) {
      Printf(javarettype,"%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
          "No jtype typemap defined for %s\n", SwigType_str(t,0));
    }

    is_void_return = (Cmp(jnirettype, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f,"jresult", jnirettype, "jresult = 0",NIL);

    Printv(jniclass_class_code, 
           "\n  [DllImport(\"",module_class_name,"\", EntryPoint=\"CSharp_",overloaded_name,"\")]\n", NIL);

    Printf(jniclass_class_code, "  public static extern %s %s(", javarettype, overloaded_name);

    Printv(f->def, " DllExport ", jnirettype, " ", wname, "(", NIL); //JNIEXPORT

    // Emit all of the local variables for holding arguments.
    emit_args(t,l,f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);
    Setattr(n,"wrap:parms",l);

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
      String   *javaparamtype = NewString("");
      String   *jni_param_type = NewString("");
      String   *arg = NewString("");

      Printf(arg,"j%s", ln);

      /* Get the jni types of the parameter */
      if ((tm = Getattr(p,"tmap:jni"))) {
        Printv(jni_param_type, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
            "No jni typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Get the java types of the parameter */
      if ((tm = Getattr(p,"tmap:jtype"))) {
        Printv(javaparamtype, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
            "No jtype typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Add to java function header */
      if(gencomma) Printf(jniclass_class_code, ", ");
      Printf(jniclass_class_code, "%s %s", javaparamtype, arg);

      // Add to Jni function header
      Printv(f->def, gencomma?", ":"", jni_param_type, " ", arg, NIL);

      gencomma = 1;
      
      // Get typemap for this argument
      if ((tm = Getattr(p,"tmap:in"))) {
        addThrows(n, "tmap:in", p);
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
      Delete(javaparamtype);
      Delete(jni_param_type);
      Delete(arg);
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
        addThrows(n, "tmap:check", p);
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
        addThrows(n, "tmap:freearg", p);
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
        addThrows(n, "tmap:argout", p);
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

    // Get any Java exception classes in the throw typemap
    ParmList *throw_parm_list = NULL;
    if ((throw_parm_list = Getattr(n,"throws"))) {
      Swig_typemap_attach_parms("throws", throw_parm_list, f);
      for (p = throw_parm_list; p; p=nextSibling(p)) {
        if ((tm = Getattr(p,"tmap:throws"))) {
          addThrows(n, "tmap:throws", p);
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
    if(!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
        addThrows(n, "tmap:out", n);
        Replaceall(tm,"$source", "result"); /* deprecated */
        Replaceall(tm,"$target", "jresult"); /* deprecated */
        Replaceall(tm,"$result","jresult");
        Printf(f->code,"%s", tm);
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
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* See if there is any return cleanup code */
    if(!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* Finish JNI C function and JNI class native function definitions */
    Printf(jniclass_class_code, ")");
    generateThrowsClause(n, jniclass_class_code);
    Printf(jniclass_class_code, ";\n");
    Printf(f->def,") {");

    if(!is_void_return)
      Printv(f->code, "    return jresult;\n", NIL);
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code,"$cleanup",cleanup);

    if(!is_void_return)
      Replaceall(f->code,"$null","0");
    else
      Replaceall(f->code,"$null","");

    /* Dump the function out */
    if(!native_function_flag)
      Wrapper_print(f,f_wrappers);

    Setattr(n,"wrap:name", wname);

    /* Emit warnings for the few cases that can't be overloaded in Java */
    if (Getattr(n,"sym:overloaded")) {
      if (!Getattr(n,"sym:nextSibling"))
        Swig_overload_rank(n);
    }

    if(!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
      moduleClassFunctionHandler(n);
    }

    Delete(jnirettype);
    Delete(javarettype);
    Delete(cleanup);
    Delete(outarg);
    Delete(body);
    Delete(javaParameterSignature);
    Delete(overloaded_name);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * variableWrapper()
   *
   * Create a JAVA link to a C variable.
   * ----------------------------------------------------------------------- */

  virtual int variableWrapper(Node *n) {
    Language::variableWrapper(n);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {
    SwigType  *t = Getattr(n,"type");
    String    *tm;

    // Get the variable type
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      substituteJavaclassname(t, tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    // Output the property's field declaration and accessor methods
    Printf(module_class_code, "  public static %s %s {", tm, Getattr(n, "sym:name"));

    variable_name = Getattr(n,"sym:name");
    global_variable_flag = true;
    int ret = Language::globalvariableHandler(n);
    global_variable_flag = false;

    Printf(module_class_code, "\n  }\n\n");

    return ret;
  }

  /* -----------------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *symname = Getattr(n,"sym:name");
    SwigType *t     = Getattr(n,"type");
    ParmList  *l    = Getattr(n,"parms");
    String *tm;
    String *shadowrettype = NewString("");
    String *constants_code = NewString("");
    SwigType *original_type = t;

    if (!addSymbol(symname,n)) return SWIG_ERROR;

    bool is_enum_item = (Cmp(nodeType(n), "enumitem") == 0);

    /* Adjust the enum type for the Swig_typemap_lookup. We want the same jstype typemap for all the enum items.
     * The type of each enum item depends on what value it is assigned, but is usually a C int. */
    if (is_enum_item) {
      t = NewStringf("enum %s", Getattr(parentNode(n), "sym:name"));
      Setattr(n,"type", t);
    }

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("jstype", l, NULL);

    /* Get Java return types */
    bool is_return_type_java_class = false;
    
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      is_return_type_java_class = substituteJavaclassname(t, tm);
      Printf(shadowrettype, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
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

    // enums are wrapped using a public final static int in java.
    // Other constants are wrapped using a public final static [jstype] in Java.
    Printf(constants_code, "  public static %s %s = ", shadowrettype, ((proxy_flag && wrapping_member_flag) ? variable_name : symname));

    // The %javaconst directive determines how the constant value is obtained
    String *javaconst = Getattr(n,"feature:java:const");

    if ((is_enum_item && Getattr(n,"enumvalue") == 0) || !javaconst || Cmp(javaconst, "0") == 0) {
      // Enums without value and default constant handling will work with any type of C constant and initialises the Java variable from C through a JNI call.

      if(is_return_type_java_class) // This handles function pointers using the %constant directive
        Printf(constants_code, "new %s(%s.%s(), false);\n", shadowrettype, jniclass_name, Swig_name_get(symname));
      else
        Printf(constants_code, "%s.%s();\n", jniclass_name, Swig_name_get(symname));

      // Each constant and enum value is wrapped with a separate JNI function call
      enum_constant_flag = true;
      variableWrapper(n);
      enum_constant_flag = false;
    } else if (is_enum_item) {
      // Alternative enum item handling will use the explicit value of the enum item and hope that it compiles as Java code
      Printf(constants_code, "%s;\n", Getattr(n,"enumvalue"));
    } else {
      // Alternative constant handling will use the C syntax to make a true Java constant and hope that it compiles as Java code
      Printf(constants_code, "%s;\n", Getattr(n,"value"));
    }

    if(proxy_flag && wrapping_member_flag)
      Printv(shadow_constants_code, constants_code, NIL);
    else
      Printv(module_constants_code, constants_code, NIL);

    Swig_restore(n);
    if (is_enum_item) {
      Delete(Getattr(n,"type"));
      Setattr(n,"type", original_type);
    }
    Delete(new_value);
    Delete(shadowrettype);
    Delete(constants_code);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * pragmaDirective()
   *
   * Valid Pragmas:
   * jniclassbase            - base (extends) for the JNI class
   * jniclassclassmodifiers  - class modifiers for the JNI class
   * jniclasscode            - text (java code) is copied verbatim to the JNI class
   * jniclassimports         - import statements for the JNI class
   * jniclassinterfaces      - interface (implements) for the JNI class
   *
   * modulebase              - base (extends) for the module class
   * moduleclassmodifiers    - class modifiers for the module class
   * modulecode              - text (java code) is copied verbatim to the module class
   * moduleimports           - import statements for the module class
   * moduleinterfaces        - interface (implements) for the module class
   *
   * ----------------------------------------------------------------------------- */

  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n,"lang");
      String *code = Getattr(n,"name");
      String *value = Getattr(n,"value");

      if(Strcmp(lang, "java") == 0) {

        String *strvalue = NewString(value);
        Replaceall(strvalue,"\\\"", "\"");

        if(Strcmp(code, "jniclassbase") == 0) {
          Delete(jniclass_baseclass);
          jniclass_baseclass = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclassclassmodifiers") == 0) {
          Delete(jniclass_class_modifiers);
          jniclass_class_modifiers = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclasscode") == 0) {
          Printf(jniclass_class_code, "%s\n", strvalue);
        } 
        else if(Strcmp(code, "jniclassimports") == 0) {
          Delete(jniclass_imports);
          jniclass_imports = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclassinterfaces") == 0) {
          Delete(jniclass_interfaces);
          jniclass_interfaces = Copy(strvalue);
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
        } 
        else if(Strcmp(code, "moduleimport") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use the moduleimports pragma.\n", input_file, line_number);
        } 
        else if(Strcmp(code, "moduleinterface") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use the moduleinterfaces pragma.\n", input_file, line_number);
        } 
        else if(Strcmp(code, "modulemethodmodifiers") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %javamethodmodifiers.\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowimport") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javaimports).\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowcode") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javacode).\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowbase") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javabase).\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowinterface") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javainterfaces).\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowclassmodifiers") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javaclassmodifiers).\n", input_file, line_number);
        } 
        else if (proxy_flag) {
          if (Strcmp(code,"shadowcode") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javacode).\n", input_file, line_number);
          } 
          else if (Strcmp(code,"shadowimport") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javaimports).\n", input_file, line_number);
          } 
          else if (Strcmp(code,"shadowbase") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javabase).\n", input_file, line_number);
          } 
          else if (Strcmp(code,"shadowinterface") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javainterfaces).\n", input_file, line_number);
          } 
          else if (Strcmp(code,"shadowclassmodifiers") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javaclassmodifiers).\n", input_file, line_number);
          }  else {
            Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
          }
        } else {
          Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
        }
        Delete(strvalue);
      }
    }
    return Language::pragmaDirective(n);
  }

  /* -----------------------------------------------------------------------------
   * emitShadowClassDefAndCPPCasts()
   * ----------------------------------------------------------------------------- */

  void emitShadowClassDefAndCPPCasts(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n,"name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;

    /* Deal with inheritance */
    List *baselist = Getattr(n,"bases");
    if (baselist) {
      Node *base = Firstitem(baselist);
      c_baseclassname = Getattr(base,"name");
      baseclass = Copy(is_shadow(c_baseclassname));
      if (baseclass){
        c_baseclass = SwigType_namestr(Getattr(base,"name"));
      }
      base = Nextitem(baselist);
      if (base) {
        Swig_warning(WARN_JAVA_MULTIPLE_INHERITANCE, input_file, line_number, 
            "Warning for %s: Base %s ignored. Multiple inheritance is not supported in C#.\n", shadow_classname, Getattr(base,"name"));
      }
    }

    bool derived = baseclass && is_shadow(c_baseclassname);
    if (!baseclass)
      baseclass = NewString("");

    // Inheritance from pure Java classes
    const String *pure_java_baseclass = javaTypemapLookup("javabase", shadow_classname, WARN_NONE);
    if (Len(pure_java_baseclass) > 0 && Len(baseclass) > 0) {
      Swig_warning(WARN_JAVA_MULTIPLE_INHERITANCE, input_file, line_number, 
          "Warning for %s: Base %s ignored. Multiple inheritance is not supported in C#.\n", shadow_classname, pure_java_baseclass);
    }

    // Pure Java interfaces
    const String *pure_java_interfaces = javaTypemapLookup("javainterfaces", shadow_classname, WARN_NONE);

    // Start writing the shadow class
    Printv(shadow_classdef,
        javaTypemapLookup("javaimports", shadow_classname, WARN_NONE), // Import statements
        "\n",
        javaTypemapLookup("javaclassmodifiers", shadow_classname, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " class $javaclassname : ",       // Class name and bases
        baseclass,
        pure_java_baseclass,
        (derived || *Char(pure_java_baseclass)) ?
        ", " :
        "",
        pure_java_interfaces,
        *Char(pure_java_interfaces) ?  // Pure Java interfaces
        ", IDisposable" :
        "IDisposable",
        " {\n",
        "  private IntPtr swigCPtr;\n",  // Member variables for memory handling
        derived ? 
        "" : 
        "  protected bool swigCMemOwn;\n",
        "\n",
        "  ",
        javaTypemapLookup("javaptrconstructormodifiers", shadow_classname, WARN_JAVA_TYPEMAP_PTRCONSTMOD_UNDEF), // pointer constructor modifiers
        " $javaclassname(IntPtr cPtr, bool cMemoryOwn) ", // Constructor used for wrapping pointers
        derived ? 
        ": base($jniclassname.$javaclassnameTo$baseclass(cPtr), cMemoryOwn) {\n" : 
        "{\n    swigCMemOwn = cMemoryOwn;\n",
        "    swigCPtr = cPtr;\n",
        "  }\n",
        NIL);

    if(!have_default_constructor_flag) { // All Java classes need a constructor
      Printv(shadow_classdef, 
          "\n",
          "  protected $javaclassname() : this(IntPtr.Zero, false) {\n",
          "  }\n",
          NIL);
    }

    Printv(shadow_classdef, 
        derived?javaTypemapLookup("cildisposeoverride", shadow_classname, WARN_NONE):
            javaTypemapLookup("cildispose", shadow_classname, WARN_NONE), // finalize method
        "\n",
        *Char(destructor_call) ? "  protected " : "  private ", 
        derived ? "override" : "virtual",
        " void delete() {\n",
        "    if(swigCPtr != IntPtr.Zero && swigCMemOwn) {\n",
        destructor_call,
        "",
        "      swigCMemOwn = false;\n",
        derived ?    // Zero all pointers up any inheritance hierarchy
        "      base.delete();\n" : 
        "",
        "    }\n",
        "    swigCPtr = IntPtr.Zero;\n",
        "  }\n",
        javaTypemapLookup("javagetcptr", shadow_classname, WARN_JAVA_TYPEMAP_GETCPTR_UNDEF), // getCPtr method
        javaTypemapLookup("javacode", shadow_classname, WARN_NONE), // extra Java code
        "\n",
        NIL);

    // Substitute various strings into the above template
    Replaceall(shadow_code,     "$javaclassname", shadow_classname);
    Replaceall(shadow_classdef, "$javaclassname", shadow_classname);

    Replaceall(shadow_classdef, "$baseclass", baseclass);
    Replaceall(shadow_code,     "$baseclass", baseclass);

    Replaceall(shadow_classdef, "$jniclassname", jniclass_name);
    Replaceall(shadow_code,     "$jniclassname", jniclass_name);

    // Add JNI code to do C++ casting to base class (only for classes in an inheritance hierarchy)
    if(derived){
      Printv(jniclass_cppcasts_code,"\n  [DllImport(\"", module_class_name, "\", EntryPoint=\"CSharp_", shadow_classname ,"To", baseclass ,"\")]\n", NIL);
      Printv(jniclass_cppcasts_code,"  public static extern IntPtr ",
          "$javaclassnameTo$baseclass(IntPtr objectRef);\n",
          NIL);

      Replaceall(jniclass_cppcasts_code, "$javaclassname", shadow_classname);
      Replaceall(jniclass_cppcasts_code, "$baseclass", baseclass);

      Printv(wrapper_conversion_code,
          "DllExport long CSharp_$jniclazznameTo$jnibaseclass", //JNIEXPORT
          "(long objectRef) {\n",
          "    long baseptr = 0;\n"
          "    *($cbaseclass **)&baseptr = *($cclass **)&objectRef;\n"
          "    return baseptr;\n"
          "}\n",
          "\n",
          NIL); 

      Replaceall(wrapper_conversion_code, "$jnibaseclass",baseclass);
      Replaceall(wrapper_conversion_code, "$cbaseclass",  c_baseclass);
      Replaceall(wrapper_conversion_code, "$jniclazzname",shadow_classname);
      Replaceall(wrapper_conversion_code, "$cclass",      c_classname);
      //Replaceall(wrapper_conversion_code, "$jnipackage",  jnipackage);
      //Replaceall(wrapper_conversion_code, "$jnijniclass", jniclass_name);
    }
    Delete(baseclass);
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {

    File *f_shadow = NULL;
    if (proxy_flag) {
      shadow_classname = NewString(Getattr(n,"sym:name"));

      if (!addSymbol(shadow_classname,n)) return SWIG_ERROR;

      if (Cmp(shadow_classname, jniclass_name) == 0) {
        Printf(stderr, "Class name cannot be equal to JNI class name: %s\n", shadow_classname);
        SWIG_exit(EXIT_FAILURE);
      }

      if (Cmp(shadow_classname, module_class_name) == 0) {
        Printf(stderr, "Class name cannot be equal to module class name: %s\n", shadow_classname);
        SWIG_exit(EXIT_FAILURE);
      }

      String *filen = NewStringf("%s%s.cs", Swig_file_dirname(outfile), shadow_classname);
      f_shadow = NewFile(filen,"w");
      if(!f_shadow) {
        Printf(stderr, "Unable to create proxy class file: %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      emitBanner(f_shadow);

      if(Len(package) > 0)
        Printf(f_shadow, "//package %s;\n\n", package);

      Clear(shadow_classdef);
      Clear(shadow_code);

      have_default_constructor_flag = false;
      destructor_call = NewString("");
      shadow_constants_code = NewString("");
    }
    Language::classHandler(n);

    if (proxy_flag) {

      emitShadowClassDefAndCPPCasts(n);

      Printv(f_shadow, shadow_classdef, shadow_code, NIL);

      // Write out all the enums and constants
      if (Len(shadow_constants_code) != 0 )
        Printv(f_shadow, "  // enums and constants\n", shadow_constants_code, NIL);

      Printf(f_shadow, "}\n");
      Close(f_shadow);
      f_shadow = NULL;

      Delete(shadow_classname); shadow_classname = NULL;
      Delete(destructor_call); destructor_call = NULL;
      Delete(shadow_constants_code); shadow_constants_code = NULL;
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
      String *java_function_name = Swig_name_member(shadow_classname, overloaded_name);
      Setattr(n,"java:shadowfuncname", Getattr(n, "sym:name"));
      Setattr(n,"java:funcname", java_function_name);
      javaShadowFunctionHandler(n);
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
      String *java_function_name = Swig_name_member(shadow_classname, overloaded_name);
      Setattr(n,"java:shadowfuncname", Getattr(n,"sym:name"));
      Setattr(n,"java:funcname", java_function_name);
      javaShadowFunctionHandler(n);
      Delete(overloaded_name);
    }
    static_flag = false;

    return SWIG_OK;
  }


  /* -----------------------------------------------------------------------------
   * javaShadowFunctionHandler()
   *
   * Function called for creating a java class wrapper function around a c++ function in the 
   * java wrapper class. Used for both static and non static functions.
   * C++ static functions map to java static functions.
   * Two extra attributes in the Node must be available. These are "java:shadowfuncname" - the name of the java class shadow 
   * function, which in turn will call "java:funcname" - the java native function name which wraps the c++ function.
   * ----------------------------------------------------------------------------- */

  void javaShadowFunctionHandler(Node *n) {
    SwigType  *t = Getattr(n,"type");
    ParmList  *l = Getattr(n,"parms");
    String    *java_function_name = Getattr(n,"java:funcname");
    String    *java_shadow_function_name = Getattr(n,"java:shadowfuncname");
    String    *tm;
    Parm      *p;
    int       i;
    String    *nativecall = NewString("");
    String    *shadowrettype = NewString("");
    String    *function_code = NewString("");
    bool      setter_flag;

    if(!proxy_flag) return;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("jstype", l, NULL);
    Swig_typemap_attach_parms("javain", l, NULL);

    /* Get Java return types */
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      substituteJavaclassname(t, tm);
      Printf(shadowrettype, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Properties
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(Swig_name_member(shadow_classname, variable_name))) == 0);
    }

    /* Start generating the shadow function */
    Printf(function_code, "  %s ", Getattr(n,"feature:java:methodmodifiers"));
    if (static_flag)
      Printf(function_code, "static ");
    if (Getattr(n,"virtual:derived"))
        Printf(function_code, "override ");
    else if (checkAttribute(n, "storage", "virtual"))
        Printf(function_code, "virtual ");

    Printf(function_code, "%s %s(", shadowrettype, java_shadow_function_name);

    Printv(nativecall, jniclass_name, ".", java_function_name, "(", NIL);
    if (!static_flag)
      Printv(nativecall, "swigCPtr", NIL);

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
        String   *javaparamtype = NewString("");

        /* Get the java type of the parameter */
        if ((tm = Getattr(p,"tmap:jstype"))) {
          substituteJavaclassname(pt, tm);
          Printf(javaparamtype, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
              "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(nativecall, ", ");

        String *arg = variable_wrapper_flag ? NewString("value") : makeParameterName(n, p, i);

        // Use typemaps to transform type used in Java wrapper function (in proxy class) to type used in native function (in JNI class)
        if ((tm = Getattr(p,"tmap:javain"))) {
          substituteJavaclassname(pt, tm);
          Replaceall(tm, "$javainput", arg);
          Printv(nativecall, tm, NIL);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
              "No javain typemap defined for %s\n", SwigType_str(pt,0));
        }

        /* Add to java shadow function header */
        if (gencomma >= 2)
          Printf(function_code, ", ");
        gencomma = 2;
        Printf(function_code, "%s %s", javaparamtype, arg);

        Delete(arg);
        Delete(javaparamtype);
      }
      p = Getattr(p,"tmap:in:next");
    }

    Printf(nativecall, ")");
    Printf(function_code, ")");
    generateThrowsClause(n, function_code);

    // Transform return type used in native function (in JNI class) to type used in Java wrapper function (in proxy class)
    if ((tm = Swig_typemap_lookup_new("javaout",n,"",0))) {
      if (Getattr(n,"feature:new"))
        Replaceall(tm,"$owner","true");
      else
        Replaceall(tm,"$owner","false");
      substituteJavaclassname(t, tm);
      Replaceall(tm, "$jnicall", nativecall);
      Printf(function_code, " %s\n\n", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
          "No javaout typemap defined for %s\n", SwigType_str(t,0));
    }

    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Properties
      if(setter_flag) {
        // Setter method
        if ((tm = Swig_typemap_lookup_new("csvarin",n,"",0))) {
          if (Getattr(n,"feature:new"))
            Replaceall(tm,"$owner","true");
          else
            Replaceall(tm,"$owner","false");
          substituteJavaclassname(t, tm);
          Replaceall(tm, "$jnicall", nativecall);
          Printf(shadow_code, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
              "No csvarin typemap defined for %s\n", SwigType_str(t,0));
        }
      } else {
        // Getter method
        if ((tm = Swig_typemap_lookup_new("csvarout",n,"",0))) {
          if (Getattr(n,"feature:new"))
            Replaceall(tm,"$owner","true");
          else
            Replaceall(tm,"$owner","false");
          substituteJavaclassname(t, tm);
          Replaceall(tm, "$jnicall", nativecall);
          Printf(shadow_code, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
              "No csvarout typemap defined for %s\n", SwigType_str(t,0));
        }
      }
    } else {
      // Normal function call
      Printv(shadow_code, function_code, NIL);
    }

    Delete(function_code);
    Delete(shadowrettype);
    Delete(nativecall);
  }

  /* ----------------------------------------------------------------------
   * constructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {

    ParmList *l = Getattr(n,"parms");
    String    *tm;
    Parm      *p;
    int       i;

    Language::constructorHandler(n);

    if(proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *nativecall = NewString("");

      Printf(shadow_code, "  %s %s(", Getattr(n,"feature:java:methodmodifiers"), shadow_classname);
      Printv(nativecall, " : this(", jniclass_name, ".", Swig_name_construct(overloaded_name), "(", NIL);

      /* Attach the non-standard typemaps to the parameter list */
      Swig_typemap_attach_parms("in", l, NULL);
      Swig_typemap_attach_parms("jstype", l, NULL);
      Swig_typemap_attach_parms("javain", l, NULL);

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
        String   *javaparamtype = NewString("");

        /* Get the java type of the parameter */
        if ((tm = Getattr(p,"tmap:jstype"))) {
          substituteJavaclassname(pt, tm);
          Printf(javaparamtype, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
              "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(nativecall, ", ");

        String *arg = makeParameterName(n, p, i);

        // Use typemaps to transform type used in Java wrapper function (in proxy class) to type used in native function (in JNI class)
        if ((tm = Getattr(p,"tmap:javain"))) {
          substituteJavaclassname(pt, tm);
          Replaceall(tm, "$javainput", arg);
          Printv(nativecall, tm, NIL);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
              "No javain typemap defined for %s\n", SwigType_str(pt,0));
        }

        /* Add to java shadow function header */
        if(gencomma)
          Printf(shadow_code, ", ");
        Printf(shadow_code, "%s %s", javaparamtype, arg);
        gencomma = 1;

        Delete(arg);
        Delete(javaparamtype);
        p = Getattr(p,"tmap:in:next");
      }

      Printf(nativecall, "), true)");

      Printf(shadow_code, ")");
      Printf(shadow_code,"%s", nativecall);
      generateThrowsClause(n, shadow_code);
      Printf(shadow_code, " {\n");
      Printf(shadow_code, "  }\n\n");

      if(!gencomma)  // We must have a default constructor
        have_default_constructor_flag = true;

      Delete(overloaded_name);
      Delete(nativecall);
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
      Printv(destructor_call, "      ", jniclass_name, ".", Swig_name_destroy(symname), "(swigCPtr);\n", NIL);
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    SwigType  *t = Getattr(n,"type");
    String    *tm;

    // Get the variable type
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      substituteJavaclassname(t, tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    // Output the property's field declaration and accessor methods
    Printf(shadow_code, "  public %s %s {", tm, Getattr(n, "sym:name"));

    variable_name = Getattr(n,"sym:name");
    wrapping_member_flag = true;
    variable_wrapper_flag = true;
    Language::membervariableHandler(n);
    wrapping_member_flag = false;
    variable_wrapper_flag = false;

    Printf(shadow_code, "\n  }\n\n");

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmembervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {

    bool static_const_member_flag = (Getattr(n, "value") == 0);
    if(static_const_member_flag) {
      SwigType  *t = Getattr(n,"type");
      String    *tm;

      // Get the variable type
      if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
        substituteJavaclassname(t, tm);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
            "No jstype typemap defined for %s\n", SwigType_str(t,0));
      }

      // Output the property's field declaration and accessor methods
      Printf(shadow_code, "  public static %s %s {", tm, Getattr(n, "sym:name"));
    }

    variable_name = Getattr(n,"sym:name");
    wrapping_member_flag = true;
    static_flag = true;
    Language::staticmembervariableHandler(n);
    wrapping_member_flag = false;
    static_flag = false;

    if(static_const_member_flag)
      Printf(shadow_code, "\n  }\n\n");

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

    /* Although the JNI is designed to handle overloaded Java functions, a Java long is used for all classes in the SWIG
     * JNI native interface. The JNI native interface function is thus mangled when overloaded to give a unique name. */
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
    int       i;
    String    *nativecall = NewString("");
    String    *shadowrettype = NewString("");
    String    *function_code = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;
    String    *overloaded_name = getOverloadedName(n);
    String    *func_name = NULL;
    bool      setter_flag;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("jstype", l, NULL);
    Swig_typemap_attach_parms("javain", l, NULL);

    /* Get Java return types */
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      substituteJavaclassname(t, tm);
      Printf(shadowrettype, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    /* Change function name for global variables */
    if (proxy_flag && global_variable_flag) {
      // Capitalize the first letter in the variable to create a JavaBean type getter/setter function name
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
    Printf(function_code, "  %s static %s %s(", Getattr(n,"feature:java:methodmodifiers"), shadowrettype, func_name);
    Printv(nativecall, jniclass_name, ".", overloaded_name, "(", NIL);

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
      String   *javaparamtype = NewString("");

      /* Get the java type of the parameter */
      if ((tm = Getattr(p,"tmap:jstype"))) {
        substituteJavaclassname(pt, tm);
        Printf(javaparamtype, "%s", tm);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
            "No jstype typemap defined for %s\n", SwigType_str(pt,0));
      }

      if (gencomma)
        Printf(nativecall, ", ");

      String *arg = makeParameterName(n, p, i);

      // Use typemaps to transform type used in Java wrapper function (in proxy class) to type used in native function (in JNI class)
      if ((tm = Getattr(p,"tmap:javain"))) {
        substituteJavaclassname(pt, tm);
        Replaceall(tm, "$javainput", arg);
        Printv(nativecall, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
            "No javain typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Add to java shadow function header */
      if (gencomma >= 2)
        Printf(function_code, ", ");
      gencomma = 2;
      Printf(function_code, "%s %s", javaparamtype, arg);

      p = Getattr(p,"tmap:in:next");
      Delete(arg);
      Delete(javaparamtype);
    }

    Printf(nativecall, ")");
    Printf(function_code, ")");
    generateThrowsClause(n, function_code);

    // Transform return type used in native function (in JNI class) to type used in Java wrapper function (in module class)
    if ((tm = Swig_typemap_lookup_new("javaout",n,"",0))) {
      if (Getattr(n,"feature:new"))
        Replaceall(tm,"$owner","true");
      else
        Replaceall(tm,"$owner","false");
      substituteJavaclassname(t, tm);
      Replaceall(tm, "$jnicall", nativecall);
      Printf(function_code, " %s\n\n", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
          "No javaout typemap defined for %s\n", SwigType_str(t,0));
    }

    if (proxy_flag && global_variable_flag) {
      // Properties
      if(setter_flag) {
        // Setter method
        if ((tm = Swig_typemap_lookup_new("csvarin",n,"",0))) {
          if (Getattr(n,"feature:new"))
            Replaceall(tm,"$owner","true");
          else
            Replaceall(tm,"$owner","false");
          substituteJavaclassname(t, tm);
          Replaceall(tm, "$jnicall", nativecall);
          Printf(module_class_code, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
              "No csvarin typemap defined for %s\n", SwigType_str(t,0));
        }
      } else {
        // Getter method
        if ((tm = Swig_typemap_lookup_new("csvarout",n,"",0))) {
          if (Getattr(n,"feature:new"))
            Replaceall(tm,"$owner","true");
          else
            Replaceall(tm,"$owner","false");
          substituteJavaclassname(t, tm);
          Replaceall(tm, "$jnicall", nativecall);
          Printf(module_class_code, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
              "No csvarout typemap defined for %s\n", SwigType_str(t,0));
        }
      }
    } else {
      // Normal function call
      Printv(module_class_code, function_code, NIL);
    }

    Delete(function_code);
    Delete(shadowrettype);
    Delete(nativecall);
    Delete(func_name);
  }

  /* -----------------------------------------------------------------------------
   * substituteJavaclassname()
   *
   * Substitute $javaclassname with either the shadow class name for classes/structs/unions that SWIG knows about.
   * Otherwise use the $descriptor name for the Java class name. Note that the $&javaclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - jstype typemap
   * Outputs:
   *   tm - jstype typemap with $javaclassname substitution
   * Return:
   *   is_java_class - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteJavaclassname(SwigType *pt, String *tm) {
    bool is_java_class = false;
    if (Strstr(tm, "$javaclassname") || Strstr(tm,"$&javaclassname")) {
      String *javaclassname = is_shadow(pt);
      if (javaclassname) {
        Replaceall(tm,"$&javaclassname", javaclassname); // is_shadow() works for pointers to classes too
        Replaceall(tm,"$javaclassname", javaclassname);
      }
      else { // use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
        String *descriptor = NULL;
        SwigType *type = Copy(SwigType_typedef_resolve_all(pt));

        if (Strstr(tm, "$&javaclassname")) {
          SwigType_add_pointer(type);
          descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
          Replaceall(tm, "$&javaclassname", descriptor);
        }
        else { // $javaclassname
          descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
          Replaceall(tm, "$javaclassname", descriptor);
        }

        // Add to hash table so that the SWIGTYPE Java classes can be created later
        Setattr(swig_types_hash, descriptor, type);
        Delete(descriptor);
        Delete(type);
      }
      is_java_class = true;
    }
    return is_java_class;
  }

  /* -----------------------------------------------------------------------------
   * makeParameterName()
   *
   * Inputs: 
   *   n - Node
   *   p - parameter node
   *   arg_num - parameter argument number
   * Return:
   *   arg - a unique parameter name
   * ----------------------------------------------------------------------------- */

  String *makeParameterName(Node *n, Parm *p, int arg_num) {

    // Use C parameter name unless it is a duplicate or an empty parameter name
    String   *pn = Getattr(p,"name");
    int count = 0;
    ParmList *plist = Getattr(n,"parms");
    while (plist) {
      if ((Cmp(pn, Getattr(plist,"name")) == 0))
        count++;
      plist = nextSibling(plist);
    }
    String *arg = (!pn || (count > 1)) ? NewStringf("arg%d",arg_num) : Copy(Getattr(p,"name"));
    
    return arg;
  }

  /* -----------------------------------------------------------------------------
   * emitJavaClass()
   * ----------------------------------------------------------------------------- */

  void emitJavaClass(String *javaclassname, SwigType *type) {
    String *filen = NewStringf("%s%s.cs", Swig_file_dirname(outfile), javaclassname);
    File *f_swigtype = NewFile(filen,"w");
    String *swigtype = NewString("");

    // Emit banner and package name
    emitBanner(f_swigtype);
    if(Len(package) > 0)
      Printf(f_swigtype, "//package %s;\n\n", package);

    // Pure Java baseclass and interfaces
    const String *pure_java_baseclass = javaTypemapLookup("javabase", type, WARN_NONE);
    const String *pure_java_interfaces = javaTypemapLookup("javainterfaces", type, WARN_NONE);

    // Emit the class
    Printv(swigtype,
        javaTypemapLookup("javaimports", type, WARN_NONE), // Import statements
        "\n",
        javaTypemapLookup("javaclassmodifiers", type, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " class $javaclassname",       // Class name and bases
        *Char(pure_java_baseclass) ?
        " : " : 
        "",
        pure_java_baseclass,
        *Char(pure_java_interfaces) ?  // Pure Java interfaces
        " : " :
        "",
        pure_java_interfaces,
        " {\n",
        "  private IntPtr swigCPtr;\n",
        "\n",
        "  ",
        javaTypemapLookup("javaptrconstructormodifiers", type, WARN_JAVA_TYPEMAP_PTRCONSTMOD_UNDEF), // pointer constructor modifiers
        " $javaclassname(IntPtr cPtr, bool bFutureUse) {\n", // Constructor used for wrapping pointers
        "    swigCPtr = cPtr;\n",
        "  }\n",
        "\n",
        "  protected $javaclassname() {\n", // Default constructor
        "    swigCPtr = IntPtr.Zero;\n",
        "  }\n",
        javaTypemapLookup("javagetcptr", type, WARN_JAVA_TYPEMAP_GETCPTR_UNDEF), // getCPtr method
        javaTypemapLookup("javacode", type, WARN_NONE), // extra Java code
        "}\n",
        "\n",
        NIL);

        Replaceall(swigtype, "$javaclassname", javaclassname);
        Printv(f_swigtype, swigtype, NIL);

        Close(f_swigtype);
        Delete(filen);
        Delete(swigtype);
  }

  /* -----------------------------------------------------------------------------
   * javaTypemapLookup()
   * ----------------------------------------------------------------------------- */

  const String *javaTypemapLookup(const String *op, String *type, int warning) {
    String *tm = NULL;
    const String *code = NULL;

    if((tm = Swig_typemap_search(op, type, NULL, NULL))) {
      code = Getattr(tm,"code");
    }

    if (!code) {
      code = empty_string;
      if (warning != WARN_NONE)
        Swig_warning(warning, input_file, line_number, "No %s typemap defined for %s\n", op, type);
    }

    return code ? code : empty_string;
  }

  /* -----------------------------------------------------------------------------
   * addThrows()
   * ----------------------------------------------------------------------------- */

  void addThrows(Node *n, const String *typemap, Node *parameter) {
    // Get the comma separated throws clause - held in "throws" attribute in the typemap passed in
    String *throws_attribute = NewStringf("%s:throws", typemap);
    String *throws = Getattr(parameter,throws_attribute);

    if (throws) {
      String *throws_list = Getattr(n,"java:throwslist");
      if (!throws_list) {
        throws_list = NewList();
        Setattr(n,"java:throwslist", throws_list);
      }

      // Put the exception classes in the throws clause into a temporary List
      List *temp_classes_list = Split(throws,',',INT_MAX);

      // Add the exception classes to the node throws list, but don't duplicate if already in list
      if (temp_classes_list && Len(temp_classes_list) > 0) {
        for (String *cls = Firstitem(temp_classes_list); cls; cls = Nextitem(temp_classes_list)) {
          String *javacls = NewString(cls);
          Replaceall(javacls," ","");  // remove spaces
          Replaceall(javacls,"\t",""); // remove tabs
          if (Len(javacls) > 0) {
            // $javaclassname substitution
            SwigType *pt = Getattr(parameter,"type");
            substituteJavaclassname(pt, javacls);

            // Don't duplicate the Java class in the throws clause
            bool found_flag = false;
            for (String *item = Firstitem(throws_list); item; item = Nextitem(throws_list)) {
              if (Strcmp(item, javacls) == 0)
                found_flag = true;
            }
            if (!found_flag)
              Append(throws_list, javacls);
          }
          Delete(javacls);
        } 
      }
      Delete(temp_classes_list);
    } 
    Delete(throws_attribute);
  }

  /* -----------------------------------------------------------------------------
   * generateThrowsClause()
   * ----------------------------------------------------------------------------- */

  void generateThrowsClause(Node *n, String *code) {
    // Add the throws clause into code
    List *throws_list = Getattr(n,"java:throwslist");
    if (throws_list) {
      String *cls = Firstitem(throws_list);
      Printf(code, " throws %s", cls);
      while ( (cls = Nextitem(throws_list)) )
        Printf(code, ", %s", cls);
    }
  }

};   /* class CSHARP */

/* -----------------------------------------------------------------------------
 * swig_csharp()    - Instantiate module
 * ----------------------------------------------------------------------------- */

extern "C" Language *
swig_csharp(void) {
  return new CSHARP();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *CSHARP::usage = (char*)"\
C# Options (available with -csharp)\n\
     -package <name> - set name of the assembly\n\
     -noproxy        - Generate the low-level functional interface instead of proxy classes\n\
\n";
