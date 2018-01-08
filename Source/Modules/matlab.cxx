/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * matlab.cxx
 *
 * Matlab language module for SWIG.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include "cparse.h"

static const char *usage = (char *) "\
Matlab Options (available with -matlab)\n\
     -opprefix <str> - Set global operator functions prefix to <str> [default: 'op_']\n\
     -pkgname <str>  - Set package name prefix to <str> [default: '<module>']\n\
     -mexname <name> - Set mex function name to <name> [default: '<module>MEX']\n\
\n";

class MATLAB:public Language {
public:
  MATLAB();
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int globalfunctionHandler(Node *n);
  virtual int variableWrapper(Node *n);
  virtual int constantWrapper(Node *n);
  virtual int nativeWrapper(Node *n);
  virtual int enumDeclaration(Node *n);
  virtual int enumvalueDeclaration(Node *n);
  virtual int classHandler(Node *n);
  virtual int memberfunctionHandler(Node *n);
  virtual int membervariableHandler(Node *n);
  virtual int constructorHandler(Node *n);
  virtual int destructorHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int memberconstantHandler(Node *n);
  virtual int staticmembervariableHandler(Node *n);
  virtual int insertDirective(Node *n);
  virtual int importDirective(Node *n);
  virtual String *runtimeCode();
  virtual String *defaultExternalRuntimeFilename();
  int classDirectorMethods(Node *n);
  int classDirectorMethod(Node *n, Node *parent, String *super);
  int classDirectorConstructor(Node *n);
  int classDirectorDefaultConstructor(Node *n);
  int classDirectorInit(Node *n);
  int classDirectorEnd(Node *n);
  int classDirectorDisown(Node *n);

protected:
  File *f_wrap_m;
  File *f_setup_m;
  File *f_gateway;
  File *f_constants;
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_doc;
  File *f_wrappers;
  File *f_init;
  File *f_initbeforefunc;
  File *f_directors;
  File *f_directors_h;
  File *f_runtime_h;
  String *class_name;
  String *mex_name;
  String *base_init;
  String *get_field;
  String *set_field;
  String *static_methods;

  // Current constant
  int con_id;

  // List of function names
  List *l_fnames;

  // List of constant names
  List *l_cnames;

  // List of dependent modules
  List *l_modules;

  bool have_constructor;
  bool have_destructor;
  //String *constructor_name;
  int num_gateway;
  int num_constant;

  int director_method_index;

  // Options
  String *op_prefix;
  String *pkg_name;
  String *pkg_name_fullpath;
  bool redirectoutput;
  int no_header_file;

  // Helper functions
  static void nameUnnamedParams(ParmList *parms, bool all);
  String *getOverloadedName(Node *n);
  void initGateway();
  int toGateway(String *fullname, String *wname);
  void finalizeGateway();
  void initConstant();
  int toConstant(String *constname, String *constdef);
  void finalizeConstant();
  void createSwigRef();
  void createSwigMem();
  void createSwigGet();
  void createSwigStorage();
  void autodoc_to_m(File *f, Node *n);
  void process_autodoc(Node *n);
  void make_autodocParmList(Node *n, String *decl_str, String *args_str);
  void addMissingParameterNames(ParmList *plist, int arg_offset);
  String *convertValue(String *v, SwigType *t);
  const char *get_implicitconv_flag(Node *n);
  void dispatchFunction(Node *n);
  static String *matlab_escape(String *_s);
  void wrapConstructor(int gw_ind, String *symname, String *fullname, Node *n);
  void wrapConstructorDirector(int gw_ind, String *symname, String *fullname, Node *n);
  int getRangeNumReturns(Node *n, int &max_num_returns, int &min_num_returns);
  void checkValidSymName(Node *node);
};

extern "C" Language *swig_matlab(void) {
  return new MATLAB();
}

// Only implementations from here on

MATLAB::MATLAB():
  f_wrap_m(0),
  f_setup_m(0),
  f_gateway(0),
  f_constants(0),
  f_begin(0),
  f_runtime(0),
  f_header(0),
  f_doc(0),
  f_wrappers(0),
  f_init(0),
  f_initbeforefunc(0),
  f_directors(0),
  f_directors_h(0),
  class_name(0),
  mex_name(0),
  base_init(0),
  get_field(0),
  set_field(0),
  static_methods(0),
  have_constructor(false),
  have_destructor(false),
  num_gateway(0),
  director_method_index(0),
  op_prefix(0),
  pkg_name(0),
  pkg_name_fullpath(0),
  no_header_file(0) {
  /* Add code to manage protected constructors and directors */
  director_prot_ctor_code = NewString("");
  Printv(director_prot_ctor_code,
	 "if ( argc==1 ) { /* subclassed */\n",
	 "  $director_new \n",
	 "} else {\n", "   mexErrMsgIdAndTxt(\"SWIG:RuntimeError\",\"accessing abstract class or protected constructor\"); \n", "  SWIG_fail;\n", "}\n", NIL);

  enable_cplus_runtime_mode();
  allow_overloading();
  director_multiple_inheritance = 1;
  director_language = 1;
}

void MATLAB::main(int argc, char *argv[]) {
  int cppcast = 1;
  redirectoutput = false;

  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i], "-help") == 0) {
	fputs(usage, stdout);
      } else if (strcmp(argv[i], "-opprefix") == 0) {
	if (argv[i + 1]) {
	  op_prefix = NewString(argv[i + 1]);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-cppcast") == 0) {
	cppcast = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-nocppcast") == 0) {
	cppcast = 0;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-noh") == 0) {
	no_header_file = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-pkgname") == 0) {
	if (argv[i + 1]) {
	  pkg_name = NewString(argv[i + 1]);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-mexname") == 0) {
	if (argv[i + 1]) {
	  mex_name = NewString(argv[i + 1]);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-redirectoutput") == 0) {
	redirectoutput = true;
	Swig_mark_arg(i);
      }
    }
  }

  if (!op_prefix) {
    op_prefix = NewString("op_");
  }

  SWIG_library_directory("matlab");
  Preprocessor_define("SWIGMATLAB 1", 0);
  if (cppcast) {
    Preprocessor_define((DOH *) "SWIG_CPLUSPLUS_CAST", 0);
  }
  SWIG_config_file("matlab.swg");
  SWIG_typemap_lang("matlab");
  allow_overloading();

  // Matlab API is C++, so output must be C++ compatibile even when wrapping C code
  //    if (!cparse_cplusplus)
  //      Swig_cparse_cplusplusout(1);
}

