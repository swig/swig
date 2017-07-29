
/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * kotlinnative.cxx
 *
 * Kotlin/Native language module for SWIG.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include <limits.h>
#include "cparse.h"
#include <ctype.h>
#include <errno.h>
#include <stdlib.h>

static const char *class_this_name = "ref";

class KOTLINNATIVE:public Language {
protected:
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;

  File *f_begin_h;
  File *f_wrappers_h;

  File *f_begin_def;

  File *f_begin_kt;
  File *f_wrappers_kt;

  File *companion_object_kt;

  int current_indent;

private:
  void print_kotlin_parameters(void *obj, ParmList *parms) {
    for (Parm *p = parms; p; p = nextSibling(p)) {
      if(p != parms) {
        Printv(obj, ", ", NIL);
      }
      String *kt_type = Swig_typemap_lookup("cinterop", p, "", 0);
      String *p_name = Getattr(p, "name");
      Printv(obj, p_name, ": ", kt_type, NIL);
      Delete(kt_type);
    }
  }

  void print_parameters_call(void *obj, ParmList *parms, bool first_comma = false) {
    for (Parm *p = parms; p; p = nextSibling(p)) {
      if(p != parms || first_comma) {
        Printv(obj, ", ", NIL);
      }
      String *p_name = Getattr(p, "name");
      Printv(obj, p_name, NIL);
    }
  }

  void indent_line(void *obj) {
    switch(current_indent) {
      case 0:
        return;
      case 1:
        Printv(obj, "  ", NIL);
        return;
      case 2:
        Printv(obj, "    ", NIL);
        return;
      case 3:
        Printv(obj, "      ", NIL);
        return;
      case 4:
        Printv(obj, "        ", NIL);
        return;
      case 5:
        Printv(obj, "          ", NIL);
        return;
      case 6:
        Printv(obj, "            ", NIL);
        return;
      default:
        Printv(obj, "              ", NIL);
        break;
    }

    for(int i=0; i<current_indent-6; i++) {
      Printv(obj, "  ", NIL);
    }
  }

  File *init_companion_object() {
    if (companion_object_kt) {
      return companion_object_kt;
    }

    return companion_object_kt = NewStringEmpty();
  }

public:
  KOTLINNATIVE() {
  }

  virtual void main(int argc, char *argv[]) {
    (void)argc; (void)argv;
    SWIG_library_directory("kotlinnative");
    Preprocessor_define("SWIGKOTLINNATIVE 1", 0);
    SWIG_typemap_lang("kotlinnative");
    SWIG_config_file("kotlinnative.swg");
  }

#define NEW_FILE_CHECK(file, filename) { \
  file = NewFile(filename, "w", SWIG_output_files()); \
  if (!file) { FileErrorDisplay(filename); SWIG_exit(EXIT_FAILURE); } }

  virtual int top(Node *n) {
    String *module = Getattr(n, "name");

    // Initialize all of the output files
    String *outfile = Getattr(n, "outfile");
    String *outfile_h = Getattr(n, "outfile_h");
    String *outfile_def = NewStringf("%s%s.def", SWIG_output_directory(), Char(module));
    String *outfile_kt = NewStringf("%s%s.kt", SWIG_output_directory(), Char(module));

    NEW_FILE_CHECK(f_begin, outfile);
    NEW_FILE_CHECK(f_begin_h, outfile_h);
    NEW_FILE_CHECK(f_begin_def, outfile_def);
    NEW_FILE_CHECK(f_begin_kt, outfile_kt);


    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    f_wrappers_h = NewString("");

    f_wrappers_kt = NewString("");

    // Register file targets with the SWIG file handler
    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    Swig_register_filebyname("begin_kt", f_wrappers_kt);


    Swig_banner(f_begin);
    Printf(f_runtime, "\n\n#ifndef SWIGKOTLINNATIVE\n#define SWIGKOTLINNATIVE\n#endif\n\n");

    Swig_banner(f_begin_h);

    // TODO: is there any standard way to generate include guards in swig?
    Printf(f_begin_h, "\n\n#pragma once\n\n");


    Printv(f_begin_def, "headers = ", outfile_h, "\n", NIL);
    Printv(f_begin_def, "compilerOpts = -I.\n", NIL);
    Printv(f_begin_def, "linkerOpts = -L. -l", module, "_wrap\n", NIL); // TODO: is there any generic way to do this?


    Swig_banner(f_begin_kt);
    Printv(f_begin_kt, "\n\nimport ", module, ".*\n\n", NIL);

    companion_object_kt = 0;

    current_indent = 0;


    // emit code
    int result = Language::top(n);


    // Write all to the files
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);

    Dump(f_wrappers_h, f_begin_h);

    Dump(f_wrappers_kt, f_begin_kt);

    // Cleanup files
    Delete(f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Delete(f_begin);

    Delete(f_wrappers_h);
    Delete(f_begin_h);

    Delete(f_begin_def);
    Delete(outfile_def);

    Delete(f_begin_kt);
    Delete(outfile_kt);

    return result;
  }

