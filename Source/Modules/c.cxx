/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.cxx
 *
 * C language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_c_cxx[] = "$Id$";

#include <ctype.h>
#include "swigmod.h"

class C:public Language {
  static const char *usage;

  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  File *f_proxy_c;
  File *f_proxy_h;

  String *f_proxy_code_init;
  String *f_proxy_code_body;
  String *f_proxy_header;

  String *empty_string;
  String *int_string;
  String *enum_values;
  String *create_object;
  String *destroy_object;

  bool proxy_flag;
  bool runtime_flag;
  bool typecheck_flag;

public:

  /* -----------------------------------------------------------------------------
   * C()
   * ----------------------------------------------------------------------------- */

  C() : 
    empty_string(NewString("")),
    int_string(NewString("int")),
    enum_values(0),
    create_object(0),
    destroy_object(0),
    proxy_flag(true),
    runtime_flag(true),
    typecheck_flag(false) {
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("c");

    // add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGC 1", 0);
    if (runtime_flag)
      Preprocessor_define("SWIG_C_RUNTIME 1", 0);

    // add typemap definitions
    SWIG_typemap_lang("c");
    SWIG_config_file("c.swg");

    // look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i], "-help") == 0) {
          Printf(stdout, "%s\n", usage);
        } else if ((strcmp(argv[i], "-proxy") == 0) || (strcmp(argv[i], "-proxy") == 0)) {
          proxy_flag = true;
          Swig_mark_arg(i);
        } else if (strcmp(argv[i], "-noproxy") == 0) {
          proxy_flag = false;
          Swig_mark_arg(i);
        } else if (strcmp(argv[i], "-noruntime") == 0) {
          runtime_flag = false;
          Swig_mark_arg(i);
        }
      }
    }

    if (!CPlusPlus)
      runtime_flag = false;

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * start_create_object()
   * --------------------------------------------------------------------- */

  void start_create_object() {
    String *s = create_object = NewString("");
    Printf(s, "\nSWIGINTERN SwigObj *SWIG_create_object(const char *classname) {\n");
    Printf(s, "SWIG_Runtime_init();\n");
    Printf(s, "SwigObj *result;\n");
    Printf(s, "result = (SwigObj *) malloc(sizeof(SwigObj));\n");
    Printf(s, "result->obj = 0;\n");
  }

  /* ---------------------------------------------------------------------
   * finish_create_object()
   * --------------------------------------------------------------------- */

  String *finish_create_object() {
    String *s = create_object;
    //Printf(s, "SWIG_add_registry_entry(result);\n");
    Printf(s, "return result;\n");
    Printf(s, "}\n\n");
    return create_object;
  }

  /* ---------------------------------------------------------------------
   * start_destroy_object()
   * --------------------------------------------------------------------- */

  void start_destroy_object() {
    String *s = destroy_object = NewString("");
    Printf(s, "\nSWIGINTERN void SWIG_destroy_object(SwigObj *object) {\n");
    Printf(s, "if (object)\nif (object->typenames) {\n");
  }

  /* ---------------------------------------------------------------------
   * finish_destroy_object()
   * --------------------------------------------------------------------- */
  
  String *finish_destroy_object() {
    String *s = destroy_object;
    Printf(s, "free(object->typenames);\n");
    Printf(s, "free(object);\n");
    Printf(s, "object = (SwigObj *) 0;\n");
    Printf(s, "}\n}\n");
    return destroy_object;
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

    // generate proxy files if enabled
    if (proxy_flag) {
      f_proxy_code_init = NewString("");
      f_proxy_code_body = NewString("");
      f_proxy_header = NewString("");

      // create proxy files with appropriate name
      String *proxy_code_filename = NewStringf("%s%s_proxy.c", SWIG_output_directory(), Char(module));
      if ((f_proxy_c = NewFile(proxy_code_filename, "w")) == 0) {
        FileErrorDisplay(proxy_code_filename);
        SWIG_exit(EXIT_FAILURE);
      }

      String *proxy_header_filename = NewStringf("%s%s_proxy.h", SWIG_output_directory(), Char(module));
      if ((f_proxy_h = NewFile(proxy_header_filename, "w")) == 0) {
        FileErrorDisplay(proxy_header_filename);
        SWIG_exit(EXIT_FAILURE);
      }

      Swig_register_filebyname("proxy_code_init", f_proxy_code_init);
      Swig_register_filebyname("proxy_code_body", f_proxy_code_body);
      Swig_register_filebyname("proxy_header", f_proxy_header);

      Swig_banner(f_proxy_code_init);
      Swig_banner(f_proxy_header);
      Printf(f_proxy_code_init, "#include \"%s\"\n\n", proxy_header_filename);
      Printf(f_proxy_header, "#ifndef _%s_proxy_H_\n#define _%s_proxy_H_\n\n", Char(module), Char(module));
    }

    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrappers", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "extern \"C\" {\n");
    Printf(f_wrappers, "#endif\n\n");

    start_create_object();
    start_destroy_object();
    
    // emit code for children
    Language::top(n);

    Append(f_header, finish_create_object());
    Append(f_header, finish_destroy_object());

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "}\n");
    Printf(f_wrappers, "#endif\n");

    // finalize generating proxy file
    if (proxy_flag) {
      Printv(f_proxy_c, f_proxy_code_init, "\n", NIL);
      Printv(f_proxy_c, f_proxy_code_body, "\n", NIL);
      Printv(f_proxy_h, f_proxy_header, "\n#endif /* _", Char(module), "_proxy_H_ */\n", NIL);
      Close(f_proxy_c);
      Close(f_proxy_h);
      Delete(f_proxy_code_init);
      Delete(f_proxy_header);
    }

    // write all to the file
    Wrapper_pretty_print(f_header, f_runtime);
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
    if (!proxy_flag)
      return SWIG_OK;
    String *name = Getattr(n, "name");
    SwigType *type = Getattr(n, "type");
    String *type_str = SwigType_str(type, 0);
    Printv(f_proxy_header, "SWIGIMPORT ", type_str, " ", name, ";\n\n", NIL);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalfunctionHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalfunctionHandler(Node *n ) {
    String *action = NewString("");
    String *vis_hint = NewString("");
    String *return_type_str = SwigType_str(Getattr(n, "type"), 0);
    String *name = Getattr(n, "sym:name");
    ParmList *parms = Getattr(n, "parms");
    String *arg_list = NewString("");

    if (SwigType_type(Getattr(n, "type")) != T_VOID) {
      Printv(action, "$cppresult = $mod (", SwigType_str(Getattr(n, "type"), 0), ") ", NIL);
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
   * prepend_feature()
   * ---------------------------------------------------------------------- */

  String* prepend_feature(Node *n) {
    String *prepend_str = Getattr(n, "feature:prepend");
    if (prepend_str) {
      char *t = Char(prepend_str);
      if (*t == '{') {
        Delitem(prepend_str, 0);
        Delitem(prepend_str, DOH_END);
      }
    }
    return (prepend_str ? prepend_str : empty_string);
  }

  /* ----------------------------------------------------------------------
   * append_feature()
   * ---------------------------------------------------------------------- */

  String* append_feature(Node *n) {
    String *append_str = Getattr(n, "feature:append");
    if (append_str) {
      char *t = Char(append_str);
      if (*t == '{') {
        Delitem(append_str, 0);
        Delitem(append_str, DOH_END);
      }
    }
    return (append_str ? append_str : empty_string);
  }

  /* ----------------------------------------------------------------------
   * getMangledType()
   * ---------------------------------------------------------------------- */

  String *getMangledType(SwigType *type_arg) {
    static String *result = 0;
    SwigType *prefix = 0;
    if (result)
      Delete(result);
    result = NewString("");

    /*Printf(stderr, "MANGLING TYPE: %s\n", type_arg);*/

    SwigType *type = Copy(type_arg);

    if (SwigType_ismemberpointer(type)) {
      SwigType_del_memberpointer(type);
      SwigType_add_pointer(type);
    }

    if (SwigType_ispointer(type)) {
      SwigType_del_pointer(type);
      if (SwigType_isfunction(type)) {
        Printf(result, "f");
        goto ready;
      }
      Delete(type);
      type = Copy(type_arg);
    }

    prefix = SwigType_prefix(type);
    Replaceall(prefix, ".", "");
    Replaceall(prefix, "const", "c");
    Replaceall(prefix, "volatile", "v");
    Replaceall(prefix, "a(", "a");
    Replaceall(prefix, "m(", "m");
    Replaceall(prefix, "q(", "");
    Replaceall(prefix, ")", "");
    Replaceall(prefix, " ", "");
    Printf(result, "%s", prefix);

    type = SwigType_base(type);
    if (SwigType_isbuiltin(type))
      Printf(result, "%c", *Char(SwigType_base(type)));
    else if (SwigType_isenum(type))
      Printf(result, "e%s", Swig_scopename_last(type));
    else
      Printf(result, "%s", Char(SwigType_base(type)));

ready:
    /*Printf(stderr, "  RESULT: %s\n", result);*/

    if (prefix)
      Delete(prefix);
    if (type)
      Delete(type);
    return result;
  }

  /* ----------------------------------------------------------------------
   * make_enum_type()
   *
   * given C++ enum type this function returns its C representation
   * ---------------------------------------------------------------------- */

  String *make_enum_type(Node *n, SwigType *enumtype) {
    Symtab *symtab = Getattr(n, "sym:symtab");
    String *unnamed = Getattr(n, "unnamed");
    String *newtype = 0;
    String *query = 0;

    if (!unnamed)
      query = Swig_scopename_last(SwigType_str(enumtype, 0));
    else {
      Replaceall(unnamed, "$unnamed", "enum");
      Replaceall(unnamed, "$", "");
      query = unnamed;
    }

    Node *node = Swig_symbol_clookup(query, symtab);
    if (node)
      newtype = NewStringf("enum %s", Getattr(node, "name"));
    else
      newtype = Copy(enumtype);

    return newtype;
  }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   * ---------------------------------------------------------------------- */
  
  virtual int functionWrapper(Node *n) {
    String *name = Getattr(n, "sym:name");
    SwigType *type = Getattr(n, "type");
    SwigType *return_type = NewString("");
    String *wname;
    String *arg_names = NewString("");
    ParmList *parms = Getattr(n, "parms");
    Parm *p;
    String *tm;
    String *proto = NewString("");
    String *over_suffix = NewString("");
    int gencomma;
    bool is_void_return = (SwigType_type(type) == T_VOID);

    // create new function wrapper object
    Wrapper *wrapper = NewWrapper();

    if (!CPlusPlus) {
      // this is C function, we don't apply typemaps to it
      
      // create new wrapper name
      wname = Swig_name_wrapper(name);
      Setattr(n, "wrap:name", wname);

      // create function call
      arg_names = Swig_cfunction_call(empty_string, parms);
      if (arg_names) {
        Delitem(arg_names, 0);
        Delitem(arg_names, DOH_END);
      }
      return_type = SwigType_str(type, 0);

      // emit wrapper prototype and code
      gencomma = 0;
      for (p = parms; p; p = nextSibling(p)) {
        Printv(proto, gencomma ? ", " : "", SwigType_str(Getattr(p, "type"), 0), " ", Getattr(p, "lname"), NIL);
        gencomma = 1;
      }
      Printv(wrapper->def, return_type, " ", wname, "(", proto, ") {\n", NIL);
      Append(wrapper->code, prepend_feature(n));
      if (!is_void_return) {
        Printv(wrapper->code, return_type, " result;\n", NIL);
        Printf(wrapper->code, "result = ");
      }
      Printv(wrapper->code, name, "(", arg_names, ");\n", NIL);
      Append(wrapper->code, append_feature(n));
      if (!is_void_return)
        Printf(wrapper->code, "return result;\n");
      Printf(wrapper->code, "}");
    }
    else {
      // mangle name if function is overloaded
      if (Getattr(n, "sym:overloaded")) {
        if (!Getattr(n, "copy_constructor")) {
          for (p = parms; p; p = nextSibling(p)) {
            if (Getattr(p, "c:objstruct"))
              continue;
            String *mangled = getMangledType(Getattr(p, "type"));
            Printv(over_suffix, "_", mangled, NIL);
          }
          Append(name, over_suffix);
        }
      }

      // create new wrapper name
      wname = Swig_name_wrapper(name);
      Setattr(n, "wrap:name", wname);
 
      // set the return type
      if (Cmp(Getattr(n, "c:objstruct"), "1") == 0) {
        Printv(return_type, SwigType_str(type, 0), NIL);
      }
      else if (SwigType_isenum(type)) {
        type = return_type = make_enum_type(n, type);
        Setattr(n, "type", return_type);
      }
      else if ((tm = Swig_typemap_lookup("couttype", n, "", 0))) {
        String *ctypeout = Getattr(n, "tmap:couttype:out");
        if (ctypeout)
          tm = ctypeout;
        Printf(return_type, "%s", tm);
      } 
      else {
        Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No couttype typemap defined for %s\n", SwigType_str(type, 0));
      }

      // add variable for holding result of original function
      if (!is_void_return && (Cmp(Getattr(n, "c:objstruct"), "1") != 0)) {
        if (SwigType_isconst(type))
          SwigType_del_qualifier(type);
        SwigType *return_var_type;
        return_var_type = SwigType_isreference(type) ? SwigType_add_pointer(SwigType_base(type)) : type;
        return_var_type = SwigType_isarray(type) ? SwigType_add_pointer(SwigType_base(type)) : type;
        if (SwigType_isenum(type))
          Wrapper_add_localv(wrapper, "cppresult", "int", "cppresult", NIL);
        else
          Wrapper_add_localv(wrapper, "cppresult", SwigType_str(return_var_type, 0), "cppresult", NIL);
      }

      // create wrapper function prototype
      Printv(wrapper->def, "SWIGEXPORTC ", return_type, " ", wname, "(", NIL);

      // attach the standard typemaps
      emit_attach_parmmaps(parms, wrapper);
      Setattr(n, "wrap:parms", parms);

      // attach 'ctype' typemaps
      Swig_typemap_attach_parms("ctype", parms, wrapper);

      // prepare function definition
      gencomma = 0;
      for (p = parms; p; ) {

        while (checkAttribute(p, "tmap:in:numinputs", "0")) {
          p = Getattr(p, "tmap:in:next");
        }

        SwigType* type = Getattr(p, "type");
        String* lname = Getattr(p, "lname");
        String* c_parm_type = NewString("");
        String* proxy_parm_type = NewString("");
        String* arg_name = NewString("");

        Printf(arg_name, "c%s", lname);

        bool dont_apply_tmap = false;

        // set the appropriate type for parameter
        if (Cmp(Getattr(p, "c:objstruct"), "1") == 0) {
          Printv(c_parm_type, SwigType_str(type, 0), NIL);
          dont_apply_tmap = true;
        }
        else if (SwigType_isenum(type)) {
          c_parm_type = make_enum_type(n, type);
          if (Getattr(n, "unnamed")) {
            type = int_string;
            Setattr(p, "type", type);
            dont_apply_tmap = true;
          }
        }
        else if ((tm = Getattr(p, "tmap:ctype"))) {
          Printv(c_parm_type, tm, NIL);
        }
        else {
          Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(type, 0));
        }

        // use proxy-type for parameter if supplied
        String* stype = Getattr(p, "c:stype");
        if (stype) {
          Printv(proxy_parm_type, SwigType_str(stype, 0), NIL);
        }
        else {
          Printv(proxy_parm_type, c_parm_type, NIL);
        }

        Printv(arg_names, gencomma ? ", " : "", Getattr(p, "name"), NIL);
        Printv(wrapper->def, gencomma ? ", " : "", c_parm_type, " ", arg_name, NIL);
        Printv(proto, gencomma ? ", " : "", proxy_parm_type, " ", Getattr(p, "name"), NIL);
        gencomma = 1;
 
        // apply typemaps for input parameter
        if ((tm = Getattr(p, "tmap:in"))) {
          if (dont_apply_tmap) {
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
        Delete(proxy_parm_type);
        Delete(c_parm_type);
      }

      Printf(wrapper->def, ") {");

      // emit variables for holding parameters
      emit_parameter_variables(parms, wrapper);

      // emit variable for holding function return value
      emit_return_variable(n, return_type, wrapper);

      // emit action code
      String *action = emit_action(n);
      if (Getattr(n, "throws") || Getattr(n, "feature:except")) {
        Printf(action, "if (SWIG_exception.handled) {\nSWIG_rt_stack_pop();\nlongjmp(SWIG_rt_env, 1);\n}\n");
      }
      Replaceall(action, "$cppresult", "cppresult");

      // handle return-by-reference
      if (SwigType_isreference(type)) {
        String *ref_cast = NewString("");
        if (SwigType_isconst(SwigType_del_reference(type))) {
          Printf(ref_cast, "const_cast<%s*>(&", SwigType_str(SwigType_base(type), 0));
          Replaceall(action, ";", ");");
        }
        else
          Printf(ref_cast, "&");
        Replaceall(action, "$mod", ref_cast);
        Delete(ref_cast);
      }
      else if (SwigType_isenum(type))
        Replaceall(action, "$mod", "(int)");
      else
        Replaceall(action, "$mod", "");

      // emit output typemap if needed
      if (!is_void_return && (Cmp(Getattr(n, "c:objstruct"), "1") != 0)) {
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
    }

    // take care of proxy function
    if (proxy_flag) {
      // use proxy-type for return type if supplied
      SwigType *proxy_type = Getattr(n, "c:stype");
      if (proxy_type) {
        return_type = SwigType_str(proxy_type, 0);
      }

      // emit proxy functions prototypes
      Printv(f_proxy_code_init, return_type, " ", wname, "(", proto, ");\n", NIL);
      Printv(f_proxy_code_body, return_type, " ", name, "(", proto, ") {\n", NIL);

      // call to the wrapper function
      Printv(f_proxy_code_body, "  return ", wname, "(", arg_names, ");\n}\n", NIL);

      // add function declaration to the proxy header file
      Printv(f_proxy_header, return_type, " ", name, "(", proto, ");\n");
    }

    Wrapper_print(wrapper, f_wrappers);

    // cleanup
    Delete(over_suffix);
    Delete(proto);
    Delete(arg_names);
    Delete(wname);
    Delete(return_type);
    DelWrapper(wrapper);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * emit_runtime_typecheck()
   * --------------------------------------------------------------------- */

  void emit_runtime_typecheck(String *classname, String *funcname, String *code) {
    Printf(code, "{\nint i = 0, type_ok = 0;\n");
    Printf(code, "if (arg1 == NULL) {\n");
    Printv(code, "  fprintf(stdout, \"error: NULL object-struct passed to ", funcname, "\\n\");\n");
    Printf(code, "  longjmp(Swig_rt_env, 0);\n}\n");
    Printf(code, "while(arg1->typenames[i]) {\n");
    Printv(code, "  if (strcmp(arg1->typenames[i++], \"", classname, "\") == 0) {\n", NIL);
    Printf(code, "    type_ok = 1;\nbreak;\n}\n}\n");
    Printf(code, "if (!type_ok) {\n");
    Printv(code, "    fprintf(stdout, \"error: object-struct passed to ", funcname, " is not of class ", classname, "\\n\");\n", NIL);
    Printf(code, "    longjmp(Swig_rt_env, 0);\n}\n}\n");
  }

  /* ---------------------------------------------------------------------
   * copy_node()
   * --------------------------------------------------------------------- */

  Node *copy_node(Node *node) {
    Node *new_node = NewHash();
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
   * is_in()
   *
   * tests if given name already exists in one of child nodes of n
   * --------------------------------------------------------------------- */

  bool is_in(String *name, Node *n) {
    Hash *h;
    for (h = firstChild(n); h; h = nextSibling(h)) {
      if (Cmp(name, Getattr(h, "name")) == 0)
        return true;
    }
    return false;
  }

  /* ---------------------------------------------------------------------
   * classHandler()
   * --------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {
    String *name = NewString("");
    String *sobj = NewString("");
    List *baselist = Getattr(n, "bases");

    String *prefix = Swig_scopename_prefix(Getattr(n, "classtype"));
    if (prefix) 
      Printf(name, "%s_", Swig_name_mangle(prefix));
    Append(name, Getattr(n, "sym:name"));
    Setattr(n, "sym:name", name);

    if (CPlusPlus) {
      // inheritance support: attach all members from base classes to this class
      if (baselist) {
        Iterator i;
        for (i = First(baselist); i.item; i = Next(i)) {
          // look for member variables and functions
          Node *node;
          for (node = firstChild(i.item); node; node = nextSibling(node)) {
            if ((Cmp(Getattr(node, "kind"), "variable") == 0) 
                || (Cmp(Getattr(node, "kind"), "function") == 0)) {
              if ((Cmp(Getattr(node, "access"), "public") == 0)
                  && (Cmp(Getattr(node, "storage"), "static") != 0)) {
                if (!is_in(Getattr(node, "name"), n)) {
                  Node* new_node = copy_node(node);
                  Setattr(new_node, "sym:name", Getattr(new_node, "name"));
                  Setattr(new_node, "sym:symtab", Getattr(n, "symtab"));
                  set_nodeType(new_node, "cdecl");
                  // make sure there are no copyied object-structs params
                  ParmList* all_parms = Getattr(new_node, "parms"), * parms;
                  if (Getattr(all_parms, "c:objstruct")) {
                    parms = Copy(nextSibling(all_parms));
                    Delete(all_parms);
                    Setattr(new_node, "parms", parms);
                  }
                  appendChild(n, new_node);
                }
              }
            }
          }
        }
      }

      Printv(f_header, "const char* Swig_typename_", name, " = \"", name, "\";\n\n", NIL);

      // declare type for specific class in the proxy header
      if (proxy_flag)
        Printv(f_proxy_header, "\ntypedef SwigObj ", name, ";\n\n", NIL);

      Delete(sobj);
      Delete(name);
      return Language::classHandler(n);
    }
    else if (Cmp(Getattr(n, "kind"), "struct") == 0) {
      // this is C struct, just declare it in proxy
      if (proxy_flag) {
        Printv(f_proxy_header, "struct ", name, " {\n", NIL);
        Node* node;
        for (node = firstChild(n); node; node = nextSibling(node)) {
          String* kind = Getattr(node, "kind");
          if ((Cmp(kind, "variable") == 0) || (Cmp(kind, "function") == 0)) {
            String* type = NewString("");
            Printv(type, Getattr(node, "decl"), Getattr(node, "type"), NIL);
            Printv(f_proxy_header, "  ", SwigType_str(type, 0), " ", Getattr(node, "name"), ";\n", NIL);
            Delete(type);
          }
        }
        Append(f_proxy_header, "};\n\n");
      }

      Delete(sobj);
      Delete(name);
    }
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * staticmemberfunctionHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node *n) {
    String *name = Copy(Getattr(n, "sym:name"));
    String *classname = Getattr(parentNode(n), "typename");
    String *newclassname = Getattr(parentNode(n), "sym:name");
    String *new_name = NewString("");
    String *code = NewString("");
    String *arg_lnames = NewString("");
    ParmList *parms = Getattr(n, "parms");

    // prepare function call
    Append(arg_lnames, Swig_cfunction_call(empty_string, parms));
    Delitem(arg_lnames, 0);
    Delitem(arg_lnames, DOH_END);

    // modify method name
    new_name = Swig_name_member(newclassname, name);
    Setattr(n, "sym:name", new_name);

    // generate action code
    Printv(code, (Strcmp(Getattr(n, "type"), "void") != 0) ? "$cppresult = $mod " : "", NIL);
    Printv(code, classname, "::", Getattr(n, "name"), "(", arg_lnames, ");\n", NIL);
    Setattr(n, "wrap:action", code);

    functionWrapper(n);

    Delete(arg_lnames);
    Delete(code);
    Delete(new_name);
    Delete(name);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * memberfunctionHandler()
   * --------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    String *name = Copy(Getattr(n, "sym:name"));
    String *classname = Getattr(parentNode(n), "classtype");
    String *newclassname = Getattr(parentNode(n), "sym:name");
    String *sobj_name = NewString("");
    String *ctype = NewString("");
    String *stype = NewString("");
    String *new_name = NewString("");
    String *code = NewString("");
    String *arg_lnames = NewString("");
    ParmList *parms = Getattr(n, "parms");

    // create first argument
    Printf(sobj_name, "SwigObj");
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Parm *p = NewParm(ctype, "self");
    stype = Copy(newclassname);
    SwigType_add_pointer(stype);
    Setattr(p, "c:stype", stype);
    Setattr(p, "c:objstruct", "1");
    if (parms)
      set_nextSibling(p, parms);
    Setattr(n, "parms", p);

    // prepare function call
    parms = Getattr(n, "parms");
    Append(arg_lnames, Swig_cfunction_call(empty_string, parms));

    // omit first argument in method call
    String *arg_call_lnames = Strstr(arg_lnames, "*arg2");
    if (!arg_call_lnames)
      arg_call_lnames = Strstr(arg_lnames, "arg2");
    if (!arg_call_lnames)
      arg_call_lnames = empty_string;
    else
      Delitem(arg_lnames, DOH_END);

    // modify method name
    new_name = Swig_name_member(newclassname, name);
    Setattr(n, "sym:name", new_name);

    // generate action code
    if (typecheck_flag)
      emit_runtime_typecheck(newclassname, new_name, code);
    Printv(code, (Strcmp(Getattr(n, "type"), "void") != 0) ? "$cppresult = $mod " : "", NIL);
    Printv(code, "((", classname, "*) arg1->obj)->", Getattr(n, "name"), "(", arg_call_lnames, ");\n", NIL);
    Setattr(n, "wrap:action", code);

    functionWrapper(n);

    Delete(arg_lnames);
    Delete(code);
    Delete(new_name);
    Delete(stype);
    Delete(ctype);
    Delete(sobj_name);
    Delete(name);
    return SWIG_OK;
  }

  /* --------------------------------------------------------------------
   * wrap_get_variable()
   * --------------------------------------------------------------------- */

  void wrap_get_variable(Node *n, String *classname, String *newclassname, String *name, String *code) {
    // modify method name
    String *new_name = NewString("");
    Printv(new_name, newclassname, "_", Swig_name_get(name), NIL);
    Setattr(n, "sym:name", new_name);

    // generate action code
    String *action = NewString("");
    ParmList *parms = Getattr(n, "parms");
    if (parms)
      if (typecheck_flag && Getattr(parms, "c:objstruct"))
        emit_runtime_typecheck(newclassname, new_name, action);
    if (!code) {
      code = NewString("");
      Printv(code, "$cppresult = $mod ((", classname, "*) arg1->obj)->", name, ";\n", NIL);
    }
    Append(action, code);

    Setattr(n, "wrap:action", action);

    functionWrapper(n);

    Delete(code);     // we are deallocating it, regardless of where it was created
    Delete(action);
    Delete(new_name);
  }

  /* --------------------------------------------------------------------
   * wrap_set_variable()
   * --------------------------------------------------------------------- */

  void wrap_set_variable(Node *n, String *classname, String *newclassname, String *name, String *code) {
    // modify method name
    String *new_name = NewString("");
    Printv(new_name, newclassname, "_", Swig_name_set(name), NIL);
    Setattr(n, "sym:name", new_name);

    // generate action code
    String *action = NewString("");
    ParmList *parms = Getattr(n, "parms");
    if (parms)
      if (typecheck_flag && Getattr(parms, "c:objstruct"))
        emit_runtime_typecheck(newclassname, new_name, action);
    if (!code) {
      code = NewString("");
      Printv(code, "((", classname, "*) arg1->obj)->", name, " = arg2;\n", NIL);
    }
    Append(action, code);
    Setattr(n, "wrap:action", action);

    functionWrapper(n);

    Delete(code);     // see wrap_get_variable()
    Delete(action);
    Delete(new_name);
  }

  /* ---------------------------------------------------------------------
   * staticmembervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    String *name = Getattr(n, "sym:name");
    SwigType *type = Copy(Getattr(n, "type"));
    String *classname = Getattr(parentNode(n), "classtype");
    String *newclassname = Getattr(parentNode(n), "sym:name");
    String *new_name = NewString("");
    String *code = NewString("");

    // create code for 'get' function
    Printv(code, "$cppresult = $mod ", classname, "::", name, ";\n", NIL);
    wrap_get_variable(n, classname, newclassname, name, code);

    // create parameter for 'set' function
    Parm *p = NewParm(Getattr(n, "type"), "value");
    Setattr(p, "lname", "arg1");
    Setattr(n, "parms", p);
   
    if (!SwigType_isconst(type)) {
      // create code for 'set' function
      if (SwigType_isarray(Getattr(n, "type"))) {
        code = NewString("");
        Printf(code, "if (arg2) {\n");
        Printf(code, "int i;\n");
        Printv(code, "for (i = 0; i < ", SwigType_array_getdim(Getattr(n, "type"), 0), "; ++i) {\n", NIL);
        Printv(code, classname, "::", name, "[i] = arg2[i];\n", NIL);
        Printf(code, "}\n}\n");
      }
      else if (SwigType_isenum(Getattr(n, "type")) && Getattr(n, "unnamed")) {
        code = NewString("* (int *) &");
      }
      else 
        code = NewString("");
      Printv(code, classname, "::", name, " = arg1;\n", NIL);
      wrap_set_variable(n, classname, newclassname, name, code);
    }

    Setattr(n, "type", "void");

    Delete(new_name);
    Delete(type);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * membervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    String *name = Getattr(n, "sym:name");
    SwigType *type = Copy(Getattr(n, "type"));
    String *classname = Getattr(parentNode(n), "classtype");
    String *newclassname = Getattr(parentNode(n), "sym:name");
    String *sobj_name = NewString("");
    String *ctype = NewString("");
    String *stype;
    String *new_name = NewString("");

    // create first argument
    Printf(sobj_name, "SwigObj");
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Parm *p = NewParm(ctype, "self");
    stype = Copy(newclassname);
    SwigType_add_pointer(stype);
    Setattr(p, "c:stype", stype);
    Setattr(p, "c:objstruct", "1");
    Setattr(p, "lname", "arg1");

    // create second argument
    Parm *t = NewParm(Getattr(n, "type"), "value");
    Setattr(t, "lname", "arg2");

    // create 'get' function
    Setattr(n, "parms", p);
    wrap_get_variable(n, classname, newclassname, name, 0);

    if (!SwigType_isconst(type)) {
      // create 'set' function
      set_nextSibling(p, t);
      Setattr(n, "parms", p);
      String *code = 0;
      if (SwigType_isarray(Getattr(n, "type"))) {
        code = NewString("");
        Printf(code, "if (arg2) {\n");
        Printf(code, "int i;\n");
        Printv(code, "for (i = 0; i < ", SwigType_array_getdim(Getattr(n, "type"), 0), "; ++i) {\n", NIL);
        Printv(code, "((", classname, "*) arg1->obj)->", name, "[i] = arg2[i];\n", NIL);
        Printf(code, "}\n}\n");
      }
      else if (SwigType_isenum(Getattr(n, "type")) && Getattr(n, "unnamed")) {
        code = NewString("");
        Printv(code, "* (int *) &((", classname, "*) arg1->obj)->", name, " = arg2;\n", NIL);
      }
      Setattr(n, "type", "void");
      wrap_set_variable(n, classname, newclassname, name, code);
    }

    Delete(new_name);
    Delete(stype);
    Delete(ctype);
    Delete(sobj_name);
    Delete(type);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * add_to_create_object()
   * --------------------------------------------------------------------- */

  void add_to_create_object(Node *n, String *classname, String *newclassname) {
    String *s = create_object;

    Printv(s, "if (strcmp(classname, \"", classname, "\") == 0) {\n", NIL);

    // store the name of each class in the hierarchy
    List *baselist = Getattr(parentNode(n), "bases");
    Printf(s, "result->typenames = (const char **) malloc(%d*sizeof(const char*));\n", Len(baselist) + 2);
    Printv(s, "result->typenames[0] = Swig_typename_", newclassname, ";\n", NIL);
    int i = 1;
    if (baselist) {
      Iterator it;
      for (it = First(baselist); it.item; it = Next(it)) {
        Printf(s, "result->typenames[%d] = Swig_typename_%s;\n", i++, Getattr(it.item, "sym:name"));
      }
    }
    Printf(s, "result->typenames[%d] = 0;\n", i);
    Printf(s, "}\n");

    s = destroy_object;

    Printv(s, "if (strcmp(object->typenames[0], \"", classname, "\") == 0) {\n", NIL);
    Printv(s, "if (object->obj)\ndelete (", classname, " *) (object->obj);\n", NIL);
    Printf(s, "}\n");
  }

  /* ---------------------------------------------------------------------
   * constructorHandler()
   * --------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {
    if (Getattr(n, "copy_constructor"))
      return copyconstructorHandler(n);

    String *classname = Getattr(parentNode(n), "classtype");
    String *newclassname = Getattr(parentNode(n), "sym:name");
    String *sobj_name = NewString("");
    String *ctype;
    String *stype;
    String *code = NewString("");
    String *constr_name = NewString("");
    String *arg_lnames = NewString("");
    ParmList *parms = Getattr(n, "parms");

    // prepare argument names
    Append(arg_lnames, Swig_cfunction_call(empty_string, parms));

    // set the function return type to the pointer to struct
    Printf(sobj_name, "SwigObj");
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Setattr(n, "type", ctype);
    Setattr(n, "c:objstruct", "1");
    stype = Copy(newclassname);
    SwigType_add_pointer(stype);
    Setattr(n, "c:stype", stype);

    // modify the constructor name
    constr_name = Swig_name_construct(newclassname);
    Setattr(n, "name", constr_name);
    Setattr(n, "sym:name", constr_name);

    // generate action code
    add_to_create_object(n, classname, newclassname);
    Printv(code, "result = SWIG_create_object(\"", classname, "\");\n", NIL);
    Printv(code, "result->obj = (void*) new ", classname, arg_lnames, ";\n", NIL);

    Printf(code, "SWIG_add_registry_entry(result);\n");

    Setattr(n, "wrap:action", code);
    
    functionWrapper(n);

    Delete(arg_lnames);
    Delete(constr_name);
    Delete(code);
    Delete(stype);
    Delete(ctype);
    Delete(sobj_name);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * copyconstructorHandler()
   * --------------------------------------------------------------------- */

  virtual int copyconstructorHandler(Node *n) {
    String *classname = Getattr(parentNode(n), "classtype");
    String *newclassname = Getattr(parentNode(n), "sym:name");
    String *sobj_name = NewString("");
    String *ctype;
    String *stype;
    String *code = NewString("");
    String *constr_name = NewString("");
    ParmList *parms = Getattr(n, "parms");

    Setattr(parms, "lname", "arg1");

    // set the function return type to the pointer to struct
    Printf(sobj_name, "SwigObj");
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Setattr(n, "type", ctype);
    Setattr(n, "c:objstruct", "1");
    stype = Copy(newclassname);
    SwigType_add_pointer(stype);
    Setattr(n, "c:stype", stype);

    // modify the constructor name
    constr_name = Swig_name_construct(newclassname);
    Setattr(n, "name", constr_name);
    Setattr(n, "sym:name", constr_name);

    // generate action code
    add_to_create_object(n, classname, newclassname);
    Printv(code, "result = SWIG_create_object(\"", classname, "\");\n", NIL);
    Printv(code, "result->obj = (void*) new ", classname, "((", classname, " const &)*arg1);\n", NIL);
    
    Setattr(n, "wrap:action", code);
    
    functionWrapper(n);

    Delete(constr_name);
    Delete(code);
    Delete(stype);
    Delete(ctype);
    Delete(sobj_name);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * destructorHandler()
   * --------------------------------------------------------------------- */

  virtual int destructorHandler(Node *n) {
    String *newclassname = Getattr(parentNode(n), "sym:name");
    String *sobj_name = NewString("");
    String *ctype;
    String *stype;
    String *code = NewString("");
    String *destr_name = NewString("");
    Parm *p;

    // create first argument
    Printf(sobj_name, "SwigObj");
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    p = NewParm(ctype, "self");
    Setattr(p, "lname", "arg1");
    stype = Copy(newclassname);
    SwigType_add_pointer(stype);
    Setattr(p, "c:stype", stype);
    Setattr(p, "c:objstruct", "1");
    Setattr(n, "parms", p);
    Setattr(n, "type", "void");

    // modify the destructor name
    destr_name = Swig_name_destroy(newclassname);
    Setattr(n, "sym:name", destr_name);

    // create action code
    if (typecheck_flag)
      emit_runtime_typecheck(newclassname, destr_name, code);

    Printf(code, "SWIG_remove_registry_entry(arg1);\n");
    Printf(code, "SWIG_destroy_object(arg1);\n");
    Setattr(n, "wrap:action", code);
    
    functionWrapper(n);

    Delete(p);
    Delete(destr_name);
    Delete(code);
    Delete(stype);
    Delete(ctype);
    Delete(sobj_name);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * enumDeclaration()
   *
   * for enums declared inside class we create global enum declaration
   * and change enum parameter and return value names
   * --------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {
    if (!proxy_flag)
      return SWIG_OK;
    String *newclassname = Getattr(parentNode(n), "sym:name");
    String *name = Getattr(n, "sym:name");
    String *code = NewString("");
    String *tdname = Getattr(n, "tdname");
    String *newname = newclassname ? NewStringf("%s_", newclassname) : Copy(name);
    Symtab *symtab = Getattr(n, "sym:symtab");
      
    if (tdname)
      Printf(code, "typedef ");

    Printf(code, "enum ");

    if (Delattr(n, "unnamed")) {
      // unnamed enum declaration: create new symbol
      Replaceall(name, "$unnamed", "enum");
      Delitem(name, DOH_END);

      Node *entry = NewHash();
      set_nodeType(entry, "enum");
      Setattr(entry, "name", name);
      Setattr(entry, "sym:name", name);
      Setattr(entry, "sym:symtab", symtab);
      Swig_symbol_add(name, entry);
    }

    if (newclassname) {
      if (symtab) {
        Node *node = Swig_symbol_clookup(name, symtab);
        if (node) {
          Append(newname, name);
          Setattr(node, "name", newname);
        }
      }
    }
    Printv(code, newname ? newname : "", " {\n$enumvalues\n} ", tdname ? tdname : "", ";\n\n", NIL);
    emit_children(n);
    if (enum_values) {
      Replaceall(code, "$enumvalues", enum_values);
      Append(f_proxy_header, code);
      if (newclassname)
        Append(f_header, code);
      Delete(enum_values);
      enum_values = 0;
    }

    Delete(newname);
    Delete(code);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * enumvalueDeclaration()
   * --------------------------------------------------------------------- */

  virtual int enumvalueDeclaration(Node *n) {
    String *name = Getattr(n, "sym:name");
    String *enumvalue = Getattr(n, "enumvalue");
    String *init = 0;
    if (enumvalue) {
      char *value_repr = Char(enumvalue);
      if (value_repr)
        if (!isdigit(*value_repr) && *value_repr != '+') {
          init = NewStringf(" = '%c'", *value_repr);
        }
        else
          init = NewStringf(" = %s", enumvalue);
    }

    String *newclassname = Getattr(parentNode(parentNode(n)), "sym:name");
    String *newname = NewStringf("%s_%s", newclassname, name);
    int gencomma = 1;
    if (!enum_values) {
      enum_values = NewString("");
      gencomma = 0;
    }
    Printv(enum_values, gencomma ? ",\n  " : "  ", newclassname ? newname : name, enumvalue ? init : "", NIL);
    Delete(newname);
    if (init)
      Delete(init);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * typedefHandler()
   * --------------------------------------------------------------------- */

  virtual int typedefHandler(Node *n) {
    if (!proxy_flag)
      return SWIG_OK;
    String *name = Getattr(n, "sym:name");
    String *type = Getattr(n, "type");
    char *c = Char(SwigType_str(type, 0));
    if (strncmp(c, "enum", 4) != 0) {
      if (name && type)  {
        String *code = NewStringf("typedef %s %s;\n\n", type, name);
        Append(f_proxy_header, code);
        Delete(code);
      }
    }
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * constantWrapper()
   * --------------------------------------------------------------------- */

  virtual int constantWrapper(Node *n) {
    if (!proxy_flag)
      return SWIG_OK;
    String *name = Getattr(n, "sym:name");
    String *value = Getattr(n, "value");
    Printv(f_proxy_header, "#define ", name, " ", value, "\n", NIL);
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
    -noproxy      - do not generate proxy interface\n\
    -noruntime    - disable runtime error checking\n\
\n";