int MATLAB::top(Node *n) {
  {
    Node *mod = Getattr(n, "module");
    if (mod) {
      Node *options = Getattr(mod, "options");
      if (options) {
	int dirprot = 0;
	if (Getattr(options, "dirprot")) {
	  dirprot = 1;
	}
	if (Getattr(options, "nodirprot")) {
	  dirprot = 0;
	}
	if (Getattr(options, "directors")) {
	  allow_directors();
	  if (dirprot)
	    allow_dirprot();
	}
	// Set package name via module option if not set via command-line
	// Otherwise use module name as default (see below)
	if (!pkg_name && Getattr(options, "package")) {
	  pkg_name = Getattr(options, "package");
	}
	// Set mex name via module option if not set via command-line
	// Otherwise use module name as default (see below)
	if (!mex_name && Getattr(options, "mexname")) {
	  mex_name = Getattr(options, "mexname");
	}
      }
    }
  }

  /* Set comparison with none for ConstructorToFunction */
  setSubclassInstanceCheck(NewString("!mxIsNumeric($arg)"));

  // Create SwigRef base class
  createSwigRef();

  // Create SwigMem helper function
  createSwigMem();

  // Crete SwigGet helper function
  createSwigGet();

  String *module = Getattr(n, "name");
  String *outfile = Getattr(n, "outfile");


  /* Initialize all of the output files */
  String *outfile_h = !no_header_file ? Getattr(n, "outfile_h") : 0;

  // Add default package prefix
  if (!pkg_name) {
    pkg_name = Copy(module);
  }

  // List of dependent modules
  l_modules = NewList();

  // Create subdirectory
  String *pkg_directory_name = NewString("+");
  Append(pkg_directory_name, pkg_name);
  (void) Replace(pkg_directory_name, ".", "/+", DOH_REPLACE_ANY);
  pkg_name_fullpath = NewString("");
  Printf(pkg_name_fullpath, "%s%s", SWIG_output_directory(), pkg_directory_name);
  Swig_new_subdirectory((String *) SWIG_output_directory(), pkg_directory_name);

  // Create output (mex) file
  f_begin = NewFile(outfile, "w", SWIG_output_files());
  if (!f_begin) {
    FileErrorDisplay(outfile);
    SWIG_exit(EXIT_FAILURE);
  }

  /* The name of the compiled mex-wrapper is modulenameMEX by default, but this
     can be overridden by setting the mexname opion */
  if (!mex_name) {
    mex_name = NewString(module);
    Append(mex_name, "MEX");
  }

  f_gateway = NewString("");
  f_constants = NewString("");
  f_runtime = NewString("");
  f_header = NewString("");
  f_doc = NewString("");
  f_wrappers = NewString("");
  f_init = NewString("");
  f_initbeforefunc = NewString("");
  f_directors_h = NewString("");
  f_directors = NewString("");

  if (directorsEnabled()) {
    // Create SwigStorage helper function
    createSwigStorage();

    if (!no_header_file) {
      f_runtime_h = NewFile(outfile_h, "w", SWIG_output_files());
      if (!f_runtime_h) {
	FileErrorDisplay(outfile_h);
	SWIG_exit(EXIT_FAILURE);
      }
    } else {
      f_runtime_h = f_runtime;
    }
  }

  Swig_register_filebyname("gateway", f_gateway);
  Swig_register_filebyname("constants", f_constants);
  Swig_register_filebyname("begin", f_begin);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("header", f_header);
  Swig_register_filebyname("doc", f_doc);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("init", f_init);
  Swig_register_filebyname("initbeforefunc", f_initbeforefunc);
  Swig_register_filebyname("director", f_directors);
  Swig_register_filebyname("director_h", f_directors_h);

  Swig_banner(f_begin);

  Printf(f_runtime, "\n");
  Printf(f_runtime, "#define SWIGMATLAB\n");
  Printf(f_runtime, "#define SWIG_name_d      \"%s\"\n", module);
  Printf(f_runtime, "#define SWIG_name        %s\n", module);

  Printf(f_runtime, "\n");
  Printf(f_runtime, "#define SWIG_op_prefix        \"%s\"\n", op_prefix);
  Printf(f_runtime, "#define SWIG_pkg_name        \"%s\"\n", pkg_name);
  Printf(f_runtime, "#define SwigVar_mxArray mxArray*\n");
  if (directorsEnabled()) {
    Printf(f_runtime, "#define SWIG_DIRECTORS\n");
  }

  Printf(f_runtime, "\n");

  // Constant lookup
  initConstant();

  // Mex-file gateway
  initGateway();

  if (directorsEnabled()) {
    Swig_banner(f_directors_h);
    Printf(f_directors_h, "\n");
    Printf(f_directors_h, "#ifndef SWIG_%s_WRAP_H_\n", module);
    Printf(f_directors_h, "#define SWIG_%s_WRAP_H_\n\n", module);
    if (dirprot_mode()) {
      Printf(f_directors_h, "#include <map>\n");
      Printf(f_directors_h, "#include <string>\n\n");
    }

    Printf(f_directors, "\n\n");
    Printf(f_directors, "/* ---------------------------------------------------\n");
    Printf(f_directors, " * C++ director class methods\n");
    Printf(f_directors, " * --------------------------------------------------- */\n\n");
    if (outfile_h) {
      String *filename = Swig_file_filename(outfile_h);
      Printf(f_directors, "#include \"%s\"\n\n", filename);
      Delete(filename);
    }
  }


  /* Emit code for children */
  Language::top(n);

  // Finalize constant lookup
  finalizeConstant();

  // Finalize Mex-file gate way
  finalizeGateway();

  // Load dependent modules
  Iterator i = First(l_modules);
  if (i.item) {
    Printf(f_init, "mxArray *id = mxCreateDoubleScalar(double(4));\n");
    Printf(f_init, "int error;\n");
    Printf(f_init, "if (!id) mexErrMsgIdAndTxt(\"SWIG:RuntimeError\", \"Setup failed\");\n");
    for (; i.item; i = Next(i)) {
      Printf(f_init, "error = SWIG_Matlab_CallInterp(0, 0, 1, &id, \"%s\");\n", i.item);
      Printf(f_init, "if (error) mexErrMsgIdAndTxt(\"SWIG:RuntimeError\", \"Cannot initialize %s\");\n", i.item);
      Delete(i.item);
    }
    Printf(f_init, "mxDestroyArray(id);\n");
  }
  Delete(l_modules);

  /* Load this module */
  Printf(f_init, "SWIG_InitializeModule(0);\n\n");

  if (directorsEnabled()) {
    Swig_insert_file("director.swg", f_runtime);
  }

  /* Finish off our init function:
     we need to close the bracket of the initialisation function (LoadModule).
     This was left open such that any dynamic_cast variables are
     set inside that function (as those are set via %init in swig.swg, see macro
     DYNAMIC_CAST).
   */
  Printf(f_init, "}\n");

  SwigType_emit_type_table(f_runtime, f_wrappers);
  Dump(f_runtime, f_begin);
  Dump(f_header, f_begin);


  if (directorsEnabled()) {
    Dump(f_directors_h, f_runtime_h);
    Printf(f_runtime_h, "\n");
    Printf(f_runtime_h, "#endif\n");
    if (f_runtime_h != f_begin)
      Delete(f_runtime_h);
    Dump(f_directors, f_begin);
  }

  Dump(f_doc, f_begin);
  Dump(f_wrappers, f_begin);
  Dump(f_initbeforefunc, f_begin);
  Wrapper_pretty_print(f_init, f_begin);

  // Get constant name by index, internal
  Printf(f_begin, "\n");
  Printf(f_begin, "const char* swigConstantName_(int con_id) {\n");
  Printf(f_begin, "  switch (con_id) {\n");

  // Add cases and deallocate list
  int c = 0;
  for (i = First(l_cnames); i.item; i = Next(i)) {
    Printf(f_begin, "  case %d: return \"%s\";\n", c++, i.item);
    Delete(i.item);
  }
  Delete(l_cnames);

  // Default case
  Printf(f_begin, "  default: return 0;\n");
  Printf(f_begin, "  }\n");
  Printf(f_begin, "}\n");

  // Get constant name by index
  Printf(f_begin, "\n");
  Printf(f_begin, "int swigConstantName(int resc, mxArray *resv[], int argc, mxArray *argv[]) {\n");

  // The first argument is always the ID
  Printf(f_begin, "  if (argc!=1 || !mxIsDouble(*argv) || mxGetNumberOfElements(*argv)!=1) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"This mex file should only be called from "
	 "inside the .m files generated by SWIG. The input should be the constant ID.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");

  // Make sure one output
  Printf(f_begin, "  if (resc!=1) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"The function should have one output.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");

  // Get the string
  Printf(f_begin, "  int con_id = (int)mxGetScalar(*argv);\n");
  Printf(f_begin, "  const char* s = swigConstantName_(con_id);\n");

  // Make sure found
  Printf(f_begin, "  if (s==0) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"No such constant ID.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");

  // Return string
  Printf(f_begin, "  *resv = mxCreateString(s);\n");
  Printf(f_begin, "  return 0;\n");
  Printf(f_begin, "}\n\n");

  Dump(f_constants, f_begin);

  // Get function name by index, internal
  Printf(f_begin, "\n");
  Printf(f_begin, "const char* swigFunctionName_(int fcn_id) {\n");
  Printf(f_begin, "  switch(fcn_id) {\n");

  // Add cases and deallocate list
  c = 0;
  for (i = First(l_fnames); i.item; i = Next(i)) {
    Printf(f_begin, "  case %d: return \"%s\";\n", c++, i.item);
    Delete(i.item);
  }
  Delete(l_fnames);

  // Default case
  Printf(f_begin, "  default: return 0;\n");
  Printf(f_begin, "  }\n");
  Printf(f_begin, "}\n");

  // Get function name by index
  Printf(f_begin, "\n");
  Printf(f_begin, "int swigFunctionName(int resc, mxArray *resv[], int argc, mxArray *argv[]) {\n");

  // The first argument is always the ID
  Printf(f_begin, "  if (argc!=1 || !mxIsDouble(*argv) || mxGetNumberOfElements(*argv)!=1) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"This mex file should only be called from "
	 "inside the .m files generated by SWIG. The input should be the function ID.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");

  // Make sure one output
  Printf(f_begin, "  if (resc!=1) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"The function should have one output.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");

  // Get the string
  Printf(f_begin, "  int fcn_id = (int)mxGetScalar(*argv);\n");
  Printf(f_begin, "  const char* s = swigFunctionName_(fcn_id);\n");

  // Make sure found
  Printf(f_begin, "  if (s==0) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"No such function ID.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");

  // Return string
  Printf(f_begin, "  *resv = mxCreateString(s);\n");
  Printf(f_begin, "  return 0;\n");
  Printf(f_begin, "}\n\n");

  // Get memory
  Printf(f_begin, "int swigThis(int resc, mxArray *resv[], int argc, mxArray *argv[]) {\n");

  // Make sure only one input and max one output
  Printf(f_begin, "  if (argc!=1 || resc!=1) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"swigThis should have one input and one output.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");

  // Get the SwigPtr object
  Printf(f_begin, "  SwigPtr* swig_ptr = SWIG_Matlab_getSwigPtr(argv[0]);\n");
  Printf(f_begin, "  if (!swig_ptr) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"The argument should be a SWIG class.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");

  // Convert to uint64 and return
  Printf(f_begin, "  resv[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);\n");
  Printf(f_begin, "  *(uint64_T *)mxGetData(resv[0]) = (uint64_T)swig_ptr->ptr;\n");
  Printf(f_begin, "  return 0;\n");
  Printf(f_begin, "}\n\n");

  // Touch module
  Printf(f_begin, "int swigTouch(int resc, mxArray** /*resv*/, int argc, mxArray** /*argv*/) {\n");

  // Make sure no inputs or outputs
  Printf(f_begin, "  if (argc!=0 || resc!=0) {\n");
  Printf(f_begin, "    SWIG_Error(SWIG_RuntimeError, \"swigTouch should have no inputs or outputs.\");\n");
  Printf(f_begin, "    return 1;\n");
  Printf(f_begin, "  }\n");
  Printf(f_begin, "  return 0;\n");
  Printf(f_begin, "}\n\n");

  Dump(f_gateway, f_begin);

  Delete(f_initbeforefunc);
  Delete(f_init);
  Delete(f_wrappers);
  Delete(f_doc);
  Delete(f_header);
  Delete(f_directors);
  Delete(f_directors_h);
  Delete(f_runtime);
  Delete(f_begin);
  Delete(f_constants);
  Delete(f_gateway);
  Delete(pkg_name);
  Delete(pkg_name_fullpath);
  Delete(op_prefix);
  Delete(mex_name);

  return SWIG_OK;
}

void MATLAB::process_autodoc(Node *n) {
  String *str = Getattr(n, "feature:docstring");
  bool autodoc_enabled = !Cmp(Getattr(n, "feature:autodoc"), "1");
  Setattr(n, "matlab:synopsis", NewString(""));
  Setattr(n, "matlab:decl_info", NewString(""));
  Setattr(n, "matlab:cdecl_info", NewString(""));
  Setattr(n, "matlab:args_info", NewString(""));

  String *synopsis = Getattr(n, "matlab:synopsis");
  String *decl_info = Getattr(n, "matlab:decl_info");
  //    String *cdecl_info = Getattr(n, "matlab:cdecl_info");
  String *args_info = Getattr(n, "matlab:args_info");

  if (autodoc_enabled) {
    String *decl_str = NewString("");
    String *args_str = NewString("");
    make_autodocParmList(n, decl_str, args_str);
    Append(decl_info, "Usage: ");

    SwigType *type = Getattr(n, "type");
    if (type && Strcmp(type, "void")) {
      // TODO this is probably wrong. we need sym:name all the time
      // (currently reporting C++ name)
      Node *nn = classLookup(Getattr(n, "type"));
      String *type_str = nn ? Copy(Getattr(nn, "sym:name")) : SwigType_str(type, 0);
      Append(decl_info, "retval = ");
      Printf(args_str, "%sretval is of type %s. ", args_str, type_str);
      Delete(type_str);
    }

    Append(decl_info, Getattr(n, "sym:name"));
    Append(decl_info, " (");
    Append(decl_info, decl_str);
    Append(decl_info, ")\n");
    Append(args_info, args_str);
    Delete(decl_str);
    Delete(args_str);
  }

  if (str && Len(str) > 0) {
    // strip off {} if necessary
    char *t = Char(str);
    if (*t == '{') {
      Delitem(str, 0);
      Delitem(str, DOH_END);
    }

    // emit into synopsis section
    Append(synopsis, str);
  }
}


/* ------------------------------------------------------------
 * have_matlabprepend()
 *    Check if there is a %matlabprepend directive and it has text
 * ------------------------------------------------------------ */

bool have_matlabprepend(Node *n) {
  String *str = Getattr(n, "feature:matlabprepend");
  return (str && Len(str) > 0);
}

/* ------------------------------------------------------------
 * matlabprepend()
 *    Get the %matlabprepend code, stripping off {} if neccessary
 * ------------------------------------------------------------ */

String *matlabprepend(Node *n) {
  String *str = Getattr(n, "feature:matlabprepend");
  char *t = Char(str);
  if (*t == '{') {
    Delitem(str, 0);
    Delitem(str, DOH_END);
  }
  return str;
}

/* ------------------------------------------------------------
 * have_matlabappend()
 *    Check if there is a %matlabappend directive and it has text
 * ------------------------------------------------------------ */

bool have_matlabappend(Node *n) {
  String *str = Getattr(n, "feature:matlabappend");
  if (!str)
    str = Getattr(n, "feature:addtofunc");
  return (str && Len(str) > 0);
}

/* ------------------------------------------------------------
 * matlabappend()
 *    Get the %matlabappend code, stripping off {} if neccessary
 * ------------------------------------------------------------ */

String *matlabappend(Node *n) {
  String *str = Getattr(n, "feature:matlabappend");
  if (!str)
    str = Getattr(n, "feature:addtofunc");

  char *t = Char(str);
  if (*t == '{') {
    Delitem(str, 0);
    Delitem(str, DOH_END);
  }
  return str;
}

int MATLAB::importDirective(Node *n) {
  String *modname = Getattr(n, "module");

  if (modname) {
    // Find the module node for this imported module.  It should be the
    // first child but search just in case.
    Node *mod = firstChild(n);
    while (mod && Strcmp(nodeType(mod), "module") != 0)
      mod = nextSibling(mod);

    // If option mexname set for module, use instead
    Node *options = Getattr(mod, "options");
    String *import_mexname = options ? Getattr(options, "mexname") : 0;
    if (import_mexname == 0) {
      import_mexname = Copy(modname);
      Append(import_mexname, "MEX");
    }

    /* Add to list of modules to be imported */
    Append(l_modules, import_mexname);
  }
  return Language::importDirective(n);
}

// const char *get_implicitconv_flag(Node *n) {
//   int conv = 0;
//   if (n && GetFlag(n, "feature:implicitconv")) {
//     conv = 1;
//   }
//   return conv ? "SWIG_POINTER_IMPLICIT_CONV" : "0";
// }

void MATLAB::addMissingParameterNames(ParmList *plist, int arg_offset) {
  Parm *p = plist;
  int i = arg_offset;
  while (p) {
    if (!Getattr(p, "lname")) {
      String *pname = Swig_cparm_name(p, i);
      Delete(pname);
    }
    i++;
    p = nextSibling(p);
  }
}

void MATLAB::make_autodocParmList(Node *n, String *decl_str, String *args_str) {
  String *pdocs = 0;
  ParmList *plist = CopyParmList(Getattr(n, "parms"));
  Parm *p;
  Parm *pnext;
  int start_arg_num = is_wrapping_class() ? 1 : 0;

  addMissingParameterNames(plist, start_arg_num); // for $1_name substitutions done in Swig_typemap_attach_parms

  Swig_typemap_attach_parms("in", plist, 0);
  Swig_typemap_attach_parms("doc", plist, 0);

  for (p = plist; p; p = pnext) {

    String *tm = Getattr(p, "tmap:in");
    if (tm) {
      pnext = Getattr(p, "tmap:in:next");
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
	continue;
      }
    } else {
      pnext = nextSibling(p);
    }

    String *name = 0;
    String *type = 0;
    String *value = 0;
    String *pdoc = Getattr(p, "tmap:doc");
    if (pdoc) {
      name = Getattr(p, "tmap:doc:name");
      type = Getattr(p, "tmap:doc:type");
      value = Getattr(p, "tmap:doc:value");
    }

    // Note: the generated name should be consistent with that in kwnames[]
    name = name ? name : Getattr(p, "name");
    name = name ? name : Getattr(p, "lname");
    name = Swig_name_make(p, 0, name, 0, 0); // rename parameter if a keyword

    type = type ? type : Getattr(p, "type");
    value = value ? value : Getattr(p, "value");

    if (SwigType_isvarargs(type))
      break;

    String *tex_name = NewString("");
    if (name)
      Printf(tex_name, "%s", name);
    else
      Printf(tex_name, "?");

    if (Len(decl_str))
      Append(decl_str, ", ");
    Append(decl_str, tex_name);

    if (value) {
      String *new_value = convertValue(value, Getattr(p, "type"));
      if (new_value) {
	value = new_value;
      } else {
	Node *lookup = Swig_symbol_clookup(value, 0);
	if (lookup)
	  value = Getattr(lookup, "sym:name");
      }
      Printf(decl_str, " = %s", value);
    }

    Node *nn = classLookup(Getattr(p, "type"));
    String *type_str = nn ? Copy(Getattr(nn, "sym:name")) : SwigType_str(type, 0);
    Printf(args_str, "%s is of type %s. ", tex_name, type_str);

    Delete(type_str);
    Delete(tex_name);
    Delete(name);
  }
  if (pdocs)
    Setattr(n, "feature:pdocs", pdocs);
  Delete(plist);
}

String *MATLAB::convertValue(String *v, SwigType *t) {
  if (v && Len(v) > 0) {
    char fc = (Char(v))[0];
    if (('0' <= fc && fc <= '9') || '\'' == fc || '"' == fc) {
      /* number or string (or maybe NULL pointer) */
      if (SwigType_ispointer(t) && Strcmp(v, "0") == 0)
	return NewString("None");
      else
	return v;
    }
    if (Strcmp(v, "NULL") == 0 || Strcmp(v, "nullptr") == 0)
      return SwigType_ispointer(t) ? NewString("nil") : NewString("0");
    if (Strcmp(v, "true") == 0 || Strcmp(v, "TRUE") == 0)
      return NewString("true");
    if (Strcmp(v, "false") == 0 || Strcmp(v, "FALSE") == 0)
      return NewString("false");
  }
  return 0;
}

int MATLAB::functionWrapper(Node *n) {
  Parm *p;
  String *tm;
  int j;

  String *nodeType = Getattr(n, "nodeType");
  int constructor = (!Cmp(nodeType, "constructor"));
  int destructor = (!Cmp(nodeType, "destructor"));
  String *storage = Getattr(n, "storage");

  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");
  String *iname = Getattr(n, "sym:name");
  String *wname = Swig_name_wrapper(iname);
  String *overname = Copy(wname);
  SwigType *d = Getattr(n, "type");
  ParmList *l = Getattr(n, "parms");

  if (!overloaded && !addSymbol(iname, n))
    return SWIG_ERROR;

  if (overloaded)
    Append(overname, Getattr(n, "sym:overname"));

  Wrapper *f = NewWrapper();
  Printf(f->def, "int %s (int resc, mxArray *resv[], int argc, mxArray *argv[]) {", overname);

  emit_parameter_variables(l, f);
  emit_attach_parmmaps(l, f);
  Setattr(n, "wrap:parms", l);

  int num_arguments = emit_num_arguments(l);
  int num_required = emit_num_required(l);
  int varargs = emit_isvarargs(l);
  char source[64];

  if (destructor) {
    Append(f->code, "int is_owned;\n");
  }

  Printf(f->code, "if (!SWIG_check_num_args(\"%s\",argc,%i,%i,%i)) " "{\n SWIG_fail;\n }\n", iname, num_arguments, num_required, varargs);
  if (num_arguments == 0 && num_required == 0) {
    Printf(f->code, "(void)argv; // Unused variable\n");
  } else if (constructor && num_arguments == 1 && num_required == 1) {
    if (Cmp(storage, "explicit") == 0) {
      Node *parent = Swig_methodclass(n);
      if (GetFlag(parent, "feature:implicitconv")) {
	String *desc = NewStringf("SWIGTYPE%s", SwigType_manglestr(Getattr(n, "type")));
	Printf(f->code, "if (SWIG_CheckImplicit(%s)) SWIG_fail;\n", desc);
	Delete(desc);
      }
    }
  }
  // Check if owned here, before possibly disowning in the typemaps
  if (destructor) {
    Append(f->code, "is_owned = SWIG_Matlab_isOwned(argv[0]);\n");
  }

  for (j = 0, p = l; j < num_arguments; ++j) {
    while (checkAttribute(p, "tmap:in:numinputs", "0")) {
      p = Getattr(p, "tmap:in:next");
    }

    SwigType *pt = Getattr(p, "type");

    String *tm = Getattr(p, "tmap:in");
    if (tm) {
      if (!tm || checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = nextSibling(p);
	continue;
      }

      sprintf(source, "argv[%d]", j);
      Setattr(p, "emit:input", source);

      Replaceall(tm, "$source", Getattr(p, "emit:input"));
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Replaceall(tm, "$target", Getattr(p, "lname"));

      if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:in:disown"))) {
	Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
      } else {
	Replaceall(tm, "$disown", "0");
      }

      if (Getattr(p, "tmap:in:implicitconv")) {
	const char *convflag = "0";
	if (!Getattr(p, "hidden")) {
	  SwigType *ptype = Getattr(p, "type");
	  convflag = get_implicitconv_flag(classLookup(ptype));
	}
	Replaceall(tm, "$implicitconv", convflag);
	Setattr(p, "implicitconv", convflag);
      }

      String *getargs = NewString("");
      if (j >= num_required)
	Printf(getargs, "if (%d<argc) {\n%s\n}", j, tm);
      else
	Printv(getargs, tm, NIL);
      Printv(f->code, getargs, "\n", NIL);
      Delete(getargs);

      p = Getattr(p, "tmap:in:next");
      continue;
    } else {
      Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
      break;
    }
  }

  // Check for trailing varargs
  if (varargs) {
    if (p && (tm = Getattr(p, "tmap:in"))) {
      Replaceall(tm, "$input", "varargs");
      Printv(f->code, tm, "\n", NIL);
    }
  }

  // Insert constraint checking code
  for (p = l; p;) {
    if ((tm = Getattr(p, "tmap:check"))) {
      Replaceall(tm, "$target", Getattr(p, "lname"));
      Printv(f->code, tm, "\n", NIL);
      p = Getattr(p, "tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }

  // Insert cleanup code
  String *cleanup = NewString("");
  for (p = l; p;) {
    if ((tm = Getattr(p, "tmap:freearg"))) {
      if (Getattr(p, "tmap:freearg:implicitconv")) {
	const char *convflag = "0";
	if (!Getattr(p, "hidden")) {
	  SwigType *ptype = Getattr(p, "type");
	  convflag = get_implicitconv_flag(classLookup(ptype));
	}
	if (strcmp(convflag, "0") == 0) {
	  tm = 0;
	}
      }
      if (tm && (Len(tm) != 0)) {
	Replaceall(tm, "$source", Getattr(p, "lname"));
	Printv(cleanup, tm, "\n", NIL);
      }
      p = Getattr(p, "tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  // Total number of function outputs, including return value
  int num_returns = 1;

  // Insert argument output code
  String *outarg = NewString("");
  for (p = l; p;) {
    if ((tm = Getattr(p, "tmap:argout"))) {
      Replaceall(tm, "$source", Getattr(p, "lname"));
      Replaceall(tm, "$target", "if (--resc>=0) *resv++");
      Replaceall(tm, "$result", "if (--resc>=0) *resv++");
      Replaceall(tm, "$arg", Getattr(p, "emit:input"));
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Printv(outarg, tm, "\n", NIL);
      p = Getattr(p, "tmap:argout:next");
      num_returns++;
    } else {
      p = nextSibling(p);
    }
  }

  Setattr(n, "wrap:name", overname);

  /* See comments in Python module */
  int director_method = is_member_director(n) && !is_smart_pointer() && !destructor;
  if (director_method) {
    Wrapper_add_local(f, "director", "Swig::Director *director = 0");
    Append(f->code, "director = SWIG_DIRECTOR_CAST(arg1);\n");
    Wrapper_add_local(f, "upcall", "bool upcall = false");
    const char *self_parm = "argv[0]";
    Printf(f->code, "upcall = director;\n", self_parm);
  }

  /* Emit the function call */
  if (director_method) {
    Append(f->code, "try {\n");
  }

  Swig_director_emit_dynamic_cast(n, f);

  if (destructor) {
    Append(f->code, "if (is_owned) {\n");
  }
  String *actioncode = emit_action(n);
  if (destructor) {
    Append(actioncode, "}\n");
  }

  if (director_method) {
    Append(actioncode, "} catch (Swig::DirectorException&) {\n");
    Append(actioncode, "  SWIG_fail;\n");
    Append(actioncode, "}\n");
  }


  Wrapper_add_local(f, "_out", "mxArray * _out");

  // First output
  bool first_output = true;

  // Return the function value
  if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode))) {

    // Check if void return
    if (SwigType_issimple(d)) {
      String *typestr = SwigType_str(d, 0);
      if (Strcmp(typestr, "void") == 0)
	num_returns--;
      Delete(typestr);
    }

    Replaceall(tm, "$source", Swig_cresult_name());
    Replaceall(tm, "$target", "_out");
    Replaceall(tm, "$result", "_out");

    if (GetFlag(n, "feature:new"))
      Replaceall(tm, "$owner", "1");
    else
      Replaceall(tm, "$owner", "0");

    Printf(f->code, "%s\n", tm);

    if (constructor && Swig_directorclass(n)) {
      Printf(f->code, "if (!mxIsNumeric(arg1)) {\n");
      Printf(f->code, "SwigPtr* thisPtr = SWIG_Matlab_getSwigPtr(_out);\n");
      Printf(f->code, "SwigPtr* thatPtr = SWIG_Matlab_getSwigPtr(arg1);\n");
      Printf(f->code, "thisPtr->next = thatPtr;\n");
      Printf(f->code, "}\n");
    }
    if (first_output) {
      // If first output, store even if resc==0 (ans output)
      Printf(f->code, "if (_out) --resc, *resv++ = _out;\n");
      first_output = false;
    } else {
      // For subsequent outputs, store if the corresponding output exists, otherwise discard
      Printf(f->code, "if (_out && --resc>=0) *resv++ = _out;\n");
    }

    Delete(tm);
  } else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(d, 0), iname);
  }
  emit_return_variable(n, d, f);

  Printv(f->code, outarg, NIL);
  Printv(f->code, cleanup, NIL);

  if (GetFlag(n, "feature:new")) {
    if ((tm = Swig_typemap_lookup("newfree", n, Swig_cresult_name(), 0))) {
      Replaceall(tm, "$source", Swig_cresult_name());
      Printf(f->code, "%s\n", tm);
    }
  }

  if ((tm = Swig_typemap_lookup("ret", n, Swig_cresult_name(), 0))) {
    Replaceall(tm, "$source", Swig_cresult_name());
    Replaceall(tm, "$result", "_outv");
    Printf(f->code, "%s\n", tm);
    Delete(tm);
  }
  // Store the number of return values to the node
  String *num_returns_str = NewStringf("%d", num_returns);
  Setattr(n, "matlab:num_returns", num_returns_str);

  Printf(f->code, "return 0;\n");
  Printf(f->code, "fail:\n");
  Printv(f->code, cleanup, NIL);
  Printf(f->code, "return 1;\n");
  Printf(f->code, "}\n");

  /* Substitute the cleanup code */
  Replaceall(f->code, "$cleanup", cleanup);

  Replaceall(f->code, "$symname", iname);
  Wrapper_print(f, f_wrappers);
  DelWrapper(f);

  if (last_overload)
    dispatchFunction(n);

  Delete(overname);
  Delete(wname);
  Delete(cleanup);
  Delete(outarg);

  return SWIG_OK;
}

int MATLAB::globalfunctionHandler(Node *n) {
  // Emit C wrappers
  int flag = Language::globalfunctionHandler(n);
  if (flag != SWIG_OK)
    return flag;

  // Skip if inside class
  if (class_name)
    return flag;

  // Name of function
  String *symname = Getattr(n, "sym:name");

  // No MATLAB wrapper for the overloads
  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");
  if (overloaded && !last_overload)
    return flag;

  // Create MATLAB proxy
  String *mfile = NewString("");
  Printf(mfile, "%s/%s.m", pkg_name_fullpath, symname);
  if (f_wrap_m)
    SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m) {
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }
  // Add to function switch
  String *wname = Swig_name_wrapper(symname);
  int gw_ind = toGateway(wname, wname);

  // Add function to matlab proxy
  checkValidSymName(n);
  Printf(f_wrap_m, "function varargout = %s(varargin)\n", symname);
  autodoc_to_m(f_wrap_m, n);
  const char *varginstr = GetFlag(n, "feature:varargin") ? "varargin" : "varargin{:}";
  if (have_matlabprepend(n)) {
    Printf(f_wrap_m, "%s\n", matlabprepend(n));
  }
  if (GetFlag(n, "feature:optionalunpack")) {
    Printf(f_wrap_m, "  out = %s(%d, %s);\n", mex_name, gw_ind, varginstr);
    Printf(f_wrap_m, "  if nargout<=1\n");
    Printf(f_wrap_m, "    varargout{1}=out;\n");
    Printf(f_wrap_m, "  else\n");
    Printf(f_wrap_m, "    nargoutchk(length(out),length(out))\n");
    Printf(f_wrap_m, "    for i=1:nargout\n");
    Printf(f_wrap_m, "      varargout{i} = out(i);\n");
    Printf(f_wrap_m, "    end\n");
    Printf(f_wrap_m, "  end\n");
  } else {
    Printf(f_wrap_m, "  [varargout{1:nargout}] = %s(%d, %s);\n", mex_name, gw_ind, varginstr);
  }
  if (have_matlabappend(n))
    Printf(f_wrap_m, "%s\n", matlabappend(n));
  Printf(f_wrap_m, "end\n");

  Delete(wname);
  Delete(mfile);
  Delete(f_wrap_m);
  f_wrap_m = 0;
  return flag;
}

int MATLAB::variableWrapper(Node *n) {
  String *name = Getattr(n, "name");
  String *iname = Getattr(n, "sym:name");
  SwigType *t = Getattr(n, "type");

  if (!addSymbol(iname, n))
    return SWIG_ERROR;

  // Skip if inside class // FIXME(@jaeandersson) ignores varin, varout
  if (class_name)
    return Language::variableWrapper(n);

  // Name of variable
  checkValidSymName(n);

  // Create MATLAB proxy
  String *mfile = NewString("");
  Printf(mfile, "%s/%s.m", pkg_name_fullpath, iname);
  if (f_wrap_m)
    SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m) {
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }
  // Add getter function
  String *getname = Swig_name_get(NSPACE_TODO, iname);
  String *getwname = Swig_name_wrapper(getname);
  int gw_ind_get = toGateway(getname, getwname);

  // varout typemap
  String *tm;
  Wrapper *getf = NewWrapper();
  int addfail = 0;
  Setattr(n, "wrap:name", getname);
  Printf(getf->def, "SWIGINTERN int %s (int resc, mxArray *resv[], int argc, mxArray *argv[]) {", getwname);
  if ((tm = Swig_typemap_lookup("varout", n, name, 0))) {
    Replaceall(tm, "$source", name);
    Replaceall(tm, "$target", "resv[0]");
    Replaceall(tm, "$result", "resv[0]");
    addfail = emit_action_code(n, getf->code, tm);
    Delete(tm);
  } else {
    Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number, "Unable to read variable of type %s\n", SwigType_str(t, 0));
  }
  Append(getf->code, "  return 0;\n");
  if (addfail) {
    Append(getf->code, "fail:\n");
    Append(getf->code, "  return 1;\n");
  }
  Append(getf->code, "}\n");
  Wrapper_print(getf, f_wrappers);

  // Add getter/setter function
  if (!is_assignable(n)) {
    // Only getter
    if (!class_name) {
      Printf(f_wrap_m, "function v = %s()\n", iname);
      Printf(f_wrap_m, "  v = %s(%d);\n", mex_name, gw_ind_get);
      Printf(f_wrap_m, "end\n");
    }
  } else {
    // Add setter function
    String *setname = Swig_name_set(NSPACE_TODO, iname);
    String *setwname = Swig_name_wrapper(setname);
    int gw_ind_set = toGateway(setname, setwname);

    // varin typemap
    Wrapper *setf = NewWrapper();
    Setattr(n, "wrap:name", setname);
    Printf(setf->def, "SWIGINTERN int %s (int resc, mxArray *resv[], int argc, mxArray *argv[]) {", setwname);
    if ((tm = Swig_typemap_lookup("varin", n, name, 0))) {
      Replaceall(tm, "$source", "argv[0]");
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$input", "argv[0]");
      if (Getattr(n, "tmap:varin:implicitconv")) {
	Replaceall(tm, "$implicitconv", get_implicitconv_flag(n));
      }
      emit_action_code(n, setf->code, tm);
      Delete(tm);
    } else {
      Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number, "Unable to set variable of type %s.\n", SwigType_str(t, 0));
    }
    Printf(setf->code, "return 0;\n");
    Append(setf->code, "fail:\n");
    Printf(setf->code, "return 1;\n");
    Append(setf->code, "}\n");
    Wrapper_print(setf, f_wrappers);

    // Getter and setter
    if (!class_name) {
      Printf(f_wrap_m, "function varargout = %s(varargin)\n", iname);
      Printf(f_wrap_m, "  narginchk(0,1)\n");
      Printf(f_wrap_m, "  if nargin==0\n");
      Printf(f_wrap_m, "    nargoutchk(0,1)\n");
      Printf(f_wrap_m, "    varargout{1} = %s(%d);\n", mex_name, gw_ind_get);
      Printf(f_wrap_m, "  else\n");
      Printf(f_wrap_m, "    nargoutchk(0,0)\n");
      Printf(f_wrap_m, "    %s(%d,varargin{1});\n", mex_name, gw_ind_set);
      Printf(f_wrap_m, "  end\n");
      Printf(f_wrap_m, "end\n");
    }

    // Tidy up
    Delete(setname);
    Delete(setwname);
    DelWrapper(setf);
  }

  // Tidy up
  Delete(getname);
  Delete(getwname);
  Delete(mfile);
  Delete(f_wrap_m);
  DelWrapper(getf);
  f_wrap_m = 0;

  return SWIG_OK;
}

int MATLAB::constantWrapper(Node *n) {
  String *name = Getattr(n, "name");
  String *symname = Getattr(n, "sym:name");
  SwigType *type = Getattr(n, "type");
  String *rawval = Getattr(n, "rawval");
  String *value = rawval ? rawval : Getattr(n, "value");
  String *cppvalue = Getattr(n, "cppvalue");
  String *tm;

  if (!addSymbol(symname, n))
    return SWIG_ERROR;

  if (SwigType_type(type) == T_MPOINTER) {
    String *wname = Swig_name_wrapper(symname);
    String *str = SwigType_str(type, wname);
    Printf(f_header, "static %s = %s;\n", str, value);
    Delete(str);
    value = wname;
  }
  con_id = -1;
  if ((tm = Swig_typemap_lookup("constcode", n, name, 0))) {
    Replaceall(tm, "$source", value);
    Replaceall(tm, "$target", name);
    Replaceall(tm, "$value", CPlusPlus && cppvalue ? cppvalue : value);
    Replaceall(tm, "$nsname", symname);
    con_id = toConstant(symname, tm);
  } else {
    Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number, "Unsupported constant value.\n");
    return SWIG_NOWRAP;
  }

  if (!class_name) {
    // Create MATLAB proxy
    String *mfile = NewString("");
    Printf(mfile, "%s/%s.m", pkg_name_fullpath, symname);
    if (f_wrap_m)
      SWIG_exit(EXIT_FAILURE);
    f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
    if (!f_wrap_m) {
      FileErrorDisplay(mfile);
      SWIG_exit(EXIT_FAILURE);
    }
    // Add getter function
    checkValidSymName(n);
    Printf(f_wrap_m, "function v = %s()\n", symname);
    Printf(f_wrap_m, "  persistent vInitialized;\n");
    Printf(f_wrap_m, "  if isempty(vInitialized)\n");
    Printf(f_wrap_m, "    vInitialized = %s(0, %d);\n", mex_name, con_id);
    Printf(f_wrap_m, "  end\n");
    Printf(f_wrap_m, "  v = vInitialized;\n");
    Printf(f_wrap_m, "end\n");

    // Tidy up
    Delete(mfile);
    Delete(f_wrap_m);
    f_wrap_m = 0;
  }

  return SWIG_OK;
}

