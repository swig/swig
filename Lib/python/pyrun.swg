/***********************************************************************
 * python.swg
 *
 *     This file contains the runtime support for Python modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 * Author : David Beazley (beazley@cs.uchicago.edu)
 ************************************************************************/

#include "Python.h"

#include <limits.h>
#include <float.h>
#include <string.h>

#ifdef __cplusplus
#define SWIG_STATIC_INLINE static inline 
#else
#define SWIG_STATIC_INLINE static 
#endif 

SWIG_STATIC_INLINE long
SPyObj_AsLong(PyObject * obj)
{
  return PyInt_Check(obj) ?  PyInt_AsLong(obj) : PyLong_AsLong(obj);
}

SWIG_STATIC_INLINE unsigned long
SPyObj_AsUnsignedLong(PyObject * obj) 
{
  if (PyLong_Check(obj)) {
    return PyLong_AsUnsignedLong(obj);
  } else {
    long i = PyInt_AsLong(obj);
    if ( !PyErr_Occurred() && (i < 0)) {
      PyErr_SetString(PyExc_TypeError, "negative value for unsigned type");
    }
    return i;
  }
}

SWIG_STATIC_INLINE PyObject* 
SPyObj_FromLongLong(long long value)
{
  return (value > (long)(LONG_MAX)) ?
    PyLong_FromLongLong(value) : PyInt_FromLong((long)value); 
}

SWIG_STATIC_INLINE PyObject* 
SPyObj_FromUnsignedLong(unsigned long value)
{
  return (value > (unsigned long)(LONG_MAX)) ?
    PyLong_FromUnsignedLong(value) : PyInt_FromLong((long)value); 
}

SWIG_STATIC_INLINE PyObject* 
SPyObj_FromUnsignedLongLong(unsigned long long value)
{
  return (value > (unsigned long long)(LONG_MAX)) ?
    PyLong_FromUnsignedLongLong(value) : PyInt_FromLong((long)value); 
}

SWIG_STATIC_INLINE long
SPyObj_AsLongInRange(PyObject * obj, long min_value, long max_value)
{
  long value = SPyObj_AsLong(obj);
  if (!PyErr_Occurred()) {
    if (value < min_value) {
      PyErr_SetString(PyExc_OverflowError,"value is smaller than type minimum");
    } else if (value > max_value) {
      PyErr_SetString(PyExc_OverflowError,"value is greater than type maximum");
    }
  }
  return value;
}

SWIG_STATIC_INLINE unsigned long
SPyObj_AsUnsignedLongInRange(PyObject *obj, unsigned long max_value) 
{
  unsigned long value = SPyObj_AsUnsignedLong(obj);
  if (!PyErr_Occurred()) {
    if (value > max_value) {     
      PyErr_SetString(PyExc_OverflowError,"value is greater than type maximum");
    }
  }
  return value;
}

SWIG_STATIC_INLINE signed char
SPyObj_AsSignedChar(PyObject *obj) { 
  return SPyObj_AsLongInRange(obj, SCHAR_MIN, SCHAR_MAX);
}

SWIG_STATIC_INLINE short
SPyObj_AsShort(PyObject *obj) { 
  return SPyObj_AsLongInRange(obj, SHRT_MIN, SHRT_MAX);
}

SWIG_STATIC_INLINE int
SPyObj_AsInt(PyObject *obj) { 
  return SPyObj_AsLongInRange(obj, INT_MIN, INT_MAX);
}

SWIG_STATIC_INLINE unsigned char
SPyObj_AsUnsignedChar(PyObject *obj) { 
  return SPyObj_AsUnsignedLongInRange(obj, UCHAR_MAX);
}

SWIG_STATIC_INLINE unsigned short 
SPyObj_AsUnsignedShort(PyObject *obj) { 
  return SPyObj_AsUnsignedLongInRange(obj, USHRT_MAX);
}

SWIG_STATIC_INLINE unsigned int
SPyObj_AsUnsignedInt(PyObject *obj) { 
  return SPyObj_AsUnsignedLongInRange(obj, UINT_MAX);
}

