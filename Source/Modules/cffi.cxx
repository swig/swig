/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * cffi.cxx
 *
 * cffi language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_cffi_cxx[] = "$Header$";

#include "swigmod.h"
#include "cparse.h"
#include <ctype.h>

//#define CFFI_DEBUG
//#define CFFI_WRAP_DEBUG

class CFFI:public Language {
public:
  String *f_cl;
  String *f_clhead;
  String *f_clwrap;
  bool CWrap;     // generate wrapper file for C code?  
  File *f_cxx;
  File *f_cxx_header;
  File *f_cxx_wrapper;
  File *f_clos;

  String *module;
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int variableWrapper(Node *n);
  virtual int constantWrapper(Node *n);
  //  virtual int classDeclaration(Node *n);
  virtual int enumDeclaration(Node *n);
  virtual int typedefHandler(Node *n);

  //c++ specific code
  virtual int constructorHandler(Node *n);
  virtual int destructorHandler(Node *n);
  virtual int memberfunctionHandler(Node *n);
  virtual int membervariableHandler(Node *n);
  virtual int classHandler(Node *n);

private:
  void emit_defun(Node *n, String *name);
  void emit_defmethod(Node *n);
  void emit_initialize_instance(Node *n);
  void emit_getter(Node *n);
  void emit_setter(Node *n);
  void emit_class(Node *n);
  void emit_struct_union(Node *n, bool un);
  void emit_export(Node *n, String *name);
  void emit_inline(Node *n, String *name);
  String *lispy_name(char *name);
  String *lispify_name(Node *n, String *ty, const char *flag, bool kw = false);
  String *convert_literal(String *num_param, String *type, bool try_to_split = true);
  String *infix_to_prefix(String *val, char split_op, const String *op, String *type);
  String *strip_parens(String *string);
  String *trim(String *string);
  int generate_typedef_flag;
  bool no_swig_lisp;
};

void CFFI::main(int argc, char *argv[]) {
  int i;

  SWIG_library_directory("cffi");
  SWIG_config_file("cffi.swg");
  generate_typedef_flag = 0;
  no_swig_lisp = false;
  CWrap = false;
  for (i = 1; i < argc; i++) {
    if (!Strcmp(argv[i], "-help")) {
      Printf(stdout, "cffi Options (available with -cffi)\n");
      Printf(stdout,
       "   -generate-typedef\n"
       "\tIf this option is given then defctype will be used to generate\n"
       "\tshortcuts according to the typedefs in the input.\n"
       "   -[no]cwrap\n"
       "\tTurn on or turn off generation of an intermediate C file when\n"
       "\tcreating a C interface. By default this is only done for C++ code.\n"
       "   -[no]swig-lisp\n"
       "\tTurns on or off generation of code for helper lisp macro, functions,\n"
       "\tetc. which SWIG uses while generating wrappers. These macros, functions\n" "\tmay still be used by generated wrapper code.\n");
    } else if (!strcmp(argv[i], "-cwrap")) {
      CWrap = true;
      Swig_mark_arg(i);
    } else if ((Strcmp(argv[i], "-generate-typedef") == 0)) {
      generate_typedef_flag = 1;
      Swig_mark_arg(i);
    } else if (!strcmp(argv[i], "-nocwrap")) {
      CWrap = false;
      Swig_mark_arg(i);
    } else if (!strcmp(argv[i], "-swig-lisp")) {
      no_swig_lisp = false;
      Swig_mark_arg(i);
    } else if (!strcmp(argv[i], "-noswig-lisp")) {
      no_swig_lisp = true;
      Swig_mark_arg(i);
    }

  }
  f_clhead = NewString("");
  f_clwrap = NewString("");
  f_cl = NewString("");

  allow_overloading();
}

