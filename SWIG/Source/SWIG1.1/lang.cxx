/* ----------------------------------------------------------------------------- 
 * lang.cxx
 *
 *     Language base class functions.  Default C++ handling is also implemented here.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "internal.h"
#include <ctype.h>

extern "C" {
#include "swig.h"
}

/* Some status variables used during parsing */

static int      InClass = 0;          /* Parsing C++ or not */
static String  *ClassName = 0;        /* This is the real name of the current class */
static String  *ClassRename = 0;      /* This is non-NULL if the class has been renamed */
static String  *ClassTag = 0;         /* Type of class (ie. union, struct, class)  */
static String  *ClassPrefix = 0;      /* Class prefix */
static String  *ClassType = 0;        /* Fully qualified type name to use */
static int      lang_init = 0;
static int      Abstract = 0;
static int      has_constructor = 0;
static int      has_destructor = 0;
static int      has_copy = 0;
static int      private_constructor = 0;
static int      private_destructor = 0;
static int      base_default_constructor = 0;
static int      has_default_constructor = 0;
static String  *Callback = 0;
int             IsVirtual = 0;
static String  *AttributeFunctionGet = 0;
static String  *AttributeFunctionSet = 0;
static String  *ActionFunc = 0;
static int      cplus_mode = 0;

/* import modes */

#define  IMPORT_MODE     1
#define  IMPORT_MODULE   2

/* C++ access modes */

#define CPLUS_PUBLIC     0
#define CPLUS_PROTECTED  1
#define CPLUS_PRIVATE    2

/* ----------------------------------------------------------------------
   emit_one()
   ---------------------------------------------------------------------- */

void emit_one(Node *n) {
    String *err;
    Symtab *symtab;

    char *tag = Char(nodeType(n));
    if (!tag) {
      Printf(stderr,"SWIG: Fatal internal error. Malformed parse tree node!\n");
      return;
    }
    if ((err = Geterror(n))) {
      return;
    }
    line_number = Getline(n);
    input_file = Char(Getfile(n));

    symtab = Getattr(n,"symtab");
    if (symtab) {
      Swig_symbol_setscope(symtab);
    }
    
    if (strcmp(tag,"top") == 0) {
      lang->top(n);
    } else if (strcmp(tag,"addmethods") == 0) {
      lang->addmethodsDirective(n);
    } else if (strcmp(tag,"apply") == 0) {
      lang->applyDirective(n);
    } else if (strcmp(tag,"clear") == 0) {
      lang->clearDirective(n);
    } else if (strcmp(tag,"constant") == 0) {
      lang->constantDirective(n);
    } else if (strcmp(tag,"except") == 0) {
      lang->exceptDirective(n);
    } else if (strcmp(tag,"import") == 0) {
      lang->importDirective(n);
    } else if (strcmp(tag,"include") == 0) {
      lang->includeDirective(n);
    } else if (strcmp(tag,"insert") == 0) {
      lang->insertDirective(n);
    } else if (strcmp(tag,"module") == 0) { 
      lang->moduleDirective(n);
    } else if (strcmp(tag,"native") == 0) {
      lang->nativeDirective(n);
    } else if (strcmp(tag,"new") == 0) {
      lang->newDirective(n);
    } else if (strcmp(tag,"pragma") == 0) {
      lang->pragmaDirective(n);
    } else if (strcmp(tag,"typemap") == 0) {
      lang->typemapDirective(n);
    } else if (strcmp(tag,"typemapcopy") == 0) {
      lang->typemapcopyDirective(n);
    } else if (strcmp(tag,"types") == 0) {
      lang->typesDirective(n);
    }

      /* ============================================================
       * C/C++ parsing
       * ============================================================ */

    else if (strcmp(tag,"extern") == 0) {
      lang->externDeclaration(n);
    } else if (strcmp(tag,"cdecl") == 0) {
      lang->cDeclaration(n);
    } else if (strcmp(tag,"enum") == 0) {
      lang->enumDeclaration(n);
    } else if (strcmp(tag,"enumitem") == 0) {
      lang->enumvalueDeclaration(n);
    } else if (strcmp(tag,"class") == 0) {
      lang->classDeclaration(n);
    } else if (strcmp(tag,"classforward") == 0) {
      lang->classforwardDeclaration(n);
    } else if (strcmp(tag,"constructor") == 0) {
      lang->constructorDeclaration(n);
    } else if (strcmp(tag,"destructor") == 0) {
      lang->destructorDeclaration(n);
    } else if (strcmp(tag,"operator") == 0) {
      lang->operatorDeclaration(n);
    } else if (strcmp(tag,"access") == 0) {
      lang->accessDeclaration(n);
    } else {
      Printf(stderr,"%s:%d. Unrecognized parse tree node type '%s'\n", input_file, line_number, tag);
    }
}