SWIG_STATIC_INLINE long long
SPyObj_AsLongLong(PyObject *obj) {
  return PyInt_Check(obj) ?
    PyInt_AsLong(obj) : PyLong_AsLongLong(obj);
}

SWIG_STATIC_INLINE unsigned long long
SPyObj_AsUnsignedLongLong(PyObject *obj) {
  return PyLong_Check(obj) ?
    PyLong_AsUnsignedLongLong(obj) : SPyObj_AsUnsignedLong(obj);
}

SWIG_STATIC_INLINE double
SPyObj_AsDouble(PyObject *obj) {
  return (PyFloat_Check(obj)) ? PyFloat_AsDouble(obj) :
    (double)((PyInt_Check(obj)) ? PyInt_AsLong(obj) : PyLong_AsLongLong(obj));
}

SWIG_STATIC_INLINE float
SPyObj_AsFloat(PyObject *obj) {
  double value = SPyObj_AsDouble(obj);
  if (!PyErr_Occurred()) {
    if (value < FLT_MIN) {
      PyErr_SetString(PyExc_OverflowError,"float is smaller than flt_min");
    } else if (value > FLT_MAX) {     
      PyErr_SetString(PyExc_OverflowError,"float is greater than flt_max");
    }
  }
  return (float) value;
}

SWIG_STATIC_INLINE char
SPyObj_AsChar(PyObject *obj) { 
  char c = (PyString_Check(obj) && PyString_Size(obj) == 1) ?
    PyString_AsString(obj)[0] 
    : (char) SPyObj_AsLongInRange(obj, CHAR_MIN, CHAR_MAX);
  if (PyErr_Occurred()) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a char is required");
  }
  return c;
}

SWIG_STATIC_INLINE PyObject *
SPyObj_FromChar(char c) { 
  return PyString_FromStringAndSize(&c,1);
}

SWIG_STATIC_INLINE PyObject *
SPyObj_FromCharPtr(const char* cptr) { 
  return cptr ? PyString_FromString(cptr) : Py_BuildValue((char*)"");
}

/*
  these two routines allows char[ANY] with '0' chars inside, ie:
   
     const char def_namet[5] = {'h','o',0, 'l','a'};
   
  is not truncated to "ho". 
 */

SWIG_STATIC_INLINE PyObject *
SPyObj_FromCharArray(const char* carray, int len) {
  /* checking the effective size backward */
  for (; len && (carray[len - 1] == 0); --len);
  
  return PyString_FromStringAndSize(carray, len);
}

SWIG_STATIC_INLINE void
SPyObj_AsCharArray(PyObject *obj, char* carray, int size) { 
  int len = size;
  char* buf;
  PyString_AsStringAndSize(obj, &buf, &len);
  if (!PyErr_Occurred()) {
    if (len > size) {
      PyErr_SetObject(PyExc_TypeError, 
         PyString_FromFormat("a string of maximum size %d is required", size));
    } else {
      memcpy(carray, buf, len);
      /* pad the string with zero chars if needed */
      if (len < size) 
	memset(carray + len, 0, size - len);
    }
  }
}
 
SWIG_STATIC_INLINE int
SPyObj_AsBool(PyObject *obj) {
  return SPyObj_AsLongLong(obj) ?  1 : 0;
}

