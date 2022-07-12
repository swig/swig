/* Compatibility macros for Python 3 */

#define PyClass_Check(obj) PyObject_IsInstance(obj, (PyObject *)&PyType_Type)
#define PyInt_Check(x) PyLong_Check(x)
#define PyInt_AsLong(x) PyLong_AsLong(x)
#define PyInt_FromLong(x) PyLong_FromLong(x)
#define PyInt_FromSize_t(x) PyLong_FromSize_t(x)
#define PyString_Check(name) PyBytes_Check(name)
#define PyString_FromString(x) PyUnicode_FromString(x)
#define PyString_Format(fmt, args)  PyUnicode_Format(fmt, args)
#define PyString_AsString(str) PyBytes_AsString(str)
#define PyString_Size(str) PyBytes_Size(str)	
#define PyString_InternFromString(key) PyUnicode_InternFromString(key)
#define Py_TPFLAGS_HAVE_CLASS Py_TPFLAGS_BASETYPE
#define _PyLong_FromSsize_t(x) PyLong_FromSsize_t(x)

#ifndef Py_TYPE
#  define Py_TYPE(op) ((op)->ob_type)
#endif

#define SWIG_Python_str_FromFormat PyUnicode_FromFormat


/* Warning: This function will allocate a new string in Python 3,
 * so please call SWIG_Python_str_DelForPy3(x) to free the space.
 */
SWIGINTERN char*
SWIG_Python_str_AsChar(PyObject *str)
{
  return (char *)PyUnicode_AsUTF8(str);
}

#define SWIG_Python_str_DelForPy3(x)


SWIGINTERN PyObject*
SWIG_Python_str_FromChar(const char *c)
{
  return PyUnicode_FromString(c); 
}

#ifndef PyObject_DEL
# define PyObject_DEL PyObject_Del
#endif

/* SWIGPY_USE_CAPSULE is no longer used within SWIG itself, but some user interface files check for it. */
# define SWIGPY_USE_CAPSULE
#ifdef SWIGPYTHON_BUILTIN
# define SWIGPY_CAPSULE_ATTR_NAME "type_pointer_capsule_builtin" SWIG_TYPE_TABLE_NAME
#else
# define SWIGPY_CAPSULE_ATTR_NAME "type_pointer_capsule" SWIG_TYPE_TABLE_NAME
#endif
# define SWIGPY_CAPSULE_NAME ("swig_runtime_data" SWIG_RUNTIME_VERSION "." SWIGPY_CAPSULE_ATTR_NAME)

