/* -----------------------------------------------------------------------------
 * generate.cxx
 *
 *     This file roughly emulates the language module API for SWIG1.1 by walking
 *     a parse tree.  This is really nasty stuff... sorry.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2001.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "internal.h"

/* cplus.cxx */

extern void cplus_open_class(char *name, char *rname, char *ctype);
extern void cplus_member_func(char *, char *, SwigType *, ParmList *, int);
extern void cplus_constructor(char *, char *, ParmList *);
extern void cplus_destructor(char *, char *);
extern void cplus_variable(char *, char *, SwigType *);
extern void cplus_static_func(char *, char *, SwigType *, ParmList *);
extern void cplus_declare_const(char *, char *, SwigType *, char *);
extern void cplus_class_close(char *);
extern void cplus_inherit(int, char **);
extern void cplus_cleanup(void);
extern void cplus_static_var(char *, char *, SwigType *);
extern void cplus_register_type(char *);
extern void cplus_register_scope(void *);
extern void cplus_inherit_scope(int, char **);
extern void cplus_add_pragma(char *, char *, char *);
extern void cplus_set_class(char *);
extern void cplus_unset_class();
extern void cplus_abort();

static int     module_init = 0;    /* Indicates whether the %module name was given */
static int     lang_init = 0;      /* Indicates if the language has been initialized */
static String  *yyrename = 0;      /* Set by %name directive */
static int     cplus_mode;
static int     InClass = 0;
static char   *Callback = 0;
static Hash   *symbols = 0;

extern int     line_number;
extern char   *input_file;

/* C++ modes */

#define  CPLUS_PUBLIC    1
#define  CPLUS_PRIVATE   2
#define  CPLUS_PROTECTED 3

/* import modes */

#define  IMPORT_MODE     1
#define  IMPORT_MODULE   2

/* --------------------------------------------------------------------------
 * swig_pragma()
 *
 * Handle swig pragma directives.  
 * -------------------------------------------------------------------------- */

void swig_pragma(char *lang, char *name, char *value) {
  if (strcmp(lang,"swig") == 0) {
    if (strcmp(name,"make_default") == 0) {
      GenerateDefault = 1;
    } else if (strcmp(name,"no_default") == 0) {
      GenerateDefault = 0;
    } else if (strcmp(name,"readonly") == 0) {
      Status = Status | STAT_READONLY;
    } else if (strcmp(name,"readwrite") == 0) {
      Status = Status & ~STAT_READONLY;
    } else if (strcmp(name,"callback") == 0) {
      Callback = Swig_copy_string(value ? value:"%s");
    } else if (strcmp(name,"nocallback") == 0) {
      Callback = 0;
    }
  }
}

/* Create a type list from a set of parameters */
static List *typelist(Parm *p) {
   List *l = NewList();
   while (p) {
     Append(l,Gettype(p));
     p = Getnext(p);
   }
   return l;
 }

static Parm *nonvoid_parms(Parm *p) {
  if (p) {
    SwigType *t = Gettype(p);
    if (SwigType_type(t) == T_VOID) return 0;
  }
  return p;
}

/* Hack alert */
static char *symname = 0;

char *make_name(char *n) {
  if (symname) 
    return symname;
  return n;
}

/* -----------------------------------------------------------------------------
 * emit_extern_func()
 * 
 * Emit an external function declaration.
 * ----------------------------------------------------------------------------- */

static void emit_extern_func(char *decl, SwigType *t, ParmList *L, char *extern_type, DOHFile *f) {
  SwigType *ty;
  List     *tlist;
  ty = Copy(t);
  tlist = typelist(L);
  SwigType_add_function(ty,tlist);

  if (!extern_type) {
    Printf(f,"%s",SwigType_str(ty,decl));
  } else if (strcmp(extern_type,"extern") == 0) {
    Printf(f,"extern %s;\n", SwigType_str(ty,decl));
  } else if (strcmp(extern_type,"externc") == 0) {
    Printf(f,"extern \"C\" %s;\n", SwigType_str(ty,decl));
  }
  Delete(ty);
  Delete(tlist);
}

