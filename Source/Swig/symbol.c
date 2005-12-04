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

char cvsroot_symbol_c[] = "$Header$";

#include "swig.h"
#include "swigwarn.h"
#include <ctype.h>

/* #define SWIG_DEBUG*/
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
 * Structures and classes:
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
 * Target language vs C:
 *
 * The symbol tables are normally managed *in the namespace of the target language*.
 * This means that name-collisions can be resolved using %rename and related 
 * directives.   A quirk of this is that sometimes the symbol tables need to
 * be used for C type resolution as well.  To handle this, each symbol table
 * also has a C-symbol table lurking behind the scenes.  This is used to locate 
 * symbols in the C namespace.  However, this symbol table is not used for error 
 * reporting nor is it used for anything else during code generation.
 *
 * Symbol table structure:
 *
 * Symbol tables themselves are a special kind of node that is organized just like
 * a normal parse tree node.  Symbol tables are organized in a tree that can be
 * traversed using the SWIG-DOM API. The following attributes names are reserved.
 *
 *     name           -- Name of the scope defined by the symbol table (if any)
 *                       This name is the C-scope name and is not affected by
 *                       %renaming operations
 *     symtab         -- Hash table mapping identifiers to nodes.
 *     csymtab        -- Hash table mapping C identifiers to nodes.
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
 *
 * An example dump of the parse tree showing symbol table entries for the 
 * following code should clarify this:
 *
 *   namespace OuterNamespace {
 *       namespace InnerNamespace {
 *           class Class {
 *           };
 *           struct Struct {
 *               int Var;
 *           };
 *       }
 *    }
 *
 *   +++ namespace ----------------------------------------
 *   | sym:name     - "OuterNamespace"
 *   | symtab       - 0xa064bf0
 *   | sym:symtab   - 0xa041690
 *   | sym:overname - "__SWIG_0"
 *  
 *         +++ namespace ----------------------------------------
 *         | sym:name     - "InnerNamespace"
 *         | symtab       - 0xa064cc0
 *         | sym:symtab   - 0xa064bf0
 *         | sym:overname - "__SWIG_0"
 *  
 *               +++ class ----------------------------------------
 *               | sym:name     - "Class"
 *               | symtab       - 0xa064d80
 *               | sym:symtab   - 0xa064cc0
 *               | sym:overname - "__SWIG_0"
 *               | 
 *               +++ class ----------------------------------------
 *               | sym:name     - "Struct"
 *               | symtab       - 0xa064f00
 *               | sym:symtab   - 0xa064cc0
 *               | sym:overname - "__SWIG_0"
 *  
 *                     +++ cdecl ----------------------------------------
 *                     | sym:name     - "Var"
 *                     | sym:symtab   - 0xa064f00
 *                     | sym:overname - "__SWIG_0"
 *                     | 
 *  
 *
 * Each class and namespace has its own scope and thus a new symbol table (sym)
 * is created. The sym attribute is only set for the first entry in the symbol
 * table. The sym:symtab entry points to the symbol table in which the symbol
 * exists, so for example, Struct is in the scope OuterNamespace::InnerNamespace
 * so sym:symtab points to this symbol table (0xa064cc0).
 *
 * ----------------------------------------------------------------------------- */
     
static Hash *current = 0;         /* The current symbol table hash */
static Hash *ccurrent = 0;        /* The current c symbol table hash */
static Hash *current_symtab = 0;  /* Current symbol table node */
static Hash *symtabs = 0;         /* Hash of all symbol tables by fully-qualified name */
static Hash *global_scope = 0;    /* Global scope */

/* common attribute keys, to avoid calling find_key all the times */

static String *empty_string = 0;
static String *k_allowstypedef = 0;
static String *k_cdecl = 0;
static String *k_coloncolon = 0;
static String *k_constructor = 0;
static String *k_csymnextSibling = 0;
static String *k_csympreviousSibling = 0;
static String *k_csymtab = 0;
static String *k_decl = 0;
static String *k_enumitem = 0;
static String *k_inherit = 0;
static String *k_name = 0;
static String *k_namespace = 0;
static String *k_nodetype = 0;
static String *k_parentnode = 0;
static String *k_storage = 0;
static String *k_symboltable = 0;
static String *k_symname = 0;
static String *k_symnextSibling = 0;
static String *k_symoverloaded = 0;
static String *k_symovername = 0;
static String *k_sympreviousSibling = 0;
static String *k_symsymtab = 0;
static String *k_symtab = 0;
static String *k_symtypename = 0;
static String *k_symweak = 0;
static String *k_template = 0;
static String *k_templateparm = 0;
static String *k_templateparms = 0;
static String *k_templatetype = 0;
static String *k_type = 0;
static String *k_typedef = 0;
static String *k_uname = 0;
static String *k_using = 0;
static String *k_value = 0;


#if 0
void
Swig_symbol_dump_symtable() {
  Printf(stdout, "DUMPING SYMTABLE start =======================================\n");
  {
    Hash* cst = Getattr(current_symtab, k_csymtab);
    Swig_print_tree(cst);
    /*
    Swig_print_tree(Getattr(cst, "NumSpace"));
    */
  }
  Printf(stdout, "DUMPING SYMTABLE end   =======================================\n");
}
#endif

