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

#include <ctype.h>

static const char *usage = (char*)
    ("Ocaml Options (available with -ocaml)\n"
     "-prefix <name>  - Set a prefix <name> to be prepended to all names\n"
     "-where          - Emit library location\n"
     "-suffix <name>  - Change .cxx to something else\n"
     "-oldvarnames    - old intermediary method names for variable wrappers\n"
     "\n");

static int classmode = 0;
static int in_constructor = 0, in_destructor = 0, in_copyconst = 0;
static int const_enum = 0;
static int static_member_function = 0;
static int generate_sizeof = 0;
static char *prefix=0;
static char *ocaml_path=(char*)"ocaml";
static bool  old_variable_names = false;
static String *classname=0;
static String *module=0;
static String *init_func_def = 0;
static String *f_classtemplate = 0;
static String *name_qualifier = 0;

static  Hash         *seen_enums = 0;
static  Hash         *seen_enumvalues = 0;
static  Hash         *seen_constructors = 0;

static  File         *f_header = 0;
static  File         *f_runtime = 0;
static  File         *f_wrappers = 0;
static  File         *f_directors = 0;
static  File         *f_directors_h = 0;
static  File         *f_init = 0;
static  File         *f_mlout = 0;
static  File         *f_mliout = 0;
static  File         *f_mlbody = 0;
static  File         *f_mlibody = 0;
static  File         *f_mltail = 0;
static  File         *f_mlitail = 0;
static  File         *f_enumtypes_type = 0;
static  File         *f_enumtypes_value = 0;
static  File         *f_class_ctors = 0;
static  File         *f_class_ctors_end = 0;
static  File         *f_enum_to_int = 0;
static  File         *f_int_to_enum = 0;

class OCAML : public Language {
public:

  OCAML() 
  {
    director_prot_ctor_code = NewString("");    
    Printv(director_prot_ctor_code,
	   "if ( $comparison ) { /* subclassed */\n",
	   "  $director_new \n",
	   "} else {\n",
	   "  failwith(\"accessing abstract class or protected constructor\"); \n",
	   "}\n", NIL);
    director_multiple_inheritance = 1;
    director_language = 1;
  }
  
      
    String *Swig_class_name(Node *n) {
	String *name;
	name = Copy(Getattr(n, "sym:name"));
	return name;
    }

