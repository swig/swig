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
static PyObject *illegal_exc = 0;

/* Function return points and values */

static WadReturnFunc retpts[] = {
  {"call_builtin", 0},
  {"_PyImport_LoadDynamicModule", 0},
  {"PyEval_EvalCode", 0},
  {"PyObject_GetAttrString", 0},
  {"PyObject_SetAttrString", -1},
  {"PyObject_Repr", 0},
  {"PyObject_Print", -1},
  {"PyObject_CallFunction", 0},
  {"PyObject_CallMethod", 0},
  {"PyObject_CallObject", 0},
  {"PyObject_Cmp", -1},
  {"PyObject_Compare", -1},
  {"PyObject_DelAttrString",-1},
  {"PyObject_DelItem",-1},
  {"PyObject_GetItem",0},
  {"PyObject_SetItem",-1},
  {"PyObject_HasAttrString",-1},
  {"PyObject_Hash",-1},
  {"PyObject_Length",-1},
  {"PyObject_Str",0},
  {"PyObject_Type", 0},

  {"PyNumber_Absolute", 0},
  {"PyNumber_Add",0},
  {"PyNumber_And",0},
  {"PyNumber_Coerce",0},
  {"PyNumber_Divide",0},
  {"PyNumber_Divmod",0},
  {"PyNumber_Float",0},
  {"PyNumber_Int",0},
  {"PyNumber_Invert",0},
  {"PyNumber_Long",0},
  {"PyNumber_Lshift",0},
  {"PyNumber_Multiply", 0},
  {"PyNumber_Negative", 0},
  {"PyNumber_Or",0},
  {"PyNumber_Positive", 0},
  {"PyNumber_Power",0},
  {"PyNumber_Remainder",0},
  {"PyNumber_Rshift",0},
  {"PyNumber_Subtract",0},
  {"PyNumber_Xor",0},

  {"PySequence_Concat",0},
  {"PySequence_Count",-1},
  {"PySequence_Delitem",-1},
  {"PySequence_DelSlice",-1},
  {"PySequence_Getitem",0},
  {"PySequence_GetSlice",0},
  {"PySequence_In",-1},
  {"PySequence_Index",-1},
  {"PySequence_Repeat",0},
  {"PySequence_SetItem",-1},
  {"PySequence_SetSlice",-1},
  {"PySequence_Tuple",0},

  {"PyMapping_Clear",-1},
  {"PyMapping_DelItem",-1},
  {"PyMapping_DelItemString",-1},
  {"PyMapping_GetItemString",0},
  {"PyMapping_HasKey",-1},
  {"PyMapping_HasKeyString",-1},
  {"PyMapping_Items",0},
  {"PyMapping_Keys",0},
  {"PyMapping_Length", -1},
  {"PyMapping_SetItemString", -1},
  {"PyMapping_Values", 0},
  {"",0}};

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
  case SIGFPE:
    type = PyExc_FloatingPointError;
    break;
  case SIGILL:
    type = illegal_exc;
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

  illegal_exc = PyErr_NewException((char *)"exceptions.IllegalInstruction", NULL, NULL);
  PyDict_SetItemString(d,(char *)"IllegalInstruction",illegal_exc);  

  wad_init();
  wad_set_callback(handler);
  wad_set_returns(retpts);
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
void initlibwadpy() {
  Py_InitModule((char *)"libwadpy",wadmethods);
}
