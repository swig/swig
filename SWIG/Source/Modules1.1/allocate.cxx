/* ----------------------------------------------------------------------------- 
 * allocate.cxx
 *
 *     This module tries to figure out which classes and structures support
 *     default constructors and destructors in C++.   There are several rules that
 *     define this behavior including pure abstract methods, private sections,
 *     and non-default constructors in base classes.  See the ARM or
 *     Doc/Manual/SWIGPlus.html for details.
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

class Allocate : public Dispatcher {
  Node  *inclass;
  enum AccessMode { PUBLIC, PRIVATE, PROTECTED };
  AccessMode cplus_mode;
  int extendmode;

  /* Checks to see if a class is abstract through inheritance */
  int is_abstract_inherit(Node *n, Node *base = 0) {
    if (!base) {
      /* Root node */
      Symtab *stab = Getattr(n,"symtab");         /* Get symbol table for node */
      Symtab *oldtab = Swig_symbol_setscope(stab);
      int ret = is_abstract_inherit(n,n);
      Swig_symbol_setscope(oldtab);
      return ret;
    }
    List *abstract = Getattr(base,"abstract");

    if (abstract) {
      for (int i = 0; i < Len(abstract); i++) {
	Node *n = Getitem(abstract,i);
	String *name = Getattr(n,"name");
	if (Strstr(name,"~")) continue;   /* Don't care about destructors */
	Node *dn = Swig_symbol_clookup(name,0);
	assert(dn);       /* If symbol is in abstract list, it sure better be in the class itself */
	if (dn && (Getattr(dn,"abstract"))) {
	  return 1;
	} 
      }
    }
    List *bases = Getattr(base,"bases");
    if (!bases) return 0;
    for (int i = 0; i < Len(bases); i++) {
      if (is_abstract_inherit(n,Getitem(bases,i))) {
	return 1;
      }
    }
    return 0;
  }

