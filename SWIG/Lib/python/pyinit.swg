/* ------------------------------------------------------------
 * The start of the Python initialization function 
 * ------------------------------------------------------------ */

%insert(init) "swiginit.swg"

%init %{

#ifdef __cplusplus
extern "C" {   
#endif

/* Python-specific SWIG API */
#define SWIG_newvarlink()                             SWIG_Python_newvarlink()
#define SWIG_addvarlink(p, name, get_attr, set_attr)  SWIG_Python_addvarlink(p, name, get_attr, set_attr)
#define SWIG_InstallConstants(d, constants)           SWIG_Python_InstallConstants(d, constants)

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

SWIGINTERN PyObject *
swig_varlink_repr(swig_varlinkobject *v) {
  v = v;
  return PyString_FromString("<Swig global variables>");
}

SWIGINTERN int
swig_varlink_print(swig_varlinkobject *v, FILE *fp, int flags) {
  swig_globalvar  *var;
  flags = flags;
  fprintf(fp,"Swig global variables { ");
  for (var = v->vars; var; var=var->next) {
    fprintf(fp,"%s", var->name);
    if (var->next) fprintf(fp,", ");
  }
  fprintf(fp," }\n");
  return 0;
}

SWIGINTERN PyObject *
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

SWIGINTERN int
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

SWIGINTERN PyTypeObject*
swig_varlink_type(void) {
  static char varlink__doc__[] = "Swig var link object";
  static PyTypeObject varlink_type
#if !defined(__cplusplus)
  ;
  static int type_init = 0;  
  if (!type_init) {
    PyTypeObject tmp
#endif
      = {
      PyObject_HEAD_INIT(&PyType_Type)
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
      varlink__doc__,                     /* tp_doc */
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
    varlink_type = tmp;
    type_init = 1;
  }
#endif
  return &varlink_type;
}

/* Create a variable linking object for use later */
SWIGINTERN PyObject *
SWIG_Python_newvarlink(void) {
  swig_varlinkobject *result = PyObject_NEW(swig_varlinkobject, swig_varlink_type());
  if (result) {
    result->vars = 0;
  }
  return ((PyObject*) result);
}

SWIGINTERN void 
SWIG_Python_addvarlink(PyObject *p, char *name, PyObject *(*get_attr)(void), int (*set_attr)(PyObject *p)) {
  swig_varlinkobject *v = (swig_varlinkobject *) p;
  swig_globalvar *gv = (swig_globalvar *) malloc(sizeof(swig_globalvar));
  if (gv) {
    size_t size = strlen(name)+1;
    gv->name = (char *)malloc(size);
    if (gv->name) {
      strncpy(gv->name,name,size);
      gv->get_attr = get_attr;
      gv->set_attr = set_attr;
      gv->next = v->vars;
    }
  }
  v->vars = gv;
}

/* -----------------------------------------------------------------------------
 * constants/methods manipulation
 * ----------------------------------------------------------------------------- */

/* Install Constants */
SWIGINTERN void
SWIG_Python_InstallConstants(PyObject *d, swig_const_info constants[]) {
  PyObject *obj = 0;
  size_t i;
  for (i = 0; constants[i].type; ++i) {
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

/* -----------------------------------------------------------------------------*/
/* Fix SwigMethods to carry the callback ptrs when needed */
/* -----------------------------------------------------------------------------*/

SWIGINTERN void
SWIG_Python_FixMethods(PyMethodDef *methods,
		       swig_const_info *const_table,
		       swig_type_info **types,
		       swig_type_info **types_initial) {
  size_t i;
  for (i = 0; methods[i].ml_name; ++i) {
    char *c = methods[i].ml_doc;
    if (c && (c = strstr(c, "swig_ptr: "))) {
      int j;
      swig_const_info *ci = 0;
      char *name = c + 10;
      for (j = 0; const_table[j].type; ++j) {
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
	if (ndoc) {
	  char *buff = ndoc;
	  void *ptr = (ci->type == SWIG_PY_POINTER) ? ci->pvalue : 0;
	  if (ptr) {
	    strncpy(buff, methods[i].ml_doc, ldoc);
	    buff += ldoc;
	    strncpy(buff, "swig_ptr: ", 10);
	    buff += 10;
	    SWIG_PackVoidPtr(buff, ptr, ty->name, lptr);
	    methods[i].ml_doc = ndoc;
	  }
	}
      }
    }
  }
}

/* -----------------------------------------------------------------------------*
 *  Initialize type list
 * -----------------------------------------------------------------------------*/

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
    return -1;
  }
  if (!o) {
    PyErr_SetString(PyExc_TypeError,
		    "PyModule_AddObject() needs non-NULL value");
    return -1;
  }
  
  dict = PyModule_GetDict(m);
  if (dict == NULL) {
    /* Internal error -- modules must have a dict! */
    PyErr_Format(PyExc_SystemError, "module '%s' has no __dict__",
		 PyModule_GetName(m));
    return -1;
  }
  if (PyDict_SetItemString(dict, name, o))
    return -1;
  Py_DECREF(o);
  return 0;
}
#endif

#ifdef __cplusplus
}
#endif

/* -----------------------------------------------------------------------------*
 *  Partial Init method
 * -----------------------------------------------------------------------------*/

#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT(void) SWIG_init(void) {
  static PyObject *SWIG_globals = 0; 
  PyObject *m, *d;
  if (!SWIG_globals) SWIG_globals = SWIG_newvarlink();

  /* Fix SwigMethods to carry the callback ptrs when needed */
  SWIG_Python_FixMethods(SwigMethods, swig_const_table, swig_types, swig_type_initial);
  
  m = Py_InitModule((char *) SWIG_name, SwigMethods);
  d = PyModule_GetDict(m);

  SWIG_InitializeModule(0);
  SWIG_InstallConstants(d,swig_const_table);
%}

