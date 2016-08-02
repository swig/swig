#include "swigmod.h"

static Hash *class_get_vars;
static Hash *class_set_vars;

class HHVM : public Language {
protected:
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_classes;
  File *f_wrappers;
  File *f_register;
  File *f_link;
  File *f_init;
  File *f_phpcode;
  String *s_accessor;
  bool staticmethodwrapper;
  bool in_class;
  Hash *swig_types_hash;

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
    f_classes = NewString("");
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
    Printf(f_begin, "#include \"hphp/runtime/vm/native-prop-handler.h\"\n");
    Printf(f_begin, "\n");
    // Printf(f_header, "#ifdef __cplusplus\n");
    // Printf(f_header, "extern \"C\" {\n");
    // Printf(f_header, "#endif\n");
    Printf(f_link, "namespace HPHP {\n");
    Printf(f_link, "\n");

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
    Printf(f_register, "  %sExtension(): Extension(\"%s\", NO_EXTENSION_VERSION_YET) {}\n\n", cap_module, module);
    Printf(f_register, "  void moduleInit() override {\n");

    staticmethodwrapper = false;
    in_class = false;
    swig_types_hash = NewHash();

    /* Emit code for children */
    Language::top(n);
    
    // Output a type wrapper class for each SWIG type
    for (Iterator swig_type = First(swig_types_hash); swig_type.key; swig_type = Next(swig_type)) {
      String *classname = swig_type.key;
      SwigType *type = swig_type.item;
      Node *node = NewHash();
      Setattr(node, "type", type);
      String *tm = Swig_typemap_lookup("hhwrapclass", node, "", 0);
      Replaceall(tm, "$hhclassname", classname);
      Printv(f_classes, tm, NIL);
      Printf(f_register, "    Native::registerNativeDataInfo<_wrap_%s>(_wrap_%s::s_className.get());\n", classname, classname);
      Printf(f_phpcode, "<<__NativeData(\"%s\")>>\n", classname);
      Printf(f_phpcode, "class %s {}\n", classname);
    }

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
    Dump(f_classes, f_begin);
    Dump(f_wrappers, f_begin);
    Dump(f_link, f_begin);
    Dump(f_register, f_begin);
    Wrapper_pretty_print(f_init, f_begin);

    Delete(swig_types_hash);
    swig_types_hash = NULL;

     /* Cleanup files */
    Delete(f_runtime);
    Delete(f_header);
    Delete(f_classes);
    Delete(f_wrappers);
    Delete(f_register);
    Delete(f_link);
    Delete(f_init);
    Delete(f_begin);
    Delete(f_phpcode); 

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * getProxyName()
   *
   * Test to see if a type corresponds to something wrapped with a proxy class.
   * Return NULL if not otherwise the proxy class name, fully qualified with
   * a namespace if the nspace feature is used.
   * ----------------------------------------------------------------------------- */
  
  String *getProxyName(SwigType *t) {
    String *proxyname = NULL;
    // TODO: Add proxy flag and nspace
    Node *n = classLookup(t);
    if (n) {
      proxyname = Getattr(n, "proxyname");
      if (!proxyname) {
        proxyname = Copy(Getattr(n, "sym:name"));
        Setattr(n, "proxyname", proxyname);
        Delete(proxyname);
      }
    }
    return proxyname;
  }

  /* -----------------------------------------------------------------------------
   * getEnumName()
   * ----------------------------------------------------------------------------- */

  String *getEnumName(SwigType *t) {
    Node *enumname = NULL;
    Node *n = enumLookup(t);
    if (n) {
      enumname = Getattr(n, "enumname");
      if (!enumname) {
        String *symname = Getattr(n, "sym:name");
        if (symname) {
          // Add in class scope when referencing enum if not a global enum
          String *scopename_prefix = Swig_scopename_prefix(Getattr(n, "name"));
          String *proxyname = 0;
          if (scopename_prefix) {
            proxyname = getProxyName(scopename_prefix);
          }
          if (proxyname) {
            enumname = NewStringf("%s/%s", proxyname, symname);
          } else {
            // global enum or enum in a namespace
            String *nspace = Getattr(n, "sym:nspace");
            if (nspace) {
              enumname = NewStringf("%s/%s", nspace, symname);
            } else {
              enumname = Copy(symname);
            }
          }
          Setattr(n, "enumname", enumname);
          Delete(enumname);
          Delete(scopename_prefix);
        }
      }
    }

    return enumname;
  }

