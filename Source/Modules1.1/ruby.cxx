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

#define RCLASS(hash, name) (RClass*)(Getattr(hash, name) ? Data(Getattr(hash, name)) : 0)
#define SET_RCLASS(hash, name, klass) Setattr(hash, name, NewVoid(klass, 0))

static String& indent(String& s, char *sp = (char*)tab4) {
  sp >> s;
  String rep = sp;
  s.replace("\n", ("\n" >> rep).get());
  return s;
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
	fprintf(stderr,"%s\n", usage);
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
  headers();

  // typedef void *VALUE
  DataType value;
  strcpy(value.name, "void");
  value.type = T_VOID;
  value.is_pointer = 1;
  value.implicit_ptr = 0;
  value.typedef_add((char*)"VALUE");

  yyparse();       // Run the SWIG parser
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
    fprintf(f_init, "%srb_f_require(Qnil, rb_str_new2(\"%s\"));\n", tab4, mod_name);
    delete [] import_file;
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
    other_extern << "#ifdef __cplusplus\n"
		 << "extern \"C\" {\n"
		 << "#endif\n";
    for (int i = 0; mod_list[i] != NULL; i++) {
      other_extern << "extern void Init_" << mod_list[i] << "(void);\n";
      other_init << tab4 << "Init_" << mod_list[i] << "();\n";
    }
    other_extern << "#ifdef __cplusplus\n"
		 << "}\n"
		 << "#endif\n";
  }
}


