/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.cxx
 *
 * C language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_c_cxx[] = "$Id: c.cxx 10452 2008-05-15 21:16:48Z wsfulton $";

#include "swigmod.h"

class C:public Language {
  static const char *usage;

  File *f_runtime;
  File *f_runtime_h;
  File *f_header;
  File *f_wrappers;
  File *f_init;  

public:

  /* -----------------------------------------------------------------------------
   * C()
   * ----------------------------------------------------------------------------- */

   C() {
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("c");

    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGC 1", 0);

    // Add typemap definitions
    SWIG_typemap_lang("c");
    SWIG_config_file("c.swg");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i], "-help") == 0) {
          Printf(stdout, "%s\n", usage);
        }
      }
    }
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {
    Printf(stdout, "top called\n");

    String *module = Getattr(n, "name");
    String *outfile = Getattr(n, "outfile");

    /* initialize I/O */
    f_runtime = NewFile(outfile, "w");
    if (!f_runtime) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrappers", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    /* emit code for children */
    Language::top(n);

    /* write all to file */
    Dump(f_header, f_runtime);
    Dump(f_wrappers, f_runtime);
    Wrapper_pretty_print(f_init, f_runtime);

    /* cleanup */
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Close(f_runtime);
    Delete(f_runtime);

    return SWIG_OK;
  }

  virtual int functionWrapper(Node *n) {
    Printf(stdout, "creating function wrapper\n");
    String *name = Getattr(n, "sym:name");
    String *type = Getattr(n, "type");
    ParmList *parms = Getattr(n, "parms");
    String *wrapname = Getattr(n, "wrap:name");

    Wrapper *wrapper = NewWrapper();
    String *wname = Swig_name_wrapper(name);

    Setattr(n, "wrap:name", wname);

    String *parse_args = NewString("");
    Parm *parm;
    for (parm = parms; parm; ) {
      Append(parse_args, Getattr(parm, "type"));
      Append(parse_args, " ");
      Append(parse_args, Getattr(parm, "lname"));
      parm = nextSibling(parm);
      if (parm) {
        Append(parse_args, ", ");
      }
    }

    Printv(wrapper->def, type, " ", wname, "(", parse_args, ") {", NIL);
    Printv(wrapper->code, Getattr(n, "type"), " result;\n", NIL);
    Printv(wrapper->code, Getattr(n, "wrap:action"), "\n", NIL);
    Printv(wrapper->code, "return result;\n}\n", NIL);

    Wrapper_print(wrapper, f_wrappers);

    Delete(wname);
    DelWrapper(wrapper);

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

