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
#define SWIG_ConvertPtr(obj, pp, type, flags)    SWIG_Python_ConvertPtr(obj, pp, type, flags)
#define SWIG_NewPointerObj(p, type, flags)       SWIG_Python_NewPointerObj(p, type, flags)
#define SWIG_MustGetPtr(p, type, argnum, flags)  SWIG_Python_MustGetPtr(p, type, argnum, flags)
 

/* Python-specific SWIG API */
#define SWIG_ConvertPacked(obj, ptr, sz, ty, flags)   SWIG_Python_ConvertPacked(obj, ptr, sz, ty, flags)
#define SWIG_NewPackedObj(ptr, sz, type)              SWIG_Python_NewPackedObj(ptr, sz, type)


/* -----------------------------------------------------------------------------
 * Pointer declarations
 * ----------------------------------------------------------------------------- */
/*
  Use SWIG_NO_COBJECT_TYPES to force the use of strings to represent
  C/C++ pointers in the python side. Very useful for debugging, but
  not always safe.
*/
#if !defined(SWIG_NO_COBJECT_TYPES) && !defined(SWIG_COBJECT_TYPES)
#  define SWIG_COBJECT_TYPES
#endif

/* Flags for pointer conversion */
#define SWIG_POINTER_EXCEPTION     0x1
#define SWIG_POINTER_DISOWN        0x2


#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------------
 * Create a new pointer string 
 * ----------------------------------------------------------------------------- */


#if defined(SWIG_COBJECT_TYPES)
#if !defined(SWIG_COBJECT_PYTHON)
/* -----------------------------------------------------------------------------
 * Implements a simple Swig Object type, and use it instead of PyCObject
 * ----------------------------------------------------------------------------- */

typedef struct {
  PyObject_HEAD
  void *ptr;
  char *desc;
} PySwigObject;

/* Declarations for objects of type PySwigObject */

SWIGRUNTIME int
PySwigObject_print(PySwigObject *v, FILE *fp, int flags)
{
  char result[1024];
  if (SWIG_PackVoidPtr(result, v->ptr, v->desc, 1024)) {
    fputs("<Swig Object at ", fp); fputs(result, fp); fputs(">", fp);
    return 0; 
  } else {
    return 1; 
  }
}
  
SWIGRUNTIME PyObject *
PySwigObject_repr(PySwigObject *v)
{
  char result[1024];
  return SWIG_PackVoidPtr(result, v->ptr, v->desc, 1024) ?
    PyString_FromFormat("<Swig Object at %s>", result) : 0;
}

SWIGRUNTIME PyObject *
PySwigObject_str(PySwigObject *v)
{
  char result[1024];
  return SWIG_PackVoidPtr(result, v->ptr, v->desc, 1024) ?
    PyString_FromString(result) : 0;
}

SWIGRUNTIME PyObject *
PySwigObject_long(PySwigObject *v)
{
  return PyLong_FromUnsignedLong((unsigned long) v->ptr);
}

SWIGRUNTIME int
PySwigObject_compare(PySwigObject *v, PySwigObject *w)
{
  int c = strcmp(v->desc, w->desc);
  if (c) {
    return c;
  } else {
    void *i = v->ptr;
    void *j = w->ptr;
    return (i < j) ? -1 : (i > j) ? 1 : 0;
  }
}

SWIGRUNTIME void
PySwigObject_dealloc(PySwigObject *self)
{
  PyObject_DEL(self);
}

