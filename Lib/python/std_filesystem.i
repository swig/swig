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

%fragment("SWIG_std_filesystem", "header") {
SWIGINTERN PyObject *SWIG_std_filesystem_importPathClass() {
  PyObject *module = PyImport_ImportModule("pathlib");
  PyObject *cls = PyObject_GetAttrString(module, "Path");
  SWIG_Py_DECREF(module);
  return cls;
}

SWIGINTERN bool SWIG_std_filesystem_isPathInstance(PyObject *obj) {
  PyObject *cls = SWIG_std_filesystem_importPathClass();
  bool is_instance = PyObject_IsInstance(obj, cls);
  SWIG_Py_DECREF(cls);
  return is_instance;
}
}

%typemap(in, fragment="SWIG_std_filesystem", fragment="<type_traits>") std::filesystem::path {
  if (PyUnicode_Check($input)) {
    PyObject *bytes = NULL;
    const char *s = SWIG_PyUnicode_AsUTF8AndSize($input, NULL, &bytes);
    $1 = std::filesystem::path(s);
    SWIG_Py_XDECREF(bytes);
  } else if (SWIG_std_filesystem_isPathInstance($input)) {
    PyObject *str_obj = PyObject_Str($input);
    if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
      Py_ssize_t size = 0;
      wchar_t *ws = PyUnicode_AsWideCharString(str_obj, &size);
      if (!ws) SWIG_fail;
      $1 = std::filesystem::path(std::wstring(ws, static_cast<size_t>(size)));
      PyMem_Free(ws);
    } else {
      PyObject *bytes = NULL;
      const char *s = SWIG_PyUnicode_AsUTF8AndSize(str_obj, NULL, &bytes);
      $1 = std::filesystem::path(s);
      SWIG_Py_XDECREF(bytes);
    }
    SWIG_Py_DECREF(str_obj);
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

%typemap(in, fragment="SWIG_std_filesystem", fragment="<type_traits>") const std::filesystem::path &(std::filesystem::path temp_path) {
  if (PyUnicode_Check($input)) {
    PyObject *bytes = NULL;
    const char *s = SWIG_PyUnicode_AsUTF8AndSize($input, NULL, &bytes);
    temp_path = std::filesystem::path(s);
    $1 = &temp_path;
    SWIG_Py_XDECREF(bytes);
  } else if (SWIG_std_filesystem_isPathInstance($input)) {
    PyObject *str_obj = PyObject_Str($input);
    if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
      Py_ssize_t size = 0;
      wchar_t *ws = PyUnicode_AsWideCharString(str_obj, &size);
      if (!ws) SWIG_fail;
      temp_path = std::filesystem::path(std::wstring(ws, static_cast<size_t>(size)));
      $1 = &temp_path;
      PyMem_Free(ws);
    } else {
      PyObject *bytes = NULL;
      const char *s = SWIG_PyUnicode_AsUTF8AndSize(str_obj, NULL, &bytes);
      temp_path = std::filesystem::path(s);
      $1 = &temp_path;
      SWIG_Py_XDECREF(bytes);
    }
    SWIG_Py_DECREF(str_obj);
  } else {
    void *argp = 0;
    int res = SWIG_ConvertPtr($input, &argp, $descriptor, $disown | 0);
    if (!SWIG_IsOK(res)) {
      %argument_fail(res, "$type", $symname, $argnum);
    }
    $1 = %reinterpret_cast(argp, $1_ltype);
  }
}

%typemap(out, fragment="SWIG_std_filesystem", fragment="<type_traits>") std::filesystem::path {
  PyObject *args;
  if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
    std::wstring s = $1.generic_wstring();
    args = Py_BuildValue("(u)", s.data());
  } else {
    std::string s = $1.generic_string();
    args = Py_BuildValue("(s)", s.data());
  }
  PyObject *cls = SWIG_std_filesystem_importPathClass();
  $result = PyObject_CallObject(cls, args);
  SWIG_Py_DECREF(cls);
  SWIG_Py_DECREF(args);
}

%typemap(out, fragment="SWIG_std_filesystem", fragment="<type_traits>") const std::filesystem::path & {
  PyObject *args;
  if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
    std::wstring s = $1->generic_wstring();
    args = Py_BuildValue("(u)", s.data());
  } else {
    std::string s = $1->generic_string();
    args = Py_BuildValue("(s)", s.data());
  }
  PyObject *cls = SWIG_std_filesystem_importPathClass();
  $result = PyObject_CallObject(cls, args);
  SWIG_Py_DECREF(cls);
  SWIG_Py_DECREF(args);
}
