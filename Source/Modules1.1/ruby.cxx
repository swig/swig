/********************************************************************
 * Ruby module for SWIG
 *
 * $Header$
 *
 * Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
 * Copyright (C) 2000  Information-technology Promotion Agency, Japan
 *
 * Masaki Fukushima
 *
 ********************************************************************/

static char cvsroot[] = "$Header$";

#include "mod11.h"
#include "ruby.h"

#include <ctype.h>
#include <string.h>

static char *usage = (char*)"\
Ruby Options\n\
     -module name    - Set module name\n\
     -toplevel       - Do not define module\n\
     -feature name   - Set feature name (used by `require')\n";

static  char *module;
static  char *modvar;
static  char *feature;
static  int toplevel;
static  DOH  *other_extern = 0;
static  DOH  *other_init = 0;
static  char *import_file;

static int current;

enum {
  NO_CPP,
  MEMBER_FUNC,
  CONSTRUCTOR,
  DESTRUCTOR,
  MEMBER_VAR,
  CLASS_CONST,
  STATIC_FUNC,
  STATIC_VAR
};

static  DOHHash *classes;		// key=cname val=RClass
static  RClass *klass;	                // Currently processing class
static  DOHHash *special_methods;	// Python style special method name table


#define RCLASS(hash, name) (RClass*)(Getattr(hash, name) ? Data(Getattr(hash, name)) : 0)
#define SET_RCLASS(hash, name, klass) Setattr(hash, name, NewVoid(klass, 0))

static void indent(DOHString *s, char *sp = (char*)tab4) {
  char rep[256] = "\n";
  Insert(s,0,sp);
  strcpy(rep+1,sp);
  Replace(s,"\n", rep, DOH_REPLACE_ANY);
}

// ---------------------------------------------------------------------
// RUBY::RUBY()
//
// Constructor
// ---------------------------------------------------------------------
RUBY::RUBY(void) {
  module = 0;
  modvar = 0;
  feature = 0;
  toplevel = 0;
  import_file = 0;
  current = NO_CPP;
  klass = 0;
  classes = NewHash();
  special_methods = NewHash();

  // Python style special method name.
  // Basic
  Setattr(special_methods, "__repr__", "inspect");
  Setattr(special_methods, "__str__", "to_s");
  Setattr(special_methods, "__cmp__", "<=>");
  Setattr(special_methods, "__hash__", "hash");
  Setattr(special_methods, "__nonzero__", "nonzero?");
  // Callable
  Setattr(special_methods, "__call__", "call");
  // Collection
  Setattr(special_methods, "__len__", "length");
  Setattr(special_methods, "__getitem__", "[]");
  Setattr(special_methods, "__setitem__", "[]=");
  // Numeric
  Setattr(special_methods, "__add__", "+");
  Setattr(special_methods, "__sub__", "-");
  Setattr(special_methods, "__mul__", "*");
  Setattr(special_methods, "__div__", "/");
  Setattr(special_methods, "__mod__", "%");
  Setattr(special_methods, "__divmod__", "divmod");
  Setattr(special_methods, "__pow__", "**");
  Setattr(special_methods, "__lshift__", "<<");
  Setattr(special_methods, "__rshift__", ">>");
  Setattr(special_methods, "__and__", "&");
  Setattr(special_methods, "__xor__", "^");
  Setattr(special_methods, "__or__", "|");
  Setattr(special_methods, "__neg__", "-@");
  Setattr(special_methods, "__pos__", "+@");
  Setattr(special_methods, "__abs__", "abs");
  Setattr(special_methods, "__invert__", "~");
  Setattr(special_methods, "__int__", "to_i");
  Setattr(special_methods, "__float__", "to_f");
  Setattr(special_methods, "__coerce__", "coerce");
}

// ---------------------------------------------------------------------
// RUBY::parse_args(int argc, char *argv[])
//
// Parse command line options and initializes variables.
// ---------------------------------------------------------------------
void RUBY::parse_args(int argc, char *argv[]) {
  // Look for certain command line options
  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i],"-module") == 0) {
	if (argv[i+1]) {
	  set_module(argv[i+1],0);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i+1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i],"-feature") == 0) {
	if (argv[i+1]) {
	  char *name = argv[i+1];
	  feature = new char [strlen(name)+1];
	  strcpy(feature, name);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i+1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i],"-toplevel") == 0) {
	toplevel = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-help") == 0) {
	Printf(stderr,"%s\n", usage);
      }
    }
  }
  // Check consistency
  if (module && toplevel)
    Swig_arg_error();

  // Set location of SWIG library
  strcpy(LibDir,"ruby");

  // Add a symbol to the parser for conditional compilation
  Preprocessor_define((void *) "SWIGRUBY", 0);

  // Add typemap definitions
  typemap_lang = (char*)"ruby";
}

// ---------------------------------------------------------------------
// RUBY::parse()
//
// Start parsing an interface file.
// ---------------------------------------------------------------------
void RUBY::parse() {
  printf("Generating wrappers for Ruby\n");

  other_extern = NewString("");
  other_init = NewString("");

  headers();

  // typedef void *VALUE
  DataType *value = NewDataType(T_VOID);
  DataType_Setname(value,"void");
  value->is_pointer = 1;
  value->implicit_ptr = 0;
  DataType_typedef_add(value,(char*)"VALUE",0);

  yyparse();       // Run the SWIG parser
  DelDataType(value);
}

// ---------------------------------------------------------------------
// RUBY::set_module(char *mod_name,char **mod_list)
//
// Sets the module name.  Does nothing if it's already set (so it can
// be overridden as a command line option).
//
// mod_list is a NULL-terminated list of additional modules.  This
// is really only useful when building static executables.
//----------------------------------------------------------------------