int CFFI::top(Node *n) {
  File *f_null = NewString("");
  module = Getattr(n, "name");

  String *cxx_filename = Getattr(n, "outfile");
  String *lisp_filename = NewString("");

  Printf(lisp_filename, "%s%s.lisp", SWIG_output_directory(), module);

  File *f_lisp = NewFile(lisp_filename, "w");
  NewFile(lisp_filename, "w");
  if (!f_lisp) {
    FileErrorDisplay(lisp_filename);
    SWIG_exit(EXIT_FAILURE);
  }

  if (CPlusPlus || CWrap) {
    f_cxx = NewFile(cxx_filename, "w");
    if (!f_cxx) {
      Close(f_lisp);
      Delete(f_lisp);
      Printf(stderr, "Unable to open %s for writing\n", cxx_filename);
      SWIG_exit(EXIT_FAILURE);
    }

    String *clos_filename = NewString("");
    Printf(clos_filename, "%s%s-clos.lisp", SWIG_output_directory(), module);
    f_clos = NewFile(clos_filename, "w");
    if (!f_clos) {
      Close(f_lisp);
      Delete(f_lisp);
      Printf(stderr, "Unable to open %s for writing\n", cxx_filename);
      SWIG_exit(EXIT_FAILURE);
    }
  } else {
    f_cxx = NewString("");
    f_clos = NewString("");
  }

  f_cxx_header = f_cxx;
  f_cxx_wrapper = NewString("");

  Swig_register_filebyname("header", f_cxx_header);
  Swig_register_filebyname("wrapper", f_cxx_wrapper);
  Swig_register_filebyname("runtime", f_cxx);
  Swig_register_filebyname("lisphead", f_clhead);
  if (!no_swig_lisp)
    Swig_register_filebyname("swiglisp", f_cl);
  else
    Swig_register_filebyname("swiglisp", f_null);

  Language::top(n);
  Printf(f_lisp, "%s\n", f_clhead);
  Printf(f_lisp, "%s\n", f_cl);
  Printf(f_lisp, "%s\n", f_clwrap);

  Printf(stderr, "All done now!\n");
  Close(f_lisp);
  Delete(f_lisp);   // Deletes the handle, not the file
  Delete(f_cl);
  Delete(f_clhead);
  Delete(f_clwrap);
  Close(f_cxx);
  Delete(f_cxx);
  Delete(f_cxx_wrapper);
  Delete(f_null);

  return SWIG_OK;
}

int CFFI::classHandler(Node *n) {
#ifdef CFFI_DEBUG
  Printf(stderr, "class %s::%s\n", "some namespace",  //current_namespace,
   Getattr(n, "sym:name"));
#endif
  String *name = Getattr(n, "sym:name");
  String *kind = Getattr(n, "kind");

  // maybe just remove this check and get rid of the else clause below.
  if (Strcmp(kind, "struct") == 0) {
    emit_struct_union(n, false);
    return SWIG_OK;
  } else if (Strcmp(kind, "union") == 0) {
    emit_struct_union(n, true);
    return SWIG_OK;
  } else if (Strcmp(kind, "class") == 0) {
    emit_class(n);
    Language::classHandler(n);
  } else {
    Printf(stderr, "Don't know how to deal with %s kind of class yet.\n", kind);
    Printf(stderr, " (name: %s)\n", name);
    SWIG_exit(EXIT_FAILURE);
    return SWIG_OK;
  }

  return SWIG_OK;
}

int CFFI::constructorHandler(Node *n) {
#ifdef CFFI_DEBUG
  Printf(stderr, "constructor %s\n", Getattr(n, "name"));
  Printf(stderr, "constructor %s\n and %s and %s", Getattr(n, "kind"), Getattr(n, "sym:name"), Getattr(n, "allegrocl:old-sym:name"));
#endif
  Setattr(n, "cffi:constructorfunction", "1");
  // Let SWIG generate a global forwarding function.
  return Language::constructorHandler(n);
}

int CFFI::destructorHandler(Node *n) {
#ifdef CFFI_DEBUG
  Printf(stderr, "destructor %s\n", Getattr(n, "name"));
#endif

  // Let SWIG generate a global forwarding function.
  return Language::destructorHandler(n);
}

void CFFI::emit_defmethod(Node *n) {
  String *args_placeholder = NewStringf("");
  String *args_call = NewStringf("");

  ParmList *pl = Getattr(n, "parms");
  int argnum = 0;
  Node *parent = parentNode(n);
  bool first = 0;
  
  for (Parm *p = pl; p; p = nextSibling(p), argnum++) {
    String *argname = Getattr(p, "name");
    String *ffitype = Swig_typemap_lookup_new("lispclass", p, "", 0);

    int tempargname = 0;

    if(!first)
      first = true;
    else
      Printf(args_placeholder, " ");
      
    if (!argname) {
      argname = NewStringf("arg%d", argnum);
      tempargname = 1;
    } else if (Strcmp(argname, "t") == 0 || Strcmp(argname, "T") == 0) {
      argname = NewStringf("t-arg%d", argnum);
      tempargname = 1;
    }
    if (Len(ffitype) > 0)
      Printf(args_placeholder, "(%s %s)", argname, ffitype);
    else
      Printf(args_placeholder, "%s", argname);

    if (Strcmp(ffitype, lispify_name(parent, lispy_name(Char(Getattr(parent, "sym:name"))), "'classname")) == 0)
      Printf(args_call, " (ff-pointer %s)", argname);
    else
      Printf(args_call, " %s", argname);

    Delete(ffitype);

    if (tempargname)
      Delete(argname);
  }

  String *method_name = Getattr(n, "name");
  int x = Replace(method_name, "operator ", "", DOH_REPLACE_FIRST); //  

  if (x == 1)
    Printf(f_clos, "(cl:shadow \"%s\")\n", method_name);

  Printf(f_clos, "(cl:defmethod %s (%s)\n  (%s%s))\n\n",
         lispify_name(n, lispy_name(Char(method_name)), "'method"), args_placeholder,
         lispify_name(n, Getattr(n, "sym:name"), "'function"), args_call);

}

