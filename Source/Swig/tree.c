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

static Hash   *rules = 0;

/* -----------------------------------------------------------------------------
 * Swig_next()
 * Swig_prev()
 *
 * Return next/prev node in a parse tree
 * ----------------------------------------------------------------------------- */

DOH *Swig_next(DOH *obj) {
  return Getattr(obj,"next");
}

DOH *Swig_prev(DOH *obj) {
  return Getattr(obj,"prev");
}

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
    Printf(stdout,"%s.%s\n", croot, Getattr(obj,"tag"));
    cobj = Getattr(obj,"child");
    if (cobj) {
      newroot = NewStringf("%s.%s",croot,Getattr(obj,"tag"));
      Swig_dump_tags(cobj,newroot);
      Delete(newroot);
    }
    obj = Swig_next(obj);
  }
  if (!root)
    Delete(croot);
}

/* -----------------------------------------------------------------------------
 * Swig_add_rule()
 *
 * Adds a new rule to the tree walking code.
 * ----------------------------------------------------------------------------- */

void
Swig_add_rule(String_or_char *name,  int (*action)(DOH *node, void *clientdata))
{
  if (!rules) rules = NewHash();
  if (action)
    Setattr(rules,name,NewVoid((void *) action,0));
  else
    Delattr(rules,name);
}

/* -----------------------------------------------------------------------------
 * Swig_add_rules()
 *
 * Add a complete set of rules to the rule system
 * ----------------------------------------------------------------------------- */

void
Swig_add_rules(SwigRule ruleset[]) {
  int i = 0;
  while (ruleset[i].name) {
    Swig_add_rule(ruleset[i].name, ruleset[i].action);
    i++;
  }
}

/* -----------------------------------------------------------------------------
 * Swig_clear_rules()
 *
 * Clears all of the existing rules
 * ----------------------------------------------------------------------------- */

void
Swig_clear_rules()
{
  if (rules) Delete(rules);
  rules = NewHash();
}

/* -----------------------------------------------------------------------------
 * int Swig_emit()
 *
 * Emit an action for a specific object
 * ----------------------------------------------------------------------------- */

int
Swig_emit(DOH *obj, void *clientdata) {
  DOH *tag;
  DOH *actionobj;
  int (*action)(DOH *obj, void *clientdata);

  int  ret;

  assert(obj);

  if (!rules) return -1;
  while (obj) {
    tag = Getattr(obj,"tag");
    actionobj = Getattr(rules,tag);
    if (actionobj) {
      action = (int (*)(DOH *, void *)) Data(actionobj);
      ret = (*action)(obj,clientdata);
      if (ret < 0) return -1;
    } else {
      Printf(stderr,"warning: no action defined for '%s'\n", tag);
    }
    obj = Swig_next(obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_cut_node(DOH *obj)
 *
 * This function cuts an object out of a parse tree.  To do this, the object
 * MUST be properly initialized with "next", "prev", and "parent" attributes.
 * ----------------------------------------------------------------------------- */

void Swig_cut_node(DOH *obj) {
  DOH *parent;
  DOH *next;
  DOH *prev;

  parent = Getattr(obj,"parent");
  assert(parent);
  next = Getattr(obj,"next");
  prev = Getattr(obj,"prev");

  DohIncref(obj);            /* Make sure object doesn't go away */
  Delattr(obj,"parent");     /* Disassociate from my parent */

  if (!next && !prev) {
    /* Well, this is a single child.  Guess we'll just update the parent their child is gone */
    Delattr(parent,"child");
    return;
  }

  /* If no next node, then this must be at the end of a list */
  if (!next) {
    Delattr(prev,"next");      /* Break the 'next' link in the previous node */
    Delattr(obj,"prev");       /* Break my link back to the previous object */
    return;
  }

  /* No previous node. This must be the beginning of a list */
  if (!prev) {
    Delattr(next,"prev");          /* Break the 'prev' link of the next node */
    Setattr(parent,"child",next);  /* Update parent to point at next node */
    Delattr(obj,"next");           /* Break my link to the next object */
    return;
  }

  /* In the middle of a list someplace */
  Setattr(prev,"next",next);       /* Update previous node to my next node */
  Setattr(next,"prev",prev);       /* Update next node to my previous node */
  Delattr(obj,"next");
  Delattr(obj,"prev");             
  return;
}






