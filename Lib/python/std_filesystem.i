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
}

%typemap(in, fragment="SWIG_std_filesystem", fragment="<type_traits>") std::filesystem::path {
  if (PyUnicode_Check($input)) {
    PyObject *bytes = NULL;
    const char *s = SWIG_PyUnicode_AsUTF8AndSize($input, NULL, &bytes);
    if (!s) SWIG_fail;
    $1 = std::filesystem::path(s);
    SWIG_Py_XDECREF(bytes);
  } else if (SWIG_std_filesystem_isPathInstance($input)) {
    PyObject *str_obj = PyObject_Str($input);
    if (!str_obj) SWIG_fail;
    if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
      Py_ssize_t size = 0;
      wchar_t *ws = PyUnicode_AsWideCharString(str_obj, &size);
      if (!ws) {
        SWIG_Py_DECREF(str_obj);
        SWIG_fail;
      }
      $1 = std::filesystem::path(std::wstring(ws, static_cast<size_t>(size)));
      PyMem_Free(ws);
    } else {
      PyObject *bytes = NULL;
      const char *s = SWIG_PyUnicode_AsUTF8AndSize(str_obj, NULL, &bytes);
      if (!s) {
        SWIG_Py_DECREF(str_obj);
        SWIG_fail;
      }
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
    if (!argp) {
      %argument_nullref("$type", $symname, $argnum);
    }
    std::filesystem::path *temp = %reinterpret_cast(argp, $1_ltype*);
    $1 = *temp;
  }
}

%typemap(in, fragment="SWIG_std_filesystem", fragment="<type_traits>") const std::filesystem::path &(std::filesystem::path temp_path) {
  if (PyUnicode_Check($input)) {
    PyObject *bytes = NULL;
    const char *s = SWIG_PyUnicode_AsUTF8AndSize($input, NULL, &bytes);
    if (!s) SWIG_fail;
    temp_path = std::filesystem::path(s);
    $1 = &temp_path;
    SWIG_Py_XDECREF(bytes);
  } else if (SWIG_std_filesystem_isPathInstance($input)) {
    PyObject *str_obj = PyObject_Str($input);
    if (!str_obj) SWIG_fail;
    if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
      Py_ssize_t size = 0;
      wchar_t *ws = PyUnicode_AsWideCharString(str_obj, &size);
      if (!ws) {
        SWIG_Py_DECREF(str_obj);
        SWIG_fail;
      }
      temp_path = std::filesystem::path(std::wstring(ws, static_cast<size_t>(size)));
      $1 = &temp_path;
      PyMem_Free(ws);
    } else {
      PyObject *bytes = NULL;
      const char *s = SWIG_PyUnicode_AsUTF8AndSize(str_obj, NULL, &bytes);
      if (!s) {
        SWIG_Py_DECREF(str_obj);
        SWIG_fail;
      }
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
    if (!argp) {
      %argument_nullref("$type", $symname, $argnum);
    }
    $1 = %reinterpret_cast(argp, $1_ltype);
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STDFILESYSTEMPATH, fragment="SWIG_std_filesystem") std::filesystem::path, const std::filesystem::path & %{
  if (PyUnicode_Check($input) || SWIG_std_filesystem_isPathInstance($input)) {
    $1 = 1;
  } else {
    void *vptr = 0;
    int res = SWIG_ConvertPtr($input, &vptr, $descriptor(std::filesystem::path *), SWIG_POINTER_NO_NULL);
    $1 = SWIG_CheckState(res);
  }
%}

%typemap(out, fragment="SWIG_std_filesystem", fragment="<type_traits>") std::filesystem::path {
  PyObject *args;
  if constexpr (std::is_same_v<typename std::filesystem::path::value_type, wchar_t>) {
    std::wstring s = $1.generic_wstring();
    args = Py_BuildValue("(u)", s.data());
  } else {
    std::string s = $1.generic_string();
    args = Py_BuildValue("(s)", s.data());
  }
  if (!args) SWIG_fail;
  PyObject *cls = SWIG_std_filesystem_importPathClass();
  $result = cls ? PyObject_CallObject(cls, args) : NULL;
  SWIG_Py_XDECREF(cls);
  SWIG_Py_DECREF(args);
  if (!$result) SWIG_fail;
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
  if (!args) SWIG_fail;
  PyObject *cls = SWIG_std_filesystem_importPathClass();
  $result = cls ? PyObject_CallObject(cls, args) : NULL;
  SWIG_Py_XDECREF(cls);
  SWIG_Py_DECREF(args);
  if (!$result) SWIG_fail;
}