void RUBY::set_module(char *mod_name, char **mod_list) {
  if (import_file) {
    Printf(f_init, "%srb_f_require(Qnil, rb_str_new2(\"%s\"));\n", tab4, mod_name);
    free(import_file);  // Note: was allocated from C
    import_file = 0;
  }

  if (module) return;

  if (!feature) {
    feature = new char[strlen(mod_name)+1];
    strcpy(feature, mod_name);
  }

  module = new char[strlen(mod_name)+1];
  strcpy(module, mod_name);
  // module name must be a constant.
  module[0] = toupper(module[0]);

  modvar = new char[1+strlen(module)+1];
  modvar[0] = 'm';
  strcpy(modvar+1, module);

  if (mod_list) {
    Printv(other_extern,
	   "#ifdef __cplusplus\n",
	   "extern \"C\" {\n",
	   "#endif\n",
	   0);
    for (int i = 0; mod_list[i] != NULL; i++) {
      Printv(other_extern, "extern void Init_", mod_list[i], "(void);\n", 0);
      Printv(other_init, tab4, "Init_", mod_list[i], "();\n", 0);
    }
    Printv(other_extern,
	   "#ifdef __cplusplus\n",
	   "}\n",
	   "#endif\n",
	   0);
  }
}


static void insert_file(char *filename, FILE *file) {
  if (Swig_insert_file(filename, file) == -1) {
    Printf(stderr,
	    "SWIG : Fatal error. "
	    "Unable to locate %s. (Possible installation problem).\n",
	    filename);
    SWIG_exit(1);
  }
}
// ----------------------------------------------------------------------
// RUBY::headers(void)
//
// Generate the appropriate header files for RUBY interface.
// ----------------------------------------------------------------------
void RUBY::headers(void) {
  Swig_banner(f_header);
  Printf(f_header,"/* Implementation : RUBY */\n\n");
  Printf(f_header,"#define SWIGRUBY\n");

  insert_file((char*)"ruby.swg", f_header);
  if (NoInclude) {
    insert_file((char*)"rubydec.swg", f_header);
  } else {
    insert_file((char*)"rubydef.swg", f_header);
  }
}

// ---------------------------------------------------------------------
// RUBY::initialize(void)
//
// Produces an initialization function.   Assumes that the module
// name has already been specified.
// ---------------------------------------------------------------------
void RUBY::initialize() {
  if (!module) {
    Printf(stderr,"SWIG : *** Warning. No module name specified.\n");
    set_module((char*)"swig", NULL);         // Pick a default name
  }

  Printf(f_header,"#define SWIG_init    Init_%s\n", feature);
  Printf(f_header,"#define SWIG_name    \"%s\"\n\n", module);
  if (!toplevel) Printf(f_header,"static VALUE %s;\n", modvar);
  Printf(f_header,"\n%s\n", other_extern);

  // Start generating the initialization function
  Printv(f_init,
	 "\n",
	 "#ifdef __cplusplus\n",
	 "extern \"C\"\n",
	 "#endif\n",
	 "void Init_", feature, "(void) {\n",
	 other_init,
	 0);

  if (!toplevel) {
    Printv(f_init, tab4, modvar, " = rb_define_module(\"", module, "\");\n", 0);
  }
  Printf(f_init,"\n");
  klass = new RClass();
}

// ---------------------------------------------------------------------
// RUBY::close(void)
//
// Finish the initialization function. Close any additional files and
// resources in use.
// ---------------------------------------------------------------------
void RUBY::close(void) {
  // Finish off our init function
  Printf(f_init, "\n");
  emit_ptr_equivalence(f_wrappers,f_init);
  Printf(f_init,"}\n");
}

// ---------------------------------------------------------------------
// RUBY::make_wrapper_name(char *cname)
//
// Creates a name for a wrapper function
//              cname = Name of the C function
// ---------------------------------------------------------------------
char *RUBY::make_wrapper_name(char *cname) {
  return Swig_name_wrapper(cname);
}

// ---------------------------------------------------------------------
// RUBY::create_command(char *cname, char *iname)
//
// Creates a new command from a C function.
//              cname = Name of the C function
//              iname = Name of function in scripting language
//              argc  = Number of arguments
// ---------------------------------------------------------------------
void RUBY::create_command(char *cname, char *iname, int argc) {
  DOHString *wname = NewString(make_wrapper_name(cname));
  if (CPlusPlus) {
    Insert(wname,0,"VALUEFUNC(");
    Append(wname,")");
  }
  if (current != NO_CPP)
    iname = klass->strip(iname);
  if (Getattr(special_methods, iname)) {
    iname = GetChar(special_methods, iname);
  }

  DOHString *s = NewString("");
  DOHString *temp = NewString("");
  char argcs[32];
  sprintf(argcs,"%d",argc);

  switch (current) {
  case MEMBER_FUNC:
    Printv(klass->init, tab4, "rb_define_method(", klass->vname, ", \"",
	   iname, "\", ", wname, ", ", argcs, ");\n", 0);

    break;
  case CONSTRUCTOR:
    Printv(s, tab4, "rb_define_singleton_method(", klass->vname,
	   ", \"new\", ", wname,  ", ", argcs, ");\n", 0);
    Replace(klass->init,"$constructor", s, DOH_REPLACE_ANY);
    break;
  case MEMBER_VAR:
    Append(temp,iname);
    Replace(temp,"_set", "=", DOH_REPLACE_ANY);
    Replace(temp,"_get", "", DOH_REPLACE_ANY);
    Printv(klass->init, tab4, "rb_define_method(", klass->vname, ", \"",
	   temp, "\", ", wname, ", ", argcs, ");\n", 0);
    break;
  case STATIC_FUNC:
    Printv(klass->init, tab4, "rb_define_singleton_method(", klass->vname,
	   ", \"", iname, "\", ", wname, ", ", argcs, ");\n", 0);
    break;
  default:
    if (toplevel) {
      Printv(s, tab4, "rb_define_global_function(\"",
	     iname, "\", ", wname, ", ", argcs, ");\n",0);
    } else {
      Printv(s, tab4, "rb_define_module_function(", modvar, ", \"",
	     iname, "\", ", wname, ", ", argcs, ");\n",0);
    }
    Printv(f_init,s,0);
    break;
  }
  Delete(s);
  Delete(temp);
}

