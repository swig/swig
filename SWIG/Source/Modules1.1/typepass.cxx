/* ----------------------------------------------------------------------------- 
 * typepass.cxx
 *
 *     This module builds all of the internal type information by collecting
 *     typedef declarations as well as registering classes, structures, and unions.
 *     This information is needed to correctly handle shadow classes and other
 *     advanced features.   This phase of compilation is also used to perform
 *     type-expansion.  All types are fully qualified with namespace prefixes
 *     and other information needed for compilation.
 *
 *     This module also handles the %varargs directive by looking for
 *     "feature:varargs" and substituting ... with an alternative set of
 *     arguments.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2002.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "swig11.h"

class TypePass : public Dispatcher {
  Node   *inclass;
  String *module;
  int    importmode;
  String *nsname;
  Hash   *classhash;
  List  *normalize;

  /* Normalize a type. Replaces type with fully qualified version */

  void normalize_type(SwigType *ty) {
    SwigType *qty = SwigType_typedef_qualified(ty);

    /* SwigType *qty = Swig_symbol_type_qualify(ty,0);  */
    /*    Printf(stdout,"%s --> %s\n", ty, qty); */
    Clear(ty);
    Append(ty,qty);
    Delete(qty);
  }
  
  /* Normalize a parameter list */
  
  void normalize_parms(ParmList *p) {
    while (p) {
      SwigType *ty = Getattr(p,"type");
      normalize_type(ty);
      p = nextSibling(p);
    }
  }

  void normalize_later(ParmList *p) {
    while (p) {
      SwigType *ty = Getattr(p,"type");
      Append(normalize,ty);
      p = nextSibling(p);
    }
  }

  /* Walk through entries in normalize list and patch them up */
  void normalize_list() {
      SwigType *t;
      for (t = Firstitem(normalize); t; t = Nextitem(normalize)) {
	normalize_type(t);
      }
  }
  
  /* generate C++ inheritance type-relationships */
  void cplus_inherit_types(Node *cls, String *clsname) {

    List *ilist = Getattr(cls,"bases");
    if (!ilist) {
      List *nlist = Getattr(cls,"baselist");
      if (nlist) {
	int     len = Len(nlist);
	int i;
	for (i = 0; i < len; i++) {
	  Node *bcls = 0;
	  String *bname = Getitem(nlist,i);
	  String *sname = bname;
	  /* Try to locate the base class.   We look in the symbol table and we chase 
             typedef declarations to get to the base class if necessary */
	  Symtab *st = 0;
	  while (1) {
	    bcls = Swig_symbol_clookup(sname,st);
	    if (bcls) {
	      if (Strcmp(nodeType(bcls),"class") != 0) {
		/* Not a class.   The symbol could be a typedef. */
		String *storage = Getattr(bcls,"storage");
		if (storage && (Strcmp(storage,"typedef") == 0)) {
		  SwigType *decl = Getattr(bcls,"decl");
		  if (!decl || !(Len(decl))) {
		    sname = Getattr(bcls,"type");
		    st = Getattr(bcls,"sym:symtab");
		    continue;
		  } 
		}
		Printf(stderr,"%s:%d. '%s' is not a class. \n", Getfile(bname),Getline(bname), bname);
		bcls = 0;
	      } else {
		if (!ilist) ilist = NewList();
		Append(ilist,bcls);
	      }
	    }
	    break;
	  }
	  if (!bcls) {
	    if (!Getmeta(bname,"already_warned")) {
	      Printf(stderr,"%s:%d. Nothing known about class '%s'. Ignored.\n", Getfile(bname),Getline(bname), bname);
	      if (Strchr(bname,'<')) {
		Printf(stderr,"%s:%d. Maybe you forgot to instantiate '%s' using %%template.\n", Getfile(bname), Getline(bname), bname);
	      }
	      Setmeta(bname,"already_warned","1");
	    }
	    SwigType_inherit(clsname,bname);
	  }
	}
      }
      if (ilist) Setattr(cls,"bases",ilist);
    }
    if (!ilist) return;
    int len = Len(ilist);
    int i;
    for (i = 0; i < len; i++) {
      Node *n = Getitem(ilist,i);
      String *bname = Getattr(n,"name");
      Node *bclass = n; /* Getattr(n,"class"); */
      Hash *scopes = Getattr(bclass,"typescope");
      SwigType_inherit(clsname,bname);
      if (!importmode) {
	String *btype = Copy(bname);
	SwigType_add_pointer(btype);
	SwigType_remember(btype);
	Delete(btype);
      }
      if (scopes) {
	SwigType_inherit_scope(scopes);
      }
      cplus_inherit_types(bclass,clsname);
    }
  }

