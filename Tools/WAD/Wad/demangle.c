/* ----------------------------------------------------------------------------- 
 * demangle.c
 *
 *     This file performs C++ partial name demangling to the extent that it 
 *     seems reasonable.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"

static char cvs[] = "$Header$";

char *wad_cplus_demangle(WadSymbol *ws) {
  static char buffer[4096];
  strcpy(buffer,ws->name);
  return buffer;
}