// ---------------------------------------------------------------------
// RUBY::create_function(char *name, char *iname, DataType *d, ParmList *l)
//
// Create a function declaration and register it with the interpreter.
//              name = Name of real C function
//              iname = Name of function in scripting language
//              t = Return datatype
//              l = Function parameters
// ---------------------------------------------------------------------
void RUBY::create_function(char *name, char *iname, DataType *t, ParmList *l) {
  char source[256], target[256];
  char *tm;
  DOHString *cleanup, *outarg;
  Wrapper *f;
  int i;

  // Ruby needs no destructor wrapper
  if (current == DESTRUCTOR)
    return;

  char *wname = make_wrapper_name(name);
  char mname[256], inamebuf[256];
  int predicate = 0;

  cleanup = NewString("");
  outarg = NewString("");
  f = NewWrapper();

  switch (current) {
  case MEMBER_FUNC:
  case MEMBER_VAR:
  case STATIC_FUNC:
    strcpy(mname, klass->strip(iname));
    if (Getattr(klass->predmethods, mname)) {
      predicate = 1;
      sprintf(inamebuf,"%s?",iname);
      iname = inamebuf;
    }
    break;
  }

  // Get number of arguments
  int numarg = ParmList_numarg(l);
  int numopt = check_numopt(l);

  int start = 0;
  int use_self = 0;
  switch (current) {
  case MEMBER_FUNC:
  case MEMBER_VAR:
    numarg--;
    start++;
    use_self = 1;
    break;
  }

  int numreq = 0;
  int numoptreal = 0;
  for (i = start; i < Len(l); i++) {
    if (!Getignore(Getitem(l,i))) {
      if (i >= Len(l) - numopt) numoptreal++;
      else numreq++;
    }
  }
  int vararg = (numoptreal != 0);

  // Now write the wrapper function itself
  Printv(f->def, "static VALUE\n", wname, "(", 0);
  if (vararg) {
    Printv(f->def, "int argc, VALUE *argv, VALUE self",0);
  } else {
    Printv(f->def, "VALUE self", 0);
    for (i = start; i < Len(l); i++) {
      if (!Getignore(Getitem(l,i))) {
	Printf(f->def,", VALUE varg%d", i);
      }
    }
  }
  Printf(f->def,") {");

  // Emit all of the local variables for holding arguments.
  if (vararg) {
    for (i = start; i < Len(l); i++) {
      if (!Getignore(Getitem(l,i))) {
	char s[256];
	sprintf(s,"varg%d",i);
	Wrapper_add_localv(f,s,"VALUE",s,0);
      }
    }
  }
  Wrapper_add_local(f,"vresult","VALUE vresult = Qnil");
  int pcount = emit_args(t,l,f);

#if 0
  // Dave's note: This won't work with strings gone -- 7/9/00 */
  String temp;
  temp << "/* " << name << " */" << br;
  temp << "/* nparms     = " << l->nparms << " */" << br;
  temp << "/* numarg     = " << numarg << " */" << br;
  temp << "/* numopt     = " << numopt << " */" << br;
  temp << "/* numignore  = " << numignore << " */" << br;
  temp << "/* numoptreal = " << numoptreal << " */" << br;
  temp << "/* pcount     = " << pcount << " */" << br;
  temp << "/* rb_scan_args(argc, argv, \""
       << (numarg-numoptreal) << numoptreal << "\") */" << br;
  temp << br;
  if (numignore != 0) Printf(stderr, temp);
  f->code << temp;
#endif
  // Emit count to check the number of arguments
  if (vararg) {
    Printf(f->code,"    rb_scan_args(argc, argv, \"%d%d\"", (numarg-numoptreal), numoptreal);
    for (i = start; i < Len(l); i++) {
      if (!Getignore(Getitem(l,i))) {
	Printf(f->code,", &varg%d", i);
      }
    }
    Printf(f->code,");\n");
  }

  // Now walk the function parameter list and generate code
  // to get arguments
  int j = 0;                // Total number of non-optional arguments

  for (i = 0; i < pcount ; i++) {
    Parm *p = Getitem(l,i);
    DataType *pt = Gettype(p);
    char     *pn = Getname(p);

    // Produce string representation of source and target arguments
    int selfp = (use_self && i == 0);
    if (selfp)
      strcpy(source,"self");
    else
      sprintf(source,"varg%d",i);

    sprintf(target,"%s", Getlname(p));

    if (!Getignore(p)) {
      char *tab = (char*)tab4;
      if (j >= (pcount-numopt)) { // Check if parsing an optional argument
	Printf(f->code,"    if (argc > %d) {\n", j -  start);
	tab = (char*)tab8;
      }

      // Get typemap for this argument
      tm = ruby_typemap_lookup((char*)"in",pt,pn,source,target,f);
      if (tm) {
	DOHString *s = NewString(tm);
	indent(s,tab);
	Printv(f->code, s, "\n", 0);
	Replace(f->code, "$arg", source, DOH_REPLACE_ANY);
	Delete(s);
      } else {
	Printf(stderr,"%s : Line %d. No typemapping for datatype %s\n",
		input_file,line_number, DataType_str(pt,0));
      }
      if (j >= (pcount-numopt))
	Printv(f->code, tab4, "} \n");
      j++;
    }

    // Check to see if there was any sort of a constaint typemap
    tm = ruby_typemap_lookup((char*)"check",pt,pn,source,target);
    if (tm) {
      DOHString *s = NewString(tm);
      indent(s);
      Printv(f->code, s, "\n", 0);
      Replace(f->code, "$arg", source, DOH_REPLACE_ANY);
      Delete(s);
    }

    // Check if there was any cleanup code (save it for later)
    tm = ruby_typemap_lookup((char*)"freearg",pt,pn,target,source);
    if (tm) {
      DOHString *s = NewString(tm);
      indent(s);
      Printv(cleanup,s,"\n",0);
      Replace(cleanup,"$arg",source, DOH_REPLACE_ANY);
      Delete(s);
    }

    tm = ruby_typemap_lookup((char*)"argout",pt,pn,target,(char*)"vresult");
    if (tm) {
      DOHString *s = NewString(tm);
      indent(s);
      Printv(outarg, s, "\n", 0);
      Replace(outarg, "$arg", source, DOH_REPLACE_ANY);
      Delete(s);
    }
  }

  // Now write code to make the function call
  emit_func_call(name,t,l,f);


  // Return value if necessary
  if (DataType_type(t) != T_VOID) {
    if (predicate) {
      Printv(f->code, tab4, "vresult = (result ? Qtrue : Qfalse);\n", 0);
    } else {
      tm = ruby_typemap_lookup((char*)"out",t,name,(char*)"result",(char*)"vresult");
      if (tm) {
	DOHString *s = NewString(tm);
	indent(s);
	Printv(f->code, s, "\n", 0);
	Delete(s);
      } else {
	Printf(stderr,"%s : Line %d. No return typemap for datatype %s\n",
		input_file,line_number,DataType_str(t,0));
      }
    }
  }

  // Dump argument output code;
  Printv(f->code,outarg,0);

  // Dump the argument cleanup code
  Printv(f->code,cleanup,0);

  // Look for any remaining cleanup.  This processes the %new directive
  if (NewObject) {
    tm = ruby_typemap_lookup((char*)"newfree",t,name,(char*)"result",(char*)"");
    if (tm) {
      DOHString *s = NewString(tm);
      indent(s);
      Printv(f->code,s,"\n", 0);
      Delete(s);
    }
  }

  // free pragma
  if (current == MEMBER_FUNC && Getattr(klass->freemethods, mname)) {
    Printv(f->code, tab4, "DATA_PTR(self) = 0;\n", 0);
  }

  // Special processing on return value.
  tm = ruby_typemap_lookup((char*)"ret",t,name,(char*)"result",(char*)"");
  if (tm) {
    DOHString *s = NewString(tm);
    indent(s);
    Printv(f->code,s,"\n", 0);
  }

  // Wrap things up (in a manner of speaking)
  Printv(f->code, tab4, "return vresult;\n}\n", 0);

  // Substitute the cleanup code
  Replace(f->code,"$cleanup",cleanup, DOH_REPLACE_ANY);

  // Emit the function
  Wrapper_print(f,f_wrappers);

  // Now register the function with the language
  create_command(name, iname, (vararg ? -1 : numarg));
  Delete(cleanup);
  Delete(outarg);
  DelWrapper(f);
}