/* ------------------------------------------------------------
 * classDirectorConstructor()
 * ------------------------------------------------------------ */

int MATLAB::classDirectorConstructor(Node *n) {
  Node *parent = Getattr(n, "parentNode");
  String *sub = NewString("");
  String *decl = Getattr(n, "decl");
  String *supername = Swig_class_name(parent);
  String *classname = NewString("");
  Printf(classname, "SwigDirector_%s", supername);

  /* insert self parameter */
  Parm *p;
  ParmList *superparms = Getattr(n, "parms");
  ParmList *parms = CopyParmList(superparms);
  String *type = NewString("mxArray");
  SwigType_add_pointer(type);
  p = NewParm(type, NewString("self"), n);
  set_nextSibling(p, parms);
  parms = p;

  if (!Getattr(n, "defaultargs")) {
    /* constructor */
    {
      Wrapper *w = NewWrapper();
      String *call;
      String *basetype = Getattr(parent, "classtype");
      String *target = Swig_method_decl(0, decl, classname, parms, 0);
      call = Swig_csuperclass_call(0, basetype, superparms);
      Printf(w->def, "%s::%s: %s, Swig::Director(self) { \n", classname, target, call);
      Printf(w->def, "   SWIG_DIRECTOR_RGTR((%s *)this, this); \n", basetype);
      Printf(w->def, "   SWIG_Matlab_getSwigPtr(self);\n");
      Append(w->def, "}\n");
      Delete(target);
      Wrapper_print(w, f_directors);
      Delete(call);
      DelWrapper(w);
    }

    /* constructor header */
    {
      String *target = Swig_method_decl(0, decl, classname, parms, 1);
      Printf(f_directors_h, "    %s;\n", target);
      Delete(target);
    }
  }



  Delete(sub);
  Delete(classname);
  Delete(supername);
  Delete(parms);
  return Language::classDirectorConstructor(n);
}

