#include "swigmod.h"

class HHVM : public Language {
protected:
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_register;
  File *f_link;
  File *f_init;
  File *f_phpcode;
  bool staticmethodwrapper;

public:
  virtual void main(int argc, char *argv[]) {
   // command line options to be added here ...

    SWIG_library_directory("hhvm");
    Preprocessor_define("SWIGHHVM 1", 0);
    SWIG_config_file("hhvm.swg");
    SWIG_typemap_lang("hhvm");
    allow_overloading();
  }

  virtual int top(Node *n) {
    /* Get the module name */
    String *module = Getattr(n,"name");
    String *cap_module = NewStringf("%(upper)s", module);

    /* Get the output file name */
    String *outfile = Getattr(n,"outfile");

    /* Initialize I/O */
    String *filename = NewStringEmpty();
    /* TODO: Use the default outfile */
    Printv(filename, SWIG_output_directory(), "ext_", module, ".cpp", NIL);
    f_begin = NewFile(filename, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }

    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_register = NewString("");
    f_link = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    /* Output module initialization code */
    Swig_banner(f_begin);

    Printf(f_begin, "\n");
    Printf(f_begin, "#include \"hphp/runtime/ext/extension.h\"\n");
    Printf(f_begin, "#include \"hphp/runtime/base/execution-context.h\"\n");
    Printf(f_begin, "#include \"hphp/runtime/vm/native-data.h\"\n");
    Printf(f_begin, "\n");
    // Printf(f_header, "#ifdef __cplusplus\n");
    // Printf(f_header, "extern \"C\" {\n");
    // Printf(f_header, "#endif\n");
    Printf(f_wrappers, "namespace HPHP {\n");
    Printf(f_wrappers, "\n");

    filename = NewStringEmpty();
    Printv(filename, SWIG_output_directory(), "ext_", module, ".php", NIL);

    f_phpcode = NewFile(filename, "w", SWIG_output_files());
    if (!f_phpcode) {
      FileErrorDisplay(filename);
      SWIG_exit(EXIT_FAILURE);
    }

    Printf(f_phpcode, "<?hh\n\n");

    Swig_banner(f_phpcode);

    /* module extension class declaration */
    Printf(f_register, "\n\nclass %sExtension : public Extension {\n", cap_module);
    Printf(f_register, "public:\n");

    /* TODO: Take extension version as input */ 
    Printf(f_register, "  %sExtension(): Extension(\"%s\", \"1.0\") {}\n\n", cap_module, module);
    Printf(f_register, "  void moduleInit() override {\n");

    staticmethodwrapper = false;

    /* Emit code for children */
    Language::top(n);
    
    /* All registrations go here */

    Printf(f_register, "    loadSystemlib();\n");
    Printf(f_register, "  }\n");
    Printf(f_register, "} s_%s_extension;\n\n", module);
    Printf(f_register, "HHVM_GET_MODULE(%s);\n\n", module);

    /* close namespace HPHP */
    Printf(f_register, "}");

    /* close cplusplus */
    // Printf(f_header, "#ifdef __cplusplus\n");
    // Printf(f_header, "}\n");
    // Printf(f_header, "#endif\n");

    /* Write all to the file */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Dump(f_link, f_begin);
    Dump(f_register, f_begin);
    Wrapper_pretty_print(f_init, f_begin);

     /* Cleanup files */
    Delete(f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_register);
    Delete(f_link);
    Delete(f_init);
    Delete(f_begin);
    Delete(f_phpcode); 

    return SWIG_OK;
  }

  virtual int constantWrapper(Node *n) {
    String *name = GetChar(n, "name");
    String *iname = GetChar(n, "sym:name");
    SwigType *type = Getattr(n, "type");
    String *rawval = Getattr(n, "rawval");
    String *value = rawval ? rawval : Getattr(n, "value");
    String *tm;

    if (!addSymbol(iname, n))
      return SWIG_ERROR;

    SwigType_remember(type);

    if ((tm = Swig_typemap_lookup("consttab", n, name, 0))) {
      if (Strcmp(tm, "KindOfPersistentString") == 0) {
        Printf(f_register, "    Native::registerConstant<%s>(makeStaticString(\"%s\"), makeStaticString(%s));\n", tm, name, value);
      } else {
        Printf(f_register, "    Native::registerConstant<%s>(makeStaticString(\"%s\"), %s);\n", tm, name, value);
      }
    }

    return SWIG_OK;
  }

