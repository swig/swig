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
public:
  virtual int top(Node *n) {
    cplus_mode = PUBLIC;
    inclass = 0;
    emit_children(n);
  }

  virtual int importDirective(Node *n) { return emit_children(n); }
  virtual int includeDirective(Node *n) { return emit_children(n); }
  virtual int externDeclaration(Node *n) { return emit_children(n); }

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

    if (Getattr(n,"abstract")) {
      Delattr(n,"allocate:default_constructor");
      Delattr(n,"allocate:has_constructor");
    } else if (!Getattr(n,"allocate:has_constructor")) {
      /* No constructor was defined.  We need to check a few things */
      /* If class is abstract.  No default constructor. Sorry */
      if (Getattr(n,"abstract")) {
	Delattr(n,"allocate:default_constructor");
      } else if (!Getattr(n,"allocate:default_constructor")) {
	/* Check base classes */
	List *bases = Getattr(n,"bases");
	int   allows_default = 1;

	for (int i = 0; i < Len(bases); i++) {
	  Node *n = Getitem(bases,i);
	  /* If base class does not allow default constructor, we don't allow it either */
	  if (!Getattr(n,"allocate:default_constructor")) {
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
	/* If base class does not allow default constructor, we don't allow it either */
	if (!Getattr(n,"allocate:default_destructor")) {
	  allows_destruct = 0;
	}
      }
      if (allows_destruct) {
	Setattr(n,"allocate:default_destructor","1");
      }
    }

    /* Only care about default behavior.  Remove temporary values */
    Delattr(n,"allocate:has_constructor");
    Delattr(n,"allocate:has_destructor");
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

  virtual int constructorDeclaration(Node *n) {
    if (!inclass) return SWIG_OK;
    Parm   *parms = Getattr(n,"parms");
    if (!ParmList_numrequired(parms)) {
      /* Class does define a default constructor */
      /* However, we had better see where it is defined */
      if (cplus_mode != PRIVATE) {
	Setattr(inclass,"allocate:default_constructor","1");
      }
    }
    /* Class defines some kind of constructor. May or may not be public */
    Setattr(inclass,"allocate:has_constructor","1");
    return SWIG_OK;
  }

  virtual int destructorDeclaration(Node *n) {
    if (!inclass) return SWIG_OK;

    Setattr(inclass,"allocate:has_destructor","1");
    if (cplus_mode == PUBLIC) {
      Setattr(inclass,"allocate:default_destructor","1");
    }
    return SWIG_OK;
  }
};

void Swig_default_allocators(Node *n) {
  Allocate *a = new Allocate;
  a->top(n);
  delete a;
}





  

