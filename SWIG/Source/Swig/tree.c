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

static char cvsroot[] = "$Header$";

/* -----------------------------------------------------------------------------
 * Swig_dump_tags()
 *
 * Dump the tag structure of a parse tree to standard output
 * ----------------------------------------------------------------------------- */

void 
Swig_dump_tags(DOH *obj, DOH *root) {
  DOH *croot, *newroot;
  DOH *cobj;

  if (!root) croot = NewString("");
  else croot = root;

  while (obj) {
    Printf(stdout,"%s . %s (%s:%d)\n", croot, nodeType(obj), Getfile(obj), Getline(obj));
    cobj = firstChild(obj);
    if (cobj) {
      newroot = NewStringf("%s . %s",croot,nodeType(obj));
      Swig_dump_tags(cobj,newroot);
      Delete(newroot);
    }
    obj = nextSibling(obj);
  }
  if (!root)
    Delete(croot);
}


/* -----------------------------------------------------------------------------
 * Swig_dump_tree()
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

void 
Swig_dump_tree(DOH *obj) {
  DOH *k;
  DOH *cobj;

  while (obj) {
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
      Swig_dump_tree(cobj);
      indent_level -= 6;
    } else {
      print_indent(1);
      Printf(stdout,"\n");
    }
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
 * Swig_require()
 * ----------------------------------------------------------------------------- */


static List  *attr_stack = 0;
static int    stackp = 0;
#define MAX_SWIG_STACK 64

int 
Swig_require(Node *n, ...) {
  va_list ap;
  char *name;
  DOH *obj;
  DOH *frame = 0;
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
      if (!attr_stack) {
	int i;
	attr_stack = NewList();
	for (i = 0; i < MAX_SWIG_STACK; i++)
	  Append(attr_stack,NewHash());
      }
      if (!frame) {
	frame = Getitem(attr_stack,stackp);
      }
      Setattr(frame,name,obj);
    } 
    name = va_arg(ap, char *);
  }
  va_end(ap);
  if (frame) stackp++;
  return 1;
}


int 
Swig_save(Node *n, ...) {
  va_list ap;
  char *name;
  DOH *obj;
  DOH *frame = Getitem(attr_stack,stackp-1);
  va_start(ap, n);
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
    Setattr(frame,name,obj);
    name = va_arg(ap, char *);
  }
  va_end(ap);
  return 1;
}


void 
Swig_restore(Node *n) {
  String *key;
  Hash   *frame;
  assert(attr_stack && (stackp > 0));
  frame = Getitem(attr_stack,stackp-1);
  for (key = Firstkey(frame); key; key = Nextkey(frame)) {
    DOH *obj = Getattr(frame,key);
    if (obj != DohNone) {
      Setattr(n,key,obj);
    } else {
      Delattr(n,key);
    }
    Delattr(frame,key);
  }
  stackp--;
}
