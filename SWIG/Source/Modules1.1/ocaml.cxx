/******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 *
 * Modified for Ocaml from mzscheme.cxx by Art Yerkes
 * Modifications from Benedikt Grundmann (bgrundmann@gmx.net):
 *
 *  Constants as values
 *  Enums as proper ocaml types
 *
 * Original Author : David Beazley
 *
 * Department of Computer Science
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *****************************************************************************/

static char cvsroot[] = "$Header$";

/***********************************************************************
 * $Header$
 *
 * ocaml.cxx
 *
 * Definitions for adding functions to Ocaml 101
 ***********************************************************************/

#include "swigmod.h"
#include <ctype.h>

/* Extern items from the swig system */
extern "C" int SwigType_isenum(SwigType *t);
extern void emit_one( Node *n );

static char *ocaml_usage = (char*)
    ("\n"
     "Ocaml Options (available with -ocaml)\n"
     "-help           - Print this help\n"
     "-objects        - Use objects\n"
     "-onlyobjects    - Only export an object interface to a C++ object\n"
     "-modwrap name   - Wrap in module 'Name'\n"
     "-mlout name     - Specify the ML output file name\n"
     "\n");
static const char *ocaml_path = "ocaml";

/* Data used by more than one handler */

#define VWRAP_SET 1
#define VWRAP_GET 2

static int in_constructor = 0;   /* Is this function a constructor */
static int in_destructor = 0;    /* Is this function a destructor */
static int in_copyconst = 0;     /* Copy constructor */
static int in_vwrap = 0;         /* Vwrap cycle */
static int const_enum;           /* Is this constant an enum label */
static int classmode;            /* Are we in a class definition */
static int error_count;          /* Number of errors encountered */
static int objects = 0;		 /* Use objects. */
static int onlyobjects = 0;	 /* Do not export functions that back
				    methods. */
static int mliout = 0;		 /* Are we in .mli file */

static String *classname = NULL; /* Name of the current class */

/* Wrapmod */

static String *wrapmod = NULL;   /* Non-null if we want an additional module
				    wrapper. */
static String *module = NULL;    /* Module name */
static String *modfile_cmd = NULL;/* Command-line specified .ml output file */

/* C(++) output */
static String *f_init = NULL;
static String *f_header = NULL;
static String *f_init_fn = NULL;
static String *f_runtime = NULL;
static String *f_wrappers = NULL;

/* Ocaml output */
static String *f_module = NULL;       /* Main body of the module file */
static String *f_module_file = NULL;  /* Module file itself */
static String *f_modclass = NULL;     /* Class definitions */
static String *f_pvariant_def = NULL; /* Polymorphic variant definition at
					 top of file. */
static String *f_pvariant_value = NULL; /* Function to get the int value of a
					   polymorphic variant label */
static String *f_pvariant_to_int = NULL; /* enum_to_int definition. */
static String *f_pvariant_from_int = NULL; /* int_to_enum definition. */

/* Lists */
static Hash *seen_deleters = NULL;    /* A delete function is in here if we
					 have touched it before.  This allows
					 the deleter to be installed in the
					 custom_operations block on new */
static Hash *seen_types = NULL;       /* Types we have emitted so far. */
static Hash *seen_classes = NULL;     /* Classes emitted so far. */
static Hash *seen_names = NULL;       /* The list of seen names */
static Hash *seen_methods = NULL;     /* Seen methods */
static Hash *seen_wrappers = NULL;    /* Seen wrappers */

static char *simple_types[][2] = {
    { "_bool", "bool" },
    { "_void", "unit" },
    { "_int", "int" },
    { "_short", "int" },
    { "_long", "int64" },
    { "_unsigned_long", "int64" },
    { "_char", "char" },
    { "_p_char", "string" },
    { "_float", "float" },
    { "_double", "float" },
    { "_oc_bool", "bool" },
    { "_unsigned_int", "int32" },
    { "_unsigned_short", "int" },
    { "_unsigned_char", "char" }, 
    { "_long_long", "int64" },
    { "_unisgned_long_long", "int64" },
    { NULL, NULL }
};

// ---------------------------------------------------------------------
// main()
//
// Parse arguments.
// ---------------------------------------------------------------------