#ifdef __cplusplus
extern "C" {
#endif

#define SWIG_PY_INT     1
#define SWIG_PY_FLOAT   2
#define SWIG_PY_STRING  3
#define SWIG_PY_POINTER 4
#define SWIG_PY_BINARY  5

/* Flags for pointer conversion */

#define SWIG_POINTER_EXCEPTION     0x1
#define SWIG_POINTER_DISOWN        0x2

/* Exception handling in wrappers */
#define SWIG_fail   goto fail

/* Constant information structure */
typedef struct swig_const_info {
    int type;
    char *name;
    long lvalue;
    double dvalue;
    void   *pvalue;
    swig_type_info **ptype;
} swig_const_info;

/* Common SWIG API */
#define SWIG_ConvertPtr(obj, pp, type, flags) \
  SWIG_Python_ConvertPtr(obj, pp, type, flags)
#define SWIG_NewPointerObj(p, type, flags) \
  SWIG_Python_NewPointerObj(p, type, flags)
#define SWIG_MustGetPtr(p, type, argnum, flags) \
  SWIG_Python_MustGetPtr(p, type, argnum, flags)
 
/* Python-specific SWIG API */
#define SWIG_newvarlink() \
  SWIG_Python_newvarlink()
#define SWIG_addvarlink(p, name, get_attr, set_attr) \
  SWIG_Python_addvarlink(p, name, get_attr, set_attr)
#define SWIG_ConvertPacked(obj, ptr, sz, ty, flags) \
  SWIG_Python_ConvertPacked(obj, ptr, sz, ty, flags)
#define SWIG_NewPackedObj(ptr, sz, type) \
  SWIG_Python_NewPackedObj(ptr, sz, type)
#define SWIG_InstallConstants(d, constants) \
  SWIG_Python_InstallConstants(d, constants)

#ifdef SWIG_NOINCLUDE

SWIGIMPORT(int)               SWIG_Python_ConvertPtr(PyObject *, void **, swig_type_info *, int);
SWIGIMPORT(PyObject *)        SWIG_Python_NewPointerObj(void *, swig_type_info *,int own);
SWIGIMPORT(void *)            SWIG_Python_MustGetPtr(PyObject *, swig_type_info *, int, int);
SWIGIMPORT(PyObject *)        SWIG_Python_newvarlink(void);
SWIGIMPORT(void)              SWIG_Python_addvarlink(PyObject *, char *, PyObject *(*)(void), int (*)(PyObject *));
SWIGIMPORT(int)               SWIG_Python_ConvertPacked(PyObject *, void *, int sz, swig_type_info *, int);
SWIGIMPORT(PyObject *)        SWIG_Python_NewPackedObj(void *, int sz, swig_type_info *);
SWIGIMPORT(void)              SWIG_Python_InstallConstants(PyObject *d, swig_const_info constants[]);

#else

/* -----------------------------------------------------------------------------
 * global variable support code.
 * ----------------------------------------------------------------------------- */

typedef struct swig_globalvar {   
  char       *name;                  /* Name of global variable */
  PyObject *(*get_attr)(void);       /* Return the current value */
  int       (*set_attr)(PyObject *); /* Set the value */
  struct swig_globalvar *next;
} swig_globalvar;

typedef struct swig_varlinkobject {
  PyObject_HEAD
  swig_globalvar *vars;
} swig_varlinkobject;

static PyObject *
swig_varlink_repr(swig_varlinkobject *v) {
  v = v;
  return PyString_FromString("<Global variables>");
}

static int
swig_varlink_print(swig_varlinkobject *v, FILE *fp, int flags) {
  swig_globalvar  *var;
  flags = flags;
  fprintf(fp,"Global variables { ");
  for (var = v->vars; var; var=var->next) {
    fprintf(fp,"%s", var->name);
    if (var->next) fprintf(fp,", ");
  }
  fprintf(fp," }\n");
  return 0;
}

static PyObject *
swig_varlink_getattr(swig_varlinkobject *v, char *n) {
  swig_globalvar *var = v->vars;
  while (var) {
    if (strcmp(var->name,n) == 0) {
      return (*var->get_attr)();
    }
    var = var->next;
  }
  PyErr_SetString(PyExc_NameError,"Unknown C global variable");
  return NULL;
}

static int
swig_varlink_setattr(swig_varlinkobject *v, char *n, PyObject *p) {
  swig_globalvar *var = v->vars;
  while (var) {
    if (strcmp(var->name,n) == 0) {
      return (*var->set_attr)(p);
    }
    var = var->next;
  }
  PyErr_SetString(PyExc_NameError,"Unknown C global variable");
  return 1;
}

statichere PyTypeObject varlinktype = {
  PyObject_HEAD_INIT(0)              
  0,
  (char *)"swigvarlink",              /* Type name    */
  sizeof(swig_varlinkobject),         /* Basic size   */
  0,                                  /* Itemsize     */
  0,                                  /* Deallocator  */ 
  (printfunc) swig_varlink_print,     /* Print        */
  (getattrfunc) swig_varlink_getattr, /* get attr     */
  (setattrfunc) swig_varlink_setattr, /* Set attr     */
  0,                                  /* tp_compare   */
  (reprfunc) swig_varlink_repr,       /* tp_repr      */    
  0,                                  /* tp_as_number */
  0,                                  /* tp_as_mapping*/
  0,                                  /* tp_hash      */
};

/* Create a variable linking object for use later */
SWIGRUNTIME(PyObject *)
SWIG_Python_newvarlink(void) {
  swig_varlinkobject *result = 0;
  result = PyMem_NEW(swig_varlinkobject,1);
  varlinktype.ob_type = &PyType_Type;    /* Patch varlinktype into a PyType */
  result->ob_type = &varlinktype;
  result->vars = 0;
  result->ob_refcnt = 0;
  Py_XINCREF((PyObject *) result);
  return ((PyObject*) result);
}

SWIGRUNTIME(void)
SWIG_Python_addvarlink(PyObject *p, char *name, PyObject *(*get_attr)(void), int (*set_attr)(PyObject *p)) {
  swig_varlinkobject *v;
  swig_globalvar *gv;
  v= (swig_varlinkobject *) p;
  gv = (swig_globalvar *) malloc(sizeof(swig_globalvar));
  gv->name = (char *) malloc(strlen(name)+1);
  strcpy(gv->name,name);
  gv->get_attr = get_attr;
  gv->set_attr = set_attr;
  gv->next = v->vars;
  v->vars = gv;
}

/* Convert a pointer value */
SWIGRUNTIME(int)
SWIG_Python_ConvertPtr(PyObject *obj, void **ptr, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  char  *c = 0;
  static PyObject *SWIG_this = 0;
  int    newref = 0;
  PyObject  *pyobj = 0;

  if (!obj) return 0;
  if (obj == Py_None) {
    *ptr = 0;
    return 0;
  }
#ifdef SWIG_COBJECT_TYPES
  if (!(PyCObject_Check(obj))) {
    if (!SWIG_this)
      SWIG_this = PyString_FromString("this");
    pyobj = obj;
    obj = PyObject_GetAttr(obj,SWIG_this);
    newref = 1;
    if (!obj) goto type_error;
    if (!PyCObject_Check(obj)) {
      Py_DECREF(obj);
      goto type_error;
    }
  }  
  *ptr = PyCObject_AsVoidPtr(obj);
  c = (char *) PyCObject_GetDesc(obj);
  if (newref) Py_DECREF(obj);
  goto cobject;
#else
  if (!(PyString_Check(obj))) {
    if (!SWIG_this)
      SWIG_this = PyString_FromString("this");
    pyobj = obj;
    obj = PyObject_GetAttr(obj,SWIG_this);
    newref = 1;
    if (!obj) goto type_error;
    if (!PyString_Check(obj)) {
      Py_DECREF(obj);
      goto type_error;
    }
  } 
  c = PyString_AsString(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') {
    *ptr = (void *) 0;
    if (strcmp(c,"NULL") == 0) {
      if (newref) { Py_DECREF(obj); }
      return 0;
    } else {
      if (newref) { Py_DECREF(obj); }
      goto type_error;
    }
  }
  c++;
  c = SWIG_UnpackData(c,ptr,sizeof(void *));
  if (newref) { Py_DECREF(obj); }
#endif

#ifdef SWIG_COBJECT_TYPES
cobject:
#endif

  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
    *ptr = SWIG_TypeCast(tc,(void*) *ptr);
  }

  if ((pyobj) && (flags & SWIG_POINTER_DISOWN)) {
    PyObject *zero = PyInt_FromLong(0);
    PyObject_SetAttrString(pyobj,(char*)"thisown",zero);
    Py_DECREF(zero);
  }
  return 0;

type_error:
  if (flags & SWIG_POINTER_EXCEPTION) {
    if (ty && c) {
      char *temp = (char *) malloc(64+strlen(ty->name)+strlen(c));
      sprintf(temp,"Type error. Got %s, expected %s", c, ty->name);
      PyErr_SetString(PyExc_TypeError, temp);
      free((char *) temp);
    } else {
      PyErr_SetString(PyExc_TypeError,"Expected a pointer");
    }
  }
  return -1;
}

