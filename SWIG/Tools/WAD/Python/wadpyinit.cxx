/* ----------------------------------------------------------------------------- 
 * wadpyinit.cxx
 *
 *     C++ automatic initializer for Python module.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago.  All rights reserved.
 * ----------------------------------------------------------------------------- */

#include "wad.h"

static char cvs[] = "$Header$";

extern "C" void pywadinit();

/* This hack is used to auto-initialize wad regardless of whether we are
   used as an imported module or as a link-library for another module */
   
class wadinitializer {
public:
  wadinitializer() {
    pywadinit();
  }
};

static wadinitializer wi;


