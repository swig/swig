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
