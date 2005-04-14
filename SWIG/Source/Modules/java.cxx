/* -----------------------------------------------------------------------------
 * java.cxx
 *
 *     Java wrapper module.
 *
 * Author(s) : William Fulton
 *             Harco de Hilster
 *
 * Copyright (C) 1999-2002.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

char cvsroot_java_cxx[] = "$Header$";

#include <limits.h> // for INT_MAX
#include "swigmod.h"
#include <ctype.h>

/* Hash type used for JNI upcall data */
typedef DOH UpcallData;

class JAVA : public Language {
  static const char *usage;
  const  String *empty_string;
  const  String *public_string;
  const  String *protected_string;

  Hash   *swig_types_hash;
  File   *f_runtime;
  File   *f_runtime_h;
  File   *f_header;
  File   *f_wrappers;
  File   *f_init;
  File   *f_directors;
  File   *f_directors_h;

  bool   proxy_flag; // Flag for generating proxy classes
  bool   native_function_flag;     // Flag for when wrapping a native function
  bool   enum_constant_flag; // Flag for when wrapping an enum or constant
  bool   static_flag; // Flag for when wrapping a static functions or member variables
  bool   variable_wrapper_flag; // Flag for when wrapping a nonstatic member variable
  bool   wrapping_member_flag; // Flag for when wrapping a member variable/enum/const
  bool   global_variable_flag; // Flag for when wrapping a global variable
  bool   member_func_flag;      // flag set when wrapping a member function

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
  String *package; // Optional package name
  String *jnipackage; // Package name used in the JNI code
  String *package_path; // Package name used internally by JNI (slashes)
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
  String *imclass_directors; // Intermediate class director Java code
  String *destructor_call; //C++ destructor call if any

  // Director method stuff:
  List   *dmethods_seq;
  Hash   *dmethods_table;
  int     n_dmethods;
  int     n_directors;
  int     first_class_dmethod;
  int     curr_class_dmethod;

  enum EnumFeature { SimpleEnum, TypeunsafeEnum, TypesafeEnum, ProperEnum };

  public:

  /* -----------------------------------------------------------------------------
   * JAVA()
   * ----------------------------------------------------------------------------- */

  JAVA() : 
    empty_string(NewString("")),
    public_string(NewString("public")),
    protected_string(NewString("protected")),

    swig_types_hash(NULL),
    f_runtime(NULL),
    f_runtime_h(NULL),
    f_header(NULL),
    f_wrappers(NULL),
    f_init(NULL),
    f_directors(NULL),
    f_directors_h(NULL),

    proxy_flag(true),
    native_function_flag(false),
    enum_constant_flag(false),
    static_flag(false),
    variable_wrapper_flag(false),
    wrapping_member_flag(false),
    global_variable_flag(false),
    member_func_flag(false),

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
    package(NULL),
    jnipackage(NULL),
    package_path(NULL),
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
    imclass_directors(NULL),
    destructor_call(NULL),