void CFFI::emit_initialize_instance(Node *n) {
  String *args_placeholder = NewStringf("");
  String *args_call = NewStringf("");

  ParmList *pl = Getattr(n, "parms");
  int argnum = 0;
  Node *parent = parentNode(n);

  for (Parm *p = pl; p; p = nextSibling(p), argnum++) {
    String *argname = Getattr(p, "name");
    String *ffitype = Swig_typemap_lookup_new("lispclass", p, "", 0);

    int tempargname = 0;
    if (!argname) {
      argname = NewStringf("arg%d", argnum);
      tempargname = 1;
    } else if (Strcmp(argname, "t") == 0 || Strcmp(argname, "T") == 0) {
      argname = NewStringf("t-arg%d", argnum);
      tempargname = 1;
    }
    if (Len(ffitype) > 0)
      Printf(args_placeholder, " (%s %s)", argname, ffitype);
    else
      Printf(args_placeholder, " %s", argname);

    if (Strcmp(ffitype, lispify_name(parent, lispy_name(Char(Getattr(parent, "sym:name"))), "'classname")) == 0)
      Printf(args_call, " (ff-pointer %s)", argname);
    else
      Printf(args_call, " %s", argname);

    Delete(ffitype);

    if (tempargname)
      Delete(argname);
  }

  Printf(f_clos, "(cl:defmethod initialize-instance :after ((obj %s) &key%s)\n  (setf (slot-value obj 'ff-pointer) (%s%s)))\n\n",
         lispify_name(parent, lispy_name(Char(Getattr(parent, "sym:name"))), "'class"), args_placeholder,
         lispify_name(n, Getattr(n, "sym:name"), "'function"), args_call);

}

void CFFI::emit_setter(Node *n) {
  Node *p = parentNode(n);
  Printf(f_clos, "(cl:defmethod (cl:setf %s) (arg0 (obj %s))\n  (%s (ff-pointer obj) arg0))\n\n",
         lispify_name(n, Getattr(n, "name"), "'method"),
         lispify_name(p, lispy_name(Char(Getattr(p, "sym:name"))), "'class"), lispify_name(n, Getattr(n, "sym:name"), "'function"));
}


void CFFI::emit_getter(Node *n) {
  Node *p = parentNode(n);
  Printf(f_clos, "(cl:defmethod %s ((obj %s))\n  (%s (ff-pointer obj)))\n\n",
         lispify_name(n, Getattr(n, "name"), "'method"),
         lispify_name(p, lispy_name(Char(Getattr(p, "sym:name"))), "'class"), lispify_name(n, Getattr(n, "sym:name"), "'function"));
}

int CFFI::memberfunctionHandler(Node *n) {
  // Let SWIG generate a global forwarding function.
  Setattr(n, "cffi:memberfunction", "1");
  return Language::memberfunctionHandler(n);
}

int CFFI::membervariableHandler(Node *n) {
  // Let SWIG generate a get/set function pair.
  Setattr(n, "cffi:membervariable", "1");
  return Language::membervariableHandler(n);
}

