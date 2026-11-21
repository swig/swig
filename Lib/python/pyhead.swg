#if !defined(SWIG_NO_HEAPTYPES)
#if !defined(SWIG_HEAPTYPES)
#define SWIG_HEAPTYPES
#endif
#endif

#if defined(SWIG_HEAPTYPES)
#if PY_VERSION_HEX < 0x030c0000
#include <structmember.h>
#define Py_READONLY READONLY
#define Py_T_PYSSIZET T_PYSSIZET
#endif
#endif

#include <stddef.h> /* For offsetof */


/* Wrapper around PyUnicode_AsUTF8AndSize - call Py_XDECREF on the returned pbytes when finished with the returned string */
SWIGINTERN const char *
SWIG_PyUnicode_AsUTF8AndSize(PyObject *str, Py_ssize_t *psize, PyObject **pbytes)
{
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030A0000
  *pbytes = NULL;
  return PyUnicode_AsUTF8AndSize(str, psize);
#else
  const char *chars;
  *pbytes = PyUnicode_AsUTF8String(str);
  chars = *pbytes ? PyBytes_AsString(*pbytes) : NULL;
  if (chars && psize)
    *psize = PyBytes_Size(*pbytes);
  return chars;
#endif
}

#define SWIG_RUNTIME_MODULE "swig_runtime_data" SWIG_RUNTIME_VERSION

/* SWIGPY_USE_CAPSULE is no longer used within SWIG itself, but some user interface files check for it. */
# define SWIGPY_USE_CAPSULE
#ifdef SWIGPYTHON_BUILTIN
# define SWIGPY_CAPSULE_ATTR_NAME "type_pointer_capsule_builtin" SWIG_TYPE_TABLE_NAME
#else
# define SWIGPY_CAPSULE_ATTR_NAME "type_pointer_capsule" SWIG_TYPE_TABLE_NAME
#endif
#define SWIGPY_CAPSULE_NAME SWIG_RUNTIME_MODULE "." SWIGPY_CAPSULE_ATTR_NAME

#if defined(Py_LIMITED_API)
# define PyTuple_GET_ITEM PyTuple_GetItem
/* Note that PyTuple_SetItem() has different semantics from PyTuple_SET_ITEM as it decref's the original tuple item, so in general they cannot be used
  interchangeably. However in SWIG-generated code PyTuple_SET_ITEM is only used with newly initialized tuples without any items and for them this does work. */
# define PyTuple_SET_ITEM PyTuple_SetItem
# define PyTuple_GET_SIZE PyTuple_Size
# define PyCFunction_GET_FLAGS PyCFunction_GetFlags
# define PyCFunction_GET_FUNCTION PyCFunction_GetFunction
# define PyCFunction_GET_SELF PyCFunction_GetSelf
# define PyList_GET_ITEM PyList_GetItem
# define PyList_SET_ITEM PyList_SetItem
# define PySliceObject PyObject
#endif

/* Increment and Decrement wrappers - for portability when using the stable abi and for performance otherwise */
#ifdef Py_LIMITED_API
# define SWIG_Py_INCREF Py_IncRef
# define SWIG_Py_XINCREF Py_IncRef
# define SWIG_Py_DECREF Py_DecRef
# define SWIG_Py_XDECREF Py_DecRef
#else
# define SWIG_Py_INCREF Py_INCREF
# define SWIG_Py_XINCREF Py_XINCREF
# define SWIG_Py_DECREF Py_DECREF
# define SWIG_Py_XDECREF Py_XDECREF
#endif

#if (PY_VERSION_HEX >= 0x030d00a6) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030d0000)
# define SWIG_PyType_GetFullyQualifiedName PyType_GetFullyQualifiedName
#else
SWIGINTERN PyObject *
SWIG_PyType_GetFullyQualifiedName(PyTypeObject *type) {
  PyObject *result = NULL;
#if (PY_VERSION_HEX >= 0x030b0000) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030b0000)
  PyObject *qualname = PyType_GetQualName(type);
#else
  PyObject *qualname = PyObject_GetAttrString((PyObject *)type, "__qualname__");
#endif
  if (qualname) {
    PyObject *mod = PyObject_GetAttrString((PyObject *)type, "__module__");
    if (mod) {
      if (PyUnicode_Check(mod) && PyUnicode_CompareWithASCIIString(mod, "builtins") && PyUnicode_CompareWithASCIIString(mod, "__main__")) {
        result = PyUnicode_FromFormat("%U%c%U", mod, '.', qualname);
        SWIG_Py_DECREF(qualname);
      } else {
        result = qualname;
      }
      SWIG_Py_DECREF(mod);
    } else {
      result = qualname;
    }
  }

  return result;
}
#endif