/* ------------------------------------------------------------
 * classDirectorDefaultConstructor()
 * ------------------------------------------------------------ */

int MATLAB::classDirectorDefaultConstructor(Node *n) {
  String *classname = Swig_class_name(n);
  {
    Node *parent = Swig_methodclass(n);
    String *basetype = Getattr(parent, "classtype");
    Wrapper *w = NewWrapper();
    Printf(w->def, "SwigDirector_%s::SwigDirector_%s(mxArray* self) : Swig::Director(self) { \n", classname, classname);
    Printf(w->def, "   SWIG_DIRECTOR_RGTR((%s *)this, this); \n", basetype);
    Append(w->def, "}\n");
    Wrapper_print(w, f_directors);
    DelWrapper(w);
  }
  Printf(f_directors_h, "    SwigDirector_%s(mxArray* self);\n", classname);
  Delete(classname);
  return Language::classDirectorDefaultConstructor(n);
}


/* ------------------------------------------------------------
 * classDirectorInit()
 * ------------------------------------------------------------ */

int MATLAB::classDirectorInit(Node *n) {
  String *declaration = Swig_director_declaration(n);
  Printf(f_directors_h, "\n");
  Printf(f_directors_h, "%s\n", declaration);
  Printf(f_directors_h, "public:\n");
  Delete(declaration);
  return Language::classDirectorInit(n);
}

/* ------------------------------------------------------------
 * classDirectorEnd()
 * ------------------------------------------------------------ */

int MATLAB::classDirectorEnd(Node *n) {
  if (dirprot_mode()) {
    /*
      This implementation uses a std::map<std::string,int>.

      It should be possible to rewrite it using a more elegant way,
      like copying the Java approach for the 'override' array.

      But for now, this seems to be the least intrusive way.
    */
    Printf(f_directors_h, "\n");
    Printf(f_directors_h, "/* Internal director utilities */\n");
    Printf(f_directors_h, "public:\n");
    Printf(f_directors_h, "    bool swig_get_inner(const char *swig_protected_method_name) const {\n");
    Printf(f_directors_h, "      std::map<std::string, bool>::const_iterator iv = swig_inner.find(swig_protected_method_name);\n");
    Printf(f_directors_h, "      return (iv != swig_inner.end() ? iv->second : false);\n");
    Printf(f_directors_h, "    }\n");

    Printf(f_directors_h, "    void swig_set_inner(const char *swig_protected_method_name, bool val) const {\n");
    Printf(f_directors_h, "      swig_inner[swig_protected_method_name] = val;\n");
    Printf(f_directors_h, "    }\n");
    Printf(f_directors_h, "private:\n");
    Printf(f_directors_h, "    mutable std::map<std::string, bool> swig_inner;\n");

  }

  Printf(f_directors_h, "};\n\n");
  return Language::classDirectorEnd(n);
}


/* ------------------------------------------------------------
 * classDirectorDisown()
 * ------------------------------------------------------------ */

int MATLAB::classDirectorDisown(Node *n) {
  int result;
  Printf(f_directors_h, "\n");
  result = Language::classDirectorDisown(n);
  return result;
}

/* ---------------------------------------------------------------
 * classDirectorMethod()
 *
 * Emit a virtual director method to pass a method call on to the
 * underlying MATLAB object.
 *
 * ** Moved it here due to internal error on gcc-2.96 **
 * --------------------------------------------------------------- */
int MATLAB::classDirectorMethods(Node *n) {
  director_method_index = 0;
  return Language::classDirectorMethods(n);
}


