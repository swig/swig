/*
  filesystem::path
*/
%{
#if __cplusplus >= 201703L
#include <filesystem>
#include <Python.h>
#endif // __cplusplus >= 201703L
%}

%fragment("common", "header") {
    PyObject * importPathCls() {
        PyObject * module = PyImport_ImportModule("pathlib");
        PyObject * cls = PyObject_GetAttrString(module, "Path");

        Py_DECREF(module);

        return cls;
    }

    bool isPathInstance(PyObject * obj) {
        PyObject * cls = importPathCls();
        bool is_instance =  PyObject_IsInstance(obj, cls);

        Py_DECREF(cls);

        return is_instance;
    }

    const char * pathToStr(PyObject * obj) {
        PyObject * str_obj = PyObject_Str(obj);
        const char * s = PyUnicode_AsUTF8(str_obj);

        Py_DECREF(str_obj);

        return s;
    }
}

%typemap(in, fragment="common") std::filesystem::path {
    if (PyUnicode_Check($input)) {
        const char* s = PyUnicode_AsUTF8($input);
        $1 = std::filesystem::path(s);
    }
    else if (isPathInstance($input)) {
        const char * s = pathToStr($input);
        $1 = std::filesystem::path(s);
    }
    else {
        void* argp = 0;
        int res = SWIG_ConvertPtr($input, &argp, $descriptor(std::filesystem::path *), $disown |  0 );
        if (!SWIG_IsOK(res)) {
            %argument_fail(res, "$type", $symname, $argnum);
        }
        std::filesystem::path * temp = %reinterpret_cast(argp, $ltype*);
        $1 = *temp;
    }
}

%typemap(in, fragment="common") std::filesystem::path const *, std::filesystem::path const & {
    if (PyUnicode_Check($input)) {
        const char* s = PyUnicode_AsUTF8($input);
        $1 = new std::filesystem::path(s);
    }
    else if (isPathInstance($input)) {
        const char * s = pathToStr($input);
        $1 = new std::filesystem::path(s);
    }
    else {
        void* argp = 0;
        int res = SWIG_ConvertPtr($input, &argp, $descriptor, $disown |  0 );
        if (!SWIG_IsOK(res)) {
            %argument_fail(res, "$type", $symname, $argnum);
        }
        $1 = %reinterpret_cast(argp, $ltype);
    }
}

%typemap(out, fragment="common") std::filesystem::path {
    const std::string& s = $1.string();

    PyObject * cls = importPathCls();

    PyObject* args = Py_BuildValue("(s)", s.data());
    $result = PyObject_CallObject(cls, args);

    Py_DECREF(cls);
    Py_DECREF(args);
}

%include <std_string.i>
