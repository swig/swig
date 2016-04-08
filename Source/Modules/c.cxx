/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.cxx
 *
 * C language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_c_cxx[] = "$Id: c.cxx 11186 2009-04-11 10:46:13Z maciekd $";

#include <ctype.h>
#include "swigmod.h"

#ifdef IS_SET_TO_ONE
#undef IS_SET_TO_ONE
#endif
#define IS_SET_TO_ONE(n, var) \
       (Cmp(Getattr(n, var), "1") == 0)

int SwigType_isbuiltin(SwigType *t) {
  const char* builtins[] = { "void", "short", "int", "long", "char", "float", "double", "bool", 0 };
  int i = 0;
  char *c = Char(t);
  if (!t)
    return 0;
  while (builtins[i]) {
    if (strcmp(c, builtins[i]) == 0)
      return 1;
    i++;
  }
  return 0;
}

class C:public Language {
  static const char *usage;

  File *f_begin;
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
  String *create_object;
  String *destroy_object;
  String *tl_namespace; // optional top level namespace

  bool proxy_flag;
  bool except_flag;

public:

  /* -----------------------------------------------------------------------------
   * C()
   * ----------------------------------------------------------------------------- */

  C() : 
    empty_string(NewString("")),
    int_string(NewString("int")),
    create_object(0),
    destroy_object(0),
    tl_namespace(NULL),
    proxy_flag(true),
    except_flag(true) {
  }


  String *getNamespacedName(Node *n)
  {
     if (!n)
      return 0;

     String *proxyname = NULL;
     if ((proxyname = Getattr(n, "proxyname")))
     {
      //Printf(stdout, "Returning proxytype: %s\n", proxyname); 
      return Copy(proxyname);
     }

     String *symname = Getattr(n, "sym:name");
     String *nspace = Getattr(n, "sym:nspace");

     if (nspace) {
          Replaceall(nspace, ".", "_"); // Classes' namespaces get dotted -> replace; FIXME in core!
          proxyname = Swig_name_proxy(nspace, symname);
          if (tl_namespace)
            proxyname = Swig_name_proxy(tl_namespace, proxyname);
     } else {
          proxyname = symname;
     }
     Setattr(n, "proxyname", proxyname);
     Delete(proxyname);
     //Printf(stdout, "Returning proxytype: %s\n", proxyname);

     return Copy(proxyname);
  }

  /* -----------------------------------------------------------------------------
   * getProxyName()
   *
   * Test to see if a type corresponds to something wrapped with a proxy class.
   * Return NULL if not otherwise the proxy class name, fully qualified with
   * top level namespace name if the nspace feature is used.
   * ----------------------------------------------------------------------------- */
  
   String *getProxyName(SwigType *t) {
     Node *n = NULL;

     /* original java code
     if (proxy_flag) {
       Node *n = classLookup(t);
       if (n) {
         proxyname = Getattr(n, "proxyname");
         if (!proxyname) {
           String *nspace = Getattr(n, "sym:nspace");
           String *symname = Getattr(n, "sym:name");
           if (nspace) {
             if (package)
               proxyname = NewStringf("%s.%s.%s", package, nspace, symname);
             else
               proxyname = NewStringf("%s.%s", nspace, symname);
           } else {
             proxyname = Copy(symname);
           }
           Setattr(n, "proxyname", proxyname);
           Delete(proxyname);
         }
       }
     }*/
     t = SwigType_typedef_resolve_all(t);
     //Printf(stdout, "Proxytype for type %s was asked.\n", t);
     if (!proxy_flag || !t || !(n = classLookup(t)))
      return NULL;

    return getNamespacedName(n);

   }

  /* -----------------------------------------------------------------------------
   * getEnumName()
   *
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
            enumname = NewStringf("%s_%s", proxyname, symname);
          } else {
            // global enum or enum in a namespace
            String *nspace = Getattr(n, "sym:nspace");
            if (nspace) {
              if (tl_namespace)
                enumname = NewStringf("%s_%s_%s", tl_namespace, nspace, symname);
              else
                enumname = NewStringf("%s_%s", nspace, symname);
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
   * substituteResolvedTypeSpecialVariable()
   * ----------------------------------------------------------------------------- */

  void substituteResolvedTypeSpecialVariable(SwigType *classnametype, String *tm, const char *classnamespecialvariable) {

    if (SwigType_isenum(classnametype)) {
      String *enumname = getEnumName(classnametype);
      if (enumname)
  Replaceall(tm, classnamespecialvariable, enumname);
      else
  Replaceall(tm, classnamespecialvariable, NewStringf("int"));
    } else {
      String *classname = getProxyName(classnametype);
      if (classname) {
  Replaceall(tm, classnamespecialvariable, classname);  // getProxyName() works for pointers to classes too
      } else {/*      // use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
  String *descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(classnametype));
  Replaceall(tm, classnamespecialvariable, descriptor);

  // Add to hash table so that the type wrapper classes can be created later
  Setattr(swig_types_hash, descriptor, classnametype);
  Delete(descriptor);
  */
      }
    }
  }