  /* -----------------------------------------------------------------------------
   * substituteClassname()
   *
   * Substitute the special variable $csclassname with the proxy class name for classes/structs/unions 
   * that SWIG knows about. Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the C# class name. Note that the $&csclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - typemap contents that might contain the special variable to be replaced
   * Outputs:
   *   tm - typemap contents complete with the special variable substitution
   * Return:
   *   substitution_performed - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteClassname(SwigType *pt, String *tm) {
    bool substitution_performed = false;
    SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$hhclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteClassnameSpecialVariable(classnametype, tm, "$hhclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$&hhclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteClassnameSpecialVariable(classnametype, tm, "$&hhclassname");
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
    String *replacementname;
    if (SwigType_isenum(classnametype)) {
      String *enumname = getEnumName(classnametype);
      if (enumname) {
        replacementname = Copy(enumname);
      } else {
        bool anonymous_enum = (Cmp(classnametype, "enum ") == 0);
        if (anonymous_enum) {
          replacementname = NewString("int");
        } else {
          // An unknown enum - one that has not been parsed (neither a C enum forward reference nor a definition) or an ignored enum
          replacementname = NewStringf("SWIGTYPE%s", SwigType_manglestr(classnametype));
          Replace(replacementname, "enum ", "", DOH_REPLACE_ANY);
          Setattr(swig_types_hash, replacementname, classnametype);
        }
      }
    } else {
      String *classname = getProxyName(classnametype); // getProxyName() works for pointers to classes too
      if (classname) {
        replacementname = Copy(classname);
      } else {
        // use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
        replacementname = NewStringf("SWIGTYPE%s", SwigType_manglestr(classnametype));

        // Add to hash table so that the type wrapper classes can be created later
        Setattr(swig_types_hash, replacementname, classnametype);
      }

    }
    Replaceall(tm, classnamespecialvariable, replacementname);

    Delete(replacementname);
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

  void create_command(Node *n, String *call_parms, bool is_overloaded) {
    String   *name   = Getattr(n,"sym:name");
    SwigType *type   = Getattr(n,"type");
    ParmList *parms  = Getattr(n,"parms");
    String *wname = Swig_name_wrapper(name);
    String *return_type = NewString(""), *tm;
    String *classname = NewString("");
    String *wclassname = NewString("");
    String *methodname = NewString("");
    String *acc = NewString(Getattr(n, "access"));
    bool is_void_return;
    bool is_member = Getattr(n, "ismember");
    bool is_constructor = (Cmp(Getattr(n, "nodeType"), "constructor") == 0);
    bool is_destructor = (Cmp(Getattr(n, "nodeType"), "destructor") == 0);
    bool is_static = (Cmp(Getattr(n, "storage"), "static") == 0);

    if (is_constructor || is_destructor) {
      Printf(f_link, "void ");
      Printf(return_type, "void");
    } else if (is_overloaded) {
      Printf(f_link, "HPHP::Variant ");
      Printf(return_type, "HPHP::Variant");
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
    } else if (staticmethodwrapper || is_static) {
      wclassname = GetChar(Swig_methodclass(n), "wrap:name");
      classname = GetChar(Swig_methodclass(n), "sym:name");
      if (staticmethodwrapper)
        methodname = Char(Getattr(n, "staticmemberfunctionHandler:sym:name"));
      else
        methodname = Char(Getattr(n, "sym:name"));
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

    if (!is_overloaded) {
      bool prev = false;
      Parm *p = parms;

      // Skip the class pointer
      if (!is_constructor && !staticmethodwrapper && !is_static && in_class) {
        p = nextSibling(p);
      }

      for (; p; p = nextSibling(p)) {
        String *parm_name = Getattr(p, "lname");
        SwigType *parm_type = Getattr(p, "type");
        String *val = Getattr(p, "value");

        if ((tm = Swig_typemap_lookup("hni_parmtype", p, parm_name, 0))) {
          Printf(f_link, ", %s %s", tm, parm_name);
        }

        if ((tm = Swig_typemap_lookup("php_type", p, parm_name, 0))) {
          substituteClassname(parm_type, tm);
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
        substituteClassname(type, tm);
        // Small hack to avoid creating separate php return typemap
        if(Cmp(tm, "mixed&") == 0) {
          Printf(f_phpcode, ": mixed");
        } else {
        Printf(f_phpcode, ": %s", tm);
        }
      }
    } else {
      if (is_constructor) {
        Printf(f_phpcode, "...$argv): void");
      } else {
        Printf(f_phpcode, "...$argv): mixed");
      }
      Printf(f_link, ", const HPHP::Array& argv");
    }
    
    Printf(f_link, ") {\n");
    Printf(f_phpcode, ";\n\n");

    if (in_class && !staticmethodwrapper && !is_static) {
    Printf(f_link, "  auto data = Object(this_);\n", classname);
      if (!is_constructor) {
        Replaceall(call_parms, "arg1", "data");
      }
    }

    if (staticmethodwrapper || is_static) {
      Printf(f_link, "  ");
      if (!is_void_return) {
        Printf(f_link, "return ");
      }
      Printf(f_link, "%s(%s);\n", wname, call_parms);
    } else if (is_constructor) {
      String *overresolve = is_overloaded ? NewString(".toObject()") : NULL;
      Printf(f_link, "  auto new_obj = %s(%s)%s;\n", wname, call_parms, overresolve);
      String *wclassname = GetChar(Swig_methodclass(n), "wrap:name");
      Printf(f_link, "  Native::data<%s>(this_)->_obj_ptr = Native::data<%s>(new_obj)->_obj_ptr;\n", wclassname, wclassname);
      Printf(f_link, "  Native::data<%s>(new_obj)->_obj_ptr = nullptr;\n", wclassname);
    } else if(is_destructor) {
      String *wclassname = GetChar(Swig_methodclass(n), "wrap:name");
      Printf(f_link, "  if (!Native::data<%s>(this_)->isRef)\n", wclassname);
      Printf(f_link, "    %s(%s);\n", wname, call_parms);
      Printf(f_link, "  Native::data<%s>(this_)->_obj_ptr = nullptr;\n", wclassname);
    } else {
      Printf(f_link, "  ");
      if (!is_void_return) {
        Printf(f_link, "return ");
      }
      Printf(f_link, "%s(%s);\n", wname, call_parms);
    }
    Printf(f_link, "}\n\n");
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
          Printf(lfmt, "return HPHP::Variant();\n");
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
        Printf(lfmt, "return ");
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
        Printf(lfmt, "return HPHP::Variant();\n");
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

    String *tmp = NewStringEmpty();
    Printf(tmp, "result = %%s($commaargs);\n");
    Printf(tmp, "if (result.isInitialized()) {\n return result; \n}");
    String *dispatch = hhvm_overload_dispatch(n);

    /* Generate a dispatch wrapper for all overloaded functions */

