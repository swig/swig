
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

private:
  void printKotlinParameters(void *obj, ParmList *parms) {
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

  void printParametersCall(void *obj, ParmList *parms, bool first_comma = false) {
    for (Parm *p = parms; p; p = nextSibling(p)) {
      if(p != parms || first_comma) {
        Printv(obj, ", ", NIL);
      }
      String *p_name = Getattr(p, "name");
      Printv(obj, p_name, NIL);
    }
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
    String   *name   = Getattr(n, "sym:name");
    SwigType *type   = Getattr(n, "type");
    ParmList *parms  = Getattr(n, "parms");
    String   *action = Getattr(n, "wrap:action");

    bool is_void_return = (Cmp(type, "void") == 0);
    char *test = Char(type);

    Wrapper *f = NewWrapper();
    String *wname = Swig_name_wrapper(name);

    SwigType *type_wrap = Swig_typemap_lookup("kt_wrap", n, type, 0);String *type_str = SwigType_str(type_wrap, 0);

    Printv(f->def, "#ifdef __cplusplus\nextern \"C\"\n#endif\n", type_str, " ", wname, "(", NIL);
    Printv(f_wrappers_h, "#ifdef __cplusplus\nextern \"C\"\n#endif\n", type_str, " ", wname, "(", NIL);

    // arguments

    int i;
    Parm *p;
    for (i = 0, p = parms; p; i++, p = nextSibling(p)) {
      SwigType *pt_original = Getattr(p, "type");
      SwigType *pt = Swig_typemap_lookup("kt_wrap", p, pt_original, 0);
      String *ln = NewStringf("arg%d", i+1); // TODO: use lname or something else, don't hard-code arg*

      String *pstr = SwigType_str(pt, 0);
      if (i != 0) {
        Printv(f->def, ", ", NIL);
        Printv(f_wrappers_h, ", ", NIL);
      }
      Printv(f->def, pstr, " _", ln, NIL);
      Printv(f_wrappers_h, pstr, NIL); // TODO: default arguments
      Delete(pstr);

      pstr = SwigType_str(pt_original, 0);
      Printf(f->code, "  %s arg%d = (%s)_arg%d;\n", pstr, i+1, pstr, i+1);

      Delete(ln);
      Delete(pstr);
    }

    Printv(f->def, ") {", NIL);
    Printv(f_wrappers_h, ");\n\n", NIL);



    if (!is_void_return) {
      Printv(f->code, type_str, " ", Swig_cresult_name(), ";\n", NIL);
    }
    Printv(f->code, action, "\n", NIL);
    if (!is_void_return) {
      Printv(f->code, "return ", Swig_cresult_name(), ";\n", NIL);
    }
    Printv(f->code, "}", NIL);

    Wrapper_print(f, f_wrappers);
    DelWrapper(f);



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
    printKotlinParameters(f_wrappers_kt, parms);
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

    printParametersCall(f_wrappers_kt, parms);

    Printv(f_wrappers_kt, ")\n}\n\n", NIL);

    return Language::globalfunctionHandler(n);
  }

  virtual int globalvariableHandler(Node *n) {
    String   *name   = Getattr(n, "sym:name");

    String   *kt_type = Swig_typemap_lookup("cinterop", n, "", 0);


    Printv(f_wrappers_kt, "var ", name, ": ", kt_type, "\n", NIL);


    String *fname = Swig_name_get(0, name); // TODO: what is the nspace parameter for?
    String *fname_wrap = Swig_name_wrapper(fname);
    Printv(f_wrappers_kt, "  get() = ", fname_wrap, "()\n", NIL);
    Delete(fname_wrap);
    Delete(fname);

    // TODO: only create setter if needed
    fname = Swig_name_set(0, name); // TODO: what is the nspace parameter for?
    fname_wrap = Swig_name_wrapper(fname);
    Printv(f_wrappers_kt, "  set(value) { ", fname_wrap, "(value) }\n\n", NIL);
    Delete(fname_wrap);
    Delete(fname);

    return Language::globalvariableHandler(n);
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

    int result = Language::classHandler(n);

    Printv(f_wrappers_kt, "}\n\n", NIL);

    return result;
  }

  virtual int constructorHandler(Node *n) {
    ParmList *parms  = Getattr(n, "parms");
    String *name  = Getattr(n, "sym:name");
    String *cname = Swig_name_construct(0, name);
    String *wrapper_name = Swig_name_wrapper(cname);
    Delete(cname);

    Printv(f_wrappers_kt, "  constructor(", NIL);
    printKotlinParameters(f_wrappers_kt, parms);
    Printv(f_wrappers_kt, "): super(", wrapper_name, "(", NIL);
    printParametersCall(f_wrappers_kt, parms);
    Printv(f_wrappers_kt, ")!!)\n", NIL);

    Delete(wrapper_name);

    return Language::constructorHandler(n);
  }


  virtual int memberfunctionHandler(Node *n) {
    String   *name   = Getattr(n, "sym:name");
    SwigType *type   = Getattr(n, "type");
    ParmList *parms  = Getattr(n, "parms");

    String *fname = Swig_name_member(0, getClassPrefix(), name);

    bool is_void_return = (Cmp(type, "void") == 0);
    bool is_override = (Getattr(n, "override") != 0);
    bool is_virtual = (Cmp(Getattr(n, "storage"), "virtual") == 0);

    // def

    Printv(f_wrappers_kt, "\n  ", NIL);

    if (is_override) {
      Printv(f_wrappers_kt, "override ", NIL);
    } else if (is_virtual) {
      Printv(f_wrappers_kt, "open ", NIL);
    }

    Printv(f_wrappers_kt, "fun ", name, "(", NIL);
    printKotlinParameters(f_wrappers_kt, parms);
    Printv(f_wrappers_kt, ")", NIL);

    if (!is_void_return) {
      String *kt_type = Swig_typemap_lookup("cinterop", n, "", 0);
      Printv(f_wrappers_kt, ": ", kt_type, NIL);
    }

    Printv(f_wrappers_kt, " {\n", NIL);


    // body

    Printv(f_wrappers_kt, "    ", NIL);
    if(!is_void_return) {
      Printv(f_wrappers_kt, "return ", NIL);
    }
    String *wname = Swig_name_wrapper(fname);
    Printv(f_wrappers_kt, wname, "(ref", NIL);
    Delete(wname);

    printParametersCall(f_wrappers_kt, parms, true);

    Printv(f_wrappers_kt, ")\n  }\n", NIL);

    Delete(fname);

    return Language::memberfunctionHandler(n);
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
