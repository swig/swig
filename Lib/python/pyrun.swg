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
#define SWIG_ConvertPtr(obj, pptr, type, flags)         SWIG_Python_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewPointerObj(ptr, type, flags)            SWIG_Python_NewPointerObj(ptr, type, flags)

/* for raw packed data */
#define SWIG_ConvertPacked(obj, ptr, sz, ty, flags)     SWIG_Python_ConvertPacked(obj, ptr, sz, ty, flags)
#define SWIG_NewPackedObj(ptr, sz, type, flags)         SWIG_Python_NewPackedObj(ptr, sz, type)

/* for class or struct pointers */
#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_Python_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(ptr, type, flags)           SWIG_Python_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define SWIG_ConvertFunctionPtr(obj, pptr, type, flags) SWIG_Python_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_Python_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(obj, ptr, sz, ty, flags)     SWIG_Python_ConvertPacked(obj, ptr, sz, ty, flags)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_Python_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define SWIG_GetModule(clientdata)                      SWIG_Python_GetModule()
#define SWIG_SetModule(clientdata, pointer)             SWIG_Python_SetModule(pointer)

/* Error manipulation */

#define SWIG_ErrorType(code)                            SWIG_Python_ErrorType(code)                       
#define SWIG_Error(code, msg)            		PyErr_SetString(SWIG_Python_ErrorType(code), msg) 
#define SWIG_fail                        		goto fail					   

/* -----------------------------------------------------------------------------
 * Pointer declarations
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#if 0
} /* cc-mode */
#endif
#endif


/* PySwigObject */

typedef struct {
  PyObject_HEAD
  void *ptr;
  const char *desc;
} PySwigObject;


SWIGRUNTIME int
PySwigObject_print(PySwigObject *v, FILE *fp, int flags)
{
  char result[SWIG_BUFFER_SIZE];
  flags = flags;
  if (SWIG_PackVoidPtr(result, v->ptr, v->desc, sizeof(result))) {
    fputs("<Swig Object at ", fp); fputs(result, fp); fputs(">", fp);
    return 0; 
  } else {
    return 1; 
  }
}
  
SWIGRUNTIME PyObject *
PySwigObject_repr(PySwigObject *v)
{
  char result[SWIG_BUFFER_SIZE];
  return SWIG_PackVoidPtr(result, v->ptr, v->desc, sizeof(result)) ?
    PyString_FromFormat("<Swig Object at %s>", result) : 0;
}

SWIGRUNTIME PyObject *
PySwigObject_str(PySwigObject *v)
{
  char result[SWIG_BUFFER_SIZE];
  return SWIG_PackVoidPtr(result, v->ptr, v->desc, sizeof(result)) ?
    PyString_FromString(result) : 0;
}

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
  if (args && (PyTuple_SetItem(args, 0, PySwigObject_long(v)) == 0)) {
    PyObject *ofmt = PyString_FromString(fmt);
    if (ofmt) {
      res = PyString_Format(ofmt,args);
      Py_DECREF(ofmt);
    }
    Py_DECREF(args);
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

SWIGRUNTIME int
PySwigObject_compare(PySwigObject *v, PySwigObject *w)
{
  int c = strcmp(v->desc, w->desc);
  if (c) {
    return (c > 0) ? 1 : -1;
  } else {
    void *i = v->ptr;
    void *j = w->ptr;
    return (i < j) ? -1 : ((i > j) ? 1 : 0);
  }
}

SWIGRUNTIME void
PySwigObject_dealloc(PySwigObject *self)
{
  PyObject_Del(self);
}

SWIGRUNTIME PyTypeObject*
PySwigObject_type(void) {
  static char pyswigobject_type__doc__[] = 
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

  static PyTypeObject pyswigobject_type
#if !defined(__cplusplus)
    ;  
  static int type_init = 0;
  if (!type_init) {
    PyTypeObject tmp
#endif
      = {
	PyObject_HEAD_INIT(&PyType_Type)
	0,					/*ob_size*/
	(char *)"PySwigObject",		/*tp_name*/
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
	0,0,0,0,
	pyswigobject_type__doc__, 	        /* Documentation string */
#if PY_VERSION_HEX >= 0x02000000
	0,                                  /* tp_traverse */
	0,                                  /* tp_clear */
#endif
#if PY_VERSION_HEX >= 0x02010000
	0,                                  /* tp_richcompare */
	0,                                  /* tp_weaklistoffset */
#endif
#if PY_VERSION_HEX >= 0x02020000
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* tp_iter -> tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
	0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
	0,0,0,0                             /* tp_alloc -> tp_next */
#endif
      };
#if !defined(__cplusplus)
    pyswigobject_type = tmp;
    type_init = 1;
  }
#endif
  return &pyswigobject_type;
}

SWIGRUNTIME PyObject *
PySwigObject_FromVoidPtrAndDesc(void *ptr, const char *desc)
{
  PySwigObject *self = PyObject_NEW(PySwigObject, PySwigObject_type());
  if (self) {
    self->ptr = ptr;
    self->desc = desc;
  }
  return (PyObject *)self;
}

SWIGRUNTIMEINLINE void *
PySwigObject_AsVoidPtr(PyObject *self)
{
  return ((PySwigObject *)self)->ptr;
}

SWIGRUNTIMEINLINE const char *
PySwigObject_GetDesc(PyObject *self)
{
  return ((PySwigObject *)self)->desc;
}

SWIGRUNTIMEINLINE int
PySwigObject_Check(PyObject *op) {
  return ((op)->ob_type == PySwigObject_type()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigObject") == 0);
}

/* -----------------------------------------------------------------------------
 * Implements a simple Swig Packed type, and use it instead of string
 * ----------------------------------------------------------------------------- */

typedef struct {
  PyObject_HEAD
  void *pack;
  const char *desc;
  size_t size;
} PySwigPacked;

SWIGRUNTIME int
PySwigPacked_print(PySwigPacked *v, FILE *fp, int flags)
{
  char result[SWIG_BUFFER_SIZE];
  flags = flags;
  fputs("<Swig Packed ", fp); 
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    fputs("at ", fp); 
    fputs(result, fp); 
  }
  fputs(v->desc,fp); 
  fputs(">", fp);
  return 0; 
}
  
SWIGRUNTIME PyObject *
PySwigPacked_repr(PySwigPacked *v)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    return PyString_FromFormat("<Swig Packed at %s%s>", result, v->desc);
  } else {
    return PyString_FromFormat("<Swig Packed %s>", v->desc);
  }  
}

