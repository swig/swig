//
// SWIG pointer conversion and utility library
// 
// Dave Beazley
// April 19, 1997
//
// Python specific implementation.   This file is included
// by the file ../pointer.i


%{
#include <ctype.h>

/* Types used by the library */
static swig_type_info *SWIG_POINTER_int_p = 0;
static swig_type_info *SWIG_POINTER_short_p =0;
static swig_type_info *SWIG_POINTER_long_p = 0;
static swig_type_info *SWIG_POINTER_float_p = 0;
static swig_type_info *SWIG_POINTER_double_p = 0;
static swig_type_info *SWIG_POINTER_char_p = 0;
static swig_type_info *SWIG_POINTER_char_pp = 0;
%}

%init %{
  SWIG_POINTER_int_p = SWIG_TypeQuery("int *");
  SWIG_POINTER_short_p = SWIG_TypeQuery("short *");
  SWIG_POINTER_long_p = SWIG_TypeQuery("long *");
  SWIG_POINTER_float_p = SWIG_TypeQuery("float *");
  SWIG_POINTER_double_p = SWIG_TypeQuery("double *");
  SWIG_POINTER_char_p = SWIG_TypeQuery("char *");
  SWIG_POINTER_char_pp = SWIG_TypeQuery("char **");
%}

%{

/*------------------------------------------------------------------
  ptrvalue(ptr,type = 0)

  Attempts to dereference a pointer value.  If type is given, it 
  will try to use that type.  Otherwise, this function will attempt
  to "guess" the proper datatype by checking against all of the 
  builtin C datatypes. 
  ------------------------------------------------------------------ */

static PyObject *ptrvalue(PyObject *_PTRVALUE, int index, char *type) {
  void     *ptr;
  char     *s;
  PyObject *obj;

  if (SWIG_ConvertPtr(_PTRVALUE,&ptr,0,0)) {
    PyErr_SetString(PyExc_TypeError,"Type error in ptrvalue. Argument is not a valid pointer value.");
    return NULL;
  }

  /* If no datatype was passed, try a few common datatypes first */
  if (!type) {
    /* No datatype was passed.   Type to figure out if it's a common one */
    if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_int_p,0)) {
      type = "int";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_double_p,0)) {
      type = "double";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_short_p,0)) {
      type = "short";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_long_p,0)) {
      type = "long";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_float_p,0)) {
      type = "float";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_char_p,0)) {
      type = "char";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_char_pp,0)) {
      type = "char *";
    } else {
      type = "unknown";
    }
  }
  if (!ptr) {
    PyErr_SetString(PyExc_TypeError,"Unable to dereference NULL pointer.");
    return NULL;
  }
  /* Now we have a datatype.  Try to figure out what to do about it */
  if (strcmp(type,"int") == 0) {
    obj = PyInt_FromLong((long) *(((int *) ptr) + index));
  } else if (strcmp(type,"double") == 0) {
    obj = PyFloat_FromDouble((double) *(((double *) ptr)+index));
  } else if (strcmp(type,"short") == 0) {
    obj = PyInt_FromLong((long) *(((short *) ptr)+index));
  } else if (strcmp(type,"long") == 0) {
    obj = PyInt_FromLong((long) *(((long *) ptr)+index));
  } else if (strcmp(type,"float") == 0) {
    obj = PyFloat_FromDouble((double) *(((float *) ptr)+index));
  } else if (strcmp(type,"char") == 0) {
    obj = PyString_FromString(((char *) ptr)+index);
  } else if (strcmp(type,"char *") == 0) {
    char *c = *(((char **) ptr)+index);
    if (c) obj = PyString_FromString(c);
    else obj = PyString_FromString("NULL");
  } else {
    PyErr_SetString(PyExc_TypeError,"Unable to dereference unsupported datatype.");
    return NULL;
  }
  return obj;
}

/*------------------------------------------------------------------
  ptrcreate(type,value = 0,numelements = 1)

  Attempts to create a new object of given type.  Type must be
  a basic C datatype.  Will not create complex objects.
  ------------------------------------------------------------------ */

