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

#include "swig11.h"
#include <ctype.h>

/* Some status variables used during parsing */

static int      InClass = 0;          /* Parsing C++ or not */
static String  *ClassName = 0;        /* This is the real name of the current class */
static String  *ClassRename = 0;      /* This is non-NULL if the class has been renamed */
static String  *ClassTag = 0;         /* Type of class (ie. union, struct, class)  */
static String  *ClassPrefix = 0;      /* Class prefix */
static String  *ClassType = 0;        /* Fully qualified type name to use */
       int      Abstract = 0;
static int      ImportMode = 0;
static int      has_constructor = 0;
static int      has_destructor = 0;
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

extern    int           GenerateDefault;
extern    int           ForceExtern;
extern    Language      *lang;

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
    if ((err = Getattr(n,"error"))) {
      return;
    }
    line_number = Getline(n);
    input_file = Char(Getfile(n));

    symtab = Getattr(n,"symtab");
    if (symtab) {
      Swig_symbol_setscope(symtab);
    }

      /* ============================================================
       * C/C++ parsing
       * ============================================================ */

    if (strcmp(tag,"extern") == 0) {
      lang->externDeclaration(n);
    } else if (strcmp(tag,"cdecl") == 0) {
      lang->cDeclaration(n);
    } else if (strcmp(tag,"function") == 0) {
      lang->functionDeclaration(n);
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
    } else if (strcmp(tag,"access") == 0) {
      lang->accessDeclaration(n);
    } 
    
    /* ===============================================================
     *  SWIG directives
     * =============================================================== */

    else if (strcmp(tag,"top") == 0) {
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
    } else {
      Printf(stderr,"%s:%d. Unrecognized parse tree node type '%s'\n", input_file, line_number, tag);
    }
}

static Parm *nonvoid_parms(Parm *p) {
  if (p) {
    SwigType *t = Getattr(p,"type");
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
      ReadOnly = 1;
    } else if (strcmp(name,"readwrite") == 0) {
      ReadOnly = 0;
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
    Node *bname = Getattr(n,"name");
    Node *bclass = Getattr(n,"class");
    Hash *scopes = Getattr(bclass,"typescope");
    
    private_constructor |= GetInt(bclass,"private_constructor");
    private_destructor |= GetInt(bclass,"private_destructor");
    base_default_constructor &= GetInt(bclass,"default_constructor");

    SwigType_inherit(clsname,bname);
    if (!ImportMode) {
      String *btype = Copy(bname);
      SwigType_add_pointer(btype);
      SwigType_remember(btype);
      Delete(btype);
    }
    if (scopes)
      SwigType_merge_scope(scopes);
    cplus_inherit_types(bclass,clsname);
  }
}

/* ----------------------------------------------------------------------
 * Language::top()   - Top of parsing tree 
 * ---------------------------------------------------------------------- */