    dmethods_seq(NULL),
    dmethods_table(NULL),
    n_dmethods(0),
    n_directors(0)
    {
      /* for now, multiple inheritance in directors is disabled, this
         should be easy to implement though */
      director_multiple_inheritance = 0;
      director_language = 1;
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

  /* -----------------------------------------------------------------------------
   * makeValidJniName()
   * ----------------------------------------------------------------------------- */

  String *makeValidJniName(const String *name) {
    String *valid_jni_name = NewString(name);
    Replaceall(valid_jni_name,"_","_1");
    return valid_jni_name;
  }

  /* -----------------------------------------------------------------------------
   * directorClassName()
   * ----------------------------------------------------------------------------- */

  String *directorClassName(Node *n) {
    String *dirclassname;
    const char *attrib = "director:classname";

    if ((dirclassname = Getattr(n, attrib)) == NULL) {
      String *classname = Getattr(n, "sym:name");

      dirclassname = NewStringf("SwigDirector_%s", classname);
      Setattr(n, attrib, dirclassname);
    }

    return dirclassname;
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("java");

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
          Printf(stderr,"Deprecated command line option: -nofinalize. Use the new javafinalize typemap instead.\n");
        } else if (strcmp(argv[i],"-jnicpp") == 0) {
          Swig_mark_arg(i);
          Printf(stderr,"Deprecated command line option: -jnicpp. C++ JNI calling convention now used when -c++ specified.\n");
        } else if (strcmp(argv[i],"-help") == 0) {
          Printf(stdout,"%s\n", usage);
        }
      }
    }

    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGJAVA 1",0);

    // Add typemap definitions
    SWIG_typemap_lang("java");
    SWIG_config_file("java.swg");

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {

    // Get any options set in the module directive
    Node* optionsnode = Getattr( Getattr(n,"module"), "options");

    if (optionsnode) {
      if (Getattr(optionsnode,"jniclassname"))
        imclass_name = Copy(Getattr(optionsnode,"jniclassname"));
      /* check if directors are enabled for this module.  note: this 
       * is a "master" switch, without which no director code will be
       * emitted.  %feature("director") statements are also required
       * to enable directors for individual classes or methods.
       *
       * use %module(directors="1") modulename at the start of the 
       * interface file to enable director generation.
       */
      if (Getattr(optionsnode, "directors")) {
        allow_directors();
      }
      if (Getattr(optionsnode, "dirprot")) {
        allow_dirprot();
      }
    }

    /* Initialize all of the output files */
    String *outfile = Getattr(n,"outfile");
    String *outfile_h = Getattr(n, "outfile_h");

    f_runtime = NewFile(outfile,"w");
    if (!f_runtime) {
      Printf(stderr,"Unable to open %s\n", outfile);
      SWIG_exit(EXIT_FAILURE);
    }

    if (directorsEnabled()) {
      f_runtime_h = NewFile(outfile_h,"w");
      if (!f_runtime_h) {
        Printf(stderr,"Unable to open %s\n", outfile_h);
        SWIG_exit(EXIT_FAILURE);
      }
    }

    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_directors_h = NewString("");
    f_directors = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header",f_header);
    Swig_register_filebyname("wrapper",f_wrappers);
    Swig_register_filebyname("runtime",f_runtime);
    Swig_register_filebyname("init",f_init);
    Swig_register_filebyname("director",f_directors);
    Swig_register_filebyname("director_h",f_directors_h);

    swig_types_hash = NewHash();

    // Make the intermediary class and module class names. The intermediary class name can be set in the module directive.
    if (!imclass_name) {
      imclass_name = NewStringf("%sJNI", Getattr(n,"name"));
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
    imclass_directors = NewString("");
    upcasts_code = NewString("");
    dmethods_seq = NewList();
    dmethods_table = NewHash();
    n_dmethods = 0;
    n_directors = 0;
    if (!package) package = NewString("");
    jnipackage = NewString("");
    package_path = NewString("");

    Swig_banner(f_runtime);               // Print the SWIG banner message

    if (directorsEnabled()) {
      Printf(f_runtime,"#define SWIG_DIRECTORS\n");

      /* Emit initial director header and director code: */
      Swig_banner(f_directors_h);
      Printf(f_directors_h, "#ifndef SWIG_%s_WRAP_H_\n", module_class_name);
      Printf(f_directors_h, "#define SWIG_%s_WRAP_H_\n\n", module_class_name);

      Printf(f_directors, "\n\n");
      Printf(f_directors, "/* ---------------------------------------------------\n");
      Printf(f_directors, " * C++ director class methods\n");
      Printf(f_directors, " * --------------------------------------------------- */\n\n");
      Printf(f_directors, "#include \"%s\"\n\n", Swig_file_filename(outfile_h));
    }

    String *wrapper_name = NewString("");

    if(Len(package)) {
      String *jniname = makeValidJniName(package);
      Printv(jnipackage, jniname, NIL);
      Delete(jniname);
      Replaceall(jnipackage,".","_");
      Append(jnipackage, "_");
      Printv(package_path, package, NIL);
      Replaceall(package_path, ".", "/");
    }
    String *jniname = makeValidJniName(imclass_name);
    Printf(wrapper_name, "Java_%s%s_%%f", Char(jnipackage), jniname);
    Delete(jniname);

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

    if (directorsEnabled()) {
      // Insert director runtime into the f_runtime file (make it occur before %header section)
      Swig_insert_file("director.swg", f_runtime);
    }

    // Generate the intermediary class
    {
      String *filen = NewStringf("%s%s.java", SWIG_output_directory(), imclass_name);
      File *f_im = NewFile(filen,"w");
      if(!f_im) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the intermediary class file
      emitBanner(f_im);

      if(Len(package) > 0)
        Printf(f_im, "package %s;\n", package);

      if(imclass_imports)
        Printf(f_im, "%s\n", imclass_imports);

      if (Len(imclass_class_modifiers) > 0)
        Printf(f_im, "%s ", imclass_class_modifiers);
      Printf(f_im, "%s ", imclass_name);

      if (imclass_baseclass && *Char(imclass_baseclass))
        Printf(f_im, "extends %s ", imclass_baseclass);
      if (Len(imclass_interfaces) > 0)
        Printv(f_im, "implements ", imclass_interfaces, " ", NIL);
      Printf(f_im, "{\n");

      // Add the intermediary class methods
      Replaceall(imclass_class_code, "$module", module_class_name);
      Printv(f_im, imclass_class_code, NIL);
      Printv(f_im, imclass_cppcasts_code, NIL);
      if (Len(imclass_directors) > 0) {
        Printf(f_im, "\n/* Director upcall methods: */\n\n");
        Printv(f_im, imclass_directors, NIL);
      }

      if (n_dmethods > 0) {
        Putc('\n', f_im);
        Printf(f_im, "  private final static native void swig_module_init();\n");
        Printf(f_im, "  static {\n");
        Printf(f_im, "    swig_module_init();\n");
        Printf(f_im, "  }\n");
      }

      // Finish off the class
      Printf(f_im, "}\n");
      Close(f_im);
    }

    // Generate the Java module class
    {
      String *filen = NewStringf("%s%s.java", SWIG_output_directory(), module_class_name);
      File *f_module = NewFile(filen,"w");
      if(!f_module) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the module class file
      emitBanner(f_module);

      if(Len(package) > 0)
        Printf(f_module, "package %s;\n", package);

      if(module_imports)
        Printf(f_module, "%s\n", module_imports);

      if (Len(module_class_modifiers) > 0)
        Printf(f_module, "%s ", module_class_modifiers);
      Printf(f_module, "%s ", module_class_name);

      if (module_baseclass && *Char(module_baseclass))
        Printf(f_module, "extends %s ", module_baseclass);
      if (Len(module_interfaces) > 0) {
        if (Len(module_class_constants_code) != 0 )
          Printv(f_module, "implements ", Getattr(n, "name"), "Constants, ", module_interfaces, " ", NIL);
        else
          Printv(f_module, "implements ", module_interfaces, " ", NIL);
      } else {
        if (Len(module_class_constants_code) != 0 )
          Printv(f_module, "implements ", Getattr(n, "name"), "Constants ", NIL);
      }
      Printf(f_module, "{\n");

      Replaceall(module_class_code, "$module", module_class_name);
      Replaceall(module_class_constants_code, "$module", module_class_name);

      // Add the wrapper methods
      Printv(f_module, module_class_code, NIL);

      // Finish off the class
      Printf(f_module, "}\n");
      Close(f_module);
    }

    // Generate the Java constants interface
    if (Len(module_class_constants_code) != 0 ) {
      String *filen = NewStringf("%s%sConstants.java", SWIG_output_directory(), module_class_name);
      File *f_module = NewFile(filen,"w");
      if(!f_module) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the Java constants interface file
      emitBanner(f_module);

      if(Len(package) > 0)
        Printf(f_module, "package %s;\n", package);

      if(module_imports)
        Printf(f_module, "%s\n", module_imports);

      Printf(f_module, "public interface %sConstants {\n", module_class_name);

      // Write out all the global constants
      Printv(f_module, module_class_constants_code, NIL);

      // Finish off the Java interface
      Printf(f_module, "}\n");
      Close(f_module);
    }

    if(upcasts_code)
      Printv(f_wrappers,upcasts_code,NIL);

    emitDirectorUpcalls();

    Printf(f_wrappers,"#ifdef __cplusplus\n");
    Printf(f_wrappers,"}\n");
    Printf(f_wrappers,"#endif\n");

    // Output a Java type wrapper class for each SWIG type
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
    Delete(imclass_directors); imclass_directors = NULL;
    Delete(upcasts_code); upcasts_code = NULL;
    Delete(package); package = NULL;
    Delete(jnipackage); jnipackage = NULL;
    Delete(package_path); package_path = NULL;
    Delete(dmethods_seq); dmethods_seq = NULL;
    Delete(dmethods_table); dmethods_table = NULL;
    n_dmethods = 0;

    /* Close all of the files */
    Dump(f_header,f_runtime);

    if (directorsEnabled()) {
      Dump(f_directors, f_runtime);
      Dump(f_directors_h, f_runtime_h);

      Printf(f_runtime_h, "\n");
      Printf(f_runtime_h, "#endif\n");

      Close(f_runtime_h);
      Delete(f_runtime_h); f_runtime_h = NULL;
      Delete(f_directors); f_directors = NULL;
      Delete(f_directors_h); f_directors_h = NULL;
    }

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

  /*-----------------------------------------------------------------------
   * Add new director upcall signature
   *----------------------------------------------------------------------*/

  UpcallData * addUpcallMethod(String *imclass_method, String *class_method, String *imclass_desc, String *class_desc, String *decl) {
    UpcallData         *udata;
    String             *imclass_methodidx;
    String             *class_methodidx;
    Hash               *new_udata;
    String             *key = NewStringf("%s|%s", imclass_method, decl);
    
    /* Do we know about this director class already? */
    if ((udata = Getattr(dmethods_table, key)) != NULL) {
      Delete(key);
      return Getattr(udata, "methodoff");
    }

    imclass_methodidx = NewStringf("%d", n_dmethods);
    class_methodidx = NewStringf("%d", n_dmethods - first_class_dmethod);
    n_dmethods++;

    new_udata = NewHash();
    Append(dmethods_seq, new_udata);
    Setattr(dmethods_table, key, new_udata);

    Setattr(new_udata, "method", Copy(class_method));
    Setattr(new_udata, "fdesc", Copy(class_desc));
    Setattr(new_udata, "imclass_method", Copy(imclass_method));
    Setattr(new_udata, "imclass_fdesc", Copy(imclass_desc));
    Setattr(new_udata, "imclass_methodidx", imclass_methodidx);
    Setattr(new_udata, "class_methodidx", class_methodidx);
    Setattr(new_udata, "decl", Copy(decl));

    Delete(key);
    return new_udata;
  }

  /*-----------------------------------------------------------------------
   * Get director upcall signature
   *----------------------------------------------------------------------*/

  UpcallData * getUpcallMethodData(String *director_class, String *decl) {
    String             *key = NewStringf("%s|%s", director_class, decl);
    UpcallData         *udata = Getattr(dmethods_table, key);

    Delete(key);
    return udata;
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
    int       num_arguments = 0;
    int       num_required = 0;
    int       gencomma = 0;
    bool      is_void_return;
    String    *overloaded_name = getOverloadedName(n);
    String    *nondir_args = NewString("");

    if (!Getattr(n,"sym:overloaded")) {
      if (!addSymbol(Getattr(n,"sym:name"),n)) return SWIG_ERROR;
    }

    /*
       The rest of this function deals with generating the intermediary class wrapper function (that wraps
       a c/c++ function) and generating the JNI c code. Each Java wrapper function has a 
       matching JNI c function call.
       */

    // A new wrapper function object
    Wrapper *f = NewWrapper();

    // Make a wrapper name for this function
    String *jniname = makeValidJniName(overloaded_name);
    String *wname = Swig_name_wrapper(jniname);

    Delete(jniname);

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("jni", l, f);
    Swig_typemap_attach_parms("jtype", l, f);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("jni",n,"",0))) {
      Printf(c_return_type,"%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
          "No jni typemap defined for %s\n", SwigType_str(t,0));
    }

    if ((tm = Swig_typemap_lookup_new("jtype",n,"",0))) {
      Printf(im_return_type,"%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
          "No jtype typemap defined for %s\n", SwigType_str(t,0));
    }

    is_void_return = (Cmp(c_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f,"jresult", c_return_type, "jresult = 0",NIL);

    Printv(f->def, "JNIEXPORT ", c_return_type, " JNICALL ", wname, "(JNIEnv *jenv, jclass jcls", NIL);

    // Usually these function parameters are unused - The code below ensures
    // that compilers do not issue such a warning if configured to do so.

    Printv(f->code,"    (void)jenv;\n",NIL);
    Printv(f->code,"    (void)jcls;\n",NIL);

    // Emit all of the local variables for holding arguments.
    emit_args(t,l,f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);

    // Parameter overloading
    Setattr(n,"wrap:parms",l);
    Setattr(n,"wrap:name", wname);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Java
    if (Getattr(n,"sym:overloaded")) {
      // Emit warnings for the few cases that can't be overloaded in Java and give up on generating wrapper
        Swig_overload_check(n);
        if (Getattr(n, "overload:ignore"))
          return SWIG_OK;
    }

    Printf(imclass_class_code, "  public final static native %s %s(", im_return_type, overloaded_name);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);

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

      /* Get the JNI C types of the parameter */
      if ((tm = Getattr(p,"tmap:jni"))) {
        Printv(c_param_type, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
            "No jni typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Get the intermediary class parameter types of the parameter */
      if ((tm = Getattr(p,"tmap:jtype"))) {
        Printv(im_param_type, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
            "No jtype typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Add parameter to intermediary class method */
      if(gencomma) Printf(imclass_class_code, ", ");
      Printf(imclass_class_code, "%s %s", im_param_type, arg);

      // Add parameter to C function
      Printv(f->def, ", ", c_param_type, " ", arg, NIL);
      
      ++gencomma;

      // Get typemap for this argument
      if ((tm = Getattr(p,"tmap:in"))) {
        addThrows(n, "tmap:in", p);
        Replaceall(tm,"$source",arg); /* deprecated */
        Replaceall(tm,"$target",ln); /* deprecated */
        Replaceall(tm,"$arg",arg); /* deprecated? */
        Replaceall(tm,"$input", arg);
        Setattr(p,"emit:input", arg);

        Printf(nondir_args,"%s\n", tm);

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

    Printv(f->code, nondir_args, NIL);
    Delete(nondir_args);

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

    // Get any Java exception classes in the throws typemap
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
    if(!native_function_flag) {
      emit_action(n,f);
      // Handle exception classes specified in the "except" feature's "throws" attribute
      addThrows(n, "feature:except", n);
    }

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
        addThrows(n, "tmap:newfree", n);
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* See if there is any return cleanup code */
    if(!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
        addThrows(n, "tmap:ret", n);
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* Finish C function and intermediary class function definitions */
    Printf(imclass_class_code, ")");
    generateThrowsClause(n, imclass_class_code);
    Printf(imclass_class_code, ";\n");

    Printf(f->def,") {");

    if(!is_void_return)
      Printv(f->code, "    return jresult;\n", NIL);
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code,"$cleanup",cleanup);

    /* Contract macro modification */
    Replaceall(f->code, "SWIG_contract_assert(", "SWIG_contract_assert($null, ");

    /* Exception macro modification */
    Replaceall(f->code, "SWIG_exception(", "SWIG_exception($null, ");

    if(!is_void_return)
      Replaceall(f->code,"$null","0");
    else
      Replaceall(f->code,"$null","");

    /* Dump the function out */
    if(!native_function_flag)
      Wrapper_print(f,f_wrappers);

    if(!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
      moduleClassFunctionHandler(n);
    }

    /* 
     * Generate the proxy class getters/setters for public member variables.
     * Not for enums and constants.
     */
    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Capitalize the first letter in the variable to create a JavaBean type getter/setter function name
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
    variable_wrapper_flag = true;
    Language::variableWrapper(n);           /* Default to functions */
    variable_wrapper_flag = false;
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {

    variable_name = Getattr(n,"sym:name");
    global_variable_flag = true;
    int ret = Language::globalvariableHandler(n);
    global_variable_flag = false;
    return ret;
  }

  /* ----------------------------------------------------------------------
   * enumDeclaration()
   *
   * C/C++ enums can be mapped in one of 4 ways, depending on the java:enum feature specified:
   * 1) Simple enums - simple constant within the proxy class or module class
   * 2) Typeunsafe enums - simple constant in a Java class (class named after the c++ enum name)
   * 3) Typesafe enum - typesafe enum pattern (class named after the c++ enum name)
   * 4) Proper enums - proper Java enum
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
        // Wrap (non-anonymous) C/C++ enum within a typesafe, typeunsafe or proper Java enum

        // Pure Java baseclass and interfaces
        const String *pure_baseclass = typemapLookup("javabase", typemap_lookup_type, WARN_NONE);
        const String *pure_interfaces = typemapLookup("javainterfaces", typemap_lookup_type, WARN_NONE);

        // Emit the enum
        Printv(enum_code,
            typemapLookup("javaclassmodifiers", typemap_lookup_type, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers (enum modifiers really)
            " ",
            symname,
            *Char(pure_baseclass) ? // Bases
            " extends " : 
            "",
            pure_baseclass,
            *Char(pure_interfaces) ?  // Interfaces
            " implements " :
            "",
            pure_interfaces,
            " {\n",
            NIL);
        if (proxy_flag && is_wrapping_class())
          Replaceall(enum_code, "$static ", "static ");
        else
          Replaceall(enum_code, "$static ", "");
      } else {
        // Wrap C++ enum with integers - just indicate start of enum with a comment, no comment for anonymous enums of any sort
        if (symname && !Getattr(n,"unnamedinstance"))
          Printf(constants_code, "  // %s \n", symname);
      }

      // Emit each enum item
      Language::enumDeclaration(n);

      if ((enum_feature != SimpleEnum) && symname && typemap_lookup_type) {
        // Wrap (non-anonymous) C/C++ enum within a typesafe, typeunsafe or proper Java enum
        // Finish the enum declaration
        // Typemaps are used to generate the enum definition in a similar manner to proxy classes.
        Printv(enum_code,
            (enum_feature == ProperEnum) ? 
            ";\n" :
            "",
            typemapLookup("javabody", typemap_lookup_type, WARN_JAVA_TYPEMAP_JAVABODY_UNDEF), // main body of class
            typemapLookup("javacode", typemap_lookup_type, WARN_NONE), // extra Java code
            "}\n",
            "\n",
            NIL);

        Replaceall(enum_code, "$javaclassname", symname);

        // Substitute $enumvalues - intended usage is for typesafe enums
        if (Getattr(n,"enumvalues"))
          Replaceall(enum_code, "$enumvalues", Getattr(n,"enumvalues"));
        else
          Replaceall(enum_code, "$enumvalues", "");

        if (proxy_flag && is_wrapping_class()) {
          // Enums defined within the C++ class are defined within the proxy class

          // Add extra indentation
          Replaceall(enum_code, "\n  ", "\n    ");
          Replaceall(enum_code, "\n}\n", "\n  }\n");

          Printv(proxy_class_constants_code, "  ", enum_code, NIL);
        } else {
          // Global enums are defined in their own file
          String *filen = NewStringf("%s%s.java", SWIG_output_directory(), symname);
          File *f_enum = NewFile(filen,"w");
          if(!f_enum) {
            Printf(stderr,"Unable to open %s\n", filen);
            SWIG_exit(EXIT_FAILURE);
          } 
          Delete(filen); filen = NULL;

          // Start writing out the enum file
          emitBanner(f_enum);

          if(Len(package) > 0)
            Printf(f_enum, "package %s;\n", package);

          Printv(f_enum,
              typemapLookup("javaimports", typemap_lookup_type, WARN_NONE), // Import statements
              "\n",
              enum_code,
              NIL);

          Printf(f_enum, "\n");
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
        // Wrap (non-anonymous) C/C++ enum with a proper Java enum
        // Emit the enum item.
        if (!Getattr(n,"_last")) // Only the first enum item has this attribute set
          Printf(enum_code, ",\n");
        Printf(enum_code, "  %s", symname);
        if (Getattr(n,"enumvalue")) {
          String *value = enumValue(n);
          Printf(enum_code, "(%s)", value);
          Delete(value);
        }
      } else {
        // Wrap C/C++ enums with constant integers or use the typesafe enum pattern
        const String *parent_name = Getattr(parentNode(n),"name");
        String *typemap_lookup_type = parent_name ? Copy(parent_name) : NewString("int");
        const String *tm = typemapLookup("jstype", typemap_lookup_type, WARN_JAVA_TYPEMAP_JSTYPE_UNDEF);
        String *return_type = Copy(tm);
        Delete(typemap_lookup_type); typemap_lookup_type = NULL;

        if ((enum_feature == TypesafeEnum) && Getattr(parentNode(n),"sym:name") && !Getattr(parentNode(n),"unnamedinstance")) {
          // Wrap (non-anonymouse) enum using the typesafe enum pattern
          if (Getattr(n,"enumvalue")) {
            String *value = enumValue(n);
            Printf(enum_code, "  public final static %s %s = new %s(\"%s\", %s);\n", return_type, symname, return_type, symname, value);
            Delete(value);
          } else {
            Printf(enum_code, "  public final static %s %s = new %s(\"%s\");\n", return_type, symname, return_type, symname);
          }
        } else {
          // Simple integer constants
          // Note these are always generated for anonymous enums, no matter what enum_feature is specified
          // Code generated is the same for SimpleEnum and TypeunsafeEnum -> the class it is generated into is determined later
          String *value = enumValue(n);
          Printf(enum_code, "  public final static %s %s = %s;\n", return_type, symname, value);
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
   * Java static final variables are generated for these.
   * If the %javaconst(1) feature is used then the C constant value is used to initialise the Java final variable.
   * If not, a JNI method is generated to get the C constant value for initialisation of the Java final variable.
   * However, if the %javaconstvalue feature is used, it overrides all other ways to generate the initialisation.
   * Also note that this method might be called for wrapping enum items (when the enum is using %javaconst(0)).
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

    // The %javaconst feature determines how the constant value is obtained
    String *const_feature = Getattr(n,"feature:java:const");
    bool const_feature_flag = const_feature && Cmp(const_feature, "0") != 0;

    /* Adjust the enum type for the Swig_typemap_lookup.
     * We want the same jstype typemap for all the enum items so we use the enum type (parent node). */
    if (is_enum_item) {
      t = Getattr(parentNode(n),"enumtype");
      Setattr(n,"type", t);
    }

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("jstype", l, NULL);

    /* Get Java return types */
    bool classname_substituted_flag = false;
    
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      classname_substituted_flag = substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
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

    const String *itemname = (proxy_flag && wrapping_member_flag) ? variable_name : symname;
    Printf(constants_code, "  public final static %s %s = ", return_type, itemname);

    // Check for the %javaconstvalue feature
    String *value = Getattr(n,"feature:java:constvalue");

    if (value) {
      Printf(constants_code, "%s;\n", value);
    } else if (!const_feature_flag) {
      // Default enum and constant handling will work with any type of C constant and initialises the Java variable from C through a JNI call.

      if(classname_substituted_flag) {
        if (SwigType_isenum(t)) {
          // This handles wrapping of inline initialised const enum static member variables (not when wrapping enum items - ignored later on)
          Printf(constants_code, "%s.swigToEnum(%s.%s());\n", return_type, imclass_name, Swig_name_get(symname));
        } else {
          // This handles function pointers using the %constant directive
          Printf(constants_code, "new %s(%s.%s(), false);\n", return_type, imclass_name, Swig_name_get(symname));
        }
      } else
        Printf(constants_code, "%s.%s();\n", imclass_name, Swig_name_get(symname));

      // Each constant and enum value is wrapped with a separate JNI function call
      enum_constant_flag = true;
      variableWrapper(n);
      enum_constant_flag = false;
    } else {
      // Alternative constant handling will use the C syntax to make a true Java constant and hope that it compiles as Java code
      Printf(constants_code, "%s;\n", Getattr(n,"value"));
    }

    // Emit the generated code to appropriate place
    // Enums only emit the intermediate and JNI methods, so no proxy or module class wrapper methods needed
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
    return Language::insertDirective(n);
  }

  /* -----------------------------------------------------------------------------
   * pragmaDirective()
   *
   * Valid Pragmas:
   * jniclassbase            - base (extends) for the intermediary class
   * jniclassclassmodifiers  - class modifiers for the intermediary class
   * jniclasscode            - text (java code) is copied verbatim to the intermediary class
   * jniclassimports         - import statements for the intermediary class
   * jniclassinterfaces      - interface (implements) for the intermediary class
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
          Delete(imclass_baseclass);
          imclass_baseclass = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclassclassmodifiers") == 0) {
          Delete(imclass_class_modifiers);
          imclass_class_modifiers = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclasscode") == 0) {
          Printf(imclass_class_code, "%s\n", strvalue);
        } 
        else if(Strcmp(code, "jniclassimports") == 0) {
          Delete(imclass_imports);
          imclass_imports = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclassinterfaces") == 0) {
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
   * emitProxyClassDefAndCPPCasts()
   * ----------------------------------------------------------------------------- */

  void emitProxyClassDefAndCPPCasts(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n,"name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;
    String *typemap_lookup_type = Getattr(n,"classtypeobj");
    bool    feature_director = Swig_directorclass(n);

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
        Swig_warning(WARN_JAVA_MULTIPLE_INHERITANCE, input_file, line_number, 
            "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in Java.\n", typemap_lookup_type, Getattr(base.item,"name"));
      }
    }

    bool derived = baseclass && getProxyName(c_baseclassname);
    if (!baseclass)
      baseclass = NewString("");

    // Inheritance from pure Java classes
    const String *pure_baseclass = typemapLookup("javabase", typemap_lookup_type, WARN_NONE);
    if (Len(pure_baseclass) > 0 && Len(baseclass) > 0) {
      Swig_warning(WARN_JAVA_MULTIPLE_INHERITANCE, input_file, line_number, 
          "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in Java.\n", typemap_lookup_type, pure_baseclass);
      pure_baseclass = empty_string;
    }

    // Pure Java interfaces
    const String *pure_interfaces = typemapLookup("javainterfaces", typemap_lookup_type, WARN_NONE);

    // Start writing the proxy class
    Printv(proxy_class_def,
        typemapLookup("javaimports", typemap_lookup_type, WARN_NONE), // Import statements
        "\n",
        typemapLookup("javaclassmodifiers", typemap_lookup_type, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " $javaclassname",       // Class name and bases
        (derived || *Char(pure_baseclass)) ?
        " extends " : 
        "",
        baseclass, // Note only one of these base classes should ever be set as multiple inheritance is not permissible
        pure_baseclass,
        *Char(pure_interfaces) ?  // Pure Java interfaces
        " implements " :
        "",
        pure_interfaces,
        " {",
        derived ?
        typemapLookup("javabody_derived", typemap_lookup_type, WARN_JAVA_TYPEMAP_JAVABODY_UNDEF) : // main body of class
        typemapLookup("javabody", typemap_lookup_type, WARN_JAVA_TYPEMAP_JAVABODY_UNDEF), // main body of class
        NIL);

    // C++ destructor is wrapped by the delete method
    // Note that the method name is specified in a typemap attribute called methodname
    String *destruct = NewString("");
    const String *tm = NULL;
    Node *attributes = NewHash();
    String *destruct_methodname = NULL;
    if (derived) {
      tm = typemapLookup("javadestruct_derived", typemap_lookup_type, WARN_NONE, attributes);
      destruct_methodname = Getattr(attributes, "tmap:javadestruct_derived:methodname");
    } else {
      tm = typemapLookup("javadestruct", typemap_lookup_type, WARN_NONE, attributes);
      destruct_methodname = Getattr(attributes, "tmap:javadestruct:methodname");
    }
    if (!destruct_methodname) {
      Swig_error(input_file, line_number, 
          "No methodname attribute defined in javadestruct%s typemap for %s\n", (derived ? "_derived" : ""), proxy_class_name);
    }

    // Emit the finalize and delete methods
    if (tm) {
      // Finalize method
      if (*Char(destructor_call)) {
        Printv(proxy_class_def, 
            typemapLookup("javafinalize", typemap_lookup_type, WARN_NONE),
            NIL);
      }
      // delete method
      Printv(destruct, tm, NIL);
      if (*Char(destructor_call))
        Replaceall(destruct, "$jnicall", destructor_call);
      else
        Replaceall(destruct, "$jnicall", "throw new UnsupportedOperationException(\"C++ destructor does not have public access\")");
      if (*Char(destruct))
        Printv(proxy_class_def, "\n  ", "public void ", destruct_methodname, "() ", destruct, "\n", NIL);
    }

    /* Insert declaration for directordisconnect/directordisconnect_derived typemap, if this class has directors enabled */
    if (feature_director) {
      const String *disconn_tm = NULL;
      Node *disconn_attr = NewHash();
      String *disconn_methodname = NULL;

      if (derived) {
        disconn_tm = typemapLookup("directordisconnect_derived", typemap_lookup_type, WARN_NONE, disconn_attr);
        disconn_methodname = Getattr(disconn_attr, "tmap:directordisconnect_derived:methodname");
      } else {
        disconn_tm = typemapLookup("directordisconnect", typemap_lookup_type, WARN_NONE, disconn_attr);
        disconn_methodname = Getattr(disconn_attr, "tmap:directordisconnect:methodname");
      }

      if (*Char(disconn_tm)) {
        if (disconn_methodname != NULL) {
          String *disconn_call = Copy(disconn_tm);
          String *disconn_destruct = Copy(destruct_methodname);
          Append(disconn_destruct, "()");
          Replaceall(disconn_call, "$jnicall", disconn_destruct);
          Printv(proxy_class_def,
                 "\n",
                 "  protected void ", disconn_methodname, "() ",
                 disconn_call,
                 "\n",
                 NIL);
          Delete(disconn_call);
          Delete(disconn_destruct);
        } else {
          Swig_error(input_file, line_number,
              "No directordisconnect%s method name for %s\n", (derived ? "_derived" : ""), proxy_class_name);
        }
      } else {
        Swig_error(input_file, line_number,
            "No directordisconnect%s typemap for %s\n", (derived ? "_derived" : ""), proxy_class_name);
      }

      Delete(disconn_attr);
    }

    Delete(attributes);
    Delete(destruct);

    // Emit extra user code
    Printv(proxy_class_def, 
        typemapLookup("javacode", typemap_lookup_type, WARN_NONE), // extra Java code
        "\n",
        NIL);

    // Substitute various strings into the above template
    Replaceall(proxy_class_code, "$javaclassname", proxy_class_name);
    Replaceall(proxy_class_def,  "$javaclassname", proxy_class_name);

    Replaceall(proxy_class_def,  "$module", module_class_name);
    Replaceall(proxy_class_code, "$module", module_class_name);

    // Add code to do C++ casting to base class (only for classes in an inheritance hierarchy)
    if(derived){
      Printv(imclass_cppcasts_code,"  public final static native long SWIG$javaclassnameUpcast(long jarg1);\n", NIL);

      Replaceall(imclass_cppcasts_code, "$javaclassname", proxy_class_name);

      Printv(upcasts_code,
          "JNIEXPORT jlong JNICALL Java_$jnipackage$imimclass_SWIG$imclazznameUpcast",
          "(JNIEnv *jenv, jclass jcls, jlong jarg1) {\n",
          "    jlong baseptr = 0;\n"
          "    (void)jenv;\n"
          "    (void)jcls;\n"
          "    *($cbaseclass **)&baseptr = *($cclass **)&jarg1;\n"
          "    return baseptr;\n"
          "}\n",
          "\n",
          NIL); 

      String *imimclass  = makeValidJniName(imclass_name);
      String *imclazzname = makeValidJniName(proxy_class_name);
      Replaceall(upcasts_code, "$cbaseclass",  c_baseclass);
      Replaceall(upcasts_code, "$imclazzname", imclazzname);
      Replaceall(upcasts_code, "$cclass",      c_classname);
      Replaceall(upcasts_code, "$jnipackage",  jnipackage);
      Replaceall(upcasts_code, "$imimclass",   imimclass);

      Delete(imclazzname);
      Delete(imimclass);
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

      String *filen = NewStringf("%s%s.java", SWIG_output_directory(), proxy_class_name);
      f_proxy = NewFile(filen,"w");
      if(!f_proxy) {
        Printf(stderr, "Unable to create proxy class file: %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the proxy class file
      emitBanner(f_proxy);

      if(Len(package) > 0)
        Printf(f_proxy, "package %s;\n", package);

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
      Printv(f_proxy, proxy_class_def, proxy_class_code, NIL);

      // Write out all the constants
      if (Len(proxy_class_constants_code) != 0 )
        Printv(f_proxy, proxy_class_constants_code, NIL);

      Printf(f_proxy, "}\n");
      Close(f_proxy);
      f_proxy = NULL;

      /* Output the downcast method, if necessary. Note: There's no other really
         good place to put this code, since Abstract Base Classes (ABCs) can and should have 
         downcasts, making the constructorHandler() a bad place (because ABCs don't get to
         have constructors emitted.) */
      if (Getattr(n, "feature:javadowncast")) {
        String *jni_imclass_name = makeValidJniName(imclass_name);
        String *jni_class_name = makeValidJniName(proxy_class_name);
        String *norm_name = SwigType_namestr(Getattr(n, "name"));

        Printf(imclass_class_code, "  public final static native %s downcast%s(long cPtrBase, boolean cMemoryOwn);\n",
               proxy_class_name, proxy_class_name);

        Wrapper *dcast_wrap = NewWrapper();

        Printf(dcast_wrap->def, "JNIEXPORT jobject JNICALL Java_%s%s_downcast%s(JNIEnv *jenv, jclass jcls, jlong jCPtrBase, jboolean cMemoryOwn) {",
               jnipackage, jni_imclass_name, jni_class_name);
        Printf(dcast_wrap->code, "  Swig::Director *director = (Swig::Director *) 0;\n");
        Printf(dcast_wrap->code, "  jobject jresult = (jobject) 0;\n");
        Printf(dcast_wrap->code, "  %s *obj = *((%s **) &jCPtrBase);\n", norm_name, norm_name);
        Printf(dcast_wrap->code, "  if (obj) director = dynamic_cast<Swig::Director *>(obj);\n");
        Printf(dcast_wrap->code, "  if (director) jresult = director->swig_get_self(jenv);\n");
        Printf(dcast_wrap->code, "  return jresult;\n");
        Printf(dcast_wrap->code, "}\n");

        Wrapper_print(dcast_wrap, f_wrappers);
        DelWrapper(dcast_wrap);
      }

      emitDirectorExtraMethods(n);

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
    member_func_flag = true;
    Language::memberfunctionHandler(n);

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *intermediary_function_name = Swig_name_member(proxy_class_name, overloaded_name);
      Setattr(n,"proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n,"imfuncname", intermediary_function_name);
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    member_func_flag = false;
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
      String *overloaded_name = getOverloadedName(n);
      String *intermediary_function_name = Swig_name_member(proxy_class_name, overloaded_name);
      Setattr(n,"proxyfuncname", Getattr(n,"sym:name"));
      Setattr(n,"imfuncname", intermediary_function_name);
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
   * Function called for creating a Java wrapper function around a c++ function in the 
   * proxy class. Used for both static and non-static C++ class functions.
   * C++ class static functions map to Java static functions.
   * Two extra attributes in the Node must be available. These are "proxyfuncname" - 
   * the name of the Java class proxy function, which in turn will call "imfuncname" - 
   * the intermediary (JNI) function name in the intermediary class.
   * ----------------------------------------------------------------------------- */

  void proxyClassFunctionHandler(Node *n) {
    SwigType  *t = Getattr(n,"type"); 
    ParmList  *l = Getattr(n,"parms");
    String    *intermediary_function_name = Getattr(n,"imfuncname");
    String    *proxy_function_name = Getattr(n,"proxyfuncname");
    String    *tm;
    Parm      *p;
    int       i;
    String    *imcall = NewString("");
    String    *return_type = NewString("");
    String    *function_code = NewString("");
    bool      setter_flag = false;

    if(!proxy_flag) return;

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Java
    if (Getattr(n, "overload:ignore")) return;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("jstype", l, NULL);
    Swig_typemap_attach_parms("javain", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      // Note that in the case of polymorphic (covariant) return types, the method's return type is changed to be the base of the C++ return type
      SwigType *virtualtype = Getattr(n,"virtual:type");
      substituteClassname(virtualtype ? virtualtype : t, tm);
      Printf(return_type, "%s", tm);
      if (virtualtype)
        Swig_warning(WARN_JAVA_COVARIANT_RET, input_file, line_number, 
          "Covariant return types not supported in Java. Proxy method will return %s.\n", SwigType_str(virtualtype,0));
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // For wrapping member variables (Javabean setter)
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(Swig_name_member(proxy_class_name, variable_name))) == 0);
    }

    /* Start generating the proxy function */
    const String *methodmods = Getattr(n,"feature:java:methodmodifiers");
    methodmods = methodmods ? methodmods : (!is_public(n) ? protected_string : public_string);
    Printf(function_code, "  %s ", methodmods);
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
      if (!(variable_wrapper_flag && i==0) || static_flag)
      {
        SwigType *pt = Getattr(p,"type");
        String   *param_type = NewString("");

        /* Get the Java parameter type */
        if ((tm = Getattr(p,"tmap:jstype"))) {
          substituteClassname(pt, tm);
          Printf(param_type, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
              "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(imcall, ", ");

        String *arg = makeParameterName(n, p, i, setter_flag);

        // Use typemaps to transform type used in Java proxy wrapper (in proxy class) to type used in JNI function (in intermediary class)
        if ((tm = Getattr(p,"tmap:javain"))) {
          addThrows(n, "tmap:javain", p);
          substituteClassname(pt, tm);
          Replaceall(tm, "$javainput", arg);
          Printv(imcall, tm, NIL);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
              "No javain typemap defined for %s\n", SwigType_str(pt,0));
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

    // Transform return type used in JNI function (in intermediary class) to type used in Java wrapper function (in proxy class)
    if ((tm = Swig_typemap_lookup_new("javaout",n,"",0))) {
      addThrows(n, "tmap:javaout", n);
      if (Getattr(n,"feature:new"))
        Replaceall(tm,"$owner","true");
      else
        Replaceall(tm,"$owner","false");
      substituteClassname(t, tm);
      Replaceall(tm, "$jnicall", imcall);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
          "No javaout typemap defined for %s\n", SwigType_str(t,0));
    }

    generateThrowsClause(n, function_code);
    Printf(function_code, " %s\n\n", tm ? (const String *)tm : empty_string);
    Printv(proxy_class_code, function_code, NIL);

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
    bool      feature_director = (parentNode(n) && Swig_directorclass(n));

    Language::constructorHandler(n);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Java
    if (Getattr(n, "overload:ignore"))
      return SWIG_OK;

    if(proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *mangled_overname = Swig_name_construct(overloaded_name);
      String *imcall = NewString("");

      const String *methodmods = Getattr(n,"feature:java:methodmodifiers");
      methodmods = methodmods ? methodmods : (!is_public(n) ? protected_string : public_string);
      Printf(function_code, "  %s %s(", methodmods, proxy_class_name);
      Printv(imcall, imclass_name, ".", mangled_overname, "(", NIL);

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
        String   *param_type = NewString("");

        /* Get the Java parameter type */
        if ((tm = Getattr(p,"tmap:jstype"))) {
          substituteClassname(pt, tm);
          Printf(param_type, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
              "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(imcall, ", ");

        String *arg = makeParameterName(n, p, i, false);

        // Use typemaps to transform type used in Java wrapper function (in proxy class) to type used in JNI function (in intermediary class)
        if ((tm = Getattr(p,"tmap:javain"))) {
          addThrows(n, "tmap:javain", p);
          substituteClassname(pt, tm);
          Replaceall(tm, "$javainput", arg);
          Printv(imcall, tm, NIL);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
              "No javain typemap defined for %s\n", SwigType_str(pt,0));
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
      generateThrowsClause(n, function_code);
      if (feature_director) {
        Printv(function_code, " ", typemapLookup("javaconstruct_director", Getattr(n,"name"), WARN_JAVA_TYPEMAP_JAVACONSTRUCT_UNDEF), NIL);
      } else {
        Printv(function_code, " ", typemapLookup("javaconstruct", Getattr(n,"name"), WARN_JAVA_TYPEMAP_JAVACONSTRUCT_UNDEF), NIL);
      }
      Printf(function_code, "\n");
      Replaceall(function_code, "$imcall", imcall);

      Printv(proxy_class_code, function_code, "\n", NIL);

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
    variable_name = Getattr(n,"sym:name");
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
    variable_name = Getattr(n,"sym:name");
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

    /* Although JNI functions are designed to handle overloaded Java functions,
     * a Java long is used for all classes in the SWIG intermediary class.
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
    Swig_typemap_attach_parms("jstype", l, NULL);
    Swig_typemap_attach_parms("javain", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
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
    const String *methodmods = Getattr(n,"feature:java:methodmodifiers");
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

      /* Get the Java parameter type */
      if ((tm = Getattr(p,"tmap:jstype"))) {
        substituteClassname(pt, tm);
        Printf(param_type, "%s", tm);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
            "No jstype typemap defined for %s\n", SwigType_str(pt,0));
      }

      if (gencomma)
        Printf(imcall, ", ");

      String *arg = makeParameterName(n, p, i, setter_flag);

      // Use typemaps to transform type used in Java wrapper function (in proxy class) to type used in JNI function (in intermediary class)
      if ((tm = Getattr(p,"tmap:javain"))) {
        addThrows(n, "tmap:javain", p);
        substituteClassname(pt, tm);
        Replaceall(tm, "$javainput", arg);
        Printv(imcall, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
            "No javain typemap defined for %s\n", SwigType_str(pt,0));
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

    // Transform return type used in JNI function (in intermediary class) to type used in Java wrapper function (in module class)
    if ((tm = Swig_typemap_lookup_new("javaout",n,"",0))) {
      addThrows(n, "tmap:javaout", n);
      if (Getattr(n,"feature:new"))
        Replaceall(tm,"$owner","true");
      else
        Replaceall(tm,"$owner","false");
      substituteClassname(t, tm);
      Replaceall(tm, "$jnicall", imcall);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
          "No javaout typemap defined for %s\n", SwigType_str(t,0));
    }

    generateThrowsClause(n, function_code);
    Printf(function_code, " %s\n\n", tm ? (const String *)tm : empty_string);
    Printv(module_class_code, function_code, NIL);

    Delete(function_code);
    Delete(return_type);
    Delete(imcall);
    Delete(func_name);
  }

  /*----------------------------------------------------------------------
   * decodeEnumFeature()
   * Decode the possible enum features, which are one of:
   *   %javaenum(simple)
   *   %javaenum(typeunsafe) - default
   *   %javaenum(typesafe)
   *   %javaenum(proper)
   *--------------------------------------------------------------------*/

  EnumFeature decodeEnumFeature(Node *n) {
      EnumFeature enum_feature = TypeunsafeEnum;
      String *feature = Getattr(n,"feature:java:enum");
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
   * This method will return a string with an enum value to use in Java generated
   * code. If the %javaconst feature is not used, the string will contain the intermediary
   * class call to obtain the enum value. The intermediary class and JNI methods to obtain
   * the enum value will be generated. Otherwise the C/C++ enum value will be used if there
   * is one and hopefully it will compile as Java code - e.g. 20 as in: enum E{e=20};
   * The %javaconstvalue feature overrides all other ways to generate the constant value.
   * The caller must delete memory allocated for the returned string.
   * ------------------------------------------------------------------------ */

  String *enumValue(Node *n) {
    String *symname = Getattr(n,"sym:name");

    // Check for the %javaconstvalue feature
    String *value = Getattr(n,"feature:java:constvalue");

    if (!value) {
      // The %javaconst feature determines how the constant value is obtained
      String *const_feature = Getattr(n,"feature:java:const");
      bool const_feature_flag = const_feature && Cmp(const_feature, "0") != 0;

      if (const_feature_flag) {
        // Use the C syntax to make a true Java constant and hope that it compiles as Java code
        value = Getattr(n,"enumvalue") ? Copy(Getattr(n,"enumvalue")) : Copy(Getattr(n,"enumvalueex"));
      } else {
        // Get the enumvalue from a JNI call
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
   *
   * If jnidescriptor is set, inner class names are separated with '$' otherwise a '.'
   * ----------------------------------------------------------------------------- */

  String *getEnumName(SwigType *t, bool jnidescriptor) {
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
        if (proxyname) {
          const char *class_separator = jnidescriptor ? "$" : ".";
          enum_name = NewStringf("%s%s%s", proxyname, class_separator, symname);
        } else {
          enum_name = NewStringf("%s", symname);
        }
        Delete(scopename_prefix);
      }
    }

    return enum_name;
  }

  /* -----------------------------------------------------------------------------
   * substituteClassname()
   *
   * Substitute $javaclassname with the proxy class name for classes/structs/unions that SWIG knows about.
   * Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the Java class name. Note that the $&javaclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - jstype typemap
   *   jnidescriptor - if set, inner class names are separated with '$' otherwise a '.'
   * Outputs:
   *   tm - jstype typemap with $javaclassname substitution
   * Return:
   *   substitution_performed - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteClassname(SwigType *pt, String *tm, bool jnidescriptor = false) {
    bool substitution_performed = false;
    SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$javaclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteClassnameSpecialVariable(classnametype, tm, "$javaclassname", jnidescriptor);
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$*javaclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      substituteClassnameSpecialVariable(classnametype, tm, "$*javaclassname", jnidescriptor);
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$&javaclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteClassnameSpecialVariable(classnametype, tm, "$&javaclassname", jnidescriptor);
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

  void substituteClassnameSpecialVariable(SwigType *classnametype, String *tm, const char *classnamespecialvariable, bool jnidescriptor) {
    if (SwigType_isenum(classnametype)) {
      String *enumname = getEnumName(classnametype, jnidescriptor);
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
      // Note that for setters the parameter name is always set but sometimes includes C++ 
      // scope resolution, so we need to strip off the scope resolution to make a valid name.
      arg = NewString("value"); //Swig_scopename_last(pn);
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
    String *filen = NewStringf("%s%s.java", SWIG_output_directory(), classname);
    File *f_swigtype = NewFile(filen,"w");
    if(!f_swigtype) {
      Printf(stderr,"Unable to open %s\n", filen);
      SWIG_exit(EXIT_FAILURE);
    } 
    Delete(filen); filen = NULL;

    // Start writing out the type wrapper class file
    emitBanner(f_swigtype);

    if(Len(package) > 0)
      Printf(f_swigtype, "package %s;\n", package);

    // Pure Java baseclass and interfaces
    const String *pure_baseclass = typemapLookup("javabase", type, WARN_NONE);
    const String *pure_interfaces = typemapLookup("javainterfaces", type, WARN_NONE);

    // Emit the class
    Printv(swigtype,
        typemapLookup("javaimports", type, WARN_NONE), // Import statements
        "\n",
        typemapLookup("javaclassmodifiers", type, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " $javaclassname",       // Class name and bases
        *Char(pure_baseclass) ?
        " extends " : 
        "",
        pure_baseclass,
        *Char(pure_interfaces) ?  // Interfaces
        " implements " :
        "",
        pure_interfaces,
        " {",
        typemapLookup("javabody", type, WARN_JAVA_TYPEMAP_JAVABODY_UNDEF), // main body of class
        typemapLookup("javacode", type, WARN_NONE), // extra Java code
        "}\n",
        "\n",
        NIL);

    Replaceall(swigtype, "$javaclassname", classname);
    Replaceall(swigtype, "$module", module_class_name);
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
   * addThrows()
   *
   * Adds exception classes to a throws list. The throws list is the list of classes
   * that will form the Java throws clause. Mainly for checked exceptions.
   * ----------------------------------------------------------------------------- */

  void addThrows(Node *n, const String *attribute, Node *parameter) {
    // Get the comma separated exception classes for the throws clause - held in typemap/feature's "throws" attribute
    String *throws_attribute = NewStringf("%s:throws", attribute);
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
        for (Iterator cls = First(temp_classes_list); cls.item; cls = Next(cls)) {
          String *exception_class = NewString(cls.item);
          Replaceall(exception_class," ","");  // remove spaces
          Replaceall(exception_class,"\t",""); // remove tabs
          if (Len(exception_class) > 0) {
            // $javaclassname substitution
            SwigType *pt = Getattr(parameter,"type");
            substituteClassname(pt, exception_class);

            // Don't duplicate the Java exception class in the throws clause
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
    List *throws_list = Getattr(n,"java:throwslist");
    if (throws_list) {
      Iterator cls = First(throws_list);
      Printf(code, " throws %s", cls.item);
      while ( (cls = Next(cls)).item)
        Printf(code, ", %s", cls.item);
    }
  }

  /*----------------------------------------------------------------------
   * getUpcallJNIMethod()
   *--------------------------------------------------------------------*/

  String * getUpcallJNIMethod(String *descrip) {
    static struct {
      char      code;
      const char *method;
    } upcall_methods[] = {
      { 'B', "CallStaticByteMethod" },
      { 'C', "CallStaticCharMethod" },
      { 'D', "CallStaticDoubleMethod" },
      { 'F', "CallStaticFloatMethod" },
      { 'I', "CallStaticIntMethod" },
      { 'J', "CallStaticLongMethod" },
      { 'L', "CallStaticObjectMethod" },
      { 'S', "CallStaticShortMethod" },
      { 'V', "CallStaticVoidMethod" },
      { 'Z', "CallStaticBooleanMethod" },
      { '[', "CallStaticObjectMethod" }
    };

    char code;
    int i;

    code = *Char(descrip);
    for (i = 0; i < (int) (sizeof(upcall_methods)/sizeof(upcall_methods[0])); ++i)
      if (code == upcall_methods[i].code)
        return NewString(upcall_methods[i].method);
    return NULL;
  }

  /*----------------------------------------------------------------------
   * emitDirectorUpcalls()
   *--------------------------------------------------------------------*/

  void emitDirectorUpcalls() {
    if (n_dmethods) {
      Wrapper          *w = NewWrapper();
      String           *jni_imclass_name = makeValidJniName(imclass_name);
      String           *swig_module_init = NewString("swig_module_init");
      String           *swig_module_init_jni = makeValidJniName(swig_module_init);
      String           *dmethod_data = NewString("");
      int               n_methods = 0;
      Iterator          udata_iter;

      udata_iter = First(dmethods_seq);
      while (udata_iter.item) {
        UpcallData     *udata = udata_iter.item;
        Printf(dmethod_data, "  { \"%s\", \"%s\" }", Getattr(udata, "imclass_method"), Getattr(udata, "imclass_fdesc"));
        ++n_methods;

        udata_iter = Next(udata_iter);

        if (udata_iter.item)
          Putc(',', dmethod_data);
        Putc('\n', dmethod_data);
      }

      Printf(f_runtime, "namespace Swig {\n");
      Printf(f_runtime, "  static jclass jclass_%s = NULL;\n", imclass_name);
      Printf(f_runtime, "  static jmethodID director_methids[%d];\n", n_methods);
      Printf(f_runtime, "}\n");

      Printf(w->def, "JNIEXPORT void JNICALL Java_%s%s_%s(JNIEnv *jenv, jclass jcls) {",
             jnipackage, jni_imclass_name, swig_module_init_jni);
      Printf(w->code, "static struct {\n");
      Printf(w->code, "  const char *method;\n");
      Printf(w->code, "  const char *signature;\n");
      Printf(w->code, "} methods[%d] = {\n", n_methods);
      Printv(w->code, dmethod_data, NIL);
      Printf(w->code, "};\n");

      Wrapper_add_local(w, "i", "int i");

      Printf(w->code, "Swig::jclass_%s = (jclass) jenv->NewGlobalRef(jcls);\n", imclass_name);
      Printf(w->code, "if (Swig::jclass_%s == NULL) return;\n", imclass_name);
      Printf(w->code, "for (i = 0; i < (int) (sizeof(methods)/sizeof(methods[0])); ++i) {\n");
      Printf(w->code, "  Swig::director_methids[i] = jenv->GetStaticMethodID(jcls, methods[i].method, methods[i].signature);\n");
      Printf(w->code, "  if (Swig::director_methids[i] == NULL) return;\n");
      Printf(w->code, "}\n");

      Printf(w->code, "}\n");

      Wrapper_print(w, f_wrappers);
      Delete(dmethod_data);
      Delete(swig_module_init_jni);
      Delete(swig_module_init);
      Delete(jni_imclass_name);
      DelWrapper(w);
    }
  }

  /*----------------------------------------------------------------------
   * emitDirectorExtraMethods()
   *
   * This is where the $javaclassname_director_connect is
   * generated.
   *--------------------------------------------------------------------*/
  void emitDirectorExtraMethods(Node *n)
  {
    if (Swig_directorclass(n)) {
      String *jni_imclass_name = makeValidJniName(imclass_name);
      String *norm_name = SwigType_namestr(Getattr(n, "name"));
      String *swig_director_connect = NewStringf("%s_director_connect", proxy_class_name);
      String  *swig_director_connect_jni = makeValidJniName(swig_director_connect);
      Wrapper *code_wrap;

      Printf(imclass_class_code, "  public final static native void %s(%s obj, long cptr, boolean mem_own, boolean weak_global);\n",
             swig_director_connect, proxy_class_name);

      code_wrap = NewWrapper();
      Printf(code_wrap->def,
             "JNIEXPORT void JNICALL Java_%s%s_%s(JNIEnv *jenv, jclass jcls, jobject jself, jlong objarg, jboolean jswig_mem_own, "
             "jboolean jweak_global) {\n",
             jnipackage, jni_imclass_name, swig_director_connect_jni);
      Printf(code_wrap->code, "  %s *obj = *((%s **) &objarg);\n", norm_name, norm_name);
      Printf(code_wrap->code, "  (void)jcls;\n");
      Printf(code_wrap->code, "  SwigDirector_%s *director = dynamic_cast<SwigDirector_%s *>(obj);\n",
             Getattr(n, "sym:name"), Getattr(n, "sym:name"));
      Printf(code_wrap->code, "  if (director) {\n");
      Printf(code_wrap->code, "    director->swig_connect_director(jenv, jself, jenv->GetObjectClass(jself), "
             "(jswig_mem_own == JNI_TRUE), (jweak_global == JNI_TRUE));\n");
      Printf(code_wrap->code, "  }\n");
      Printf(code_wrap->code, "}\n");

      Wrapper_print(code_wrap, f_wrappers);
      DelWrapper(code_wrap);

      Delete(swig_director_connect_jni);
      Delete(norm_name);
      Delete(jni_imclass_name);
      Delete(swig_director_connect);
    }
  }

  /* ---------------------------------------------------------------
   * Canonicalize the JNI field descriptor
   *
   * Replace the $javapackage and $javaclassname family of special
   * variables with the desired package and Java proxy name as 
   * required in the JNI field descriptors.
   * 
   * !!SFM!! If $packagepath occurs in the field descriptor, but
   * package_path isn't set (length == 0), then strip it and the
   * optional trailing '/' from the resulting name.
   * 
   * --------------------------------------------------------------- */

  String *canonicalizeJNIDescriptor(String *descriptor_in, Parm *p) {
    String *pkg_path = Swig_typemap_lookup_new("javapackage", p, "", 0);
    SwigType *type = Getattr(p,"type");

    if (pkg_path && Len(pkg_path) != 0) {
      Replaceall(pkg_path, ".", "/");
    } else
      pkg_path = package_path;

    String *descriptor_out = Copy(descriptor_in);

    if (Len(pkg_path) > 0) {
      Replaceall(descriptor_out, "$packagepath", pkg_path);
    } else {
      Replaceall(descriptor_out, "$packagepath/", empty_string);
      Replaceall(descriptor_out, "$packagepath", empty_string);
    }

    substituteClassname(type, descriptor_out, true);

    if (pkg_path != package_path)
      Delete(pkg_path);

    return descriptor_out;
  }

  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // (scottm) Class director mods:
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  /* ---------------------------------------------------------------
   * classDirectorMethod()
   *
   * Emit a virtual director method to pass a method call on to the 
   * underlying Java object.
   *
   * --------------------------------------------------------------- */

  int classDirectorMethod(Node *n, Node *parent, String *super) {
    String     *empty_str = NewString("");
    String     *classname = Getattr(parent, "sym:name");
    String     *name = Getattr(n, "name");
    String     *symname = Getattr(n, "sym:name");
    SwigType   *type = Getattr(n, "type");
    SwigType   *returntype = Getattr(n,"returntype");
    String     *c_classname = NULL;
    String     *overloaded_name = getOverloadedName(n);
    String     *storage = Getattr(n, "storage");
    String     *value = Getattr(n, "value");
    String     *decl = Getattr(n, "decl");
    String     *declaration = NewString("");
    String     *tm;
    Parm       *p;
    int         i;
    Wrapper    *w = NewWrapper();
    ParmList   *l = Getattr(n, "parms");
    bool        is_void = !(Cmp(returntype, "void"));
    String     *qualified_return = NewString("");
    bool        pure_virtual = (!(Cmp(storage, "virtual")) && !(Cmp(value, "0")));
    int         status = SWIG_OK;

    bool        output_director = true;
    String     *dirclassname = directorClassName(parent);
    String     *qualified_name = NewStringf("%s::%s", dirclassname, name);
    String     *jnidesc = NewString("");
    String     *classdesc = NewString("");
    String     *jniret_desc = NewString("");
    String     *classret_desc = NewString("");
    SwigType   *jniret_type = NULL;
    String     *jupcall_args = NewString("swig_get_self(jenv)");
    String     *imclass_dmethod;
    Wrapper    *imw = NewWrapper();
    String     *imcall_args = NewString("");
    int         gencomma = 0;
    int         classmeth_off = curr_class_dmethod - first_class_dmethod;


    // Kludge Alert: functionWrapper sets sym:overload properly, but it
    // isn't at this point, so we have to manufacture it ourselves. At least
    // we're consistent with the sym:overload name in functionWrapper. (?? when
    // does the overloaded method name get set?)

    imclass_dmethod = NewStringf("SwigDirector_%s", Swig_name_member(classname, overloaded_name));

    // Get the C++ name for the parent node (should be a class... hint)

    c_classname = Getattr(parent, "name");
    if (!(Cmp(type, "class")))
      c_classname = classname;

    if (returntype) {
      if (!is_void) {

        qualified_return = SwigType_rcaststr(returntype, "result");
        if (!SwigType_isclass(returntype)) {
          if (!(SwigType_ispointer(returntype) || SwigType_isreference(returntype))) {
            Wrapper_add_localv(w, "result", SwigType_lstr(returntype, "result"), NIL);
          } else {
            String *base_typename = SwigType_base(returntype);
            String *resolved_typename = SwigType_typedef_resolve_all(base_typename);
            Symtab *symtab = Getattr(n, "sym:symtab");
            Node *typenode = Swig_symbol_clookup(resolved_typename, symtab);

            if (SwigType_ispointer(returntype) || (typenode != NULL && Getattr(typenode, "abstract"))) {
              /* initialize pointers to something sane. Same for abstract
                 classes when a reference is returned. */
              Wrapper_add_localv(w, "result", SwigType_lstr(returntype, "result"), "= 0", NIL);
            } else {
              /* If returning a reference, initialize the pointer to a sane
                 default - if a Java exception occurs, then the pointer returns
                 something other than a NULL-initialized reference. */
              String *non_ref_type = Copy(returntype);

              /* Remove reference and const qualifiers */
              Replaceall(non_ref_type, "r.", "");
              Replaceall(non_ref_type, "q(const).", "");
              Wrapper_add_localv(w, "result_default", "static", SwigType_str(non_ref_type, "result_default"), 
                  "=", SwigType_str(non_ref_type, "()"), NIL);
              Wrapper_add_localv(w, "result", SwigType_lstr(returntype, "result"), "= &result_default", NIL);

              Delete(non_ref_type);
            }

            Delete(base_typename);
            Delete(resolved_typename);
          }
        } else {
          SwigType *vt;

          vt = cplus_value_type(returntype);
          if (vt == NULL) {
            Wrapper_add_localv(w, "result", SwigType_lstr(returntype, "result"), NIL);
          } else {
            Wrapper_add_localv(w, "result", SwigType_lstr(vt, "result"), NIL);
            Delete(vt);
          }
        }

        /* Create the intermediate class wrapper */
        Parm *tp = NewParmFromNode(returntype, empty_str, n);

        tm = Swig_typemap_lookup_new("jtype", tp, "", 0);
        if (tm != NULL) {
          Printf(imw->def, "public static %s %s(%s self", tm, imclass_dmethod, classname);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
              "No jtype typemap defined for %s\n", SwigType_str(returntype,0));
        }
      } else
        Printf(imw->def, "public static void %s(%s self", imclass_dmethod, classname);

      /* Get the JNI field descriptor for this return type, add the JNI field descriptor
         to jniret_desc */

      Parm  *retpm = NewParmFromNode(returntype, empty_str, n);
      
      if ((jniret_type = Swig_typemap_lookup_new("jni", retpm, "", 0)) != NULL) {
        String *jdesc;
        Parm *tp = NewParmFromNode(jniret_type, empty_str, n);

        if (!is_void) {
          String *jretval_decl = NewStringf("%s jresult", jniret_type);
          Wrapper_add_localv(w, "jresult", jretval_decl, " = 0", NIL);
          Delete(jretval_decl);
        }

        if ((tm = Swig_typemap_lookup_new("directorin", tp, "", 0)) != NULL
            && (jdesc = Getattr(tp, "tmap:directorin:descriptor")) != NULL) {
          String *jnidesc_canon;

          jnidesc_canon = canonicalizeJNIDescriptor(jdesc, tp);
          Append(jniret_desc, jnidesc_canon);
          Delete(jnidesc_canon);
        } else {
          Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file, line_number, 
                       "No or improper directorin typemap defined for %s\n", SwigType_str(jniret_type,0));
          output_director = false;
        }

        Delete(tp);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
                     "No jni typemap defined for %s\n", SwigType_str(returntype,0));
        output_director = false;
      }

      String *jdesc;

      SwigType *virtualtype = Getattr(n,"virtual:type");
      SwigType *adjustedreturntype = virtualtype ? virtualtype : returntype;
      Parm *adjustedreturntypeparm = NewParmFromNode(adjustedreturntype, empty_str, n);

      if ((tm = Swig_typemap_lookup_new("directorin", adjustedreturntypeparm, "", 0)) != NULL
          && (jdesc = Getattr(adjustedreturntypeparm, "tmap:directorin:descriptor")) != NULL) {
        String *jnidesc_canon;

        // Note that in the case of polymorphic (covariant) return types, the
        // method's return type is changed to be the base of the C++ return
        // type
        jnidesc_canon = canonicalizeJNIDescriptor(jdesc, adjustedreturntypeparm);
        Append(classret_desc, jnidesc_canon);
        Delete(jnidesc_canon);
      } else {
        Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file, line_number, 
                     "No or improper directorin typemap defined for %s\n", SwigType_str(jniret_type,0));
        output_director = false;
      }

      Delete(adjustedreturntypeparm);
      Delete(retpm);
    }

    /* Go through argument list, attach lnames for arguments */
    for (i = 0, p=l; p; p = nextSibling(p), ++i) {
      String *arg = Getattr(p, "name");
      String *lname = NewString("");

      if (arg == NULL && Cmp(Getattr(p, "type"), "void")) {
        lname = NewStringf("arg%d", i);
        Setattr(p, "name", lname);
      } else
        lname = arg;

      Setattr(p, "lname", lname);
    }

    /* Attach the standard typemaps */
    Swig_typemap_attach_parms("out", l, w);
    Swig_typemap_attach_parms("jni", l, w);
    Swig_typemap_attach_parms("jtype", l, w);
    Swig_typemap_attach_parms("directorin", l, 0);
    Swig_typemap_attach_parms("javadirectorin", l, 0);

    /* Add Java environment pointer to wrapper */
    String *jenvstr = NewString("jenv");

    Wrapper_add_localv(w, jenvstr, "JNIEnv *", jenvstr, "= (JNIEnv *) NULL", NIL);
    Delete(jenvstr);

    /* Preamble code */

    Printf(w->code, "if (!swig_override[%d]) {\n", classmeth_off);

    if (!pure_virtual) {
      if (is_void) {
        Printf(w->code, "%s;\n", Swig_method_call(super,l));
        Printf(w->code, "return;\n");
      } else {
        String *super_call = Swig_method_call(super, l);
        Printf(w->code, "return %s;\n", super_call);
        Delete(super_call);
      }
    } else {
      Printf(w->code, "SWIG_JavaThrowException(jenv, SWIG_JavaDirectorPureVirtual,\n");
      Printf(w->code, "      \"Attempted to invoke pure virtual method %s::%s.\");\n",
             c_classname, name);

      /* Make sure that we return something in the case of a pure
       * virtual method call for syntactical reasons. */
      if (!is_void)
        Printf(w->code, "return %s;", qualified_return);
      else
        Printf(w->code, "return;\n");
    }

    Printf(w->code, "}\n");
    Printf(w->code, "jenv = swig_acquire_jenv();\n");

    /* Start the Java field descriptor for the intermediate class's upcall (insert self object) */
    Parm *tp = NewParmFromNode(c_classname, empty_str, n);
    String *jdesc;

    if ((tm = Swig_typemap_lookup_new("directorin", tp, "", 0)) != NULL
        && (jdesc = Getattr(tp, "tmap:directorin:descriptor")) != NULL) {
      String *jni_canon;
        
      jni_canon = canonicalizeJNIDescriptor(jdesc, tp);
      Append(jnidesc, jni_canon);
      Delete(jni_canon);
      Delete(tm);
    } else {
      Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file, line_number, 
                   "No or improper directorin typemap defined for %s\n", SwigType_str(classname, 0));
      output_director = false;
    }

    Delete(tp);

    /* Go through argument list, convert from native to Java */
    for (p=l; p != NULL; /* empty */) {
      /* Is this superfluous? */
      while (checkAttribute(p,"tmap:directorin:numinputs","0")) {
        p = Getattr(p,"tmap:directorin:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *ln = Copy(Getattr(p,"name"));
      String   *c_param_type = NULL;
      String   *c_decl = NewString("");
      String   *arg = NewString("");

      Printf(arg, "j%s", ln);

      /* Add various typemap's 'throws' clauses */
      addThrows(n, "tmap:directorin", p);
      addThrows(n, "tmap:out", p);

      /* And add to the upcall args */
      Printf(jupcall_args, ", %s", arg);

      /* Get parameter's JNI C type */
      if ((c_param_type = Getattr(p, "tmap:jni")) != NULL) {
        Parm *tp = NewParmFromNode(c_param_type, empty_str, n);
        String *desc_tm = NULL, *jdesc = NULL, *cdesc = NULL;

        /* Add to local variables */
        Printf(c_decl, "%s %s", c_param_type, arg);
        Wrapper_add_localv(w, arg, c_decl, (!(SwigType_ispointer(pt) || SwigType_isreference(pt)) ? "" : "= 0"), NIL);

        /* Add input marshalling code and update JNI field descriptor */
        if ((desc_tm = Swig_typemap_lookup_new("directorin", tp, "", 0)) != NULL
            && (jdesc = Getattr(tp, "tmap:directorin:descriptor")) != NULL
            && (tm = Getattr(p, "tmap:directorin")) != NULL
            && (cdesc = Getattr(p, "tmap:directorin:descriptor")) != NULL) {
          String *jni_canon;
        
          jni_canon = canonicalizeJNIDescriptor(jdesc, tp);
          Append(jnidesc, jni_canon);
          Delete(jni_canon);

          Replaceall(tm,"$input", arg);

          if (Len(tm))
            Printf(w->code,"%s\n", tm);

          Delete(tm);

          /* Add parameter to the intermediate class code if generating the
           * intermediate's upcall code */
          if ((tm = Getattr(p, "tmap:jtype")) != NULL) {
            String   *din;
            
            din = Copy(Getattr(p, "tmap:javadirectorin"));

            if (din != NULL) {
              Replaceall(din, "$module", module_class_name);
              substituteClassname(pt, din);
              Replaceall(din, "$jniinput", ln);

              Printf(imw->def, ", %s %s", tm, ln);
              if (++gencomma > 1)
                Printf(imcall_args, ", ");

              if (Cmp(din, ln)) {
                Printv(imcall_args, din, NIL);
              } else
                Printv(imcall_args, ln, NIL);

              jni_canon = canonicalizeJNIDescriptor(cdesc, p);
              Append(classdesc, jni_canon);
              Delete(jni_canon);
            } else {
              Swig_warning(WARN_JAVA_TYPEMAP_JAVADIRECTORIN_UNDEF, input_file, line_number, 
                           "No javadirectorin typemap defined for %s\n", SwigType_str(pt,0));
              output_director = false;
            }
          } else {
            Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
                "No jtype typemap defined for %s\n", SwigType_str(pt,0));
            output_director = false;
          }

          p = Getattr(p, "tmap:directorin:next");

          Delete(desc_tm);
        } else {
          if (desc_tm == NULL) {
            Swig_warning(WARN_JAVA_TYPEMAP_JAVADIRECTORIN_UNDEF, input_file, line_number, 
                         "No or improper directorin typemap defined for %s\n", SwigType_str(c_param_type, 0));
            p = nextSibling(p);
          } else if (jdesc == NULL) {
            Swig_warning(WARN_JAVA_TYPEMAP_DIRECTORIN_NODESC, input_file, line_number, 
                         "Missing JNI descriptor in directorin typemap defined for %s\n",
                         SwigType_str(c_param_type, 0));
            p = Getattr(p, "tmap:directorin:next");
          } else if (tm == NULL) {
            Swig_warning(WARN_JAVA_TYPEMAP_JAVADIRECTORIN_UNDEF, input_file, line_number, 
                         "No or improper directorin typemap defined for argument %s\n", SwigType_str(pt, 0));
            p = nextSibling(p);
          } else if (cdesc == NULL) {
            Swig_warning(WARN_JAVA_TYPEMAP_DIRECTORIN_NODESC, input_file, line_number, 
                         "Missing JNI descriptor in directorin typemap defined for %s\n", SwigType_str(pt, 0));
            p = Getattr(p, "tmap:directorin:next");
          }

          output_director = false;
        }

        Delete(tp);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
            "No jni typemap defined for %s\n", SwigType_str(pt,0));
        output_director = false;
        p = nextSibling(p);
      }

      Delete(arg);
      Delete(c_decl);
      Delete(c_param_type);
    }

    /* header declaration, start wrapper definition */
    String *target;

    target = Swig_method_decl(decl, qualified_name, l, 0, 0);
    String *rtype = SwigType_str(type, 0);

    Printf(w->def, "%s %s", rtype, target);
    Delete(qualified_name);
    Delete(target);

    target = Swig_method_decl(decl, name, l, 0, 1);
    Printf(declaration, "    virtual %s %s", rtype, target);
    Delete(rtype);
    Delete(target);

    // Get any Java exception classes in the throws typemap
    ParmList *throw_parm_list = NULL;

    if ((tm = Swig_typemap_lookup_new("out",n,"",0)))
      addThrows(n, "tmap:out", n);

    if ((throw_parm_list = Getattr(n,"throws")) || Getattr(n,"throw")) {
      int       gencomma = 0;

      Append(w->def, " throw(");
      Append(declaration, " throw(");

      if (throw_parm_list) Swig_typemap_attach_parms("throws", throw_parm_list, 0);
      for (p = throw_parm_list; p; p=nextSibling(p)) {
        if ((tm = Getattr(p,"tmap:throws"))) {
          addThrows(n, "tmap:throws", p);

          if (gencomma++) {
            Append(w->def, ", ");
            Append(declaration, ", ");
          }

          Printf(w->def, "%s", SwigType_str(Getattr(p, "type"),0));
          Printf(declaration, "%s", SwigType_str(Getattr(p, "type"),0));
        }
      }

      Append(w->def, ")");
      Append(declaration, ")");
    }

    Append(w->def, " {");
    Append(declaration, ";\n");

    /* Finish off the inherited upcall's definition */

    Putc(')', imw->def);
    generateThrowsClause(n, imw->def);
    Printf(imw->def, " {");
    
    /* Emit the intermediate class's upcall to the actual class */

    String *upcall = NewStringf("self.%s(%s)", symname, imcall_args);

    if (!is_void) {
      Parm *tp = NewParmFromNode(returntype, empty_str, n);

      tm = Swig_typemap_lookup_new("javadirectorout", tp, "", 0);
      if (tm != NULL) {
        substituteClassname(returntype, tm);
        Replaceall(tm, "$javacall", upcall);

        Printf(imw->code, "return %s;\n", tm);
      }

      Delete(tm);
      Delete(tp);
    } else
      Printf(imw->code, "%s;", upcall);

    Printf(imw->code, " }");
    Delete(upcall);

    /* Emit the actual upcall through JNI */
    String *imclass_desc = NewStringf("(%s)%s", jnidesc, jniret_desc);
    String *class_desc = NewStringf("(%s)%s", classdesc, classret_desc);
    UpcallData *udata = addUpcallMethod(imclass_dmethod, symname, imclass_desc, class_desc, decl);
    String *methid = Getattr(udata, "imclass_methodidx");
    String *methop = getUpcallJNIMethod(jniret_desc);

    if (!is_void) {
      Printf(w->code, "jresult = (%s) jenv->%s(Swig::jclass_%s, Swig::director_methids[%s], %s);\n",
             jniret_type, methop, imclass_name, methid, jupcall_args);
    } else {
      Printf(w->code, "jenv->%s(Swig::jclass_%s, Swig::director_methids[%s], %s);\n",
             methop, imclass_name, methid, jupcall_args);
    }

    Printf(w->code, "if (jenv->ExceptionOccurred()) return $null;\n");

    if (!is_void) {
      String *jresult_str = NewString("jresult");
      String *result_str = NewString("result");
      Parm *tp = NewParmFromNode(returntype, result_str, n);

      /* Copy jresult into result... */
      if ((tm = Swig_typemap_lookup_new("directorout", tp, result_str, w))) {
        addThrows(n, "tmap:directorout", tp);
        Replaceall(tm,"$source", jresult_str); /* deprecated */
        Replaceall(tm,"$target", result_str); /* deprecated */
        Replaceall(tm,"$arg", jresult_str); /* deprecated? */
        Replaceall(tm,"$input", jresult_str);
        Printf(w->code, "%s\n", tm);
      } else {
        Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number, 
		     "Unable to use return type %s in director method %s::%s (skipping method).\n", SwigType_str(tp, 0), classname, name);
        output_director = false;
      }

      Delete(tp);
      Delete(jresult_str);
      Delete(result_str);
    }

    Delete(imclass_desc);
    Delete(class_desc);

    /* Terminate wrapper code */
    if (!is_void)
      Printf(w->code, "return %s;", qualified_return);

    Printf(w->code, "}");

    /* emit code */
    if (status == SWIG_OK && output_director) {
      if(!is_void) {
        Replaceall(w->code,"$null", qualified_return);
      } else {
        Replaceall(w->code,"$null","");
      }
      Wrapper_print(imw, imclass_directors);
      if (!Getattr(n,"defaultargs")) {
        Wrapper_print(w, f_directors);
        Printv(f_directors_h, declaration, NIL);
      }
    }

    Delete(qualified_return);
    Delete(jnidesc);
    Delete(jniret_type);
    Delete(jniret_desc);
    Delete(declaration);
    DelWrapper(w);

    ++curr_class_dmethod;
    return status;
  }

  /* ------------------------------------------------------------
   * directorPrefixArgs()
   * ------------------------------------------------------------ */

  void directorPrefixArgs(Node *n) {
    Parm     *p;

    /* Need to prepend 'jenv' to the director constructor's argument list */

    String   *jenv_type = NewString("JNIEnv");

    SwigType_add_pointer(jenv_type);

    p = NewParmFromNode(jenv_type, NewString("jenv"), n);
    Setattr(p, "arg:byname", "1");
    set_nextSibling(p, NULL);

    Setattr(n, "director:prefix_args", p);
  }

  /* ------------------------------------------------------------
   * classDirectorConstructor()
   * ------------------------------------------------------------ */

  int classDirectorConstructor(Node *n) {
    Node *parent = parentNode(n);
    String *decl = Getattr(n, "decl");;
    String *supername = Swig_class_name(parent);
    String *classname = directorClassName(parent);
    String *sub = NewString("");
    Parm *p;
    ParmList *superparms = Getattr(n, "parms");
    ParmList *parms;
    int argidx = 0;

    /* Assign arguments to superclass's parameters, if not already done */
    for (p = superparms; p; p = nextSibling(p)) {
      String   *pname = Getattr(p, "name");

      if (pname == NULL) {
        pname = NewStringf("arg%d", argidx++);
        Setattr(p, "name", pname);
      }
    }

    /* insert jenv prefix argument */
    parms = CopyParmList(superparms);

    String   *jenv_type = NewString("JNIEnv");
    SwigType_add_pointer(jenv_type);
    p = NewParmFromNode(jenv_type, NewString("jenv"), n);
    set_nextSibling(p, parms);
    parms = p;

    directorPrefixArgs(n);

    if (!Getattr(n,"defaultargs")) {
      /* constructor */
      {
        String *basetype = Getattr(parent, "classtype");
        String *target = Swig_method_decl(decl, classname, parms, 0, 0);
        String *call = Swig_csuperclass_call(0, basetype, superparms);
        String *classtype = SwigType_namestr(Getattr(n, "name"));
        String *dirclass_type = SwigType_namestr(Getattr(n, "sym:name"));

        Printf(f_directors, "%s::%s: %s, %s {\n", classname, target, call, Getattr(parent, "director:ctor"));
        Printf(f_directors, "}\n\n");

        Delete(dirclass_type);
        Delete(classtype);
        Delete(target);
        Delete(call);
      }

      /* constructor header */
      {
        String *target = Swig_method_decl(decl, classname, parms, 0, 1);
        Printf(f_directors_h, "    %s;\n", target);
        Delete(target);
      }
    }

    Delete(sub);
    Delete(supername);
    Delete(jenv_type);
    Delete(parms);
    return Language::classDirectorConstructor(n);
  }

  /* ------------------------------------------------------------
   * classDirectorDefaultConstructor()
   * ------------------------------------------------------------ */
   
  int classDirectorDefaultConstructor(Node *n) {
    String *classname = Swig_class_name(n);
    String *classtype = SwigType_namestr(Getattr(n, "name"));
    String *dirclass_type = SwigType_namestr(Getattr(n, "sym:name"));
    Wrapper *w = NewWrapper();

    Printf(w->def, "SwigDirector_%s::SwigDirector_%s(JNIEnv *jenv) : %s {",
           classname, classname, Getattr(n, "director:ctor"));
    Printf(w->code, "}\n");
    Wrapper_print(w, f_directors);

    Printf(f_directors_h, "    SwigDirector_%s(JNIEnv *jenv);\n", classname);
    DelWrapper(w);
    Delete(dirclass_type);
    Delete(classtype);
    Delete(classname);
    directorPrefixArgs(n);
    return Language::classDirectorDefaultConstructor(n);
  }


  /* ------------------------------------------------------------
   * classDirectorInit()
   * ------------------------------------------------------------ */

  int classDirectorInit(Node *n) {
    Delete(none_comparison);
    none_comparison = NewString("");            // not used

    Delete(director_ctor_code);
    director_ctor_code = NewString("$director_new");

    Java_director_declaration(n);

    Printf(f_directors_h, "%s {\n", Getattr(n, "director:decl"));
    Printf(f_directors_h, "\npublic:\n");
    Printf(f_directors_h, "    void swig_connect_director(JNIEnv *jenv, jobject jself, jclass jcls, bool swig_mem_own, bool weak_global);\n");

    /* Keep track of the director methods for this class */
    first_class_dmethod = curr_class_dmethod = n_dmethods;
   
    return Language::classDirectorInit(n);
  }

  /* ----------------------------------------------------------------------
   * classDirectorDestructor()
   * ---------------------------------------------------------------------- */

  int classDirectorDestructor(Node *n) {
    Node *current_class = getCurrentClass();
    String *full_classname = Getattr(current_class, "name");
    String *classname= Swig_class_name(current_class);
    Wrapper *w = NewWrapper();

    if (Getattr(n,"throw")) {
      Printf(f_directors_h, "    virtual ~SwigDirector_%s() throw ();\n", classname);
      Printf(w->def, "SwigDirector_%s::~SwigDirector_%s() throw () {\n", classname, classname);
    } else {
      Printf(f_directors_h, "    virtual ~SwigDirector_%s();\n", classname);
      Printf(w->def, "SwigDirector_%s::~SwigDirector_%s() {\n", classname, classname);
    }

    /* Ensure that correct directordisconnect/_derived typemap's method name is called
     * here: */

    const String *disconn_tm = NULL;
    Node *disconn_attr = NewHash();
    String *disconn_methodname = NULL;

    if (Getattr(current_class, "bases") != NULL) {
      disconn_tm = typemapLookup("directordisconnect_derived", full_classname, WARN_NONE, disconn_attr);
      disconn_methodname = Getattr(disconn_attr, "tmap:directordisconnect_derived:methodname");
    } else {
      disconn_tm = typemapLookup("directordisconnect", full_classname, WARN_NONE, disconn_attr);
      disconn_methodname = Getattr(disconn_attr, "tmap:directordisconnect:methodname");
    }

    Printv(w->code,
           "  swig_disconnect_director_self(\"", disconn_methodname, "\");\n",
           "}\n",
           NIL);

    Wrapper_print(w, f_directors);

    DelWrapper(w);
    Delete(disconn_attr);
    Delete(classname);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classDirectorEnd()
   * ------------------------------------------------------------ */

  int classDirectorEnd(Node *n) {
    String *classname = Getattr(n, "sym:name");
    String *director_classname = directorClassName(n);
    String *internal_classname;

    Wrapper *w = NewWrapper();

    if (Len(package_path) > 0)
      internal_classname = NewStringf("%s/%s", package_path, classname);
    else
      internal_classname = NewStringf("%s", classname);

    Wrapper_add_localv(w, "baseclass", "static jclass baseclass", " = 0", NIL);
    Printf(w->def, "void %s::swig_connect_director(JNIEnv *jenv, jobject jself, jclass jcls, bool swig_mem_own, bool weak_global) {", director_classname);

    if (first_class_dmethod != curr_class_dmethod) {
      Printf(w->def, "static struct {\n");
      Printf(w->def, "const char *mname;\n");
      Printf(w->def, "const char *mdesc;\n");
      Printf(w->def, "jmethodID base_methid;\n");
      Printf(w->def, "} methods[] = {\n");

      for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
        UpcallData       *udata = Getitem(dmethods_seq, i);

        Printf(w->def, "{ \"%s\", \"%s\", NULL }", Getattr(udata, "method"), Getattr(udata, "fdesc"));
        if (i != curr_class_dmethod - 1)
          Putc(',', w->def);
        Putc('\n', w->def);
      }

      Printf(w->def, "};\n");
    }

    Printf(w->code, "if (swig_set_self(jenv, jself, swig_mem_own, weak_global)) {\n");
    Printf(w->code, "if (baseclass == NULL) {\n");
    Printf(w->code, "baseclass = jenv->FindClass(\"%s\");\n", internal_classname);
    Printf(w->code, "if (baseclass == NULL) return;\n");
    Printf(w->code, "baseclass = (jclass) jenv->NewGlobalRef(baseclass);\n");
    Printf(w->code, "}\n");
    Printf(w->code, "bool derived = (jenv->IsSameObject(baseclass, jcls) ? false : true);\n");

    int n_methods = curr_class_dmethod - first_class_dmethod;

    if (n_methods) {
      /* Emit the swig_overrides() method and the swig_override array */
      Printf(f_directors_h, "public:\n");
      Printf(f_directors_h, "    bool swig_overrides(int n) {\n");
      Printf(f_directors_h, "      return (n < %d ? swig_override[n] : false);\n", n_methods);
      Printf(f_directors_h, "    }\n");
      Printf(f_directors_h, "protected:\n");
      Printf(f_directors_h, "    bool swig_override[%d];\n", n_methods);

      /* Emit the code to look up the class's methods, initialize the override array */

      Printf(w->code, "for (int i = 0; i < %d; ++i) {\n", n_methods);
      Printf(w->code, "  if (methods[i].base_methid == NULL) {\n");
      Printf(w->code, "    methods[i].base_methid = jenv->GetMethodID(baseclass, methods[i].mname, methods[i].mdesc);\n");
      Printf(w->code, "    if (methods[i].base_methid == NULL) return;\n");
      Printf(w->code, "  }\n");
      Printf(w->code, "  swig_override[i] = false;\n");
      Printf(w->code, "  if (derived) {\n");
      Printf(w->code, "    jmethodID methid = jenv->GetMethodID(jcls, methods[i].mname, methods[i].mdesc);\n");
      Printf(w->code, "    swig_override[i] = (methid != methods[i].base_methid);\n");
      Printf(w->code, "    jenv->ExceptionClear();\n");
      Printf(w->code, "  }\n");
      Printf(w->code, "}\n");
    } else {
      Printf(f_directors_h, "public:\n");
      Printf(f_directors_h, "    bool swig_overrides(int n) {\n");
      Printf(f_directors_h, "      return false;\n");
      Printf(f_directors_h, "    }\n");
    }

    Printf(f_directors_h, "};\n\n");
    Printf(w->code, "}\n");
    Printf(w->code, "}\n");

    Wrapper_print(w, f_directors);

    DelWrapper(w);
    Delete(internal_classname);

    return Language::classDirectorEnd(n);
  }

  /* --------------------------------------------------------------------
   * classDirectorDisown()
   * ------------------------------------------------------------------*/
  virtual int classDirectorDisown(Node *n) {
    (void)n;
    return SWIG_OK;
  }
    
  /* --------------------------------------------------------------------
   * Java_director_declaration()
   *
   * Generate the director class's declaration
   * e.g. "class SwigDirector_myclass : public myclass, public Swig::Director {"
   * ------------------------------------------------------------------*/

  void Java_director_declaration(Node *n) {
    String *base = Getattr(n, "classtype");
    String *class_ctor = NewString("Swig::Director(jenv)");

    String* classname = Swig_class_name(n);
    String *directorname = NewStringf("SwigDirector_%s", classname);
    String *declaration = Swig_class_declaration(n, directorname);

    Printf(declaration, " : public %s, public Swig::Director", base);

    // Stash stuff for later.
    Setattr(n, "director:decl", declaration);
    Setattr(n, "director:ctor", class_ctor);
  }

};   /* class JAVA */

/* -----------------------------------------------------------------------------
 * swig_java()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language * new_swig_java() {
  return new JAVA();
}
extern "C" Language * swig_java(void) {
  return new_swig_java();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *JAVA::usage = (char*)"\
Java Options (available with -java)\n\
     -package <name> - set name of the Java package to <name>\n\
     -noproxy        - Generate the low-level functional interface instead\n\
                       of proxy classes\n\
\n";