#undef NEW_FILE_CHECK


  virtual int functionWrapper(Node *n) {
    String   *name      = Getattr(n, "sym:name");
    SwigType *type      = Getattr(n, "type");
    ParmList *parms     = Getattr(n, "parms");
    String   *action    = Getattr(n, "wrap:action");
    String   *kind      = Getattr(n, "kind");
    String   *varname;
    SwigType *vartype;

    bool is_static      = Cmp(Getattr(n, "storage"), "static") == 0;
    bool is_void_return = (Cmp(type, "void") == 0);
    bool is_member      = (Cmp(Getattr(n, "ismember"), "1") == 0);
    bool is_var         = false;

    if (kind) {
      is_var = Cmp(kind, "variable") == 0;
    }

    bool is_getter;
    bool is_setter;

    if (is_member && !is_static) {
      is_getter         = Getattr(n, "memberget") != 0;
      is_setter         = Getattr(n, "memberset") != 0;

      varname           = Getattr(n, "membervariableHandler:name");
      vartype           = Getattr(n, "membervariableHandler:type");
    } else {
      is_getter         = Getattr(n, "varget") != 0;
      is_setter         = Getattr(n, "varset") != 0;

      vartype         = Getattr(n, "variableWrapper:type");

      if (is_static) {
        varname         = Getattr(n, "variableWrapper:name");
      } else {
        varname         = Getattr(n, "staticmembervariableWrapper:name");
      }
    }


    Wrapper *f = NewWrapper();
    String *wname;

    if(is_var && is_member && !is_static) {
      String *member_name = Swig_name_member(getNSpace(), getClassPrefix(), name);
      wname = Swig_name_wrapper(member_name);
      Delete(member_name);
    } else {
      wname = Swig_name_wrapper(name);
    }

    SwigType *type_wrap = Swig_typemap_lookup("kt_wrap", n, type, 0);
    String *type_str = SwigType_str(type_wrap, 0);

    Printv(f->def, "#ifdef __cplusplus\nextern \"C\"\n#endif\n", type_str, " ", wname, "(", NIL);
    Printv(f_wrappers_h, "#ifdef __cplusplus\nextern \"C\"\n#endif\n", type_str, " ", wname, "(", NIL);

    // arguments

    int i;
    Parm *p;
    for (i = 0, p = parms; p; i++, p = nextSibling(p)) {
      SwigType *pt_original = Getattr(p, "type");
      SwigType *pt = Swig_typemap_lookup("kt_wrap", p, pt_original, 0);
      String *ln = NewStringf("arg%d", i + 1);

      String *pstr = SwigType_str(pt, 0);
      if (i != 0) {
        Printv(f->def, ", ", NIL);
        Printv(f_wrappers_h, ", ", NIL);
      }
      Printv(f->def, pstr, " _", ln, NIL);
      Printv(f_wrappers_h, pstr, NIL); // TODO: default arguments
      Delete(pstr);

      pstr = SwigType_str(pt_original, 0);
      Printf(f->code, "  %s arg%d = (%s)_arg%d;\n", pstr, i + 1, pstr, i + 1);

      Delete(ln);
      Delete(pstr);
    }


    Printv(f->def, ") {", NIL);
    Printv(f_wrappers_h, ");\n\n", NIL);


    // action code

    if (!is_void_return) {
      Printv(f->code, type_str, " ", Swig_cresult_name(), ";\n", NIL);
    }

    if (is_var && !is_static) {
      if (is_getter) {
        Printv(f->code, Swig_cresult_name(), " = arg1->", varname, ";\n", NIL);
      } else {
        String *vartype_str = SwigType_str(vartype, 0);
        Printv(f->code, "arg1->", varname, " = (", vartype_str, ")arg2;\n", NIL);
        Delete(vartype_str);
      }
    } else {
      Printv(f->code, action, "\n", NIL);
    }


    // return

    if (!is_void_return) {
      Printv(f->code, "return ", Swig_cresult_name(), ";\n", NIL);
    }
    Printv(f->code, "}", NIL);

    Wrapper_print(f, f_wrappers);
    DelWrapper(f);

    if (is_getter) {
      Setattr(n, "wrap:get", wname);
    } else if(is_setter) {
      Setattr(n, "wrap:set", wname);
    } else {
      Setattr(n, "wrap:name", wname);
    }

    Delete(type_str);
    Delete(wname);

    return SWIG_OK;
  }


  virtual int globalfunctionHandler(Node *n) {
    String   *name   = Getattr(n, "sym:name");
    SwigType *type   = Getattr(n, "type");
    ParmList *parms  = Getattr(n, "parms");

    bool is_void_return = (Cmp(type, "void") == 0);

    // def

    Printv(f_wrappers_kt, "fun ", name, "(", NIL);
    print_kotlin_parameters(f_wrappers_kt, parms);
    Printv(f_wrappers_kt, ")", NIL);

    if (!is_void_return) {
      String *kt_type = Swig_typemap_lookup("cinterop", n, "", 0);
      Printv(f_wrappers_kt, ": ", kt_type, NIL);
    }

    Printv(f_wrappers_kt, " {\n", NIL);


    // body

    Printv(f_wrappers_kt, "  ", NIL);
    if(!is_void_return) {
      Printv(f_wrappers_kt, "return ", NIL);
    }
    String *wname = Swig_name_wrapper(name);
    Printv(f_wrappers_kt, wname, "(", NIL);
    Delete(wname);

    print_parameters_call(f_wrappers_kt, parms);

    Printv(f_wrappers_kt, ")\n}\n\n", NIL);

    return Language::globalfunctionHandler(n);
  }

  virtual int classHandler(Node *n) {
    String   *name   = Getattr(n, "name");
    List *baselist  = Getattr(n, "baselist");
    int base_count = Len(baselist);

    Printv(f_wrappers_kt, "open class ", name, ": ", NIL);
    if(base_count == 0) {
      Printv(f_wrappers_kt, "SwigObject", NIL);
    } else {
      if(base_count > 1) {
        // TODO: error for now
      }
      Printv(f_wrappers_kt, Getitem(baselist, 0), NIL);
    }

    Printv(f_wrappers_kt, " {\n", NIL);
    Printv(f_wrappers_kt, "  constructor(ref: COpaquePointer) : super(ref)\n", NIL);

    File *old_companion_object = companion_object_kt;
    companion_object_kt = 0;

    current_indent++;
    int result = Language::classHandler(n);

    if (companion_object_kt) {
      Printv(f_wrappers_kt, "\n", NIL);
      indent_line(f_wrappers_kt);
      Printv(f_wrappers_kt, "companion object {", companion_object_kt, NIL);
      indent_line(f_wrappers_kt);
      Printv(f_wrappers_kt, "}\n", NIL);
      Delete(companion_object_kt);
    }

    current_indent--;

    companion_object_kt = old_companion_object;

    Printv(f_wrappers_kt, "}\n\n", NIL);

    return result;
  }

  virtual int constructorHandler(Node *n) {
    ParmList *parms  = Getattr(n, "parms");
    String *name  = Getattr(n, "sym:name");
    String *cname = Swig_name_construct(0, name);
    String *wrapper_name = Swig_name_wrapper(cname);
    Delete(cname);

    indent_line(f_wrappers_kt);
    Printv(f_wrappers_kt, "constructor(", NIL);
    print_kotlin_parameters(f_wrappers_kt, parms);
    Printv(f_wrappers_kt, "): super(", wrapper_name, "(", NIL);
    print_parameters_call(f_wrappers_kt, parms);
    Printv(f_wrappers_kt, ")!!)\n", NIL);

    Delete(wrapper_name);

    return Language::constructorHandler(n);
  }

  virtual int destructorHandler(Node *n) {
    int result = Language::destructorHandler(n);

    String   *wname  = Getattr(n, "wrap:name");

    Printv(f_wrappers_kt, "\n", NIL);
    indent_line(f_wrappers_kt);
    Printv(f_wrappers_kt, "override fun delete() { ", wname, "(", class_this_name, ") }\n", NIL);

    return result;
  }


  virtual int memberfunctionHandler(Node *n) {
    int result = Language::memberfunctionHandler(n);

    String   *name   = Getattr(n, "sym:name");
    SwigType *type   = Getattr(n, "type");
    ParmList *parms  = Getattr(n, "parms");
    String   *wname  = Getattr(n, "wrap:name");

    bool is_void_return = (Cmp(type, "void") == 0);
    bool is_override = (Getattr(n, "override") != 0);
    bool is_virtual = (Cmp(Getattr(n, "storage"), "virtual") == 0);

    // def

    Printv(f_wrappers_kt, "\n", NIL);
    indent_line(f_wrappers_kt);

    if (is_override) {
      Printv(f_wrappers_kt, "override ", NIL);
    } else if (is_virtual) {
      Printv(f_wrappers_kt, "open ", NIL);
    }

    Printv(f_wrappers_kt, "fun ", name, "(", NIL);
    print_kotlin_parameters(f_wrappers_kt, parms);
    Printv(f_wrappers_kt, ")", NIL);

    if (!is_void_return) {
      String *kt_type = Swig_typemap_lookup("cinterop", n, "", 0);
      Printv(f_wrappers_kt, ": ", kt_type, NIL);
    }

    Printv(f_wrappers_kt, " {\n", NIL);


    // body

    current_indent++;
    indent_line(f_wrappers_kt);
    if(!is_void_return) {
      Printv(f_wrappers_kt, "return ", NIL);
    }
    Printv(f_wrappers_kt, wname, "(",  class_this_name, NIL);

    print_parameters_call(f_wrappers_kt, parms, true);

    Printv(f_wrappers_kt, ")\n", NIL);

    current_indent--;
    indent_line(f_wrappers_kt);
    Printv(f_wrappers_kt, "}\n", NIL);

    return result;
  }

  virtual int variableHandler(Node *n) {
    int result = Language::variableHandler(n);

    String   *name       = Getattr(n, "sym:name");
    String   *wname_get  = Getattr(n, "wrap:get");
    String   *wname_set  = Getattr(n, "wrap:set");

    bool is_member      = (Cmp(Getattr(n, "ismember"), "1") == 0);
    bool is_static      = (Cmp(Getattr(n, "storage"), "static") == 0);

    File *file = f_wrappers_kt;

    if (is_static) {
      file = init_companion_object();
      current_indent++;
    }

    // var
    String   *kt_type = Swig_typemap_lookup("cinterop", n, "", 0);
    Printv(file, "\n", NIL);
    indent_line(file);
    Printv(file, "var ", name, ": ", kt_type, "\n", NIL);
    Delete(kt_type);

    current_indent++;

    // get
    indent_line(file);
    Printv(file, "get() = ", wname_get, "(", NIL);
    if (is_member && !is_static) {
      Printv(file, class_this_name, NIL);
    }
    Printv(file, ")\n", NIL);

    // set
    if (wname_set) {
      indent_line(file);
      Printv(file, "set(value) { ", wname_set, "(", NIL);
      if (is_member && !is_static) {
        Printv(file, class_this_name, ", ", NIL);
      }
      Printv(file, "value) }\n", NIL);
    }

    current_indent--;

    if (is_static) {
      current_indent--;
    }

    return result;
  }

};


/* -----------------------------------------------------------------------------
 * swig_kotlinnative()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_kotlinnative() {
  return new KOTLINNATIVE();
}
extern "C" Language *swig_kotlinnative(void) {
  return new_swig_kotlinnative();
}