int MATLAB::classDirectorMethod(Node *n, Node *parent, String *super) {
  int is_void = 0;
  int is_pointer = 0;
  String *decl = Getattr(n, "decl");
  String *name = Getattr(n, "name");
  String *classname = Getattr(parent, "sym:name");
  String *c_classname = Getattr(parent, "name");
  String *symname = Getattr(n, "sym:name");
  String *declaration = NewString("");
  ParmList *l = Getattr(n, "parms");
  Wrapper *w = NewWrapper();
  String *tm;
  String *wrap_args = NewString("");
  String *returntype = Getattr(n, "type");
  String *value = Getattr(n, "value");
  String *storage = Getattr(n, "storage");
  bool pure_virtual = false;
  int status = SWIG_OK;
  int idx;
  bool ignored_method = GetFlag(n, "feature:ignore") ? true : false;

  if (Cmp(storage, "virtual") == 0) {
    if (Cmp(value, "0") == 0) {
      pure_virtual = true;
    }
  }

  /* determine if the method returns a pointer */
  is_pointer = SwigType_ispointer_return(decl);
  is_void = (!Cmp(returntype, "void") && !is_pointer);

  /* virtual method definition */
  String *target;
  String *pclassname = NewStringf("SwigDirector_%s", classname);
  String *qualified_name = NewStringf("%s::%s", pclassname, name);
  SwigType *rtype = Getattr(n, "conversion_operator") ? 0 : Getattr(n, "classDirectorMethods:type");
  target = Swig_method_decl(rtype, decl, qualified_name, l, 0);
  Printf(w->def, "%s", target);
  Delete(qualified_name);
  Delete(target);
  /* header declaration */
  target = Swig_method_decl(rtype, decl, name, l, 1);
  Printf(declaration, "    virtual %s", target);
  Delete(target);

  // Get any exception classes in the throws typemap
  ParmList *throw_parm_list = 0;

  if ((throw_parm_list = Getattr(n, "throws")) || Getattr(n, "throw")) {
    Parm *p;
    int gencomma = 0;

    Append(w->def, " throw(");
    Append(declaration, " throw(");

    if (throw_parm_list)
      Swig_typemap_attach_parms("throws", throw_parm_list, 0);
    for (p = throw_parm_list; p; p = nextSibling(p)) {
      if (Getattr(p, "tmap:throws")) {
	if (gencomma++) {
	  Append(w->def, ", ");
	  Append(declaration, ", ");
	}
	String *str = SwigType_str(Getattr(p, "type"), 0);
	Append(w->def, str);
	Append(declaration, str);
	Delete(str);
      }
    }

    Append(w->def, ")");
    Append(declaration, ")");
  }

  Append(w->def, " {");
  Append(declaration, ";\n");

  /* declare method return value
   * if the return value is a reference or const reference, a specialized typemap must
   * handle it, including declaration of c_result ($result).
   */
  if (!is_void) {
    if (!(ignored_method && !pure_virtual)) {
      String *cres = SwigType_lstr(returntype, "c_result");
      Printf(w->code, "%s;\n", cres);
      Delete(cres);
    }
  }

  if (ignored_method) {
    if (!pure_virtual) {
      if (!is_void)
	Printf(w->code, "return ");
      String *super_call = Swig_method_call(super, l);
      Printf(w->code, "%s;\n", super_call);
      Delete(super_call);
    } else {
      Printf(w->code, "Swig::DirectorPureVirtualException::raise(\"Attempted to invoke pure virtual method %s::%s\");\n", SwigType_namestr(c_classname),
	     SwigType_namestr(name));
    }
  } else {
    /* attach typemaps to arguments (C/C++ -> MATLAB) */
    String *arglist = NewString("");
    String *parse_args = NewString("");

    Swig_director_parms_fixup(l);

    /* remove the wrapper 'w' since it was producing spurious temps */
    Swig_typemap_attach_parms("in", l, 0);
    Swig_typemap_attach_parms("directorin", l, 0);
    Swig_typemap_attach_parms("directorargout", l, w);

    Parm *p;
    char source[256];

    int outputs = 0;
    if (!is_void)
      outputs++;

    /* build argument list and type conversion string */
    idx = 0;
    p = l;
    int use_parse = 0;
    while (p) {
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
	continue;
      }

      /* old style?  caused segfaults without the p!=0 check
         in the for() condition, and seems dangerous in the
         while loop as well.
         while (Getattr(p, "tmap:ignore")) {
         p = Getattr(p, "tmap:ignore:next");
         }
       */

      if (Getattr(p, "tmap:directorargout") != 0)
	outputs++;

      String *pname = Getattr(p, "name");
      String *ptype = Getattr(p, "type");

      Putc(',', arglist);
      if ((tm = Getattr(p, "tmap:directorin")) != 0) {
	String *parse = Getattr(p, "tmap:directorin:parse");
	if (!parse) {
	  sprintf(source, "obj%d", idx++);
	  String *input = NewString(source);
	  Setattr(p, "emit:directorinput", input);
	  Replaceall(tm, "$input", input);
	  Delete(input);
	  Replaceall(tm, "$owner", "0");
	  /* Wrapper_add_localv(w, source, "SwigVar_mxArray", source, "= 0", NIL); */
	  Printv(wrap_args, "SwigVar_mxArray ", source, ";\n", NIL);

	  Printv(wrap_args, tm, "\n", NIL);
	  Printv(arglist, "(mxArray *)", source, NIL);
	  Putc('O', parse_args);
	} else {
	  use_parse = 1;
	  Append(parse_args, parse);
	  Setattr(p, "emit:directorinput", pname);
	  Replaceall(tm, "$input", pname);
	  Replaceall(tm, "$owner", "0");
	  if (Len(tm) == 0)
	    Append(tm, pname);
	  Append(arglist, tm);
	}
	p = Getattr(p, "tmap:directorin:next");
	continue;
      } else if (Cmp(ptype, "void")) {
	/* special handling for pointers to other C++ director classes.
	 * ideally this would be left to a typemap, but there is currently no
	 * way to selectively apply the dynamic_cast<> to classes that have
	 * directors.  in other words, the type "SwigDirector_$1_lname" only exists
	 * for classes with directors.  we avoid the problem here by checking
	 * module.wrap::directormap, but it's not clear how to get a typemap to
	 * do something similar.  perhaps a new default typemap (in addition
	 * to SWIGTYPE) called DIRECTORTYPE?
	 */
	if (SwigType_ispointer(ptype) || SwigType_isreference(ptype)) {
	  Node *module = Getattr(parent, "module");
	  Node *target = Swig_directormap(module, ptype);
	  sprintf(source, "obj%d", idx++);
	  String *nonconst = 0;
	  /* strip pointer/reference --- should move to Swig/stype.c */
	  String *nptype = NewString(Char(ptype) + 2);
	  /* name as pointer */
	  String *ppname = Copy(pname);
	  if (SwigType_isreference(ptype)) {
	    Insert(ppname, 0, "&");
	  }
	  /* if necessary, cast away const since MATLAB doesn't support it! */
	  if (SwigType_isconst(nptype)) {
	    nonconst = NewStringf("nc_tmp_%s", pname);
	    String *nonconst_i = NewStringf("= const_cast< %s >(%s)", SwigType_lstr(ptype, 0), ppname);
	    Wrapper_add_localv(w, nonconst, SwigType_lstr(ptype, 0), nonconst, nonconst_i, NIL);
	    Delete(nonconst_i);
	    Swig_warning(WARN_LANG_DISCARD_CONST, input_file, line_number,
			 "Target language argument '%s' discards const in director method %s::%s.\n",
			 SwigType_str(ptype, pname), SwigType_namestr(c_classname), SwigType_namestr(name));
	  } else {
	    nonconst = Copy(ppname);
	  }
	  Delete(nptype);
	  Delete(ppname);
	  String *mangle = SwigType_manglestr(ptype);
	  if (target) {
	    String *director = NewStringf("director_%s", mangle);
	    Wrapper_add_localv(w, director, "Swig::Director *", director, "= 0", NIL);
	    Wrapper_add_localv(w, source, "SwigVar_mxArray", source, "= 0", NIL);
	    Printf(wrap_args, "%s = SWIG_DIRECTOR_CAST(%s);\n", director, nonconst);
	    Printf(wrap_args, "if (!%s) {\n", director);
	    Printf(wrap_args, "%s = SWIG_InternalNewPointerObj(%s, SWIGTYPE%s, 0);\n", source, nonconst, mangle);
	    Append(wrap_args, "} else {\n");
	    Printf(wrap_args, "%s = %s->swig_get_self();\n", source, director);
	    Printf(wrap_args, "Py_INCREF((mxArray *)%s);\n", source);
	    Append(wrap_args, "}\n");
	    Delete(director);
	    Printv(arglist, source, NIL);
	  } else {
	    Wrapper_add_localv(w, source, "SwigVar_mxArray", source, "= 0", NIL);
	    Printf(wrap_args, "%s = SWIG_InternalNewPointerObj(%s, SWIGTYPE%s, 0);\n", source, nonconst, mangle);
	    //Printf(wrap_args, "%s = SWIG_NewPointerObj(%s, SWIGTYPE_p_%s, 0);\n",
	    //       source, nonconst, base);
	    Printv(arglist, source, NIL);
	  }
	  Putc('O', parse_args);
	  Delete(mangle);
	  Delete(nonconst);
	} else {
	  Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file, line_number,
		       "Unable to use type %s as a function argument in director method %s::%s (skipping method).\n", SwigType_str(ptype, 0),
		       SwigType_namestr(c_classname), SwigType_namestr(name));
	  status = SWIG_NOWRAP;
	  break;
	}
      }
      p = nextSibling(p);
    }

    /* wrap complex arguments to PyObjects */
    Printv(w->code, wrap_args, NIL);

    /* pass the method call on to the MATLAB object */
    if (dirprot_mode() && !is_public(n)) {
      Printf(w->code, "swig_set_inner(\"%s\", true);\n", name);
    }


    Append(w->code, "if (!swig_get_self()) {\n");
    Printf(w->code, "  Swig::DirectorException::raise(\"'self' uninitialized, maybe you forgot to call %s.__init__.\");\n", classname);
    Append(w->code, "}\n");
    if (Len(parse_args) > 0) {
      if (use_parse) {
      } else {
	Printf(w->code, "mxArray* dispatch_in[%d] = {swig_get_self()%s};\n", Len(parse_args) + 1, arglist);
	if (outputs) {
	  Printf(w->code, "mxArray* dispatch_out[%d];\n", outputs);
	  Printf(w->code, "mxArray* error = SWIG_Matlab_CallInterpEx(%d, dispatch_out, %d, dispatch_in, \"%s\");\n", outputs, Len(parse_args) + 1, symname);
	  Printf(w->code, "mxArray* %s = dispatch_out[0];\n", Swig_cresult_name());
	} else {
	  Printf(w->code, "mxArray* error = SWIG_Matlab_CallInterpEx(0, 0, %d, dispatch_in, \"%s\");\n", Len(parse_args) + 1, symname);
	}
      }
    } else {
      Printf(w->code, "mxArray* dispatch_in[1] = {swig_get_self()};\n");
      if (outputs) {
	Printf(w->code, "mxArray* dispatch_out[%d];\n", outputs);
	Printf(w->code, "mxArray* error = SWIG_Matlab_CallInterpEx(%d, dispatch_out, 1, dispatch_in, \"%s\");\n", outputs, symname);
	Printf(w->code, "mxArray* %s = dispatch_out[0];\n", Swig_cresult_name());
      } else {
	Printf(w->code, "mxArray* error = SWIG_Matlab_CallInterpEx(0, 0, 1, dispatch_in, \"%s\");\n", symname);
      }
    }
    // todo: destroy
    // todo: exception handling

    if (dirprot_mode() && !is_public(n))
      Printf(w->code, "swig_set_inner(\"%s\", false);\n", name);

    /* exception handling */
    tm = Swig_typemap_lookup("director:except", n, Swig_cresult_name(), 0);
    if (!tm) {
      tm = Getattr(n, "feature:director:except");
      if (tm)
	tm = Copy(tm);
    }
    Printf(w->code, "if (error != 0) {\n", Swig_cresult_name());
    Printf(w->code, "mexCallMATLAB(0, (mxArray **)NULL,1, &error, \"throw\");");

    if ((tm) && Len(tm) && (Strcmp(tm, "1") != 0)) {
      Replaceall(tm, "$error", "error");
      Printv(w->code, Str(tm), "\n", NIL);
    } else {
      Append(w->code, "  if (error) {\n");
      Printf(w->code, "    Swig::DirectorMethodException::raise(\"Error detected when calling '%s.%s'\");\n", classname, symname);
      Append(w->code, "  }\n");
    }
    Append(w->code, "}\n");
    Delete(tm);

    /*
     * MATLAB method may return a simple object, or a tuple.
     * for in/out aruments, we have to extract the appropriate PyObjects from the tuple,
     * then marshal everything back to C/C++ (return value and output arguments).
     *
     */

    /* marshal return value and other outputs (if any) from mxArray to C/C++ type */

    String *cleanup = NewString("");
    String *outarg = NewString("");

    if (outputs > 1) {
      Wrapper_add_local(w, "output", "mxArray *output");
      Printf(w->code, "if (!PyTuple_Check(%s)) {\n", Swig_cresult_name());
      Printf(w->code, "  Swig::DirectorTypeMismatchException::raise(\"MATLAB method %s.%sfailed to return a tuple.\");\n", classname, symname);
      Append(w->code, "}\n");
    }

    idx = 0;

    /* marshal return value */
    if (!is_void) {
      tm = Swig_typemap_lookup("directorout", n, Swig_cresult_name(), w);
      if (tm != 0) {
	if (outputs > 1) {
	  Printf(w->code, "output = PyTuple_GetItem(%s, %d);\n", Swig_cresult_name(), idx++);
	  Replaceall(tm, "$input", "output");
	} else {
	  Replaceall(tm, "$input", Swig_cresult_name());
	}
	char temp[24];
	sprintf(temp, "%d", idx);
	Replaceall(tm, "$argnum", temp);

	/* TODO check this */
	if (Getattr(n, "wrap:disown")) {
	  Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
	} else {
	  Replaceall(tm, "$disown", "0");
	}
	if (Getattr(n, "tmap:directorout:implicitconv")) {
	  Replaceall(tm, "$implicitconv", get_implicitconv_flag(n));
	}
	Replaceall(tm, "$result", "c_result");
	Printv(w->code, tm, "\n", NIL);
	Delete(tm);
      } else {
	Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number,
		     "Unable to use return type %s in director method %s::%s (skipping method).\n", SwigType_str(returntype, 0), SwigType_namestr(c_classname),
		     SwigType_namestr(name));
	status = SWIG_ERROR;
      }
    }

    /* marshal outputs */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:directorargout")) != 0) {
	if (outputs > 1) {
	  Printf(w->code, "output = PyTuple_GetItem(%s, %d);\n", Swig_cresult_name(), idx++);
	  Replaceall(tm, "$result", "output");
	} else {
	  Replaceall(tm, "$result", Swig_cresult_name());
	}
	Replaceall(tm, "$input", Getattr(p, "emit:directorinput"));
	Printv(w->code, tm, "\n", NIL);
	p = Getattr(p, "tmap:directorargout:next");
      } else {
	p = nextSibling(p);
      }
    }

    Delete(parse_args);
    Delete(arglist);
    Delete(cleanup);
    Delete(outarg);
  }

  if (!is_void) {
    if (!(ignored_method && !pure_virtual)) {
      String *rettype = SwigType_str(returntype, 0);
      if (!SwigType_isreference(returntype)) {
	Printf(w->code, "return (%s) c_result;\n", rettype);
      } else {
	Printf(w->code, "return (%s) *c_result;\n", rettype);
      }
      Delete(rettype);
    }
  }

  Append(w->code, "}\n");

  // We expose protected methods via an extra public inline method which makes a straight call to the wrapped class' method
  String *inline_extra_method = NewString("");
  if (dirprot_mode() && !is_public(n) && !pure_virtual) {
    Printv(inline_extra_method, declaration, NIL);
    String *extra_method_name = NewStringf("%sSwigPublic", name);
    Replaceall(inline_extra_method, name, extra_method_name);
    Replaceall(inline_extra_method, ";\n", " {\n      ");
    if (!is_void)
      Printf(inline_extra_method, "return ");
    String *methodcall = Swig_method_call(super, l);
    Printv(inline_extra_method, methodcall, ";\n    }\n", NIL);
    Delete(methodcall);
    Delete(extra_method_name);
  }

  /* emit the director method */
  if (status == SWIG_OK) {
    if (!Getattr(n, "defaultargs")) {
      Replaceall(w->code, "$symname", symname);
      Wrapper_print(w, f_directors);
      Printv(f_directors_h, declaration, NIL);
      Printv(f_directors_h, inline_extra_method, NIL);
    }
  }

  /* clean up */
  Delete(wrap_args);
  Delete(pclassname);
  DelWrapper(w);
  return status;
}

