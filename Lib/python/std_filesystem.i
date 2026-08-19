/* -----------------------------------------------------------------------------
 * std_filesystem.i
 *
 * SWIG typemaps for std::filesystem::path
 * ----------------------------------------------------------------------------- */

%{
#include <filesystem>
%}

namespace std {
  namespace filesystem {
    class path;
  }
}

%fragment("SWIG_std_filesystem", "header", fragment="<type_traits>") {
SWIGINTERN PyObject *SWIG_std_filesystem_importPathClass() {
  PyObject *cls = NULL;
  PyObject *module = PyImport_ImportModule("pathlib");
  if (module) {
    cls = PyObject_GetAttrString(module, "Path");
    SWIG_Py_DECREF(module);
  }
  return cls;
}

SWIGINTERN bool SWIG_std_filesystem_isPathInstance(PyObject *obj) {
  PyObject *cls = SWIG_std_filesystem_importPathClass();
  int is_instance = cls ? PyObject_IsInstance(obj, cls) : -1;
  SWIG_Py_XDECREF(cls);
  if (is_instance < 0)
    PyErr_Clear(); /* Report the object as not being a 'pathlib.Path' so that the usual type error is raised for it. */
  return is_instance > 0;
}

/* Converts a Python str or pathlib.Path instance into 'path'. Returns SWIG_OK, or SWIG_ERROR with a Python error set. */
SWIGINTERN int SWIG_std_filesystem_AsPath(PyObject *obj, std::filesystem::path *path) {
  int res = SWIG_ERROR;
  PyObject *str_obj = PyObject_Str(obj); /* Returns 'obj' itself, with a new reference, when it is already a str. */
  if (!str_obj)
    return SWIG_ERROR;
  if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
    Py_ssize_t size = 0;
    wchar_t *ws = PyUnicode_AsWideCharString(str_obj, &size);
    if (ws) {
      *path = std::filesystem::path(std::wstring(ws, static_cast<size_t>(size)));
      PyMem_Free(ws);
      res = SWIG_OK;
    }
  } else {
    PyObject *bytes = NULL;
    const char *s = SWIG_PyUnicode_AsUTF8AndSize(str_obj, NULL, &bytes);
    if (s) {
      *path = std::filesystem::path(s);
      res = SWIG_OK;
    }
    SWIG_Py_XDECREF(bytes);
  }
  SWIG_Py_DECREF(str_obj);
  return res;
}

/* Converts 'path' into a new pathlib.Path instance. Returns NULL with a Python error set on failure. */
SWIGINTERN PyObject *SWIG_std_filesystem_FromPath(const std::filesystem::path &path) {
  PyObject *result = NULL;
  PyObject *cls = SWIG_std_filesystem_importPathClass();
  if (cls) {
    if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
      std::wstring s = path.generic_wstring();
      result = PyObject_CallFunction(cls, "(u)", s.c_str());
    } else {
      std::string s = path.generic_string();
      result = PyObject_CallFunction(cls, "(s)", s.c_str());
    }
    SWIG_Py_DECREF(cls);
  }
  return result;
}
}

%typemap(in, fragment="SWIG_std_filesystem") std::filesystem::path {
  if (PyUnicode_Check($input) || SWIG_std_filesystem_isPathInstance($input)) {
    if (!SWIG_IsOK(SWIG_std_filesystem_AsPath($input, &$1)))
      SWIG_fail;
  } else {
    void *argp = 0;
    int res = SWIG_ConvertPtr($input, &argp, $descriptor(std::filesystem::path *), $disown | 0);
    if (!SWIG_IsOK(res)) {
      %argument_fail(res, "$type", $symname, $argnum);
    }
    std::filesystem::path *temp = %reinterpret_cast(argp, $1_ltype*);
    $1 = *temp;
  }
}

%typemap(in, fragment="SWIG_std_filesystem") const std::filesystem::path &(std::filesystem::path temp_path) {
  if (PyUnicode_Check($input) || SWIG_std_filesystem_isPathInstance($input)) {
    if (!SWIG_IsOK(SWIG_std_filesystem_AsPath($input, &temp_path)))
      SWIG_fail;
    $1 = &temp_path;
  } else {
    void *argp = 0;
    int res = SWIG_ConvertPtr($input, &argp, $descriptor, $disown | 0);
    if (!SWIG_IsOK(res)) {
      %argument_fail(res, "$type", $symname, $argnum);
    }
    $1 = %reinterpret_cast(argp, $1_ltype);
  }
}

%typemap(out, fragment="SWIG_std_filesystem") std::filesystem::path {
  $result = SWIG_std_filesystem_FromPath($1);
  if (!$result)
    SWIG_fail;
}

%typemap(out, fragment="SWIG_std_filesystem") const std::filesystem::path & {
  $result = SWIG_std_filesystem_FromPath(*$1);
  if (!$result)
    SWIG_fail;
}