class OCAML : public Language {
    virtual void main (int argc, char *argv[]) {
	int i;
	
	SWIG_library_directory(ocaml_path);
	
	wrapmod = NULL;
	modfile_cmd = NULL;
	
	onlyobjects = 0;
	objects = 0;
	
	// Look for certain command line options
	for (i = 1; i < argc; i++) {
	    if (argv[i]) {
		if (strcmp (argv[i], "-help") == 0) {
		    fputs (ocaml_usage, stderr);
		    SWIG_exit (0);
		}
		else if (strcmp (argv[i], "-mlout") == 0) {
		    if( argv[i + 1] ) {
			modfile_cmd = NewString( argv[i + 1] );
			Swig_mark_arg (i);
			Swig_mark_arg (i + 1);
			i++;
		    } else {
			Swig_arg_error();
		    }
		}
		else if (strcmp (argv[i], "-onlyobjects") == 0) {
		    onlyobjects = 1;
		    Swig_mark_arg (i);
		}
		else if (strcmp (argv[i], "-objects") == 0) {
		    objects = 1;
		    Swig_mark_arg (i);
		}
		else if (strcmp (argv[i], "-modwrap") == 0) {
		    if( argv[i + 1] ) {
			wrapmod = NewString( argv[i + 1] );
			Swig_mark_arg (i);
			Swig_mark_arg (i + 1);
			i++;
		    } else {
			Swig_arg_error();
		    }
		}
	    }
	}
	
	// Add a symbol for this module
	
	Preprocessor_define ((void *) "SWIGOCAML",0);
	Preprocessor_define ("SWIG_NO_OVERLOAD 1", 0);    
	
	// Set name of typemaps
	SWIG_typemap_lang("ocaml");
	
	// Read in default typemaps */
	SWIG_config_file("ocaml.i");
    }
    
    void print_unseen_type( String *type ) {
	String *rtype = mangle_type(SwigType_typedef_resolve_all(type));
	String *ntype = mangle_type(type);
	
	if( Getattr(seen_types,ntype) ) return;
	else {
	    if( Getattr(seen_types,rtype) ) {
		Setattr(seen_types,ntype,rtype);
		Printf(f_module,"  type %s = %s\n", ntype, rtype );
	    } else {
		Setattr(seen_types,ntype,ntype);
		Printf(f_module,"  type %s\n", ntype );
	    }
	}
    }

// --------------------------------------------------------------------
// top()
// --------------------------------------------------------------------
    int 
    top(Node *n) {
	String *modfile = NULL;

	assert(Getattr(n,"name"));
	set_module(Char(Getattr(n,"name")));

	if( modfile_cmd ) {
	    if( modfile ) Delete( modfile );
	    modfile = Copy(modfile_cmd);
	}

	if( !modfile ) {
	    modfile = Copy(module);
	    Printf(modfile, ".ml");
	}

	mliout = 0;
	processInterface( modfile, n );

	String *tmp = NewString(Char(modfile));
	Delete(modfile);
	modfile = NewString("");
	Printf(modfile,"%si", tmp); // Append 'i' to make .mli
	Delete(tmp);

	mliout = 1;
	return processInterface( modfile, n );
    }

    int
    processInterface( String *modfile, Node *n ) {
	/* Initialize all of the output files */
	String *outfile = Getattr(n,"outfile");
	
	classmode = 0;
	const_enum = 0;
	
	if( !outfile || !modfile ) {
	    Printf(stderr,"%s name was not set.\n", 
		   (!outfile) ? "Output file" : "Module file");
	    SWIG_exit(EXIT_FAILURE);
	}
	
	if( mliout ) 
	    f_runtime = NewString("");
	else
	    f_runtime = NewFile(outfile,"w");
	
	if (!f_runtime) {
	    Printf(stderr,"*** Can't open '%s'\n", outfile);
	    SWIG_exit(EXIT_FAILURE);
	}
	
	f_module_file = NewFile(modfile,"w");
	if (!f_module_file) {
	    Printf(stderr,"*** Can't open '%s'\n", modfile);
	    SWIG_exit(EXIT_FAILURE);
	}
	
	classname = NewString("");
	f_module = NewString("");
	
	Printf(f_module_file,
	       "(* -*- buffer-read-only: t -*- vi: set ro: *)\n");
	if( !mliout ) {
	    Printf(f_module_file,"open Int32\n" );
	    Printf(f_module_file,"open Int64\n" );
	}
	
	if( wrapmod )
	    Printf(f_module_file,"module %s = struct\n",wrapmod);
	
	seen_types = NewHash();
	seen_deleters = NewHash();
	seen_classes = NewHash();
	seen_names = NewHash();
	seen_wrappers = NewHash();
	seen_methods = NewHash();
    
	
	int i;
	
	// I starts at one here to skip the _enum type.
	for( i = 0; simple_types[i][0]; i++ ) {
	    Printf(f_module, "type %s = %s\n", 
		   simple_types[i][0], simple_types[i][1] );
	    Setattr(seen_types,simple_types[i][0],
		    NewString(simple_types[i][1]));
	}
	
	f_init = NewString("");
	f_header = NewString("");
	f_init_fn = NewString("");
	f_wrappers = NewString("");
	f_modclass = NewString("");
	
	f_pvariant_def = NewString("");
	f_pvariant_value = NewString("");
	f_pvariant_to_int = NewString("");
	f_pvariant_from_int = NewString("");
	
	/* Register file targets with the SWIG file handler */
	Swig_register_filebyname("header",f_header);
	Swig_register_filebyname("wrapper",f_wrappers);
	Swig_register_filebyname("runtime",f_runtime);
	Swig_register_filebyname("init",f_init_fn);
	
	Printf(f_runtime, 
	       "/* -*- buffer-read-only: t -*- vi: set ro: */\n");
	Swig_banner (f_runtime);
	
	if (NoInclude) {
	    Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
	}

	/* Produce the enum_to_int and int_to_enum functions */
	Printf( f_wrappers,
	        "static int enum_to_int( char *nm, value v ) {\n"
	        "  value *en_to_int_cb = "
	        "caml_named_value(nm);\n"
	        "  return Int_val(callback(*en_to_int_cb,v));\n"
	        "}\n"
	        "static value int_to_enum( char *nm, int v ) {\n"
	        "  value *int_to_en_cb = "
	        "caml_named_value(nm);\n"
	        "  return callback(*int_to_en_cb,Val_int(v));\n"
	        "}\n" );
	
	Printf( f_init_fn,
		"#ifdef __cplusplus\n"
		"extern \"C\"\n"
		"#endif\n"
		"value _wrapper_init_fn(value v) {\n"
		"  CAMLparam1(v);\n");
	
	Swig_name_register((char *)"get",(char *)"%v_get");
	Swig_name_register((char *)"set",(char *)"%v_set");

	Language::top(n);
	
	Printf( f_init_fn,
		"\n"
		"  CAMLreturn(Val_unit);\n"
		"}\n\n" );
	
	SwigType_emit_type_table (f_runtime, f_wrappers);
	
	Dump(f_pvariant_def,f_module_file);
	Dump(f_module,f_module_file);
	Dump(f_modclass,f_module_file);
	
	// *** Polymorphic variant support ***
	Dump(f_pvariant_from_int,f_module_file);
	Dump(f_pvariant_to_int,f_module_file);
	
	/* Close all of the files */
	if( wrapmod )
	    Printf(f_module_file,"end\n",wrapmod);
	
	Dump(f_header,f_runtime);
	
	Dump(f_wrappers,f_runtime);
	Dump(f_init_fn,f_runtime);
	Wrapper_pretty_print(f_init,f_runtime);
	
	// Init function support in module
	if( !mliout )
	    Printf(f_module_file,
		   "external _wrapper_init_fn : unit -> unit = "
		   "\"_wrapper_init_fn\"\n"
		   "let _ = _wrapper_init_fn ()\n");
	
	Delete(f_header);
	Delete(f_wrappers);
	Delete(f_init);
	Delete(f_init_fn);
	
	if( !mliout ) 
	    Close(f_runtime);
	
	Close(f_module_file);
	Delete(f_runtime);
	Delete(f_module);
	Delete(f_module_file);
	
	return SWIG_OK;
    }

//----------------------------------------------------------------------
// Words must start lower case in ocaml except as module names or labels
// Also guard against ocaml keywords
//----------------------------------------------------------------------