public:

#ifdef OLD
  virtual int emit_one(Node *n) {
    Symtab *symtab;
    Symtab *oldsymtab;
    int     ret;

    symtab = Getattr(n,"symtab");
    if (symtab) {
      oldsymtab = Swig_symbol_current();
      Swig_symbol_setscope(symtab);
    }
    ret = Dispatcher::emit_one(n);
    if (symtab) {
      Swig_symbol_setscope(oldsymtab);
    }
    return ret;
  }
#endif

  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */ 

  virtual int top(Node *n) {
    importmode = 0;
    module = 0;
    inclass = 0;
    normalize = 0;
    nsname = 0;
    classhash = Getattr(n,"classes");
    emit_children(n);
    return SWIG_OK;
  }


  /* ------------------------------------------------------------
   * moduleDirective()
   * ------------------------------------------------------------ */ 

  virtual int moduleDirective(Node *n) {
    module = Getattr(n,"name");
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * importDirective()
   * ------------------------------------------------------------ */ 

  virtual int importDirective(Node *n) { 
    String *oldmodule = module;
    int oldimport = importmode;
    importmode = 1;
    emit_children(n); 
    importmode = oldimport;
    module = oldmodule;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * includeDirective()
   * externDirective()
   * addmethodsDirective()
   * ------------------------------------------------------------ */ 

  virtual int includeDirective(Node *n) { return emit_children(n); }
  virtual int externDeclaration(Node *n) { return emit_children(n); }
  virtual int addmethodsDirective(Node *n) { return emit_children(n); }

  /* ------------------------------------------------------------
   * classDeclaration()
   * ------------------------------------------------------------ */ 

  virtual int classDeclaration(Node *n) {
    String *kind = Getattr(n,"kind");
    String *name = Getattr(n,"name");
    List   *bases = Getattr(n,"bases");
    String *tdname = Getattr(n,"tdname");
    String *symname = Getattr(n,"sym:name");
    String *unnamed = Getattr(n,"unnamed");
    String *storage = Getattr(n,"storage");
    Node   *oldinclass = inclass;
    List   *olist = normalize;
    Symtab *symtab;
    String *nname = 0;

    normalize = NewList();

    char *classname = tdname ? Char(tdname) : Char(name);
    char *iname = Char(symname);
    int   strip = (tdname || CPlusPlus) ? 1 : 0;

    if (name) {
      SwigType_typedef_class(name);
      SwigType_new_scope(name);
    } else {
      SwigType_new_scope(0);
    }

    /* Need to set up a typedef if unnamed */
    if (unnamed && tdname && (Cmp(storage,"typedef") == 0)) {
      SwigType_typedef(unnamed,tdname);
    }

    if (nsname) {
      nname = NewStringf("%s::%s", nsname, name);
    } 
    /* Inherit type definitions into the class */
    if (name) {
      cplus_inherit_types(n, nname ? nname : name);
    }
    
    inclass = n;
    symtab = Swig_symbol_setscope(Getattr(n,"symtab"));
    emit_children(n);
    Swig_symbol_setscope(symtab);

    /* Normalize deferred types */
    normalize_list();
    Delete(normalize);
    normalize = olist;

    inclass = oldinclass;
    Hash *ts = SwigType_pop_scope();
    Setattr(n,"typescope",ts);
    Setattr(n,"module",module);

    /* If in a namespace, patch the class name */
    if (nname) {
      Setattr(n,"name",nname);
    }
    return SWIG_OK;
  }


  /* ------------------------------------------------------------
   * namespaceDeclaration()
   * ------------------------------------------------------------ */ 

  virtual int classforwardDeclaration(Node *n) {

    /* Temporary hack. Can't do inside a class because it breaks
       C nested structure wrapping */

    if (!inclass) {
      String *name = Getattr(n,"name");
      String *nname;
      SwigType_typedef_class(name);
      if (nsname) {
	nname = NewStringf("%s::%s", nsname, name);
	Setattr(n,"name",nname);
      } 

    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * namespaceDeclaration()
   * ------------------------------------------------------------ */ 

  virtual int namespaceDeclaration(Node *n) {
    static int warn = 0;
    Symtab *symtab;
    String *name = Getattr(n,"name");
    String *alias = Getattr(n,"alias");
    List   *olist = normalize;
    normalize = NewList();    

    if (!warn) {
      Printf(stderr,"%s:%d. Warning. C++ namespace support is experimental and under development.\n", Getfile(n), Getline(n));
      warn = 1;
    }

    if (alias) {
      Typetab *ts = Getattr(n,"typescope");
      if (!ts) {
	Node *ns;
	/* Create a empty scope for the alias */
	SwigType_new_scope(name);
	ns = Getattr(n,"namespace");
	if (ns) {
	  SwigType_inherit_scope(Getattr(ns,"typescope"));
	}
	ts = SwigType_pop_scope();	  
	Setattr(n,"typescope",ts);
      }
      /* Namespace alias */
      return SWIG_OK;
    } else {
      if (name) {
	Node *nn = Swig_symbol_clookup(name,n);
	Hash *ts = Getattr(nn,"typescope");
	if (!ts) {
	  SwigType_new_scope(name);
	} else {
	  SwigType_set_scope(ts);
	}
      }
      String *oldnsname = nsname;
      nsname = Swig_symbol_qualified(Getattr(n,"symtab"));

      symtab = Swig_symbol_setscope(Getattr(n,"symtab"));
      emit_children(n);
      Swig_symbol_setscope(symtab);

      normalize_list();
      Delete(normalize);
      normalize = olist;

      Delete(nsname);
      nsname = oldnsname;

      if (name) {
	Hash *ts = SwigType_pop_scope();
	Setattr(n,"typescope",ts);
      }
      return SWIG_OK;
    }
  }

  /* ------------------------------------------------------------
   * cDeclaration()
   * ------------------------------------------------------------ */ 

  virtual int cDeclaration(Node *n) {
    /* Search for var args */
    if (Getattr(n,"feature:varargs")) {
      ParmList *v = Getattr(n,"feature:varargs");
      Parm     *p = Getattr(n,"parms");
      Parm     *pp = 0;
      while (p) {
	SwigType *t = Getattr(p,"type");
	if (Strcmp(t,"v(...)") == 0) {
	  if (pp) {
	    set_nextSibling(pp,Copy(v));
	  } else {
	    Setattr(n,"parms", Copy(v));
	  }
	  break;
	}
	pp = p;
	p = nextSibling(p);
      }
    }

    /* Normalize types. */
    SwigType *ty = Getattr(n,"type");
    normalize_type(ty);
    SwigType *decl = Getattr(n,"decl");
    if (decl) {
      normalize_type(decl);
    }
    normalize_parms(Getattr(n,"parms"));

    String *storage = Getattr(n,"storage");
    if (storage && Strcmp(storage,"typedef") == 0) {
      String   *name = Getattr(n,"name");
      ty   = Getattr(n,"type");
      decl = Getattr(n,"decl");
      
      SwigType *t = Copy(ty);
      SwigType_push(t,decl);
      SwigType_typedef(t,name);
    }
    /* If namespaces are active.  We need to patch the name with a namespace prefix */
    if (nsname && !inclass) {
      String *name = Getattr(n,"name");
      if (name) {
	String *nname = NewStringf("%s::%s", nsname, name);
	Setattr(n,"name", nname);
	Delete(nname);
      }
    }
    return SWIG_OK;
  }


  /* ------------------------------------------------------------
   * constructorDeclaration()
   * ------------------------------------------------------------ */ 

  virtual int constructorDeclaration(Node *n) {
    /* Search for var args */
    if (Getattr(n,"feature:varargs")) {
      ParmList *v = Getattr(n,"feature:varargs");
      Parm     *p = Getattr(n,"parms");
      Parm     *pp = 0;
      while (p) {
	SwigType *t = Getattr(p,"type");
	if (Strcmp(t,"v(...)") == 0) {
	  if (pp) {
	    set_nextSibling(pp,Copy(v));
	  } else {
	    Setattr(n,"parms", Copy(v));
	  }
	  break;
	}
	pp = p;
	p = nextSibling(p);
      }
    }
    normalize_parms(Getattr(n,"parms"));
    /* If in a namespace, patch the class name */
    if (nsname) {
      String *nname = NewStringf("%s::%s", nsname, Getattr(n,"name"));
      Setattr(n,"name",nname);
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * destructorDeclaration()
   * ------------------------------------------------------------ */ 

  virtual int destructorDeclaration(Node *n) {
    /* If in a namespace, patch the class name */
    if (nsname) {
      String *nname = NewStringf("%s::%s", nsname, Getattr(n,"name"));
      Setattr(n,"name",nname);
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constantDirective()
   * ------------------------------------------------------------ */ 

  virtual int constantDirective(Node *n) {
    SwigType *ty = Getattr(n,"type");
    if (ty) {
      Setattr(n,"type",SwigType_typedef_qualified(ty));
    }
    return SWIG_OK;
  }


  /* ------------------------------------------------------------
   * enumDeclaration()
   * ------------------------------------------------------------ */ 

  virtual int enumDeclaration(Node *n) {
    String *name = Getattr(n,"name");
    if (name) {
      SwigType *t = NewStringf("enum %s", name);
      SwigType_typedef(t,name);
      Delete(t);
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * usingDeclaration()
   * ------------------------------------------------------------ */

  virtual int usingDeclaration(Node *n) {
    if (Getattr(n,"namespace")) {
      /* using namespace id */

      /* For a namespace import.   We set up inheritance in the type system */
      Node *ns = Getattr(n,"node");
      if (ns) {
	Typetab *ts = Getattr(ns,"typescope");
	if (ts) {
	  SwigType_inherit_scope(ts);
	}
      }
      return SWIG_OK;
    } else {
      /* using id */

      /* Only a single symbol is being used.  There are only a few symbols that
	 we actually care about.  These are typedef, class declarations, and enum */

      Node *ns = Getattr(n,"node");
      String *ntype = nodeType(ns);
      if (Strcmp(ntype,"cdecl") == 0) {
	String *storage = Getattr(ns,"storage");
	if (Strcmp(storage,"typedef") == 0) {
	  /* A typedef declaration */
	  /*	  SwigType *ty = Getattr(ns,"type");
	  SwigType *decl = Getattr(ns,"decl");
	  SwigType *t = Copy(ty);
	  SwigType_push(t,decl);
	  SwigType_typedef(t,Getattr(n,"name"));*/
	  String *uname = Getattr(n,"uname");
	  SwigType_typedef_using(uname);
	}
      } else if ((Strcmp(ntype,"class") == 0) || ((Strcmp(ntype,"classforward") == 0))) {
	/* We install the using class name as kind of a typedef back to the original class */
	String *uname = Getattr(n,"uname");
	/* Import into current type scope */
	SwigType_typedef_using(uname);
      } else if (Strcmp(ntype,"enum") == 0) {
	SwigType_typedef_using(Getattr(n,"uname"));	
      }
    }
    return SWIG_OK;
  }
  /* ------------------------------------------------------------
   * typemapDirective()
   * ------------------------------------------------------------ */ 

  virtual int typemapDirective(Node *n) {
    if (inclass || nsname) {
      Node *items = firstChild(n);
      while (items) {
	Parm *pattern = Getattr(items,"pattern");
	Parm *parms   = Getattr(items,"parms");
	normalize_later(pattern);
	normalize_later(parms);
	items = nextSibling(items);
      }
    }
    return SWIG_OK;
  }


  /* ------------------------------------------------------------
   * typemapcopyDirective()
   * ------------------------------------------------------------ */ 

  virtual int typemapcopyDirective(Node *n) {
    if (inclass) {
      Node *items = firstChild(n);
      ParmList *pattern = Getattr(n,"pattern");
      normalize_later(pattern);
      while (items) {
	ParmList *npattern = Getattr(items,"pattern");
	normalize_later(npattern);
	items = nextSibling(items);
      }
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * applyDirective()
   * ------------------------------------------------------------ */ 

  virtual int applyDirective(Node *n) {
    if (inclass) {
      ParmList *pattern = Getattr(n,"pattern");
      normalize_later(pattern);
      Node *items = firstChild(n);
      while (items) {
	Parm *apattern = Getattr(items,"pattern");
	normalize_later(apattern);
	items = nextSibling(items);
      }
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * clearDirective()
   * ------------------------------------------------------------ */ 

  virtual int clearDirective(Node *n) {
    if (inclass) {
      Node *p;
      for (p = firstChild(n); p; p = nextSibling(p)) {
	ParmList *pattern = Getattr(p,"pattern");
	normalize_later(pattern);
      }
    }
    return SWIG_OK;
  }
};

void Swig_process_types(Node *n) {
  if (!n) return;
  TypePass *t = new TypePass;
  t->top(n);
  delete t;
}





  

