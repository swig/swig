/* ----------------------------------------------------------------------------- 
 * fragment.c
 *
 *     This file manages named code fragments.  Code fragments are typically
 *     used to hold helper-code that may or may not be included in the wrapper
 *     file (depending on what features are actually used in the interface).
 *
 *     By using fragments, it's possible to greatly reduce the amount of
 *     wrapper code and to generate cleaner wrapper files. 
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

char cvsroot_fragment_c[] = "$Header$";

#include "swig.h"

static Hash *fragments = 0;

/* -----------------------------------------------------------------------------
 * Swig_fragment_register()
 *
 * Add a fragment. Use the original Node*, so, if something needs to be
 * changed, lang.cxx doesn't nedd to be touched again.
 * ----------------------------------------------------------------------------- */

void
Swig_fragment_register(Node* fragment) {
  String *name = Getattr(fragment,"name");
  String *section = Getattr(fragment,"section");
  String *ccode = Copy(Getattr(fragment,"code"));
  Hash *kwargs = Getattr(fragment,"kwargs");
  if (!fragments) {
    fragments = NewHash();
  }
  Setmeta(ccode,"section",Copy(section));
  if (kwargs) Setmeta(ccode,"kwargs",Copy(kwargs));
  Setattr(fragments,Copy(name),ccode);
}

/* -----------------------------------------------------------------------------
 * Swig_fragment_emit()
 *
 * Emit a fragment
 * ----------------------------------------------------------------------------- */

void
Swig_fragment_emit(String *name) {
  String *code;
  if (!fragments) return;
  
  code = Getattr(fragments,name);
  if (code) {
    String *section = Getmeta(code,"section");
    Hash *n = Getmeta(code,"kwargs");
    while (n) {
      if (Cmp(Getattr(n,"name"),"fragment") == 0) {
	Swig_fragment_emit(Getattr(n,"value"));
      }
      n = nextSibling(n);
    }
    if (section) {
      File *f = Swig_filebyname(section);
      if (!f) {
	Swig_error(Getfile(code),Getline(code),"Bad section '%s' for code fragment '%s'\n", section,name);
      } else {
	Printf(f,"%s\n",code);
      }
    }
    Delattr(fragments,name);
  }
}
