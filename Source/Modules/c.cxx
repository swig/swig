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

  int enum_id;

  bool proxy_flag;
  bool except_flag;

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
    enum_id(1),
    proxy_flag(true),
    except_flag(true) {
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

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
        } else if (strcmp(argv[i], "-noexcept") == 0) {
          except_flag = false;
          Swig_mark_arg(i);
        }
      }
    }

    if (!CPlusPlus) 
      except_flag = false;

    // add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGC 1", 0);
    if (except_flag)
      Preprocessor_define("SWIG_C_EXCEPT 1", 0);
    if (CPlusPlus)
      Preprocessor_define("SWIG_CPPMODE 1", 0);

    SWIG_library_directory("c");

    // add typemap definitions
    SWIG_typemap_lang("c");
    SWIG_config_file("c.swg");

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * start_create_object()
   * --------------------------------------------------------------------- */

  void start_create_object() {
    String *s = create_object = NewString("");
    Printv(s, "\nSWIGINTERN SwigObj *SWIG_create_object(", except_flag ? "const char *classname" : "", ") {\n", NIL);
    if (except_flag)
      Printf(s, "SWIG_runtime_init();\n");
    Printf(s, "SwigObj *result;\n");
    Printf(s, "result = (SwigObj *) malloc(sizeof(SwigObj));\n");
    Printf(s, "result->obj = 0;\n");
  }

  /* ---------------------------------------------------------------------
   * finish_create_object()
   * --------------------------------------------------------------------- */

  String *finish_create_object() {
    String *s = create_object;
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
    Printf(s, "if (object) {\n");
    if (except_flag)
      Printf(s, "if (object->typenames) {\n");
  }

  /* ---------------------------------------------------------------------
   * finish_destroy_object()
   * --------------------------------------------------------------------- */
  
  String *finish_destroy_object() {
    String *s = destroy_object;
    if (except_flag)
      Printf(s, "free(object->typenames);\n");
    Printf(s, "free(object);\n");
    Printf(s, "object = (SwigObj *) 0;\n");
    if (except_flag)
      Printf(s, "}\n");
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
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "extern \"C\" {\n");
    Printf(f_wrappers, "#endif\n\n");

    start_create_object();
    if (except_flag)
      start_destroy_object();
    
    // emit code for children
    Language::top(n);

    Append(f_header, finish_create_object());
    if (except_flag)
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
    if (SwigType_isenum(type))
      type = make_enum_type(n, type);
    String *type_str = Copy(SwigType_str(type, 0));
    if (SwigType_isarray(type)) {
      String *dims = Strchr(type_str, '[');
      char *c = Char(type_str);
      c[Len(type_str) - Len(dims) - 1] = '\0';
      String *bare_type = NewStringf("%s", c);
      //Printv(f_proxy_header, "SWIGIMPORT ", bare_type, " *", name, ";\n\n", NIL);
      Printv(f_proxy_header, "SWIGIMPORT ", bare_type, " ", name, "[];\n\n", NIL);
      Delete(bare_type);
    }
    else
      Printv(f_proxy_header, "SWIGIMPORT ", type_str, " ", name, ";\n\n", NIL);
    Delete(type_str);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalfunctionHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalfunctionHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    String *vis_hint = NewString("");
    String *return_type_str = SwigType_str(Getattr(n, "type"), 0);
    String *name = Getattr(n, "sym:name");
    ParmList *parms = Getattr(n, "parms");
    String *arg_list = NewString("");
    String *call = empty_string;
    String *cres = empty_string;

    call = Swig_cfunction_call(Getattr(n, "name"), parms);
    cres = Swig_cresult(type, "result", call);
    Setattr(n, "wrap:action", cres);

    functionWrapper(n);

    // add visibility hint for the compiler (do not override this symbol)
    Printv(vis_hint, "SWIGPROTECT(", return_type_str, " ", name, "(", ParmList_str(parms), ");)\n\n", NIL);
    Printv(f_header, vis_hint, NIL);

    Delete(cres);
    Delete(call);
    Delete(arg_list);
    Delete(vis_hint);
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
   * get_mangled_type()
   * ---------------------------------------------------------------------- */

  String *get_mangled_type(SwigType *type_arg) {
    static String *result = 0;
    SwigType *prefix = 0;
    if (result)
      Delete(result);
    result = NewString("");

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
      newtype = SwigType_str(enumtype, 0);
   
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
    SwigType *return_var_type = empty_string;
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

      // attach 'check' typemaps
      Swig_typemap_attach_parms("check", parms, wrapper);

      // insert constraint checking
      for (p = parms; p; ) {
        if ((tm = Getattr(p, "tmap:check"))) {
          Replaceall(tm, "$target", Getattr(p, "lname"));
          Replaceall(tm, "$name", name);
          Printv(wrapper->code, tm, "\n", NIL);
          p = Getattr(p, "tmap:check:next");
        }
        else {
          p = nextSibling(p);
        }
      }

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
      // C++ function wrapper
      
      // mark the first parameter as object-struct
      if ((Cmp(Getattr(n, "storage"), "static") != 0) &&
          (Cmp(Getattr(n, "ismember"), "1") == 0) &&
          (Cmp(nodeType(n), "constructor") != 0)) {
        Setattr(parms, "c:objstruct", "1");
        if (!Getattr(parms, "lname"))
          Setattr(parms, "lname", "arg1");
        SwigType *stype = Copy(Getattr(Swig_methodclass(n), "sym:name"));
        SwigType_add_pointer(stype);
        Setattr(parms, "c:stype", stype);
      }

      // mangle name if function is overloaded
      if (Getattr(n, "sym:overloaded")) {
        if (!Getattr(n, "copy_constructor")) {
          for (p = parms; p; p = nextSibling(p)) {
            if (Getattr(p, "c:objstruct"))
              continue;
            String *mangled = get_mangled_type(Getattr(p, "type"));
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

      // add variable for holding result of original function 'cppresult'
      bool return_object = false;
      if (!is_void_return && (Cmp(Getattr(n, "c:objstruct"), "1") != 0)) {
        SwigType *tdtype = SwigType_typedef_resolve(type);
        if (tdtype)
          type = tdtype;
        
        if (SwigType_isenum(type)) {
          Wrapper_add_localv(wrapper, "cppresult", "int", "cppresult", NIL);
        }
        else if (SwigType_isbuiltin(SwigType_base(type))) {
          // type is built-in (int, char, double, etc.)
          if (SwigType_isconst(type))
            SwigType_del_qualifier(type);

          if (SwigType_isreference(type)) {
            if (SwigType_isconst(SwigType_del_reference(type))) {
              return_var_type = SwigType_base(type);
              SwigType_add_qualifier(return_var_type, "const");
              SwigType_add_pointer(return_var_type);
            }
            else {
              return_var_type = SwigType_base(type);
              SwigType_add_pointer(return_var_type);
            }
            if (SwigType_ispointer(type)) {
              SwigType_add_pointer(return_var_type);
            }
            SwigType_add_reference(type);
          }
          else if (SwigType_isarray(type)) {
            
            return_var_type = SwigType_base(type);
            SwigType *atype = Copy(type);
            do {
              SwigType_del_array(atype);
              SwigType_add_pointer(return_var_type);
            } while (SwigType_isarray(atype));
            if (SwigType_ispointer(atype))
              SwigType_add_pointer(return_var_type);
            Delete(atype);
          }
          else {
            return_var_type = type;
          }

          Wrapper_add_localv(wrapper, "cppresult", SwigType_str(return_var_type, 0), "cppresult", NIL);
        }
        else {
          // type is class
          if (SwigType_ispointer(type))
            return_var_type = type;
          else if (SwigType_isreference(type)) {
            return_var_type = SwigType_base(type);
            SwigType_add_pointer(return_var_type);
            if (SwigType_ispointer(type))
              SwigType_add_pointer(return_var_type);
          }
          else if (SwigType_isarray(type)) {
            return_var_type = SwigType_base(type);
            SwigType *atype = Copy(type);
            do {
              SwigType_del_array(atype);
              SwigType_add_pointer(return_var_type);
            } while (SwigType_isarray(atype));
            Delete(atype);
            if (Cmp(Getattr(n, "c:retval"), "1"))
              SwigType_add_pointer(return_var_type);
          }
          else {
            SwigType_add_pointer(type);
            return_var_type = type;
          }
          Wrapper_add_localv(wrapper, "cppresult", SwigType_str(return_var_type, 0), "cppresult", NIL);
          return_object = true;
        }
      }

      // make sure lnames are set
      int index = 1;
      for (p = parms; p; p = nextSibling(p)) {
        String *lname = Getattr(p, "lname");
        if (!lname) {
          lname = NewStringf("arg%d", index);
          Setattr(p, "lname", lname);
        }
        index++;
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

        SwigType *type = Getattr(p, "type");
        String *lname = Getattr(p, "lname");
        String *c_parm_type = NewString("");
        String *proxy_parm_type = NewString("");
        String *arg_name = NewString("");

        Printf(arg_name, "c%s", lname);
        bool dont_apply_tmap = false;

        // set the appropriate type for parameter
        if (SwigType_isenum(type)) {
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
        if (Cmp(nodeType(n), "destructor") == 0) {
          p = Getattr(p, "tmap:in:next");
        }
        else if ((tm = Getattr(p, "tmap:in"))) {
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

      if (Cmp(nodeType(n), "destructor") != 0) {
        // emit variables for holding parameters
        emit_parameter_variables(parms, wrapper);
        
        // emit variable for holding function return value
        emit_return_variable(n, return_type, wrapper);
      }
      
      // insert constraint checking
      for (p = parms; p; ) {
        if ((tm = Getattr(p, "tmap:check"))) {
          Replaceall(tm, "$target", Getattr(p, "lname"));
          Replaceall(tm, "$name", name);
          Printv(wrapper->code, tm, "\n", NIL);
          p = Getattr(p, "tmap:check:next");
        }
        else {
          p = nextSibling(p);
        }
      }

      // emit action code
      String *action = emit_action(n);
      String *except = Getattr(n, "feature:except");
      if (Getattr(n, "throws") || except) {
        if (!except || (Cmp(except, "0") != 0))
          Printf(action, "if (SWIG_exc.handled) {\nSWIG_rt_stack_pop();\nlongjmp(SWIG_rt_env, 1);\n}\n");
      }
      if (Cmp(nodeType(n), "constructor") != 0)
        Replace(action, "result =", "cppresult = $mod", DOH_REPLACE_FIRST);
      
      // handle special cases of cpp return result

      String *mod = NewString("$mod");
      if (SwigType_isreference(type))
        Replaceall(mod, "$mod", "");
      else if (SwigType_isenum(type))
        Replaceall(mod, "$mod", "(int)");
      else if (return_object && Getattr(n, "c:retval") && !SwigType_isarray(type))
        Replaceall(mod, "$mod", "&");
      else {
        Delete(mod);
        mod = empty_string;
      }

      Replaceall(action, "$mod", mod);

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

      // insert cleanup code
      for (p = parms; p; ) {
        if ((tm = Getattr(p, "tmap:freearg"))) {
          if (tm && (Len(tm) != 0)) {
            String *input = NewStringf("c%s", Getattr(p, "lname"));
            Replaceall(tm, "$source", Getattr(p, "lname"));
            Replaceall(tm, "$input", input);
            Delete(input);
            Printv(wrapper->code, tm, "\n", NIL);
          }
          p = Getattr(p, "tmap:freearg:next");
        }
        else {
          p = nextSibling(p);
        }
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
   * emit_c_struct_def()
   * --------------------------------------------------------------------- */

  void emit_c_struct_def(Node *node) {
    for ( ; node; node = nextSibling(node)) {
      String* kind = Getattr(node, "kind");
      if ((Cmp(kind, "variable") == 0) || (Cmp(kind, "function") == 0)) {
        String* type = NewString("");
        Printv(type, Getattr(node, "decl"), Getattr(node, "type"), NIL);
        Printv(f_proxy_header, "  ", SwigType_str(type, 0), " ", Getattr(node, "name"), ";\n", NIL);
        Delete(type);
      }
      if (Cmp(nodeType(node), "extend") == 0)
        emit_c_struct_def(firstChild(node));
    }
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
                  appendChild(n, new_node);
                }
              }
            }
          }
        }
      }

      if (except_flag)
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
        Node *node = firstChild(n);
        emit_c_struct_def(node);
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
    SwigType *type = Getattr(n, "type");
    SwigType *tdtype;
    tdtype = SwigType_typedef_resolve(type);
    if (tdtype)
      type = tdtype;
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    return Language::staticmemberfunctionHandler(n);
  }

  /* ---------------------------------------------------------------------
   * memberfunctionHandler()
   * --------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    SwigType *tdtype;
    tdtype = SwigType_typedef_resolve(type);
    if (tdtype)
      type = tdtype;
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    return Language::memberfunctionHandler(n);
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
    if (!code) {
      code = NewString("");
      Printv(code, "result = ((", classname, "*) arg1->obj)->", name, ";\n", NIL);
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
   * TODO: refactor
   * --------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    Node *klass = Swig_methodclass(n);
    String *name = Getattr(n, "sym:name");
    SwigType *type = Copy(Getattr(n, "type"));
    String *classname = Getattr(klass, "classtype");
    String *newclassname = Getattr(klass, "sym:name");
    String *new_name = NewString("");
    String *code = NewString("");

    // create code for 'get' function
    Printv(code, "result = $mod", classname, "::", name, ";\n", NIL);
    if (!SwigType_isbuiltin(SwigType_base(type)) && !SwigType_ispointer(type))
      Replaceall(code, "$mod", "&");
    else
      Replaceall(code, "$mod", "");
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
      Printv(code, classname, "::", name, " = $mod arg1;\nresult = arg1;\n", NIL);
      if (!SwigType_isbuiltin(SwigType_base(type)) && !SwigType_ispointer(type))
        Replaceall(code, "$mod", "*");
      else
        Replaceall(code, "$mod", "");
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
    SwigType *type = Getattr(n, "type");
    SwigType *btype = SwigType_base(type);
    if (SwigType_isarray(type) && !SwigType_isbuiltin(btype)) {
      // this hack applies to member objects array (not ptrs.)
      SwigType_add_pointer(btype);
      SwigType_add_array(btype, NewStringf("%s", SwigType_array_getdim(type, 0)));
      Setattr(n, "type", btype);
    }
    return Language::membervariableHandler(n);
  }

  /* ---------------------------------------------------------------------
   * add_to_create_object()
   * --------------------------------------------------------------------- */

  void add_to_create_object(Node *n, String *classname, String *newclassname) {
    String *s = create_object;

    Printv(s, "if (strcmp(classname, \"", classname, "\") == 0) {\n", NIL);

    // store the name of each class in the hierarchy
    List *baselist = Getattr(Swig_methodclass(n), "bases");
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

    Node *klass = Swig_methodclass(n);
    String *classname = Getattr(klass, "classtype");
    String *newclassname = Getattr(klass, "sym:name");
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
    if (except_flag) {
      add_to_create_object(n, classname, newclassname);
      Printv(code, "result = SWIG_create_object(\"", classname, "\");\n", NIL);
      Printf(code, "SWIG_add_registry_entry(result);\n");
    }
    else {
      Printf(code, "result = SWIG_create_object();\n");
    }

    Printv(code, "result->obj = (void*) new ", classname, arg_lnames, ";\n", NIL);

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
    Node *klass = Swig_methodclass(n);
    String *classname = Getattr(klass, "classtype");
    String *newclassname = Getattr(klass, "sym:name");
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
    if (except_flag) {
      add_to_create_object(n, classname, newclassname);
      Printv(code, "result = SWIG_create_object(\"", classname, "\");\n", NIL);
      Printf(code, "SWIG_add_registry_entry(result);\n");
   }
    else {
      Printf(code, "result = SWIG_create_object();\n");
    }

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
    Node *klass = Swig_methodclass(n);
    String *classname = Getattr(klass, "classtype");
    String *newclassname = Getattr(klass, "sym:name");
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
    if (except_flag) {
      Printf(code, "SWIG_remove_registry_entry(carg1);\n");
      Printf(code, "SWIG_destroy_object(carg1);");
    }
    else {
      Printv(code, "if (carg1->obj)\ndelete (", classname, " *) (carg1->obj);\n", NIL);
    }

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
    String *newclassname = Getattr(Swig_methodclass(n), "sym:name");
    String *name = Getattr(n, "sym:name");
    String *code = NewString("");
    String *tdname = Getattr(n, "tdname");

    if (tdname) {
      Printf(code, "typedef ");
      name = Getattr(n, "name");
      String *td_def_name = NewStringf("enum %s", name);
      SwigType_typedef(td_def_name, name);
      Delete(td_def_name);
      SwigType_istypedef(name);
    }

    Symtab *symtab = Getattr(n, "sym:symtab");
    String *newname = newclassname ? NewStringf("%s_", newclassname) : Copy(name);

    Printf(code, "enum ");

    if (!name) {
      String *anonymous_name = NewStringf("enum%d ", enum_id++);
      Setattr(n, "sym:name", anonymous_name);
      Setattr(n, "unnamed", "1");
      name = Getattr(n, "sym:name");
      Delete(anonymous_name);
    }
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
        if (node)
          Append(newname, name);
      }
      else
        Append(newname, "enum");

     Setattr(n, "name", newname);
    }
    else {
      Delete(newname);
      newname = name;
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
        if (!isdigit(*value_repr) && *value_repr != '+' && *value_repr != '-') {
          init = NewStringf(" = '%c'", *value_repr);
        }
        else
          init = NewStringf(" = %s", enumvalue);
    }

    String *newclassname = Getattr(Swig_methodclass(parentNode(n)), "sym:name");
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

    if (!name)
      name = Getattr(n, "name");

    if (strncmp(c, "enum", 4) != 0) {
      if (name && type)  {
        String *code = NewStringf("typedef %s %s;\n\n", name, type);
        Append(f_proxy_header, code);
        Delete(code);
        SwigType_typedef(type, name);
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
     -noexcept     - do not generate exception handling code\n\
\n";

