/* ----------------------------------------------------------------------------- 
 * warn.c
 *
 *     SWIG warning framework.  This was added to warn developers about 
 *     deprecated APIs and other features.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2001.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

char cvsroot_warn_c[] = "$Header$";

#include "swig.h"

static Hash *warnings = 0;

/* -----------------------------------------------------------------------------
 * Swig_warn()
 * 
 * Issue a warning
 * ----------------------------------------------------------------------------- */

void
Swig_warn(const char *filename, int line, const char *msg) {
  String *key;
  if (!warnings) {
    warnings = NewHash();
  }
  key = NewStringf("%s:%d", filename,line);
  if (!Getattr(warnings,key)) {
    Printf(stderr,"swig-dev warning:%s:%d:%s\n", filename, line, msg);
    Setattr(warnings,key,key);
  }
  Delete(key);
}

	
		


