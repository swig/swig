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
 * overloaded functions.  In this case, a linked list is built.  The "sym:nextSibling"
 * attribute is reserved to hold a link to the next entry.  For example:
 *
 * int foo(int);            --> "name" : "foo"         "name" : "foo"
 * int foo(int,double);         "type" : "int"         "type" : "int" 
 *                              "decl" : "f(int)."     "decl" : "f(int,double)."
 *                               ...                    ...
 *                   "sym:nextSibling" :  --------> "sym:nextSibling": --------> ...
 *
 * When more than one symbol has the same name, the symbol declarator is 
 * used to detect duplicates.  For example, in the above case, foo(int) and
 * foo(int,double) are different because their "decl" attribute is different.
 * However, if a third declaration "foo(int)" was made, it would generate a 
 * conflict (due to having a declarator that matches a previous entry).
 *
 * Tag space:
 *
 * C/C++ symbol tables are normally managed in a few different spaces.  The
 * most visible namespace is reserved for functions, variables, typedef, enum values
 * and such.  A separate tag-space is reserved for 'struct name', 'class name',
 * 'union name', and 'enum name' declarations.   Each symbol table contains
 * separate spaces for both normal symbols and tags.
 * 
 * Symbol table structure:
 *
 * Symbol tables themselves are a special kind of node that is organized just like
 * a normal parse tree node.  Symbol tables are organized in a tree that can be
 * traversed using the SWIG-DOM API. The following attributes names are reserved.
 *
 *     name           -- Name of the scope defined by the symbol table (if any)
 *     symtab         -- Hash table containing all of the normal symbols
 *     tags           -- Hash table containing tag symbols
 *
 * Reserved attributes on symbol objects:
 *
 * When a symbol is placed in the symbol table, the following attributes
 * are set:
 *       
 *     sym:name             -- Symbol name
 *     sym:nextSibling      -- Next symbol (if overloaded)
 *     sym:previousSibling  -- Previous symbol (if overloaded)
 *     sym:symtab           -- Symbol table object holding the symbol
 *     sym:overloaded       -- Set to the first symbol if overloaded
 *
 * These names are modeled after XML namespaces.  In particular, every attribute 
 * pertaining to symbol table management is prefaced by the "sym:" prefix.   
 * ----------------------------------------------------------------------------- */
     
static Hash *current = 0;         /* This current symbol table */
static Hash *current_symtab = 0;  /* Current symbol table node */

/* -----------------------------------------------------------------------------
 * Swig_symbol_new()
 *
 * Create a new symbol table object
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_init() {
  current = NewHash();
  current_symtab = NewHash();
  set_nodeType(current_symtab,"sym:symboltable");
  Setattr(current_symtab,"symtab",current);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_setscopename()
 *
 * Set the name of the current symbol table scope
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_setscopename(String_or_char *name) {
  Setattr(current_symtab,"name",name);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_getscopename()
 *
 * Get the name of the current symbol table scope
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_getscopename() {
  return Getattr(current_symtab,"name");
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
  if (!symtab) symtab = current_symtab;
  parent = parentNode(symtab);
  if (parent) {
    result = Swig_symbol_qualifiedscopename(parent);
  }
  if (!result) {
    result = NewString("");
  }
  name = Getattr(symtab,"name");
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
  Hash *hsyms, *h;
  hsyms = NewHash();
  h = NewHash();
  
  Setattr(h,"symtab",hsyms);
  set_parentNode(h,current_symtab);
  
  n = lastChild(current_symtab);
  if (!n) {
    set_firstChild(current_symtab,h);
  } else {
    set_nextSibling(n,h);
  }
  set_lastChild(current_symtab,h);
  current = hsyms;
  current_symtab = h;
  return current;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_setscope()
 *
 * Set the current scope.  Returns the previous current scope.
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_setscope(Symtab *sym) {
  Symtab *ret = current_symtab;
  current_symtab = sym;
  current = Getattr(sym,"symtab");
  assert(current);
  return ret;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_popscope()
 *
 * Pop out of the current scope.  Returns the popped scope
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_popscope() {
  Hash *h = current_symtab;
  current_symtab = parentNode(current_symtab);
  assert(current_symtab);
  current = Getattr(current_symtab,"symtab");
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
  return current_symtab;
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
      cn = Getattr(cn,"sym:nextSibling");
    }

    /* Well, we made it this far.  Guess we can drop the symbol in place */
    Setattr(n,"sym:symtab",current_symtab);
    Setattr(n,"sym:name",symname);
    Setattr(cl,"sym:nextSibling",n);
    Setattr(n,"sym:previousSibling",cl);
    Setattr(cl,"sym:overloaded",c);
    Setattr(n,"sym:overloaded",c);
    return n;
  }

  /* No conflict.  Just add it */
  Setattr(n,"sym:symtab",current_symtab);
  Setattr(n,"sym:name",symname);
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
  tag = Getattr(current_symtab,"tags");
  if (!tag) {
    tag = NewHash();
    Setattr(current_symtab,"tags",tag);
  }
  c = Getattr(tag,symname);
  if (c) {
    return c;
  }
  /* No conflict.  Just add it there */
  Setattr(n,"sym:symtab",current_symtab);
  Setattr(n,"sym:name",symname);
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
  Hash *h,*hsym;
  Hash *s;
  h = current;
  hsym = current_symtab;
  while (h) {
    s = Getattr(h,name);
    if (s) return s;
    hsym = parentNode(hsym);
    if (!hsym) break;
    h = Getattr(hsym,"symtab");
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
  h = current_symtab;
  while (h) {
    t = Getattr(h,"tags");
    if (t) {
      s = Getattr(t,name);
      if (s) return s;
    }
    h = parentNode(h);
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
  Symtab  *symtab; 
  String  *symname;
  Node    *symprev;
  Node    *symnext;
  symtab  = Getattr(n,"sym:symtab");        /* Get symbol table object */
  symtab  = Getattr(symtab,"symtab");       /* Get actual hash table of symbols */
  symname = Getattr(n,"sym:name");
  symprev = Getattr(n,"sym:previousSibling");
  symnext = Getattr(n,"sym:nextSibling");

  /* If previous symbol, just fix the links */
  if (symprev) {
    if (symnext) {
      Setattr(symprev,"sym:nextSibling",symnext);
    } else {
      Delattr(symprev,"sym:nextSibling");
    }
  } else {
    /* If no previous symbol, see if there is a next symbol */
    if (symnext) {
      Setattr(symtab,symname,symnext);
    } else {
      Delattr(symtab,symname);
    }
  }
  Delattr(n,"sym:symtab");
  Delattr(n,"sym:previousSibling");
  Delattr(n,"sym:nextSibling");
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_qualified()
 *
 * Return the qualified name of a symbol
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_qualified(Node *n) {
  Hash *symtab;
  symtab = Getattr(n,"sym:symtab");
  if (!symtab) return NewString("");
  return Swig_symbol_qualifiedscopename(symtab);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_isoverloaded()
 * 
 * Check if a symbol is overloaded.  Returns the first symbol if so.
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_isoverloaded(Node *n) {
  return Getattr(n,"sym:overloaded");
}




