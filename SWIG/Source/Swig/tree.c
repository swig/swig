/* ----------------------------------------------------------------------------- 
 * tree.c
 *
 *     This file provides some general purpose functions for walking through
 *     parse trees.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"

static char cvsroot[] = "$Header$";

static DOHHash   *rules = 0;

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
    obj = Getattr(obj,"sibling");
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
Swig_add_rule(DOHString_or_char *name,  int (*action)(DOH *node, void *clientdata))
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
    obj = Getattr(obj,"sibling");
  }
  return 0;
}


 