static PyObject *ptrcreate(char *type, PyObject *_PYVALUE, int numelements) {
  void     *ptr;
  PyObject *obj;
  int       sz;
  swig_type_info *cast;
  char      temp[40];

  /* Check the type string against a variety of possibilities */

  if (strcmp(type,"int") == 0) {
    sz = sizeof(int)*numelements;
    cast = SWIG_POINTER_int_p;
  } else if (strcmp(type,"short") == 0) {
    sz = sizeof(short)*numelements;
    cast = SWIG_POINTER_short_p;
  } else if (strcmp(type,"long") == 0) {
    sz = sizeof(long)*numelements;
    cast = SWIG_POINTER_long_p;
  } else if (strcmp(type,"double") == 0) {
    sz = sizeof(double)*numelements;
    cast = SWIG_POINTER_double_p;
  } else if (strcmp(type,"float") == 0) {
    sz = sizeof(float)*numelements;
    cast = SWIG_POINTER_float_p;
  } else if (strcmp(type,"char") == 0) {
    sz = sizeof(char)*numelements;
    cast = SWIG_POINTER_char_p;
  } else if (strcmp(type,"char *") == 0) {
    sz = sizeof(char *)*(numelements+1);
    cast = SWIG_POINTER_char_pp;
  } else {
    PyErr_SetString(PyExc_TypeError,"Unable to create unknown datatype."); 
    return NULL;
  }
   
  /* Create the new object */
  
  ptr = (void *) malloc(sz);
  if (!ptr) {
    PyErr_SetString(PyExc_MemoryError,"Out of memory in swig_create."); 
    return NULL;
  }

  /* Now try to set its default value */

  if (_PYVALUE) {
    if (strcmp(type,"int") == 0) {
      int *ip,i,ivalue;
      ivalue = (int) PyInt_AsLong(_PYVALUE);
      ip = (int *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"short") == 0) {
      short *ip,ivalue;
      int i;
      ivalue = (short) PyInt_AsLong(_PYVALUE);
      ip = (short *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"long") == 0) {
      long *ip,ivalue;
      int i;
      ivalue = (long) PyInt_AsLong(_PYVALUE);
      ip = (long *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"double") == 0) {
      double *ip,ivalue;
      int i;
      ivalue = (double) PyFloat_AsDouble(_PYVALUE);
      ip = (double *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"float") == 0) {
      float *ip,ivalue;
      int i;
      ivalue = (float) PyFloat_AsDouble(_PYVALUE);
      ip = (float *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"char") == 0) {
      char *ip,*ivalue;
      ivalue = (char *) PyString_AsString(_PYVALUE);
      ip = (char *) ptr;
      strncpy(ip,ivalue,numelements-1);
    } else if (strcmp(type,"char *") == 0) {
      char **ip, *ivalue;
      int  i;
      ivalue = (char *) PyString_AsString(_PYVALUE);
      ip = (char **) ptr;
      for (i = 0; i < numelements; i++) {
	if (ivalue) {
	  ip[i] = (char *) malloc(strlen(ivalue)+1);
	  strcpy(ip[i],ivalue);
	} else {
	  ip[i] = 0;
	}
      }
      ip[numelements] = 0;
    }
  } 
  /* Create the pointer value */
  
  obj = SWIG_NewPointerObj(ptr,cast);
  return obj;
}


/*------------------------------------------------------------------
  ptrset(ptr,value,index = 0,type = 0)

  Attempts to set the value of a pointer variable.  If type is
  given, we will use that type.  Otherwise, we'll guess the datatype.
  ------------------------------------------------------------------ */