    void lcase(String *out) {
	if( isupper((Char(out))[0]) ||
	    banned_word(Char(out)) ||
	    (Char(out))[0] == '_' ) // leading caps are special in ocaml
	    Insert(out,0,"_");      // The '_' handling removes the
	                            // possibility of overlapping names.
    }
       
// ---------------------------------------------------------------------
// set_module(char *mod_name)
//
// Sets the module name.
// Does nothing if it's already set (so it can be overridden as a command
// line option).
//
//----------------------------------------------------------------------

    void set_module (char *mod_name) {
	module = NewString(mod_name);
    }
    
//----------------------------------------------------------------------
// Get a name that works as a C symbol name
//----------------------------------------------------------------------
    
    String *get_wrapper_name( Node *n ) {
	String *out = get_function_name(n);
	Insert(out,0,"_wrap_");
	return out;
    }

//----------------------------------------------------------------------
// Given a function name, return an ocaml name that works as a function
// name.
// If in_constructor or in_destructor, then 
//----------------------------------------------------------------------

    String *get_function_name( Node *n ) {
	String *name = Getattr(n,"origname");
	char *fname;
	const char *prefix = 
	    in_constructor ? 
	    (in_copyconst ? "copy_" : "new_") :
	    in_destructor ? "delete_" : "";

	if( !name ) name = Getattr(n,"name");
	fname = Char(name);

	String *out = NewString(prefix);
	Printf(out,"%s",fname);

	if( classmode && !in_constructor ) {
	    Insert(out,0,"::");
	    Insert(out,0,classname);
	}

	Replaceall(out,"::","_");
	Replaceall(out,"<","T_");
	Replaceall(out,"(","P_");
	Replaceall(out,")","_p");
	Replaceall(out,">","_t");
	Replaceall(out,",","X");
	Replaceall(out,".","O");
	Replaceall(out," ","_");
	Replaceall(out,"~","");

	if( in_vwrap == VWRAP_SET ) 
	    out = Swig_name_set(out);
	else if( in_vwrap == VWRAP_GET )
	    out = Swig_name_get(out);

	return out;
    }

    String *get_ml_function_name( Node *n ) {
	String *out = get_function_name(n);
	lcase(out);

	return out;
    }

