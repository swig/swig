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

extern void inputmodule();
extern void preprocessormodule();
extern void cparsemodule();
extern void swig11module();

static void (*modules[])(void) = {
  inputmodule,
  preprocessormodule,
  cparsemodule,
  swig11module,
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

/* This array contains the names of modules that should be loaded by default */
static char *default_modules[] = {
  "input",
  "preprocessor",
  "cparse",
  0
};

int main(int argc, char **argv) {
  init_modules();
  return Swig_main(argc, argv, default_modules);
}

