/* ----------------------------------------------------------------------------- 
 * init.c
 *
 *     Initialize built-in SWIG modules.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"

extern void testmodule();
extern void pythonmodule();

static void (*modules[])(void) = {
  testmodule,
  pythonmodule,
  0
};

/* ----------------------------------------------------------------------------- 
 * init_modules()
 *
 * ----------------------------------------------------------------------------- */
 
void init_modules() {
  int i = 0;
  while (modules[i]) {
    (*modules[i])();
    i++;
  }
}

int main(int argc, char **argv) {
  init_modules();
  return Swig_main(argc, argv);
}