    String *get_ml_method_name( Node *n ) {
	char *fname = GetChar(n,"name");
	char *last_comp = strstr(fname,"::");
	if( !last_comp ) last_comp = fname;

	while( *last_comp == ':' ) last_comp++;

	String *out;

	if( *last_comp == '~' ) out = NewString("delete");
	else out = NewString(last_comp);

	if( in_vwrap == VWRAP_SET ) 
	    out = Swig_name_set(out);
	else if( in_vwrap == VWRAP_GET )
	    out = Swig_name_get(out);

	Replaceall(out,"<","T_");
	Replaceall(out,"(","P_");
	Replaceall(out,")","_p");
	Replaceall(out,">","_t");
	Replaceall(out,",","X");
	Replaceall(out,".","O");
	Replaceall(out," ","_");

	lcase(out);

	return out;
    }

//----------------------------------------------------------------------
// Generate a usable class name
//----------------------------------------------------------------------

    String *get_ml_class_name( char *cname ) {
	char *c = strrchr(cname,':');

	if( !c ) c = cname; else c++;

	String *out = NewString(cname);
	Replaceall(out,"::","_");
	Replaceall(out,"<","T_");
	Replaceall(out,"(","P_");
	Replaceall(out,")","_p");
	Replaceall(out,">","_t");
	Replaceall(out,",","X");
	Replaceall(out,".","O");
	Replaceall(out," ","_");

	lcase(out);

	return out;
    }

//----------------------------------------------------------------------
// Generate a usable class pointer type
//----------------------------------------------------------------------

    String *get_ml_class_type( SwigType *classtype ) {
	String *out = Copy(classtype);
	Replaceall(out,"::","_");

	return out;
    }

//-----------------------------------------------------------------------
// True if the word is a keyword in ocaml
//-----------------------------------------------------------------------

    String *uniqueify(Hash *h,char *word) {
	int x = 1;
	String *out = NewString(word);
    
	while( Getattr(h,out) ) {
	    Delete( out );
	    out = NewString( "" );
	    Printf( out, "%s_%d", word, x );
	    x++;
	}

	return out;
    }

    int banned_word(char *word) {
	char *keywords[] = { "type", "class", "object", "true", "false",
			     "val", "function", "fun", "let", "rec",
			     "char", "int", "bool", "string", "end",
			     "begin", "in", "match", "with", "try",
			     "new", "method", "struct", "val",
			     NULL };
	int i;

	for( i = 0; keywords[i]; i++ )
	    if( !strcmp( word, keywords[i] ) ) return 1;
	return 0;
    }

    void throw_unhandled_ocaml_type_error (SwigType *d) {
	Printf (stderr, "%s : Line %d. Unable to handle type %s.\n", 
		input_file, line_number, SwigType_str(d,0));
	error_count++;
    }

    void delete_replacement(SwigType *tm, SwigType *d) {
	String *delete_fn = NewString("");
	SwigType *dcaml_deref = Copy(d);
	String *dcaml_delete = mangle_type(dcaml_deref);
    
	if( Getattr(seen_deleters, dcaml_delete) )
	    Printf( delete_fn, "%s", Getattr(seen_deleters,dcaml_delete) );
	else
	    Printf( delete_fn, "_wrap_delete_void" );
    
	Replaceall( tm, "$delete_fn", delete_fn );

	Delete(delete_fn);
	Delete(dcaml_deref);
	Delete(dcaml_delete);
    }

/* Return true iff T is a pointer type */

    int is_enum(SwigType *t) {
	return SwigType_isenum(SwigType_typedef_resolve_all(t));
    }

    int is_a_pointer (SwigType *t) {
	return SwigType_ispointer(SwigType_typedef_resolve_all(t)) ||
	    !strncmp(Char(mangle_type(t)),"_p",2);
    }
    
    int is_simple (SwigType *t) {
	int i;
	String *str = mangle_type(SwigType_typedef_resolve_all(t));
	
	for( i = 0; simple_types[i][0]; i++ )
	    if( !strcmp( Char(str), simple_types[i][0] ) ) return 1;
	
	return is_enum(t);
    }
    
    SwigType *process_type( SwigType *t ) { 
        // Return a SwigType that's liveable for ocaml
	if( !is_enum(t) && !is_simple(t) && !is_a_pointer(t) ) {
	    SwigType *tt = Copy(t);
	    SwigType_add_pointer(tt);
	    return Copy(tt);
	} else {
	    return Copy(t);
	}
    }

    String *mangle_type( SwigType *t ) {
	if( is_enum( t ) ) {
	    String *s = NewString("");

	    if( !strncmp( Char(t), "enum ", 5 ) ) {
		Printf(s, "_%s", Char(t)+5);
	    } else
		Printf(s, "_%s", t);

	    char *c = strrchr( Char(s), ':' );
	    if( c ) {
		c++;
		Delete(s);
		s = NewString("");
		Printf(s, "_%s", c );
	    }

	    Setattr(seen_types,s,s);

	    return Copy(s);
	} else
	    return Copy(SwigType_manglestr(t));
    }