SWIGRUNTIME PyTypeObject*
PySwigObject_GetType() {
  static char PySwigObject_Type__doc__[] = 
    "Swig object carries a C/C++ instance pointer";
  
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
    0,		 /*nb_invert*/
    0,		 /*nb_lshift*/
    0,		 /*nb_rshift*/
    0,		 /*nb_and*/
    0,		 /*nb_xor*/
    0,		 /*nb_or*/
    (coercion)0,   /*nb_coerce*/
    (unaryfunc)PySwigObject_long,  /*nb_int*/
    (unaryfunc)PySwigObject_long, /*nb_long*/
    (unaryfunc)0,  /*nb_float*/
    0,		 /* nb_oct */
    0,		 /* nb_hex */
    0,		 /* nb_inplace_add */
    0,		 /* nb_inplace_subtract */
    0,		 /* nb_inplace_multiply */
    0,		 /* nb_inplace_divide */
    0,		 /* nb_inplace_remainder */
    0, 		 /* nb_inplace_power */
    0,		 /* nb_inplace_lshift */
    0,		 /* nb_inplace_rshift */
    0,		 /* nb_inplace_and */
    0,		 /* nb_inplace_xor */
    0,		 /* nb_inplace_or */
    0,           /* nb_floor_divide */
    0,	         /* nb_true_divide */
    0,		 /* nb_inplace_floor_divide */
    0,		 /* nb_inplace_true_divide */
  };
  
  static PyTypeObject PySwigObject_Type = {
    PyObject_HEAD_INIT(&PyType_Type)
    0,					/*ob_size*/
    "PySwigObject",			/*tp_name*/
    sizeof(PySwigObject),		/*tp_basicsize*/
    0,					/*tp_itemsize*/
    /* methods */
    (destructor)PySwigObject_dealloc,	/*tp_dealloc*/
    (printfunc)PySwigObject_print,	/*tp_print*/
    (getattrfunc)0,			/*tp_getattr*/
    (setattrfunc)0,			/*tp_setattr*/
    (cmpfunc)PySwigObject_compare,	/*tp_compare*/
    (reprfunc)PySwigObject_repr,	/*tp_repr*/
    &PySwigObject_as_number,	        /*tp_as_number*/
    0,					/*tp_as_sequence*/
    0,					/*tp_as_mapping*/
    (hashfunc)0,			/*tp_hash*/
    (ternaryfunc)0,			/*tp_call*/
    (reprfunc)PySwigObject_str,		/*tp_str*/
    /* Space for future expansion */
    0L,0L,0L,0L,
    PySwigObject_Type__doc__, 	        /* Documentation string */
    0,                                  /* tp_traverse */
    0,                                  /* tp_clear */
    0,                                  /* tp_richcompare */
    0,                                  /* tp_weaklistoffset */
#if PY_VERSION_HEX >= 0x02020000
    0,                                  /* tp_iter */
    0,                                  /* tp_iternext */
    0,                                  /* tp_methods */
    0,                                  /* tp_members */
    0,                                  /* tp_getset */
    0,                                  /* tp_base */
    0,                                  /* tp_dict */
    0,                                  /* tp_descr_get */
    0,                                  /* tp_descr_set */
    0,                                  /* tp_dictoffset */
    0,                                  /* tp_init */
    0,                                  /* tp_alloc */
    0,                                  /* tp_new */
    0,                                  /* tp_free */
    0,                                  /* tp_is_gc */
    0,                                  /* tp_bases */
    0,                                  /* tp_mro */
    0,                                  /* tp_cache */
    0,                                  /* tp_subclasses */
    0,                                  /* tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
    0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
    /* these must be last */
    0,                                  /* tp_alloc */
    0,                                  /* tp_free */
    0,                                  /* tp_maxalloc */
    0,                                  /*  tp_next */
#endif
  };

  return &PySwigObject_Type;
}

SWIGRUNTIME PyObject *
PySwigObject_FromVoidPtrAndDesc(void *ptr, char *desc)
{
  PySwigObject *self = PyObject_NEW(PySwigObject, PySwigObject_GetType());
  if (self == NULL) return NULL;
  self->ptr = ptr;
  self->desc = desc;
  return (PyObject *)self;
}

SWIGRUNTIMEINLINE void *
PySwigObject_AsVoidPtr(PyObject *self)
{
  return ((PySwigObject *)self)->ptr;
}

SWIGRUNTIMEINLINE char *
PySwigObject_GetDesc(PyObject *self)
{
  return ((PySwigObject *)self)->desc;
}