  void create_command(Node *n) {
    String   *name   = Getattr(n,"sym:name");
    SwigType *type   = Getattr(n,"type");
    ParmList *parms  = Getattr(n,"parms");
    String *return_type = NewString(""), *tm;
    String *classname = NewString("");
    String *wclassname = NewString("");
    String *methodname = NewString("");
    String *acc = NewString(Getattr(n, "access"));
    bool is_void_return;
    bool is_member = Getattr(n, "ismember");
    bool is_constructor = (Cmp(Getattr(n, "nodeType"), "constructor") == 0);
    bool is_destructor = (Cmp(Getattr(n, "nodeType"), "destructor") == 0);

    if (is_constructor || is_destructor) {
      Printf(f_link, "void ");
      Printf(return_type, "void");
    } else if ((tm = Swig_typemap_lookup("hni_rttype", n, name, 0))) {
      Printv(f_link, tm, " ", NIL);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), name);
    }

    is_void_return = (Cmp(return_type, "void") == 0);

    Printf(f_phpcode, "<<__Native>>\n");
    if (is_constructor){
      wclassname = GetChar(Swig_methodclass(n), "wrap:name");
      classname = GetChar(Swig_methodclass(n), "sym:name");
      Printf(f_register, "    HHVM_MALIAS(%s, __construct, %s, __construct);\n", classname, wclassname);
      Printf(f_link, "HHVM_METHOD(%s, __construct", wclassname);
      Printf(f_phpcode, "function __construct(");
    } else if (is_destructor) {
      wclassname = GetChar(Swig_methodclass(n), "wrap:name");
      classname = GetChar(Swig_methodclass(n), "sym:name");
      Printf(f_register, "    HHVM_MALIAS(%s, __destruct, %s, __destruct);\n", classname, wclassname);
      Printf(f_link, "HHVM_METHOD(%s, __destruct", wclassname);
      Printf(f_phpcode, "function __destruct(");
    } else if (staticmethodwrapper) {
      wclassname = GetChar(Swig_methodclass(n), "wrap:name");
      classname = GetChar(Swig_methodclass(n), "sym:name");
      methodname = Char(Getattr(n, "staticmemberfunctionHandler:sym:name"));
      Printf(f_register, "    HHVM_STATIC_MALIAS(%s, %s, %s, %s);\n", classname, methodname, wclassname, methodname);
      Printf(f_link, "HHVM_STATIC_METHOD(%s, %s", wclassname, methodname);
      Printf(f_phpcode, "static %s function %s(", acc, methodname);
    } else if (is_member) {
      wclassname = GetChar(Swig_methodclass(n), "wrap:name");
      classname = GetChar(Swig_methodclass(n), "sym:name");
      if (Getattr(n, "memberfunctionHandler:sym:name")) {
        methodname = Getattr(n, "memberfunctionHandler:sym:name");
      } else {
        methodname = name;
      }
      Printf(f_register, "    HHVM_MALIAS(%s, %s, %s, %s);\n", classname, methodname, wclassname, methodname);
      Printf(f_link, "HHVM_METHOD(%s, %s", wclassname, methodname);
      Printf(f_phpcode, "%s function %s(", acc, methodname);
    } else {
      Printf(f_register, "    HHVM_FE(%s);\n", name);
      Printf(f_link, "HHVM_FUNCTION(%s", name);
      Printf(f_phpcode, "function %s(", name);
    }

    bool prev = false;
    Parm *p = parms;

    // Skip the class pointer
    if ((!is_constructor && !staticmethodwrapper && is_member) || is_destructor) {
      assert(p);
      p = nextSibling(p);
    }
    for (; p; p = nextSibling(p)) {
      String *parm_name = Getattr(p, "lname");
      String *parm_type = Getattr(p, "type");
      String *val = Getattr(p, "value");

      if ((tm = Swig_typemap_lookup("hni_parmtype", p, parm_name, 0))) {
        Printf(f_link, ", %s %s", tm, parm_name);
      }

      if ((tm = Swig_typemap_lookup("php_type", p, parm_name, 0))) {
        if (prev) {
          Printf(f_phpcode, ", ");
        }
        prev = true;
        Printf(f_phpcode, "%s $%s", tm, parm_name);
        if (val) {
          Printf(f_phpcode, " = %s", val);
        }
      }
    }

    Printf(f_phpcode, ") ");
    if (!is_constructor && !is_destructor && (tm = Swig_typemap_lookup("php_type", n, name, 0))) {
      Printf(f_phpcode, ": %s", tm);
    }
    
    Printf(f_link, ") {\n");
    Printf(f_phpcode, ";\n\n");
  }

  static bool hhvm_print_typecheck(String *f, int j, Parm *pj, bool implicitconvtypecheckoff) {
    char tmp[256], rtmp[256];
    sprintf(tmp, Char(argv_template_string), j);
    sprintf(rtmp, "targ%d", j);
    String *tm = Getattr(pj, "tmap:typecheck");
    if (tm) {
      tm = Copy(tm);
      Replaceid(tm, Getattr(pj, "lname"), "_v");
      String *conv = Getattr(pj, "implicitconv");
      if (conv && !implicitconvtypecheckoff) {
        Replaceall(tm, "$implicitconv", conv);
      } else {
        Replaceall(tm, "$implicitconv", "0");
      }
      Replaceall(tm, "$input", tmp);
      Replaceall(tm, "$result", rtmp);
      Printv(f, tm, "\n", NIL);
      Delete(tm);
      return true;
    } else
      return false;
  }

  String *hhvm_overload_dispatch(Node *n) {
    int i, j;

    int maxargs = 1;

    String *f = NewString("");

    /* Get a list of methods ranked by precedence values and argument count */
    List *dispatch = Swig_overload_rank(n, true);
    int nfunc = Len(dispatch);
    bool is_void_return;

    /* Loop over the functions */

    for (i = 0; i < nfunc; i++) {
      Node *ni = Getitem(dispatch, i);
      Parm *pi = Getattr(ni, "wrap:parms");
      SwigType *return_type = SwigType_namestr(Getattr(n,"type"));
      bool implicitconvtypecheckoff = GetFlag(ni, "implicitconvtypecheckoff") != 0;
      int num_required = emit_num_required(pi);
      int num_arguments = emit_num_arguments(pi);
      if (num_arguments > maxargs)
        maxargs = num_arguments;

      if (num_required == num_arguments) {
        Printf(f, "if (%s == %d) {\n", argc_template_string, num_required);
      } else {
        Printf(f, "if ((%s >= %d) && (%s <= %d)) {\n", argc_template_string, num_required, argc_template_string, num_arguments);
      }

      if (num_arguments) {
        Printf(f, "bool _v;\n");
      }

      int num_braces = 0;
      bool prev_comma;
      j = 0;
      Parm *pj = pi;
      while (pj) {
        if (checkAttribute(pj, "tmap:in:numinputs", "0")) {
        pj = Getattr(pj, "tmap:in:next");
          continue;
      }
      if (j >= num_required) {
        String *lfmt = NewString("");
        prev_comma = false;
        is_void_return = (Cmp(return_type, "void") == 0);
        if (!is_void_return) {
          Printf(lfmt, "return ");
        }
        Printf(lfmt, "%%s(");
        for (int it = 0; it < num_arguments; it++) {
          if (prev_comma) {
            Printf(lfmt, ", ", it);
          }
          prev_comma = true;
          Printf(lfmt, "targ%d", it);
        }
        Printf(lfmt, ");\n");
        if (is_void_return) {
          Printf(lfmt, "return Variant();\n");
        }
        Printf(f, "if (%s <= %d) {\n", argc_template_string, j);
        Printf(f, Char(lfmt), Getattr(ni, "wrap:name"));
        Printf(f, "}\n");
        Delete(lfmt);
      }
      if (hhvm_print_typecheck(f, (GetFlag(n, "wrap:this") ? j + 1 : j), pj, implicitconvtypecheckoff)) {
        Printf(f, "if (_v) {\n");
        num_braces++;
      }
      if (!Getattr(pj, "tmap:in:SWIGTYPE") && Getattr(pj, "tmap:typecheck:SWIGTYPE")) {
        /* we emit  a warning if the argument defines the 'in' typemap, but not the 'typecheck' one */
        Swig_warning(WARN_TYPEMAP_TYPECHECK_UNDEF, Getfile(ni), Getline(ni),
        "Overloaded method %s with no explicit typecheck typemap for arg %d of type '%s'\n",
        Swig_name_decl(n), j, SwigType_str(Getattr(pj, "type"), 0));
      }
      Parm *pk = Getattr(pj, "tmap:in:next");
      if (pk)
        pj = pk;
      else
        pj = nextSibling(pj);
        j++;
      }
      String *lfmt = NewString("");
      is_void_return = (Cmp(return_type, "void") == 0);
      if (!is_void_return) {
        Printf(lfmt, "return Variant();\n");
      }
      Printf(lfmt, "%%s(");
      prev_comma = false;
      for (int it = 0; it < num_arguments; it++) {
        if (prev_comma) {
          Printf(lfmt, ", ", it);
        }
        prev_comma = true;
        Printf(lfmt, "targ%d", it);
      }
      Printf(lfmt, ");\n");
      if (is_void_return) {
        Printf(lfmt, "return Variant();\n");
      }
      Printf(f, Char(lfmt), Getattr(ni, "wrap:name"));
      Delete(lfmt);
      /* close braces */
      for ( /* empty */ ; num_braces > 0; num_braces--)
        Printf(f, "}\n");
      Printf(f, "}\n");   
    }
    Delete(dispatch);
    return f;
  }

  void dispatchFunction(Node *n) {
    /* Last node in overloaded chain */

    int maxargs;
    String *tmp = NewStringEmpty();
    Printf(tmp, "result = %%s($commaargs);\n");
    Printf(tmp, "if (result.isInitialized()) {\n return result; \n}");
    String *dispatch = hhvm_overload_dispatch(n);

    /* Generate a dispatch wrapper for all overloaded functions */

    Wrapper *wrapper = NewWrapper();
    String *name = Getattr(n, "sym:name");
    String *wname = Swig_name_wrapper(name);

    Printf(f_register, "    HHVM_FE(%s);\n", name);
    Printf(f_phpcode, "<<__Native>>\n");
    Printf(f_phpcode, "function %s(...$argv): mixed;\n\n", name);
    Printv(wrapper->def, "Variant HHVM_FUNCTION(", name, ", const Array& argv) {\n", NIL);

    Wrapper_add_local(wrapper, "argc", "int argc");
    Wrapper_add_local(wrapper, "result", "Variant result");
    Printf(wrapper->code, "argc = argv.size();\n");

    Printv(wrapper->code, dispatch, "\n", NIL);

    // Printf(wrapper->code, "SWIG_ErrorCode() = E_ERROR;\n");
    Printf(wrapper->code, "throw \"No matching function for overloaded '%s'\";\n", name);

    Printv(wrapper->code, "}\n", NIL);
    Wrapper_print(wrapper, f_link);

    DelWrapper(wrapper);
    Delete(dispatch);
    Delete(tmp);
    Delete(wname);
  }

  virtual int functionWrapper(Node *n) {
    /* Get some useful attributes of this function */
    String   *name   = Getattr(n,"sym:name");
    SwigType *type   = Getattr(n,"type");
    ParmList *parms  = Getattr(n,"parms");

    Parm *p;
    String *tm, *wname;
    String *return_type = NewString("");
    String *call_parms = NewString("");
    String *member_name = NewString("");
    Wrapper *wrapper = NewWrapper();
    bool is_void_return;
    bool overloaded = false;
    String *overname;
    bool is_member = Getattr(n, "ismember");
    bool is_constructor = (Cmp(Getattr(n, "nodeType"), "constructor") == 0);
    bool is_destructor = (Cmp(Getattr(n, "nodeType"), "destructor") == 0);

    // Test for overloading;
    if (Getattr(n, "sym:overloaded")) {
      overloaded = true;
      overname = Getattr(n, "sym:overname");
    } else {
      if (!addSymbol(name, n))
        return SWIG_ERROR;
    }

    wname = Swig_name_wrapper(name);
    if (overloaded) {
      Printf(wname, "%s", overname);
    }

    Swig_typemap_attach_parms("hni_parmtype", parms, wrapper);
    Swig_typemap_attach_parms("php_type", parms, wrapper);

    if (staticmethodwrapper || !is_member) {
      Printf(wrapper->def, "static ");
    }
    if ((tm = Swig_typemap_lookup("hni_rttype", n, "", 0))) {
      Printv(wrapper->def, tm, " ");
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Func: Unable to use return type %s in function %s.\n", SwigType_str(type, 0), name);
    }

    Printf(wrapper->def, "%s(", wname);

    is_void_return = (Cmp(return_type, "void") == 0);

    emit_parameter_variables(parms, wrapper);
    /* Attach the standard typemaps */
    emit_attach_parmmaps(parms, wrapper);

    bool prev = false;
    for (p = parms; p;) {
      String *parm_name = Getattr(p, "lname");
      String *parm_type = Getattr(p, "type");
      String *arg = NewString("");
      String *val = Getattr(p, "value");

      Printf(arg, "t%s", parm_name);

      if ((tm = Getattr(p, "tmap:hni_parmtype"))) {
        if (prev) {
          Printf(wrapper->def, ", ");
          Printf(call_parms, ", ");
        }
        Printf(wrapper->def, "%s %s", tm, arg);
        Printf(call_parms, "%s", parm_name);
        prev = true;
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to define type %s as a function argument.\n", SwigType_str(parm_type, 0));
      }

      if ((tm = Getattr(p, "tmap:in"))) {
        Replaceall(tm, "$input", arg);
        Setattr(p, "emit:input", arg);
        Printf(wrapper->code, "%s\n", tm);
        p = Getattr(p, "tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to convert type %s as a function argument.\n", SwigType_str(parm_type, 0));
        p = nextSibling(p);
      }
    }
    
    Printf(wrapper->def, ") {");

    if (!overloaded) {
      create_command(n);
      if ((is_constructor || is_destructor || is_member) && !staticmethodwrapper) {
        String *classname = GetChar(Swig_methodclass(n), "wrap:name");
        Printf(f_link, "  auto data = Native::data<%s>(this_);\n", classname);
        if (!is_constructor) {
          Replaceall(call_parms, "arg1", "data->_obj_ptr");
        }
      }

      if (staticmethodwrapper) {
        String *classname = GetChar(Swig_methodclass(n), "wrap:name");
        Printf(f_link, "  ");
        if (!is_void_return) {
          Printf(f_link, "return ");
        }
        Printf(f_link, "%s::%s(%s);\n", classname, wname, call_parms);
      } else if (is_constructor) {
        Printf(f_link, "  data->_obj_ptr = data->%s(%s);\n", wname, call_parms);
      } else if(is_destructor) {
        Printf(f_link, "  data->%s(%s);\n", wname, call_parms);
      } else {
        Printf(f_link, "  ");
        if (!is_void_return) {
          Printf(f_link, "return ");
        }
        if (is_member) {
          Printf(f_link, "data->");
        }
        Printf(f_link, "%s(%s);\n", wname, call_parms);
      }
      Printf(f_link, "}\n\n");
    }
    Setattr(n, "wrap:name", wname);

    // wrap:parms is used by overload resolution.
    Setattr(n, "wrap:parms", parms);

    if (!is_void_return) {
      Wrapper_add_localv(wrapper, "tresult", return_type, "tresult", NIL);
    }

    /* emit function call */
    String *actioncode = emit_action(n);
    if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), wrapper, actioncode))) {
      Replaceall(tm, "$result", "tresult");
      Printf(wrapper->code, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), name);
    }
    emit_return_variable(n, type, wrapper);
  
    if (!is_void_return)
      Printv(wrapper->code, "return tresult;\n", NIL);

    Printv(wrapper->code, "}\n", NIL);

    Wrapper_print(wrapper,f_wrappers);
    DelWrapper(wrapper);

    if (overloaded && !Getattr(n, "sym:nextSibling")) {
      dispatchFunction(n);
    }

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * variableWrapper()
   * ----------------------------------------------------------------------- */

  virtual int variableWrapper(Node *n) {
    Language::variableWrapper(n);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classDeclaration()
   * ------------------------------------------------------------ */

  virtual int classDeclaration(Node *n) {
    return Language::classDeclaration(n);
  }

  /* ------------------------------------------------------------
   * classHandler()
   * ------------------------------------------------------------ */
  virtual int classHandler(Node *n) {
    String *name = GetChar(n, "name");
    String *wname = Swig_name_wrapper(name);
    Setattr(n, "wrap:name", wname);
    Printf(f_phpcode, "<<__NativeData(\"%s\")>>\n", wname);
    Printf(f_phpcode, "class %s {\n", name);
    Printf(f_wrappers, "class %s {\n", wname);
    Printf(f_wrappers, "public:\n");
    Language::classHandler(n);
    Printf(f_wrappers, "Resource _obj_ptr;\n");
    Printf(f_phpcode, "}\n");
    Printf(f_wrappers, "}; // class %s\n", wname);
    Printf(f_register, "    Native::registerNativeDataInfo<%s>(makeStaticString(\"%s\"));\n", wname, wname);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int staticmemberfunctionHandler(Node *n) {
    staticmethodwrapper = true;
    Language::staticmemberfunctionHandler(n);
    staticmethodwrapper = false;

    return SWIG_OK;
  } 
};

extern "C" Language *
swig_hhvm(void) {
  return new HHVM();
}
