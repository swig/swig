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
  WadFrame *f;
  WadFrame *fline = 0;


  printf("python handler.\n");
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

  f = frame;
  /* Find the last exception frame */
  while (!f->last) {
    f= f->next;
  }
  /* Now work backwards */
  f = f->prev;
  while (f) {
    sprintf(temp,"#%-3d 0x%08x in ", f->frameno, f->pc);
    strcat(message,temp);
    strcat(message, f->sym_name ? f->sym_name : "?");
    strcat(message,"(");
    strcat(message,wad_arg_string(f));
    strcat(message,")");
    if (f->loc_srcfile && strlen(f->loc_srcfile)) {
      strcat(message," in '");
      strcat(message, wad_strip_dir(f->loc_srcfile));
      strcat(message,"'");
      if (f->loc_line > 0) {
	sprintf(temp,", line %d", f->loc_line);
	strcat(message,temp);
	{
	  int fd;
	  fd = open(f->loc_srcfile, O_RDONLY);
	  if (fd > 0) {
	    fline = f;
	  } 
	  close(fd);
	}
      }
    } else {
      if (f->loc_objfile && strlen(f->loc_objfile)) {
	strcat(message," from '");
	strcat(message, wad_strip_dir(f->loc_objfile));
	strcat(message,"'");
      }
    }
    strcat(message,"\n");
    f = f->prev;
  }
  if (fline) {
    int first;
    int last;
    char *line, *c;
    int i;
    first = fline->loc_line - 2;
    last  = fline->loc_line + 2;
    if (first < 1) first = 1;
    
    line = wad_load_source(fline->loc_srcfile,first);
    if (line) {
      strcat(message,"\n");
      strcat(message, fline->loc_srcfile);
      sprintf(temp,", line %d\n\n", fline->loc_line);
      strcat(message, temp);
      for (i = first; i <= last; i++) {
	if (i == fline->loc_line) strcat(message," => ");
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
  if (wad_heap_overflow) {
    write(2, "WAD: Heap overflow detected.\n", 30);
    wad_default_callback(signo, frame, ret);
  }

  /* Note: if the heap is blown, there is a very good chance that this
  function will not succeed and we'll dump core.  However, the check
  above should dump a stack trace to stderr just in case we don't make it
  back. */

  PyErr_SetString(type, message);
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


