/* ----------------------------------------------------------------------------- 
 * wadpy.cxx
 *
 *     Dynamically loadable python module for wad.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "Python.h"
#include "wad.h"
#include <signal.h>

/* These are the python exception objects we will add
   SegFault, BusError, AbortError */

static PyObject *segfault_exc = 0;
static PyObject *buserror_exc = 0;
static PyObject *abort_exc = 0;

/* Handler function */	
static void handler(int signo, WadFrame *frame, char *ret) {
  static char message[65536];
  static char temp[1024];
  int  len = 0;
  PyObject *type;
  char *name;
  char *fd;
  WadFrame *f;
  WadFrame *fline = 0;

  if (!ret) {
    wad_default_callback(signo, frame, ret);
    return;
  }

  strcpy(message,"[ C stack trace ]\n\n");
  switch(signo) {
  case SIGSEGV:
    type = segfault_exc;
    break;
  case SIGBUS:
    type = buserror_exc;
    break;
  case SIGABRT:
    type = abort_exc;
    break;
  default:
    type = PyExc_RuntimeError;
    break;
  }
  fd = (char *) frame;
  f = (WadFrame *) fd;

  /* Find the last exception frame */
  while (!f->last) {
    fd = fd + f->size;
    f = (WadFrame *) fd;
  }
  /* Now work backwards */
  fd = fd - f->lastsize;
  f = (WadFrame *) fd;
  while (1) {
    sprintf(temp,"#%-3d 0x%08x in ", f->frameno, f->pc);
    strcat(message,temp);
    strcat(message,*(fd + f->sym_off) ? fd+f->sym_off : "?");
    strcat(message,"(");
    strcat(message,wad_arg_string(f));
    strcat(message,")");
    if (strlen(SRCFILE(f))) {
      strcat(message," in '");
      strcat(message, wad_strip_dir(SRCFILE(f)));
      strcat(message,"'");
      if (f->line_number > 0) {
	sprintf(temp,", line %d", f->line_number);
	strcat(message,temp);
	fline = f;
      }
    } else {
      if (strlen(fd+f->obj_off)) {
	strcat(message," from '");
	strcat(message, wad_strip_dir(OBJFILE(f)));
	strcat(message,"'");
      }
    }
    strcat(message,"\n");
    if (!f->lastsize) break;
    fd = fd - f->lastsize;
    f = (WadFrame *) fd;
  }
  if (fline) {
    int first;
    int last;
    char *line, *c;
    int i;
    first = fline->line_number - 2;
    last  = fline->line_number + 2;
    if (first < 1) first = 1;
    
    line = wad_load_source(SRCFILE(fline),first);
    if (line) {
      strcat(message,"\n");
      strcat(message, SRCFILE(fline));
      sprintf(temp,", line %d\n\n", fline->line_number);
      strcat(message, temp);
      for (i = first; i <= last; i++) {
	if (i == fline->line_number) strcat(message," => ");
	else                         strcat(message,"    ");
	c = strchr(line,'\n');
	if (c) {
	  *c = 0;
	  strcat(message,line);
	  strcat(message,"\n");
	  *c = '\n';
	} else {
	  strcat(message,line);
	  strcat(message,"\n");
	  break;
	}
	line = c+1;
      }
      wad_release_source();
      strcat(message,"\n");
    }
  }
  PyErr_SetString(type, message);
  wad_release_trace();
}

static void pywadinit() {
  PyObject *d, *m;
  m = PyImport_ImportModule((char *)"__builtin__");
  d = PyModule_GetDict(m);
  printf("WAD Enabled\n");

  segfault_exc = PyErr_NewException((char *)"exceptions.SegFault", NULL, NULL);
  PyDict_SetItemString(d,(char *)"SegFault",segfault_exc);

  buserror_exc = PyErr_NewException((char *)"exceptions.BusError", NULL, NULL);
  PyDict_SetItemString(d,(char *)"BusError",buserror_exc);

  abort_exc = PyErr_NewException((char*)"exceptions.AbortError", NULL, NULL);
  PyDict_SetItemString(d,(char *)"AbortError",abort_exc);

  wad_init();
  wad_set_callback(handler);
  wad_set_return((char *)"call_builtin",0);
  wad_set_return((char *)"_PyImport_LoadDynamicModule",0);
  wad_set_return((char *)"PyEval_EvalCode",0);
  wad_set_return((char *)"PyObject_GetAttr",0);
}

/* This hack is used to auto-initialize wad regardless of whether we are
   used as an imported module or as a link-library for another module */
   
class wadinitializer {
public:
  wadinitializer() {
    pywadinit();
  }
};

static wadinitializer wi;

static PyMethodDef wadmethods[] = {
  {0,0},
};

extern "C"
void initwad() {
  Py_InitModule((char *)"wad",wadmethods);
}