int Language::top(Node *n) {
  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::addmethodsDirective()
 * ---------------------------------------------------------------------- */

int Language::addmethodsDirective(Node *n) {
  int oldam = AddMethods;
  Node *c;
  AddMethods = 1;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
  AddMethods = oldam;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::applyDirective()
 * ---------------------------------------------------------------------- */

int Language::applyDirective(Node *n) {

  Parm     *pattern = Getattr(n,"pattern");
  Node     *c = firstChild(n);
  while (c) {
    Parm   *apattern = Getattr(n,"pattern");
    if (ParmList_len(pattern) != ParmList_len(apattern)) {
      Printf(stderr,"%s:%d. Can't apply (%s) to (%s).  Number of arguments don't match.\n",
	     input_file, line_number, ParmList_str(pattern), ParmList_str(apattern));
    } else {
      Swig_typemap_apply(pattern,apattern);
    }
    c = nextSibling(c);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::clearDirective()
 * ---------------------------------------------------------------------- */

int Language::clearDirective(Node *n) {
  Node *p;
  for (p = firstChild(n); p; p = nextSibling(p)) {
    ParmList *pattern = Getattr(p,"pattern");
    Swig_typemap_clear_apply(pattern);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::constantDirective()
 * ---------------------------------------------------------------------- */

int Language::constantDirective(Node *n) {
  if (!ImportMode) {
    Swig_require(&n,"name", "?value",0);
    String *name = Getattr(n,"name");
    String *value = Getattr(n,"value");
    if (!value) {
      value = Copy(name);
    } else {
      value = NewStringf("%(escape)s", value);
    }
    Setattr(n,"value", value);
    this->constantWrapper(n);
    Swig_restore(&n);
    return SWIG_OK;
  }
  return SWIG_NOWRAP;
}

/* ----------------------------------------------------------------------
 * Language::exceptDirective()
 * ---------------------------------------------------------------------- */

int Language::exceptDirective(Node *n) {
  String *code = Getattr(n,"code");
  if (code) {
    Swig_except_register(code);
  } else {
    Swig_except_clear();
  }
  return SWIG_OK;
}


/* ----------------------------------------------------------------------
 * Language::importDirective()
 * ---------------------------------------------------------------------- */

int Language::importDirective(Node *n) {
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
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::includeDirective()
 * ---------------------------------------------------------------------- */

int Language::includeDirective(Node *n) {
  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::insertDirective()
 * ---------------------------------------------------------------------- */

int Language::insertDirective(Node *n) {
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
    return SWIG_OK;
  } else {
    return SWIG_NOWRAP;
  }
}

/* ----------------------------------------------------------------------
 * Language::moduleDirective()
 * ---------------------------------------------------------------------- */

int Language::moduleDirective(Node *n) {
  /* %module directive */
  String *name = Getattr(n,"name");
  if (ImportMode) {
    if (ImportMode == IMPORT_MODE) {
      lang->import_start(Char(name));
      ImportMode |= IMPORT_MODULE;
    } 
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::nativeDirective()
 * ---------------------------------------------------------------------- */

int Language::nativeDirective(Node *n) {
  
  if (!ImportMode) {
    String *name = Getattr(n,"cname");
    String *symname = Getattr(n,"sym:name");
    SwigType *type = Getattr(n,"type");
    Parm    *parms = Getattr(n,"parms");
    lang->add_native(Char(name),Char(symname),type,parms);
    return SWIG_OK;
  } else {
    return SWIG_NOWRAP;
  }
}

/* ----------------------------------------------------------------------
 * Language::newDirective()
 * ---------------------------------------------------------------------- */

int Language::newDirective(Node *n) {
  /* %new directive */
  NewObject = 1;
  emit_one(firstChild(n));
  NewObject = 0;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::pragmaDirective()
 * ---------------------------------------------------------------------- */

int Language::pragmaDirective(Node *n) {
  /* %pragma directive */
  if (!ImportMode) {
    String *lan = Getattr(n,"lang");
    String *name = Getattr(n,"name");
    String *value = Getattr(n,"value");
    swig_pragma(Char(lan),Char(name),Char(value));
    lang->pragma(Char(lan),Char(name),Char(value));
    return SWIG_OK;
  } else {
    return SWIG_NOWRAP;
  }
}

/* ----------------------------------------------------------------------
 * Language::typemapDirective()
 * ---------------------------------------------------------------------- */

int Language::typemapDirective(Node *n) {
  /* %typemap directive */
  String *method = Getattr(n,"method");
  String *code   = Getattr(n,"code");
  Parm   *kwargs = Getattr(n,"kwargs");
  Node   *items  = firstChild(n);
  while (items) {
    Parm     *pattern   = Getattr(items,"pattern");
    Parm     *parms     = Getattr(items,"parms");
    if (code) {
      Swig_typemap_register(method,pattern,code,parms,kwargs);
    } else {
      Swig_typemap_clear(method,pattern);
    }
    items = nextSibling(items);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::typemapcopyDirective()
 * ---------------------------------------------------------------------- */

int Language::typemapcopyDirective(Node *n) {
  String *method  = Getattr(n,"method");
  Parm   *pattern = Getattr(n,"pattern");
  Node *items    = firstChild(n);
  int   nsrc = 0;
  nsrc = ParmList_len(pattern);
  while (items) {
    ParmList *npattern = Getattr(items,"pattern");
    if (nsrc != ParmList_len(npattern)) {
      Printf(stderr,"%s:%d. Can't copy typemap. Number of types differ.\n", input_file, line_number);      
    } else {
      if (Swig_typemap_copy(method,pattern,npattern) < 0) {
	Printf(stderr,"%s:%d. Can't copy typemap.\n", input_file, line_number);
      }
    }
    items = nextSibling(items);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::typesDirective()
 * ---------------------------------------------------------------------- */

int Language::typesDirective(Node *n) {
  Parm  *parms = Getattr(n,"parms");
  while (parms) {
    SwigType *t = Getattr(parms,"type");
    SwigType_remember(t);
    parms = nextSibling(parms);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::cDeclaration()
 * ---------------------------------------------------------------------- */

int Language::cDeclaration(Node *n) {

  String *name    = Getattr(n,"name");
  String *symname = Getattr(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  SwigType *decl  = Getattr(n,"decl");
  String *storage = Getattr(n,"storage");
  Node   *over;
  File   *f_header = 0;
  SwigType *ty, *fullty;

  if (InClass && (cplus_mode != CPLUS_PUBLIC)) return SWIG_NOWRAP;

  if (Cmp(storage,"typedef") == 0) {
    SwigType *t = Copy(type);
    if (t) {
      SwigType_push(t,decl);
      SwigType_typedef(t,name);
      lang->add_typedef(t,Char(name));
    }
    return SWIG_OK;
  } else if (Cmp(storage,"friend") == 0) {
    return SWIG_NOWRAP;
  } 

  /* If in import mode, we proceed no further */
  if (ImportMode) return SWIG_NOWRAP;

  /* Overloaded symbol check */
  over = Swig_symbol_isoverloaded(n);
  if (over && (over != n)) {
    SwigType *tc = Copy(decl);
    SwigType *td = SwigType_pop(tc);
    String   *oname;
    String   *cname;
    if (InClass) {
      oname = NewStringf("%s::%s",ClassName,name);
      cname = NewStringf("%s::%s",ClassName,Getattr(over,"name"));
    } else {
      oname = NewString(name);
      cname = NewString(Getattr(over,"name"));
    }
    Printf(stderr,"%s:%d. Overloaded declaration ignored.  %s\n",
	   input_file,line_number, SwigType_str(td,oname));
    
    Printf(stdout,"%s:%d. Previous declaration is %s\n", Getfile(over),Getline(over), SwigType_str(Getattr(over,"decl"),cname));
    Delete(tc);
    Delete(td);
    Delete(oname);
    Delete(cname);
    return SWIG_NOWRAP;
  }
  
  if (strstr(Char(name),"::")) {
    Printf(stderr,"%s:%d. Warning. Qualified declaration %s ignored.\n", input_file, line_number, name);    
    return SWIG_NOWRAP;
  }

  if (symname && !validIdentifier(symname)) {
    Printf(stderr,"%s:%d. Warning. Can't wrap %s unless renamed to a valid identifier.\n",
	   input_file, line_number, symname);
    return SWIG_NOWRAP;
  }

  ty = Copy(type);
  SwigType_push(ty,decl);
  fullty = SwigType_typedef_resolve_all(ty);
  if (SwigType_isfunction(fullty)) {
    if (!SwigType_isfunction(ty)) {
      Delete(ty);
      ty = fullty;
      fullty = 0;
      ParmList *parms = SwigType_function_parms(ty);
      Setattr(n,"parms",parms);
    }
    /* Transform the node into a 'function' node and emit */
    if (!InClass) {
      f_header = Swig_filebyname("header");
      if (f_header) {
	if ((Cmp(storage,"extern") == 0) || (ForceExtern && !storage)) {
	  Printf(f_header,"extern %s;\n", SwigType_str(ty,name));
	} else if (Cmp(storage,"externc") == 0) {
	  Printf(f_header,"extern \"C\" %s;\n", SwigType_str(ty,name));
	}
      }
    }
    /* This needs to check qualifiers */
    if (SwigType_isqualifier(ty)) {
      Setattr(n,"qualifier", SwigType_pop(ty));
    }
    Delete(SwigType_pop_function(ty));
    DohIncref(type);
    Setattr(n,"type",ty);
    functionDeclaration(n);
    Setattr(n,"type",type);
    Delete(ty);
    Delete(type);
    return SWIG_OK;
  } else {
    /* Some kind of variable declaration */
    Delattr(n,"decl");
    int oldro = ReadOnly;
    if (Getattr(n,"nested")) ReadOnly = 1;
    if (!InClass) {
      if ((Cmp(storage,"extern") == 0) || ForceExtern) {
	f_header = Swig_filebyname("header");
	if (f_header)
	  Printf(f_header,"extern %s;\n", SwigType_str(ty,name));
      }
    }
    if (SwigType_isconst(ty)) {
      ReadOnly = 1;
    }
    /* If an array and elements are const, then read-only */
    if (SwigType_isarray(ty)) {
      SwigType *tya = SwigType_array_type(ty);
      if (SwigType_isconst(tya)) {
	ReadOnly = 1;
      }
    }
    DohIncref(type);
    Setattr(n,"type",ty);
    variableDeclaration(n);
    Setattr(n,"type",type);
    Delete(ty);
    Delete(type);
    Delete(fullty);
    ReadOnly = oldro;
    return SWIG_OK;
  }
}

/* ----------------------------------------------------------------------
 * Language::functionDeclaration()
 * ---------------------------------------------------------------------- */

int
Language::functionDeclaration(Node *n) {
  if (!InClass) {
    globalfunctionDeclaration(n);
  } else {
    String *storage   = Getattr(n,"storage");
    if (Cmp(storage,"static") == 0) {
      staticmemberfunctionDeclaration(n);
    } else {
      memberfunctionDeclaration(n);
    }
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::globalfunctionDeclaration()
 * ---------------------------------------------------------------------- */

int
Language::globalfunctionDeclaration(Node *n) {

  Swig_require(&n,"name","sym:name","type","?parms",0);

  String   *name    = Getattr(n,"name");
  String   *symname = Getattr(n,"sym:name");
  SwigType *type    = Getattr(n,"type");
  String   *storage = Getattr(n,"storage");  
  ParmList *parms   = Getattr(n,"parms");

  if (Cmp(storage,"static") == 0) {
    Swig_restore(&n);
    return SWIG_NOWRAP;   /* Can't wrap static functions */
  } else {
    /* Check for callback mode */
    if (Callback) {
      String   *cbname = NewStringf(Callback,symname);

      callbackfunctionDeclaration(n);

      if (Cmp(cbname, symname) == 0) {
	Delete(cbname);
	Swig_restore(&n);
	return SWIG_NOWRAP;
      }
      Delete(cbname);
    }
    Setattr(n,"parms",nonvoid_parms(parms));
    Setattr(n,"wrap:action", Swig_cresult(type,"result", Swig_cfunction_call(name,parms)));
    functionWrapper(n);
  }
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::callbackfunctionDeclaration()
 * ---------------------------------------------------------------------- */

int 
Language::callbackfunctionDeclaration(Node *n) {
  Swig_require(&n,"name","*sym:name","*type","?value",0);
  String *symname = Getattr(n,"sym:name");
  String *type    = Getattr(n,"type");
  String *name    = Getattr(n,"name");
  String *parms   = Getattr(n,"parms");

  String  *cbname = NewStringf(Callback,symname);
  SwigType *cbty = Copy(type);
  SwigType_add_function(cbty,parms); 
  SwigType_add_pointer(cbty);

  Setattr(n,"sym:name", cbname);
  Setattr(n,"type", cbty);
  Setattr(n,"value", name);

  constantWrapper(n);
  Delete(cbname);
  Delete(cbty);

  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::memberfunctionDeclaration()
 * ---------------------------------------------------------------------- */

int
Language::memberfunctionDeclaration(Node *n) {

  Swig_require(&n,"*name","*sym:name","*type","?parms","?value",0);

  String *storage   = Getattr(n,"storage");
  String   *name    = Getattr(n,"name");
  String   *symname = Getattr(n,"sym:name");
  SwigType *type    = Getattr(n,"type");
  String   *value   = Getattr(n,"value");
  ParmList *parms   = Getattr(n,"parms");

  if (Cmp(storage,"virtual") == 0) {
    if (Cmp(value,"0") == 0) {
      IsVirtual = PURE_VIRTUAL;
    } else {
      IsVirtual = PLAIN_VIRTUAL;
    }
  } else {
    IsVirtual = 0;
  }
  if (Callback) {
    Node   *cb = NewHash();
    String *cbname = NewStringf(Callback,symname);
    String *cbvalue;
    SwigType *cbty = Copy(type);
    SwigType_add_function(cbty,parms); 
    SwigType_add_memberpointer(cbty,ClassName);
    cbvalue = NewStringf("&%s::%s",ClassName,name);
    Setattr(cb,"sym:name", cbname);
    Setattr(cb,"type", cbty);
    Setattr(cb,"value", cbvalue);
    Setattr(cb,"name", name);

    memberconstantDeclaration(n);

    Delete(cb);
    Delete(cbvalue);
    Delete(cbty);
    Delete(cbname);
    if (Cmp(cbname,symname) == 0) {
      Swig_restore(&n);
      return SWIG_NOWRAP;
    }
  }

  String *fname = Swig_name_member(ClassPrefix, symname);
  /* Transformation */
  Swig_MethodToFunction(n,ClassType, AddMethods);
  Setattr(n,"sym:name",fname);

  functionWrapper(n);

  /*  DelWrapper(w);*/
  Delete(fname);
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::staticmemberfunctionDeclaration()
 * ---------------------------------------------------------------------- */

int
Language::staticmemberfunctionDeclaration(Node *n) {

  Swig_require(&n,"*name","*sym:name","*type",0);
  Swig_save(&n,"storage",0);
  String   *name    = Getattr(n,"name");
  String   *symname = Getattr(n,"sym:name");
  SwigType *type    = Getattr(n,"type");
  ParmList *parms   = Getattr(n,"parms");
  String   *code    = Getattr(n,"code");
  String   *cname, *mrename;

  if (!AddMethods) {
    cname = NewStringf("%s::%s",ClassName,name);
  } else {
    cname = Copy(Swig_name_member(ClassPrefix,name));    
  }
  mrename = Swig_name_member(ClassPrefix, symname);

  Setattr(n,"name",cname);
  Setattr(n,"sym:name",mrename);

  if ((AddMethods) && (code)) {
    /* Hmmm. An added static member.  We have to create a little wrapper for this */
    String *tmp = NewStringf("%s(%s)", cname, ParmList_str(parms));
    String *wrap = SwigType_str(type,tmp);
    Printv(wrap,code,"\n",0);
    Setattr(n,"wrap:code",wrap);
    Delete(tmp);
    Delete(wrap);
  }
  Delattr(n,"storage");
  globalfunctionDeclaration(n);

  Delete(cname);
  Delete(mrename);
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::variableDeclaration()
 * ---------------------------------------------------------------------- */

int
Language::variableDeclaration(Node *n) {
  if (!InClass) {
    globalvariableDeclaration(n);
  } else {
    String *storage = Getattr(n,"storage");
    if (Cmp(storage,"static") == 0) {
      staticmembervariableDeclaration(n);
    } else {
      membervariableDeclaration(n);
    }
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::globalvariableDeclaration()
 * ---------------------------------------------------------------------- */

int
Language::globalvariableDeclaration(Node *n) {
  String *storage = Getattr(n,"storage");
  if (Cmp(storage,"static") == 0) return SWIG_NOWRAP;
  variableWrapper(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::membervariableDeclaration()
 * ---------------------------------------------------------------------- */

int
Language::membervariableDeclaration(Node *n) {

  Swig_require(&n,"*name","*sym:name","*type",0);
  Swig_save(&n,"parms",0);

  String   *name    = Getattr(n,"name");
  String   *symname = Getattr(n,"sym:name");
  SwigType *type  = Getattr(n,"type");

  if (!AttributeFunctionGet) {
  
    String *mrename_get, *mrename_set;
    
    mrename_get = Swig_name_get(Swig_name_member(ClassPrefix, symname));
    mrename_set = Swig_name_set(Swig_name_member(ClassPrefix, symname));

    /* Create a function to set the value of the variable */
    
    if (!ReadOnly) {
      int       make_wrapper = 1;
      Swig_MembersetToFunction(n,ClassType,AddMethods);
      if (!AddMethods) {
	/* Check for a member in typemap here */
	String *target = NewStringf("%s->%s", Swig_cparm_name(0,0),name);
	String *tm = Swig_typemap_lookup((char *) "memberin",type,name,target,Swig_cparm_name(0,1),target,0);
	if (!tm) {
	  if (SwigType_isarray(type)) {
	    /*	  Printf(stderr,"%s:%d. Warning. Array member %s will be read-only.\n", input_file, line_number, name);*/
	    make_wrapper = 0;
	  }
	}  else {
	  Replace(tm,"$minput",Swig_cparm_name(0,1),DOH_REPLACE_ANY);
	  Replace(tm,"$self",Swig_cparm_name(0,0),DOH_REPLACE_ANY);
	  Setattr(n,"wrap:action", tm);
	  Delete(tm);
	}
	Delete(target);
      }
      if (make_wrapper) {
	Setattr(n,"sym:name", mrename_set);
	functionWrapper(n);
      } else {
	ReadOnly = 1;     /* Note: value is restored by generate.cxx */
      }
      /* Restore parameters */
      Setattr(n,"type",type);
      Setattr(n,"name",name);
      Setattr(n,"sym:name",symname);
    }
    /* Emit get function */
    {
      Swig_MembergetToFunction(n,ClassType,AddMethods);
      Setattr(n,"sym:name",  mrename_get);
      functionWrapper(n);
    }
    Delete(mrename_get);
    Delete(mrename_set);

  } else {

    /* This code is used to support the attributefunction directive 
       where member variables are converted automagically to 
       accessor functions */

#if 0    
    Parm *p;
    String *gname;
    SwigType *vty;
    p = NewParm(type,0);
    gname = NewStringf(AttributeFunctionGet,symname);
    if (!AddMethods) {
      ActionFunc = Copy(Swig_cmemberget_call(name,type));
      lang->cpp_member_func(Char(gname),Char(gname),type,0);
      Delete(ActionFunc);
    } else {
      String *cname = Copy(Swig_name_get(name));
      lang->cpp_member_func(Char(cname),Char(gname),type,0);
      Delete(cname);
    }
    Delete(gname);
    if (!ReadOnly) {
      gname = NewStringf(AttributeFunctionSet,symname);
      vty = NewString("void");
      if (!AddMethods) {
	ActionFunc = Copy(Swig_cmemberset_call(name,type));
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
#endif
  }
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::staticmembervariableDeclaration()
 * ---------------------------------------------------------------------- */

int 
Language::staticmembervariableDeclaration(Node *n)
{
  Swig_require(&n,"*name","*sym:name","*type",0);

  String *name    = Getattr(n,"name");
  String *symname = Getattr(n,"sym:name");
  String *cname, *mrename;

  /* Create the variable name */
  mrename = Swig_name_member(ClassPrefix, symname);
  cname = NewStringf("%s::%s", ClassName,name);

  Setattr(n,"sym:name",mrename);
  Setattr(n,"name", cname);
  
  /* Wrap as an ordinary global variable */
  variableWrapper(n);

  Delete(mrename);
  Delete(cname);
  Swig_restore(&n);
  return SWIG_OK;
}


/* ----------------------------------------------------------------------
 * Language::externDeclaration()
 * ---------------------------------------------------------------------- */

int Language::externDeclaration(Node *n) {
  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_one(c);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::enumDeclaration()
 * ---------------------------------------------------------------------- */

int Language::enumDeclaration(Node *n) {
  String *name = Getattr(n,"name");
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
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::enumvalueDeclaration()
 * ---------------------------------------------------------------------- */

int Language::enumvalueDeclaration(Node *n) {
  if (InClass && (cplus_mode != CPLUS_PUBLIC)) return SWIG_NOWRAP;

  Swig_require(&n,"name", "?value",0);
  String *value = Getattr(n,"value");
  String *name  = Getattr(n,"name");
  if (value)
    Setattr(n,"value", value);
  else
    Setattr(n,"value", name);

  if (!InClass) {
    constantWrapper(n);
  } else {
    memberconstantDeclaration(n);
  }
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------------- 
 * Language::memberconstantDeclaration()
 * ----------------------------------------------------------------------------- */

int Language::memberconstantDeclaration(Node *n) {

  Swig_require(&n,"*name","*sym:name","*value",0);

  String *name    = Getattr(n,"name");
  String *symname = Getattr(n,"sym:name");
  String *value   = Getattr(n,"value");

  String *mrename;
  String *new_value;

  mrename = Swig_name_member(ClassPrefix, symname);

  if ((!value) || (Cmp(value,name) == 0)) {
    new_value = NewStringf("%s::%s",ClassName,name);
  } else {
    new_value = NewString(value);
  }
  Setattr(n,"sym:name", mrename);
  Setattr(n,"value", new_value);
  Setattr(n,"name", NewStringf("%s::%s", ClassName,name));
  constantWrapper(n);
  Delete(mrename);
  Delete(new_value);
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDeclaration()
 * ---------------------------------------------------------------------- */

int Language::classDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  String *name = Getattr(n,"name");
  List   *bases = Getattr(n,"bases");
  String *tdname = Getattr(n,"tdname");
  String *symname = Getattr(n,"sym:name");
  String *unnamed = Getattr(n,"unnamed");
  String *storage = Getattr(n,"storage");

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

  /* Need to set up a typedef if an unnamed */
  if (unnamed && tdname && (Cmp(storage,"typedef") == 0)) {
    SwigType_typedef(unnamed,tdname);
  }
    
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

  cplus_mode = CPLUS_PUBLIC;

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
      if ((!has_constructor) && (!private_constructor) && (base_default_constructor)) {
	/* Generate default constructor */
	constructorDeclaration(n);
	/*	this->cpp_constructor(classname,iname,0); */
	SetInt(n,"default_constructor",1);
      } 
      if ((!has_destructor) && (!private_destructor)) {
	/* Generate default destructor */
	destructorDeclaration(n);
	/*	this->cpp_destructor(classname,iname); */
      }
    }
    char *baselist[256];
    int   i = 0;
    for (i = 0; i < Len(bases); i++) {
      baselist[i] = Char(Getattr(Getitem(bases,i),"name"));
    }
    baselist[i] = 0;
    lang->cpp_inherit(baselist,i);
    lang->cpp_close_class();
  }
  Hash *ts = SwigType_pop_scope();
  Setattr(n,"typescope",ts);
  InClass = 0;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classforwardDeclaration()
 * ---------------------------------------------------------------------- */

int Language::classforwardDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  String *name = Getattr(n,"name");
  String *symname = Getattr(n,"sym:name");
  if (!symname) symname = name;
  lang->cpp_class_decl(Char(name),Char(symname),Char(kind));
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::constructorDeclaration()
 * ---------------------------------------------------------------------- */

int Language::constructorDeclaration(Node *n) {
  String *name = Getattr(n,"name");
  Parm   *parms = Getattr(n,"parms");

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
    return SWIG_NOWRAP;
  }
  private_constructor = 0;
  if (ImportMode) return SWIG_NOWRAP;

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
      String *cname = NewStringf("%s::%s", ClassName, Getattr(over,"name"));
      SwigType *decl = Getattr(n,"decl");
      Printf(stderr,"%s:%d. Overloaded constructor ignored.  %s\n", input_file,line_number, SwigType_str(decl,oname));
      Printf(stderr,"%s:%d. Previous declaration is %s\n", Getfile(over),Getline(over),SwigType_str(Getattr(over,"decl"),cname));
      Delete(oname);
      Delete(cname);
    } else {
      if (name && Cmp(name,ClassName)) {
	Printf(stderr,"%s:%d.  Function %s must have a return type.\n", 
	       input_file, line_number, name);
	return SWIG_NOWRAP;
      }
      publicconstructorDeclaration(n);
    }
  }
  has_constructor = 1;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::publicconstructorDeclaration()
 * ---------------------------------------------------------------------- */

int 
Language::publicconstructorDeclaration(Node *n) {
  Swig_require(&n,"?name","*sym:name","?type","?parms",0);
  String *symname = Getattr(n,"sym:name");
  String *mrename;

  mrename = Swig_name_construct(symname);

  Swig_ConstructorToFunction(n,ClassType,CPlusPlus,AddMethods);
  Setattr(n,"sym:name", mrename);
  functionWrapper(n);
  Delete(mrename);
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::destructorDeclaration()
 * ---------------------------------------------------------------------- */

int Language::destructorDeclaration(Node *n) {

  if (InClass && (cplus_mode != CPLUS_PUBLIC)) {
    has_destructor = 1;
    if (cplus_mode == CPLUS_PRIVATE)
      private_destructor = 1;
    return SWIG_NOWRAP;
  }
  if (!AddMethods) 
    private_destructor = 0;
  if (ImportMode) return SWIG_NOWRAP;

  char *c = GetChar(n,"name");
  if (c && (*c == '~')) Setattr(n,"name",c+1);

  c = GetChar(n,"sym:name");
  if (c && (*c == '~')) Setattr(n,"sym:name",c+1);

  publicdestructorDeclaration(n);

  has_destructor = 1;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::publicdestructorDeclaration()
 * ---------------------------------------------------------------------- */

int Language::publicdestructorDeclaration(Node *n) {
  Swig_require(&n,"?name","*sym:name",0);
  Swig_save(&n,"type","parms",0);

  String *symname = Getattr(n,"sym:name");
  String *mrename;
  char *csymname = Char(symname);
  if (csymname && (*csymname == '~')) csymname +=1;

  mrename = Swig_name_destroy(csymname);
 
  Swig_DestructorToFunction(n,ClassType,CPlusPlus,AddMethods);
  Setattr(n,"sym:name", mrename);
  functionWrapper(n);
  Delete(mrename);
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::accessDeclaration()
 * ---------------------------------------------------------------------- */

int Language::accessDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  if (Cmp(kind,"public") == 0) {
    cplus_mode = CPLUS_PUBLIC;
  } else if (Cmp(kind,"private") == 0) {
    cplus_mode = CPLUS_PRIVATE;
  } else if (Cmp(kind,"protected") == 0) {
    cplus_mode = CPLUS_PROTECTED;
  }
  return SWIG_OK;
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
 * Language::cpp_inherit()
 * ----------------------------------------------------------------------------- */

void Language::cpp_inherit(char **baseclass, int mode) {
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

void Language::import_start(char *modulename) {
  /* Does nothing by default */
}

void Language::import_end() {
  /* Does nothing by default */
}

int Language::validIdentifier(String *s) {
  char *c = Char(s);
  while (*c) {
    if (!(isalnum(*c) || (*c == '_'))) return 0;
    c++;
  }
  return 1;
}

/* Stubs. Language modules need to implement these */

/* ----------------------------------------------------------------------
 * Language::constantWrapper()
 * ---------------------------------------------------------------------- */

int Language::constantWrapper(Node *n) {
  String   *name  = Getattr(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  String   *value = Getattr(n,"value");

  Printf(stdout,"constantWrapper   : %s = %s\n", SwigType_str(type,name), value);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::variableWrapper()
 * ---------------------------------------------------------------------- */
int Language::variableWrapper(Node *n) {
  Swig_require(&n,"*name","*sym:name","*type","?parms",0);
  String *symname    = Getattr(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  String *name   = Getattr(n,"name");

  /* If no way to set variables.  We simply create functions */
  if (!ReadOnly) {
    int make_wrapper = 1;
    Swig_VarsetToFunction(n);
    Setattr(n,"sym:name", Swig_name_set(symname));
    String *tm = Swig_typemap_lookup((char *) "globalin",type,name,name,Swig_cparm_name(0,0),name,0);
    if (!tm) {
      if (SwigType_isarray(type)) {
	/*	  Printf(stderr,"%s:%d. Warning. Array member %s will be read-only.\n", input_file, line_number, name);*/
	make_wrapper = 0;
      }
    }  else {
      Replace(tm,"$input",Swig_cparm_name(0,0),DOH_REPLACE_ANY);
      Setattr(n,"wrap:action", tm);
      Delete(tm);
    }
    if (make_wrapper) {
      functionWrapper(n);
    }
    Setattr(n,"sym:name",symname);
    Setattr(n,"type",type);
    Setattr(n,"name",name);
  }
  Swig_VargetToFunction(n);
  Setattr(n,"sym:name", Swig_name_get(symname));
  functionWrapper(n);
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::functionWrapper()
 * ---------------------------------------------------------------------- */

int Language::functionWrapper(Node *n) {
  String   *name   = Getattr(n,"sym:name");
  SwigType *type   = Getattr(n,"type");
  ParmList *parms  = Getattr(n,"parms");

  Printf(stdout,"functionWrapper   : %s\n", SwigType_str(type, NewStringf("%s(%s)", name, ParmList_str(parms))));
  Printf(stdout,"           action : %s\n", Getattr(n,"wrap:action")); 
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Language::nativeWrapper()
 * ----------------------------------------------------------------------------- */

int Language::nativeWrapper(Node *n) {
  return SWIG_OK;
}

void Language::main(int argc, char *argv[]) {
}