    void PrintIncludeArg() {
	Printv(stdout,SWIG_LIB,SWIG_FILE_DELIMETER,ocaml_path,
	       "\n",NIL);
    }

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
		    fputs (usage, stdout);
		    SWIG_exit (0);
		} else if (strcmp (argv[i], "-where") == 0) {
		    PrintIncludeArg();
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
		} else if (strcmp (argv[i], "-suffix") == 0) {
		    if (argv[i + 1]) {
			SWIG_config_cppext( argv[i+1] );
			Swig_mark_arg (i);
			Swig_mark_arg (i+1);
			i++;
		    } else
			Swig_arg_error();
		} else if (strcmp(argv[i],"-oldvarnames") == 0) {
		  Swig_mark_arg(i);
		  old_variable_names = true;
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

    /* Swig_director_declaration()
     *
     * Generate the full director class declaration, complete with base classes.
     * e.g. "class SwigDirector_myclass : public myclass, public Swig::Director {"
     *
     */
  
    String *Swig_director_declaration(Node *n) {
	String* classname = Swig_class_name(n);
	String *directorname = NewStringf("SwigDirector_%s", classname);
	String *base = Getattr(n, "classtype");
	String *declaration = Swig_class_declaration(n, directorname);
	Printf(declaration, " : public %s, public Swig::Director {\n", base);
	Delete(classname);
	Delete(directorname);
	return declaration;
    }
  
    /* ------------------------------------------------------------
     * top()
     *
     * Recognize the %module, and capture the module name.
     * Create the default enum cases.
     * Set up the named outputs:
     *
     *  init
     *  ml
     *  mli
     *  wrapper
     *  header
     *  runtime
     *  directors
     *  directors_h
     * ------------------------------------------------------------ */

    virtual int top(Node *n) {
	/* Set comparison with none for ConstructorToFunction */
	setSubclassInstanceCheck(NewString("caml_list_nth(args,0) != Val_unit"));

	/* check if directors are enabled for this module.  note: this 
	 * is a "master" switch, without which no director code will be
	 * emitted.  %feature("director") statements are also required
	 * to enable directors for individual classes or methods.
	 *
	 * use %module(directors="1") modulename at the start of the 
	 * interface file to enable director generation.
	 */
	{
	    Node *module = Getattr(n, "module");
	    if (module) {
		Node *options = Getattr(module, "options");
		if (options) {
		    if (Getattr(options, "directors")) {
			allow_directors();
		    }
		    if (Getattr(options, "dirprot")) {
		        allow_dirprot();
		    }
		    if (Getattr(options, "sizeof")) {
			generate_sizeof = 1;
		    }
		}
	    }
	}

	/* Initialize all of the output files */
	String *outfile = Getattr(n,"outfile");
    
	f_runtime = NewFile(outfile,"w");
	if (!f_runtime) {
	    FileErrorDisplay(outfile);
	    SWIG_exit(EXIT_FAILURE);
	}
	f_init = NewString("");
	f_header = NewString("");
	f_wrappers = NewString("");
	f_directors = NewString("");
	f_directors_h = NewString("");
	f_enumtypes_type = NewString("");
	f_enumtypes_value = NewString("");
	init_func_def = NewString("");
	f_mlbody = NewString("");
	f_mlibody = NewString("");
	f_mltail = NewString("");
	f_mlitail = NewString("");
	f_class_ctors = NewString("");
	f_class_ctors_end = NewString("");
	f_enum_to_int = NewString("");
	f_int_to_enum = NewString("");
	f_classtemplate = NewString("");

	module = Getattr(n,"name");

	seen_constructors = NewHash();
	seen_enums = NewHash();
	seen_enumvalues = NewHash();
    
	/* Register file targets with the SWIG file handler */
	Swig_register_filebyname("init",init_func_def);
	Swig_register_filebyname("header",f_header);
	Swig_register_filebyname("wrapper",f_wrappers);
	Swig_register_filebyname("runtime",f_runtime);
	Swig_register_filebyname("mli",f_mlibody);
	Swig_register_filebyname("ml",f_mlbody);
	Swig_register_filebyname("mlitail",f_mlitail);
	Swig_register_filebyname("mltail",f_mltail);
	Swig_register_filebyname("director",f_directors);
	Swig_register_filebyname("director_h",f_directors_h);
	Swig_register_filebyname("classtemplate",f_classtemplate);
	Swig_register_filebyname("class_ctors",f_class_ctors);
    
	if (old_variable_names) {
	  Swig_name_register("set","%v__set__");
	  Swig_name_register("get","%v__get__");
	}
    
	Printf( f_runtime, 
		"/* -*- buffer-read-only: t -*- vi: set ro: */\n" );
	Printf( f_runtime, "#define SWIG_MODULE \"%s\"\n", module );
	/* Module name */
	Printf( f_mlbody, "let module_name = \"%s\"\n", module );
	Printf( f_mlibody, "val module_name : string\n" );
	Printf( f_enum_to_int, 
		"let enum_to_int x (v : c_obj) =\n"
		"   match v with\n"
		"     C_enum _y ->\n"
		"     (let y = _y in match (x : c_enum_type) with\n"
		"       `unknown -> "
		"         (match y with\n"
		"           `Int x -> (Swig.C_int x)\n"
		"           | _ -> raise (LabelNotFromThisEnum v))\n" );

	Printf( f_int_to_enum,
		"let int_to_enum x y =\n"
		"    match (x : c_enum_type) with\n"
		"      `unknown -> C_enum (`Int y)\n" );

	Swig_banner (f_runtime);

	if( directorsEnabled() ) {
	    Printf( f_runtime, "#define SWIG_DIRECTORS\n");
	    Swig_insert_file("director.swg", f_directors_h);
	}
    
	/* Produce the enum_to_int and int_to_enum functions */
    
	Printf(f_enumtypes_type,"open Swig\n"
	       "type c_enum_type = [ \n  `unknown\n" );
	Printf(f_enumtypes_value,"type c_enum_value = [ \n  `Int of int\n" );
	String *mlfile = NewString("");
	String *mlifile = NewString("");

	Printv(mlfile,module,".ml",NIL);
	Printv(mlifile,module,".mli",NIL);
    
	String *mlfilen = NewStringf("%s%s", SWIG_output_directory(),mlfile);
	if ((f_mlout = NewFile(mlfilen,"w")) == 0) {
	    FileErrorDisplay(mlfilen);
	    SWIG_exit (EXIT_FAILURE);
	}
	String *mlifilen = NewStringf("%s%s", SWIG_output_directory(),mlifile);
	if ((f_mliout = NewFile(mlifilen,"w")) == 0) {
	    FileErrorDisplay(mlifilen);
	    SWIG_exit (EXIT_FAILURE);
	}
    
	Language::top(n);

	Printf( f_enum_to_int, 
		") | _ -> (C_int (get_int v))\n"
		"let _ = Callback.register \"%s_enum_to_int\" enum_to_int\n", 
		module );
	Printf( f_mlibody, 
		"val enum_to_int : c_enum_type -> c_obj -> Swig.c_obj\n" );

	Printf( f_int_to_enum,
		"let _ = Callback.register \"%s_int_to_enum\" int_to_enum\n",
		module );
	Printf( f_mlibody,
		"val int_to_enum : c_enum_type -> int -> c_obj\n" );
	Printf( f_init,
		"#define SWIG_init f_%s_init\n"
		"%s"
		"}\n",
		module, init_func_def );
	Printf( f_mlbody,
		"external f_init : unit -> unit = \"f_%s_init\" ;;\n"
		"let _ = f_init ()\n",
		module, module );
	Printf( f_enumtypes_type, "]\n" );
	Printf( f_enumtypes_value, "]\n\n"
		"type c_obj = c_enum_value c_obj_t\n" );

	SwigType_emit_type_table (f_runtime, f_wrappers);
	/* Close all of the files */
	Dump(f_directors_h,f_header);
	Dump(f_header,f_runtime);
	Dump(f_directors,f_wrappers);
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
	Dump(f_mltail,f_mlout);
	Close(f_mlout);
	Delete(f_mlout);

	Dump(f_enumtypes_type,f_mliout);
	Dump(f_enumtypes_value,f_mliout);
	Dump(f_mlibody,f_mliout);
	Dump(f_mlitail,f_mliout);
	Close(f_mliout);
	Delete(f_mliout);

	return SWIG_OK;
    }
  
    /* Produce an error for the given type */
    void throw_unhandled_ocaml_type_error (SwigType *d, const char *types) {
	Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		     "Unable to handle type %s (%s).\n", SwigType_str(d,0),
		     types );
    }

    /* Return true iff T is a pointer type */
    int
    is_a_pointer (SwigType *t) {
	return SwigType_ispointer(SwigType_typedef_resolve_all(t));
    }

    /*
     * Delete one reference from a given type.
     */

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

    void oc_SwigType_del_array(SwigType *t) {
	char *c = Char(t);
	if (strncmp(c,"q(",2) == 0) {
	    Delete(SwigType_pop(t));
	    c = Char(t);
	}
	if (strncmp(c,"a(",2) == 0) {
	    Delete(SwigType_pop(t));
	}
    }
  
    /* 
     * Return true iff T is a reference type 
     */

    int
    is_a_reference (SwigType *t) {
	return SwigType_isreference(SwigType_typedef_resolve_all(t));
    }

    int
    is_an_array (SwigType *t) {
	return SwigType_isarray(SwigType_typedef_resolve_all(t));
    }

    /* ------------------------------------------------------------
     * functionWrapper()
     * Create a function declaration and register it with the interpreter.
     * ------------------------------------------------------------ */

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
	int newobj = GetFlag(n,"feature:new");
	String *nodeType = Getattr(n, "nodeType");
	int constructor = !Cmp(nodeType, "constructor");
	int destructor = (!Cmp(nodeType, "destructor")); 
	String *storage = Getattr(n,"storage");
	int isVirtual = !Cmp(storage,"virtual");
	String *overname = 0;
	bool isOverloaded = Getattr(n,"sym:overloaded") ? true : false;

	// Make a wrapper name for this
	String *wname = Swig_name_wrapper(iname);
	if (isOverloaded) {
	    overname = Getattr(n,"sym:overname");
	} else {
	    if (!addSymbol(iname,n)) return SWIG_ERROR;
	}
	if (overname) {
	    Append(wname, overname);
	}
	/* Do this to disambiguate functions emitted from different modules */
	Append(wname, module);

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
	       "SWIGEXT CAML_VALUE ", wname, " (", NIL);
	Printv(f->def, "CAML_VALUE args", NIL);
	Printv(f->def, ")\n{", NIL);
    
	/* Define the scheme name in C. This define is used by several
	   macros. */
	//Printv(f->def, "#define FUNC_NAME \"", mangled_name, "\"", NIL);
    
	// adds local variables
	Wrapper_add_local(f, "args", "CAMLparam1(args)");
	Wrapper_add_local(f, "ret" , "SWIG_CAMLlocal2(swig_result,rv)");
	Wrapper_add_local(f, "_v"  , "int _v = 0");
	if( isOverloaded ) {
	    Wrapper_add_local(f, "i"   , "int i");
	    Wrapper_add_local(f, "argc", "int argc = caml_list_length(args)");
	    Wrapper_add_local(f, "argv", "CAML_VALUE *argv");

	    Printv( f->code,
		    "argv = (CAML_VALUE *)malloc( argc * sizeof( CAML_VALUE ) );\n"
		    "for( i = 0; i < argc; i++ ) {\n"
		    "  argv[i] = caml_list_nth(args,i);\n"
		    "}\n", NIL );
	}

	// Declare return variable and arguments
	// number of parameters
	// they are called arg0, arg1, ...
	// the return value is called result
    
	d = SwigType_typedef_qualified(d);
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
	    pt = SwigType_typedef_qualified(pt);
	
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
		throw_unhandled_ocaml_type_error (pt,"in");
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
		Replaceall(tm,"$ntype",
			   normalizeTemplatedClassName(Getattr(p,"type")));
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

	/* if the object is a director, and the method call originated from its
	 * underlying python object, resolve the call by going up the c++ 
	 * inheritance chain.  otherwise try to resolve the method in python.  
	 * without this check an infinite loop is set up between the director and 
	 * shadow class method calls.
	 */

	// NOTE: this code should only be inserted if this class is the
	// base class of a director class.  however, in general we haven't
	// yet analyzed all classes derived from this one to see if they are
	// directors.  furthermore, this class may be used as the base of
	// a director class defined in a completely different module at a
	// later time, so this test must be included whether or not directorbase
	// is true.  we do skip this code if directors have not been enabled
	// at the command line to preserve source-level compatibility with
	// non-polymorphic swig.  also, if this wrapper is for a smart-pointer
	// method, there is no need to perform the test since the calling object
	// (the smart-pointer) and the director object (the "pointee") are
	// distinct.

	if (directorsEnabled()) {
	  if (!is_smart_pointer()) {
	    if (/*directorbase &&*/ !constructor && !destructor 
		&& isVirtual  && !Getattr(n,"feature:nodirector")) {
		    Wrapper_add_local(f, "director", "Swig::Director *director = 0");
		    Printf(f->code, "director = dynamic_cast<Swig::Director *>(arg1);\n");
			   
		    Printf(f->code, 
			   "if (director && !director->swig_get_up(false))"
			   "director->swig_set_up();\n");
		}
	    }
	}

	// Now write code to make the function call
    
	emit_action(n,f);
    
	// Now have return value, figure out what to do with it.
    
	if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
	    Replaceall(tm,"$source","swig_result");
	    Replaceall(tm,"$target","rv");
	    Replaceall(tm,"$result","rv");
	    Replaceall(tm,"$ntype",return_type_normalized);
	    Printv(f->code, tm, "\n",NIL);
	} else {
	    throw_unhandled_ocaml_type_error (d, "out");
	}
    
	// Dump the argument output code
	Printv(f->code, Char(outarg),NIL);
    
	// Dump the argument cleanup code
	Printv(f->code, Char(cleanup),NIL);
    
	// Look for any remaining cleanup
    
	if (GetFlag(n,"feature:new")) {
	    if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
		Replaceall(tm,"$source","swig_result");
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
	       tab4, "swig_result = caml_list_append(swig_result,rv);\n", NIL);
	if( isOverloaded )
	    Printv(f->code, "free(argv);\n", NIL);
	Printv(f->code,
	       tab4, "CAMLreturn(swig_result);\n", NIL );
	Printv(f->code, "}\n",NIL);
    
	Wrapper_print(f, f_wrappers);

	if( isOverloaded ) {
	    if( !Getattr(n,"sym:nextSibling") ) {
		int maxargs;
		Wrapper *df = NewWrapper();
		String *dispatch = 
		    Swig_overload_dispatch(n,
					   "free(argv);\n"
					   "CAMLreturn(%s(args));\n",
					   &maxargs);

		Wrapper_add_local(df, "_v", "int _v = 0");
		Wrapper_add_local(df, "argv", "CAML_VALUE *argv");
		
		/* Undifferentiate name .. this is the dispatch function */
		wname = Swig_name_wrapper(iname);
		/* Do this to disambiguate functions emitted from different
		 * modules */
		Append(wname, module);

		Printv(df->def,
		       "SWIGEXT CAML_VALUE ",wname,"(CAML_VALUE args) {\n"
		       "  CAMLparam1(args);\n"
		       "  int i;\n"
		       "  int argc = caml_list_length(args);\n",NIL);
		Printv( df->code,
			"argv = (CAML_VALUE *)malloc( argc * sizeof( CAML_VALUE ) );\n"
			"for( i = 0; i < argc; i++ ) {\n"
			"  argv[i] = caml_list_nth(args,i);\n"
			"}\n", NIL );
		Printv(df->code,dispatch,"\n",NIL);
		Printf(df->code,"failwith(\"No matching function for overloaded '%s'\");\n", iname);
		Printv(df->code,"}\n",NIL);
		Wrapper_print(df,f_wrappers);

		DelWrapper(df);
		Delete(dispatch);
	    }
	}

	Printf(f_mlbody, 
	       "external %s_f : c_obj list -> c_obj list = \"%s\" ;;\n"
	       "let %s arg = match %s_f (fnhelper arg) with\n"
	       "  [] -> C_void\n"
	       "| [x] -> (if %s then Gc.finalise \n"
	       "  (fun x -> ignore ((invoke x) \"~\" C_void)) x) ; x\n"
	       "| lst -> C_list lst ;;\n",
	       mangled_name, wname, 
	       mangled_name, mangled_name, newobj ? "true" : "false");
	
	if( !classmode || in_constructor || in_destructor ||
	    static_member_function ) 
	    Printf(f_mlibody,
		   "val %s : c_obj -> c_obj\n", mangled_name );
   
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
     * simply evaluating this variable.  In the set case we return C_void.
     *
     * symname is the name of the variable with respect to C.  This 
     * may need to differ from the original name in the case of enums.
     * enumvname is the name of the variable with respect to ocaml.  This
     * will vary if the variable has been renamed.
     * ------------------------------------------------------------ */

    virtual int variableWrapper(Node *n)  {
	char *name  = GetChar(n,"feature:symname");
	String *iname = Getattr(n,"feature:enumvname");
	String *mname = mangleNameForCaml(iname);
	SwigType *t = Getattr(n,"type");
	
	String *proc_name = NewString("");
	char  var_name[256];
	String *tm;
	String *tm2 = NewString("");;
	String *argnum = NewString("0");
	String *arg = NewString("SWIG_Field(args,0)");
	Wrapper *f;

	if( !name ) {
	    name = GetChar(n,"name");
	}

	if( !iname ) {
	    iname = Getattr(n,"sym:name");
	    mname = mangleNameForCaml(NewString(iname));
	}

	if (!iname || !addSymbol(iname,n)) return SWIG_ERROR;
	
	f = NewWrapper();

	// evaluation function names
	strcpy(var_name, Char(Swig_name_wrapper(iname)));
	
	// Build the name for scheme.
	Printv(proc_name, iname, NIL);
	
	Printf (f->def, 
		"SWIGEXT CAML_VALUE %s(CAML_VALUE args) {\n", var_name);
	// Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", NIL);
	
	Wrapper_add_local (f, "swig_result", "CAML_VALUE swig_result");
	
	if (!Getattr(n,"feature:immutable")) {
	    /* Check for a setting of the variable value */
	    Printf (f->code, "if (args != Val_int(0)) {\n");
	    if ((tm = Swig_typemap_lookup_new("varin",n,name,0))) {
		Replaceall(tm,"$source","args");
		Replaceall(tm,"$target",name);
		Replaceall(tm,"$input","args");
		Printv(f->code, tm, "\n",NIL);
	    } else if ((tm = Swig_typemap_lookup_new("in",n,name,0))) {
		Replaceall(tm,"$source","args");
		Replaceall(tm,"$target",name);
		Replaceall(tm,"$input","args");
		Printv(f->code, tm, "\n",NIL);
	    } else {
		throw_unhandled_ocaml_type_error (t, "varin/in");
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
	} else if ((tm   = Swig_typemap_lookup_new("out",n,name,0))) {
	    Replaceall(tm,"$source",name);
	    Replaceall(tm,"$target","swig_result");
	    Replaceall(tm,"$result","swig_result");
	    Printf (f->code, "%s\n", tm);
	    
	} else {
	    throw_unhandled_ocaml_type_error (t, "varout/out");
	}
	
	Printf (f->code, "\nreturn swig_result;\n");
	Printf (f->code, "}\n");
	
	Wrapper_print (f, f_wrappers);
	
	// Now add symbol to the Ocaml interpreter
	
	if( Getattr( n, "feature:immutable" ) ) {
	    Printf( f_mlbody, 
		    "external _%s : c_obj -> Swig.c_obj = \"%s\" \n",
		    mname, var_name );
	    Printf( f_mlibody, "val _%s : c_obj -> Swig.c_obj\n", iname );
	    if( const_enum ) {
		Printf( f_enum_to_int, 
			" | `%s -> _%s C_void\n", 
			mname, mname );
		Printf( f_int_to_enum, 
			" if y = (get_int (_%s C_void)) then `%s else\n",
			mname, mname );
	    }
	} else {
	    Printf( f_mlbody, "external _%s : c_obj -> c_obj = \"%s\"\n",
		    mname, var_name );
	    Printf( f_mlibody, "external _%s : c_obj -> c_obj = \"%s\"\n",
		    mname, var_name );
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
     *
     * The one trick here is that we have to make sure we rename the
     * constant to something useful that doesn't collide with the
     * original if any exists.
     * ------------------------------------------------------------ */

    virtual int constantWrapper(Node *n) {
	String *name    = Getattr(n,"feature:symname");
	SwigType *type  = Getattr(n,"type");
	String   *value = Getattr(n,"value");
	String   *qvalue = Getattr(n,"qualified:value");
	String   *rvalue = NewString("");
	String   *temp = 0;

	if( qvalue ) value = qvalue;

	if( !name ) {
	    name = mangleNameForCaml(Getattr(n,"name"));
	    Insert(name,0,"_swig_wrap_");
	    Setattr(n,"feature:symname",name);
	}

	// See if there's a typemap
	
	Printv(rvalue, value,NIL);
	if ((SwigType_type(type) == T_CHAR) && (is_a_pointer(type) == 1)) {
	    temp = Copy(rvalue);
	    Clear(rvalue);
	    Printv(rvalue, "\"", temp, "\"",NIL);
	    Delete(temp);
	}
	if ((SwigType_type(type) == T_CHAR) && (is_a_pointer(type) == 0)) {
	    temp = Copy(rvalue);
	    Clear(rvalue);
	    Printv(rvalue, "'", temp, "'",NIL);
	    Delete(temp);
	}

	// Create variable and assign it a value
	
	Printf (f_header, "static %s = ", SwigType_lstr(type,name));
	if ((SwigType_type(type) == T_STRING)) {
	    Printf (f_header, "\"%s\";\n", value);
	} else if (SwigType_type(type) == T_CHAR) {
	    Printf (f_header, "\'%s\';\n", value);
	} else {
	    Printf (f_header, "%s;\n", value);
	}

	Setattr(n,"feature:immutable","1");
	variableWrapper(n);
	return SWIG_OK;
    }
	
    int constructorHandler(Node *n) {
	int ret;

	in_constructor = 1;
	ret = Language::constructorHandler(n);
	in_constructor = 0;

	return ret;
    }

    /* destructorHandler:
     * Turn on destructor flag to inform decisions in functionWrapper
     */

    int destructorHandler(Node *n) {
	int ret;

	in_destructor = 1;
	ret = Language::destructorHandler(n);
	in_destructor = 0;
	    
	return ret;
    }

    /* copyconstructorHandler:
     * Turn on constructor and copyconstructor flags for functionWrapper
     */

    int copyconstructorHandler(Node *n) {
	int ret;

	in_copyconst = 1;
	in_constructor = 1;
	ret = Language::copyconstructorHandler(n);
	in_constructor = 0;
	in_copyconst = 0;

	return ret;
    }

    /**
     * A simple, somewhat general purpose function for writing to multiple
     * streams from a source template.  This allows the user to define the
     * class definition in ways different from the one I have here if they
     * want to.  It will also make the class definition system easier to
     * fiddle with when I want to change methods, etc.
     */

    void Multiwrite( String *s ) {
	char *find_marker = strstr(Char(s),"(*Stream:");
	while( find_marker ) {
	    char *next = strstr(find_marker,"*)");
	    find_marker += strlen("(*Stream:");

	    if( next ) {
		int num_chars = next - find_marker;
		String *stream_name = NewString(find_marker);
		Delslice(stream_name,num_chars,Len(stream_name));
		File *fout = Swig_filebyname(stream_name);
		if( fout ) {
		    next += strlen("*)");
		    char *following = strstr(next,"(*Stream:");
		    find_marker = following;
		    if( !following ) following = next + strlen(next);
		    String *chunk = NewString(next);
		    Delslice(chunk,following-next,Len(chunk));
		    Printv(fout,chunk,NIL);
		}
	    }
	}
    }

    bool isSimpleType( String *name ) {
	char *ch = Char(name);

	return 
	    !(strchr(ch,'(') || strchr(ch,'<') || 
	      strchr(ch,')') || strchr(ch,'>'));
    }

    /* We accept all chars in identifiers because we use strings to index
     * them. */
    int validIdentifier( String *name ) {
	return Len(name) > 0 ? 1 : 0; 
    }

    /* classHandler
     * 
     * Create a "class" definition for ocaml.  I thought quite a bit about
     * how I should do this part of it, and arrived here, using a function
     * invocation to select a method, and dispatch.  This can obviously be
     * done better, but I can't see how, given that I want to support 
     * overloaded methods, out parameters, and operators.
     *
     * I needed a system that would do this:
     *
     *  a Be able to call these methods:
     *   int foo( int x );
     *   float foo( int x, int &out );
     *
     *  b Be typeable, even in the presence of mutually dependent classes.
     *
     *  c Support some form of operator invocation.
     *
     * (c) I chose strings for the method names so that "+=" would be a
     * valid method name, and the somewhat natural << (invoke x) "+=" y >>
     * would work.
     *
     * (a) (b) Since the c_obj type exists, it's easy to return C_int in one
     * case and C_list [ C_float ; C_int ] in the other.  This makes tricky
     * problems with out parameters disappear; they're simply appended to the
     * return list.
     *
     * (b) Since every item that comes from C++ is the same type, there is no
     * problem with the following:
     *
     * class Foo;
     * class Bar { Foo *toFoo(); }
     * class Foo { Bar *toBar(); }
     *
     * Since the Objective caml types of Foo and Bar are the same.  Now that
     * I correctly incorporate SWIG's typechecking, this isn't a big deal.
     *
     * The class is in the form of a function returning a c_obj.  The c_obj
     * is a C_obj containing a function which invokes a method on the
     * underlying object given its type.
     *
     * The name emitted here is normalized before being sent to
     * Callback.register, because we need this string to look up properly
     * when the typemap passes the descriptor string.  I've been considering
     * some, possibly more forgiving method that would do some transformations
     * on the $descriptor in order to find a potential match.  This is for
     * later.
     *
     * Important things to note:
     *
     * We rely on exception handling (BadMethodName) in order to call an
     * ancestor.  This can be improved.
     *
     * The method used to get :classof could be improved to look at the type
     * info that the base pointer contains.  It's really an error to have a
     * SWIG-generated object that does not contain type info, since the
     * existence of the object means that SWIG knows the type.
     *
     * :parents could use :classof to tell what class it is and make a better
     * decision.  This could be nice, (i.e. provide a run-time graph of C++
     * classes represented);.
     *
     * I can't think of a more elegant way of converting a C_obj fun to a
     * pointer than "operator &"... 
     *
     * Added a 'sizeof' that will allow you to do the expected thing.
     * This should help users to fill buffer structs and the like (as is
     * typical in windows-styled code).  It's only enabled if you give
     * %feature(sizeof) and then, only for simple types.
     *
     * Overall, carrying the list of methods and base classes has worked well.
     * It allows me to give the Ocaml user introspection over their objects.
     */

    int classHandler( Node *n ) {
	String *name = Getattr(n,"name");
	String *mangled_sym_name = mangleNameForCaml(name);
	String *this_class_def = NewString( f_classtemplate );
	String *name_normalized = normalizeTemplatedClassName(name);
	String *old_class_ctors = f_class_ctors;
	String *base_classes = NewString("");
	f_class_ctors = NewString("");
	bool sizeof_feature = generate_sizeof && isSimpleType(name);
	
	if( !name ) return SWIG_OK;

	classname = mangled_sym_name;
	classmode = true;
	int rv = Language::classHandler(n);
	classmode = false;

	if( sizeof_feature ) {
	    Printf( f_wrappers, 
		    "SWIGEXT CAML_VALUE _wrap_%s_sizeof( CAML_VALUE args ) {\n"
		    "    CAMLparam1(args);\n"
		    "    CAMLreturn(Val_int(sizeof(%s)));\n"
		    "}\n",
		    mangled_sym_name, name_normalized );
	    
	    Printf( f_mlbody, "external __%s_sizeof : unit -> int = "
		    "\"_wrap_%s_sizeof\"\n",
		    classname, mangled_sym_name );
	}


	/* Insert sizeof operator for concrete classes */
	if( sizeof_feature ) {
	    Printv(f_class_ctors, "\"sizeof\" , (fun args -> C_int (__",
		   classname, "_sizeof ())) ;\n", NIL);
	}
	/* Handle up-casts in a nice way */
	List *baselist = Getattr(n,"bases");
	if (baselist && Len(baselist)) {
	  Iterator b;
	  b = First(baselist);
	  while (b.item) {
	    String *bname = Getattr(b.item, "name");
	    if (bname) {
	      String *base_create = NewString("");
	      Printv(base_create,"(create_class \"",bname,"\")",NIL);
	      Printv(f_class_ctors,
		     "   \"::",bname,"\", (fun args -> ",
		     base_create," args) ;\n",NIL);
	      Printv( base_classes, base_create, " ;\n", NIL );
	    }
	    b = Next(b);
	  }
	}    
    
	Replaceall(this_class_def,"$classname",classname);
	Replaceall(this_class_def,"$normalized",name_normalized);
	Replaceall(this_class_def,"$realname",name);
	Replaceall(this_class_def,"$baselist",base_classes);
	Replaceall(this_class_def,"$classbody",f_class_ctors);

	Delete(f_class_ctors);
	f_class_ctors = old_class_ctors;

	// Actually write out the class definition

	Multiwrite( this_class_def );

	Setattr(n,"ocaml:ctor",classname);
    
	return rv;
    }
  
    String *normalizeTemplatedClassName( String *name ) {
	String *name_normalized = SwigType_typedef_resolve_all(name);
	bool took_action;
	
	do {
	    took_action = false;

	    if( is_a_pointer(name_normalized) ) {
		SwigType_del_pointer( name_normalized );
		took_action = true;
	    }
    
	    if( is_a_reference(name_normalized) ) {
		oc_SwigType_del_reference( name_normalized );
		took_action = true;
	    }
    
	    if( is_an_array(name_normalized) ) {
		oc_SwigType_del_array( name_normalized );
		took_action = true;
	    }
	} while( took_action );

	return SwigType_str(name_normalized,0);
    }

    /*
     * Produce the symbol name that ocaml will use when referring to the 
     * target item.  I wonder if there's a better way to do this:
     *
     * I shudder to think about doing it with a hash lookup, but that would
     * make a couple of things easier:
     */

    String *mangleNameForCaml( String *s ) {
	String *out = Copy(s);
	Replaceall(out," ","_xx");
	Replaceall(out,"::","_xx");
	Replaceall(out,",","_x");
	Replaceall(out,"+","_xx_plus");
	Replaceall(out,"-","_xx_minus");
	Replaceall(out,"<","_xx_ldbrace");
	Replaceall(out,">","_xx_rdbrace");
	Replaceall(out,"!","_xx_not");
	Replaceall(out,"%","_xx_mod");
	Replaceall(out,"^","_xx_xor");
	Replaceall(out,"*","_xx_star");
	Replaceall(out,"&","_xx_amp");
	Replaceall(out,"|","_xx_or");
	Replaceall(out,"(","_xx_lparen");
	Replaceall(out,")","_xx_rparen");
	Replaceall(out,"[","_xx_lbrace");
	Replaceall(out,"]","_xx_rbrace");
	Replaceall(out,"~","_xx_bnot");
	Replaceall(out,"=","_xx_equals");
	Replaceall(out,"/","_xx_slash");
	Replaceall(out,".","_xx_dot");
	return out;
    }
    
    String *fully_qualify_enum_name( Node *n, String *name ) {
	Node *parent = 0;
	String *qualification = NewString("");
	String *fully_qualified_name = NewString("");
	String *parent_type = 0;
	String *normalized_name;

	parent = parentNode(n);
	while( parent ) {
	    parent_type = nodeType(parent);
	    if( Getattr(parent,"name") ) {
		String *parent_copy = 
		    NewStringf("%s::",Getattr(parent,"name"));
		if( !Cmp(parent_type,"class") || 
		    !Cmp(parent_type,"namespace") ) 
		    Insert(qualification,0,parent_copy);
		Delete(parent_copy);
	    }
	    if( !Cmp( parent_type, "class" ) ) break;
	    parent = parentNode(parent);
	}

	Printf( fully_qualified_name, "%s%s", qualification, name );

	normalized_name = normalizeTemplatedClassName(fully_qualified_name);
	if( !strncmp(Char(normalized_name),"enum ",5) ) {
	    Insert(normalized_name,5,qualification);
	}
	
	return normalized_name;
    }

    /* Benedikt Grundmann inspired --> Enum wrap styles */

    int enumvalueDeclaration(Node *n) {
	String *name = Getattr(n,"name");
	String *qvalue = 0;

	if( name_qualifier ) {
	    qvalue = Copy(name_qualifier);
	    Printv( qvalue, name, NIL );
	}

	if( const_enum && name && !Getattr(seen_enumvalues,name) ) {
	    Setattr(seen_enumvalues,name,"true");
	    Setattr(n,"feature:immutable","1");
	    Setattr(n,"feature:enumvalue","1");

	    if( qvalue ) 
		Setattr(n,"qualified:value",qvalue);

	    String *evname = SwigType_manglestr(qvalue);
	    Insert( evname, 0, "SWIG_ENUM_" );

	    Setattr(n,"feature:enumvname",name);
	    Setattr(n,"feature:symname",evname);
	    Delete( evname );
	    Printf( f_enumtypes_value, "| `%s\n", name );

	    return Language::enumvalueDeclaration(n);
	} else return SWIG_OK;
    }

    /* -------------------------------------------------------------------
     * This function is a bit uglier than it deserves.
     *
     * I used to direct lookup the name of the enum.  Now that certain fixes
     * have been made in other places, the names of enums are now fully
     * qualified, which is a good thing, overall, but requires me to do
     * some legwork.
     *
     * The other thing that uglifies this function is the varying way that
     * typedef enum and enum are handled.  I need to produce consistent names,
     * which means looking up and registering by typedef and enum name. */
    int enumDeclaration(Node *n) {
	String *name = Getattr(n,"name");
	String *oname = name ? NewString(name) : NULL;
	/* name is now fully qualified */
	String *fully_qualified_name = NewString(name);
	bool seen_enum = false;
	if( name_qualifier ) 
	    Delete(name_qualifier);
	char *strip_position;
	name_qualifier = fully_qualify_enum_name(n,NewString(""));
	
	/* Recent changes have distrubed enum and template naming again.
	 * Will try to keep it consistent by can't guarantee much given
	 * that these things move around a lot.
	 *
	 * I need to figure out a way to isolate this module better.
	 */
	if( oname ) {
	    strip_position = strstr(Char(oname),"::");
	    
	    while( strip_position ) {
		strip_position += 2;
		oname = NewString( strip_position );
		strip_position = strstr( Char(oname), "::" );
	    }
	}

	seen_enum = oname ? 
	    (Getattr(seen_enums,fully_qualified_name) ? true : false) : false;

	if( oname && !seen_enum ) {
	    const_enum = true;
	    Printf( f_enum_to_int, "| `%s -> (match y with\n", oname );
	    Printf( f_int_to_enum, "| `%s -> C_enum (\n", oname );
	    /* * * * A note about enum name resolution * * * *
	     * This code should now work, but I think we can do a bit better.
	     * The problem I'm having is that swig isn't very precise about
	     * typedef name resolution.  My opinion is that SwigType_typedef
	     * resolve_all should *always* return the enum tag if one exists,
	     * rather than the admittedly friendlier enclosing typedef.
	     * 
	     * This would make one of the cases below unnecessary. 
	     * * * */
	    Printf( f_mlbody, 
		    "let _ = Callback.register \"%s_marker\" (`%s)\n",
		    fully_qualified_name, oname );
	    if( !strncmp(Char(fully_qualified_name),"enum ",5) ) {
		String *fq_noenum = NewString(Char(fully_qualified_name) + 5);
		Printf( f_mlbody,
			"let _ = Callback.register \"%s_marker\" (`%s)\n"
			"let _ = Callback.register \"%s_marker\" (`%s)\n",
			fq_noenum, oname,
			fq_noenum, name );
	    }

	    Printf( f_enumtypes_type,"| `%s\n", oname );
	    Insert(fully_qualified_name,0,"enum ");
	    Setattr(seen_enums,fully_qualified_name,n);
	}

	int ret = Language::enumDeclaration(n);
	
	if( const_enum ) {
	    Printf( f_int_to_enum, "`Int y)\n" );
	    Printf( f_enum_to_int, 
		    "| `Int x -> Swig.C_int x\n"
		    "| _ -> raise (LabelNotFromThisEnum v))\n" );
	}

	const_enum = false;
	
	return ret;
    }

    /***************************************************************************
     * BEGIN C++ Director Class modifications
     ***************************************************************************/

    /*
     * Modified polymorphism code for Ocaml language module.
     * Original:
     * C++/Python polymorphism demo code, copyright (C) 2002 Mark Rose 
     * <mrose@stm.lbl.gov>
     *
     * TODO
     *
     * Move some boilerplate code generation to Swig_...() functions.
     *
     */

    /* ---------------------------------------------------------------
     * classDirectorMethod()
     *
     * Emit a virtual director method to pass a method call on to the 
     * underlying Python object.
     *
     * --------------------------------------------------------------- */

    int classDirectorMethod(Node *n, Node *parent, String *super) {
	int is_void = 0;
	int is_pointer = 0;
	String *storage;
	String *value;
	String *decl;
	String *type;
	String *name;
	String *classname;
	String *declaration;
	ParmList *l;
	Wrapper *w;
	String *tm;
	String *wrap_args;
	String *return_type;
	int status = SWIG_OK;
	int idx;
	bool pure_virtual = false;

	storage = Getattr(n, "storage");
	value = Getattr(n, "value");
	classname = Getattr(parent, "sym:name");
	type = Getattr(n, "type");
	name = Getattr(n, "name");

	if (Cmp(storage,"virtual") == 0) {
	    if (Cmp(value,"0") == 0) {
		pure_virtual = true;
	    }
	}

	w = NewWrapper();
	declaration = NewString("");
	Wrapper_add_local(w,"swig_result",
			  "CAMLparam0();\n"
			  "SWIG_CAMLlocal2(swig_result,args)");
	
	/* determine if the method returns a pointer */
	decl = Getattr(n, "decl");
	is_pointer = SwigType_ispointer_return(decl);
	is_void = (!Cmp(type, "void") && !is_pointer);

	/* form complete return type */
	return_type = Copy(type);
	{
	    SwigType *t = Copy(decl);
	    SwigType *f = 0;
	    f = SwigType_pop_function(t);
	    SwigType_push(return_type, t);
	    Delete(f);
	    Delete(t);
	}

	/* virtual method definition */
	l = Getattr(n, "parms");
	String *target;
	String *pclassname = NewStringf("SwigDirector_%s", classname);
	String *qualified_name = NewStringf("%s::%s", pclassname, name);
	target = Swig_method_decl(decl, qualified_name, l, 0, 0);
	String *rtype = SwigType_str(type, 0);
	Printf(w->def, "%s %s {", rtype, target);
	Delete(qualified_name);
	Delete(target);
	/* header declaration */
	target = Swig_method_decl(decl, name, l, 0, 1);
	Printf(declaration, "    virtual %s %s;\n", rtype, target);
	Delete(target);
    
	/* attach typemaps to arguments (C/C++ -> Ocaml) */
	String *arglist = NewString("");

	Swig_typemap_attach_parms("in", l, w);
	Swig_typemap_attach_parms("directorin", l, w);
	Swig_typemap_attach_parms("directorout", l, w);
	Swig_typemap_attach_parms("directorargout", l, w);

	Parm* p;
	int num_arguments = emit_num_arguments(l);
	int i;
	char source[256];

	wrap_args = NewString("");
	int outputs = 0;
	if (!is_void) outputs++;

	/* build argument list and type conversion string */
	for (i=0, idx=0, p = l; i < num_arguments; i++) {

	    while (Getattr(p, "tmap:ignore")) {
		p = Getattr(p, "tmap:ignore:next");
	    }

	    if (Getattr(p, "tmap:directorargout") != 0) outputs++;
      
	    String* pname = Getattr(p, "name");
	    String* ptype = Getattr(p, "type");
      
	    Putc(',',arglist);
	    if ((tm = Getattr(p, "tmap:directorin")) != 0) {
		Replaceall(tm, "$input", pname);
		Replaceall(tm, "$owner", "0");
		if (Len(tm) == 0) Append(tm, pname);
		Printv(wrap_args, tm, "\n", NIL);
		p = Getattr(p, "tmap:directorin:next");
		continue;
	    } else
		if (Cmp(ptype, "void")) {
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
			String *nptype = NewString(Char(ptype)+2);
			/* name as pointer */
			String *ppname = Copy(pname);
			if (SwigType_isreference(ptype)) {
			    Insert(ppname,0,"&");
			}
			/* if necessary, cast away const since Python doesn't support it! */
			if (SwigType_isconst(nptype)) {
			    nonconst = NewStringf("nc_tmp_%s", pname);
			    String *nonconst_i = NewStringf("= const_cast<%s>(%s)", SwigType_lstr(ptype, 0), ppname);
			    Wrapper_add_localv(w, nonconst, SwigType_lstr(ptype, 0), nonconst, nonconst_i, NIL);
			    Delete(nonconst_i);
			    Swig_warning(WARN_LANG_DISCARD_CONST, input_file, line_number,
					 "Target language argument '%s' discards const in director method %s::%s.\n", SwigType_str(ptype, pname), classname, name);
			} else {
			    nonconst = Copy(ppname);
			}
			Delete(nptype);
			Delete(ppname);
			String *mangle = SwigType_manglestr(ptype);
			if (target) {
			    String *director = NewStringf("director_%s", mangle);
			    Wrapper_add_localv(w, director, "Swig::Director *", director, "= 0", NIL);
			    Wrapper_add_localv(w, source, "CAML_VALUE", source, "= Val_unit", NIL);
			    Printf(wrap_args, "%s = dynamic_cast<Swig::Director *>(%s);\n", director, nonconst);
			    Printf(wrap_args, "if (!%s) {\n", director);
			    Printf(wrap_args,   "%s = SWIG_NewPointerObj(%s, SWIGTYPE%s, 0);\n", source, nonconst, mangle);
			    Printf(wrap_args, "} else {\n");
			    Printf(wrap_args,   "%s = %s->swig_get_self();\n", source, director);
			    Printf(wrap_args, "}\n");
			    Delete(director);
			    Printv(arglist, source, NIL);
			} else {
			    Wrapper_add_localv(w, source, "CAML_VALUE", source, "= Val_unit", NIL);
			    Printf(wrap_args, "%s = SWIG_NewPointerObj(%s, SWIGTYPE%s, 0);\n", 
				   source, nonconst, mangle); 
			    //Printf(wrap_args, "%s = SWIG_NewPointerObj(%s, SWIGTYPE_p_%s, 0);\n", 
			    //       source, nonconst, base);
			    Printv(arglist, source, NIL);
			}
			Delete(mangle);
			Delete(nonconst);
		    } else {
			Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file, line_number,
				     "Unable to use type %s as a function argument in director method %s::%s (skipping method).\n", SwigType_str(ptype, 0), classname, name);
			status = SWIG_NOWRAP;
			break;
		    }
		}
	    p = nextSibling(p);
	}

	/* declare method return value 
	 * if the return value is a reference or const reference, a specialized typemap must
	 * handle it, including declaration of c_result ($result).
	 */
	if (!is_void) {
	    Wrapper_add_localv(w, "c_result", SwigType_lstr(return_type, "c_result"), NIL);
	}

	Printv(w->code, "swig_result = Val_unit;\n",0);
	Printf(w->code,"args = Val_unit;\n");

	/* direct call to superclass if _up is set */
	if( pure_virtual ) {
	    Printf(w->code, "if (swig_get_up()) {\n");
	    Printf(w->code, "  throw Swig::DirectorPureVirtualException();\n");
	    Printf(w->code, "}\n");
	} else {
	    Printf(w->code, "if (swig_get_up()) {\n");
	    Printf(w->code,   "CAMLreturn(%s);\n", Swig_method_call(super,l));
	    Printf(w->code, "}\n");
	}
    
	/* wrap complex arguments to values */
	Printv(w->code, wrap_args, NIL);

	/* pass the method call on to the Python object */
	Printv(w->code,
	       "swig_result = caml_swig_alloc(1,C_list);\n"
	       "SWIG_Store_field(swig_result,0,args);\n"
	       "args = swig_result;\n"
	       "swig_result = Val_unit;\n",0);
	Printf(w->code, 
	       "swig_result = "
	       "callback3(*caml_named_value(\"swig_runmethod\"),"
	       "swig_get_self(),copy_string(\"%s\"),args);\n",
	       Getattr(n,"name"));
	/* exception handling */
	tm = Swig_typemap_lookup_new("director:except", n, "result", 0);
	if (!tm) {
	    tm = Getattr(n, "feature:director:except");
	}
	if ((tm) && Len(tm) && (Strcmp(tm, "1") != 0)) {
	    Printf(w->code, "if (result == NULL) {\n");
	    Printf(w->code, "  CAML_VALUE error = *caml_named_value(\"director_except\");\n");
	    Replaceall(tm, "$error", "error");
	    Printv(w->code, Str(tm), "\n", NIL);
	    Printf(w->code, "}\n");
	}

	/*
	 * Python method may return a simple object, or a tuple.
	 * for in/out aruments, we have to extract the appropriate values from the 
	 * argument list, then marshal everything back to C/C++ (return value and
	 * output arguments).
	 */

	/* marshal return value and other outputs (if any) from value to C/C++ 
	 * type */

	String* cleanup = NewString("");
	String* outarg = NewString("");

	idx = 0;

	/* this seems really silly.  the node's type excludes 
	 * qualifier/pointer/reference markers, which have to be retrieved 
	 * from the decl field to construct return_type.  but the typemap
	 * lookup routine uses the node's type, so we have to swap in and
	 * out the correct type.  it's not just me, similar silliness also
	 * occurs in Language::cDeclaration().
	 */
	Setattr(n, "type", return_type);
	tm = Swig_typemap_lookup_new("directorout", n, "c_result", w);
	Setattr(n, "type", type);
	if (tm == 0) {
	    String *name = NewString("c_result");
	    tm = Swig_typemap_search("directorout", return_type, name, NULL);
	    Delete(name);
	}
	if (tm != 0) {
	    Replaceall(tm, "$input", "swig_result");
	    /* TODO check this */
	    if (Getattr(n,"wrap:disown")) {
		Replaceall(tm,"$disown","SWIG_POINTER_DISOWN");
	    } else {
		Replaceall(tm,"$disown","0");
	    }
	    Replaceall(tm, "$result", "c_result");
	    Printv(w->code, tm, "\n", NIL);
	}
	  
	/* marshal outputs */
	for (p = l; p; ) {
	    if ((tm = Getattr(p, "tmap:directorargout")) != 0) {
		Replaceall(tm, "$input", "swig_result");
		Replaceall(tm, "$result", Getattr(p, "name"));
		Printv(w->code, tm, "\n", NIL);
		p = Getattr(p, "tmap:directorargout:next");
	    } else {
		p = nextSibling(p);
	    }
	}

	/* any existing helper functions to handle this? */
	if (!is_void) {
	    /* A little explanation:
	     * The director_enum test case makes a method whose return type
	     * is an enum type.  return_type here is "int".  gcc complains
	     * about an implicit enum conversion, and although i don't strictly
	     * agree with it, I'm working on fixing the error:
	     *
	     * Below is what I came up with.  It's not great but it should
	     * always essentially work.
	     */
	    if( !SwigType_isreference(return_type) ) {
		Printf(w->code, "CAMLreturn((%s)c_result);\n",
		       SwigType_lstr(return_type, ""));
	    } else {
		Printf(w->code, "CAMLreturn(*c_result);\n");
	    }
	}

	Printf(w->code, "}\n");

	/* emit the director method */
	if (status == SWIG_OK) {
          if (!Getattr(n,"defaultargs")) {
	    Wrapper_print(w, f_directors);
	    Printv(f_directors_h, declaration, NIL);
          }
	}

	/* clean up */
	Delete(wrap_args);
	Delete(arglist);
	Delete(rtype);
	Delete(return_type);
	Delete(pclassname);
	Delete(cleanup);
	Delete(outarg);
	DelWrapper(w);
	return status;
    }

    /* ------------------------------------------------------------
     * classDirectorConstructor()
     * ------------------------------------------------------------ */

    int classDirectorConstructor(Node *n) {
	Node *parent = Getattr(n, "parentNode");
	String *sub = NewString("");
	String *decl = Getattr(n, "decl");
	String *supername = Swig_class_name(parent);
	String *classname = NewString("");
	Printf(classname, "SwigDirector_%s", supername);

	/* insert self parameter */
	Parm *p, *q;
	ParmList *superparms = Getattr(n, "parms");
	ParmList *parms = CopyParmList(superparms);
	String *type = NewString("CAML_VALUE");
	p = NewParm(type, NewString("self"));
	q = Copy(p);
	set_nextSibling(q, superparms);
	set_nextSibling(p, parms);
	parms = p;

        if (!Getattr(n,"defaultargs")) {
          /* constructor */
          {
              Wrapper *w = NewWrapper();
              String *call;
              String *basetype = Getattr(parent, "classtype");
              String *target = Swig_method_decl(decl, classname, parms, 0, 0);
              call = Swig_csuperclass_call(0, basetype, superparms);
              Printf( w->def, "%s::%s: %s, Swig::Director(self) { }", classname, target, call );
              Delete(target);
              Wrapper_print(w, f_directors);
              Delete(call);
              DelWrapper(w);
          }
      
          /* constructor header */
          {
              String *target = Swig_method_decl(decl, classname, parms, 0, 1);
              Printf(f_directors_h, "    %s;\n", target);
              Delete(target);
          }
        }

	Setattr(n,"parms",q);
	Language::classDirectorConstructor(n);

	Delete(sub);
	Delete(classname);
	Delete(supername);
	//Delete(parms);	

	return SWIG_OK;
    }

    /* ------------------------------------------------------------
     * classDirectorDefaultConstructor()
     * ------------------------------------------------------------ */
   
    int classDirectorDefaultConstructor(Node *n) {
	String *classname;
	classname = Swig_class_name(n);

	/* insert self parameter */
	Parm *p, *q;
	ParmList *superparms = Getattr(n, "parms");
	ParmList *parms = CopyParmList(superparms);
	String *type = NewString("CAML_VALUE");
	p = NewParm(type, NewString("self"));
	q = Copy(p);
	set_nextSibling(p, parms);
	parms = p;

	{
	    Wrapper *w = NewWrapper();
	    Printf(w->def, "SwigDirector_%s::SwigDirector_%s(CAML_VALUE self) : Swig::Director(self) { }", classname, classname);
	    Wrapper_print(w, f_directors);
	    DelWrapper(w);
	}
	Printf(f_directors_h, "    SwigDirector_%s(CAML_VALUE self);\n", classname);
	Delete(classname);
	Setattr(n,"parms",q);
	return Language::classDirectorDefaultConstructor(n);
    }

    int classDirectorInit( Node *n ) {
	String *declaration = Swig_director_declaration(n);
	Printf( f_directors_h, 
		"\n"
		"%s\n"
		"public:\n", declaration );
	Delete( declaration );
	return Language::classDirectorInit( n );
    }

    int classDirectorEnd( Node *n ) {
	Printf( f_directors_h, "};\n\n" );
	return Language::classDirectorEnd( n );
    }

    /* ---------------------------------------------------------------------
     * typedefHandler
     *
     * This is here in order to maintain the correct association between
     * typedef names and enum names. 
     *
     * Since I implement enums as polymorphic variant tags, I need to call
     * back into ocaml to evaluate them.  This requires a string that can
     * be generated in the typemaps, and also at SWIG time to be the same
     * string.  The problem that arises is that SWIG variously generates
     * enum e_name_tag
     * e_name_tag
     * e_typedef_name
     * for
     * typedef enum e_name_tag { ... } e_typedef_name;
     * 
     * Since I need these strings to be consistent, I must maintain a correct
     * association list between typedef and enum names.
     * --------------------------------------------------------------------- */
    int typedefHandler( Node *n ) {
        String *type = Getattr(n,"type");
	Node *enum_node = type ? 
	    Getattr(seen_enums,type) : 0;
	if( enum_node ) {
	    String *name = Getattr(enum_node,"name");

	    Printf( f_mlbody, 
		    "let _ = Callback.register \"%s_marker\" (`%s)\n",
		    Getattr(n,"name"), name );
	    
	}
	return SWIG_OK;
    }

    String *runtimeCode() {
      String *s = Swig_include_sys("ocaml.swg");
      if (!s) {
        Printf(stderr, "*** Unable to open 'ocaml.swg'\n");
        s = NewString("");
      }
      return s;
    }

    String *defaultExternalRuntimeFilename() {
      return NewString("swigocamlrun.h");
    }
};

/* -------------------------------------------------------------------------
 * swig_ocaml()    - Instantiate module
 * ------------------------------------------------------------------------- */

static Language * new_swig_ocaml() {
    return new OCAML();
}
extern "C" Language * swig_ocaml(void) {
    return new_swig_ocaml();
}