/* -----------------------------------------------------------------------------
 * init_language()
 * 
 * Initialize the target language.  Does nothing if the function
 * is called more than once.
 * ----------------------------------------------------------------------------- */

static void init_language() {
  if (lang_init) return;
  lang->initialize();
  lang_init = 1;
}

/* ------------------------------------------------------------------
 * create_constant()
 *
 * Creates a new constant.
 * ------------------------------------------------------------------- */

static void create_constant(char *name, SwigType *type, char *value) {

  if (ImportMode) return;   
  init_language();

  char *iname = make_name(name);

  if (!value) value = Swig_copy_string(name);
  String *tval = NewStringf("%(escape)s",value);
  lang->declare_const(name, iname, type, Char(tval));
  Delete(tval);
}

/* ----------------------------------------------------------------------
 * c_varfunc_decl()
 *
 * Create a wrapper for a C declaration (variable or function)
 * ---------------------------------------------------------------------- */

static void
c_varfunc_decl(char *storage, SwigType *type, char *name, SwigType *decltype, ParmList *parms) {
  SwigType *ty;
  if (ImportMode) return;
  if (!storage) storage = "";
  
  if (strcmp(storage,"static") == 0) return;
  init_language();

  if (!type) {
    Printf(stderr,"%s:%d. Can't wrap '%s' because it is declared with an unnamed type.\n", input_file,line_number,name);
    return;
  }

  if (strstr(name,"::")) {
    Printf(stderr,"%s:%d. Warning. Qualified declaration %s ignored.\n", input_file, line_number, name);
    return;
  }

  char *iname = make_name(name);
  ty = Copy(type);    
  if (SwigType_isfunction(decltype)) {
    SwigType_push(ty,decltype);
    Delete(SwigType_pop(ty));
    if ((storage) || (ForceExtern)) {
      emit_extern_func(name,ty,parms,ForceExtern ? (char *) "extern" : storage, f_header);
    }
    if (Callback) {
      String *cbname;
      SwigType *cbty = Copy(type);
      SwigType_push(cbty,decltype);
      SwigType_add_pointer(cbty);
      cbname = NewStringf(Callback,iname);
      if (Cmp(cbname,iname) == 0) {
	lang->declare_const(name,iname,cbty,name);
      } else {
	create_constant(Char(cbname),cbty,name);
	lang->create_function(name,iname,ty,nonvoid_parms(parms));
      }
      Delete(cbty);
      Delete(cbname);
    } else {
      lang->create_function(name,iname,ty,nonvoid_parms(parms));
    }
  } else {
    /* Variable declaration */
    SwigType_push(ty,decltype);
    if ((strcmp(storage,"extern") == 0)|| (ForceExtern)) {
      Printf(f_header,"extern %s;\n", SwigType_str(ty,name));
    }
    int oldstatus = Status;
    if (SwigType_isconst(ty)) {
      Status |= STAT_READONLY;
    }
    /* If an array and elements are const, then read-only */
    if (SwigType_isarray(ty)) {
      SwigType *tya = SwigType_array_type(ty);
      if (SwigType_isconst(tya)) {
	Status |= STAT_READONLY;
      }
    }
    lang->link_variable(name,iname,ty);
    Status = oldstatus;
  }
  Delete(ty);
}

/* ----------------------------------------------------------------------
 * C++ member variable or function declaration
 * ---------------------------------------------------------------------- */

static void
cplus_varfunc_decl(char *storage, SwigType *type, char *id, SwigType *decltype, ParmList *parms, String *val) {
  char *iname;
  SwigType *ty;
  init_language();

  if (cplus_mode != CPLUS_PUBLIC) return;
  if (!storage) storage = "";

  if (strstr(id,"::")) {
    Printf(stderr,"%s:%d. Warning. Qualified declaration %s ignored.\n", input_file, line_number, id);
    return;
  }

  /*  Printf(stdout,"vardecl: %s %s %s %s\n", id, type, decltype, parms); */
  ty = Copy(type);
  iname = make_name(id);
  if (iname == id) iname = 0;
  if (SwigType_isfunction(decltype)) {
    /* A member function */
    Delete(SwigType_pop(decltype));
    SwigType_push(ty,decltype);
    if (strcmp(storage,"static") == 0) {
      /* Static member function */
      cplus_static_func(id,iname,ty,nonvoid_parms(parms));
    } else {
      int is_virtual = 0;
      if (strcmp(storage,"virtual") == 0) {
	is_virtual = PLAIN_VIRTUAL;
	/* Check for pure virtual */
	if (val && Cmp(val,"0") == 0) is_virtual = PURE_VIRTUAL;
      }
      cplus_member_func(id,iname,ty,nonvoid_parms(parms),is_virtual);
    }
  } else {
    /* A member variable */
    SwigType_push(ty,decltype);
    int oldstatus = Status;
    if (SwigType_isconst(ty)) {
      Status |= STAT_READONLY;
    }
    /* If an array and elements are const, then read-only */
    if (SwigType_isarray(ty)) {
      SwigType *tya = SwigType_array_type(ty);
      if (SwigType_isconst(tya)) {
	Status |= STAT_READONLY;
      }
    }
    if (strcmp(storage,"static") == 0) {
      cplus_static_var(id,iname,ty);
    } else {
      cplus_variable(id,iname,ty);
    }
    Status = oldstatus;
  }
  Delete(ty);
}

/* Create a C++ constant */
static void 
cplus_enum_const(char *name, SwigType *type, char *value) {
  String *tval;
  char *iname;
  iname = make_name(name);
  if (name == iname) iname = 0;
  if (value) {
    tval = NewStringf("%(escape)s",value);
    cplus_declare_const(name,iname,type,Char(tval));
    Delete(tval);
  } else {
    cplus_declare_const(name,iname,type,value);
  }
}


/* ----------------------------------------------------------------------
 * start_class()
 *
 * Start a new class definition.
 * ---------------------------------------------------------------------- */

static char  *cpp_name = 0;
static char  *cpp_type = 0;
static char  *cpp_bases[256];
static int   cpp_nbases = 0;

static void 
start_class(char *cpptype, char *name, List *bases)
{
  char *iname;
  int  i;
  init_language();
  SwigType_new_scope();

  /* Rip apart the bases list */
  cpp_nbases = bases ? Len(bases) : 0;
  for (i = 0; i < cpp_nbases; i++) {
    cpp_bases[i] = Char(Getitem(bases,i));
  }
  iname = make_name(name);
  if ((iname == name) || (strlen(iname) == 0)) {
    cplus_open_class(name,0,cpptype);
  } else {
    cplus_open_class(name,iname,cpptype);
  }
  if (strcmp(cpptype,"class") == 0) 
    cplus_mode = CPLUS_PRIVATE;
  else
    cplus_mode = CPLUS_PUBLIC;
  // Merge scope from base classes
  if (cpp_nbases) 
    cplus_inherit_scope(cpp_nbases,cpp_bases);
  InClass = 1;
  cpp_type = cpptype;
  if (strlen(name)) cpp_name = name;
  else cpp_name = 0;
}

/* ----------------------------------------------------------------------
 * end_class()
 * 
 * End a class definition
 * ---------------------------------------------------------------------- */

static void
end_class(SwigType *endtype, char *endname) {
  InClass = 0;
  SwigType *et = endtype;
  char     *en = endname;

  if (cpp_nbases) {
    cplus_inherit(cpp_nbases,cpp_bases);
  }

  if (cpp_name)
    SwigType_set_scope_name(cpp_name);
  cplus_register_scope(SwigType_pop_scope());

  if (endtype && Len(endtype)) {
    Printf(stderr,"%s:%d. typedef %s { } %s not supported.\n", input_file, line_number, cpp_type, 
	   SwigType_str(endtype,endname));
    endtype = 0;
    endname = 0;
  }
  if (CPlusPlus && cpp_name) endname = 0;
  if (endname) {
    cplus_class_close(endname);
  } else {
    cplus_class_close((char *)0);
  }
  cplus_mode = CPLUS_PUBLIC;
}

