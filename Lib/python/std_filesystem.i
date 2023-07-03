/*
  filesystem::path
*/
%{
#include <filesystem>
#include <type_traits>
%}

%fragment("SWIG_std_filesystem", "header") {
  SWIGINTERN PyObject * SWIG_std_filesystem_importPathClass() {
    PyObject * module = PyImport_ImportModule("pathlib");
    PyObject * cls = PyObject_GetAttrString(module, "Path");
    Py_DECREF(module);
    return cls;
  }

  SWIGINTERN bool SWIG_std_filesystem_isPathInstance(PyObject * obj) {
    PyObject * cls = SWIG_std_filesystem_importPathClass();
    bool is_instance =  PyObject_IsInstance(obj, cls);
    Py_DECREF(cls);
    return is_instance;
  }
}

%typemap(in, fragment="SWIG_std_filesystem") std::filesystem::path {
  if (PyUnicode_Check($input)) {
    const char* s = PyUnicode_AsUTF8($input);
    $1 = std::filesystem::path(s);
  } else if (SWIG_std_filesystem_isPathInstance($input)) {
    PyObject * str_obj = PyObject_Str($input);   // New reference
    if constexpr (std::is_same_v< typename std::filesystem::path::value_type, wchar_t>) {
      Py_ssize_t size = 0;
      wchar_t * s = PyUnicode_AsWideCharString(str_obj, &size);
      $1 = std::filesystem::path(std::wstring{s, static_cast<size_t>(size)});
      PyMem_Free(s);
    } else {
      const char * s = PyUnicode_AsUTF8(str_obj);  // This stores the UTF-8 representation buffer within str_obj
      $1 = std::filesystem::path(s);
    }
    Py_DECREF(str_obj);
  } else {
    void* argp = 0;
    int res = SWIG_ConvertPtr($input, &argp, $descriptor(std::filesystem::path *), $disown |  0 );
    if (!SWIG_IsOK(res)) {
      %argument_fail(res, "$type", $symname, $argnum);
    }
    std::filesystem::path * temp = %reinterpret_cast(argp, $ltype*);
    $1 = *temp;
  }
}

%typemap(in, fragment="SWIG_std_filesystem") std::filesystem::path const *, std::filesystem::path const & {
  if (PyUnicode_Check($input)) {
    const char* s = PyUnicode_AsUTF8($input);
    $1 = new std::filesystem::path(s);
  } else if (SWIG_std_filesystem_isPathInstance($input)) {
    PyObject * str_obj = PyObject_Str($input);   // New reference
    if constexpr (std::is_same_v< typename std::filesystem::path::value_type, wchar_t>) {
      Py_ssize_t size = 0;
      wchar_t * s = PyUnicode_AsWideCharString(str_obj, &size);
      $1 = new std::filesystem::path(std::wstring{s, static_cast<size_t>(size)});
      PyMem_Free(s);
    } else {
      const char * s = PyUnicode_AsUTF8(str_obj);
      $1 = new std::filesystem::path(s);
    }
    Py_DECREF(str_obj);
  } else {
    void* argp = 0;
    int res = SWIG_ConvertPtr($input, &argp, $descriptor, $disown |  0 );
    if (!SWIG_IsOK(res)) {
      %argument_fail(res, "$type", $symname, $argnum);
    }
    $1 = %reinterpret_cast(argp, $ltype);
  }
}

%typemap(out, fragment="SWIG_std_filesystem") std::filesystem::path {

  PyObject* args;
  if constexpr (std::is_same_v< typename std::filesystem::path::value_type, wchar_t>) {
    const std::wstring s = $1.generic_wstring();
    args = Py_BuildValue("(u)", s.data());
  } else {
    const std::string s = $1.generic_string();
    args = Py_BuildValue("(s)", s.data());
  }


  PyObject * cls = SWIG_std_filesystem_importPathClass();
  $result = PyObject_CallObject(cls, args);

  Py_DECREF(cls);
  Py_DECREF(args);
}

%include <std_string.i>
