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

#include "swigmod.h"

struct normal_node {
    Symtab *symtab;
    Hash   *typescope;
    List   *normallist;
    normal_node *next;
};

static normal_node *patch_list = 0;

class TypePass : public Dispatcher {
    Node   *inclass;
    Node   *module;
    int    importmode;
    String *nsname;
    Hash   *classhash;
    List   *normalize;

    /* Normalize a type. Replaces type with fully qualified version */

    void normalize_type(SwigType *ty) {
	SwigType *qty = SwigType_typedef_qualified(ty);
	/* SwigType *qty = Swig_symbol_type_qualify(ty,0);  */
	/*	Printf(stdout,"%s --> %s\n", ty, qty); */
	Clear(ty);
	Append(ty,qty);
	Delete(qty);
    }
  
    /* Normalize a parameter list */
  
    void normalize_parms(ParmList *p) {
	while (p) {
	    SwigType *ty = Getattr(p,"type");
	    normalize_type(ty);
	    String *value = Getattr(p,"value");
	    if (value) {
	      /*	      Printf(stdout,"value = '%s'\n", value); */
	      Node *n = Swig_symbol_clookup(value,0);
	      if (n) {
		String *q = Swig_symbol_qualified(n);
		if (q && Len(q)) {
		  Insert(value,0,"::");
		  Insert(value,0,SwigType_namestr(q));
		  Delete(q);
		}
	      }
	    }
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
	Hash *currentsym = Swig_symbol_current();

	normal_node *nn = patch_list;
	normal_node *np;
	while (nn) {
	    Swig_symbol_setscope(nn->symtab);
	    SwigType_set_scope(nn->typescope);
	    SwigType *t;
	    for (t = Firstitem(nn->normallist); t; t = Nextitem(nn->normallist)) {
		normalize_type(t);
	    }
	    Delete(nn->normallist);
	    np = nn->next;
	    delete(nn);
	    nn = np;
	}
	Swig_symbol_setscope(currentsym);
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
		    int   clsforward = 0;
		    String *bname = Getitem(nlist,i);
		    String *sname = bname;
		    String *tname = 0;

		    /* Try to locate the base class.   We look in the symbol table and we chase 
		       typedef declarations to get to the base class if necessary */
		    Symtab *st = Getattr(cls,"sym:symtab");

		    if (SwigType_istemplate(bname)) {
		      tname = SwigType_typedef_resolve_all(bname);
		      sname = tname;
		    }
		    /*		    Printf(stdout,"'%s' ---> '%s'\n", bname, SwigType_typedef_resolve_all(bname)); */
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
				if (Strcmp(nodeType(bcls),"classforward") != 0) {
				  Swig_error(Getfile(bname),Getline(bname),"'%s' is not a class. \n",bname);
				} else {
				  Swig_warning(WARN_TYPE_INCOMPLETE,Getfile(bname),Getline(bname),"Base class '%s' is incomplete.\n", bname);
				  clsforward = 1;
				}
				bcls = 0;
			    } else {
			      if (Getattr(bcls,"typepass:visit")) {
				if (!ilist) ilist = NewList();
				Append(ilist,bcls);
			      } else {
				Swig_error(Getfile(bname),Getline(bname),"class '%s' must be defined before it is used as a base class.\n", bname);
			      }
			    }
			}
			break;
		    }
		    if (tname) Delete(tname);
		    if (!bcls) {
			if (!clsforward) {
			    if (!Getmeta(bname,"already_warned")) {
				Swig_warning(WARN_TYPE_UNDEFINED_CLASS, Getfile(bname),Getline(bname),"Nothing known about class '%s'. Ignored.\n", SwigType_namestr(bname));
				if (Strchr(bname,'<')) {
				    Swig_warning(WARN_TYPE_UNDEFINED_CLASS, Getfile(bname), Getline(bname), "Maybe you forgot to instantiate '%s' using %%template.\n", SwigType_namestr(bname));
				}
				Setmeta(bname,"already_warned","1");
			    }
			}
			SwigType_inherit(clsname,bname);
		    }
		}
	    }
	    if (ilist) {
	      Setattr(cls,"bases",ilist);
	    }
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

  /* Clean overloaded list.  Removes templates, friends, ignored, and errors */

  void clean_overloaded(Node *n) {
    Node *nn = Getattr(n,"sym:overloaded");
    Node *first = 0;
    while (nn) {
      if ((Strcmp(nodeType(nn),"template") == 0) ||
	  (Getattr(nn,"feature:ignore")) ||
	  (Getattr(nn,"error")) ||
	  (checkAttribute(nn,"storage","friend"))) {
	/* Remove from overloaded list */
	Node *ps = Getattr(nn,"sym:previousSibling");
	Node *ns = Getattr(nn,"sym:nextSibling");
	if (ps) {
	  Setattr(ps,"sym:nextSibling",ns);
	} 
	if (ns) {
	  Setattr(ns,"sym:previousSibling",ps);
	}
      } else {
	if (!first) first = nn;
	Setattr(nn,"sym:overloaded",first);
      }
      nn = Getattr(nn,"sym:nextSibling");
    }
    if (!first) {
      Delattr(n,"sym:overloaded");
    }
  }

