/*
 *
 * Swig Module for the Objective Caml language.
 *
 */

#include "swigmod.h"

class OCAML : public Language {

  public:
    virtual void main(int argc, char * argv[]);
    virtual int top(Node * n);

    // The following functions are used while passing through the
    // parse tree. They are responsible for doing the actual wrapping
    // to the target language.

    virtual int functionWrapper    (Node * n);
    virtual int classHandler       (Node * n);
    virtual int constructorHandler (Node * n);


  protected:
    // General DOH objects used for holding the strings
    // These strings are used for the C/C++ stub code.
    File * f_runtime;
    File * f_header;
    File * f_wrappers;
    File * f_init;

    // DOH objects for output to OCaml code
    File * f_mlcdecl;                 // File object for the import of the C declaration in the .ml module
    File * f_mlbody;                  // File object for the .ml code that will be exported
    File * f_mlout;                   // File object where .ml code will be concatenated and dumped
    File * f_mliout;                  // File object where .mli interface description is written

    String * f_mlbody_virtualclass;   // String object containing the OCaml virtual class declarations.
    String * f_mlbody_concreteclass;  // String object containing the OCaml "concrete" class declarations.

    // Objects used while delving into the parse tree.
    String * proxy_class_name;

    // Variables specifying the state of the parse tree parsing.
    int classmode;                    // classmode will determine whether or not
                                      // the code we are wrapping is relevant to a class
    int in_constructor;               // in_constructor will determine whether or
                                      // not we're dealing with a constructor...
    int constructor_number;           // first constructor has this value set at 0, and
                                      // we increment it for each constructor.

};

extern "C" Language *
swig_ocaml(void) {
  return new OCAML();
}

void OCAML::main(int argc, char * argv[]) {

  // Sets the name of the swig subfolder where swig will

  SWIG_library_directory("ocaml");

  // No command line options are yet implemented.
  // TODO: -noproxy and -help

  // Add a symbol to the parser for conditional compilation
  Preprocessor_define("SWIGOCAML 1", 0);

  // Add typemap definitions
  SWIG_typemap_lang("ocaml");
  SWIG_config_file("ocaml.swg");

  // TODO: We need to allow overloading at a later point in development.
  // allow_overloading();
}

int OCAML::top(Node * n) {

  // Initialisation of variables describing the status of the parse tree parsing.
  classmode = 0;
  in_constructor = 0;

  // Get the module name
  String * modulename = Getattr(n, "name");

  // Get the output filename
  String * outfile = Getattr(n, "outfile");

  // Initialise I/O - Initialise the all the output files.
  f_runtime = NewFile(outfile, "w", SWIG_output_files());
  if (!f_runtime) {
    FileErrorDisplay(outfile);
    SWIG_exit(EXIT_FAILURE);
  }
  f_init     = NewString("");
  f_header   = NewString("");
  f_wrappers = NewString("");
  f_mlcdecl  = NewString("");
  f_mlbody   = NewString("");

  // Register file targets with the SWIG file handler
  Swig_register_filebyname("header" , f_header  );
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("runtime", f_runtime );
  Swig_register_filebyname("init"   , f_init    );
  // OCaml-specific output file.
  Swig_register_filebyname("ml"     , f_mlbody  );
  Swig_register_filebyname("mlcdecl", f_mlcdecl );

  // Initialising OCaml-specific files
  String * mlfile = NewString("");
  Printv(mlfile, modulename, ".ml", NIL);
  String * ml_filename = NewStringf("%s%s", SWIG_output_directory(), mlfile);
  if (0 == (f_mlout = NewFile(ml_filename, "w", SWIG_output_files()))) {
    FileErrorDisplay(ml_filename);
    SWIG_exit(EXIT_FAILURE);
  }
  String * mlifile = NewString("");
  Printv(mlifile, modulename, ".mli", NIL);
  String * mli_filename = NewStringf("%s%s", SWIG_output_directory(), mlifile);
  if (0 == (f_mliout = NewFile(mli_filename, "w", SWIG_output_files()))) {
    FileErrorDisplay(mli_filename);
    SWIG_exit(EXIT_FAILURE);
  }

  // Initialising the OCaml submodule containing low-level access
  // to C wrapper functions and to low-level OCaml type declarations.
  // This OCaml submodule will be opaque to the end user.
  Printf(f_mlcdecl, "module Swig = struct\n\n");
  Printf(f_mlcdecl, "  (* The Swig module contains raw accessors to C functions,\n");
  Printf(f_mlcdecl, "     as well as type declarations enforcing sound typing. *)\n\n");

  // n contains the whole parse tree. This instruction is
  // the code iterating over the whole parse tree. Code for
  // Language::top is in the lang.cxx file. Flow of execution
  // goes from Language::top to Language::emit_children, and
  // then to Language::emit_one, where handlers are executed
  // for different elements of the parse tree... functions,
  // constants, classes, et ceterae.
  //
  //   swig -c++ -ocaml -debug-module 4 myinterface.i
  //
  // is a command that outputs the parse tree.

  Language::top(n);

  // Closing the OCaml submodule containing low-level C accessors
  // and low-level OCaml type declarations.

  Printf(f_mlcdecl, "\nend;;\n\n");

  // Write all to the file
  Dump                (f_header  , f_runtime);
  Dump                (f_wrappers, f_runtime);
  Wrapper_pretty_print(f_init    , f_runtime);

  // Cleanup files
  Delete(f_header  );
  Delete(f_wrappers);
  Delete(f_init    );
  Close (f_runtime );
  Delete(f_runtime );

  // Write and dump OCaml-specific files, cleanup.
  Dump   (f_mlcdecl, f_mlout);
  Dump   (f_mlbody,  f_mlout);
  Close  (f_mlout) ;
  Delete (f_mlout) ;
  Close  (f_mliout);
  Delete (f_mliout);

  return SWIG_OK;
}

