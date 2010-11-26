/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * go.cxx
 *
 * Go language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_go_cxx[] = "$Id";

#include "swigmod.h"
#include "cparse.h"
#include <ctype.h>
#include <string>

class GO:public Language {
  static const char *const usage;

  // Go package name.
  String *package;
  // Flag for generating gccgo output.
  bool gccgo_flag;
  // Prefix to use with gccgo.
  String *go_prefix;
  // Name of shared library to import.
  String *soname;
  // Size in bits of the C type "long".
  int long_type_size;

  /* Output files */
  File *f_c_begin;
  File *f_go_begin;
  File *f_gc_begin;

  /* Output fragments */
  File *f_c_runtime;
  File *f_c_header;
  File *f_c_wrappers;
  File *f_c_init;
  File *f_c_directors;
  File *f_c_directors_h;
  File *f_go_runtime;
  File *f_go_header;
  File *f_go_wrappers;
  File *f_go_once;
  File *f_gc_runtime;
  File *f_gc_header;
  File *f_gc_wrappers;
  File *f_gc_once;

  // True if we imported a module.
  bool saw_import;
  // If not NULL, name of import package being processed.
  String *imported_package;
  // Build interface methods while handling a class.  This is only
  // non-NULL when we are handling methods.
  String *interfaces;
  // The class node while handling a class.  This is only non-NULL
  // when we are handling methods.
  Node *class_node;
  // The class name while handling a class.  This is only non-NULL
  // when we are handling methods.  This is the name of the class as
  // SWIG sees it.
  String *class_name;
  // The receiver name while handling a class.  This is only non-NULL
  // when we are handling methods.  This is the name of the class
  // as run through goCPointerType.
  String *class_receiver;
  // A hash table of method names that we have seen when processing a
  // class.  This lets us detect base class methods that we don't want
  // to use.
  Hash *class_methods;
  // True when we are generating the wrapper functions for a variable.
  bool making_variable_wrappers;
  // True when working with a static member function.
  bool is_static_member_function;
  // A hash table of types that we have seen but which may not have
  // been defined.  The index is a SwigType.
  Hash *undefined_types;
  // A hash table of classes which were defined.  The index is a Go
  // type name.
  Hash *defined_types;

public:
  GO():package(NULL),
     gccgo_flag(false),
     go_prefix(NULL),
     soname(NULL),
     long_type_size(32),
     f_c_begin(NULL),
     f_go_begin(NULL),
     f_gc_begin(NULL),
     f_c_runtime(NULL),
     f_c_header(NULL),
     f_c_wrappers(NULL),
     f_c_init(NULL),
     f_c_directors(NULL),
     f_c_directors_h(NULL),
     f_go_runtime(NULL),
     f_go_header(NULL),
     f_go_wrappers(NULL),
     f_go_once(NULL),
     f_gc_runtime(NULL),
     f_gc_header(NULL),
     f_gc_wrappers(NULL),
     f_gc_once(NULL),
     saw_import(false),
     imported_package(NULL),
     interfaces(NULL),
     class_receiver(NULL),
     class_methods(NULL),
     making_variable_wrappers(false),
     is_static_member_function(false),
     undefined_types(NULL),
     defined_types(NULL) {
    director_multiple_inheritance = 1;
    director_language = 1;
    director_prot_ctor_code = NewString("_swig_gopanic(\"accessing abstract class or protected constructor\");");
  }

private:
  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */
  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("go");

