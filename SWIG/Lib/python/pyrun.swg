/***********************************************************************
 * pyrun.swg
 *
 *     This file contains the runtime support for Python modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 * Author : David Beazley (beazley@cs.uchicago.edu)
 ************************************************************************/

/* Common SWIG API */

/* for raw pointers */
#define SWIG_Python_ConvertPtr(obj, pptr, type, flags)  SWIG_Python_ConvertPtrAndOwn(obj, pptr, type, flags, 0)
#define SWIG_ConvertPtr(obj, pptr, type, flags)         SWIG_Python_ConvertPtr(obj, pptr, type, flags)
#define SWIG_ConvertPtrAndOwn(obj,pptr,type,flags,own)  SWIG_Python_ConvertPtrAndOwn(obj, pptr, type, flags, own)
#define SWIG_NewPointerObj(ptr, type, flags)            SWIG_Python_NewPointerObj(ptr, type, flags)
#define SWIG_AcquirePtr(ptr, src)                       SWIG_Python_AcquirePtr(ptr, src)
#define swig_owntype                                    int

/* for raw packed data */
#define SWIG_ConvertPacked(obj, ptr, sz, ty)            SWIG_Python_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewPackedObj(ptr, sz, type)                SWIG_Python_NewPackedObj(ptr, sz, type)

/* for class or struct pointers */
#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(ptr, type, flags)           SWIG_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_Python_ConvertFunctionPtr(obj, pptr, type)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_Python_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_Python_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_Python_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define SWIG_GetModule(clientdata)                      SWIG_Python_GetModule()
#define SWIG_SetModule(clientdata, pointer)             SWIG_Python_SetModule(pointer)
#define SWIG_NewClientData(obj)                         PySwigClientData_New(obj)

/* Error manipulation */
#define SWIG_SetErrorObj(type, obj)            		{SWIG_PYTHON_THREAD_BEGIN_BLOCK; PyErr_SetObject(type, obj); SWIG_PYTHON_THREAD_END_BLOCK; }
#define SWIG_SetErrorMsg(type, msg)            		{SWIG_PYTHON_THREAD_BEGIN_BLOCK; PyErr_SetString(type, msg); SWIG_PYTHON_THREAD_END_BLOCK; }
#define SWIG_ErrorType(code)                            SWIG_Python_ErrorType(code)                       
#define SWIG_Error(code, msg)            		SWIG_SetErrorMsg(SWIG_Python_ErrorType(code), msg)
#define SWIG_fail                        		goto fail					   

/*
  Helper for static pointer initialization for both C and C++ code, for example
  static PyObject *SWIG_STATIC_POINTER(MyVar) = NewSomething(...);
*/
#ifdef __cplusplus
#define SWIG_STATIC_POINTER(var)  var
#else
#define SWIG_STATIC_POINTER(var)  var = 0; if (!var) var
#endif

/* -----------------------------------------------------------------------------
 * Pointer declarations
 * ----------------------------------------------------------------------------- */

/* Flags for new pointer objects */
#define SWIG_POINTER_NOSHADOW      SWIG_POINTER_OWN << 1
#define SWIG_POINTER_NEW           SWIG_POINTER_NOSHADOW | SWIG_POINTER_OWN

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0

#ifdef __cplusplus
extern "C" {
#if 0
} /* cc-mode */
#endif
#endif

/*  Safe Py_None and Py_Void accessors */

SWIGRUNTIME PyObject * 
_SWIG_Py_None(void)
{
  static PyObject *none = 0;
  if (!none) {
    none = Py_BuildValue("");
    Py_DECREF(none);
  }
  return none;
}

SWIGRUNTIMEINLINE PyObject * 
SWIG_Py_None(void)
{
  static PyObject *SWIG_STATIC_POINTER(none) = _SWIG_Py_None();
  return none;
}

SWIGRUNTIMEINLINE PyObject * 
SWIG_Py_Void(void)
{
  PyObject *none = SWIG_Py_None();
  Py_INCREF(none);
  return none;
}

/* Append a value to the result obj */

SWIGINTERN PyObject*
SWIG_Python_AppendOutput(PyObject* result, PyObject* obj) {
  if (!result) {
    result = obj;
  } else if (result == SWIG_Py_None()) {
    Py_DECREF(result);
    result = obj;
  } else {
    if (!PyList_Check(result)) {
      PyObject *o2 = result;
      result = PyList_New(1);
      PyList_SetItem(result, 0, o2);
    }
    PyList_Append(result,obj);
    Py_DECREF(obj);
  }
  return result;
}