/* ----------------------------------------------------------------------
   generate()
 
   Top-level tree parsing code
   ---------------------------------------------------------------------- */

void generate(Node *top) {
  Node *n = top;
  String *err;
  while (n) {
    char *tag = GetChar(n,"tag");
    if (!tag) goto g_error;
    
    if ((err = Geterror(n))) {
      n = Getnext(n);
      continue;
    }

    symname = Char(Getsymname(n));

    line_number = Getline(n);
    input_file = Char(Getfile(n));
    
    /*    Printf(stderr,"%s:%d.  %s '%s'\n", input_file, line_number, tag, Getname(n)); */

    if (strcmp(tag,"top") == 0) {

      /* top-level parse-tree node */
      generate(Getchild(n));


      /* ============================================================
       * SWIG directives
       * ============================================================ */

    } else if (strcmp(tag,"addmethods") == 0) {

      /* %addmethods directive */

      int oldam = AddMethods;
      if (!InClass) {            /* Not in a class */

	cplus_mode = CPLUS_PUBLIC;
	InClass = 1;
	cplus_set_class(Char(Getname(n)));
	generate(Getchild(n));
	InClass = 0;
	cplus_unset_class();
	AddMethods = oldam;

      } else {                  /* Inside a class */

	AddMethods = 1;
	generate(Getchild(n));
	AddMethods = oldam;

      }
    } else if (strcmp(tag,"apply") == 0) {
      
	/* %apply directive */
	
	SwigType *type = Gettype(n);
	String   *name = Getname(n);
	Parm     *p    = Getparms(n);
	while (p) {
	  Swig_typemap_apply(type,name,Gettype(p),Getname(p));
	  p = Getnext(p);
	}

    } else if (strcmp(tag,"clear") == 0) {

      /* %clear directive */
      Printf(stderr,"%s:%d. Warning. %%clear directive is temporarily disabled in this release.\n", input_file, line_number);

    } else if (strcmp(tag,"constant") == 0) {

      /* %constant directive */
      if (!ImportMode) {
	String *name = Getname(n);
	SwigType *type = Gettype(n);
	String *value = Getvalue(n);
	create_constant(Char(name),type,Char(value));
      }

    } else if (strcmp(tag,"except") == 0) {
      
      /* %except directive */
      
	String *code = Getattr(n,"code");
	if (code) {
	  Swig_except_register(code);       /* Set %except */
	} else {
	  Swig_except_clear();
	}

    } else if (strcmp(tag,"include") == 0) {
      
      /* %include directive */

      int oldim = ImportMode;
      String *kind = Getattr(n,"kind");
      if (Cmp(kind,"import") == 0) {
	ImportMode = IMPORT_MODE;
      }
      generate(Getchild(n));
      if (Cmp(kind,"import") == 0) {
	if (ImportMode & IMPORT_MODULE) {
	  lang->import_end();
	}
      }
      ImportMode = oldim;

    } else if (strcmp(tag,"insert") == 0) {

      /* %insert directive */
      if (!ImportMode) {
	String *code = Getattr(n,"code");
	String *section = Getattr(n,"section");
	String *filename = Getattr(n,"filename");
	File *f = 0;
	
	if (!section) {     /* %{ ... %} */
	  f = Swig_filebyname("header");
	} else {
	  f = Swig_filebyname(section);
	}
	if (f) {
	  if (code) {
	    Printf(f,"%s\n",code);
	  } else if (filename) {
	    if (Swig_insert_file(filename,f) < 0) {
	      Printf(stderr,"%s:%d: Couldn't find '%s'. Possible installation problem.\n", input_file, line_number, filename);
	      SWIG_exit (EXIT_FAILURE);
	    }
	  }
	} else {
	  Printf(stderr,"%s:%d: Unknown target '%s' for %%insert directive.\n", input_file, line_number, section);
	}
      }

    } else if (strcmp(tag,"module") == 0) { 

      /* %module directive */

      String *name = Getname(n);
      if (ImportMode) {
	if (ImportMode == IMPORT_MODE) {
	  lang->import_start(Char(name));
	  ImportMode |= IMPORT_MODULE;
	} 
      } else {
	lang->set_module(Char(name));
	module_init = 1;
	init_language();
      }

    } else if (strcmp(tag,"native") == 0) {

      /* %native directive */
      if (!ImportMode) {
	String *name = Getname(n);
	String *sname = Getattr(n,"scriptname");
	SwigType *type = Gettype(n);
	SwigType *decl = Getdecl(n);
	Parm    *parms = Getparms(n);

	/* need to implement */
      }

    } else if (strcmp(tag,"new") == 0) {

      /* %new directive */

      NewObject = 1;
      generate(Getchild(n));
      NewObject = 0;

    } else if (strcmp(tag,"pragma") == 0) {

      /* %pragma directive */
      if (!ImportMode) {
	String *lan = Getattr(n,"lang");
	String *name = Getname(n);
	String *value = Getvalue(n);
	swig_pragma(Char(lan),Char(name),Char(value));
	if (InClass) {
	  cplus_add_pragma(Char(lan),Char(name),Char(value));
	} else {
	  lang->pragma(Char(lan),Char(name),Char(value));
	}
      }

    } else if (strcmp(tag,"typemap") == 0) {

      /* %typemap directive */
      String *method = Getattr(n,"method");
      String *code = Getattr(n,"code");
      Node   *items = Getchild(n);
      while (items) {
	SwigType *type = Gettype(items);
	String   *name = Getname(items);
	Parm     *parms = Getparms(items);
	if (code) {
	  Swig_typemap_register(method,type,name,code,parms);
	} else {
	  /* Typemap deletion disabled */
	}
	items = Getnext(items);
      }

    } else if (strcmp(tag,"typemapcopy") == 0) {

      String *method = Getattr(n,"method");
      String *name   = Getname(n);
      String *type   = Gettype(n);
      Node *items = Getchild(n);
      while (items) {
	SwigType *newtype = Getattr(items,"newtype");
	String   *newname = Getattr(items,"newname");
	Swig_typemap_copy(method,type,name,newtype,newname);
	items = Getnext(items);
      }
    } else if (strcmp(tag,"types") == 0) {

      /* %types directive */

      Parm  *parms = Getparms(n);
      while (parms) {
	SwigType *t = Gettype(parms);
	SwigType_remember(t);
	parms = Getnext(parms);
      }

      /* ============================================================
       * C/C++ parsing
       * ============================================================ */

    } else if (strcmp(tag,"extern") == 0) {

      /* extern "C" declaration */
      generate(Getchild(n));

    } else if (strcmp(tag,"cdecl") == 0) {
      String *storage = Getattr(n,"storage");
      String *name    = Getname(n);
      SwigType *type    = Gettype(n);
      SwigType *decl    = Getdecl(n);
      Parm     *parms   = Getparms(n);
      String   *value   = Getvalue(n);
      String   *code    = Getattr(n,"code");

      if (storage && (Cmp(storage, "typedef") == 0)) {
	/* A typedef declaration */
	SwigType *t = Copy(type);
	if (t) {
	  SwigType_push(t,decl);
	  SwigType_typedef(t,name);
	  lang->add_typedef(t,Char(name));
	  cplus_register_type(Char(name));
	}
      } else if (storage && ((Cmp(storage,"friend") == 0))) {
	/* nothing */
      } else {
	Clear(CCode);
	if (code) {
	  Append(CCode,code);
	}
	if (!InClass) {
	  /* A normal C declaration */
	  c_varfunc_decl(Char(storage),type,Char(name),decl,parms);
	} else {
	  int s = Status;
	  if (Getattr(n,"nested")) Status = Status | STAT_READONLY;
	  cplus_varfunc_decl(Char(storage),type,Char(name),decl,parms,Char(value));
	  Status = s;
	}
      }
    } else if (strcmp(tag,"enum") == 0) {

      /* enum declaration */
      String *name = Getname(n);
      generate(Getchild(n));
      if (name) {
	cplus_register_type(Char(name));
	SwigType *t = NewStringf("enum %s", name);
	SwigType_typedef(t,name);
	lang->add_typedef(t,Char(name));
	Delete(t);
      }
    } else if (strcmp(tag,"enumitem") == 0) {
      String *name = Getname(n);
      String *value = Getvalue(n);
      SwigType *ttype = NewSwigType(T_INT);

      if (!value) value = name;
      if (!InClass) {
	create_constant(Char(name),ttype,Char(value));
      } else {
	cplus_enum_const(Char(name),ttype,0);
      }

    } else if (strcmp(tag,"class") == 0) {
      String *kind = Getattr(n,"kind");
      String *name = Getattr(n,"name");
      List   *bases = Getattr(n,"bases");
      String *tdname = Getattr(n,"tdname");
      SwigType *tddecl = Getattr(n,"decl");
      
      start_class(Char(kind), name ? Char(name) : (char *) "",bases);
      generate(Getchild(n));
      end_class(tddecl,Char(tdname));

    } else if (strcmp(tag,"forwardclass") == 0) {

      String *kind = Getattr(n,"kind");
      String *name = Getname(n);

      init_language();
      char *iname = make_name(Char(name));
      lang->cpp_class_decl(Char(name),iname,Char(kind));

    } else if (strcmp(tag,"constructor") == 0) {
      char *name = Char(Getname(n));
      Parm   *parms = Getparms(n);
      String *code  = Getattr(n,"code");

      if (cplus_mode == CPLUS_PUBLIC) {
	char *iname = make_name(Char(name));
	if (iname == name) iname = 0;
	if (Cmp(name,iname) == 0) iname = 0;
	cplus_constructor(name,iname,nonvoid_parms(parms));
      }
    } else if (strcmp(tag,"destructor") == 0) {
      char *name = Char(Getname(n))+1;
      String *code  = Getattr(n,"code");
      String *storage = Getattr(n,"storage");
      
      if (cplus_mode == CPLUS_PUBLIC) {
	char *iname = make_name(name);
	if (iname == name) iname = 0;
	if (name && (*name == '~')) name = name + 1;
	if (iname && (*iname == '~')) iname = iname + 1; 
	if (Cmp(name,iname) == 0) iname = 0;
	cplus_destructor(name,iname);
      }

    } else if (strcmp(tag,"access") == 0) {
      String *kind = Getattr(n,"kind");
      if (Cmp(kind,"public") == 0) {
	cplus_mode = CPLUS_PUBLIC;
      } else if (Cmp(kind,"private") == 0) {
	cplus_mode = CPLUS_PRIVATE;
      } else if (Cmp(kind,"protected") == 0) {
	cplus_mode = CPLUS_PROTECTED;
      }
    } else if (strcmp(tag,"operator") == 0) {
      String *name = Getname(n);
      SwigType *type = Gettype(n);
      SwigType *decl = Getdecl(n);
      Parm     *parms = Getparms(n);
      String   *code = Getattr(n,"code");
    } else {
      Printf(stderr,"%s:%d. Unrecognized parse tree node type '%s'\n", input_file, line_number, tag);
    }
    n = Getnext(n);
  }
  return;
 g_error:
  Printf(stderr,"SWIG: Fatal internal error. Malformed parse tree!\n");
  return;
}

void generate_all(Node *n) {
  generate(n);
  /*  Swig_dump_tree(n); */
  if (lang_init) {
    cplus_cleanup();
    lang->close();
  }
}

