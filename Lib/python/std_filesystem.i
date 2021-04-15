/*
  filesystem::path
*/

%{
#include <filesystem>
#include <Python.h>
%}

%typemap(in) std::filesystem::path {
    if (PyUnicode_Check($input)) {
        const char* s = PyUnicode_AsUTF8($input);
        $1 = std::filesystem::path(s);
    }
    else {
        PyObject* module = PyImport_ImportModule("pathlib");
        PyObject* cls = PyObject_GetAttrString(module, "Path");
        if (PyObject_IsInstance($input, cls)) {
            PyObject* s1 = PyObject_Str($input);
            const char* s2 = PyUnicode_AsUTF8(s1);
            $1 = std::filesystem::path(s2);
        }
        else {
            void* argp = 0;
            int res = SWIG_ConvertPtr($input, &argp,SWIGTYPE_p_std__filesystem__path, $disown |  0 );
            if (!SWIG_IsOK(res)) { 
                SWIG_exception_fail(SWIG_ArgError(res), "in method '" "$symname" "', argument "
                                "$argnum"" of type '" "$type""'"); 
            } 
            std::filesystem::path * ptr = ($ltype*)(argp);
            $1 = *ptr;
        }
    }
}

%typemap(in) std::filesystem::path const *, std::filesystem::path const & {
    if (PyUnicode_Check($input)) {
        const char* s = PyUnicode_AsUTF8($input);
        $1 = new std::filesystem::path(s);
    }
    else {
        PyObject* module = PyImport_ImportModule("pathlib");
        PyObject* cls = PyObject_GetAttrString(module, "Path");
        if (PyObject_IsInstance($input, cls)) {
            PyObject* s1 = PyObject_Str($input);
            const char* s2 = PyUnicode_AsUTF8(s1);
            $1 = new std::filesystem::path(s2);
        }
        else {
            void* argp = 0;
            int res = SWIG_ConvertPtr($input, &argp,$descriptor, $disown |  0 );
            if (!SWIG_IsOK(res)) { 
                SWIG_exception_fail(SWIG_ArgError(res), "in method '" "$symname" "', argument "
                                "$argnum"" of type '" "$type""'"); 
            } 
            $1 = ($ltype)(argp);
        }
    }
}

%typemap(out) std::filesystem::path {
    const std::string& s = $1.string();
    // $result = PyUnicode_FromString(s.data());
    
    PyObject* module = PyImport_ImportModule("pathlib");
    PyObject* cls = PyObject_GetAttrString(module, "Path");
    
    PyObject* args = Py_BuildValue("(s)", s.data());
    $result = PyObject_CallObject(cls, args);
    
    Py_DECREF(module);
    Py_DECREF(cls);
    Py_DECREF(args);
}

%include <std_string.i>