SWIGRUNTIME PyObject *
PySwigPacked_str(PySwigPacked *v)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))){
    return PyString_FromFormat("%s%s", result, v->desc);
  } else {
    return PyString_FromString(v->desc);
  }  
}

SWIGRUNTIME int
PySwigPacked_compare(PySwigPacked *v, PySwigPacked *w)
{
  int c = strcmp(v->desc, w->desc);
  if (c) {
    return (c > 0) ? 1 : -1;
  } else {
    size_t i = v->size;
    size_t j = w->size;
    int s = (i < j) ? -1 : ((i > j) ? 1 : 0);
    return s ? s : strncmp((char *)v->pack, (char *)w->pack, 2*v->size);
  }
}

SWIGRUNTIME void
PySwigPacked_dealloc(PySwigPacked *self)
{
  free(self->pack);
  PyObject_Del(self);
}

SWIGRUNTIME PyTypeObject*
PySwigPacked_type(void) {
  static char pyswigpacked_type__doc__[] = 
    "Swig object carries a C/C++ instance pointer";
  static PyTypeObject pyswigpacked_type
#if !defined(__cplusplus)
    ;
  static int type_init = 0;  
  if (!type_init) {
    PyTypeObject tmp
#endif
      = {
	PyObject_HEAD_INIT(&PyType_Type)
	0,					/*ob_size*/
	(char *)"PySwigPacked",		/*tp_name*/
	sizeof(PySwigPacked),		/*tp_basicsize*/
	0,					/*tp_itemsize*/
	/* methods */
	(destructor)PySwigPacked_dealloc,	/*tp_dealloc*/
	(printfunc)PySwigPacked_print,	/*tp_print*/
	(getattrfunc)0,			/*tp_getattr*/
	(setattrfunc)0,			/*tp_setattr*/
	(cmpfunc)PySwigPacked_compare,	/*tp_compare*/
	(reprfunc)PySwigPacked_repr,	/*tp_repr*/
	0,	                                /*tp_as_number*/
	0,					/*tp_as_sequence*/
	0,					/*tp_as_mapping*/
	(hashfunc)0,			/*tp_hash*/
	(ternaryfunc)0,			/*tp_call*/
	(reprfunc)PySwigPacked_str,		/*tp_str*/
	/* Space for future expansion */
	0,0,0,0,
	pyswigpacked_type__doc__, 	        /* Documentation string */
#if PY_VERSION_HEX >= 0x02000000
	0,                                  /* tp_traverse */
	0,                                  /* tp_clear */
#endif
#if PY_VERSION_HEX >= 0x02010000
	0,                                  /* tp_richcompare */
	0,                                  /* tp_weaklistoffset */
#endif
#if PY_VERSION_HEX >= 0x02020000         
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* tp_iter -> tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
	0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
	0,0,0,0                             /* tp_alloc -> tp_next */
#endif
      };
#if !defined(__cplusplus)
    pyswigpacked_type = tmp;
    type_init = 1;
  }
#endif
  return &pyswigpacked_type;
}