SWIGINTERN int
SWIG_Python_UnpackTuple(PyObject *args, const char *name, int min, int max, PyObject **objs)
{    
  if (!PyTuple_Check(args)) {
    PyErr_SetString(PyExc_SystemError, "UnpackTuple() argument list is not a tuple");
    return 0;
  } else {
    int l = PyTuple_GET_SIZE(args);
    if (l < min) {
      PyErr_Format(PyExc_TypeError, "%s expected %s%d arguments, got %d", 
		   name, (min == max ? "" : "at least "), min, l);
      return 0;
    } else if (l > max) {
      PyErr_Format(PyExc_TypeError, "%s expected %s%d arguments, got %d", 
		   name, (min == max ? "" : "at most "), max, l);
      return 0;
    } else {
      register int i;
      for (i = 0; i < l; ++i) {
	objs[i] = PyTuple_GET_ITEM(args, i);
      }
    }    
    return 1;
  }
}

/* PySwigClientData */

typedef struct {
  PyObject *klass;
  PyObject *newraw;
  PyObject *newargs;
  PyObject *destroy;
#ifndef SWIG_PYTHON_FAST_PARSE
  PyObject *delargs;
#endif
} PySwigClientData;

SWIGRUNTIME PySwigClientData * 
PySwigClientData_New(PyObject* obj)
{
  if (!obj) {
    return 0;
  } else {
    PySwigClientData *data = (PySwigClientData *)malloc(sizeof(PySwigClientData));
    /* the klass element */
    data->klass = obj;
    Py_INCREF(obj);
    /* the newraw method and newargs arguments used to create a new raw instance */
    if (PyClass_Check(obj)) {
      data->newraw = 0;
      data->newargs = obj;
      Py_INCREF(obj);
    } else {
      data->newraw = PyObject_GetAttrString((PyObject*)&PyBaseObject_Type, "__new__");
      Py_INCREF(data->newraw);
      data->newargs = PyTuple_New(1);
      PyTuple_SetItem(data->newargs, 0, obj);
    }
    /* the destroy method, aka as the C++ delete method */
    data->destroy = PyObject_GetAttrString(data->klass, "__swig_destroy__");
    if (PyErr_Occurred()) {
      PyErr_Clear();
      data->destroy = 0;
    }
    Py_XINCREF(data->destroy);
#ifndef SWIG_PYTHON_FAST_PARSE
    data->delargs = PyTuple_New(1);
#endif
    return data;
  }
}

SWIGRUNTIME void 
PySwigClientData_Del(PySwigClientData* data)
{
  Py_XDECREF(data->klass);
  Py_XDECREF(data->newraw);
  Py_XDECREF(data->newargs);
  Py_XDECREF(data->destroy);
#ifndef SWIG_PYTHON_FAST_PARSE
  Py_XDECREF(data->delargs);
#endif
  free(data);
}

/* PySwigObject */

typedef struct {
  PyObject_HEAD
  void *ptr;
  swig_type_info *ty;
  int own;
  PyObject *next;
} PySwigObject;

SWIGRUNTIME PyObject *
PySwigObject_long(PySwigObject *v)
{
  return PyLong_FromVoidPtr(v->ptr);
}

SWIGRUNTIME PyObject *
PySwigObject_format(const char* fmt, PySwigObject *v)
{
  PyObject *res = NULL;
  PyObject *args = PyTuple_New(1);
  if (args) {
    if (PyTuple_SetItem(args, 0, PySwigObject_long(v)) == 0) {
      PyObject *ofmt = PyString_FromString(fmt);
      if (ofmt) {
	res = PyString_Format(ofmt,args);
	Py_DECREF(ofmt);
      }
      Py_DECREF(args);
    }
  }
  return res;
}

SWIGRUNTIME PyObject *
PySwigObject_oct(PySwigObject *v)
{
  return PySwigObject_format("%o",v);
}

SWIGRUNTIME PyObject *
PySwigObject_hex(PySwigObject *v)
{
  return PySwigObject_format("%x",v);
}

SWIGRUNTIME PyObject *
PySwigObject_repr(PySwigObject *v)
{
  const char *name = SWIG_TypePrettyName(v->ty);
  PyObject *hex = PySwigObject_hex(v);    
  PyObject *repr = PyString_FromFormat("<Swig Object of type '%s' at 0x%s>", name, PyString_AsString(hex));
  Py_DECREF(hex);
  if (v->next) {
    PyObject *nrep = PySwigObject_repr((PySwigObject *)v->next);
    PyString_ConcatAndDel(&repr,nrep);
  }
  return repr;  
}