int CFFI::functionWrapper(Node *n) {

  ParmList *parms = Getattr(n, "parms");
  String *iname = Getattr(n, "sym:name");
  Wrapper *wrap = NewWrapper();

  String *raw_return_type = Swig_typemap_lookup_new("ctype", n, "", 0);
  SwigType *return_type = Swig_cparse_type(raw_return_type);
  SwigType *resolved = SwigType_typedef_resolve_all(return_type);
  int is_void_return = (Cmp(resolved, "void") == 0);
  Delete(resolved);

  if (!is_void_return) {
    String *lresult_init = NewStringf("lresult = (%s)0", raw_return_type);
    Wrapper_add_localv(wrap, "lresult", raw_return_type, lresult_init, NIL);
    Delete(lresult_init);
  }

  String *overname = 0;
  if (Getattr(n, "sym:overloaded")) {
    overname = Getattr(n, "sym:overname");
  } else {
    if (!addSymbol(iname, n))
      return SWIG_ERROR;
  }

  String *wname = Swig_name_wrapper(iname);
  if (overname) {
    Append(wname, overname);
  }
  // Emit all of the local variables for holding arguments.
  emit_args(Getattr(n, "type"), parms, wrap);

  // Attach the standard typemaps 
  Swig_typemap_attach_parms("ctype", parms, wrap);
  emit_attach_parmmaps(parms, wrap);

  int num_arguments = emit_num_arguments(parms);
  String *name_and_parms = NewStringf("%s (", wname);
  int i;
  Parm *p;
  int gencomma = 0;

#ifdef CFFI_DEBUG
  Printf(stderr, "function  -  %s - %d\n", Getattr(n, "name"), num_arguments);
#endif

  for (i = 0, p = parms; i < num_arguments; i++) {

    while (checkAttribute(p, "tmap:in:numinputs", "0")) {
      p = Getattr(p, "tmap:in:next");
    }

    SwigType *c_parm_type = Swig_cparse_type(Getattr(p, "tmap:ctype"));
    String *arg = NewStringf("l%s", Getattr(p, "lname"));

    // Emit parameter declaration
    if (gencomma)
      Printf(name_and_parms, ", ");
    String *parm_decl = SwigType_str(c_parm_type, arg);
    Printf(name_and_parms, "%s", parm_decl);
#ifdef CFFI_DEBUG
    Printf(stderr, "  param: %s\n", parm_decl);
#endif
    Delete(parm_decl);
    gencomma = 1;

    // Emit parameter conversion code
    String *parm_code = Getattr(p, "tmap:in");
    {
      Replaceall(parm_code, "$input", arg);
      Setattr(p, "emit:input", arg);
      Printf(wrap->code, "%s\n", parm_code);
      p = Getattr(p, "tmap:in:next");
    }

    Delete(arg);
  }
  Printf(name_and_parms, ")");

  // Emit the function definition
  String *signature = SwigType_str(return_type, name_and_parms);
  Printf(wrap->def, "EXPORT %s {", signature);
  Printf(wrap->code, "  try {\n");
  emit_action(n, wrap);
  if (!is_void_return) {
    String *result_convert = Swig_typemap_lookup_new("out", n, "result", 0);
    Replaceall(result_convert, "$result", "lresult");
    Printf(wrap->code, "%s\n", result_convert);
    Printf(wrap->code, "    return lresult;\n");
    Delete(result_convert);
  }

  Printf(wrap->code, "  } catch (...) {\n");
  if (!is_void_return)
    Printf(wrap->code, "    return (%s)0;\n", raw_return_type);
  Printf(wrap->code, "  }\n");
  Printf(wrap->code, "}\n");

  if (CPlusPlus)
    Wrapper_print(wrap, f_cxx);

  if (CPlusPlus) {
    emit_defun(n, wname);
    if (Getattr(n, "cffi:memberfunction"))
      emit_defmethod(n);
    else if (Getattr(n, "cffi:membervariable")) {
      if (Getattr(n, "memberget"))
        emit_getter(n);
      else if (Getattr(n, "memberset"))
        emit_setter(n);
    }
    else if (Getattr(n, "cffi:constructorfunction")) {
      emit_initialize_instance(n);
    }
  } else
    emit_defun(n, iname);

  //   if (!overloaded || !Getattr(n, "sym:nextSibling")) {
  //     update_package_if_needed(n);
  //     emit_buffered_defuns(n);
  //     // this is the last overload.
  //     if (overloaded) {
  //       emit_dispatch_defun(n);
  //     }
  //   }

  Delete(wname);

  return SWIG_OK;
}


void CFFI::emit_defun(Node *n, String *name) {

  //   String *storage=Getattr(n,"storage");
  //   if(!storage || (Strcmp(storage,"extern") && Strcmp(storage,"externc")))
  //     return SWIG_OK;

  String *func_name = Getattr(n, "sym:name");

  ParmList *pl = Getattr(n, "parms");

  int argnum = 0;

  func_name = lispify_name(n, func_name, "'function");

  emit_inline(n, func_name);

  Printf(f_cl, "\n(cffi:defcfun (\"%s\" %s)", name, func_name);
  String *ffitype = Swig_typemap_lookup_new("cout", n, ":pointer", 0);

  Printf(f_cl, " %s", ffitype);
  Delete(ffitype);

  for (Parm *p = pl; p; p = nextSibling(p), argnum++) {

    if (SwigType_isvarargs(Getattr(p, "type"))) {
      Printf(f_cl, "\n  %s", NewString("&rest"));
      continue;
    }

    String *argname = Getattr(p, "name");

    ffitype = Swig_typemap_lookup_new("cin", p, "", 0);

    int tempargname = 0;
    if (!argname) {

      argname = NewStringf("arg%d", argnum);
      tempargname = 1;
    } else if (Strcmp(argname, "t") == 0 || Strcmp(argname, "T") == 0) {
      argname = NewStringf("t_arg%d", argnum);
      tempargname = 1;
    }

    Printf(f_cl, "\n  (%s %s)", argname, ffitype);

    Delete(ffitype);

    if (tempargname)
      Delete(argname);
  }
  Printf(f_cl, ")\n");    /* finish arg list */

  emit_export(n, func_name);
}


int CFFI::constantWrapper(Node *n) {
  String *type = Getattr(n, "type");
  String *converted_value = convert_literal(Getattr(n, "value"), type);
  String *name = lispify_name(n, Getattr(n, "sym:name"), "'constant");

  if (Strcmp(name, "t") == 0 || Strcmp(name, "T") == 0)
    name = NewStringf("t_var");

  Printf(f_cl, "\n(cl:defconstant %s %s)\n", name, converted_value);
  Delete(converted_value);

  emit_export(n, name);
  return SWIG_OK;
}