  /* -----------------------------------------------------------------------------
   * substituteResolvedType()
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

  bool substituteResolvedType(SwigType *pt, String *tm) {
    bool substitution_performed = false;
    SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$resolved_type")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteResolvedTypeSpecialVariable(classnametype, tm, "$resolved_type");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$*resolved_type")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      if (Len(classnametype) > 0) {
  substituteResolvedTypeSpecialVariable(classnametype, tm, "$*resolved_type");
  substitution_performed = true;
      }
      Delete(classnametype);
    }
    if (Strstr(tm, "$&resolved_type")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteResolvedTypeSpecialVariable(classnametype, tm, "$&resolved_type");
      substitution_performed = true;
      Delete(classnametype);
    }

    Delete(strippedtype);
    Delete(type);

    return substitution_performed;
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
    Printf(s, "SWIG_add_registry_entry(result);\n");
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
    Printf(s, "SWIG_free_SwigObj(object);\n}\n}\n}\n");
    return destroy_object;
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {
    String *module = Getattr(n, "name");
    String *outfile = Getattr(n, "outfile");

    // initialize I/O
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    Swig_banner(f_begin);

    // generate proxy files if enabled
    if (proxy_flag) {
      f_proxy_code_init = NewString("");
      f_proxy_code_body = NewString("");
      f_proxy_header = NewString("");

      // create proxy files with appropriate name
      String *proxy_code_filename = NewStringf("%s%s_proxy.c", SWIG_output_directory(), Char(module));
      if ((f_proxy_c = NewFile(proxy_code_filename, "w", SWIG_output_files())) == 0) {
        FileErrorDisplay(proxy_code_filename);
        SWIG_exit(EXIT_FAILURE);
      }

      String *proxy_header_filename = NewStringf("%s%s_proxy.h", SWIG_output_directory(), Char(module));
      if ((f_proxy_h = NewFile(proxy_header_filename, "w", SWIG_output_files())) == 0) {
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

    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    Swig_name_register("proxyname", "%n_%v");

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "extern \"C\" {\n");
    Printf(f_wrappers, "#endif\n\n");

    
    if (except_flag) {
      start_create_object();
      start_destroy_object();
    }
    
    // emit code for children
    Language::top(n);

    if (except_flag) {
      Append(f_header, finish_create_object());
      Append(f_header, finish_destroy_object());
    }

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "}\n");
    Printf(f_wrappers, "#endif\n");

    // finalize generating proxy file
    if (proxy_flag) {
      Printv(f_proxy_c, f_proxy_code_init, "\n", NIL);
      Printv(f_proxy_c, f_proxy_code_body, "\n", NIL);
      Printv(f_proxy_h, f_proxy_header, "\n#endif /* _", Char(module), "_proxy_H_ */\n", NIL);
      Delete(f_proxy_c);
      Delete(f_proxy_h);
      Delete(f_proxy_code_init);
      Delete(f_proxy_header);
    }

    // write all to the file
    Dump(f_header, f_runtime);
    Wrapper_pretty_print(f_wrappers, f_runtime);
    Dump(f_init, f_runtime);
    Dump(f_runtime, f_begin);

    // cleanup
    Delete(f_begin);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
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
    String *type_str = Copy(SwigType_str(type, 0));
    if (SwigType_isarray(type)) {
      String *dims = Strchr(type_str, '[');
      char *c = Char(type_str);
      c[Len(type_str) - Len(dims) - 1] = '\0';
      String *bare_type = NewStringf("%s", c);
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
    ParmList *parms = Getattr(n, "parms");
    String *arg_list = NewString("");
    String *call = empty_string;
    String *cres = empty_string;

    call = Swig_cfunction_call(Getattr(n, "name"), parms);
    cres = Swig_cresult(type, "result", call);
    Setattr(n, "wrap:action", cres);
    Setattr(n, "c:globalfun", "1");

    if (!SwigType_ispointer(type) && !SwigType_isreference(type))
      Setattr(n, "c:retval", "1");

    functionWrapper(n);

    Delete(cres);
    Delete(call);
    Delete(arg_list);
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
    String *result = NewString("");
    SwigType *prefix = 0;
    SwigType *type = 0;
    SwigType *tdtype = SwigType_typedef_resolve_all(type_arg);
    if (tdtype)
      type = tdtype;
    else
      type = Copy(type_arg);

    // special cases for ptr to function as an argument
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
      Printf(result, "%s", Char(Swig_name_mangle(SwigType_base(type))));

ready:
    if (prefix)
      Delete(prefix);
    if (type)
      Delete(type);
    
    return result;
  }

  virtual void functionWrapperCSpecific(Node *n)
    {
       // this is C function, we don't apply typemaps to it
       String *name = Getattr(n, "sym:name");
       String *wname = Swig_name_wrapper(name);
       SwigType *type = Getattr(n, "type");
       SwigType *return_type = NULL;
       String *arg_names = NULL;
       ParmList *parms = Getattr(n, "parms");
       Parm *p;
       String *proto = NewString("");
       int gencomma = 0;
       bool is_void_return = (SwigType_type(type) == T_VOID);

       // create new function wrapper object
       Wrapper *wrapper = NewWrapper();

       // create new wrapper name
       Setattr(n, "wrap:name", wname); //Necessary to set this attribute? Apparently, it's never read!

       // create function call
       arg_names = Swig_cfunction_call(empty_string, parms);
       if (arg_names) {
            Delitem(arg_names, 0);
            Delitem(arg_names, DOH_END);
       }
       return_type = SwigType_str(type, 0);

       // emit wrapper prototype and code
       for (p = parms, gencomma = 0; p; p = nextSibling(p)) {
            Printv(proto, gencomma ? ", " : "", SwigType_str(Getattr(p, "type"), 0), " ", Getattr(p, "lname"), NIL);
            gencomma = 1;
       }
       Printv(wrapper->def, return_type, " ", wname, "(", proto, ") {\n", NIL);

       // attach 'check' typemaps
       Swig_typemap_attach_parms("check", parms, wrapper);

       // insert constraint checking
       for (p = parms; p; ) {
            String *tm;
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

       if (proxy_flag) // take care of proxy function
         {
            SwigType *proxy_type = Getattr(n, "c:stype"); // use proxy-type for return type if supplied

            if (proxy_type) {
                 return_type = SwigType_str(proxy_type, 0);
            }

            // emit proxy functions prototypes
            // print wrapper prototype into proxy body for later use within proxy
            // body
            Printv(f_proxy_code_init, return_type, " ", wname, "(", proto, ");\n", NIL);

            // print actual proxy code into proxy .c file
            Printv(f_proxy_code_body, return_type, " ", name, "(", proto, ") {\n", NIL);

            // print the call of the wrapper function
            Printv(f_proxy_code_body, "  return ", wname, "(", arg_names, ");\n}\n", NIL);

            /*
            // add visibility hint for the compiler (do not override this symbol)
            String *vis_hint = NewString("");
            Printv(vis_hint, "SWIGPROTECT(", return_type, " ", name, "(", proto, ");)\n\n", NIL);
            Printv(f_proxy_header, vis_hint, NIL);
            Delete(vis_hint);
            */
            // add function declaration to the proxy header file
            Printv(f_proxy_header, return_type, " ", name, "(", proto, ");\n\n", NIL);

         }

       Wrapper_print(wrapper, f_wrappers);

       // cleanup
       Delete(proto);
       Delete(arg_names);
       Delete(wname);
       Delete(return_type);
       Delete(name);
       DelWrapper(wrapper);
    }

  static void functionWrapperPrepareArgs(const ParmList *parms)
    {
       Parm *p;
       int index = 1;
       String *lname = 0;

       for (p = (Parm*)parms, index = 1; p; (p = nextSibling(p)), index++) {
            if(!(lname = Getattr(p, "lname"))) {
                 lname = NewStringf("arg%d", index);
                 Setattr(p, "lname", lname);
            }
       }
    }

  virtual void functionWrapperAppendOverloaded(String *name, const ParmList *parms)
    {
       String *over_suffix = NewString("");
       Parm *p;
       String *mangled;

       for (p = (Parm*)parms; p; p = nextSibling(p)) {
            if (Getattr(p, "c:objstruct"))
              continue;
            mangled = get_mangled_type(Getattr(p, "type"));
            Printv(over_suffix, "_", mangled, NIL);
       }
       Append(name, over_suffix);
       Delete(over_suffix);
    }

  static void functionWrapperAddCPPResult(Wrapper *wrapper, const SwigType *type, const String *tm)
    {
       SwigType *cpptype;
       SwigType *tdtype = SwigType_typedef_resolve_all(tm);
       if (tdtype)
         cpptype = tdtype;
       else
         cpptype = (SwigType*)tm;
       if (SwigType_ismemberpointer(type))
         Wrapper_add_local(wrapper, "cppresult", SwigType_str(type, "cppresult"));
       else
         Wrapper_add_local(wrapper, "cppresult", SwigType_str(cpptype, "cppresult"));
    }

  virtual SwigType *functionWrapperCPPSpecificWrapperReturnTypeGet(Node *n)
    {
       SwigType *type = Getattr(n, "type");
       SwigType *return_type = NewString("");
       String *tm;

       // set the return type
       if (IS_SET_TO_ONE(n, "c:objstruct")) {
            Printv(return_type, SwigType_str(type, 0), NIL);
       }
       else if ((tm = Swig_typemap_lookup("cmodtype", n, "", 0))) {
            String *ctypeout = Getattr(n, "tmap:cmodtype:out");
            if (ctypeout)
              {
                 tm = ctypeout;
                 Printf(stdout, "Obscure cmodtype:out found! O.o\n");
              }
            Printf(return_type, "%s", tm);
            // template handling
            Replaceall(return_type, "$tt", SwigType_lstr(type, 0));
       }
       else {
            Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No cmodtype typemap defined for %s\n", SwigType_str(type, 0));
       }
       return return_type;
    }

  virtual SwigType *functionWrapperCPPSpecificProxyReturnTypeGet(Node *n)
    {
       SwigType *type = Getattr(n, "type");
       SwigType *return_type = NewString("");
       //SwigType *ns = Getattr(n, "name");
       String *tm;

       // set the return type
       if (IS_SET_TO_ONE(n, "c:objstruct")) {
            Printv(return_type, SwigType_str(type, 0), NIL);
       }
       else if ((tm = Swig_typemap_lookup("ctype", n, "", 0))) {
            // handle simple typemap cases
            String *ctypeout = Getattr(n, "tmap:ctype:out");
            if (ctypeout)
              {
                 //tm = ctypeout;
                 return_type = ctypeout;
                 Printf(stdout, "Obscure ctype:out found! O.o\n");
              }
            else
              {
                 substituteResolvedType(type, tm);
                 return_type = tm;
              }
       }
       else {
            Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No cmodtype typemap defined for %s\n", SwigType_str(type, 0));
       }

       Replaceall(return_type, "::", "_");

       return return_type;
    }

  virtual String *functionWrapperCPPSpecificProxyPrototypeGet(Node *n, ParmList *parms)
    {
       Parm *p;
       String *proto = NewString("");
       int gencomma = 0;

       // attach the standard typemaps
       Swig_typemap_attach_parms("in", parms, 0);

       // attach 'ctype' typemaps
       Swig_typemap_attach_parms("ctype", parms, 0);


       // prepare function definition
       for (p = parms, gencomma = 0; p; ) {
            String *tm;
            SwigType *type = NULL;

            while (p && checkAttribute(p, "tmap:in:numinputs", "0")) {
                 p = Getattr(p, "tmap:in:next");
            }
            if (!p) break;

            type = Getattr(p, "type");
            if (SwigType_type(type) == T_VOID) {
                 p = nextSibling(p);
                 continue;
            }
            String *lname = Getattr(p, "lname");
            String *proxy_parm_type = 0;
            String *arg_name = NewString("");
            String* stype = 0;

            SwigType *tdtype = SwigType_typedef_resolve_all(type);
            if (tdtype)
              type = tdtype;

            Printf(arg_name, "c%s", lname);

            if ((tm = Getattr(p, "tmap:ctype"))) { // set the appropriate type for parameter
                 tm = Copy(tm);
            }
            else {
                 Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(type, 0));
            }
            // use proxy-type for parameter if supplied
            if ((stype = Getattr(p, "c:stype"))) {
                proxy_parm_type = SwigType_lstr(stype, 0);
            } else {
                substituteResolvedType(type, tm);
                proxy_parm_type = tm;              
            }

            Printv(proto, gencomma ? ", " : "", proxy_parm_type, " ", arg_name, NIL);
            gencomma = 1;

            // apply typemaps for input parameter
            if (Cmp(nodeType(n), "destructor") == 0) {
                 p = Getattr(p, "tmap:in:next");
            }
            else if ((tm = Getattr(p, "tmap:in"))) {
                 Replaceall(tm, "$input", arg_name);
                 p = Getattr(p, "tmap:in:next");
            }
            else {
                 Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(type, 0));
                 p = nextSibling(p);
            }

            Delete(arg_name);
            Delete(proxy_parm_type);
       }
       return proto;
    }

  virtual String *functionWrapperCPPSpecificProxyWrapperCallGet(Node *n, const String *wname, ParmList *parms)
    {
       Parm *p;
       String *call = NewString(wname);
       String *args = NewString("");
       int gencomma = 0;

       Printv(call, "(", NIL);
       // attach the standard typemaps
       //Swig_typemap_attach_parms("in", parms, 0);

       // attach typemaps to cast wrapper call with proxy types
       Swig_typemap_attach_parms("cmodtype", parms, 0);

       // prepare function definition
       for (p = parms, gencomma = 0; p; ) {
            String *tm;
            SwigType *type = NULL;

            while (p && checkAttribute(p, "tmap:in:numinputs", "0")) {
                 p = Getattr(p, "tmap:in:next");
            }
            if (!p) break;

            type = Getattr(p, "type");
            if (SwigType_type(type) == T_VOID) {
                 p = nextSibling(p);
                 continue;
            }
            String *lname = Getattr(p, "lname");
            String *c_parm_type = NewString("");
            //String *proxy_parm_type = NewString("");
            String *arg_name = NewString("");

            SwigType *tdtype = SwigType_typedef_resolve_all(type);
            if (tdtype)
              type = tdtype;

            Printf(arg_name, "c%s", lname);

            // set the appropriate type for parameter
            if ((tm = Getattr(p, "tmap:cmodtype"))) {
                 Printv(c_parm_type, NewString("("), tm, NewString(")"), NIL);
                 // template handling
                 Replaceall(c_parm_type, "$tt", SwigType_lstr(type, 0));
            }
            else {
                 Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No cmodtype typemap defined for %s\n", SwigType_str(type, 0));
            }

            /*
            // use proxy-type for parameter if supplied
            String* stype = Getattr(p, "c:stype");
            if (stype) {
                 Printv(proxy_parm_type, SwigType_str(stype, 0), NIL);
            }
            else {
                 Printv(proxy_parm_type, c_parm_type, NIL);
            }
            */

            Printv(args, gencomma ? ", " : "", c_parm_type, arg_name, NIL);
            gencomma = 1;

            // apply typemaps for input parameter
            if (Cmp(nodeType(n), "destructor") == 0) {
                 p = Getattr(p, "tmap:in:next");
            }
            else if ((tm = Getattr(p, "tmap:in"))) {
                 Replaceall(tm, "$input", arg_name);
                 p = Getattr(p, "tmap:in:next");
            }
            else {
                 Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(type, 0));
                 p = nextSibling(p);
            }

            Delete(arg_name);
            //Delete(proxy_parm_type);
            Delete(c_parm_type);
       }
       Printv(call, args, ")", NIL);

       return call;
    }

  virtual void functionWrapperCPPSpecificProxy(Node *n, String *name)
    {
       // C++ function wrapper proxy code
       ParmList *parms = Getattr(n, "parms");
       String *wname = Swig_name_wrapper(name);
       SwigType *preturn_type = functionWrapperCPPSpecificProxyReturnTypeGet(n);
       String *wproto = Getattr(n, "wrap:proto");
       String *pproto = functionWrapperCPPSpecificProxyPrototypeGet(n, parms);
       String *wrapper_call = NewString("");
       SwigType *proxy_type = Getattr(n, "c:stype"); // use proxy-type for return type if supplied

       if (proxy_type) {
            preturn_type = SwigType_str(proxy_type, 0);
       }

       // emit proxy functions prototypes
       // print wrapper prototype into proxy body for later use within proxy
       // body
       Printv(f_proxy_code_init, wproto, "\n", NIL);

       // print actual proxy code into proxy .c file
       Printv(f_proxy_code_body, preturn_type, " ", name, "(", pproto, ") {\n", NIL);

       // print the call of the wrapper function
       //Printv(f_proxy_code_body, "  return ", wname, "(", proxy_wrap_args, ");\n}\n", NIL);

       // Add cast if necessary
       if (SwigType_type(preturn_type) != T_VOID) {
            Printf(wrapper_call, "(%s)", preturn_type);
       }
       Printv(wrapper_call, functionWrapperCPPSpecificProxyWrapperCallGet(n, wname, parms), NIL);
       Printv(f_proxy_code_body, "  return ", wrapper_call, ";\n}\n", NIL);

       // add function declaration to the proxy header file
       /*
       // add visibility hint for the compiler (do not override this symbol)
       String *vis_hint = NewString("");
       Printv(vis_hint, "SWIGPROTECT(", preturn_type, " ", name, "(", pproto, ");)\n\n", NIL);
       Printv(f_proxy_header, vis_hint, NIL);
       Delete(vis_hint);
       */

       Printv(f_proxy_header, preturn_type, " ", name, "(", pproto, ");\n\n", NIL);

       // cleanup
       Delete(pproto);
       Delete(wrapper_call);
       Delete(preturn_type);
    }

  virtual SwigType *functionWrapperCPPSpecificWrapperSetReturnType(Node *n)
    {
       SwigType *type = Getattr(n, "type");
       SwigType *return_type = NewString("");
       String *tm;

       // set the return type
       if (IS_SET_TO_ONE(n, "c:objstruct")) {
            Printv(return_type, SwigType_str(type, 0), NIL);
       }
       else if ((tm = Swig_typemap_lookup("cmodtype", n, "", 0))) {
            String *ctypeout = Getattr(n, "tmap:cmodtype:out");
            if (ctypeout)
              {
                 tm = ctypeout;
                 Printf(stdout, "Obscure ctype:out found! O.o\n");
              }
            Printf(return_type, "%s", tm);
            // template handling
            Replaceall(return_type, "$tt", SwigType_lstr(type, 0));
       }
       else {
            Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No cmodtype typemap defined for %s\n", SwigType_str(type, 0));
       }
       return return_type;
    }


  virtual void functionWrapperCPPSpecificWrapper(Node *n, String *name)
    {
       // C++ function wrapper
       String *storage = Getattr(n, "storage");
       SwigType *type = Getattr(n, "type");
       SwigType *otype = Copy(type);
       SwigType *return_type = functionWrapperCPPSpecificWrapperReturnTypeGet(n);
       String *wname = Swig_name_wrapper(name);
       String *arg_names = NewString("");
       ParmList *parms = Getattr(n, "parms");
       Parm *p;
       int gencomma = 0;
       bool is_void_return = (SwigType_type(type) == T_VOID);
       bool return_object = false;
       // create new function wrapper object
       Wrapper *wrapper = NewWrapper();

       // create new wrapper name
       Setattr(n, "wrap:name", wname);

       // add variable for holding result of original function 'cppresult'
       // WARNING: testing typemap approach
       if (!is_void_return && !IS_SET_TO_ONE(n, "c:objstruct")) {
            String *tm;
            if ((tm = Swig_typemap_lookup("cppouttype", n, "", 0))) {
                 functionWrapperAddCPPResult(wrapper, type, tm);
                 return_object = checkAttribute(n, "tmap:cppouttype:retobj", "1");
            }
            else {
                 Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No cppouttype typemap defined for %s\n", SwigType_str(type, 0));
            }
       }

       // create wrapper function prototype
       Printv(wrapper->def, "SWIGEXPORTC ", return_type, " ", wname, "(", NIL);

       // attach the standard typemaps
       emit_attach_parmmaps(parms, wrapper);
       Setattr(n, "wrap:parms", parms); //never read again?!

       // attach 'ctype' typemaps
       Swig_typemap_attach_parms("cmodtype", parms, wrapper);

       // prepare function definition
       for (p = parms, gencomma = 0; p; ) {
            String *tm;

            while (p && checkAttribute(p, "tmap:in:numinputs", "0")) {
                 p = Getattr(p, "tmap:in:next");
            }
            if (!p) break;

            SwigType *type = Getattr(p, "type");
            if (SwigType_type(type) == T_VOID) {
                 p = nextSibling(p);
                 continue;
            }
            String *lname = Getattr(p, "lname");
            String *c_parm_type = NewString("");
            String *proxy_parm_type = NewString("");
            String *arg_name = NewString("");

            SwigType *tdtype = SwigType_typedef_resolve_all(type);
            if (tdtype)
              type = tdtype;

            Printf(arg_name, "c%s", lname);

            // set the appropriate type for parameter
            if ((tm = Getattr(p, "tmap:cmodtype"))) {
                 Printv(c_parm_type, tm, NIL);
                 // template handling
                 Replaceall(c_parm_type, "$tt", SwigType_lstr(type, 0));
            }
            else {
                 Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No cmodtype typemap defined for %s\n", SwigType_str(type, 0));
            }

            // use proxy-type for parameter if supplied
            String* stype = Getattr(p, "c:stype");
            if (stype) {
                 Printv(proxy_parm_type, SwigType_str(stype, 0), NIL);
            }
            else {
                 Printv(proxy_parm_type, c_parm_type, NIL);
            }

            Printv(arg_names, gencomma ? ", " : "", arg_name, NIL);
            Printv(wrapper->def, gencomma ? ", " : "", c_parm_type, " ", arg_name, NIL);
            gencomma = 1;

            // apply typemaps for input parameter
            if (Cmp(nodeType(n), "destructor") == 0) {
                 p = Getattr(p, "tmap:in:next");
            }
            else if ((tm = Getattr(p, "tmap:in"))) {
                 Replaceall(tm, "$input", arg_name);
                 Setattr(p, "emit:input", arg_name);
                 Printf(wrapper->code, "%s\n", tm);
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

       Printv(wrapper->def, ")", NIL);
       //Create prototype for proxy file
       String *wrap_proto = Copy(wrapper->def);
       //Declare function as extern so only the linker has to find it
       Replaceall(wrap_proto, "SWIGEXPORTC", "extern");
       Printv(wrap_proto, ";", NIL);
       Setattr(n, "wrap:proto", wrap_proto);
       Printv(wrapper->def, " {", NIL);

       if (Cmp(nodeType(n), "destructor") != 0) {
            // emit variables for holding parameters
            emit_parameter_variables(parms, wrapper);

            // emit variable for holding function return value
            emit_return_variable(n, return_type, wrapper);
       }

       // insert constraint checking
       for (p = parms; p; ) {
            String *tm;
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

       // create action code
       String *action = Getattr(n, "wrap:action");
       if (!action)
         action = NewString("");

       String *cbase_name = Getattr(n, "c:base_name");
       if (cbase_name) {
            Replaceall(action, "arg1)->", NewStringf("(%s*)arg1)->", Getattr(n, "c:inherited_from")));
            Replaceall(action, Getattr(n, "name"), cbase_name);
       }

       // handle special cases of cpp return result
       if (Cmp(nodeType(n), "constructor") != 0) {
            if (SwigType_isenum(SwigType_base(type))){
                 if (return_object)
                   Replaceall(action, "result =", "cppresult = (int)");
                 else Replaceall(action, "result =", "cppresult = (int*)");
            }
            else if (return_object && Getattr(n, "c:retval") && !SwigType_isarray(type)
                  && (Cmp(storage, "static") != 0)) {
                 // returning object by value
                 String *str = SwigType_str(SwigType_add_reference(SwigType_base(type)), "_result_ref");
                 String *lstr = SwigType_lstr(type, 0);
                 if (Cmp(Getattr(n, "kind"), "variable") == 0) {
                      Delete(action);
                      action = NewStringf("{const %s = %s;", str, Swig_cmemberget_call(Getattr(n, "name"), type, 0, 0));
                 }
                 else {
                      String *call_str = NewStringf("{const %s = %s", str,
                            SwigType_ispointer(SwigType_typedef_resolve_all(otype)) ? "*" : "");
                      Replaceall(action, "result =", call_str);
                      Delete(call_str);
                 }
                 if (Getattr(n, "nested"))
                   Replaceall(action, "=", NewStringf("= *(%s)(void*) &", SwigType_str(otype, 0)));
                 Printf(action, "cppresult = (%s*) &_result_ref;}", lstr);
                 Delete(str);
                 Delete(lstr);
            }
            else
              Replaceall(action, "result =", "cppresult = ");
       }

       // prepare action code to use, e.g. insert try-catch blocks
       action = emit_action(n);

       // emit output typemap if needed
       if (!is_void_return && (Cmp(Getattr(n, "c:objstruct"), "1") != 0)) {
            String *tm;
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

       String *except = Getattr(n, "feature:except");
       if (Getattr(n, "throws") || except) {
            if (!except || (Cmp(except, "0") != 0))
              Printf(wrapper->code, "if (SWIG_exc.handled) {\nSWIG_rt_stack_pop();\nlongjmp(SWIG_rt_env, 1);\n}\n");
       }

       // insert cleanup code
       for (p = parms; p; ) {
            String *tm;
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

       Wrapper_print(wrapper, f_wrappers);

       // cleanup
       Delete(arg_names);
       Delete(wname);
       Delete(return_type);
       Delete(otype);
       DelWrapper(wrapper);
    }

  virtual void functionWrapperCPPSpecificMarkFirstParam(Node *n)
    {
       bool is_global = IS_SET_TO_ONE(n, "c:globalfun");  // possibly no longer neede
       String *storage = Getattr(n, "storage");
       ParmList *parms = Getattr(n, "parms");

       // mark the first parameter as object-struct
       if (!is_global && storage && (Cmp(storage, "static") != 0)) {
            if (IS_SET_TO_ONE(n, "ismember") &&
                  (Cmp(nodeType(n), "constructor") != 0)) {
                 Setattr(parms, "c:objstruct", "1");
                 if (!Getattr(parms, "lname"))
                   Setattr(parms, "lname", "arg1");
                 SwigType *stype = Copy(Getattr(Swig_methodclass(n), "sym:name"));
                 SwigType_add_pointer(stype);
                 Setattr(parms, "c:stype", stype);
            }
       }
    }

  virtual void functionWrapperCPPSpecific(Node *n)
    {
       ParmList *parms = Getattr(n, "parms");
       String *name = Copy(Getattr(n, "sym:name"));
       SwigType *type = Getattr(n, "type");
       SwigType *tdtype = NULL;

       functionWrapperCPPSpecificMarkFirstParam(n);

       // mangle name if function is overloaded
       if (Getattr(n, "sym:overloaded")) {
            if (!Getattr(n, "copy_constructor")) {
                 functionWrapperAppendOverloaded(name, parms);
            }
       }

       // resolve correct type
       if((tdtype = SwigType_typedef_resolve_all(type)))
         Setattr(n, "type", tdtype);

       // make sure lnames are set
       functionWrapperPrepareArgs(parms);

       // C++ function wrapper
       functionWrapperCPPSpecificWrapper(n, name);

       if (proxy_flag) // take care of proxy function
         functionWrapperCPPSpecificProxy(n, name);

       Delete(name);
    }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   * ---------------------------------------------------------------------- */
   
  virtual int functionWrapper(Node *n) {

    if (CPlusPlus) {
         functionWrapperCPPSpecific(n);
    }
    else {
         functionWrapperCSpecific(n);
    }

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
    String *cif = Getattr(node, "c:inherited_from");
    if (cif) 
      Setattr(new_node, "c:inherited_from", Copy(cif));
    return new_node;
  }

  /* ---------------------------------------------------------------------
   * is_in()
   *
   * tests if given name already exists in one of child nodes of n
   * --------------------------------------------------------------------- */

  Hash *is_in(String *name, Node *n) {
    Hash *h;
    for (h = firstChild(n); h; h = nextSibling(h)) {
      if (Cmp(name, Getattr(h, "name")) == 0)
        return h;
    }
    return 0;
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
      // WARNING: proxy delaration can be different than original code
      if (Cmp(nodeType(node), "extend") == 0)
        emit_c_struct_def(firstChild(node));
    }
  }

  /* ---------------------------------------------------------------------
   * classHandler()
   * --------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {
    //String *name = Copy(Getattr(n, "sym:name"));
    String *name = getNamespacedName(n);
    String *sobj = NewString("");
    List *baselist = Getattr(n, "bases");

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
                    Node *new_node = copy_node(node);
                    String *parent_name = Getattr(parentNode(node), "name");
                    Hash *dupl_name_node = is_in(Getattr(node, "name"), n);
                    // if there's a duplicate inherited name, due to the C++ multiple
                    // inheritance, change both names to avoid ambiguity
                    if (dupl_name_node) {
                      String *cif = Getattr(dupl_name_node, "c:inherited_from");
                      String *old_name = Getattr(dupl_name_node, "name");
                      if (cif && parent_name && (Cmp(cif, parent_name) != 0)) {
                        Setattr(dupl_name_node, "name", NewStringf("%s%s", cif ? cif : "", old_name));                      
                        Setattr(dupl_name_node, "c:base_name", old_name);
                        Setattr(new_node, "name", NewStringf("%s%s", parent_name, old_name));
                        Setattr(new_node, "c:base_name", old_name);
                        Setattr(new_node, "c:inherited_from", parent_name);
                        Setattr(new_node, "sym:name", Getattr(new_node, "name"));
                        Setattr(new_node, "sym:symtab", Getattr(n, "symtab"));
                        set_nodeType(new_node, "cdecl");
                        appendChild(n, new_node);
                      }
                    }
                    else {
                      Setattr(new_node, "c:inherited_from", parent_name);
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

      // declare type for specific class in the proxy header
      if (proxy_flag)
        Printv(f_proxy_header, "\ntypedef struct SwigObj_", name, " ", name, ";\n\n", NIL);

      Delete(sobj);
      Delete(name);
      return Language::classHandler(n);
    }
    else if (Cmp(Getattr(n, "kind"), "struct") == 0) {
      // this is C struct, just declare it in the proxy
      if (proxy_flag) {
        String *storage = Getattr(n, "storage");
        int usetd = storage && Cmp(storage, "typedef") == 0;
        if (usetd)
          Append(f_proxy_header, "typedef struct {\n");
        else 
          Printv(f_proxy_header, "struct ", name, " {\n", NIL);
        Node *node = firstChild(n);
        emit_c_struct_def(node);
        if (usetd)
          Printv(f_proxy_header, "} ", name, ";\n\n", NIL);
        else
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
    tdtype = SwigType_typedef_resolve_all(type);
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
    tdtype = SwigType_typedef_resolve_all(type);
    if (tdtype)
      type = tdtype;
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    return Language::memberfunctionHandler(n);
  }

  /* ---------------------------------------------------------------------
   * staticmembervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    SwigType *tdtype = SwigType_typedef_resolve_all(type);
    if (tdtype) {
      type = tdtype;
      Setattr(n, "type", type);
    }
    SwigType *btype = SwigType_base(type);
    if (SwigType_isarray(type) && !SwigType_isbuiltin(btype)) {
      // this hack applies to member objects array (not ptrs.)
      SwigType_add_pointer(btype);
      SwigType_add_array(btype, NewStringf("%s", SwigType_array_getdim(type, 0)));
      Setattr(n, "type", btype);
    }
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    Delete(type);
    Delete(btype);
    return Language::staticmembervariableHandler(n);
  }

  /* ---------------------------------------------------------------------
   * membervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    SwigType *tdtype = SwigType_typedef_resolve_all(type);
    if (tdtype) {
      type = tdtype;
      Setattr(n, "type", type);
    }
    SwigType *btype = SwigType_base(type);
    if (SwigType_isarray(type) && !SwigType_isbuiltin(btype)) {
      // this hack applies to member objects array (not ptrs.)
      SwigType_add_pointer(btype);
      SwigType_add_array(btype, NewStringf("%s", SwigType_array_getdim(type, 0)));
      Setattr(n, "type", btype);
    }
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    Delete(type);
    Delete(btype);
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
        String *kname = Getattr(it.item, "sym:name");
        if (kname)
          Printf(s, "result->typenames[%d] = Swig_typename_%s;\n", i++, kname);
      }
    }
    Printf(s, "result->typenames[%d] = 0;\n", i);
    Printf(s, "}\n");
  }
  
  /* ---------------------------------------------------------------------
   * add_to_destroy_object()
   * --------------------------------------------------------------------- */

  void add_to_destroy_object(Node *n, String *classname, String *classtype) {
    String *s = destroy_object;
    String *access = Getattr(n, "access");
    if (access && Cmp(access, "private") != 0) {
      Printv(s, "if (strcmp(object->typenames[0], \"", classname, "\") == 0) {\n", NIL);
      Printv(s, "if (object->obj)\ndelete (", classtype, " *) (object->obj);\n", NIL);
      Printf(s, "}\n");
    }
  }

  /* ---------------------------------------------------------------------
   * constructorHandler()
   * --------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {
    String *access = Getattr(n, "access");
    if (Cmp(access, "private") == 0)
      return SWIG_NOWRAP;
    if (Getattr(n, "copy_constructor"))
      return copyconstructorHandler(n);

    Node *klass = Swig_methodclass(n);
    String *classname = Getattr(klass, "name");
    String *newclassname = Getattr(klass, "sym:name");
    String *sobj_name = NewString("");
    String *ctype;
    String *stype;
    String *code = NewString("");
    String *constr_name = NewString("");
    String *arg_lnames = NewString("");
    ParmList *parms = Getattr(n, "parms");
    String *nspace = Getattr(klass, "sym:nspace");

    // prepare argument names
    Append(arg_lnames, Swig_cfunction_call(empty_string, parms));

    // set the function return type to the pointer to struct
    Printf(sobj_name, "SwigObj");
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Setattr(n, "type", ctype);
    Setattr(n, "c:objstruct", "1");
    stype = Swig_name_proxy(nspace, newclassname);
    SwigType_add_pointer(stype);
    Setattr(n, "c:stype", stype);

    // Modify the constructor name if necessary
    constr_name = Swig_name_construct(nspace, newclassname);

    Setattr(n, "name", newclassname);
    Setattr(n, "sym:name", constr_name);

    // generate action code
    if (except_flag) {
      if (!Getattr(klass, "c:create")) {
        add_to_create_object(n, classname, newclassname);
        Setattr(klass, "c:create", "1");
      }
      Printv(code, "result = SWIG_create_object(\"", classname, "\");\n", NIL);
    }
    else {
      Printf(code, "result = SWIG_create_object();\n");
    }
    Printv(code, "result->obj = (void*) new ", Getattr(klass, "classtype"), arg_lnames, ";\n", NIL);

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
    String *nspace = Getattr(klass, "sym:nspace");

    Setattr(parms, "lname", "arg1");

    // set the function return type to the pointer to struct
    Printf(sobj_name, "SwigObj");
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    Setattr(n, "type", ctype);
    Setattr(n, "c:objstruct", "1");
    stype = Swig_name_proxy(nspace, newclassname);
    SwigType_add_pointer(stype);
    Setattr(n, "c:stype", stype);

    // modify the constructor if necessary
    constr_name = Swig_name_copyconstructor(nspace, newclassname);

    //Setattr(n, "name", constr_name);
    Setattr(n, "name", newclassname);
    //Setattr(n, "sym:name", constr_name);
    Setattr(n, "sym:name", constr_name);

    // generate action code
    if (except_flag) {
      if (!Getattr(klass, "c:create")) {
        add_to_create_object(n, classname, newclassname);
        Setattr(klass, "c:create", "1");
      }
      Printv(code, "result = SWIG_create_object(\"", classname, "\");\n", NIL);
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
    String *classname = Getattr(klass, "name");// Remove class namespace from constructor
    String *classtype = Getattr(klass, "classtype");
    String *newclassname = Getattr(klass, "sym:name");
    String *sobj_name = NewString("");
    String *ctype;
    String *stype;
    String *code = NewString("");
    String *destr_name = NewString("");
    String *nspace = Getattr(klass, "sym:nspace");
    Parm *p;

    // create first argument
    Printf(sobj_name, "SwigObj");
    ctype = Copy(sobj_name);
    SwigType_add_pointer(ctype);
    p = NewParm(ctype, "self", n);
    Setattr(p, "lname", "arg1");
    stype = Swig_name_proxy(nspace, newclassname);
    SwigType_add_pointer(stype);
    Setattr(p, "c:stype", stype);
    Setattr(p, "c:objstruct", "1");
    Setattr(n, "parms", p);
    Setattr(n, "type", "void");

    // modify the destructor name if necessary
    destr_name = Swig_name_destroy(nspace, newclassname);

    Setattr(n, "name", NULL);
    Setattr(n, "sym:name", destr_name);

    // create action code
    if (except_flag) {
      add_to_destroy_object(n, classname, classtype);
      Printf(code, "SWIG_remove_registry_entry(carg1);\n");
      Printf(code, "SWIG_destroy_object(carg1);");
    }
    else {
      Printv(code, "if (carg1->obj)\ndelete (", classtype, " *) (carg1->obj);\n", NIL);
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
   * --------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {
    return Language::enumDeclaration(n);
  }

  /* ---------------------------------------------------------------------
   * enumvalueDeclaration()
   * --------------------------------------------------------------------- */

  virtual int enumvalueDeclaration(Node *n) {
    if (Cmp(Getattr(n, "ismember"), "1") == 0 && Cmp(Getattr(n, "access"), "public") != 0)
      return SWIG_NOWRAP;
    Swig_require("enumvalueDeclaration", n, "*value", "?enumvalueex", "?enumvalue", NIL);
    String *name = Getattr(n, "value");
    String *value = Getattr(n, "enumvalueex");
    value = value ? value : Getattr(n, "enumvalue");
    Printv(f_proxy_header, "#define ", Swig_name_mangle(name), " ", value, "\n", NIL);
    Swig_restore(n);
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
  
  /* ---------------------------------------------------------------------
   * classDeclaration()
   * --------------------------------------------------------------------- */

  virtual int classDeclaration(Node *n) {
    String *name = NewString("");
    String *classtype = Getattr(n, "classtype");
    String *prefix = 0;
    if (classtype) {
      prefix = Swig_scopename_prefix(classtype);
      if (prefix) 
        Printf(name, "%s_", Swig_name_mangle(prefix));
    }
    Append(name, Swig_name_mangle(Getattr(n, "sym:name")));
    Setattr(n, "sym:name", name);
    if (except_flag)
      Printv(f_header, "const char* Swig_typename_", name, " = \"", Getattr(n, "name"), "\";\n\n", NIL);
    return Language::classDeclaration(n);
  }
  
  /* ---------------------------------------------------------------------
   * extendDirective()
   *
   * The idea is to extend the class with additional variables, using
   * SwigObj structs. This is not implemented yet.
   * --------------------------------------------------------------------- */

  virtual int extendDirective(Node *n) {
    return Language::extendDirective(n);
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