    // Process command line options.
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-package") == 0) {
	  if (argv[i + 1]) {
	    package = NewString(argv[i + 1]);
	    Swig_mark_arg(i);
	    Swig_mark_arg(i + 1);
	    i++;
	  } else {
	    Swig_arg_error();
	  }
	} else if (strcmp(argv[i], "-gccgo") == 0) {
	  Swig_mark_arg(i);
	  gccgo_flag = true;
	} else if (strcmp(argv[i], "-go-prefix") == 0) {
	  if (argv[i + 1]) {
	    go_prefix = NewString(argv[i + 1]);
	    Swig_mark_arg(i);
	    Swig_mark_arg(i + 1);
	    i++;
	  } else {
	    Swig_arg_error();
	  }
	} else if (strcmp(argv[i], "-soname") == 0) {
	  if (argv[i + 1]) {
	    soname = NewString(argv[i + 1]);
	    Swig_mark_arg(i);
	    Swig_mark_arg(i + 1);
	    i++;
	  } else {
	    Swig_arg_error();
	  }
	} else if (strcmp(argv[i], "-longsize") == 0) {
	  if (argv[i + 1]) {
	    long_type_size = atoi(argv[i + 1]);
	    if (long_type_size != 32 && long_type_size != 64) {
	      Printf(stderr, "-longsize not 32 or 64\n");
	      Swig_arg_error();
	    }
	    Swig_mark_arg(i);
	    Swig_mark_arg(i + 1);
	    ++i;
	  } else {
	    Swig_arg_error();
	  }
	} else if (strcmp(argv[i], "-help") == 0) {
	  Printf(stdout, "%s\n", usage);
	}
      }
    }

    if (gccgo_flag && !go_prefix) {
      go_prefix = NewString("go");
    }

    // Add preprocessor symbol to parser.
    Preprocessor_define("SWIGGO 1", 0);

    if (gccgo_flag) {
      Preprocessor_define("SWIGGO_GCCGO 1", 0);
    }

    if (long_type_size == 32) {
      Preprocessor_define("SWIGGO_LONG_TYPE_SIZE 32", 0);
    } else {
      Preprocessor_define("SWIGGO_LONG_TYPE_SIZE 64", 0);
    }

    // Add typemap definitions.
    SWIG_typemap_lang("go");
    SWIG_config_file("go.swg");

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   *
   * For 6g/8g, we are going to create the following files:
   *
   * 1) A .c or .cxx file compiled with gcc.  This file will contain
   *    function wrappers.  Each wrapper will take a pointer to a
   *    struct holding the arguments, unpack them, and call the real
   *    function.
   *
   * 2) A .go file which defines the Go form of all types, and which
   *    defines Go function wrappers.  Each wrapper will call the C
   *    function wrapper in the second file.
   *
   * 3) A .c file compiled with 6c/8c.  This file will define
   *    Go-callable C function wrappers.  Each wrapper will use
   *    cgocall to call the function wrappers in the first file.
   *
   * When generating code for gccgo, we don't need the third file, and
   * the function wrappers in the first file have a different form.
   *
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {
    Node *optionsnode = Getattr(Getattr(n, "module"), "options");
    if (optionsnode) {
      if (Getattr(optionsnode, "directors")) {
	allow_directors();
      }
      if (Getattr(optionsnode, "dirprot")) {
	allow_dirprot();
      }
      allow_allprotected(GetFlag(optionsnode, "allprotected"));
    }

    String *module = Getattr(n, "name");
    if (!package) {
      package = Copy(module);
    }
    if (!soname) {
      soname = Copy(package);
      Append(soname, ".so");
    }

    // Get filenames.

    String *c_filename = Getattr(n, "outfile");
    String *c_filename_h = Getattr(n, "outfile_h");

    String *go_filename = NewString("");
    Printf(go_filename, "%s%s.go", SWIG_output_directory(), module);

    String *gc_filename = NULL;
    if (!gccgo_flag) {
      gc_filename = NewString("");
      Printf(gc_filename, "%s%s_gc.c", SWIG_output_directory(), module);
    }

    // Open files.

    f_c_begin = NewFile(c_filename, "w", SWIG_output_files());
    if (!f_c_begin) {
      FileErrorDisplay(c_filename);
      SWIG_exit(EXIT_FAILURE);
    }

    if (directorsEnabled()) {
      if (!c_filename_h) {
	Printf(stderr, "Unable to determine outfile_h\n");
	SWIG_exit(EXIT_FAILURE);
      }
      f_c_directors_h = NewFile(c_filename_h, "w", SWIG_output_files());
      if (!f_c_directors_h) {
	FileErrorDisplay(c_filename_h);
	SWIG_exit(EXIT_FAILURE);
      }
    }

    f_go_begin = NewFile(go_filename, "w", SWIG_output_files());
    if (!f_go_begin) {
      FileErrorDisplay(go_filename);
      SWIG_exit(EXIT_FAILURE);
    }

    if (!gccgo_flag) {
      f_gc_begin = NewFile(gc_filename, "w", SWIG_output_files());
      if (!f_gc_begin) {
	FileErrorDisplay(gc_filename);
	SWIG_exit(EXIT_FAILURE);
      }
    }

    f_c_runtime = NewString("");
    f_c_header = NewString("");
    f_c_wrappers = NewString("");
    f_c_init = NewString("");
    f_c_directors = NewString("");
    f_go_runtime = NewString("");
    f_go_header = NewString("");
    f_go_wrappers = NewString("");
    f_go_once = NewString("");
    if (!gccgo_flag) {
      f_gc_runtime = NewString("");
      f_gc_header = NewString("");
      f_gc_wrappers = NewString("");
      f_gc_once = NewString("");
    }

    Swig_register_filebyname("begin", f_c_begin);
    Swig_register_filebyname("runtime", f_c_runtime);
    Swig_register_filebyname("header", f_c_header);
    Swig_register_filebyname("wrapper", f_c_wrappers);
    Swig_register_filebyname("init", f_c_init);
    Swig_register_filebyname("director", f_c_directors);
    Swig_register_filebyname("director_h", f_c_directors_h);
    Swig_register_filebyname("go_begin", f_go_begin);
    Swig_register_filebyname("go_runtime", f_go_runtime);
    Swig_register_filebyname("go_header", f_go_header);
    Swig_register_filebyname("go_wrapper", f_go_wrappers);
    Swig_register_filebyname("go_once", f_go_once);
    if (!gccgo_flag) {
      Swig_register_filebyname("gc_begin", f_gc_begin);
      Swig_register_filebyname("gc_runtime", f_gc_runtime);
      Swig_register_filebyname("gc_header", f_gc_header);
      Swig_register_filebyname("gc_wrapper", f_gc_wrappers);
      Swig_register_filebyname("gc_once", f_gc_once);
    }

    Swig_banner(f_c_begin);

    if (directorsEnabled()) {
      Printf(f_c_runtime, "#define SWIG_DIRECTORS\n");

      Swig_banner(f_c_directors_h);
      Printf(f_c_directors_h, "#ifndef SWIG_%s_WRAP_H_\n", module);
      Printf(f_c_directors_h, "#define SWIG_%s_WRAP_H_\n\n", module);

      Printf(f_c_directors, "\n// C++ director class methods.\n");
      Printf(f_c_directors, "#include \"%s\"\n\n", Swig_file_filename(c_filename_h));
    }

    Swig_banner(f_go_begin);

    if (!gccgo_flag) {
      Swig_banner(f_gc_begin);
      Printf(f_gc_begin, "\n/* This file should be compiled with 6c/8c.  */\n");
    }

    // Output module initialization code.

    Printf(f_go_begin, "\npackage %s\n\n", package);

    // All the C++ wrappers should be extern "C".

    Printv(f_c_wrappers, "#ifdef __cplusplus\n", "extern \"C\" {\n", "#endif\n\n", NULL);

    // Set up the hash table for types not defined by SWIG.

    undefined_types = NewHash();
    defined_types = NewHash();

    // Emit code.

    Language::top(n);

    // Write out definitions for the types not defined by SWIG.

    Printv(f_go_wrappers, "\n", NULL);
    for (Iterator p = First(undefined_types); p.key; p = Next(p)) {
      String *ty = goType(NULL, p.key);
      if (!Getattr(defined_types, ty)) {
	String *cp = goCPointerType(p.key, false);
	if (!Getattr(defined_types, cp)) {
	  Printv(f_go_wrappers, "type ", cp, " uintptr\n", NULL);
	  Printv(f_go_wrappers, "type ", ty, " interface {\n", NULL);
	  Printv(f_go_wrappers, "\tSwigcptr() uintptr;\n", NULL);
	  Printv(f_go_wrappers, "}\n", NULL);
	  Printv(f_go_wrappers, "func (p ", cp, ") Swigcptr() uintptr {\n", NULL);
	  Printv(f_go_wrappers, "\treturn uintptr(p)\n", NULL);
	  Printv(f_go_wrappers, "}\n\n", NULL);
	}
	Delete(cp);
      }
      Delete(ty);
    }
    Delete(undefined_types);
    Delete(defined_types);

    /* Write and cleanup */

    Dump(f_c_header, f_c_runtime);

    if (directorsEnabled()) {
      Printf(f_c_directors_h, "#endif\n");
      Close(f_c_directors_h);
      Delete(f_c_directors_h);
      f_c_directors_h = NULL;

      Dump(f_c_directors, f_c_runtime);
      Close(f_c_directors);
      Delete(f_c_directors);
      f_c_directors = NULL;
    }

    // End the extern "C".
    Printv(f_c_wrappers, "#ifdef __cplusplus\n", "}\n", "#endif\n\n", NULL);

    Dump(f_c_runtime, f_c_begin);
    Dump(f_c_wrappers, f_c_begin);
    Dump(f_c_init, f_c_begin);
    Dump(f_go_header, f_go_begin);
    if (!saw_import) {
      Dump(f_go_once, f_go_begin);
    }
    Dump(f_go_runtime, f_go_begin);
    Dump(f_go_wrappers, f_go_begin);
    if (!gccgo_flag) {
      Dump(f_gc_header, f_gc_begin);
      if (!saw_import) {
	Dump(f_gc_once, f_gc_begin);
      }
      Dump(f_gc_runtime, f_gc_begin);
      Dump(f_gc_wrappers, f_gc_begin);
    }

    Delete(f_c_runtime);
    Delete(f_c_header);
    Delete(f_c_wrappers);
    Delete(f_c_init);
    Delete(f_go_runtime);
    Delete(f_go_header);
    Delete(f_go_wrappers);
    if (!gccgo_flag) {
      Delete(f_gc_runtime);
      Delete(f_gc_header);
      Delete(f_gc_wrappers);
    }

    Close(f_c_begin);
    Delete(f_c_begin);
    Close(f_go_begin);
    Delete(f_go_begin);
    if (!gccgo_flag) {
      Close(f_gc_begin);
      Delete(f_gc_begin);
    }

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * importDirective()
   *
   * Handle a SWIG import statement by generating a Go import
   * statement.
   * ------------------------------------------------------------ */

  virtual int importDirective(Node *n) {
    String *hold_import = imported_package;
    String *modname = Getattr(n, "module");
    if (modname) {
      Printv(f_go_begin, "import \"", modname, "\"\n", NULL);
      imported_package = modname;
      saw_import = true;
    }
    int r = Language::importDirective(n);
    imported_package = hold_import;
    return r;
  }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   *
   * Implement a function.
   * ---------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    if (GetFlag(n, "feature:ignore")) {
      return SWIG_OK;
    }

    // We don't need explicit calls.
    if (GetFlag(n, "explicitcall")) {
      return SWIG_OK;
    }

    String *name = Getattr(n, "sym:name");
    String *nodetype = Getattr(n, "nodeType");
    bool is_static = is_static_member_function || isStatic(n);
    bool is_friend = isFriend(n);
    bool is_ctor_dtor = false;

    SwigType *result = Getattr(n, "type");

    // For some reason SWIG changs the "type" value during the call to
    // functionWrapper.  We need to remember the type for possible
    // overload processing.
    Setattr(n, "go:type", Copy(result));

    String *go_name;

    String *r1 = NULL;
    if (making_variable_wrappers) {
      // Change the name of the variable setter and getter functions
      // to be more Go like.

      bool is_set = Strcmp(Char(name) + Len(name) - 4, "_set") == 0;
      assert(is_set || Strcmp(Char(name) + Len(name) - 4, "_get") == 0);

      // Start with Set or Get.
      go_name = NewString(is_set ? "Set" : "Get");

      // If this is a static variable, put in the class name,
      // capitalized.
      if (is_static && class_name) {
	String *ccn = exportedName(class_name);
	Append(go_name, ccn);
	Delete(ccn);
      }

      // Add the rest of the name, capitalized, dropping the _set or
      // _get.
      String *c1 = removeClassname(name);
      String *c2 = exportedName(c1);
      char *p = Char(c2);
      int len = Len(p);
      for (int i = 0; i < len - 4; ++i) {
	Putc(p[i], go_name);
      }
      Delete(c2);
      Delete(c1);

      if (!checkIgnoredParameters(n, go_name)) {
	Delete(go_name);
	return SWIG_NOWRAP;
      }
    } else if (Cmp(nodetype, "constructor") == 0) {
      is_ctor_dtor = true;

      // Change the name of a constructor to be more Go like.  Change
      // new_ to New, and capitalize the class name.
      assert(Strncmp(name, "new_", 4) == 0);
      String *c1 = NewString(Char(name) + 4);
      String *c2 = exportedName(c1);
      go_name = NewString("New");
      Append(go_name, c2);
      Delete(c2);
      Delete(c1);

      if (Swig_methodclass(n) && Swig_directorclass(n)
	  && Strcmp(Char(Getattr(n, "wrap:action")), director_prot_ctor_code) != 0) {
	// The core SWIG code skips the first parameter when
	// generating the $nondirector_new string.  Recreate the
	// action in this case.  But don't it if we are using the
	// special code for an abstract class.
	String *call = Swig_cppconstructor_call(getClassType(),
						Getattr(n, "parms"));
	SwigType *type = Copy(getClassType());
	SwigType_add_pointer(type);
	String *cres = Swig_cresult(type, "result", call);
	Setattr(n, "wrap:action", cres);
      }
    } else if (Cmp(nodetype, "destructor") == 0) {
      // No need to emit protected destructors.
      if (!is_public(n)) {
	return SWIG_OK;
      }

      is_ctor_dtor = true;

      // Change the name of a destructor to be more Go like.  Change
      // delete_ to Delete and capitalize the class name.
      assert(Strncmp(name, "delete_", 7) == 0);
      String *c1 = NewString(Char(name) + 7);
      String *c2 = exportedName(c1);
      go_name = NewString("Delete");
      Append(go_name, c2);
      Delete(c2);
      Delete(c1);

      result = NewString("void");
      r1 = result;
    } else {
      if (!is_public(n)) {
	return SWIG_OK;
      }

      go_name = buildGoName(name, is_static, is_friend);

      if (!checkIgnoredParameters(n, go_name)) {
	Delete(go_name);
	return SWIG_NOWRAP;
      }
    }

    String *overname = NULL;
    if (Getattr(n, "sym:overloaded")) {
      overname = Getattr(n, "sym:overname");
    } else {
      String *scope;
      if (!class_name || is_static || is_ctor_dtor) {
	scope = NULL;
      } else {
	scope = NewString("swiggoscope.");
	Append(scope, class_name);
      }
      if (!checkNameConflict(go_name, n, scope)) {
	Delete(go_name);
	return SWIG_NOWRAP;
      }
    }

    String *wname = Swig_name_wrapper(name);
    if (overname) {
      Append(wname, overname);
    }
    Setattr(n, "wrap:name", wname);

    ParmList *parms = Getattr(n, "parms");
    Setattr(n, "wrap:parms", parms);

    int r = makeWrappers(n, name, go_name, overname, wname, NULL, parms, result, is_static);
    if (r != SWIG_OK) {
      return r;
    }

    if (Getattr(n, "sym:overloaded") && !Getattr(n, "sym:nextSibling")) {
      String *scope ;
      if (!class_name || is_static || is_ctor_dtor) {
	scope = NULL;
      } else {
	scope = NewString("swiggoscope.");
	Append(scope, class_name);
      }
      if (!checkNameConflict(go_name, n, scope)) {
	Delete(go_name);
	return SWIG_NOWRAP;
      }

      String *receiver = class_receiver;
      if (is_static || is_ctor_dtor) {
	receiver = NULL;
      }
      r = makeDispatchFunction(n, go_name, receiver, is_static, NULL, false);
      if (r != SWIG_OK) {
	return r;
      }
    }

    Delete(wname);
    Delete(go_name);
    Delete(r1);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmemberfunctionHandler
   *
   * For some reason the language code removes the "storage" attribute
   * for a static function before calling functionWrapper, which means
   * that we have no way of knowing whether a function is static or
   * not.  That makes no sense in the Go context.  Here we note that a
   * function is static.
   * ---------------------------------------------------------------------- */

  int staticmemberfunctionHandler(Node *n) {
    assert(!is_static_member_function);
    is_static_member_function = true;
    int r = Language::staticmemberfunctionHandler(n);
    is_static_member_function = false;
    return r;
  }

  /* ----------------------------------------------------------------------
   * makeWrappers()
   *
   * Write out the various function wrappers.
   * n: The function we are emitting.
   * name: The function name.
   * go_name: The name of the function in Go.
   * overname: The overload string for overloaded function.
   * wname: The SWIG wrapped name--the name of the C function.
   * base: A list of the names of base classes, in the case where this
   *       is is a vritual method not defined in the current class.
   * parms: The parameters.
   * result: The result type.
   * is_static: Whether this is a static method or member.
   * ---------------------------------------------------------------------- */

  int makeWrappers(Node *n, String *name, String *go_name, String *overname, String *wname, List *base, ParmList *parms, SwigType *result, bool is_static) {

    assert(result);

    bool needs_wrapper;
    int r = goFunctionWrapper(n, name, go_name, overname, wname, base, parms, result, is_static, &needs_wrapper);
    if (r != SWIG_OK) {
      return r;
    }

    if (!gccgo_flag) {
      r = gcFunctionWrapper(n, name, go_name, overname, wname, parms, result, is_static, needs_wrapper);
      if (r != SWIG_OK) {
	return r;
      }
      r = gccFunctionWrapper(n, base, wname, parms, result);
      if (r != SWIG_OK) {
	return r;
      }
    } else {
      r = gccgoFunctionWrapper(n, base, wname, parms, result);
      if (r != SWIG_OK) {
	return r;
      }
    }

    if (class_methods) {
      Setattr(class_methods, Getattr(n, "name"), NewString(""));
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * goFunctionWrapper()
   *
   * Write out a function wrapper in Go.  When not implementing a
   * method, the actual code is all in C; here we just declare the C
   * function.  When implementing a method, we have to call the C
   * function, because it will have a different name.  If base is not
   * NULL, then we are being called to forward a virtual method to a
   * base class.
   * ---------------------------------------------------------------------- */

  int goFunctionWrapper(Node *n, String *name, String *go_name, String *overname, String *wname, List *base, ParmList *parms, SwigType *result, bool is_static, bool *p_needs_wrapper) {
    Wrapper *dummy = NewWrapper();
    emit_attach_parmmaps(parms, dummy);
    Swig_typemap_attach_parms("default", parms, dummy);
    Swig_typemap_attach_parms("gotype", parms, dummy);
    int parm_count = emit_num_arguments(parms);
    int required_count = emit_num_required(parms);

    String *receiver = class_receiver;
    if (receiver && is_static) {
      receiver = NULL;
    }

    String *nodetype = Getattr(n, "nodeType");
    bool is_constructor = Cmp(nodetype, "constructor") == 0;
    bool is_destructor = Cmp(nodetype, "destructor") == 0;
    if (is_constructor || is_destructor) {
      assert(class_receiver);
      assert(!base);
      receiver = NULL;
    }

    bool add_to_interface = (interfaces && !is_constructor && !is_destructor && !is_static && !overname && is_public(n));

    bool needs_wrapper = (gccgo_flag || receiver || is_constructor || is_destructor || parm_count > required_count);

    // See whether any of the function parameters are represented by
    // interface values When calling the C++ code, we need to convert
    // back to a uintptr.
    if (!needs_wrapper) {
      Parm *p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	String *ty = Getattr(p, "type");
	if (goTypeIsInterface(p, ty)) {
	  needs_wrapper = true;
	  break;
	}
	p = nextParm(p);
      }
    }
    if (goTypeIsInterface(NULL, result)) {
      needs_wrapper = true;
    }

    *p_needs_wrapper = needs_wrapper;

    // If this is a method, first declare the C function we will call.
    // If we do not need a wrapper, then we will only be writing a
    // declaration.
    String *wrapper_name = NULL;
    if (needs_wrapper) {
      wrapper_name = buildGoWrapperName(name, overname);

      Printv(f_go_wrappers, "func ", wrapper_name, "(", NULL);
      if (parm_count > required_count) {
	Printv(f_go_wrappers, "int", NULL);
      }
      Parm *p = getParm(parms);
      Swig_cparm_name(p, 0);
      int i = 0;
      if (is_destructor) {
	if (parm_count > required_count) {
	  Printv(f_go_wrappers, ", ", NULL);
	}
	Printv(f_go_wrappers, "uintptr", NULL);
	++i;
	p = nextParm(p);
      } else if (receiver && (base || !is_constructor)) {
	if (parm_count > required_count) {
	  Printv(f_go_wrappers, ", ", NULL);
	}
	Printv(f_go_wrappers, receiver, NULL);
	if (!base) {
	  ++i;
	  p = nextParm(p);
	}
      }
      for (; i < parm_count; ++i) {
	p = getParm(p);
	// Give the parameter a name we will use below.
	Swig_cparm_name(p, i);
	if (i > 0 || (base && receiver) || parm_count > required_count) {
	  Printv(f_go_wrappers, ", ", NULL);
	}
	String *tm = goWrapperType(p, Getattr(p, "type"), false);
	Printv(f_go_wrappers, tm, NULL);
	Delete(tm);
	p = nextParm(p);
      }
      Printv(f_go_wrappers, ")", NULL);
      if (is_constructor) {
	Printv(f_go_wrappers, " ", class_receiver, NULL);
      } else {
	if (SwigType_type(result) != T_VOID) {
	  String *tm = goWrapperType(n, result, true);
	  Printv(f_go_wrappers, " ", tm, NULL);
	  Delete(tm);
	}
      }

      if (gccgo_flag) {
	Printv(f_go_wrappers, " __asm__ (\"", go_prefix, "_", wname, "\")", NULL);
      }

      Printv(f_go_wrappers, "\n\n", NULL);
    }

    // Start defining the Go function.

    Printv(f_go_wrappers, "func ", NULL);

    Parm *p = parms;
    int pi = 0;

    // Add the receiver if this is a method.
    if (receiver) {
      Printv(f_go_wrappers, "(", NULL);
      if (base && receiver) {
	Printv(f_go_wrappers, "_swig_base", NULL);
      } else {
	Printv(f_go_wrappers, Getattr(p, "lname"), NULL);
	p = nextParm(p);
	++pi;
      }
      Printv(f_go_wrappers, " ", receiver, ") ", NULL);
    }

    Printv(f_go_wrappers, go_name, NULL);
    if (overname) {
      Printv(f_go_wrappers, overname, NULL);
    }
    Printv(f_go_wrappers, "(", NULL);

    // If we are doing methods, add this function to the interface.
    if (add_to_interface) {
      Printv(interfaces, "\t", go_name, "(", NULL);
    }

    // Write out the parameters to both the function definition and
    // the interface.

    String *parm_print = NewString("");

    for (; pi < parm_count; ++pi) {
      p = getParm(p);
      if (pi == 0 && is_destructor) {
	String *cl = exportedName(class_name);
	Printv(parm_print, Getattr(p, "lname"), " ", cl, NULL);
	Delete(cl);
      } else {
	if (pi > (receiver && !base ? 1 : 0)) {
	  Printv(parm_print, ", ", NULL);
	}
	if (pi >= required_count) {
	  Printv(parm_print, "_swig_args ...interface{}", NULL);
	  break;
	}
	if (needs_wrapper) {
	  Printv(parm_print, Getattr(p, "lname"), " ", NULL);
	}
	String *tm = goType(p, Getattr(p, "type"));
	Printv(parm_print, tm, NULL);
	Delete(tm);
      }
      p = nextParm(p);
    }

    Printv(parm_print, ")", NULL);

    // Write out the result type.
    if (is_constructor) {
      String *cl = exportedName(class_name);
      Printv(parm_print, " ", cl, NULL);
      Delete(cl);
    } else {
      if (SwigType_type(result) != T_VOID) {
	String *tm = goType(n, result);
	Printv(parm_print, " ", tm, NULL);
	Delete(tm);
      }
    }

    Printv(f_go_wrappers, parm_print, NULL);
    if (add_to_interface) {
      Printv(interfaces, parm_print, "\n", NULL);
    }

    // If this is a wrapper, we need to actually call the C function.
    if (needs_wrapper) {
      Printv(f_go_wrappers, " {\n", NULL);

      if (parm_count > required_count) {
	Parm *p = parms;
	int i;
	for (i = 0; i < required_count; ++i) {
	  p = getParm(p);
	  p = nextParm(p);
	}
	for (; i < parm_count; ++i) {
	  p = getParm(p);
	  String *tm = goType(p, Getattr(p, "type"));
	  Printv(f_go_wrappers, "\tvar ", Getattr(p, "lname"), " ", tm, "\n", NULL);
	  Printf(f_go_wrappers, "\tif len(_swig_args) > %d {\n", i - required_count);
	  Printf(f_go_wrappers, "\t\t%s = _swig_args[%d].(%s)\n", Getattr(p, "lname"), i - required_count, tm);
	  Printv(f_go_wrappers, "\t}\n", NULL);
	  Delete(tm);
	  p = nextParm(p);
	}
      }

      Printv(f_go_wrappers, "\t", NULL);
      if (SwigType_type(result) != T_VOID) {
	Printv(f_go_wrappers, "return ", NULL);
      }

      Printv(f_go_wrappers, wrapper_name, "(", NULL);

      if (parm_count > required_count) {
	Printv(f_go_wrappers, "len(_swig_args)", NULL);
      }

      if (base && receiver) {
	if (parm_count > required_count) {
	  Printv(f_go_wrappers, ", ", NULL);
	}
	Printv(f_go_wrappers, "_swig_base", NULL);
      }

      Parm *p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	if (i > 0 || (base && receiver)
	    || parm_count > required_count) {
	  Printv(f_go_wrappers, ", ", NULL);
	}
	Printv(f_go_wrappers, Getattr(p, "lname"), NULL);

	// If this is a destructor, then the C function expects the
	// C++ value, and we have the interface.  We need to get the
	// C++ value.  The same is true for a type represented as an
	// interface.
	if ((i == 0 && is_destructor) || ((i > 0 || !receiver || base || is_constructor) && goTypeIsInterface(p, Getattr(p, "type")))) {
	  Printv(f_go_wrappers, ".Swigcptr()", NULL);
	}

	p = nextParm(p);
      }
      Printv(f_go_wrappers, ")\n", NULL);
      Printv(f_go_wrappers, "}\n", NULL);
    } else {
      if (gccgo_flag) {
	Printv(f_go_wrappers, " __asm__ (\"", go_prefix, "_", wname, "\")\n", NULL);
      }
    }

    Printv(f_go_wrappers, "\n", NULL);

    Delete(wrapper_name);
    DelWrapper(dummy);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * gcFunctionWrapper()
   *
   * This is used for 6g/8g, not for gccgo.  Write out the function
   * wrapper which will be compiled with 6c/8c.
   * ---------------------------------------------------------------------- */

  int gcFunctionWrapper(Node *n, String *name, String *go_name, String *overname, String *wname, ParmList *parms, SwigType *result, bool is_static, bool needs_wrapper) {
    Wrapper *f = NewWrapper();

    Printv(f->def, "#pragma dynimport ", wname, " ", wname, " \"", soname, "\"\n", NULL);
    Printv(f->def, "void (*", wname, ")(void*);\n", NULL);
    Printv(f->def, "\n", NULL);
    Printv(f->def, "void\n", NULL);

    Wrapper *dummy = NewWrapper();
    emit_attach_parmmaps(parms, dummy);
    Swig_typemap_attach_parms("default", parms, dummy);
    Swig_typemap_attach_parms("gosize", parms, dummy);
    int parm_count = emit_num_arguments(parms);
    int required_count = emit_num_required(parms);

    String *parm_size = NewString("");

    if (parm_count > required_count) {
      Append(parm_size, "SWIG_PARM_SIZE");
    }

    if (class_receiver && !is_static) {
      if (Len(parm_size) > 0) {
	Append(parm_size, " + ");
      }
      Append(parm_size, "SWIG_PARM_SIZE");
    }

    Parm *p = parms;
    for (int i = 0; i < parm_count; ++i) {
      p = getParm(p);
      addGcTypeSize(p, Getattr(p, "type"), parm_size);
      p = nextParm(p);
    }

    if (SwigType_type(result) != T_VOID) {
      addGcTypeSize(n, result, parm_size);
    }

    if (Len(parm_size) == 0) {
      Append(parm_size, "1");
    }

    String *fn_name;
    if (!needs_wrapper) {
      fn_name = Copy(go_name);
      if (overname) {
	Append(fn_name, overname);
      }
    } else {
      fn_name = buildGoWrapperName(name, overname);
    }

    // \xc2\xb7 is UTF-8 for U+00B7 which is Unicode 'Middle Dot'
    Printv(f->def, "\xc2\xb7", fn_name, "(struct { uint8 x[", parm_size, "];} p)", NULL);

    Delete(fn_name);
    Delete(parm_size);

    Printv(f->code, "{\n", NULL);
    Printv(f->code, "\truntime\xc2\xb7" "cgocall(", wname, ", &p);\n", NULL);
    Printv(f->code, "}\n", NULL);
    Printv(f->code, "\n", NULL);

    Wrapper_print(f, f_gc_wrappers);

    DelWrapper(f);
    DelWrapper(dummy);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * getGcTypeSize()
   *
   * Return the size to use when passing a type from 6g/8g to 6c/8c.
   * ---------------------------------------------------------------------- */

  String *addGcTypeSize(Node *n, SwigType *type, String *orig) {
    if (Len(orig) > 0) {
      Append(orig, " + ");
    }

    String *go = goType(n, type);
    if (Cmp(go, "string") == 0) {
      // A string has a pointer and a length.
      Append(orig, "(2 * SWIG_PARM_SIZE)");
    } else if (Strncmp(go, "[]", 2) == 0) {
      // A slice has a pointer, a length, and a capacity.  The
      // length and capacity are always 4 bytes.
      Append(orig, "(SWIG_PARM_SIZE + 8)");
    } else if (Strcmp(go, "float") == 0 || Strcmp(go, "float64") == 0) {
      Append(orig, "8");
    } else if (Strcmp(go, "complex") == 0 || Strcmp(go, "complex64") == 0) {
      Append(orig, "8");
    } else if (Strcmp(go, "complex128") == 0) {
      Append(orig, "16");
    } else {
      Append(orig, "SWIG_PARM_SIZE");
    }

    return orig;
  }

  /* ----------------------------------------------------------------------
   * gccFunctionWrapper()
   *
   * This is used for 6g/8g, not for gccgo.  Write out the function
   * wrapper which will be compiled with gcc.  If the base parameter
   * is not NULL, this is calls the base class method rather than
   * executing the SWIG wrapper code.
   * ---------------------------------------------------------------------- */

  int gccFunctionWrapper(Node *n, List *base, String *wname, ParmList *parms, SwigType *result) {
    Wrapper *f = NewWrapper();

    Swig_save("gccFunctionWrapper", n, "parms", NULL);

    Parm *base_parm = NULL;
    if (base && !isStatic(n)) {
      SwigType *base_type = Copy(Getattr(class_node, "classtype"));
      SwigType_add_pointer(base_type);
      base_parm = NewParm(base_type, NewString("arg1"), n);
      set_nextSibling(base_parm, parms);
      parms = base_parm;
    }

    emit_parameter_variables(parms, f);
    emit_attach_parmmaps(parms, f);
    int parm_count = emit_num_arguments(parms);
    int required_count = emit_num_required(parms);

    emit_return_variable(n, result, f);

    // Start the function definition.

    Printv(f->def, "void\n", wname, "(void *swig_v)\n", "{\n", NULL);

    // The single function parameter is a pointer to the real argument
    // values.  Define the structure that it points to.

    Printv(f->code, "\tstruct swigargs {\n", NULL);

    if (parm_count > required_count) {
      Printv(f->code, "\t\tint _swig_optargc;\n", NULL);
    }

    Parm *p = parms;
    for (int i = 0; i < parm_count; ++i) {
      p = getParm(p);
      String *ln = Getattr(p, "lname");
      SwigType *pt = Getattr(p, "type");
      String *ct = gcCTypeForGoValue(p, pt, ln);
      Printv(f->code, "\t\t\t", ct, ";\n", NULL);
      Delete(ct);
      p = nextParm(p);
    }
    if (SwigType_type(result) != T_VOID) {
      Printv(f->code, "\t\tint : 0;\n", NULL);
      String *ln = NewString("result");
      String *ct = gcCTypeForGoValue(n, result, ln);
      Delete(ln);
      Printv(f->code, "\t\t", ct, ";\n", NULL);
      Delete(ct);
    }
    Printv(f->code, "\t} *swig_a = (struct swigargs *) swig_v;\n", NULL);

    Printv(f->code, "\n", NULL);

    // Copy the input arguments out of the structure into the
    // parameter variables.

    p = parms;
    for (int i = 0; i < parm_count; ++i) {
      p = getParm(p);

      String *tm = Getattr(p, "tmap:in");
      if (!tm) {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument\n", SwigType_str(Getattr(p, "type"), 0));
      } else {
	String *ln = Getattr(p, "lname");
	String *input = NewString("");
	Printv(input, "swig_a->", ln, NULL);
	Replaceall(tm, "$input", input);
	Setattr(p, "emit:input", input);
	if (i < required_count) {
	  Printv(f->code, "\t", tm, "\n", NULL);
	} else {
	  Printf(f->code, "\tif (swig_a->_swig_optargc > %d) {\n", i - required_count);
	  Printv(f->code, "\t\t", tm, "\n", NULL);
	  Printv(f->code, "\t}\n", NULL);
	}
      }
      p = nextParm(p);
    }

    Printv(f->code, "\n", NULL);

    // Do the real work of the function.

    checkConstraints(parms, f);

    emitGoAction(n, base, parms, result, f);

    argout(parms, f);

    cleanupFunction(n, f, parms);

    Printv(f->code, "}\n", NULL);

    Wrapper_print(f, f_c_wrappers);

    Swig_restore(n);

    DelWrapper(f);
    Delete(base_parm);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * gccgoFunctionWrapper()
   *
   * This is used for gccgo, not 6g/8g.  Write out the function
   * wrapper which will be compiled with gcc.  If the base parameter
   * is not NULL, this is calls the base class method rather than
   * executing the SWIG wrapper code.
   * ---------------------------------------------------------------------- */

  int gccgoFunctionWrapper(Node *n, List *base, String *wname, ParmList *parms, SwigType *result) {
    Wrapper *f = NewWrapper();

    Swig_save("gccgoFunctionWrapper", n, "parms", NULL);

    Parm *base_parm = NULL;
    if (base && !isStatic(n)) {
      SwigType *base_type = Copy(Getattr(class_node, "classtype"));
      SwigType_add_pointer(base_type);
      base_parm = NewParm(base_type, NewString("arg1"), n);
      set_nextSibling(base_parm, parms);
      parms = base_parm;
    }

    emit_parameter_variables(parms, f);
    emit_attach_parmmaps(parms, f);
    int parm_count = emit_num_arguments(parms);
    int required_count = emit_num_required(parms);

    emit_return_variable(n, result, f);

    // Start the function definition.

    String *fnname = NewString("");
    Printv(fnname, go_prefix, "_", wname, "(", NULL);

    if (parm_count > required_count) {
      Printv(fnname, "int _swig_optargc", NULL);
    }

    Parm *p = parms;
    for (int i = 0; i < parm_count; ++i) {
      p = getParm(p);
      SwigType *pt = Getattr(p, "type");
      String *pn = NewString("g");
      Append(pn, Getattr(p, "lname"));
      String *ct = gccgoCTypeForGoValue(p, pt, pn);
      if (i > 0 || parm_count > required_count) {
	Printv(fnname, ", ", NULL);
      }
      Printv(fnname, ct, NULL);
      Delete(ct);
      Delete(pn);
      p = nextParm(p);
    }

    Printv(fnname, ")", NULL);

    if (SwigType_type(result) == T_VOID) {
      Printv(f->def, "void ", fnname, NULL);
    } else {
      String *ct = gccgoCTypeForGoValue(n, result, fnname);
      Printv(f->def, ct, NULL);
      Delete(ct);
    }

    Printv(f->def, " {\n", NULL);

    Delete(fnname);

    if (SwigType_type(result) != T_VOID) {
      String *ln = NewString("go_result");
      String *ct = gccgoCTypeForGoValue(n, result, ln);
      Wrapper_add_local(f, "go_result", ct);
      Delete(ct);
      Delete(ln);
    }

    // Copy the parameters into the variables which hold their values,
    // applying appropriate transformations.

    p = parms;
    for (int i = 0; i < parm_count; ++i) {
      p = getParm(p);

      String *tm = Getattr(p, "tmap:in");
      if (!tm) {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number,
		     "Unable to use type %s as a function argument\n", SwigType_str(Getattr(p, "type"), 0));
      } else {
	String *ln = Getattr(p, "lname");
	String *pn = NewString("g");
	Append(pn, ln);
	Replaceall(tm, "$input", pn);
	Setattr(p, "emit:input", pn);
	if (i < required_count) {
	  Printv(f->code, "  ", tm, "\n", NULL);
	} else {
	  Printf(f->code, "  if (_swig_optargc > %d) {\n", i - required_count);
	  Printv(f->code, "    ", tm, "\n", NULL);
	  Printv(f->code, "  }\n", NULL);
	}
      }

      p = nextParm(p);
    }

    Printv(f->code, "\n", NULL);

    // Do the real work of the function.

    checkConstraints(parms, f);

    emitGoAction(n, base, parms, result, f);

    argout(parms, f);

    cleanupFunction(n, f, parms);

    if (SwigType_type(result) != T_VOID) {
      Printv(f->code, "  return go_result;\n", NULL);
    }

    Printv(f->code, "}\n", NULL);

    Wrapper_print(f, f_c_wrappers);

    Swig_restore(n);

    DelWrapper(f);
    Delete(base_parm);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * checkConstraints()
   *
   * Check parameter constraints if any.  This is used for the C/C++
   * function.  This assumes that each parameter has an "emit:input"
   * property with the name to use to refer to that parameter.
   * ----------------------------------------------------------------------- */

  void checkConstraints(ParmList *parms, Wrapper *f) {
    Parm *p = parms;
    while (p) {
      String *tm = Getattr(p, "tmap:check");
      if (!tm) {
	p = nextSibling(p);
      } else {
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(f->code, tm, "\n\n", NULL);
	p = Getattr(p, "tmap:check:next");
      }
    }
  }

  /* -----------------------------------------------------------------------
   * getGoAction()
   *
   * Get the action of the function.  This is used for C/C++ function.
   * ----------------------------------------------------------------------- */

  void emitGoAction(Node *n, List *base, ParmList *parms, SwigType *result, Wrapper *f) {
    String *actioncode;
    if (!base || isStatic(n)) {
      Swig_director_emit_dynamic_cast(n, f);
      actioncode = emit_action(n);
    } else {
      // Call the base class method.
      actioncode = NewString("");

      String *current = NewString("");
      if (!gccgo_flag) {
	Printv(current, "swig_a->", NULL);
      }
      Printv(current, Getattr(parms, "lname"), NULL);

      String *last = NULL;
      int vc = 0;
      for (Iterator bi = First(base); bi.item; bi = Next(bi)) {
	Printf(actioncode, "  %s *swig_b%d = (%s *)%s;\n", bi.item, vc, bi.item, current);
	Delete(current);
	current = NewString("");
	Printf(current, "swig_b%d", vc);
	++vc;
	last = bi.item;
      }

      String *code = Copy(Getattr(n, "wrap:action"));
      Replaceall(code, Getattr(parms, "lname"), current);
      Printv(actioncode, code, "\n", NULL);
    }

    Swig_save("emitGoAction", n, "type", "tmap:out", NULL);

    Setattr(n, "type", result);

    String *tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode);
    if (!tm) {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s\n", SwigType_str(result, 0));
    } else {
      if (!gccgo_flag) {
	Replaceall(tm, "$result", "swig_a->result");
      } else {
	Replaceall(tm, "$result", "go_result");
      }
      if (GetFlag(n, "feature:new")) {
	Replaceall(tm, "$owner", "1");
      } else {
	Replaceall(tm, "$owner", "0");
      }
      Printv(f->code, tm, "\n", NULL);
      Delete(tm);
    }

    Swig_restore(n);
  }

  /* -----------------------------------------------------------------------
   * argout()
   *
   * Handle argument output code if any.  This is used for the C/C++
   * function.  This assumes that each parameter has an "emit:input"
   * property with the name to use to refer to that parameter.
   * ----------------------------------------------------------------------- */

  void argout(ParmList *parms, Wrapper *f) {
    Parm *p = parms;
    while (p) {
      String *tm = Getattr(p, "tmap:argout");
      if (!tm) {
	p = nextSibling(p);
      } else {
	Replaceall(tm, "$result", "result");
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(f->code, tm, "\n", NULL);
	p = Getattr(p, "tmap:argout:next");
      }
    }
  }

  /* -----------------------------------------------------------------------
   * freearg()
   *
   * Handle argument cleanup code if any.  This is used for the C/C++
   * function.  This assumes that each parameter has an "emit:input"
   * property with the name to use to refer to that parameter.
   * ----------------------------------------------------------------------- */

  String *freearg(ParmList *parms) {
    String *ret = NewString("");
    Parm *p = parms;
    while (p) {
      String *tm = Getattr(p, "tmap:freearg");
      if (!tm) {
	p = nextSibling(p);
      } else {
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(ret, tm, "\n", NULL);
	p = Getattr(p, "tmap:freearg:next");
      }
    }
    return ret;
  }

  /* -----------------------------------------------------------------------
   * cleanupFunction()
   *
   * Final function cleanup code.
   * ----------------------------------------------------------------------- */

  void cleanupFunction(Node *n, Wrapper *f, ParmList *parms) {
    String *cleanup = freearg(parms);
    Printv(f->code, cleanup, NULL);

    if (GetFlag(n, "feature:new")) {
      String *tm = Swig_typemap_lookup("newfree", n, "result", 0);
      if (tm) {
	Replaceall(tm, "$source", "result");
	Printv(f->code, tm, "\n", NULL);
	Delete(tm);
      }
    }

    Replaceall(f->code, "$cleanup", cleanup);
    Delete(cleanup);

    Replaceall(f->code, "$symname", Getattr(n, "sym:name"));
  }

  /* -----------------------------------------------------------------------
   * variableHandler()
   *
   * This exists just to set the making_variable_wrappers flag.
   * ----------------------------------------------------------------------- */

  virtual int variableHandler(Node *n) {
    assert(!making_variable_wrappers);
    making_variable_wrappers = true;
    int r = Language::variableHandler(n);
    making_variable_wrappers = false;
    return r;
  }

  /* -----------------------------------------------------------------------
   * constantWrapper()
   *
   * Product a const declaration.
   * ------------------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    SwigType *type = Getattr(n, "type");

    if (!SwigType_issimple(type) && SwigType_type(type) != T_STRING) {
      return goComplexConstant(n, type);
    }

    if (Getattr(n, "storage") && Strcmp(Getattr(n, "storage"), "static") == 0) {
      return goComplexConstant(n, type);
    }

    String *go_name = buildGoName(Getattr(n, "sym:name"), false, false);

    String *tm = goType(n, type);
    String *value = Getattr(n, "value");

    String *copy = NULL;
    if (SwigType_type(type) == T_BOOL) {
      if (Cmp(value, "true") != 0 && Cmp(value, "false") != 0) {
	return goComplexConstant(n, type);
      }
    } else if (SwigType_type(type) == T_STRING || SwigType_type(type) == T_CHAR) {
      // Backslash sequences are somewhat different in Go and C/C++.
      if (Strchr(value, '\\') != 0) {
	return goComplexConstant(n, type);
      }
    } else {
      // Accept a 0x prefix, and strip combinations of u and l
      // suffixes.  Otherwise accept digits, decimal point, and
      // exponentiation.  Treat anything else as too complicated to
      // handle as a Go constant.
      char *p = Char(value);
      int len = strlen(p);
      bool need_copy = false;
      while (len > 0) {
	char c = p[len - 1];
	if (c != 'l' && c != 'L' && c != 'u' && c != 'U') {
	  break;
	}
	--len;
	need_copy = true;
      }
      bool is_hex = false;
      int i = 0;
      if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
	i = 2;
	is_hex = true;
      }
      for (; i < len; ++i) {
	switch (p[i]) {
	case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
	  break;
	case 'a': case 'b': case 'c': case 'd': case 'f': case 'A': case 'B': case 'C': case 'D': case 'F':
	  if (!is_hex) {
	    return goComplexConstant(n, type);
	  }
	  break;
	case '.': case 'e': case 'E': case '+': case '-':
	  break;
	default:
	  return goComplexConstant(n, type);
	}
      }
      if (need_copy) {
	copy = Copy(value);
	Replaceall(copy, p + len, "");
	value = copy;
      }
    }

    if (!checkNameConflict(go_name, n, NULL)) {
      Delete(tm);
      Delete(go_name);
      Delete(copy);
      return SWIG_NOWRAP;
    }

    Printv(f_go_wrappers, "const ", go_name, " ", tm, " = ", NULL);
    if (SwigType_type(type) == T_STRING) {
      Printv(f_go_wrappers, "\"", value, "\"", NULL);
    } else if (SwigType_type(type) == T_CHAR) {
      Printv(f_go_wrappers, "'", value, "'", NULL);
    } else {
      Printv(f_go_wrappers, value, NULL);
    }

    Printv(f_go_wrappers, "\n", NULL);

    Delete(tm);
    Delete(go_name);
    Delete(copy);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * enumDeclaration()
   *
   * A C++ enum type turns into a Named go int type.
   * ---------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {
    String *name = goEnumName(n);
    if (Strcmp(name, "int") != 0) {
      if (!ImportMode || !imported_package) {
	if (!checkNameConflict(name, n, NULL)) {
	  Delete(name);
	  return SWIG_NOWRAP;
	}
	Printv(f_go_wrappers, "type ", name, " int\n", NULL);
      } else {
	String *nw = NewString("");
	Printv(nw, imported_package, ".", name, NULL);
	Setattr(n, "go:enumname", nw);
      }
    }
    Delete(name);

    return Language::enumDeclaration(n);
  }

  /* -----------------------------------------------------------------------
   * enumvalueDeclaration()
   *
   * Declare a single value of an enum type.  We fetch the value by
   * calling a C/C++ function.
   * ------------------------------------------------------------------------ */

  virtual int enumvalueDeclaration(Node *n) {
    if (!is_public(n)) {
      return SWIG_OK;
    }
    if (Getattr(parentNode(n), "unnamed")) {
      Setattr(n, "type", NewString("int"));
    } else {
      Setattr(n, "type", Getattr(parentNode(n), "enumtype"));
    }
    return goComplexConstant(n, Getattr(n, "type"));
  }

  /* -----------------------------------------------------------------------
   * goComplexConstant()
   *
   * Handle a const declaration for something which is not a Go constant.
   * ------------------------------------------------------------------------ */

  int goComplexConstant(Node *n, SwigType *type) {
    String *symname = Getattr(n, "sym:name");
    if (!symname) {
      symname = Getattr(n, "name");
    }

    String *varname = buildGoName(symname, true, false);

    if (!checkNameConflict(varname, n, NULL)) {
      Delete(varname);
      return SWIG_NOWRAP;
    }

    String *get = NewString("");
    Printv(get, "result = ", NULL);

    char quote;
    if (Getattr(n, "wrappedasconstant")) {
      quote = '\0';
    } else if (SwigType_type(type) == T_CHAR) {
      quote = '\'';
    } else if (SwigType_type(type) == T_STRING) {
      quote = '"';
    } else {
      quote = '\0';
    }

    if (quote != '\0') {
      Printf(get, "%c", quote);
    }

    Printv(get, Getattr(n, "value"), NULL);

    if (quote != '\0') {
      Printf(get, "%c", quote);
    }

    Printv(get, ";\n", NULL);
    Setattr(n, "wrap:action", get);

    String *sname = Copy(symname);
    if (class_name) {
      Append(sname, "_");
      Append(sname, class_name);
    }

    String *go_name = NewString("_swig_get");
    if (class_name) {
      Append(go_name, class_name);
      Append(go_name, "_");
    }
    Append(go_name, sname);

    String *wname = Swig_name_wrapper(sname);
    Setattr(n, "wrap:name", wname);

    int r = makeWrappers(n, sname, go_name, NULL, wname, NULL, NULL, type, true);

    if (r != SWIG_OK) {
      return r;
    }

    String *t = goType(n, type);
    Printv(f_go_wrappers, "var ", varname, " ", t, " = ", go_name, "()\n", NULL);

    Delete(varname);
    Delete(t);
    Delete(go_name);
    Delete(sname);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classHandler()
   *
   * For a C++ class, in Go we generate both a struct and an
   * interface.  The interface will declare all the class public
   * methods.  We will define all the methods on the struct, so that
   * the struct meets the interface.  We then expect users of the
   * class to use the interface.
   * ------------------------------------------------------------ */

  virtual int classHandler(Node *n) {
    class_node = n;

    List *baselist = Getattr(n, "bases");
    bool has_base_classes = baselist && Len(baselist) > 0;

    String *name = Getattr(n, "sym:name");

    String *go_name = exportedName(name);

    if (!checkNameConflict(go_name, n, NULL)) {
      Delete(go_name);
      SetFlag(n, "go:conflict");
      return SWIG_NOWRAP;
    }

    String *go_type_name = goCPointerType(Getattr(n, "classtypeobj"), true);

    class_name = name;
    class_receiver = go_type_name;
    class_methods = NewHash();

    int isdir = GetFlag(n, "feature:director");
    int isnodir = GetFlag(n, "feature:nodirector");
    bool is_director = isdir && !isnodir;

    Printv(f_go_wrappers, "type ", go_type_name, " uintptr\n\n", NULL);

    // A method to return the pointer to the C++ class.  This is used
    // by generated code to convert between the interface and the C++
    // value.
    Printv(f_go_wrappers, "func (p ", go_type_name, ") Swigcptr() uintptr {\n", NULL);
    Printv(f_go_wrappers, "\treturn (uintptr)(p)\n", NULL);
    Printv(f_go_wrappers, "}\n\n", NULL);

    // A method used as a marker for the class, to avoid invalid
    // interface conversions when using multiple inheritance.
    Printv(f_go_wrappers, "func (p ", go_type_name, ") SwigIs", go_name, "() {\n", NULL);
    Printv(f_go_wrappers, "}\n\n", NULL);

    if (is_director) {
      // Return the interface passed to the NewDirector function.
      Printv(f_go_wrappers, "func (p ", go_type_name, ") DirectorInterface() interface{} {\n", NULL);
      Printv(f_go_wrappers, "\treturn nil\n", NULL);
      Printv(f_go_wrappers, "}\n\n", NULL);
    }

    // We have seen a definition for this type.
    Setattr(defined_types, go_name, go_name);
    Setattr(defined_types, go_type_name, go_type_name);

    interfaces = NewString("");

    int r = Language::classHandler(n);
    if (r != SWIG_OK) {
      return r;
    }

    if (has_base_classes) {
      // For each method defined in a base class but not defined in
      // this class, we need to define the method in this class.  We
      // can't use anonymous field inheritance because it works
      // differently in Go and in C++.

      Hash *local = NewHash();
      for (Node *ni = Getattr(n, "firstChild"); ni; ni = nextSibling(ni)) {

	if (!is_public(ni)) {
	  continue;
	}

	String *type = Getattr(ni, "nodeType");
	if (Cmp(type, "constructor") == 0 || Cmp(type, "destructor") == 0) {
	  continue;
	}

	String *cname = Getattr(ni, "sym:name");
	if (!cname) {
	  cname = Getattr(ni, "name");
	}
	if (cname) {
	  Setattr(local, cname, NewString(""));
	}
      }

      for (Iterator b = First(baselist); b.item; b = Next(b)) {
	List *bases = NewList();
	Append(bases, Getattr(b.item, "classtype"));
	int r = addBase(n, b.item, bases, local);
	if (r != SWIG_OK) {
	  return r;
	}
	Delete(bases);
      }

      Delete(local);

      Hash *parents = NewHash();
      addFirstBaseInterface(n, parents, baselist);
      int r = addExtraBaseInterfaces(n, parents, baselist);
      Delete(parents);
      if (r != SWIG_OK) {
	return r;
      }
    }

    Printv(f_go_wrappers, "type ", go_name, " interface {\n", NULL);
    Printv(f_go_wrappers, "\tSwigcptr() uintptr\n", NULL);
    Printv(f_go_wrappers, "\tSwigIs", go_name, "()\n", NULL);

    if (is_director) {
      Printv(f_go_wrappers, "\tDirectorInterface() interface{}\n", NULL);
    }

    Append(f_go_wrappers, interfaces);
    Printf(f_go_wrappers, "}\n\n", NULL);
    Delete(interfaces);

    interfaces = NULL;
    class_name = NULL;
    class_receiver = NULL;
    class_node = NULL;
    Delete(class_methods);
    class_methods = NULL;

    Delete(go_type_name);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * addBase()
   *
   * Implement methods and members defined in a parent class for a
   * child class.
   * ------------------------------------------------------------ */

  int addBase(Node *n, Node *base, List *bases, Hash *local) {
    if (GetFlag(base, "feature:ignore")) {
      return SWIG_OK;
    }

    for (Node *ni = Getattr(base, "firstChild"); ni; ni = nextSibling(ni)) {

      if (GetFlag(ni, "feature:ignore")) {
	continue;
      }

      if (!is_public(ni)) {
	continue;
      }

      String *type = Getattr(ni, "nodeType");
      if (Strcmp(type, "constructor") == 0 || Strcmp(type, "destructor") == 0 || Strcmp(type, "enum") == 0 || Strcmp(type, "using") == 0) {
	continue;
      }
      String *storage = Getattr(ni, "storage");
      if (Strcmp(storage, "typedef") == 0 || Strcmp(storage, "friend") == 0) {
	continue;
      }

      String *mname = Getattr(ni, "sym:name");
      if (!mname) {
	continue;
      }

      String *lname = Getattr(ni, "name");
      if (Getattr(class_methods, lname)) {
	continue;
      }
      if (Getattr(local, lname)) {
	continue;
      }
      Setattr(local, lname, NewString(""));

      String *ty = NewString(Getattr(ni, "type"));
      SwigType_push(ty, Getattr(ni, "decl"));
      String *fullty = SwigType_typedef_resolve_all(ty);
      bool is_function = SwigType_isfunction(fullty) ? true : false;
      Delete(ty);
      Delete(fullty);

      if (is_function) {
	int r = goBaseMethod(n, bases, ni);
	if (r != SWIG_OK) {
	  return r;
	}

	if (Getattr(ni, "sym:overloaded")) {
	  for (Node *on = Getattr(ni, "sym:nextSibling"); on; on = Getattr(on, "sym:nextSibling")) {
	    r = goBaseMethod(n, bases, on);
	    if (r != SWIG_OK) {
	      return r;
	    }
	  }

	  String *receiver = class_receiver;
	  bool is_static = isStatic(ni);
	  if (is_static) {
	    receiver = NULL;
	  }
	  String *go_name = buildGoName(Getattr(ni, "sym:name"), is_static, false);
	  r = makeDispatchFunction(ni, go_name, receiver, is_static, NULL, false);
	  Delete(go_name);
	  if (r != SWIG_OK) {
	    return r;
	  }
	}
      } else {
	int r = goBaseVariable(n, bases, ni);
	if (r != SWIG_OK) {
	  return r;
	}
      }
    }

    List *baselist = Getattr(base, "bases");
    if (baselist && Len(baselist) > 0) {
      for (Iterator b = First(baselist); b.item; b = Next(b)) {
	List *nb = Copy(bases);
	Append(nb, Getattr(b.item, "classtype"));
	int r = addBase(n, b.item, nb, local);
	Delete(nb);
	if (r != SWIG_OK) {
	  return r;
	}
      }
    }

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * goBaseMethod()
   *
   * Implement a method defined in a parent class for a child class.
   * ------------------------------------------------------------ */

  int goBaseMethod(Node *method_class, List *bases, Node *method) {
    String *symname = Getattr(method, "sym:name");
    if (!validIdentifier(symname)) {
      return SWIG_OK;
    }

    String *name = NewString("");
    Printv(name, Getattr(method_class, "sym:name"), "_", symname, NULL);

    bool is_static = isStatic(method);

    String *go_name = buildGoName(name, is_static, false);

    String *overname = NULL;
    if (Getattr(method, "sym:overloaded")) {
      overname = Getattr(method, "sym:overname");
    }
    String *wname = Swig_name_wrapper(name);
    if (overname) {
      Append(wname, overname);
    }

    String *result = NewString(Getattr(method, "type"));
    SwigType_push(result, Getattr(method, "decl"));
    if (SwigType_isqualifier(result)) {
      Delete(SwigType_pop(result));
    }
    Delete(SwigType_pop_function(result));

    // If the base method is imported, wrap:action may not be set.
    Swig_save("goBaseMethod", method, "wrap:name", "wrap:action", "parms", NULL);
    Setattr(method, "wrap:name", wname);
    if (!Getattr(method, "wrap:action")) {
      if (!is_static) {
	Swig_MethodToFunction(method, getNSpace(), getClassType(), (Getattr(method, "template") ? SmartPointer : Extend | SmartPointer), NULL, false);
	// Remove any self parameter that was just added.
	ParmList *parms = Getattr(method, "parms");
	if (parms && Getattr(parms, "self")) {
	  parms = CopyParmList(nextSibling(parms));
	  Setattr(method, "parms", parms);
	}
      } else {
	String *call = Swig_cfunction_call(Getattr(method, "name"), Getattr(method, "parms"));
	Setattr(method, "wrap:action", Swig_cresult(Getattr(method, "type"), "result", call));
      }
    }

    int r = makeWrappers(method, name, go_name, overname, wname, bases, Getattr(method, "parms"), result, is_static);

    Swig_restore(method);

    Delete(result);
    Delete(go_name);
    Delete(name);

    return r;
  }

  /* ------------------------------------------------------------
   * goBaseVariable()
   *
   * Add accessors for a member variable defined in a parent class for
   * a child class.
   * ------------------------------------------------------------ */

  int goBaseVariable(Node *var_class, List *bases, Node *var) {
    if (isStatic(var)) {
      return SWIG_OK;
    }

    String *var_name = buildGoName(Getattr(var, "sym:name"), false, false);

    Swig_save("goBaseVariable", var, "type", "wrap:action", NULL);

    // For a pointer type we apparently have to wrap in the decl.
    SwigType *var_type = NewString(Getattr(var, "type"));
    SwigType_push(var_type, Getattr(var, "decl"));
    Setattr(var, "type", var_type);

    SwigType *vt = Copy(var_type);
    if (SwigType_isclass(vt)) {
      SwigType_add_pointer(vt);
    }

    int flags = Extend | SmartPointer | use_naturalvar_mode(var);
    if (is_non_virtual_protected_access(var)) {
      flags |= CWRAP_ALL_PROTECTED_ACCESS;
    }

    String *mname = Swig_name_member(getNSpace(), Getattr(var_class, "sym:name"), var_name);

    if (is_assignable(var)) {
      for (Iterator ki = First(var); ki.key; ki = Next(ki)) {
	if (Strncmp(ki.key, "tmap:", 5) == 0) {
	  Delattr(var, ki.key);
	}
      }
      Swig_save("goBaseVariableSet", var, "name", "sym:name", "type", NULL);

      String *mname_set = NewString("Set");
      Append(mname_set, mname);

      String *go_name = NewString("Set");
      Append(go_name, var_name);

      Swig_MembersetToFunction(var, class_name, flags);

      String *wname = Swig_name_wrapper(mname_set);
      ParmList *parms = NewParm(vt, var_name, var);
      String *result = NewString("void");
      int r = makeWrappers(var, mname_set, go_name, NULL, wname, bases, parms, result, false);
      if (r != SWIG_OK) {
	return r;
      }
      Delete(wname);
      Delete(parms);
      Delete(result);
      Delete(go_name);
      Delete(mname_set);

      Swig_restore(var);
      for (Iterator ki = First(var); ki.key; ki = Next(ki)) {
	if (Strncmp(ki.key, "tmap:", 5) == 0) {
	  Delattr(var, ki.key);
	}
      }
    }

    Swig_MembergetToFunction(var, class_name, flags);

    String *mname_get = NewString("Get");
    Append(mname_get, mname);

    String *go_name = NewString("Get");
    Append(go_name, var_name);

    String *wname = Swig_name_wrapper(mname_get);

    int r = makeWrappers(var, mname_get, go_name, NULL, wname, bases, NULL, vt, false);
    if (r != SWIG_OK) {
      return r;
    }

    Delete(wname);
    Delete(mname_get);
    Delete(go_name);
    Delete(mname);
    Delete(var_name);
    Delete(var_type);
    Delete(vt);

    Swig_restore(var);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * addFirstBaseInterface()
   *
   * When a C++ class uses multiple inheritance, we can use the C++
   * pointer for the first base class but not for any subsequent base
   * classes.  However, the Go interface will match the interface for
   * all the base classes.  To avoid accidentally treating a class as
   * a pointer to a base class other than the first one, we use an
   * isClassname method.  This function adds those methods as
   * required.
   *
   * For convenience when using multiple inheritance, we also add
   * functions to retrieve the base class pointers.
   * ------------------------------------------------------------ */

  void addFirstBaseInterface(Node *n, Hash *parents, List *bases) {
    if (!bases || Len(bases) == 0) {
      return;
    }
    Iterator b = First(bases);
    if (!GetFlag(b.item, "feature:ignore")) {
      String *go_name = buildGoName(Getattr(n, "sym:name"), false, false);
      String *go_type_name = goCPointerType(Getattr(n, "classtypeobj"), true);
      String *go_base_name = exportedName(Getattr(b.item, "sym:name"));
      String *go_base_type = goType(n, Getattr(b.item, "classtypeobj"));
      String *go_base_type_name = goCPointerType(Getattr(b.item, "classtypeobj"), true);

      Printv(f_go_wrappers, "func (p ", go_type_name, ") SwigIs", go_base_name, "() {\n", NULL);
      Printv(f_go_wrappers, "}\n\n", NULL);

      Printv(interfaces, "\tSwigIs", go_base_name, "()\n", NULL);

      Printv(f_go_wrappers, "func (p ", go_type_name, ") SwigGet", go_base_name, "() ", go_base_type, " {\n", NULL);
      Printv(f_go_wrappers, "\treturn ", go_base_type_name, "(p.Swigcptr())\n", NULL);
      Printv(f_go_wrappers, "}\n\n", NULL);

      Printv(interfaces, "\tSwigGet", go_base_name, "() ", go_base_type, "\n", NULL);

      Setattr(parents, go_base_name, NewString(""));

      Delete(go_name);
      Delete(go_type_name);
      Delete(go_base_type);
      Delete(go_base_type_name);
    }

    addFirstBaseInterface(n, parents, Getattr(b.item, "bases"));
  }

  /* ------------------------------------------------------------
   * addExtraBaseInterfaces()
   *
   * Add functions to retrieve the base class pointers for all base
   * classes other than the first.
   * ------------------------------------------------------------ */

  int addExtraBaseInterfaces(Node *n, Hash *parents, List *bases) {
    Iterator b = First(bases);

    Node *fb = b.item;

    for (b = Next(b); b.item; b = Next(b)) {
      if (GetFlag(b.item, "feature:ignore")) {
	continue;
      }

      String *go_base_name = exportedName(Getattr(b.item, "sym:name"));

      Swig_save("addExtraBaseInterface", n, "wrap:action", "wrap:name", "wrap:parms", NULL);

      SwigType *type = Copy(Getattr(n, "classtypeobj"));
      SwigType_add_pointer(type);
      Parm *parm = NewParm(type, "self", n);
      Setattr(n, "wrap:parms", parm);

      String *pn = Swig_cparm_name(parm, 0);
      String *action = NewString("");
      Printv(action, "result = (", Getattr(b.item, "classtype"), "*)", pn, ";", NULL);
      Delete(pn);

      Setattr(n, "wrap:action", action);

      String *name = Copy(class_name);
      Append(name, "_SwigGet");
      Append(name, go_base_name);

      String *go_name = NewString("SwigGet");
      String *c1 = exportedName(go_base_name);
      Append(go_name, c1);
      Delete(c1);

      String *wname = Swig_name_wrapper(name);
      Setattr(n, "wrap:name", wname);

      SwigType *result = Copy(Getattr(b.item, "classtypeobj"));
      SwigType_add_pointer(result);

      int r = makeWrappers(n, name, go_name, NULL, wname, NULL, parm, result,
			   false);
      if (r != SWIG_OK) {
	return r;
      }

      Swig_restore(n);

      Setattr(parents, go_base_name, NewString(""));

      Delete(go_name);
      Delete(type);
      Delete(parm);
      Delete(action);
      Delete(result);

      String *ns = NewString("");
      addParentExtraBaseInterfaces(n, parents, b.item, false, ns);
      Delete(ns);
    }

    if (!GetFlag(fb, "feature:ignore")) {
      String *ns = NewString("");
      addParentExtraBaseInterfaces(n, parents, fb, true, ns);
      Delete(ns);
    }

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * addParentExtraBaseInterfaces()
   *
   * Add functions to retrieve the base class pointers for all base
   * classes of parents other than the first base class at each level.
   * ------------------------------------------------------------ */

  void addParentExtraBaseInterfaces(Node *n, Hash *parents, Node *base, bool is_base_first, String *sofar) {
    List *baselist = Getattr(base, "bases");
    if (!baselist || Len(baselist) == 0) {
      return;
    }

    String *go_this_base_name = exportedName(Getattr(base, "sym:name"));

    String *sf = NewString("");
    Printv(sf, sofar, ".SwigGet", go_this_base_name, "()", NULL);

    Iterator b = First(baselist);

    if (is_base_first) {
      if (!GetFlag(b.item, "feature:ignore")) {
	addParentExtraBaseInterfaces(n, parents, b.item, true, sf);
      }

      b = Next(b);
      if (!b.item) {
	return;
      }
    }

    String *go_name = buildGoName(Getattr(n, "sym:name"), false, false);
    String *go_type_name = goCPointerType(Getattr(n, "classtypeobj"), true);

    for (; b.item; b = Next(b)) {
      if (GetFlag(b.item, "feature:ignore")) {
	continue;
      }

      String *go_base_name = exportedName(Getattr(b.item, "sym:name"));

      if (!Getattr(parents, go_base_name)) {
	Printv(f_go_wrappers, "func (p ", go_type_name, ") SwigGet", go_base_name, "() ", go_base_name, " {\n", NULL);
	Printv(f_go_wrappers, "\treturn p", sf, ".SwigGet", go_base_name, "()\n", NULL);
	Printv(f_go_wrappers, "}\n\n", NULL);

	Printv(interfaces, "\tSwigGet", go_base_name, "() ", go_base_name, "\n", NULL);

	addParentExtraBaseInterfaces(n, parents, b.item, false, sf);

	Setattr(parents, go_base_name, NewString(""));
      }
    }

    Delete(go_name);
    Delete(go_type_name);
    Delete(go_this_base_name);
    Delete(sf);
  }

  /* ------------------------------------------------------------
   * classDirectorInit
   *
   * Add support for a director class.
   *
   * Virtual inheritance is different in Go and C++.  We implement
   * director classes by defining a new function in Go,
   * NewDirectorClassname, which takes a empty interface value and
   * creates an instance of a new child class.  The new child class
   * refers all methods back to Go.  The Go code checks whether the
   * value passed to NewDirectorClassname implements that method; if
   * it does, it calls it, otherwise it calls back into C++.
   * ------------------------------------------------------------ */

  int classDirectorInit(Node *n) {
    // Because we use a different function to handle inheritance in
    // Go, ordinary creations of the object should not create a
    // director object.
    Delete(director_ctor_code);
    director_ctor_code = NewString("$nondirector_new");

    class_node = n;

    String *name = Getattr(n, "sym:name");

    assert(!class_name);
    class_name = name;

    String *go_name = exportedName(name);

    String *go_type_name = goCPointerType(Getattr(n, "classtypeobj"), true);

    assert(!class_receiver);
    class_receiver = go_type_name;

    String *director_struct_name = NewString("_swig_Director");
    Append(director_struct_name, go_name);

    String *cxx_director_name = NewString("SwigDirector_");
    Append(cxx_director_name, name);

    // The Go type of the director class.
    Printv(f_go_wrappers, "type ", director_struct_name, " struct {\n", NULL);
    Printv(f_go_wrappers, "\t", go_type_name, "\n", NULL);
    Printv(f_go_wrappers, "\tv interface{}\n", NULL);
    Printv(f_go_wrappers, "}\n\n", NULL);

    Printv(f_go_wrappers, "func (p *", director_struct_name, ") Swigcptr() uintptr {\n", NULL);
    Printv(f_go_wrappers, "\treturn p.", go_type_name, ".Swigcptr()\n", NULL);
    Printv(f_go_wrappers, "}\n\n", NULL);

    Printv(f_go_wrappers, "func (p *", director_struct_name, ") SwigIs", go_name, "() {\n", NULL);
    Printv(f_go_wrappers, "}\n\n", NULL);

    Printv(f_go_wrappers, "func (p *", director_struct_name, ") DirectorInterface() interface{} {\n", NULL);
    Printv(f_go_wrappers, "\treturn p.v\n", NULL);
    Printv(f_go_wrappers, "}\n\n", NULL);

    // Start defining the director class.
    Printv(f_c_directors_h, "class ", cxx_director_name, " : public ", Getattr(n, "classtype"), "\n", NULL);
    Printv(f_c_directors_h, "{\n", NULL);
    Printv(f_c_directors_h, " public:\n", NULL);

    Delete(director_struct_name);
    Delete(cxx_director_name);

    class_methods = NewHash();

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classDirectorConstructor
   *
   * Emit a constructor for a director class.
   * ------------------------------------------------------------ */

  int classDirectorConstructor(Node *n) {
    bool is_ignored = GetFlag(n, "feature:ignore") ? true : false;

    String *name = Getattr(n, "sym:name");
    if (!name) {
      assert(is_ignored);
      name = Getattr(n, "name");
    }

    String *overname = NULL;
    if (Getattr(n, "sym:overloaded")) {
      overname = Getattr(n, "sym:overname");
    }

    String *go_name = exportedName(name);

    ParmList *parms = Getattr(n, "parms");
    Setattr(n, "wrap:parms", parms);

    String *cn = exportedName(Getattr(parentNode(n), "sym:name"));

    String *go_type_name = goCPointerType(Getattr(parentNode(n), "classtypeobj"), true);

    String *director_struct_name = NewString("_swig_Director");
    Append(director_struct_name, cn);

    String *fn_name = NewString("_swig_NewDirector");
    Append(fn_name, cn);
    Append(fn_name, go_name);

    if (!overname && !is_ignored) {
      if (!checkNameConflict(fn_name, n, NULL)) {
	return SWIG_NOWRAP;
      }
    }

    String *wname = Swig_name_wrapper(fn_name);

    if (overname) {
      Append(wname, overname);
    }
    Setattr(n, "wrap:name", wname);

    bool is_static = isStatic(n);

    Wrapper *dummy = NewWrapper();
    emit_attach_parmmaps(parms, dummy);
    DelWrapper(dummy);

    Swig_typemap_attach_parms("gotype", parms, NULL);
    int parm_count = emit_num_arguments(parms);

    String *func_name = NewString("NewDirector");
    Append(func_name, go_name);

    String *func_with_over_name = Copy(func_name);
    if (overname) {
      Append(func_with_over_name, overname);
    }

    SwigType *first_type = NewString("void");
    SwigType_add_pointer(first_type);
    Parm *first_parm = NewParm(first_type, "swig_p", n);
    set_nextSibling(first_parm, parms);
    Setattr(first_parm, "lname", "p");

    Parm *p = parms;
    for (int i = 0; i < parm_count; ++i) {
      p = getParm(p);
      Swig_cparm_name(p, i);
      p = nextParm(p);
    }

    if (!is_ignored) {
      // Declare the C++ wrapper.
      Printv(f_go_wrappers, "func ", fn_name, NULL);
      if (overname) {
	Printv(f_go_wrappers, overname, NULL);
      }
      Printv(f_go_wrappers, "(*", director_struct_name, NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	String *tm = goType(p, Getattr(p, "type"));
	Printv(f_go_wrappers, ", ", tm, NULL);
	Delete(tm);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ") ", go_type_name, NULL);

      if (gccgo_flag) {
	Printv(f_go_wrappers, " __asm__(\"", go_prefix, "_", wname, "\")", NULL);
      }

      Printv(f_go_wrappers, "\n\n", NULL);

      Printv(f_go_wrappers, "func ", func_with_over_name, "(v interface{}", NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	// Set the lname parameter.
	Printv(f_go_wrappers, ", ", Getattr(p, "lname"), " ", NULL);
	String *tm = goType(p, Getattr(p, "type"));
	Printv(f_go_wrappers, tm, NULL);
	Delete(tm);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ") ", cn, " {\n", NULL);

      Printv(f_go_wrappers, "\tp := &", director_struct_name, "{0, v}\n", NULL);
      Printv(f_go_wrappers, "\tp.", class_receiver, " = ", fn_name, NULL);
      if (overname) {
	Printv(f_go_wrappers, overname, NULL);
      }
      Printv(f_go_wrappers, "(p", NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	Printv(f_go_wrappers, ", ", Getattr(p, "lname"), NULL);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ")\n", NULL);
      Printv(f_go_wrappers, "\treturn p\n", NULL);
      Printv(f_go_wrappers, "}\n\n", NULL);

      SwigType *result = Copy(Getattr(parentNode(n), "classtypeobj"));
      SwigType_add_pointer(result);

      Swig_save("classDirectorConstructor", n, "wrap:name", "wrap:action", NULL);

      Setattr(n, "wrap:name", Swig_name_wrapper(name));

      String *action = NewString("");
      Printv(action, "result = new SwigDirector_", class_name, "(", NULL);
      String *pname = Swig_cparm_name(NULL, 0);
      Printv(action, pname, NULL);
      Delete(pname);
      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	String *pname = Swig_cparm_name(NULL, i + 1);
	Printv(action, ", ", NULL);
	if (SwigType_isreference(Getattr(p, "type"))) {
	  Printv(action, "*", NULL);
	}
	Printv(action, pname, NULL);
	Delete(pname);
	p = nextParm(p);
      }
      Printv(action, ");", NULL);
      Setattr(n, "wrap:action", action);

      if (!gccgo_flag) {
	int r = gcFunctionWrapper(n, fn_name, fn_name, overname, wname,
				  first_parm, result, is_static, false);
	if (r != SWIG_OK) {
	  return r;
	}
	r = gccFunctionWrapper(n, NULL, wname, first_parm, result);
	if (r != SWIG_OK) {
	  return r;
	}
      } else {
	int r = gccgoFunctionWrapper(n, NULL, wname, first_parm, result);
	if (r != SWIG_OK) {
	  return r;
	}
      }

      Swig_restore(n);

      Delete(result);
    }

    String *cxx_director_name = NewString("SwigDirector_");
    Append(cxx_director_name, class_name);

    String *decl = Swig_method_decl(NULL, Getattr(n, "decl"),
				    cxx_director_name, first_parm, 0, 0);
    Printv(f_c_directors_h, "  ", decl, ";\n", NULL);
    Delete(decl);

    decl = Swig_method_decl(NULL, Getattr(n, "decl"), cxx_director_name, first_parm, 0, 0);
    Printv(f_c_directors, cxx_director_name, "::", decl, "\n", NULL);
    Delete(decl);

    Printv(f_c_directors, "    : ", Getattr(parentNode(n), "classtype"), "(", NULL);

    p = parms;
    for (int i = 0; i < parm_count; ++i) {
      p = getParm(p);
      if (i > 0) {
	Printv(f_c_directors, ", ", NULL);
      }
      String *pn = Getattr(p, "name");
      assert(pn);
      Printv(f_c_directors, pn, NULL);
      p = nextParm(p);
    }
    Printv(f_c_directors, "),\n", NULL);
    Printv(f_c_directors, "      go_val(swig_p)\n", NULL);
    Printv(f_c_directors, "{ }\n\n", NULL);

    if (Getattr(n, "sym:overloaded") && !Getattr(n, "sym:nextSibling")) {
      int r = makeDispatchFunction(n, func_name, cn, is_static, Getattr(parentNode(n), "classtypeobj"), false);
      if (r != SWIG_OK) {
	return r;
      }
    }

    Delete(cxx_director_name);
    Delete(go_name);
    Delete(cn);
    Delete(go_type_name);
    Delete(director_struct_name);
    Delete(fn_name);
    Delete(func_name);
    Delete(func_with_over_name);
    Delete(wname);
    Delete(first_type);
    Delete(first_parm);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classDirectorDestructor
   *
   * Emit a destructor for a director class.
   * ------------------------------------------------------------ */

  int classDirectorDestructor(Node *n) {
    if (!is_public(n)) {
      return SWIG_OK;
    }

    bool is_ignored = GetFlag(n, "feature:ignore") ? true : false;

    if (!is_ignored) {
      String *fnname = NewString("DeleteDirector");
      String *c1 = exportedName(class_name);
      Append(fnname, c1);
      Delete(c1);

      String *wname = Swig_name_wrapper(fnname);

      Setattr(n, "wrap:name", fnname);

      Swig_DestructorToFunction(n, getNSpace(), getClassType(), CPlusPlus, Extend);

      ParmList *parms = Getattr(n, "parms");
      Setattr(n, "wrap:parms", parms);

      String *result = NewString("void");
      int r = makeWrappers(n, fnname, fnname, NULL, wname, NULL, parms, result,
			   isStatic(n));
      if (r != SWIG_OK) {
	return r;
      }

      Delete(result);
      Delete(fnname);
      Delete(wname);
    }

    // Generate the destructor for the C++ director class.  Since the
    // Go code is keeping a pointer to the C++ object, we need to call
    // back to the Go code to let it know that the C++ object is gone.

    String *wname = NewString("_swiggo_wrap_DeleteDirector_");
    Append(wname, class_name);

    String *go_name = NewString("Swiggo_DeleteDirector_");
    Append(go_name, class_name);

    String *cn = exportedName(class_name);

    String *director_struct_name = NewString("_swig_Director");
    Append(director_struct_name, cn);

    Printv(f_c_directors_h, "  virtual ~SwigDirector_", class_name, "()", NULL);

    String *throws = buildThrow(n);
    if (throws) {
      Printv(f_c_directors_h, " ", throws, NULL);
    }

    Printv(f_c_directors_h, ";\n", NULL);

    if (!is_ignored) {
      if (!gccgo_flag) {
	Printv(f_c_directors, "extern \"C\" void ", wname, "(void*, int);\n", NULL);
      } else {
	Printv(f_c_directors, "extern \"C\" void ", wname, "(void*) __asm__(\"", go_prefix, ".", package, ".", go_name, "\");\n", NULL);
      }
    }

    Printv(f_c_directors, "SwigDirector_", class_name, "::~SwigDirector_", class_name, "()", NULL);

    if (throws) {
      Printv(f_c_directors, " ", throws, NULL);
      Delete(throws);
    }

    Printv(f_c_directors, "\n", NULL);
    Printv(f_c_directors, "{\n", NULL);

    if (!is_ignored) {
      if (!gccgo_flag) {
	Printv(f_c_directors, "  struct { void *p; } a;\n", NULL);
	Printv(f_c_directors, "  a.p = go_val;\n", NULL);
	Printv(f_c_directors, "  crosscall2(", wname, ", &a, (int) sizeof a);\n", NULL);

	Printv(f_gc_wrappers, "#pragma dynexport ", wname, " ", wname, "\n", NULL);
	Printv(f_gc_wrappers, "extern void \xc2\xb7", go_name, "();\n", NULL);
	Printv(f_gc_wrappers, "void\n", NULL);
	Printv(f_gc_wrappers, wname, "(void *a, int32 n)\n", NULL);
	Printv(f_gc_wrappers, "{\n", NULL);
	Printv(f_gc_wrappers, "\truntime\xc2\xb7" "cgocallback(\xc2\xb7", go_name, ", a, n);\n", NULL);
	Printv(f_gc_wrappers, "}\n\n", NULL);
      } else {
	Printv(f_c_directors, "  ", wname, "(go_val);\n", NULL);
      }
    }

    Printv(f_c_directors, "}\n\n", NULL);

    if (!is_ignored) {
      Printv(f_go_wrappers, "func ", go_name, "(p *", director_struct_name, ") {\n", NULL);
      Printv(f_go_wrappers, "\tp.", class_receiver, " = 0\n", NULL);
      Printv(f_go_wrappers, "}\n\n", NULL);
    }

    Delete(wname);
    Delete(go_name);
    Delete(cn);
    Delete(director_struct_name);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classDirectorMethod
   *
   * Emit a method for a director class, plus its overloads.
   * ------------------------------------------------------------ */

  int classDirectorMethod(Node *n, Node *parent, String *super) {
    (void) super;

    bool is_ignored = GetFlag(n, "feature:ignore") ? true : false;
    bool is_pure_virtual = (Cmp(Getattr(n, "storage"), "virtual") == 0 && Cmp(Getattr(n, "value"), "0") == 0);

    // We don't need explicit calls.
    if (GetFlag(n, "explicitcall")) {
      return SWIG_OK;
    }

    String *name = Getattr(n, "sym:name");
    if (!name) {
      assert(is_ignored);
      name = Getattr(n, "name");
    }

    if (Getattr(class_methods, name)) {
      // We need to emit a pure virtual function, even if it is
      // overloaded.  Otherwise we won't be able to create an instance
      // of the director class.  The function doesn't need to actually
      // do anything.
      if (!is_pure_virtual || Getattr(n, "sym:overloaded")) {
	return SWIG_OK;
      }
    }
    Setattr(class_methods, name, NewString(""));

    if (!Getattr(n, "sym:overloaded")) {
      int r = oneClassDirectorMethod(n, parent);
      if (r != SWIG_OK) {
	return r;
      }
    } else {
      // Handle overloaded methods here, because otherwise we will
      // reject them in the class_methods hash table.  We need to use
      // class_methods so that we correctly handle cases where a
      // function in one class hides a function of the same name in a
      // parent class.
      for (Node *on = Getattr(n, "sym:overloaded"); on; on = Getattr(on, "sym:nextSibling")) {
	int r = oneClassDirectorMethod(on, parent);
	if (r != SWIG_OK) {
	  return r;
	}

	// Swig_overload_rank expects wrap:name and wrap:parms to be
	// set.
	String *wn = Swig_name_wrapper(Getattr(on, "sym:name"));
	Append(wn, Getattr(on, "sym:overname"));
	Setattr(on, "wrap:name", wn);
	Delete(wn);
	Setattr(on, "wrap:parms", Getattr(on, "parms"));
      }

      bool is_static = isStatic(n);

      String *cn = exportedName(Getattr(parent, "sym:name"));
      String *go_name = buildGoName(name, is_static, false);

      String *director_struct_name = NewString("_swig_Director");
      Append(director_struct_name, cn);

      int r = makeDispatchFunction(n, go_name, director_struct_name, is_static, director_struct_name, false);
      if (r != SWIG_OK) {
	return r;
      }

      String *go_upcall = NewString("Director");
      Append(go_upcall, cn);
      Append(go_upcall, go_name);
      r = makeDispatchFunction(n, go_upcall, director_struct_name, is_static, director_struct_name, true);
      if (r != SWIG_OK) {
	return r;
      }

      Delete(cn);
      Delete(go_name);
      Delete(director_struct_name);
      Delete(go_upcall);
    }

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * oneClassDirectorMethod
   *
   * Emit a method for a director class.
   * ------------------------------------------------------------ */

  int oneClassDirectorMethod(Node *n, Node *parent) {
    bool is_ignored = GetFlag(n, "feature:ignore") ? true : false;
    bool is_pure_virtual = (Cmp(Getattr(n, "storage"), "virtual") == 0 && Cmp(Getattr(n, "value"), "0") == 0);

    String *name = Getattr(n, "sym:name");
    if (!name) {
      assert(is_ignored);
      name = Getattr(n, "name");
    }

    String *overname = NULL;
    if (Getattr(n, "sym:overloaded")) {
      overname = Getattr(n, "sym:overname");
    }

    String *cn = exportedName(Getattr(parent, "sym:name"));

    String *go_type_name = goCPointerType(Getattr(parent, "classtypeobj"), true);

    String *director_struct_name = NewString("_swig_Director");
    Append(director_struct_name, cn);

    bool is_static = isStatic(n);

    String *go_name = buildGoName(name, is_static, false);

    ParmList *parms = Getattr(n, "parms");
    Setattr(n, "wrap:parms", parms);

    Wrapper *dummy = NewWrapper();
    emit_attach_parmmaps(parms, dummy);
    DelWrapper(dummy);

    Swig_typemap_attach_parms("gotype", parms, NULL);
    int parm_count = emit_num_arguments(parms);

    SwigType *result = Getattr(n, "returntype");
    if (!result) {
      // This can happen when following overloads.
      result = NewString(Getattr(n, "type"));
      SwigType_push(result, Getattr(n, "decl"));
      if (SwigType_isqualifier(result)) {
	Delete(SwigType_pop(result));
      }
      Delete(SwigType_pop_function(result));
      Setattr(n, "returntype", result);
    }

    // Save the type for overload processing.
    Setattr(n, "go:type", result);

    String *interface_name = NewString("_swig_DirectorInterface");
    Append(interface_name, cn);
    Append(interface_name, go_name);
    if (overname) {
      Append(interface_name, overname);
    }

    String *callback_name = Copy(director_struct_name);
    Append(callback_name, "_callback_");
    Append(callback_name, name);
    Replace(callback_name, "_swig", "Swig", DOH_REPLACE_FIRST);
    if (overname) {
      Append(callback_name, overname);
    }

    String *callback_wname = Swig_name_wrapper(callback_name);

    String *upcall_name = Copy(director_struct_name);
    Append(upcall_name, "_upcall_");
    Append(upcall_name, go_name);

    String *upcall_wname = Swig_name_wrapper(upcall_name);

    String *go_with_over_name = Copy(go_name);
    if (overname) {
      Append(go_with_over_name, overname);
    }

    Wrapper *f = NewWrapper();

    Parm *p = parms;
    for (int i = 0; i < parm_count; ++i) {
      p = getParm(p);
      Swig_cparm_name(p, i);
      if (!Getattr(p, "name")) {
	String *pn = NewString("");
	Printf(pn, "arg%d", i);
	Setattr(p, "name", pn);
      }
      p = nextParm(p);
    }

    Swig_typemap_attach_parms("directorin", parms, f);

    if (!is_ignored) {
      // We use an interface to see if this method is defined in Go.
      Printv(f_go_wrappers, "type ", interface_name, " interface {\n", NULL);
      Printv(f_go_wrappers, "\t", go_with_over_name, "(", NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	if (i > 0) {
	  Printv(f_go_wrappers, ", ", NULL);
	}
	String *tm = goType(p, Getattr(p, "type"));
	Printv(f_go_wrappers, tm, NULL);
	Delete(tm);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ")", NULL);

      if (SwigType_type(result) != T_VOID) {
	String *tm = goType(n, result);
	Printv(f_go_wrappers, " ", tm, NULL);
	Delete(tm);
      }

      Printv(f_go_wrappers, "\n", NULL);
      Printv(f_go_wrappers, "}\n\n", NULL);

      // Declare the upcall function, which calls the method on the
      // parent class.

      if (overname) {
	Append(upcall_wname, overname);
      }

      String *upcall_gc_name = buildGoWrapperName(upcall_name, overname);

      Printv(f_go_wrappers, "func ", upcall_gc_name, "(", go_type_name, NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	String *tm = goWrapperType(p, Getattr(p, "type"), false);
	Printv(f_go_wrappers, ", ", tm, NULL);
	Delete(tm);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ")", NULL);

      if (SwigType_type(result) != T_VOID) {
	String *tm = goWrapperType(n, result, true);
	Printv(f_go_wrappers, " ", tm, NULL);
	Delete(tm);
      }

      if (gccgo_flag) {
	Printv(f_go_wrappers, " __asm__(\"", go_prefix, "_", upcall_wname, "\")", NULL);
      }

      Printv(f_go_wrappers, "\n", NULL);

      // Define the method on the director class in Go.

      Printv(f_go_wrappers, "func (swig_p *", director_struct_name, ") ", go_with_over_name, "(", NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	if (i > 0) {
	  Printv(f_go_wrappers, ", ", NULL);
	}
	Printv(f_go_wrappers, Getattr(p, "lname"), " ", NULL);
	String *tm = goType(p, Getattr(p, "type"));
	Printv(f_go_wrappers, tm, NULL);
	Delete(tm);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ")", NULL);

      if (SwigType_type(result) != T_VOID) {
	String *tm = goType(n, result);
	Printv(f_go_wrappers, " ", tm, NULL);
	Delete(tm);
      }

      Printv(f_go_wrappers, " {\n", NULL);

      Printv(f_go_wrappers, "\tif swig_g, swig_ok := swig_p.v.(", interface_name, "); swig_ok {\n", NULL);
      Printv(f_go_wrappers, "\t\t", NULL);
      if (SwigType_type(result) != T_VOID) {
	Printv(f_go_wrappers, "return ", NULL);
      }
      Printv(f_go_wrappers, "swig_g.", go_with_over_name, "(", NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	if (i > 0) {
	  Printv(f_go_wrappers, ", ", NULL);
	}
	Printv(f_go_wrappers, Getattr(p, "lname"), NULL);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ")\n", NULL);
      if (SwigType_type(result) == T_VOID) {
	Printv(f_go_wrappers, "\t\treturn\n", NULL);
      }
      Printv(f_go_wrappers, "\t}\n", NULL);
      Printv(f_go_wrappers, "\t", NULL);
      if (SwigType_type(result) != T_VOID) {
	Printv(f_go_wrappers, "return ", NULL);
      }
      Printv(f_go_wrappers, upcall_gc_name, "(swig_p.", go_type_name, NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	SwigType *pt = Getattr(p, "type");
	Printv(f_go_wrappers, ", ", Getattr(p, "lname"), NULL);
	if (goTypeIsInterface(p, pt)) {
	  Printv(f_go_wrappers, ".Swigcptr()", NULL);
	}
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ")\n", NULL);
      Printv(f_go_wrappers, "}\n\n", NULL);

      // Define a method in the C++ director class that the C++ upcall
      // function can call.  This permits an upcall to a protected
      // method.

      String *upcall_method_name = NewString("_swig_upcall_");
      Append(upcall_method_name, name);
      if (overname) {
	Append(upcall_method_name, overname);
      }
      String *upcall_decl = Swig_method_decl(Getattr(n, "type"), Getattr(n, "decl"), upcall_method_name, parms, 0, 0);
      Printv(f_c_directors_h, "  ", upcall_decl, " {\n", NULL);
      Delete(upcall_decl);

      Printv(f_c_directors_h, "    ", NULL);
      if (SwigType_type(result) != T_VOID) {
	Printv(f_c_directors_h, "return ", NULL);
      }
      Printv(f_c_directors_h, Getattr(parent, "classtype"), "::", Getattr(n, "name"), "(", NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	if (i > 0) {
	  Printv(f_c_directors_h, ", ", NULL);
	}
	String *pn = Getattr(p, "name");
	assert(pn);
	Printv(f_c_directors_h, pn, NULL);
	p = nextParm(p);
      }

      Printv(f_c_directors_h, ");\n", NULL);
      Printv(f_c_directors_h, "  }\n", NULL);


      // Define the C++ function that the Go function calls.

      SwigType *first_type = NULL;
      Parm *first_parm = parms;
      if (!is_static) {
	first_type = NewString("SwigDirector_");
	Append(first_type, class_name);
	SwigType_add_pointer(first_type);
	first_parm = NewParm(first_type, "p", n);
	set_nextSibling(first_parm, parms);
      }

      Swig_save("classDirectorMethod", n, "wrap:name", "wrap:action", NULL);

      Setattr(n, "wrap:name", upcall_wname);

      String *action = NewString("");
      if (SwigType_type(result) != T_VOID) {
	Printv(action, "result = (", SwigType_lstr(result, 0), ")", NULL);
	if (SwigType_isreference(result)) {
	  Printv(action, "&", NULL);
	}
      }
      Printv(action, Swig_cparm_name(NULL, 0), "->", upcall_method_name, "(", NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	String *pname = Swig_cparm_name(NULL, i + 1);
	if (i > 0) {
	  Printv(action, ", ", NULL);
	}
	// A parameter whose type is a reference is converted into a
	// pointer type by gcCTypeForGoValue.  We are calling a
	// function which expects a reference so we need to convert
	// back.
	if (SwigType_isreference(Getattr(p, "type"))) {
	  Printv(action, "*", NULL);
	}
	Printv(action, pname, NULL);
	Delete(pname);
	p = nextParm(p);
      }
      Printv(action, ");", NULL);
      Setattr(n, "wrap:action", action);

      if (!gccgo_flag) {
	// Write the upcall wrapper function.  This is compiled by gc
	// and calls the C++ function.
	int r = gcFunctionWrapper(n, upcall_name, upcall_name, overname, upcall_wname, first_parm, result, is_static, true);
	if (r != SWIG_OK) {
	  return r;
	}
	r = gccFunctionWrapper(n, NULL, upcall_wname, first_parm, result);
	if (r != SWIG_OK) {
	  return r;
	}
      } else {
	int r = gccgoFunctionWrapper(n, NULL, upcall_wname, first_parm, result);
	if (r != SWIG_OK) {
	  return r;
	}
      }

      Delete(first_type);
      if (first_parm != parms) {
	Delete(first_parm);
      }

      Swig_restore(n);

      // Define a function which uses the Go director type that other
      // methods in the Go type can call to get parent methods.

      Printv(f_go_wrappers, "func Director", cn, go_with_over_name, "(p ", cn, NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	Printv(f_go_wrappers, ", ", Getattr(p, "lname"), " ", NULL);
	String *tm = goType(p, Getattr(p, "type"));
	Printv(f_go_wrappers, tm, NULL);
	Delete(tm);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ")", NULL);

      if (SwigType_type(result) != T_VOID) {
	String *tm = goType(n, result);
	Printv(f_go_wrappers, " ", tm, NULL);
	Delete(tm);
      }

      Printv(f_go_wrappers, " {\n", NULL);

      Printv(f_go_wrappers, "\t", NULL);
      if (SwigType_type(result) != T_VOID) {
	Printv(f_go_wrappers, "return ", NULL);
      }
      Printv(f_go_wrappers, upcall_gc_name, "(p.(*", director_struct_name, ").", go_type_name, NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	SwigType *pt = Getattr(p, "type");
	Printv(f_go_wrappers, ", ", Getattr(p, "lname"), NULL);
	if (goTypeIsInterface(p, pt)) {
	  Printv(f_go_wrappers, ".Swigcptr()", NULL);
	}
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ")\n", NULL);
      Printv(f_go_wrappers, "}\n\n", NULL);

      // The Go function which invokes the method.  This is called
      // from by the C++ method on the director class.

      Printv(f_go_wrappers, "func ", callback_name, "(p *", director_struct_name, NULL);

      p = parms;
      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	String *tm = goWrapperType(p, Getattr(p, "type"), false);
	Printv(f_go_wrappers, ", ", Getattr(p, "lname"), " ", tm, NULL);
	Delete(tm);
	p = nextParm(p);
      }

      Printv(f_go_wrappers, ") ", NULL);
      String *result_wrapper = NULL;
      if (SwigType_type(result) != T_VOID) {
	result_wrapper = goWrapperType(n, result, true);
	Printv(f_go_wrappers, "(swig_result ", result_wrapper, ") ", NULL);
      }
      Printv(f_go_wrappers, "{\n", NULL);
      Printv(f_go_wrappers, "\t", NULL);

      if (is_ignored) {
	Printv(f_go_wrappers, "return\n", NULL);
      } else {
	bool result_is_interface = false;
	if (SwigType_type(result) != T_VOID) {
	  Printv(f_go_wrappers, "return ", NULL);
	  result_is_interface = goTypeIsInterface(NULL, result);
	  if (result_is_interface) {
	    Printv(f_go_wrappers, result_wrapper, "(", NULL);
	  }
	}
	Printv(f_go_wrappers, "p.", go_with_over_name, "(", NULL);

	p = parms;
	for (int i = 0; i < parm_count; ++i) {
	  p = getParm(p);
	  if (i > 0) {
	    Printv(f_go_wrappers, ", ", NULL);
	  }
	  SwigType *pt = Getattr(p, "type");

	  // If the Go representation is an interface type class, then
	  // we are receiving a uintptr, and must convert to the
	  // interface.
	  bool is_interface = goTypeIsInterface(p, pt);
	  if (is_interface) {
	    // Passing is_result as true to goWrapperType gives us the
	    // name of the Go type we need to convert to an interface.
	    String *wt = goWrapperType(p, pt, true);
	    Printv(f_go_wrappers, wt, "(", NULL);
	    Delete(wt);
	  }

	  Printv(f_go_wrappers, Getattr(p, "lname"), NULL);

	  if (is_interface) {
	    Printv(f_go_wrappers, ")", NULL);
	  }

	  p = nextParm(p);
	}

	Printv(f_go_wrappers, ")", NULL);

	if (result_is_interface) {
	  Printv(f_go_wrappers, ".Swigcptr())", NULL);
	}

	Printv(f_go_wrappers, "\n", NULL);

	Delete(upcall_gc_name);
      }

      Printv(f_go_wrappers, "}\n\n", NULL);

      Delete(result_wrapper);

      // Build the C++ functions.

      Delete(upcall_wname);

      if (!gccgo_flag) {
	Printv(f_c_directors, "extern \"C\" void ", callback_wname, "(void*, int);\n", NULL);
      } else {
	Printv(f_c_directors, "extern \"C\" ", NULL);

	String *fnname = NewString("");
	Printv(fnname, callback_wname, "(void*", NULL);

	p = parms;
	while (p) {
	  while (checkAttribute(p, "tmap:directorin:numinputs", "0")) {
	    p = Getattr(p, "tmap:directorin:next");
	  }
	  String *cg = gccgoCTypeForGoValue(p, Getattr(p, "type"),
					    Getattr(p, "lname"));
	  Printv(fnname, ", ", cg, NULL);
	  Delete(cg);
	  p = Getattr(p, "tmap:directorin:next");
	}

	Printv(fnname, ")", NULL);

	if (SwigType_type(result) == T_VOID) {
	  Printv(f_c_directors, "void ", fnname, NULL);
	} else {
	  String *tm = gccgoCTypeForGoValue(n, result, fnname);
	  Printv(f_c_directors, tm, NULL);
	  Delete(tm);
	}

	Delete(fnname);

	Printv(f_c_directors, " __asm__(\"", go_prefix, ".", package, ".", callback_name, "\");\n", NULL);
      }

      Delete(upcall_method_name);
      Delete(go_with_over_name);
    }

    if (!is_ignored || is_pure_virtual) {
      // Declare the method for the director class.

      SwigType *rtype = (Getattr(n, "conversion_operator") ? NULL : Getattr(n, "type"));
      String *decl = Swig_method_decl(rtype, Getattr(n, "decl"), Getattr(n, "name"), parms, 0, 0);
      Printv(f_c_directors_h, "  virtual ", decl, NULL);
      Delete(decl);

      String *qname = NewString("");
      Printv(qname, "SwigDirector_", class_name, "::", Getattr(n, "name"), NULL);
      decl = Swig_method_decl(rtype, Getattr(n, "decl"), qname, parms, 0, 0);
      Printv(f->def, decl, NULL);
      Delete(decl);
      Delete(qname);

      String *throws = buildThrow(n);
      if (throws) {
	Printv(f_c_directors_h, " ", throws, NULL);
	Printv(f->def, " ", throws, NULL);
	Delete(throws);
      }

      Printv(f_c_directors_h, ";\n", NULL);

      Printv(f->def, " {\n", NULL);

      if (SwigType_type(result) != T_VOID) {
	Wrapper_add_local(f, "c_result", SwigType_lstr(Getattr(n, "returntype"), "c_result"));
      }

      if (!is_ignored) {
	if (!gccgo_flag) {
	  Printv(f->code, "  struct {\n", NULL);
	  Printv(f->code, "    void *go_val;\n", NULL);

	  p = parms;
	  while (p) {
	    while (checkAttribute(p, "tmap:directorin:numinputs", "0")) {
	      p = Getattr(p, "tmap:directorin:next");
	    }
	    String *ln = Getattr(p, "lname");
	    String *cg = gcCTypeForGoValue(p, Getattr(p, "type"), ln);
	    Printv(f->code, "      ", cg, ";\n", NULL);
	    Delete(cg);
	    p = Getattr(p, "tmap:directorin:next");
	  }
	  if (SwigType_type(result) != T_VOID) {
	    Printv(f->code, "    int : 0;\n", NULL);
	    String *rname = NewString("result");
	    String *cg = gcCTypeForGoValue(n, result, rname);
	    Printv(f->code, "    ", cg, ";\n", NULL);
	    Delete(cg);
	    Delete(rname);
	  }

	  Printv(f->code, "  } swig_a;\n", NULL);
	  Printv(f->code, "  swig_a.go_val = go_val;\n", NULL);

	  p = parms;
	  while (p) {
	    while (checkAttribute(p, "tmap:directorin:numinputs", "0")) {
	      p = Getattr(p, "tmap:directorin:next");
	    }
	    String *tm = Getattr(p, "tmap:directorin");
	    if (!tm) {
	      Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file,
			   line_number, "Unable to use type %s as director method argument\n", SwigType_str(Getattr(p, "type"), 0));
	    } else {
	      String *ln = Getattr(p, "lname");
	      String *input = NewString("");
	      Printv(input, "swig_a.", ln, NULL);
	      Replaceall(tm, "$input", input);
	      Replaceall(tm, "$owner", "0");
	      Delete(input);
	      Printv(f->code, "\t", tm, "\n", NULL);
	    }
	    p = Getattr(p, "tmap:directorin:next");
	  }

	  Printv(f->code, "  crosscall2(", callback_wname, ", &swig_a, (int) sizeof swig_a);\n", NULL);

	  if (SwigType_type(result) != T_VOID) {
	    String *rname = NewString("c_result");
	    Parm *rp = NewParm(Getattr(n, "returntype"), rname, n);
	    String *tm = Swig_typemap_lookup("directorout", rp, rname, NULL);
	    if (!tm) {
	      Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number,
			   "Unable to use type %s as director method result\n", SwigType_str(result, 0));
	    } else {
	      Replaceall(tm, "$input", "swig_a.result");
	      Replaceall(tm, "$result", "c_result");
	      Printv(f->code, "  ", tm, "\n", NULL);
	      String *retstr = SwigType_rcaststr(Getattr(n, "returntype"), "c_result");
	      Printv(f->code, "  return ", retstr, ";\n", NULL);
	      Delete(retstr);
	      Delete(tm);
	    }
	    Delete(rp);
	    Delete(rname);
	  }

	  // The C wrapper code which calls the Go function.
	  Printv(f_gc_wrappers, "#pragma dynexport ", callback_wname, " ", callback_wname, "\n", NULL);
	  Printv(f_gc_wrappers, "extern void \xc2\xb7", callback_name, "();\n", NULL);
	  Printv(f_gc_wrappers, "void\n", NULL);
	  Printv(f_gc_wrappers, callback_wname, "(void *a, int32 n)\n", NULL);
	  Printv(f_gc_wrappers, "{\n", NULL);
	  Printv(f_gc_wrappers, "\truntime\xc2\xb7" "cgocallback(\xc2\xb7", callback_name, ", a, n);\n", NULL);
	  Printv(f_gc_wrappers, "}\n\n", NULL);
	} else {
	  if (SwigType_type(result) != T_VOID) {
	    String *r = NewString("result");
	    String *tm = gccgoCTypeForGoValue(n, result, r);
	    Wrapper_add_local(f, r, tm);
	    Delete(tm);
	    Delete(r);
	  }

	  String *args = NewString("");

	  p = parms;
	  while (p) {
	    while (checkAttribute(p, "tmap:directorin:numinputs", "0")) {
	      p = Getattr(p, "tmap:directorin:next");
	    }

	    String *pn = NewString("g");
	    Append(pn, Getattr(p, "lname"));
	    Setattr(p, "emit:input", pn);

	    String *tm = gccgoCTypeForGoValue(n, Getattr(p, "type"), pn);
	    Wrapper_add_local(f, pn, tm);
	    Delete(tm);

	    tm = Getattr(p, "tmap:directorin");
	    if (!tm) {
	      Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file,
			   line_number, "Unable to use type %s as director method argument\n", SwigType_str(Getattr(p, "type"), 0));
	    } else {
	      Replaceall(tm, "$input", pn);
	      Replaceall(tm, "$owner", 0);
	      Printv(f->code, "  ", tm, "\n", NULL);

	      Printv(args, ", ", pn, NULL);
	    }

	    p = Getattr(p, "tmap:directorin:next");
	  }

	  Printv(f->code, "  ", NULL);
	  if (SwigType_type(result) != T_VOID) {
	    Printv(f->code, "result = ", NULL);
	  }
	  Printv(f->code, callback_wname, "(go_val", args, ");\n", NULL);

	  if (SwigType_type(result) != T_VOID) {
	    String *rname = NewString("c_result");
	    Parm *rp = NewParm(Getattr(n, "returntype"), rname, n);
	    String *tm = Swig_typemap_lookup("directorout", rp, rname, NULL);
	    if (!tm) {
	      Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number,
			   "Unable to use type %s as director method result\n", SwigType_str(result, 0));
	    } else {
	      Replaceall(tm, "$input", "result");
	      Replaceall(tm, "$result", "c_result");
	      Printv(f->code, "  ", tm, "\n", NULL);
	      String *retstr = SwigType_rcaststr(Getattr(n, "returntype"), "c_result");
	      Printv(f->code, "  return ", retstr, ";\n", NULL);
	      Delete(retstr);
	      Delete(tm);
	    }
	    Delete(rp);
	    Delete(rname);
	  }
	}
      } else {
	assert(is_pure_virtual);
	Printv(f->code, "  _swig_gopanic(\"call to pure virtual function ", Getattr(parent, "sym:name"), name, "\");\n");
	if (SwigType_type(result) != T_VOID) {
	  String *retstr = SwigType_rcaststr(Getattr(n, "returntype"), "c_result");
	  Printv(f->code, "  return ", retstr, ";\n", NULL);
	  Delete(retstr);
	}
      }

      Printv(f->code, "}", NULL);

      Wrapper_print(f, f_c_directors);

      DelWrapper(f);
    }

    Delete(cn);
    Delete(go_type_name);
    Delete(director_struct_name);
    Delete(interface_name);
    Delete(upcall_name);
    Delete(callback_wname);
    Delete(go_name);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classDirectorEnd
   *
   * Complete support for a director class.
   * ------------------------------------------------------------ */

  int classDirectorEnd(Node *n) {
    (void) n;

    Printv(f_c_directors_h, " private:\n", NULL);
    Printv(f_c_directors_h, "  void *go_val;\n", NULL);
    Printv(f_c_directors_h, "};\n\n", NULL);

    class_name = NULL;
    class_node = NULL;

    Delete(class_receiver);
    class_receiver = NULL;

    Delete(class_methods);
    class_methods = NULL;

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classDirectorDisown
   *
   * I think Go does not require a disown method.
   * ------------------------------------------------------------ */

  int classDirectorDisown(Node *n) {
    (void) n;
    return SWIG_OK;
  }

  /*----------------------------------------------------------------------
   * buildThrow()
   *
   * Build and return a throw clause if needed.
   *--------------------------------------------------------------------*/

  String *buildThrow(Node *n) {
    ParmList *throw_parm_list = Getattr(n, "throws");
    if (!throw_parm_list && !Getattr(n, "throw"))
      return NULL;
    String *ret = NewString("throw(");
    if (throw_parm_list) {
      Swig_typemap_attach_parms("throws", throw_parm_list, NULL);
    }
    bool first = true;
    for (Parm *p = throw_parm_list; p; p = nextSibling(p)) {
      if (Getattr(p, "tmap:throws")) {
	if (first) {
	  first = false;
	} else {
	  Printv(ret, ", ", NULL);
	}
	String *s = SwigType_str(Getattr(p, "type"), 0);
	Printv(ret, s, NULL);
	Delete(s);
      }
    }
    Printv(ret, ")", NULL);
    return ret;
  }

  /*----------------------------------------------------------------------
   * extraDirectorProtectedCPPMethodsRequired()
   *
   * We don't need to check upcall when calling methods.
   *--------------------------------------------------------------------*/

  bool extraDirectorProtectedCPPMethodsRequired() const {
    return false;
  }

  /*----------------------------------------------------------------------
   * makeDispatchFunction
   *
   * Make a dispatch function for an overloaded C++ function.  The
   * receiver parameter is the receiver for a method, unless is_upcall
   * is true.  If is_upcall is true, then the receiver parameter is
   * the type of the first argument to the function.
   *--------------------------------------------------------------------*/

  int makeDispatchFunction(Node *n, String *go_name, String *receiver, bool is_static, SwigType *director_struct, bool is_upcall) {
    bool is_director = director_struct ? true : false;

    String *nodetype = Getattr(n, "nodeType");
    bool is_constructor = Cmp(nodetype, "constructor") == 0;
    bool is_destructor = Cmp(nodetype, "destructor") == 0;

    bool can_use_receiver = (!is_constructor && !is_destructor && !is_upcall);

    bool use_receiver = (!is_static && can_use_receiver);

    bool add_to_interface = (interfaces && !is_constructor && !is_destructor && !is_static && !is_upcall);

    List *dispatch = Swig_overload_rank(n, false);
    int nfunc = Len(dispatch);

    SwigType *all_result;
    bool mismatch;
    if (is_constructor) {
      assert(!is_upcall);
      if (!is_director) {
	all_result = Getattr(class_node, "classtypeobj");
      } else {
	all_result = director_struct;
      }
      mismatch = false;
    } else {
      all_result = NULL;
      mismatch = false;
      bool any_void = false;
      for (int i = 0; i < nfunc; ++i) {
	Node *ni = Getitem(dispatch, i);
	SwigType *result = Getattr(ni, "go:type");
	assert(result);

	if (SwigType_type(result) == T_VOID) {
	  if (all_result) {
	    mismatch = true;
	  }
	  any_void = true;
	} else {
	  if (any_void) {
	    mismatch = true;
	  } else if (!all_result) {
	    all_result = Copy(result);
	  } else if (Cmp(result, all_result) != 0) {
	    mismatch = true;
	  }
	}
      }
      if (mismatch) {
	Delete(all_result);
	all_result = NULL;
      } else if (all_result) {
	;
      } else {
	all_result = NewString("void");
      }
    }

    Printv(f_go_wrappers, "func ", NULL);

    if (receiver && use_receiver) {
      Printv(f_go_wrappers, "(p ", receiver, ") ", NULL);
    }

    Printv(f_go_wrappers, go_name, "(", NULL);
    if (is_director && is_constructor) {
      Printv(f_go_wrappers, "abi interface{}, ", NULL);
      assert(!add_to_interface);
    }
    if (is_upcall) {
      Printv(f_go_wrappers, "p *", receiver, ", ", NULL);
      assert(!add_to_interface);
    }
    Printv(f_go_wrappers, "a ...interface{})", NULL);

    if (add_to_interface) {
      Printv(interfaces, "\t", go_name, "(a ...interface{})", NULL);
    }

    if (mismatch) {
      Printv(f_go_wrappers, " interface{}", NULL);
      if (add_to_interface) {
	Printv(interfaces, " interface{}", NULL);
      }
    } else if (all_result && SwigType_type(all_result) != T_VOID) {
      if (is_director && is_constructor) {
	Printv(f_go_wrappers, " ", receiver, NULL);
	if (add_to_interface) {
	  Printv(interfaces, " ", receiver, NULL);
	}
      } else {
	String *tm = goType(n, all_result);
	Printv(f_go_wrappers, " ", tm, NULL);
	if (add_to_interface) {
	  Printv(interfaces, " ", tm, NULL);
	}
	Delete(tm);
      }
    }
    Printv(f_go_wrappers, " {\n", NULL);
    if (add_to_interface) {
      Printv(interfaces, "\n", NULL);
    }

    Printv(f_go_wrappers, "\targc := len(a)\n", NULL);

    for (int i = 0; i < nfunc; ++i) {
      int fn = 0;
      Node *ni = Getitem(dispatch, i);
      Parm *pi = Getattr(ni, "wrap:parms");

      // If we are using a receiver, we want to ignore a leading self
      // parameter.  Because of the way this is called, there may or
      // may not be a self parameter at this point.
      if (use_receiver && pi && Getattr(pi, "self")) {
	pi = getParm(pi);
	if (pi) {
	  pi = nextParm(pi);
	}
      }

      int num_required = emit_num_required(pi);
      int num_arguments = emit_num_arguments(pi);
      bool varargs = emit_isvarargs(pi) ? true : false;

      if (varargs) {
	Printf(f_go_wrappers, "\tif argc >= %d {\n", num_required);
      } else {
	if (num_required == num_arguments) {
	  Printf(f_go_wrappers, "\tif argc == %d {\n", num_required);
	} else {
	  Printf(f_go_wrappers, "\tif argc >= %d && argc <= %d {\n", num_required, num_arguments);
	}
      }

      // Build list of collisions with the same number of arguments.
      List *coll = NewList();
      for (int k = i + 1; k < nfunc; ++k) {
	Node *nk = Getitem(dispatch, k);
	Parm *pk = Getattr(nk, "wrap:parms");
	if (use_receiver && pk && Getattr(pk, "self")) {
	  pk = getParm(pk);
	  if (pk) {
	    pk = nextParm(pk);
	  }
	}
	int nrk = emit_num_required(pk);
	int nak = emit_num_arguments(pk);
	if ((nrk >= num_required && nrk <= num_arguments)
	    || (nak >= num_required && nak <= num_arguments)
	    || (nrk <= num_required && nak >= num_arguments)) {
	  Append(coll, nk);
	}
      }

      int num_braces = 0;
      if (Len(coll) > 0 && num_arguments > 0) {
	int j = 0;
	Parm *pj = pi;
	while (pj) {
	  pj = getParm(pj);
	  if (!pj) {
	    break;
	  }

	  // If all the wrappers have the same type in this position,
	  // we can omit the check.
	  SwigType *tm = goWrapperType(pj, Getattr(pj, "type"), true);
	  bool emitcheck = false;
	  for (int k = 0; k < Len(coll) && !emitcheck; ++k) {
	    Node *nk = Getitem(coll, k);
	    Parm *pk = Getattr(nk, "wrap:parms");
	    if (use_receiver && pk && Getattr(pk, "self")) {
	      pk = getParm(pk);
	      if (pk) {
		pk = nextParm(pk);
	      }
	    }
	    int nak = emit_num_arguments(pk);
	    if (nak <= j)
	      continue;
	    int l = 0;
	    Parm *pl = pk;
	    while (pl && l <= j) {
	      pl = getParm(pl);
	      if (!pl) {
		break;
	      }
	      if (l == j) {
		SwigType *tml = goWrapperType(pl, Getattr(pl, "type"), true);
		if (Cmp(tm, tml) != 0) {
		  emitcheck = true;
		}
		Delete(tml);
	      }
	      pl = nextParm(pl);
	      ++l;
	    }
	  }

	  if (emitcheck) {
	    if (j >= num_required) {
	      Printf(f_go_wrappers, "\t\tif argc > %d {\n", j);
	      ++num_braces;
	    }

	    fn = i + 1;
	    Printf(f_go_wrappers, "\t\tif _, ok := a[%d].(%s); !ok {\n", j, tm);
	    Printf(f_go_wrappers, "\t\t\tgoto check_%d\n", fn);
	    Printv(f_go_wrappers, "\t\t}\n", NULL);
	  }

	  Delete(tm);

	  pj = nextParm(pj);

	  ++j;
	}
      }

      for (; num_braces > 0; --num_braces) {
	Printv(f_go_wrappers, "\t\t}\n", NULL);
      }

      // We may need to generate multiple calls if there are variable
      // argument lists involved.  Build the start of the call.

      String *start = NewString("");

      SwigType *result = Getattr(ni, "go:type");

      if (is_constructor) {
	result = all_result;
      } else if (is_destructor) {
	result = NULL;
      }

      if (result && SwigType_type(result) != T_VOID && (!all_result || SwigType_type(all_result) != T_VOID)) {
	Printv(start, "return ", NULL);
      }

      bool advance_parm = false;

      if (receiver && use_receiver) {
	Printv(start, "p.", go_name, NULL);
      } else if (can_use_receiver && !isStatic(ni) && pi && Getattr(pi, "self")) {
	// This is an overload of a static function and a non-static
	// function.
	assert(num_required > 0);
	SwigType *tm = goWrapperType(pi, Getattr(pi, "type"), true);
	String *nm = buildGoName(Getattr(ni, "sym:name"), false, isFriend(ni));
	Printv(start, "a[0].(", tm, ").", nm, NULL);
	Delete(nm);
	Delete(tm);
	advance_parm = true;
      } else {
	Printv(start, go_name, NULL);
      }

      Printv(start, Getattr(ni, "sym:overname"), "(", NULL);

      bool need_comma = false;

      if (is_director && is_constructor) {
	Printv(start, "abi", NULL);
	need_comma = true;
      }
      if (is_upcall) {
	Printv(start, "p", NULL);
	need_comma = true;
      }
      Parm *p = pi;
      int pn = 0;
      if (advance_parm) {
	p = getParm(p);
	if (p) {
	  p = nextParm(p);
	}
	++pn;
      }
      while (pn < num_required) {
	p = getParm(p);

	if (need_comma) {
	  Printv(start, ", ", NULL);
	}

	SwigType *tm = goType(p, Getattr(p, "type"));
	Printf(start, "a[%d].(%s)", pn, tm);
	Delete(tm);

	need_comma = true;
	++pn;
	p = nextParm(p);
      }

      String *end = NULL;
      if (!result || SwigType_type(result) == T_VOID || (all_result && SwigType_type(all_result) == T_VOID)) {
	end = NewString("");
	Printv(end, "return", NULL);
	if (!all_result || SwigType_type(all_result) != T_VOID) {
	  Printv(end, " 0", NULL);
	}
      }

      if (num_required == num_arguments) {
	Printv(f_go_wrappers, "\t\t", start, ")\n", NULL);
	if (end) {
	  Printv(f_go_wrappers, "\t\t", end, "\n", NULL);
	}
      } else {
	Printv(f_go_wrappers, "\t\tswitch argc {\n", NULL);
	for (int j = num_required; j <= num_arguments; ++j) {
	  Printf(f_go_wrappers, "\t\tcase %d:\n", j);
	  Printv(f_go_wrappers, "\t\t\t", start, NULL);
	  bool nc = need_comma;
	  for (int k = num_required; k < j; ++k) {
	    if (nc) {
	      Printv(f_go_wrappers, ", ", NULL);
	    }
	    Printf(f_go_wrappers, "a[%d]", k);
	    nc = true;
	  }
	  Printv(f_go_wrappers, ")\n", NULL);
	  if (end) {
	    Printv(f_go_wrappers, "\t\t\t", end, "\n", NULL);
	  }
	}
	Printv(f_go_wrappers, "\t\t}\n", NULL);
      }

      Printv(f_go_wrappers, "\t}\n", NULL);

      if (fn != 0) {
	Printf(f_go_wrappers, "check_%d:\n", fn);
      }

      Delete(coll);
    }

    Printv(f_go_wrappers, "fail:\n", NULL);
    Printv(f_go_wrappers, "\tpanic(\"No match for overloaded function call\")\n", NULL);
    Printv(f_go_wrappers, "}\n\n", NULL);

    Delete(all_result);
    Delete(dispatch);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * exportedName()
   *
   * Given a C/C++ name, return a name in Go which will be exported.
   * If the first character is an upper case letter, this returns a
   * copy of its argment.  If the first character is a lower case
   * letter, this forces it to upper case.  Otherwise, this prepends
   * 'X'.
   * ---------------------------------------------------------------------- */

  String *exportedName(String *name) {
    String *copy = Copy(name);
    char c = *Char(copy);
    if (islower(c)) {
      char l[2];
      char u[2];
      l[0] = c;
      l[1] = '\0';
      u[0] = toupper(c);
      u[1] = '\0';
      Replace(copy, l, u, DOH_REPLACE_FIRST);
    } else if (!isalpha(c)) {
      char l[2];
      char u[3];
      l[0] = c;
      l[1] = '\0';
      u[0] = 'X';
      u[1] = c;
      u[2] = '\0';
      Replace(copy, l, u, DOH_REPLACE_FIRST);
    }
    String *ret = Swig_name_mangle(copy);
    Delete(copy);
    return ret;
  }

  /* ----------------------------------------------------------------------
   * removeClassname()
   *
   * If the name starts with the current class name, followed by an
   * underscore, remove it.  If there is no current class name, this
   * simply returns a copy of the name.  This undoes Swig's way of
   * recording the class name in a member name.
   * ---------------------------------------------------------------------- */

  String *removeClassname(String *name) {
    String *copy = Copy(name);
    if (class_name) {
      char *p = Char(name);
      if (Strncmp(name, class_name, Len(class_name)) == 0 && p[Len(class_name)] == '_') {
	Replace(copy, class_name, "", DOH_REPLACE_FIRST);
	Replace(copy, "_", "", DOH_REPLACE_FIRST);
      }
    }
    return copy;
  }

  /* ----------------------------------------------------------------------
   * buildGoName()
   *
   * Build the name to use for an ordinary function, variable, or
   * whatever in Go.  The name argument is something like the sym:name
   * attribute of the node.  If is_static is false, this could be a
   * method, and the returned name will be the name of the
   * method--i.e., it will not include the class name.
   * ---------------------------------------------------------------------- */

  String *buildGoName(String *name, bool is_static, bool is_friend) {
    String *nw = NewString("");
    if (is_static && !is_friend && class_name) {
      String *c1 = exportedName(class_name);
      Append(nw, c1);
      Delete(c1);
    }
    String *c2 = removeClassname(name);
    String *c3 = exportedName(c2);
    Append(nw, c3);
    Delete(c2);
    Delete(c3);
    String *ret = Swig_name_mangle(nw);
    Delete(nw);
    return ret;
  }

  /* ----------------------------------------------------------------------
   * buildGoWrapperName()
   *
   * Build the name to use for a Go wrapper function.  This is a
   * function called by the real Go function in order to convert C++
   * classes from interfaces to pointers, and other such conversions
   * between the Go type and the C++ type.
   * ---------------------------------------------------------------------- */

  String *buildGoWrapperName(String *name, String *overname) {
    String *s1 = NewString("_swig_wrap_");
    Append(s1, name);
    String *s2 = Swig_name_mangle(s1);
    Delete(s1);
    if (overname) {
      Append(s2, overname);
    }
    return s2;
  }

  /* ----------------------------------------------------------------------
   * checkNameConflict()
   *
   * Check for a name conflict on the name we are going to use in Go.
   * These conflicts are likely because of the enforced
   * capitalization.  When we find one, issue a warning and return
   * false.  If the name is OK, return true.
   * ---------------------------------------------------------------------- */

  bool checkNameConflict(String* name, Node* n, const_String_or_char_ptr scope) {
    Node *lk = symbolLookup(name, scope);
    if (lk) {
      String *n1 = Getattr(n, "sym:name");
      if (!n1) {
	n1 = Getattr(n, "name");
      }
      String *n2 = Getattr(lk, "sym:name");
      if (!n2) {
	n2 = Getattr(lk, "name");
      }
      Swig_warning(WARN_GO_NAME_CONFLICT, input_file, line_number,
		   "Ignoring '%s' due to Go name ('%s') conflict with '%s'\n",
		   n1, name, n2);
      return false;
    }
    bool r = addSymbol(name, n, scope) ? true : false;
    assert(r);
    return true;
  }

  /* ----------------------------------------------------------------------
   * checkIgnoredParameters()
   *
   * If any of the parameters of this function, or the return type,
   * are ignored due to a name conflict, give a warning and return
   * false.
   * ---------------------------------------------------------------------- */

  bool checkIgnoredParameters(Node *n, String *go_name) {
    ParmList *parms = Getattr(n, "parms");
    if (parms) {
      Wrapper *dummy = NewWrapper();
      emit_attach_parmmaps(parms, dummy);
      int parm_count = emit_num_arguments(parms);
      Parm *p = parms;

      for (int i = 0; i < parm_count; ++i) {
	p = getParm(p);
	if (!checkIgnoredType(n, go_name, Getattr(p, "type"))) {
	  DelWrapper(dummy);
	  return false;
	}
	p = nextParm(p);
      }

      DelWrapper(dummy);
    }

    if (!checkIgnoredType(n, go_name, Getattr(n, "type"))) {
      return false;
    }

    return true;
  }

  /* ----------------------------------------------------------------------
   * checkIgnoredType()
   *
   * If this type is being ignored due to a name conflict, give a
   * warning and return false.
   * ---------------------------------------------------------------------- */

  bool checkIgnoredType(Node *n, String *go_name, SwigType *type) {
    if (hasGoTypemap(type)) {
      return true;
    }

    SwigType *t = SwigType_typedef_resolve_all(type);

    bool ret = true;
    bool is_conflict = false;
    Node *e = Language::enumLookup(t);
    if (e) {
      if (GetFlag(e, "go:conflict")) {
	is_conflict = true;
      }
    } else if (SwigType_issimple(t)) {
      Node *cn = classLookup(t);
      if (cn) {
	if (GetFlag(cn, "go:conflict")) {
	  is_conflict = true;
	}
      }
    } else if (SwigType_ispointer(t) || SwigType_isarray(t) || SwigType_isqualifier(t) || SwigType_isreference(t)) {
      SwigType *r = Copy(t);
      if (SwigType_ispointer(r)) {
	SwigType_del_pointer(r);
      } else if (SwigType_isarray(r)) {
	SwigType_del_array(r);
      } else if (SwigType_isqualifier(r)) {
	SwigType_del_qualifier(r);
      } else {
	SwigType_del_reference(r);
      }

      if (!checkIgnoredType(n, go_name, r)) {
	ret = false;
      }

      Delete(r);
    }

    if (is_conflict) {
      String *s = SwigType_str(t, NULL);
      Swig_warning(WARN_GO_NAME_CONFLICT, input_file, line_number,
		   "Ignoring '%s' (Go name '%s') due to Go name conflict for parameter or result type '%s'\n",
		   Getattr(n, "name"), go_name, s);
      Delete(s);
      ret = false;
    }

    Delete(t);

    return ret;
  }

  /* ----------------------------------------------------------------------
   * goType()
   *
   * Given a SWIG type, return a string for the type in Go.
   * ---------------------------------------------------------------------- */

  String *goType(Node *n, SwigType *type) {
    return goTypeWithInfo(n, type, NULL);
  }

  /* ----------------------------------------------------------------------
   * goTypeWithInfo()
   *
   * Like goType, but return some more information.
   *
   * If the p_is_interface parameter is not NULL, this sets
   * *p_is_interface to indicate whether this type is going to be
   * represented by a Go interface type.  These are cases where the Go
   * code needs to make some adjustments when passing values back and
   * forth with C/C++.
   * ---------------------------------------------------------------------- */

  String *goTypeWithInfo(Node *n, SwigType *type, bool *p_is_interface) {
    if (p_is_interface) {
      *p_is_interface = false;
    }

    String *ret;
    if (n && Cmp(type, Getattr(n, "type")) == 0) {
      ret = NULL;
      if (Strcmp(Getattr(n, "nodeType"), "parm") == 0) {
	ret = Getattr(n, "tmap:gotype");
      }
      if (!ret) {
	ret = Swig_typemap_lookup("gotype", n, "", NULL);
      }
    } else {
      Parm *p = NewParmWithoutFileLineInfo(type, "goType");
      ret = Swig_typemap_lookup("gotype", p, "", NULL);
      Delete(p);
    }

    if (Strstr(ret, "$gotypename") != 0) {
      ret = NULL;
    }

    if (ret) {
      return Copy(ret);
    }

    SwigType *t = SwigType_typedef_resolve_all(type);

    Node *e = Language::enumLookup(t);
    if (e) {
      ret = goEnumName(e);
    } else if (Strcmp(t, "enum ") == 0) {
      ret = NewString("int");
    } else if (SwigType_isfunctionpointer(type) || SwigType_isfunction(type)) {
      ret = NewString("_swig_fnptr");
    } else if (SwigType_ismemberpointer(type)) {
      ret = NewString("_swig_memberptr");
    } else if (SwigType_issimple(t)) {
      Node *cn = classLookup(t);
      if (cn) {
	ret = Getattr(cn, "sym:name");
	if (!ret) {
	  ret = Getattr(cn, "name");
	}
	ret = exportedName(ret);

	Node *cnmod = Getattr(cn, "module");
	if (!cnmod || Strcmp(Getattr(cnmod, "name"), package) == 0) {
	  Setattr(undefined_types, t, t);
	} else {
	  String *nw = NewString("");
	  Printv(nw, Getattr(cnmod, "name"), ".", ret, NULL);
	  Delete(ret);
	  ret = nw;
	}
      } else {
	// SWIG does not know about this type.
	ret = exportedName(t);
	Setattr(undefined_types, t, t);
      }
      if (p_is_interface) {
	*p_is_interface = true;
      }
    } else if (SwigType_ispointer(t) || SwigType_isarray(t)) {
      SwigType *r = Copy(t);
      if (SwigType_ispointer(r)) {
	SwigType_del_pointer(r);
      } else {
	SwigType_del_array(r);
      }

      if (SwigType_type(r) == T_VOID) {
	ret = NewString("uintptr");
      } else {
	bool is_interface;
	String *base = goTypeWithInfo(n, r, &is_interface);

	// At the Go level, an unknown or class type is handled as an
	// interface wrapping a pointer.  This means that if a
	// function returns the C type X, we will be wrapping the C
	// type X*.  In Go we will call that type X.  That means that
	// if a C function expects X*, we can pass the Go type X.  And
	// that means that when we see the C type X*, we should use
	// the Go type X.

	// The is_interface variable tells us this.  However, it will
	// be true both for the case of X and for the case of X*.  If
	// r is a pointer here, then we are looking at X**.  There is
	// really no good way for us to handle that.
	bool is_pointer_to_pointer = false;
	if (is_interface) {
	  SwigType *c = Copy(r);
	  if (SwigType_isqualifier(c)) {
	    SwigType_del_qualifier(c);
	    if (SwigType_ispointer(c) || SwigType_isarray(c)) {
	      is_pointer_to_pointer = true;
	    }
	  }
	  Delete(c);
	}

	if (is_interface) {
	  if (!is_pointer_to_pointer) {
	    ret = base;
	    if (p_is_interface) {
	      *p_is_interface = true;
	    }
	  } else {
	    ret = NewString("uintptr");
	  }
	} else {
	  ret = NewString("*");
	  Append(ret, base);
	  Delete(base);
	}
      }

      Delete(r);
    } else if (SwigType_isreference(t)) {
      SwigType *r = Copy(t);
      SwigType_del_reference(r);

      // If this is a const reference, and we are looking at a pointer
      // to it, then we just use the pointer we already have.
      bool add_pointer = true;
      if (SwigType_isqualifier(r)) {
	String *q = SwigType_parm(r);
	if (Strcmp(q, "const") == 0) {
	  SwigType *c = Copy(r);
	  SwigType_del_qualifier(c);
	  if (SwigType_ispointer(c)) {
	    add_pointer = false;
	  }
	  Delete(c);
	}
      }
      if (add_pointer) {
	SwigType_add_pointer(r);
      }
      ret = goTypeWithInfo(n, r, p_is_interface);
      Delete(r);
    } else if (SwigType_isqualifier(t)) {
      SwigType *r = Copy(t);
      SwigType_del_qualifier(r);
      ret = goTypeWithInfo(n, r, p_is_interface);
      Delete(r);
    }

    Delete(t);

    if (!ret) {
      Swig_warning(WARN_LANG_NATIVE_UNIMPL, input_file, line_number, "No Go typemap defined for %s\n", SwigType_str(type, 0));
      ret = NewString("uintptr");
    }

    return ret;
  }

  /* ----------------------------------------------------------------------
   * goWrapperType()
   *
   * Given a type, return a string for the type to use for the wrapped
   * Go function.  This function exists because for a C++ class we
   * need to convert interface and reference types.
   * ---------------------------------------------------------------------- */

  String *goWrapperType(Node *n, SwigType *type, bool is_result) {
    bool is_interface;
    String *ret = goTypeWithInfo(n, type, &is_interface);

    // If this is an interface, we want to pass the real type.
    if (is_interface) {
      Delete(ret);
      if (!is_result) {
	ret = NewString("uintptr");
      } else {
	SwigType *ty = SwigType_typedef_resolve_all(type);
	while (true) {
	  if (SwigType_ispointer(ty)) {
	    SwigType_del_pointer(ty);
	  } else if (SwigType_isarray(ty)) {
	    SwigType_del_array(ty);
	  } else if (SwigType_isreference(ty)) {
	    SwigType_del_reference(ty);
	  } else if (SwigType_isqualifier(ty)) {
	    SwigType_del_qualifier(ty);
	  } else {
	    break;
	  }
	}
	assert(SwigType_issimple(ty));
	String *p = goCPointerType(ty, true);
	Delete(ty);
	ret = p;
      }
    }

    return ret;
  }

  /* ----------------------------------------------------------------------
   * goCPointerType()
   *
   * Return the name of the Go type to use for the C pointer value.
   * The regular C type is the name of an interface type which wraps a
   * pointer whose name is returned by this function.
   * ---------------------------------------------------------------------- */

  String *goCPointerType(SwigType *type, bool add_to_hash) {
    SwigType *ty = SwigType_typedef_resolve_all(type);
    Node *cn = classLookup(ty);
    String *ex;
    String *ret;
    if (!cn) {
      if (add_to_hash) {
	Setattr(undefined_types, ty, ty);
      }
      ret = NewString("Swigcptr");
      ex = exportedName(ty);
      Append(ret, ex);
    } else {
      String *cname = Getattr(cn, "sym:name");
      if (!cname) {
	cname = Getattr(cn, "name");
      }
      ex = exportedName(cname);
      Node *cnmod = Getattr(cn, "module");
      if (!cnmod || Strcmp(Getattr(cnmod, "name"), package) == 0) {
	if (add_to_hash) {
	  Setattr(undefined_types, ty, ty);
	}
	ret = NewString("Swigcptr");
	Append(ret, ex);
      } else {
	ret = NewString("");
	Printv(ret, Getattr(cnmod, "name"), ".Swigcptr", ex, NULL);
      }
    }
    Delete(ty);
    Delete(ex);
    return ret;
  }

  /* ----------------------------------------------------------------------
   * gcCTypeForGoValue()
   *
   * Given a type, return the C/C++ type which will be used to catch
   * the value in Go.  This is the 6g/8g version.
   * ---------------------------------------------------------------------- */

  String *gcCTypeForGoValue(Node *n, SwigType *type, String *name) {
    bool is_interface;
    String *gt = goTypeWithInfo(n, type, &is_interface);
    bool is_string = Strcmp(gt, "string") == 0;
    bool is_slice = Strncmp(gt, "[]", 2) == 0;
    bool is_function = Strcmp(gt, "_swig_fnptr") == 0;
    bool is_member = Strcmp(gt, "_swig_memberptr") == 0;
    bool is_complex = Strcmp(gt, "complex") == 0;
    bool is_complex64 = Strcmp(gt, "complex64") == 0;
    bool is_complex128 = Strcmp(gt, "complex128") == 0;
    Delete(gt);

    String *ret;
    if (is_string) {
      // Note that we don't turn a reference to a string into a
      // pointer to a string.  Strings are immutable anyhow.
      ret = NewString("_gostring_ ");
      Append(ret, name);
      return ret;
    } else if (is_slice) {
      ret = NewString("_goslice_ ");
    } else if (is_function || is_member) {
      ret = NewString("void *");
      Append(ret, name);
      return ret;
    } else if (is_complex || is_complex64) {
      ret = NewString("_Complex float ");
    } else if (is_complex128) {
      ret = NewString("_Complex double ");
    } else if (is_interface) {
      SwigType *t = SwigType_typedef_resolve_all(type);
      SwigType_strip_qualifiers(t);
      if (SwigType_ispointer(t)) {
	SwigType_del_pointer(t);
	SwigType_strip_qualifiers(t);
      }
      if (SwigType_isreference(t)) {
	SwigType_del_reference(t);
	SwigType_strip_qualifiers(t);
      }
      SwigType_add_pointer(t);
      ret = SwigType_lstr(t, name);
      Delete(t);
      return ret;
    } else {
      SwigType *t = SwigType_typedef_resolve_all(type);
      if (SwigType_isreference(t)) {
	// A const reference to a known type, or to a pointer, is not
	// mapped to a pointer.
	SwigType_del_reference(t);
	if (SwigType_isqualifier(t)) {
	  String *q = SwigType_parm(t);
	  if (Strcmp(q, "const") == 0) {
	    SwigType_del_qualifier(t);
	    if (hasGoTypemap(t) || SwigType_ispointer(t)) {
	      ret = SwigType_lstr(t, name);
	      Delete(q);
	      Delete(t);
	      return ret;
	    }
	  }
	  Delete(q);
	}
      }
      Delete(t);
      return SwigType_lstr(type, name);
    }

    if (SwigType_isreference(type)) {
      Append(ret, "* ");
    }
    Append(ret, name);
    return ret;
  }

  /* ----------------------------------------------------------------------
   * gcCTypeForGoValue()
   *
   * Given a type, return the C/C++ type which will be used to catch
   * the value in Go.  This is the gccgo version.
   * ---------------------------------------------------------------------- */

  String *gccgoCTypeForGoValue(Node *n, SwigType *type, String *name) {
    return gcCTypeForGoValue(n, type, name);
  }

  /* ----------------------------------------------------------------------
   * goTypeIsInterface
   *
   * Return whether this C++ type is represented as an interface type
   * in Go.  These types require adjustments in the Go code when
   * passing them back and forth between Go and C++.
   * ---------------------------------------------------------------------- */

  bool goTypeIsInterface(Node *n, SwigType *type) {
    bool is_interface;
    Delete(goTypeWithInfo(n, type, &is_interface));
    return is_interface;
  }

  /* ----------------------------------------------------------------------
   * hasGoTypemap
   *
   * Return whether a type has a "gotype" typemap entry.
   * ---------------------------------------------------------------------- */

  bool hasGoTypemap(SwigType *type) {
    Parm *p = NewParmWithoutFileLineInfo(type, "test");
    SwigType *tm = Swig_typemap_lookup("gotype", p, "", NULL);
    Delete(p);
    if (tm && Strstr(tm, "$gotypename") == 0) {
      Delete(tm);
      return true;
    }
    Delete(tm);
    return false;
  }

  /* ----------------------------------------------------------------------
   * goEnumName()
   *
   * Given an enum node, return a string to use for the enum type in Go.
   * ---------------------------------------------------------------------- */

  String *goEnumName(Node *n) {
    String *ret = Getattr(n, "go:enumname");
    if (ret) {
      return Copy(ret);
    }

    if (Strcmp(Getattr(n, "type"), "enum ") == 0) {
      return NewString("int");
    }

    String *type = Getattr(n, "enumtype");
    assert(type);
    char *p = Char(type);
    int len = Len(type);
    String *s = NewString("");
    bool capitalize = true;
    for (int i = 0; i < len; ++i, ++p) {
      if (*p == ':') {
	++i;
	++p;
	assert(*p == ':');
	capitalize = true;
      } else if (capitalize) {
	Putc(toupper(*p), s);
	capitalize = false;
      } else {
	Putc(*p, s);
      }
    }

    ret = Swig_name_mangle(s);
    Delete(s);
    return ret;
  }


  /* ----------------------------------------------------------------------
   * getParm()
   *
   * Get the real parameter to use.
   * ---------------------------------------------------------------------- */

  Parm *getParm(Parm *p) {
    while (p && checkAttribute(p, "tmap:in:numinputs", "0")) {
      p = Getattr(p, "tmap:in:next");
    }
    return p;
  }

  /* ----------------------------------------------------------------------
   * nextParm()
   *
   * Return the next parameter.
   * ---------------------------------------------------------------------- */

  Parm *nextParm(Parm *p) {
    if (!p) {
      return NULL;
    } else if (Getattr(p, "tmap:in")) {
      return Getattr(p, "tmap:in:next");
    } else {
      return nextSibling(p);
    }
  }

  /* ----------------------------------------------------------------------
   * isStatic
   *
   * Return whether a node should be considered as static rather than
   * as a member.
   * ---------------------------------------------------------------------- */

  bool isStatic(Node *n) {
    String *storage = Getattr(n, "storage");
    return (storage && (Strcmp(storage, "static") == 0 || Strcmp(storage, "friend") == 0) && (!SmartPointer || !Getattr(n, "allocate:smartpointeraccess")));
  }

  /* ----------------------------------------------------------------------
   * isFriend
   *
   * Return whether a node is a friend.
   * ---------------------------------------------------------------------- */

  bool isFriend(Node *n) {
    String *storage = Getattr(n, "storage");
    return storage && Strcmp(storage, "friend") == 0;
  }

};				/* class GO */

/* -----------------------------------------------------------------------------
 * swig_go()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_go() {
  return new GO();
}
extern "C" Language *swig_go(void) {
  return new_swig_go();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

// Usage message.
const char * const GO::usage = (char *) "\
Go Options (available with -go)\n\
     -package <name>     - Set name of the Go package to <name>\n\
     -gccgo              - Generate code for gccgo rather than 6g/8g\n\
     -go-prefix <p>      - Like gccgo -fgo-prefix option\n\
     -soname <name>      - Set shared library holding C/C++ code to <name>\n\
     -longsize <s>       - Set size of C/C++ long type--32 or 64 bits\n\
\n";
