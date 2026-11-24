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

/* An instance of a heap type holds a reference on its type, which the tp_dealloc of the heap type must release after
   freeing the instance. PyType_GenericAlloc() has always taken this reference, but PyObject_New() only takes it from
   Python 3.8. This came from bpo-35810 and is described in "Changes in the C API" in What's New In Python 3.8 and in
   the tp_dealloc documentation:
     https://docs.python.org/3/whatsnew/3.8.html#changes-in-the-c-api
     https://docs.python.org/3/c-api/typeobj.html#c.PyTypeObject.tp_dealloc
   It is only released from Python 3.8, as before then subtype_dealloc() releases it for an instance of a Python
   subclass. A stable ABI module built for an earlier Python can run on 3.8 or later, so it checks the version it runs on. */
SWIGINTERN void
SWIG_PyType_DeallocRelease(PyTypeObject *type) {
#if defined(SWIG_HEAPTYPES) && defined(Py_LIMITED_API) && Py_LIMITED_API+0 < 0x03080000
  static int holds_reference = -1;
  if (holds_reference < 0) {
    const char *version = Py_GetVersion();
    const char *dot = strchr(version, '.');
    int major = atoi(version);
    int minor = dot ? atoi(dot + 1) : 0;
    holds_reference = major > 3 || (major == 3 && minor >= 8);
  }
  if (holds_reference)
    SWIG_Py_DECREF((PyObject *)type);
#elif defined(SWIG_HEAPTYPES) && PY_VERSION_HEX >= 0x03080000
  SWIG_Py_DECREF((PyObject *)type);
#else
  (void)type;
#endif
}

/* PyType_GetQualName() was added to Python 3.11 */
#if (PY_VERSION_HEX >= 0x030b0000) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030b0000)
# define SWIG_PyType_GetQualName PyType_GetQualName
#else
SWIGINTERN PyObject *
SWIG_PyType_GetQualName(PyTypeObject *type) {
  return PyObject_GetAttrString((PyObject *)type, "__qualname__");
}
#endif

/* PyType_GetModuleName() and PyType_GetFullyQualifiedName() were added to Python 3.13 */
#if (PY_VERSION_HEX >= 0x030d00a6) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030d0000)
# define SWIG_PyType_GetModuleName PyType_GetModuleName
# define SWIG_PyType_GetFullyQualifiedName PyType_GetFullyQualifiedName
#else
SWIGINTERN PyObject *
SWIG_PyType_GetModuleName(PyTypeObject *type) {
  return PyObject_GetAttrString((PyObject *)type, "__module__");
}

SWIGINTERN PyObject *
SWIG_PyType_GetFullyQualifiedName(PyTypeObject *type) {
  PyObject *result = NULL;
  PyObject *qualname = SWIG_PyType_GetQualName(type);
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

/* gh-114329 added PyList_GetItemRef() to Python 3.13.0a4 */
#if (PY_VERSION_HEX >= 0x030d00a4) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030d0000)
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
#if (PY_VERSION_HEX >= 0x030d00a1) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030d0000)
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

/* gh-106521 added PyObject_GetOptionalAttr() to Python 3.13.0a1 */
#if (PY_VERSION_HEX >= 0x030d00a1) && (!defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x030d0000)
# define SWIG_PyObject_GetOptionalAttr PyObject_GetOptionalAttr
#else
SWIGINTERN int
SWIG_PyObject_GetOptionalAttr(PyObject *obj, PyObject *attr_name, PyObject **result) {
  *result = PyObject_GetAttr(obj, attr_name);
  if (*result != NULL)
    return 1;
  if (PyErr_ExceptionMatches(PyExc_AttributeError)) {
    PyErr_Clear();
    return 0;
  }
  return -1;
}
#endif