/* Create a type list from a set of parameters */
static List *typelist(Parm *p) {
   List *l = NewList();
   while (p) {
     Append(l,Gettype(p));
     p = nextSibling(p);
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

/* --------------------------------------------------------------------------
 * swig_pragma()
 *
 * Handle swig pragma directives.  
 * -------------------------------------------------------------------------- */

void swig_pragma(char *lang, char *name, char *value) {
  if (strcmp(lang,"swig") == 0) {
    if ((strcmp(name,"make_default") == 0) || ((strcmp(name,"makedefault") == 0))) {
      GenerateDefault = 1;
    } else if ((strcmp(name,"no_default") == 0) || ((strcmp(name,"nodefault") == 0))) {
      GenerateDefault = 0;
    } else if (strcmp(name,"readonly") == 0) {
      Status = Status | STAT_READONLY;
    } else if (strcmp(name,"readwrite") == 0) {
      Status = Status & ~STAT_READONLY;
    } else if (strcmp(name,"callback") == 0) {
      Callback = Swig_copy_string(value ? value:"%s");
    } else if (strcmp(name,"nocallback") == 0) {
      Callback = 0;
    } else if (strcmp(name,"attributefunction") == 0) {
      String *nvalue = NewString(value);
      char *s = strchr(Char(nvalue),':');
      if (!s) {
	Printf(stderr,"%s:%d. Bad value for attributefunction. Expected \"fmtget:fmtset\".\n",
	       input_file, line_number);
      } else {
	*s = 0;
	AttributeFunctionGet = NewString(Char(nvalue));
	AttributeFunctionSet = NewString(s+1);
      }
      Delete(nvalue);
    } else if (strcmp(name,"noattributefunction") == 0) {
      AttributeFunctionGet = 0;
      AttributeFunctionSet = 0;
    }
  }
}

/* generate C++ inheritance type-relationships */
static void cplus_inherit_types(Node *cls, String *clsname) {
  List *ilist = Getattr(cls,"bases");

  if (!ilist) return;
  int len = Len(ilist);
  int i;
  for (i = 0; i < len; i++) {
    Node *n = Getitem(ilist,i);
    Node *bname = Getname(n);
    Node *bclass = Getattr(n,"class");
    Hash *scopes = Getattr(bclass,"typescope");
    
    private_constructor |= GetInt(bclass,"private_constructor");
    private_destructor |= GetInt(bclass,"private_destructor");
    base_default_constructor &= GetInt(bclass,"default_constructor");

    SwigType_inherit(clsname,bname);
    String *btype = Copy(bname);
    SwigType_add_pointer(btype);
    SwigType_remember(btype);
    Delete(btype);
    if (scopes)
      SwigType_merge_scope(scopes);
    cplus_inherit_types(bclass,clsname);
  }
}

/* ----------------------------------------------------------------------
 * Language::top()   - Top of parsing tree 
 * ---------------------------------------------------------------------- */

void Language::top(Node *n) {
  Node *c;
  String *name = Getname(n);
  if (!name) {
    Printf(stderr,"*** No module name specified using %%module or -module.\n");
    return;
  }
  lang->set_module(Char(name));
  lang->initialize();
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
  lang->close();
}

/* ----------------------------------------------------------------------
 * Language::addmethodsDirective()
 * ---------------------------------------------------------------------- */

void Language::addmethodsDirective(Node *n) {
  int oldam = AddMethods;
  Node *c;
  AddMethods = 1;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
  AddMethods = oldam;
}

/* ----------------------------------------------------------------------
 * Language::applyDirective()
 * ---------------------------------------------------------------------- */

void Language::applyDirective(Node *n) {
  SwigType *type = Gettype(n);
  String   *name = Getname(n);
  Parm     *p    = Getparms(n);
  while (p) {
    Swig_typemap_apply(type,name,Gettype(p),Getname(p));
    p = nextSibling(p);
  }
}

/* ----------------------------------------------------------------------
 * Language::clearDirective()
 * ---------------------------------------------------------------------- */

void Language::clearDirective(Node *n) {
  Parm *p;
  for (p = Getparms(n); p; p = nextSibling(p)) {
    Swig_typemap_clear_apply(Gettype(p),Getname(p));
  }
}

/* ----------------------------------------------------------------------
 * Language::constantDirective()
 * ---------------------------------------------------------------------- */

void Language::constantDirective(Node *n) {
  if (!ImportMode) {
    this->constantWrapper(n);
  }
}

/* ----------------------------------------------------------------------
 * Language::exceptDirective()
 * ---------------------------------------------------------------------- */

void Language::exceptDirective(Node *n) {
  String *code = Getattr(n,"code");
  if (code) {
    Swig_except_register(code);
  } else {
    Swig_except_clear();
  }
}


/* ----------------------------------------------------------------------
 * Language::importDirective()
 * ---------------------------------------------------------------------- */

void Language::importDirective(Node *n) {
  Node *c;
  int oldim = ImportMode;
  ImportMode = IMPORT_MODE;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
  if (ImportMode & IMPORT_MODULE) {
    lang->import_end();
  }
  ImportMode = oldim;
}

/* ----------------------------------------------------------------------
 * Language::includeDirective()
 * ---------------------------------------------------------------------- */

void Language::includeDirective(Node *n) {
  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
}

/* ----------------------------------------------------------------------
 * Language::insertDirective()
 * ---------------------------------------------------------------------- */

void Language::insertDirective(Node *n) {
  /* %insert directive */
  if (!ImportMode) {
    String *code     = Getattr(n,"code");
    String *section  = Getattr(n,"section");
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
}

/* ----------------------------------------------------------------------
 * Language::moduleDirective()
 * ---------------------------------------------------------------------- */

void Language::moduleDirective(Node *n) {
  /* %module directive */
  String *name = Getname(n);
  if (ImportMode) {
    if (ImportMode == IMPORT_MODE) {
      lang->import_start(Char(name));
      ImportMode |= IMPORT_MODULE;
    } 
  } else {
    lang->set_module(Char(name));
  }
}

/* ----------------------------------------------------------------------
 * Language::nativeDirective()
 * ---------------------------------------------------------------------- */

void Language::nativeDirective(Node *n) {
  
  if (!ImportMode) {
    String *name = Getattr(n,"cname");
    String *symname = Getsymname(n);
    SwigType *type = Gettype(n);
    Parm    *parms = Getparms(n);
    
    lang->add_native(Char(name),Char(symname),type,parms);
  }
}

/* ----------------------------------------------------------------------
 * Language::newDirective()
 * ---------------------------------------------------------------------- */

void Language::newDirective(Node *n) {
  /* %new directive */
  NewObject = 1;
  emit_one(firstChild(n));
  NewObject = 0;
}

/* ----------------------------------------------------------------------
 * Language::pragmaDirective()
 * ---------------------------------------------------------------------- */

void Language::pragmaDirective(Node *n) {
  /* %pragma directive */
  if (!ImportMode) {
    String *lan = Getattr(n,"lang");
    String *name = Getname(n);
    String *value = Getvalue(n);
    swig_pragma(Char(lan),Char(name),Char(value));
    lang->pragma(Char(lan),Char(name),Char(value));
  }
}

/* ----------------------------------------------------------------------
 * Language::typemapDirective()
 * ---------------------------------------------------------------------- */

void Language::typemapDirective(Node *n) {
  /* %typemap directive */
  String *method = Getattr(n,"method");
  String *code = Getattr(n,"code");
  Node   *items = firstChild(n);
  while (items) {
    SwigType *type = Gettype(items);
    String   *name = Getname(items);
    Parm     *parms = Getparms(items);
    if (code) {
      Swig_typemap_register(method,type,name,code,parms);
    } else {
      Swig_typemap_clear(method,type,name);
    }
    items = nextSibling(items);
  }
}

/* ----------------------------------------------------------------------
 * Language::typemapcopyDirective()
 * ---------------------------------------------------------------------- */

void Language::typemapcopyDirective(Node *n) {
  String *method = Getattr(n,"method");
  String *name   = Getname(n);
  String *type   = Gettype(n);
  Node *items = firstChild(n);
  while (items) {
    SwigType *newtype = Getattr(items,"newtype");
    String   *newname = Getattr(items,"newname");
    Swig_typemap_copy(method,type,name,newtype,newname);
    items = nextSibling(items);
  }
}

/* ----------------------------------------------------------------------
 * Language::typesDirective()
 * ---------------------------------------------------------------------- */

void Language::typesDirective(Node *n) {
  Parm  *parms = Getparms(n);
  while (parms) {
    SwigType *t = Gettype(parms);
    SwigType_remember(t);
    parms = nextSibling(parms);
  }
}

/* ----------------------------------------------------------------------
 * Language::cDeclaration()
 * ---------------------------------------------------------------------- */

void Language::cDeclaration(Node *n) {
  String *name    = Getname(n);
  String *symname = Getsymname(n);
  SwigType *type  = Gettype(n);
  SwigType *decl  = Getdecl(n);
  String *storage = Getattr(n,"storage");
  String *code    = Getattr(n,"code");
  Parm   *parms   = Getparms(n);
  String *value   = Getvalue(n);
  Node   *over;
  CCode = code;
  emit_set_action(0);

  if (InClass && (cplus_mode != CPLUS_PUBLIC)) return;

  if (Cmp(storage,"typedef") == 0) {
    SwigType *t = Copy(type);
    if (t) {
      SwigType_push(t,decl);
      SwigType_typedef(t,name);
      lang->add_typedef(t,Char(name));
    }
    return;
  } else if (Cmp(storage,"friend") == 0) {
    return;
  } 

  /* If in import mode, we proceed no further */
  if (ImportMode) return;

  /* Overloaded symbol check */
  over = Swig_symbol_isoverloaded(n);
  if (over && (over != n)) {
    SwigType *tc = Copy(decl);
    SwigType *td = SwigType_pop(tc);
    String   *oname;
    String   *cname;
    if (InClass) {
      oname = NewStringf("%s::%s",ClassName,name);
      cname = NewStringf("%s::%s",ClassName,Getname(over));
    } else {
      oname = NewString(name);
      cname = NewString(Getname(over));
    }
    Printf(stderr,"%s:%d. Overloaded declaration ignored.  %s\n",
	   input_file,line_number, SwigType_str(td,oname));
    
    Printf(stdout,"%s:%d. Previous declaration is %s\n", Getfile(over),Getline(over), SwigType_str(Getdecl(over),cname));
    Delete(tc);
    Delete(td);
    Delete(oname);
    Delete(cname);
    return;
  }
  
  if (strstr(Char(name),"::")) {
    Printf(stderr,"%s:%d. Warning. Qualified declaration %s ignored.\n", input_file, line_number, name);    
    return;
  }

  if (Cmp(storage,"virtual") == 0) {
    if (Cmp(value,"0") == 0) {
      IsVirtual = PURE_VIRTUAL;
    } else {
      IsVirtual = PLAIN_VIRTUAL;
    }
  } else {
    IsVirtual = 0;
  }

  SwigType *ty = Copy(type);
  if (SwigType_isfunction(decl)) {
    /* Functions */
    SwigType_push(ty,decl);
    if (!InClass) {
      if ((Cmp(storage,"extern") == 0) || (ForceExtern && !storage)) {
	Printf(f_header,"extern %s;\n", SwigType_str(ty,name));
      } else if (Cmp(storage,"externc") == 0) {
	Printf(f_header,"extern \"C\" %s;\n", SwigType_str(ty,name));
      }
    }
    Delete(SwigType_pop(ty));

    /* Static functions */
    if (Cmp(storage,"static") == 0) {
      if (InClass) {
	lang->cpp_static_func(Char(name),Char(symname),ty,nonvoid_parms(parms));
      }
    } else {
      /* Normal functions */
      if (Callback) {
	String *cbname = NewStringf(Callback,symname);
	String *cbvalue;
	SwigType *cbty = Copy(type);
	SwigType_push(cbty, decl);
	if (!InClass) {
	  SwigType_add_pointer(cbty);
	  cbvalue = NewString(name);
	} else {
	  SwigType_add_memberpointer(cbty,ClassName);
	  cbvalue = NewStringf("&%s::%s",ClassName,name);
	}
	if (Cmp(cbname,symname) == 0) {
	  if (!InClass) {
	    lang->declare_const(Char(name),Char(symname),cbty,Char(cbvalue));
	  } else {
	    lang->cpp_declare_const(Char(name), Char(symname),cbty, Char(cbvalue));
	  }
	} else {
	  if (!InClass) {
	    lang->declare_const(Char(name),Char(cbname), cbty, Char(cbvalue));
	    lang->create_function(Char(name),Char(symname),ty,nonvoid_parms(parms));
	  } else {
	    lang->cpp_declare_const(Char(name),Char(cbname),cbty,Char(cbvalue));
	    lang->cpp_member_func(Char(name),Char(symname),ty,nonvoid_parms(parms));
	  }
	}
	Delete(cbvalue);
	Delete(cbty);
	Delete(cbname);
      } else {
	if (!InClass) {
	  lang->create_function(Char(name),Char(symname),ty,nonvoid_parms(parms));
	} else {
	  lang->cpp_member_func(Char(name),Char(symname),ty,nonvoid_parms(parms));
	}
      }
    }
  } else {
    /* Some kind of variable declaration */
    SwigType_push(ty,decl);
    int oldstatus = Status;
    if (Getattr(n,"nested")) Status |= STAT_READONLY;
    if (!InClass) {
      if ((Cmp(storage,"extern") == 0) || ForceExtern) {
	Printf(f_header,"extern %s;\n", SwigType_str(ty,name));
      }
    }
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
    if (Cmp(storage,"static") == 0) {
      if (InClass) {
	lang->cpp_static_var(Char(name),Char(symname),ty);
      }
    } else {
      if (!InClass) {
	lang->link_variable(Char(name),Char(symname),ty);
      } else {
	if (!AttributeFunctionGet) {
	  lang->cpp_variable(Char(name),Char(symname),ty);
	} else {

	  /* This code is used to support the attributefunction directive 
	     where member variables are converted automagically to 
             accessor functions */

	  Parm *p;
	  String *gname;
	  SwigType *vty;
	  p = NewParm(ty,0);
	  gname = NewStringf(AttributeFunctionGet,symname);
	  if (!AddMethods) {
	    ActionFunc = Copy(Swig_cmemberget_call(name,ty));
	    lang->cpp_member_func(Char(gname),Char(gname),ty,0);
	    Delete(ActionFunc);
	  } else {
	    String *cname = Copy(Swig_name_get(name));
	    lang->cpp_member_func(Char(cname),Char(gname),ty,0);
	    Delete(cname);
	  }
	  Delete(gname);
	  if (!(Status & STAT_READONLY)) {
	    gname = NewStringf(AttributeFunctionSet,symname);
	    vty = NewString("void");
	    if (!AddMethods) {
	      ActionFunc = Copy(Swig_cmemberset_call(name,ty));
	      lang->cpp_member_func(Char(gname),Char(gname),vty,p);
	      Delete(ActionFunc);
	    } else {
	      String *cname = Copy(Swig_name_set(name));
	      lang->cpp_member_func(Char(cname),Char(gname),vty,p);
	      Delete(cname);
	    }
	    Delete(gname);
	  }
	  ActionFunc = 0;
	}
      }
    }
    Status = oldstatus;
  }
  Delete(ty);
}

/* ----------------------------------------------------------------------
 * Language::externDeclaration()
 * ---------------------------------------------------------------------- */

void Language::externDeclaration(Node *n) {
  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
}

/* ----------------------------------------------------------------------
 * Language::enumDeclaration()
 * ---------------------------------------------------------------------- */

void Language::enumDeclaration(Node *n) {
  String *name = Getname(n);
  if (!ImportMode) {
    Node *c;
    for (c = firstChild(n); c; c = nextSibling(c)) {
      emit_one(c);
    }
  }
  if (name) {
    SwigType *t = NewStringf("enum %s", name);
    SwigType_typedef(t,name);
    Delete(t);
    lang->add_typedef(t,Char(name));
  }
}

/* ----------------------------------------------------------------------
 * Language::enumvalueDeclaration()
 * ---------------------------------------------------------------------- */

void Language::enumvalueDeclaration(Node *n) {
  if (InClass && (cplus_mode != CPLUS_PUBLIC)) return;

  if (!InClass) {
    /* A normal C enum */
    constantWrapper(n);
  } else {
    Hash *h;
    String *newvalue;
    String *name = Getname(n);
    String *symname = Getsymname(n);
    String *value = Getvalue(n);
    String *type  = Gettype(n);
    if (Cmp(value,name) == 0) {
      newvalue = 0;
    } else {
      newvalue = value;
    }
    this->cpp_declare_const(Char(name),Char(symname),type,Char(newvalue));
  }
}

/* ----------------------------------------------------------------------
 * Language::classDeclaration()
 * ---------------------------------------------------------------------- */

void Language::classDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  String *name = Getattr(n,"name");
  List   *bases = Getattr(n,"bases");
  String *tdname = Getattr(n,"tdname");
  String *symname = Getsymname(n);
  char *classname = tdname ? Char(tdname) : Char(name);
  char *iname = Char(symname);
  int   strip = (tdname || CPlusPlus) ? 1 : 0;

  if (Cmp(kind,"class") == 0) {
    cplus_mode = CPLUS_PRIVATE;
  } else {
    cplus_mode = CPLUS_PUBLIC;
  }

  if (name) {
    this->cpp_class_decl(Char(name),iname, Char(kind));
  } else {
    this->cpp_class_decl(classname,iname, Char(kind));
  }
  SwigType_new_scope();
  if (name) SwigType_set_scope_name(name);
    
  if (!ImportMode) {
    this->cpp_open_class(classname,iname,Char(kind),strip);
  }
  InClass = 1;
  Abstract = GetInt(n,"abstract");
  has_constructor = 0;
  has_destructor = 0;
  private_constructor = 0;
  private_destructor = 0;
  base_default_constructor = Abstract ? 0 : 1;
  has_default_constructor = 0;

  /* Inherit type definitions into the class */
  if (CPlusPlus && name) {
    cplus_inherit_types(n,name);
  }

  /* Emit all of the members */
  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }

  if (private_constructor) {
    SetInt(n,"private_constructor",1);
  }
  if (private_destructor) {
    SetInt(n,"private_destructor",1);
  }
  if ((base_default_constructor) || (has_default_constructor)) {
    SetInt(n,"default_constructor",1);
  }
  
  if (!ImportMode) {
    if (GenerateDefault) {
      CCode = 0;
      if ((!has_constructor) && (!private_constructor) && (base_default_constructor)) {
	/* Generate default constructor */
	this->cpp_constructor(classname,iname,0);
	SetInt(n,"default_constructor",1);
      } 
      if ((!has_destructor) && (!private_destructor)) {
	/* Generate default destructor */
	this->cpp_destructor(classname,iname);
      }
    }
    char *baselist[256];
    int   i = 0;
    for (i = 0; i < Len(bases); i++) {
      baselist[i] = Char(Getname(Getitem(bases,i)));
    }
    baselist[i] = 0;
    lang->cpp_inherit(baselist,i);
    lang->cpp_close_class();
  }
  Hash *ts = SwigType_pop_scope();
  Setattr(n,"typescope",ts);
  InClass = 0;
}

/* ----------------------------------------------------------------------
 * Language::classforwardDeclaration()
 * ---------------------------------------------------------------------- */

void Language::classforwardDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  String *name = Getname(n);
  String *symname = Getsymname(n);
  if (!symname) symname = name;
  lang->cpp_class_decl(Char(name),Char(symname),Char(kind));
}