public:

    /* ------------------------------------------------------------
     * top()
     * ------------------------------------------------------------ */ 

    virtual int top(Node *n) {
	importmode = 0;
	module = Getattr(n,"module");
	inclass = 0;
	normalize = 0;
	nsname = 0;
	classhash = Getattr(n,"classes");
	emit_children(n);
	normalize_list();
	SwigType_set_scope(0);
	return SWIG_OK;
    }


    /* ------------------------------------------------------------
     * moduleDirective()
     * ------------------------------------------------------------ */ 

    virtual int moduleDirective(Node *n) {
	module = n;
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
     * extendDirective()
     * ------------------------------------------------------------ */ 

    virtual int includeDirective(Node *n) { return emit_children(n); }
    virtual int externDeclaration(Node *n) { return emit_children(n); }
    virtual int extendDirective(Node *n) { return emit_children(n); }

    /* ------------------------------------------------------------
     * classDeclaration()
     * ------------------------------------------------------------ */ 

    virtual int classDeclaration(Node *n) {
	String *name = Getattr(n,"name");
	String *tdname = Getattr(n,"tdname");
	String *unnamed = Getattr(n,"unnamed");
	String *storage = Getattr(n,"storage");
	String *kind = Getattr(n,"kind");
	Node   *oldinclass = inclass;
	List   *olist = normalize;
	Symtab *symtab;
	String *nname = 0;
	String *fname = 0;
	String *scopename = 0;

	normalize = NewList();

	if (name) {

	  if (SwigType_istemplate(name)) {
	    // We need to fully resolve the name to make templates work correctly */
	    Node *cn;
	    fname = SwigType_typedef_resolve_all(name);
	    if (Strcmp(fname,name) != 0) {
	      cn = Swig_symbol_clookup_local(fname,0);
	      if ((!cn) || (Strcmp(nodeType(cn),"template") == 0)) {
		Swig_symbol_cadd(fname,n);
		SwigType_typedef_class(fname);
		scopename = Copy(fname);
	      } else {
		Swig_warning(WARN_TYPE_REDEFINED,Getfile(n),Getline(n),"Template '%s' was already wrapped as '%s' at %s:%d.\n",
			     SwigType_namestr(name), SwigType_namestr(Getattr(cn,"name")), Getfile(cn), Getline(cn));
		scopename = 0;
	      }
	    } else {
	      Swig_symbol_cadd(fname,n);
	      SwigType_typedef_class(fname);
	      scopename = Copy(fname);
	    }
	  } else {
	    if ((CPlusPlus) || (unnamed)) {
	      SwigType_typedef_class(name);
	    } else {
	      SwigType_typedef_class(NewStringf("%s %s", kind, name));
	    }
	    scopename = Copy(name);
	  }
	} else {
	  scopename = 0;
	}

	Setattr(n,"typepass:visit","1");

	/* Need to set up a typedef if unnamed */
	if (unnamed && tdname && (Cmp(storage,"typedef") == 0)) {
	    SwigType_typedef(unnamed,tdname);
	}

	if (nsname) {
	    nname = NewStringf("%s::%s", nsname, name);
	} 
	SwigType_new_scope(scopename);
	SwigType_attach_symtab(Getattr(n,"symtab"));

	/* Inherit type definitions into the class */
	if (name) {
	    cplus_inherit_types(n, nname ? nname : (fname ? fname : name));
	}
    
	inclass = n;
	symtab = Swig_symbol_setscope(Getattr(n,"symtab"));
	emit_children(n);
	Swig_symbol_setscope(symtab);

	Hash *ts = SwigType_pop_scope();
	Setattr(n,"typescope",ts);
	Setattr(n,"module",module);

	/* Normalize deferred types */
	{
	    normal_node *nn = new normal_node();
	    nn->normallist = normalize;
	    nn->symtab = Getattr(n,"symtab");
	    nn->next = patch_list;
	    nn->typescope = Getattr(n,"typescope");
	    patch_list = nn;
	}

	normalize = olist;

	inclass = oldinclass;

	/* If in a namespace, patch the class name */
	if (nname) {
	  Setattr(n,"name",nname);
	}
	return SWIG_OK;
    }

    /* ------------------------------------------------------------
     * namespaceDeclaration()
     * ------------------------------------------------------------ */ 

  virtual int templateDeclaration(Node *n) {
    String *name = Getattr(n,"name");
    String *ttype = Getattr(n,"templatetype");
    if (Strcmp(ttype,"class") == 0) {
      SwigType_typedef_class(name);
    } else if (Strcmp(ttype,"classforward") == 0) {
      SwigType_typedef_class(name);
    }
    return SWIG_OK;
  }

    /* ------------------------------------------------------------
     * classforwardDeclaration()
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
	Symtab *symtab;
	String *name = Getattr(n,"name");
	String *alias = Getattr(n,"alias");
	List   *olist = normalize;
	normalize = NewList();    
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
		    SwigType_attach_symtab(Getattr(n,"symtab"));
		} else {
		    SwigType_set_scope(ts);
		}
	    }
	    String *oldnsname = nsname;
	    nsname = Swig_symbol_qualified(Getattr(n,"symtab"));
	    symtab = Swig_symbol_setscope(Getattr(n,"symtab"));
	    emit_children(n);
	    Swig_symbol_setscope(symtab);

	    if (name) {
		Hash *ts = SwigType_pop_scope();
		Setattr(n,"typescope",ts);
	    }

	    /* Normalize deferred types */
	    {
		normal_node *nn = new normal_node();
		nn->normallist = normalize;
		nn->symtab = Getattr(n,"symtab");
		nn->next = patch_list;
		nn->typescope = Getattr(n,"typescope");
		patch_list = nn;
	    }
	    normalize = olist;

	    Delete(nsname);
	    nsname = oldnsname;
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
	    if (CPlusPlus) {
	      Replaceall(t,"struct ","");
	      Replaceall(t,"union ","");
	      Replaceall(t,"class ","");
	    }
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

	clean_overloaded(n);
#if 0
	/* If overloaded, removed templates */
	{
	  Node *nn = Getattr(n,"sym:overloaded");
	  Node *first = 0;
	  while (nn) {
	    if (Strcmp(nodeType(nn),"template") != 0) {
	      if (!first) first = nn;
	      Setattr(nn,"sym:overloaded",first);
	    } else {
	      /* Is a template */
	      Node *ps = Getattr(nn,"sym:previousSibling");
	      Node *ns = Getattr(nn,"sym:nextSibling");
	      if (ps) {
		Setattr(ps,"sym:nextSibling",ns);
	      } 
	      if (ns) {
		Setattr(ns,"sym:previousSibling",ps);
	      }
	    }
	    nn = Getattr(nn,"sym:nextSibling");
	  }
	  if (!first) {
	    Delattr(n,"sym:overloaded");
	  }

	}
#endif

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
	clean_overloaded(n);
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
	emit_children(n);
	return SWIG_OK;
    }

    /* ------------------------------------------------------------
     * enumvalueDeclaration()
     * ------------------------------------------------------------ */

  virtual int enumvalueDeclaration(Node *n) {
    String *name = Getattr(n,"name");
    String *value = Getattr(n,"value");
    if (!value) value = name;
    if (Strcmp(value,name) == 0) {
      String *new_value;
      if ((nsname) || (inclass)) {
	new_value = NewStringf("%s::%s", SwigType_namestr(Swig_symbol_qualified(n)), value);
      } else {
	new_value = NewString(value);
      }
      Setattr(n,"value",new_value);
      Delete(new_value);
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
	  Node *ns;
	    /* using id */

	  if (Getattr(n,"sym:symtab")) {
	    ns = Swig_symbol_clookup(Getattr(n,"uname"), Getattr(n,"sym:symtab"));
	  } else {
	    ns = 0;
	  }
	  if (!ns) {
	    if (!Getattr(n,"access") || ((Strcmp(Getattr(n,"access"),"public") == 0))) {
	      Swig_warning(WARN_PARSE_USING_UNDEF, Getfile(n), Getline(n), "tp: Nothing known about '%s'.\n", Getattr(n,"uname"));	    
	    }
	  } else {

	    /* Only a single symbol is being used.  There are only a few symbols that
	       we actually care about.  These are typedef, class declarations, and enum */

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





  