int CFFI::variableWrapper(Node *n) {
  //  String *storage=Getattr(n,"storage");
  //  Printf(stdout,"\"%s\" %s)\n",storage,Getattr(n, "sym:name"));

  //  if(!storage || (Strcmp(storage,"extern") && Strcmp(storage,"externc")))
  //    return SWIG_OK;

  String *var_name = Getattr(n, "sym:name");
  String *lisp_type = Swig_typemap_lookup_new("cin", n, "", 0);
  String *lisp_name = lispify_name(n, var_name, "'variable");

  if (Strcmp(lisp_name, "t") == 0 || Strcmp(lisp_name, "T") == 0)
    lisp_name = NewStringf("t_var");

  Printf(f_cl, "\n(cffi:defcvar (\"%s\" %s)\n %s)\n", var_name, lisp_name, lisp_type);

  Delete(lisp_type);

  emit_export(n, lisp_name);
  return SWIG_OK;
}

int CFFI::typedefHandler(Node *n) {
  if (generate_typedef_flag && strncmp(Char(Getattr(n, "type")), "enum", 4)) {
    String *lisp_name = lispify_name(n, Getattr(n, "name"), "'typename");
    Printf(f_cl, "\n(cffi:defctype %s %s)\n", lisp_name, Swig_typemap_lookup_new("cin", n, "", 0));
    emit_export(n, lisp_name);
  }
  return Language::typedefHandler(n);
}