/* Return 1 if the type's fully qualified name is modname.qualname, or 0
   otherwise (modname and qualname must be string literals). Where possible,
   the type's existing __qualname__ and __module__ strings are compared
   individually, without constructing a new string; the cheap __qualname__
   check also quickly rejects most types, such as proxy classes. */
#define SWIG_PyType_HasName(type, modname, qualname) \
  SWIG_PyType_HasNameImpl(type, modname, qualname, modname "." qualname)

SWIGINTERN int
SWIG_PyType_HasNameImpl(PyTypeObject *type, const char *modname,
                        const char *qualname, const char *fullname) {
  int cmp;
  /* If we have PyType_GetQualName() (Python 3.11), we can return early
     if qualname does not match */
#if (PY_VERSION_HEX >= 0x030b0000) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030b0000)
  PyObject *tpqualname = PyType_GetQualName(type);
  if (!tpqualname) {
    PyErr_Clear();
    return 0;
  }
  cmp = PyUnicode_CompareWithASCIIString(tpqualname, qualname);
  SWIG_Py_DECREF(tpqualname);
  if (cmp != 0)
    return 0;
#else
  (void)qualname;
#endif

  /* If we have PyType_GetModuleName() (Python 3.13), we can return
     if modname does not match */
#if (PY_VERSION_HEX >= 0x030d00a6) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030d0000)
  {
    PyObject *tpmodname = PyType_GetModuleName(type);
    (void)fullname;
    if (!tpmodname) {
      PyErr_Clear();
      return 0;
    }
    cmp = PyUnicode_Check(tpmodname) ? PyUnicode_CompareWithASCIIString(tpmodname, modname) : 1;
    SWIG_Py_DECREF(tpmodname);
  }
#else
  {
    /* Otherwise, check the fully qualified name */
    PyObject *tpname = SWIG_PyType_GetFullyQualifiedName(type);
    (void)modname;
    if (!tpname) {
      PyErr_Clear();
      return 0;
    }
    cmp = PyUnicode_CompareWithASCIIString(tpname, fullname);
    SWIG_Py_DECREF(tpname);
  }
#endif
  return cmp == 0;
}

/* gh-114329 added PyList_GetItemRef() to Python 3.13.0a4 */
#if (PY_VERSION_HEX >= 0x030d00a4) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030d00a4)
# define SWIG_PyList_GetItemRef PyList_GetItemRef
#else
SWIGINTERN PyObject *
SWIG_PyList_GetItemRef(PyObject *op, Py_ssize_t index) {
  PyObject *item = PyList_GetItem(op, index);
  Py_XINCREF(item);
  return item;
}
#endif

/* gh-106004 added PyDict_GetItemRef() and PyDict_GetItemStringRef() to Python 3.13.0a1
   functions are renamed here for compatibility with abi3audit */
#if (PY_VERSION_HEX >= 0x030d00a1) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030d00a1)
# define SWIG_PyDict_GetItemRef PyDict_GetItemRef
# define SWIG_PyDict_GetItemStringRef PyDict_GetItemStringRef
#else
SWIGINTERN int
SWIG_PyDict_GetItemRef(PyObject *mp, PyObject *key, PyObject **result) {
  PyObject *item = PyDict_GetItemWithError(mp, key);
  if (item != NULL) {
    *result = (PyObject *)(item);
    SWIG_Py_INCREF(*result);
    return 1;
  }
  if (!PyErr_Occurred()) {
    *result = NULL;
    return 0;
  }
  *result = NULL;
  return -1;
}

SWIGINTERN int
SWIG_PyDict_GetItemStringRef(PyObject *mp, const char *key, PyObject **result) {
  int res;
  PyObject *key_obj = PyUnicode_FromString(key);
  if (key_obj == NULL) {
    *result = NULL;
    return -1;
  }
  res = SWIG_PyDict_GetItemRef(mp, key_obj, result);
  Py_DECREF(key_obj);
  return res;
}
#endif