/* Convert a pointer value, signal an exception on a type mismatch */
SWIGRUNTIME(void *)
SWIG_Python_MustGetPtr(PyObject *obj, swig_type_info *ty, int argnum, int flags) {
  void *result;
  SWIG_Python_ConvertPtr(obj, &result, ty, flags | SWIG_POINTER_EXCEPTION);
  return result;
}

/* Convert a packed value value */
SWIGRUNTIME(int)
SWIG_Python_ConvertPacked(PyObject *obj, void *ptr, int sz, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  char  *c = 0;

  if ((!obj) || (!PyString_Check(obj))) goto type_error;
  c = PyString_AsString(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') goto type_error;
  c++;
  c = SWIG_UnpackData(c,ptr,sz);
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
  }
  return 0;

type_error:

  if (flags) {
    if (ty && c) {
      char *temp = (char *) malloc(64+strlen(ty->name)+strlen(c));
      sprintf(temp,"Type error. Got %s, expected %s", c, ty->name);
      PyErr_SetString(PyExc_TypeError, temp);
      free((char *) temp);
    } else {
      PyErr_SetString(PyExc_TypeError,"Expected a pointer");
    }
  }
  return -1;
}

/* Create a new pointer object */
SWIGRUNTIME(PyObject *)
SWIG_Python_NewPointerObj(void *ptr, swig_type_info *type, int own) {
  PyObject *robj;
  if (!ptr) {
    Py_INCREF(Py_None);
    return Py_None;
  }
#ifdef SWIG_COBJECT_TYPES
  robj = PyCObject_FromVoidPtrAndDesc((void *) ptr, (char *) type->name, NULL);
#else
  {
    char result[1024];
    char *r = result;
    *(r++) = '_';
    r = SWIG_PackData(r,&ptr,sizeof(void *));
    strcpy(r,type->name);
    robj = PyString_FromString(result);
  }
#endif
  if (!robj || (robj == Py_None)) return robj;
  if (type->clientdata) {
    PyObject *inst;
    PyObject *args = Py_BuildValue((char*)"(O)", robj);
    Py_DECREF(robj);
    inst = PyObject_CallObject((PyObject *) type->clientdata, args);
    Py_DECREF(args);
    if (inst) {
      if (own) {
        PyObject *n = PyInt_FromLong(1);
        PyObject_SetAttrString(inst,(char*)"thisown",n);
        Py_DECREF(n);
      }
      robj = inst;
    }
  }
  return robj;
}

