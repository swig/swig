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
 * Structure and classes:
 *
 * C/C++ symbol tables are normally managed in a few different spaces.  The
 * most visible namespace is reserved for functions, variables, typedef, enum values
 * and such.  In C, a separate tag-space is reserved for 'struct name', 'class name',
 * and 'union name' declarations.   In SWIG, a single namespace is used for everything
 * this means that certain incompatibilities will arise with some C programs. For instance:
 *
 *        struct Foo {
 *             ...
 *        }
 *
 *        int Foo();       // Error. Name clash.  Works in C though 
 * 
 * Due to the unified namespace for structures, special handling is performed for
 * the following:
 *
 *        typedef struct Foo {
 *
 *        } Foo;
 * 
 * In this case, the symbol table contains an entry for the structure itself.  The
 * typedef is left out of the symbol table.
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
static Hash *symtabs = 0;         /* Hash of all symbol tables by fully-qualified name */
static Hash *global_scope = 0;    /* Global scope */

/* -----------------------------------------------------------------------------
 * Swig_symbol_new()
 *
 * Create a new symbol table object
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_init() {
  current = NewHash();
  current_symtab = NewHash();
  set_nodeType(current_symtab,"symboltable");
  Setattr(current_symtab,"symtab",current);

  /* Set the global scope */
  symtabs = NewHash();
  Setattr(symtabs,"",current_symtab);
  global_scope = current_symtab;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_setscopename()
 *
 * Set the name of the current symbol table scope
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_setscopename(const String_or_char *name) {
  String *qname;
  Symtab *p;
  assert(!Getattr(current_symtab,"name"));
  Setattr(current_symtab,"name",name);

  /* Set nested scope in parent */

  qname = Swig_symbol_qualifiedscopename(current_symtab);

  /* Save a reference to this scope */
  Setattr(symtabs,qname,current_symtab);
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
 * Swig_symbol_getscope()
 *
 * Given a fully qualified name, this function returns a scope 
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_getscope(const String_or_char *name) {
  if (!symtabs) return 0;
  if (Strcmp(name,"::") == 0) name = "";
  return Getattr(symtabs,name);
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
  name = Getattr(symtab,"name");
  if (name) {
    if (!result) {
      result = NewString("");
    }
    if (Len(result)) {
      Printf(result,"::%s",name);
    } else {
      Printf(result,"%s",name);
    }
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

  set_nodeType(h,"symboltable");  
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
  int      nt = 0, ct = 0;
  /* See if the symbol already exists in the table */
  c = Getattr(current,symname);
  if (c) {
    /* There is a symbol table conflict.  There are a few cases to consider here:
        (1) A conflict between a class/enum and a typedef declaration is okay.
            In this case, the symbol table entry is set to the class/enum declaration
            itself, not the typedef.   

        (2) A conflict between namespaces is okay--namespaces are open

        (3) Otherwise, overloading is only allowed for functions
    */

    /* Check for namespaces */
    if ((Strcmp(nodeType(n),nodeType(c)) == 0) && ((Strcmp(nodeType(n),"namespace") == 0))) {
      Node *cl, *pcl = 0;
      cl = c;
      while (cl) {
	pcl = cl;
	cl = Getattr(cl,"sym:nextSibling");
      }
      Setattr(pcl,"sym:nextSibling",n);
      Setattr(n,"sym:symtab", current_symtab);
      Setattr(n,"sym:name", symname);
      Setattr(n,"sym:previousSibling", pcl);
      return n;
    }
    if (Getattr(n,"allows_typedef")) nt = 1;
    if (Getattr(c,"allows_typedef")) ct = 1;
    if (nt || ct) {
      Node *td, *other;
      String *s;
      /* At least one of the nodes allows typedef overloading.  Make sure that
         both don't--this would be a conflict */

      if (nt && ct) return c;

      /* Figure out which node allows the typedef */
      if (nt) {
	td = n;
	other = c;
      } else {
	td = c;
	other = n;
      }
      /* Make sure the other node is a typedef */
      s = Getattr(other,"storage");
      if (!s || (Strcmp(s,"typedef"))) return c;  /* No.  This is a conflict */
      
      /* Hmmm.  This appears to be okay.  Make sure the symbol table refers to the allow_type node */
      
      if (td != c) {
	Setattr(current,symname, td);
	Setattr(td,"sym:symtab", current_symtab);
	Setattr(td,"sym:name", symname);
      }
      return n;
    }
     
    decl = Getattr(c,"decl");
    ndecl = Getattr(n,"decl");

    if (Cmp(nodeType(n),nodeType(c))) return c;
    if ((!SwigType_isfunction(decl)) || (!SwigType_isfunction(ndecl))) {
      /* Symbol table conflict */
      return c;
    }
    
    /* Hmmm. Declarator seems to indicate that this is a function */
    /* Look at storage class to see if compatible */
    cstorage = Getattr(c,"storage");
    nstorage = Getattr(n,"storage");

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
      decl = Getattr(cn,"decl");
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
 * symbol_lookup_qualified()
 *
 * Internal function to handle fully qualified symbol table lookups.  This
 * works from the symbol table supplied in symtab and unwinds its way out
 * towards the global scope.
 * ----------------------------------------------------------------------------- */

static Node *
symbol_lookup_qualified(String_or_char *name, Symtab *symtab, String *prefix, int local) {

  /* This is a little funky, we search by fully qualified names */

  if (!symtab) return 0;
  if (!prefix) {
    Node *n;
    List *namelist;
    int   i, len;

    String *nname = NewString(name);
    Replaceall(nname,"::",":");
    namelist = Split(nname,":",-1);
    prefix = NewString("");
    len = Len(namelist);
    for (i = 0; i < len - 1; i++) {
      if (i > 0) Append(prefix,"::");
      Append(prefix,Getitem(namelist,i));
    }
    name = Getitem(namelist,len-1);
    n = symbol_lookup_qualified(name, symtab, prefix, local);
    Delete(nname);
    Delete(namelist);
    Delete(prefix);
    return n;
  } else {
    String *qname;
    Symtab *st;
    Node *n = 0;
    /* Make qualified name of current scope */
    qname = Swig_symbol_qualifiedscopename(symtab);
    if (qname && Len(qname)) {
      if (Len(prefix)) {
	Append(qname,"::");
	Append(qname,prefix);
      }
    } else {
      qname = NewString(prefix);
    }
    st = Getattr(symtabs,qname);
    Delete(qname);

    /* Found a scope match */
    if (st) {
      Hash *sym = Getattr(st,"symtab");
      if (!name) return st;
      n = Getattr(sym,name);
    }

    if (!n) {
      if (!local) {
	return symbol_lookup_qualified(name,parentNode(symtab), prefix, local);
      } else {
	return 0;
      }
    }
    return n;
  }

#ifdef OLD
  if (!symtab) return 0;

  if (!namelist) {
    Node *n;
    String *nname = NewString(name);
    Replaceall(nname,"::",":");
    namelist = Split(nname,":",-1);
    n = symbol_lookup_qualified(name, symtab, namelist, local);
    Delete(nname);
    Delete(namelist);
    return n;
  } else {
    int   i, len;
    Node *n;
    Symtab *nsym = symtab;
    len = Len(namelist);

    /* First, we try to pin down the enclosing scopes */
    for (i = 0; i < len-1; i++) {
      String *nm;
      Hash *sym;
      if (!nsym) {
	/* Whoa. No symbol table */
	if (!local) {
	  return symbol_lookup_qualified(name, parentNode(symtab), namelist, local);
	} else {
	  return 0;
	}
      }
      nm = Getitem(namelist,i);
      /* See if this scope has any children with the right name */
      {
	Symtab *chd = firstChild(nsym);
	while (chd) {
	  String *cname = Getattr(chd,"name");
	  if (cname && (Strcmp(cname,nm) == 0)) break;
	  chd = nextSibling(chd);
	}
	nsym = chd;
      }
    }
    /* If we made it this far, we found all enclosing scopes do a final check */
    if (nsym) {
      n = Getattr(nsym, Getitem(namelist,len-1));
      if (n) return n;
    }
    if (!local) {
      return symbol_lookup_qualified(name,parentNode(symtab),namelist, local);
    }  else {
      return 0;
    }
  }
#endif

}

/* -----------------------------------------------------------------------------
 * Swig_symbol_lookup()
 *
 * Look up a symbol in the symbol table
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_lookup(String_or_char *name, Symtab *n) {
  Hash *h,*hsym;
  Hash *s;

  if (!n) {
    h = current;
    hsym = current_symtab;
  } else {
    if (Strcmp(nodeType(n),"symboltable")) {
      n = Getattr(n,"sym:symtab");
    }
    assert(n);
    if (n) {
      hsym = n;
      h = Getattr(hsym,"symtab");
    }
  }

  if (Strstr(name,"::")) {
    if (Strncmp(name,"::",2) == 0) return symbol_lookup_qualified(Char(name)+2,global_scope,0,0);
    else return symbol_lookup_qualified(name,hsym,0,0);
  }

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
Swig_symbol_lookup_local(String_or_char *name, Symtab *n) {
  Hash *h, *hsym;
  if (!n) {
    hsym = current_symtab;
    h = current;
  } else {
    if (Strcmp(nodeType(n),"symboltable")) {
      n = Getattr(n,"sym:symtab");
    }
    assert(n);
    hsym = n;
    h = Getattr(n,"symtab");
  }

  if (Strstr(name,"::")) {
    if ((Strncmp(name,"::",2) == 0)  && (hsym == global_scope)) {
      return symbol_lookup_qualified(Char(name)+2,hsym,0,1);
    } else {
      return symbol_lookup_qualified(name,hsym,0,1);
    }
  }
  return Getattr(h,name);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_scope_lookup()
 *
 * Look up a scope name.
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_scope_lookup(String_or_char *name, Symtab *symtab) {
  if (Strncmp(name,"::",2) == 0) return symbol_lookup_qualified(0, global_scope, name, 0);
  return symbol_lookup_qualified(0,symtab,name,0);
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
  if (Strcmp(nodeType(n),"symboltable") == 0) {
    symtab = n;
  } else {
    symtab = Getattr(n,"sym:symtab");
  }
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