SWIGRUNTIMEINLINE int
PySwigObject_Check(PyObject *op) {
  return ((op)->ob_type == PySwigObject_GetType()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigObject") == 0);
}

#else
/* -----------------------------------------------------------------------------
 * Use the old and original Python PyCObject instead of PySwigObject
 * ----------------------------------------------------------------------------- */

#define PySwigObject_GetDesc(obj)	           PyCObject_GetDesc(obj)
#define PySwigObject_Check(obj)	           PyCObject_Check(obj)
#define PySwigObject_AsVoidPtr(obj)	   PyCObject_AsVoidPtr(obj)
#define PySwigObject_FromVoidPtrAndDesc(p, d)  PyCObject_FromVoidPtrAndDesc(p, d, NULL)

#endif

#endif

/* -----------------------------------------------------------------------------
 * errors manipulation
 * ----------------------------------------------------------------------------- */

SWIGRUNTIME void
SWIG_Python_TypeError(const char *type, PyObject *obj)
{
  if (type) {
    if (!PySwigObject_Check(obj)) {
      const char *otype = (obj ? obj->ob_type->tp_name : 0); 
      if (otype) {
	PyObject *str = PyObject_Str(obj);
	const char *cstr = str ? PyString_AsString(str) : 0;
	if (cstr) {
	  PyErr_Format(PyExc_TypeError, "a '%s' is expected, '%s(%s)' is received",
		       type, otype, cstr);
	} else {
	  PyErr_Format(PyExc_TypeError, "a '%s' is expected, '%s' is received",
		       type, otype);
	}
	Py_DECREF(str);
	return;
      }
    } else {
      const char *otype = (char *) PySwigObject_GetDesc(obj);
      if (otype) {
	PyErr_Format(PyExc_TypeError, "a '%s' is expected, 'PySwigObject(%s)' is received",
		     type, otype);
	return;
      }
    }   
    PyErr_Format(PyExc_TypeError, "a '%s' is expected", type);
  } else {
    PyErr_Format(PyExc_TypeError, "unexpected type is received");
  }
}

SWIGRUNTIMEINLINE void
SWIG_Python_NullRef(const char *type)
{
  if (type) {
    PyErr_Format(PyExc_TypeError, "null reference of type '%s' was received",type);
  } else {
    PyErr_Format(PyExc_TypeError, "null reference was received");
  }
}

SWIGRUNTIME int
SWIG_Python_AddErrMesg(const char* mesg, int infront)
{
  if (PyErr_Occurred()) {
    PyObject *type = 0;
    PyObject *value = 0;
    PyObject *traceback = 0;
    PyErr_Fetch(&type, &value, &traceback);
    if (value) {
      PyObject *old_str = PyObject_Str(value);
      Py_XINCREF(type);
      PyErr_Clear();
      if (infront) {
	PyErr_Format(type, "%s %s", mesg, PyString_AsString(old_str));
      } else {
	PyErr_Format(type, "%s %s", PyString_AsString(old_str), mesg);
      }
      Py_DECREF(old_str);
    }
    return 1;
  } else {
    return 0;
  }
}

SWIGRUNTIME int
SWIG_Python_ArgFail(int argnum)
{
  if (PyErr_Occurred()) {
    /* add information about failing argument */
    char mesg[256];
    sprintf(mesg, "argument number %d:", argnum);
    return SWIG_Python_AddErrMesg(mesg, 1);
  } else {
    return 0;
  }
}


/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

/* Convert a pointer value */
SWIGRUNTIME int
SWIG_Python_ConvertPtr(PyObject *obj, void **ptr, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  char  *c = 0;
  static PyObject *SWIG_this = 0;
  int    newref = 0;
  PyObject  *pyobj = 0;
  void *vptr;
  
  if (!obj) return 0;
  if (obj == Py_None) {
    *ptr = 0;
    return 0;
  }

#ifdef SWIG_COBJECT_TYPES
  if (!(PySwigObject_Check(obj))) {
    if (!SWIG_this)
      SWIG_this = PyString_FromString("this");
    pyobj = obj;
    obj = PyObject_GetAttr(obj,SWIG_this);
    newref = 1;
    if (!obj) goto type_error;
    if (!PySwigObject_Check(obj)) {
      Py_DECREF(obj);
      goto type_error;
    }
  }  
  vptr = PySwigObject_AsVoidPtr(obj);
  c = (char *) PySwigObject_GetDesc(obj);
  if (newref) { Py_DECREF(obj); }
  goto type_check;
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
  c = PyString_AS_STRING(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') {
    if (strcmp(c,"NULL") == 0) {
      if (newref) { Py_DECREF(obj); }
      *ptr = (void *) 0;
      return 0;
    } else {
      if (newref) { Py_DECREF(obj); }
      goto type_error;
    }
  }
  c++;
  c = SWIG_UnpackData(c,&vptr,sizeof(void *));
  if (!c) goto type_error;
  if (newref) { Py_DECREF(obj); }
#endif

type_check:

  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
    *ptr = SWIG_TypeCast(tc,vptr);
  }

  if ((pyobj) && (flags & SWIG_POINTER_DISOWN)) {
    PyObject_SetAttrString(pyobj,(char*)"thisown",Py_False);
  }
  return 0;

type_error:
  PyErr_Clear();
  if (pyobj && !obj) {    
    obj = pyobj;
    if (PyCFunction_Check(obj)) {
      /* here we get the method pointer for callbacks */
      char *doc = (((PyCFunctionObject *)obj) -> m_ml -> ml_doc);
      c = doc ? strstr(doc, "swig_ptr: ") : 0;
      if (c) {
	c += 10;
	if (*c == '_') {
	  c++;
	  c = SWIG_UnpackData(c,&vptr,sizeof(void *));
	  if (!c) goto type_error;
	  goto type_check;
	}
      }
    }
  }
  if (flags & SWIG_POINTER_EXCEPTION) {
    if (ty) {
      SWIG_Python_TypeError(SWIG_TypePrettyName(ty), obj);
    } else {
      SWIG_Python_TypeError("C/C++ pointer", obj);
    }
  }
  return -1;
}

