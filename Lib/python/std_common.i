//
// SWIG typemaps for STL - common utilities
// Luigi Ballabio
// Aug 3, 2002
//
// Python implementation

%{
#include <string>

PyObject* SwigInt_FromBool(bool b) {
    return PyInt_FromLong(b ? 1L : 0L);
}
double SwigNumber_Check(PyObject* o) {
    return PyFloat_Check(o) || PyInt_Check(o) || PyLong_Check(o);
}
double SwigNumber_AsDouble(PyObject* o) {
    return PyFloat_Check(o) ? PyFloat_AsDouble(o) 
        : (PyInt_Check(o) ?   double(PyInt_AsLong(o))
                            : double(PyLong_AsLong(o)));
}
PyObject* SwigString_FromString(const std::string& s) {
    return PyString_FromString(s.c_str());
}
std::string SwigString_AsString(PyObject* o) {
    return std::string(PyString_AsString(o));
}
%}
