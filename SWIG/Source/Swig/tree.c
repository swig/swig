/* ----------------------------------------------------------------------------- 
 * tree.c
 *
 *     This file provides some general purpose functions for manipulating 
 *     parse trees.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include <stdarg.h>
#include <assert.h>

char cvsroot_tree_c[] = "$Header$";

/* -----------------------------------------------------------------------------
 * Swig_print_tags()
 *
 * Dump the tag structure of a parse tree to standard output
 * ----------------------------------------------------------------------------- */

void 
Swig_print_tags(DOH *obj, DOH *root) {
  DOH *croot, *newroot;
  DOH *cobj;

  if (!root) croot = NewString("");
  else croot = root;

  while (obj) {
    Printf(stdout,"%s . %s (%s:%d)\n", croot, nodeType(obj), Getfile(obj), Getline(obj));
    cobj = firstChild(obj);
    if (cobj) {
      newroot = NewStringf("%s . %s",croot,nodeType(obj));
      Swig_print_tags(cobj,newroot);
      Delete(newroot);
    }
    obj = nextSibling(obj);
  }
  if (!root)
    Delete(croot);
}

static int indent_level = 0;

static void print_indent(int l) {
  int i;
  for (i = 0; i < indent_level; i++) {
    fputc(' ', stdout);
  }
  if (l) {
    fputc('|', stdout);
    fputc(' ', stdout);
  }
}


/* -----------------------------------------------------------------------------
 * Swig_dump_node(Node *n)
 * ----------------------------------------------------------------------------- */

void
Swig_print_node(Node *obj) {
  Iterator ki;
  Node   *cobj;
  
  print_indent(0);
  Printf(stdout,"+++ %s ----------------------------------------\n", nodeType(obj));
  ki = First(obj);
  while (ki.key) {
    String *k = ki.key;
    if ((Cmp(k,"nodeType") == 0) || (Cmp(k,"firstChild") == 0) || (Cmp(k,"lastChild") == 0) ||
	(Cmp(k,"parentNode") == 0) || (Cmp(k,"nextSibling") == 0) ||
	(Cmp(k,"previousSibling") == 0) || (*(Char(k)) == '$')) {
      /* Do nothing */
    } else if (Cmp(k,"parms") == 0) {
      print_indent(2);
      Printf(stdout,"%-12s - %s\n", k, ParmList_protostr(Getattr(obj,k)));
    } else {
      DOH *o;
      char *trunc = "";
      print_indent(2);
      if (DohIsString(Getattr(obj,k))) {
	o = Str(Getattr(obj,k));
	if (Len(o) > 40) {
	  trunc = "...";
	}
	Printf(stdout,"%-12s - \"%(escape)-0.40s%s\"\n", k, o, trunc);
	Delete(o);
      } else {
	Printf(stdout,"%-12s - 0x%x\n", k, Getattr(obj,k));
      }
    }
    ki = Next(ki);
  }
  cobj = firstChild(obj);
  if (cobj) {
    indent_level += 6;
    Printf(stdout,"\n");
    Swig_print_tree(cobj);
    indent_level -= 6;
  } else {
    print_indent(1);
    Printf(stdout,"\n");
  }
}

/* -----------------------------------------------------------------------------
 * Swig_print_tree()
 *
 * Dump the tree structure of a parse tree to standard output
 * ----------------------------------------------------------------------------- */

void 
Swig_print_tree(DOH *obj) {
  while (obj) {
    Swig_print_node(obj);
    obj = nextSibling(obj);
  }
}

/* -----------------------------------------------------------------------------
 * appendChild()
 *
 * Appends a new child to a node
 * ----------------------------------------------------------------------------- */

void
appendChild(Node *node, Node *chd) {
  Node *lc;

  if (!chd) return;

  lc = lastChild(node);
  if (!lc) {
    set_firstChild(node,chd);
  } else {
    set_nextSibling(lc,chd);
    set_previousSibling(chd,lc);
  }
  while (chd) {
    lc = chd;
    set_parentNode(chd,node);
    chd = nextSibling(chd);
  }
  set_lastChild(node,lc);
}

/* -----------------------------------------------------------------------------
 * deleteNode()
 *
 * Deletes a node.
 * ----------------------------------------------------------------------------- */

void
deleteNode(Node *n) {
  Node *parent;
  Node *prev;
  Node *next;

  parent = parentNode(n);
  prev = previousSibling(n);
  next = nextSibling(n);
  if (prev) {
    set_nextSibling(prev,next);
  } else {
    if (parent) {
      set_firstChild(parent,next);
    }
  }
  if (next) {
    set_previousSibling(next,prev);
  } else {
    if (parent) {
      set_lastChild(parent,prev);
    }
  }
}

/* -----------------------------------------------------------------------------
 * copyNode()
 *
 * Copies a node, but only copies simple attributes (no lists, hashes).
 * ----------------------------------------------------------------------------- */

Node *
copyNode(Node *n) {
  Iterator ki;
  Node *c = NewHash();
  for (ki = First(n); ki.key; ki = Next(ki)) {
    if (DohIsString(ki.item)) {
      Setattr(c,ki.key,Copy(ki.item));
    }
  }
  Setfile(c,Getfile(n));
  Setline(c,Getline(n));
  return c;
}