    Wrapper *wrapper = NewWrapper();
    String *name = Getattr(n, "sym:name");
    String *wname = Swig_name_wrapper(name);

    // Printf(f_register, "    HHVM_FE(%s);\n", name);
    // Printf(f_phpcode, "<<__Native>>\n");
    // Printf(f_phpcode, "function %s(...$argv): mixed;\n\n", name);
    // Printv(wrapper->def, "Variant HHVM_FUNCTION(", name, ", const Array& argv) {\n", NIL);

    Printf(wrapper->def, "HPHP::Variant %s(const HPHP::Array& argv) {\n", wname);
    Wrapper_add_local(wrapper, "argc", "int argc");
    Wrapper_add_local(wrapper, "result", "HPHP::Variant result");
    Printf(wrapper->code, "argc = argv.size();\n");

    Printv(wrapper->code, dispatch, "\n", NIL);

    // Printf(wrapper->code, "SWIG_ErrorCode() = E_ERROR;\n");
    Printf(wrapper->code, "throw \"No matching function for overloaded '%s'\";\n", name);

    Printv(wrapper->code, "}\n", NIL);
    String *call_parms = NewString("");
    Printf(call_parms, "argv");
    create_command(n, call_parms, true);
    Wrapper_print(wrapper, f_wrappers);

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
    Wrapper *wrapper = NewWrapper();
    bool is_void_return;
    bool overloaded = false;
    String *overname;
    bool is_member = Getattr(n, "ismember");
    bool accessor = is_member && 
      (Cmp(Getattr(n, "kind"), "variable") == 0) &&
      (Cmp(Getattr(n, "view"), "membervariableHandler") == 0);
    // Swig_print_node(n);

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
    Setattr(n, "wrap:name", wname);