// ---------------------------------------------------------------------
// RUBY::link_variable(char *name, char *iname, DataType *t)
//
// Create a link to a C variable.
//              name = Name of C variable
//              iname = Name of variable in scripting language
//              t = Datatype of the variable
// ---------------------------------------------------------------------
void RUBY::link_variable(char *name, char *iname, DataType *t) {
  char *tm;
  
  DOHString *getfname, *setfname;
  Wrapper *getf, *setf;
  int mod_attr = 0;

  getf = NewWrapper();
  setf = NewWrapper();

  // module attribute?
  if (current == STATIC_VAR || !toplevel)
    mod_attr = 1;

  // create getter
  getfname = NewString(Swig_name_get(name));
  Replace(getfname,"::", "_", DOH_REPLACE_ANY); /* FIXME: Swig_name_get bug? */
  Printv(getf->def, "static VALUE\n", getfname, "(", 0);
  if (mod_attr) Printf(getf->def, "VALUE self");
  Printf(getf->def, ") {");
  Wrapper_add_local(getf,"_val","VALUE _val");
  tm = ruby_typemap_lookup((char*)"varout",t,name,name,(char*)"_val");
  if (!tm)
    tm = ruby_typemap_lookup((char*)"out",t,name,name,(char*)"_val");
  if (tm) {
    DOHString *s = NewString(tm);
    indent(s);
    Printv(getf->code,s,"\n", 0);
    Delete(s);
  } else if (DataType_type(t) == T_USER) {
    // Hack this into a pointer
    t->is_pointer++;
    DataType_remember(t);
    Printv(getf->code, tab4, "_val = SWIG_NewPointerObj((void *)&", name,
	   ", \"", DataType_manglestr(t), "\");\n", 0);
    t->is_pointer--;
  } else {
    Printf(stderr,"%s: Line %d. Unable to link with variable type %s\n",
	    input_file,line_number,DataType_str(t,0));
  }
  Printv(getf->code, tab4, "return _val;\n}\n", 0);
  Wrapper_print(getf,f_wrappers);

  if (Status & STAT_READONLY) {
    setfname = NewString("NULL");
  } else {
    // create setter
    setfname = NewString(Swig_name_set(name));
    Replace(setfname,"::", "_", DOH_REPLACE_ANY); /* FIXME: Swig_name_get bug? */
    if (mod_attr)
      Printv(setf->def, "static VALUE\n", setfname, "(VALUE self, ", 0);
    else
      Printv(setf->def, "static void\n", setfname, "(", 0);
    Printf(setf->def, "VALUE _val) {");
    tm = ruby_typemap_lookup((char*)"varin",t,name,(char*)"_val",name);
    if (!tm)
      tm = ruby_typemap_lookup((char*)"in",t,name,(char*)"_val",name);
    if (tm) {
      DOHString *s = NewString(tm);
      indent(s);
      Printv(setf->code,s,"\n",0);
      Delete(s);
    } else if (DataType_type(t) == T_USER) {
      t->is_pointer++;
      Wrapper_add_localv(setf,"temp",DataType_lstr(t,0), "temp",0);
      Printv(setf->code, tab4, "temp = (", DataType_lstr(t,0), ")",
	     "SWIG_ConvertPtr(_val, \"", DataType_manglestr(t), "\");\n",
	     0);
      Printv(setf->code, tab4, name, " = *temp;\n",0);
      t->is_pointer--;
    } else {
      Printf(stderr,"%s: Line %d. Unable to link with variable type %s\n",
	      input_file,line_number,DataType_str(t,0));
    }
    if (mod_attr)
      Printv(setf->code, tab4, "return _val;\n",0);
    Printf(setf->code,"}\n");
    Wrapper_print(setf,f_wrappers);
  }

  // define accessor method
  if (CPlusPlus) {
    Insert(getfname,0,"VALUEFUNC(");
    Append(getfname,")");
    Insert(setfname,0,"VALUEFUNC(");
    Append(setfname,")");
  }

  DOHString *s = NewString("");
  switch (current) {
  case STATIC_VAR:
    // C++ class variable
    Printv(s,
	   tab4, "rb_define_singleton_method(", klass->vname, ", \"",
	   klass->strip(iname), "\", ", getfname, ", 0);\n",
	   0);
    if (!(Status & STAT_READONLY)) {
      Printv(s,
	     tab4, "rb_define_singleton_method(", klass->vname, ", \"",
	     klass->strip(iname), "=\", ", setfname, ", 1);\n",
	     0);
    }
    Printv(klass->init,s,0);
    break;
  default:
    // C global variable
    if (toplevel) {
      // wrapped in Ruby global variable
      Printv(s,
	     tab4, "rb_define_virtual_variable(\"", iname, "\", ",
	     getfname, ", ", setfname, ");\n",
	     0);
    } else {
      // wrapped in Ruby module attribute
      Printv(s,
	     tab4, "rb_define_singleton_method(", modvar, ", \"",
	     iname, "\", ", getfname, ", 0);\n",
	     0);
      if (!(Status & STAT_READONLY)) {
	Printv(s,
	       tab4, "rb_define_singleton_method(", modvar, ", \"",
	       iname, "=\", ", setfname, ", 1);\n",
	       0);
      }
    }
    Printv(f_init,s,0);
    Delete(s);
    break;
  }
  Delete(getfname);
  Delete(setfname);
  DelWrapper(setf);
  DelWrapper(getf);
}