SWIGRUNTIME(PyObject *)
SWIG_Python_NewPackedObj(void *ptr, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(type->name)) > 1000) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  strcpy(r,type->name);
  return PyString_FromString(result);
}

/* Install Constants */
SWIGRUNTIME(void)
SWIG_Python_InstallConstants(PyObject *d, swig_const_info constants[]) {
  int i;
  PyObject *obj;
  for (i = 0; constants[i].type; i++) {
    switch(constants[i].type) {
    case SWIG_PY_INT:
      obj = PyInt_FromLong(constants[i].lvalue);
      break;
    case SWIG_PY_FLOAT:
      obj = PyFloat_FromDouble(constants[i].dvalue);
      break;
    case SWIG_PY_STRING:
      obj = SPyObj_FromCharPtr((const char *) constants[i].pvalue);
      break;
    case SWIG_PY_POINTER:
      obj = SWIG_NewPointerObj(constants[i].pvalue, *(constants[i]).ptype,0);
      break;
    case SWIG_PY_BINARY:
      obj = SWIG_NewPackedObj(constants[i].pvalue, constants[i].lvalue, *(constants[i].ptype));
      break;
    default:
      obj = 0;
      break;
    }
    if (obj) {
      PyDict_SetItemString(d,constants[i].name,obj);
      Py_DECREF(obj);
    }
  }
}

#endif

/* Contract support */

#define SWIG_contract_assert(expr, msg) if (!(expr)) { PyErr_SetString(PyExc_RuntimeError, (char *) msg ); goto fail; } else

#ifdef __cplusplus
}
#endif
