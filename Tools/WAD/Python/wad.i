%module wad
%{
#include "wad.h"
#include <setjmp.h>
#include <signal.h>

extern jmp_buf Py_cerror;
extern PyObject *Py_cerror_obj;

static PyObject *segfault_exc = 0;
static PyObject *buserror_exc = 0;
static PyObject *abort_exc = 0;

/* Handler function */	
static void handler(int signo, void *clientdata) {
  static char message[65536];
  int  len = 0;
  PyObject *type;
  char *name;

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
  PyErr_SetString(type, message);
}

%}


%init %{
  wad_set_callback(handler);

  wad_set_return("call_builtin", 0);
	
  segfault_exc = PyErr_NewException("exceptions.SegFault", NULL, NULL);
  PyDict_SetItemString(d,"SegFault",segfault_exc);

  buserror_exc = PyErr_NewException("exceptions.BusError", NULL, NULL);
  PyDict_SetItemString(d,"BusError",buserror_exc);

  abort_exc = PyErr_NewException("exceptions.AbortError", NULL, NULL);
  PyDict_SetItemString(d,"AbortError",abort_exc);
  
%}