    // wrap:parms is used for overload resolution.
    Setattr(n, "wrap:parms", parms);

    Printf(wrapper->def, "SWIGINTERN\n");
    if ((tm = Swig_typemap_lookup("hni_rttype", n, "", 0))) {
      Printv(wrapper->def, tm, " ", NIL);
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
    p = parms;
    while (p) {
      String *parm_name = Getattr(p, "lname");
      String *parm_type = Getattr(p, "type");
      String *arg = NewString("");

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
        substituteClassname(parm_type, tm);
        Setattr(p, "emit:input", arg);
        Printf(wrapper->code, "%s\n", tm);
        p = Getattr(p, "tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to convert type %s as a function argument.\n", SwigType_str(parm_type, 0));
        p = nextSibling(p);
      }
    }
    
    Printf(wrapper->def, ") {");

    if (!overloaded && !accessor) {
      create_command(n, call_parms, false);
    } else if (accessor) {
      const char *fname = Char(name);
      if (strlen(fname) > 4) {
        fname += strlen(fname) - 4;
        String *varname = Getattr(n, "membervariableHandler:sym:name");
        if (strcmp(fname, "_get") == 0) {
          Setattr(class_get_vars, varname, wname);
        } else if (strcmp(fname, "_set") == 0) {
          Setattr(class_set_vars, varname, wname);
        }
      }
    }

    if (!is_void_return) {
      Wrapper_add_localv(wrapper, "tresult", return_type, "tresult", NIL);
    }

