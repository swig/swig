#include "swigmod.h"

class HHVM : public Language {
protected:
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;

public:
  virtual void main(int argc, char *argv[]) {
   // command line options to be added here ...

    SWIG_library_directory("hhvm");
    Preprocessor_define("SWIGHHVM 1", 0);
    SWIG_config_file("hhvm.swg");
    SWIG_typemap_lang("hhvm");
  }

  virtual int top(Node *n) {
    /* Get the module name */
    String *module = Getattr(n,"name");

    /* Get the output file name */
    String *outfile = Getattr(n,"outfile");

    /* Initialize I/O */
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

     /* Register file targets with the SWIG file handler */
     Swig_register_filebyname("begin", f_begin);
     Swig_register_filebyname("header", f_header);
     Swig_register_filebyname("wrapper", f_wrappers);
     Swig_register_filebyname("runtime", f_runtime);
     Swig_register_filebyname("init", f_init);

     /* Output module initialization code */
     Swig_banner(f_begin);
     //...

     /* Emit code for children */
     Language::top(n);

     //...
     /* Write all to the file */
     Dump(f_runtime, f_begin);
     Dump(f_header, f_begin);
     Dump(f_wrappers, f_begin);
     Wrapper_pretty_print(f_init, f_begin);

     /* Cleanup files */
     Delete(f_runtime);
     Delete(f_header);
     Delete(f_wrappers);
     Delete(f_init);
     Delete(f_begin);

    return SWIG_OK;
  }

  virtual int functionWrapper(Node *n) {
    /* Get some useful attributes of this function */
    String   *name   = Getattr(n,"sym:name");
    SwigType *type   = Getattr(n,"type");
    ParmList *parms  = Getattr(n,"parms");
    String   *parmstr= ParmList_str_defaultargs(parms); // to string
    String   *func   = SwigType_str(type, NewStringf("%s(%s)", name, parmstr));
    String   *action = Getattr(n,"wrap:action");

    Printf(f_wrappers,"functionWrapper   : %s\n", func);
    Printf(f_wrappers,"           action : %s\n", action);
    return SWIG_OK;
  }

};

extern "C" Language *
swig_hhvm(void) {
  return new HHVM();
}