    /* Output a method version of this function */
    void print_method( Node *n ) {
	String *ml_function_name = Getattr(n,"funcname");
	String *ml_method_name = Getattr(n,"methodname");

	SwigType *dcaml = process_type(Getattr(n,"type"));

	ParmList *l = Getattr(n,"parms");
	Parm *p;

	Printf( f_modclass, "  method %s", 
		ml_method_name );

	int numargs = emit_num_arguments(l);	
	
	if( mliout ) {
	    if( numargs > 1 ) {
		Printf( f_modclass, " : (" );
		
		p = l; if( p ) p = nextSibling(p);
		while( p ) {
		    SwigType *tcaml = process_type(Getattr(p,"type"));
		    Printf(f_modclass, "%s", 
			   mangle_type(tcaml));
		    p = nextSibling(p);
		    if( p ) Printf(f_modclass," * ");
		    Delete(tcaml);
		}
		
		Printf( f_modclass, ") -> %s\n",
			mangle_type(dcaml) );
	    } else {
		Printf( f_modclass, " : %s\n", 
			mangle_type(dcaml) );
	    }
	} else {
	    char x = 'a';
	    
	    if( numargs > 1 ) 
		Printf( f_modclass, " (" );
	    
	    p = l; if( p ) p = nextSibling(p);
	    while( p ) {
		Printf(f_modclass, "%c", x);
		++x;
		p = nextSibling(p);
		if( p ) Printf(f_modclass,",");
	    }
	    
	    Printf( f_modclass, "%s", numargs > 1 ? ")" : "" );
	    
	    Printf( f_modclass, " = %s ", 
		    ml_function_name );
	    
	    if( numargs != 1 )
		Printf( f_modclass, "(" );
	    if( numargs > 0 ) 
		Printf( f_modclass, "(Obj.magic c_self)" );
	    if( numargs > 1 ) 
		Printf( f_modclass, "," );
	    
	    x = 'a';
	    
	    p = l; if( p ) p = nextSibling(p);
	    while( p ) {
		Printf(f_modclass, "%c", x);
		++x;
		p = nextSibling(p);
		if( p ) Printf(f_modclass,",");
	    }
	    
	    if( numargs != 1 ) 
		Printf( f_modclass, ")" );
	    
	    Printf( f_modclass, "\n" );
	}

	Delete(ml_function_name);
	Delete(ml_method_name);
    }

// ----------------------------------------------------------------------
// functionWrapper()
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

    int functionWrapper(Node *n) {
	// ML function name
	SwigType *d = Getattr(n,"type");
	SwigType *dcaml;
	ParmList *l = Getattr(n,"parms");
	Parm *p;
	Wrapper *f = NewWrapper();
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

	// Potentially, do type substitution
	if( !d ) dcaml = NewString("int");
	else dcaml = process_type(d);
	if( !dcaml ) dcaml = NewString("int");

	// Don't produce a 'set' for an immutable.
	if( in_vwrap == VWRAP_SET && Getattr(n,"feature:immutable") )
	    in_vwrap = VWRAP_GET;

	// Make a function name
	String *ml_function_name = uniqueify(seen_names,
					     Char(get_ml_function_name(n)));
	Setattr(seen_names,ml_function_name,ml_function_name);

	// Make a wrapper name
	String *wrap_name = uniqueify(seen_wrappers,
				      Char(get_wrapper_name(n)));
	Setattr(seen_wrappers,wrap_name,wrap_name);

	// Set the symbol name
	Setattr(n,"sym:name",Char(wrap_name));
	Setattr(n,"funcname",Char(ml_function_name));

	// Output the return type and argument types if they don't
	// exist already.
	print_unseen_type( dcaml );
	for(p = l; p;) {
	    SwigType *tcaml = process_type(Getattr(p,"type"));
	    print_unseen_type( tcaml );
	    p = nextSibling(p);
	    Delete(tcaml);
	}

	// writing the function wrapper function
	Printf(f->def, 
	       "#ifdef __cplusplus\n"
	       "extern \"C\"\n"
	       "#endif\n"
	       "value %s( value args )\n"
	       "{\n"
	       "\tCAMLparam1(args);\n", wrap_name);
    
	// Declare return variable and arguments
	// number of parameters
	// they are called arg0, arg1, ...
	// the return value is called result
    
	emit_args(d, l, f);

	/* Attach the standard typemaps */
	emit_attach_parmmaps(l,f);
	
	numargs = emit_num_arguments(l);
	numreq  = emit_num_required(l);
	
	// adds local variables
	Wrapper_add_local(f, "swig_result", "CAMLlocal1(swig_result)");
	
	// Now write code to extract the parameters (this is super ugly)

	for (i = 0, p = l; i < numargs; i++) {
	    /* Skip ignored arguments */
	    while (Getattr(p,"tmap:ignore")) {
		p = Getattr(p,"tmap:ignore:next");
	    }

	    String   *ln = Getattr(p,"lname");

	    // Produce names of source and target
	    Clear(source);
	    Clear(target);
	    Clear(arg);
	    if( numargs == 1 ) 
		Printf(source, "args");
	    else 
		Printf(source, "Field(args,%d)", i);
	    Printf(target, "%s",ln);
	    Printv(arg, Getattr(p,"name"),0);

	    // Handle parameter types.
	    if ((tm = Getattr(p,"tmap:in"))) {
		Replace(tm,"$input",source,DOH_REPLACE_ANY);
		Setattr(p,"emit:input",source);
		Printv(f->code, tm, "\n", 0);
		p = Getattr(p,"tmap:in:next");
	    } else {
		// no typemap found
		// check if typedef and resolve
		Printf(f->code,"\tfailwith(\"Type error\");\n");
		p = nextSibling(p);
	    }
	}

	// Write out signature for function in module file
	if( !classmode || !onlyobjects || !mliout ||
	    in_constructor || in_destructor ) {
	    Printf(f_module, "  external %s : ", ml_function_name);
	
	    if( numargs == 0 ) 
		Printf(f_module," unit");
	    else if( numargs != 1 ) Printf(f_module,"(");
	
	    for(p = l; p;) {
		SwigType *tcaml = process_type(Getattr(p,"type"));
		Printf(f_module, "%s", mangle_type(tcaml));
		p = nextSibling(p);
		if( p ) Printf(f_module," * ");
		Delete(tcaml);
	    }
	
	    if( numargs > 1 ) 
		Printf(f_module,")");
	
	    Printf(f_module, " -> %s = \"%s\"\n", mangle_type(dcaml), 
		   wrap_name );
	}

	if( classmode ) {
	    if( !in_constructor ) {
		String *method_name = NewString("");
		String *method = get_ml_method_name(n);

		Printf(method_name,"%s::%s", classname, method);

		method_name = uniqueify(seen_methods,Char(method_name));
		char *str = strstr(Char(method_name),"::");
		str += 2;

		Delete(method);
		method = NewString(str);

		Setattr(n,"methodname",method);
		Setattr(seen_methods,method_name,method_name);

		print_method( n );
		Delete(method);
	    }
	}

	/* Insert constraint checking code */
	for (p = l; p;) {
	    if ((tm = Getattr(p,"tmap:check"))) {
		Replace(tm,"$target",Getattr(p,"lname"),DOH_REPLACE_ANY);
		Printv(f->code,tm,"\n",0);
		p = Getattr(p,"tmap:check:next");
	    } else {
		p = nextSibling(p);
	    }
	}

	// Pass output arguments back to the caller.
	
	for (p = l; p;) {
	    if ((tm = Getattr(p,"tmap:argout"))) {
		Replaceall(tm,"$arg",Getattr(p,"emit:input"));
		Replaceall(tm,"$input",Getattr(p,"emit:input"));
		Printv(outarg,tm,"\n",NULL);
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
		Replace(tm,"$target",Getattr(p,"lname"),DOH_REPLACE_ANY);
		Printv(cleanup,tm,"\n",0);
		p = Getattr(p,"tmap:freearg:next");
	    } else {
		p = nextSibling(p);
	    }
	}

	// Now write code to make the function call

	emit_action(n,f);

	// Now have return value, figure out what to do with it.

	if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
	    delete_replacement(tm,d);
	    Replaceall(tm,"$source","result");
	    Replaceall(tm,"$target","swig_result");
	    Replaceall(tm,"$result","swig_result");

	    Printv(f->code, tm, "\n",0);
	} else {
	    throw_unhandled_ocaml_type_error (dcaml);
	}

