/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * lang.cxx
 *
 * Language base class functions.  Default C++ handling is also implemented here.
 * ----------------------------------------------------------------------------- */

char cvsroot_lang_cxx[] = "$Header$";

#include "swigmod.h"
#include "cparse.h"
#include <ctype.h>

static int director_mode = 0;   /* set to 0 on default */
static int director_protected_mode = 1;   /* set to 1 on default */
static int naturalvar_mode = 0;

/* Set director_protected_mode */
void Wrapper_director_mode_set(int flag) {
  director_mode = flag;
}

void Wrapper_director_protected_mode_set(int flag) {
  director_protected_mode = flag;
}

void Wrapper_naturalvar_mode_set(int flag) {
  naturalvar_mode = flag;
}

extern "C" {
  int Swig_director_mode() 
  {
    return director_mode;
  }
}

  

/* Some status variables used during parsing */

static int      InClass = 0;          /* Parsing C++ or not */
static String  *ClassName = 0;        /* This is the real name of the current class */
static String  *ClassPrefix = 0;      /* Class prefix */
static String  *ClassType = 0;        /* Fully qualified type name to use */
static String  *DirectorClassName = 0;/* Director name of the current class */
int             Abstract = 0;
int             ImportMode = 0;
int             IsVirtual = 0;
static String  *AttributeFunctionGet = 0;
static String  *AttributeFunctionSet = 0;
static Node    *CurrentClass = 0;
int             line_number = 0;
char           *input_file = 0;
int             SmartPointer = 0;
static Hash    *classhash;

extern    int           GenerateDefault;
extern    int           ForceExtern;
extern    int           AddExtern;

/* import modes */

#define  IMPORT_MODE     1
#define  IMPORT_MODULE   2

/* ----------------------------------------------------------------------
 * Dispatcher::emit_one()
 *
 * Dispatch a single node
 * ---------------------------------------------------------------------- */

int Dispatcher::emit_one(Node *n) {
  String *wrn;
  int     ret = SWIG_OK;

  char *tag = Char(nodeType(n));
  if (!tag) {
    /* Printf(stderr,"SWIG: Fatal internal error. Malformed parse tree
       node!\n"); */
    return SWIG_OK;
  }
    
  /* Do not proceed if marked with an error */
    
  if (Getattr(n,"error")) return SWIG_OK;

  /* Look for warnings */
  wrn = Getattr(n,"feature:warnfilter");
  if (wrn) {
    Swig_warnfilter(wrn,1);
  }

  /* ============================================================
   * C/C++ parsing
   * ============================================================ */
    
  if (strcmp(tag,"extern") == 0) {
    ret = externDeclaration(n);
  } else if (strcmp(tag,"cdecl") == 0) {
    ret = cDeclaration(n);
  } else if (strcmp(tag,"enum") == 0) {
    ret = enumDeclaration(n);
  } else if (strcmp(tag,"enumitem") == 0) {
    ret = enumvalueDeclaration(n);
  } else if (strcmp(tag,"enumforward") == 0) {
    ret = enumforwardDeclaration(n);
  } else if (strcmp(tag,"class") == 0) {
    ret = classDeclaration(n);
  } else if (strcmp(tag,"classforward") == 0) {
    ret = classforwardDeclaration(n);
  } else if (strcmp(tag,"constructor") == 0) {
    ret = constructorDeclaration(n);
  } else if (strcmp(tag,"destructor") == 0) {
    ret = destructorDeclaration(n);
  } else if (strcmp(tag,"access") == 0) {
    ret = accessDeclaration(n);
  } else if (strcmp(tag,"using") == 0) {
    ret = usingDeclaration(n);
  } else if (strcmp(tag,"namespace") == 0) {
    ret = namespaceDeclaration(n);
  } else if (strcmp(tag,"template") == 0) {
    ret = templateDeclaration(n);
  }
    
  /* ===============================================================
   *  SWIG directives
   * =============================================================== */

  else if (strcmp(tag,"top") == 0) {
    ret = top(n);
  } else if (strcmp(tag,"extend") == 0) {
    ret = extendDirective(n);
  } else if (strcmp(tag,"apply") == 0) {
    ret = applyDirective(n);
  } else if (strcmp(tag,"clear") == 0) {
    ret = clearDirective(n);
  } else if (strcmp(tag,"constant") == 0) {
    ret = constantDirective(n);
  } else if (strcmp(tag,"fragment") == 0) {
    ret = fragmentDirective(n);
  } else if (strcmp(tag,"import") == 0) {
    ret = importDirective(n);
  } else if (strcmp(tag,"include") == 0) {
    ret = includeDirective(n);
  } else if (strcmp(tag,"insert") == 0) {
    ret = insertDirective(n);
  } else if (strcmp(tag,"module") == 0) { 
    ret = moduleDirective(n);
  } else if (strcmp(tag,"native") == 0) {
    ret = nativeDirective(n);
  } else if (strcmp(tag,"pragma") == 0) {
    ret = pragmaDirective(n);
  } else if (strcmp(tag,"typemap") == 0) {
    ret = typemapDirective(n);
  } else if (strcmp(tag,"typemapcopy") == 0) {
    ret = typemapcopyDirective(n);
  } else if (strcmp(tag,"typemapitem") == 0) {
    ret = typemapitemDirective(n);
  } else if (strcmp(tag,"types") == 0) {
    ret = typesDirective(n);
  } else {
    Printf(stderr,"%s:%d. Unrecognized parse tree node type '%s'\n", input_file, line_number, tag);
    ret = SWIG_ERROR;
  }
  if (wrn) {
    Swig_warnfilter(wrn,0);
  }
  return ret;
}

/* ----------------------------------------------------------------------
 * Dispatcher::emit_children()
 *
 * Emit all children that match the given type. type = 0 means all types.
 * ---------------------------------------------------------------------- */

int Dispatcher::emit_children(Node *n) {
  Node *c;
  char *eo = Char(Getattr(n,"feature:emitonlychildren"));
  for (c = firstChild(n); c; c = nextSibling(c)) {
    if (eo) {
      const char *tag = Char(nodeType(c));
      if (strcmp(tag,"cdecl") == 0) {
	if (checkAttribute(c, "storage", "typedef"))
	  tag = "typedef";
      }
      if (strstr(eo,tag) == 0) {
	continue;
      }
    }
    emit_one(c);    
  }
  return SWIG_OK;
}


/* Stubs for dispatcher class.  We don't do anything by default---up to derived class
   to fill in traversal code */

int Dispatcher::defaultHandler(Node *) { return SWIG_OK; }
int Dispatcher::extendDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::applyDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::clearDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::constantDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::fragmentDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::importDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::includeDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::insertDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::moduleDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::nativeDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::pragmaDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::typemapDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::typemapitemDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::typemapcopyDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::typesDirective(Node *n) { return defaultHandler(n); }
int Dispatcher::cDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::externDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::enumDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::enumvalueDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::enumforwardDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::classDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::templateDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::classforwardDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::constructorDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::destructorDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::accessDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::usingDeclaration(Node *n) { return defaultHandler(n); }
int Dispatcher::namespaceDeclaration(Node *n) { return defaultHandler(n); }


/* Allocators */
Language::Language() :
  none_comparison(NewString("$arg != 0")),
  director_ctor_code(NewString("")),
  director_prot_ctor_code(0),
  symbols(NewHash()),
  classtypes(NewHash()),
  enumtypes(NewHash()),
  overloading(0),
  multiinput(0),
  directors(0)
{
  argc_template_string = NewString("argc");
  argv_template_string = NewString("argv[%d]");

  /* Default director constructor code, passed to Swig_ConstructorToFunction */
  Printv(director_ctor_code,
      "if ( $comparison ) { /* subclassed */\n",
      "  $director_new \n",
      "} else {\n",
      "  $nondirector_new \n",
      "}\n", NIL);

  /*
    Default director 'protected' constructor code, disabled by
    default. Each language that needs it, has to define it.
  */
  director_prot_ctor_code = 0;
  director_multiple_inheritance = 1;
  director_language = 0;
}

Language::~Language() {
  Delete(symbols);
  Delete(classtypes);
  Delete(enumtypes);
  Delete(director_ctor_code);
  Delete(none_comparison);
}

/* ----------------------------------------------------------------------
   emit_one()
   ---------------------------------------------------------------------- */

int Language::emit_one(Node *n) {
  int ret;
  int oldext;
  if (!n) return SWIG_OK;

  if (GetFlag(n,"feature:ignore")
      && !Getattr(n,"feature:onlychildren")) return SWIG_OK;

  oldext = Extend;
  if (Getattr(n,"feature:extend")) Extend = 1;
  
  line_number = Getline(n);
  input_file = Char(Getfile(n));

  /*
    symtab = Getattr(n,"symtab");
    if (symtab) {
    symtab = Swig_symbol_setscope(symtab);
    }
  */
  ret = Dispatcher::emit_one(n);
  /*
    if (symtab) {
    Swig_symbol_setscope(symtab);
    }
  */
  Extend = oldext;
  return ret;
}


static Parm *nonvoid_parms(Parm *p) {
  if (p) {
    SwigType *t = Getattr(p,"type");
    if (SwigType_type(t) == T_VOID) return 0;
  }
  return p;
}

/* -----------------------------------------------------------------------------
 * cplus_value_type()
 *
 * Returns the alternative value type needed in C++ for class value
 * types. When swig is not sure about using a plain $ltype value,
 * since the class doesn't have a default constructor, or it can't be
 * assigned, you will get back 'SwigValueWrapper<type >'.
 *
 * ----------------------------------------------------------------------------- */

SwigType *cplus_value_type(SwigType *t) {
  return SwigType_alttype(t, 0);
}