SWIGRUNTIME int
PySwigObject_print(PySwigObject *v, FILE *fp, int SWIGUNUSEDPARM(flags))
{
  PyObject *repr = PySwigObject_repr(v);
  if (repr) {
    fputs(PyString_AsString(repr), fp);
    Py_DECREF(repr);
    return 0; 
  } else {
    return 1; 
  }
}

SWIGRUNTIME PyObject *
PySwigObject_str(PySwigObject *v)
{
  char result[SWIG_BUFFER_SIZE];
  return SWIG_PackVoidPtr(result, v->ptr, v->ty->name, sizeof(result)) ?
    PyString_FromString(result) : 0;
}

SWIGRUNTIME int
PySwigObject_compare(PySwigObject *v, PySwigObject *w)
{
  void *i = v->ptr;
  void *j = w->ptr;
  return (i < j) ? -1 : ((i > j) ? 1 : 0);
}

SWIGRUNTIME PyTypeObject* _PySwigObject_type(void);

SWIGRUNTIMEINLINE PyTypeObject*
PySwigObject_type(void) {
  static PyTypeObject *SWIG_STATIC_POINTER(type) = _PySwigObject_type();
  return type;
}

SWIGRUNTIMEINLINE int
PySwigObject_Check(PyObject *op) {
  return ((op)->ob_type == PySwigObject_type()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigObject") == 0);
}

SWIGRUNTIME void
PySwigObject_dealloc(PyObject *v)
{
  PySwigObject *sobj = (PySwigObject *) v;
  PyObject *next = sobj->next;
  if (sobj->own) {
    swig_type_info *ty = sobj->ty;
    PySwigClientData *data = ty ? (PySwigClientData *) ty->clientdata : 0;
    PyObject *destroy = data ? data->destroy : 0;
    if (destroy) {
      /* destroy is always a VARARGS method */
      PyObject *res;
      PyCFunction meth = PyCFunction_GET_FUNCTION(destroy);
#ifdef SWIG_PYTHON_FAST_PARSE
      res = ((*meth)(PyCFunction_GET_SELF(destroy), v));
#else
      PyObject *args = data->delargs;
      PyTuple_SetItem(args,0,v);
      res = ((*meth)(PyCFunction_GET_SELF(destroy), args));
      PyTuple_SetItem(args,0,SWIG_Py_Void());
#endif
      Py_XDECREF(res);
    } else {
      const char *name = SWIG_TypePrettyName(ty);
      PyObject *wrn = PyString_FromFormat("swig/python detected a memory leak of type '%s'.", name);
      PyErr_Warn(PyExc_RuntimeWarning, PyString_AsString(wrn));
      Py_DECREF(wrn);
    }
  } 
  Py_XDECREF(next);
  v->ob_type->tp_free(v);
}

SWIGRUNTIME PyObject* 
PySwigObject_append(PyObject* v, PyObject* next)
{
  PySwigObject *sobj = (PySwigObject *) v;
  if (!PySwigObject_Check(next)) {
    return NULL;
  }
  sobj->next = next;
  Py_INCREF(next);
  return SWIG_Py_Void();
}

SWIGRUNTIME PyObject* 
PySwigObject_next(PyObject* v)
{
  PySwigObject *sobj = (PySwigObject *) v;
  if (sobj->next) {    
    Py_INCREF(sobj->next);
    return sobj->next;
  } else {
    return SWIG_Py_Void();
  }
}

SWIGINTERN PyObject*
PySwigObject_disown(PyObject *v)
{
  PySwigObject *sobj = (PySwigObject *)v;
  sobj->own = 0;
  return SWIG_Py_Void();
}

SWIGINTERN PyObject*
PySwigObject_acquire(PyObject *v)
{
  PySwigObject *sobj = (PySwigObject *)v;
  sobj->own = SWIG_POINTER_OWN;
  return SWIG_Py_Void();
}

SWIGINTERN PyObject*
PySwigObject_own(PyObject *v, PyObject *args)
{
  PyObject *val = 0;
  if (!PyArg_UnpackTuple(args, "own", 0, 1, &val)) {
    return NULL;
  } else {
    PySwigObject *sobj = (PySwigObject *)v;
    PyObject *obj = sobj->own ? Py_True : Py_False;
    if (val) {
      if (PyObject_IsTrue(val)) {
	PySwigObject_acquire(v);
      } else {
	PySwigObject_disown(v);
      }
    } 
    Py_INCREF(obj);
    return obj;
  }
}

SWIGRUNTIME PyTypeObject*
_PySwigObject_type(void) {
  static char swigobject_doc[] = "Swig object carries a C/C++ instance pointer";
  static PyMethodDef
    swigobject_methods[] = {
      {"disown",  (PyCFunction)PySwigObject_disown,  METH_NOARGS,  "releases ownership of the pointer"},
      {"acquire", (PyCFunction)PySwigObject_acquire, METH_NOARGS,  "aquires ownership of the pointer"},
      {"own",     (PyCFunction)PySwigObject_own,     METH_VARARGS, "returns/sets ownership of the pointer"},
      {"append",  (PyCFunction)PySwigObject_append,  METH_O,       "appends another 'this' object"},
      {"next",    (PyCFunction)PySwigObject_next,    METH_NOARGS,  "returns the next 'this' object"},
      {0, 0, 0, 0}  
    };
  
  static PyNumberMethods PySwigObject_as_number = {
    (binaryfunc)0, /*nb_add*/
    (binaryfunc)0, /*nb_subtract*/
    (binaryfunc)0, /*nb_multiply*/
    (binaryfunc)0, /*nb_divide*/
    (binaryfunc)0, /*nb_remainder*/
    (binaryfunc)0, /*nb_divmod*/
    (ternaryfunc)0,/*nb_power*/
    (unaryfunc)0,  /*nb_negative*/
    (unaryfunc)0,  /*nb_positive*/
    (unaryfunc)0,  /*nb_absolute*/
    (inquiry)0,    /*nb_nonzero*/
    0,		   /*nb_invert*/
    0,		   /*nb_lshift*/
    0,		   /*nb_rshift*/
    0,		   /*nb_and*/
    0,		   /*nb_xor*/
    0,		   /*nb_or*/
    (coercion)0,   /*nb_coerce*/
    (unaryfunc)PySwigObject_long, /*nb_int*/
    (unaryfunc)PySwigObject_long, /*nb_long*/
    (unaryfunc)0,                 /*nb_float*/
    (unaryfunc)PySwigObject_oct,  /*nb_oct*/
    (unaryfunc)PySwigObject_hex,  /*nb_hex*/
#if PY_VERSION_HEX >= 0x02020000
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /* nb_inplace_add -> nb_inplace_true_divide */ 
#elif PY_VERSION_HEX >= 0x02000000
    0,0,0,0,0,0,0,0,0,0,0 /* nb_inplace_add -> nb_inplace_or */
#endif
  };

  static PyTypeObject pyswigobject_type;  
  static int type_init = 0;
  if (!type_init) {
    const PyTypeObject tmp
      = {
	PyObject_HEAD_INIT(NULL)
	0,				    /* ob_size */
	(char *)"PySwigObject",		    /* tp_name */
	sizeof(PySwigObject),		    /* tp_basicsize */
	0,			            /* tp_itemsize */
	(destructor)PySwigObject_dealloc,   /* tp_dealloc */
	(printfunc)PySwigObject_print,	    /* tp_print */   
	(getattrfunc)0,			    /* tp_getattr */ 
	(setattrfunc)0,			    /* tp_setattr */ 
	(cmpfunc)PySwigObject_compare,	    /* tp_compare */ 
	(reprfunc)PySwigObject_repr,	    /* tp_repr */    
	&PySwigObject_as_number,	    /* tp_as_number */
	0,				    /* tp_as_sequence */
	0,				    /* tp_as_mapping */
	(hashfunc)0,			    /* tp_hash */
	(ternaryfunc)0,			    /* tp_call */
	(reprfunc)PySwigObject_str,	    /* tp_str */
	PyObject_GenericGetAttr,	    /* tp_getattro */
	0,				    /* tp_setattro */
	0,		                    /* tp_as_buffer */
	Py_TPFLAGS_DEFAULT,	            /* tp_flags */
	swigobject_doc, 	            /* tp_doc */        
	0,                                  /* tp_traverse */
	0,                                  /* tp_clear */
	0,                                  /* tp_richcompare */
	0,                                  /* tp_weaklistoffset */
#if PY_VERSION_HEX >= 0x02020000
	0,                                  /* tp_iter */
	0,                                  /* tp_iternext */
	swigobject_methods,		    /* tp_methods */ 
	0,			            /* tp_members */
	0,				    /* tp_getset */	    	
	0,			            /* tp_base */	        
	0,				    /* tp_dict */	    	
	0,				    /* tp_descr_get */  	
	0,				    /* tp_descr_set */  	
	0,				    /* tp_dictoffset */ 	
	0,				    /* tp_init */	    	
	0,				    /* tp_alloc */	    	
	0,			            /* tp_new */	    	
	PyObject_Del,	                    /* tp_free */	   
        0,                                  /* tp_is_gc */  
	0,				    /* tp_bases */   
	0,				    /* tp_mro */
	0,				    /* tp_cache */   
 	0,				    /* tp_subclasses */
	0,				    /* tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
	0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
	0,0,0,0                             /* tp_alloc -> tp_next */
#endif
      };
    pyswigobject_type = tmp;
    pyswigobject_type.ob_type = &PyType_Type;
    type_init = 1;
  }
  return &pyswigobject_type;
}

SWIGRUNTIMEINLINE PyObject *
PySwigObject_New(void *ptr, swig_type_info *ty, int own)
{
  PySwigObject *sobj = PyObject_NEW(PySwigObject, PySwigObject_type());
  if (sobj) {
    sobj->ptr  = ptr;
    sobj->ty   = ty;
    sobj->own  = own;
    sobj->next = 0;
  }
  return (PyObject *)sobj;
}

/* -----------------------------------------------------------------------------
 * Implements a simple Swig Packed type, and use it instead of string
 * ----------------------------------------------------------------------------- */

typedef struct {
  PyObject_HEAD
  void *pack;
  swig_type_info *ty;
  size_t size;
} PySwigPacked;

SWIGRUNTIME int
PySwigPacked_print(PySwigPacked *v, FILE *fp, int SWIGUNUSEDPARM(flags))
{
  char result[SWIG_BUFFER_SIZE];
  fputs("<Swig Packed ", fp); 
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    fputs("at ", fp); 
    fputs(result, fp); 
  }
  fputs(v->ty->name,fp); 
  fputs(">", fp);
  return 0; 
}
  
