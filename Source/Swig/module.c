/* ----------------------------------------------------------------------------- 
 * module.c
 *
 *     This file implements the SWIG module system.  Modules are simply 
 *     pieces of code that manipulate tree objects.  Each module is defined
 *     by 4 quantities:
 *  
 *            -  Module name    (used to select the module on the command line)
 *            -  init function  (called with the SWIG command line options).
 *            -  start function (called to launch the module)
 *            -  start tag      (starting tag expected by the module)
 * 
 *     Currently modules must be statically linked with SWIG.  However, it
 *     is anticipated that the module system may eventually support
 *     dynamic loading.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"

#ifdef DYNAMIC_MODULES
#include <dlfcn.h>
#endif

static char cvsroot[] = "$Header$";

struct Module {
  String   *modname;
  int      (*initfunc)(int argc, char **argv);
  DOH      *(*startfunc)(DOH *);
  String   *starttag;
  struct Module *next;
};

static Module *Modules = 0;
static Hash   *LoadedModules = 0;

/* -----------------------------------------------------------------------------
 * Swig_register_module()
 *
 * Register a new module with the system
 * ----------------------------------------------------------------------------- */

void
Swig_register_module(const String_or_char *modname, const String_or_char *starttag,
		     int (*initfunc)(int argc, char **argv),
		     DOH *(*startfunc)(DOH *))
{
  Module *m;
  m = (Module *) malloc(sizeof(Module));
  m->modname = NewString(modname);
  m->starttag = NewString(starttag);
  m->initfunc = initfunc;
  m->startfunc = startfunc;
  m->next = Modules;
  Modules = m;
}

/* ----------------------------------------------------------------------------- 
 * Swig_load_module()
 *
 * Load a module.  Returns the module object.
 * ----------------------------------------------------------------------------- */

Module *
Swig_load_module(const String_or_char *modname) {
  Module *m;
  static int dlcheck = 0;
  m = Modules;

  while (m) {
    if (Cmp(m->modname, modname) == 0) {
      /* Create a new entry in the loaded modules table */
      List *ml;
      if (!LoadedModules) LoadedModules = NewHash();
      ml = Getattr(LoadedModules,m->starttag);
      if (!ml) {
	ml = NewList();
	Setattr(LoadedModules,m->starttag,ml);
      }
      Append(ml,NewVoid(m,0));
      return m;
    }
    m = m->next;
  }
  /* Module is not a built-in module.   See if we can dynamically load it */

#ifdef DYNAMIC_MODULES
  if (dlcheck) return 0;
  {
    DOH *filename;
    void *handle;
    void (*init)(void) = 0;
    char initfunc[256];
    FILE *f;
    filename = NewStringf("./swig%s.so", modname);
    f = Swig_open(filename);
    if (!f) return 0;
    fclose(f);

    Clear(filename);
    Append(filename,Swig_last_file());
    
    sprintf(initfunc,"%smodule",Char(modname));
    handle = dlopen(Char(filename), RTLD_NOW | RTLD_GLOBAL);
    if (!handle) {
      Printf(stdout,"%s\n", dlerror());
      return 0;
    }
    
    init = (void (*)(void)) dlsym(handle,initfunc);
    if (!init) {
      Printf(stdout,"Dynamic module %s doesn't define %s()\n", initfunc);
      return 0;
    }
    (*init)();   /* Register function */
    dlcheck = 1;
    m = Swig_load_module(modname);
    dlcheck = 0;
    return m;
  }
#else
  return 0;
#endif
}

/* -----------------------------------------------------------------------------
 * Swig_init_module()
 * 
 * Initialize a module
 * ----------------------------------------------------------------------------- */

int Swig_init_module(Module *m, int argc, char **argv) {
  return (*m->initfunc)(argc,argv);
}

/* -----------------------------------------------------------------------------
 * Swig_start_module()
 *
 * Start a module
 * ----------------------------------------------------------------------------- */

DOH *
Swig_start_module(Module *m, DOH *obj) {
  return (*m->startfunc)(obj);
}

/* -----------------------------------------------------------------------------
 * Swig_run_modules()
 *
 * Given a tree node. This function tries to run it through all of the loaded
 * modules.  This works by looking at the "tag" attribute of the node and
 * searching for a loaded module that can handle that tag.  If no module can be
 * found, processing stops and an error is generated.
 *
 * If more than one module can work on a given tag, those modules will be
 * executed one after the other.  Caveat: if one of those modules outputs
 * a different type of tree, processing immediately stops.
 * ----------------------------------------------------------------------------- */

DOH *Swig_run_modules(DOH *node) {
  String *tag;
  List   *ml;
  DOH    *newnode;
  String *newtag;
  int     i;

  tag = Getattr(node,"tag");
  if (!tag) {
    Printf(stderr,"Whoa.  No tag attribute on node passed to Swig_module_run.\n");
    exit(EXIT_FAILURE);
  }
  /* Get the set of modules that can respond to this node */
  while (node) {
    if (!LoadedModules) {
      Printf(stderr,"No modules loaded.\n");
      return 0;
    }
    ml = Getattr(LoadedModules,tag);
    if ((!ml) || (Len(ml) == 0)) {
      Printf(stderr,"No module for object '%s'\n", tag);
      return 0;
    }
    newnode = 0;
    newtag = 0;
    for (i = 0; i < Len(ml); i++) {
      Module *m;
      m = (Module *) Data(Getitem(ml,i));
      assert(m);
      newnode = (*m->startfunc)(node);
      if (!newnode) return 0;   /* Done */
      newtag = Getattr(newnode,"tag");
      if (!newtag) {
	Printf(stderr,"Fatal error. Module '%s' returns untagged object.\n", m->modname);
	exit(EXIT_FAILURE);
      }
      if (Cmp(newtag,tag)) break;      /* Tag is different.  Oh well */
    }
    if (Cmp(newtag,tag) == 0) break;   /* Hmmm. The tag is the same but we already did everything */
    node = newnode;
    tag = newtag;
  }
  return 0;
}
 
 
