/* ----------------------------------------------------------------------------- 
 * typepass.cxx
 *
 *     This module builds all of the internal type information by collecting
 *     typedef declarations as well as registering classes, structures, and unions.
 *     This information is need to correctly handle shadow classes and other
 *     advanced features.
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
  Node  *inclass;
  int    importmode;

/* generate C++ inheritance type-relationships */
  void cplus_inherit_types(Node *cls, String *clsname) {
    List *ilist = Getattr(cls,"bases");
    
    if (!ilist) return;
    int len = Len(ilist);
    int i;
    for (i = 0; i < len; i++) {
      Node *n = Getitem(ilist,i);
      Node *bname = Getattr(n,"name");
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
	SwigType_merge_scope(scopes);
      }
      cplus_inherit_types(bclass,clsname);
    }
  }

public:
  virtual int top(Node *n) {
    importmode = 0;
    emit_children(n);
    return SWIG_OK;
  }

  virtual int importDirective(Node *n) { 
    int oldimport = importmode;
    importmode = 1;
    emit_children(n); 
    importmode = oldimport;
    return SWIG_OK;
  }

  virtual int includeDirective(Node *n) { return emit_children(n); }
  virtual int externDeclaration(Node *n) { return emit_children(n); }

  virtual int classDeclaration(Node *n) {
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

    SwigType_new_scope();
    if (name) SwigType_set_scope_name(name);

    /* Need to set up a typedef if unnamed */
    if (unnamed && tdname && (Cmp(storage,"typedef") == 0)) {
      SwigType_typedef(unnamed,tdname);
    }

    /* Inherit type definitions into the class */
    if (name) {
      cplus_inherit_types(n,name);
    }

    emit_children(n);

    Hash *ts = SwigType_pop_scope();
    Setattr(n,"typescope",ts);
    return SWIG_OK;
  }

  virtual int cDeclaration(Node *n) {
    String *storage = Getattr(n,"storage");
    if (!storage) return SWIG_OK;
    if (!(Strcmp(storage,"typedef") == 0)) {
      return SWIG_OK;
    }

    SwigType *ty   = Getattr(n,"type");
    String   *name = Getattr(n,"name");
    SwigType  *decl = Getattr(n,"decl");

    SwigType *t = Copy(ty);
    SwigType_push(t,decl);
    SwigType_typedef(t,name);
    return SWIG_OK;
  }

  virtual int enumDeclaration(Node *n) {
    String *name = Getattr(n,"name");
    if (name) {
      SwigType *t = NewStringf("enum %s", name);
      SwigType_typedef(t,name);
      Delete(t);
    }
    return SWIG_OK;
  }

};

void Swig_process_types(Node *n) {
  TypePass *t = new TypePass;
  t->top(n);
  delete t;
}





  

