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
    Printf(stdout,"%s . %s (%s:%d)\n", croot, Getattr(obj,"tag"), Getfile(obj), Getline(obj));
    cobj = firstChild(obj);
    if (cobj) {
      newroot = NewStringf("%s . %s",croot,Getattr(obj,"tag"));
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
    Printf(stdout,"+++ %s ----------------------------------------\n", Getattr(obj,"tag"));
      
    k = Firstkey(obj);
    while (k) {
      if ((Cmp(k,"tag") == 0) || (Cmp(k,"firstChild") == 0) || (Cmp(k,"lastChild") == 0) ||
	  (Cmp(k,"parentNode") == 0) || (Cmp(k,"nextSibling") == 0) ||
	  (Cmp(k,"previousSibling") == 0) || (Cmp(k,"symtab") == 0) || (*(Char(k)) == '$')) {
	/* Do nothing */
      } else if (Cmp(k,"parms") == 0) {
	print_indent(2);
	Printf(stdout,"%-12s - %s\n", k, ParmList_protostr(Getattr(obj,k)));
      } else {
	DOH *o;
	char *trunc = "";
	print_indent(2);
	o = Str(Getattr(obj,k));
	if (Len(o) > 40) {
	  trunc = "...";
	}
	Printf(stdout,"%-12s - \"%(escape)-0.40s%s\"\n", k, o, trunc);
	Delete(o);
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
  Node *c;
  Node *pc;
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

  



