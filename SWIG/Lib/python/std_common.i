//
// SWIG typemaps for STL - common utilities
// Luigi Ballabio
// Aug 3, 2002
//
// Python implementation

%apply size_t { std::size_t };

%{
#include <string>

PyObject* SwigInt_FromBool(bool b) {
    return PyInt_FromLong(b ? 1L : 0L);
}
int SwigNumber_Check(PyObject* o) {
    return PyFloat_Check(o) || PyInt_Check(o) || PyLong_Check(o);
}
double SwigNumber_AsDouble(PyObject* o) {
    return PyFloat_Check(o) ? PyFloat_AsDouble(o) 
        : (PyInt_Check(o) ?   double(PyInt_AsLong(o))
                            : double(PyLong_AsLong(o)));
}
PyObject* SwigString_FromString(const std::string& s) {
    return PyString_FromStringAndSize(s.data(),s.size());
}
std::string SwigString_AsString(PyObject* o) {
    return std::string(PyString_AsString(o));
}
%}