	Printv(f->code,"/* Mark 2 */\n",0);

	// Dump the argument output code
	if( argout_set ) Printv(f->code, Char(outarg),0);

	// Dump the argument cleanup code
	Printv(f->code, Char(cleanup),0);

	// Look for any remaining cleanup

	if ((NewObject) || (Getattr(n,"feature:new"))) {
	    if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
		Replaceall(tm,"$source","result");
		Printv(f->code, tm, "\n",0);
	    }
	}

	// Free any memory allocated by the function being wrapped..

	if ((tm = Swig_typemap_lookup_new("ret",n,"result",0))) {
	    Replaceall(tm,"$source","result");
	    Printv(f->code, tm, "\n",0);
	}

	// Wrap things up (in a manner of speaking)

	Printf(f->code, "\tCAMLreturn(swig_result);\n");
	Printv(f->code, "}\n",0);

	// Slightly ugly wrap-advance for get/set

	if( in_vwrap ) in_vwrap++;

	Wrapper_print(f, f_wrappers);

	Delete(source);
	Delete(target);
	Delete(arg);
	Delete(outarg);
	Delete(cleanup);
	Delete(build);
	// I am getting a core dump because of this, but dcaml, as I
	// understand it is always a Copy().  I may need to rethink the
	// way I manage these objects.
	//Delete(dcaml);
	Delete(ml_function_name);
	DelWrapper(f);

	return SWIG_OK;
    }

    /* Benedikt Grundmann inspired --> Enum wrap styles */

    int enumvalueDeclaration(Node *n) {
	String *value = Getattr(n,"value");
	String *name  = Getattr(n,"name");
	String *tmpValue;
  
	if (value)
	    tmpValue = NewString(value);
	else
	    tmpValue = NewString(name);
	Setattr(n, "value", tmpValue);

	// Explanation: Do everything as usual, but dump f_pvariant_value
	// into this string, so we can retrieve it.  This is to avoid some
	// duplication of logic above. 

	if(f_pvariant_value) { 
	    Delete(f_pvariant_value);
	    f_pvariant_value = NULL;
	}

	const_enum = 1;
	Language::enumvalueDeclaration(n); // Output 
	const_enum = 0;

	if(f_pvariant_value) {
	    // Implementation only
	    if( !mliout ) {
		Printf(f_pvariant_to_int,"| `%s -> %s\n", 
		       name, f_pvariant_value);
		Printf(f_pvariant_from_int,"if _v_ == %s then `%s else\n", 
		       f_pvariant_value, name);
	    }
	    // Both
	    Printf(f_pvariant_def,"| `%s\n", name);
	}

	return SWIG_OK;
    }

