/* -----------------------------------------------------------------------------
 * symbol.c
 *
 *     This file implements the SWIG symbol table.  See details below.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "swig.h"

/* -----------------------------------------------------------------------------
 * Synopsis
 *
 * This module provides symbol table management for all of SWIG.  In previous
 * releases, the management of symbols was rather haphazard.  This module tries
 * to correct that.
 *
 * All symbols are associated with simple identifiers.  For example, here are some
 * declarations that generate symbol table entries:
 *
 *  decl                                    symbol
 *  --------------                          ------------
 *  void foo(int);                          foo
 *  int  x;                                 x
 *  typedef int *blah;                      blah
 *
 * Associated with each symbol is a Hash table that can contain any set of
 * attributes that make sense for that object.  For example:
 *
 *  typedef int *blah;             ---->    "name" : 'blah'
 *                                          "type" : 'int'
 *                                          "decl" : 'p.'
 *                                       "storage" : 'typedef'          
 * 
 * In some cases, the symbol table needs to manage overloaded entries.  For instance,
 * overloaded functions.  In this case, a linked list is built.  The "$symnext"
 * attribute is reserved to hold a link to the next entry.  For example:
 *
 * int foo(int);            --> "name" : "foo"         "name" : "foo"
 * int foo(int,double);         "type" : "int"         "type" : "int" 
 *                              "decl" : "f(int)."     "decl" : "f(int,double)."
 *                               ...                    ...
 *                          "$symnext" :  --------> "$symnext": --------> ...
 *
 * When more than one symbol has the same name, the symbol declarator is often
 * used to detect duplicates.  For example, in the above case, foo(int) and
 * foo(int,double) are different because their "decl" attribute is different.
 * However, a third declaration "foo(int)" was made, it would generate a conflict
 * (due to having an existing declarator).
 * 
 * Reserved symbol names:   
 *
 * Symbol tables themselves need a few attributes.  These are always prefaced by 
 * a $ in SWIG.  The only reserved attributes used at this time are as follows:
 *
 *     $scopename           -- Name of the scope defined by the symbol table (if any)
 *     $parent              -- Link to parent symbol table
 *     $child               -- Link to first child symbol table
 *     $lastchild           -- Link to last child
 *     $nextsibling         -- Link to next sibling (if any)
 *
 * When used properly, the symbol table is built during parsing and used later
 * during code generation.
 *
 * Reserved attributes:
 *
 * Each symbol table entry has $symnext and $symtab attributes to point to the
 * next symbol and the symbol table.
 *
 * Tag space:
 *
 * C/C++ symbol tables are normally managed in a few different spaces.  The
 * most visible namespace is reserved for functions, variables, typedef, enum values
 * and such.  A separate tag-space is reserved for 'struct name', 'class name',
 * 'union name', and 'enum name' declarations.     The *tag* functions deal with this.
 * ----------------------------------------------------------------------------- */
     
static Hash *current = 0;