int CFFI::enumDeclaration(Node *n) {
  String *name = Getattr(n, "sym:name");
  bool slot_name_keywords;
  String *lisp_name = 0;
  if (name && Len(name) != 0) {
    lisp_name = lispify_name(n, name, "'enumname");
    if (GetFlag(n, "feature:bitfield")) {
      Printf(f_cl, "\n(cffi:defbitfield %s", lisp_name);
    } else {
      Printf(f_cl, "\n(cffi:defcenum %s", lisp_name);
    }
    slot_name_keywords = true;

    //Registering the enum name to the cin and cout typemaps
    Parm *pattern = NewParm(name, NULL);
    Swig_typemap_register("cin", pattern, lisp_name, NULL, NULL);
    Swig_typemap_register("cout", pattern, lisp_name, NULL, NULL);
    Delete(pattern);
    //Registering with the kind, i.e., enum
    pattern = NewParm(NewStringf("enum %s", name), NULL);
    Swig_typemap_register("cin", pattern, lisp_name, NULL, NULL);
    Swig_typemap_register("cout", pattern, lisp_name, NULL, NULL);
    Delete(pattern);

  } else {
    Printf(f_cl, "\n(defanonenum %s", name);
    slot_name_keywords = false;
  }

  for (Node *c = firstChild(n); c; c = nextSibling(c)) {

    String *slot_name = lispify_name(c, Getattr(c, "name"), "'enumvalue", slot_name_keywords);
    String *value = Getattr(c, "enumvalue");

    if (!value || GetFlag(n, "feature:bitfield:ignore_values"))
      Printf(f_cl, "\n\t%s", slot_name);
    else {
      String *type = Getattr(c, "type");
      String *converted_value = convert_literal(value, type);
      Printf(f_cl, "\n\t(%s %s)", slot_name, converted_value);
      Delete(converted_value);
    }
    Delete(value);
  }

  Printf(f_cl, ")\n");

  // No need to export keywords
  if (lisp_name && Len(lisp_name) != 0) {
    emit_export(n, lisp_name);
  } else {
    for (Node *c = firstChild(n); c; c = nextSibling(c))
      emit_export(c, lispify_name(c, Getattr(c, "name"), "'enumvalue"));
  }

  return SWIG_OK;
}
void CFFI::emit_class(Node *n) {

#ifdef CFFI_WRAP_DEBUG
  Printf(stderr, "emit_class: ENTER... '%s'(%x)\n", Getattr(n, "sym:name"), n);
#endif

  String *name = Getattr(n, "sym:name");
  String *lisp_name = lispify_name(n, lispy_name(Char(name)), "'classname");

  String *bases = Getattr(n, "bases");
  String *supers = NewString("(");
  if (bases) {
    int first = 1;
    for (Iterator i = First(bases); i.item; i = Next(i)) {
      if (!first)
  Printf(supers, " ");
      String *s = Getattr(i.item, "name");
      Printf(supers, "%s", lispify_name(i.item, s, "'classname"));
    }
  } else {
    // Printf(supers,"ff:foreign-pointer");
  }

  Printf(supers, ")");
  Printf(f_clos, "\n(cl:defclass %s%s", lisp_name, supers);
  Printf(f_clos, "\n  ((ff :reader ff-pointer)))\n\n");

  Parm *pattern = NewParm(Getattr(n, "name"), NULL);

  Swig_typemap_register("lispclass", pattern, lisp_name, NULL, NULL);
  SwigType_add_pointer(Getattr(pattern, "type"));
  Swig_typemap_register("lispclass", pattern, lisp_name, NULL, NULL);
  SwigType_add_qualifier(Getattr(pattern, "type"), "const");
  Swig_typemap_register("lispclass", pattern, lisp_name, NULL, NULL);
  SwigType_del_pointer(Getattr(pattern, "type"));
  SwigType_add_reference(Getattr(pattern, "type"));
  Swig_typemap_register("lispclass", pattern, lisp_name, NULL, NULL);

#ifdef CFFI_WRAP_DEBUG
  Printf(stderr, "  pattern %s  name %s .. ... %s .\n", pattern, lisp_name);
#endif

  Delete(pattern);

  // Walk children to generate type definition.
  String *slotdefs = NewString("   ");

#ifdef CFFI_WRAP_DEBUG
  Printf(stderr, "  walking children...\n");
#endif

  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    String *storage_type = Getattr(c, "storage");
    if ((!Strcmp(nodeType(c), "cdecl") && (!storage_type || Strcmp(storage_type, "typedef")))) {
      String *access = Getattr(c, "access");

      // hack. why would decl have a value of "variableHandler" and now "0"?
      String *childDecl = Getattr(c, "decl");
      // Printf(stderr,"childDecl = '%s' (%s)\n", childDecl, Getattr(c,"view"));
      if (!Strcmp(childDecl, "0"))
  childDecl = NewString("");

      SwigType *childType = NewStringf("%s%s", childDecl,
               Getattr(c, "type"));
      String *cname = (access && Strcmp(access, "public")) ? NewString("nil") : Copy(Getattr(c, "name"));

      if (!SwigType_isfunction(childType)) {
  // Printf(slotdefs, ";;; member functions don't appear as slots.\n ");
  // Printf(slotdefs, ";; ");
  //        String *ns = listify_namespace(Getattr(n, "cffi:package"));
  String *ns = NewString("");
#ifdef CFFI_WRAP_DEBUG
  Printf(stderr, "slot name = '%s' ns = '%s' class-of '%s' and type = '%s'\n", cname, ns, name, childType);
#endif
  Printf(slotdefs, "(#.(swig-insert-id \"%s\" %s :type :slot :class \"%s\") %s)", cname, ns, name, childType);  //compose_foreign_type(childType)
  Delete(ns);
  if (access && Strcmp(access, "public"))
    Printf(slotdefs, " ;; %s member", access);

  Printf(slotdefs, "\n   ");
      }
      Delete(childType);
      Delete(cname);
    }
  }


  //   String *ns_list = listify_namespace(Getattr(n,"cffi:namespace"));
  //   update_package_if_needed(n,f_clhead);
  //   Printf(f_clos, 
  //          "(swig-def-foreign-class \"%s\"\n %s\n  (:%s\n%s))\n\n", 
  //          name, supers, kind, slotdefs);

  Delete(supers);
  //  Delete(ns_list);

  //  Parm *pattern = NewParm(name,NULL);
  // Swig_typemap_register("cin",pattern,lisp_name,NULL,NULL);  
  //Swig_typemap_register("cout",pattern,lisp_name,NULL,NULL);
  //Delete(pattern);

#ifdef CFFI_WRAP_DEBUG
  Printf(stderr, "emit_class: EXIT\n");
#endif
}

