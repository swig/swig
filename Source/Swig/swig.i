/* -*- c -*- */
/* -------------------------------------------------------------------------
 * swig.i
 *
 *     Interface file for the SWIG core.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *             Dustin Mitchell (djmitche@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 *
 * $Header$
 * ------------------------------------------------------------------------- */

/* todo: implement callable stuff -- ternaryfunc? */
/* todo: new DOH type to wrap Python objects. geesh. */
/* todo: Delattr -> return errors */

%module swig

%{
#include "doh.h"
%}

%typemap(python,in) FILE * {
   $target = PyFile_AsFile($source);
}

%typemap(python,out) FILE * {
   $target = PyFile_FromFile($source, "unknown", "?", fclose);
}

%{
   /* -------------------------------------------------------------------------
    * An extension type for DOH objects -- we could use shadow classes,
    * but this will be lots faster, and provide a slightly cleaner interface.
    * ------------------------------------------------------------------------- */

   typedef struct PyDOH {
      PyObject_HEAD
      DOH *doh;
   } PyDOH;

   staticforward PyTypeObject PyDOHSequenceType, PyDOHMappingType;

   /* --------------------------------------------------------------------- */
   /* meta-functions
    */

   /* Given a DOH object, return an equivalent PyObject.  Note that
      when the PyObject is destroyed, the DOH's reference count will
      decrease; thus this is refcount-safe on both the DOH and Python
      sides. */
   static PyObject * Swig_PyDOH_new(DOH *in) {
      PyDOH *self;
      if (!in)
      {
	 Incref(Py_None);
	 return Py_None;
      }
      if (DohIsMapping(in))
	 self = PyObject_NEW(PyDOH, &PyDOHMappingType);
      else
	 self = PyObject_NEW(PyDOH, &PyDOHSequenceType);
      if (!self) return (PyObject *)self;
      self->doh = in;
      Incref(in);		/* increase the DOH refcount */
      return (PyObject *)self;
   }

   static void Swig_PyDOH_delete(PyDOH *self) {
      Delete(self->doh);		/* decrease the DOH refcount */
      PyMem_DEL(self);
   }

   static int Swig_PyDOH_check(void *self) {
      return ((PyObject *)self)->ob_type == &PyDOHMappingType
	 || ((PyObject *)self)->ob_type == &PyDOHSequenceType;
   }

   /* Given a PyObject, return an equivalent DOH object */
   static PyDOH *Swig_PyDOH_as_DOH(PyObject *source)
      {
	 DOH *target;

	 if (Swig_PyDOH_check(source))
	    target = ((PyDOH *)source)->doh;
	 else if (PyString_Check(source))
	    target = (DOH *)PyString_AsString(source);
	 else if (PySequence_Check(source))
	    printf("Sequence -> NULL\n"), target = NULL;
	 else if (PyMapping_Check(source))
	    printf("Mapping -> NULL\n"), target = NULL;
	 else if (PyNumber_Check(source))
	    target = (DOH *)source;
	 else if (PyFile_Check(source))
	    target = (DOH *)PyFile_AsFile(source);
	 else
	    printf("?? -> NULL\n"), target = NULL;

	 return target;
      }


   /* --------------------------------------------------------------------- */
   /* sequence methods
    */

   static int Swig_PyDOH_length(PyDOH *self) {
      return Len(self->doh);	/* also a mapping method */
   }

   static PyObject *Swig_PyDOH_item(PyDOH *self, int index) {
      DOH *r = Getitem(self->doh, index);

      if (r)
	 return Swig_PyDOH_new(r);

      /* return an exception */
      PyErr_SetObject(PyExc_KeyError, PyInt_FromLong(index));
      return NULL;
   }

   static int Swig_PyDOH_ass_item(PyDOH *self, int index,
				  PyObject *v) {
      int result;
      if (v)
	 result = Setitem(self->doh, index, Swig_PyDOH_as_DOH(v));
      else			/* NULL v => delete item */
	 result = Delitem(self->doh, index);

      /* post an exception if necessary */
      if (result == -1)
	 PyErr_SetObject(PyExc_KeyError,
			 PyInt_FromLong(index));

      return result;
   }

   static PySequenceMethods Swig_PyDOH_as_sequence = {
      (inquiry)Swig_PyDOH_length,
      (binaryfunc)NULL,		/* sq_concat */
      (intargfunc)NULL,		/* sq_repeat */
      (intargfunc)Swig_PyDOH_item,
      (intintargfunc)NULL,	/* sq_slice */
      (intobjargproc)Swig_PyDOH_ass_item,
      (intintobjargproc)NULL	/* sq_ass_slice */
   };


   /* --------------------------------------------------------------------- */
   /* Mapping methods
    */

   static PyObject *Swig_PyDOH_subscript(PyDOH *self, PyObject *k) {
      DOH *r = Getattr(self->doh, Swig_PyDOH_as_DOH(k));
      if (r)
	 return Swig_PyDOH_new(r);

      PyErr_SetObject(PyExc_KeyError, k);
      return NULL;
   }

   static int Swig_PyDOH_ass_subscript(PyDOH *self, PyObject *k,
				       PyObject *v) {
      int result = 0;
      if (v)
	 result = Setattr(self->doh, Swig_PyDOH_as_DOH(k),
			  Swig_PyDOH_as_DOH(v));
      else
	 Delattr(self->doh, Swig_PyDOH_as_DOH(k));

      if (result == -1)
	 PyErr_SetObject(PyExc_KeyError,
			 k);

      return result;
   }

   static PyMappingMethods Swig_PyDOH_as_mapping = {
      (inquiry)Swig_PyDOH_length,
      (binaryfunc)Swig_PyDOH_subscript,
      (objobjargproc)Swig_PyDOH_ass_subscript
   };


   /* --------------------------------------------------------------------- */
   /* named methods
    */

   static PyObject *Swig_PyDOH_Copy(PyDOH *self, PyObject *args) {
      DOH * _result;

      if(!PyArg_ParseTuple(args,":Copy"))
	 return NULL;
      _result = (DOH *)DohCopy(self->doh);
      return Swig_PyDOH_new(_result);
   }

   static PyObject *Swig_PyDOH_Clear(PyDOH *self, PyObject *args) {
      if(!PyArg_ParseTuple(args,":Clear"))
	 return NULL;
      DohClear(self->doh);
      Py_INCREF(Py_None);
      return Py_None;
   }

   static PyObject *Swig_PyDOH_SetScope(PyDOH *self, PyObject *args) {
      int  _arg1;

      if(!PyArg_ParseTuple(args,"i:SetScope",&_arg1))
	 return NULL;
      DohSetScope(self->doh,_arg1);
      Py_INCREF(Py_None);
      return Py_None;
   }

   static PyObject *Swig_PyDOH_Dump(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;
      DOH * _arg1;
      PyObject * _obj1 = 0;

      if(!PyArg_ParseTuple(args,"O:Dump",&_obj1))
	 return NULL;
      _arg1 = Swig_PyDOH_as_DOH(_obj1);
      _result = (int )DohDump(self->doh,_arg1);
      return PyInt_FromLong(_result);
   }

   static PyObject *Swig_PyDOH_Firstkey(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      DOH * _result;

      if(!PyArg_ParseTuple(args,":Firstkey"))
	 return NULL;
      _result = (DOH *)DohFirstkey(self->doh);
      _resultobj = Swig_PyDOH_new(_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Nextkey(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      DOH * _result;

      if(!PyArg_ParseTuple(args,":Nextkey"))
	 return NULL;
      _result = (DOH *)DohNextkey(self->doh);
      _resultobj = Swig_PyDOH_new(_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_GetInt(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;
      DOH * _arg1;
      PyObject * _obj1 = 0;

      if(!PyArg_ParseTuple(args,"O:GetInt",&_obj1))
	 return NULL;
      _arg1 = Swig_PyDOH_as_DOH(_obj1);
      _result = (int )DohGetInt(self->doh,_arg1);
      _resultobj = Py_BuildValue("i",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_GetDouble(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      double  _result;
      DOH * _arg1;
      PyObject * _obj1 = 0;

      if(!PyArg_ParseTuple(args,"O:GetDouble",&_obj1))
	 return NULL;
      _arg1 = Swig_PyDOH_as_DOH(_obj1);
      _result = (double )DohGetDouble(self->doh,_arg1);
      _resultobj = Py_BuildValue("d",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_GetChar(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      char * _result;
      DOH * _arg1;
      PyObject * _obj1 = 0;

      if(!PyArg_ParseTuple(args,"O:GetChar",&_obj1))
	 return NULL;
      _arg1 = Swig_PyDOH_as_DOH(_obj1);
      _result = (char *)DohGetChar(self->doh,_arg1);
      _resultobj = Py_BuildValue("s", _result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_SetInt(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      DOH * _arg1;
      int  _arg2;
      PyObject * _obj1 = 0;

      if(!PyArg_ParseTuple(args,"Oi:SetInt",&_obj1,&_arg2))
	 return NULL;
      _arg1 = Swig_PyDOH_as_DOH(_obj1);
      DohSetInt(self->doh,_arg1,_arg2);
      Py_INCREF(Py_None);
      _resultobj = Py_None;
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_SetDouble(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      DOH * _arg1;
      double  _arg2;
      PyObject * _obj1 = 0;

      if(!PyArg_ParseTuple(args,"Od:SetDouble",&_obj1,&_arg2))
	 return NULL;
      _arg1 = Swig_PyDOH_as_DOH(_obj1);
      DohSetDouble(self->doh,_arg1,_arg2);
      Py_INCREF(Py_None);
      _resultobj = Py_None;
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Insertitem(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;
      int  _arg1;
      DOH * _arg2;
      PyObject * _obj2 = 0;

      if(!PyArg_ParseTuple(args,"iO:Insertitem",&_arg1,&_obj2))
	 return NULL;
      _arg2 = Swig_PyDOH_as_DOH(_obj2);
      _result = (int )DohInsertitem(self->doh,_arg1,_arg2);
      _resultobj = Py_BuildValue("i",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Firstitem(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      DOH * _result;

      if(!PyArg_ParseTuple(args,":Firstitem"))
	 return NULL;
      _result = (DOH *)DohFirstitem(self->doh);
      _resultobj = Swig_PyDOH_new(_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Nextitem(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      DOH * _result;

      if(!PyArg_ParseTuple(args,":Nextitem"))
	 return NULL;
      _result = (DOH *)DohNextitem(self->doh);
      _resultobj = Swig_PyDOH_new(_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Write(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;
      int  _arg2;
      char * _arg1 = 0;

      if(!PyArg_ParseTuple(args,"si:Write",&_arg1,&_arg2))
	 return NULL;
      _result = (int )DohWrite(self->doh,_arg1,_arg2);
      _resultobj = Py_BuildValue("i",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Read(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;
      int  _arg2;
      char *buffer;

      if(!PyArg_ParseTuple(args,"i:Read",&_arg2))
	 return NULL;
      buffer = DohMalloc(_arg2);
      if (!buffer) {
	 PyErr_SetString(PyExc_MemoryError, "Not enough memory for Read buffer");
	 return NULL;
      }
      _result = (int )DohRead(self->doh,buffer,_arg2);
      _resultobj = Py_BuildValue("(is)",_result, buffer);
      DohFree(buffer);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Seek(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;
      long  _arg1;
      int  _arg2;

      if(!PyArg_ParseTuple(args,"li:Seek",&_arg1,&_arg2))
	 return NULL;
      _result = (int )DohSeek(self->doh,_arg1,_arg2);
      _resultobj = Py_BuildValue("i",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Tell(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      long  _result;

      if(!PyArg_ParseTuple(args,":Tell"))
	 return NULL;
      _result = (long )DohTell(self->doh);
      _resultobj = Py_BuildValue("l",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Getc(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;

      if(!PyArg_ParseTuple(args,":Getc"))
	 return NULL;
      _result = (int )DohGetc(self->doh);
      if (_result > 0) {
	 char c[2] = { (char)_result, 0 };
	 _resultobj = PyString_FromString(c);
      }
      else
      {
	 Py_INCREF(Py_None);
	 _resultobj = Py_None;
      }
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Putc(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;
      int  _arg0;

      if(!PyArg_ParseTuple(args,"i:Putc",&_arg0))
	 return NULL;
      _result = (int )DohPutc(_arg0, self->doh);
      _resultobj = Py_BuildValue("i",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Ungetc(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;
      int  _arg0;

      if(!PyArg_ParseTuple(args,"iO:Ungetc",&_arg0))
	 return NULL;
      _result = (int )DohUngetc(_arg0,self->doh);
      _resultobj = Py_BuildValue("i",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Getline(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _result;

      if(!PyArg_ParseTuple(args,":Getline"))
	 return NULL;
      _result = (int )DohGetline(self->doh);
      _resultobj = Py_BuildValue("i",_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Setline(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      int  _arg1;

      if(!PyArg_ParseTuple(args,"i:Setline",&_arg1))
	 return NULL;
      DohSetline(self->doh,_arg1);
      Py_INCREF(Py_None);
      _resultobj = Py_None;
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Getfile(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      DOH * _result;

      if(!PyArg_ParseTuple(args,":Getfile"))
	 return NULL;
      _result = (DOH *)DohGetfile(self->doh);
      _resultobj = Swig_PyDOH_new(_result);
      return _resultobj;
   }

   static PyObject *Swig_PyDOH_Setfile(PyDOH *self, PyObject *args) {
      PyObject * _resultobj;
      DOH * _arg1;
      PyObject * _obj1 = 0;

      if(!PyArg_ParseTuple(args,"O:Setfile",&_obj1))
	 return NULL;
      _arg1 = Swig_PyDOH_as_DOH(_obj1);
      DohSetfile(self->doh,_arg1);
      Py_INCREF(Py_None);
      _resultobj = Py_None;
      return _resultobj;
   }

   static struct PyMethodDef Swig_PyDOH_methods[] = {
      {"copy", (PyCFunction)Swig_PyDOH_Copy, METH_VARARGS},
      {"clear", (PyCFunction)Swig_PyDOH_Clear, METH_VARARGS},
      {"setscope", (PyCFunction)Swig_PyDOH_SetScope, METH_VARARGS},
      {"dump", (PyCFunction)Swig_PyDOH_Dump, METH_VARARGS},
      {"firstkey", (PyCFunction)Swig_PyDOH_Firstkey, METH_VARARGS},
      {"nextkey", (PyCFunction)Swig_PyDOH_Nextkey, METH_VARARGS},
      {"getint", (PyCFunction)Swig_PyDOH_GetInt, METH_VARARGS},
      {"getdouble", (PyCFunction)Swig_PyDOH_GetDouble, METH_VARARGS},
      {"getchar", (PyCFunction)Swig_PyDOH_GetChar, METH_VARARGS},
      {"setint", (PyCFunction)Swig_PyDOH_SetInt, METH_VARARGS},
      {"setdouble", (PyCFunction)Swig_PyDOH_SetDouble, METH_VARARGS},
      {"insertitem", (PyCFunction)Swig_PyDOH_Insertitem, METH_VARARGS},
      {"insert", (PyCFunction)Swig_PyDOH_Insertitem, METH_VARARGS},
      {"firstitem", (PyCFunction)Swig_PyDOH_Firstitem, METH_VARARGS},
      {"nextitem", (PyCFunction)Swig_PyDOH_Nextitem, METH_VARARGS},
      {"write", (PyCFunction)Swig_PyDOH_Write, METH_VARARGS},
      {"read", (PyCFunction)Swig_PyDOH_Read, METH_VARARGS},
      {"seek", (PyCFunction)Swig_PyDOH_Seek, METH_VARARGS},
      {"tell", (PyCFunction)Swig_PyDOH_Tell, METH_VARARGS},
      {"getc", (PyCFunction)Swig_PyDOH_Getc, METH_VARARGS},
      {"putc", (PyCFunction)Swig_PyDOH_Putc, METH_VARARGS},
      {"ungetc", (PyCFunction)Swig_PyDOH_Ungetc, METH_VARARGS},
      {"getline", (PyCFunction)Swig_PyDOH_Getline, METH_VARARGS},
      {"setline", (PyCFunction)Swig_PyDOH_Setline, METH_VARARGS},
      {"getfile", (PyCFunction)Swig_PyDOH_Getfile, METH_VARARGS},
      {"setfile", (PyCFunction)Swig_PyDOH_Setfile, METH_VARARGS},
      {NULL, NULL}
   };


   /* --------------------------------------------------------------------- */
   /* general methods
    */

   static PyObject *Swig_PyDOH_getattr(PyDOH *self, char *name) {
      return Py_FindMethod(Swig_PyDOH_methods,
			   (PyObject *)self, name);
   }

   static int Swig_PyDOH_setattr(PyDOH *self, char *name, PyObject *v) {
      return Setattr(self->doh, name, Swig_PyDOH_as_DOH(v));
   }

   static int Swig_PyDOH_cmp(PyDOH *self, PyObject *other) {
      return Cmp(self->doh, Swig_PyDOH_as_DOH(other));
   }

   static PyObject *Swig_PyDOH_repr(PyDOH *self) {
      char *str = Char(self->doh);
      char buffer[1024] = "";

      str = Char(self->doh);
      if (!str) {
	 /* give up! */
	 sprintf(buffer, "<DOH *0x%08x>", self->doh);
	 str = buffer;
      }

      return PyString_FromString(str);
   }

   static long Swig_PyDOH_hash(PyDOH *self) {
      return (long)Hashval(self->doh);
   }

   static char PyDOH_docstring[] =
      "Interface to DOH objects from Python.  DOH objects behave largely\n\
like Python objects, although some functionality may be different.";

   /* Type objects (one for mappings, one for everything else) */
   static PyTypeObject PyDOHSequenceType = {
      PyObject_HEAD_INIT(&PyType_Type)
      0,
      "DOH",
      sizeof(PyDOH),
      0,
      (destructor)Swig_PyDOH_delete,
      (printfunc)0,
      (getattrfunc)Swig_PyDOH_getattr,
      (setattrfunc)Swig_PyDOH_setattr,
      (cmpfunc)Swig_PyDOH_cmp,
      (reprfunc)Swig_PyDOH_repr,

      0,			/* tp_as_number */
      &Swig_PyDOH_as_sequence,
      0,			/* tp_as_mapping */
      (hashfunc)Swig_PyDOH_hash,
      (ternaryfunc)0,		/* tp_call */
      (reprfunc)0,		/* tp_str */
      (getattrofunc)0,
      (setattrofunc)0,
      0,			/* tp_as_buffer */
      0,			/* tp_xxx4 */
      PyDOH_docstring
   };

   static PyTypeObject PyDOHMappingType = {
      PyObject_HEAD_INIT(&PyType_Type)
      0,
      "DOH_hash",
      sizeof(PyDOH),
      0,
      (destructor)Swig_PyDOH_delete,
      (printfunc)0,
      (getattrfunc)Swig_PyDOH_getattr,
      (setattrfunc)Swig_PyDOH_setattr,
      (cmpfunc)Swig_PyDOH_cmp,
      (reprfunc)Swig_PyDOH_repr,

      0,			/* tp_as_number */
      0,			/* tp_as_sequence */
      &Swig_PyDOH_as_mapping,
      (hashfunc)Swig_PyDOH_hash,
      (ternaryfunc)0,		/* tp_call */
      (reprfunc)0,		/* tp_str */
      (getattrofunc)0,
      (setattrofunc)0,
      0,			/* tp_as_buffer */
      0,			/* tp_xxx4 */
      PyDOH_docstring
   };
   %}

%typemap(python,in) DOH * {
   $target = Swig_PyDOH_as_DOH($source);
}

%typemap(python,out) DOH * {
   $target = Swig_PyDOH_new($source);
}

%typemap(python,in) char * {
   if (Swig_PyDOH_check($source))
      $target = Char(((PyDOH *)$source)->doh);
   else
      $target = PyString_AsString($source);
}

%title "SWIG", after

%section "DOH Objects", before

%subsection "Constants"

/* The beginning of a sequence */
#define DOH_BEGIN    -1
/* The end of a sequence */
#define DOH_END      -2
/* The current point in a sequence */
#define DOH_CUR      -3
/* Synonymous with DOH_CUR */
#define DOH_CURRENT  -3

/* Replace any matches of the given text */
#define   DOH_REPLACE_ANY         0x00
/* Replace, but not inside of quotes */
#define   DOH_REPLACE_NOQUOTE     0x01
/* Replace only full identifiers */
#define   DOH_REPLACE_ID          0x02
/* Replace only the first match */
#define   DOH_REPLACE_FIRST       0x04

%subsection "SuperStrings"
/* SuperString constructor */
extern DOH *NewSuperString(char *string, DOH *filename, int firstline);
/* Is this a SuperString? */
extern int SuperString_check(DOH *);

%subsection "Strings"
/* String constructor */
extern DOH   *NewString(const DOH *c);
/* Is this a string? */
extern int    String_check(const DOH *);

%subsection "Files"
/* File constructor */
extern DOH *NewFile(DOH *file, char *mode);
/* File constructor from Python file */
extern DOH *NewFileFromFile(FILE *file);
/* File constructor from a file descriptor */
extern DOH *NewFileFromFd(int fd);
/* Copy from file to file */
%name(CopyTo) extern int  DohCopyto(DOH *input, DOH *output);

%subsection "Lists"
/* List constructor */
extern DOH  *NewList();
/* Is this a list? */
extern int  List_check(const DOH *);
/* Sort a list */
extern void List_sort(DOH *);

%subsection "Hash tables"
/* Hash table constructor */
extern DOH   *NewHash();
/* Is this a hash table? */
extern int    Hash_check(const DOH *);
/* Get a List of the keys in a hash table */
extern DOH   *Hash_keys(DOH *);

%section "Files"

extern void  Swig_add_directory(DOH *dirname);
extern DOH  *Swig_last_file();
extern DOH  *Swig_search_path();
extern FILE *Swig_open(DOH *name);
extern DOH  *Swig_read_file(FILE *file);
extern DOH  *Swig_include(DOH *name);

#define  SWIG_FILE_DELIMETER   "/"

%section "Command Line Parsing"

extern void  Swig_init_args(int argc, char **argv);
extern void  Swig_mark_arg(int n);
extern void  Swig_check_options(int check_input);
extern void  Swig_arg_error();

%section "Miscelaneous", after

extern int     DohNewScope();	/* create a new scope    */
extern void    DohDelScope(int); /* Delete a scope        */
extern void    DohIntern(DOH *); /* Intern an object      */
extern void    DohDebug(int d);	/* set debugging level */

%section "Scanner Interface"

/*  typedef struct SwigScanner SwigScanner; */

/*  extern SwigScanner *NewSwigScanner(); */
/*  extern void     DelSwigScanner(SwigScanner *); */
/*  extern void     SwigScanner_clear(SwigScanner *); */
/*  extern void     SwigScanner_push(SwigScanner *, DOH *); */
/*  extern void     SwigScanner_pushtoken(SwigScanner *, int); */
/*  extern int      SwigScanner_token(SwigScanner *); */
/*  extern DOH     *SwigScanner_text(SwigScanner *); */
/*  extern void     SwigScanner_skip_line(SwigScanner *); */
/*  extern int      SwigScanner_skip_balanced(SwigScanner *, int startchar, int endchar); */
/*  extern void     SwigScanner_set_location(SwigScanner *, DOH *file, int line); */
/*  extern DOH     *SwigScanner_get_file(SwigScanner *); */
/*  extern int      SwigScanner_get_line(SwigScanner *); */
/*  extern void     SwigScanner_idstart(SwigScanner *, char *idchar); */

/*  #define   SWIG_MAXTOKENS          512 */
/*  #define   SWIG_TOKEN_LPAREN        1   */
/*  #define   SWIG_TOKEN_RPAREN        2 */
/*  #define   SWIG_TOKEN_SEMI          3 */
/*  #define   SWIG_TOKEN_COMMA         4 */
/*  #define   SWIG_TOKEN_STAR          5 */
/*  #define   SWIG_TOKEN_LBRACE        6 */
/*  #define   SWIG_TOKEN_RBRACE        7 */
/*  #define   SWIG_TOKEN_EQUAL         8 */
/*  #define   SWIG_TOKEN_EQUALTO       9 */
/*  #define   SWIG_TOKEN_NOTEQUAL     10 */
/*  #define   SWIG_TOKEN_PLUS         11 */
/*  #define   SWIG_TOKEN_MINUS        12 */
/*  #define   SWIG_TOKEN_AND          13 */
/*  #define   SWIG_TOKEN_LAND         14 */
/*  #define   SWIG_TOKEN_OR           15 */
/*  #define   SWIG_TOKEN_LOR          16 */
/*  #define   SWIG_TOKEN_XOR          17 */
/*  #define   SWIG_TOKEN_LESSTHAN     18 */
/*  #define   SWIG_TOKEN_GREATERTHAN  19 */
/*  #define   SWIG_TOKEN_LTEQUAL      20 */
/*  #define   SWIG_TOKEN_GTEQUAL      21 */
/*  #define   SWIG_TOKEN_NOT          22 */
/*  #define   SWIG_TOKEN_LNOT         23 */
/*  #define   SWIG_TOKEN_LBRACKET     24 */
/*  #define   SWIG_TOKEN_RBRACKET     25 */
/*  #define   SWIG_TOKEN_SLASH        26 */
/*  #define   SWIG_TOKEN_BACKSLASH    27 */
/*  #define   SWIG_TOKEN_ENDLINE      28 */
/*  #define   SWIG_TOKEN_STRING       29 */
/*  #define   SWIG_TOKEN_POUND        30 */
/*  #define   SWIG_TOKEN_PERCENT      31 */
/*  #define   SWIG_TOKEN_COLON        32 */
/*  #define   SWIG_TOKEN_DCOLON       33 */
/*  #define   SWIG_TOKEN_LSHIFT       34 */
/*  #define   SWIG_TOKEN_RSHIFT       35 */
/*  #define   SWIG_TOKEN_ID           36 */
/*  #define   SWIG_TOKEN_FLOAT        37 */
/*  #define   SWIG_TOKEN_DOUBLE       38 */
/*  #define   SWIG_TOKEN_INT          39 */
/*  #define   SWIG_TOKEN_UINT         40 */
/*  #define   SWIG_TOKEN_LONG         41 */
/*  #define   SWIG_TOKEN_ULONG        42 */
/*  #define   SWIG_TOKEN_CHAR         43 */
/*  #define   SWIG_TOKEN_PERIOD       44 */
/*  #define   SWIG_TOKEN_AT           45 */
/*  #define   SWIG_TOKEN_DOLLAR       46 */
/*  #define   SWIG_TOKEN_CODEBLOCK    47 */
/*  #define   SWIG_TOKEN_ILLEGAL      98 */
/*  #define   SWIG_TOKEN_LAST         99  */

%section "SWIG types"

/*  #define   SWIG_TYPE_BYTE          1 */
/*  #define   SWIG_TYPE_UBYTE         2 */
/*  #define   SWIG_TYPE_SHORT         3 */
/*  #define   SWIG_TYPE_USHORT        4 */
/*  #define   SWIG_TYPE_INT           5 */
/*  #define   SWIG_TYPE_UINT          6 */
/*  #define   SWIG_TYPE_LONG          7 */
/*  #define   SWIG_TYPE_ULONG         8 */
/*  #define   SWIG_TYPE_LONGLONG      9 */
/*  #define   SWIG_TYPE_ULONGLONG    10 */
/*  #define   SWIG_TYPE_FLOAT        11 */
/*  #define   SWIG_TYPE_DOUBLE       12 */
/*  #define   SWIG_TYPE_QUAD         13 */
/*  #define   SWIG_TYPE_CHAR         14 */
/*  #define   SWIG_TYPE_WCHAR        15 */
/*  #define   SWIG_TYPE_VOID         16 */
/*  #define   SWIG_TYPE_ENUM         17 */
/*  #define   SWIG_TYPE_VARARGS      18 */
/*  #define   SWIG_TYPE_TYPEDEF      19 */

/*  #define   SWIG_TYPE_POINTER      50 */
/*  #define   SWIG_TYPE_REFERENCE    51 */
/*  #define   SWIG_TYPE_FUNCTION     52 */
/*  #define   SWIG_TYPE_ARRAY        53 */
/*  #define   SWIG_TYPE_RECORD       54 */
/*  #define   SWIG_TYPE_NAME         55 */

/*  DOH *NewSwigType(int tc, DOH *value); */





