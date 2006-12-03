/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * module.cxx
 *
 * This file is responsible for the module system.  
 * ----------------------------------------------------------------------------- */

char cvsroot_module_cxx[] = "$Header$";

#include "swigmod.h"

struct Module {
  ModuleFactory fac;
  char *name;
  Module *next;
   Module(const char *n, ModuleFactory f) {
    fac = f;
    name = new char[strlen(n) + 1];
     strcpy(name, n);
     next = 0;
  } ~Module() {
    delete[]name;
  }
};

static Module *modules = 0;

/* -----------------------------------------------------------------------------
 * void Swig_register_module()
 *
 * Register a module.
 * ----------------------------------------------------------------------------- */

void Swig_register_module(const char *n, ModuleFactory f) {
  Module *m = new Module(n, f);
  m->next = modules;
  modules = m;
}

/* -----------------------------------------------------------------------------
 * Language *Swig_find_module()
 *
 * Given a command line option, locates the factory function.
 * ----------------------------------------------------------------------------- */

ModuleFactory Swig_find_module(const char *name) {
  Module *m = modules;
  while (m) {
    if (strcmp(m->name, name) == 0) {
      return m->fac;
    }
    m = m->next;
  }
  return 0;
}
