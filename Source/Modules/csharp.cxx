/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * csharp.cxx
 *
 * C# language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_csharp_cxx[] = "$Id$";

#include "swigmod.h"
#include <limits.h>		// for INT_MAX
#include "cparse.h"
#include <ctype.h>

/* Hash type used for upcalls from C/C++ */
typedef DOH UpcallData;

class CSHARP:public Language {
  static const char *usage;
  const String *empty_string;
  const String *public_string;
  const String *protected_string;

  Hash *swig_types_hash;
  File *f_runtime;
  File *f_runtime_h;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  File *f_directors;
  File *f_directors_h;
  List *filenames_list;

  bool proxy_flag;		// Flag for generating proxy classes
  bool native_function_flag;	// Flag for when wrapping a native function
  bool enum_constant_flag;	// Flag for when wrapping an enum or constant
  bool static_flag;		// Flag for when wrapping a static functions or member variables
  bool variable_wrapper_flag;	// Flag for when wrapping a nonstatic member variable
  bool wrapping_member_flag;	// Flag for when wrapping a member variable/enum/const
  bool global_variable_flag;	// Flag for when wrapping a global variable
  bool old_variable_names;	// Flag for old style variable names in the intermediary class
  bool generate_property_declaration_flag;	// Flag for generating properties

  String *imclass_name;		// intermediary class name
  String *module_class_name;	// module class name
  String *imclass_class_code;	// intermediary class code
  String *proxy_class_def;
  String *proxy_class_code;
  String *module_class_code;
  String *proxy_class_name;
  String *variable_name;	//Name of a variable being wrapped
  String *proxy_class_constants_code;
  String *module_class_constants_code;
  String *enum_code;
  String *dllimport;		// DllImport attribute name
  String *namespce;		// Optional namespace name
  String *imclass_imports;	//intermediary class imports from %pragma
  String *module_imports;	//module imports from %pragma
  String *imclass_baseclass;	//inheritance for intermediary class class from %pragma
  String *module_baseclass;	//inheritance for module class from %pragma
  String *imclass_interfaces;	//interfaces for intermediary class class from %pragma
  String *module_interfaces;	//interfaces for module class from %pragma
  String *imclass_class_modifiers;	//class modifiers for intermediary class overriden by %pragma
  String *module_class_modifiers;	//class modifiers for module class overriden by %pragma
  String *upcasts_code;		//C++ casts for inheritance hierarchies C++ code
  String *imclass_cppcasts_code;	//C++ casts up inheritance hierarchies intermediary class code
  String *director_callback_typedefs;	// Director function pointer typedefs for callbacks
  String *director_callbacks;	// Director callback function pointer member variables
  String *director_delegate_callback;	// Director callback method that delegates are set to call
  String *director_delegate_definitions;	// Director delegates definitions in proxy class
  String *director_delegate_instances;	// Director delegates member variables in proxy class
  String *director_method_types;	// Director method types
  String *director_connect_parms;	// Director delegates parameter list for director connect call
  String *destructor_call;	//C++ destructor call if any

  // Director method stuff:
  List *dmethods_seq;
  Hash *dmethods_table;
  int n_dmethods;
  int n_directors;
  int first_class_dmethod;
  int curr_class_dmethod;

  enum EnumFeature { SimpleEnum, TypeunsafeEnum, TypesafeEnum, ProperEnum };

  static Parm *NewParmFromNode(SwigType *type, const String_or_char *name, Node *n) {
    Parm *p = NewParm(type, name);
    Setfile(p, Getfile(n));
    Setline(p, Getline(n));
    return p;
  }

public:

  /* -----------------------------------------------------------------------------
   * CSHARP()
   * ----------------------------------------------------------------------------- */