SWIGRUNTIME PyObject *
PySwigPacked_FromDataAndDesc(void *ptr, size_t size, const char *desc)
{
  PySwigPacked *self = PyObject_NEW(PySwigPacked, PySwigPacked_type());
  if (self == NULL) {
    return NULL;
  } else {
    void *pack = malloc(size);
    if (pack) {
      memcpy(pack, ptr, size);
      self->pack = pack;
      self->desc = desc;
      self->size = size;
      return (PyObject *) self;
    }
    return NULL;
  }
}

SWIGRUNTIMEINLINE const char *
PySwigPacked_UnpackData(PyObject *obj, void *ptr, size_t size)
{
  PySwigPacked *self = (PySwigPacked *)obj;
  if (self->size != size) return 0;
  memcpy(ptr, self->pack, size);
  return self->desc;
}

SWIGRUNTIMEINLINE const char *
PySwigPacked_GetDesc(PyObject *self)
{
  return ((PySwigPacked *)self)->desc;
}

SWIGRUNTIMEINLINE int
PySwigPacked_Check(PyObject *op) {
  return ((op)->ob_type == PySwigPacked_type()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigPacked") == 0);
}


/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

/* Convert a pointer value */
SWIGRUNTIME int
SWIG_Python_ConvertPtr(PyObject *obj, void **ptr, swig_type_info *ty, int flags) {
  swig_cast_info *tc;
  const char *c = 0;
  static PyObject *SWIG_this = 0;
  int    newref = 0;
  PyObject  *pyobj = 0;
  void *vptr;
  
  if (!obj) return SWIG_ERROR;
  if (obj == Py_None) {
    *ptr = 0;
    return SWIG_OK;
  }

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
  c = (const char *) PySwigObject_GetDesc(obj);
  if (newref) { Py_DECREF(obj); }
  goto type_check;

 type_check:
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
    *ptr = SWIG_TypeCast(tc,vptr);
  } else {
    *ptr = vptr;
  }
  if ((pyobj) && (flags & SWIG_POINTER_DISOWN)) {
    PyObject_SetAttrString(pyobj,(char*)"thisown",Py_False);
  }
  return SWIG_OK;

 type_error:
  PyErr_Clear();
  if (pyobj && !obj) {    
    obj = pyobj;
    if (PyCFunction_Check(obj)) {
      /* here we get the method pointer for callbacks */
      char *doc = (((PyCFunctionObject *)obj) -> m_ml -> ml_doc);
      c = doc ? strstr(doc, "swig_ptr: ") : 0;
      if (c) {
	c = ty ? SWIG_UnpackVoidPtr(c + 10, &vptr, ty->name) : 0;
	if (!c) goto type_error;
	goto type_check;
      }
    }
  }
  return SWIG_ERROR;
}

/* Convert a packed value value */
SWIGRUNTIME int
SWIG_Python_ConvertPacked(PyObject *obj, void *ptr, size_t sz, swig_type_info *ty, int flags) {
  swig_cast_info *tc;
  const char *c = 0;

  c = PySwigPacked_UnpackData(obj, ptr, sz);
  if (!c) goto type_error;
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
  }
  return SWIG_OK;

 type_error:
  PyErr_Clear();
  return SWIG_ERROR;
}  

/* -----------------------------------------------------------------------------
 * Create a new pointer object
 * ----------------------------------------------------------------------------- */

SWIGRUNTIME PyObject *
SWIG_Python_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  PyObject *robj = 0;
  int own = flags & SWIG_POINTER_OWN;
  if (!type) {
    if (!PyErr_Occurred()) {
      PyErr_SetString(PyExc_TypeError, "Swig: null type passed to NewPointerObj");
    }
    return robj;
  }
  if (!ptr) {
    Py_INCREF(Py_None);
    return Py_None;
  }
  robj = PySwigObject_FromVoidPtrAndDesc((void *) ptr, (char *)type->name);
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

/* Create a new array object */

SWIGRUNTIME PyObject *
SWIG_Python_NewPackedObj(void *ptr, size_t sz, swig_type_info *type) {
  PyObject *robj = 0;
  if (!ptr) {
    Py_INCREF(Py_None);
    return Py_None;
  }

  robj = PySwigPacked_FromDataAndDesc((void *) ptr, sz, (char *)type->name);
  return robj;
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
SWIG_Python_SetModule(swig_module_info *swig_module) {
  static PyMethodDef swig_empty_runtime_method_table[] = { {NULL, NULL, 0, NULL} };/* Sentinel */

  PyObject *module = Py_InitModule((char*)"swig_runtime_data" SWIG_RUNTIME_VERSION,
				   swig_empty_runtime_method_table);
  PyObject *pointer = PyCObject_FromVoidPtr((void *) swig_module, NULL);
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