///////////////////////////////////
// IMPLEMENTING FUNCTION WRAPPER //
///////////////////////////////////

int OCAML::functionWrapper (Node * n) {

  // Get some useful attributes of this function
  String   * name    = Getattr(n, "sym:name"   );
  String   * type    = Getattr(n, "type"       );
  ParmList * parms   = Getattr(n, "parms"      );

  // Conversion of parms to the string parmstr
  // ???
  //String   * parmstr = ParmList_str_defaultargs(parms);
  //String   * func    = SwigType_str(type, NewStringf("%s(%s)", name, parmstr));
  //String   * action  = Getattr(n, "wrap:action");

  // Declaration of the wrapper.
  Wrapper * f = NewWrapper();

  // Construction of the wrapper name.
  String * wrapper_name = Swig_name_wrapper(name);

  // Checking that the wrapper name doesn't conflict with another symbol.
  // YZIQUEL: Why is this there? Ask on the mailing list. OK, it's there
  // because we want to avoid conflicts, but what is Swig's policy, here?
  if (!addSymbol(name, n)) {
    DelWrapper(f);
    return SWIG_ERROR;
  }

  // Registering the wrapper name.
  Setattr(n, "wrap:name", wrapper_name);

  // Attach the non-standard typemaps to the parameter list.
  Swig_typemap_attach_parms("ocamlin", parms, f);


  // Trying to generate wrapper code.... No promise yet!

  // Documentation on wrapper objects can be found in
  // /usr/share/doc/swig-doc/Devel/wrapobj.html

  // Generating wrapper C declaration, without arguments...
  Printv(f->def, "extern \"C\" CAML_VALUE ", wrapper_name, " (", NIL);

  // Declaring the output return variable.
  Wrapper_add_local(f, "caml_result", "SWIG_CAMLlocal1(caml_result)");

  type = SwigType_typedef_qualified(type);

  // Emit all of the local variables for holding arguments.
  emit_parameter_variables(parms, f);

  // Attach the standard typemaps.
  emit_attach_parmmaps(parms, f);

  // Parameter overloading.
  Setattr(n, "wrap:parms", parms       );
  Setattr(n, "wrap:name" , wrapper_name);

  // Get the number of required and total arguments.
  int num_arguments = emit_num_arguments(parms);
  int num_required = emit_num_required(parms);

  // Placeholder strings for OCaml code - arguments and types for wrappers.
  String * ml_wrapper_argtypes = NewString("");
  String * ml_constructor_args = NewString("");

  // Now walk the function parameter list and generate code to get arguments.
  int gencomma = 0;
  Parm * p;
  int i;
  for (i = 0, p = parms; i < num_arguments; i++) {

    while (checkAttribute(p, "tmap:in:numinputs", "0")) {
      p = Getattr(p, "tmap:in:next");
    }

    SwigType * pt  = Getattr(p, "type" );
    String   * ln  = Getattr(p, "lname");
    String   * arg = NewString("");

    Printf(arg, "ocaml_%s", ln);

    // Writing the current argument in the wrapper function header.
    Printv(f->def, gencomma ? ", " : "", "CAML_VALUE ", arg, NIL);
    gencomma = 1;

    // Iteratively writing the strings for wrapper arguments on the OCaml side.
    Printv(ml_wrapper_argtypes, Getattr(p, "tmap:ocamlin"), " -> ", NIL);
    Printf(ml_constructor_args, " arg%d", i);

    // Declaring the input ocaml_arg_n, i.e. arg, value in the wrapper.
    String * caml_parameter_declaration = NewString("");
    Printf(caml_parameter_declaration, "CAMLparam1(%s)", arg);
    Wrapper_add_local(f, arg, caml_parameter_declaration);
    Delete(caml_parameter_declaration);

    String * tm;
    // Get the standard typemap for this argument
    if ((tm = Getattr(p, "tmap:in"))) {
      // Replaceall(tm, "$source", arg);          /* deprecated   */
      // Replaceall(tm, "$target", ln );          /* deprecated   */
      // Replaceall(tm, "$arg"   , arg);          /* deprecated ? */
      Replaceall(tm, "$input", arg);
      Setattr(p, "emit:input", arg);
      Printf(f->code, "%s\n", tm);
      p = Getattr(p, "tmap:in:next");
    } else {
      Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number,
        "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
      p = nextSibling(p);
    }

    Delete(arg);

  }
  Printf(f->def, ")\n{\n");

  // Now write code to make the function call.
  String * action_code = emit_action(n);

  // Return value if necessary.
  String * tm;
  if ((tm = Swig_typemap_lookup_out("out", n, "result", f, action_code)))
  {
    //Replaceall(tm, "$source", "result");          /* deprecated */
    //Replaceall(tm, "$target", "caml_result");     /* deprecated */
    Replaceall(tm, "$result", "caml_result");

    // The following line might be completely unnecessary, depending on
    // how garbage-collection is done...
    //Replaceall(tm, "$owner", (GetFlag(n, "feature:new")) ? "1" : "0");

    Printf(f->code, "%s", tm);
  } else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
      "Unable to use return type %s in function %s.\n",
      SwigType_str(type, 0), Getattr(n, "name"));
  }
  emit_return_variable(n, type, f);

  Printf(f->code, "\nCAMLreturn(caml_result);\n}");
  Wrapper_print(f, f_wrappers);

  // This switch is where we choose the OCaml-side wrapping behaviour, depending on
  // whether we are wrapping a raw C function, or a C++ function of a class.
  //
  // TODO: Make this switch exhaustive.

  if (classmode && in_constructor) {
    Printf(f_mlcdecl, "  external %s : %s%s = \"%s\"\n",
      wrapper_name, ml_wrapper_argtypes, proxy_class_name, wrapper_name);
    Printf(f_mlbody_concreteclass, "class %s_%d%s = object(self)\n",
      proxy_class_name, constructor_number, ml_constructor_args);
    Printf(f_mlbody_concreteclass, "  inherit %s\n", proxy_class_name);
    Printf(f_mlbody_concreteclass, "  val underlying_cpp_object = Swig.%s%s\n",
      wrapper_name, ml_constructor_args);
    Printf(f_mlbody_concreteclass, "end;;\n");
  } else if (classmode) {
    Printf(f_mlcdecl, "external %s : Obj.t * Obj.t -> Obj.t = \"%s\"\n", wrapper_name, wrapper_name);
    Printf(f_mlbody_virtualclass, "method %s x = Swig.%s (underlying_cpp_object, x)\n", name, wrapper_name);
  }

  // Cleaning up placeholder strings for args and types for OCaml code.
  Delete(ml_wrapper_argtypes);
  Delete(ml_constructor_args);

  return SWIG_OK;
}

////////////////////////////////
// IMPLEMENTING CLASS WRAPPER //
////////////////////////////////

int OCAML::classHandler (Node * n) {

  // Error handling if symbols/names collide.
  proxy_class_name = NewString(Getattr(n, "sym:name"));
  if (!addSymbol(proxy_class_name, n))
    return SWIG_ERROR;

  // OCaml submodule: low-level type declaration.
  // This declares the type of an OCaml-wrapped pointer
  // to a C++ object instantiated from this class.
  Printf(f_mlcdecl, "  type %s\n", proxy_class_name);

  // Initialisation of the String containing the virtual
  // and concrete class declarations.
  f_mlbody_virtualclass  = NewString("");
  f_mlbody_concreteclass = NewString("");
  Printf(f_mlbody_virtualclass, "class virtual %s = object(self)\n", proxy_class_name);
  Printf(f_mlbody_virtualclass, "  val virtual underlying_cpp_object : Swig.%s\n", proxy_class_name);
  Printf(f_mliout, "type %s = < >\n", proxy_class_name);

  // We are wrapping a class. Set classmode to true.
  classmode = true;

  // Concerning overloading, as overloading is not allowed in Objective Caml,
  // we count the number of constructors, to generate different class names.
  constructor_number = 0;

  // Recursing throughout the node's children.
  Language::classHandler(n);

  // We are not wrapping a class anymore. Set classmode
  // to false.
  classmode = false;

  // Finishing the virtual class declaration, and dumping
  // everything to f_mlbody.
  Printf(f_mlbody_virtualclass, "end;;\n");
  Printv(f_mlbody, f_mlbody_virtualclass, f_mlbody_concreteclass, NIL);
  Delete(f_mlbody_virtualclass);
  Delete(f_mlbody_concreteclass);

  return SWIG_OK;
}

// Basically, this handler's purpose is to toggle the
// in_constructor value on/off...
int OCAML::constructorHandler (Node * n) {
  int ret;
  in_constructor = true;
  ret = Language::constructorHandler(n);
  in_constructor = false;
  constructor_number++;
  return ret;
}