/* -----------------------------------------------------------------------------
 * Swig_symbol_new()
 *
 * Create a new symbol table object
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_init() {
  empty_string = NewString("");
  k_allowstypedef = NewString("allows_typedef");
  k_cdecl = NewString("cdecl");
  k_coloncolon = NewString("::");
  k_constructor = NewString("constructor");
  k_csymnextSibling = NewString("csym:nextSibling");
  k_csympreviousSibling = NewString("csym:previousSibling");
  k_csymtab = NewString("csymtab");
  k_decl = NewString("decl");
  k_enumitem = NewString("enumitem");
  k_inherit = NewString("inherit");
  k_name = NewString("name");
  k_namespace = NewString("namespace");
  k_nodetype = NewString("nodeType");
  k_parentnode = NewString("parentNode");
  k_storage = NewString("storage");
  k_symboltable = NewString("symboltable");
  k_symname = NewString("sym:name");
  k_symnextSibling = NewString("sym:nextSibling");
  k_symoverloaded = NewString("sym:overloaded");
  k_symovername = NewString("sym:overname");
  k_sympreviousSibling = NewString("sym:previousSibling");
  k_symsymtab = NewString("sym:symtab");
  k_symtab = NewString("symtab");
  k_symtypename = NewString("sym:typename");
  k_symweak = NewString("sym:weak");
  k_template = NewString("template");
  k_templateparm = NewString("templateparm");
  k_templateparms = NewString("templateparms");
  k_templatetype = NewString("templatetype");
  k_type = NewString("type");
  k_typedef = NewString("typedef");
  k_uname = NewString("uname");
  k_using = NewString("using");
  k_value = NewString("value");

  current = NewHash();
  current_symtab = NewHash();
  ccurrent = NewHash();
  set_nodeType(current_symtab,k_symboltable);
  Setattr(current_symtab,k_symtab,current);
  Delete(current);
  Setattr(current_symtab,k_csymtab, ccurrent);
  Delete(ccurrent);

  /* Set the global scope */
  symtabs = NewHash();
  Setattr(symtabs,empty_string,current_symtab);
  Delete(current_symtab);
  global_scope = current_symtab;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_setscopename()
 *
 * Set the C scopename of the current symbol table.
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_setscopename(const String_or_char *name) {
  String *qname;
  /* assert(!Getattr(current_symtab,k_name)); */
  Setattr(current_symtab,k_name,name);

  /* Set nested scope in parent */

  qname = Swig_symbol_qualifiedscopename(current_symtab);

  /* Save a reference to this scope */
  Setattr(symtabs,qname,current_symtab);
  Delete(qname);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_getscopename()
 *
 * Get the C scopename of the current symbol table
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_getscopename() {
  return HashGetAttr(current_symtab,k_name);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_getscope()
 *
 * Given a fully qualified C scopename, this function returns a symbol table
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_getscope(const String_or_char *name) {
  if (!symtabs) return 0;
  if (StringEqual(k_coloncolon,(String_or_char *)name)) name = empty_string;
  return Getattr(symtabs,name);
}

/* ----------------------------------------------------------------------------- 
 * Swig_symbol_qualifiedscopename()
 *
 * Get the fully qualified C scopename of a symbol table.  Note, this only pertains
 * to the C/C++ scope name.  It is not affected by renaming.
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_qualifiedscopename(Symtab *symtab) {
  String *result = 0;
  Hash *parent;
  String *name;
  if (!symtab) symtab = current_symtab;
  parent = HashGetAttr(symtab,k_parentnode);
  if (parent) {
    result = Swig_symbol_qualifiedscopename(parent);
  }
  name = HashGetAttr(symtab,k_name);
  if (name) {
    if (!result) {
      result = NewStringEmpty();
    }
    if (StringLen(result)) {
      Printv(result,"::",name, NIL);
    } else {
      StringAppend(result,name);
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

  set_nodeType(h,k_symboltable);  
  Setattr(h,k_symtab,hsyms);
  Delete(hsyms);
  set_parentNode(h,current_symtab);
  
  n = lastChild(current_symtab);
  if (!n) {
    set_firstChild(current_symtab,h);
  } else {
    set_nextSibling(n,h);
    Delete(h);
  }
  set_lastChild(current_symtab,h);
  current = hsyms;
  ccurrent = NewHash();
  Setattr(h,k_csymtab,ccurrent);
  Delete(ccurrent);
  current_symtab = h;
  return h;
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
  current = HashGetAttr(sym,k_symtab);
  assert(current);
  ccurrent = HashGetAttr(sym,k_csymtab);
  assert(ccurrent);
  return ret;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_popscope()
 *
 * Pop out of the current scope.  Returns the popped scope and sets the
 * scope to the parent scope.
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_popscope() {
  Hash *h = current_symtab;
  current_symtab = HashGetAttr(current_symtab, k_parentnode);
  assert(current_symtab);
  current = HashGetAttr(current_symtab,k_symtab);
  assert(current);
  ccurrent = HashGetAttr(current_symtab,k_csymtab);
  assert(ccurrent);
  return h;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_current()
 *
 * Return the current symbol table.
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_current() {
  return current_symtab;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_alias()
 *
 * Makes an alias for a symbol in the global symbol table.
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_alias(String_or_char *aliasname, Symtab *s) {
  String *qname = Swig_symbol_qualifiedscopename(current_symtab);
  if (qname) {
    Printf(qname,"::%s", aliasname);
  } else {
    qname = NewString(aliasname);
  }
  if (!HashGetAttr(symtabs,qname)) {
    Setattr(symtabs,qname,s);
  }
  Delete(qname);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_inherit()
 *
 * Inherit symbols from another scope.
 * ----------------------------------------------------------------------------- */

void Swig_symbol_inherit(Symtab *s) {
  int i;
  List *inherit = HashGetAttr(current_symtab,k_inherit);
  if (!inherit) {
    inherit = NewList();
    Setattr(current_symtab,k_inherit, inherit);
    Delete(inherit);
  }
  assert(s != current_symtab);
  for (i = 0; i < Len(inherit); i++) {
    Node *n = Getitem(inherit,i);
    if (n == s) return;              /* Already inherited */
  }
  Append(inherit,s);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_cadd()
 *
 * Adds a node to the C symbol table only.
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_cadd(String_or_char *name, Node *n) {
  Node *append = 0;

  Node *cn;
  /* There are a few options for weak symbols.  A "weak" symbol 
     is any symbol that can be replaced by another symbol in the C symbol
     table.  An example would be a forward class declaration.  A forward
     class sits in the symbol table until a real class declaration comes along.

     Certain symbols are marked as "sym:typename".  These are important 
     symbols related to the C++ type-system and take precedence in the C
     symbol table.  An example might be code like this:

            template<class T> T foo(T x);
            int foo(int);

     In this case, the template is marked with "sym:typename" so that it
     stays in the C symbol table (so that it can be expanded using %template).
   */

  if (!name) return;
  if (SwigType_istemplate(name)) {
    String *cname = NewString(name);
    String *dname = Swig_symbol_template_deftype(cname,0);
    if (!StringEqual(dname,name)) {    
      Swig_symbol_cadd(dname, n);
    }
    Delete(dname);
    Delete(cname);
  }

#ifdef SWIG_DEBUG
  Printf(stderr,"symbol_cadd %s %x\n", name, n);
#endif
  cn = Getattr(ccurrent,name);

  if (cn && (HashGetAttr(cn,k_symtypename))) {
    /* The node in the C symbol table is a typename.  Do nothing */
    /* We might append the symbol at the end */
    append = n;
  } else if (cn && (HashGetAttr(cn,k_symweak))) {
    /* The node in the symbol table is weak. Replace it */
    Setattr(ccurrent,name, n);
  } else if (cn && (HashGetAttr(n,k_symweak))) {
    /* The node being added is weak.  Don't worry about it */
  } else if (cn && (HashGetAttr(n,k_symtypename))) {
    /* The node being added is a typename.  We definitely add it */
    Setattr(ccurrent,name,n);
    append = cn;
  } else if (cn && (HashCheckAttr(cn, k_nodetype, k_templateparm))) {
    Swig_error(Getfile(n),Getline(n),
	       "Declaration of '%s' shadows template parameter,\n",
	       name);
    Swig_error(Getfile(cn),Getline(cn),
	       "previous template parameter declaration '%s'.\n",
	       name);
    return;
  } else if (cn) {
    append = n;
  } else if (!cn) {
    /* No conflict. Add the symbol */
    Setattr(ccurrent,name,n);
  }

  /* Multiple entries in the C symbol table.   We append to to the symbol table */
  if (append) {
    Node *fn, *pn = 0;
    cn = Getattr(ccurrent,name);
    fn = cn;
    while (fn) {
      pn = fn;
      if (fn == append) {
	/* already added. Bail */
	return;
      }
      fn = HashGetAttr(fn,k_csymnextSibling);
    }
    if (pn) {
      Setattr(pn,k_csymnextSibling,append);
    }
  }

  /* Special typedef handling.  When a typedef node is added to the symbol table, we
     might have to add a type alias.   This would occur if the typedef mapped to another
     scope in the system.  For example:

           class Foo {
           };

           typedef Foo OtherFoo;

     In this case, OtherFoo becomes an alias for Foo. */

  {
    Node *td = n;
    while (td && HashCheckAttr(td,k_nodetype,k_cdecl) && HashCheckAttr(td,k_storage,k_typedef)) {
      SwigType *type;
      Node *td1;
      type = Copy(HashGetAttr(td,k_type));
      SwigType_push(type,HashGetAttr(td,k_decl));
      td1 = Swig_symbol_clookup(type,0);
 
      /* Fix patetic case #1214313:
	 
	 class Foo
	 {
	 };
	 
	 typedef Foo FooBar;
	 
	 class CBaz
	 {
	 public:
	 typedef FooBar Foo;
	 };

	 ie, when Foo -> FooBar -> Foo, jump one scope up when possible.
	 
      */
      if (td1 && HashCheckAttr(td1,k_storage,k_typedef)) {
	String *st = HashGetAttr(td1,k_type);
	String *sn = HashGetAttr(td,k_name);
	if (st && sn && StringEqual(st, sn)) {
	  Symtab *sc = HashGetAttr(current_symtab,k_parentnode);
	  if (sc) td1 = Swig_symbol_clookup(type,sc);
	}
      }

      Delete(type);
      if (td1 == td) break;
      td = td1;
      if (td) {
	Symtab *st = HashGetAttr(td,k_symtab);
	if (st) {
	  Swig_symbol_alias(HashGetAttr(n,k_name),st);
	  break;
	}
      }
    }
  }
}

/* ----------------------------------------------------------------------------- 
 * Swig_symbol_add()
 *
 * Adds a node to the symbol table.  Returns the node itself if successfully
 * added.  Otherwise, it returns the symbol table entry of the conflicting node.
 *
 * Also places the symbol in a behind-the-scenes C symbol table.  This is needed
 * for namespace support, type resolution, and other issues.
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_add(String_or_char *symname, Node *n) {
  Hash *c, *cn, *cl = 0;
  SwigType *decl, *ndecl;
  String   *cstorage, *nstorage;
  int      nt = 0, ct = 0;
  int      pn = 0;
  int      u1 = 0, u2 = 0;
  String   *name, *overname;

  /* See if the node has a name.  If so, we place in the C symbol table for this
     scope. We don't worry about overloading here---the primary purpose of this
     is to record information for type/name resolution for later. Conflicts
     in C namespaces are errors, but these will be caught by the C++ compiler
     when compiling the wrapper code */

  
  /* There are a few options for weak symbols.  A "weak" symbol 
     is any symbol that can be replaced by another symbol in the C symbol
     table.  An example would be a forward class declaration.  A forward
     class sits in the symbol table until a real class declaration comes along.

     Certain symbols are marked as "sym:typename".  These are important 
     symbols related to the C++ type-system and take precedence in the C
     symbol table.  An example might be code like this:

            template<class T> T foo(T x);
            int foo(int);

     In this case, the template is marked with "sym:typename" so that it
     stays in the C symbol table (so that it can be expanded using %template).
   */

  name = HashGetAttr(n,k_name);
  if (name && Len(name)) {
    Swig_symbol_cadd(name,n);
  }

  /* No symbol name defined.  We return. */
  if (!symname) {
    Setattr(n,k_symsymtab,current_symtab);
    return n;
  }

  /* If node is ignored. We don't proceed any further */
  if (GetFlag(n,"feature:ignore")) return n;

  /* See if the symbol already exists in the table */
  c = Getattr(current,symname);

  /* Check for a weak symbol.  A weak symbol is allowed to be in the
     symbol table, but is silently overwritten by other symbols.  An example
     would be a forward class declaration.  For instance:

           class Foo;

     In this case, "Foo" sits in the symbol table.  However, the
     definition of Foo would replace the entry if it appeared later. */
     
  if (c && HashGetAttr(c,k_symweak)) {
    c = 0;
  }
  if (c) {
    /* There is a symbol table conflict.  There are a few cases to consider here:
        (1) A conflict between a class/enum and a typedef declaration is okay.
            In this case, the symbol table entry is set to the class/enum declaration
            itself, not the typedef.   

        (2) A conflict between namespaces is okay--namespaces are open

        (3) Otherwise, overloading is only allowed for functions
    */

    /* Check for namespaces */
    String *ntype = HashGetAttr(n, k_nodetype); 
    if ((StringEqual(ntype,HashGetAttr(c,k_nodetype))) && ((StringEqual(ntype,k_namespace)))) {
      Node *cl, *pcl = 0;
      cl = c;
      while (cl) {
	pcl = cl;
	cl = HashGetAttr(cl,k_symnextSibling);
      }
      Setattr(pcl,k_symnextSibling,n);
      Setattr(n,k_symsymtab, current_symtab);
      Setattr(n,k_symname, symname);
      Setattr(n,k_sympreviousSibling, pcl);
      return n;
    }
    if (HashGetAttr(n,k_allowstypedef)) nt = 1;
    if (HashGetAttr(c,k_allowstypedef)) ct = 1;
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
      s = HashGetAttr(other,k_storage);
      if (!s || (!StringEqual(s,k_typedef))) return c;  /* No.  This is a conflict */
      
      /* Hmmm.  This appears to be okay.  Make sure the symbol table refers to the allow_type node */
      
      if (td != c) {
	Setattr(current,symname, td);
	Setattr(td,k_symsymtab, current_symtab);
	Setattr(td,k_symname, symname);
      }
      return n;
    }
     
    decl = HashGetAttr(c,k_decl);
    ndecl = HashGetAttr(n,k_decl);

    {
      String *nt1, *nt2;
      nt1 = HashGetAttr(n,k_nodetype);
      if (StringEqual(nt1,k_template)) nt1 = HashGetAttr(n,k_templatetype);
      nt2 = HashGetAttr(c,k_nodetype);
      if (StringEqual(nt2,k_template)) nt2 = HashGetAttr(c,k_templatetype);
      if (StringEqual(nt1,k_using)) u1 = 1;
      if (StringEqual(nt2,k_using)) u2 = 1;

      if ((!StringEqual(nt1,nt2)) && !(u1 || u2)) return c;
    }
    if (!(u1 || u2)) {
      if ((!SwigType_isfunction(decl)) || (!SwigType_isfunction(ndecl))) {
	/* Symbol table conflict */
	return c;
      }
    }
    
    /* Hmmm. Declarator seems to indicate that this is a function */
    /* Look at storage class to see if compatible */
    cstorage = HashGetAttr(c,k_storage);
    nstorage = HashGetAttr(n,k_storage);

    /* If either one is declared as typedef, forget it. We're hosed */
    if (Cmp(cstorage,k_typedef) == 0) {
      return c;
    }
    if (Cmp(nstorage,k_typedef) == 0) {
      return c;
    }

    /* Okay. Walk down the list of symbols and see if we get a declarator match */
    {
      String *nt = HashGetAttr(n,k_nodetype);
      int n_template = StringEqual(nt,k_template) && HashCheckAttr(n,k_templatetype,k_cdecl);
      int n_plain_cdecl = StringEqual(nt,k_cdecl);
      cn = c;
      pn = 0;
      while (cn) {
        decl = HashGetAttr(cn,k_decl);
        if (!(u1 || u2)) {
          if (Cmp(ndecl,decl) == 0) {
            /* Declarator conflict */
            /* Now check we don't have a non-templated function overloaded by a templated function with same params,
             * eg void foo(); template<typename> void foo(); */
	    String *cnt = HashGetAttr(cn,k_nodetype);
            int cn_template = StringEqual(cnt,k_template) && HashCheckAttr(cn,k_templatetype,k_cdecl);
            int cn_plain_cdecl = StringEqual(cnt,k_cdecl);
            if (!((n_template && cn_plain_cdecl) || (cn_template && n_plain_cdecl))) {
              /* found a conflict */
              return cn;
            }
          }
        }
        cl = cn;
        cn = HashGetAttr(cn,k_symnextSibling);
        pn++;
      }
    }
    /* Well, we made it this far.  Guess we can drop the symbol in place */
    Setattr(n,k_symsymtab,current_symtab);
    Setattr(n,k_symname,symname);
    /* Printf(stdout,"%s %x\n", Getattr(n,k_symovername), current_symtab); */
    assert(!HashGetAttr(n,k_symovername));
    overname = NewStringf("__SWIG_%d", pn);
    Setattr(n,k_symovername, overname);
    /*Printf(stdout,"%s %s %s\n", symname, Getattr(n,k_decl), Getattr(n,k_symovername)); */
    Setattr(cl,k_symnextSibling,n);
    Setattr(n,k_sympreviousSibling,cl);
    Setattr(cl,k_symoverloaded,c);
    Setattr(n,k_symoverloaded,c);
    Delete(overname);
    return n;
  }

  /* No conflict.  Just add it */
  Setattr(n,k_symsymtab,current_symtab);
  Setattr(n,k_symname,symname);
  /* Printf(stdout,"%s\n", Getattr(n,k_symovername)); */
  overname = NewStringf("__SWIG_%d", pn);
  Setattr(n,k_symovername, overname);
  Delete(overname);
  /* Printf(stdout,"%s %s %s\n", symname, Getattr(n,k_decl), Getattr(n,k_symovername)); */
  Setattr(current,symname,n);
  return n;
}

/* -----------------------------------------------------------------------------
 * symbol_lookup()
 *
 * Internal function to handle fully qualified symbol table lookups.  This
 * works from the symbol table supplied in symtab and unwinds its way out
 * towards the global scope. 
 *
 * This function operates in the C namespace, not the target namespace.
 *
 * The check function is an optional callback that can be used to verify a particular
 * symbol match.   This is only used in some of the more exotic parts of SWIG. For instance,
 * verifying that a class hierarchy implements all pure virtual methods.
 * ----------------------------------------------------------------------------- */

static Node *
_symbol_lookup(String *name, Symtab *symtab, int (*check)(Node *n)) {
  Node *n;
  List *inherit;
  Hash *sym = HashGetAttr(symtab,k_csymtab);
  if (Getmark(symtab)) return 0;
  Setmark(symtab,1);


  n = HashGetAttr(sym,name);

#ifdef SWIG_DEBUG
  Printf(stderr,"symbol_look %s %x %x %s\n", name, n, symtab, HashGetAttr(symtab,k_name));
#endif
  
  if (n) {
    /* if a check-function is defined.  Call it to determine a match */
    if (check) {
      int c = check(n);
      if (c == 1) {
	Setmark(symtab,0);
	return n;
      }
      if (c < 0) {
	/* Terminate the search right away */
	Setmark(symtab,0);
	return 0;
      }
    } else {
      Setmark(symtab,0);
      return n;
    }
  }

  if (!n && SwigType_istemplate(name)) {
    String *dname = 0;
    Setmark(symtab,0);
    dname = Swig_symbol_template_deftype(name,symtab);
    if (!StringEqual(dname,name)) {
      n = _symbol_lookup(dname, symtab, check);
    }
    Delete(dname);
    if (n) return n;
  }

  inherit = HashGetAttr(symtab,k_inherit);
  if (inherit) {
    int  i,len;
    len = Len(inherit);
    for (i = 0; i < len; i++) {
      n = _symbol_lookup(name, Getitem(inherit,i),check);
      if (n) {
	Setmark(symtab,0);
	return n;
      }
    }
  }

  Setmark(symtab,0);
  return 0;
}

static Node *
symbol_lookup(String_or_char *name, Symtab *symtab, int (*check)(Node *n)) {
  Node *n = 0;
  if (DohCheck(name)) {
    n = _symbol_lookup(name, symtab, check);
  } else {
    String *sname = NewString(name);
    n =  _symbol_lookup(sname, symtab, check);
    Delete(sname);
  }
  return n;
}



/* -----------------------------------------------------------------------------
 * symbol_lookup_qualified()
 * ----------------------------------------------------------------------------- */

static Node *
symbol_lookup_qualified(String_or_char *name, Symtab *symtab, String *prefix, int local, int (*checkfunc)(Node *n)) {
  /* This is a little funky, we search by fully qualified names */

  if (!symtab) return 0;
  if (!prefix) {
    Node *n;
    String *bname;
    String *prefix;
    Swig_scopename_split(name, &prefix, &bname);
    n = symbol_lookup_qualified(bname,symtab,prefix,local,checkfunc);
    Delete(bname);
    Delete(prefix);
    return n;
  } else {
    Symtab *st;
    Node *n = 0;
    /* Make qualified name of current scope */
    String *qalloc = 0;
    String *qname = Swig_symbol_qualifiedscopename(symtab);
    if (qname){
      if (StringLen(qname)) {
	if (prefix && StringLen(prefix)) {
	  Printv(qname,k_coloncolon,prefix,NIL);
	}
      } else {
	StringAppend(qname, prefix);
      }
      qalloc = qname;
    } else {
      qname = prefix;
    }
    st = HashGetAttr(symtabs,qname);
    /* Found a scope match */
    if (st) {
      if (!name) {
	if (qalloc) Delete(qalloc);
	return st;
      }
      n = symbol_lookup(name, st,checkfunc);
    }
    if (qalloc) Delete(qalloc);

    if (!n) {
      if (!local) {
	Node *pn = HashGetAttr(symtab,k_parentnode);
	if (pn) n = symbol_lookup_qualified(name,pn, prefix, local,checkfunc);
      } else {
	n = 0;
      }
    }
    return n;
  }
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_clookup()
 *
 * Look up a symbol in the symbol table.   This uses the C name, not scripting
 * names.   Note: If we come across a using a directive, we follow it to
 * to get the real node.
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_clookup(String_or_char *name, Symtab *n) {
  Hash *hsym = 0;
  Node *s = 0;
  
  if (!n) {
    hsym = current_symtab;
  } else {
    if (!HashCheckAttr(n,k_nodetype,k_symboltable)) {
      n = HashGetAttr(n,k_symsymtab);
    }
    assert(n);
    if (n) {
      hsym = n;
    }
  }
  
  if (Swig_scopename_check(name)) {
    char *cname = Char(name);
    if (strncmp(cname,"::",2) == 0) {
      String *nname = NewString(cname+2);
      if (Swig_scopename_check(nname)) {
	s = symbol_lookup_qualified(nname,global_scope,0,0,0);
      }
      Delete(nname);
    } else {
      String *prefix = Swig_scopename_prefix(name);
      if (prefix) {
	s = symbol_lookup_qualified(name,hsym,0,0,0);
	Delete(prefix);
	if (!s) {
	  return 0;
	}
      }
    }
  }
  if (!s) {
    while (hsym) {
      s = symbol_lookup(name,hsym,0);
      if (s) break;
      hsym = HashGetAttr(hsym,k_parentnode);
      if (!hsym) break;
    }
  }
  if (!s) {
    return 0;
  }
  /* Check if s is a 'using' node */
  while (s && HashCheckAttr(s,k_nodetype,k_using)) {
    String *uname = HashGetAttr(s,k_uname);
    Symtab *un = HashGetAttr(s,k_symsymtab);
    Node *ss = (!StringEqual(name,uname) || (un != n)) ?
      Swig_symbol_clookup(uname, un) : 0; /* avoid infinity loop */
    if (!ss) {
      Swig_warning(WARN_PARSE_USING_UNDEF, Getfile(s), Getline(s), "Nothing known about '%s'.\n", HashGetAttr(s,k_uname));
    }
    s = ss;
  }
  return s;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_clookup_check()
 *
 * This function is identical to Swig_symbol_clookup() except that it
 * accepts a callback function that is invoked to determine a symbol match.
 * The purpose of this function is to support complicated algorithms that need
 * to examine multiple definitions of the same symbol that might appear in an
 * inheritance hierarchy. 
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_clookup_check(String_or_char *name, Symtab *n, int (*checkfunc)(Node *n)) {
  Hash *hsym = 0;
  Node *s = 0;
  
  if (!n) {
    hsym = current_symtab;
  } else {
    if (!HashCheckAttr(n,k_nodetype,k_symboltable)) {
      n = HashGetAttr(n,k_symsymtab);
    }
    assert(n);
    if (n) {
      hsym = n;
    }
  }
  
  if (Swig_scopename_check(name)) {
    char *cname = Char(name);
    if (strncmp(cname,"::",2) == 0) {
      String *nname = NewString(cname+2);
      if (Swig_scopename_check(nname)) {
	s = symbol_lookup_qualified(nname,global_scope,0,0,checkfunc);
      }
      Delete(nname);
    } else {
      String *prefix = Swig_scopename_prefix(name);
      if (prefix) {
	s = symbol_lookup_qualified(name,hsym,0,0,checkfunc);
	Delete(prefix);
	if (!s) {
	  return 0;
	}
      }
    }
  }
  if (!s) {
    while (hsym) {
      s = symbol_lookup(name,hsym,checkfunc);
      if (s) break;
      hsym = HashGetAttr(hsym,k_parentnode);
      if (!hsym) break;
    }
  }
  if (!s) {
    return 0;
  }
  /* Check if s is a 'using' node */
  while (s && HashCheckAttr(s,k_nodetype,k_using)) {
    Node *ss;
    ss = Swig_symbol_clookup(HashGetAttr(s,k_uname), HashGetAttr(s,k_symsymtab));
    if (!ss && !checkfunc) {
      Swig_warning(WARN_PARSE_USING_UNDEF, Getfile(s), Getline(s), "Nothing known about '%s'.\n", HashGetAttr(s,k_uname));
    }
    s = ss;
  }
  return s;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_clookup_local()
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_clookup_local(String_or_char *name, Symtab *n) {
  Hash *h, *hsym;
  Node *s = 0;

  if (!n) {
    hsym = current_symtab;
    h = ccurrent;
  } else {
    if (!HashCheckAttr(n,k_nodetype,k_symboltable)) {
      n = HashGetAttr(n,k_symsymtab);
    }
    assert(n);
    hsym = n;
    h = HashGetAttr(n,k_csymtab);
  }

  if (Swig_scopename_check(name)) {
    char *cname = Char(name);
    if (strncmp(cname,"::",2) == 0) {
      String *nname = NewString(cname+2);
      if (Swig_scopename_check(nname)) {
	s = symbol_lookup_qualified(nname,global_scope,0,0,0);
      }
      Delete(nname);
    } else {
      s = symbol_lookup_qualified(name,hsym,0,0,0);
    }
  }
  if (!s) {
    s = symbol_lookup(name,hsym,0);
  }
  if (!s) return 0;
  /* Check if s is a 'using' node */
  while (s && HashCheckAttr(s,k_nodetype,k_using)) {
    Node *ss = Swig_symbol_clookup_local(HashGetAttr(s,k_uname), HashGetAttr(s,k_symsymtab));
    if (!ss) {
      Swig_warning(WARN_PARSE_USING_UNDEF, Getfile(s), Getline(s), "Nothing known about '%s'.\n", HashGetAttr(s,k_uname));
    }
    s = ss;
  }
  return s;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_clookup_local_check()
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_clookup_local_check(String_or_char *name, Symtab *n, int (*checkfunc)(Node *)) {
  Hash *h, *hsym;
  Node *s = 0;

  if (!n) {
    hsym = current_symtab;
    h = ccurrent;
  } else {
    if (!HashCheckAttr(n,k_nodetype,k_symboltable)) {
      n = HashGetAttr(n,k_symsymtab);
    }
    assert(n);
    hsym = n;
    h = HashGetAttr(n,k_csymtab);
  }

  if (Swig_scopename_check(name)) {
    char *cname = Char(name);
    if (strncmp(cname,"::",2) == 0) {
      String *nname = NewString(cname+2);
      if (Swig_scopename_check(nname)) {
	s = symbol_lookup_qualified(nname,global_scope,0,0,checkfunc);
      }
      Delete(nname);
    } else {
      s = symbol_lookup_qualified(name,hsym,0,0,checkfunc);
    }
  }
  if (!s) {
    s = symbol_lookup(name,hsym,checkfunc);
  }
  if (!s) return 0;
  /* Check if s is a 'using' node */
  while (s && HashCheckAttr(s,k_nodetype,k_using)) {
    Node *ss = Swig_symbol_clookup_local_check(HashGetAttr(s,k_uname), HashGetAttr(s,k_symsymtab),checkfunc);
    if (!ss && !checkfunc) {
      Swig_warning(WARN_PARSE_USING_UNDEF, Getfile(s), Getline(s), "Nothing known about '%s'.\n", HashGetAttr(s,k_uname));
    }
    s = ss;
  }
  return s;
}


/* -----------------------------------------------------------------------------
 * Swig_symbol_cscope()
 *
 * Look up a scope name.
 * ----------------------------------------------------------------------------- */

Symtab *
Swig_symbol_cscope(String_or_char *name, Symtab *symtab) {
  char *cname = Char(name);
  if (strncmp(cname,"::",2) == 0) return symbol_lookup_qualified(0, global_scope, name, 0,0);
  return symbol_lookup_qualified(0,symtab,name,0,0);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_remove()
 *
 * Remove a symbol. If the symbol is an overloaded function and the symbol removed
 * is not the last in the list of overloaded functions, then the overloaded
 * names (sym:overname attribute) are changed to start from zero, eg __SWIG_0.
 * ----------------------------------------------------------------------------- */

void
Swig_symbol_remove(Node *n) {
  Symtab  *symtab; 
  String  *symname;
  String  *overname;
  Node    *symprev;
  Node    *symnext;
  Node    *fixovername = 0;
  symtab  = HashGetAttr(n,k_symsymtab);        /* Get symbol table object */
  symtab  = HashGetAttr(symtab,k_symtab);       /* Get actual hash table of symbols */
  symname = HashGetAttr(n,k_symname);
  symprev = HashGetAttr(n,k_sympreviousSibling);
  symnext = HashGetAttr(n,k_symnextSibling);

  /* If previous symbol, just fix the links */
  if (symprev) {
    if (symnext) {
      Setattr(symprev,k_symnextSibling,symnext);
      fixovername = symprev; /* fix as symbol to remove is somewhere in the middle of the linked list */
    } else {
      Delattr(symprev,k_symnextSibling);
    }
  } else {
    /* If no previous symbol, see if there is a next symbol */
    if (symnext) {
      Setattr(symtab,symname,symnext);
      fixovername = symnext; /* fix as symbol to remove is at head of linked list */
    } else {
      Delattr(symtab,symname);
    }
  }
  if (symnext) {
    if (symprev) {
      Setattr(symnext,k_sympreviousSibling,symprev);
    } else {
      Delattr(symnext,k_sympreviousSibling);
    }
  }
  Delattr(n,k_symsymtab);
  Delattr(n,k_sympreviousSibling);
  Delattr(n,k_symnextSibling);
  Delattr(n,k_csymnextSibling);
  Delattr(n,k_symovername);
  Delattr(n,k_csympreviousSibling);
  Delattr(n,k_symoverloaded);
  n = 0;

  if (fixovername) {
    Node *nn = fixovername;
    Node *head = fixovername;
    int pn = 0;

    /* find head of linked list */
    while (nn) {
      head = nn;
      nn = HashGetAttr(nn, k_sympreviousSibling);
    }

    /* adjust all the sym:overname strings to start from 0 and increment by one */
    nn = head;
    while (nn) {
      assert(HashGetAttr(nn,k_symovername));
      Delattr(nn,k_symovername);
      overname = NewStringf("__SWIG_%d", pn);
      Setattr(nn,k_symovername, overname);
      Delete(overname);
      pn++;
      nn = HashGetAttr(nn,k_symnextSibling);
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_qualified()
 *
 * Return the qualified name of a symbol
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_qualified(Node *n) {
  Hash *symtab;
  if (HashCheckAttr(n,k_nodetype,k_symboltable)) {
    symtab = n;
  } else {
    symtab = HashGetAttr(n,k_symsymtab);
  }
  if (!symtab) return NewStringEmpty();
#ifdef SWIG_DEBUG
  Printf(stderr,"symbol_qscope %s %x %s\n", HashGetAttr(n,k_name), symtab,HashGetAttr(symtab,k_name));
#endif
  return Swig_symbol_qualifiedscopename(symtab);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_isoverloaded()
 * 
 * Check if a symbol is overloaded.  Returns the first symbol if so.
 * ----------------------------------------------------------------------------- */

Node *
Swig_symbol_isoverloaded(Node *n) {
  return HashGetAttr(n,k_symoverloaded);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_type_qualify()
 *
 * Create a fully qualified type name
 * ----------------------------------------------------------------------------- */

static int no_constructor(Node *n) {
#ifdef SWIG_DEBUG
  Printf(stderr,"node type %s\n", HashGetAttr(n,k_name), type);
#endif
  return !HashCheckAttr(n, k_nodetype, k_constructor);
}

#define SWIG_TEMPLATE_QUALIFY_CACHE
static SwigType *
Swig_symbol_template_qualify(const SwigType *e, Symtab *st) {
  String *tprefix, *tsuffix;
  SwigType *qprefix;
  List   *targs;
  Node *tempn;
  Symtab *tscope;
  Iterator ti;
#ifdef SWIG_TEMPLATE_QUALIFY_CACHE
  static Hash *qualify_cache = 0;
  String *scopetype = st ? NewStringf("%s::%s",Getattr(st,k_name),e)
    : NewStringf("%s::%s",Swig_symbol_getscopename(),e);
  if (!qualify_cache) {
    qualify_cache = NewHash();
  }
  if (scopetype) {
    String *cres = Getattr(qualify_cache, scopetype);
    if (cres) {
      Delete(scopetype);
      return Copy(cres);
    }  
  }
#endif

  tprefix = SwigType_templateprefix(e);
  tsuffix = SwigType_templatesuffix(e);
  qprefix = Swig_symbol_type_qualify(tprefix,st);
  targs = SwigType_parmlist(e);
  tempn = Swig_symbol_clookup_local(tprefix,st);
  tscope = tempn ? HashGetAttr(tempn,k_symsymtab) : 0;
  StringAppend(qprefix,"<(");
  for (ti = First(targs); ti.item;) {
    String *vparm;
    String *qparm = Swig_symbol_type_qualify(ti.item,st);
    if (tscope && (tscope != st)) {
      String *ty = Swig_symbol_type_qualify(qparm,tscope);
      Delete(qparm);      
      qparm = ty;
    }

    vparm = Swig_symbol_template_param_eval(qparm, st);
    StringAppend(qprefix,vparm);
    ti = Next(ti);
    if (ti.item) {
      StringPutc(',',qprefix);
    }
    Delete(qparm);
    Delete(vparm);
  }
  StringAppend(qprefix,")>");
  StringAppend(qprefix,tsuffix);
  Delete(tprefix);
  Delete(tsuffix);
  Delete(targs);
#ifdef SWIG_DEBUG
  Printf(stderr,"symbol_temp_qual %s %s\n", e, qprefix);
#endif
#ifdef SWIG_TEMPLATE_QUALIFY_CACHE
  Setattr(qualify_cache,scopetype,qprefix);
  Delete(scopetype);
#endif

  return qprefix;
}


SwigType *
Swig_symbol_type_qualify(const SwigType *t, Symtab *st) {
  List   *elements;
  String *result = NewStringEmpty();
  int     i,len;

  elements = SwigType_split(t);

  len = Len(elements);
  for (i = 0; i < len; i++) {
    String *e = Getitem(elements,i);
    if (SwigType_issimple(e)) {
      Node *n = Swig_symbol_clookup_check(e,st,no_constructor);
      if (n) {
	String *name = HashGetAttr(n,k_name);
	Clear(e);
	StringAppend(e,name);
#ifdef SWIG_DEBUG
	Printf(stderr,"symbol_qual_ei %d %s %s %x\n", i, name, e, st);
#endif
	if (!Swig_scopename_check(name)) {
	  String *qname = Swig_symbol_qualified(n);
	  if (qname && StringLen(qname)) {
	    Insert(e,0,k_coloncolon);
	    Insert(e,0,qname);
	  }
#ifdef SWIG_DEBUG
	  Printf(stderr,"symbol_qual_sc %d %s %s %x\n", i, qname, e, st);
#endif
	  Delete(qname);
	}
      } else if (SwigType_istemplate(e)) {
	SwigType *ty = Swig_symbol_template_qualify(e,st);
	Clear(e);
	StringAppend(e,ty);
	Delete(ty);	
      }
      if (strncmp(StringChar(e),"::",2) == 0) {
	Delitem(e,0);
	Delitem(e,0);
      }
      StringAppend(result,e);
    } else if (SwigType_isfunction(e)) {
      List *parms = SwigType_parmlist(e);
      String *s = NewString("f(");
      Iterator pi = First(parms);
      while (pi.item) {
	String *pf = Swig_symbol_type_qualify(pi.item,st);
	StringAppend(s,pf);
	pi = Next(pi);
	if (pi.item) {
	  StringAppend(s,",");
	}
	Delete(pf);
      }
      StringAppend(s,").");
      StringAppend(result,s);
      Delete(parms);
      Delete(s);
    } else {
      StringAppend(result,e);
    }
  }
  Delete(elements);
#ifdef SWIG_DEBUG
  Printf(stderr,"symbol_qualify %s %s %x %s\n", t, result, st, st ?HashGetAttr(st,k_name): 0);
#endif

  return result;
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_typedef_reduce()
 *
 * Chase a typedef through symbol tables looking for a match.
 * ----------------------------------------------------------------------------- */

static 
SwigType *Swig_symbol_template_reduce(SwigType *qt, Symtab *ntab)
{
  Parm *p;
  List *parms = SwigType_parmlist(qt);
  Iterator pi = First(parms);
  String *tprefix = SwigType_templateprefix(qt);
  String *tsuffix = SwigType_templatesuffix(qt);
  String *qprefix = SwigType_typedef_qualified(tprefix);
  StringAppend(qprefix,"<(");
  while ((p = pi.item)) {
    String *np;
    String *tp = Swig_symbol_typedef_reduce(p, ntab);
    String *qp = Swig_symbol_type_qualify(tp, ntab);
    Node *n = Swig_symbol_clookup(qp,ntab);
    if (n) {
      String *qual = Swig_symbol_qualified(n);
      np = Copy(HashGetAttr(n,k_name));
      Delete(tp);
      tp = np;
      if (qual && StringLen(qual)) {
	Insert(np,0,k_coloncolon);
	Insert(np,0,qual);
      }
      Delete(qual);
    } else {
      np = qp;
    }
    StringAppend(qprefix,np);
    pi= Next(pi);
    if (pi.item) {
      StringAppend(qprefix,",");
    }
    Delete(qp);
    Delete(tp);
  }
  StringAppend(qprefix,")>");
  StringAppend(qprefix,tsuffix);
  Delete(parms);  
  Delete(tprefix);  
  Delete(tsuffix);  
  return qprefix;
}


SwigType *Swig_symbol_typedef_reduce(SwigType *ty, Symtab *tab) {
  SwigType *prefix, *base;
  Node *n;
  String *nt;

  base = SwigType_base(ty);
  prefix = SwigType_prefix(ty);

  n = Swig_symbol_clookup(base,tab);
  if (!n) {
    Delete(base);
    if (SwigType_istemplate(ty)) {
      SwigType *qt = Swig_symbol_template_reduce(ty,tab);
      StringAppend(prefix,qt);
      Delete(qt);
#ifdef SWIG_DEBUG
      Printf(stderr,"symbol_reduce %s %s\n", ty, prefix);
#endif
      return prefix;
    } else {
      Delete(prefix);
#ifdef SWIG_DEBUG
      Printf(stderr,"symbol_reduce %s %s\n", ty, ty);
#endif
      return Copy(ty);
    }
  }
  nt = HashGetAttr(n,k_nodetype);
  if (StringEqual(nt,k_using)) {
    String *uname = HashGetAttr(n,k_uname);
    if (uname) {
      n = Swig_symbol_clookup(base,HashGetAttr(n,k_symsymtab));
      if (!n) {
	Delete(base);
	Delete(prefix);
#ifdef SWIG_DEBUG
	Printf(stderr,"symbol_reduce %s %s\n", ty, ty);
#endif
	return Copy(ty);
      }
    } 
  }
  if (StringEqual(nt,k_cdecl)) {
    String *storage = HashGetAttr(n,k_storage);
    if (storage && (StringEqual(storage,k_typedef))) {
      SwigType *decl;
      SwigType *rt;
      SwigType *qt;
      Symtab *ntab;
      SwigType *nt = Copy(HashGetAttr(n,k_type));
      
      /* Fix for case 'typedef struct Hello hello;' */
      {	
	const char* dclass[3] = {"struct ", "union ", "class "};
	int i;
	char * c = StringChar(nt);
	for (i=0; i<3; i++) {
	  if (strstr(c, dclass[i]) == c) {
	    Replace(nt,dclass[i],"", DOH_REPLACE_FIRST); 
	  }
	}
      }
      decl = HashGetAttr(n,k_decl);
      if (decl) {
	SwigType_push(nt,decl);
      }
      SwigType_push(nt,prefix);
      Delete(base);
      Delete(prefix);
      ntab = HashGetAttr(n,k_symsymtab);
      rt = Swig_symbol_typedef_reduce(nt, ntab);
      qt = Swig_symbol_type_qualify(rt, ntab);
      if (SwigType_istemplate(qt)) {
	SwigType *qtr = Swig_symbol_template_reduce(qt,ntab);
	Delete(qt);
	qt = qtr;
      }      
      Delete(nt);
      Delete(rt);
#ifdef SWIG_DEBUG
      Printf(stderr,"symbol_reduce %s %s\n", qt, ty);
#endif
      return qt;
    }
  }
  Delete(base);
  Delete(prefix);
#ifdef SWIG_DEBUG
      Printf(stderr,"symbol_reduce %s %s\n", ty, ty);
#endif
  return Copy(ty);
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_string_qualify()
 *
 * This function takes a string and looks for identifiers.  Identifiers are
 * then qualified according to scope rules.  This function is used in a number
 * of settings including expression evaluation, scoping of conversion operators,
 * and so forth.
 * ----------------------------------------------------------------------------- */

String *
Swig_symbol_string_qualify(String *s, Symtab *st) {
  int have_id = 0;
  String *id = NewStringEmpty();
  String *r = NewStringEmpty();
  char *c = StringChar(s);
  while (*c) {
    if (isalpha((int)*c) || (*c == '_') || (*c == ':')) {
      StringPutc(*c,id);
      have_id = 1;
    } else {
      if (have_id) {
	String *qid = Swig_symbol_type_qualify(id,st);
	StringAppend(r,qid);
	Clear(id);
	Delete(qid);
	have_id = 0;
      }
      StringPutc(*c,r);
    }
    c++;
  }
  if (have_id) {
    String *qid = Swig_symbol_type_qualify(id,st);
    StringAppend(r,qid);
    Delete(qid);
  }
  Delete(id);
  return r;
}


/* -----------------------------------------------------------------------------
 * Swig_symbol_template_defargs()
 *
 * Apply default arg from generic template default args 
 * ----------------------------------------------------------------------------- */


void
Swig_symbol_template_defargs(Parm *parms, Parm *targs, Symtab *tscope, Symtab *tsdecl) {
  if (Len(parms) < Len(targs)) {
    Parm *lp = parms;
    Parm *p = lp;
    Parm *tp = targs;
    while(p && tp) {
      p = nextSibling(p);
      tp = nextSibling(tp);
      if (p) lp = p;
    }
    while (tp) {
      String *value = HashGetAttr(tp,k_value);
      if (value) {
	Parm *cp;
	Parm *ta = targs;
	Parm *p = parms;
	SwigType *nt = Swig_symbol_string_qualify(value,tsdecl);
	SwigType *ntq = 0;
#ifdef SWIG_DEBUG
	Printf(stderr,"value %s %s %s\n",value, nt,tsdecl ? HashGetAttr(tsdecl,k_name) : tsdecl);
#endif
	while(p && ta) {
	  String *name = HashGetAttr(ta,k_name);
	  String *pvalue = HashGetAttr(p,k_value);
	  String *value = pvalue ? pvalue : HashGetAttr(p,k_type);
	  String *ttq = Swig_symbol_type_qualify(value,tscope);
	  /* value = SwigType_typedef_resolve_all(value);*/
	  Replaceid(nt, name, ttq);
	  p = nextSibling(p);
	  ta = nextSibling(ta);
	  Delete(ttq);
	}
	ntq = Swig_symbol_type_qualify(nt,tsdecl);
	if (SwigType_istemplate(ntq)) {
	  String *ty = Swig_symbol_template_deftype(ntq, tscope);
	  Delete(ntq);
	  ntq = ty;
	}
	/* Printf(stderr,"value %s %s %s\n",value,ntr,ntq);*/
	cp = NewParm(ntq,0);
	set_nextSibling(lp,cp);
	lp = cp;
	tp = nextSibling(tp);
	Delete(cp);
	Delete(nt);
	Delete(ntq);
      } else {
	tp = 0;
      }
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_symbol_template_deftype()
 *
 * Apply default args to generic template type
 * ----------------------------------------------------------------------------- */


#define SWIG_TEMPLATE_DEFTYPE_CACHE
SwigType*
Swig_symbol_template_deftype(const SwigType *type, Symtab *tscope) {
  String *result   = NewStringEmpty();
  List   *elements = SwigType_split(type);
  int     len = Len(elements);
  int     i;
#ifdef SWIG_TEMPLATE_DEFTYPE_CACHE
  static Hash *deftype_cache = 0;
  String *scopetype = tscope ? NewStringf("%s::%s",Getattr(tscope,k_name),type)
    : NewStringf("%s::%s",Swig_symbol_getscopename(),type);
  if (!deftype_cache) {
    deftype_cache = NewHash();
  }
  if (scopetype) {
    String *cres = Getattr(deftype_cache, scopetype);
    if (cres) {
      Append(result,cres);
      Delete(scopetype);
      return result;
    }  
  }
#endif

#ifdef SWIG_DEBUG
  Printf(stderr,"finding deftype %s\n", type);
#endif

  for (i = 0; i < len; i++) {
    String *e = Getitem(elements,i);
    if (SwigType_isfunction(e)) {
      String *s = NewString("f(");
      List *parms = SwigType_parmlist(e);
      Iterator pi = First(parms);
      while (pi.item) {
	String *pf = SwigType_istemplate(e) ? 
	  Swig_symbol_template_deftype(pi.item,tscope)
	  : Swig_symbol_type_qualify(pi.item,tscope);
	StringAppend(s,pf);
	pi = Next(pi);
	if (pi.item) {
	  StringAppend(s,",");
	}
	Delete(pf);
      }
      StringAppend(s,").");
      StringAppend(result,s);
      Delete(s);
      Delete(parms);
    } else if (SwigType_istemplate(e)) {
      String *prefix   = SwigType_prefix(e);
      String *base     = SwigType_base(e);
      String *tprefix  = SwigType_templateprefix(base);
      String *targs    = SwigType_templateargs(base);
      String *tsuffix  = SwigType_templatesuffix(base);
      ParmList *tparms = SwigType_function_parms(targs);
      Node *tempn = Swig_symbol_clookup_local(tprefix,tscope);
#ifdef SWIG_DEBUG
      Printf(stderr,"deftype type %s \n", e);
#endif
      if (tempn) {
	ParmList *tnargs = HashGetAttr(tempn,k_templateparms);
	Parm *p;
	Symtab *tsdecl = HashGetAttr(tempn,k_symsymtab);
	
#ifdef SWIG_DEBUG
	Printf(stderr,"deftype type %s %s %s\n", tprefix, targs,tsuffix);
#endif
	StringAppend(tprefix,"<(");
	Swig_symbol_template_defargs(tparms, tnargs,tscope,tsdecl);
	p = tparms;
	tscope = tsdecl;
	while (p) {
	  SwigType *ptype = HashGetAttr(p,k_type);
	  SwigType *ttr = ptype ? ptype : HashGetAttr(p,k_value);
	  SwigType *ttf = Swig_symbol_type_qualify(ttr,tscope);
	  SwigType *ttq = Swig_symbol_template_param_eval(ttf,tscope);
#ifdef SWIG_DEBUG
	  Printf(stderr,"arg type %s\n", ttq);
#endif
	  if (SwigType_istemplate(ttq)) {
	    SwigType *ttd = Swig_symbol_template_deftype(ttq, tscope);
	    Delete(ttq);
	    ttq = ttd;
#ifdef SWIG_DEBUG
	    Printf(stderr,"arg deftype %s\n", ttq);
#endif
	  }	
	  StringAppend(tprefix,ttq);
	  p = nextSibling(p);
	  if (p) StringPutc(',',tprefix);
	  Delete(ttf);
	  Delete(ttq);
	}
	StringAppend(tprefix,")>");
	StringAppend(tprefix,tsuffix);
	StringAppend(prefix,tprefix);
#ifdef SWIG_DEBUG
	Printf(stderr,"deftype %s %s \n", type, tprefix); 
#endif
	StringAppend(result,prefix);
      } else {
	StringAppend(result,e);
      }
      Delete(prefix);
      Delete(base);
      Delete(tprefix);
      Delete(tsuffix);
      Delete(targs);
      Delete(tparms);
    } else {
      StringAppend(result,e);
    }
  }
  Delete(elements);
#ifdef SWIG_TEMPLATE_DEFTYPE_CACHE
  Setattr(deftype_cache,scopetype,result);
  Delete(scopetype);
#endif

  return result;
}

SwigType *Swig_symbol_template_param_eval(const SwigType *p, Symtab *symtab)
{
  String *value = Copy(p);
  Node *lastnode = 0;
  while (1) {
    Node *n = Swig_symbol_clookup(value,symtab);
    if (n == lastnode) break;
    lastnode = n;
    if (n) {
      String *nt = HashGetAttr(n,k_nodetype);
      if (StringEqual(nt,k_enumitem)) {
	/* An enum item.   Generate a fully qualified name */
	String *qn = Swig_symbol_qualified(n);
	if (qn && StringLen(qn)) {
	  StringAppend(qn,k_coloncolon);
	  StringAppend(qn,HashGetAttr(n,k_name));
	  Delete(value);
	  value = qn;
	  continue;
	} else {
	  Delete(qn);
	  break;
	}
      } else if ((StringEqual(nt,k_cdecl))) {
	String *nv = HashGetAttr(n,k_value);
	if (nv) {
	  Delete(value);
	  value = Copy(nv);
	  continue;
	}
      }
    }
    break;
  }
  return value;
}
