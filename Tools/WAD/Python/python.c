/* ----------------------------------------------------------------------------- 
 * python.c
 *
 *     Dynamically loadable python module for wad.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago. 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * See the file COPYING for a complete copy of the LGPL.
 * ----------------------------------------------------------------------------- */

#include "Python.h"
#include "wad.h"

static char cvs[] = "$Id$";

/* These are the python exception objects we will add
   SegFault, BusError, AbortError */

static PyObject *segfault_exc = 0;
static PyObject *buserror_exc = 0;
static PyObject *abort_exc = 0;
static PyObject *illegal_exc = 0;

extern PyObject *new_wadobject(WadFrame *f,int);

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
  char     *srcstr = 0;

  /*  printf("python handler.\n"); */
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

#ifdef OLD
  f = frame;
  /* Find the last exception frame */
  while (!f->last) {
    f= f->next;
  }
  /* Now work backwards */
  f = f->prev;
  while (f) {
    strcat(message, f->debug_str);
    if (f->debug_srcstr) srcstr = f->debug_srcstr;
    f = f->prev;
  }
  if (srcstr) {
    strcat(message,"\n");
    strcat(message, srcstr);
    strcat(message,"\n");
  }
#endif

  if (wad_heap_overflow) {
    write(2, "WAD: Heap overflow detected.\n", 30);
    wad_default_callback(signo, frame, ret);
  }

  /* Note: if the heap is blown, there is a very good chance that this
  function will not succeed and we'll dump core.  However, the check
  above should dump a stack trace to stderr just in case we don't make it
  back. */

#ifdef OLD
  PyErr_SetString(type, message);
#endif
  PyErr_SetObject(type, new_wadobject(frame,0));

}

void pywadinit() {
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

static PyMethodDef wadmethods[] = {
  {0,0},
};

void initlibwadpy() {
  Py_InitModule((char *)"libwadpy",wadmethods);
}


