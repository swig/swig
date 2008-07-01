/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.cxx
 *
 * C language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_c_cxx[] = "$Id$";

#include "swigmod.h"

class C:public Language {
  static const char *usage;

  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  File *f_shadow_c;
  File *f_shadow_h;

  String *f_shadow_code_init;
  String *f_shadow_code_body;
  String *f_shadow_header;

  String *empty_string;

  bool shadow_flag;

public:

  /* -----------------------------------------------------------------------------
   * C()
   * ----------------------------------------------------------------------------- */

  C() : 
    empty_string(NewString("")),
    shadow_flag(true) {
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("c");

    // add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGC 1", 0);

    // add typemap definitions
    SWIG_typemap_lang("c");
    SWIG_config_file("c.swg");

    // look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i], "-help") == 0) {
          Printf(stdout, "%s\n", usage);
        } else if ((strcmp(argv[i], "-shadow") == 0) || (strcmp(argv[i], "-proxy") == 0)) {
          shadow_flag = true;
        } else if (strcmp(argv[i], "-noproxy") == 0) {
          shadow_flag = false;
        }
      }
    }
  }

  void emitSwigProtectSymbols(File *f) {
    Printf(f, "#ifndef SWIGPROTECT\n");
    Printf(f, "# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)\n");
    Printf(f, "#   define SWIGPROTECT(x)\n");
    Printf(f, "# else\n");
    Printf(f, "#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)\n");
    Printf(f, "#     define SWIGPROTECT(x) __attribute__ ((visibility(\"protected\"))) x\n");
    Printf(f, "#   else\n");
    Printf(f, "#     define SWIGPROTECT(x)\n");
    Printf(f, "#   endif\n");
    Printf(f, "# endif\n");
    Printf(f, "#endif\n\n");
  }

  void emitSwigImport(File *f) {
    Printf(f, "#ifndef SWIGIMPORT\n");
    Printf(f, "# ifndef __GNUC__\n");
    Printf(f, "#   define __DLL_IMPORT __declspec(dllimport)\n");
    Printf(f, "# else\n");
    Printf(f, "#   define __DLL_IMPORT __attribute__((dllimport)) extern\n");
    Printf(f, "# endif\n");
    Printf(f, "# if !defined (__WIN32__)\n");
    Printf(f, "#   define SWIGIMPORT extern\n");
    Printf(f, "# else\n");
    Printf(f, "#   define SWIGIMPORT __DLL_IMPORT\n");
    Printf(f, "# endif\n");
    Printf(f, "#endif\n\n");
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {
    String *module = Getattr(n, "name");
    String *outfile = Getattr(n, "outfile");

    // initialize I/O
    f_runtime = NewFile(outfile, "w");
    if (!f_runtime) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    Swig_banner(f_runtime);
    emitSwigProtectSymbols(f_header);

    // FIXME
    Printf(f_header, "#include <malloc.h>\n\n");

    // generate shadow files if enabled
    if (shadow_flag) {
      f_shadow_code_init = NewString("");
      f_shadow_code_body = NewString("");
      f_shadow_header = NewString("");

      // create shadow files with appropriate name
      String *shadow_code_filename = NewStringf("%s%s_proxy.c", SWIG_output_directory(), Char(module));
      if ((f_shadow_c = NewFile(shadow_code_filename, "w")) == 0) {
        FileErrorDisplay(shadow_code_filename);
        SWIG_exit(EXIT_FAILURE);
      }

      String *shadow_header_filename = NewStringf("%s%s_proxy.h", SWIG_output_directory(), Char(module));
      if ((f_shadow_h = NewFile(shadow_header_filename, "w")) == 0) {
        FileErrorDisplay(shadow_header_filename);
        SWIG_exit(EXIT_FAILURE);
      }

      Swig_register_filebyname("shadow_code_init", f_shadow_code_init);
      Swig_register_filebyname("shadow_code_body", f_shadow_code_body);
      Swig_register_filebyname("shadow_header", f_shadow_header);

      Swig_banner(f_shadow_code_init);
      Swig_banner(f_shadow_header);
      emitSwigImport(f_shadow_header);
      Printf(f_shadow_code_init, "#include \"%s\"\n\n", shadow_header_filename);
    }

    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrappers", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "extern \"C\" {\n");
    Printf(f_wrappers, "#endif\n\n");
    
    // emit code for children
    Language::top(n);

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "}\n");
    Printf(f_wrappers, "#endif\n");

    // finalize generating shadow file
    if (shadow_flag) {
      Printv(f_shadow_c, f_shadow_code_init, "\n", NIL);
      Printv(f_shadow_c, f_shadow_code_body, "\n", NIL);
      Printv(f_shadow_h, f_shadow_header, "\n", NIL);
      Close(f_shadow_c);
      Close(f_shadow_h);
      Delete(f_shadow_code_init);
      Delete(f_shadow_header);
    }

    // write all to the file
    Dump(f_header, f_runtime);
    Dump(f_wrappers, f_runtime);
    Wrapper_pretty_print(f_init, f_runtime);

    // cleanup
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Close(f_runtime);
    Delete(f_runtime);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */  

  virtual int globalvariableHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    String *type_str = SwigType_str(type, 0);
    Printv(f_wrappers, "SWIGEXPORT ", type_str, " ", Getattr(n, "name"), ";\n", NIL);
    if (shadow_flag) {
      Printv(f_shadow_header, "SWIGIMPORT ", type_str, " ", Getattr(n, "name"), ";\n", NIL);
    }
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalfunctionHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalfunctionHandler(Node *n ) {
    String* action = NewString("");
    String* vis_hint = NewString("");
    String* return_type_str = SwigType_str(Getattr(n, "type"), 0);
    String* name = Getattr(n, "sym:name");
    ParmList* parms = Getattr(n, "parms");
    String* arg_list = NewString("");

    if (SwigType_type(Getattr(n, "type")) != T_VOID) {
      Printv(action, "$cppresult = (", SwigType_str(Getattr(n, "type"), 0), ") ", NIL);
    }
    Printv(action, Swig_cfunction_call(Getattr(n, "name"), parms), ";", NIL);
    Setattr(n, "wrap:action", action);

    functionWrapper(n);

    // add visibility hint for the compiler (do not override this symbol)
    Printv(vis_hint, "SWIGPROTECT(", return_type_str, " ", name, "(", ParmList_str(parms), ");)\n\n", NIL);
    Printv(f_header, vis_hint, NIL);

    Delete(arg_list);
    Delete(vis_hint);
    Delete(action);
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   * ---------------------------------------------------------------------- */
  
  virtual int functionWrapper(Node *n) {
    String *name = Getattr(n, "sym:name");
    SwigType *type = Getattr(n, "type");
    SwigType *return_type = NewString("");
    String *arg_names = NewString("");
    ParmList *parms = Getattr(n, "parms");
    Parm *p;
    String* tm;
    String* proto = NewString("");
    bool is_void_return;

    // create new function wrapper object
    Wrapper *wrapper = NewWrapper();

    // create new wrapper name
    String *wname = Swig_name_wrapper(name);
    Setattr(n, "wrap:name", wname);

    // attach the standard typemaps
    emit_attach_parmmaps(parms, wrapper);
    Setattr(n, "wrap:parms", parms);

    // set the return type
    if (Cmp(Getattr(n, "c:immutable"), "1") == 0) {
        Printv(return_type, SwigType_str(type, 0), NIL);
    }
    else if ((tm = Swig_typemap_lookup("couttype", n, "", 0))) {
      String *ctypeout = Getattr(n, "tmap:ctype:out");	// the type in the ctype typemap's out attribute overrides the type in the typemap
      if (ctypeout)
        tm = ctypeout;
      Printf(return_type, "%s", tm);
    } 
    else {
      Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(type, 0));
    }

    // attach 'ctype' typemaps
    Swig_typemap_attach_parms("ctype", parms, wrapper);

    // emit variables for holding parameters
    emit_parameter_variables(parms, wrapper);

    // is the function void?
    is_void_return = (SwigType_type(Getattr(n, "type")) == T_VOID);

    // add variable for holding result of original function
    if (!is_void_return && (Cmp(Getattr(n, "c:immutable"), "1") != 0)) {
      Wrapper_add_localv(wrapper, "cppresult", SwigType_str(type, 0), "cppresult", NIL);
    }

    // create wrapper function prototype
    Printv(wrapper->def, "SWIGEXPORT ", return_type, " ", wname, "(", NIL);

    // prepare function definition
    int gencomma = 0;
    for (p = parms; p; ) {

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
        p = Getattr(p, "tmap:in:next");
      }

      SwigType* type = Getattr(p, "type");
      String* lname = Getattr(p, "lname");
      String* c_parm_type = NewString("");
      String* shadow_parm_type = NewString("");
      String* arg_name = NewString("");

      Printf(arg_name, "c%s", lname);

      // set the appropriate type for parameter
      if (Cmp(Getattr(p, "c:immutable"), "1") == 0) {
        Printv(c_parm_type, SwigType_str(type, 0), NIL);
      }
      else if ((tm = Getattr(p, "tmap:ctype"))) {
        Printv(c_parm_type, tm, NIL);
      }
      else {
        Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(type, 0));
      }

      // use shadow-type for parameter if supplied
      String* stype = Getattr(p, "c:stype");
      if (stype) {
        Printv(shadow_parm_type, SwigType_str(stype, 0), NIL);
      }
      else {
        Printv(shadow_parm_type, c_parm_type, NIL);
      }

      Replaceall(c_parm_type, "::", "_");

      Printv(arg_names, gencomma ? ", " : "", Getattr(p, "name"), NIL);
      Printv(wrapper->def, gencomma ? ", " : "", c_parm_type, " ", arg_name, NIL);
      Printv(proto, gencomma ? ", " : "", shadow_parm_type, " ", Getattr(p, "name"), NIL);
      gencomma = 1;
 
      // apply typemaps for input parameter
      if ((tm = Getattr(p, "tmap:in"))) {
        if (Cmp(Getattr(p, "c:immutable"), "1") == 0) {
          // FIXME: should work as typemaps for basic types
          Printv(wrapper->code, lname, " = ", arg_name, ";\n", NIL);
        }
        else {
          Replaceall(tm, "$input", arg_name);
          Setattr(p, "emit:input", arg_name);
          Printf(wrapper->code, "%s\n", tm);
        }
        p = Getattr(p, "tmap:in:next");
      }
      else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(type, 0));
        p = nextSibling(p);
      }
      Delete(arg_name);
      Delete(shadow_parm_type);
      Delete(c_parm_type);
    }

    Printf(wrapper->def, ") {");

    // emit variable for holding function return value
    emit_return_variable(n, return_type, wrapper);

    // emit action code
    String *action = emit_action(n);
    Replaceall(action, "$cppresult", "cppresult");

    // emit output typemap if needed
    if (!is_void_return && (Cmp(Getattr(n, "c:immutable"), "1") != 0)) {
      if ((tm = Swig_typemap_lookup_out("out", n, "cppresult", wrapper, action))) {
        Replaceall(tm, "$result", "result");
        Printf(wrapper->code, "%s", tm);
        if (Len(tm))
          Printf(wrapper->code, "\n");
      }
      else {
        Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), Getattr(n, "name")); 
      }
    }
    else {
      Append(wrapper->code, action);
    }

    if (!is_void_return)
      Append(wrapper->code, "return result;\n");

    Append(wrapper->code, "}\n");
    Wrapper_print(wrapper, f_wrappers);

    // take care of shadow function
    if (shadow_flag) {
      // use shadow-type for return type if supplied
      SwigType* shadow_type = Getattr(n, "c:stype");
      if (shadow_type) {
        return_type = SwigType_str(shadow_type, 0);
      }

      // emit proxy functions prototypes
      Printv(f_shadow_code_init, "extern ", return_type, " ", wname, "(", proto, ");\n", NIL);
      Printv(f_shadow_code_body, return_type, " ", name, "(", proto, ") {\n", NIL);

      // handle 'prepend' feature
      String *prepend_str = Getattr(n, "feature:prepend");
      if (prepend_str) {
        char *t = Char(prepend_str);
        if (*t == '{') {
          Delitem(prepend_str, 0);
          Delitem(prepend_str, DOH_END);
        }
        Printv(f_shadow_code_body, prepend_str, "\n", NIL);
      }

      // call to the wrapper function
      Printv(f_shadow_code_body, "  return ", wname, "(", arg_names, ");\n", NIL);

      // handle 'append' feature
      String *append_str = Getattr(n, "feature:append");
      if (append_str) {
        char *t = Char(append_str);
        if (*t == '{') {
          Delitem(append_str, 0);
          Delitem(append_str, DOH_END);
        }
        Printv(f_shadow_code_body, append_str, "\n", NIL);
      }

      Printv(f_shadow_code_body, "}\n", NIL);

      // add function declaration to the proxy header file
      Printv(f_shadow_header, return_type, " ", name, "(", proto, ");\n");
    }

    // cleanup
    Delete(proto);
    Delete(arg_names);
    Delete(wname);
    Delete(return_type);
    DelWrapper(wrapper);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * copy_node()
   * --------------------------------------------------------------------- */

  Node* copy_node(Node *node) {
    Node* new_node = NewHash();
    Setattr(new_node, "name", Copy(Getattr(node, "name")));
    Setattr(new_node, "ismember", Copy(Getattr(node, "ismember")));
    Setattr(new_node, "view", Copy(Getattr(node, "view")));
    Setattr(new_node, "kind", Copy(Getattr(node, "kind")));
    Setattr(new_node, "access", Copy(Getattr(node, "access")));
    Setattr(new_node, "parms", Copy(Getattr(node, "parms")));
    Setattr(new_node, "type", Copy(Getattr(node, "type")));
    Setattr(new_node, "decl", Copy(Getattr(node, "decl")));
    return new_node;
  }

  /* ---------------------------------------------------------------------
   * classDeclaration()
   * --------------------------------------------------------------------- */

  virtual int classHandler(Node* n) {
    String* name = Copy(Getattr(n, "name"));
    String* sobj_name = NewString("");
    List* baselist = Getattr(n, "bases");
    Replaceall(name, "::", "_");

    // inheritance support: attach all members from base classes to this class
    if (baselist) {
      Iterator i;
      for (i = First(baselist); i.item; i = Next(i)) {
        // look for member variables (TODO: support for other constructs)
        Node* node;
        for (node = firstChild(i.item); node; node = nextSibling(node)) {
          if ((Cmp(Getattr(node, "kind"), "variable") == 0)
              && (Cmp(Getattr(node, "access"), "private") != 0)
              && (Cmp(Getattr(node, "storage"), "static") != 0)) {
            Node* new_node = copy_node(node);
            Setattr(new_node, "sym:name", Getattr(new_node, "name"));
            set_nodeType(new_node, "cdecl");
            appendChild(n, new_node);
          }
        }
      }
    }

    // emit "class"-struct definition
    Printv(sobj_name, "struct ", name, "Obj", NIL);
    Printv(f_header, sobj_name, " {\n  void* obj;\n};\n\n", NIL);

    // declare it in the proxy header
    if (shadow_flag) {
      Printv(f_shadow_header, "\ntypedef ", sobj_name, " {\n  void* obj;\n} ", name, ";\n\n", NIL);
    }

    Delete(sobj_name);
    Delete(name);
    return Language::classHandler(n);
  }

  /* ---------------------------------------------------------------------
   * staticmemberfunctionHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node* n) {
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * memberfunctionHandler()
   * --------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node* n) {
    String* name = Copy(Getattr(n, "name"));
    String* classname = Getattr(parentNode(n), "name");
    String* newclassname = Copy(classname);
    String* sobj_name = NewString("");
    String* ctype = NewString("");
    String* stype = NewString("");
    String* new_name = NewString("");
    String* code = NewString("");
    String* arg_lnames = NewString("");
    ParmList* parms = Getattr(n, "parms");

    Replaceall(newclassname, "::", "_");

    // create first argument
    Printv(sobj_name, "struct ", newclassname, "Obj", NIL);
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Parm* p = NewParm(ctype, "self");
    stype = Copy(newclassname);
    SwigType_add_pointer(stype);
    Setattr(p, "c:stype", stype);
    Setattr(p, "c:immutable", "1");
    if (parms)
      set_nextSibling(p, parms);
    Setattr(n, "parms", p);

    // prepare argument names
    parms = Getattr(n, "parms");
    Append(arg_lnames, Swig_cfunction_call(empty_string, parms));

    // omit first argument in method call
    String* arg_call_lnames = Strstr(arg_lnames, "arg2");
    if (!arg_call_lnames)
      arg_call_lnames = empty_string;
    else
      Delitem(arg_lnames, DOH_END);

    // generate action code
    Printv(code, (Strcmp(Getattr(n, "type"), "void") != 0) ? "$cppresult = " : "", NIL);
    Printv(code, "((", classname, "*) arg1->obj)->", name, "(", arg_call_lnames, ");\n", NIL);
    Setattr(n, "wrap:action", code);

    // modify method name
    Printv(new_name, newclassname, "_", name, NIL);
    Setattr(n, "sym:name", new_name);

    functionWrapper(n);

    Delete(arg_lnames);
    Delete(code);
    Delete(new_name);
    Delete(stype);
    Delete(ctype);
    Delete(sobj_name);
    Delete(newclassname);
    Delete(name);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * staticmembervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node* n) {
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * membervariableHandler()
   *
   * TODO: generate additional setters and getters to handle inheritance
   * properly, i.e. pair of functions for each type in hierarchy
   *
   * --------------------------------------------------------------------- */

  virtual int membervariableHandler(Node* n) {
    String* name = Getattr(n, "sym:name");
    String* classname = Getattr(parentNode(n), "name");
    String* newclassname = Copy(classname);
    String* sobj_name = NewString("");
    String* ctype = NewString("");
    String* stype = NewString("");
    String* new_name = NewString("");
    String* code = NewString("");
    Replaceall(newclassname, "::", "_");

    // create first argument
    Printv(sobj_name, "struct ", newclassname, "Obj", NIL);
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Parm* p = NewParm(ctype, "self");
    stype = Copy(newclassname);
    SwigType_add_pointer(stype);
    Setattr(p, "c:stype", stype);
    Setattr(p, "c:immutable", "1");
    Setattr(p, "lname", "arg1");

    // create second argument
    Parm* t = NewParm(Getattr(n, "type"), "value");
    Setattr(t, "lname", "arg2");

    /* create 'get' function */

    Setattr(n, "parms", p);

    // generate action code
    Printv(code, "$cppresult = ((", classname, "*) arg1->obj)->", name, ";\n", NIL);
    Setattr(n, "wrap:action", code);

    // modify method name
    Printv(new_name, newclassname, "_get_", name, NIL);
    Setattr(n, "sym:name", new_name);

    functionWrapper(n);

    /* create 'set' function */

    set_nextSibling(p, t);
    Setattr(n, "parms", p);
    Setattr(n, "type", "void");

    // generate action code

    code = NewString("");
    Printv(code, "((", classname, "*) arg1->obj)->", name, " = arg2;\n", NIL);
    Setattr(n, "wrap:action", code);

    // modify method name
    Delete(new_name);
    new_name = NewString("");
    Printv(new_name, newclassname, "_set_", name, NIL);
    Setattr(n, "sym:name", new_name);

    functionWrapper(n);

    Delete(code);
    Delete(new_name);
    Delete(ctype);
    Delete(sobj_name);
    Delete(newclassname);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * constructorHandler()
   * --------------------------------------------------------------------- */

  virtual int constructorHandler(Node* n) {
    String* name = Copy(Getattr(n, "name"));
    String* classname = Getattr(parentNode(n), "name");
    String* sobj_name = NewString("");
    String* ctype = NewString("");
    String* stype;
    String* code = NewString("");
    String* constr_name = NewString("");
    String* arg_lnames = NewString("");
    ParmList* parms = Getattr(n, "parms");

    Replaceall(name, "::", "_");

    // prepare argument names
    Append(arg_lnames, Swig_cfunction_call(empty_string, parms));

    // set the function return type to the pointer to struct
    Printv(sobj_name, "struct ", name, "Obj", NIL);
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Setattr(n, "type", ctype);
    Setattr(n, "c:immutable", "1");
    stype = Copy(name);
    SwigType_add_pointer(stype);
    Setattr(n, "c:stype", stype);

    // generate action code
    Printv(code, "result = (", sobj_name, "*) malloc(sizeof(", sobj_name, "));\n", NIL);
    Printv(code, "result->obj = (void*) new ", classname, arg_lnames, ";\n", NIL);
    Setattr(n, "wrap:action", code);
    
    // modify the constructor name
    Printv(constr_name, "new_", name, NIL);
    Setattr(n, "sym:name", constr_name);

    functionWrapper(n);

    Delete(arg_lnames);
    Delete(constr_name);
    Delete(code);
    Delete(stype);
    Delete(ctype);
    Delete(sobj_name);
    Delete(name);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * destructorHandler()
   * --------------------------------------------------------------------- */

  virtual int destructorHandler(Node* n) {
    String* classname = Getattr(parentNode(n), "name");
    String* newclassname = Copy(classname);
    String* sobj_name = NewString("");
    String* ctype = NewString("");
    String* stype;
    String* code = NewString("");
    String* destr_name = NewString("");
    Parm* p;

    Replaceall(newclassname, "::", "_");
    Replaceall(newclassname, "~", "");

    // create first argument
    Printv(sobj_name, "struct ", newclassname, "Obj", NIL);
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    p = NewParm(ctype, "self");
    Setattr(p, "lname", "arg1");
    stype = Copy(newclassname);
    SwigType_add_pointer(stype);
    Setattr(p, "c:stype", stype);
    Setattr(p, "c:immutable", "1");
    Setattr(n, "parms", p);
    Setattr(n, "type", "void");

    // create action code
    Printv(code, "delete (", classname, "*) (arg1->obj);\nfree(arg1);\n", NIL);
    Setattr(n, "wrap:action", code);

    // modify the destructor name
    Printv(destr_name, "delete_", newclassname, NIL);
    Setattr(n, "sym:name", destr_name);
    
    functionWrapper(n);

    Delete(p);
    Delete(destr_name);
    Delete(code);
    Delete(stype);
    Delete(ctype);
    Delete(sobj_name);
    Delete(newclassname);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * enumDeclaration()
   * --------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * enumvalueDeclaration()
   * --------------------------------------------------------------------- */

  virtual int enumvalueDeclaration(Node *n) {
    return SWIG_OK;
  }

};				/* class C */

/* -----------------------------------------------------------------------------
 * swig_c()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_c() {
  return new C();
}

extern "C" Language *swig_c(void) {
  return new_swig_c();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *C::usage = (char *) "\
C Options (available with -c)\n\
\n";

