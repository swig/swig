/*
 *  OBJC.cxx
 *  Module file for Objective C support
 */

#include "swigmod.h"

class OBJC:public Language {
protected:
  static const char *usage;
  const String *empty_string;
  File *f_ll_h;
  File *f_ll_mm;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  String *objcpp_h_code;

  bool proxy_flag;		// Flag for generating proxy classes
  bool native_function_flag;	// Flag for when wrapping a native function

public:
   OBJC():empty_string(NewString("")),
      f_ll_h(NULL), f_ll_mm(NULL), f_runtime(NULL), f_header(NULL), f_wrappers(NULL), f_init(NULL), native_function_flag(false), objcpp_h_code(NULL) {
  } virtual void main(int argc, char *argv[]) {
    SWIG_library_directory("objc");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if ((strcmp(argv[i], "-noproxy") == 0)) {
	  Swig_mark_arg(i);
	  proxy_flag = false;
	} else if (strcmp(argv[i], "-help") == 0) {
	  Printf(stdout, "%s\n", usage);
	}
      }
    }

    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGOBJC 1", 0);

    // Add typemap definitions
    SWIG_typemap_lang("objc");
    SWIG_config_file("objc.swg");

    allow_overloading();
  }

  virtual int top(Node *n) {

    // Get the module name
    String *modulename = Getattr(n, "name");

    // Initialize all of the output files
    String *file_mm = NewStringf("%sWrapper.mm", modulename);
    f_ll_mm = NewFile(file_mm, "w", SWIG_output_files());
    if (!f_ll_mm) {
      FileErrorDisplay(f_ll_mm);
      SWIG_exit(EXIT_FAILURE);
    }

    String *file_h = NewStringf("%sWrapper.h", modulename);
    f_ll_h = NewFile(file_h, "w", SWIG_output_files());
    if (!f_ll_h) {
      FileErrorDisplay(f_ll_h);
      SWIG_exit(EXIT_FAILURE);
    }

    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    // Register file targets with the SWIG file handler
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    // Initialize members
    objcpp_h_code = NewString("");

    // Generate low level accessors
    Swig_banner(f_ll_h);

    Printf(f_runtime, "\n");
    Printf(f_runtime, "#define SWIGOBJC\n");
    Printf(f_runtime, "\n");

    Swig_name_register((char *) "wrapper", (char *) "ObjCPP_%f");

    Printf(f_ll_h, "\n#ifdef __cplusplus\n");
    Printf(f_ll_h, "extern \"C\" {\n");
    Printf(f_ll_h, "#endif\n\n");

    Printf(f_wrappers, "#include \"%s\"\n\n", file_h);
    Printf(f_wrappers, "extern \"C\" {\n");

    // Emit code for children
    Language::top(n);

    Printv(f_ll_h, objcpp_h_code, NIL);
    Printf(f_ll_h, "\n#ifdef __cplusplus\n");
    Printf(f_ll_h, "}\n");
    Printf(f_ll_h, "#endif\n");

    Printf(f_wrappers, "}\n");

    // Write all to the files
    Dump(f_header, f_ll_mm);
    Dump(f_wrappers, f_ll_mm);
    Wrapper_pretty_print(f_init, f_ll_mm);

    // Cleanup strings
    Delete(file_h);
    Delete(objcpp_h_code);
    objcpp_h_code = NULL;

    // Cleanup files
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Delete(f_runtime);
    Close(f_ll_mm);
    Delete(f_ll_mm);
    Close(f_ll_h);
    Delete(f_ll_h);
    return SWIG_OK;
  }

  virtual int nativeWrapper(Node *n) {
    String *wrapname = Getattr(n, "wrap:name");

    if (!addSymbol(wrapname, n))
      return SWIG_ERROR;

    if (Getattr(n, "type")) {
      Swig_save("nativeWrapper", n, "name", NIL);
      Setattr(n, "name", wrapname);
      native_function_flag = true;
      functionWrapper(n);
      Swig_restore(n);
      native_function_flag = false;
    } else {
      Printf(stderr, "%s : Line %d. No return type for %%native method %s.\n", input_file, line_number, Getattr(n, "wrap:name"));
    }

    return SWIG_OK;
  }

  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");

    String *objcpp_return_type = NewString("");
    String *tm;
    Parm *p;
    int i;
    int num_arguments = 0;
    int num_required = 0;
    bool is_void_return;

    Wrapper *f = NewWrapper();
    String *wname = Swig_name_wrapper(symname);

    Swig_typemap_attach_parms("ObjCpptype", l, f);

    if ((tm = Swig_typemap_lookup("ObjCpptype", n, "", 0))) {
      Printf(objcpp_return_type, "%s", tm);
    } else {
      // Display warning
    }

    is_void_return = (Cmp(objcpp_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f, "objcresult", objcpp_return_type, "objcresult", NIL);

    Printv(f->def, objcpp_return_type, " ", wname, "(", NIL);
    Printv(objcpp_h_code, objcpp_return_type, " ", wname, "(", NIL);

    // Emit all of the local variables for holding arguments.
    emit_parameter_variables(l, f);

    // Attach the standard typemaps
    emit_attach_parmmaps(l, f);

    // Parameter overloading
    Setattr(n, "wrap:parms", l);
    Setattr(n, "wrap:name", wname);

    // Get number of required and total arguments
    num_arguments = emit_num_arguments(l);
    num_required = emit_num_required(l);
    int gencomma = 0;

    // Now walk the function parameter list and generate code to get arguments
    for (i = 0, p = l; i < num_arguments; i++) {

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *ln = Getattr(p, "lname");
      String *objcpp_param_type = NewString("");
      String *arg = NewString("");

      Printf(arg, "objc%s", ln);

      // Get the ctype types of the parameter
      if ((tm = Getattr(p, "tmap:ObjCpptype"))) {
	Printv(objcpp_param_type, tm, NIL);
      } else {
	// Display warning
      }

      // Add parameter to the objcpp function
      Printv(f->def, gencomma ? ", " : "", objcpp_param_type, " ", arg, NIL);
      Printv(objcpp_h_code, gencomma ? ", " : "", objcpp_param_type, " ", arg, NIL);

      gencomma = 1;

      // Get typemap for this argument
      if ((tm = Getattr(p, "tmap:in"))) {
	Replaceall(tm, "$source", arg);	/* deprecated */
	Replaceall(tm, "$target", ln);	/* deprecated */
	Replaceall(tm, "$arg", arg);	/* deprecated? */
	Replaceall(tm, "$input", arg);
	Setattr(p, "emit:input", arg);
	Printf(f->code, "%s\n", tm);
	p = Getattr(p, "tmap:in:next");
      } else {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
	p = nextSibling(p);
      }
      Delete(objcpp_param_type);
      Delete(arg);
    }

    // Now write code to make the function call
    if (!native_function_flag) {
      String *actioncode = emit_action(n);

      // Return value if necessary
      if ((tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode))) {
	Replaceall(tm, "$source", "result");	/* deprecated */
	Replaceall(tm, "$target", "objcresult");	/* deprecated */
	Replaceall(tm, "$result", "objcresult");
	if (GetFlag(n, "feature:new"))
	  Replaceall(tm, "$owner", "1");
	else
	  Replaceall(tm, "$owner", "0");
	Printf(f->code, "%s", tm);
	if (Len(tm))
	  Printf(f->code, "\n");
      } else {
	Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(t, 0), Getattr(n, "name"));
      }
      emit_return_variable(n, t, f);
    }

    Printf(objcpp_h_code, ");\n");
    Printf(f->def, ") {");

    if (!is_void_return)
      Printv(f->code, "    return objcresult;\n", NIL);
    Printf(f->code, "}\n");

    // Dump the function out
    Wrapper_print(f, f_wrappers);

    // Tidy up
    Delete(objcpp_return_type);
    Delete(wname);
    DelWrapper(f);

    return SWIG_OK;
  }
};

/* -----------------------------------------------------------------------------
 * swig_objc()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_objc() {
  return new OBJC();
}

extern "C" Language *swig_objc() {
  return new_swig_objc();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *OBJC::usage = (char *) "\
Objective-C Options (available with -objc)\n\
-noproxy        - Generate the low-level functional interface instead\n\
of proxy classes\n\
\n";