/* ----------------------------------------------------------------------
 * Language::constructorDeclaration()
 * ---------------------------------------------------------------------- */

void Language::constructorDeclaration(Node *n) {
  String *name = Getname(n);
  String *symname = Getsymname(n);
  Parm   *parms = Getparms(n);
  String *code  = Getattr(n,"code");
  CCode = code;

  /* If a class defines a constructor, it overrides any default constructors in the base. 
     Note: constructors are not inherited  */

  base_default_constructor = 0;

  /* Private/protected inheritance check.   We can't generate a constructor
     in this case, but need to record some information so that derived classes
     don't try to generate default constructors */

  if (InClass && (cplus_mode != CPLUS_PUBLIC)) {
    if (!has_constructor) {
      if (cplus_mode == CPLUS_PRIVATE) {
	private_constructor = 1;
      } else {
	/* Protected mode: class has a default constructor, but it's not accessible directly */
	if (!ParmList_numrequired(parms)) {
	  has_default_constructor = 1;
	}
      }
    }
    has_constructor = 1;
    return;
  }
  private_constructor = 0;
  
  if (ImportMode) return;
  if (Cmp(symname,name) == 0) symname = 0;

  /* Check for default constructor.  A class has a default constructor if it 
     has a constructor that will accept no arguments */
  if (!(AddMethods) && (ParmList_numrequired(parms) == 0)) {
    has_default_constructor = 1;
  }
  if (!Abstract) {
    Node *over;
    over = Swig_symbol_isoverloaded(n);
    if ((over) && (over != n)) {
      String *oname = NewStringf("%s::%s", ClassName, name);
      String *cname = NewStringf("%s::%s", ClassName, Getname(over));
      SwigType *decl = Getdecl(n);
      Printf(stderr,"%s:%d. Overloaded constructor ignored.  %s\n", input_file,line_number, SwigType_str(decl,oname));
      Printf(stderr,"%s:%d. Previous declaration is %s\n", Getfile(over),Getline(over),SwigType_str(Getdecl(over),cname));
      Delete(oname);
      Delete(cname);
    } else {
      Parm *nv = nonvoid_parms(parms);
      lang->cpp_constructor(Char(name),Char(symname),nv);
    }
  }
  has_constructor = 1;
}