static PyObject *ptrset(PyObject *_PTRVALUE, PyObject *_PYVALUE, int index, char *type) {
  void     *ptr;
  PyObject *obj;

  if (SWIG_ConvertPtr(_PTRVALUE,&ptr,0,0)) {
    PyErr_SetString(PyExc_TypeError,"Type error in ptrset. Argument is not a valid pointer value.");
    return NULL;
  }

  /* If no datatype was passed, try a few common datatypes first */
  if (!type) {
    /* No datatype was passed.   Type to figure out if it's a common one */
    if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_int_p,0)) {
      type = "int";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_double_p,0)) {
      type = "double";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_short_p,0)) {
      type = "short";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_long_p,0)) {
      type = "long";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_float_p,0)) {
      type = "float";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_char_p,0)) {
      type = "char";
    } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_char_pp,0)) {
      type = "char *";
    } else {
      type = "unknown";
    }
  }
  if (!ptr) {
    PyErr_SetString(PyExc_TypeError,"Unable to set NULL pointer.");
    return NULL;
  }
  
  /* Now we have a datatype.  Try to figure out what to do about it */
  if (strcmp(type,"int") == 0) {
    *(((int *) ptr)+index) = (int) PyInt_AsLong(_PYVALUE);
  } else if (strcmp(type,"double") == 0) {
    *(((double *) ptr)+index) = (double) PyFloat_AsDouble(_PYVALUE);
  } else if (strcmp(type,"short") == 0) {
    *(((short *) ptr)+index) = (short) PyInt_AsLong(_PYVALUE);
  } else if (strcmp(type,"long") == 0) {
    *(((long *) ptr)+index) = (long) PyInt_AsLong(_PYVALUE);
  } else if (strcmp(type,"float") == 0) {
    *(((float *) ptr)+index) = (float) PyFloat_AsDouble(_PYVALUE);
  } else if (strcmp(type,"char") == 0) {
    char *c = PyString_AsString(_PYVALUE);
    strcpy(((char *) ptr)+index, c);
  } else if (strcmp(type,"char *") == 0) {
    char *c = PyString_AsString(_PYVALUE);
    char **ca = (char **) ptr;
    if (ca[index]) free(ca[index]);
    if (strcmp(c,"NULL") == 0) {
      ca[index] = 0;
    } else {
      ca[index] = (char *) malloc(strlen(c)+1);
      strcpy(ca[index],c);
    }
  } else {
    PyErr_SetString(PyExc_TypeError,"Unable to set unsupported datatype.");
    return NULL;
  }
  Py_INCREF(Py_None);
  return Py_None;
}

/*------------------------------------------------------------------
  ptradd(ptr,offset)

  Adds a value to an existing pointer value.  Will do a type-dependent
  add for basic datatypes.  For other datatypes, will do a byte-add.
  ------------------------------------------------------------------ */

static PyObject *ptradd(PyObject *_PTRVALUE, int offset) {

  char *r;
  void *ptr,*junk;
  PyObject *obj;
  swig_type_info *type;

  /* Check to see what kind of object _PTRVALUE is */
  
  /* Try to handle a few common datatypes first */
  if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_int_p,0)) {
    ptr = (void *) (((int *) ptr) + offset);
    type = SWIG_POINTER_int_p;
  } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_double_p,0)) {
    ptr = (void *) (((double *) ptr) + offset);
    type = SWIG_POINTER_double_p;
  } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_short_p,0)) {
    ptr = (void *) (((short *) ptr) + offset);
    type = SWIG_POINTER_short_p;
  } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_long_p,0)) {
    ptr = (void *) (((long *) ptr) + offset);
    type = SWIG_POINTER_long_p;
  } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_float_p,0)) {
    ptr = (void *) (((float *) ptr) + offset);
    type = SWIG_POINTER_float_p;
  } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_char_p,0)) {
    ptr = (void *) (((char *) ptr) + offset);
    type = SWIG_POINTER_char_p;
  } else if (!SWIG_ConvertPtr(_PTRVALUE,&ptr,SWIG_POINTER_char_pp,0)) {
    ptr = (void *) (((char *) ptr) + offset);
    type = SWIG_POINTER_char_pp;
  } else {
    PyErr_SetString(PyExc_TypeError,"Type error in ptradd. Argument is not a valid pointer value.");
    return NULL;
  }
  obj = SWIG_NewPointerObj(ptr, type);
  return obj;
}

/*------------------------------------------------------------------
  ptrfree(ptr)

  Destroys a pointer value
  ------------------------------------------------------------------ */