// -----------------------------------------------------------------------
// constantWrapper()
// ------------------------------------------------------------------------

    int constantWrapper(Node *n) {
	char *name      = GetChar(n,"name");
	char *iname     = GetChar(n,"sym:name");
	SwigType *type  = Getattr(n,"type");
	String   *value = Getattr(n,"value");

	String *var_name = get_wrapper_name(n);
	String *rvalue = NewString("");
	String *temp = NewString("");
	String *tm;

	print_unseen_type( type );

	// Build the name for scheme.

	if ((SwigType_type(type) == T_USER) && (!is_a_pointer(type))) {
	    fprintf (stderr, "%s : Line %d.  Unsupported constant value.\n",
		     input_file, line_number);
	    return SWIG_NOWRAP;
	}

	// See if there's a typemap

	Printv(rvalue, value,0);
	if ((SwigType_type(type) == T_CHAR) && (is_a_pointer(type) == 1)) {
	    temp = Copy(rvalue);
	    Clear(rvalue);
	    Printv(rvalue, "\"", temp, "\"",0);
	}
	if ((SwigType_type(type) == T_CHAR) && (is_a_pointer(type) == 0)) {
	    Delete(temp);
	    temp = Copy(rvalue);
	    Clear(rvalue);
	    Printv(rvalue, "'", temp, "'",0);
	}
	if ((tm = Swig_typemap_lookup_new("constant",n,name,0))) {
	    Replaceall(tm,"$source",rvalue);
	    Replaceall(tm,"$value",rvalue);
	    Replaceall(tm,"$target",name);
	    Printf (f_init, "%s\n", tm);
	} else {
	    // Create variable and assign it a value

	    Printf (f_header, "static %s = ", 
		    SwigType_str(type,var_name));
	    if ((SwigType_type(type) == T_STRING)) {
		Printf (f_header, "\"%s\";\n", value);
	    } else if (SwigType_type(type) == T_CHAR) {
		Printf (f_header, "\'%s\';\n", value);
	    } else {
		Printf (f_header, "%s;\n", value);
	    }

	    // Now create a variable declaration

	    {
		/* Hack alert: will cleanup later -- Dave */
		Node *n = NewHash();
		Setattr(n,"origname",name);
		Setattr(n,"name",var_name);
		Setattr(n,"type",type);
		Setattr(n,"sym:name",iname);
		Setattr(n,"feature:immutable","true");

		in_vwrap = VWRAP_GET;
		String *get_function = get_ml_function_name(n); // Get func
		in_vwrap = VWRAP_GET;

		variableWrapper(n);
		
		in_vwrap = VWRAP_GET + 1;
		
		f_pvariant_value = get_ml_function_name(n);
		if( mliout )
		    Printf(f_module,"val %s : %s\n",
			   f_pvariant_value,
			   SwigType_manglestr(process_type(type)));
		else
		    Printf(f_module,"let %s = %s ()\n",
			   f_pvariant_value,get_function);

		Delete(get_function);
		//Delete(n);
	    }
	}
	Delete(rvalue);
	Delete(temp);
	return SWIG_OK;
    }

    int enumDeclaration(Node *n) {
	String *name = get_ml_function_name(n);
	String *type = NewString("enum ");
	String *type_str;

	Printf(type,"%s",Getattr(n,"name"));
	type_str = mangle_type(type);

	if( !name || !strlen(Char(name)) ) return SWIG_OK;

	/* Produce the enum_to_int and int_to_enum functions */
	Printf(f_wrappers,
	       "static int %s_to_int( value v ) {\n"
	       "  value *en_to_int_cb = "
	       "caml_named_value(\"%s_to_int\");\n"
	       "  return Int_val(callback(*en_to_int_cb,v));\n"
	       "}\n"
	       "static value int_to_%s( int v ) {\n"
	       "  value *int_to_en_cb = "
	       "caml_named_value(\"int_to_%s\");\n"
	       "  return callback(*int_to_en_cb,Val_int(v));\n"
	       "}\n",name,name,name,name);
	
	if( !mliout ) {
	    Printf(f_pvariant_to_int,
		   "let %s_to_int _v_ =\nmatch _v_ with\n"
		   "`int x -> x\n",name);
	    Printf(f_pvariant_from_int,"let int_to_%s _v_ =\n",name);
	}
	
	Printf(f_pvariant_def,"type %s =\n[ `int of int\n",type_str);

	Language::enumDeclaration(n);

	Printf(f_pvariant_def,"]\n");

	if( !mliout ) {
	    Printf( f_pvariant_to_int,
		    "let _ = Callback.register \"%s_to_int\" "
		    "%s_to_int\n"
		    "let %s_bits _v_ = int_to_%s "
		    "(List.fold_left (fun a b -> a lor (%s_to_int b)) "
		    "0 _v_)\n"
		    "let check_%s_bit f _v_ = "
		    "(%s_to_int _v_) land (%s_to_int f) == "
		    "(%s_to_int f)\n"
		    "let bits_%s _v_ f_list = "
		    "List.filter (fun f -> check_%s_bit f _v_) f_list\n",
		    name, name,
		    name, name,
		    name,
		    name,
		    name, name,
		    name,
		    name,
		    name );
	    
	    Printf( f_pvariant_from_int,
		    "`int _v_\n"
		    "let _ = Callback.register \"int_to_%s\" "
		    "int_to_%s\n",
		    name, name);
	} else {
	    Printf( f_pvariant_to_int,
		    "val %s_to_int : %s -> int\n"
		    "val int_to_%s : int -> %s\n"
		    "val %s_bits : %s list -> %s\n"
		    "val check_%s_bit : %s -> %s -> bool\n"
		    "val bits_%s : %s -> %s list -> %s list\n",
		    type_str, name, 
		    name, type_str, 
		    name, type_str, type_str,
		    name, type_str, type_str,
		    name, type_str, type_str, type_str );
	}

	return SWIG_OK;
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
	String *name = NewString(GetChar(n,"name"));
	// Make a wrapper name for this
	String *wrap_name = get_wrapper_name(n);
	Setattr(n,"sym:name",Char(wrap_name));
    
	in_destructor = 1;
	
	Setattr( seen_deleters, name, wrap_name );

	ret = Language::destructorHandler(n);
	in_destructor = 0;
	    
	Delete(name);
	Delete(wrap_name);

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

    int classHandler(Node *n) {
	int rv = 0;

	if( classname ) Delete(classname);
	classname = get_ml_class_name(GetChar(n,"name"));

	if( strlen(Char(classname)) && objects ) {
	    classmode = 1;

	    /* Print this pointer type if it hasn't been seen before */
	    String *type_name = NewString("");
	    Printf(type_name,"p.%s", Getattr(n,"name"));
	    print_unseen_type( type_name );
	    type_name = SwigType_manglestr(process_type(type_name));

	    if( mliout )
		Printf(f_modclass,"class %s : %s -> object\n", 
		       classname, type_name );
	    else
		Printf(f_modclass,"class %s (c_self : %s) = object\n",
		       classname, type_name );
	
	    DOH *baseclass_list = Getattr(n,"bases");
	    Printf(f_modclass,"(* Start superclasses *)\n" );
	
	    int i;
	
	    for( i = 0; i < Len(baseclass_list); i++ ) {
		SwigType *baseclass = Getitem(baseclass_list,i);
		String *basename = 
		    get_ml_class_name(GetChar(baseclass,"name"));

		Printf(f_modclass,"(* %s is a superclass *)\n", basename);
		String *seen = Getattr(seen_classes,basename);

		if( seen ) {
		    if( mliout ) 
			Printf( f_modclass, "  inherit %s\n", seen );
		    else
			Printf( f_modclass,
				"  inherit %s (Obj.magic c_self)\n", 
				seen );
		}

		baseclass = nextSibling(baseclass);
	    }
	    Printf(f_modclass,"(* End superclasses *)\n" );
	
	    rv = Language::classHandler(n);

	    if( !mliout )
		Printf( f_modclass,
			"  method _self_%s : %s = (Obj.magic c_self)\n",
			classname, type_name );
	    else
		Printf(f_modclass,
		       "  method _self_%s : %s\n",
		       classname, type_name );

	    Printf(f_modclass,"end\n");	    
	    
	    classmode = 0;

	    String *cln = Copy(classname);
	    Setattr(seen_classes,cln,cln);

	    //Printf(stderr,"Adding class %s\n",cln);
	} else {
	    rv = Language::classHandler(n);
	}

	return rv;
    }

    int globalvariableHandler(Node *n) {
	in_vwrap = VWRAP_SET;
	if( Getattr(n,"feature:immutable") )
	    in_vwrap++;

	Language::variableWrapper(n);
	in_vwrap = 0;
	
	return SWIG_OK;
    }

    int membervariableHandler(Node *n) {
	in_vwrap = VWRAP_SET;
	Language::membervariableHandler(n);
	in_vwrap = 0;
	
	return SWIG_OK;
    }

    int variableWrapper(Node *n) {
	in_vwrap = VWRAP_SET;
	Language::variableWrapper(n);
	in_vwrap = 0;

	return SWIG_OK;
    }

    int namespaceDeclaration(Node *n) {
	if(Getattr(n,"alias")) return SWIG_OK;
	if(Getattr(n,"name")) {
	    return emit_children(n);
	} else return Language::namespaceDeclaration(n);
    }

    void import_start(char *modname) {
    }

    void import_end() {
    }
};
extern "C" Language *swig_ocaml(void) {
    return new OCAML();
}
