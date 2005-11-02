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
#define SWIG_ConvertPacked(obj, ptr, sz, ty)            SWIG_Python_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewPackedObj(ptr, sz, type)                SWIG_Python_NewPackedObj(ptr, sz, type)

/* for class or struct pointers */
#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_Python_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(ptr, type, flags)           SWIG_Python_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_Python_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_Python_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_Python_ConvertPacked(obj, ptr, sz, ty)
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

/* Flags for new pointer objects */
#define SWIG_POINTER_NOSHADOW      SWIG_POINTER_OWN << 1
#define SWIG_POINTER_NEW           SWIG_POINTER_NOSHADOW | SWIG_POINTER_OWN


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
  swig_type_info *ty;
  int own;
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

SWIGRUNTIME PyObject *
PySwigObject_repr(PySwigObject *v)
{
  const char *name = SWIG_TypePrettyName(v->ty);
  PyObject *hex = PySwigObject_hex(v);
  if (name) {
    return PyString_FromFormat("<Swig Object of type '%s' at 0x%s>", name, PyString_AsString(hex));
  } else {
    return PyString_FromFormat("<Swig Object at 0x%s>", PyString_AsString(hex));
  }
  Py_DECREF(hex);
}

SWIGRUNTIME int
PySwigObject_print(PySwigObject *v, FILE *fp, int SWIGUNUSED flags)
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

SWIGRUNTIME PyTypeObject* PySwigObject_type(void);