// ---------------------------------------------------------------------
// RUBY::validate_const_name(char *name)
//
// Validate constant name.
// ---------------------------------------------------------------------
char *RUBY::validate_const_name(char *name) {
  if (!name || name[0] == '\0')
    return name;

  if (isupper(name[0]))
    return name;

  if (islower(name[0])) {
    name[0] = toupper(name[0]);
    Printf(stderr,"%s : Line %d. Wrong constant/class/module name "
	    "(corrected to `%s')\n", input_file, line_number, name);
    return name;
  }

  Printf(stderr,"%s : Line %d. Wrong constant/class/module name\n",
	  input_file, line_number);
  return name;
}

// ---------------------------------------------------------------------
// RUBY::declare_const(char *name, char *iname, DataType *type, char *value)
//
// Makes a constant.
//              name = Name of the constant
//              iname = Scripting language name of constant
//              type = Datatype of the constant
//              value = Constant value (as a string)
// ---------------------------------------------------------------------
void RUBY::declare_const(char *name, char *iname, DataType *type, char *value) {
  char *tm;

  if (current == CLASS_CONST)
    iname = klass->strip(iname);

  tm = ruby_typemap_lookup((char*)"const",type,name,value,iname);
  if (tm) {
    DOHString *str = NewString(tm);
    Replace(str,"$value",value, DOH_REPLACE_ANY);
    if (current == CLASS_CONST) {
      Replace(str,"$module", klass->vname, DOH_REPLACE_ANY);
      indent(str);
      Printv(klass->init, str, "\n", 0);
    } else {
      if (toplevel)
	Replace(str,"$module", "rb_cObject", DOH_REPLACE_ANY);
      else
	Replace(str,"$module", modvar, DOH_REPLACE_ANY);
      indent(str);
      Printf(f_init,"%s\n", str);
    }
    Delete(str);
  } else {
    Printf(stderr,"%s : Line %d. Unable to create constant %s = %s\n",
	    input_file, line_number, DataType_str(type,0), value);
  }
}

// ---------------------------------------------------------------------
// RUBY::ruby_typemap_lookup(char *op, DataType *type, char *pname, char *source, char *target, WrapperFunction *f = 0)
//
// Ruby specific typemap_lookup.
//              op     = string code for type of mapping
//              type   = the datatype
//              pname  = an optional parameter name
//              source = a string with the source variable
//              target = a string containing the target value
//              f      = a wrapper function object (optional)
// ---------------------------------------------------------------------
char *RUBY::ruby_typemap_lookup(char *op, DataType *type, char *pname, char *source, char *target, Wrapper *f) {
  static DOHString *s = 0;
  char *tm;
  DOHString *target_replace = NewString(target);
  target = Char(target_replace);

  RClass *cls = RCLASS(classes, DataType_Getname(type));

  if (!s) s = NewString("");
  Clear(s);

  if ((strcmp("out", op) == 0 || strcmp("in", op) == 0)
      && strcmp(DataType_Getname(type), "VALUE") == 0) {
    Printf(s,"$target = $source;");
  } else if (strcmp("out", op) == 0 && (DataType_Gettypecode(type) == T_USER) &&
	     type->is_pointer == 1 && cls) {
    const char *vname = (current == CONSTRUCTOR ? "self" : Char(cls->vname));
    Printv(s, "$target = Wrap_", cls->cname, "(", vname, ", $source);",0);
  } else if (strcmp("in", op)==0 && (DataType_Gettypecode(type) == T_USER) &&
	     type->is_pointer == 1 && cls) {
    Printv(s, "Get_", cls->cname, "($source, $target);", 0);
  } else {
    tm = typemap_lookup(op, typemap_lang, type, pname, source, target, f);
    if (tm) {
      Delete(target_replace);
      return tm;
    }
    Clear(s);
    if (strcmp("in", op) == 0) {
      DOHString *v = NewString("");
      if (from_VALUE(type, (char*)"$source", v))
	Printv(s, "$target = ", v, ";", 0);
      Delete(v);
    } else if (strcmp("out", op) == 0) {
      DOHString *v = NewString("");
      if (to_VALUE(type, (char*)"$source", v))
	Printv(s, "$target = ", v, ";", 0);
      Delete(v);
    } else if (strcmp("const", op) == 0) {
      DOHString *v = NewString("");
      if (to_VALUE(type, (char*)"$value", v, 1)) {
	Printv(s, "rb_define_const($module, \"$target\", ", v, ");", 0);
	validate_const_name(target);
      }
      Delete(v);
    }
  }
  if (Len(s) == 0) {
    return NULL;
  }

  if (source && strlen(source) > 0)
    Replace(s,"$source",source, DOH_REPLACE_ANY);
  if (target && strlen(target) > 0)
    Replace(s,"$target",target, DOH_REPLACE_ANY);
  Replace(s,"$type", DataType_str(type,0), DOH_REPLACE_ANY);
  return Char(s);
}