/* ----------------------------------------------------------------------
 * Language::destructorDeclaration()
 * ---------------------------------------------------------------------- */

void Language::destructorDeclaration(Node *n) {
  String *name = Getname(n);
  String *symname = Getsymname(n);
  String *code  = Getattr(n,"code");
  CCode = code;
  String *storage = Getattr(n,"storage");

  if (InClass && (cplus_mode != CPLUS_PUBLIC)) {
    has_destructor = 1;
    if (cplus_mode == CPLUS_PRIVATE)
      private_destructor = 1;
    return;
  }
  if (!AddMethods) 
    private_destructor = 0;
  if (ImportMode) return;

  char *cname = Char(name);
  if (*cname == '~') cname += 1;
  char *csymname = Char(symname);
  if (csymname && (*csymname == '~')) csymname +=1;
  lang->cpp_destructor(cname,csymname);
  has_destructor = 1;
}

/* ----------------------------------------------------------------------
 * Language::operatorDeclaration()
 * ---------------------------------------------------------------------- */

void Language::operatorDeclaration(Node *n) {

}

/* ----------------------------------------------------------------------
 * Language::accessDeclaration()
 * ---------------------------------------------------------------------- */

void Language::accessDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  if (Cmp(kind,"public") == 0) {
    cplus_mode = CPLUS_PUBLIC;
  } else if (Cmp(kind,"private") == 0) {
    cplus_mode = CPLUS_PRIVATE;
  } else if (Cmp(kind,"protected") == 0) {
    cplus_mode = CPLUS_PROTECTED;
  }
}

