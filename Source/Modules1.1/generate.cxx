/* ----------------------------------------------------------------------------- 
 * generate.cxx
 *
 *     This file manages the code generation process and serves as a bridge between
 *     the new SWIG parser and the old set of C++-based language modules.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig11.h"

static char cvstag[] = "$Header$";

int ReadOnly = 0;  
int WrapExtern = 0;

/* Access permissions: public, private, protected */
enum { PUBLIC, PRIVATE, PROTECTED };
int Access   = PUBLIC;

/* Miscellaneous modes */
int Native   = 0;

/* This function tries to locate the module name within the parse tree */
static String *find_module(DOH *node) {
  DOH *n;

  if (!node) return 0;
  n = node;
  while (n) {
    if (Swig_tag_check(n,"module")) {
      return Getname(n);
    }
    if (Swig_tag_check(n,"file")) {
      String *ty;
      ty = Getattr(n,"type");
      if (Cmp(ty,"include") == 0) {
	DOH *m;
	/* Might be in an include file */
	m = find_module(Getchild(n));
	if (m) return m;
      }
    }
    n = Getnext(n);
  }
  return find_module(Getchild(node));
}

/* This helper function emits external function declarations */
static
void emit_extern_func(DOH *node, File *f) {
  Parm *p; 
  SwigType *tc;
  char *c;
  String *storage;
  storage = Getattr(node,"storage");
  if (!storage) return;
  c = Char(storage);
  if (strncmp(c,"extern",6) == 0) {
    List *tl = NewList();
    p = Getparms(node);
    while (p) {
      Append(tl,Gettype(p));
      p = Getnext(p);
    }
    tc = Copy(Gettype(node));
    SwigType_add_function(tc,tl);
    Printf(f,"%s %s;\n", storage, SwigType_str(tc,Getname(node)));
    Delete(tc);
    Delete(tl);
  }
}

/* Test if static */
static int
check_static(DOH *node) {
  String *storage = Getattr(node,"storage");
  if (!storage) return 0;
  if (Cmp(storage,"static") == 0) return 1;
  return 0;
}

/* Test if extern */
static int
check_extern(DOH *node) {
  String *storage = Getattr(node,"storage");
  if (!storage) return 0;
  if (strncmp(Char(storage),"extern",6) == 0) return 1;
  return 0;
}

static String *new_name = 0;

/* Handle renaming */
static
void set_scriptname(DOH *node) {
  if (new_name) {
    Setattr(node,"scriptname",new_name);
  } else {
    String *aname = Getattr(node,"altname");
    if (aname) {
      Setattr(node,"scriptname",aname);
    } else {
      Setattr(node,"scriptname", Getname(node));
    }
  }
  new_name = 0;
}

/* -----------------------------------------------------------------------------
 *                              C++ Support
 * ----------------------------------------------------------------------------- */

static DOH    *class_hash = 0;          /* Hash table of classes that have been seen so far */
static DOH    *current_class = 0;       /* Set when wrapping a class */
static DOH    *class_name = 0;          /* Real name of current class */
static DOH    *class_types = 0;         /* Types defined within this class */
static String *construct_name = 0;      /* Expected name of a constructor */
int AddMethods = 0;                     /* Set when in addmethods mode */
int Abstract = 0;                       /* Set when the class is determined to be abstract */

/* Check for abstract classes */

int cplus_check_abstract(DOH *node) {
  while (node) {
    if (Getattr(node,"abstract")) return 1;
    node = Getnext(node);
  }
  return 0;
}

/* Given a class object, this function builds an internal symbol table */
void cplus_build_symbols(DOH *node) {
  Hash *sym;
  DOH  *c;
  sym = Getattr(node,"symbols");
  if (!sym) {
    sym = NewHash();
    Setattr(node,"symbols",sym);
  }
  c = Getchild(node);
  while (c) {
    String *name = Getname(c);
    String *tag = Gettag(c);
    if (Cmp(tag,"c:destructor") == 0) {
      name = NewStringf("~%s",name);
    }
    if (name) {
      DOH *pnode = Getattr(sym,name);
      if (pnode) {
	Printf(stderr,"%s:%d. '%s' redefined.  Previous definition at %s:%d.\n", 
	       Getfile(c),Getline(c), name, Getfile(pnode), Getline(pnode));
      } else {
	Setattr(sym,name,c);
      }
    }
    c = Getnext(c);
  }
  return;
}

/* Add a class type */
static void
class_addtype(String *name) {
  String *s = NewStringf("%s::%s", class_name, name);
  if (!class_types) class_types = NewHash();
  Setattr(class_types,name,s);
}