/* ----------------------------------------------------------------------------
 * END of C++ Director Class modifications
 * ------------------------------------------------------------------------- */


int MATLAB::nativeWrapper(Node *n) {
  return Language::nativeWrapper(n);
}

int MATLAB::enumDeclaration(Node *n) {
  return Language::enumDeclaration(n);
}

int MATLAB::enumvalueDeclaration(Node *n) {
  return Language::enumvalueDeclaration(n);
}

int MATLAB::classHandler(Node *n) {
  // Save current class name
  if (class_name)
    SWIG_exit(EXIT_FAILURE);
  class_name = Getattr(n, "sym:name");

  // Wrappers cannot be emitted
  static Hash *emitted = NewHash();
  String *mangled_classname = Swig_name_mangle(Getattr(n, "name"));
  if (Getattr(emitted, mangled_classname)) {
    Delete(mangled_classname);
    class_name = 0;
    return SWIG_NOWRAP;
  }
  Setattr(emitted, mangled_classname, "1");
  Delete(mangled_classname);

  // store class_name for use by NewPointerObj
  {
    // need to add quotes around class_name
    String *quoted_class_name = NewStringf("\"%s.%s\"", pkg_name, class_name);
    // different processing for smart or ordinary pointers
    String *smartptr = Getattr(n, "feature:smartptr");
    if (smartptr) {
      SwigType *spt = Swig_cparse_type(smartptr);
      SwigType *smart = SwigType_typedef_resolve_all(spt);
      SwigType_add_pointer(smart);
      SwigType_remember_clientdata(smart, quoted_class_name);
      Delete(spt);
      Delete(smart);
    } else {
      SwigType *t = Copy(Getattr(n, "name"));
      SwigType_add_pointer(t);
      SwigType_remember_clientdata(t, quoted_class_name);
      Delete(t);
    }
    Delete(quoted_class_name);
    Delete(smartptr);
  }
  // No destructor or constructor found yet
  have_constructor = false;
  have_destructor = false;

  // Name of wrapper .m file
  String *mfile = NewString("");
  Printf(mfile, "%s/%s.m", pkg_name_fullpath, class_name);

  // Create wrapper .m file
  if (f_wrap_m)
    SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m) {
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }

  // Declare MATLAB class
  Printf(f_wrap_m, "classdef %s < ", Getattr(n, "sym:name"));

  // Initialization of base classes
  base_init = NewString("");

  // Declare base classes, if any
  List *baselist = Getattr(n, "bases");
  int base_count = 0;
  if (baselist) {
    // Loop over base classes
    for (Iterator b = First(baselist); b.item; b = Next(b)) {
      // Get base class name, possibly ignore
#if 0
      // some prints for debugging
      {
	String *tmpname = Getattr(b.item, "name");
	if (tmpname)
	  Printf(stderr, "BASE %s\n", tmpname);
	tmpname = Getattr(b.item, "sym:name");
	if (tmpname)
	  Printf(stderr, "BASEsym %s\n", tmpname);
      }
#endif
      String *bname = Getattr(b.item, "sym:name");
      Node *bpkgNode = Getattr(b.item, "module");
      String *bpkg = Getattr(bpkgNode, "name");
      if (!bname || !bpkg || GetFlag(b.item, "feature:ignore"))
	continue;
      base_count++;

      // Separate multiple base classes with &
      if (base_count > 1)
	Printf(f_wrap_m, " & ");

      // Add to list of bases
      Printf(f_wrap_m, "%s.%s", bpkg, bname);

      // Add to initialization
      Printf(base_init, "      self@%s.%s(SwigRef.Null);\n", bpkg, bname);
    }
  }

  // Getters and setters for fields
  get_field = NewString("");
  set_field = NewString("");

  // Static methods
  static_methods = NewString("");

  // If no bases, top level class
  if (base_count == 0) {
    Printf(f_wrap_m, "SwigRef");
  }

  // End of class def
  Printf(f_wrap_m, "\n");

  // Emit documentation
  autodoc_to_m(f_wrap_m, n);

  // Declare class methods
  Printf(f_wrap_m, "  methods\n");

  // swig_this (not needed if defined in base class)
  if (base_count != 1) { // If >1 bases, need to define to avoid ambiguity
    Printf(f_wrap_m, "    function this = swig_this(self)\n");
    Printf(f_wrap_m, "      this = %s(3, self);\n", mex_name); // swigThis has index 3
    Printf(f_wrap_m, "    end\n");
  }

  // Emit member functions
  Language::classHandler(n);

  // Add constructor, if none added
  if (!have_constructor) {
    checkValidSymName(n);
    wrapConstructor(-1, class_name, 0, n);
    have_constructor = true;
  }

  // End of non-static methods
  Printf(f_wrap_m, "  end\n");

  // Add static methods
  Printf(f_wrap_m, "  methods(Static)\n");
  Printf(f_wrap_m, "%s", static_methods);
  Printf(f_wrap_m, "  end\n");

  // Finalize file
  Printf(f_wrap_m, "end\n");

  // Tidy up
  Delete(base_init);
  base_init = 0;
  Delete(f_wrap_m);
  f_wrap_m = 0;
  //note: don't Delete class_name as it's not a new object
  class_name = 0;
  Delete(mfile);
  Delete(get_field);
  get_field = 0;
  Delete(set_field);
  set_field = 0;
  Delete(static_methods);
  static_methods = 0;
  return SWIG_OK;
}

int MATLAB::memberfunctionHandler(Node *n) {
  // Emit C wrappers
  int flag = Language::memberfunctionHandler(n);
  if (flag != SWIG_OK)
    return flag;

  // No MATLAB wrapper for the overloads
  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");
  if (overloaded && !last_overload)
    return flag;

  // Add to function switch
  String *symname = Getattr(n, "sym:name");
  String *fullname = Swig_name_member(NSPACE_TODO, class_name, symname);
  String *wname = Swig_name_wrapper(fullname);
  int gw_ind = toGateway(fullname, wname);

  // Add function to .m wrapper
  checkValidSymName(n);
  const char *varginstr = GetFlag(n, "feature:varargin") ? "varargin" : "varargin{:}";
  Printf(f_wrap_m, "    function varargout = %s(self,varargin)\n", symname);
  autodoc_to_m(f_wrap_m, n);
  if (have_matlabprepend(n))
    Printf(f_wrap_m, "%s\n", matlabprepend(n));
  if (GetFlag(n, "feature:convertself") && checkAttribute(n, "qualifier", "q(const).")) {
    // explicit type conversion of self
    Printf(f_wrap_m, "      if ~isa(self,'%s.%s')\n", pkg_name, class_name);
    Printf(f_wrap_m, "        self = %s.%s(self);\n", pkg_name, class_name);
    Printf(f_wrap_m, "      end\n");
  }
  if (GetFlag(n, "feature:optionalunpack")) {
    Printf(f_wrap_m, "      out = %s(%d, self, %s);\n", mex_name, gw_ind, varginstr);
    Printf(f_wrap_m, "      if nargout<=1\n");
    Printf(f_wrap_m, "        varargout{1}=out;\n");
    Printf(f_wrap_m, "      else\n");
    Printf(f_wrap_m, "        nargoutchk(length(out),length(out))\n");
    Printf(f_wrap_m, "        for i=1:nargout\n");
    Printf(f_wrap_m, "          varargout{i} = out(i);\n");
    Printf(f_wrap_m, "        end\n");
    Printf(f_wrap_m, "      end\n");
  } else {
    Printf(f_wrap_m, "      [varargout{1:nargout}] = %s(%d, self, %s);\n", mex_name, gw_ind, varginstr);
  }
  if (have_matlabappend(n))
    Printf(f_wrap_m, "%s\n", matlabappend(n));
  Printf(f_wrap_m, "    end\n");
  Delete(wname);
  Delete(fullname);
  return flag;
}

void MATLAB::initGateway() {
  if (CPlusPlus)
    Printf(f_gateway, "extern \"C\"\n");
  Printf(f_gateway, "void mexFunction(int resc, mxArray *resv[], int argc, const mxArray *argv[]) {\n");

  // Load module if first call
  Printf(f_gateway, "  /* Initialize module if first call */\n");
  Printf(f_gateway, "  SWIG_Matlab_LoadModule();\n\n");

  // The first argument is always the ID
  Printf(f_gateway, "  if (--argc < 0 || !mxIsDouble(*argv) || mxGetNumberOfElements(*argv)!=1)\n");
  Printf(f_gateway,
	 "    mexErrMsgTxt(\"This mex file should only be called from inside the .m files generated by SWIG. First input should be the function ID .\");\n");
  Printf(f_gateway, "  int fcn_id = (int)mxGetScalar(*argv++);\n");

  // Redirect std::cout and std::cerr to SWIG_Matlab_cout
  if (CPlusPlus && redirectoutput) {
    Printf(f_gateway, "  std::streambuf *cout_backup = std::cout.rdbuf(&swig::SWIG_Matlab_buf);\n");
    Printf(f_gateway, "  std::streambuf *cerr_backup = std::cerr.rdbuf(&swig::SWIG_Matlab_buf);\n");
  }
  // Begin the switch:
  Printf(f_gateway, "  int flag=0;\n");
  Printf(f_gateway, "  switch (fcn_id) {\n");

  // List of function names
  l_fnames = NewList();

  // Constants retrieval function has index 0
  String *fname = NewString("swigConstant");
  toGateway(fname, fname);
  Delete(fname);

  // Function name retrieval function has index 1
  fname = NewString("swigFunctionName");
  toGateway(fname, fname);
  Delete(fname);

  // Constant name retrieval function has index 2
  fname = NewString("swigConstantName");
  toGateway(fname, fname);
  Delete(fname);

  // Memory retrieval function has index 3
  fname = NewString("swigThis");
  toGateway(fname, fname);
  Delete(fname);

  // Just touching the module (to load) has index 4
  fname = NewString("swigTouch");
  toGateway(fname, fname);
  Delete(fname);
}

int MATLAB::toGateway(String *fullname, String *wname) {
  // Keep list of all function names
  Append(l_fnames, Copy(fullname));

  // Add to gateway
  Printf(f_gateway, "  case %d: flag=%s(resc,resv,argc,(mxArray**)(argv)); break;\n", num_gateway, wname);
  return num_gateway++;
}

void MATLAB::finalizeGateway() {
  Printf(f_gateway, "  default: flag=1, SWIG_Error(SWIG_RuntimeError, \"No function id %%d.\", fcn_id);\n");
  Printf(f_gateway, "  }\n");

  // Restore std::cout and std::cerr
  if (CPlusPlus && redirectoutput) {
    Printf(f_gateway, "  std::cout.rdbuf(cout_backup);\n");
    Printf(f_gateway, "  std::cerr.rdbuf(cerr_backup);\n");
  }
  Printf(f_gateway, "  if (flag) {\n");
  Printf(f_gateway, "    mexErrMsgIdAndTxt(SWIG_ErrorType(SWIG_lasterror_code), SWIG_lasterror_msg);\n");
  Printf(f_gateway, "  }\n");
  Printf(f_gateway, "}\n");
}