/* -----------------------------------------------------------------------------
 * Swig_tag_nodes()
 *
 * Tags a collection of nodes with an attribute.   Used by the parser to mark
 * subtypes with extra information.
 * ----------------------------------------------------------------------------- */

void
Swig_tag_nodes(Node *n, const String_or_char *attrname, DOH *value) {
  while (n) {
    Setattr(n,attrname,value);
    Swig_tag_nodes(firstChild(n),attrname, value);
    n = nextSibling(n);
  }
}

/* -----------------------------------------------------------------------------
 * checkAttribute()
 * ----------------------------------------------------------------------------- */

int
checkAttribute(Node *n, const String_or_char *name, const String_or_char *value) {
  String *v = Getattr(n,name);
  if (!v) return 0;
  if (Equal(v,value)) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_require()
 * ns   - namespace for the view name for saving any attributes under
 * n    - node
 * ...  - list of attribute names of type char*
 * This method checks that the attribute names exist in the node n and asserts if
 * not. Assert will only occur unless the attribute is optional. An attribute is
 * optional if it is prefixed by ?, eg "?value". If the attribute name is prefixed
 * by * or ?, eg "*value" then a copy of the attribute is saved. The saved
 * attributes will be restored on a subsequent call to Swig_restore(). All the 
 * saved attributes are saved in the view namespace (prefixed by ns).
 * This function can be called more than once with different namespaces.
 * ----------------------------------------------------------------------------- */

int 
Swig_require(const char *ns, Node *n, ...) {
  va_list ap;
  char *name;
  DOH *obj;
  char   temp[512];

  va_start(ap, n);
  name = va_arg(ap, char *);
  while (name) {
    int newref = 0;
    int opt = 0;
    if (*name == '*') {
      newref = 1;
      name++;
    } else if (*name == '?') {
      newref = 1;
      opt = 1;
      name++;
    }
    obj = Getattr(n,name);
    if (!opt && !obj) {
      Printf(stderr,"%s:%d. Fatal error (Swig_require).  Missing attribute '%s' in node '%s'.\n", 
	     Getfile(n), Getline(n), name, nodeType(n));
      assert(obj);
    }
    if (!obj) obj = DohNone;
    if (newref) {
      /* Save a copy of the attribute */
      strcpy(temp,ns);
      strcat(temp,":");
      strcat(temp,name);
      Setattr(n,temp,obj);
    } 
    name = va_arg(ap, char *);
  }
  va_end(ap);

  /* Save the view */
  {
    String *view = Getattr(n,"view");
    if (view) {
      if (Strcmp(view,ns) != 0) {
	strcpy(temp,ns);
	strcat(temp,":view");
	Setattr(n,temp,view);
	Setattr(n,"view",ns);
      }
    } else {
      Setattr(n,"view",ns);
    }
  }

  return 1;
}


/* -----------------------------------------------------------------------------
 * Swig_save()
 * Same as Swig_require(), but all attribute names are optional and all attributes
 * are saved, ie behaves as if all the attribute names were prefixed by ?.
 * ----------------------------------------------------------------------------- */

int 
Swig_save(const char *ns, Node *n, ...) {
  va_list ap;
  char *name;
  DOH *obj;
  char temp[512];

  va_start(ap, n);
  name = va_arg(ap, char *);
  while (name) {
    if (*name == '*') {
      name++;
    } else if (*name == '?') {
      name++;
    }
    obj = Getattr(n,name);
    if (!obj) obj = DohNone;

    /* Save a copy of the attribute */
    strcpy(temp,ns);
    strcat(temp,":");
    strcat(temp,name);
    if (Setattr(n,temp,obj)) {
      Printf(stderr,"Swig_save('%s','%s'): Warning, attribute '%s' was already saved.\n", ns, nodeType(n), name);
    }
    name = va_arg(ap, char *);
  }
  va_end(ap);

  /* Save the view */
  {
    String *view = Getattr(n,"view");
    if (view) {
      if (Strcmp(view,ns) != 0) {
	strcpy(temp,ns);
	strcat(temp,":view");
	Setattr(n,temp,view);
	Setattr(n,"view",ns);
      }
    } else {
      Setattr(n,"view",ns);
    }
  }

  return 1;
}

/* -----------------------------------------------------------------------------
 * Swig_restore()
 * Restores attributes saved by a previous call to Swig_require() or Swig_save().
 * ----------------------------------------------------------------------------- */

void 
Swig_restore(Node *n) {
  char  temp[512];
  int   len;
  List  *l;
  String *ns;
  Iterator ki;

  ns = Getattr(n,"view");
  assert(ns);

  l = NewList();

  strcpy(temp,Char(ns));
  strcat(temp,":");
  len = strlen(temp);

  for (ki = First(n); ki.key; ki = Next(ki)) {
    if (Strncmp(temp,ki.key,len) == 0) {
      Append(l,ki.key);
    }
  }
  for (ki = First(l); ki.item; ki = Next(ki)) {
    DOH *obj = Getattr(n,ki.item);
    Setattr(n,Char(ki.item)+len,obj);
    Delattr(n,ki.item);
  }
  Delete(l);
}
