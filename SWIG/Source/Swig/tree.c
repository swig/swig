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

/* -----------------------------------------------------------------------------
 * Swig_print_tree()
 *
 * Dump the tree structure of a parse tree to standard output
 * ----------------------------------------------------------------------------- */

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
  String *k;
  Node   *cobj;
  
  print_indent(0);
  Printf(stdout,"+++ %s ----------------------------------------\n", nodeType(obj));
  k = Firstkey(obj);
  while (k) {
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
    k = Nextkey(obj);
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
  String *key;
  DOH *v;
  Node *c = NewHash();
  for (key = Firstkey(n); key; key = Nextkey(n)) {
    v = Getattr(n,key);
    if (DohIsString(v)) {
      Setattr(c,key,Copy(v));
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

int
checkAttribute(Node *n, const String_or_char *name, const String_or_char *value) {
  String *v;
  v = Getattr(n,name);
  if (!v) return 0;
  if (Cmp(v,value) == 0) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_require()
 * ----------------------------------------------------------------------------- */

#define MAX_SWIG_STACK 256
static Hash    *attr_stack[MAX_SWIG_STACK];
static Node   **nodeptr_stack[MAX_SWIG_STACK];
static Node    *node_stack[MAX_SWIG_STACK];
static int      stackp = 0;
static int      stack_direction = 0;

static void set_direction(int n, int *x) {
  if (n == 1) {
    set_direction(0,&n);
  } else {
    if (&n < x) {
      stack_direction = -1;   /* Stack grows down */
    } else {
      stack_direction = 1;    /* Stack grows up */
    }
  }
}

int 
Swig_require(Node **nptr, ...) {
  va_list ap;
  char *name;
  DOH *obj;
  DOH *frame = 0;
  Node *n = *nptr;
  va_start(ap, nptr);
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
      if (!attr_stack[stackp]) {
	attr_stack[stackp]= NewHash();
      }
      frame = attr_stack[stackp];
      if (Setattr(frame,name,obj)) {
	Printf(stderr,"Swig_require('%s'): Warning, attribute '%s' was already saved.\n", nodeType(n), name);
      }
    } 
    name = va_arg(ap, char *);
  }
  va_end(ap);
  if (frame) {
    /* This is a sanity check to make sure no one is saving data, but not restoring it */
    if (stackp > 0) {
      int e = 0;
      if (!stack_direction) set_direction(1,0);
      
      if (stack_direction < 0) {
	if ((((char *) nptr) >= ((char *) nodeptr_stack[stackp-1])) && (n != node_stack[stackp-1])) e = 1;
      } else {
	if ((((char *) nptr) <= ((char *) nodeptr_stack[stackp-1])) && (n != node_stack[stackp-1])) e = 1;
      }
      if (e) {
	Printf(stderr,
"Swig_require('%s'): Fatal memory management error.  If you are seeing this\n\
message. It means that the target language module is not managing its memory\n\
correctly.  A handler for '%s' probably forgot to call Swig_restore().\n\
Please report this problem to swig-dev@cs.uchicago.edu.\n", nodeType(n), nodeType(node_stack[stackp-1]));
	assert(0);
      }
    }
    nodeptr_stack[stackp] = nptr;
    node_stack[stackp] = n;
    stackp++;
  }
  return 1;
}


int 
Swig_save(Node **nptr, ...) {
  va_list ap;
  char *name;
  DOH *obj;
  DOH *frame;
  Node *n = *nptr;

  if ((stackp > 0) && (nodeptr_stack[stackp-1] == nptr)) {
      frame = attr_stack[stackp-1];
  } else {
    if (stackp > 0) {
      int e = 0;
      if (!stack_direction) set_direction(1,0);
      if (stack_direction < 0) {
	if ((((char *) nptr) >= ((char *) nodeptr_stack[stackp-1])) && (n != node_stack[stackp-1])) e = 1;
      } else {
	if ((((char *) nptr) <= ((char *) nodeptr_stack[stackp-1])) && (n != node_stack[stackp-1])) e = 1;
      }
      if (e) {
	Printf(stderr,
"Swig_save('%s'): Fatal memory management error.  If you are seeing this\n\
message. It means that the target language module is not managing its memory\n\
correctly.  A handler for '%s' probably forgot to call Swig_restore().\n\
Please report this problem to swig-dev@cs.uchicago.edu.\n", nodeType(n), nodeType(node_stack[stackp-1]));
	assert(0);
      }
    }
    attr_stack[stackp] = NewHash();
    nodeptr_stack[stackp] = nptr;
    node_stack[stackp] = n;
    frame = attr_stack[stackp];
    stackp++;
  }
  va_start(ap, nptr);
  name = va_arg(ap, char *);
  while (name) {
    if (*name == '*') {
      name++;
    } else if (*name == '?') {
      name++;
    }
    obj = Getattr(n,name);
    if (!obj) {
      obj = DohNone;
    }
    if (Setattr(frame,name,obj)) {
      Printf(stderr,"Swig_save('%s'): Warning, attribute '%s' was already saved.\n", nodeType(n), name);
    }
    name = va_arg(ap, char *);
  }
  va_end(ap);
  return 1;
}

void 
Swig_restore(Node **nptr) {
  String *key;
  Hash   *frame;
  Node   *n = *nptr;
  assert(stackp > 0);
  if (!(nptr==nodeptr_stack[stackp-1])) {
	Printf(stderr,
"Swig_restore('%s'): Fatal memory management error.  If you are seeing this\n\
message. It means that the target language module is not managing its memory\n\
correctly.  A handler for '%s' probably forgot to call Swig_restore().\n\
Please report this problem to swig-dev@cs.uchicago.edu.\n", nodeType(n), nodeType(node_stack[stackp-1]));
    assert(0);
  }
  stackp--;
  frame = attr_stack[stackp];
  nodeptr_stack[stackp] = 0;
  node_stack[stackp] = 0;
  for (key = Firstkey(frame); key; key = Nextkey(frame)) {
    DOH *obj = Getattr(frame,key);
    if (obj != DohNone) {
      Setattr(n,key,obj);
    } else {
      Delattr(n,key);
    }
    Delattr(frame,key);
  }
}