void MATLAB::initConstant() {
  if (CPlusPlus)
    Printf(f_constants, "extern \"C\"\n");
  Printf(f_constants, "int swigConstant(int /*resc*/, mxArray *resv[], int argc, mxArray *argv[]) {\n");

  // The first argument is always the ID
  Printf(f_constants, "  if (--argc < 0 || !mxIsDouble(*argv) || mxGetNumberOfElements(*argv)!=1) {\n");
  Printf(f_constants,
	 "    SWIG_Error(SWIG_RuntimeError, \"This function should only be called from inside the .m files generated by SWIG. First input should be the constant ID .\");\n");
  Printf(f_constants, "    return 1;\n");
  Printf(f_constants, "  }\n");
  Printf(f_constants, "  int con_id = (int)mxGetScalar(*argv++);\n");

  // Begin the switch:
  Printf(f_constants, "  switch (con_id) {\n");

  // List of all constants
  l_cnames = NewList();
}

int MATLAB::toConstant(String *constname, String *constdef) {
  // Keep list of all constant names
  Append(l_cnames, Copy(constname));

  // Add to gateway
  Printf(f_constants, "  case %d: *resv = %s; break;\n", num_constant, constdef);
  return num_constant++;
}

void MATLAB::finalizeConstant() {
  Printf(f_constants, "  default:\n");
  Printf(f_constants, "    SWIG_Error(SWIG_RuntimeError, \"No such constant.\");\n");
  Printf(f_constants, "    return 1;\n");
  Printf(f_constants, "  }\n");
  if (num_constant == 0) {
    Printf(f_constants, "  (void)resv; // Unused variable\n");
  }
  Printf(f_constants, "  return 0;\n");
  Printf(f_constants, "}\n");
}

int MATLAB::membervariableHandler(Node *n) {
  // Name of variable
  checkValidSymName(n);
  String *symname = Getattr(n, "sym:name");

  // Add getter function
  String *getname = Swig_name_get(NSPACE_TODO, Swig_name_member(NSPACE_TODO, class_name, symname));
  String *getwname = Swig_name_wrapper(getname);
  int gw_ind_get = toGateway(getname, getwname);

  if (!is_assignable(n)) {
    // Only getter function
    Printf(f_wrap_m, "    function v = %s(self)\n", symname);
    Printf(f_wrap_m, "      v = %s(%d, self);\n", mex_name, gw_ind_get);
    Printf(f_wrap_m, "    end\n");
  } else {
    // Add setter function
    String *setname = Swig_name_set(NSPACE_TODO, Swig_name_member(NSPACE_TODO, class_name, symname));
    String *setwname = Swig_name_wrapper(setname);
    int gw_ind_set = toGateway(setname, setwname);

    // Getter and setter function
    Printf(f_wrap_m, "    function varargout = %s(self, varargin)\n", symname);
    Printf(f_wrap_m, "      narginchk(1, 2)\n");
    Printf(f_wrap_m, "      if nargin==1\n");
    Printf(f_wrap_m, "        nargoutchk(0, 1)\n");
    Printf(f_wrap_m, "        varargout{1} = %s(%d, self);\n", mex_name, gw_ind_get);
    Printf(f_wrap_m, "      else\n");
    Printf(f_wrap_m, "        nargoutchk(0, 0)\n");
    Printf(f_wrap_m, "        %s(%d, self, varargin{1});\n", mex_name, gw_ind_set);
    Printf(f_wrap_m, "      end\n");
    Printf(f_wrap_m, "    end\n");

    // Tidy up
    Delete(setname);
    Delete(setwname);
  }

  // Tidy up
  Delete(getname);
  Delete(getwname);

  return Language::membervariableHandler(n);
}

void MATLAB::wrapConstructor(int gw_ind, String *symname, String *fullname, Node *n) {
  Printf(f_wrap_m, "    function self = %s(varargin)\n", symname);
  Printf(f_wrap_m, "%s", base_init);
  Printf(f_wrap_m, "      if nargin==1 && strcmp(class(varargin{1}),'SwigRef')\n");
  Printf(f_wrap_m, "        if ~isnull(varargin{1})\n");
  Printf(f_wrap_m, "          self.swigPtr = varargin{1}.swigPtr;\n");
  Printf(f_wrap_m, "        end\n");
  Printf(f_wrap_m, "      else\n");
  if (fullname == 0) {
    Printf(f_wrap_m, "        error('No matching constructor');\n");
  } else {
    // How to get working on C side? Commented out, replaced by hack below
    // Printf(f_wrap_m,"        self.swigPtr = %s(%d, varargin{:});\n", mex_name, gw_ind);
    if (have_matlabprepend(n))
      Printf(f_wrap_m, "%s\n", matlabprepend(n));
    Printf(f_wrap_m, "        tmp = %s(%d, varargin{:});\n", mex_name, gw_ind);
    Printf(f_wrap_m, "        self.swigPtr = tmp.swigPtr;\n");
    Printf(f_wrap_m, "        tmp.swigPtr = [];\n");
    if (have_matlabappend(n))
      Printf(f_wrap_m, "%s\n", matlabappend(n));
  }
  Printf(f_wrap_m, "      end\n");
  Printf(f_wrap_m, "    end\n");
}

void MATLAB::wrapConstructorDirector(int gw_ind, String *symname, String *fullname, Node *n) {
  Printf(f_wrap_m, "    function self = %s(varargin)\n", symname);
  Printf(f_wrap_m, "%s", base_init);
  Printf(f_wrap_m, "      if nargin==1 && strcmp(class(varargin{1}),'SwigRef')\n");
  Printf(f_wrap_m, "        if ~isnull(varargin{1})\n");
  Printf(f_wrap_m, "          self.swigPtr = varargin{1}.swigPtr;\n");
  Printf(f_wrap_m, "        end\n");
  Printf(f_wrap_m, "      else\n");
  if (fullname == 0) {
    Printf(f_wrap_m, "        error('No matching constructor');\n");
  } else {
    // How to get working on C side? Commented out, replaed by hack below
    // Printf(f_wrap_m,"        self.swigPtr = %s(%d, varargin{:});\n", mex_name, gw_ind);
    if (have_matlabprepend(n))
      Printf(f_wrap_m, "%s\n", matlabprepend(n));
    Printf(f_wrap_m, "        if strcmp(class(self),'director_basic.%s')\n", symname);
    Printf(f_wrap_m, "          tmp = %s(%d, 0, varargin{:});\n", mex_name, gw_ind);
    Printf(f_wrap_m, "        else\n");
    Printf(f_wrap_m, "          tmp = %s(%d, self, varargin{:});\n", mex_name, gw_ind);
    Printf(f_wrap_m, "        end\n");
    Printf(f_wrap_m, "        self.swigPtr = tmp.swigPtr;\n");
    Printf(f_wrap_m, "        tmp.swigPtr = [];\n");
    if (have_matlabappend(n))
      Printf(f_wrap_m, "%s\n", matlabappend(n));
  }
  Printf(f_wrap_m, "      end\n");
  Printf(f_wrap_m, "    end\n");
}

int MATLAB::constructorHandler(Node *n) {
  have_constructor = true;
  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");
  int use_director = Swig_directorclass(n);

  if (!overloaded || last_overload) {
    // Add function to .m wrapper
    String *symname = Getattr(n, "sym:name");
    String *fullname = Swig_name_construct(NSPACE_TODO, symname);

    // Add to function switch
    String *wname = Swig_name_wrapper(fullname);
    int gw_ind = toGateway(fullname, wname);

    // Add to .m file
    checkValidSymName(n);
    if (use_director) {
      wrapConstructorDirector(gw_ind, symname, fullname, n);
    } else {
      wrapConstructor(gw_ind, symname, fullname, n);
    }

    Delete(wname);
    Delete(fullname);
  }

  if (use_director) {
    Parm *parms = Getattr(n, "parms");
    Parm *self;
    String *name = NewString("self");
    String *type = NewString("mxArray");
    SwigType_add_pointer(type);
    self = NewParm(type, name, n);
    Delete(type);
    Delete(name);
    Setattr(self, "lname", "O");
    if (parms)
      set_nextSibling(self, parms);
    Setattr(n, "parms", self);
    Setattr(n, "wrap:self", "1");
    Setattr(n, "hidden", "1");
    Delete(self);
  }


  return Language::constructorHandler(n);
}

int MATLAB::destructorHandler(Node *n) {
  have_destructor = true;
  Printf(f_wrap_m, "    function delete(self)\n");
  String *symname = Getattr(n, "sym:name");
  String *fullname = Swig_name_destroy(NSPACE_TODO, symname);

  // Add to function switch
  String *wname = Swig_name_wrapper(fullname);
  int gw_ind = toGateway(fullname, wname);
  Printf(f_wrap_m, "      if self.swigPtr\n");
  Printf(f_wrap_m, "        %s(%d, self);\n", mex_name, gw_ind);
  // Prevent that the object gets deleted another time.
  // This is important for MATLAB as for class hierarchies, it calls delete for
  // each class in the hierarchy. This isn't the case for C++ which only calls the
  // destructor of the "leaf-class", which should take care of deleting everything.
  Printf(f_wrap_m, "        self.swigPtr=[];\n");
  Printf(f_wrap_m, "      end\n");
  Printf(f_wrap_m, "    end\n");

  Delete(wname);
  Delete(fullname);

  return Language::destructorHandler(n);
}

int MATLAB::staticmemberfunctionHandler(Node *n) {
  // Emit C wrappers
  int flag = Language::staticmemberfunctionHandler(n);
  if (flag != SWIG_OK)
    return flag;

  // No MATLAB wrapper for the overloads
  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");
  if (overloaded && !last_overload)
    return flag;

  // Add to function switch
  String *symname = Getattr(n, "sym:name");
  String *fullname = Swig_name_member(NSPACE_TODO, class_name, symname);
  String *wname = Swig_name_wrapper(fullname);
  int gw_ind = toGateway(fullname, wname);

  // Add function to .m wrapper
  checkValidSymName(n);
  File *wrapper = GetFlag(n, "feature:nonstatic") ? f_wrap_m : static_methods;
  const char *varginstr = GetFlag(n, "feature:varargin") ? "varargin" : "varargin{:}";
  Printf(wrapper, "    function varargout = %s(varargin)\n", symname);
  autodoc_to_m(wrapper, n);
  if (have_matlabprepend(n)) {
    Printf(wrapper, "%s\n", Char(matlabprepend(n)));
  }
  if (GetFlag(n, "feature:optionalunpack")) {
    Printf(wrapper, "     out = %s(%d, %s);\n", mex_name, gw_ind, varginstr);
    Printf(wrapper, "     if nargout<=1\n");
    Printf(wrapper, "       varargout{1}=out;\n");
    Printf(wrapper, "     else\n");
    Printf(wrapper, "       nargoutchk(length(out),length(out))\n");
    Printf(wrapper, "       for i=1:nargout\n");
    Printf(wrapper, "         varargout{i} = out(i);\n");
    Printf(wrapper, "       end\n");
    Printf(wrapper, "     end\n");
  } else {
    Printf(wrapper, "     [varargout{1:nargout}] = %s(%d, %s);\n", mex_name, gw_ind, varginstr);
  }
  if (have_matlabappend(n)) {
    Printf(wrapper, "%s\n", Char(matlabappend(n)));
  }
  Printf(wrapper, "    end\n");
  Delete(wname);
  Delete(fullname);

  return flag;
}

int MATLAB::memberconstantHandler(Node *n) {
  // Emit C wrappers
  int flag = Language::memberconstantHandler(n);
  if (flag != SWIG_OK)
    return flag;

  // Name of variable
  String *symname = Getattr(n, "sym:name");

  // Get name of wrapper
  String *fullname = Swig_name_member(NSPACE_TODO, class_name, symname);

  // Add getter function
  checkValidSymName(n);
  Printf(static_methods, "    function v = %s()\n", symname);
  Printf(static_methods, "      persistent vInitialized;\n");
  Printf(static_methods, "      if isempty(vInitialized)\n");
  Printf(static_methods, "        vInitialized = %s(0, %d);\n", mex_name, con_id);
  Printf(static_methods, "      end\n");
  Printf(static_methods, "      v = vInitialized;\n");
  Printf(static_methods, "    end\n");

  // Tidy up
  Delete(fullname);

  return flag;
}

int MATLAB::insertDirective(Node *n) {
  String *code = Getattr(n, "code");
  String *section = Getattr(n, "section");

  if (Cmp(section, "matlab") == 0 && f_wrap_m) {
    Printv(f_wrap_m, code, NIL);
  } else if (Cmp(section, "matlabsetup") == 0) {
    Printv(f_setup_m, code, NIL);
  } else {
    Language::insertDirective(n);
  }

  return SWIG_OK;
}

