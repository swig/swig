#include "swigmod.h"

class HHVM : public Language {
protected:
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_register;
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
    String *cap_module = NewStringf("%(upper)s", module);

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
    f_register = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    /* Output module initialization code */
    Swig_banner(f_header);

    Printf(f_header, "\n");
    Printf(f_header, "#include \"hphp/runtime/ext/extension.h\"\n");
    Printf(f_header, "#include \"hphp/runtime/base/execution-context.h\"\n");
    Printf(f_header, "#include \"hphp/runtime/vm/native-data.h\"\n");
    Printf(f_header, "\n");
    Printf(f_header, "namespace HPHP {\n");
    Printf(f_header, "\n");

    /* Emit code for children */
    Language::top(n);

    /* module extension class declaration */
    Printf(f_register, "class %sExtension : public Extension {\n", cap_module);
    Printf(f_register, "public:\n");

    /* TODO: Take extension version as input */ 
    Printf(f_register, "  %sExtension(): Extension(\"%s\", \"1.0\") {}\n\n", cap_module, module);
    Printf(f_register, "  void moduleInit() override {\n");
    
    /* All registrations go here */

    Printf(f_register, "    loadSystemlib();\n");
    Printf(f_register, "  }\n");
    Printf(f_register, "} s_%s_extension;\n\n", module);
    Printf(f_register, "HHVM_GET_MODULE(%s);\n\n", module);

    /* close namespace HPHP */
    Printf(f_register, "}");

    /* Write all to the file */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Dump(f_register, f_begin);
    Wrapper_pretty_print(f_init, f_begin);

     /* Cleanup files */
    Delete(f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_register);
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