/* -----------------------------------------------------------------------------
 * Swig_symbol_new()
 *
 * Create a new symbol table object
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_init() {
  current = NewHash();
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_setscopename()
 *
 * Set the name of the current symbol table scope
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_setscopename(String_or_char *name) {
  Setattr(current,"$scopename",name);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_getscopename()
 *
 * Get the name of the current symbol table scope
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_getscopename() {
  return Getattr(current,"$scopename");
}

/* ----------------------------------------------------------------------------- 
 * Swig_symbol_qualifiedscopename()
 *
 * Get the fully qualified name of a symbol table
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_qualifiedscopename(Symtab *symtab) {
  String *result = 0;
  Hash *parent;
  String *name;
  if (!symtab) symtab = current;
  parent = Getattr(symtab,"$parent");
  if (parent) {
    result = Swig_symbol_qualifiedscopename(parent);
  }
  if (!result) {
    result = NewString("");
  }
  name = Getattr(symtab,"$scopename");
  if (name) {
    Printf(result,"%s::",name);
  }
  return result;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_newscope()
 *
 * Create a new scope.  Returns the newly created scope.
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_newscope() 
{
  Hash *n;
  Hash *h = NewHash();
  Setattr(h,"$parent",current);
  
  n = Getattr(current,"$lastchild");
  if (!n) {
    Setattr(current,"$child",h);
  } else {
    Setattr(n,"$nextsibling",h);
  }
  Setattr(current,"$lastchild",h);
  current = h;
  return current;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_setscope()
 *
 * Set the current scope.  Returns the previous current scope.
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_setscope(Symtab *sym) {
  Symtab *ret = current;
  current = sym;
  return ret;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_popscope()
 *
 * Pop out of the current scope.  Returns the popped scope
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_popscope() {
  Hash *h = current;
  current = Getattr(current,"$parent");
  assert(current);
  return h;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_current()
 *
 * Get current scope
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_current() {
  return current;
}

/* ----------------------------------------------------------------------------- 
 * Swig_symbol_add()
 *
 * Adds a node to the symbol table.  Returns the node itself if successfully
 * added.  Otherwise, it returns the symbol table entry of the conflicting node
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_add(String_or_char *symname, Node *n) {
  Hash *c, *cn, *cl;
  SwigType *decl, *ndecl;
  String   *cstorage, *nstorage;

  /* See if the symbol already exists in the table */
  c = Getattr(current,symname);
  if (c) {
    /* Yes. It does.  We *only* support overloaded functions */
    decl = Getdecl(c);
    ndecl = Getdecl(n);

    if (Cmp(nodeType(n),nodeType(c))) return c;
    if ((!SwigType_isfunction(decl)) || (!SwigType_isfunction(ndecl))) {
      /* Symbol table conflict */
      return c;
    }
    
    /* Hmmm. Declarator seems to indicate that this is a function */
    /* Look at storage class to see if compatible */
    cstorage = Getstorage(c);
    nstorage = Getstorage(n);

    /* If either one is declared as typedef, forget it. We're hosed */
    if (Cmp(cstorage,"typedef") == 0) {
      return c;
    }
    if (Cmp(nstorage,"typedef") == 0) {
      return c;
    }

    /* Okay. Walk down the list of symbols and see if we get a declarator match */

    cn = c;
    while (cn) {
      decl = Getdecl(cn);
      if (Cmp(ndecl,decl) == 0) {
	/* Declarator conflict */
	return cn;
      }
      cl = cn;
      cn = Getattr(cn,"$symnext");
    }

    /* Well, we made it this far.  Guess we can drop the symbol in place */
    Setattr(n,"$symtab",current);
    Setattr(n,"$symname",symname);
    Setattr(cl,"$symnext",n);
    Setattr(n,"$symprev",cl);
    Setattr(cl,"$overloaded",c);
    Setattr(n,"$overloaded",c);
    return n;
  }

  /* No conflict.  Just add it right in there */
  Setattr(n,"$symtab",current);
  Setattr(n,"$symname",symname);
  Setattr(current,symname,n);
  return n;
}

/* ----------------------------------------------------------------------------- 
 * Swig_symbol_add_tag()
 *
 * Adds a node to the tag space.
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_add_tag(String_or_char *symname, Node *n) {
  Hash *tag;
  Node *c;
  tag = Getattr(current,"$tags");
  if (!tag) {
    tag = NewHash();
    Setattr(current,"$tags",tag);
  }
  c = Getattr(tag,symname);
  if (c) {
    return c;
  }
  /* No conflict.  Just add it right in there */
  Setattr(n,"$symtab",tag);
  Setattr(n,"$symname",symname);
  Setattr(tag,symname,n);
  return n;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_lookup()
 *
 * Look up a symbol in the symbol table
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_lookup(String_or_char *name) {
  Hash *h;
  Hash *s;
  h = current;
  while (h) {
    s = Getattr(h,name);
    if (s) return s;
    h = Getattr(h,"$parent");
  }
  return 0;
}


Node *
Swig_symbol_lookup_local(String_or_char *name) {
  Hash *s;
  s = Getattr(current,name);
  if (s) return s;
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_lookup_tag()
 *
 * Look up a symbol in the symbol table
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_lookup_tag(String_or_char *name) {
  Hash *h, *t;
  Hash *s;
  h = current;
  while (h) {
    t = Getattr(current,"$tags");
    if (t) {
      s = Getattr(t,name);
      if (s) return s;
    }
    h = Getattr(h,"$parent");
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_remove()
 *
 * Remove a symbol 
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_remove(Node *n) {
  Symtab *symtab; 
  String *symname;
  Node   *symprev;
  Node   *symnext;
  symtab = Getattr(n,"$symtab");
  symname = Getattr(n,"$symname");
  symprev = Getattr(n,"$symprev");
  symnext = Getattr(n,"$symnext");

  /* If previous symbol, just fix the links */
  if (symprev) {
    if (symnext) {
      Setattr(symprev,"$symnext",symnext);
    } else {
      Delattr(symprev,"$symnext");
    }
  } else {
    /* If no previous symbol, see if there is a next symbol */
    if (symnext) {
      Setattr(symtab,symname,symnext);
    } else {
      Delattr(symtab,symname);
    }
  }
  Delattr(n,"$symtab");
  Delattr(n,"$symprev");
  Delattr(n,"$symnext");
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_qualified()
 *
 * Return the qualified name of a symbol
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_qualified(Node *n) {
  Hash *symtab;
  symtab = Getattr(n,"$symtab");
  if (!symtab) return NewString("");
  return Swig_symbol_qualifiedscopename(symtab);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_isoverloaded()
 * 
 * Check if a symbol is overloaded
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_isoverloaded(Node *n) {
  return Getattr(n,"$overloaded");
}