int MATLAB::staticmembervariableHandler(Node *n) {
  // call Language implementation first, as this sets wrappedasconstant
  if (Language::staticmembervariableHandler(n) != SWIG_OK)
    return SWIG_ERROR;

  // Quick return if already wrapped
  if (GetFlag(n, "wrappedasconstant"))
    return SWIG_OK;

  // Name of variable
  checkValidSymName(n);
  String *symname = Getattr(n, "sym:name");

  // Add getter function
  String *getname = Swig_name_get(NSPACE_TODO, Swig_name_member(NSPACE_TODO, class_name, symname));
  String *getwname = Swig_name_wrapper(getname);
  int gw_ind_get = toGateway(getname, getwname);

  if (!is_assignable(n)) {
    // Only getter
    Printf(static_methods, "    function v = %s()\n", symname);
    if (have_matlabprepend(n))
      Printf(static_methods, "%s\n", Char(matlabprepend(n)));
    Printf(static_methods, "      v = %s(%d);\n", mex_name, gw_ind_get);
    if (have_matlabappend(n))
      Printv(static_methods, "%s\n", Char(matlabappend(n)));
    Printf(static_methods, "    end\n");
  } else {
    // Add setter function
    String *setname = Swig_name_set(NSPACE_TODO, Swig_name_member(NSPACE_TODO, class_name, symname));
    String *setwname = Swig_name_wrapper(setname);
    int gw_ind_set = toGateway(setname, setwname);

    // Getter and setter
    Printf(static_methods, "    function varargout = %s(varargin)\n", symname);
    Printf(static_methods, "      narginchk(0,1)\n");
    if (have_matlabprepend(n))
      Printf(static_methods, "%s\n", Char(matlabprepend(n)));
    Printf(static_methods, "      if nargin==0\n");
    Printf(static_methods, "        nargoutchk(0,1)\n");
    Printf(static_methods, "        varargout{1} = %s(%d);\n", mex_name, gw_ind_get);
    Printf(static_methods, "      else\n");
    Printf(static_methods, "        nargoutchk(0,0)\n");
    Printf(static_methods, "        %s(%d, varargin{1});\n", mex_name, gw_ind_set);
    Printf(static_methods, "      end\n");
    if (have_matlabappend(n))
      Printf(static_methods, "%s\n", Char(matlabappend(n)));
    Printf(static_methods, "    end\n");

    // Tidy up
    Delete(setname);
    Delete(setwname);
  }

  // Tidy up
  Delete(getname);
  Delete(getwname);

  return SWIG_OK;
}

/*
  this function names unnamed parameters

  Security by obscurity! If user chooses swig_par_name_2 as a parameter name
  for the first parameter and does not name the second one, boom.
*/
void MATLAB::nameUnnamedParams(ParmList *parms, bool all) {
  Parm *p;
  int i;
  for (p = parms, i = 1; p; p = nextSibling(p), i++) {
    if (all || !Getattr(p, "name")) {
      String *parname = NewStringf("swig_par_name_%d", i);
      Setattr(p, "name", parname);
    }

  }
}

String *MATLAB::getOverloadedName(Node *n) {
  String *overloaded_name = NewStringf("%s", Getattr(n, "sym:name"));
  if (Getattr(n, "sym:overloaded")) {
    Printv(overloaded_name, Getattr(n, "sym:overname"), NIL);
  }
  return overloaded_name;
}

void MATLAB::createSwigRef() {
  // Create file
  String *mfile = NewString(SWIG_output_directory());
  Append(mfile, "SwigRef.m");
  if (f_wrap_m)
    SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m) {
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }
  // Output SwigRef abstract base class
  Printf(f_wrap_m, "classdef SwigRef < handle\n");
  Printf(f_wrap_m, "  properties(Hidden = true, Access = public) \n");
  Printf(f_wrap_m, "    swigPtr\n");
  Printf(f_wrap_m, "  end\n");
  Printf(f_wrap_m, "  methods(Static = true, Access = protected)\n");
  Printf(f_wrap_m, "    function obj = Null()\n");
  Printf(f_wrap_m, "      persistent obj_null\n");
  Printf(f_wrap_m, "      if isempty(obj_null)\n");
  Printf(f_wrap_m, "        obj_null = SwigRef();\n");
  Printf(f_wrap_m, "      end\n");
  Printf(f_wrap_m, "      obj = obj_null;\n");
  Printf(f_wrap_m, "    end\n");
  Printf(f_wrap_m, "  end\n");
  Printf(f_wrap_m, "  methods\n");
  Printf(f_wrap_m, "    function out = saveobj(self)\n");
  Printf(f_wrap_m, "      error('Serializing SWIG objects not supported.')\n");
  Printf(f_wrap_m, "    end\n");
  Printf(f_wrap_m, "    function b = isnull(self)\n");
  Printf(f_wrap_m, "      b = isempty(self.swigPtr);\n");
  Printf(f_wrap_m, "    end\n");
  Printf(f_wrap_m, "    function SwigSet(self,ptr)\n");
  Printf(f_wrap_m, "        self.swigPtr = ptr;\n");
  Printf(f_wrap_m, "    end\n");
  Printf(f_wrap_m, "    function ptr = SwigGet(self)\n");
  Printf(f_wrap_m, "        ptr = self.swigPtr;\n");
  Printf(f_wrap_m, "    end\n");
  Printf(f_wrap_m, "  end\n");
  Printf(f_wrap_m, "end\n");

  // Tidy up
  Delete(f_wrap_m);
  Delete(mfile);
  f_wrap_m = 0;
}

void MATLAB::createSwigMem() {
  // Create file
  String *mfile = NewString(SWIG_output_directory());
  Append(mfile, "SwigMem.m");
  if (f_wrap_m)
    SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m) {
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }
  // Output SwigMem function
  Printf(f_wrap_m, "function varargout = SwigMem(varargin)\n");
  Printf(f_wrap_m, "  persistent mem\n");
  Printf(f_wrap_m, "  mlock\n");
  Printf(f_wrap_m, "  if (nargin > 1)\n");
  Printf(f_wrap_m, "    error('Too many input arguments')\n");
  Printf(f_wrap_m, "  end\n");
  Printf(f_wrap_m, "  if nargin==0\n");
  Printf(f_wrap_m, "    if (nargout > 1)\n");
  Printf(f_wrap_m, "      error('Too many output arguments')\n");
  Printf(f_wrap_m, "    end\n");
  Printf(f_wrap_m, "    varargout{1} = mem;\n");
  Printf(f_wrap_m, "  else\n");
  Printf(f_wrap_m, "    if (nargout > 0)\n");
  Printf(f_wrap_m, "      error('Too many output arguments')\n");
  Printf(f_wrap_m, "    end\n");
  Printf(f_wrap_m, "    mem = varargin{1};\n");
  Printf(f_wrap_m, "  end\n");
  Printf(f_wrap_m, "end\n");

  // Tidy up
  Delete(f_wrap_m);
  Delete(mfile);
  f_wrap_m = 0;
}

void MATLAB::createSwigGet() {
  // Create file
  String *mfile = NewString(SWIG_output_directory());
  Append(mfile, "SwigGet.m");
  if (f_wrap_m)
    SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m) {
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }
  // Output SwigMem function
  Printf(f_wrap_m, "function ptr = SwigGet(self)\n");
  Printf(f_wrap_m, "  ptr = [];\n");
  Printf(f_wrap_m, "end\n");

  // Tidy up
  Delete(f_wrap_m);
  Delete(mfile);
  f_wrap_m = 0;
}

void MATLAB::createSwigStorage() {
  // Create file
  String *mfile = NewString(SWIG_output_directory());
  Append(mfile, "SwigStorage.m");
  if (f_wrap_m)
    SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m) {
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }
  // Output SwigMem function
  Printf(f_wrap_m, "function varargout = SwigStorage(field, varargin)\n");
  Printf(f_wrap_m, "  persistent dir_mem\n");
  Printf(f_wrap_m, "  mlock\n");
  Printf(f_wrap_m, "  narginchk(1,2)\n");
  Printf(f_wrap_m, "  if isempty(dir_mem)\n");
  Printf(f_wrap_m, "    dir_mem = struct;\n");
  Printf(f_wrap_m, "  end\n");
  Printf(f_wrap_m, "  if nargin==1\n");
  Printf(f_wrap_m, "    nargoutchk(0,1)\n");
  Printf(f_wrap_m, "    varargout{1} = dir_mem.(field);\n");
  Printf(f_wrap_m, "  else\n");
  Printf(f_wrap_m, "    nargoutchk(0,0)\n");
  Printf(f_wrap_m, "    if isempty(varargin{1})\n");
  Printf(f_wrap_m, "      dir_mem = rmfield(dir_mem, field);\n");
  Printf(f_wrap_m, "    else\n");
  Printf(f_wrap_m, "      dir_mem.(field) = varargin{1};\n");
  Printf(f_wrap_m, "    end\n");
  Printf(f_wrap_m, "  end\n");
  Printf(f_wrap_m, "end\n");

  // Tidy up
  Delete(f_wrap_m);
  Delete(mfile);
  f_wrap_m = 0;
}

const char *MATLAB::get_implicitconv_flag(Node *n) {
  int conv = 0;
  if (n && GetFlag(n, "feature:implicitconv")) {
    conv = 1;
  }
  return conv ? "SWIG_POINTER_IMPLICIT_CONV" : "0";
}

void MATLAB::dispatchFunction(Node *n) {
  Wrapper *f = NewWrapper();

  String *iname = Getattr(n, "sym:name");
  String *wname = Swig_name_wrapper(iname);
  int maxargs;
  String *dispatch = Swig_overload_dispatch(n, "return %s(resc,resv,argc,argv);", &maxargs);
  String *tmp = NewString("");

  Node *sibl = n;
  while (Getattr(sibl, "sym:previousSibling"))
    sibl = Getattr(sibl, "sym:previousSibling"); // go all the way up
  String *protoTypes = NewString("");
  do {
    String *fulldecl = Swig_name_decl(sibl);
    Printf(protoTypes, "\n\"    %s\\n\"", fulldecl);
    Delete(fulldecl);
  } while ((sibl = Getattr(sibl, "sym:nextSibling")));

  Printf(f->def, "int %s (int resc, mxArray *resv[], int argc, mxArray *argv[]) {", wname);
  Printv(f->code, dispatch, "\n", NIL);
  Printf(f->code, "SWIG_Error(SWIG_RuntimeError, \"No matching function for overload function '%s'.\"\n", iname);
  Printf(f->code, "   \"  Possible C/C++ prototypes are:\\n\"%s);\n", protoTypes);
  Printf(f->code, "return 1;\n");
  Printv(f->code, "}\n", NIL);

  Wrapper_print(f, f_wrappers);
  Delete(tmp);
  DelWrapper(f);
  Delete(dispatch);
  Delete(wname);
}

// this function is used on autodoc strings
// it currently just appends "    %" after every explicit newline
String *MATLAB::matlab_escape(String *_s) {
  const char *s = (const char *) Data(_s);
  while (*s && (*s == '\t' || *s == '\r' || *s == '\n' || *s == ' '))
    ++s;
  String *r = NewString("");
  for (int j = 0; s[j]; ++j) {
    if (s[j] == '\n') {
      Append(r, "\n    %");
    } else
      Putc(s[j], r);
  }
  return r;
}

void MATLAB::autodoc_to_m(File *f, Node *n) {
  if (!n)
    return;
  process_autodoc(n);
  String *synopsis = Getattr(n, "matlab:synopsis");
  String *decl_info = Getattr(n, "matlab:decl_info");
  // String *cdecl_info = Getattr(n, "matlab:cdecl_info");
  String *args_info = Getattr(n, "matlab:args_info");

  if (Len(synopsis) > 0)
    Printf(f, "    %%%s\n", matlab_escape(synopsis));
  if (Len(decl_info) > 0)
    Printf(f, "    %%%s\n", matlab_escape(decl_info));
  // if (Len(cdecl_info)>0)
  //   Printf(f,"    %%%s\n", matlab_escape(cdecl_info));
  if (Len(args_info) > 0)
    Printf(f, "    %%%s\n", matlab_escape(args_info));
}

int MATLAB::getRangeNumReturns(Node *n, int &max_num_returns, int &min_num_returns) {
  bool overloaded = !!Getattr(n, "sym:overloaded");
  Node *n_overload = n;
  while (n_overload) {
    String *symname = Getattr(n_overload, "sym:name");
    if (symname == 0)
      return SWIG_ERROR;
    String *num_returns_str = Getattr(n_overload, "matlab:num_returns");
    if (num_returns_str == 0)
      return SWIG_ERROR;
    int num_returns = 0;
    sscanf(Char(num_returns_str), "%d", &num_returns);
    if (n == n_overload) {
      max_num_returns = min_num_returns = num_returns;
    } else {
      if (num_returns < min_num_returns)
	min_num_returns = num_returns;
      if (num_returns > max_num_returns)
	max_num_returns = num_returns;
    }
    if (!overloaded)
      break;
    n_overload = Getattr(n_overload, "sym:previousSibling");
  }
  return SWIG_OK;
}

void MATLAB::checkValidSymName(Node *node) {
  String *symname = Getattr(node, "sym:name");
  String *kind = Getattr(node, "kind");
  if (symname && !Strncmp(symname, "_", 1)) {
    Printf(stderr, "Warning: invalid MATLAB symbol '%s' (%s)\n"
	   "  Symbols may not start with '_'.  Maybe try something like this: %%rename(u%s) %s;\n", symname, kind, symname, symname);
  }
}

String *MATLAB::runtimeCode() {
  String *s = NewString("");
  String *srun = Swig_include_sys("matlabrun.swg");
  if (!srun) {
    Printf(stderr, "*** Unable to open 'matlabrun.swg'\n");
  } else {
    Append(s, srun);
    Delete(srun);
  }
  return s;
}

String *MATLAB::defaultExternalRuntimeFilename() {
  return NewString("swigmatlabrun.h");
}