/* Convert a pointer value, signal an exception on a type mismatch */
SWIGRUNTIME void *
SWIG_Python_MustGetPtr(PyObject *obj, swig_type_info *ty, int argnum, int flags) {
  void *result;
  if (SWIG_Python_ConvertPtr(obj, &result, ty, flags) == -1) {
    PyErr_Clear();
    if (flags & SWIG_POINTER_EXCEPTION) {
      SWIG_Python_TypeError(SWIG_TypePrettyName(ty), obj);
      SWIG_Python_ArgFail(argnum);
    }
  }
  return result;
}

/* Convert a packed value value */
SWIGRUNTIME int
SWIG_Python_ConvertPacked(PyObject *obj, void *ptr, size_t sz, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  char  *c = 0;

  if ((!obj) || (!PyString_Check(obj))) goto type_error;
  c = PyString_AS_STRING(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') goto type_error;
  c++;
  c = SWIG_UnpackData(c,ptr,sz);
  if (!c) goto type_error;
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
  }
  return 0;

type_error:
  PyErr_Clear();
  if (flags & SWIG_POINTER_EXCEPTION) {
    if (ty) {
      SWIG_Python_TypeError(SWIG_TypePrettyName(ty), obj);
    } else {
      SWIG_Python_TypeError("C/C++ packed data", obj);
    }
  }
  return -1;
}  

/* Create a new array object */
SWIGRUNTIME PyObject *
SWIG_Python_NewPointerObj(void *ptr, swig_type_info *type, int own) {
  PyObject *robj = 0;
  if (!ptr) {
    Py_INCREF(Py_None);
    return Py_None;
  }
#ifdef SWIG_COBJECT_TYPES
  robj = PySwigObject_FromVoidPtrAndDesc((void *) ptr, (char *)type->name);
#else
  {
    char result[1024];
    robj = SWIG_PackVoidPtr(result, ptr, type->name, 1024) ?
      PyString_FromString(result) : 0;
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
        PyObject_SetAttrString(inst,(char*)"thisown",Py_True);
      }
      robj = inst;
    }
  }
  return robj;
}

SWIGRUNTIME PyObject *
SWIG_Python_NewPackedObj(void *ptr, size_t sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 2 + strlen(type->name)) > 1024) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  strcpy(r,type->name);
  return PyString_FromString(result);
}

/* -----------------------------------------------------------------------------*
 *  Get type list 
 * -----------------------------------------------------------------------------*/

#ifdef SWIG_LINK_RUNTIME
void *SWIG_ReturnGlobalTypeList(void *);
#endif

SWIGRUNTIME swig_type_info **
SWIG_Python_GetTypeListHandle() {
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
  }
#endif
  return (swig_type_info **) type_pointer;
}

/*
  Search for a swig_type_info structure
 */
SWIGRUNTIMEINLINE swig_type_info *
SWIG_Python_GetTypeList() {
  swig_type_info **type_list_handle = SWIG_Python_GetTypeListHandle();
  return type_list_handle ? *type_list_handle : (swig_type_info *)0;
}

/* -----------------------------------------------------------------------------*
 *  Standard SWIG API 
 * -----------------------------------------------------------------------------*/

SWIGRUNTIMEINLINE swig_type_info *
SWIG_Python_TypeQuery(const char *name) {
  swig_type_info *tl = SWIG_Python_GetTypeList();
  return SWIG_TypeQueryTL(tl, name);
}

SWIGRUNTIMEINLINE swig_type_info *
SWIG_Python_TypeRegister(swig_type_info *ti) {
  swig_type_info **tlh = SWIG_Python_GetTypeListHandle();
  return SWIG_TypeRegisterTL(tlh, ti);
}

SWIGRUNTIMEINLINE void
SWIG_Python_TypeClientData(swig_type_info *ti, void *clientdata) {
  swig_type_info *tl = SWIG_Python_GetTypeList();
  SWIG_TypeClientDataTL(tl, ti, clientdata);
}

SWIGRUNTIMEINLINE void
SWIG_Python_PropagateClientData(swig_type_info *type) {
  swig_type_info *tl = SWIG_Python_GetTypeList();
  SWIG_PropagateClientDataTL(tl, type);
}

#ifdef __cplusplus
}
#endif