/* Updates a type with a fully qualified version */
static void
class_update_type(String *type) {
  String *base, *rep;
  base = SwigType_base(type);
  if (!class_types) return;
  rep = Getattr(class_types,base);
  if (rep) {
    SwigType_setbase(type,rep);
    /*    Printf(stdout,"updated type = '%s'\n", type); */
  }
}

/* Updates a list of parms with fully qualified names */
static void
class_update_parms(ParmList *p) {
  while (p) {
    class_update_type(Gettype(p));
    p = Getnext(p);
  }
}

extern "C" {
int swig11_unknown(DOH *node, void *clientdata) {
  Printf(stdout,"::: Unknown tag - '%s'\n", Getattr(node,"tag"));
  return 0;
}

int swig11_nil(DOH *node, void *clientdata) {
    return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_file()
 *
 * File inclusion directives. %include, %extern, and %import.
 * ----------------------------------------------------------------------------- */

int swig11_file(DOH *node, void *clientdata) {
  DOH *c;
  String *type;
  int     old_we = WrapExtern;

  type = Getattr(node,"type");
  if ((Cmp(type, "extern") == 0) || (Cmp(type,"import") == 0)) {
    WrapExtern = 1;
  }
  c = Getchild(node);
  if (Cmp(type,"import") == 0) {
    /* If importing a module, we try to find the module name and pass it to
       the language modules */
    String *modname;
    modname = find_module(c);
    if (modname) {
      lang->import(modname);
    }
  }
  Swig_emit_all(c,clientdata);
  WrapExtern = old_we;
  return 0;
}
/* -----------------------------------------------------------------------------
 * swig11_scope()
 *
 * Handle the %scope directive.  This is a new feature not present in SWIG1.1.
 * Creates a new typemap scope and has other side effects.
 * ----------------------------------------------------------------------------- */

int swig11_scope(DOH *node, void *clientdata) {
  DOH *c;
  c = Getchild(node);
  Swig_typemap_new_scope();
  Swig_emit_all(c,clientdata);
  Swig_typemap_pop_scope();
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_insert()
 *
 * Code insertion with various %{ %} directives.
 * ----------------------------------------------------------------------------- */

int swig11_insert(DOH *node, void *clientdata) {
  String *section;
  String *filename;
  String *code;
  File   *out;

  if (WrapExtern) return 0;

  section = Getattr(node,"section");
  if (!section) {
    section = (void *) "header";
  }
  out = Swig_filebyname(section);
  if (!out) {
    Printf(stderr,"%s:%d. Can't insert code into unknown section '%s'\n", Getfile(node), Getline(node), section);
    return 0;
  }
  filename = Getattr(node,"filename");
  if (filename) {
    /* The user is inserting the contents of a file */
    if (Swig_insert_file(filename,out) < 0) {
      Printf(stderr,"%s:%d. File '%s' not found.\n", Getfile(node), Getline(node), filename);
    }
    return 0;
  }
  code = Getattr(node,"code");
  if (code) {
    Printf(out,"%s",code);
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * swig11_pragma()
 *
 * %pragma directive.
 * ----------------------------------------------------------------------------- */
   
int swig11_pragma(DOH *node, void *clientdata) {
  String *name;
  String *value;

  if (WrapExtern) return 0;
  
  name = Getname(node);
  value = Getvalue(node);

  Printf(stdout,"::: Pragma\n");
  Printf(stdout,"   name       = '%s'\n", name);
  Printf(stdout,"   value      = '%s'\n", value);

  if (Cmp(name,"readonly") == 0) {
    ReadOnly = 1;
  } else if (Cmp(name,"readwrite") == 0) {
    ReadOnly = 0;
  }
  lang->pragma(node);
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_typemap()
 *
 * Handle the %typemap directive.
 * ----------------------------------------------------------------------------- */

int swig11_typemap(DOH *node, void *clientdata) {
  String   *name;
  SwigType *type;
  String   *code;
  DOH      *parms;
  String   *method;

  if (WrapExtern) return 0;
  method = Getattr(node,"method");
  name   = Getname(node);
  type   = Gettype(node);
  code   = Getattr(node,"code");
  parms  = Getparms(node);

  if (code) {
    Swig_typemap_register(method,type,name,code,parms);
  } else {
    String *srcname;
    String *srctype;
    srcname = Getattr(node,"srcname");
    srctype = Getattr(node,"srctype");
    if (srcname && srctype) {
      Swig_typemap_copy(method,srctype,srcname,type,name);
    }  else {
      Swig_typemap_clear(method,type,name);
    }
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_apply()
 *
 * The %apply directive.
 * ----------------------------------------------------------------------------- */

int swig11_apply(DOH *node, void *clientdata) {
  DOH *parms;
  String *name;
  SwigType *type;

  if (WrapExtern) return 0;

  name = Getname(node);
  type = Gettype(node);
  parms = Getparms(node);

  while (parms) {
    Swig_typemap_apply(type,name,Gettype(parms),Getname(parms));
    parms = Getnext(parms);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_exception()
 *
 * The %except directive.
 * ----------------------------------------------------------------------------- */

int swig11_exception(DOH *node, void *clientdata) {
  String *code = Getattr(node,"code");
  if (WrapExtern) return 0;
  if (code) {
    Swig_except_register(code);
  } else {
    Swig_except_clear();
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_clear()
 *
 * The %clear directive.
 * ----------------------------------------------------------------------------- */

int swig11_clear(DOH *node, void *clientdata) {
  DOH *parms = Getattr(node,"parms");
  if (WrapExtern) return 0;
  while (parms) {
    Swig_typemap_clear_apply(Gettype(parms),Getname(parms));
    parms = Getnext(parms);
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * swig11_constant
 *
 * The %constant directive
 * ----------------------------------------------------------------------------- */

int swig11_constant(DOH *node, void *clientdata) {
  if (WrapExtern) return 0;
  if (Access != PUBLIC) return 0;

  set_scriptname(node);
  lang->constant(node);
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_function()
 *
 * Emit a wrapper function.
 * ----------------------------------------------------------------------------- */

int swig11_function(DOH *node, void *clientdata) {
  int is_static;
  if (WrapExtern) return 0;
  if (Access != PUBLIC) return 0;

  is_static = check_static(node);
  set_scriptname(node);

  /* Will need some kind of class check in here */

  if (current_class) {
    /* Function has been declared inside a class definition. */
    class_update_parms(Getparms(node));
    String *name = Getname(node);
    if (Cmp(name,construct_name) == 0) {
      if (!Abstract)
	lang->cpp_constructor(node);
    } else {
      if (is_static) lang->cpp_staticfunction(node);
      else lang->cpp_memberfunction(node);
    }
  } else {

    /* Can't wrap a static function.  Oh well. */
    if (is_static) return 0;
    emit_extern_func(node,f_header);
    lang->function(node);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_variable()
 *
 * Wrap a variable.
 * ----------------------------------------------------------------------------- */

int swig11_variable(DOH *node, void *clientdata) {
  int is_static;
  SwigType *type;

  if (WrapExtern) return 0;
  if (Access != PUBLIC) return 0;

  type = Gettype(node);
  
  is_static = check_static(node);
  set_scriptname(node);

  if (current_class) {
    /* Inside a class definition */
    if (is_static) {
      lang->cpp_staticvariable(node);
    } else {
      lang->cpp_variable(node);
    }
  } else {
    if (check_extern(node)) {
      Printf(f_header,"extern %s;\n", SwigType_str(type, Getname(node)));
    }
    if (is_static) return 0;
    
    if (SwigType_isconst(type)) {
      swig11_constant(node,clientdata);
    } else {
      lang->variable(node);
    }
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * swig11_typedef()
 *
 * Handle a typedef declaration.
 * ----------------------------------------------------------------------------- */

int swig11_typedef(DOH *node, void *clientdata) {
  String *name;
  SwigType *type;

  type = Gettype(node);
  name = Getname(node);
  SwigType_typedef(type,name);

  lang->add_typedef(type, Char(name));

  return 0;
}

/* ----------------------------------------------------------------------------- 
 * swig11_enum()
 *
 * Support for enumerations.
 * ----------------------------------------------------------------------------- */

int swig11_enum(DOH *node, void *clientdata) {
  DOH *c;
  String *name;
  if (WrapExtern) return 0;
  if (Access != PUBLIC) return 0;

  name = Getname(node);
  if (name && CPlusPlus) {
    /* Add a typedef */
    String *t = NewStringf("enum %s", name);
    SwigType_typedef(t,name);
    class_addtype(name);
    Delete(t);
  }
  c = Getchild(node);
  Swig_emit_all(c,clientdata);
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_enumvalue()
 *
 * Create a constant corresponding to an enum value.
 * ----------------------------------------------------------------------------- */
int swig11_enumvalue(DOH *node, void *clientdata) {
  set_scriptname(node);  
  Setattr(node,"type","int");            /* Enums wrapped as ints */
  if (!Getvalue(node)) {                 /* If no value, use the name itself */
    if (class_name) {
      Setvalue(node,NewStringf("%s::%s",class_name, Getname(node)));
    } else {
      Setvalue(node,Getname(node));
    }
  }
  if (current_class) {
    lang->cpp_constant(node);
  } else {
    swig11_constant(node,clientdata);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_class()
 * 
 * Wrapping of C++ classes
 * ----------------------------------------------------------------------------- */

int swig11_class(DOH *node, void *clientdata) {
  DOH *c;

  /* Save the class */
  String *name = Getname(node);
  Setattr(class_hash,name,node);
  if (WrapExtern) return 0;

  set_scriptname(node);
  class_name = name;

  /* Create a new type scope for this class */
  
  SwigType_new_scope();
  if (name) {
    SwigType_set_scope_name(name);
  }
  class_types = 0;
  cplus_build_symbols(node);
  lang->cpp_open_class(node);
  current_class = node;

  construct_name = Getname(node);
  if (!CPlusPlus) {
    String *altname = Getattr(node,"altname");
    if (altname) construct_name = altname;
  }

  c = Getchild(node);
  Abstract = cplus_check_abstract(c);

  Swig_emit_all(c,clientdata);  

  List *bases = Getattr(node,"bases");
  if (bases) {
    lang->cpp_inherit(bases,INHERIT_ALL);
  }
  lang->cpp_close_class();

  /* Pop the type scope and save with the class */
  Hash *scp = SwigType_pop_scope();
  Setattr(node,"typescope",scp);

  Setattr(node,"types",class_types);
  current_class = 0;
  construct_name = 0;
  class_name = 0;
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_classdecl()
 *
 * Empty class declaration.  Used to register classes with language modules.
 * ----------------------------------------------------------------------------- */

int swig11_classdecl(DOH *node, void *clientdata) {
  if (WrapExtern) return 0;
  set_scriptname(node);

  lang->cpp_class_decl(node);
  return 0;
}

int swig11_addmethods(DOH *node, void *clientdata) {
  DOH *c;
  int  oldaddmethods = AddMethods;
  if (WrapExtern) return 0;
  if (!current_class) {
    Printf(stderr,"%s:%d. %%addmethods ignored (does not appear inside a class).\n", Getfile(node),Getline(node));
    return 0;
  }
  AddMethods = 1;
  c = Getchild(node);
  Swig_emit_all(c,clientdata);  
  AddMethods = oldaddmethods;;
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_destructor()
 *
 * C++ Destructor 
 * ----------------------------------------------------------------------------- */

int swig11_destructor(DOH *node, void *clientdata) {
  if (WrapExtern) return 0;
  if (Access != PUBLIC) return 0;
  if (!current_class) return 0;

  set_scriptname(node);
  lang->cpp_destructor(node);
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_access()
 *
 * Handle an access specifier (public, private, protected)
 * ----------------------------------------------------------------------------- */

int swig11_access(DOH *node, void *clientdata) {
  String *name = Getname(node);
  if (Cmp(name,"public") == 0) Access = PUBLIC;
  else if (Cmp(name,"private") == 0) Access = PRIVATE;
  else if (Cmp(name,"protected") == 0) Access = PROTECTED;
  return 0;
}

/* -----------------------------------------------------------------------------
 * swig11_types()
 *
 * Handle the types directive.
 * ----------------------------------------------------------------------------- */

int swig11_types(DOH *node, void *clientdata) {
  Parm *p;
  p = Getparms(node);
  while (p) {
    SwigType *t = Gettype(p);
    SwigType_remember(t);
    p = Getnext(p);
  }
  return 0;
}
  
static SwigRule rules[] = {
  { "file", swig11_file},
  { "scope", swig11_scope},
  { "insert", swig11_insert},
  { "pragma", swig11_pragma},
  { "typemap", swig11_typemap},
  { "apply", swig11_apply},
  { "exception", swig11_exception},
  { "clear", swig11_clear},
  { "addmethods", swig11_addmethods},
  { "constant", swig11_constant},
  { "function", swig11_function},
  { "variable", swig11_variable},
  { "typedef", swig11_typedef},
  { "enum", swig11_enum},
  { "enumvalue", swig11_enumvalue},
  { "class", swig11_class},
  { "classdecl", swig11_classdecl},
  { "destructor", swig11_destructor},
  { "access", swig11_access},
  { "types", swig11_types},
  { "module", swig11_nil},
  { "*", swig11_unknown},
  { 0 }
};

}

/* -----------------------------------------------------------------------------
 * generate()
 *
 * Called by the SWIG1.1 system to emit code
 * ----------------------------------------------------------------------------- */

void generate(DOH *node) {
  DOH *c;
  extern String *swig_module;

  /* Initialize globals */
  class_hash = NewHash();

  Swig_add_rules(rules);
  c = Getattr(node,"child");

  /* Find the module name */
  if (!swig_module) {
    swig_module = find_module(c);
  }
  if (!swig_module) {
    Printf(stderr,"SWIG: No module name specified! Please use %%module or -module.\n");
    Swig_exit(EXIT_FAILURE);
  }

  lang->initialize(swig_module);
  Swig_emit_all(c,0);
  lang->close();

  Swig_dump_tags(node,0);

}