// Includes structs
void CFFI::emit_struct_union(Node *n, bool un = false) {
#ifdef CFFI_DEBUG
  Printf(stderr, "struct/union %s\n", Getattr(n, "name"));
  Printf(stderr, "struct/union %s\n and %s", Getattr(n, "kind"), Getattr(n, "sym:name"));
#endif

  String *name = Getattr(n, "sym:name");
  String *kind = Getattr(n, "kind");

  if (Strcmp(kind, "struct") != 0 && Strcmp(kind, "union") != 0) {
    Printf(stderr, "Don't know how to deal with %s kind of class yet.\n", kind);
    Printf(stderr, " (name: %s)\n", name);
    SWIG_exit(EXIT_FAILURE);
  }
  String *lisp_name = lispify_name(n, name, "'classname");

  //Register the struct/union name to the cin and cout typemaps

  Parm *pattern = NewParm(name, NULL);
  Swig_typemap_register("cin", pattern, lisp_name, NULL, NULL);
  Swig_typemap_register("cout", pattern, lisp_name, NULL, NULL);
  Delete(pattern);
  //Registering with the kind, i.e., struct or union
  pattern = NewParm(NewStringf("%s %s", kind, name), NULL);
  Swig_typemap_register("cin", pattern, lisp_name, NULL, NULL);
  Swig_typemap_register("cout", pattern, lisp_name, NULL, NULL);
  Delete(pattern);

  if (un) {
    Printf(f_cl, "\n(cffi:defcunion %s", lisp_name);
  } else
    Printf(f_cl, "\n(cffi:defcstruct %s", lisp_name);


  for (Node *c = firstChild(n); c; c = nextSibling(c)) {
#ifdef CFFI_DEBUG
    Printf(stderr, "struct/union %s\n", Getattr(c, "name"));
    Printf(stderr, "struct/union %s and %s \n", Getattr(c, "kind"), Getattr(c, "sym:name"));
#endif

    if (Strcmp(nodeType(c), "cdecl")) {
      //C declaration ignore
      //        Printf(stderr, "Structure %s has a slot that we can't deal with.\n",
      //               name);
      //        Printf(stderr, "nodeType: %s, name: %s, type: %s\n", 
      //               nodeType(c),
      //               Getattr(c, "name"),
      //               Getattr(c, "type"));
      //       SWIG_exit(EXIT_FAILURE);
    } else {
      SwigType *childType = NewStringf("%s%s", Getattr(c, "decl"),
               Getattr(c, "type"));

      Hash *typemap = Swig_typemap_search("cin", childType, "", 0);
      String *typespec = NewString("");
      if (typemap) {
  typespec = NewString(Getattr(typemap, "code"));
      }

      String *slot_name = lispify_name(c, Getattr(c, "sym:name"), "'slotname");
      if (Strcmp(slot_name, "t") == 0 || Strcmp(slot_name, "T") == 0)
  slot_name = NewStringf("t_var");

      Printf(f_cl, "\n\t(%s %s)", slot_name, typespec);

      Delete(typespec);
    }
  }

  Printf(f_cl, ")\n");

  emit_export(n, lisp_name);
  for (Node *c = firstChild(n); c; c = nextSibling(c)) {
    if (!Strcmp(nodeType(c), "cdecl")) {
      emit_export(c, lispify_name(c, Getattr(c, "sym:name"), "'slotname"));
    }
  }

  /* Add this structure to the known lisp types */
  //Printf(stdout, "Adding %s foreign type\n", name);
  //  add_defined_foreign_type(name);

}

void CFFI::emit_export(Node *n, String *name) {
  if (GetInt(n, "feature:export"))
    Printf(f_cl, "\n(cl:export '%s)\n", name);
}

void CFFI::emit_inline(Node *n, String *name) {
  if (GetInt(n, "feature:inline"))
    Printf(f_cl, "\n(cl:declaim (cl:inline %s))\n", name);
}

String *CFFI::lispify_name(Node *n, String *ty, const char *flag, bool kw) {
  String *intern_func = Getattr(n, "feature:intern_function");
  if (intern_func) {
    if (Strcmp(intern_func, "1") == 0)
      intern_func = NewStringf("swig-lispify");
    return NewStringf("#.(%s \"%s\" %s%s)", intern_func, ty, flag, kw ? " :keyword" : "");
  } else if (kw)
    return NewStringf(":%s", ty);
  else
    return ty;
}

/* utilities */
/* returns new string w/ parens stripped */
String *CFFI::strip_parens(String *string) {
  char *s = Char(string), *p;
  int len = Len(string);
  String *res;

  if (len == 0 || s[0] != '(' || s[len - 1] != ')') {
    return NewString(string);
  }

  p = (char *) malloc(len - 2 + 1);
  if (!p) {
    Printf(stderr, "Malloc failed\n");
    SWIG_exit(EXIT_FAILURE);
  }

  strncpy(p, s + 1, len - 1);
  p[len - 2] = 0;   /* null terminate */

  res = NewString(p);
  free(p);

  return res;
}

String *CFFI::trim(String *str) {
  char *c = Char(str);
  while (*c != '\0' && isspace((int) *c))
    ++c;
  String *result = NewString(c);
  Chop(result);
  return result;
}

String *CFFI::infix_to_prefix(String *val, char split_op, const String *op, String *type) {
  List *ored = Split(val, split_op, -1);

  // some float hackery
  //i don't understand it, if you do then please explain
  //   if ( ((split_op == '+') || (split_op == '-')) && Len(ored) == 2 &&
  //        (SwigType_type(type) == T_FLOAT || SwigType_type(type) == T_DOUBLE ||
  //    SwigType_type(type) == T_LONGDOUBLE) ) {
  //     // check that we're not splitting a float
  //     String *possible_result = convert_literal(val, type, false);
  //     if (possible_result) return possible_result;

  //   }

  // try parsing the split results. if any part fails, kick out.
  bool part_failed = false;
  if (Len(ored) > 1) {
    String *result = NewStringf("(%s", op);
    for (Iterator i = First(ored); i.item; i = Next(i)) {
      String *converted = convert_literal(i.item, type);
      if (converted) {
  Printf(result, " %s", converted);
  Delete(converted);
      } else {
  part_failed = true;
  break;
      }
    }
    Printf(result, ")");
    Delete(ored);
    return part_failed ? 0 : result;
  } else {
    Delete(ored);
  }
  return 0;
}

/* To be called by code generating the lisp interface
   Will return a String containing the literal based on type.
   Will return null if there are problems.

   try_to_split defaults to true (see stub above).
*/
String *CFFI::convert_literal(String *literal, String *type, bool try_to_split) {
  String *num_param = Copy(literal);
  String *trimmed = trim(num_param);
  String *num = strip_parens(trimmed), *res = 0;
  Delete(trimmed);
  char *s = Char(num);

  // very basic parsing of infix expressions.
  if (try_to_split) {
    if ((res = infix_to_prefix(num, '|', "cl:logior", type)))
      return res;
    if ((res = infix_to_prefix(num, '&', "cl:logand", type)))
      return res;
    if ((res = infix_to_prefix(num, '^', "cl:logxor", type)))
      return res;
    if ((res = infix_to_prefix(num, '*', "cl:*", type)))
      return res;
    if ((res = infix_to_prefix(num, '/', "cl:/", type)))
      return res;
    if ((res = infix_to_prefix(num, '+', "cl:+", type)))
      return res;
    if ((res = infix_to_prefix(num, '-', "cl:-", type)))
      return res;
  }

  if (SwigType_type(type) == T_FLOAT || SwigType_type(type) == T_DOUBLE || SwigType_type(type) == T_LONGDOUBLE) {
    // Use CL syntax for float literals 

    // careful. may be a float identifier or float constant.
    char *num_start = Char(num);
    char *num_end = num_start + strlen(num_start) - 1;

    bool is_literal = isdigit(*num_start) || (*num_start == '.') || (*num_start == '+') || (*num_start == '-');

    String *lisp_exp = 0;
    if (is_literal) {
      if (*num_end == 'f' || *num_end == 'F') {
        lisp_exp = NewString("f");
      } else {
        lisp_exp = NewString("d");
      }

      if (*num_end == 'l' || *num_end == 'L' || *num_end == 'f' || *num_end == 'F') {
        *num_end = '\0';
        num_end--;
      }

      int exponents = Replaceall(num, "e", lisp_exp) + Replaceall(num, "E", lisp_exp);

      if (!exponents)
        Printf(num, "%s0", lisp_exp);

      if (exponents > 1 || (exponents + Replaceall(num, ".", ".") == 0)) {
        Delete(num);
        num = 0;
      }
    }
    return num;
  } else if (SwigType_type(type) == T_CHAR) {
    /* Use CL syntax for character literals */
    String* result = NewStringf("#\\%c", s[2]);
    Delete(num);
    //    Printf(stderr, "%s  %c %d", s, s[2], s);
    return result;
  } else if (SwigType_type(type) == T_STRING) {
    /* Use CL syntax for string literals */
    String* result = NewStringf("\"%s\"", num_param);
    Delete(num);
    return result;
  } else if (SwigType_type(type) == T_INT || SwigType_type(type) == T_UINT) {
    // Printf(stderr, "Is a T_INT or T_UINT %s, before replaceall\n", s);
    Replaceall(num, "u", "");
    Replaceall(num, "U", "");
    Replaceall(num, "l", "");
    Replaceall(num, "L", "");

    int i, j;
    if (sscanf(s, "%d >> %d", &i, &j) == 2) {
      String* result = NewStringf("(cl:ash %d -%d)", i, j);
      Delete(num);
      return result;
    } else if (sscanf(s, "%d << %d", &i, &j) == 2) {
      String* result = NewStringf("(cl:ash %d %d)", i, j);
      Delete(num);
      return result;
    }
  }

  if (Len(num) >= 2 && s[0] == '0') { /* octal or hex */
    if (s[1] == 'x'){
      DohReplace(num,"0","#",DOH_REPLACE_FIRST);
    }
    else{
      DohReplace(num,"0","#o",DOH_REPLACE_FIRST);
    }
  }
  return num;
}

//less flexible as it does the conversion in C, the lispify name does the conversion in lisp
String *CFFI::lispy_name(char *name) {
  bool helper = false;
  String *new_name = NewString("");
  for (unsigned int i = 0; i < strlen(name); i++) {
    if (name[i] == '_' || name[i] == '-') {
      Printf(new_name, "%c", '-');
      helper = false;
    } else if (name[i] >= 'A' && name[i] <= 'Z') {
      if (helper)
  Printf(new_name, "%c", '-');
      Printf(new_name, "%c", ('a' + (name[i] - 'A')));
      helper = false;
    } else {
      helper = true;
      Printf(new_name, "%c", name[i]);
    }
  }
  return new_name;
}

extern "C" Language *swig_cffi(void) {
  return new CFFI();
}