    /* emit function call */
    String *actioncode = emit_action(n);
    if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), wrapper, actioncode))) {
      Replaceall(tm, "$result", "tresult");
      substituteClassname(type, tm);
      Printf(wrapper->code, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), name);
    }
    emit_return_variable(n, type, wrapper);
  
    for (p = parms; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
        Replaceall(tm, "$input", Getattr(p, "lname"));
        Replaceall(tm, "$arg", Getattr(p, "emit:input"));
        Replaceall(tm, "$result", Getattr(p, "emit:input"));
        Printv(wrapper->code, tm, "\n", NIL);
        p = Getattr(p, "tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

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
    String *name = GetChar(n, "sym:name");
    String *wname = Swig_name_wrapper(name);
    Setattr(n, "wrap:name", wname);
    in_class = true;
    // Swig_print_tree(n);

    if (!addSymbol(name, n))
      return SWIG_ERROR;

    Printf(f_phpcode, "<<__NativeData(\"%s\")>>\n", name);

    class_get_vars = NewHash();
    class_set_vars = NewHash();
    s_accessor = NewString("");

    Printf(s_accessor, "static Native::PropAccessor %s_properties[] {\n", name);

    List *baselist = Getattr(n, "bases");
    Iterator base;

    if (baselist) {
      base = First(baselist);
      while (base.item && GetFlag(base.item, "feature:ignore")) {
        base = Next(base);
      }
    } else {
      base.item = NULL;
    }

    if (Getattr(n, "abstracts") && !GetFlag(n, "feature:notabstract")) {
      Printf(f_phpcode, "abstract ");
    }

    Printf(f_phpcode, "class %s ", name);
    Printf(f_classes, "class %s {\n", wname);
    Printf(f_classes, "public:\n");
    String *baseclass = NULL;
    if (base.item && Getattr(base.item, "module")) {
      baseclass = Getattr(base.item, "sym:name");
      if (!baseclass)
      baseclass = Getattr(base.item, "name");
      Printf(f_phpcode, "extends %s ", baseclass);
    } else if (GetFlag(n, "feature:exceptionclass")) {
      Append(f_phpcode, "extends Exception ");
    }
    Printf(f_phpcode, "{\n");

    Printf(f_classes, "  static HPHP::Class* getClass();\n");
    Printf(f_classes, "  void sweep() {\n");
    Printf(f_classes, "    _obj_ptr = nullptr;\n");
    Printf(f_classes, "  }\n");
    Printf(f_classes, "  ~%s() { sweep(); }\n\n", wname);
    Printf(f_classes, "  static HPHP::Class* s_class;\n");
    Printf(f_classes, "  static const HPHP::StaticString s_className;\n");
    Printf(f_classes, "  %s* _obj_ptr{nullptr};\n", Getattr(n, "classtype"));
    Printf(f_classes, "  bool isRef{false};\n");
    Printf(f_classes, "}; // class %s\n\n", wname);
    Printf(f_classes, "HPHP::Class* %s::s_class = nullptr;\n", wname);
    Printf(f_classes, "const HPHP::StaticString %s::s_className(\"%s\");\n\n", wname, name);
    Printf(f_classes, "IMPLEMENT_GET_CLASS(%s)\n\n", wname);

    Printf(f_register, "    Native::registerNativeDataInfo<%s>(%s::s_className.get());\n\n", wname, wname);

    Language::classHandler(n);

    Printf(s_accessor, "  { nullptr }\n");
    Printf(s_accessor, "};\n");
    Printf(s_accessor, "static Native::PropAccessorMap %s_properties_map{ %s_properties };\n", name, name);
    Printf(s_accessor, "struct %sPropHandler : public Native::MapPropHandler<%sPropHandler> {\n", name, name);
    Printf(s_accessor, "  static constexpr Native::PropAccessorMap& map = %s_properties_map;\n", name);
    Printf(s_accessor, "};\n\n");
    Printf(f_register, "    Native::registerNativePropHandler<%sPropHandler>(%s::s_className);\n", name, wname);
    Printv(f_link, s_accessor, NIL);
    Printf(f_phpcode, "}\n\n");
    in_class = false;

    Delete(class_set_vars);
    class_set_vars = NULL;
    Delete(class_get_vars);
    class_get_vars = NULL;
    Delete(s_accessor);
    s_accessor = NULL;

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

  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    String *varname = Getattr(n, "sym:name");
    String *wname, *tm;
    String *classname = GetChar(Swig_methodclass(n), "sym:name");
    String *wclassname = GetChar(Swig_methodclass(n), "wrap:name");
    String *out_str = NewStringf("  { \"%s\", ", varname);
    
    Language::membervariableHandler(n);

    if ((wname = Getattr(class_get_vars, varname))) {
      String *accname = NewStringf("SWIG_get_%s_%s", classname, varname);
      Printf(f_link, "static Variant %s(const Object& this_) {\n", accname);
      Printf(f_link, "  auto data = Object(this_);\n", wclassname);
      Printf(f_link, "  return Variant(%s(data));\n", wname);
      Printf(f_link, "}\n\n");
      Printf(out_str, "%s, ", accname);
    } else {
      Printf(out_str, "nullptr, ");
    }

    if ((wname = Getattr(class_set_vars, varname))) {
      String *accname = NewStringf("SWIG_set_%s_%s", classname, varname);
      Printf(f_link, "static void %s(const Object& this_, HHVM_PROP_CONST Variant& value) {\n", accname);
      Printf(f_link, "  auto data = Object(this_);\n", wclassname);
      if ((tm = Swig_typemap_lookup("variant_out", n, varname, 0))) {
        Printf(f_link, "  %s(data, value.%s());\n", wname, tm);
      }
      Printf(f_link, "}\n\n");
      Printf(out_str, "%s },\n", accname);
    } else {
      Printf(out_str, "nullptr },\n");
    }

    Printv(s_accessor, out_str, NIL);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberconstantHandler()
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
    String *wclassname = GetChar(Swig_methodclass(n), "wrap:name");
    String *name = GetChar(n, "name");
    String *rawval = Getattr(n, "rawval");
    String *value = rawval ? rawval : Getattr(n, "value");
    String *tm;
    bool is_enum = (Cmp(Getattr(n, "nodeType"), "enumitem") == 0);

    if (is_enum) {
      wclassname = GetChar(parentNode(Swig_methodclass(n)), "wrap:name");
    }

    if ((tm = Swig_typemap_lookup("consttab", n, name, 0))) {
      if (Strcmp(tm, "KindOfPersistentString") == 0) {
        Printf(f_register, "    Native::registerClassConstant<%s>(%s::s_className.get(), makeStaticString(\"%s\"), makeStaticString(%s));\n", tm, wclassname, name, value);
      } else {
        Printf(f_register, "    Native::registerClassConstant<%s>(%s::s_className.get(), makeStaticString(\"%s\"), %s);\n", tm, wclassname, name, value);
      }
    }

    return SWIG_OK;
  } 
};

extern "C" Language *
swig_hhvm(void) {
  return new HHVM();
}