// ---------------------------------------------------------------------
// RUBY::to_VALUE(DataType *type, char *value, literal)
//
// Makes a VALUE (as a string)
//              type = Datatype of the C value
//              value = C value (as a string)
//              str = resulting code (as a string)
//              raw = value is raw string (not quoted) ?
// ---------------------------------------------------------------------
int RUBY::to_VALUE(DataType *type, char *value, DOHString *str, int raw) {
  Clear(str);
  switch(DataType_type(type)) {
  case T_INT:
  case T_SHORT:
  case T_LONG:
  case T_SCHAR:
    Printv(str, "INT2NUM(", value, ")", 0);
    break;
  case T_UINT:
  case T_USHORT:
  case T_ULONG:
  case T_UCHAR:
    Printv(str,"UINT2NUM(", value, ")", 0);
    break;
  case T_DOUBLE:
  case T_FLOAT:
    Printv(str, "rb_float_new(", value, ")", 0);
    break;
  case T_CHAR:
    Printv(str, "rb_str_new(&", value, ", 1)", 0);
    break;
  case T_BOOL:
    Printv(str, "(", value, " ? Qtrue : Qfalse)", 0);
    break;
  case T_STRING:
    if (raw)
      Printv(str, "rb_str_new2(\"", value, "\")", 0);
    else
      Printv(str, "rb_str_new2(", value, ")", 0);
    break;
  case T_POINTER: case T_ARRAY: case T_REFERENCE:
    Printv(str, "SWIG_NewPointerObj((void *)", value, ", \"", DataType_manglestr(type), "\")", 0);
    break;
  default:
    break;
  }
  if (Len(str) == 0)
    return 0;
  return 1;
}

// ---------------------------------------------------------------------
// RUBY::from_VALUE(DataType *type, char *value)
//
// extract VALUE
//              type  = Datatype of the C value
//              value = Ruby VALUE (as a string)
//              str   = resulting code (as a string)
// ---------------------------------------------------------------------
int RUBY::from_VALUE(DataType *type, char *value, DOHString *str) {
  Clear(str);
  switch(DataType_type(type)) {
  case T_INT:
    Printv(str, "NUM2INT(", value, ")", 0);
    break;
  case T_LONG:
    Printv(str, "NUM2LONG(", value, ")", 0);
    break;
  case T_SHORT:
    Printv(str, "NUM2SHRT(", value, ")", 0);
    break;
  case T_UINT:
    Printv(str, "NUM2UINT(", value, ")", 0);
    break;
  case T_ULONG:
    Printv(str, "NUM2ULONG(", value, ")", 0);
    break;
  case T_USHORT:
    Printv(str, "NUM2USHRT(", value, ")", 0);
    break;
  case T_DOUBLE:
  case T_FLOAT:
    Printv(str, "NUM2DBL(", value, ")", 0);
    break;
  case T_CHAR: case T_SCHAR: case T_UCHAR:
    Printv(str, "NUM2CHR(", value, ")", 0);
    break;
  case T_BOOL:
    Printv(str,"RTEST(", value, ")", 0);
    break;
  case T_STRING:
    Printv(str, "STR2CSTR(", value, ")", 0);
    break;
  case T_POINTER: case T_ARRAY: case T_REFERENCE:
    Printv(str, "SWIG_ConvertPtr(", value, ", \"", DataType_manglestr(type), "\")", 0);
    break;
  default:
    break;
  }
  if (Len(str) == 0) return 0;
  return 1;
}