static Node *first_nontemplate(Node *n) {
  while (n) {
    if (Strcmp(nodeType(n),"template") != 0) return n;
    n = Getattr(n,"sym:nextSibling");
  }
  return n;
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
      Swig_warning(WARN_DEPRECATED_NODEFAULT, "SWIG",1, 
		   "dangerous, use %%nodefaultctor, %%nodefaultdtor instead.\n");
      GenerateDefault = 0;
    } else if (strcmp(name,"attributefunction") == 0) {
      String *nvalue = NewString(value);
      char *s = strchr(Char(nvalue),':');
      if (!s) {
	Swig_error(input_file, line_number, "Bad value for attributefunction. Expected \"fmtget:fmtset\".\n");
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

/* --------------------------------------------------------------------------
 * swig_pragma()
 *
 * Handle swig pragma directives.  
 * -------------------------------------------------------------------------- */
int use_naturalvar_mode(Node *n) {
  if (Getattr(n,"unnamed")) return 0;
  int nvar = naturalvar_mode || GetFlag(n, "feature:naturalvar");
  if (!nvar) {
    /* look for feature in the class */
    SwigType *ty = Getattr(n,"type");
    if (SwigType_isclass(ty)) {
      Node *m = Copy(n);
      SwigType *tys = SwigType_strip_qualifiers(ty);
      Swig_features_get(Swig_cparse_features(), 0, tys, 0, m);
      nvar = GetFlag(m,"feature:naturalvar");      
      Delete(tys);
      Delete(m);
    }
  }
  return nvar ? CWRAP_NATURAL_VAR : 0;
}

/* ----------------------------------------------------------------------
 * Language::top()   - Top of parsing tree 
 * ---------------------------------------------------------------------- */

int Language::top(Node *n) {
  Node *mod = Getattr(n, "module");
  if (mod) {
    Node *options = Getattr(mod, "options");
    if (options) {
      if (Getattr(options, "naturalvar")) {
	naturalvar_mode = 1;
      }
      if (Getattr(options, "nonaturalvar")) {
	naturalvar_mode = 0;
      }
    }
  }
  classhash = Getattr(n,"classes");
  return emit_children(n);
}

/* ----------------------------------------------------------------------
 * Language::extendDirective()
 * ---------------------------------------------------------------------- */

int Language::extendDirective(Node *n) {
  int oldam = Extend;
  AccessMode oldmode = cplus_mode;
  Extend = CWRAP_EXTEND;
  cplus_mode = PUBLIC;

  emit_children(n);

  Extend = oldam;
  cplus_mode = oldmode;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::applyDirective()
 * ---------------------------------------------------------------------- */

int Language::applyDirective(Node *n) {

  Parm     *pattern = Getattr(n,"pattern");
  Node     *c = firstChild(n);
  while (c) {
    Parm   *apattern = Getattr(c,"pattern");
    if (ParmList_len(pattern) != ParmList_len(apattern)) {
      Swig_error(input_file, line_number, "Can't apply (%s) to (%s).  Number of arguments don't match.\n",
		 ParmList_str(pattern), ParmList_str(apattern));
    } else {
      if (!Swig_typemap_apply(pattern,apattern)) {
	Swig_warning(WARN_TYPEMAP_APPLY_UNDEF,input_file,line_number,"Can't apply (%s). No typemaps are defined.\n", ParmList_str(pattern));
      }
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

  if (CurrentClass && (cplus_mode != PUBLIC)) return SWIG_NOWRAP;

  if (!GetFlag(n,"feature:allowexcept")) {
    UnsetFlag(n,"feature:except");
  } 
  if (Getattr(n,"feature:exceptvar")) {
    Setattr(n,"feature:except",Getattr(n,"feature:exceptvar"));
  }
  
  if (!ImportMode) {
    Swig_require("constantDirective",n,"name", "?value",NIL);
    String *name = Getattr(n,"name");
    String *value = Getattr(n,"value");
    if (!value) {
      value = Copy(name);
    } else {
      /*      if (checkAttribute(n,"type","char")) {
	value = NewString(value);
      } else {
	value = NewStringf("%(escape)s", value);
      }
      */
      Setattr(n,"rawval",value);
      value = NewStringf("%(escape)s", value);
      if (!Len(value)) Append(value,"\\0");
      /*      Printf(stdout,"'%s' = '%s'\n", name, value); */
    }
    Setattr(n,"value", value);
    this->constantWrapper(n);
    Swig_restore(n);
    return SWIG_OK;
  }
  return SWIG_NOWRAP;
}

/* ----------------------------------------------------------------------
 * Language::fragmentDirective()
 * ---------------------------------------------------------------------- */

int Language::fragmentDirective(Node *n) {
  Swig_fragment_register(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::importDirective()
 * ---------------------------------------------------------------------- */

int Language::importDirective(Node *n) {
  int oldim = ImportMode;
  ImportMode = IMPORT_MODE;
  emit_children(n);
  ImportMode = oldim;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::includeDirective()
 * ---------------------------------------------------------------------- */

int Language::includeDirective(Node *n) {
  emit_children(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::insertDirective()
 * ---------------------------------------------------------------------- */

int Language::insertDirective(Node *n) {
  /* %insert directive */
  if ((!ImportMode) || Getattr(n,"generated")) {
    String *code     = Getattr(n,"code");
    String *section  = Getattr(n,"section");
    File *f = 0;
    if (!section) {     /* %{ ... %} */
      f = Swig_filebyname("header");
    } else {
      f = Swig_filebyname(section);
    }
    if (f) {
      Printf(f,"%s\n",code);
    } else {
      Swig_error(input_file,line_number,"Unknown target '%s' for %%insert directive.\n", section);
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
  (void)n;
  /* %module directive */
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::nativeDirective()
 * ---------------------------------------------------------------------- */

int Language::nativeDirective(Node *n) {
  if (!ImportMode) {
    return nativeWrapper(n);
  } else {
    return SWIG_NOWRAP;
  }
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
    /*	pragma(Char(lan),Char(name),Char(value)); */
    return SWIG_OK;
  }
  return SWIG_OK;
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
  static  int  namewarn = 0;
    

  if (code && (Strstr(code,"$source") || (Strstr(code,"$target")))) {
    Swig_warning(WARN_TYPEMAP_SOURCETARGET,Getfile(n),Getline(n),"Deprecated typemap feature ($source/$target).\n");
    if (!namewarn) {
      Swig_warning(WARN_TYPEMAP_SOURCETARGET, Getfile(n), Getline(n),
		   "The use of $source and $target in a typemap declaration is deprecated.\n\
For typemaps related to argument input (in,ignore,default,arginit,check), replace\n\
$source by $input and $target by $1.   For typemaps related to return values (out,\n\
argout,ret,except), replace $source by $1 and $target by $result.  See the file\n\
Doc/Manual/Typemaps.html for complete details.\n");
      namewarn = 1;
    }
  }

  if (Strcmp(method,"except") == 0) {
    Swig_warning(WARN_DEPRECATED_EXCEPT_TM, Getfile(n), Getline(n),
		 "%%typemap(except) is deprecated. Use the %%exception directive.\n");
  }

  if (Strcmp(method,"in") == 0) {
    Hash *k;
    k = kwargs;
    while (k) {
      if (checkAttribute(k,"name","numinputs")) {
	if (!multiinput && (GetInt(k,"value") > 1)) {
	  Swig_error(Getfile(n),Getline(n),"Multiple-input typemaps (numinputs > 1) not supported by this target language module.\n");
	  return SWIG_ERROR;
	}
	break;
      }
      k = nextSibling(k);
    }
    if (!k) {
      k = NewHash();
      Setattr(k,"name","numinputs");
      Setattr(k,"value","1");
      set_nextSibling(k,kwargs);
      Setattr(n,"kwargs",k);
      kwargs = k;
    }
  }

  if (Strcmp(method,"ignore") == 0) {
    Swig_warning(WARN_DEPRECATED_IGNORE_TM, Getfile(n), Getline(n),
		 "%%typemap(ignore) has been replaced by %%typemap(in,numinputs=0).\n");
    
    Clear(method);
    Append(method,"in");
    Hash *k = NewHash();
    Setattr(k,"name","numinputs");
    Setattr(k,"value","0");
    set_nextSibling(k,kwargs);
    Setattr(n,"kwargs",k);
    kwargs = k;
  }

  /* Replace $descriptor() macros */

  if (code) {
    Setfile(code,Getfile(n));
    Setline(code,Getline(n));
    Swig_cparse_replace_descriptor(code);
  }

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
      Swig_error(input_file,line_number,"Can't copy typemap. Number of types differ.\n");
    } else {
      if (Swig_typemap_copy(method,pattern,npattern) < 0) {
	Swig_error(input_file, line_number, "Can't copy typemap.\n");
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
    String   *v = Getattr(parms,"value");
    if (!v) {
      SwigType_remember(t);
    } else {
      if (SwigType_issimple(t)) {
	SwigType_inherit(t,v,0);
      }
    }
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

  /* discards nodes following the access control rules */
  if (cplus_mode != PUBLIC || !is_public(n)) {
    /* except for friends, they are not affected by access control */
    int isfriend = storage && (Cmp(storage,"friend") == 0);
    if (!isfriend ) {
      /* we check what the director needs. If the method is pure virtual,
	 it is always needed. */
      if (!(directorsEnabled() && is_member_director(CurrentClass,n) && need_nonpublic_member(n))) {
	return SWIG_NOWRAP;
      }
      /* prevent wrapping the method twice due to overload */
      String *wrapname = NewStringf("nonpublic_%s%s",Getattr(n,"sym:name"), Getattr(n,"sym:overname"));
      if (Getattr(CurrentClass,wrapname)) {
	Delete(wrapname);
	return SWIG_NOWRAP;	
      }
      SetFlag(CurrentClass,wrapname);
      Delete(wrapname);
    }
  }

  if (Cmp(storage,"typedef") == 0) {
    Swig_save("cDeclaration",n,"type",NIL);
    SwigType *t = Copy(type);
    if (t) {
      SwigType_push(t,decl);
      Setattr(n,"type",t);
      typedefHandler(n);
    }
    Swig_restore(n);
    return SWIG_OK;
  }

  /* If in import mode, we proceed no further */
  if (ImportMode) return SWIG_NOWRAP;

  /* If we're in extend mode and there is code, replace the $descriptor macros */
  if (Extend) {
    String *code = Getattr(n,"code");
    if (code) {
      Setfile(code,Getfile(n));
      Setline(code,Getline(n));
      Swig_cparse_replace_descriptor(code);
    }
  }

  /* Overloaded symbol check */
  over = Swig_symbol_isoverloaded(n);
  if (!overloading) {
    if (over) over = first_nontemplate(over);
    if (over && (over != n)) {
      SwigType *tc = Copy(decl);
      SwigType *td = SwigType_pop_function(tc);
      String   *oname;
      String   *cname;
      if (CurrentClass) {
	oname = NewStringf("%s::%s",ClassName,name);
	cname = NewStringf("%s::%s",ClassName,Getattr(over,"name"));
      } else {
	oname = NewString(name);
	cname = NewString(Getattr(over,"name"));
      }
      
      SwigType *tc2 = Copy(Getattr(over,"decl"));
      SwigType *td2 = SwigType_pop_function(tc2);
      
      Swig_warning(WARN_LANG_OVERLOAD_DECL, input_file, line_number, "Overloaded declaration ignored.  %s\n", SwigType_str(td,SwigType_namestr(oname)));
      Swig_warning(WARN_LANG_OVERLOAD_DECL, Getfile(over), Getline(over),"Previous declaration is %s\n", SwigType_str(td2,SwigType_namestr(cname)));
      
      Delete(tc2);
      Delete(td2);
      Delete(tc);
      Delete(td);
      Delete(oname);
      Delete(cname);
      return SWIG_NOWRAP;
    }
  }

  if (symname && !validIdentifier(symname)) {
    Swig_warning(WARN_LANG_IDENTIFIER,input_file, line_number, "Can't wrap '%s' unless renamed to a valid identifier.\n",
		 symname);
    return SWIG_NOWRAP;
  }

  ty = NewString(type);
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
    if (!CurrentClass) {
      f_header = Swig_filebyname("header");

      if (AddExtern) {
	if (f_header) {
	  if ((Cmp(storage,"extern") == 0) || (ForceExtern && !storage)) {
	    /* we don't need the 'extern' part in the C/C++ declaration,
	       and it produces some problems when namespace and SUN
	       Studio is used.

	       Printf(f_header,"extern %s", SwigType_str(ty,name));
	       
	       In fact generating extern declarations is quite error prone and is
	       no longer the default. Getting it right seems impossible with namespaces
	       and default arguments and when a method is declared with the various Windows
	       calling conventions - SWIG doesn't understand Windows (non standard) calling
	       conventions in the first place, so can't regenerate them.
	    */
	    String *str = SwigType_str(ty,name);
	    Printf(f_header,"%s", str);
	    Delete(str);
	    {
	      DOH *t = Getattr(n,"throws");
	      if (t) {
		Printf(f_header," throw(");
		while (t) {
		  Printf(f_header,"%s", Getattr(t,"type"));
		  t = nextSibling(t);
		  if (t) Printf(f_header,",");
		}
		Printf(f_header,")");
	      }
	    }
	    Printf(f_header,";\n");
	  } else if (Cmp(storage,"externc") == 0) {
	    /* here 'extern "C"' is needed */
	    String *str = SwigType_str(ty,name);
	    Printf(f_header, "extern \"C\" %s;\n", str);
	    Delete(str);
	  }
	}
      }
    }
    /* This needs to check qualifiers */
    if (SwigType_isqualifier(ty)) {
      SwigType *qual = SwigType_pop(ty);
      Setattr(n,"qualifier", qual);
      Delete(qual);
    }
    Delete(SwigType_pop_function(ty));
    DohIncref(type);
    Setattr(n,"type",ty);
    functionHandler(n);
    Setattr(n,"type",type);
    Delete(ty);
    Delete(type);
    return SWIG_OK;
  } else {
    /* Some kind of variable declaration */
    Delattr(n,"decl");
    if (Getattr(n,"nested")) SetFlag(n,"feature:immutable");
    if (!CurrentClass) {
      if ((Cmp(storage,"extern") == 0) || ForceExtern) {
	f_header = Swig_filebyname("header");
	if (AddExtern) {
	  if (f_header) {
	    String *str = SwigType_str(ty,name);
	    Printf(f_header,"extern %s;\n", str);
	    Delete(str);
	  }
	}
      }
    }
    if (!SwigType_ismutable(ty)) {
      SetFlag(n,"feature:immutable");
    }
    /* If an array and elements are const, then read-only */
    if (SwigType_isarray(ty)) {
      SwigType *tya = SwigType_array_type(ty);
      if (SwigType_isconst(tya)) {
	SetFlag(n,"feature:immutable");
      }
      Delete(tya);
    }
    DohIncref(type);
    Setattr(n,"type",ty);
    variableHandler(n);
    Setattr(n,"type",type);
    Setattr(n,"decl",decl);
    Delete(ty);
    Delete(type);
    Delete(fullty);
    return SWIG_OK;
  }
}

/* ----------------------------------------------------------------------
 * Language::functionHandler()
 * ---------------------------------------------------------------------- */

int
Language::functionHandler(Node *n) {
  String *storage = Getattr(n,"storage");
  int isfriend = CurrentClass && Cmp(storage,"friend") == 0;
  int isstatic = CurrentClass && Cmp(storage,"static") == 0 &&
	!(SmartPointer && Getattr(n,"allocate:smartpointeraccess"));
  Parm *p= Getattr(n,"parms");
  if (GetFlag(n,"feature:del")) {
    /* the method acts like a delete operator, ie, we need to disown the parameter */
    if (CurrentClass && !isstatic && !isfriend) {
      SetFlag(n,"feature:self:disown");
    } else {
      if (p) SetFlag(p,"wrap:disown");
    }
  }
  if (!CurrentClass) {
    globalfunctionHandler(n);
  } else {
    if (isstatic) {
      staticmemberfunctionHandler(n);
    } else if (isfriend) {
      globalfunctionHandler(n);
    } else {
      Node* explicit_n = 0;
      if (directorsEnabled() && is_member_director(CurrentClass,n) && !Extend && !extraDirectorProtectedCPPMethodsRequired()) {
	bool virtual_but_not_pure_virtual = (!(Cmp(storage, "virtual")) && (Cmp(Getattr(n, "value"), "0") != 0));
	if (virtual_but_not_pure_virtual) {
	  // Add additional wrapper which makes an explicit call to the virtual method (ie not a virtual call)
	  explicit_n = Copy(n);
	  String *new_symname = Copy(Getattr(n,"sym:name"));
	  String *suffix = Getattr(parentNode(n),"sym:name");
	  Printv(new_symname, "SwigExplicit", suffix, NIL);
	  Setattr(explicit_n,"sym:name", new_symname);
	  Delattr(explicit_n,"storage");
	  Delattr(explicit_n,"override");
	  Delattr(explicit_n,"hides");
	  SetFlag(explicit_n,"explicitcall");
	  Setattr(n, "explicitcallnode", explicit_n);
	}
      }

      memberfunctionHandler(n);

      if (explicit_n) {
	memberfunctionHandler(explicit_n);
        Delattr(explicit_n,"explicitcall");
        Delete(explicit_n);
      }
    }
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::globalfunctionHandler()
 * ---------------------------------------------------------------------- */

int
Language::globalfunctionHandler(Node *n) {

  Swig_require("globalfunctionHandler",n,"name","sym:name","type","?parms",NIL);

  String   *name    = Getattr(n,"name");
  String   *symname = Getattr(n,"sym:name");
  SwigType *type    = Getattr(n,"type");
  String   *storage = Getattr(n,"storage");  
  ParmList *parms   = Getattr(n,"parms");

  if (0 && (Cmp(storage,"static") == 0)) {
    Swig_restore(n);
    return SWIG_NOWRAP;   /* Can't wrap static functions */
  } else {
    /* Check for callback mode */
    String *cb = GetFlagAttr(n,"feature:callback");
    if (cb) {
      String *cbname = Getattr(n,"feature:callback:name");
      if (!cbname) {
	cbname = NewStringf(cb,symname);
	Setattr(n,"feature:callback:name",cbname);
      }
      
      callbackfunctionHandler(n);
      if (Cmp(cbname, symname) == 0) {
	Delete(cbname);
	Swig_restore(n);
	return SWIG_NOWRAP;
      }
      Delete(cbname);
    }
    Setattr(n,"parms",nonvoid_parms(parms));
    String *call = Swig_cfunction_call(name,parms);
    String *cres = Swig_cresult(type,"result", call);
    Setattr(n,"wrap:action", cres);
    Delete(cres);
    Delete(call);
    functionWrapper(n);
  }
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::callbackfunctionHandler()
 * ---------------------------------------------------------------------- */

int 
Language::callbackfunctionHandler(Node *n) {
  Swig_require("callbackfunctionHandler",n,"name","*sym:name","*type","?value",NIL);
  String *symname = Getattr(n,"sym:name");
  String *type    = Getattr(n,"type");
  String *name    = Getattr(n,"name");
  String *parms   = Getattr(n,"parms");
  String *cb      = GetFlagAttr(n,"feature:callback");
  String *cbname  = Getattr(n,"feature:callback:name");
  String *calltype= NewStringf("(%s (*)(%s))(%s)", SwigType_str(type,0), ParmList_str(parms), SwigType_namestr(name));
  SwigType *cbty = Copy(type);
  SwigType_add_function(cbty,parms); 
  SwigType_add_pointer(cbty);

  if (!cbname) {
    cbname = NewStringf(cb,symname);
    Setattr(n,"feature:callback:name",cbname);
  }

  Setattr(n,"sym:name", cbname);
  Setattr(n,"type", cbty);
  Setattr(n,"value", calltype);

  Node *ns = Getattr(symbols,cbname);
  if (!ns) constantWrapper(n);

  Delete(cbname);
  Delete(cbty);

  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::memberfunctionHandler()
 * ---------------------------------------------------------------------- */

int
Language::memberfunctionHandler(Node *n) {

  Swig_require("memberfunctionHandler",n,"*name","*sym:name","*type","?parms","?value",NIL);

  String *storage   = Getattr(n,"storage");
  String   *name    = Getattr(n,"name");
  String   *symname = Getattr(n,"sym:name");
  SwigType *type    = Getattr(n,"type");
  String   *value   = Getattr(n,"value");
  ParmList *parms   = Getattr(n,"parms");
  String   *cb      = GetFlagAttr(n,"feature:callback");

  if (Cmp(storage,"virtual") == 0) {
    if (Cmp(value,"0") == 0) {
      IsVirtual = PURE_VIRTUAL;
    } else {
      IsVirtual = PLAIN_VIRTUAL;
    }
  } else {
    IsVirtual = 0;
  }
  if (cb) {
    Node   *cbn = NewHash();
    String *cbname = Getattr(n,"feature:callback:name");
    if (!cbname) {
      cbname = NewStringf(cb,symname);
    }

    SwigType *cbty = Copy(type);
    SwigType_add_function(cbty,parms); 
    SwigType_add_memberpointer(cbty,ClassName);
    String *cbvalue = NewStringf("&%s::%s",ClassName,name);
    Setattr(cbn,"sym:name", cbname);
    Setattr(cbn,"type", cbty);
    Setattr(cbn,"value", cbvalue);
    Setattr(cbn,"name", name);

    memberconstantHandler(cbn);
    Setattr(n,"feature:callback:name",Swig_name_member(ClassPrefix, cbname));

    Delete(cb);
    Delete(cbn);
    Delete(cbvalue);
    Delete(cbty);
    Delete(cbname);
    if (Cmp(cbname,symname) == 0) {
      Swig_restore(n);
      return SWIG_NOWRAP;
    }
  }

  String *fname = Swig_name_member(ClassPrefix, symname);
  if (Extend && SmartPointer) {
    if (!Getattr(n,"classname")) {
      Setattr(n,"classname",Getattr(CurrentClass,"allocate:smartpointerbase"));
    }
  }

  // Set up the type for the cast to this class for use when wrapping const director (virtual) methods.
  // Note: protected director methods only.
  String* director_type = 0;
  if (!is_public(n) && (is_member_director(CurrentClass,n) || GetFlag(n, "explicitcall"))) {
    director_type = Copy(DirectorClassName);
    String *qualifier = Getattr(n,k_qualifier);
    if (qualifier)
      SwigType_push(director_type,qualifier);
    SwigType_add_pointer(director_type);
  }

  int DirectorExtraCall = 0;
  if (directorsEnabled() && is_member_director(CurrentClass,n) && !SmartPointer)
    if (extraDirectorProtectedCPPMethodsRequired())
      DirectorExtraCall = CWRAP_DIRECTOR_TWO_CALLS;

  if (GetFlag(n, "explicitcall"))
    DirectorExtraCall = CWRAP_DIRECTOR_ONE_CALL;

  Swig_MethodToFunction(n, ClassType, Getattr(n,"template") ? 0 : Extend | SmartPointer | DirectorExtraCall, director_type, is_member_director(CurrentClass,n));
  Setattr(n,"sym:name",fname);
  functionWrapper(n);

  Delete(director_type);
  Delete(fname);
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::staticmemberfunctionHandler()
 * ---------------------------------------------------------------------- */

int
Language::staticmemberfunctionHandler(Node *n) {

  Swig_require("staticmemberfunctionHandler",n,"*name","*sym:name","*type",NIL);
  Swig_save("staticmemberfunctionHandler",n,"storage",NIL);
  String   *name    = Getattr(n,"name");
  String   *symname = Getattr(n,"sym:name");
  SwigType *type    = Getattr(n,"type");
  ParmList *parms   = Getattr(n,"parms");
  String   *cb      = GetFlagAttr(n,"feature:callback");
  String   *cname, *mrename;

  if (!Extend) {
    Node *sb = Getattr(n,"cplus:staticbase");
    String *sname = sb ? Getattr(sb,"name") : 0;
    if (sname) {
      cname = NewStringf("%s::%s",sname,name);
    } else {
      cname = NewStringf("%s::%s",ClassName,name);
    }
  } else {
    String *mname = Swig_name_mangle(ClassName);
    cname = Swig_name_member(mname,name);
    Delete(mname);
  }
  mrename = Swig_name_member(ClassPrefix, symname);

  if (Extend) {
    String *code = Getattr(n,"code");
    String *defaultargs = Getattr(n,"defaultargs");
    String *mangled = Swig_name_mangle(mrename);
    Delete(mrename);
    mrename = mangled;

    if (Getattr(n,"sym:overloaded") && code) {
      Append(cname, Getattr(defaultargs ? defaultargs : n,"sym:overname"));
    }

    if (!defaultargs && code) {
      /* Hmmm. An added static member.  We have to create a little wrapper for this */
      Swig_add_extension_code(n, cname, parms, type, code, CPlusPlus);
    }
  }

  Setattr(n,"name",cname);
  Setattr(n,"sym:name",mrename);

  if (cb) {
    String *cbname = NewStringf(cb,symname);
    Setattr(n,"feature:callback:name", Swig_name_member(ClassPrefix, cbname));
    Setattr(n,"feature:callback:staticname", name);
  }
  Delattr(n,"storage");
  
  globalfunctionHandler(n);

  Delete(cname);
  Delete(mrename);
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::variableHandler()
 * ---------------------------------------------------------------------- */

int
Language::variableHandler(Node *n) {

  /* If not a smart-pointer access or added method. We clear
     feature:except.   There is no way C++ or C would throw
     an exception merely for accessing a member data.

     Caveat:  Some compilers seem to route attribute access through
     methods which can generate exceptions.  The feature:allowexcept
     allows this. Also, the feature:exceptvar can be used to match
     only variables.
  */
  if (!(Extend | SmartPointer)) {
    if (!GetFlag(n,"feature:allowexcept")) {
      UnsetFlag(n,"feature:except");
    } 
    if (Getattr(n,"feature:exceptvar")) {
      Setattr(n,"feature:except",Getattr(n,"feature:exceptvar"));
    }
  }

  if (!CurrentClass) {
    globalvariableHandler(n);
  } else {
    String *storage = Getattr(n,"storage");
    Swig_save("variableHandler",n,"feature:immutable",NIL);
    if (SmartPointer) {
      /* If a smart-pointer and it's a constant access, we have to set immutable */
      if (Getattr(CurrentClass,"allocate:smartpointerconst")) {
	SetFlag(n,"feature:immutable");
      }
    }
    if ((Cmp(storage,"static") == 0) 
	&& !(SmartPointer && Getattr(n,"allocate:smartpointeraccess"))) {
      staticmembervariableHandler(n);
    } else {
      membervariableHandler(n);
    }
    Swig_restore(n);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::globalvariableHandler()
 * ---------------------------------------------------------------------- */

int
Language::globalvariableHandler(Node *n) {
  String *storage = Getattr(n,"storage");
  if (0 && (Cmp(storage,"static") == 0)) return SWIG_NOWRAP;
  variableWrapper(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::membervariableHandler()
 * ---------------------------------------------------------------------- */

int
Language::membervariableHandler(Node *n) {

  Swig_require("membervariableHandler",n,"*name","*sym:name","*type",NIL);
  Swig_save("membervariableHandler",n,"parms",NIL);

  String   *name    = Getattr(n,"name");
  String   *symname = Getattr(n,"sym:name");
  SwigType *type  = Getattr(n,"type");

  if (!AttributeFunctionGet) {
    String *mname = Swig_name_member(ClassPrefix, symname);
    String *mrename_get = Swig_name_get(mname);
    String *mrename_set = Swig_name_set(mname);
    Delete(mname);

    /* Create a function to set the value of the variable */
    
    int assignable = is_assignable(n);

    if (SmartPointer) {
      if (Getattr(CurrentClass,"allocate:smartpointerconst")) {
	assignable = 0;
      }
    }

    if (assignable) {
      int       make_set_wrapper = 1;
      String *tm = 0;
      String *target = 0;
      if (!Extend) {
	if (SmartPointer) {
	  if (checkAttribute(n, "storage", "static")) {
	    Node *sn = Getattr(n,"cplus:staticbase");
	    String *base = Getattr(sn,"name"); 
	    target = NewStringf("%s::%s", base,name);
	  } else {
	    String *pname = Swig_cparm_name(0,0);
	    target = NewStringf("(*%s)->%s",pname,name);
	    Delete(pname);
	  }
	} else {
	  String *pname = Swig_cparm_name(0,0);
	  target = NewStringf("%s->%s", pname,name);
	  Delete(pname);
	}	
	tm = Swig_typemap_lookup_new("memberin",n,target,0);
      }
      int flags = Extend | SmartPointer | use_naturalvar_mode(n);

      Swig_MembersetToFunction(n,ClassType, flags);
      Setattr(n,"memberset", "1");
      if (!Extend) {
	/* Check for a member in typemap here */

	if (!tm) {
	  if (SwigType_isarray(type)) {
	    Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number, 
		     "Unable to set variable of type %s.\n", SwigType_str(type,0));
	    make_set_wrapper = 0;
	  }
	}  else {
	  String *pname0 = Swig_cparm_name(0,0);
	  String *pname1 = Swig_cparm_name(0,1);
	  Replace(tm,"$source", pname1, DOH_REPLACE_ANY);
	  Replace(tm,"$target", target, DOH_REPLACE_ANY);
	  Replace(tm,"$input",pname1,DOH_REPLACE_ANY);
	  Replace(tm,"$self",pname0,DOH_REPLACE_ANY);
	  Setattr(n,"wrap:action", tm);
	  Delete(tm);
	  Delete(pname0);
	  Delete(pname1);
	}
	Delete(target);
      }
      if (make_set_wrapper) {
	Setattr(n,"sym:name", mrename_set);
	functionWrapper(n);
      } else {
	SetFlag(n,"feature:immutable");
      }
      /* Restore parameters */
      Setattr(n,"type",type);
      Setattr(n,"name",name);
      Setattr(n,"sym:name",symname);

      /* Delete all attached typemaps and typemap attributes */
      Iterator ki;
      for (ki = First(n); ki.key; ki = Next(ki)) {
	if (Strncmp(ki.key, "tmap:", 5) == 0)
	  Delattr(n, ki.key);
      }
    }
    /* Emit get function */
    {
      int flags = Extend | SmartPointer | use_naturalvar_mode(n);
      Swig_MembergetToFunction(n,ClassType, flags);
      Setattr(n,"sym:name",  mrename_get);
      Setattr(n,"memberget", "1");
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
    if (!Extend) {
      ActionFunc = Copy(Swig_cmemberget_call(name,type));
      cpp_member_func(Char(gname),Char(gname),type,0);
      Delete(ActionFunc);
    } else {
      String *cname = Swig_name_get(name);
      cpp_member_func(Char(cname),Char(gname),type,0);
      Delete(cname);
    }
    Delete(gname);
    if (!GetFlag(n,"feature:immutable")) {
      gname = NewStringf(AttributeFunctionSet,symname);
      vty = NewString("void");
      if (!Extend) {
	ActionFunc = Copy(Swig_cmemberset_call(name,type));
	cpp_member_func(Char(gname),Char(gname),vty,p);
	Delete(ActionFunc);
      } else {
	String *cname = Swig_name_set(name);
	cpp_member_func(Char(cname),Char(gname),vty,p);
	Delete(cname);
      }
      Delete(gname);
    }
    ActionFunc = 0;
#endif
  }
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::staticmembervariableHandler()
 * ---------------------------------------------------------------------- */

int 
Language::staticmembervariableHandler(Node *n)
{
  Swig_require("staticmembervariableHandler",n,"*name","*sym:name","*type", "?value", NIL);
  String *value = Getattr(n,"value");
  String *classname = !SmartPointer ? ClassName : Getattr(CurrentClass,"allocate:smartpointerbase");
  if (!value || !Getattr(n,"hasconsttype")) {
    String *name    = Getattr(n,"name");
    String *symname = Getattr(n,"sym:name");
    String *cname, *mrename;
    
    /* Create the variable name */
    mrename = Swig_name_member(ClassPrefix, symname);
    cname = NewStringf("%s::%s", classname,name);
    
    Setattr(n,"sym:name",mrename);
    Setattr(n,"name", cname);
    
    /* Wrap as an ordinary global variable */
    variableWrapper(n);
    
    Delete(mrename);
    Delete(cname);
  } else {

    /* This is a C++ static member declaration with an initializer and it's const.
       Certain C++ compilers optimize this out so that there is no linkage to a
       memory address.  Example:

          class Foo {
          public:
              static const int x = 3;
          };

	  Some discussion of this in section 9.4 of the C++ draft standard.

      Also, we have to manage the case:

          class Foo {
          public:
              %extend {
                  static const int x = 3;
              }
          };

      in which there's no actual Foo::x variable to refer to. In this case,
      the best we can do is to wrap the given value verbatim.
    */


    String *name    = Getattr(n,"name");
    String *cname   = NewStringf("%s::%s", classname,name);
    if (Extend) {
        /* the variable is a synthesized one.
           There's nothing we can do; we just keep the given value */
    } else {
        /* we refer to the value as Foo::x */
        String* value   = SwigType_namestr(cname);
        Setattr(n, "value", value);
    }

    SwigType *t1    = SwigType_typedef_resolve_all(Getattr(n,"type"));
    SwigType *t2    = SwigType_strip_qualifiers(t1);
    Setattr(n, "type", t2);
    Delete(t1);
    Delete(t2);
    SetFlag(n,"wrappedasconstant");
    memberconstantHandler(n);
    Delete(cname);
  }  
  
  Swig_restore(n);
  return SWIG_OK;
}


/* ----------------------------------------------------------------------
 * Language::externDeclaration()
 * ---------------------------------------------------------------------- */

int Language::externDeclaration(Node *n) {
  return emit_children(n);
}

/* ----------------------------------------------------------------------
 * Language::enumDeclaration()
 * ---------------------------------------------------------------------- */

int Language::enumDeclaration(Node *n) {
  if (!ImportMode) {
    emit_children(n);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::enumvalueDeclaration()
 * ---------------------------------------------------------------------- */

int Language::enumvalueDeclaration(Node *n) {
  if (CurrentClass && (cplus_mode != PUBLIC)) return SWIG_NOWRAP;

  Swig_require("enumvalueDeclaration",n,"*name", "?value",NIL);
  String *value = Getattr(n,"value");
  String *name  = Getattr(n,"name");
  String *tmpValue;
  
  if (value)
    tmpValue = NewString(value);
  else
    tmpValue = NewString(name);
  Setattr(n, "value", tmpValue);

  if (!CurrentClass || !cparse_cplusplus) {
    Setattr(n,"name",tmpValue); /* for wrapping of enums in a namespace when emit_action is used */
    constantWrapper(n);
  } else {
    memberconstantHandler(n);
  }
  
  Delete(tmpValue);
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::enumforwardDeclaration()
 * ---------------------------------------------------------------------- */

int Language::enumforwardDeclaration(Node *n) {
  (void)n;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------------- 
 * Language::memberconstantHandler()
 * ----------------------------------------------------------------------------- */

int Language::memberconstantHandler(Node *n) {

  Swig_require("memberconstantHandler",n,"*name","*sym:name","value",NIL);

  if (!GetFlag(n,"feature:allowexcept")) {
    UnsetFlag(n,"feature:except");
  } 
  if (Getattr(n,"feature:exceptvar")) {
    Setattr(n,"feature:except",Getattr(n,"feature:exceptvar"));
  }

  String *name    = Getattr(n,"name");
  String *symname = Getattr(n,"sym:name");
  String *value   = Getattr(n,"value");

  String *mrename = Swig_name_member(ClassPrefix, symname);
  Setattr(n,"sym:name", mrename);

  String *new_name = 0;
  if (Extend)
    new_name = Copy(value);
  else
    new_name = NewStringf("%s::%s", ClassName, name);
  Setattr(n,"name", new_name);

  constantWrapper(n);
  Delete(mrename);
  Delete(new_name);
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::typedefHandler() 
 * ---------------------------------------------------------------------- */

int Language::typedefHandler(Node *n) {
  /* since this is a recurring issue, we are going to remember the
     typedef pointer, if already it is not a pointer or reference, as
     in

       typedef void NT;
       int func(NT *p); 
	
     see director_basic.i for example.
  */
  SwigType *name = Getattr(n,"name");
  SwigType *decl = Getattr(n,"decl");
  if (!SwigType_ispointer(decl) && !SwigType_isreference(decl)) {
    SwigType *pname = Copy(name);
    SwigType_add_pointer(pname);
    SwigType_remember(pname);
    Delete(pname);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirectorMethod()
 * ---------------------------------------------------------------------- */

int Language::classDirectorMethod(Node *n, Node *parent, String* super) {
  (void)n;
  (void)parent;
  (void)super;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirectorConstructor()
 * ---------------------------------------------------------------------- */

int Language::classDirectorConstructor(Node *n) {
  (void)n;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirectorDefaultConstructor()
 * ---------------------------------------------------------------------- */

int Language::classDirectorDefaultConstructor(Node *n) {
  (void)n;
  return SWIG_OK;
}



static
String *vtable_method_id(Node *n)
{
  String *nodeType = Getattr(n, "nodeType");
  int is_destructor = (Cmp(nodeType, "destructor") == 0);
  if (is_destructor) return 0;
  String *name = Getattr(n, "name");
  String *decl = Getattr(n, "decl");
  String *local_decl = SwigType_typedef_resolve_all(decl);
  String *tmp = SwigType_pop_function(local_decl);
  Delete(local_decl);
  local_decl = tmp;
  Node *method_id = NewStringf("%s|%s", name, local_decl); 
  Delete(local_decl);
  return method_id;
}


/* ----------------------------------------------------------------------
 * Language::unrollVirtualMethods()
 * ---------------------------------------------------------------------- */
int Language::unrollVirtualMethods(Node *n, 
                                   Node *parent, 
				   List *vm,
                                   int default_director, 
                                   int &virtual_destructor,
				   int protectedbase) { 
  Node *ni;
  String *nodeType;
  String *classname;
  String *decl;
  bool first_base = false;
  // recurse through all base classes to build the vtable
  List* bl = Getattr(n, "bases");
  if (bl) {
    Iterator bi;
    for (bi = First(bl); bi.item; bi = Next(bi)) {
      if (first_base && !director_multiple_inheritance) break;
      unrollVirtualMethods(bi.item, parent, vm, default_director, virtual_destructor);
      first_base = true;
    }
  }
  // recurse through all protected base classes to build the vtable, as needed
  bl = Getattr(n, "protectedbases");
  if (bl) {
    Iterator bi;
    for (bi = First(bl); bi.item; bi = Next(bi)) {
      if (first_base && !director_multiple_inheritance) break;
      unrollVirtualMethods(bi.item, parent, vm, default_director, virtual_destructor, 1);
      first_base = true;
    }
  }
  // find the methods that need directors
  classname = Getattr(n, "name");
  for (ni = Getattr(n, "firstChild"); ni; ni = nextSibling(ni)) {
    /* we only need to check the virtual members */
    if (!checkAttribute(ni, "storage", "virtual")) continue;
    nodeType = Getattr(ni, "nodeType");
    /* we need to add methods(cdecl) and destructor (to check for throw decl) */
    int is_destructor = (Cmp(nodeType, "destructor") == 0);
    if ((Cmp(nodeType, "cdecl") == 0)|| is_destructor) {
      decl = Getattr(ni, "decl");
      /* extra check for function type and proper access */
      if (SwigType_isfunction(decl) && (((!protectedbase || dirprot_mode()) && is_public(ni)) || need_nonpublic_member(ni))) {
	String *name = Getattr(ni, "name");
	Node *method_id = is_destructor ?  NewStringf("~destructor") : vtable_method_id(ni);
	/* Make sure that the new method overwrites the existing: */
	int len = Len(vm);
	const int DO_NOT_REPLACE = -1;
	int replace = DO_NOT_REPLACE;
	for (int i=0; i<len; i++) {
	  Node *item = Getitem(vm,i);
	  String *check_vmid = Getattr(item, "vmid");

	  if (Strcmp(method_id, check_vmid) == 0) {
	    replace = i;
	    break;
	  }
	}
        /* filling a new method item */
 	String *fqdname = NewStringf("%s::%s", classname, name);
	Hash *item = NewHash();
	Setattr(item, "fqdname", fqdname);
	Node *m = Copy(ni);

        /* Store the complete return type - needed for non-simple return types (pointers, references etc.) */
        SwigType *ty = NewString(Getattr(m,"type"));
        SwigType_push(ty,decl);
        if (SwigType_isqualifier(ty)) {
          Delete(SwigType_pop(ty));
        }
        Delete(SwigType_pop_function(ty));
        Setattr(m,"returntype", ty);

	String *mname = NewStringf("%s::%s", Getattr(parent,"name"),name);
	/* apply the features of the original method found in the base class */
	Swig_features_get(Swig_cparse_features(), 0, mname, Getattr(m,"decl"), m);
	Setattr(item, "methodNode", m);
	Setattr(item, "vmid", method_id);
	if (replace == DO_NOT_REPLACE)
	  Append(vm, item);
	else
	  Setitem(vm, replace, item);

	Delete(mname);
      } 
      if (is_destructor) {
	virtual_destructor = 1;
      }
    }
  }

  /*
    We delete all the nodirector methods. This prevents the
    generation of 'empty' director classes.
      
    But this has to be done outside the previous 'for'
    an the recursive loop!.
  */
  if (n == parent) {
    int len = Len(vm);
    for (int i=0; i<len; i++) {
      Node *item = Getitem(vm,i);
      Node *m = Getattr(item, "methodNode");
      /* retrieve the director features */
      int mdir = GetFlag(m, "feature:director");
      int mndir = GetFlag(m, "feature:nodirector");
      /* 'nodirector' has precedence over 'director' */
      int dir = (mdir || mndir) ? (mdir && !mndir) : 1;
      /* check if the method was found only in a base class */
      Node *p = Getattr(m, "parentNode");
      if (p != n) {
	Node *c = Copy(m);
	Setattr(c, "parentNode", n);
	int cdir = GetFlag(c, "feature:director");
	int cndir = GetFlag(c, "feature:nodirector");
	dir = (cdir || cndir) ? (cdir && !cndir) : dir;
	Delete(c);
      }
      if (dir) {
	/* be sure the 'nodirector' feature is disabled  */
	if (mndir) Delattr(m, "feature:nodirector");
      } else {
	/* or just delete from the vm, since is not a director method */
	Delitem(vm, i);
      }
    }
  }

  return SWIG_OK;
}


/* ----------------------------------------------------------------------
 * Language::classDirectorDisown()
 * ---------------------------------------------------------------------- */

int Language::classDirectorDisown(Node *n) {
  Node *disown = NewHash();
  String *mrename;
  String *symname = Getattr(n,"sym:name");
  mrename = Swig_name_disown(symname); //Getattr(n, "name"));
  String *type = NewString(ClassType);
  String *name = NewString("self");
  SwigType_add_pointer(type);
  Parm *p = NewParm(type, name);
  Delete(name);
  Delete(type);
  type = NewString("void");
  String *action = NewString("");
  Printv(action, "{\n",
                 "Swig::Director *director = dynamic_cast<Swig::Director *>(arg1);\n",
                 "if (director) director->swig_disown();\n",
		 "}\n",
		 NULL);
  Setattr(disown, "wrap:action", action);
  Setattr(disown,"name", mrename);
  Setattr(disown,"sym:name", mrename);
  Setattr(disown,"type",type);
  Setattr(disown,"parms", p);
  Delete(action);
  Delete(mrename);
  Delete(type);
  Delete(p);
  
  functionWrapper(disown);
  Delete(disown);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirectorConstructors()
 * ---------------------------------------------------------------------- */

int Language::classDirectorConstructors(Node *n) {
  Node *ni;
  String *nodeType;
  Node *parent = Swig_methodclass(n);
  int default_ctor = Getattr(parent,"allocate:default_constructor") ? 1 : 0;
  int protected_ctor = 0;
  int constructor = 0;

  /* emit constructors */
  for (ni = Getattr(n, "firstChild"); ni; ni = nextSibling(ni)) {
    nodeType = Getattr(ni, "nodeType");
    if (Cmp(nodeType, "constructor") == 0 && !GetFlag(ni, "feature:ignore")) { 
      Parm   *parms = Getattr(ni,"parms");
      if (is_public(ni)) {
	/* emit public constructor */
        classDirectorConstructor(ni);
        constructor = 1;
	if (default_ctor) 
	  default_ctor = !ParmList_numrequired(parms);
      } else {
	/* emit protected constructor if needed */
	if (need_nonpublic_ctor(ni)) {
	  classDirectorConstructor(ni);
	  constructor = 1;
	  protected_ctor = 1;
	  if (default_ctor) 
	    default_ctor = !ParmList_numrequired(parms);
	}
      }
    }
  }
  /* emit default constructor if needed */
  if (!constructor) {
    if (!default_ctor) {
      /* we get here because the class has no public, protected or
	 default constructor, therefore, the director class can't be
	 created, ie, is kind of abstract. */
      Swig_warning(WARN_LANG_DIRECTOR_ABSTRACT,Getfile(n),Getline(n),
		   "Director class '%s' can't be constructed\n",
		   SwigType_namestr(Getattr(n,"name")));
      return SWIG_OK;
    }
    classDirectorDefaultConstructor(n);
    default_ctor = 1;
  }
  /* this is just to support old java behavior, ie, the default
     constructor is always emitted, even when protected, and not
     needed, since there is a public constructor already defined.  

     (scottm) This code is needed here to make the director_abstract +
     test generate compileable code (Example2 in director_abastract.i).

     (mmatus) This is very strange, since swig compiled with gcc3.2.3
     doesn't need it here....
  */
  if (!default_ctor && !protected_ctor) {
    if (Getattr(parent,"allocate:default_base_constructor")) {
      classDirectorDefaultConstructor(n);
    }
  }

  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirectorMethods()
 * ---------------------------------------------------------------------- */

int Language::classDirectorMethods(Node *n) {
  Node *vtable = Getattr(n, "vtable");

  int len = Len(vtable);
  for (int i=0; i<len; i++) {
    Node *item = Getitem(vtable,i);
    String *method = Getattr(item, "methodNode");
    String *fqdname = Getattr(item, "fqdname");
    if (GetFlag(method, "feature:nodirector"))
      continue;

    String *type = Getattr(method, "nodeType");
    if (!Cmp(type, "destructor")) { 
      classDirectorDestructor(method);
    } else {
      if (classDirectorMethod(method, n, fqdname) == SWIG_OK) {
	Setattr(item, "director", "1");
      }
    }
  }

  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirectorInit()
 * ---------------------------------------------------------------------- */

int Language::classDirectorInit(Node *n) {
  (void)n;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirectorDestructor()
 * ---------------------------------------------------------------------- */

int Language::classDirectorDestructor(Node *n) {
  /* 
     Always emit the virtual destructor in the declaration and in the
     compilation unit.  Been explicit here can't make any damage, and
     can solve some nasty C++ compiler problems.
  */
  File *f_directors = Swig_filebyname("director");
  File *f_directors_h = Swig_filebyname("director_h");
  if (Getattr(n,"throw")) {
    Printf(f_directors_h, "    virtual ~%s() throw ();\n", DirectorClassName);
    Printf(f_directors, "%s::~%s() throw () {\n}\n\n", DirectorClassName, DirectorClassName);
  } else {
    Printf(f_directors_h, "    virtual ~%s();\n", DirectorClassName);
    Printf(f_directors, "%s::~%s() {\n}\n\n", DirectorClassName, DirectorClassName);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirectorEnd()
 * ---------------------------------------------------------------------- */

int Language::classDirectorEnd(Node *n) {
  (void)n;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDirector()
 * ---------------------------------------------------------------------- */

int Language::classDirector(Node *n) {
  Node *module = Getattr(n,"module");
  String *classtype = Getattr(n, "classtype");
  Hash *directormap = 0;
  if (module) {
    directormap = Getattr(module, "wrap:directormap");
    if (directormap == 0) {
      directormap = NewHash();
      Setattr(module, "wrap:directormap", directormap);
    }
  }
  List* vtable = NewList();
  int virtual_destructor = 0;
  unrollVirtualMethods(n, n, vtable, 0, virtual_destructor);
  if (virtual_destructor || Len(vtable) > 0) {
    if (!virtual_destructor) {
      String *classtype = Getattr(n, "classtype");
      Swig_warning(WARN_LANG_DIRECTOR_VDESTRUCT, input_file, line_number, 
                   "Director base class %s has no virtual destructor.\n",
		   classtype);
    }

    Setattr(n, "vtable", vtable);
    if (directormap != 0) {
      Setattr(directormap, classtype, n);
    }
    classDirectorInit(n);
    classDirectorConstructors(n);
    classDirectorMethods(n);
    classDirectorEnd(n);
  }
  Delete(vtable);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classDeclaration()
 * ---------------------------------------------------------------------- */
static void addCopyConstructor(Node *n) 
{
  Node *cn = NewHash();
  set_nodeType(cn,"constructor");
  Setattr(cn,"access","public");
  Setfile(cn,Getfile(n));
  Setline(cn,Getline(n));

  String *cname = Getattr(n,"name");
  SwigType *type = Copy(cname);
  String *last = Swig_scopename_last(cname);
  String *name = NewStringf("%s::%s",cname,last);
  String *cc = NewStringf("r.q(const).%s", type);
  String *decl = NewStringf("f(%s).",cc);
  String *csymname = Getattr(n,"sym:name");
  String *oldname = csymname;

  if (Getattr(n,"allocate:has_constructor")) {
    // to work properly with '%rename Class', we must look
    // for any other constructor in the class, which has not been
    // renamed, and use its name as oldname.
    Node *c;
    for (c = firstChild(n); c; c = nextSibling(c)) {
      const char *tag = Char(nodeType(c));
      if (strcmp(tag,"constructor") == 0) {
	String *cname = Getattr(c,k_name);
	String *csname = Getattr(c,k_symname);
	String *clast = Swig_scopename_last(cname);  
	if (Equal(csname, clast)) {
	  oldname = csname;
	  break;
	}
      }
    }
  }

  String *symname = Swig_name_make(cn, cname, last, decl, oldname);
  if (!symname) {
    symname = Copy(csymname);
  }
  Parm *p = NewParm(cc,"other");

  Setattr(cn,"name",name);
  Setattr(cn,"sym:name",symname);
  SetFlag(cn,"feature:new");
  Setattr(cn,"decl",decl);
  Setattr(cn,"parentNode",n);
  Setattr(cn,"parms",p);
  Setattr(cn,"copy_constructor","1");

  Symtab *oldscope = Swig_symbol_setscope(Getattr(n,"symtab"));
  Node *on = Swig_symbol_add(symname, cn);
  Swig_symbol_setscope(oldscope);
  Swig_features_get(Swig_cparse_features(), 0, name, decl, cn);

  if (on == cn) {
    Node *access = NewHash();
    set_nodeType(access,"access");
    Setattr(access,"kind","public");
    appendChild(n,access);
    appendChild(n,cn);
    Setattr(n,"has_copy_constructor","1");
    Setattr(n,"copy_constructor_decl",decl);
    Setattr(n,"allocate:copy_constructor","1");
    Delete(access);
  }
  Delete(cn);
  Delete(last);
  Delete(name);
  Delete(decl);
  Delete(symname);
}

static void addDefaultConstructor(Node *n) 
{
  Node *cn = NewHash();
  set_nodeType(cn,"constructor");
  Setattr(cn,"access","public");
  Setfile(cn,Getfile(n));
  Setline(cn,Getline(n));

  String *cname = Getattr(n,"name");
  String *last = Swig_scopename_last(cname);
  String *name = NewStringf("%s::%s",cname,last);
  String *decl = NewString("f().");
  String *csymname = Getattr(n,"sym:name");
  String *oldname = csymname;
  String *symname = Swig_name_make(cn, cname, last, decl, oldname);
  if (!symname) {
    symname = Copy(csymname);
  }
  
  Setattr(cn,"name",name);
  Setattr(cn,"sym:name",symname);
  SetFlag(cn,"feature:new");
  Setattr(cn,"decl",decl);
  Setattr(cn,"parentNode",n);
  Setattr(cn,"default_constructor","1");

  Symtab *oldscope = Swig_symbol_setscope(Getattr(n,"symtab"));
  Node *on = Swig_symbol_add(symname, cn);
  Swig_symbol_setscope(oldscope);
  Swig_features_get(Swig_cparse_features(), 0, name, decl, cn);

  if (on == cn) {
    Node *access = NewHash();
    set_nodeType(access,"access");
    Setattr(access,"kind","public");
    appendChild(n,access);
    appendChild(n,cn);
    Setattr(n,"has_default_constructor","1");
    Setattr(n,"allocate:default_constructor","1");
    Delete(access);
  }
  Delete(cn);
  Delete(last);
  Delete(name);
  Delete(decl);
  Delete(symname);
}

static void addDestructor(Node *n) 
{
  Node *cn = NewHash();
  set_nodeType(cn,"destructor");
  Setattr(cn,"access","public");
  Setfile(cn,Getfile(n));
  Setline(cn,Getline(n));

  String *cname = Getattr(n,"name");
  String *last = Swig_scopename_last(cname);
  Insert(last,0,"~");
  String *name = NewStringf("%s::%s",cname,last);
  String *decl = NewString("f().");
  String *symname = Swig_name_make(cn, cname, last, decl, 0);
  if (!symname) {
    symname = NewStringf("~%s",Getattr(n,"sym:name"));
  }

  Setattr(cn,"name",name);
  Setattr(cn,"sym:name",symname);
  Setattr(cn,"decl","f().");
  Setattr(cn,"parentNode",n);

  Symtab *oldscope = Swig_symbol_setscope(Getattr(n,"symtab"));
  Node *on = Swig_symbol_add(symname, cn);
  Swig_symbol_setscope(oldscope);
  Swig_features_get(Swig_cparse_features(), 0, name, decl, cn);

  if (on == cn) {
    Node *access = NewHash();
    set_nodeType(access,"access");
    Setattr(access,"kind","public");
    appendChild(n,access);
    appendChild(n,cn);
    Setattr(n,"has_destructor","1");
    Setattr(n,"allocate:destructor","1");
    Delete(access);
  }
  Delete(cn);
  Delete(last);
  Delete(name);
  Delete(decl);
  Delete(symname);
}

int Language::classDeclaration(Node *n) {
  String *ochildren = Getattr(n,"feature:onlychildren");
  if (ochildren) {
    Setattr(n,"feature:emitonlychildren",ochildren);
    emit_children(n);
    Delattr(n,"feature:emitonlychildren");
    SetFlag(n,"feature:ignore");
    return SWIG_NOWRAP;
  }

  String *kind = Getattr(n,"kind");
  String *name = Getattr(n,"name");
  String *tdname = Getattr(n,"tdname");
  String *symname = Getattr(n,"sym:name");

  char *classname = tdname ? Char(tdname) : Char(name);
  char *iname = Char(symname);
  int   strip = (tdname || CPlusPlus) ? 1 : 0;


  if (!classname) {
    Swig_warning(WARN_LANG_CLASS_UNNAMED, input_file, line_number, "Can't generate wrappers for unnamed struct/class.\n");
    return SWIG_NOWRAP;
  }

  /* Check symbol name for template.   If not renamed. Issue a warning */
  /*    Printf(stdout,"sym:name = %s\n", symname); */

  if (!validIdentifier(symname)) {
    Swig_warning(WARN_LANG_IDENTIFIER, input_file, line_number, "Can't wrap class %s unless renamed to a valid identifier.\n",
		 SwigType_namestr(symname));
    return SWIG_NOWRAP;
  }

  Swig_save("classDeclaration",n,"name",NIL);
  Setattr(n,"name",classname);

  if (Cmp(kind,"class") == 0) {
    cplus_mode = PRIVATE;
  } else {
    cplus_mode = PUBLIC;
  }

  ClassName = NewString(classname);
  ClassPrefix = NewString(iname);
  if (strip) {
    ClassType = NewString(classname);
  } else {
    ClassType = NewStringf("%s %s", kind, classname);
  }
  Setattr(n,"classtypeobj", Copy(ClassType));
  Setattr(n,"classtype", SwigType_namestr(ClassType));

  InClass = 1;
  CurrentClass = n;


  /* Call classHandler() here */
  if (!ImportMode) {
    int dir = 0;
    if (directorsEnabled()) {
      int ndir = GetFlag(n, "feature:director");
      int nndir = GetFlag(n, "feature:nodirector");
      /* 'nodirector' has precedence over 'director' */
      dir = (ndir || nndir) ? (ndir && !nndir) : 0;
    }
    int abstract = !dir && abstractClassTest(n);    
    int odefault = (GenerateDefault && !GetFlag(n,"feature:nodefault"));

    /* default constructor */
    if (!abstract && !GetFlag(n,"feature:nodefaultctor") && odefault) {
      if (!Getattr(n,"has_constructor") && !Getattr(n,"allocate:has_constructor") && (Getattr(n,"allocate:default_constructor"))) {
	addDefaultConstructor(n);
      }
    }
    /* copy constructor */
    if (CPlusPlus && !abstract && GetFlag(n,"feature:copyctor")) {
      if (!Getattr(n,"has_copy_constructor") && !Getattr(n,"allocate:has_copy_constructor") 
	  && (Getattr(n,"allocate:copy_constructor"))
          && (!GetFlag(n,"feature:ignore"))) {
	addCopyConstructor(n);
      }
    }
    /* default destructor */
    if (!GetFlag(n,"feature:nodefaultdtor") && odefault) {
      if (!Getattr(n,"has_destructor") && (!Getattr(n,"allocate:has_destructor")) 
	  && (Getattr(n,"allocate:default_destructor"))
          && (!GetFlag(n,"feature:ignore"))) {
	addDestructor(n);
      }
    }

    if (dir) {
      DirectorClassName = NewStringf("SwigDirector_%s", symname);
      classDirector(n);
    }
    /* check for abstract after resolving directors */
    Abstract = abstractClassTest(n);
    
    classHandler(n);
  } else {
    Abstract = abstractClassTest(n);
    Language::classHandler(n);
  }

  InClass = 0;
  CurrentClass = 0;
  Delete(ClassType);     ClassType = 0;
  Delete(ClassPrefix);   ClassPrefix = 0;
  Delete(ClassName);     ClassName = 0;
  Delete(DirectorClassName);     DirectorClassName = 0;
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classHandler()
 * ---------------------------------------------------------------------- */

int Language::classHandler(Node *n) {

  bool hasDirector = Swig_directorclass(n) ? true : false;



  /* Emit all of the class members */
  emit_children(n);

  /* Look for smart pointer handling */
  if (Getattr(n,"allocate:smartpointer")) {
    List *methods = Getattr(n,"allocate:smartpointer");
    cplus_mode = PUBLIC;
    SmartPointer = CWRAP_SMART_POINTER;
    Iterator c;
    for (c = First(methods); c.item; c= Next(c)) {
      emit_one(c.item);
    }
    SmartPointer = 0;
  }

  cplus_mode = PUBLIC;

  /* emit director disown method */
  if (hasDirector) {
    classDirectorDisown(n);

    /* Emit additional protected virtual methods - only needed if the language module
     * codes logic in the C++ layer instead of the director proxy class method - primarily
     * to catch public use of protected methods by the scripting languages. */
    if (dirprot_mode() && extraDirectorProtectedCPPMethodsRequired()) {
      Node *vtable = Getattr(n, "vtable");
      String* symname = Getattr(n, "sym:name");
      AccessMode old_mode = cplus_mode;
      cplus_mode = PROTECTED;
      int len = Len(vtable);
      for (int i=0; i<len; i++) {
	Node *item = Getitem(vtable,i);
	Node *method = Getattr(item, "methodNode");
	SwigType *type = Getattr(method,"nodeType");
	if (Strcmp(type,"cdecl") !=0 )
	  continue;
	if (GetFlag(method, "feature:ignore"))
	  continue;
	String* methodname = Getattr(method,"sym:name");
	String* wrapname = NewStringf("%s_%s", symname,methodname);
	if (!Getattr(symbols,wrapname) && (!is_public(method))) {
	  Node* m = Copy(method);
	  Setattr(m, "director", "1");
	  Setattr(m,"parentNode", n);
	  cDeclaration(m);
	  Delete(m);
	}
	Delete(wrapname);
      }
      cplus_mode = old_mode;
    }
  }

  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::classforwardDeclaration()
 * ---------------------------------------------------------------------- */

int Language::classforwardDeclaration(Node *n) {
  (void)n;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::constructorDeclaration()
 * ---------------------------------------------------------------------- */

int Language::constructorDeclaration(Node *n) {
  String *name = Getattr(n,"name");
  String *symname = Getattr(n,"sym:name");

  if (!symname) return SWIG_NOWRAP;
  if (!CurrentClass) return SWIG_NOWRAP;
  if (ImportMode) return SWIG_NOWRAP;

  if (Extend) {
    /* extend default constructor can be safetly ignored if there is
       already one */
    int num_required = ParmList_numrequired(Getattr(n,"parms"));
    if ((num_required == 0) && Getattr(CurrentClass,"has_default_constructor")) {
      return SWIG_NOWRAP;
    }
    if ((num_required == 1)  && Getattr(CurrentClass,"has_copy_constructor")) {
      String *ccdecl = Getattr(CurrentClass,"copy_constructor_decl");
      if (ccdecl && (Strcmp(ccdecl,Getattr(n,"decl")) == 0)) {
	return SWIG_NOWRAP;
      }
    }
  }
  
  /* clean protected overloaded constructors, in case they are not
     needed anymore */
  Node *over = Swig_symbol_isoverloaded(n);
  if (over && !Getattr(CurrentClass,"sym:cleanconstructor")) {
    int dirclass = Swig_directorclass(CurrentClass);
    Node *nn = over;    
    while (nn) {
      if (!is_public(nn)) {
	if (!dirclass || !need_nonpublic_ctor(nn)) {
	  SetFlag(nn,"feature:ignore");
	}
      }
      nn = Getattr(nn,"sym:nextSibling");
    }
    clean_overloaded(over);
    Setattr(CurrentClass,"sym:cleanconstructor","1");
  }
  
  if ((cplus_mode != PUBLIC)) {
    /* check only for director classes */
    if (!Swig_directorclass(CurrentClass) || !need_nonpublic_ctor(n))
      return SWIG_NOWRAP;
  }

  /* Name adjustment for %name */
  Swig_save("constructorDeclaration",n,"sym:name",NIL);

  {
    String *base = Swig_scopename_last(name);
    if ((Strcmp(base,symname) == 0) && (Strcmp(symname, ClassPrefix) != 0)) {
      Setattr(n,"sym:name", ClassPrefix);
    }
    Delete(base);
  }
  /* Only create a constructor if the class is not abstract */


  if (!Abstract) {
    Node *over;
    over = Swig_symbol_isoverloaded(n);
    if (over) over = first_nontemplate(over);
    if ((over) && (!overloading)) {
      /* If the symbol is overloaded.  We check to see if it is a copy constructor.  If so, 
	 we invoke copyconstructorHandler() as a special case. */
      if (Getattr(n,"copy_constructor") && (!Getattr(CurrentClass,"has_copy_constructor"))) {
	copyconstructorHandler(n);
	Setattr(CurrentClass,"has_copy_constructor","1");
      } else {
	if (Getattr(over,"copy_constructor")) over = Getattr(over,"sym:nextSibling");
	if (over != n) {
	  String *oname = NewStringf("%s::%s", ClassName, Swig_scopename_last(SwigType_namestr(name)));
	  String *cname = NewStringf("%s::%s", ClassName, Swig_scopename_last(SwigType_namestr(Getattr(over,"name"))));
	  SwigType *decl = Getattr(n,"decl");
	  Swig_warning(WARN_LANG_OVERLOAD_CONSTRUCT, input_file, line_number,
		       "Overloaded constructor ignored.  %s\n", SwigType_str(decl,SwigType_namestr(oname)));
	  Swig_warning(WARN_LANG_OVERLOAD_CONSTRUCT, Getfile(over), Getline(over),
		       "Previous declaration is %s\n", SwigType_str(Getattr(over,"decl"),SwigType_namestr(cname)));
	  Delete(oname);
	  Delete(cname);
	} else {
	  constructorHandler(n);
	}
      }
    } else {
      if (name && (Cmp(Swig_scopename_last(name),Swig_scopename_last(ClassName))) && !(Getattr(n,"template"))) {
	Swig_warning(WARN_LANG_RETURN_TYPE, input_file,line_number,"Function %s must have a return type.\n", 
		     name);
	Swig_restore(n);
	return SWIG_NOWRAP;
      }
      constructorHandler(n);
    }
  }
  Setattr(CurrentClass,"has_constructor","1");

  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::constructorHandler()
 * ---------------------------------------------------------------------- */

static String* 
get_director_ctor_code(Node *n, String *director_ctor_code, 
		       String *director_prot_ctor_code,
		       List*& abstract )
{
  String *director_ctor = director_ctor_code;
  int use_director = Swig_directorclass(n);
  if (use_director) {
    Node *pn = Swig_methodclass(n);
    abstract = Getattr(pn,"abstract");
    if (director_prot_ctor_code) {
      int is_notabstract = GetFlag(pn,"feature:notabstract");
      int is_abstract = abstract && !is_notabstract;
      if (is_protected(n) || is_abstract) {
	director_ctor = director_prot_ctor_code;
	Delattr(pn,"abstract");
      } else {
	if (is_notabstract) {
	  Delattr(pn,"abstract");
	} else {
	  abstract = 0;
	}
      }
    }
  }
  return director_ctor;
}


int 
Language::constructorHandler(Node *n) {
  Swig_require("constructorHandler",n,"?name","*sym:name","?type","?parms",NIL);
  String *symname = Getattr(n,"sym:name");
  String *mrename = Swig_name_construct(symname);
  String *nodeType = Getattr(n, "nodeType");
  int constructor = (!Cmp(nodeType, "constructor")); 
  List *abstract = 0;
  String *director_ctor = get_director_ctor_code(n, director_ctor_code,
						 director_prot_ctor_code,
						 abstract);
  if (!constructor) {
    /* if not originally a constructor, still handle it as one */
    Setattr(n,"handled_as_constructor","1");
  }
	
  Swig_ConstructorToFunction(n, ClassType, none_comparison, director_ctor, 
			     CPlusPlus, Getattr(n, "template") ? 0 :Extend);
  Setattr(n,"sym:name", mrename);
  functionWrapper(n);
  Delete(mrename);
  Swig_restore(n);
  if (abstract) Setattr(Swig_methodclass(n),"abstract",abstract);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::copyconstructorHandler()
 * ---------------------------------------------------------------------- */

int
Language::copyconstructorHandler(Node *n) {
  Swig_require("copyconstructorHandler",n,"?name","*sym:name","?type","?parms", NIL);
  String *symname = Getattr(n,"sym:name");
  String *mrename = Swig_name_copyconstructor(symname);
  List *abstract = 0;
  String *director_ctor = get_director_ctor_code(n, director_ctor_code,
						 director_prot_ctor_code,
						 abstract);
  Swig_ConstructorToFunction(n,ClassType, none_comparison, director_ctor,
			     CPlusPlus, Getattr(n,"template") ? 0 : Extend);
  Setattr(n,"sym:name", mrename);
  functionWrapper(n);
  Delete(mrename);
  Swig_restore(n);
  if (abstract) Setattr(Swig_methodclass(n),"abstract",abstract);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::destructorDeclaration()
 * ---------------------------------------------------------------------- */

int Language::destructorDeclaration(Node *n) {

  if (!CurrentClass) return SWIG_NOWRAP;
  if (cplus_mode != PUBLIC) return SWIG_NOWRAP;
  if (ImportMode) return SWIG_NOWRAP;

  if (Extend) {
    /* extend destructor can be safetly ignored if there is already one */
    if (Getattr(CurrentClass,"has_destructor")) {
      return SWIG_NOWRAP;
    }
  }

  Swig_save("destructorDeclaration",n,"name", "sym:name",NIL);

  char *c = GetChar(n,"name");
  if (c && (*c == '~')) Setattr(n,"name",c+1);

  c = GetChar(n,"sym:name");
  if (c && (*c == '~')) Setattr(n,"sym:name",c+1);

  /* Name adjustment for %name */

  String *name = Getattr(n,"name");
  String *symname = Getattr(n,"sym:name");

  if ((Strcmp(name,symname) == 0) || (Strcmp(symname,ClassPrefix) != 0)) {
    Setattr(n,"sym:name", ClassPrefix);
  }

  destructorHandler(n);

  Setattr(CurrentClass,"has_destructor","1");
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::destructorHandler()
 * ---------------------------------------------------------------------- */

int Language::destructorHandler(Node *n) {
  Swig_require("destructorHandler",n,"?name","*sym:name",NIL);
  Swig_save("destructorHandler",n,"type","parms",NIL);

  String *symname = Getattr(n,"sym:name");
  String *mrename;
  char *csymname = Char(symname);
  if (csymname && (*csymname == '~')) csymname +=1;

  mrename = Swig_name_destroy(csymname);
 
  Swig_DestructorToFunction(n,ClassType,CPlusPlus,Extend);
  Setattr(n,"sym:name", mrename);
  functionWrapper(n);
  Delete(mrename);
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::accessDeclaration()
 * ---------------------------------------------------------------------- */

int Language::accessDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  if (Cmp(kind,"public") == 0) {
    cplus_mode = PUBLIC;
  } else if (Cmp(kind,"private") == 0) {
    cplus_mode = PRIVATE;
  } else if (Cmp(kind,"protected") == 0) {
    cplus_mode = PROTECTED;
  }
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Language::namespaceDeclaration()
 * ----------------------------------------------------------------------------- */

int Language::namespaceDeclaration(Node *n) {
  if (Getattr(n,"alias")) return SWIG_OK;
  if (Getattr(n,"unnamed")) return SWIG_OK;
  emit_children(n);
  return SWIG_OK;
}

int Language::validIdentifier(String *s) {
  char *c = Char(s);
  while (*c) {
    if (!(isalnum(*c) || (*c == '_'))) return 0;
    c++;
  }
  return 1;
}

/* -----------------------------------------------------------------------------
 * Language::usingDeclaration()
 * ----------------------------------------------------------------------------- */

int Language::usingDeclaration(Node *n) {
  if ((cplus_mode == PUBLIC)) {
    Node* np = Copy(n);    
    Node *c;
    for (c = firstChild(np); c; c = nextSibling(c)) {
      /* it seems for some cases this is needed, like A* A::boo() */
      if (CurrentClass) 
	Setattr(c, "parentNode", CurrentClass);
      emit_one(c);
    }
    Delete(np);
  }
  return SWIG_OK;
}

/* Stubs. Language modules need to implement these */

/* ----------------------------------------------------------------------
 * Language::constantWrapper()
 * ---------------------------------------------------------------------- */

int Language::constantWrapper(Node *n) {
  String   *name  = Getattr(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  String   *value = Getattr(n,"value");
  String   *str = SwigType_str(type,name);
  Printf(stdout,"constantWrapper   : %s = %s\n", str, value);
  Delete(str);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::variableWrapper()
 * ---------------------------------------------------------------------- */
int Language::variableWrapper(Node *n) {
  Swig_require("variableWrapper",n,"*name","*sym:name","*type","?parms",NIL);
  String *symname    = Getattr(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  String *name   = Getattr(n,"name");

  /* If no way to set variables.  We simply create functions */
  int assignable = is_assignable(n);
  int flags = use_naturalvar_mode(n);
  if (assignable) {
    int make_set_wrapper = 1;
    String *tm = Swig_typemap_lookup_new("globalin", n, name, 0);

    Swig_VarsetToFunction(n, flags);
    String *sname = Swig_name_set(symname);
    Setattr(n,"sym:name", sname);
    Delete(sname);

    /*    String *tm = Swig_typemap_lookup((char *) "globalin",type,name,name,Swig_cparm_name(0,0),name,0);*/

    if (!tm) {
      if (SwigType_isarray(type)) {
	Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number, 
		     "Unable to set variable of type %s.\n", SwigType_str(type,0));
	make_set_wrapper = 0;
      }
    }  else {
      String *pname0 = Swig_cparm_name(0,0);
      Replace(tm,"$source", pname0, DOH_REPLACE_ANY);
      Replace(tm,"$target", name, DOH_REPLACE_ANY);
      Replace(tm,"$input",pname0,DOH_REPLACE_ANY);
      Setattr(n,"wrap:action", tm);
      Delete(tm);
      Delete(pname0);
    }
    if (make_set_wrapper) {
      functionWrapper(n);
    }
    /* Restore parameters */
    Setattr(n,"sym:name",symname);
    Setattr(n,"type",type);
    Setattr(n,"name",name);

    /* Delete all attached typemaps and typemap attributes */
    Iterator ki;
    for (ki = First(n); ki.key; ki = Next(ki)) {
      if (Strncmp(ki.key, "tmap:", 5) == 0)
	Delattr(n, ki.key);
    }
  }
  Swig_VargetToFunction(n, flags);
  String *gname = Swig_name_get(symname);
  Setattr(n,"sym:name", gname);
  Delete(gname);
  functionWrapper(n);
  Swig_restore(n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * Language::functionWrapper()
 * ---------------------------------------------------------------------- */

int Language::functionWrapper(Node *n) {
  String   *name   = Getattr(n,"sym:name");
  SwigType *type   = Getattr(n,"type");
  ParmList *parms  = Getattr(n,"parms");

  Printf(stdout,"functionWrapper   : %s\n", SwigType_str(type, NewStringf("%s(%s)", name, ParmList_str_defaultargs(parms))));
  Printf(stdout,"           action : %s\n", Getattr(n,"wrap:action")); 
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Language::nativeWrapper()
 * ----------------------------------------------------------------------------- */

int Language::nativeWrapper(Node *n) {
  (void)n;
  return SWIG_OK;
}

void Language::main(int argc, char *argv[]) {
  (void)argc;
  (void)argv;
}

/* -----------------------------------------------------------------------------
 * Language::addSymbol()
 *
 * Adds a symbol entry.  Returns 1 if the symbol is added successfully.
 * Prints an error message and returns 0 if a conflict occurs.
 * ----------------------------------------------------------------------------- */

int
Language::addSymbol(const String *s, const Node *n) {
  Node *c = Getattr(symbols,s);
  if (c && (c != n)) {
    Swig_error(input_file, line_number, "'%s' is multiply defined in the generated module.\n", s);
    Swig_error(Getfile(c),Getline(c), "Previous declaration of '%s'\n", s);
    return 0;
  }
  Setattr(symbols,s,n);
  return 1;
}

/* -----------------------------------------------------------------------------
 * Language::symbolLookup()
 * ----------------------------------------------------------------------------- */

Node *
Language::symbolLookup(String *s) {
  return Getattr(symbols,s);
}

/* -----------------------------------------------------------------------------
 * Language::classLookup()
 *
 * Tries to locate a class from a type definition
 * ----------------------------------------------------------------------------- */

Node *
Language::classLookup(SwigType *s) {
  Node *n = 0;

  /* Look in hash of cached values */
  n = Getattr(classtypes,s);
  if (!n) {
    Symtab  *stab = 0;
    SwigType *lt = SwigType_ltype(s);
    SwigType *ty1 = SwigType_typedef_resolve_all(lt);
    SwigType *ty2 = SwigType_strip_qualifiers(ty1);
    Delete(lt);
    Delete(ty1);
    lt = 0;
    ty1 = 0;

    String *base = SwigType_base(ty2);

    Replaceall(base,"class ","");
    Replaceall(base,"struct ","");
    Replaceall(base,"union ","");

    String *prefix = SwigType_prefix(ty2);

    /* Do a symbol table search on the base type */
    while (!n) {
      Hash *nstab;
      n = Swig_symbol_clookup(base,stab);
      if (!n) break;
      if (Strcmp(nodeType(n),"class") == 0) break;
      n = parentNode(n);
      if (!n) break;
      nstab = Getattr(n,"sym:symtab");
      n = 0;
      if ((!nstab) || (nstab == stab)) {
        break;
      }
      stab = nstab;
    }
    if (n) {
      /* Found a match.  Look at the prefix.  We only allow
         a few cases: pointers, references, and simple */
      if ((Len(prefix) == 0) ||               /* Simple type */
          (Strcmp(prefix,"p.") == 0) ||       /* pointer     */ 
          (Strcmp(prefix,"r.") == 0)) {       /* reference   */
	SwigType *cs = Copy(s);
        Setattr(classtypes,cs,n);
	Delete(cs);
      } else {
        n = 0;
      }
    }
    Delete(ty2);
    Delete(base);
    Delete(prefix);
  }
  if (n && (GetFlag(n,"feature:ignore") || Getattr(n,"feature:onlychildren"))) {
      n = 0;
  }

  return n; 
}

/* -----------------------------------------------------------------------------
 * Language::enumLookup()
 *
 * Finds and returns the Node containing the enum declaration for the (enum) 
 * type passed in.
 * ----------------------------------------------------------------------------- */

Node *
Language::enumLookup(SwigType *s) {
  Node *n = 0;

  /* Look in hash of cached values */
  n = Getattr(enumtypes,s);
  if (!n) {
    Symtab *stab = 0;
    SwigType *lt = SwigType_ltype(s);
    SwigType *ty1 = SwigType_typedef_resolve_all(lt);
    SwigType *ty2 = SwigType_strip_qualifiers(ty1);
    Delete(lt);
    Delete(ty1);
    lt = 0;
    ty1 = 0;

    String *base = SwigType_base(ty2);

    Replaceall(base,"enum ","");
    String *prefix = SwigType_prefix(ty2);

    /* Look for type in symbol table */
    while (!n) {
      Hash *nstab;
      n = Swig_symbol_clookup(base,stab);
      if (!n) break;
      if (Strcmp(nodeType(n),"enum") == 0) break;
      n = parentNode(n);
      if (!n) break;
      nstab = Getattr(n,"sym:symtab");
      n = 0;
      if ((!nstab) || (nstab == stab)) {
        break;
      }
      stab = nstab;
    }
    if (n) {
      /* Found a match.  Look at the prefix.  We only allow simple types. */
      if (Len(prefix) == 0) {                /* Simple type */
        Setattr(enumtypes,Copy(s),n);
      } else {
        n = 0;
      }
    }
    Delete(ty2);
    Delete(base);
    Delete(prefix);
  }
  if (n && (GetFlag(n,"feature:ignore"))) {
      n = 0;
  }

  return n; 
}

/* -----------------------------------------------------------------------------
 * Language::allow_overloading()
 * ----------------------------------------------------------------------------- */

void Language::allow_overloading(int val) {
  overloading = val;
}

/* -----------------------------------------------------------------------------
 * Language::allow_multiple_input()
 * ----------------------------------------------------------------------------- */

void Language::allow_multiple_input(int val) {
  multiinput = val;
}

/* -----------------------------------------------------------------------------
 * Language::allow_directors()
 * ----------------------------------------------------------------------------- */

void Language::allow_directors(int val) {
  directors = val;
}

/* -----------------------------------------------------------------------------
 * Language::directorsEnabled()
 * ----------------------------------------------------------------------------- */
 
int Language::directorsEnabled() const {
  return director_language && CPlusPlus && (directors || director_mode);
}

/* -----------------------------------------------------------------------------
 * Language::allow_dirprot()
 * ----------------------------------------------------------------------------- */

void Language::allow_dirprot(int val) {
  director_protected_mode = val;
}

/* -----------------------------------------------------------------------------
 * Language::dirprot_mode()
 * ----------------------------------------------------------------------------- */
 
int Language::dirprot_mode() const {
  return directorsEnabled() ? director_protected_mode : 0;
}

/* -----------------------------------------------------------------------------
 * Language::need_nonpublic_ctor()
 * ----------------------------------------------------------------------------- */

int Language::need_nonpublic_ctor(Node *n) 
{
  /* 
     detects when a protected constructor is needed, which is always
     the case if 'dirprot' mode is used.  However, if that is not the
     case, we will try to strictly emit what is minimal to don't break
     the generated, while preserving compatibility with java, which
     always try to emit the default constructor.

     rules:

     - when dirprot mode is used, the protected constructors are
       always needed.

     - the protected default constructor is always needed.

     - if dirprot mode is not used, the protected constructors will be
       needed only if:

       - there is no any public constructor in the class, and
       - there is no protected default constructor

       In that case, all the declared protected constructors are
       needed since we don't know which one to pick up.

    Note: given all the complications here, I am always in favor to
    always enable 'dirprot', since is the C++ idea of protected
    members, and use %ignore for the method you don't whan to add in
    the director class.
  */
  if (directorsEnabled()) {
    if (is_protected(n)) {
      if (dirprot_mode()) {
	/* when using dirprot mode, the protected constructors are
	   always needed */
	return 1;
      } else {
	int is_default_ctor = !ParmList_numrequired(Getattr(n,"parms"));
	if (is_default_ctor) {
	  /* the default protected constructor is always needed, for java compatibility */
	  return 1;
	} else {
	  /* check if there is a public constructor */
	  Node *parent = Swig_methodclass(n);
	  int public_ctor = Getattr(parent,"allocate:default_constructor") 
	    || Getattr(parent,"allocate:public_constructor");
	  if (!public_ctor) {
	    /* if not, the protected constructor will be needed only
	       if there is no protected default constructor declared */
	    int no_prot_default_ctor = !Getattr(parent,"allocate:default_base_constructor");
	    return no_prot_default_ctor;
	  }
	}
      }
    }
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Language::need_nonpublic_member()
 * ----------------------------------------------------------------------------- */
int Language::need_nonpublic_member(Node *n) 
{
  if (directorsEnabled()) {
    if (is_protected(n)) {
      if (dirprot_mode()) {
	/* when using dirprot mode, the protected members are always
	   needed. */
	return 1;
      } else {
	/* if the method is pure virtual, we need it. */
	int pure_virtual = (Cmp(Getattr(n,"value"),"0") == 0);
	return pure_virtual;
      }
    }
  }
  return 0;
}


/* -----------------------------------------------------------------------------
 * Language::is_smart_pointer()
 * ----------------------------------------------------------------------------- */

int Language::is_smart_pointer() const {
    return SmartPointer;
}

/* -----------------------------------------------------------------------------
 * Language::extraDirectorProtectedCPPMethodsRequired()
 * ----------------------------------------------------------------------------- */

bool Language::extraDirectorProtectedCPPMethodsRequired() const {
    return true;
}

/* -----------------------------------------------------------------------------
 * Language::is_wrapping_class()
 * ----------------------------------------------------------------------------- */

int Language::is_wrapping_class() {
    return InClass;
}

/* -----------------------------------------------------------------------------
 * Language::getCurrentClass()
 * ----------------------------------------------------------------------------- */

Node * Language::getCurrentClass() const {
    return CurrentClass;
}

/* -----------------------------------------------------------------------------
 * Language::getClassName()
 * ----------------------------------------------------------------------------- */

String * Language::getClassName() const {
    return ClassName;
}

/* -----------------------------------------------------------------------------
 * Language::getClassPrefix()
 * ----------------------------------------------------------------------------- */

String * Language::getClassPrefix() const {
    return ClassPrefix;
}

/* -----------------------------------------------------------------------------
 * Language::getClassType()
 * ----------------------------------------------------------------------------- */

String * Language::getClassType() const {
    return ClassType;
}

/* -----------------------------------------------------------------------------
 * Language::abstractClassTest()
 * ----------------------------------------------------------------------------- */
//#define SWIG_DEBUG
int Language::abstractClassTest(Node *n) {
  /* check for non public operator new */
  if (GetFlag(n,"feature:notabstract")) return 0;  
  if (Getattr(n,"allocate:nonew")) return 1;
  /* now check for the rest */
  List *abstract = Getattr(n,"abstract");
  if (!abstract) return 0;
  int labs = Len(abstract);
#ifdef SWIG_DEBUG
  List *bases = Getattr(n,"allbases");
  Printf(stderr,"testing %s %d %d\n",Getattr(n,"name"),labs,Len(bases));
#endif
  if (!labs) return 0; /*strange, but need to be fixed */
  if (abstract && !directorsEnabled()) return 1;
  if (!GetFlag(n,"feature:director")) return 1;

  Node *dirabstract = 0;  
  Node *vtable = Getattr(n, "vtable");
  if (vtable) {
#ifdef SWIG_DEBUG
     Printf(stderr,"vtable %s %d %d\n",Getattr(n,"name"),Len(vtable),labs);
#endif
    for (int i = 0; i < labs; i++) {
      Node *ni = Getitem(abstract,i);
      Node *method_id = vtable_method_id(ni);
      if (!method_id) continue;
      bool exists_item = false;
      int len = Len(vtable);
      for (int i=0; i<len; i++) {
	Node *item = Getitem(vtable,i);
	String *check_item = Getattr(item, "vmid");
	if (Strcmp(method_id, check_item) == 0) {
	  exists_item = true;
	  break;
	}
      }
    }
    if (dirabstract) {
      if (is_public(dirabstract)) {
	Swig_warning(WARN_LANG_DIRECTOR_ABSTRACT,Getfile(n),Getline(n),
		     "Director class '%s' is abstract, abstract method '%s' is not accesible, maybe due to multiple inheritance or 'nodirector' feature\n",
		     SwigType_namestr(Getattr(n,"name")),
		     Getattr(dirabstract,"name"));
      } else {
	Swig_warning(WARN_LANG_DIRECTOR_ABSTRACT,Getfile(n),Getline(n),
		     "Director class '%s' is abstract, abstract method '%s' is private\n",
		     SwigType_namestr(Getattr(n,"name")),
		     Getattr(dirabstract,"name"));
      }
      return 1;
    }
  } else {
    return 1;
  }
  return dirabstract ? 1 : 0;
}

void Language::setSubclassInstanceCheck(String *nc) {
    none_comparison = nc;
}

void Language::setOverloadResolutionTemplates(String *argc, String *argv) {
    Delete(argc_template_string);
    argc_template_string = Copy(argc);
    Delete(argv_template_string);
    argv_template_string = Copy(argv);
}

int Language::is_assignable(Node *n)
{
  if (GetFlag(n,"feature:immutable")) return 0;
  SwigType *type = Getattr(n,"type");
  Node *cn = 0;
  SwigType *ftd = SwigType_typedef_resolve_all(type);
  SwigType *td = SwigType_strip_qualifiers(ftd);
  if (SwigType_type(td) == T_USER) {
    if ((cn = Swig_symbol_clookup(td,0))) {
      if ((Strcmp(nodeType(cn),"class") == 0)) {
	if (Getattr(cn,"allocate:noassign")) {
	  SetFlag(n,"feature:immutable");
	  Delete(ftd);
	  Delete(td);
	  return 0;
	}
      }    
    }
  }
  Delete(ftd);
  Delete(td);
  return 1;
}

String *Language::runtimeCode() {
  return NewString("");
}

String *Language::defaultExternalRuntimeFilename() {
  return 0;
}
