
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

public:
  KOTLINNATIVE() {
  }

  virtual void main(int argc, char *argv[]) {
    SWIG_library_directory("kotlinnative");
    Preprocessor_define("SWIGKOTLINNATIVE 1", 0);
    SWIG_typemap_lang("kotlinnative");
    SWIG_config_file("kotlinnative.swg");
  }

#define NEW_FILE_CHECK(file, filename) { file = NewFile(filename, "w", SWIG_output_files()); if (!file) { FileErrorDisplay(filename); SWIG_exit(EXIT_FAILURE); } }

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

    //Swig_register_filebyname("wrapper_h", f_wrappers_h);


    Swig_banner(f_begin);
    Printf(f_runtime, "\n\n#ifndef SWIGKOTLINNATIVE\n#define SWIGKOTLINNATIVE\n#endif\n\n");

    Swig_banner(f_begin_h);

    // TODO: is there any standard way to generate include guards in swig?
    Printf(f_begin_h, "\n\n#pragma once\n\n");



    Swig_banner(f_begin_kt);

    // TODO: get name from swig instead of hard-coding *_wrap
    Printv(f_begin_kt, "\n\nimport ", module, "_wrap.*\n\n", NIL);



    // emit code
    Language::top(n);


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

    return SWIG_OK;
  }

#undef NEW_FILE_CHECK


  virtual int functionWrapper(Node *n) {
    String   *name   = Getattr(n, "sym:name");
    SwigType *type   = Getattr(n, "type");
    ParmList *parms  = Getattr(n, "parms");

    Wrapper *wrapper = NewWrapper();
    String *wname = Swig_name_wrapper(name);
    String *parm_str = ParmList_str(parms);

    // C/C++
    Printv(wrapper->def, type, " ", wname, "(", parm_str, ") {", NIL);
    Printv(wrapper->code, "return ALL_OK;", NIL);
    Printv(wrapper->code, "}", NIL);

    Wrapper_print(wrapper, f_wrappers);
    DelWrapper(wrapper);


    // C/C++ Header
    Printv(f_wrappers_h, type, " ", wname, "(", parm_str, ");\n", NIL);


    // Kotlin
    Printv(f_wrappers_kt, "fun ", name, "() {\n", NIL);
    Printv(f_wrappers_kt, "  // TODO: call wrapper function\n", NIL);
    Printv(f_wrappers_kt, "}\n\n", NIL);

    Delete(wname);
    Delete(parm_str);

    return SWIG_OK;
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