SWIGRUNTIME int
PySwigObject_Check(PyObject *op) {
  return ((op)->ob_type == PySwigObject_type()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigObject") == 0);
}

SWIGRUNTIME void
PySwigObject_dealloc(PyObject *v)
{
  if (PySwigObject_Check(v)) {
    PySwigObject *self = (PySwigObject *) v;
    if (self->own) {
    }
  }
  v->ob_type->tp_free(v);
}


SWIGINTERN PyObject*
PySwigObject_disown(PySwigObject *self)
{
  self->own = 0;
  Py_INCREF(Py_None);
  return Py_None;
}

SWIGINTERN PyObject*
PySwigObject_acquire(PySwigObject *self)
{
  self->own = 1;
  Py_INCREF(Py_None);
  return Py_None;
}

SWIGINTERN PyObject*
PySwigObject_own(PySwigObject *self)
{
  PyObject *obj = self->own ? Py_True : Py_False;
  Py_INCREF(obj);
  return obj;
}

SWIGRUNTIME PyTypeObject*
PySwigObject_type(void) {
  static char swigobject_doc[] = "Swig object carries a C/C++ instance pointer";
  static PyMethodDef
    swigobject_methods[] = {
      {"disown",  (PyCFunction)PySwigObject_disown, METH_NOARGS, "release ownership of the pointer"},
      {"acquire", (PyCFunction)PySwigObject_acquire, METH_NOARGS, "aquire ownership of the pointer"},
      {"own",     (PyCFunction)PySwigObject_own, METH_NOARGS, "return ownership status of the pointer"},
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

  static PyTypeObject pyswigobject_type
#if !defined(__cplusplus)
    ;  
  static int type_init = 0;
  if (!type_init) {
    PyTypeObject tmp
#endif
      = {
	PyObject_HEAD_INIT(&PyType_Type)
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
#if PY_VERSION_HEX >= 0x02000000
	0,                                  /* tp_traverse */
	0,                                  /* tp_clear */
#endif
#if PY_VERSION_HEX >= 0x02010000
	0,                                  /* tp_richcompare */
	0,                                  /* tp_weaklistoffset */
#endif
#if PY_VERSION_HEX >= 0x02020000
	0,                                  /* tp_iter */
	0,                                  /* tp_iternext */
#endif
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
PySwigObject_New(void *ptr, swig_type_info *ty, int own)
{
  PySwigObject *self = PyObject_NEW(PySwigObject, PySwigObject_type());
  if (self) {
    self->ptr = ptr;
    self->ty = ty;
    self->own = own;
  }
  return (PyObject *)self;
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
PySwigPacked_print(PySwigPacked *v, FILE *fp, int flags)
{
  char result[SWIG_BUFFER_SIZE];
  flags = flags;
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

SWIGRUNTIME PyTypeObject* PySwigPacked_type(void);

SWIGRUNTIME int
PySwigPacked_Check(PyObject *op) {
  return ((op)->ob_type == PySwigPacked_type()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigPacked") == 0);
}

SWIGRUNTIME void
PySwigPacked_dealloc(PyObject *v)
{
  if (PySwigPacked_Check(v)) {
    PySwigPacked *self = (PySwigPacked *) v;
    free(self->pack);
  }
  v->ob_type->tp_free(v);
}

SWIGRUNTIME PyTypeObject*
PySwigPacked_type(void) {
  static char swigpacked_doc[] = "Swig object carries a C/C++ instance pointer";
  static PyTypeObject pyswigpacked_type
#if !defined(__cplusplus)
    ;
  static int type_init = 0;  
  if (!type_init) {
    PyTypeObject tmp
#endif
      = {
	PyObject_HEAD_INIT(&PyType_Type)
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
#if PY_VERSION_HEX >= 0x02000000
	0,                                  /* tp_traverse */
	0,                                  /* tp_clear */
#endif
#if PY_VERSION_HEX >= 0x02010000
	0,                                  /* tp_richcompare */
	0,                                  /* tp_weaklistoffset */
#endif
#if PY_VERSION_HEX >= 0x02020000
	0,                                  /* tp_iter */
	0,                                  /* tp_iternext */
#endif
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
PySwigPacked_New(void *ptr, size_t size, swig_type_info *ty)
{
  PySwigPacked *self = PyObject_NEW(PySwigPacked, PySwigPacked_type());
  if (self == NULL) {
    return NULL;
  } else {
    void *pack = malloc(size);
    if (pack) {
      memcpy(pack, ptr, size);
      self->pack = pack;
      self->ty   = ty;
      self->size = size;
      return (PyObject *) self;
    }
    return NULL;
  }
}

SWIGRUNTIMEINLINE swig_type_info *
PySwigPacked_UnpackData(PyObject *obj, void *ptr, size_t size)
{
  if (PySwigPacked_Check(obj)) {
    PySwigPacked *self = (PySwigPacked *)obj;
    if (self->size != size) return 0;
    memcpy(ptr, self->pack, size);
    return self->ty;
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

SWIGRUNTIME
PyObject *
SWIG_This()
{
  static PyObject *_this = SWIG_STATIC_POINTER(_this) PyString_FromString("this");
  return _this;
}


/* Convert a pointer value */
SWIGRUNTIME int
SWIG_Python_ConvertPtr(PyObject *obj, void **ptr, swig_type_info *ty, int flags) {
  swig_type_info *to = 0;
  const char *desc = 0;
  int    newref = 0;
  PyObject  *pyobj = 0;
  void *vptr = 0;
  PySwigObject *sobj = 0;
  
  if (!obj) return SWIG_ERROR;
  if (obj == Py_None) {
    *ptr = 0;
    return SWIG_OK;
  }

  if (!(PySwigObject_Check(obj))) {    
    pyobj = obj;
    obj = PyObject_GetAttr(obj, SWIG_This());
    if (!obj) goto type_error;
    if (!PySwigObject_Check(obj)) {
      Py_DECREF(obj);
      goto type_error;
    }
    newref = 1;
  }  
  sobj = (PySwigObject *) obj;
  vptr = sobj->ptr;
  to = sobj->ty;
  desc = (const char *) to->name;
  if (newref) { newref = 0; Py_DECREF(obj); }

 type_check:
  if (ty) {
    if (to == ty) {
      /* no type cast needed */
      *ptr = vptr;
    } else {
      swig_cast_info *tc = SWIG_TypeCheck(desc,ty);
      if (!tc) goto type_error;
      *ptr = SWIG_TypeCast(tc,vptr);
    }
  } else {
    *ptr = vptr;
  }
  if ((pyobj) && (flags & SWIG_POINTER_DISOWN)) {
    sobj->own = 0;
  }
  return SWIG_OK;

 type_error:
  PyErr_Clear();
  if (pyobj && !obj) {    
    obj = pyobj;
    if (PyCFunction_Check(obj)) {
      /* here we get the method pointer for callbacks */
      char *doc = (((PyCFunctionObject *)obj) -> m_ml -> ml_doc);
      desc = doc ? strstr(doc, "swig_ptr: ") : 0;
      if (desc) {
	desc = ty ? SWIG_UnpackVoidPtr(desc + 10, &vptr, ty->name) : 0;
	if (!desc) goto type_error;
	goto type_check;
      }
    }
  }
  return SWIG_ERROR;
}

/* Convert a packed value value */
SWIGRUNTIME int
SWIG_Python_ConvertPacked(PyObject *obj, void *ptr, size_t sz, swig_type_info *ty) {
  swig_type_info *to = PySwigPacked_UnpackData(obj, ptr, sz);
  if (!to) goto type_error;
  if (ty) {
    if (to != ty) {
      /* check type cast? */
      swig_cast_info *tc = SWIG_TypeCheck(to->name,ty);
      if (!tc) goto type_error;
    }
  }
  return SWIG_OK;
  
 type_error:
  return SWIG_ERROR;
}  

/* -----------------------------------------------------------------------------
 * Create a new pointer object
 * ----------------------------------------------------------------------------- */

SWIGRUNTIMEINLINE void * 
SWIG_NewClientData(PyObject* obj)
{
  if (PyClass_Check(obj)) {
    Py_INCREF(obj);
    return obj;
  } else {
    PyObject *args = PyTuple_New(1);
    PyTuple_SetItem(args, 0, obj);
    return args;
  }
}

/* Create a new instance object whitout calling __init__ */

SWIGRUNTIME PyObject* 
SWIG_NewInstance(PyObject * obj)
{
  PyObject *inst = 0;
  if (PyTuple_Check(obj)) {
    static PyObject* fnew = SWIG_STATIC_POINTER(fnew) PyObject_GetAttrString((PyObject*)&PyBaseObject_Type, "__new__");    
    inst = PyObject_Call(fnew, obj, NULL);
  } else if (PyClass_Check(obj)) {
    inst = PyInstance_NewRaw(obj, NULL);
  } else {
    PyObject* args = PyTuple_New(1);
    PyTuple_SetItem(args,0,obj);
    inst = SWIG_NewInstance(args);
    Py_DECREF(args);
  }
  
  return inst;
}


SWIGRUNTIME PyObject *
SWIG_Python_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  PyObject *robj = 0;
  int own = (flags & SWIG_POINTER_OWN);
  int shadow = !(flags & SWIG_POINTER_NOSHADOW);
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
  robj = PySwigObject_New((void *) ptr, type, own);
  if (!robj || (robj == Py_None)) return robj;
  if (shadow && type->clientdata) {
    PyObject *inst = SWIG_NewInstance((PyObject *)type->clientdata);
    if (inst) {
      PyObject_SetAttr(inst, SWIG_This(), robj);
      Py_DECREF(robj);
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

  robj = PySwigPacked_New((void *) ptr, sz, type);
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