SWIGRUNTIME PyObject *
PySwigPacked_repr(PySwigPacked *v)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    return PyString_FromFormat("<Swig Packed at %s%s>", result, v->ty->name);
  } else {
    return PyString_FromFormat("<Swig Packed %s>", v->ty->name);
  }  
}

SWIGRUNTIME PyObject *
PySwigPacked_str(PySwigPacked *v)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))){
    return PyString_FromFormat("%s%s", result, v->ty->name);
  } else {
    return PyString_FromString(v->ty->name);
  }  
}

SWIGRUNTIME int
PySwigPacked_compare(PySwigPacked *v, PySwigPacked *w)
{
  size_t i = v->size;
  size_t j = w->size;
  int s = (i < j) ? -1 : ((i > j) ? 1 : 0);
  return s ? s : strncmp((char *)v->pack, (char *)w->pack, 2*v->size);
}

SWIGRUNTIME PyTypeObject* _PySwigPacked_type(void);

SWIGRUNTIMEINLINE PyTypeObject*
PySwigPacked_type(void) {
  static PyTypeObject *SWIG_STATIC_POINTER(type) = _PySwigPacked_type();
  return type;
}

SWIGRUNTIMEINLINE int
PySwigPacked_Check(PyObject *op) {
  return ((op)->ob_type == _PySwigPacked_type()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigPacked") == 0);
}

SWIGRUNTIME void
PySwigPacked_dealloc(PyObject *v)
{
  if (PySwigPacked_Check(v)) {
    PySwigPacked *sobj = (PySwigPacked *) v;
    free(sobj->pack);
  }
  v->ob_type->tp_free(v);
}

SWIGRUNTIME PyTypeObject*
_PySwigPacked_type(void) {
  static char swigpacked_doc[] = "Swig object carries a C/C++ instance pointer";
  static PyTypeObject pyswigpacked_type;
  static int type_init = 0;  
  if (!type_init) {
    const PyTypeObject tmp
      = {
	PyObject_HEAD_INIT(NULL)
	0,				    /* ob_size */	
	(char *)"PySwigPacked",		    /* tp_name */	
	sizeof(PySwigPacked),		    /* tp_basicsize */	
	0,				    /* tp_itemsize */	
	(destructor)PySwigPacked_dealloc,   /* tp_dealloc */	
	(printfunc)PySwigPacked_print,	    /* tp_print */   	
	(getattrfunc)0,			    /* tp_getattr */ 	
	(setattrfunc)0,			    /* tp_setattr */ 	
	(cmpfunc)PySwigPacked_compare,	    /* tp_compare */ 	
	(reprfunc)PySwigPacked_repr,	    /* tp_repr */    	
	0,	                            /* tp_as_number */	
	0,				    /* tp_as_sequence */
	0,				    /* tp_as_mapping */	
	(hashfunc)0,			    /* tp_hash */	
	(ternaryfunc)0,			    /* tp_call */	
	(reprfunc)PySwigPacked_str,	    /* tp_str */	
	PyObject_GenericGetAttr,	    /* tp_getattro */
	0,				    /* tp_setattro */
	0,		                    /* tp_as_buffer */
	Py_TPFLAGS_DEFAULT,	            /* tp_flags */
	swigpacked_doc, 	            /* tp_doc */
	0,                                  /* tp_traverse */
	0,                                  /* tp_clear */
	0,                                  /* tp_richcompare */
	0,                                  /* tp_weaklistoffset */
#if PY_VERSION_HEX >= 0x02020000
	0,                                  /* tp_iter */
	0,                                  /* tp_iternext */
	0,		                    /* tp_methods */ 
	0,			            /* tp_members */
	0,				    /* tp_getset */	    	
	0,			            /* tp_base */	        
	0,				    /* tp_dict */	    	
	0,				    /* tp_descr_get */  	
	0,				    /* tp_descr_set */  	
	0,				    /* tp_dictoffset */ 	
	0,				    /* tp_init */	    	
	0,				    /* tp_alloc */	    	
	0,			            /* tp_new */	    	
	PyObject_Del, 	                    /* tp_free */	   
        0,                                  /* tp_is_gc */  
	0,				    /* tp_bases */   
	0,				    /* tp_mro */
	0,				    /* tp_cache */   
 	0,				    /* tp_subclasses */
	0,				    /* tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
	0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
	0,0,0,0                             /* tp_alloc -> tp_next */
#endif
      };
    pyswigpacked_type = tmp;
    pyswigpacked_type.ob_type = &PyType_Type;
    type_init = 1;
  }
  return &pyswigpacked_type;
}

SWIGRUNTIME PyObject *
PySwigPacked_New(void *ptr, size_t size, swig_type_info *ty)
{
  PySwigPacked *sobj = PyObject_NEW(PySwigPacked, PySwigPacked_type());
  if (sobj) {
    void *pack = malloc(size);
    if (pack) {
      memcpy(pack, ptr, size);
      sobj->pack = pack;
      sobj->ty   = ty;
      sobj->size = size;
    } else {
      PyObject_DEL((PyObject *) sobj);
      sobj = 0;
    }
  }
  return (PyObject *) sobj;
}

SWIGRUNTIMEINLINE swig_type_info *
PySwigPacked_UnpackData(PyObject *obj, void *ptr, size_t size)
{
  if (PySwigPacked_Check(obj)) {
    PySwigPacked *sobj = (PySwigPacked *)obj;
    if (sobj->size != size) return 0;
    memcpy(ptr, sobj->pack, size);
    return sobj->ty;
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

SWIGRUNTIME PyObject *
_SWIG_This(void)
{
  static PyObject *_this = 0;
  if (!_this) {
    _this = PyString_FromString("this");
  }
  return _this;
}

SWIGRUNTIMEINLINE PyObject *
SWIG_This(void)
{
  static PyObject *SWIG_STATIC_POINTER(swig_this) = _SWIG_This();
  return swig_this;
}

/* #define SWIG_PYTHON_SLOW_GETSET_THIS */

SWIGRUNTIMEINLINE PySwigObject *
SWIG_Python_GetSwigThis(PyObject *pyobj) 
{
  if (PySwigObject_Check(pyobj)) {
    return (PySwigObject *) pyobj;
  } else {
    PyObject *obj;
#ifndef SWIG_PYTHON_SLOW_GETSET_THIS
    if (PyInstance_Check(pyobj)) {
      obj = _PyInstance_Lookup(pyobj, SWIG_This());
    } else {
      PyObject **dictptr = _PyObject_GetDictPtr(pyobj);
      if (dictptr != NULL) {
	PyObject *dict = *dictptr;
	obj = dict ? PyDict_GetItem(dict, SWIG_This()) : 0;
      } else {
	obj = PyObject_GetAttr(pyobj,SWIG_This());
	Py_XDECREF(obj);
      }
    } 
#else
    obj = PyObject_GetAttr(pyobj,SWIG_This());
    Py_XDECREF(obj);
#endif
    if (!obj) {
      if (PyErr_Occurred()) PyErr_Clear();
      return 0;
    }
    return (PySwigObject *)obj;
  }
}

/* Acquire a pointer value */

SWIGRUNTIME int
SWIG_Python_AcquirePtr(PyObject *obj, int own) {
  if (own) {
    PySwigObject *sobj = SWIG_Python_GetSwigThis(obj);
    if (sobj) {
      int oldown = sobj->own;
      sobj->own = own;
      return oldown;
    }
  }
  return 0;
}

/* Convert a pointer value */

SWIGRUNTIME int
SWIG_Python_ConvertPtrAndOwn(PyObject *obj, void **ptr, swig_type_info *ty, int flags, int *own) {
  if (!obj) return SWIG_ERROR;
  if (obj == SWIG_Py_None()) {
    if (ptr) *ptr = 0;
    return SWIG_OK;
  } else {
    PySwigObject *sobj = SWIG_Python_GetSwigThis(obj);
    while (sobj) {
      void *vptr = sobj->ptr;
      if (ty) {
	swig_type_info *to = sobj->ty;
	if (to == ty) {
	  /* no type cast needed */
	  if (ptr) *ptr = vptr;
	  break;
	} else {
	  swig_cast_info *tc = SWIG_TypeCheck(to->name,ty);
	  if (!tc) {
	    sobj = (PySwigObject *)sobj->next;
	  } else {
	    *ptr = SWIG_TypeCast(tc,vptr);
	    break;
	  }
	}
      } else {
	if (ptr) *ptr = vptr;
	break;
      }
    }
    if (sobj) {
      if (own) *own = sobj->own;
      if (flags & SWIG_POINTER_DISOWN) {
	sobj->own = 0;
      }
      return SWIG_OK;
    } else {
      return SWIG_ERROR;
    }
  }
}

/* Convert a function ptr value */

SWIGRUNTIME int
SWIG_Python_ConvertFunctionPtr(PyObject *obj, void **ptr, swig_type_info *ty) {
  if (!PyCFunction_Check(obj)) {
    return SWIG_ConvertPtr(obj, ptr, ty, 0);
  } else {
    void *vptr = 0;
    
    /* here we get the method pointer for callbacks */
    char *doc = (((PyCFunctionObject *)obj) -> m_ml -> ml_doc);
    const char *desc = doc ? strstr(doc, "swig_ptr: ") : 0;
    if (desc) {
      desc = ty ? SWIG_UnpackVoidPtr(desc + 10, &vptr, ty->name) : 0;
      if (!desc) return SWIG_ERROR;
    }
    if (ty) {
      swig_cast_info *tc = SWIG_TypeCheck(desc,ty);
      if (!tc) return SWIG_ERROR;
      *ptr = SWIG_TypeCast(tc,vptr);
    } else {
      *ptr = vptr;
    }
    return SWIG_OK;
  }
}

/* Convert a packed value value */

SWIGRUNTIME int
SWIG_Python_ConvertPacked(PyObject *obj, void *ptr, size_t sz, swig_type_info *ty) {
  swig_type_info *to = PySwigPacked_UnpackData(obj, ptr, sz);
  if (!to) return SWIG_ERROR;
  if (ty) {
    if (to != ty) {
      /* check type cast? */
      swig_cast_info *tc = SWIG_TypeCheck(to->name,ty);
      if (!tc) return SWIG_ERROR;
    }
  }
  return SWIG_OK;
}  

/* -----------------------------------------------------------------------------
 * Create a new pointer object
 * ----------------------------------------------------------------------------- */

/*
  Create a new instance object, whitout calling __init__, and set the
  'this' attribute.
*/

SWIGRUNTIMEINLINE PyObject* 
SWIG_Python_NewShadowInstance(PySwigClientData *data, PyObject *swig_this)
{
  PyObject *inst = 0;
  PyObject *newraw = data->newraw;
  if (newraw) {
#ifdef SWIG_USE_GENERAL_NEW_CALL
    inst = PyCFunction_Call(newraw, data->newargs, NULL);
#else
    /* 'tp_new_wrapper' is a METH_KEYWORDS function */
    PyCFunctionWithKeywords meth = (PyCFunctionWithKeywords) PyCFunction_GET_FUNCTION(newraw);
    inst = (*meth)(PyCFunction_GET_SELF(newraw), data->newargs, NULL);
#endif
    if (inst) {
#ifndef SWIG_PYTHON_SLOW_GETSET_THIS
      PyObject **dictptr = _PyObject_GetDictPtr(inst);
      if (dictptr != NULL) {
	PyObject *dict = *dictptr;
	if (dict == NULL) {
	  dict = PyDict_New();
	  *dictptr = dict;
	  PyDict_SetItem(dict, SWIG_This(), swig_this);
	}
      }      
#else
      PyObject *key = SWIG_This();
      PyObject_SetAttr(inst, key, swig_this);
#endif
    }
  } else {
    PyObject *dict = PyDict_New();
    PyDict_SetItem(dict, SWIG_This(), swig_this);
    inst = PyInstance_NewRaw(data->newargs, dict);
    Py_DECREF(dict);
  }
  return inst;
}

/* Create a new pointer object */

SWIGRUNTIME PyObject *
SWIG_Python_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  if (!ptr) {
    return SWIG_Py_Void();
  } else {
    int own = (flags & SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;
    PyObject *robj = PySwigObject_New(ptr, type, own);
    PySwigClientData *clientdata = type ? (PySwigClientData *)(type->clientdata) : 0;
    if (clientdata && !(flags & SWIG_POINTER_NOSHADOW)) {
      PyObject *inst = SWIG_Python_NewShadowInstance(clientdata, robj);
      if (inst) {
	Py_DECREF(robj);
	robj = inst;
      }
    }
    return robj;
  }
}

/* Create a new packed object */

SWIGRUNTIMEINLINE PyObject *
SWIG_Python_NewPackedObj(void *ptr, size_t sz, swig_type_info *type) {
  return ptr ? PySwigPacked_New((void *) ptr, sz, type) : SWIG_Py_Void();
}

/* -----------------------------------------------------------------------------*
 *  Get type list 
 * -----------------------------------------------------------------------------*/

#ifdef SWIG_LINK_RUNTIME
void *SWIG_ReturnGlobalTypeList(void *);
#endif

SWIGRUNTIME swig_module_info *
SWIG_Python_GetModule(void) {
  static void *type_pointer = (void *)0;
  /* first check if module already created */
  if (!type_pointer) {
#ifdef SWIG_LINK_RUNTIME
    type_pointer = SWIG_ReturnGlobalTypeList((void *)0);
#else
    type_pointer = PyCObject_Import((char*)"swig_runtime_data" SWIG_RUNTIME_VERSION,
				    (char*)"type_pointer" SWIG_TYPE_TABLE_NAME);
    if (PyErr_Occurred()) {
      PyErr_Clear();
      type_pointer = (void *)0;
    }
#endif
  }
  return (swig_module_info *) type_pointer;
}

#if PY_MAJOR_VERSION < 2
/* PyModule_AddObject function was introduced in Python 2.0.  The following function
   is copied out of Python/modsupport.c in python version 2.3.4 */
SWIGINTERN int
PyModule_AddObject(PyObject *m, char *name, PyObject *o)
{
  PyObject *dict;
  if (!PyModule_Check(m)) {
    PyErr_SetString(PyExc_TypeError,
		    "PyModule_AddObject() needs module as first arg");
    return SWIG_ERROR;
  }
  if (!o) {
    PyErr_SetString(PyExc_TypeError,
		    "PyModule_AddObject() needs non-NULL value");
    return SWIG_ERROR;
  }
  
  dict = PyModule_GetDict(m);
  if (dict == NULL) {
    /* Internal error -- modules must have a dict! */
    PyErr_Format(PyExc_SystemError, "module '%s' has no __dict__",
		 PyModule_GetName(m));
    return SWIG_ERROR;
  }
  if (PyDict_SetItemString(dict, name, o))
    return SWIG_ERROR;
  Py_DECREF(o);
  return SWIG_OK;
}
#endif

SWIGRUNTIME void
SWIG_Python_DestroyModule(void *vptr)
{
  swig_module_info *swig_module = (swig_module_info *) vptr;
  swig_type_info **types = swig_module->types;
  size_t i;
  for (i =0; i < swig_module->size; ++i) {
    swig_type_info *ty = types[i];
    if (ty->owndata) {
      PySwigClientData *data = (PySwigClientData *) ty->clientdata;
      if (data) PySwigClientData_Del(data);
      ty->clientdata = 0;
    }
  }
  Py_DECREF(SWIG_This());
}

SWIGRUNTIME void
SWIG_Python_SetModule(swig_module_info *swig_module) {
  static PyMethodDef swig_empty_runtime_method_table[] = { {NULL, NULL, 0, NULL} };/* Sentinel */

  PyObject *module = Py_InitModule((char*)"swig_runtime_data" SWIG_RUNTIME_VERSION,
				   swig_empty_runtime_method_table);
  PyObject *pointer = PyCObject_FromVoidPtr((void *) swig_module, SWIG_Python_DestroyModule);
  if (pointer && module) {
    PyModule_AddObject(module, (char*)"type_pointer" SWIG_TYPE_TABLE_NAME, pointer);
  }
}

#ifdef __cplusplus
#if 0
{ /* cc-mode */
#endif
}
#endif