/* ----------------------------------------------------------------------
 * Language::constantWrapper()
 * ---------------------------------------------------------------------- */

void Language::constantWrapper(Node *n) {
  String *name    = Getname(n);
  String *symname = Getsymname(n);
  SwigType *type  = Gettype(n);
  String *value   = Getvalue(n);

  if (!value) {
    value = Copy(name);
  } else {
    value = NewStringf("%(escape)s",value);
  }

  lang->declare_const(Char(name),Char(symname),type,Char(value));
  Delete(value);
}


/* ----------------------------------------------------------------------
 * Language::variableWrapper()
 * ---------------------------------------------------------------------- */
void Language::variableWrapper(Node *n) {

}

/* ----------------------------------------------------------------------
 * Language::functionWrapper()
 * ---------------------------------------------------------------------- */

void Language::functionWrapper(Node *n) {

}


/* -----------------------------------------------------------------
 * Language::create_command()
 * -----------------------------------------------------------------  */

void Language::create_command(char *, char *) {
  Printf(stderr,"SWIG Warning. No command creation procedure defined.\n");
  Printf(stderr,"C++ inheritance may not work correctly.\n");
}

/* -----------------------------------------------------------------
 * Language::add_native()
 * ----------------------------------------------------------------- */

void
Language::add_native(char *, char *iname, SwigType *, ParmList *) {
  Printf(stderr,"%s:%d.  Adding native function %s not supported (ignored).\n", input_file, line_number, iname);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_open_class()
 * ----------------------------------------------------------------------------- */

void Language::cpp_open_class(char *classname, char *classrename, char *ctype, int strip) {

  /* Copy the class name */

  ClassName = NewString(classname);

  /* Copy the class renaming */

  if (classrename) {
    ClassRename = NewString(classrename);
  } else {
    ClassRename = 0;           /* No renaming */
  }

  /* Set class prefix */
  ClassPrefix = ClassRename ? ClassRename : ClassName;

  /* Make the class type*/
  if (strip) {
    ClassTag = NewString("");
  } else {
    ClassTag = NewStringf("%s ", ctype);
  }
  ClassType = NewStringf("%s%s", ClassTag,ClassName);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_close_class()
 * ----------------------------------------------------------------------------- */

void Language::cpp_close_class() {
  /* Doesn't really do anything  */
}

/* -----------------------------------------------------------------------------
 * Language::cpp_member_func()
 *
 * Wrap a member function
 * ----------------------------------------------------------------------------- */

void Language::cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l) {
  String *fname;
  Wrapper *w;

  /* Generate the C wrapper function name and interpreter name of this function*/
  /* Create the actual function name */

  fname = Copy(Swig_name_member(ClassPrefix, iname ? iname : name));
  w = Swig_cmethod_wrapper(ClassType, name, t, l, CCode);
  if (AddMethods && CCode) {
    /* Produce an actual C wrapper */
    Wrapper_print(w,f_wrappers);
  } else if (!AddMethods) {
    /* C++ member. Produce code that does the actual work */
    if (!ActionFunc)
      emit_set_action(Swig_cmethod_call(name, Wrapper_Getparms(w)));
    else
      emit_set_action(ActionFunc);
  }
  lang->create_function(Wrapper_Getname(w), Char(fname), Wrapper_Gettype(w), Wrapper_Getparms(w));
  DelWrapper(w);
  Delete(fname);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_constructor()
 * ----------------------------------------------------------------------------- */

void Language::cpp_constructor(char *name, char *iname, ParmList *l) {
  String *cname;
  String *mrename;
  Wrapper *w;

  if (Cmp(name,ClassName)) {
    Printf(stderr,"%s:%d.  Function %s must have a return type.\n", 
	    input_file, line_number, name);
    return;
  }
  cname = Copy(Swig_name_construct(ClassName));
  mrename = Copy(Swig_name_construct(iname ? iname : ClassPrefix));

  if (CPlusPlus) {
    w = Swig_cppconstructor_wrapper(ClassType, l, CCode);
  } else {
    w = Swig_cconstructor_wrapper(ClassType,l,CCode);
  }
  
  if (!AddMethods) {
    if (CPlusPlus) {
      emit_set_action(Swig_cppconstructor_call(ClassType, l));
    } else {
      emit_set_action(Swig_cconstructor_call(ClassType));
    }
  } else {
    if (CCode) {
      Wrapper_print(w,f_wrappers);
    }
  }
  lang->create_function(Wrapper_Getname(w), Char(mrename), Wrapper_Gettype(w), Wrapper_Getparms(w));
  DelWrapper(w);
  Delete(cname);
  Delete(mrename);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_destructor()
 * ----------------------------------------------------------------------------- */

void Language::cpp_destructor(char *name, char *iname) {
  String *cname;
  String *mrename;
  Wrapper *w;

  cname = Copy(Swig_name_destroy(ClassPrefix));
  mrename = Copy(Swig_name_destroy(iname ? iname : name));

  if (CPlusPlus) {
    w = Swig_cppdestructor_wrapper(ClassType,CCode);
  } else {
    w = Swig_cdestructor_wrapper(ClassType, CCode);
  }
  if (AddMethods && CCode) {
    Wrapper_print(w,f_wrappers);
    lang->create_function(Wrapper_Getname(w),Char(mrename),Wrapper_Gettype(w), Wrapper_Getparms(w));
  } else if (AddMethods) {
    lang->create_function(Wrapper_Getname(w),Char(mrename),Wrapper_Gettype(w), Wrapper_Getparms(w));
  } else {
    if (CPlusPlus) {
      emit_set_action(Swig_cppdestructor_call());
    } else {
      emit_set_action(Swig_cdestructor_call());
    }
    lang->create_function(Char(cname), Char(mrename), Wrapper_Gettype(w), Wrapper_Getparms(w));      
  }
  DelWrapper(w);
  Delete(cname);
  Delete(mrename);
}

/* ----------------------------------------------------------------------------- 
 * Language::cleanup()
 * ----------------------------------------------------------------------------- */

void Language::cpp_cleanup() {
  /* This doesn't do anything (well, not be default) */
}

/* ----------------------------------------------------------------------------- 
 * Language::cpp_inherit()
 * ----------------------------------------------------------------------------- */

void Language::cpp_inherit(char **baseclass, int mode) {
  /*  
  extern void cplus_inherit_members(char *, int);
  int    i = 0;

  if (!baseclass) return;
  while (baseclass[i]) {
    cplus_inherit_members(baseclass[i],mode);
    i++;
  }
  */
}

/* -----------------------------------------------------------------------------
 * Language::cpp_variable()
 * ----------------------------------------------------------------------------- */

void Language::cpp_variable(char *name, char *iname, SwigType *t) {
  
  String *cname_get, *cname_set;
  String *mrename_get, *mrename_set;
  
  cname_get = Copy(Swig_name_get(Swig_name_member(ClassPrefix,name)));
  cname_set = Copy(Swig_name_set(Swig_name_member(ClassPrefix,name)));
  
  mrename_get = Copy(Swig_name_get(Swig_name_member(ClassPrefix, iname ? iname : name)));
  mrename_set = Copy(Swig_name_set(Swig_name_member(ClassPrefix, iname ? iname : name)));

  /* Create a function to set the value of the variable */

  if (!(Status & STAT_READONLY)) {
    Wrapper   *w;
    int       make_wrapper = 1;
    w = Swig_cmemberset_wrapper(ClassType,name,t,CCode);

    // Only generate code if already existing wrapper doesn't exist
    if ((AddMethods) && (CCode)) {
      Wrapper_print(w,f_wrappers);
    } else if (!AddMethods) {
      /* Check for a member in typemap here */
      String *target = NewStringf("%s->%s", Swig_cparm_name(0,0),name);
      char *tm = Swig_typemap_lookup((char *) "memberin",t,name,Swig_cparm_name(0,1),target,0);
      if (!tm) {
	if (SwigType_isarray(t)) make_wrapper = 0;
	emit_set_action(Swig_cmemberset_call(name,t));
      }  else {
	emit_set_action(tm);
      }
      Delete(target);
    }
    if (make_wrapper) {
      lang->create_function(Wrapper_Getname(w),Char(mrename_set), Wrapper_Gettype(w), Wrapper_Getparms(w));
    } else {
      Status |= STAT_READONLY;       /* Note: value is restored by generate.cxx */
    }
    DelWrapper(w);
  }

  /* Emit get function */
  {
    Wrapper   *w;
    w = Swig_cmemberget_wrapper(ClassType,name,t, CCode);
    if ((AddMethods) && (CCode)) {
      Wrapper_print(w,f_wrappers);
    } else if (!AddMethods) {
      emit_set_action(Swig_cmemberget_call(name, t));
    }
    lang->create_function(Wrapper_Getname(w),Char(mrename_get), Wrapper_Gettype(w), Wrapper_Getparms(w));
    DelWrapper(w);
  }
  Delete(cname_get);
  Delete(cname_set);
  Delete(mrename_get);
  Delete(mrename_set);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_static_func()
 * ----------------------------------------------------------------------------- */

void Language::cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l) {
  String *cname;
  String *mrename;

  if (!AddMethods) {
    cname = NewStringf("%s::%s",ClassPrefix,name);
  } else {
    cname = Copy(Swig_name_member(ClassPrefix,name));    
  }
  mrename = Copy(Swig_name_member(ClassPrefix,iname ? iname: name));
  if (!AddMethods) {
    // Not an added method 
    lang->create_function(Char(cname),Char(mrename), t, l);
  } else {
    if (!CCode) {
      lang->create_function(Char(cname),Char(mrename), t, l);
    } else {
      Wrapper *w = Swig_cfunction_wrapper(cname, t, l, CCode);
      Wrapper_print(w,f_wrappers);	  
      lang->create_function(Char(cname),Char(mrename), Wrapper_Gettype(w), Wrapper_Getparms(w));
      DelWrapper(w);
    }
  }
  Delete(cname);
  Delete(mrename);
}

/* ----------------------------------------------------------------------------- 
 * Language::cpp_declare_const()
 * ----------------------------------------------------------------------------- */

void Language::cpp_declare_const(char *name, char *iname, SwigType *type, char *value)
{
  String *mrename;
  String *new_value;

  mrename = Copy(Swig_name_member(ClassPrefix, iname ? iname : name));

  /* Declare a constant */
  if (!value) {
    new_value = NewStringf("%s::%s",ClassName,name);
  } else {
    new_value = NewString(value);
  }
  lang->declare_const(Char(mrename),Char(mrename),type,Char(new_value));
  Delete(mrename);
  Delete(new_value);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_static_var()
 * ----------------------------------------------------------------------------- */

void Language::cpp_static_var(char *name, char *iname, SwigType *t) {
  String *cname;
  String *mrename;

  /* Create the variable name */
  mrename = Copy(Swig_name_member(ClassPrefix, iname ? iname : name));
  cname = NewStringf("%s::%s", ClassName,name);

  /* Link with this variable */
  lang->link_variable(Char(cname), Char(mrename),t);
  Delete(mrename);
  Delete(cname);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_class_decl()
 * ----------------------------------------------------------------------------- */

void Language::cpp_class_decl(char *, char *, char *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::add_typedef()
 * ----------------------------------------------------------------------------- */

void Language::add_typedef(SwigType *, char *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::pragma()
 * ----------------------------------------------------------------------------- */

void Language::pragma(char *, char *, char *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::import()
 * ----------------------------------------------------------------------------- */

void Language::import(char *) {
  /* Does nothing by default */
}

void Language::import_start(char *modulename) {
  WARNING("lang->import() API is deprecated.  See Source/SWIG1.1/swig11.h.");
  /* This implements the old behavior */
  this->import(input_file);
  this->set_module(modulename);
  /*  Printf(stdout,"import %s\n", modulename);*/
}

void Language::import_end() {
  /* Does nothing by default */
  /*  Printf(stdout,"end import\n"); */
}

/* -----------------------------------------------------------------------------
 * Language::is_multiple_definition()
 * ----------------------------------------------------------------------------- */

int Language::is_multiple_definition() {
  WARNING("lang->is_multiple_definition() is useless with new symbol table handling. Remove.");
  return 0;
}