// ----------------------------------------------------------------------
// void RUBY::cpp_open_class(char *classname, char *classrename, char *ctype, int strip)
//
// Open a new C++ class.
//
// INPUTS:
//      name   = Real name of the C++ class
//      rename = New name of the class (if %name was used)
//      ctype  = Class type (struct, class, union, etc...)
//      strip  = Flag indicating whether we should strip the
//               class type off
//
// This function is in charge of creating a new class.  The SWIG parser has
// already processed the entire class definition prior to calling this
// function (which should simplify things considerably).
//
// ----------------------------------------------------------------------
void RUBY::cpp_open_class(char *cname, char *rename, char *ctype, int strip) {
  this->Language::cpp_open_class(cname, rename, ctype, strip);

  klass = RCLASS(classes, cname);

  if (strip) {
    Clear(klass->type);
    Append(klass->type, klass->cname);
  } else {
    Clear(klass->type);
    Printv(klass->type, ctype, " ", klass->cname,0);
  }

  Printv(klass->header, "\nVALUE ", klass->vname, ";\n", 0);
  Printv(klass->init, "\n", tab4, 0);
  if (toplevel) {
    Printv(klass->init, klass->vname, " = rb_define_class(",
	   "\"", klass->name, "\", $super);\n", 0);
  } else {
    Printv(klass->init, klass->vname, " = rb_define_class_under(", modvar,
	   ", \"", klass->name, "\", $super);\n", 0);
  }
  Replace(klass->includes,"$class", klass->vname, DOH_REPLACE_ANY);
  Printv(klass->init, klass->includes,0);
  Printv(klass->init, "$constructor",0);

  Printv(klass->header,
	 "$markproto",
	 "$freeproto",
	 "#define Wrap_", klass->cname, "(klass, ptr) (\\\n",
	 tab4, "(ptr) ? Data_Wrap_Struct(klass",
	 ", $markfunc, $freefunc, ptr) : Qnil )\n",
	 "#define Get_", klass->cname, "(val, ptr) {\\\n",
	 tab4, "if (NIL_P(val)) ptr = NULL;\\\n",
	 tab4, "else {\\\n",
	 tab8, "if (!rb_obj_is_kind_of(val, ", klass->vname, "))\\\n",
	 tab8, tab4, "rb_raise(rb_eTypeError, \"wrong argument type",
	                 " (expected ", klass->name, ")\");\\\n",
	 tab8, "Data_Get_Struct(val, ", klass->type, ", ptr);\\\n",
	 tab8, "if (!ptr) rb_raise(rb_eRuntimeError, \"",
	         "This ", klass->name, " already released\");\\\n",
	 tab4, "}\\\n",
	 "}\n",
	 0);

}

// ---------------------------------------------------------------------
// void RUBY::cpp_close_class()
//
// Close the current class
// ---------------------------------------------------------------------
void RUBY::cpp_close_class() {
  this->Language::cpp_close_class();

  Replace(klass->header,"$markfunc", "0", DOH_REPLACE_ANY);
  Replace(klass->header,"$markproto", "", DOH_REPLACE_ANY);
  if (!klass->destructor_defined) {
    Replace(klass->header,"$freefunc", "0", DOH_REPLACE_ANY);
    Replace(klass->header,"$freeproto", "", DOH_REPLACE_ANY);
  }
  Printv(f_header, klass->header,0);

  Replace(klass->aliases,"$class", klass->vname, DOH_REPLACE_ANY);
  Printv(klass->init, klass->aliases,0);

  DOHString *s = NewString("");
  Printv(s, tab4, "rb_undef_method(CLASS_OF(", klass->vname,
	 "), \"new\");\n", 0);
  Replace(klass->init,"$constructor", s, DOH_REPLACE_ANY);
  Replace(klass->init,"$super", "rb_cObject", DOH_REPLACE_ANY);

  Printv(f_init,klass->init,0);
  klass = 0;
}

// ----------------------------------------------------------------------
// void RUBY::cpp_inherit(char **baseclass, int mode)
//
// Inherit attributes from given baseclass.
//
// INPUT:
//     baseclass       = NULL terminate list of baseclasses
//
// ---------------------------------------------------------------------

void RUBY::cpp_inherit(char **baseclass, int mode) {
  if (!baseclass)
    return;

  for (int i = 0; baseclass[i]; i++) {
    RClass *super = RCLASS(classes, baseclass[i]);
    if (super) {
      Replace(klass->init,"$super", super->vname, DOH_REPLACE_ANY);
      break; // ignore multiple inheritance
    }
  }
}

// ----------------------------------------------------------------------
// void RUBY::cpp_member_func(char *name, char *iname, DataType *t, ParmList *l)
//
// Method for adding C++ member function
//
// INPUTS:
//      name        - name of the member function
//      iname       - renaming (if given)
//      t           - Return datatype
//      l           - Parameter list
//
// By default, we're going to create a function of the form :
//
//         Foo_bar(this,args)
//
// Where Foo is the classname, bar is the member name and the this pointer
// is explicitly attached to the beginning.
//
// The renaming only applies to the member function part, not the full
// classname.
//
// ---------------------------------------------------------------------
void RUBY::cpp_member_func(char *name, char *iname, DataType *t, ParmList *l) {
  current = MEMBER_FUNC;
  this->Language::cpp_member_func(name, iname, t, l);
  current = NO_CPP;
}

// ---------------------------------------------------------------------
// void RUBY::cpp_constructor(char *name, char *iname, ParmList *l)
//
// Method for adding C++ member constructor
//
// INPUTS:
//      name     - Name of the constructor (usually same as classname)
//      iname    - Renamed version
//      l        - parameters
// --------------------------------------------------------------------
void RUBY::cpp_constructor(char *name, char *iname, ParmList *l) {
  current = CONSTRUCTOR;
  this->Language::cpp_constructor(name, iname, l);
  current = NO_CPP;
}

// ---------------------------------------------------------------------
// void RUBY::cpp_destructor(char *name, char *iname)
//
// Method for adding C++ member destructor
//
// INPUT:
//     name        -  Name of the destructor (classname)
//     iname       -  Renamed destructor
//
// --------------------------------------------------------------------
void RUBY::cpp_destructor(char *name, char *newname) {
  current = DESTRUCTOR;
  this->Language::cpp_destructor(name, newname);

  DOHString *freefunc = NewString("");
  DOHString *freeproto = NewString("");
  DOHString *freebody = NewString("");

  Printv(freefunc, "free_", klass->cname, 0);
  Printv(freeproto, "static void ", freefunc, "(", klass->type, " *);\n", 0);
  Printv(freebody, "static void\n",
	 freefunc, "(", klass->type, " *ptr) {\n",
	 tab4, Swig_name_destroy(name), "(ptr);\n",
	 "}\n",
	 0);
  if (CPlusPlus) {
    Insert(freefunc,0,"VOIDFUNC(");
    Append(freefunc,")");
  }

  Replace(klass->header,"$freefunc", freefunc, DOH_REPLACE_ANY);
  Replace(klass->header,"$freeproto", freeproto, DOH_REPLACE_ANY);
  Printv(f_wrappers, freebody, 0);

  klass->destructor_defined = 1;
  current = NO_CPP;
  Delete(freefunc);
  Delete(freeproto);
  Delete(freebody);
}

