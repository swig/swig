/***********************************************************************
 * pyrun.swg
 *
 *     This file contains the runtime support for Python modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 * Author : David Beazley (beazley@cs.uchicago.edu)
 ************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

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

static PyTypeObject varlinktype = {
  PyObject_HEAD_INIT(0)              
  0,                                  /* Number of items in variable part (ob_size) */
  (char *)"swigvarlink",              /* Type name (tp_name) */
  sizeof(swig_varlinkobject),         /* Basic size (tp_basicsize) */
  0,                                  /* Itemsize (tp_itemsize) */
  0,                                  /* Deallocator (tp_dealloc) */ 
  (printfunc) swig_varlink_print,     /* Print (tp_print) */
  (getattrfunc) swig_varlink_getattr, /* get attr (tp_getattr) */
  (setattrfunc) swig_varlink_setattr, /* Set attr (tp_setattr) */
  0,                                  /* tp_compare */
  (reprfunc) swig_varlink_repr,       /* tp_repr */
  0,                                  /* tp_as_number */
  0,                                  /* tp_as_sequence */
  0,                                  /* tp_as_mapping */
  0,                                  /* tp_hash */
  0,                                  /* tp_call */
  0,                                  /* tp_str */
  0,                                  /* tp_getattro */
  0,                                  /* tp_setattro */
  0,                                  /* tp_as_buffer */
  0,                                  /* tp_flags */
  0,                                  /* tp_doc */
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

/* Create a variable linking object for use later */
static PyObject *
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

static void
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

/* -----------------------------------------------------------------------------
 * errors manipulation
 * ----------------------------------------------------------------------------- */

static void
SWIG_Python_TypeError(const char *type, PyObject *obj)
{
  const char *otype = (obj ? obj->ob_type->tp_name : 0);
  if (type) {
    if (otype) {
      PyErr_Format(PyExc_TypeError, "a '%s' is expected, '%s' is received",
		   type, otype);
    } else {
      PyErr_Format(PyExc_TypeError, "a '%s' is expected", type);
    }
  } else {
    PyErr_Format(PyExc_TypeError, "unexpected type is received");
  }
}

static SWIGINLINE void
SWIG_Python_NullRef(const char *type)
{
  if (type) {
    PyErr_Format(PyExc_TypeError, "null reference of type '%s' was received",type);
  } else {
    PyErr_Format(PyExc_TypeError, "null reference was received");
  }
}

static int
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

static int
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
static int
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
  vptr = PyCObject_AsVoidPtr(obj);
  c = (char *) PyCObject_GetDesc(obj);
  if (newref) Py_DECREF(obj);
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
	  goto type_check;
	}
      }
    } else if (PyInt_Check(obj)) {
      /* here we check for the only accepted zero value */
      long v = PyInt_AsLong(obj);
      if (v == 0) {
	*ptr = 0;
	return 0;
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
static void *
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
static int
SWIG_Python_ConvertPacked(PyObject *obj, void *ptr, size_t sz, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  char  *c = 0;

  if ((!obj) || (!PyString_Check(obj))) goto type_error;
  c = PyString_AS_STRING(obj);
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

/* Create a new pointer string */
static char *
SWIG_Python_PointerStr(char *buff, void *ptr, const char *name, size_t bsz) {
  char *r = buff;
  if ((2*sizeof(void *) + 2) > bsz) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,&ptr,sizeof(void *));
  if (strlen(name) + 1 > (bsz - (r - buff))) return 0;
  strcpy(r,name);
  return buff;
}
  

/* Create a new pointer object */
static PyObject *
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
    SWIG_Python_PointerStr(result, ptr, type->name, 1024);
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
        PyObject_SetAttrString(inst,(char*)"thisown",Py_True);
      }
      robj = inst;
    }
  }
  return robj;
}

static PyObject *
SWIG_Python_NewPackedObj(void *ptr, size_t sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 2 + strlen(type->name)) > 1024) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  strcpy(r,type->name);
  return PyString_FromString(result);
}


/* -----------------------------------------------------------------------------
 * constants/methods manipulation
 * ----------------------------------------------------------------------------- */

/* Install Constants */
static void
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
      if (constants[i].pvalue) {
	obj = PyString_FromString((char *) constants[i].pvalue);
      } else {
	Py_INCREF(Py_None);
	obj = Py_None;
      }
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

/* Fix SwigMethods to carry the callback ptrs when needed */
static void
SWIG_Python_FixMethods(PyMethodDef *methods,
		       swig_const_info *const_table,
		       swig_type_info **types,
		       swig_type_info **types_initial) {
  int i;
  for (i = 0; methods[i].ml_name; ++i) {
    char *c = methods[i].ml_doc;
    if (c && (c = strstr(c, "swig_ptr: "))) {
      int j;
      swig_const_info *ci = 0;
      char *name = c + 10;
      for (j = 0; const_table[j].type; j++) {
	if (strncmp(const_table[j].name, name, 
		    strlen(const_table[j].name)) == 0) {
	  ci = &(const_table[j]);
	  break;
	}
      }
      if (ci) {
	size_t shift = (ci->ptype) - types;
	swig_type_info *ty = types_initial[shift];
	size_t ldoc = (c - methods[i].ml_doc);
	size_t lptr = strlen(ty->name)+2*sizeof(void*)+2;
	char *ndoc = (char*)malloc(ldoc + lptr + 10);
	char *buff = ndoc;
	void *ptr = (ci->type == SWIG_PY_POINTER) ? ci->pvalue: (void *)(ci->lvalue);
	strncpy(buff, methods[i].ml_doc, ldoc);
	buff += ldoc;
	strncpy(buff, "swig_ptr: ", 10);
	buff += 10;
	SWIG_Python_PointerStr(buff, ptr, ty->name, lptr);
	methods[i].ml_doc = ndoc;
      }
    }
  }
}


/* -----------------------------------------------------------------------------
 * Lookup type pointer 
 * ----------------------------------------------------------------------------- */
static void
SWIG_Python_LookupTypePointer(swig_type_info ***type_list_handle) {
  PyObject *module, *pointer;
  void *type_pointer;

  /* first check if module already created */
  type_pointer = PyCObject_Import("swig_runtime_data" SWIG_RUNTIME_VERSION, "type_pointer" SWIG_TYPE_TABLE_NAME);
  if (type_pointer) {
    *type_list_handle = (swig_type_info **) type_pointer;
  } else {
    PyErr_Clear();
    /* create a new module and variable */
    module = Py_InitModule("swig_runtime_data" SWIG_RUNTIME_VERSION, NULL);
    pointer = PyCObject_FromVoidPtr((void *) (*type_list_handle), NULL);
    if (pointer && module) {
      PyModule_AddObject(module, "type_pointer" SWIG_TYPE_TABLE_NAME, pointer);
    }
  }
}

#ifdef __cplusplus
}
#endif