PyObject *ptrfree(PyObject *_PTRVALUE) {
  void *ptr, *junk;

  if (SWIG_ConvertPtr(_PTRVALUE,&ptr,0,0)) {
    PyErr_SetString(PyExc_TypeError,"Type error in ptrfree. Argument is not a valid pointer value.");
    return NULL;
  }
  
  /* Check to see if this pointer is a char ** */
  if (!SWIG_ConvertPtr(_PTRVALUE,&junk,SWIG_POINTER_char_pp,0)) {
    char **c = (char **) ptr;
    if (c) {
      int i = 0;
      while (c[i]) {
	free(c[i]);
	i++;
      }
    }
  }
  if (ptr)
    free((char *) ptr);

  Py_INCREF(Py_None);
  return Py_None;
}

%}
%typemap(python,in) PyObject *ptr, PyObject *value {
  $target = $source;
}

%typemap(python,out) PyObject *ptrcast,
                     PyObject *ptrvalue,
                     PyObject *ptrcreate,
                     PyObject *ptrset,
                     PyObject *ptradd,
                     PyObject *ptrfree  
{
  $target = $source;
}

%typemap(python,ret) int ptrset {
  if ($source == -1) return NULL;
}

PyObject *ptrvalue(PyObject *ptr, int index = 0, char *type = 0);
// Returns the value that a pointer is pointing to (ie. dereferencing).
// The type is automatically inferred by the pointer type--thus, an
// integer pointer will return an integer, a double will return a double,
// and so on.   The index and type fields are optional parameters.  When
// an index is specified, this function returns the value of ptr[index].
// This allows array access.   When a type is specified, it overrides
// the given pointer type.   Examples :
//
//    ptrvalue(a)             #  Returns the value *a
//    ptrvalue(a,10)          #  Returns the value a[10]
//    ptrvalue(a,10,"double") #  Returns a[10] assuming a is a double *

PyObject *ptrset(PyObject *ptr, PyObject *value, int index = 0, char *type = 0);
// Sets the value pointed to by a pointer.  The type is automatically
// inferred from the pointer type so this function will work for
// integers, floats, doubles, etc...  The index and type fields are
// optional.  When an index is given, it provides array access.  When
// type is specified, it overrides the given pointer type.  Examples :
// 
//   ptrset(a,3)            # Sets the value *a = 3
//   ptrset(a,3,10)         # Sets a[10] = 3
//   ptrset(a,3,10,"int")   # Sets a[10] = 3 assuming a is a int *

PyObject *ptrcreate(char *type, PyObject *value = 0, int nitems = 1);
// Creates a new object and returns a pointer to it.  This function 
// can be used to create various kinds of objects for use in C functions.
// type specifies the basic C datatype to create and value is an
// optional parameter that can be used to set the initial value of the
// object.  nitems is an optional parameter that can be used to create
// an array.  This function results in a memory allocation using
// malloc().  Examples :
//
//   a = ptrcreate("double")     # Create a new double, return pointer
//   a = ptrcreate("int",7)      # Create an integer, set value to 7
//   a = ptrcreate("int",0,1000) # Create an integer array with initial
//                               # values all set to zero
//
// This function only recognizes a few common C datatypes as listed below :
//
//        int, short, long, float, double, char, char *, void
//
// All other datatypes will result in an error.  However, other
// datatypes can be created by using the ptrcast function.  For
// example:
//
//  a = ptrcast(ptrcreate("int",0,100),"unsigned int *")

PyObject *ptrfree(PyObject *ptr);
// Destroys the memory pointed to by ptr.  This function calls free()
// and should only be used with objects created by ptrcreate().  Since
// this function calls free, it may work with other objects, but this
// is generally discouraged unless you absolutely know what you're
// doing.

PyObject *ptradd(PyObject *ptr, int offset);
// Adds a value to the current pointer value.  For the C datatypes of
// int, short, long, float, double, and char, the offset value is the
// number of objects and works in exactly the same manner as in C.  For
// example, the following code steps through the elements of an array
//
//  a = ptrcreate("double",0,100);    # Create an array double a[100]
//  b = a;
//  for i in range(0,100):
//      ptrset(b,0.0025*i);           # set *b = 0.0025*i
//      b = ptradd(b,1);              # b++ (go to next double)
//
// In this case, adding one to b goes to the next double.
// 
// For all other datatypes (including all complex datatypes), the
// offset corresponds to bytes.  This function does not perform any
// bounds checking and negative offsets are perfectly legal.  
    