static void insert_file(char *filename, FILE *file) {
  if (Swig_insert_file(filename, file) == -1) {
    fprintf(stderr,
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
  fprintf(f_header,"/* Implementation : RUBY */\n\n");
  fprintf(f_header,"#define SWIGRUBY\n");

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
    fprintf(stderr,"SWIG : *** Warning. No module name specified.\n");
    set_module((char*)"swig", NULL);         // Pick a default name
  }

  fprintf(f_header,"#define SWIG_init    Init_%s\n", feature);
  fprintf(f_header,"#define SWIG_name    \"%s\"\n\n", module);
  if (!toplevel) fprintf(f_header,"static VALUE %s;\n", modvar);
  fprintf(f_header,"\n%s\n", (char *)other_extern.get());

  // Start generating the initialization function
  String s;
  s << "\n"
    << "#ifdef __cplusplus\n"
    << "extern \"C\"\n"
    <<"#endif\n"
    << "void Init_" << feature << "(void) {\n"
    << other_init;
  if (!toplevel) {
    s << tab4 << modvar << " = rb_define_module(\"" << module << "\");\n";
  }
  s << "\n";
  fprintf(f_init, s.get());
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
  fprintf(f_init, "\n");
  emit_ptr_equivalence(f_init);
  fprintf(f_init,"}\n");
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
  String wname = make_wrapper_name(cname);
  if (CPlusPlus) {
    "VALUEFUNC(" >> wname << ")";
  }
  if (current != NO_CPP)
    iname = klass->strip(iname);
  if (Getattr(special_methods, iname)) {
    iname = GetChar(special_methods, iname);
  }

  String s, temp;
  switch (current) {
  case MEMBER_FUNC:
    klass->init << tab4 << "rb_define_method(" << klass->vname << ", \""
		<< iname << "\", " << wname << ", " << argc << ");\n";
    break;
  case CONSTRUCTOR:
    s << tab4 << "rb_define_singleton_method(" << klass->vname
      << ", \"new\", " << wname << ", " << argc << ");\n";
    klass->init.replace("$constructor", s.get());
    break;
  case MEMBER_VAR:
    temp = iname;
    temp.replace("_set", "=");
    temp.replace("_get", "");
    klass->init << tab4 << "rb_define_method(" << klass->vname << ", \""
		<< temp << "\", " << wname << ", " << argc << ");\n";
    break;
  case STATIC_FUNC:
    klass->init << tab4 << "rb_define_singleton_method(" << klass->vname
		<< ", \"" << iname << "\", " << wname << ", " << argc
		<< ");\n";
    break;
  default:
    if (toplevel) {
      s << tab4 << "rb_define_global_function(\""
	<< iname << "\", " << wname << ", " << argc << ");\n";
    } else {
      s << tab4 << "rb_define_module_function(" << modvar << ", \""
	<< iname << "\", " << wname << ", " << argc << ");\n";
    }
    fprintf(f_init, s.get());
    break;
  }
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
  String source, target;
  char *tm;
  String cleanup, outarg;
  WrapperFunction  f;
  int i;

  // Ruby needs no destructor wrapper
  if (current == DESTRUCTOR)
    return;

  char *wname = make_wrapper_name(name);
  String mname, inamebuf;
  int predicate = 0;
  switch (current) {
  case MEMBER_FUNC:
  case MEMBER_VAR:
  case STATIC_FUNC:
    mname = klass->strip(iname);
    if (Getattr(klass->predmethods, mname.get())) {
      predicate = 1;
      inamebuf = iname;
      inamebuf << "?";
      iname = inamebuf.get();
    }
    break;
  }

  // Get number of arguments
  int numarg = l->numarg();
  int numopt = l->numopt();
  int numignore = l->nparms - numarg;
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
  for (i = start; i < l->nparms; i++) {
    if (!l->get(i)->ignore) {
      if (i >= l->nparms - numopt) numoptreal++;
      else numreq++;
    }
  }
  int vararg = (numoptreal != 0);

  // Now write the wrapper function itself
  f.def << "static VALUE\n" << wname << "(";
  if (vararg) {
    f.def << "int argc, VALUE *argv, VALUE self";
  } else {
    f.def << "VALUE self";
    for (i = start; i < l->nparms; i++) {
      if (!l->get(i)->ignore) {
	f.def << ", VALUE varg" << i;
      }
    }
  }
  f.def << ") {";

  // Emit all of the local variables for holding arguments.
  if (vararg) {
    for (i = start; i < l->nparms; i++) {
      if (!l->get(i)->ignore) {
	String s;
	s << "varg" << i;
	f.add_local((char*)"VALUE", s.get());
      }
    }
  }
  f.add_local((char*)"VALUE", (char*)"vresult", (char*)"Qnil");
  int pcount = emit_args(t,l,f);

#if 0
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
  if (numignore != 0) fprintf(stderr, temp);
  f.code << temp;
#endif
  // Emit count to check the number of arguments
  if (vararg) {
    f.code << tab4 << "rb_scan_args(argc, argv, \""
	   << (numarg-numoptreal) << numoptreal << "\"";
    for (i = start; i < l->nparms; i++) {
      if (!l->get(i)->ignore) {
	f.code << ", &varg" << i;
      }
    }
    f.code << ");\n";
  }

  // Now walk the function parameter list and generate code
  // to get arguments
  int j = 0;                // Total number of non-optional arguments

  for (i = 0; i < pcount ; i++) {
    Parm &p = (*l)[i];         // Get the ith argument
    source = "";
    target = "";

    // Produce string representation of source and target arguments
    int selfp = (use_self && i == 0);
    if (selfp)
      source << "self";
    else
      source << "varg" << i;
    target << "_arg" << i;

    if (!p.ignore) {
      char *tab = (char*)tab4;
      if (j >= (pcount-numopt)) { // Check if parsing an optional argument
	f.code << tab4 << "if (argc > " << j -  start << ") {\n";
	tab = (char*)tab8;
      }

      // Get typemap for this argument
      tm = ruby_typemap_lookup((char*)"in",p.t,p.name,source.get(),target.get(),&f);
      if (tm) {
	String s = tm;
	f.code << indent(s, tab) << "\n";
	f.code.replace("$arg",source.get());   // Perform a variable replacement
      } else {
	fprintf(stderr,"%s : Line %d. No typemapping for datatype %s\n",
		input_file,line_number, p.t->print_type());
      }
      if (j >= (pcount-numopt))
	f.code << tab4 << "} \n";
      j++;
    }

    // Check to see if there was any sort of a constaint typemap
    tm = ruby_typemap_lookup((char*)"check",p.t,p.name,source.get(),target.get());
    if (tm) {
      String s = tm;
      f.code << indent(s) << "\n";
      f.code.replace("$arg",source.get());
    }

    // Check if there was any cleanup code (save it for later)
    tm = ruby_typemap_lookup((char*)"freearg",p.t,p.name,target.get(),source.get());
    if (tm) {
      String s = tm;
      cleanup << indent(s) << "\n";
      cleanup.replace("$arg",source.get());
    }

    tm = ruby_typemap_lookup((char*)"argout",p.t,p.name,target.get(),(char*)"vresult");
    if (tm) {
      String s = tm;
      outarg << indent(s) << "\n";
      outarg.replace("$arg",source.get());
    }
  }

  // Now write code to make the function call
  emit_func_call(name,t,l,f);

  // Return value if necessary
  if ((t->type != T_VOID) || (t->is_pointer)) {
    if (predicate) {
      f.code << tab4 << "vresult = (_result ? Qtrue : Qfalse);\n";
    } else {
      tm = ruby_typemap_lookup((char*)"out",t,name,(char*)"_result",(char*)"vresult");
      if (tm) {
	String s = tm;
	f.code << indent(s) << "\n";
      } else {
	fprintf(stderr,"%s : Line %d. No return typemap for datatype %s\n",
		input_file,line_number,t->print_type());
      }
    }
  }

  // Dump argument output code;
  f.code << outarg;

  // Dump the argument cleanup code
  f.code << cleanup;

  // Look for any remaining cleanup.  This processes the %new directive
  if (NewObject) {
    tm = ruby_typemap_lookup((char*)"newfree",t,name,(char*)"_result",(char*)"");
    if (tm) {
      String s = tm;
      f.code << indent(s) << "\n";
    }
  }

  // free pragma
  if (current == MEMBER_FUNC && Getattr(klass->freemethods, mname.get())) {
    f.code << tab4 << "DATA_PTR(self) = 0;\n";
  }

  // Special processing on return value.
  tm = ruby_typemap_lookup((char*)"ret",t,name,(char*)"_result",(char*)"");
  if (tm) {
    String s = tm;
    f.code << indent(s) << "\n";
  }

  // Wrap things up (in a manner of speaking)
  f.code << tab4 << "return vresult;\n}\n";

  // Substitute the cleanup code
  f.code.replace("$cleanup",cleanup.get());

  // Emit the function
  f.print(f_wrappers);

  // Now register the function with the language
  create_command(name, iname, (vararg ? -1 : numarg));
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
  String getfname, setfname;
  WrapperFunction getf, setf;
  int mod_attr = 0;

  // module attribute?
  if (current == STATIC_VAR || !toplevel)
    mod_attr = 1;

  // create getter
  getfname = Swig_name_get(name);
  getfname.replace("::", "_"); /* FIXME: Swig_name_get bug? */
  getf.def << "static VALUE\n" << getfname << "(";
  if (mod_attr) getf.def << "VALUE self";
  getf.def << ") {";
  getf.add_local((char*)"VALUE", (char*)"_val");
  tm = ruby_typemap_lookup((char*)"varout",t,name,name,(char*)"_val");
  if (!tm)
    tm = ruby_typemap_lookup((char*)"out",t,name,name,(char*)"_val");
  if (tm) {
    String s = tm;
    getf.code << indent(s) << "\n";
  } else if (!t->is_pointer && t->type == T_USER) {
    // Hack this into a pointer
    t->is_pointer++;
    t->remember();
    getf.code << tab4 << "_val = SWIG_NewPointerObj((void *)&" << name
	      << ", \"" << t->print_mangle() << "\");\n";
    t->is_pointer--;
  } else {
    fprintf(stderr,"%s: Line %d. Unable to link with variable type %s\n",
	    input_file,line_number,t->print_type());
  }
  getf.code << tab4 << "return _val;\n}\n";
  getf.print(f_wrappers);

  if (Status & STAT_READONLY) {
    setfname = "NULL";
  } else {
    // create setter
    setfname = Swig_name_set(name);
    setfname.replace("::", "_"); /* FIXME: Swig_name_get bug? */
    if (mod_attr)
      setf.def << "static VALUE\n" << setfname << "(VALUE self, ";
    else
      setf.def << "static void\n" << setfname << "(";
    setf.def << "VALUE _val) {";
    tm = ruby_typemap_lookup((char*)"varin",t,name,(char*)"_val",name);
    if (!tm)
      tm = ruby_typemap_lookup((char*)"in",t,name,(char*)"_val",name);
    if (tm) {
      String s = tm;
      setf.code << indent(s) << "\n";
    } else if (!t->is_pointer && t->type == T_USER) {
      t->is_pointer++;
      setf.add_local(t->print_type(), (char*)"temp");
      setf.code << tab4 << "temp = (" << t->print_type() << ")"
		<< "SWIG_ConvertPtr(_val, \"" << t->print_mangle() << "\");\n";
      setf.code << tab4 << name << " = *temp;\n";
      t->is_pointer--;
    } else {
      fprintf(stderr,"%s: Line %d. Unable to link with variable type %s\n",
	      input_file,line_number,t->print_type());
    }
    if (mod_attr)
      setf.code << tab4 << "return _val;\n";
    setf.code << "}\n";
    setf.print(f_wrappers);
  }

  // define accessor method
  if (CPlusPlus) {
    "VALUEFUNC(" >> getfname << ")";
    "VALUEFUNC(" >> setfname << ")";
  }

  String s;
  switch (current) {
  case STATIC_VAR:
    // C++ class variable
    s << tab4 << "rb_define_singleton_method(" << klass->vname << ", \""
      << klass->strip(iname) << "\", " << getfname << ", 0);\n";
    if (!(Status & STAT_READONLY)) {
      s << tab4 << "rb_define_singleton_method(" << klass->vname << ", \""
	<< klass->strip(iname) << "=\", " << setfname << ", 1);\n";
    }
    klass->init << s;
    break;
  default:
    // C global variable
    if (toplevel) {
      // wrapped in Ruby global variable
      s << tab4 << "rb_define_virtual_variable(\"" << iname << "\", "
	<< getfname << ", " << setfname << ");\n";
    } else {
      // wrapped in Ruby module attribute
      s << tab4 << "rb_define_singleton_method(" << modvar << ", \""
	<< iname << "\", " << getfname << ", 0);\n";
      if (!(Status & STAT_READONLY)) {
	s << tab4 << "rb_define_singleton_method(" << modvar << ", \""
	  << iname << "=\", " << setfname << ", 1);\n";
      }
    }
    fputs(s.get(), f_init);
    break;
  }
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
    fprintf(stderr,"%s : Line %d. Wrong constant/class/module name "
	    "(corrected to `%s')\n", input_file, line_number, name);
    return name;
  }

  fprintf(stderr,"%s : Line %d. Wrong constant/class/module name\n",
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
    String str = tm;
    str.replace("$value",value);
    if (current == CLASS_CONST) {
      str.replace("$module", klass->vname.get());
      indent(str);
      klass->init << str << "\n";
    } else {
      if (toplevel)
	str.replace("$module", "rb_cObject");
      else
	str.replace("$module", modvar);
      indent(str);
      fprintf(f_init,"%s\n", str.get());
    }
  } else {
    fprintf(stderr,"%s : Line %d. Unable to create constant %s = %s\n",
	    input_file, line_number, type->print_type(), value);
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
char *RUBY::ruby_typemap_lookup(char *op, DataType *type, char *pname, char *source, char *target, WrapperFunction *f) {
  static String s;
  char *tm;
  String target_replace = target;
  target = target_replace.get();

  RClass *cls = RCLASS(classes, type->name);
  s = "";

  if ((strcmp("out", op) == 0 || strcmp("in", op) == 0)
      && strcmp(type->name, "VALUE") == 0) {
    s << "$target = $source;";
  } else if (strcmp("out", op) == 0 && type->type == T_USER &&
	     type->is_pointer == 1 && cls) {
    const char *vname = (current == CONSTRUCTOR ? "self" : cls->vname.get());
    s << "$target = Wrap_" << cls->cname << "(" << vname << ", $source);";
  } else if (strcmp("in", op)==0 && type->type == T_USER &&
	     type->is_pointer == 1 && cls) {
    s << "Get_" << cls->cname << "($source, $target);";
  } else {
    tm = typemap_lookup(op, typemap_lang, type, pname, source, target, f);
    if (tm) {
      return tm;
    }

    s = "";
    if (strcmp("in", op) == 0) {
      String v;
      if (from_VALUE(type, (char*)"$source", v))
	s << "$target = " << v << ";";
    } else if (strcmp("out", op) == 0) {
      String v;
      if (to_VALUE(type, (char*)"$source", v))
	s << "$target = " << v << ";";
    } else if (strcmp("const", op) == 0) {
      String v;
      if (to_VALUE(type, (char*)"$value", v, 1)) {
	s << "rb_define_const($module, \"$target\", " << v << ");";
	validate_const_name(target);
      }
    }
  }

  if (strlen(s.get()) == 0) {
    return NULL;
  }

  if (source && strlen(source) > 0)
    s.replace("$source", source);
  if (target && strlen(target) > 0)
    s.replace("$target", target);
  s.replace("$type", type->print_type());
  return s.get();
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
int RUBY::to_VALUE(DataType *type, char *value, String& str, int raw) {
  str = "";
  if (type->is_pointer == 0) {
    switch(type->type) {
    case T_INT:case T_SINT:
    case T_SHORT: case T_SSHORT:
    case T_LONG: case T_SLONG:
    case T_SCHAR:
      str << "INT2NUM(" << value << ")";
      break;
    case T_UINT:
    case T_USHORT:
    case T_ULONG:
    case T_UCHAR:
      str << "UINT2NUM(" << value << ")";
      break;
    case T_DOUBLE:
    case T_FLOAT:
      str << "rb_float_new(" << value << ")";
      break;
    case T_CHAR:
      str << "rb_str_new(&" << value << ", 1)";
      break;
    case T_BOOL:
      str << "(" << value << " ? Qtrue : Qfalse)";
      break;
    default:
      break;
    }
  } else if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
    if (raw)
      str << "rb_str_new2(\"" << value << "\")";
    else
      str << "rb_str_new2(" << value << ")";
  } else {
    str << "SWIG_NewPointerObj((void *)" << value << ", \"" << type->print_mangle() << "\")";
  }

  if (strlen(str.get()) == 0)
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
int RUBY::from_VALUE(DataType *type, char *value, String& str) {
  str = "";
  if (type->is_pointer == 0) {
    switch(type->type) {
    case T_INT:case T_SINT:
      str << "NUM2INT(" << value << ")";
      break;
    case T_LONG: case T_SLONG:
      str << "NUM2LONG(" << value << ")";
      break;
    case T_SHORT: case T_SSHORT:
      str << "NUM2SHRT(" << value << ")";
      break;
    case T_UINT:
      str << "NUM2UINT(" << value << ")";
      break;
    case T_ULONG:
      str << "NUM2ULONG(" << value << ")";
      break;
    case T_USHORT:
      str << "NUM2USHRT(" << value << ")";
      break;
    case T_DOUBLE:
    case T_FLOAT:
      str << "NUM2DBL(" << value << ")";
      break;
    case T_CHAR: case T_SCHAR: case T_UCHAR:
      str << "NUM2CHR(" << value << ")";
      break;
    case T_BOOL:
      str << "RTEST(" << value << ")";
      break;
    default:
      break;
    }
  } else if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
    str << "STR2CSTR(" << value << ")";
  } else {
    str << "SWIG_ConvertPtr(" << value << ", \"" << type->print_mangle() << "\")";
  }

  if (strlen(str.get()) == 0)
    return 0;
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
    klass->type = "";
    klass->type << klass->cname;
  } else {
    klass->type = "";
    klass->type << ctype << " " << klass->cname;
  }

  klass->header << "\nVALUE " << klass->vname << ";\n";
  klass->init << "\n" <<  tab4;
  if (toplevel) {
    klass->init << klass->vname << " = rb_define_class("
		<< "\"" << klass->name << "\", $super);\n";
  } else {
    klass->init << klass->vname << " = rb_define_class_under(" << modvar
		<< ", \"" << klass->name << "\", $super);\n";
  }
  klass->includes.replace("$class", klass->vname.get());
  klass->init << klass->includes;
  klass->init << "$constructor";

  klass->header
    << "$markproto"
    << "$freeproto"
    << "#define Wrap_" << klass->cname << "(klass, ptr) (\\\n"
    << tab4 << "(ptr) ? Data_Wrap_Struct(klass"
    << ", $markfunc, $freefunc, ptr) : Qnil )\n"
    << "#define Get_" << klass->cname << "(val, ptr) {\\\n"
    << tab4 << "if (NIL_P(val)) ptr = NULL;\\\n"
    << tab4 << "else {\\\n"
    << tab8 << "if (!rb_obj_is_kind_of(val, " << klass->vname << "))\\\n"
    << tab8 << tab4 << "rb_raise(rb_eTypeError, \"wrong argument type"
    <<                 " (expected " << klass->name << ")\");\\\n"
    << tab8 << "Data_Get_Struct(val, " << klass->type << ", ptr);\\\n"
    << tab8 << "if (!ptr) rb_raise(rb_eRuntimeError, \""
    <<         "This " << klass->name << " already released\");\\\n"
    << tab4 << "}\\\n"
    << "}\n";
}

// ---------------------------------------------------------------------
// void RUBY::cpp_close_class()
//
// Close the current class
// ---------------------------------------------------------------------
void RUBY::cpp_close_class() {
  this->Language::cpp_close_class();

  klass->header.replace("$markfunc", "0");
  klass->header.replace("$markproto", "");
  if (!klass->destructor_defined) {
    klass->header.replace("$freefunc", "0");
    klass->header.replace("$freeproto", "");
  }
  fprintf(f_header, klass->header.get());

  klass->aliases.replace("$class", klass->vname.get());
  klass->init << klass->aliases;

  String s;
  s << tab4 << "rb_undef_method(CLASS_OF(" << klass->vname
    << "), \"new\");\n";
  klass->init.replace("$constructor", s.get());
  klass->init.replace("$super", "rb_cObject");

  fprintf(f_init, klass->init.get());

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
      klass->init.replace("$super", super->vname.get());
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

  String freefunc, freeproto, freebody;
  freefunc << "free_" << klass->cname;
  freeproto << "static void " << freefunc << "(" << klass->type << " *);\n";
  freebody  << "static void\n"
	    << freefunc << "(" << klass->type << " *ptr) {\n"
	    << tab4 << Swig_name_destroy(name) << "(ptr);\n"
	    << "}\n";
  if (CPlusPlus) {
    "VOIDFUNC(" >> freefunc << ")";
  }

  klass->header.replace("$freefunc", freefunc.get());
  klass->header.replace("$freeproto", freeproto.get());
  fprintf(f_wrappers, freebody.get());

  klass->destructor_defined = 1;
  current = NO_CPP;
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
  String valid_name = (rename ? rename : cname);
  validate_const_name(valid_name.get());
  klass->set_name(cname, rename, valid_name.get());
  SET_RCLASS(classes, cname, klass);
  if (type && strlen(type) > 0) {
    String temp;
    temp << type << " " << cname;
    SET_RCLASS(classes, temp.get(), klass);
  }
  String s;
  s << "extern VALUE " << klass->vname << ";\n";
  fprintf(f_header, s.get());

  klass = new RClass();
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
      fprintf(stderr, "%s : Line %d. Invalid free pragma.\n",
	      input_file, line_number);
      return;
    }
    Setattr(klass->freemethods, name, name);
  } else if (strcmp(cmd, "include") == 0) {
    char name[64];
    if (sscanf(value, " %s ", name) != 1) {
      fprintf(stderr, "%s : Line %d. Invalid include pragma.\n",
	      input_file, line_number);
      return;
    }
    klass->includes << tab4 << "rb_include_module($class, "
		    << "rb_eval_string(\"" << name << "\"));\n";
  } else if (strcmp(cmd, "alias") == 0) {
    char alias[64], name[64];
    if (sscanf(value, " %s %s ", alias, name) != 2) {
      fprintf(stderr, "%s : Line %d. Invalid alias pragma.\n",
	      input_file, line_number);
      return;
    }
    klass->aliases << tab4 << "rb_define_alias($class, "
		  << "\"" << alias << "\", \"" << name << "\");\n";
  } else if (strcmp(cmd, "pred") == 0) {
    char *tok;
    tok = strtok(value, " \t");
    while (tok) {
      Setattr(klass->predmethods, tok, tok);
      tok = strtok(0, " \t");
    }
  } else if (strcmp(cmd, "debug") == 0) {
    fprintf(f_header, "/* %s */\n", value);
    fprintf(f_wrappers, "/* %s */\n", value);
    fprintf(f_init, "/* %s */\n", value);
    fprintf(stderr, "%s\n", value);
  } else {
    fprintf(stderr, "%s : Line %d. Unrecognized pragma.\n",
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
  if (import_file) delete [] import_file;
  import_file = copy_string(filename);
}

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */
