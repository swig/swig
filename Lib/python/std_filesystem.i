/*
  filesystem::path
*/
%{
#include <filesystem>
%}

%fragment("SWIG_std_filesystem", "header") {
    SWIGINTERN PyObject * importPathCls() {
        PyObject * module = PyImport_ImportModule("pathlib");
        PyObject * cls = PyObject_GetAttrString(module, "Path");
        Py_DECREF(module);
        return cls;
    }

    SWIGINTERN bool isPathInstance(PyObject * obj) {
        PyObject * cls = importPathCls();
        bool is_instance =  PyObject_IsInstance(obj, cls);
        Py_DECREF(cls);
        return is_instance;
    }
}

%typemap(in, fragment="SWIG_std_filesystem") std::filesystem::path {
    if (PyUnicode_Check($input)) {
        const char* s = PyUnicode_AsUTF8($input);
        $1 = std::filesystem::path(s);
    }
    else if (isPathInstance($input)) {
        PyObject * str_obj = PyObject_Str($input);   // New reference
        const char * s = PyUnicode_AsUTF8(str_obj);  // This stores the UTF-8 representation buffer within str_obj
        $1 = std::filesystem::path(s);
        Py_DECREF(str_obj);
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

%typemap(in, fragment="SWIG_std_filesystem") std::filesystem::path const *, std::filesystem::path const & {
    if (PyUnicode_Check($input)) {
        const char* s = PyUnicode_AsUTF8($input);
        $1 = new std::filesystem::path(s);
    }
    else if (isPathInstance($input)) {
        PyObject * str_obj = PyObject_Str($input);
        const char * s = PyUnicode_AsUTF8(str_obj);
        $1 = new std::filesystem::path(s);
        Py_DECREF(str_obj);
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

%typemap(out, fragment="SWIG_std_filesystem") std::filesystem::path {
    const std::string s = $1.string();

    PyObject * cls = importPathCls();

    PyObject* args = Py_BuildValue("(s)", s.data());
    $result = PyObject_CallObject(cls, args);

    Py_DECREF(cls);
    Py_DECREF(args);
}

%include <std_string.i>