public:
  virtual int top(Node *n) {
    cplus_mode = PUBLIC;
    inclass = 0;
    extendmode = 0;
    emit_children(n);
    return SWIG_OK;
  }

  virtual int importDirective(Node *n) { return emit_children(n); }
  virtual int includeDirective(Node *n) { return emit_children(n); }
  virtual int externDeclaration(Node *n) { return emit_children(n); }
  virtual int namespaceDeclaration(Node *n) { return emit_children(n); }
  virtual int extendDirective(Node *n) {
      extendmode = 1;
      emit_children(n);
      extendmode = 0;
      return SWIG_OK;
  }
  virtual int classDeclaration(Node *n) {
    if (!CPlusPlus) {
      /* Always have default constructors/destructors in C */
      Setattr(n,"allocate:default_constructor","1");
      Setattr(n,"allocate:default_destructor","1");
      return SWIG_OK;
    }

    if (Getattr(n,"allocate:visit")) return SWIG_OK;
    /* Always visit base classes first */
    {
      List *bases = Getattr(n,"bases");
      if (bases) {
	for (int i = 0; i < Len(bases); i++) {
	  Node *b = Getitem(bases,i);
	  classDeclaration(b);
	}
      }
    }

    inclass = n;
    String *kind = Getattr(n,"kind");
    if (Strcmp(kind,"class") == 0) {
      cplus_mode = PRIVATE;
    } else {
      cplus_mode = PUBLIC;
    }

    emit_children(n);

    /* Check if the class is abstract via inheritance.   This might occur if a class didn't have
       any pure virtual methods of its own, but it didn't implement all of the pure methods in
       a base class */

    if (is_abstract_inherit(n)) {
      if (!Getattr(n,"abstract")) {
	Swig_warning(WARN_TYPE_ABSTRACT,Getfile(n),Getline(n),"Class '%s' might be abstract. \n", Getattr(n,"name"));
		     /*	Setattr(n,"abstract",NewList()); */
      }
    }

    /*    if (Getattr(n,"abstract")) {
      Delattr(n,"allocate:default_constructor");
      Delattr(n,"allocate:has_constructor");
    }
    */
    if (!Getattr(n,"allocate:has_constructor")) {
      /* No constructor is defined.  We need to check a few things */
      /* If class is abstract.  No default constructor. Sorry */
      /*      if (Getattr(n,"abstract")) {
	Delattr(n,"allocate:default_constructor");
	} else  */
      
      if (!Getattr(n,"allocate:default_constructor")) {
	/* Check base classes */
	List *bases = Getattr(n,"bases");
	int   allows_default = 1;
	
	for (int i = 0; i < Len(bases); i++) {
	  Node *n = Getitem(bases,i);
	  /* If base class does not allow default constructor, we don't allow it either */
	  if (!Getattr(n,"allocate:default_constructor") && (!Getattr(n,"allocate:default_base_constructor"))) {
	    allows_default = 0;
	  }
	}
	if (allows_default) {
	  Setattr(n,"allocate:default_constructor","1");
	}
      }
    }
    if (!Getattr(n,"allocate:has_destructor")) {
      /* No destructor was defined.  We need to check a few things here too */
      List *bases = Getattr(n,"bases");
      int allows_destruct = 1;

      for (int i = 0; i < Len(bases); i++) {
	Node *n = Getitem(bases,i);
	/* If base class does not allow default destructor, we don't allow it either */
	if (!Getattr(n,"allocate:default_destructor") && (!Getattr(n,"allocate:default_base_destructor"))) {
	  allows_destruct = 0;
	}
      }
      if (allows_destruct) {
	Setattr(n,"allocate:default_destructor","1");
      }
    }

    /* Only care about default behavior.  Remove temporary values */
    Setattr(n,"allocate:visit","1");
    inclass = 0;
    return SWIG_OK;
  }

  virtual int accessDeclaration(Node *n) {
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

  virtual int cDeclaration(Node *n) {
    /* Look for a private assignment operator */
    if (inclass && (cplus_mode != PUBLIC)) {
      String *name = Getattr(n,"name");
      if (Strcmp(name,"operator =") == 0) {
	Setattr(inclass,"allocate:noassign","1");
      }
    }
    return SWIG_OK;
  }

  virtual int constructorDeclaration(Node *n) {
    if (!inclass) return SWIG_OK;
    Parm   *parms = Getattr(n,"parms");
    if (!extendmode) {
	if (!ParmList_numrequired(parms)) {
	    /* Class does define a default constructor */
	    /* However, we had better see where it is defined */
	    if (cplus_mode == PUBLIC) {
		Setattr(inclass,"allocate:default_constructor","1");
	    } else if (cplus_mode == PROTECTED) {
		Setattr(inclass,"allocate:default_base_constructor","1");
	    }
	}
	/* Class defines some kind of constructor. May or may not be public */
	Setattr(inclass,"allocate:has_constructor","1");
    }

    /* See if this is a copy constructor */
    if (parms && (ParmList_numrequired(parms) == 1)) {
      /* Look for a few cases. X(const X &), X(X &), X(X *) */

      String *cc = NewStringf("r.q(const).%s", Getattr(inclass,"name"));
      if (Strcmp(cc,Getattr(parms,"type")) == 0) {
	Setattr(n,"copy_constructor","1");
      }
      Delete(cc);
      cc = NewStringf("r.%s", Getattr(inclass,"name"));
      if (Strcmp(cc,Getattr(parms,"type")) == 0) {
	Setattr(n,"copy_constructor","1");
      }
      Delete(cc);
      cc = NewStringf("p.%s", Getattr(inclass,"name"));
      String *ty = SwigType_strip_qualifiers(Getattr(parms,"type"));
      if (Strcmp(cc,ty) == 0) {
	Setattr(n,"copy_constructor","1");
      }
      Delete(cc);
      Delete(ty);
    }
    return SWIG_OK;
  }

  virtual int destructorDeclaration(Node *n) {
    if (!inclass) return SWIG_OK;
    if (!extendmode) {
	Setattr(inclass,"allocate:has_destructor","1");
	if (cplus_mode == PUBLIC) {
	    Setattr(inclass,"allocate:default_destructor","1");
	} else if (cplus_mode == PROTECTED) {
	    Setattr(inclass,"allocate:default_base_destructor","1");
	}
    }
    return SWIG_OK;
  }
};

void Swig_default_allocators(Node *n) {
  if (!n) return;
  Allocate *a = new Allocate;
  a->top(n);
  delete a;
}





  