// ---------------------------------------------------------------------
// void RUBY::cpp_variable(char *name, char *iname, DataType *t)
//
// Wrap a C++ data member
//
// INPUTS :
//      name       = Name of the C++ member
//     iname       = Name as used in the interpreter
//         t       = Datatype
//
// This creates a pair of functions to set/get the variable of a member.
// --------------------------------------------------------------------
void RUBY::cpp_variable(char *name, char *iname, DataType *t) {
  current = MEMBER_VAR;
  this->Language::cpp_variable(name, iname, t);
  current = NO_CPP;
}

// -----------------------------------------------------------------------
// void RUBY::cpp_static_func(char *name, char *iname, DataType *t, ParmList *l)
//
// Wrap a static C++ function
//
// INPUTS:
//      name           = Real name of the function
//     iname           = New name in interpreter
//      t              = Return datatype
//      l              = Parameters
// ----------------------------------------------------------------------
void RUBY::cpp_static_func(char *name, char *iname, DataType *t, ParmList *l) {
  current = STATIC_FUNC;
  this->Language::cpp_static_func(name, iname, t, l);
  current = NO_CPP;
}

// ----------------------------------------------------------------------
// void RUBY::cpp_declare_const(char *name, char *iname, DataType *t, char *value)
//
// Create a C++ constant
//
// INPUTS :
//       name          = Real name of the constant
//       iname         = new name
//       t             = Datatype
//       value         = value as a string
//
// ---------------------------------------------------------------------

void RUBY::cpp_declare_const(char *name, char *iname, DataType *type, char *value) {
  current = CLASS_CONST;
  this->Language::cpp_declare_const(name, iname, type, value);
  current = NO_CPP;
}

// ---------------------------------------------------------------------
// void RUBY::cpp_static_var(char *name, char *iname, DataType *t)
//
// Wrap a static C++ variable
//
// INPUT :
//      name        = name of the variable
//     iname        = interpreter name
//         t        = Datatype
//
// ---------------------------------------------------------------------
void RUBY::cpp_static_var(char *name, char *iname, DataType *t) {
  current = STATIC_VAR;
  this->Language::cpp_static_var(name, iname, t);
  current = NO_CPP;
}

// -----------------------------------------------------------------------
// RUBY::cpp_class_decl(char *name, char *rename, char *type)
//
// A forward class declaration
// -----------------------------------------------------------------------
void RUBY::cpp_class_decl(char *cname, char *rename, char *type) {
  DOHString *valid_name = NewString((rename ? rename : cname));
  validate_const_name(Char(valid_name));
  klass->set_name(cname, rename, Char(valid_name));
  SET_RCLASS(classes, cname, klass);
  if (type && strlen(type) > 0) {
    char temp[256];
    sprintf(temp,"%s %s", type, cname);
    SET_RCLASS(classes, temp, klass);
  }
  char s[256];
  sprintf(s,"extern VALUE %s;\n", Char(klass->vname));
  Printf(f_header, s);
  klass = new RClass();
  Delete(valid_name);
}

// --------------------------------------------------------------------
// void RUBY::pragma(char *target, char *var, char *value)
//
// A pragma declaration
// --------------------------------------------------------------------
void RUBY::pragma(char *lang, char *cmd, char *value) {
  if (strcmp(lang, "ruby") != 0)
    return;

  if (strcmp(cmd, "free") == 0) {
    char name[64];
    if (sscanf(value, " %s ", name) != 1) {
      Printf(stderr, "%s : Line %d. Invalid free pragma.\n",
	      input_file, line_number);
      return;
    }
    Setattr(klass->freemethods, name, name);
  } else if (strcmp(cmd, "include") == 0) {
    char name[64];
    if (sscanf(value, " %s ", name) != 1) {
      Printf(stderr, "%s : Line %d. Invalid include pragma.\n",
	      input_file, line_number);
      return;
    }
    Printv(klass->includes,tab4, "rb_include_module($class, ",
	   "rb_eval_string(\"", name, "\"));\n", 0);
  } else if (strcmp(cmd, "alias") == 0) {
    char alias[64], name[64];
    if (sscanf(value, " %s %s ", alias, name) != 2) {
      Printf(stderr, "%s : Line %d. Invalid alias pragma.\n",
	      input_file, line_number);
      return;
    }
    Printv(klass->aliases, tab4, "rb_define_alias($class, ",
	   "\"", alias, "\", \"", name, "\");\n", 0);
  } else if (strcmp(cmd, "pred") == 0) {
    char *tok;
    tok = strtok(value, " \t");
    while (tok) {
      Setattr(klass->predmethods, tok, tok);
      tok = strtok(0, " \t");
    }
  } else if (strcmp(cmd, "debug") == 0) {
    Printf(f_header, "/* %s */\n", value);
    Printf(f_wrappers, "/* %s */\n", value);
    Printf(f_init, "/* %s */\n", value);
    Printf(stderr, "%s\n", value);
  } else {
    Printf(stderr, "%s : Line %d. Unrecognized pragma.\n",
	    input_file, line_number);
  }
}

// -----------------------------------------------------------------------------
// RUBY::cpp_pragma(Pragma *plist)
//
// Handle C++ pragmas
// -----------------------------------------------------------------------------

void RUBY::cpp_pragma(Pragma *plist) {
  while (plist) {
    pragma(Char(plist->lang), Char(plist->name), Char(plist->value));
    plist = plist->next;
  }
}

// ---------------------------------------------------------------------
// RUBY::import(char *filename)
//
// Imports a SWIG module as a separate file.
//----------------------------------------------------------------------

void RUBY::import(char *filename) {
  if (import_file) free(import_file);
  import_file = Swig_copy_string(filename);
}

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */
