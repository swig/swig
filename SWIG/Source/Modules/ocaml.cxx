/* -*- c-indentation-style: gnu -*- */
/******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 *
 * Author : Art Yerkes
 * Modified from mzscheme.cxx : David Beazley
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *****************************************************************************/

char cvsroot_ocaml_cxx[] = "$Header$";

/***********************************************************************
 * $Header$
 *
 * ocaml.cxx
 *
 * Definitions for adding functions to Ocaml 101
 ***********************************************************************/

#include "swigmod.h"

#ifndef MACSWIG
#include "swigconfig.h"
#endif

#include <ctype.h>

static const char *usage = (char*)"\
\n\
Ocaml Options (available with -ocaml)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -prefix name    - Set a prefix to be appended to all names\n\
\n";

static int classmode = 0;
static int in_constructor = 0, in_destructor = 0, in_copyconst = 0;
static int const_enum = 0;
static int static_member_function = 0;
static char *prefix=0;
static String *classname=0;
static String *module=0;
static char *ocaml_path=(char*)"ocaml";
static String *init_func_def = 0;

static  Hash         *seen_enums = 0;
static  Hash         *seen_enumvalues = 0;
static  Hash         *seen_constructors = 0;

static  File         *f_header = 0;
static  File         *f_runtime = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;
static  File         *f_mlout = 0;
static  File         *f_mliout = 0;
static  File         *f_mlbody = 0;
static  File         *f_mlibody = 0;
static  File         *f_enumtypes_type = 0;
static  File         *f_enumtypes_value = 0;
static  File         *f_class_ctors = 0;
static  File         *f_class_ctors_end = 0;
static  File         *f_enum_to_int = 0;
static  File         *f_int_to_enum = 0;

class OCAML : public Language {
public:

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main (int argc, char *argv[]) {

    int i;
    
    prefix = 0;

    SWIG_library_directory(ocaml_path);
    
    // Look for certain command line options
    for (i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp (argv[i], "-help") == 0) {
	  fputs (usage, stderr);
	  SWIG_exit (0);
	} else if (strcmp (argv[i], "-prefix") == 0) {
	  if (argv[i + 1]) {
	    prefix = new char[strlen(argv[i + 1]) + 2];
	    strcpy(prefix, argv[i + 1]);
	    Swig_mark_arg (i);
	    Swig_mark_arg (i + 1);
	    i++;
	  } else {
	    Swig_arg_error();
	  }
	} else if (strcmp (argv[i], "-ldflags") == 0) {
	  printf("%s\n", SWIG_OCAML_RUNTIME);
	  SWIG_exit (EXIT_SUCCESS);
	}
      }
    }
    
    // If a prefix has been specified make sure it ends in a '_'
    
    if (prefix) {
      if (prefix[strlen (prefix)] != '_') {
	prefix[strlen (prefix) + 1] = 0;
	prefix[strlen (prefix)] = '_';
      }
    } else
      prefix = (char*)"swig_";
    
    // Add a symbol for this module
    
    Preprocessor_define ("SWIGOCAML 1",0);
    
    // Set name of typemaps
    
    SWIG_typemap_lang("ocaml");

    // Read in default typemaps */
    SWIG_config_file("ocaml.i");
    allow_overloading();

  }
  
  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */

  virtual int top(Node *n) {
    /* Initialize all of the output files */
    String *outfile = Getattr(n,"outfile");
    
    f_runtime = NewFile(outfile,"w");
    if (!f_runtime) {
      Printf(stderr,"*** Can't open '%s'\n", outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_enumtypes_type = NewString("");
    f_enumtypes_value = NewString("");
    f_mlbody = NewString("");
    f_mlibody = NewString("");
    f_class_ctors = NewString("");
    f_class_ctors_end = NewString("");
    f_enum_to_int = NewString("");
    f_int_to_enum = NewString("");

    module = Getattr(n,"name");

    seen_constructors = NewHash();
    seen_enums = NewHash();
    seen_enumvalues = NewHash();
    
    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header",f_header);
    Swig_register_filebyname("wrapper",f_wrappers);
    Swig_register_filebyname("runtime",f_runtime);
    Swig_register_filebyname("mli",f_mlibody);
    Swig_register_filebyname("ml",f_mlbody);
    
    init_func_def = NewString("");
    Swig_register_filebyname("init",init_func_def);

    Swig_name_register("set","%v__set__");
    Swig_name_register("get","%v__get__");
    
    Printf(f_runtime, 
	   "/* -*- buffer-read-only: t -*- vi: set ro: */\n");
    Printf( f_runtime, "#define SWIG_MODULE \"%s\"\n", module );
    /* Module name */
    Printf( f_mlbody, "let module_name = \"%s\"\n", module );
    Printf( f_mlibody, "val module_name : string\n" );
    Printf( f_enum_to_int, 
	    "let enum_to_int x v =\n"
	    "  match v with C_enum y -> (\n"
	    "  match (x : c_enum_type) with\n"
	    "   `unknown -> (match (y : c_enum_tag) with\n"
	    "     `int (x : int) -> C_int x\n"
	    "   | _ -> (raise (LabelNotFromThisEnum v)))\n"
	    );

    Printf( f_int_to_enum,
	    "let int_to_enum x y =\n"
	    "    match (x : c_enum_type) with\n"
	    "      `unknown -> C_enum (`int y)\n" );

    Swig_banner (f_runtime);
    
    if (NoInclude) {
      Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
    }

    /* Produce the enum_to_int and int_to_enum functions */
    
    Printf(f_enumtypes_type,"type c_enum_type = [ \n  `unknown\n" );
    Printf(f_enumtypes_value,"type c_enum_tag = [ \n  `int of int\n" );
    
    String *mlfile = NewString("");
    String *mlifile = NewString("");

    Printv(mlfile,module,".ml",NIL);
    Printv(mlifile,module,".mli",NIL);

	String *mlfilen = NewStringf("%s%s", Swig_file_dirname(outfile),mlfile);
	if ((f_mlout = NewFile(mlfilen,"w")) == 0) {
		Printf(stderr,"Unable to open %s\n", mlfilen);
		SWIG_exit (EXIT_FAILURE);
	}
	String *mlifilen = NewStringf("%s%s", Swig_file_dirname(outfile),mlifile);
	if ((f_mliout = NewFile(mlifilen,"w")) == 0) {
		Printf(stderr,"Unable to open %s\n", mlifilen);
		SWIG_exit (EXIT_FAILURE);
	}

    Language::top(n);

    Printf( f_enum_to_int, 
	    ") | _ -> (C_int (get_int v))\n"
	    "let _ = Callback.register \"%s_enum_to_int\" enum_to_int\n", 
	    module );
    Printf( f_mlibody, 
	    "val enum_to_int : c_enum_type -> c_obj -> c_obj\n" );

    Printf( f_int_to_enum,
	    "let _ = Callback.register \"%s_int_to_enum\" int_to_enum\n",
	    module );
    Printf( f_mlibody,
	    "val int_to_enum : c_enum_type -> int -> c_obj\n" );
    Printf( f_enumtypes_type, "]\n" );
    Printf( f_enumtypes_value, "]\n" );

    SwigType_emit_type_table (f_runtime, f_wrappers);
    /* Close all of the files */
    Dump(f_header,f_runtime);
    Dump(f_wrappers,f_runtime);
    Wrapper_pretty_print(f_init,f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Close(f_runtime);
    Delete(f_runtime);

    Dump(f_enumtypes_type,f_mlout);
    Dump(f_enumtypes_value,f_mlout);
    Dump(f_mlbody,f_mlout);
    Dump(f_enum_to_int,f_mlout);
    Dump(f_int_to_enum,f_mlout);
    Delete(f_int_to_enum);
    Delete(f_enum_to_int);
    Dump(f_class_ctors,f_mlout);
    Dump(f_class_ctors_end,f_mlout);
    Close(f_mlout);
    Delete(f_mlout);

    Dump(f_enumtypes_type,f_mliout);
    Dump(f_enumtypes_value,f_mliout);
    Dump(f_mlibody,f_mliout);
    Close(f_mliout);
    Delete(f_mliout);

    return SWIG_OK;
  }
  
  /* ------------------------------------------------------------
   * functionWrapper()
   * Create a function declaration and register it with the interpreter.
   * ------------------------------------------------------------ */

  void throw_unhandled_ocaml_type_error (SwigType *d)
  {
    Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		 "Unable to handle type %s.\n", SwigType_str(d,0));
  }

  /* Return true iff T is a pointer type */

  int
  is_a_pointer (SwigType *t)
  {
    return SwigType_ispointer(SwigType_typedef_resolve_all(t));
  }

  void oc_SwigType_del_reference(SwigType *t) {
  char *c = Char(t);
  if (strncmp(c,"q(",2) == 0) {
    Delete(SwigType_pop(t));
    c = Char(t);
  }
  if (strncmp(c,"r.",2)) {
    printf("Fatal error. SwigType_del_pointer applied to non-pointer.\n");
    abort();
  }
  Replace(t,"r.","", DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
  }

  int
  is_a_reference (SwigType *t)
  {
    return SwigType_isreference(SwigType_typedef_resolve_all(t));
  }

  virtual int functionWrapper(Node *n) {
    char *iname = GetChar(n,"sym:name");
    SwigType *d = Getattr(n,"type");
    String *return_type_normalized = normalizeTemplatedClassName(d);
    ParmList *l = Getattr(n,"parms");
    Parm *p;
    
    Wrapper *f = NewWrapper();
    String *proc_name = NewString("");
    String *source = NewString("");
    String *target = NewString("");
    String *arg = NewString("");
    String *cleanup = NewString("");
    String *outarg = NewString("");
    String *build = NewString("");
    String   *tm;
    int argout_set = 0;
    int i = 0;
    int numargs;
    int numreq;
    int newobj = Getattr(n,"feature:new") ? 1 : 0;
    String *overname = 0;

    // Make a wrapper name for this
    String *wname = Swig_name_wrapper(iname);
    if (Getattr(n,"sym:overloaded")) {
      overname = Getattr(n,"sym:overname");
    } else {
      if (!addSymbol(iname,n)) return SWIG_ERROR;
    }
    if (overname) {
      Append(wname, overname);
    }
    Setattr(n,"wrap:name",wname);
    
    // Build the name for Scheme.
    Printv(proc_name,"_",iname,NIL);
    String *mangled_name = mangleNameForCaml(proc_name);

    if( classmode && in_constructor ) { // Emit constructor for object
      String *mangled_name_nounder = 
	NewString((char *)(Char(mangled_name))+1);
      Printf( f_class_ctors_end,
	      "let %s clst = _%s clst\n",
	      mangled_name_nounder, mangled_name_nounder );
      Printf(f_mlibody, 
	     "val %s : c_obj -> c_obj\n",
	     mangled_name_nounder );
      Delete(mangled_name_nounder);
    } else if( classmode && in_destructor ) {
      Printf(f_class_ctors,
	     "    \"~\", %s ;\n", mangled_name );
    } else if( classmode && !in_constructor && !in_destructor &&
	       !static_member_function ) {
      String *opname = Copy(Getattr(n,"name"));
	
      Replaceall(opname,"operator ","");

      if( strstr( Char(mangled_name), "__get__" ) ) {
	String *set_name = Copy(mangled_name);
	if( !Getattr(n,"feature:immutable") ) {
	    Replaceall(set_name,"__get__","__set__");
	    Printf(f_class_ctors,
		   "    \"%s\", (fun args -> "
		   "if args = (C_list [ raw_ptr ]) then %s args else %s args) ;\n",
		   opname, mangled_name, set_name );
	    Delete(set_name);
	} else {
	    Printf(f_class_ctors,
		   "    \"%s\", (fun args -> "
		   "if args = (C_list [ raw_ptr ]) then %s args else C_void) ;\n",
		   opname, mangled_name );
	}
      } else if( strstr( Char(mangled_name), "__set__" ) ) {
	  ; /* Nothing ... handled by the case above */
      } else {
	  Printf(f_class_ctors,
	       "    \"%s\", %s ;\n",
	       opname, mangled_name);
      }

      Delete(opname);
    } 

    if( classmode && in_constructor ) {
      Setattr(seen_constructors,mangled_name,"true");
    }

    // writing the function wrapper function
    Printv(f->def,
	   "#ifdef __cplusplus\n"
	   "extern \"C\"\n"
	   "#endif\n"
	   "value ", wname, " (", NIL);
    Printv(f->def, "value args", NIL);
    Printv(f->def, ")\n{", NIL);
    
    /* Define the scheme name in C. This define is used by several
       macros. */
    Printv(f->def, "#define FUNC_NAME \"", mangled_name, "\"", NIL);
    
    // adds local variables
    Wrapper_add_local(f, "args", "CAMLparam1(args)");
    Wrapper_add_local(f, "ret", "CAMLlocal2(swig_result,rv)");
    Wrapper_add_local(f, "_len", "int _len");
    Wrapper_add_local(f, "lenv", "int lenv = 1");
    Wrapper_add_local(f, "argc", "int argc = caml_list_length(args)");
    Wrapper_add_local(f, "argv", "value *argv");
    Wrapper_add_local(f, "i", "int i");

    Printv( f->code,
	    "argv = (value *)malloc( argc * sizeof( value ) );\n"
	    "for( i = 0; i < argc; i++ ) {\n"
	    "  argv[i] = caml_list_nth(args,i);\n"
	    "}\n", NIL );

    // Declare return variable and arguments
    // number of parameters
    // they are called arg0, arg1, ...
    // the return value is called result
    
    emit_args(d, l, f);
    
    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);
    Setattr(n,"wrap:parms",l);
    
    numargs = emit_num_arguments(l);
    numreq  = emit_num_required(l);
    
    Printf(f->code,"swig_result = Val_unit;\n" );
    
    // Now write code to extract the parameters (this is super ugly)
    
    for (i = 0, p = l; i < numargs; i++) {
      /* Skip ignored arguments */
      while (checkAttribute(p,"tmap:in:numinputs","0")) {
	p = Getattr(p,"tmap:in:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *ln = Getattr(p,"lname");
	
      // Produce names of source and target
      Clear(source);
      Clear(target);
      Clear(arg);
      Printf(source, "caml_list_nth(args,%d)", i);
      Printf(target, "%s",ln);
      Printv(arg, Getattr(p,"name"),NIL);
	
      if (i >= numreq) {
	Printf(f->code,"if (caml_list_length(args) > %d) {\n",i);
      }
      // Handle parameter types.
      if ((tm = Getattr(p,"tmap:in"))) {
	Replaceall(tm,"$source",source);
	Replaceall(tm,"$target",target);
	Replaceall(tm,"$input",source);
	Setattr(p,"emit:input",source);
	Printv(f->code, tm, "\n", NIL);
	p = Getattr(p,"tmap:in:next");
      } else {
	// no typemap found
	// check if typedef and resolve
	throw_unhandled_ocaml_type_error (pt);
	p = nextSibling(p);
      }
      if (i >= numreq) {
	Printf(f->code,"}\n");
      }
    }
    
    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
	Replaceall(tm,"$target",Getattr(p,"lname"));
	Printv(f->code,tm,"\n",NIL);
	p = Getattr(p,"tmap:check:next");
      } else {
	p = nextSibling(p);
      }
    }
    
    // Pass output arguments back to the caller.
    
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:argout"))) {
	Replaceall(tm,"$source",Getattr(p,"emit:input"));   /* Deprecated */
	Replaceall(tm,"$target",Getattr(p,"lname"));   /* Deprecated */
	Replaceall(tm,"$arg",Getattr(p,"emit:input"));
	Replaceall(tm,"$input",Getattr(p,"emit:input"));
	Replaceall(tm,"$ntype",return_type_normalized);
	Printv(outarg,tm,"\n",NIL);
	p = Getattr(p,"tmap:argout:next");
	argout_set = 1;
      } else {
	p = nextSibling(p);
      }
    }
    
    // Free up any memory allocated for the arguments.
    
    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:freearg"))) {
	Replaceall(tm,"$target",Getattr(p,"lname"));
	Printv(cleanup,tm,"\n",NIL);
	p = Getattr(p,"tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }
    
    // Now write code to make the function call
    
    emit_action(n,f);
    
    // Now have return value, figure out what to do with it.
    
    if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
      Replaceall(tm,"$source","result");
      Replaceall(tm,"$target","rv");
      Replaceall(tm,"$result","rv");
      Replaceall(tm,"$ntype",return_type_normalized);
      Printv(f->code, tm, "\n",NIL);
    } else {
      throw_unhandled_ocaml_type_error (d);
    }
    
    // Dump the argument output code
    Printv(f->code, Char(outarg),NIL);
    
    // Dump the argument cleanup code
    Printv(f->code, Char(cleanup),NIL);
    
    // Look for any remaining cleanup
    
    if (Getattr(n,"feature:new")) {
      if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
	Replaceall(tm,"$source","result");
	Printv(f->code, tm, "\n",NIL);
      }
    }
    
    // Free any memory allocated by the function being wrapped..
    
    if ((tm = Swig_typemap_lookup_new("swig_result",n,"result",0))) {
      Replaceall(tm,"$source","result");
      Printv(f->code, tm, "\n",NIL);
    }

    // Wrap things up (in a manner of speaking)
    
    Printv(f->code, 
	   tab4, "swig_result = caml_list_append(swig_result,rv);\n"
	   tab4, "free( argv );\n"
	   tab4, "if( lenv == 0 )\n"
	   tab4, "{\n"
	   tab4, tab4, "CAMLreturn(Val_unit);\n",
	   tab4, "}\n"
	   tab4, "else\n"
	   tab4, "{\n",
	   tab4, tab4, "CAMLreturn(swig_result);\n", 
	   tab4, "}\n", NIL);
    Printf(f->code, "#undef FUNC_NAME\n");
    Printv(f->code, "}\n",NIL);
    
    Wrapper_print(f, f_wrappers);

    if( Getattr(n,"sym:overloaded") ) {
      if( !Getattr(n,"sym:nextSibling") ) {
	int maxargs;
	Wrapper *df = NewWrapper();
	String *dname = Swig_name_wrapper(iname);
	String *dispatch = 
	  Swig_overload_dispatch(n,
				 "free(argv);\nCAMLreturn(%s(args));\n",
				 &maxargs);

	Wrapper_add_local(df, "argv", "value *argv");

	Printv(df->def,
	       "#ifdef __cplusplus\n"
	       "extern \"C\"\n"
	       "#endif\n"
	       "value ",dname,"(value args) {\n"
	       "  CAMLparam1(args);\n"
	       "  int i;\n"
	       "  int argc = caml_list_length(args);\n",NIL);
	Printv( df->code,
		"argv = (value *)malloc( argc * sizeof( value ) );\n"
		"for( i = 0; i < argc; i++ ) {\n"
		"  argv[i] = caml_list_nth(args,i);\n"
		"}\n", NIL );
	Printv(df->code,dispatch,"\n",NIL);
	Printf(df->code,"failwith(\"No matching function for overloaded '%s'\");\n", iname);
	Printv(df->code,"}\n",NIL);
	Wrapper_print(df,f_wrappers);

	Printf(f_mlbody, 
	       "external %s_f : c_obj list -> c_obj list = \"%s\"\n"
	       "let %s = fnhelper %s %s_f\n",
	       mangled_name, dname, mangled_name, 
	       newobj ? "true" : "false",
	       mangled_name );
	if( !classmode || in_constructor || in_destructor ||
	    static_member_function ) 
	  Printf(f_mlibody,
		 "(* overload *)\n"
		 "val %s : c_obj -> c_obj\n", mangled_name );

	DelWrapper(df);
	Delete(dispatch);
	Delete(dname);
      }
    } else {
      Printf(f_mlbody, 
	     "external %s_f : c_obj list -> c_obj list = \"%s\"\n"
	     "let %s = fnhelper %s %s_f\n",
	     mangled_name, wname, mangled_name, newobj ? "true" : "false", 
	     mangled_name );
      if( !classmode || in_constructor || in_destructor ||
	  static_member_function ) 
	Printf(f_mlibody,
	       "(* Non-overload *)\n"
	       "val %s : c_obj -> c_obj\n", mangled_name );
    }
   
    Delete(proc_name);
    Delete(source);
    Delete(target);
    Delete(arg);
    Delete(outarg);
    Delete(cleanup);
    Delete(build);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * variableWrapper()
   *
   * Create a link to a C variable.
   * This creates a single function _wrap_swig_var_varname().
   * This function takes a single optional argument.   If supplied, it means
   * we are setting this variable to some value.  If omitted, it means we are
   * simply evaluating this variable.  Either way, we return the variables
   * value.
   * ------------------------------------------------------------ */

  virtual int variableWrapper(Node *n)  {
	
    char *name  = GetChar(n,"name");
    String *iname = Getattr(n,"sym:name");
    String *mname = mangleNameForCaml(iname);
    SwigType *t = Getattr(n,"type");
	
    String *proc_name = NewString("");
    char  var_name[256];
    String *tm;
    String *tm2 = NewString("");;
    String *argnum = NewString("0");
    String *arg = NewString("Field(args,0)");
    Wrapper *f;
	
    if (!iname || !addSymbol(iname,n)) return SWIG_ERROR;
	
    f = NewWrapper();
	
    // evaluation function names
	
    strcpy(var_name, Char(Swig_name_wrapper(iname)));
	
    // Build the name for scheme.
    Printv(proc_name, iname,NIL);
    //Replaceall(proc_name, "_", "-");
	
    if ((SwigType_type(t) != T_USER) || (is_a_pointer(t))) {
	    
      Printf (f->def, 
	      "#ifdef __cplusplus\n"
	      "extern \"C\"\n"
	      "#endif\n"
	      "value %s(value args) {\n", var_name);
      Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", NIL);
	    
      Wrapper_add_local (f, "swig_result", "value swig_result");
	    
      if (!Getattr(n,"feature:immutable")) {
	/* Check for a setting of the variable value */
	Printf (f->code, "if (args != Val_int(0)) {\n");
	if ((tm = Swig_typemap_lookup_new("varin",n,name,0))) {
	  Replaceall(tm,"$source","args");
	  Replaceall(tm,"$target",name);
	  Replaceall(tm,"$input","args");
	  Printv(f->code, tm, "\n",NIL);
	} else {
	  throw_unhandled_ocaml_type_error (t);
	}
	Printf (f->code, "}\n");
      }
	    
      // Now return the value of the variable (regardless
      // of evaluating or setting)
	    
      if ((tm = Swig_typemap_lookup_new("varout",n,name,0))) {
	Replaceall(tm,"$source",name);
	Replaceall(tm,"$target","swig_result");
	Replaceall(tm,"$result","swig_result");
	Printf (f->code, "%s\n", tm);
      } else {
	throw_unhandled_ocaml_type_error (t);
      }
	    
      Printf (f->code, "\nreturn swig_result;\n");
      Printf (f->code, "#undef FUNC_NAME\n");
      Printf (f->code, "}\n");
	    
      Wrapper_print (f, f_wrappers);
	    
      // Now add symbol to the Ocaml interpreter
	    
      if( Getattr( n, "feature:immutable" ) ) {
	Printf( f_mlbody, 
		"external __%s : c_obj -> c_obj = \"%s\"\n"
		"let _%s = __%s C_void\n",
		mname, var_name, mname, mname );
	Printf( f_mlibody, "val _%s : c_obj\n", iname );
	if( const_enum ) {
	  Printf( f_enum_to_int, 
		  " | `%s -> _%s\n", 
		  mname, mname );
	  Printf( f_int_to_enum, 
		  " if y = (get_int _%s) then `%s else\n",
		  mname, mname );
	}
      } else {
	Printf( f_mlbody, "external _%s : c_obj -> c_obj = \"%s\"\n",
		mname, var_name );
	Printf( f_mlibody, "external _%s : c_obj -> c_obj = \"%s\"\n",
		mname, var_name );
      }
    } else {
      Swig_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number,
		   "Unsupported variable type %s (ignored).\n", SwigType_str(t,0));
    }

    Delete(proc_name);
    Delete(argnum);
    Delete(arg);
    Delete(tm2);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmemberfunctionHandler --
   * Overridden to set static_member_function 
   * ------------------------------------------------------------ */

  virtual int staticmemberfunctionHandler( Node *n ) {
    int rv;
    static_member_function = 1;
    rv = Language::staticmemberfunctionHandler( n );
    static_member_function = 0;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    char *name      = GetChar(n,"name");
    char *iname     = GetChar(n,"sym:name");
    SwigType *type  = Getattr(n,"type");
    String   *value = Getattr(n,"value");
    
    String *var_name = NewString("");
    String *proc_name = NewString("");
    String *rvalue = NewString("");
    String *temp = NewString("");
    String *tm;
    
    // Make a static variable;

    Printf (var_name, "_wrap_const_%s", Swig_name_mangle(iname));
    
    // Build the name for scheme.
    Printv(proc_name, iname,NIL);
    //Replaceall(proc_name, "_", "-");
    
    if ((SwigType_type(type) == T_USER) && (!is_a_pointer(type))) {
      Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number,
		   "Unsupported constant value.\n");
      return SWIG_NOWRAP;
    }
    
    // See if there's a typemap
    
    Printv(rvalue, value,NIL);
    if ((SwigType_type(type) == T_CHAR) && (is_a_pointer(type) == 1)) {
      temp = Copy(rvalue);
      Clear(rvalue);
      Printv(rvalue, "\"", temp, "\"",NIL);
    }
    if ((SwigType_type(type) == T_CHAR) && (is_a_pointer(type) == 0)) {
      Delete(temp);
      temp = Copy(rvalue);
      Clear(rvalue);
      Printv(rvalue, "'", temp, "'",NIL);
    }
    if ((tm = Swig_typemap_lookup_new("constant",n,name,0))) {
      Replaceall(tm,"$source",rvalue);
      Replaceall(tm,"$value",rvalue);
      Replaceall(tm,"$target",name);
      Printf (f_init, "%s\n", tm);
    } else {
      // Create variable and assign it a value
      
      Printf (f_header, "static %s = ", SwigType_lstr(type,var_name));
      if ((SwigType_type(type) == T_STRING)) {
	Printf (f_header, "\"%s\";\n", value);
      } else if (SwigType_type(type) == T_CHAR) {
	Printf (f_header, "\'%s\';\n", value);
      } else {
	Printf (f_header, "%s;\n", value);
      }

      {
	/* Hack alert: will cleanup later -- Dave */
	Node *n = NewHash();
	Setattr(n,"name",var_name);
	Setattr(n,"sym:name",iname);
	Setattr(n,"type", type);
	Setattr(n,"feature:immutable","1");
	variableWrapper(n);
	Delete(n);
      }
    }
    Delete(proc_name);
    Delete(rvalue);
    Delete(temp);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * validIdentifer()
   * ------------------------------------------------------------ */
  
  virtual int validIdentifier(String *s) {
#if 0
    char *c = Char(s);
    /* Check whether we have an R5RS identifier.*/
    /* <identifier> --> <initial> <subsequent>* | <peculiar identifier> */
    /* <initial> --> <letter> | <special initial> */
    if (!(isalpha(*c) || (*c == '!') || (*c == '$') || (*c == '%')
	  || (*c == '&') || (*c == '*') || (*c == '/') || (*c == ':')
	  || (*c == '<') || (*c == '=') || (*c == '>') || (*c == '?')
	  || (*c == '^') || (*c == '_') || (*c == '~'))) {
      /* <peculiar identifier> --> + | - | ... */
      if ((strcmp(c, "+") == 0)
	  || strcmp(c, "-") == 0
	  || strcmp(c, "...") == 0) return 1;
      else return 0;
    }
    /* <subsequent> --> <initial> | <digit> | <special subsequent> */
    while (*c) {
      if (!(isalnum(*c) || (*c == '!') || (*c == '$') || (*c == '%')
	    || (*c == '&') || (*c == '*') || (*c == '/') || (*c == ':')
	    || (*c == '<') || (*c == '=') || (*c == '>') || (*c == '?')
	    || (*c == '^') || (*c == '_') || (*c == '~') || (*c == '+')
	    || (*c == '-') || (*c == '.') || (*c == '@'))) return 0;
      c++;
    }
#endif
    return 1;
  }

  int constructorHandler(Node *n) {
    int ret;

    in_constructor = 1;
    ret = Language::constructorHandler(n);
    in_constructor = 0;

    return ret;
  }

  int destructorHandler(Node *n) {
    int ret;

    in_destructor = 1;
    ret = Language::destructorHandler(n);
    in_destructor = 0;
	    
    return ret;
  }

  int copyconstructorHandler(Node *n) {
    int ret;

    in_copyconst = 1;
    in_constructor = 1;
    ret = Language::copyconstructorHandler(n);
    in_constructor = 0;
    in_copyconst = 0;

    return ret;
  }

  int classHandler( Node *n ) {
    String *name = Getattr(n,"name");
    String *mangled_sym_name = mangleNameForCaml(name);

    if( !name ) return SWIG_OK;

    classname = mangled_sym_name;

    Printf( f_class_ctors,
	    "let create_%s_from_ptr raw_ptr =\n"
	    "  C_obj (let rec method_table = [\n"
	    "    \"nop\", (fun args -> C_void) ;\n",
	    classname );

    Printf( f_mlibody,
	    "val create_%s_from_ptr : c_obj -> c_obj\n",
	    classname );

    classmode = 1;
    int rv = Language::classHandler(n);
    classmode = 0;

#if 0
    Printf(f_mlibody, 
	   "val delete_%s : c_obj -> unit\n",
	   mangled_sym_name );
#endif
    
    /* Handle up-casts in a nice way */
    List *baselist = Getattr(n,"bases");
    if (baselist && Len(baselist)) {
      Node *base = Firstitem(baselist);
      while (base) {
	String *bname = Getattr(base, "ocaml:ctor");
	if (bname)
	  Printv(f_class_ctors,
		 "   \"::",bname,"\", (fun args -> "
		 "create_",bname,"_from_ptr raw_ptr) ;\n",NIL);
	
	base = Nextitem(baselist);
      }
    }    
    
    Printf(f_class_ctors,
	   "    \"&\", (fun args -> raw_ptr) ;\n"
	   "    \":parents\",\n"
	   "      (fun args -> \n"
	   "        C_list \n"
	   "        (List.map \n"
	   "	      (fun (x,y) -> \n"
	   "            C_string (String.sub x 2 ((String.length x) - 2)))\n"
	   "          (List.filter \n"
	   "            (fun (x,y) -> \n"
	   "              ((String.length x) > 2) && \n"
	   "              x.[0] == ':' && \n"
	   "              x.[1] == ':') method_table))) ;\n"
	   "    \":classof\", (fun args -> (C_string \"%s\")) ;\n"
	   "    \":methods\", "
	   "(fun args -> C_list (List.map (fun (x,y) -> C_string x) "
	   "method_table)) ] in\n"
	   "  (fun mth arg ->\n"
	   "    try\n"
	   "      let method_name,application = List.hd (List.filter (fun (x,y) -> x = mth) method_table) in\n"
	   "        application \n"
	   "          (match arg with C_list l -> (C_list (raw_ptr :: l)) | C_void -> (C_list [ raw_ptr ]) | v -> (C_list [ raw_ptr ; v ]))\n"
	   "    with (Failure \"hd\") -> \n"
	   "    (* Try parent classes *)\n"
	   "    begin\n"
	   "      let parent_classes = [ \n",
	   name );
    
    /* Handle inheritance -- Mostly stolen from python code */
    baselist = Getattr(n,"bases");
    if (baselist && Len(baselist)) {
      Node *base = Firstitem(baselist);
      while (base) {
	String *bname = Getattr(base, "ocaml:ctor");
	if (bname)
	  Printv(f_class_ctors,
		 "           create_",bname,"_from_ptr",NIL);
	
	base = Nextitem(baselist);
	if (base)
	  Printv(f_class_ctors," ;\n",NIL);
	else
	  Printv(f_class_ctors,"\n",NIL);
      }
    }    
    
    Printv(f_class_ctors,"          ]\n",NIL);
    
    Printf(f_class_ctors,
	   "     in let rec try_parent plist raw_ptr = \n"
	   "       match plist with\n"
	   "         p :: tl -> (try\n"
	   "           (invoke (p raw_ptr)) mth arg\n"
	   "         with (BadMethodName (p,m,s)) -> try_parent tl raw_ptr)\n"
	   "       | [] ->\n"
	   "         raise (BadMethodName (raw_ptr,mth,\"%s\"))\n"
	   "     in try_parent parent_classes raw_ptr\n"
	   "     end\n"
	   "   | e -> raise e))\n",
	   name );

    String *name_normalized = normalizeTemplatedClassName(name);

    Printf( f_class_ctors,
	    "let _ = Callback.register \"create_%s_from_ptr\" "
	    "create_%s_from_ptr\n",
	    name_normalized, classname );

    Setattr(n,"ocaml:ctor",classname);

    return rv;
  }
    
  String *normalizeTemplatedClassName( String *name ) {
    String *name_normalized = SwigType_typedef_resolve_all(name);

    if( is_a_pointer(name_normalized) )
      SwigType_del_pointer( name_normalized );

    if( is_a_reference(name_normalized) ) 
      oc_SwigType_del_reference( name_normalized );
    
    Replaceall(name_normalized,"(","");
    Replaceall(name_normalized,")","");
    return name_normalized;
  }

  String *mangleNameForCaml( String *s ) {
    String *out = Copy(s);
    Replaceall(out," ","_");
    Replaceall(out,"::","_");
    Replaceall(out,",","_x_");
    Replaceall(out,"+","__plus__");
    Replaceall(out,"-","__minus__");
    Replaceall(out,"<","__ldbrace__");
    Replaceall(out,">","__rdbrace__");
    Replaceall(out,"!","__not__");
    Replaceall(out,"%","__mod__");
    Replaceall(out,"^","__xor__");
    Replaceall(out,"*","__star__");
    Replaceall(out,"&","__amp__");
    Replaceall(out,"|","__or__");
    Replaceall(out,"(","__lparen__");
    Replaceall(out,")","__rparen__");
    Replaceall(out,"[","__lbrace__");
    Replaceall(out,"]","__rbrace__");
    Replaceall(out,"~","__bnot__");
    Replaceall(out,"=","__equals__");
    Replaceall(out,"/","__slash__");
    Replaceall(out,".","__dot__");
    return out;
  }
    
  /* Benedikt Grundmann inspired --> Enum wrap styles */

  int enumvalueDeclaration(Node *n) {
    String *name = Getattr(n,"name");

    if( const_enum && name && !Getattr(seen_enumvalues,name) ) {
      Printf( f_enumtypes_value,"| `%s\n", name );
      Setattr(seen_enumvalues,name,"true");
      Setattr(n,"feature:immutable","1");

      return constantWrapper(n);
    } else return SWIG_OK;
  }

  int enumDeclaration(Node *n) {
    String *name = Getattr(n,"name");

    if( name && !Getattr(seen_enums,name) ) {
      const_enum = 1;
      Printf( f_enum_to_int, "| `%s -> (match (y : c_enum_tag) with\n", name );
      Printf( f_int_to_enum, "| `%s -> C_enum (\n", name );
      Printf( f_mlbody, 
	      "let _ = Callback.register \"%s_marker\" (`%s)\n",
	      name, name );
      Printf( f_enumtypes_type,"| `%s\n", name );
      Setattr(seen_enumvalues,name,"true");
    }

    int ret = Language::enumDeclaration(n);
	
    if( const_enum ) {
      Printf( f_int_to_enum, "`int y)\n", name );
      Printf( f_enum_to_int, 
	      "| `int (x : int) -> C_int x\n"
	      "| _ -> raise (Failure \"Unknown enum tag\"))\n" );
    }

    const_enum = 0;
	
    return ret;
  }
};
  
/* -------------------------------------------------------------------------
 * swig_ocaml()    - Instantiate module
 * ------------------------------------------------------------------------- */

extern "C" Language *
swig_ocaml(void) {
  return new OCAML();
}