   CSHARP():empty_string(NewString("")),
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
      filenames_list(NULL),
      proxy_flag(true),
      native_function_flag(false),
      enum_constant_flag(false),
      static_flag(false),
      variable_wrapper_flag(false),
      wrapping_member_flag(false),
      global_variable_flag(false),
      old_variable_names(false),
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
      director_callback_typedefs(NULL),
      director_callbacks(NULL),
      director_delegate_callback(NULL),
      director_delegate_definitions(NULL),
      director_delegate_instances(NULL),
      director_method_types(NULL),
      director_connect_parms(NULL),
      destructor_call(NULL),
      dmethods_seq(NULL),
      dmethods_table(NULL),
      n_dmethods(0),
      n_directors(0) {
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
	return Getattr(n, "sym:name");
      }
    }
    return NULL;
  }

  /* -----------------------------------------------------------------------------
   * directorClassName()
   * ----------------------------------------------------------------------------- */

  String *directorClassName(Node *n) {
    String *dirclassname;
    const char *attrib = "director:classname";

    if (!(dirclassname = Getattr(n, attrib))) {
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

    SWIG_library_directory("csharp");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-dllimport") == 0) {
	  if (argv[i + 1]) {
	    dllimport = NewString("");
	    Printf(dllimport, argv[i + 1]);
	    Swig_mark_arg(i);
	    Swig_mark_arg(i + 1);
	    i++;
	  } else {
	    Swig_arg_error();
	  }
	} else if (strcmp(argv[i], "-namespace") == 0) {
	  if (argv[i + 1]) {
	    namespce = NewString("");
	    Printf(namespce, argv[i + 1]);
	    Swig_mark_arg(i);
	    Swig_mark_arg(i + 1);
	    i++;
	  } else {
	    Swig_arg_error();
	  }
	} else if ((strcmp(argv[i], "-noproxy") == 0)) {
	  Swig_mark_arg(i);
	  proxy_flag = false;
	} else if (strcmp(argv[i], "-oldvarnames") == 0) {
	  Swig_mark_arg(i);
	  old_variable_names = true;
	} else if (strcmp(argv[i], "-help") == 0) {
	  Printf(stdout, "%s\n", usage);
	}
      }
    }

    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGCSHARP 1", 0);

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
    Node *optionsnode = Getattr(Getattr(n, "module"), "options");

    if (optionsnode) {
      if (Getattr(optionsnode, "imclassname"))
	imclass_name = Copy(Getattr(optionsnode, "imclassname"));
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

    if (directorsEnabled()) {
      if (!outfile_h) {
        Printf(stderr, "Unable to determine outfile_h\n");
        SWIG_exit(EXIT_FAILURE);
      }
      f_runtime_h = NewFile(outfile_h, "w");
      if (!f_runtime_h) {
	FileErrorDisplay(outfile_h);
	SWIG_exit(EXIT_FAILURE);
      }
    }

    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_directors_h = NewString("");
    f_directors = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);
    Swig_register_filebyname("director", f_directors);
    Swig_register_filebyname("director_h", f_directors_h);

    swig_types_hash = NewHash();
    filenames_list = NewList();

    // Make the intermediary class and module class names. The intermediary class name can be set in the module directive.
    if (!imclass_name) {
      imclass_name = NewStringf("%sPINVOKE", Getattr(n, "name"));
      module_class_name = Copy(Getattr(n, "name"));
    } else {
      // Rename the module name if it is the same as intermediary class name - a backwards compatibility solution
      if (Cmp(imclass_name, Getattr(n, "name")) == 0)
	module_class_name = NewStringf("%sModule", Getattr(n, "name"));
      else
	module_class_name = Copy(Getattr(n, "name"));
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
    director_connect_parms = NewString("");
    upcasts_code = NewString("");
    dmethods_seq = NewList();
    dmethods_table = NewHash();
    n_dmethods = 0;
    n_directors = 0;
    if (!namespce)
      namespce = NewString("");
    if (!dllimport)
      dllimport = Copy(module_class_name);

    Swig_banner(f_runtime);	// Print the SWIG banner message

    if (directorsEnabled()) {
      Printf(f_runtime, "#define SWIG_DIRECTORS\n");

      /* Emit initial director header and director code: */
      Swig_banner(f_directors_h);
      Printf(f_directors_h, "#ifndef SWIG_%s_WRAP_H_\n", module_class_name);
      Printf(f_directors_h, "#define SWIG_%s_WRAP_H_\n\n", module_class_name);

      Printf(f_directors, "\n\n");
      Printf(f_directors, "/* ---------------------------------------------------\n");
      Printf(f_directors, " * C++ director class methods\n");
      Printf(f_directors, " * --------------------------------------------------- */\n\n");
      if (outfile_h)
	Printf(f_directors, "#include \"%s\"\n\n", Swig_file_filename(outfile_h));
    }

    Swig_name_register((char *) "wrapper", (char *) "CSharp_%f");
    if (old_variable_names) {
      Swig_name_register((char *) "set", (char *) "set_%v");
      Swig_name_register((char *) "get", (char *) "get_%v");
    }

    Printf(f_wrappers, "\n#ifdef __cplusplus\n");
    Printf(f_wrappers, "extern \"C\" {\n");
    Printf(f_wrappers, "#endif\n\n");

    /* Emit code */
    Language::top(n);

    if (directorsEnabled()) {
      // Insert director runtime into the f_runtime file (make it occur before %header section)
      Swig_insert_file("director.swg", f_runtime);
    }
    // Generate the intermediary class
    {
      String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), imclass_name);
      File *f_im = NewFile(filen, "w");
      if (!f_im) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      Append(filenames_list, Copy(filen));
      Delete(filen);
      filen = NULL;

      // Start writing out the intermediary class file
      emitBanner(f_im);

      addOpenNamespace(namespce, f_im);

      if (imclass_imports)
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
      Replaceall(imclass_class_code, "$imclassname", imclass_name);
      Replaceall(imclass_class_code, "$dllimport", dllimport);
      Printv(f_im, imclass_class_code, NIL);
      Printv(f_im, imclass_cppcasts_code, NIL);

      // Finish off the class
      Printf(f_im, "}\n");
      addCloseNamespace(namespce, f_im);

      Close(f_im);
    }

    // Generate the C# module class
    {
      String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), module_class_name);
      File *f_module = NewFile(filen, "w");
      if (!f_module) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      Append(filenames_list, Copy(filen));
      Delete(filen);
      filen = NULL;

      // Start writing out the module class file
      emitBanner(f_module);

      addOpenNamespace(namespce, f_module);

      if (module_imports)
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

      Replaceall(module_class_code, "$imclassname", imclass_name);
      Replaceall(module_class_constants_code, "$imclassname", imclass_name);

      Replaceall(module_class_code, "$dllimport", dllimport);
      Replaceall(module_class_constants_code, "$dllimport", dllimport);

      // Add the wrapper methods
      Printv(f_module, module_class_code, NIL);

      // Write out all the global constants
      Printv(f_module, module_class_constants_code, NIL);

      // Finish off the class
      Printf(f_module, "}\n");
      addCloseNamespace(namespce, f_module);

      Close(f_module);
    }

    if (upcasts_code)
      Printv(f_wrappers, upcasts_code, NIL);

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "}\n");
    Printf(f_wrappers, "#endif\n");

    // Output a C# type wrapper class for each SWIG type
    for (Iterator swig_type = First(swig_types_hash); swig_type.key; swig_type = Next(swig_type)) {
      emitTypeWrapperClass(swig_type.key, swig_type.item);
    }

    // Check for overwriting file problems on filesystems that are case insensitive
    Iterator it1;
    Iterator it2;
    for (it1 = First(filenames_list); it1.item; it1 = Next(it1)) {
      String *item1_lower = Swig_string_lower(it1.item);
      for (it2 = Next(it1); it2.item; it2 = Next(it2)) {
	String *item2_lower = Swig_string_lower(it2.item);
	if (it1.item && it2.item) {
	  if (Strcmp(item1_lower, item2_lower) == 0) {
	    Swig_warning(WARN_LANG_PORTABILITY_FILENAME, input_file, line_number,
			 "Portability warning: File %s will be overwritten by %s on case insensitive filesystems such as "
			 "Windows' FAT32 and NTFS unless the class/module name is renamed\n", it1.item, it2.item);
	  }
	}
	Delete(item2_lower);
      }
      Delete(item1_lower);
    }

    Delete(swig_types_hash);
    swig_types_hash = NULL;
    Delete(filenames_list);
    filenames_list = NULL;
    Delete(imclass_name);
    imclass_name = NULL;
    Delete(imclass_class_code);
    imclass_class_code = NULL;
    Delete(proxy_class_def);
    proxy_class_def = NULL;
    Delete(proxy_class_code);
    proxy_class_code = NULL;
    Delete(module_class_constants_code);
    module_class_constants_code = NULL;
    Delete(imclass_baseclass);
    imclass_baseclass = NULL;
    Delete(imclass_interfaces);
    imclass_interfaces = NULL;
    Delete(imclass_class_modifiers);
    imclass_class_modifiers = NULL;
    Delete(module_class_name);
    module_class_name = NULL;
    Delete(module_class_code);
    module_class_code = NULL;
    Delete(module_baseclass);
    module_baseclass = NULL;
    Delete(module_interfaces);
    module_interfaces = NULL;
    Delete(module_imports);
    module_imports = NULL;
    Delete(module_class_modifiers);
    module_class_modifiers = NULL;
    Delete(imclass_imports);
    imclass_imports = NULL;
    Delete(imclass_cppcasts_code);
    imclass_cppcasts_code = NULL;
    Delete(upcasts_code);
    upcasts_code = NULL;
    Delete(dmethods_seq);
    dmethods_seq = NULL;
    Delete(dmethods_table);
    dmethods_table = NULL;
    Delete(namespce);
    namespce = NULL;
    n_dmethods = 0;

    /* Close all of the files */
    Dump(f_header, f_runtime);

    if (directorsEnabled()) {
      Dump(f_directors, f_runtime);
      Dump(f_directors_h, f_runtime_h);

      Printf(f_runtime_h, "\n");
      Printf(f_runtime_h, "#endif\n");

      Close(f_runtime_h);
      Delete(f_runtime_h);
      f_runtime_h = NULL;
      Delete(f_directors);
      f_directors = NULL;
      Delete(f_directors_h);
      f_directors_h = NULL;
    }

    Dump(f_wrappers, f_runtime);
    Wrapper_pretty_print(f_init, f_runtime);
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
    Printf(f, " * Version %s\n", Swig_package_version());
    Printf(f, " *\n");
    Printf(f, " * Do not make changes to this file unless you know what you are doing--modify\n");
    Printf(f, " * the SWIG interface file instead.\n");
    Printf(f, " * ----------------------------------------------------------------------------- */\n\n");
  }

  /*-----------------------------------------------------------------------
   * Add new director upcall signature
   *----------------------------------------------------------------------*/

  UpcallData *addUpcallMethod(String *imclass_method, String *class_method, String *decl, String *overloaded_name) {
    UpcallData *udata;
    String *imclass_methodidx;
    String *class_methodidx;
    Hash *new_udata;
    String *key = NewStringf("%s|%s", imclass_method, decl);

    ++curr_class_dmethod;

    /* Do we know about this director class already? */
    if ((udata = Getattr(dmethods_table, key))) {
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
    // TODO: remove fdesc
//    Setattr(new_udata, "fdesc", Copy(class_desc));
//    Setattr(new_udata, "imclass_method", Copy(imclass_method));
//    Setattr(new_udata, "imclass_methodidx", imclass_methodidx);
    Setattr(new_udata, "class_methodidx", class_methodidx);
    Setattr(new_udata, "decl", Copy(decl));
    Setattr(new_udata, "overname", Copy(overloaded_name));

    Delete(key);
    return new_udata;
  }

  /*-----------------------------------------------------------------------
   * Get director upcall signature
   *----------------------------------------------------------------------*/

  /*
     UpcallData * getUpcallMethodData(String *director_class, String *decl) {
     String             *key = NewStringf("%s|%s", director_class, decl);
     UpcallData         *udata = Getattr(dmethods_table, key);

     Delete(key);
     return udata;
     }
   */

  /* ----------------------------------------------------------------------
   * nativeWrapper()
   * ---------------------------------------------------------------------- */

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

  /* ----------------------------------------------------------------------
   * functionWrapper()
   * ---------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *c_return_type = NewString("");
    String *im_return_type = NewString("");
    String *cleanup = NewString("");
    String *outarg = NewString("");
    String *body = NewString("");
    String *im_outattribute = 0;
    int num_arguments = 0;
    int num_required = 0;
    bool is_void_return;
    String *overloaded_name = getOverloadedName(n);

    if (!Getattr(n, "sym:overloaded")) {
      if (!addSymbol(Getattr(n, "sym:name"), n))
	return SWIG_ERROR;
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
    if ((tm = Swig_typemap_lookup_new("ctype", n, "", 0))) {
      String *ctypeout = Getattr(n, "tmap:ctype:out");	// the type in the ctype typemap's out attribute overrides the type in the typemap
      if (ctypeout)
	tm = ctypeout;
      Printf(c_return_type, "%s", tm);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(t, 0));
    }

    if ((tm = Swig_typemap_lookup_new("imtype", n, "", 0))) {
      String *imtypeout = Getattr(n, "tmap:imtype:out");	// the type in the imtype typemap's out attribute overrides the type in the typemap
      if (imtypeout)
	tm = imtypeout;
      Printf(im_return_type, "%s", tm);
      im_outattribute = Getattr(n, "tmap:imtype:outattributes");
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", SwigType_str(t, 0));
    }

    is_void_return = (Cmp(c_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f, "jresult", c_return_type, "jresult", NIL);

    Printv(f->def, " SWIGEXPORT ", c_return_type, " SWIGSTDCALL ", wname, "(", NIL);

    // Emit all of the local variables for holding arguments.
    emit_args(t, l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l, f);

    // Parameter overloading
    Setattr(n, "wrap:parms", l);
    Setattr(n, "wrap:name", wname);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in C#
    if (Getattr(n, "sym:overloaded")) {
      // Emit warnings for the few cases that can't be overloaded in C# and give up on generating wrapper
      Swig_overload_check(n);
      if (Getattr(n, "overload:ignore"))
	return SWIG_OK;
    }

    Printv(imclass_class_code, "\n  [DllImport(\"", dllimport, "\", EntryPoint=\"CSharp_", overloaded_name, "\")]\n", NIL);

    if (im_outattribute)
      Printf(imclass_class_code, "  %s\n", im_outattribute);

    Printf(imclass_class_code, "  public static extern %s %s(", im_return_type, overloaded_name);


    /* Get number of required and total arguments */
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
      String *im_param_type = NewString("");
      String *c_param_type = NewString("");
      String *arg = NewString("");

      Printf(arg, "j%s", ln);

      /* Get the ctype types of the parameter */
      if ((tm = Getattr(p, "tmap:ctype"))) {
	Printv(c_param_type, tm, NIL);
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      /* Get the intermediary class parameter types of the parameter */
      if ((tm = Getattr(p, "tmap:imtype"))) {
	String *inattributes = Getattr(p, "tmap:imtype:inattributes");
	Printf(im_param_type, "%s%s", inattributes ? (const String *) inattributes : empty_string, tm);
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      /* Add parameter to intermediary class method */
      if (gencomma)
	Printf(imclass_class_code, ", ");
      Printf(imclass_class_code, "%s %s", im_param_type, arg);

      // Add parameter to C function
      Printv(f->def, gencomma ? ", " : "", c_param_type, " ", arg, NIL);

      gencomma = 1;

      // Get typemap for this argument
      if ((tm = Getattr(p, "tmap:in"))) {
	canThrow(n, "in", p);
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
      Delete(im_param_type);
      Delete(c_param_type);
      Delete(arg);
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:check"))) {
	canThrow(n, "check", p);
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
	canThrow(n, "freearg", p);
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
	canThrow(n, "argout", p);
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

    // Get any C# exception classes in the throws typemap
    ParmList *throw_parm_list = NULL;
    if ((throw_parm_list = Getattr(n, "throws"))) {
      Swig_typemap_attach_parms("throws", throw_parm_list, f);
      for (p = throw_parm_list; p; p = nextSibling(p)) {
	if ((tm = Getattr(p, "tmap:throws"))) {
	  canThrow(n, "throws", p);
	}
      }
    }

    if (Cmp(nodeType(n), "constant") == 0) {
      // Wrapping a constant hack
      Swig_save("functionWrapper", n, "wrap:action", NIL);

      // below based on Swig_VargetToFunction()
      SwigType *ty = Swig_wrapped_var_type(Getattr(n, "type"), use_naturalvar_mode(n));
      Setattr(n, "wrap:action", NewStringf("result = (%s) %s;\n", SwigType_lstr(ty, 0), Getattr(n, "value")));
    }
    // Now write code to make the function call
    if (!native_function_flag)
      emit_action(n, f);

    if (Cmp(nodeType(n), "constant") == 0)
      Swig_restore(n);

    /* Return value if necessary  */
    String *null_attribute = 0;
    if (!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("out", n, "result", 0))) {
	canThrow(n, "out", n);
	Replaceall(tm, "$source", "result");	/* deprecated */
	Replaceall(tm, "$target", "jresult");	/* deprecated */
	Replaceall(tm, "$result", "jresult");

        if (GetFlag(n, "feature:new"))
          Replaceall(tm, "$owner", "1");
        else
          Replaceall(tm, "$owner", "0");

	Printf(f->code, "%s", tm);
	null_attribute = Getattr(n, "tmap:out:null");
	if (Len(tm))
	  Printf(f->code, "\n");
      } else {
	Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(t, 0), Getattr(n, "name"));
      }
    }

    /* Output argument output code */
    Printv(f->code, outarg, NIL);

    /* Output cleanup code */
    Printv(f->code, cleanup, NIL);

    /* Look to see if there is any newfree cleanup code */
    if (GetFlag(n, "feature:new")) {
      if ((tm = Swig_typemap_lookup_new("newfree", n, "result", 0))) {
	canThrow(n, "newfree", n);
	Replaceall(tm, "$source", "result");	/* deprecated */
	Printf(f->code, "%s\n", tm);
      }
    }

    /* See if there is any return cleanup code */
    if (!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
	canThrow(n, "ret", n);
	Replaceall(tm, "$source", "result");	/* deprecated */
	Printf(f->code, "%s\n", tm);
      }
    }

    /* Finish C function and intermediary class function definitions */
    Printf(imclass_class_code, ")");
    Printf(imclass_class_code, ";\n");

    Printf(f->def, ") {");

    if (!is_void_return)
      Printv(f->code, "    return jresult;\n", NIL);
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code, "$cleanup", cleanup);

    /* Substitute the function name */
    Replaceall(f->code, "$symname", symname);

    /* Contract macro modification */
    if (Replaceall(f->code, "SWIG_contract_assert(", "SWIG_contract_assert($null, ") > 0) {
      Setattr(n, "csharp:canthrow", "1");
    }

    if (!null_attribute)
      Replaceall(f->code, "$null", "0");
    else
      Replaceall(f->code, "$null", null_attribute);

    /* Dump the function out */
    if (!native_function_flag) {
      Wrapper_print(f, f_wrappers);

      // Handle %csexception which sets the canthrow attribute
      if (Getattr(n, "feature:except:canthrow"))
	Setattr(n, "csharp:canthrow", "1");

      // A very simple check (it is not foolproof) to help typemap/feature writers for
      // throwing C# exceptions from unmanaged code. It checks for the common methods which
      // set a pending C# exception... the 'canthrow' typemap/feature attribute must be set
      // so that code which checks for pending exceptions is added in the C# proxy method.
      if (!Getattr(n, "csharp:canthrow")) {
	if (Strstr(f->code, "SWIG_exception")) {
	  Swig_warning(WARN_CSHARP_CANTHROW, input_file, line_number,
		       "Unmanaged code contains a call to SWIG_exception and C# code does not handle pending exceptions via the canthrow attribute.\n");
	} else if (Strstr(f->code, "SWIG_CSharpSetPendingException")) {
	  Swig_warning(WARN_CSHARP_CANTHROW, input_file, line_number,
		       "Unmanaged code contains a call to a SWIG_CSharpSetPendingException method and C# code does not handle pending exceptions via the canthrow attribute.\n");
	}
      }
    }

    if (!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
      moduleClassFunctionHandler(n);
    }

    /* 
     * Generate the proxy class properties for public member variables.
     * Not for enums and constants.
     */
    if (proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Capitalize the first letter in the variable in the getter/setter function name
      bool getter_flag = Cmp(symname, Swig_name_set(Swig_name_member(proxy_class_name, variable_name))) != 0;

      String *getter_setter_name = NewString("");
      if (!getter_flag)
	Printf(getter_setter_name, "set");
      else
	Printf(getter_setter_name, "get");
      Putc(toupper((int) *Char(variable_name)), getter_setter_name);
      Printf(getter_setter_name, "%s", Char(variable_name) + 1);

      Setattr(n, "proxyfuncname", getter_setter_name);
      Setattr(n, "imfuncname", symname);

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
    variable_name = Getattr(n, "sym:name");
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
      if (getCurrentClass() && (cplus_mode != PUBLIC))
	return SWIG_NOWRAP;

      enum_code = NewString("");
      String *symname = Getattr(n, "sym:name");
      String *constants_code = (proxy_flag && is_wrapping_class())? proxy_class_constants_code : module_class_constants_code;
      EnumFeature enum_feature = decodeEnumFeature(n);
      String *typemap_lookup_type = Getattr(n, "name");

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
	Printv(enum_code, typemapLookup("csclassmodifiers", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CLASSMOD_UNDEF),	// Class modifiers (enum modifiers really)
	       " ", symname, (*Char(pure_baseclass) || *Char(pure_interfaces)) ? " : " : "", pure_baseclass, ((*Char(pure_baseclass)) && *Char(pure_interfaces)) ?	// Interfaces
	       ", " : "", pure_interfaces, " {\n", NIL);
      } else {
	// Wrap C++ enum with integers - just indicate start of enum with a comment, no comment for anonymous enums of any sort
	if (symname && !Getattr(n, "unnamedinstance"))
	  Printf(constants_code, "  // %s \n", symname);
      }

      // Emit each enum item
      Language::enumDeclaration(n);

      if ((enum_feature != SimpleEnum) && symname && typemap_lookup_type) {
	// Wrap (non-anonymous) C/C++ enum within a typesafe, typeunsafe or proper C# enum
	// Finish the enum declaration
	// Typemaps are used to generate the enum definition in a similar manner to proxy classes.
	Printv(enum_code, (enum_feature == ProperEnum) ? "\n" : typemapLookup("csbody", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF),	// main body of class
	       typemapLookup("cscode", typemap_lookup_type, WARN_NONE),	// extra C# code
	       "}", NIL);

	Replaceall(enum_code, "$csclassname", symname);

	// Substitute $enumvalues - intended usage is for typesafe enums
	if (Getattr(n, "enumvalues"))
	  Replaceall(enum_code, "$enumvalues", Getattr(n, "enumvalues"));
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
	  File *f_enum = NewFile(filen, "w");
	  if (!f_enum) {
	    FileErrorDisplay(filen);
	    SWIG_exit(EXIT_FAILURE);
	  }
	  Append(filenames_list, Copy(filen));
	  Delete(filen);
	  filen = NULL;

	  // Start writing out the enum file
	  emitBanner(f_enum);

	  addOpenNamespace(namespce, f_enum);

	  Printv(f_enum, typemapLookup("csimports", typemap_lookup_type, WARN_NONE),	// Import statements
		 "\n", enum_code, "\n", NIL);

	  addCloseNamespace(namespce, f_enum);

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

    // Strange hack from parent method
    if (value)
      tmpValue = NewString(value);
    else
      tmpValue = NewString(name);
    // Note that this is used in enumValue() amongst other places
    Setattr(n, "value", tmpValue);

    {
      EnumFeature enum_feature = decodeEnumFeature(parentNode(n));

      if ((enum_feature == ProperEnum) && Getattr(parentNode(n), "sym:name") && !Getattr(parentNode(n), "unnamedinstance")) {
	// Wrap (non-anonymous) C/C++ enum with a proper C# enum
	// Emit the enum item.
	if (!Getattr(n, "_last"))	// Only the first enum item has this attribute set
	  Printf(enum_code, ",\n");
	Printf(enum_code, "  %s", symname);

	// Check for the %csconstvalue feature
	String *value = Getattr(n, "feature:cs:constvalue");

	// Note that the enum value must be a true constant and cannot be set from a PINVOKE call, thus no support for %csconst(0)
	value = value ? value : Getattr(n, "enumvalue");
	if (value) {
	  Printf(enum_code, " = %s", value);
	}
      } else {
	// Wrap C/C++ enums with constant integers or use the typesafe enum pattern
	const String *parent_name = Getattr(parentNode(n), "name");
	String *typemap_lookup_type = parent_name ? Copy(parent_name) : NewString("int");
	const String *tm = typemapLookup("cstype", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF);
	String *return_type = Copy(tm);
	Delete(typemap_lookup_type);
	typemap_lookup_type = NULL;

	// The %csconst feature determines how the constant value is obtained
	int const_feature_flag = GetFlag(n, "feature:cs:const");

	if ((enum_feature == TypesafeEnum) && Getattr(parentNode(n), "sym:name") && !Getattr(parentNode(n), "unnamedinstance")) {
	  // Wrap (non-anonymouse) enum using the typesafe enum pattern
	  if (Getattr(n, "enumvalue")) {
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
    String *symname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    String *return_type = NewString("");
    String *constants_code = NewString("");

    if (!addSymbol(symname, n))
      return SWIG_ERROR;

    bool is_enum_item = (Cmp(nodeType(n), "enumitem") == 0);

    // The %csconst feature determines how the constant value is obtained
    int const_feature_flag = GetFlag(n, "feature:cs:const");

    /* Adjust the enum type for the Swig_typemap_lookup.
     * We want the same jstype typemap for all the enum items so we use the enum type (parent node). */
    if (is_enum_item) {
      t = Getattr(parentNode(n), "enumtype");
      Setattr(n, "type", t);
    }

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("cstype", l, NULL);

    /* Get C# return types */
    bool classname_substituted_flag = false;

    if ((tm = Swig_typemap_lookup_new("cstype", n, "", 0))) {
      String *cstypeout = Getattr(n, "tmap:cstype:out");	// the type in the cstype typemap's out attribute overrides the type in the typemap
      if (cstypeout)
	tm = cstypeout;
      classname_substituted_flag = substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No cstype typemap defined for %s\n", SwigType_str(t, 0));
    }

    // Add the stripped quotes back in
    String *new_value = NewString("");
    Swig_save("constantWrapper", n, "value", NIL);
    if (SwigType_type(t) == T_STRING) {
      Printf(new_value, "\"%s\"", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    } else if (SwigType_type(t) == T_CHAR) {
      Printf(new_value, "\'%s\'", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    }

    const String *outattributes = Getattr(n, "tmap:cstype:outattributes");
    if (outattributes)
      Printf(constants_code, "  %s\n", outattributes);
    const String *itemname = (proxy_flag && wrapping_member_flag) ? variable_name : symname;
    Printf(constants_code, "  public %s %s %s = ", (const_feature_flag ? "const" : "static readonly"), return_type, itemname);

    // Check for the %csconstvalue feature
    String *value = Getattr(n, "feature:cs:constvalue");

    if (value) {
      Printf(constants_code, "%s;\n", value);
    } else if (!const_feature_flag) {
      // Default enum and constant handling will work with any type of C constant and initialises the C# variable from C through a PINVOKE call.

      if (classname_substituted_flag) {
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
      SetFlag(n, "feature:immutable");
      enum_constant_flag = true;
      variableWrapper(n);
      enum_constant_flag = false;
    } else {
      // Alternative constant handling will use the C syntax to make a true C# constant and hope that it compiles as C# code
      Printf(constants_code, "%s;\n", Getattr(n, "value"));
    }

    // Emit the generated code to appropriate place
    // Enums only emit the intermediate and PINVOKE methods, so no proxy or module class wrapper methods needed
    if (!is_enum_item) {
      if (proxy_flag && wrapping_member_flag)
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
    String *code = Getattr(n, "code");
    Replaceall(code, "$module", module_class_name);
    Replaceall(code, "$imclassname", imclass_name);
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
      String *lang = Getattr(n, "lang");
      String *code = Getattr(n, "name");
      String *value = Getattr(n, "value");

      if (Strcmp(lang, "csharp") == 0) {

	String *strvalue = NewString(value);
	Replaceall(strvalue, "\\\"", "\"");

	if (Strcmp(code, "imclassbase") == 0) {
	  Delete(imclass_baseclass);
	  imclass_baseclass = Copy(strvalue);
	} else if (Strcmp(code, "imclassclassmodifiers") == 0) {
	  Delete(imclass_class_modifiers);
	  imclass_class_modifiers = Copy(strvalue);
	} else if (Strcmp(code, "imclasscode") == 0) {
	  Printf(imclass_class_code, "%s\n", strvalue);
	} else if (Strcmp(code, "imclassimports") == 0) {
	  Delete(imclass_imports);
	  imclass_imports = Copy(strvalue);
	} else if (Strcmp(code, "imclassinterfaces") == 0) {
	  Delete(imclass_interfaces);
	  imclass_interfaces = Copy(strvalue);
	} else if (Strcmp(code, "modulebase") == 0) {
	  Delete(module_baseclass);
	  module_baseclass = Copy(strvalue);
	} else if (Strcmp(code, "moduleclassmodifiers") == 0) {
	  Delete(module_class_modifiers);
	  module_class_modifiers = Copy(strvalue);
	} else if (Strcmp(code, "modulecode") == 0) {
	  Printf(module_class_code, "%s\n", strvalue);
	} else if (Strcmp(code, "moduleimports") == 0) {
	  Delete(module_imports);
	  module_imports = Copy(strvalue);
	} else if (Strcmp(code, "moduleinterfaces") == 0) {
	  Delete(module_interfaces);
	  module_interfaces = Copy(strvalue);
	} else {
	  Printf(stderr, "%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
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
    String *c_classname = SwigType_namestr(Getattr(n, "name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;
    String *typemap_lookup_type = Getattr(n, "classtypeobj");
    bool feature_director = Swig_directorclass(n) ? true : false;

    // Inheritance from pure C# classes
    Node *attributes = NewHash();
    const String *pure_baseclass = typemapLookup("csbase", typemap_lookup_type, WARN_NONE, attributes);
    bool purebase_replace = GetFlag(attributes, "tmap:csbase:replace") ? true : false;
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
            Swig_warning(WARN_CSHARP_MULTIPLE_INHERITANCE, input_file, line_number,
                         "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in C#.\n", proxyclassname, baseclassname);
            base = Next(base);
          }
        }
      }
    }

    const String *wanted_base = baseclass ? baseclass : pure_baseclass;
    bool derived = baseclass && getProxyName(c_baseclassname);

    if (purebase_replace) {
      wanted_base = pure_baseclass;
      derived = false;
      Delete(baseclass);
      baseclass = NULL;
    } else if (Len(pure_baseclass) > 0 && Len(baseclass) > 0) {
      Swig_warning(WARN_CSHARP_MULTIPLE_INHERITANCE, input_file, line_number,
		   "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in C#. Perhaps you need the replace attribute in the csbase typemap?\n", typemap_lookup_type, pure_baseclass);
    }

    // Pure C# interfaces
    const String *pure_interfaces = typemapLookup(derived ? "csinterfaces_derived" : "csinterfaces", typemap_lookup_type, WARN_NONE);
    // Start writing the proxy class
    Printv(proxy_class_def, typemapLookup("csimports", typemap_lookup_type, WARN_NONE),	// Import statements
	   "\n", NIL);

    // Class attributes
    const String *csattributes = typemapLookup("csattributes", typemap_lookup_type, WARN_NONE);
    if (csattributes && *Char(csattributes))
      Printf(proxy_class_def, "%s\n", csattributes);

    Printv(proxy_class_def, typemapLookup("csclassmodifiers", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CLASSMOD_UNDEF),	// Class modifiers
	   " $csclassname",	// Class name and base class
	   (*Char(wanted_base) || *Char(pure_interfaces)) ? " : " : "", wanted_base, (*Char(wanted_base) && *Char(pure_interfaces)) ?	// Interfaces
	   ", " : "", pure_interfaces, " {", derived ? typemapLookup("csbody_derived", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF) :	// main body of class
	   typemapLookup("csbody", typemap_lookup_type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF),	// main body of class
	   NIL);

    // C++ destructor is wrapped by the Dispose method
    // Note that the method name is specified in a typemap attribute called methodname
    String *destruct = NewString("");
    const String *tm = NULL;
    attributes = NewHash();
    String *destruct_methodname = NULL;
    String *destruct_methodmodifiers = NULL;
    if (derived) {
      tm = typemapLookup("csdestruct_derived", typemap_lookup_type, WARN_NONE, attributes);
      destruct_methodname = Getattr(attributes, "tmap:csdestruct_derived:methodname");
      destruct_methodmodifiers = Getattr(attributes, "tmap:csdestruct_derived:methodmodifiers");
    } else {
      tm = typemapLookup("csdestruct", typemap_lookup_type, WARN_NONE, attributes);
      destruct_methodname = Getattr(attributes, "tmap:csdestruct:methodname");
      destruct_methodmodifiers = Getattr(attributes, "tmap:csdestruct:methodmodifiers");
    }
    if (tm && *Char(tm)) {
      if (!destruct_methodname) {
	Swig_error(input_file, line_number, "No methodname attribute defined in csdestruct%s typemap for %s\n", (derived ? "_derived" : ""), proxy_class_name);
      }
      if (!destruct_methodmodifiers) {
	Swig_error(input_file, line_number,
		   "No methodmodifiers attribute defined in csdestruct%s typemap for %s.\n", (derived ? "_derived" : ""), proxy_class_name);
      }
    }
    // Emit the Finalize and Dispose methods
    if (tm) {
      // Finalize method
      if (*Char(destructor_call)) {
	Printv(proxy_class_def, typemapLookup("csfinalize", typemap_lookup_type, WARN_NONE), NIL);
      }
      // Dispose method
      Printv(destruct, tm, NIL);
      if (*Char(destructor_call))
	Replaceall(destruct, "$imcall", destructor_call);
      else
	Replaceall(destruct, "$imcall", "throw new MethodAccessException(\"C++ destructor does not have public access\")");
      if (*Char(destruct))
	Printv(proxy_class_def, "\n  ", destruct_methodmodifiers, " ", derived ? "override" : "virtual", " void ", destruct_methodname, "() ", destruct, "\n",
	       NIL);
    }

    if (feature_director) {
      // Generate director connect method
      // put this in classDirectorEnd ???
      Printf(proxy_class_code, "  private void SwigDirectorConnect() {\n");

      for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
	UpcallData *udata = Getitem(dmethods_seq, i);
	String *method = Getattr(udata, "method");
	String *methid = Getattr(udata, "class_methodidx");
	String *overname = Getattr(udata, "overname");
	Printf(proxy_class_code, "    if (SwigDerivedClassHasMethod(\"%s\", swigMethodTypes%s))\n", method, methid);
	Printf(proxy_class_code, "      swigDelegate%s = new SwigDelegate%s_%s(SwigDirector%s);\n", methid, proxy_class_name, methid, overname);
      }
      Printf(proxy_class_code, "    %s.%s_director_connect(swigCPtr", imclass_name, proxy_class_name);
      for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
	UpcallData *udata = Getitem(dmethods_seq, i);
	String *methid = Getattr(udata, "class_methodidx");
	Printf(proxy_class_code, ", swigDelegate%s", methid);
      }
      Printf(proxy_class_code, ");\n");
      Printf(proxy_class_code, "  }\n");

      if (first_class_dmethod < curr_class_dmethod) {
	// Only emit if there is at least one director method
	Printf(proxy_class_code, "\n");
	Printf(proxy_class_code, "  private bool SwigDerivedClassHasMethod(string methodName, Type[] methodTypes) {\n");
	Printf(proxy_class_code,
	       "    System.Reflection.MethodInfo methodInfo = this.GetType().GetMethod(methodName, System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance, null, methodTypes, null);\n");
	Printf(proxy_class_code, "    bool hasDerivedMethod = methodInfo.DeclaringType.IsSubclassOf(typeof(%s));\n", proxy_class_name);
	/* Could add this code to cover corner case where the GetMethod() returns a method which allows type
	 * promotion, eg it will return foo(double), if looking for foo(int).
	 if (hasDerivedMethod) {
	 hasDerivedMethod = false;
	 if (methodInfo != null)
	 {
	 hasDerivedMethod = true;
	 ParameterInfo[] parameterArray1 = methodInfo.GetParameters();
	 for (int i=0; i<methodTypes.Length; i++)
	 {
	 if (parameterArray1[0].ParameterType != methodTypes[0])
	 {
	 hasDerivedMethod = false;
	 break;
	 }
	 }
	 }
	 }
	 */
	Printf(proxy_class_code, "    return hasDerivedMethod;\n");
	Printf(proxy_class_code, "  }\n");
      }

      if (Len(director_delegate_callback) > 0)
	Printv(proxy_class_code, director_delegate_callback, NIL);
      if (Len(director_delegate_definitions) > 0)
	Printv(proxy_class_code, "\n", director_delegate_definitions, NIL);
      if (Len(director_delegate_instances) > 0)
	Printv(proxy_class_code, "\n", director_delegate_instances, NIL);
      if (Len(director_method_types) > 0)
	Printv(proxy_class_code, "\n", director_method_types, NIL);

      Delete(director_callback_typedefs);
      director_callback_typedefs = NULL;
      Delete(director_callbacks);
      director_callbacks = NULL;
      Delete(director_delegate_callback);
      director_delegate_callback = NULL;
      Delete(director_delegate_definitions);
      director_delegate_definitions = NULL;
      Delete(director_delegate_instances);
      director_delegate_instances = NULL;
      Delete(director_method_types);
      director_method_types = NULL;
      Delete(director_connect_parms);
      director_connect_parms = NULL;
    }

    Delete(attributes);
    Delete(destruct);

    // Emit extra user code
    Printv(proxy_class_def, typemapLookup("cscode", typemap_lookup_type, WARN_NONE),	// extra C# code
	   "\n", NIL);

    // Substitute various strings into the above template
    Replaceall(proxy_class_code, "$csclassname", proxy_class_name);
    Replaceall(proxy_class_def, "$csclassname", proxy_class_name);

    Replaceall(proxy_class_def, "$module", module_class_name);
    Replaceall(proxy_class_code, "$module", module_class_name);

    Replaceall(proxy_class_def, "$imclassname", imclass_name);
    Replaceall(proxy_class_code, "$imclassname", imclass_name);

    Replaceall(proxy_class_def, "$dllimport", dllimport);
    Replaceall(proxy_class_code, "$dllimport", dllimport);

    // Add code to do C++ casting to base class (only for classes in an inheritance hierarchy)
    if (derived) {
      Printv(imclass_cppcasts_code, "\n  [DllImport(\"", dllimport, "\", EntryPoint=\"CSharp_", proxy_class_name, "Upcast", "\")]\n", NIL);
      Printf(imclass_cppcasts_code, "  public static extern IntPtr $csclassnameUpcast(IntPtr objectRef);\n");

      Replaceall(imclass_cppcasts_code, "$csclassname", proxy_class_name);

      Printv(upcasts_code,
	     "SWIGEXPORT $cbaseclass * SWIGSTDCALL CSharp_$imclazznameUpcast",
	     "($cclass *objectRef) {\n", "    return ($cbaseclass *)objectRef;\n" "}\n", "\n", NIL);

      Replaceall(upcasts_code, "$cbaseclass", c_baseclass);
      Replaceall(upcasts_code, "$imclazzname", proxy_class_name);
      Replaceall(upcasts_code, "$cclass", c_classname);
    }
    Delete(baseclass);
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {

    File *f_proxy = NULL;
    if (proxy_flag) {
      proxy_class_name = NewString(Getattr(n, "sym:name"));

      if (!addSymbol(proxy_class_name, n))
	return SWIG_ERROR;

      if (Cmp(proxy_class_name, imclass_name) == 0) {
	Printf(stderr, "Class name cannot be equal to intermediary class name: %s\n", proxy_class_name);
	SWIG_exit(EXIT_FAILURE);
      }

      if (Cmp(proxy_class_name, module_class_name) == 0) {
	Printf(stderr, "Class name cannot be equal to module class name: %s\n", proxy_class_name);
	SWIG_exit(EXIT_FAILURE);
      }

      String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), proxy_class_name);
      f_proxy = NewFile(filen, "w");
      if (!f_proxy) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      Append(filenames_list, Copy(filen));
      Delete(filen);
      filen = NULL;

      // Start writing out the proxy class file
      emitBanner(f_proxy);

      addOpenNamespace(namespce, f_proxy);

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
      Replaceall(proxy_class_def, "$imclassname", imclass_name);
      Replaceall(proxy_class_code, "$imclassname", imclass_name);
      Replaceall(proxy_class_constants_code, "$imclassname", imclass_name);
      Replaceall(proxy_class_def, "$dllimport", dllimport);
      Replaceall(proxy_class_code, "$dllimport", dllimport);
      Replaceall(proxy_class_constants_code, "$dllimport", dllimport);

      Printv(f_proxy, proxy_class_def, proxy_class_code, NIL);

      // Write out all the constants
      if (Len(proxy_class_constants_code) != 0)
	Printv(f_proxy, proxy_class_constants_code, NIL);

      Printf(f_proxy, "}\n");
      addCloseNamespace(namespce, f_proxy);
      Close(f_proxy);
      f_proxy = NULL;

      /* Output the downcast method, if necessary. Note: There's no other really
         good place to put this code, since Abstract Base Classes (ABCs) can and should have 
         downcasts, making the constructorHandler() a bad place (because ABCs don't get to
         have constructors emitted.) */
      if (GetFlag(n, "feature:javadowncast")) {
	String *norm_name = SwigType_namestr(Getattr(n, "name"));

	Printf(imclass_class_code, "  public final static native %s downcast%s(long cPtrBase, boolean cMemoryOwn);\n", proxy_class_name, proxy_class_name);

	Wrapper *dcast_wrap = NewWrapper();

	Printf(dcast_wrap->def, "SWIGEXPORT jobject SWIGSTDCALL CSharp_downcast%s(JNIEnv *jenv, jclass jcls, jlong jCPtrBase, jboolean cMemoryOwn) {",
	       proxy_class_name);
	Printf(dcast_wrap->code, "  Swig::Director *director = (Swig::Director *) 0;\n");
	Printf(dcast_wrap->code, "  jobject jresult = (jobject) 0;\n");
	Printf(dcast_wrap->code, "  %s *obj = *((%s **)&jCPtrBase);\n", norm_name, norm_name);
	Printf(dcast_wrap->code, "  if (obj) director = dynamic_cast<Swig::Director *>(obj);\n");
	Printf(dcast_wrap->code, "  if (director) jresult = director->swig_get_self(jenv);\n");
	Printf(dcast_wrap->code, "  return jresult;\n");
	Printf(dcast_wrap->code, "}\n");

	Wrapper_print(dcast_wrap, f_wrappers);
	DelWrapper(dcast_wrap);
      }

      emitDirectorExtraMethods(n);

      Delete(proxy_class_name);
      proxy_class_name = NULL;
      Delete(destructor_call);
      destructor_call = NULL;
      Delete(proxy_class_constants_code);
      proxy_class_constants_code = NULL;
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
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "imfuncname", intermediary_function_name);
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
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n, "imfuncname", intermediary_function_name);
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
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *intermediary_function_name = Getattr(n, "imfuncname");
    String *proxy_function_name = Getattr(n, "proxyfuncname");
    String *tm;
    Parm *p;
    Parm *last_parm = 0;
    int i;
    String *imcall = NewString("");
    String *return_type = NewString("");
    String *function_code = NewString("");
    bool setter_flag = false;
    String *pre_code = NewString("");
    String *post_code = NewString("");

    if (!proxy_flag)
      return;

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in C#
    if (Getattr(n, "overload:ignore"))
      return;

    // Don't generate proxy method for additional explicitcall method used in directors
    if (GetFlag(n, "explicitcall"))
      return;

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("cstype", l, NULL);
    Swig_typemap_attach_parms("csin", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("cstype", n, "", 0))) {
      // Note that in the case of polymorphic (covariant) return types, the method's return type is changed to be the base of the C++ return type
      SwigType *covariant = Getattr(n, "covariant");
      String *cstypeout = Getattr(n, "tmap:cstype:out");	// the type in the cstype typemap's out attribute overrides the type in the typemap
      if (cstypeout)
	tm = cstypeout;
      substituteClassname(covariant ? covariant : t, tm);
      Printf(return_type, "%s", tm);
      if (covariant)
	Swig_warning(WARN_CSHARP_COVARIANT_RET, input_file, line_number,
		     "Covariant return types not supported in C#. Proxy method will return %s.\n", SwigType_str(covariant, 0));
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No cstype typemap defined for %s\n", SwigType_str(t, 0));
    }

    if (proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Properties
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(Swig_name_member(proxy_class_name, variable_name))) == 0);
      if (setter_flag)
        Swig_typemap_attach_parms("csvarin", l, NULL);
    }

    /* Start generating the proxy function */
    const String *outattributes = Getattr(n, "tmap:cstype:outattributes");
    if (outattributes)
      Printf(function_code, "  %s\n", outattributes);
    const String *csattributes = Getattr(n, "feature:cs:attributes");
    if (csattributes)
      Printf(function_code, "  %s\n", csattributes);
    const String *methodmods = Getattr(n, "feature:cs:methodmodifiers");
    if (methodmods) {
      if (is_smart_pointer()) {
	// Smart pointer classes do not mirror the inheritance hierarchy of the underlying pointer type, so no virtual/override/new required.
	String *mmods = Copy(methodmods);
	Replaceall(mmods, "override", "");
	Replaceall(mmods, "virtual", "");
	Replaceall(mmods, "new", "");
	Chop(mmods);		// remove trailing whitespace
	Printf(function_code, "  %s ", mmods);
	Delete(mmods);
      } else {
	Printf(function_code, "  %s ", methodmods);
      }
    } else {
      methodmods = (is_public(n) ? public_string : protected_string);
      Printf(function_code, "  %s ", methodmods);
      if (!is_smart_pointer()) {
	// Smart pointer classes do not mirror the inheritance hierarchy of the underlying pointer type, so no virtual/override/new required.
	if (Getattr(n, "override"))
	  Printf(function_code, "override ");
	else if (checkAttribute(n, "storage", "virtual"))
	  Printf(function_code, "virtual ");
	if (Getattr(n, "hides"))
	  Printf(function_code, "new ");
      }
    }
    if (static_flag)
      Printf(function_code, "static ");
    Printf(function_code, "%s %s(", return_type, proxy_function_name);

    Printv(imcall, imclass_name, ".$imfuncname(", NIL);
    if (!static_flag)
      Printf(imcall, "swigCPtr");

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
	last_parm = p;

	/* Get the C# parameter type */
	if ((tm = Getattr(p, "tmap:cstype"))) {
	  substituteClassname(pt, tm);
	  String *inattributes = Getattr(p, "tmap:cstype:inattributes");
	  Printf(param_type, "%s%s", inattributes ? (const String *) inattributes : empty_string, tm);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No cstype typemap defined for %s\n", SwigType_str(pt, 0));
	}

	if (gencomma)
	  Printf(imcall, ", ");

	String *arg = makeParameterName(n, p, i, setter_flag);

	// Use typemaps to transform type used in C# wrapper function (in proxy class) to type used in PInvoke function (in intermediary class)
	if ((tm = Getattr(p, "tmap:csin"))) {
	  substituteClassname(pt, tm);
	  Replaceall(tm, "$csinput", arg);
          String *pre = Getattr(p, "tmap:csin:pre");
          if (pre) {
            substituteClassname(pt, pre);
            Replaceall(pre, "$csinput", arg);
            if (Len(pre_code) > 0)
              Printf(pre_code, "\n");
            Printv(pre_code, pre, NIL);
          }
          String *post = Getattr(p, "tmap:csin:post");
          if (post) {
            substituteClassname(pt, post);
            Replaceall(post, "$csinput", arg);
            if (Len(post_code) > 0)
              Printf(post_code, "\n");
            Printv(post_code, post, NIL);
          }
	  Printv(imcall, tm, NIL);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSIN_UNDEF, input_file, line_number, "No csin typemap defined for %s\n", SwigType_str(pt, 0));
	}

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

    Printf(imcall, ")");
    Printf(function_code, ")");

    // Transform return type used in PInvoke function (in intermediary class) to type used in C# wrapper function (in proxy class)
    if ((tm = Swig_typemap_lookup_new("csout", n, "", 0))) {
      excodeSubstitute(n, tm, "csout", n);
      bool is_pre_code = Len(pre_code) > 0;
      bool is_post_code = Len(post_code) > 0;
      if (is_pre_code || is_post_code) {
        Replaceall(tm, "\n ", "\n   "); // add extra indentation to code in typemap
        if (is_post_code) {
          Insert(tm, 0, "\n    try ");
          Printv(tm, " finally {\n", post_code, "\n    }", NIL);
        } else {
          Insert(tm, 0, "\n    ");
        }
        if (is_pre_code) {
          Insert(tm, 0, pre_code);
          Insert(tm, 0, "\n");
        }
	Insert(tm, 0, "{");
	Printf(tm, "\n  }");
      }
      if (GetFlag(n, "feature:new"))
	Replaceall(tm, "$owner", "true");
      else
	Replaceall(tm, "$owner", "false");
      substituteClassname(t, tm);

      // For director methods: generate code to selectively make a normal polymorphic call or 
      // an explicit method call - needed to prevent infinite recursion calls in director methods.
      Node *explicit_n = Getattr(n, "explicitcallnode");
      if (explicit_n) {
	String *ex_overloaded_name = getOverloadedName(explicit_n);
	String *ex_intermediary_function_name = Swig_name_member(proxy_class_name, ex_overloaded_name);

	String *ex_imcall = Copy(imcall);
	Replaceall(ex_imcall, "$imfuncname", ex_intermediary_function_name);
	Replaceall(imcall, "$imfuncname", intermediary_function_name);

	String *excode = NewString("");
	if (!Cmp(return_type, "void"))
	  Printf(excode, "if (this.GetType() == typeof(%s)) %s; else %s", proxy_class_name, imcall, ex_imcall);
	else
	  Printf(excode, "((this.GetType() == typeof(%s)) ? %s : %s)", proxy_class_name, imcall, ex_imcall);

	Clear(imcall);
	Printv(imcall, excode, NIL);
	Delete(ex_overloaded_name);
	Delete(excode);
      } else {
	Replaceall(imcall, "$imfuncname", intermediary_function_name);
      }
      Replaceall(tm, "$imcall", imcall);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, "No csout typemap defined for %s\n", SwigType_str(t, 0));
    }

    if (proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Properties
      if (generate_property_declaration_flag) {	// Ensure the declaration is generated just once should the property contain both a set and get
	// Get the C# variable type - obtained differently depending on whether a setter is required.
	String *variable_type = return_type;
	if (setter_flag) {
	  p = last_parm;	// (last parameter is the only parameter for properties)
	  SwigType *pt = Getattr(p, "type");
	  if ((tm = Getattr(p, "tmap:cstype"))) {
	    substituteClassname(pt, tm);
            String *cstypeout = Getattr(p, "tmap:cstype:out");	// the type in the cstype typemap's out attribute overrides the type in the typemap
	    variable_type = cstypeout ? cstypeout : tm;
	  } else {
	    Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, "No csvarin typemap defined for %s\n", SwigType_str(pt, 0));
	  }
	}
	const String *csattributes = Getattr(n, "feature:cs:attributes");
	if (csattributes)
	  Printf(proxy_class_code, "  %s\n", csattributes);
	const String *methodmods = Getattr(n, "feature:cs:methodmodifiers");
	if (!methodmods)
	  methodmods = (is_public(n) ? public_string : protected_string);
	Printf(proxy_class_code, "  %s %s%s %s {", methodmods, static_flag ? "static " : "", variable_type, variable_name);
      }
      generate_property_declaration_flag = false;

      if (setter_flag) {
	// Setter method
	p = last_parm;		// (last parameter is the only parameter for properties)
	SwigType *pt = Getattr(p, "type");
	if ((tm = Getattr(p, "tmap:csvarin"))) {
	  substituteClassname(pt, tm);
	  Replaceall(tm, "$imcall", imcall);
	  excodeSubstitute(n, tm, "csvarin", p);
	  Printf(proxy_class_code, "%s", tm);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, "No csvarin typemap defined for %s\n", SwigType_str(pt, 0));
	}
      } else {
	// Getter method
	if ((tm = Swig_typemap_lookup_new("csvarout", n, "", 0))) {
	  if (GetFlag(n, "feature:new"))
	    Replaceall(tm, "$owner", "true");
	  else
	    Replaceall(tm, "$owner", "false");
	  substituteClassname(t, tm);
	  Replaceall(tm, "$imcall", imcall);
	  excodeSubstitute(n, tm, "csvarout", n);
	  Printf(proxy_class_code, "%s", tm);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, "No csvarout typemap defined for %s\n", SwigType_str(t, 0));
	}
      }
    } else {
      // Normal function call
      Printf(function_code, " %s\n\n", tm ? (const String *) tm : empty_string);
      Printv(proxy_class_code, function_code, NIL);
    }

    Delete(pre_code);
    Delete(post_code);
    Delete(function_code);
    Delete(return_type);
    Delete(imcall);
  }

  /* ----------------------------------------------------------------------
   * constructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {

    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *function_code = NewString("");
    String *helper_code = NewString(""); // Holds code for the constructor helper method generated only when the csin typemap has code in the pre or post attributes
    String *helper_args = NewString("");
    String *pre_code = NewString("");
    String *post_code = NewString("");
    String *im_return_type = NewString("");
    bool feature_director = (parentNode(n) && Swig_directorclass(n));

    Language::constructorHandler(n);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in C#
    if (Getattr(n, "overload:ignore"))
      return SWIG_OK;

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *mangled_overname = Swig_name_construct(overloaded_name);
      String *imcall = NewString("");

      const String *csattributes = Getattr(n, "feature:cs:attributes");
      if (csattributes) {
	Printf(function_code, "  %s\n", csattributes);
	Printf(helper_code, "  %s\n", csattributes);
      }
      const String *methodmods = Getattr(n, "feature:cs:methodmodifiers");
      methodmods = methodmods ? methodmods : (is_public(n) ? public_string : protected_string);

      tm = Getattr(n, "tmap:imtype"); // typemaps were attached earlier to the node
      String *imtypeout = Getattr(n, "tmap:imtype:out");	// the type in the imtype typemap's out attribute overrides the type in the typemap
      if (imtypeout)
	tm = imtypeout;
      Printf(im_return_type, "%s", tm);

      Printf(function_code, "  %s %s(", methodmods, proxy_class_name);
      Printf(helper_code, "  static private %s SwigConstruct%s(", im_return_type, proxy_class_name);

      Printv(imcall, imclass_name, ".", mangled_overname, "(", NIL);

      /* Attach the non-standard typemaps to the parameter list */
      Swig_typemap_attach_parms("in", l, NULL);
      Swig_typemap_attach_parms("cstype", l, NULL);
      Swig_typemap_attach_parms("csin", l, NULL);

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

	/* Get the C# parameter type */
	if ((tm = Getattr(p, "tmap:cstype"))) {
	  substituteClassname(pt, tm);
	  String *inattributes = Getattr(p, "tmap:cstype:inattributes");
	  Printf(param_type, "%s%s", inattributes ? (const String *) inattributes : empty_string, tm);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No cstype typemap defined for %s\n", SwigType_str(pt, 0));
	}

	if (gencomma)
	  Printf(imcall, ", ");

	String *arg = makeParameterName(n, p, i, false);
        String *cshin = 0;

	// Use typemaps to transform type used in C# wrapper function (in proxy class) to type used in PInvoke function (in intermediary class)
	if ((tm = Getattr(p, "tmap:csin"))) {
	  substituteClassname(pt, tm);
	  Replaceall(tm, "$csinput", arg);
          String *pre = Getattr(p, "tmap:csin:pre");
          if (pre) {
            substituteClassname(pt, pre);
            Replaceall(pre, "$csinput", arg);
            if (Len(pre_code) > 0)
              Printf(pre_code, "\n");
            Printv(pre_code, pre, NIL);
          }
          String *post = Getattr(p, "tmap:csin:post");
          if (post) {
            substituteClassname(pt, post);
            Replaceall(post, "$csinput", arg);
            if (Len(post_code) > 0)
              Printf(post_code, "\n");
            Printv(post_code, post, NIL);
          }
          cshin = Getattr(p, "tmap:csin:cshin");
          if (cshin)
            Replaceall(cshin, "$csinput", arg);
	  Printv(imcall, tm, NIL);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSIN_UNDEF, input_file, line_number, "No csin typemap defined for %s\n", SwigType_str(pt, 0));
	}

	/* Add parameter to proxy function */
	if (gencomma) {
	  Printf(function_code, ", ");
	  Printf(helper_code, ", ");
	  Printf(helper_args, ", ");
        }
	Printf(function_code, "%s %s", param_type, arg);
	Printf(helper_code, "%s %s", param_type, arg);
	Printf(helper_args, "%s", cshin ? cshin : arg);
	++gencomma;

	Delete(cshin);
	Delete(arg);
	Delete(param_type);
	p = Getattr(p, "tmap:in:next");
      }

      Printf(imcall, ")");

      Printf(function_code, ")");
      Printf(helper_code, ")");

      /* Insert the csconstruct typemap, doing the replacement for $directorconnect, as needed */
      Hash *attributes = NewHash();
      String *construct_tm = Copy(typemapLookup("csconstruct", Getattr(n, "name"),
						WARN_CSHARP_TYPEMAP_CSCONSTRUCT_UNDEF, attributes));
      if (construct_tm) {
	if (!feature_director) {
	  Replaceall(construct_tm, "$directorconnect", "");
	} else {
	  String *connect_attr = Getattr(attributes, "tmap:csconstruct:directorconnect");

	  if (connect_attr) {
	    Replaceall(construct_tm, "$directorconnect", connect_attr);
	  } else {
	    Swig_warning(WARN_CSHARP_NO_DIRECTORCONNECT_ATTR, input_file, line_number, "\"directorconnect\" attribute missing in %s \"csconstruct\" typemap.\n",
			 Getattr(n, "name"));
	    Replaceall(construct_tm, "$directorconnect", "");
	  }
	}

	Printv(function_code, " ", construct_tm, NIL);
      }

      excodeSubstitute(n, function_code, "csconstruct", attributes);

      bool is_pre_code = Len(pre_code) > 0;
      bool is_post_code = Len(post_code) > 0;
      if (is_pre_code || is_post_code) {
        Printf(helper_code, " {\n");
        if (is_pre_code) {
          Printv(helper_code, pre_code, "\n", NIL);
        }
        if (is_post_code) {
          Printf(helper_code, "    try {\n");
          Printv(helper_code, "      return ", imcall, ";\n", NIL);
          Printv(helper_code, "    } finally {\n", post_code, "\n    }", NIL);
        } else {
          Printv(helper_code, "    return ", imcall, ";", NIL);
        }
        Printf(helper_code, "\n  }\n");
        String *helper_name = NewStringf("%s.SwigConstruct%s(%s)", proxy_class_name, proxy_class_name, helper_args);
        String *im_outattribute = Getattr(n, "tmap:imtype:outattributes");
        if (im_outattribute)
          Printf(proxy_class_code, "  %s\n", im_outattribute);
        Printv(proxy_class_code, helper_code, "\n", NIL);
        Replaceall(function_code, "$imcall", helper_name);
        Delete(helper_name);
      } else {
        Replaceall(function_code, "$imcall", imcall);
      }

      Printv(proxy_class_code, function_code, "\n", NIL);

      Delete(helper_args);
      Delete(im_return_type);
      Delete(pre_code);
      Delete(post_code);
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
      Printv(destructor_call, imclass_name, ".", Swig_name_destroy(symname), "(swigCPtr)", NIL);
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {

    generate_property_declaration_flag = true;
    variable_name = Getattr(n, "sym:name");
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
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    static_flag = true;
    Language::staticmembervariableHandler(n);
    wrapping_member_flag = false;
    static_flag = false;
    generate_property_declaration_flag = false;

    if (static_const_member_flag)
      Printf(proxy_class_code, "\n  }\n\n");

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

    /* A C# HandleRef is used for all classes in the SWIG intermediary class.
     * The intermediary class methods are thus mangled when overloaded to give
     * a unique name. */
    String *overloaded_name = NewStringf("%s", Getattr(n, "sym:name"));

    if (Getattr(n, "sym:overloaded")) {
      Printv(overloaded_name, Getattr(n, "sym:overname"), NIL);
    }

    return overloaded_name;
  }

  /* -----------------------------------------------------------------------------
   * moduleClassFunctionHandler()
   * ----------------------------------------------------------------------------- */

  void moduleClassFunctionHandler(Node *n) {
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    Parm *last_parm = 0;
    int i;
    String *imcall = NewString("");
    String *return_type = NewString("");
    String *function_code = NewString("");
    int num_arguments = 0;
    int num_required = 0;
    String *overloaded_name = getOverloadedName(n);
    String *func_name = NULL;
    bool setter_flag = false;
    String *pre_code = NewString("");
    String *post_code = NewString("");

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("cstype", l, NULL);
    Swig_typemap_attach_parms("csin", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("cstype", n, "", 0))) {
      String *cstypeout = Getattr(n, "tmap:cstype:out");	// the type in the cstype typemap's out attribute overrides the type in the typemap
      if (cstypeout)
	tm = cstypeout;
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No cstype typemap defined for %s\n", SwigType_str(t, 0));
    }

    /* Change function name for global variables */
    if (proxy_flag && global_variable_flag) {
      // Capitalize the first letter in the variable to create the getter/setter function name
      func_name = NewString("");
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(variable_name)) == 0);
      if (setter_flag)
	Printf(func_name, "set");
      else
	Printf(func_name, "get");
      Putc(toupper((int) *Char(variable_name)), func_name);
      Printf(func_name, "%s", Char(variable_name) + 1);
      if (setter_flag)
        Swig_typemap_attach_parms("csvarin", l, NULL);
    } else {
      func_name = Copy(Getattr(n, "sym:name"));
    }

    /* Start generating the function */
    const String *outattributes = Getattr(n, "tmap:cstype:outattributes");
    if (outattributes)
      Printf(function_code, "  %s\n", outattributes);
    const String *csattributes = Getattr(n, "feature:cs:attributes");
    if (csattributes)
      Printf(function_code, "  %s\n", csattributes);
    const String *methodmods = Getattr(n, "feature:cs:methodmodifiers");
    methodmods = methodmods ? methodmods : (is_public(n) ? public_string : protected_string);
    Printf(function_code, "  %s static %s %s(", methodmods, return_type, func_name);
    Printv(imcall, imclass_name, ".", overloaded_name, "(", NIL);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required = emit_num_required(l);

    int gencomma = 0;

    /* Output each parameter */
    for (i = 0, p = l; i < num_arguments; i++) {

      /* Ignored parameters */
      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *param_type = NewString("");
      last_parm = p;

      /* Get the C# parameter type */
      if ((tm = Getattr(p, "tmap:cstype"))) {
	substituteClassname(pt, tm);
	String *inattributes = Getattr(p, "tmap:cstype:inattributes");
	Printf(param_type, "%s%s", inattributes ? (const String *) inattributes : empty_string, tm);
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No cstype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      if (gencomma)
	Printf(imcall, ", ");

      String *arg = makeParameterName(n, p, i, setter_flag);

      // Use typemaps to transform type used in C# wrapper function (in proxy class) to type used in PInvoke function (in intermediary class)
      if ((tm = Getattr(p, "tmap:csin"))) {
	substituteClassname(pt, tm);
	Replaceall(tm, "$csinput", arg);
	String *pre = Getattr(p, "tmap:csin:pre");
	if (pre) {
	  substituteClassname(pt, pre);
	  Replaceall(pre, "$csinput", arg);
          if (Len(pre_code) > 0)
            Printf(pre_code, "\n");
	  Printv(pre_code, pre, NIL);
	}
	String *post = Getattr(p, "tmap:csin:post");
	if (post) {
	  substituteClassname(pt, post);
	  Replaceall(post, "$csinput", arg);
          if (Len(post_code) > 0)
            Printf(post_code, "\n");
	  Printv(post_code, post, NIL);
	}
	Printv(imcall, tm, NIL);
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CSIN_UNDEF, input_file, line_number, "No csin typemap defined for %s\n", SwigType_str(pt, 0));
      }

      /* Add parameter to module class function */
      if (gencomma >= 2)
	Printf(function_code, ", ");
      gencomma = 2;
      Printf(function_code, "%s %s", param_type, arg);

      p = Getattr(p, "tmap:in:next");
      Delete(arg);
      Delete(param_type);
    }

    Printf(imcall, ")");
    Printf(function_code, ")");

    // Transform return type used in PInvoke function (in intermediary class) to type used in C# wrapper function (in module class)
    if ((tm = Swig_typemap_lookup_new("csout", n, "", 0))) {
      excodeSubstitute(n, tm, "csout", n);
      bool is_pre_code = Len(pre_code) > 0;
      bool is_post_code = Len(post_code) > 0;
      if (is_pre_code || is_post_code) {
        Replaceall(tm, "\n ", "\n   "); // add extra indentation to code in typemap
        if (is_post_code) {
          Insert(tm, 0, "\n    try ");
          Printv(tm, " finally {\n", post_code, "\n    }", NIL);
        } else {
          Insert(tm, 0, "\n    ");
        }
        if (is_pre_code) {
          Insert(tm, 0, pre_code);
          Insert(tm, 0, "\n");
        }
	Insert(tm, 0, "{");
	Printf(tm, "\n  }");
      }
      if (GetFlag(n, "feature:new"))
	Replaceall(tm, "$owner", "true");
      else
	Replaceall(tm, "$owner", "false");
      substituteClassname(t, tm);
      Replaceall(tm, "$imcall", imcall);
    } else {
      Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, "No csout typemap defined for %s\n", SwigType_str(t, 0));
    }

    if (proxy_flag && global_variable_flag) {
      // Properties
      if (generate_property_declaration_flag) {	// Ensure the declaration is generated just once should the property contain both a set and get
	// Get the C# variable type - obtained differently depending on whether a setter is required.
	String *variable_type = return_type;
	if (setter_flag) {
	  p = last_parm;	// (last parameter is the only parameter for properties)
	  SwigType *pt = Getattr(p, "type");
	  if ((tm = Getattr(p, "tmap:cstype"))) {
	    substituteClassname(pt, tm);
            String *cstypeout = Getattr(p, "tmap:cstype:out");	// the type in the cstype typemap's out attribute overrides the type in the typemap
	    variable_type = cstypeout ? cstypeout : tm;
	  } else {
	    Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, "No csvarin typemap defined for %s\n", SwigType_str(pt, 0));
	  }
	}
	const String *csattributes = Getattr(n, "feature:cs:attributes");
	if (csattributes)
	  Printf(module_class_code, "  %s\n", csattributes);
	const String *methodmods = Getattr(n, "feature:cs:methodmodifiers");
	if (!methodmods)
	  methodmods = (is_public(n) ? public_string : protected_string);
	Printf(module_class_code, "  %s static %s %s {", methodmods, variable_type, variable_name);
      }
      generate_property_declaration_flag = false;

      if (setter_flag) {
	// Setter method
	p = last_parm;		// (last parameter is the only parameter for properties)
	SwigType *pt = Getattr(p, "type");
	if ((tm = Getattr(p, "tmap:csvarin"))) {
	  substituteClassname(pt, tm);
	  Replaceall(tm, "$csinput", "value");
	  Replaceall(tm, "$imcall", imcall);
	  excodeSubstitute(n, tm, "csvarin", p);
	  Printf(module_class_code, "%s", tm);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, "No csvarin typemap defined for %s\n", SwigType_str(pt, 0));
	}
      } else {
	// Getter method
	if ((tm = Swig_typemap_lookup_new("csvarout", n, "", 0))) {
	  if (GetFlag(n, "feature:new"))
	    Replaceall(tm, "$owner", "true");
	  else
	    Replaceall(tm, "$owner", "false");
	  substituteClassname(t, tm);
	  Replaceall(tm, "$imcall", imcall);
	  excodeSubstitute(n, tm, "csvarout", n);
	  Printf(module_class_code, "%s", tm);
	} else {
	  Swig_warning(WARN_CSHARP_TYPEMAP_CSOUT_UNDEF, input_file, line_number, "No csvarout typemap defined for %s\n", SwigType_str(t, 0));
	}
      }
    } else {
      // Normal function call
      Printf(function_code, " %s\n\n", tm ? (const String *) tm : empty_string);
      Printv(module_class_code, function_code, NIL);
    }

    Delete(pre_code);
    Delete(post_code);
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
    String *feature = Getattr(n, "feature:cs:enum");
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
    String *symname = Getattr(n, "sym:name");

    // Check for the %csconstvalue feature
    String *value = Getattr(n, "feature:cs:constvalue");

    if (!value) {
      // The %csconst feature determines how the constant value is obtained
      int const_feature_flag = GetFlag(n, "feature:cs:const");

      if (const_feature_flag) {
	// Use the C syntax to make a true C# constant and hope that it compiles as C# code
	value = Getattr(n, "enumvalue") ? Copy(Getattr(n, "enumvalue")) : Copy(Getattr(n, "enumvalueex"));
      } else {
	// Get the enumvalue from a PINVOKE call
	if (!getCurrentClass() || !cparse_cplusplus) {
	  // Strange hack to change the name
	  Setattr(n, "name", Getattr(n, "value"));	/* for wrapping of enums in a namespace when emit_action is used */
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
   *   setter  - set this flag when wrapping member variables
   * Return:
   *   arg - a unique parameter name
   * ----------------------------------------------------------------------------- */

  String *makeParameterName(Node *n, Parm *p, int arg_num, bool setter) {

    String *arg = 0;
    String *pn = Getattr(p, "name");
    if (setter) {
      // Note that in C# properties, the input variable name is always called 'value'
      arg = NewString("value");
    } else {
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
    }

    return arg;
  }

  /* -----------------------------------------------------------------------------
   * emitTypeWrapperClass()
   * ----------------------------------------------------------------------------- */

  void emitTypeWrapperClass(String *classname, SwigType *type) {
    String *swigtype = NewString("");
    String *filen = NewStringf("%s%s.cs", SWIG_output_directory(), classname);
    File *f_swigtype = NewFile(filen, "w");
    if (!f_swigtype) {
      FileErrorDisplay(filen);
      SWIG_exit(EXIT_FAILURE);
    }
    Append(filenames_list, Copy(filen));
    Delete(filen);
    filen = NULL;

    // Start writing out the type wrapper class file
    emitBanner(f_swigtype);

    addOpenNamespace(namespce, f_swigtype);

    // Pure C# baseclass and interfaces
    const String *pure_baseclass = typemapLookup("csbase", type, WARN_NONE);
    const String *pure_interfaces = typemapLookup("csinterfaces", type, WARN_NONE);

    // Emit the class
    Printv(swigtype, typemapLookup("csimports", type, WARN_NONE),	// Import statements
	   "\n", NIL);

    // Class attributes
    const String *csattributes = typemapLookup("csattributes", type, WARN_NONE);
    if (csattributes && *Char(csattributes))
      Printf(swigtype, "%s\n", csattributes);

    Printv(swigtype, typemapLookup("csclassmodifiers", type, WARN_CSHARP_TYPEMAP_CLASSMOD_UNDEF),	// Class modifiers
	   " $csclassname",	// Class name and base class
	   (*Char(pure_baseclass) || *Char(pure_interfaces)) ? " : " : "", pure_baseclass, ((*Char(pure_baseclass)) && *Char(pure_interfaces)) ?	// Interfaces
	   ", " : "", pure_interfaces, " {", typemapLookup("csbody", type, WARN_CSHARP_TYPEMAP_CSBODY_UNDEF),	// main body of class
	   typemapLookup("cscode", type, WARN_NONE),	// extra C# code
	   "}\n", NIL);

    Replaceall(swigtype, "$csclassname", classname);
    Replaceall(swigtype, "$module", module_class_name);
    Replaceall(swigtype, "$imclassname", imclass_name);
    Replaceall(swigtype, "$dllimport", dllimport);

    Printv(f_swigtype, swigtype, NIL);

    addCloseNamespace(namespce, f_swigtype);

    Close(f_swigtype);
    Delete(swigtype);
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
   * addThrows()
   // TODO: remove
   * ----------------------------------------------------------------------------- */
  void addThrows(Node *, const String *, Node *) {
  }

  /* -----------------------------------------------------------------------------
   * canThrow()
   * Determine whether the code in the typemap can throw a C# exception.
   * If so, note it for later when excodeSubstitute() is called.
   * ----------------------------------------------------------------------------- */

  void canThrow(Node *n, const String *typemap, Node *parameter) {
    String *canthrow_attribute = NewStringf("tmap:%s:canthrow", typemap);
    String *canthrow = Getattr(parameter, canthrow_attribute);
    if (canthrow)
      Setattr(n, "csharp:canthrow", "1");
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
    if (Getattr(n, "csharp:canthrow")) {
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

  /* -----------------------------------------------------------------------------
   * addOpenNamespace()
   * ----------------------------------------------------------------------------- */

  void addOpenNamespace(String *namspace, File *file) {
    if (namspace)
      if (Len(namspace) > 0)
	Printf(file, "namespace %s {\n", namspace);
  }

  /* -----------------------------------------------------------------------------
   * addCloseNamespace()
   * ----------------------------------------------------------------------------- */

  void addCloseNamespace(String *namspace, File *file) {
    if (namspace)
      if (Len(namspace) > 0)
	Printf(file, "\n}\n");
  }

  /*----------------------------------------------------------------------
   * Start of director methods
   *--------------------------------------------------------------------*/

#if 0
  /*----------------------------------------------------------------------
   * emitDirectorUpcalls()
   *--------------------------------------------------------------------*/

  void emitDirectorUpcalls() {
    if (n_dmethods) {
      Wrapper *w = NewWrapper();
      String *dmethod_data = NewString("");
      int n_methods = 0;
      Iterator udata_iter;

      udata_iter = First(dmethods_seq);
      while (udata_iter.item) {
	UpcallData *udata = udata_iter.item;
	Printf(dmethod_data, "  { \"%s\", \"%s\" }", Getattr(udata, "imclass_method"), Getattr(udata, "imclass_fdesc"));
	++n_methods;

	udata_iter = Next(udata_iter);

	if (udata_iter.item)
	  Putc(',', dmethod_data);
	Putc('\n', dmethod_data);
      }


      Wrapper_print(w, f_wrappers);
      Delete(dmethod_data);
      Delete(swig_module_init);
      DelWrapper(w);
    }
  }
#endif

  /*----------------------------------------------------------------------
   * emitDirectorExtraMethods()
   *
   * This is where the director connect method is
   * generated.
   *--------------------------------------------------------------------*/
  void emitDirectorExtraMethods(Node *n) {
    if (!Swig_directorclass(n))
      return;

    // Output the director connect method:
    String *norm_name = SwigType_namestr(Getattr(n, "name"));
    String *swig_director_connect = NewStringf("%s_director_connect", proxy_class_name);
    String *sym_name = Getattr(n, "sym:name");
    Wrapper *code_wrap;

    Printv(imclass_class_code, "\n  [DllImport(\"", dllimport, "\", EntryPoint=\"CSharp_", swig_director_connect, "\")]\n", NIL);
    Printf(imclass_class_code, "  public static extern void %s(HandleRef jarg1", swig_director_connect);

    code_wrap = NewWrapper();
    Printf(code_wrap->def, "SWIGEXPORT void SWIGSTDCALL CSharp_%s(void *objarg", swig_director_connect);

    Printf(code_wrap->code, "  %s *obj = (%s *)objarg;\n", norm_name, norm_name);
    Printf(code_wrap->code, "  SwigDirector_%s *director = dynamic_cast<SwigDirector_%s *>(obj);\n", sym_name, sym_name);
    // TODO: if statement not needed?? - Java too
    Printf(code_wrap->code, "  if (director) {\n");
    Printf(code_wrap->code, "    director->swig_connect_director(");

    for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
      UpcallData *udata = Getitem(dmethods_seq, i);
      String *methid = Getattr(udata, "class_methodidx");

      Printf(code_wrap->def, ", ");
      if (i != first_class_dmethod)
	Printf(code_wrap->code, ", ");
      Printf(code_wrap->def, "SwigDirector_%s::SWIG_Callback%s_t callback%s", sym_name, methid, methid);
      Printf(code_wrap->code, "callback%s", methid);
      Printf(imclass_class_code, ", %s.SwigDelegate%s_%s delegate%s", sym_name, sym_name, methid, methid);
    }

    Printf(code_wrap->def, ") {\n");
    Printf(code_wrap->code, ");\n");
    Printf(imclass_class_code, ");\n");
    Printf(code_wrap->code, "  }\n");
    Printf(code_wrap->code, "}\n");

    Wrapper_print(code_wrap, f_wrappers);
    DelWrapper(code_wrap);

    Delete(swig_director_connect);
  }

  /* ---------------------------------------------------------------
   * classDirectorMethod()
   *
   * Emit a virtual director method to pass a method call on to the 
   * underlying Java object.
   *
   * --------------------------------------------------------------- */

  int classDirectorMethod(Node *n, Node *parent, String *super) {
    String *empty_str = NewString("");
    String *classname = Getattr(parent, "sym:name");
    String *c_classname = Getattr(parent, "name");
    String *name = Getattr(n, "name");
    String *symname = Getattr(n, "sym:name");
    SwigType *type = Getattr(n, "type");
    SwigType *returntype = Getattr(n, "returntype");
    String *overloaded_name = getOverloadedName(n);
    String *storage = Getattr(n, "storage");
    String *value = Getattr(n, "value");
    String *decl = Getattr(n, "decl");
    String *declaration = NewString("");
    String *tm;
    Parm *p;
    int i;
    Wrapper *w = NewWrapper();
    ParmList *l = Getattr(n, "parms");
    bool is_void = !(Cmp(returntype, "void"));
    String *qualified_return = NewString("");
    bool pure_virtual = (!(Cmp(storage, "virtual")) && !(Cmp(value, "0")));
    int status = SWIG_OK;
    bool output_director = true;
    String *dirclassname = directorClassName(parent);
    String *qualified_name = NewStringf("%s::%s", dirclassname, name);
    SwigType *c_ret_type = NULL;
    String *jupcall_args = NewString("");
    String *imclass_dmethod;
    String *callback_typedef_parms = NewString("");
    String *delegate_parms = NewString("");
    String *proxy_method_types = NewString("");
    String *callback_def = NewString("");
    String *callback_code = NewString("");
    String *imcall_args = NewString("");
    int gencomma = 0;
    bool ignored_method = GetFlag(n, "feature:ignore") ? true : false;

    // Kludge Alert: functionWrapper sets sym:overload properly, but it
    // isn't at this point, so we have to manufacture it ourselves. At least
    // we're consistent with the sym:overload name in functionWrapper. (?? when
    // does the overloaded method name get set?)

    imclass_dmethod = NewStringf("SwigDirector_%s", Swig_name_member(classname, overloaded_name));

    if (returntype) {

      qualified_return = SwigType_rcaststr(returntype, "c_result");

      if (!is_void && !ignored_method) {
	if (!SwigType_isclass(returntype)) {
	  if (!(SwigType_ispointer(returntype) || SwigType_isreference(returntype))) {
	    Wrapper_add_localv(w, "c_result", SwigType_lstr(returntype, "c_result"), NIL);
	  } else {
	    String *base_typename = SwigType_base(returntype);
	    String *resolved_typename = SwigType_typedef_resolve_all(base_typename);
	    Symtab *symtab = Getattr(n, "sym:symtab");
	    Node *typenode = Swig_symbol_clookup(resolved_typename, symtab);

	    if (SwigType_ispointer(returntype) || (typenode && Getattr(typenode, "abstract"))) {
	      /* initialize pointers to something sane. Same for abstract
	         classes when a reference is returned. */
	      Wrapper_add_localv(w, "c_result", SwigType_lstr(returntype, "c_result"), "= 0", NIL);
	    } else {
	      /* If returning a reference, initialize the pointer to a sane
	         default - if a C# exception occurs, then the pointer returns
	         something other than a NULL-initialized reference. */
	      String *non_ref_type = Copy(returntype);

	      /* Remove reference and const qualifiers */
	      Replaceall(non_ref_type, "r.", "");
	      Replaceall(non_ref_type, "q(const).", "");
	      Wrapper_add_localv(w, "result_default", "static", SwigType_str(non_ref_type, "result_default"), "=", SwigType_str(non_ref_type, "()"), NIL);
	      Wrapper_add_localv(w, "c_result", SwigType_lstr(returntype, "c_result"), "= &result_default", NIL);

	      Delete(non_ref_type);
	    }

	    Delete(base_typename);
	    Delete(resolved_typename);
	  }
	} else {
	  SwigType *vt;

	  vt = cplus_value_type(returntype);
	  if (!vt) {
	    Wrapper_add_localv(w, "c_result", SwigType_lstr(returntype, "c_result"), NIL);
	  } else {
	    Wrapper_add_localv(w, "c_result", SwigType_lstr(vt, "c_result"), NIL);
	    Delete(vt);
	  }
	}
      }

      /* Create the intermediate class wrapper */
      Parm *tp = NewParmFromNode(returntype, empty_str, n);

      tm = Swig_typemap_lookup_new("imtype", tp, "", 0);
      if (tm) {
	String *imtypeout = Getattr(tp, "tmap:imtype:out");	// the type in the imtype typemap's out attribute overrides the type in the typemap
	if (imtypeout)
	  tm = imtypeout;
	Printf(callback_def, "  private %s SwigDirector%s(", tm, overloaded_name);
	if (!ignored_method)
	  Printf(director_delegate_definitions, "  public delegate %s", tm);
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", SwigType_str(returntype, 0));
      }

      Parm *retpm = NewParmFromNode(returntype, empty_str, n);

      if ((c_ret_type = Swig_typemap_lookup_new("ctype", retpm, "", 0))) {

	if (!is_void && !ignored_method) {
	  String *jretval_decl = NewStringf("%s jresult", c_ret_type);
	  Wrapper_add_localv(w, "jresult", jretval_decl, " = 0", NIL);
	  Delete(jretval_decl);
	}
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(returntype, 0));
	output_director = false;
      }

      Delete(retpm);
    }

    /* Go through argument list, attach lnames for arguments */
    for (i = 0, p = l; p; p = nextSibling(p), ++i) {
      String *arg = Getattr(p, "name");
      String *lname = NewString("");

      if (!arg && Cmp(Getattr(p, "type"), "void")) {
	lname = NewStringf("arg%d", i);
	Setattr(p, "name", lname);
      } else
	lname = arg;

      Setattr(p, "lname", lname);
    }

    /* Attach the standard typemaps */
    Swig_typemap_attach_parms("out", l, 0);
    Swig_typemap_attach_parms("ctype", l, 0);
    Swig_typemap_attach_parms("imtype", l, 0);
    Swig_typemap_attach_parms("cstype", l, 0);
    Swig_typemap_attach_parms("directorin", l, 0);
    Swig_typemap_attach_parms("csdirectorin", l, 0);

    /* Preamble code */
    if (!ignored_method)
      Printf(w->code, "if (!swig_callback%s) {\n", overloaded_name);

    if (!pure_virtual) {
      String *super_call = Swig_method_call(super, l);
      if (is_void) {
	Printf(w->code, "%s;\n", super_call);
	if (!ignored_method)
	  Printf(w->code, "return;\n");
      } else {
	Printf(w->code, "return %s;\n", super_call);
      }
      Delete(super_call);
    } else {
      Printf(w->code, " throw Swig::DirectorPureVirtualException(\"%s::%s\");\n", SwigType_namestr(c_classname), SwigType_namestr(name));
    }

    if (!ignored_method)
      Printf(w->code, "} else {\n");

    /* Go through argument list, convert from native to Java */
    for (p = l; p; /* empty */ ) {
      /* Is this superfluous? */
      while (checkAttribute(p, "tmap:directorin:numinputs", "0")) {
	p = Getattr(p, "tmap:directorin:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *ln = Copy(Getattr(p, "name"));
      String *c_param_type = NULL;
      String *c_decl = NewString("");
      String *arg = NewString("");

      Printf(arg, "j%s", ln);

      /* Add various typemap's 'throws' clauses */
      addThrows(n, "tmap:directorin", p);
      addThrows(n, "tmap:out", p);

      /* And add to the upcall args */
      if (gencomma > 0)
	Printf(jupcall_args, ", ");
      Printf(jupcall_args, "%s", arg);

      /* Get parameter's intermediary C type */
      if ((c_param_type = Getattr(p, "tmap:ctype"))) {
	String *ctypeout = Getattr(p, "tmap:ctype:out");	// the type in the ctype typemap's out attribute overrides the type in the typemap
	if (ctypeout)
	  c_param_type = ctypeout;

	Parm *tp = NewParmFromNode(c_param_type, empty_str, n);
	String *desc_tm = NULL;

	/* Add to local variables */
	Printf(c_decl, "%s %s", c_param_type, arg);
	if (!ignored_method)
	  Wrapper_add_localv(w, arg, c_decl, (!(SwigType_ispointer(pt) || SwigType_isreference(pt)) ? "" : "= 0"), NIL);

	/* Add input marshalling code */
	if ((desc_tm = Swig_typemap_lookup_new("directorin", tp, "", 0))
	    && (tm = Getattr(p, "tmap:directorin"))) {

	  Replaceall(tm, "$input", arg);
	  Replaceall(tm, "$owner", "0");

	  if (Len(tm))
	    if (!ignored_method)
	      Printf(w->code, "%s\n", tm);

	  Delete(tm);

	  /* Add C type to callback typedef */
	  if (gencomma > 0)
	    Printf(callback_typedef_parms, ", ");
	  Printf(callback_typedef_parms, "%s", c_param_type);

	  /* Add parameter to the intermediate class code if generating the
	   * intermediate's upcall code */
	  if ((tm = Getattr(p, "tmap:imtype"))) {

	    String *imtypeout = Getattr(p, "tmap:imtype:out");	// the type in the imtype typemap's out attribute overrides the type in the typemap
	    if (imtypeout)
	      tm = imtypeout;

	    String *din = Copy(Getattr(p, "tmap:csdirectorin"));

	    if (din) {
	      Replaceall(din, "$module", module_class_name);
	      Replaceall(din, "$imclassname", imclass_name);
	      substituteClassname(pt, din);
	      Replaceall(din, "$iminput", ln);

	      if (gencomma > 0) {
		Printf(delegate_parms, ", ");
		Printf(proxy_method_types, ", ");
		Printf(imcall_args, ", ");
	      }
	      Printf(delegate_parms, "%s %s", tm, ln);

	      if (Cmp(din, ln)) {
		Printv(imcall_args, din, NIL);
	      } else
		Printv(imcall_args, ln, NIL);

	      /* Get the C# parameter type */
	      if ((tm = Getattr(p, "tmap:cstype"))) {
		substituteClassname(pt, tm);
		Printf(proxy_method_types, "typeof(%s)", tm);
	      } else {
		Swig_warning(WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF, input_file, line_number, "No cstype typemap defined for %s\n", SwigType_str(pt, 0));
	      }
	    } else {
	      Swig_warning(WARN_CSHARP_TYPEMAP_CSDIRECTORIN_UNDEF, input_file, line_number, "No csdirectorin typemap defined for %s\n", SwigType_str(pt, 0));
	      output_director = false;
	    }
	  } else {
	    Swig_warning(WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", SwigType_str(pt, 0));
	    output_director = false;
	  }

	  p = Getattr(p, "tmap:directorin:next");

	  Delete(desc_tm);
	} else {
	  if (!desc_tm) {
	    Swig_warning(WARN_CSHARP_TYPEMAP_CSDIRECTORIN_UNDEF, input_file, line_number,
			 "No or improper directorin typemap defined for %s\n", SwigType_str(c_param_type, 0));
	    p = nextSibling(p);
	  } else if (!tm) {
	    Swig_warning(WARN_CSHARP_TYPEMAP_CSDIRECTORIN_UNDEF, input_file, line_number,
			 "No or improper directorin typemap defined for argument %s\n", SwigType_str(pt, 0));
	    p = nextSibling(p);
	  }

	  output_director = false;
	}

	Delete(tp);
      } else {
	Swig_warning(WARN_CSHARP_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(pt, 0));
	output_director = false;
	p = nextSibling(p);
      }

      gencomma++;
      Delete(arg);
      Delete(c_decl);
      Delete(c_param_type);
    }

    /* header declaration, start wrapper definition */
    String *target;
    SwigType *rtype = Getattr(n, "conversion_operator") ? 0 : type;
    target = Swig_method_decl(rtype, decl, qualified_name, l, 0, 0);
    Printf(w->def, "%s", target);
    Delete(qualified_name);
    Delete(target);
    target = Swig_method_decl(rtype, decl, name, l, 0, 1);
    Printf(declaration, "    virtual %s", target);
    Delete(target);

    // Get any Java exception classes in the throws typemap
    ParmList *throw_parm_list = NULL;

    if ((tm = Swig_typemap_lookup_new("out", n, "", 0)))
      addThrows(n, "tmap:out", n);

    if ((throw_parm_list = Getattr(n, "throws")) || Getattr(n, "throw")) {
      int gencomma = 0;

      Append(w->def, " throw(");
      Append(declaration, " throw(");

      if (throw_parm_list)
	Swig_typemap_attach_parms("throws", throw_parm_list, 0);
      for (p = throw_parm_list; p; p = nextSibling(p)) {
	if ((tm = Getattr(p, "tmap:throws"))) {
	  addThrows(n, "tmap:throws", p);

	  if (gencomma++) {
	    Append(w->def, ", ");
	    Append(declaration, ", ");
	  }

	  Printf(w->def, "%s", SwigType_str(Getattr(p, "type"), 0));
	  Printf(declaration, "%s", SwigType_str(Getattr(p, "type"), 0));
	}
      }

      Append(w->def, ")");
      Append(declaration, ")");
    }

    Append(w->def, " {");
    Append(declaration, ";\n");

    /* Finish off the inherited upcall's definition */

    Printf(callback_def, "%s)", delegate_parms);
    Printf(callback_def, " {\n");

    /* Emit the intermediate class's upcall to the actual class */

    String *upcall = NewStringf("%s(%s)", symname, imcall_args);

    if (!is_void) {
      Parm *tp = NewParmFromNode(returntype, empty_str, n);

      tm = Swig_typemap_lookup_new("csdirectorout", tp, "", 0);
      if (tm) {
	substituteClassname(returntype, tm);
	Replaceall(tm, "$cscall", upcall);

	Printf(callback_code, "    return %s;\n", tm);
      }

      Delete(tm);
      Delete(tp);
    } else
      Printf(callback_code, "    %s;\n", upcall);

    Printf(callback_code, "  }\n");
    Delete(upcall);

    if (!ignored_method) {
      if (!is_void)
	Printf(w->code, "jresult = (%s) ", c_ret_type);

      Printf(w->code, "swig_callback%s(%s);\n", overloaded_name, jupcall_args);

      if (!is_void) {
	String *jresult_str = NewString("jresult");
	String *result_str = NewString("c_result");
	Parm *tp = NewParmFromNode(returntype, result_str, n);

	/* Copy jresult into c_result... */
	if ((tm = Swig_typemap_lookup_new("directorout", tp, result_str, w))) {
	  addThrows(n, "tmap:directorout", tp);
	  Replaceall(tm, "$input", jresult_str);
	  Replaceall(tm, "$result", result_str);
	  Printf(w->code, "%s\n", tm);
	} else {
	  Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number,
		       "Unable to use return type %s in director method %s::%s (skipping method).\n", SwigType_str(returntype, 0),
		       SwigType_namestr(c_classname), SwigType_namestr(name));
	  output_director = false;
	}

	Delete(tp);
	Delete(jresult_str);
	Delete(result_str);
      }

      /* Terminate wrapper code */
      Printf(w->code, "}\n");
      if (!is_void)
	Printf(w->code, "return %s;", qualified_return);
    }

    Printf(w->code, "}");

    // We expose protected methods via an extra public inline method which makes a straight call to the wrapped class' method
    String *inline_extra_method = NewString("");
    if (dirprot_mode() && !is_public(n) && !pure_virtual) {
      Printv(inline_extra_method, declaration, NIL);
      String *extra_method_name = NewStringf("%sSwigPublic", name);
      Replaceall(inline_extra_method, name, extra_method_name);
      Replaceall(inline_extra_method, ";\n", " {\n      ");
      if (!is_void)
	Printf(inline_extra_method, "return ");
      String *methodcall = Swig_method_call(super, l);
      Printv(inline_extra_method, methodcall, ";\n    }\n", NIL);
      Delete(methodcall);
      Delete(extra_method_name);
    }

    /* emit code */
    if (status == SWIG_OK && output_director) {
      if (!is_void) {
	Replaceall(w->code, "$null", qualified_return);
      } else {
	Replaceall(w->code, "$null", "");
      }
      if (!ignored_method)
	Printv(director_delegate_callback, "\n", callback_def, callback_code, NIL);
      if (!Getattr(n, "defaultargs")) {
	Wrapper_print(w, f_directors);
	Printv(f_directors_h, declaration, NIL);
	Printv(f_directors_h, inline_extra_method, NIL);
      }
    }

    if (!ignored_method) {
      /* Emit the actual upcall through */
      UpcallData *udata = addUpcallMethod(imclass_dmethod, symname, decl, overloaded_name);
      String *methid = Getattr(udata, "class_methodidx");

      Printf(director_callback_typedefs, "    typedef %s (SWIGSTDCALL* SWIG_Callback%s_t)(", c_ret_type, methid);
      Printf(director_callback_typedefs, "%s);\n", callback_typedef_parms);
      Printf(director_callbacks, "    SWIG_Callback%s_t swig_callback%s;\n", methid, overloaded_name);

      Printf(director_delegate_definitions, " SwigDelegate%s_%s(%s);\n", classname, methid, delegate_parms);
      Printf(director_delegate_instances, "  private SwigDelegate%s_%s swigDelegate%s;\n", classname, methid, methid);
      Printf(director_method_types, "  private static Type[] swigMethodTypes%s = new Type[] { %s };\n", methid, proxy_method_types);
      Printf(director_connect_parms, "SwigDirector%s%s delegate%s", classname, methid, methid);
    }

    Delete(qualified_return);
    Delete(c_ret_type);
    Delete(declaration);
    Delete(callback_typedef_parms);
    Delete(delegate_parms);
    Delete(proxy_method_types);
    Delete(callback_def);
    Delete(callback_code);
    DelWrapper(w);

    return status;
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
      String *pname = Getattr(p, "name");

      if (!pname) {
	pname = NewStringf("arg%d", argidx++);
	Setattr(p, "name", pname);
      }
    }

    // TODO: Is this copy needed?
    parms = CopyParmList(superparms);

    if (!Getattr(n, "defaultargs")) {
      /* constructor */
      {
	String *basetype = Getattr(parent, "classtype");
	String *target = Swig_method_decl(0, decl, classname, parms, 0, 0);
	String *call = Swig_csuperclass_call(0, basetype, superparms);
	String *classtype = SwigType_namestr(Getattr(n, "name"));

	Printf(f_directors, "%s::%s : %s, %s {\n", classname, target, call, Getattr(parent, "director:ctor"));
	Printf(f_directors, "  swig_init_callbacks();\n");
	Printf(f_directors, "}\n\n");

	Delete(classtype);
	Delete(target);
	Delete(call);
      }

      /* constructor header */
      {
	String *target = Swig_method_decl(0, decl, classname, parms, 0, 1);
	Printf(f_directors_h, "    %s;\n", target);
	Delete(target);
      }
    }

    Delete(sub);
    Delete(supername);
    Delete(parms);
    return Language::classDirectorConstructor(n);
  }

  /* ------------------------------------------------------------
   * classDirectorDefaultConstructor()
   * ------------------------------------------------------------ */

  int classDirectorDefaultConstructor(Node *n) {
    String *classname = Swig_class_name(n);
    String *classtype = SwigType_namestr(Getattr(n, "name"));
    Wrapper *w = NewWrapper();

    Printf(w->def, "SwigDirector_%s::SwigDirector_%s() : %s {", classname, classname, Getattr(n, "director:ctor"));
    Printf(w->code, "}\n");
    Wrapper_print(w, f_directors);

    Printf(f_directors_h, "    SwigDirector_%s();\n", classname);
    DelWrapper(w);
    Delete(classtype);
    Delete(classname);
    return Language::classDirectorDefaultConstructor(n);
  }


  /* ------------------------------------------------------------
   * classDirectorInit()
   * ------------------------------------------------------------ */

  int classDirectorInit(Node *n) {
    Delete(none_comparison);
    none_comparison = NewString("");	// not used

    Delete(director_ctor_code);
    director_ctor_code = NewString("$director_new");

    Java_director_declaration(n);

    Printf(f_directors_h, "%s {\n", Getattr(n, "director:decl"));
    Printf(f_directors_h, "\npublic:\n");

    /* Keep track of the director methods for this class */
    first_class_dmethod = curr_class_dmethod = n_dmethods;

    director_callback_typedefs = NewString("");
    director_callbacks = NewString("");
    director_delegate_callback = NewString("");
    director_delegate_definitions = NewString("");
    director_delegate_instances = NewString("");
    director_method_types = NewString("");
    director_connect_parms = NewString("");

    return Language::classDirectorInit(n);
  }

  /* ----------------------------------------------------------------------
   * classDirectorDestructor()
   * ---------------------------------------------------------------------- */

  int classDirectorDestructor(Node *n) {
    Node *current_class = getCurrentClass();
    String *full_classname = Getattr(current_class, "name");
    String *classname = Swig_class_name(current_class);
    Wrapper *w = NewWrapper();

    if (Getattr(n, "throw")) {
      Printf(f_directors_h, "    virtual ~SwigDirector_%s() throw ();\n", classname);
      Printf(w->def, "SwigDirector_%s::~SwigDirector_%s() throw () {\n", classname, classname);
    } else {
      Printf(f_directors_h, "    virtual ~SwigDirector_%s();\n", classname);
      Printf(w->def, "SwigDirector_%s::~SwigDirector_%s() {\n", classname, classname);
    }

    /* Ensure that correct directordisconnect typemap's method name is called
     * here: */

    const String *disconn_tm = NULL;
    Node *disconn_attr = NewHash();
    String *disconn_methodname = NULL;

    disconn_tm = typemapLookup("directordisconnect", full_classname, WARN_NONE, disconn_attr);
    disconn_methodname = Getattr(disconn_attr, "tmap:directordisconnect:methodname");

    Printv(w->code, "}\n", NIL);

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
    String *director_classname = directorClassName(n);

    Wrapper *w = NewWrapper();

    if (Len(director_callback_typedefs) > 0) {
      Printf(f_directors_h, "\n%s", director_callback_typedefs);
    }

    Printf(f_directors_h, "    void swig_connect_director(");

    Printf(w->def, "void %s::swig_connect_director(", director_classname);

    for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
      UpcallData *udata = Getitem(dmethods_seq, i);
      String *methid = Getattr(udata, "class_methodidx");
      String *overname = Getattr(udata, "overname");

      Printf(f_directors_h, "SWIG_Callback%s_t callback%s", methid, overname);
      Printf(w->def, "SWIG_Callback%s_t callback%s", methid, overname);
      Printf(w->code, "swig_callback%s = callback%s;\n", overname, overname);
      if (i != curr_class_dmethod - 1) {
	Printf(f_directors_h, ", ");
	Printf(w->def, ", ");
      }
    }

    Printf(f_directors_h, ");\n");
    Printf(w->def, ") {");


    if (Len(director_callback_typedefs) > 0) {
      Printf(f_directors_h, "\nprivate:\n%s", director_callbacks);
    }
    Printf(f_directors_h, "    void swig_init_callbacks();\n");
    Printf(f_directors_h, "};\n\n");
    Printf(w->code, "}\n\n");

    Printf(w->code, "void %s::swig_init_callbacks() {\n", director_classname);
    for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
      UpcallData *udata = Getitem(dmethods_seq, i);
      String *overname = Getattr(udata, "overname");
      Printf(w->code, "swig_callback%s = 0;\n", overname);
    }
    Printf(w->code, "}");

    Wrapper_print(w, f_directors);

    DelWrapper(w);

    return Language::classDirectorEnd(n);
  }

  /* --------------------------------------------------------------------
   * classDirectorDisown()
   * ------------------------------------------------------------------*/
  virtual int classDirectorDisown(Node *n) {
    (void) n;
    return SWIG_OK;
  }

  /*----------------------------------------------------------------------
   * extraDirectorProtectedCPPMethodsRequired()
   *--------------------------------------------------------------------*/

  bool extraDirectorProtectedCPPMethodsRequired() const {
    return false;
  }

  /*----------------------------------------------------------------------
   * Java_director_declaration()
   *
   * Generate the director class's declaration
   * e.g. "class SwigDirector_myclass : public myclass, public Swig::Director {"
   *--------------------------------------------------------------------*/
 
  void Java_director_declaration(Node *n) {

    String *base = Getattr(n, "classtype");
    String *class_ctor = NewString("Swig::Director()");

    String *classname = Swig_class_name(n);
    String *directorname = NewStringf("SwigDirector_%s", classname);
    String *declaration = Swig_class_declaration(n, directorname);

    Printf(declaration, " : public %s, public Swig::Director", base);

    // Stash stuff for later.
    Setattr(n, "director:decl", declaration);
    Setattr(n, "director:ctor", class_ctor);
  }

};				/* class CSHARP */

/* -----------------------------------------------------------------------------
 * swig_csharp()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_csharp() {
  return new CSHARP();
}
extern "C" Language *swig_csharp(void) {
  return new_swig_csharp();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *CSHARP::usage = (char *) "\
C# Options (available with -csharp)\n\
     -dllimport <dl> - Override DllImport attribute name to <dl>\n\
     -namespace <nm> - Generate wrappers into C# namespace <nm>\n\
     -noproxy        - Generate the low-level functional interface instead\n\
                       of proxy classes\n\
     -oldvarnames    - old intermediary method names for variable wrappers\n\
\n";
