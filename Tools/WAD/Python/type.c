/* ----------------------------------------------------------------------------- 
 * type.c
 *
 *     This file defines a new python type that contains information from
 *     the WAD stack trace.
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


#include "wad.h"
#include "Python.h"

static char cvs[] = "$Id$";

typedef struct {
  PyObject_HEAD
  WadFrame   *frame;       /* Wad Stack frame object   */
  int         count;       /* Number of frames         */
} wadobject;

staticforward PyTypeObject WadObjectType;


PyObject *
new_wadobject(WadFrame *f, int count) {
  wadobject   *self;
  self = PyObject_NEW(wadobject, &WadObjectType);
  if (self == NULL) return NULL;
  
  self->frame = f;
  if (count > 0) {
    self->count = count;
  } else {
    self->count = 0;
    while (f) {
      self->count++;
      f = f->next;
    }
  }
  return (PyObject *) self;
}

/* release a wad object */
static void
wadobject_dealloc(wadobject *self) {
  PyMem_DEL(self);
}

static char message[65536];
static PyObject *
wadobject_repr(wadobject *self) {
  char *srcstr = 0;
  WadFrame *fp = 0;
  int    n;
  WadFrame *f = self->frame;

  message[0] = 0;
  /* Find the last exception frame */
  n = self->count;
  while (f && n) {
    fp = f;
    f= f->next;
    n--;
  }

  if (fp) {
  /* Now work backwards */
    f = fp;
    while (f) {
      strcat(message, f->debug_str);
      if (f->debug_srcstr) srcstr = f->debug_srcstr;
      if (f == self->frame) break;
      f = f->prev;
    }
    if (srcstr) {
      strcat(message,"\n");
      strcat(message, srcstr);
      strcat(message,"\n");
    }
  }
  return PyString_FromString(message);
}

static PyObject *
wadobject_str(wadobject *self) {
  char *srcstr = 0;
  int   n;

  WadFrame *f = self->frame;
  n = self->count;
  strcpy(message,"[ C stack trace ]\n\n");
  /* Find the last exception frame */
  while (!f->last && n) {
    f= f->next;
    n--;
  }
  /* Now work backwards */
  if (n <= 0) {
    f = f->prev;
  }
  while (f) {
    strcat(message, f->debug_str);
    if (f->debug_srcstr) srcstr = f->debug_srcstr;
    if (self->frame == f) break;
    f = f->prev;
  }
  if (srcstr) {
    strcat(message,"\n");
    strcat(message, srcstr);
    strcat(message,"\n");
  }
  return PyString_FromString(message);
}

static int
wadobject_len(wadobject *self) {
  int n = 0;
  WadFrame *f = self->frame;
  while (f) {
    n++;
    f = f->next;
  }
  return n;
}

static PyObject *
wadobject_getitem(wadobject *self, int n) {
  int i;
  WadFrame *f;
  if (n < 0) {
    n = self->count + n;
  }
  if ((n < 0) || (n >= self->count)) {
    PyErr_SetString(PyExc_IndexError,"Stack frame out of range");
    return NULL;
  }
  f = self->frame;
  for (i = 0; i <n; i++) {
    f = f->next;
  }
  return new_wadobject(f,1);
}

static PyObject *
wadobject_getslice(wadobject *self, int start, int end) {
  int i;
  WadFrame *f;

  f = self->frame;
  for (i = 0; i < start; i++) {
    f = f->next;
  }
  return new_wadobject(f,(end-start));
}

static PyObject *
wadobject_getattr(wadobject *self, char *name) {
  if (strcmp(name,"__NAME__") == 0) {
    return Py_BuildValue("z", self->frame->sym_name);
  } else if (strcmp(name,"__EXE__") == 0) {
    return Py_BuildValue("z", self->frame->object->path);
  } else if (strcmp(name,"__FILE__") == 0) {
    return Py_BuildValue("z", self->frame->loc_srcfile);
  } else if (strcmp(name,"__OBJECT__") == 0) {
    return Py_BuildValue("z", self->frame->loc_objfile);
  } else if (strcmp(name,"__LINE__") == 0) {
    return Py_BuildValue("i", self->frame->loc_line);
  } else if (strcmp(name,"__SOURCE__") == 0) {
    return Py_BuildValue("z",self->frame->debug_srcstr);
  } else if (strcmp(name,"__PC__") == 0) {
    return PyLong_FromUnsignedLong(self->frame->pc);
  } else if (strcmp(name,"__SP__") == 0) {
    return PyLong_FromUnsignedLong(self->frame->sp);
  } else if (strcmp(name,"__FP__") == 0) {
    return PyLong_FromUnsignedLong(self->frame->fp);
  } else if (strcmp(name,"__STACK__") == 0) {
    return PyString_FromStringAndSize(self->frame->stack, self->frame->stack_size);
  } else if (strcmp(name,"__NARGS__") == 0) {
    return PyInt_FromLong(self->frame->debug_nargs);
  } else if (strcmp(name,"__LAST__") == 0) {
    return PyInt_FromLong(self->frame->last);
  } else if (strcmp(name,"__WHERE__") == 0) {
    return Py_BuildValue("z",self->frame->debug_str);
  } else if (strcmp(name,"__WAD__") == 0) {
    return PyInt_FromLong(1);
  }

  
  /* Put a check for local variables */
  {
    int i;
    for (i = 0; i < 2; i++) {
      WadLocal *loc;
      if (i == 0) loc = self->frame->debug_locals;
      else loc = self->frame->debug_args;
      while (loc) {
	if (strcmp(name,loc->name) == 0) {
	  switch(loc->type) {
	  case WAD_TYPE_INT32:
	  case WAD_TYPE_INT16:
	  case WAD_TYPE_INT8:
	    return PyLong_FromLong(wad_local_as_long(loc));
	    break;
	  case WAD_TYPE_UINT8:
	  case WAD_TYPE_UINT16:
	  case WAD_TYPE_UINT32:
	    return PyLong_FromUnsignedLong((unsigned long) wad_local_as_long(loc));
	    break;
	  case WAD_TYPE_CHAR:
	    return Py_BuildValue("c", (char) (PyLong_FromLong(wad_local_as_long(loc))));
	    break;
	  case WAD_TYPE_FLOAT:
	  case WAD_TYPE_DOUBLE:
	    return PyFloat_FromDouble(wad_local_as_double(loc));
	    break;
	  default:
	    return PyLong_FromUnsignedLong((unsigned long) wad_local_as_long(loc));
	  }
	}
	loc = loc->next;
      }
    }
  }
  
  PyErr_SetString(PyExc_NameError,"Unknown attribute.");
  return NULL;
}
static PySequenceMethods wadobject_as_sequence = {
  (inquiry)   wadobject_len,
  0,
  0,
  (intargfunc)  wadobject_getitem,  /* get item */
  (intintargfunc)  wadobject_getslice,  /* get slice */
  0,
  0
};

static PyTypeObject WadObjectType = {
  PyObject_HEAD_INIT(&PyType_Type)
  0,
  "WadObject",
  sizeof(wadobject),
  0,
  (destructor) wadobject_dealloc,
  0,             /* printfunc */
  (getattrfunc) wadobject_getattr,
  (setattrfunc) 0,
  (cmpfunc) 0,
  (reprfunc) wadobject_repr,
  
  0,     /* number */
  &wadobject_as_sequence,     /* sequence */
  0,     /* mapping */
  0,     /* hash */
  0,     /* call */
  (reprfunc) wadobject_str,   /* str */
};

