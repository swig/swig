extern int
pyswig_setter_closure (PyObject *obj, PyObject *val, void *closure)
{
    if (!closure)
        return -1;
    PyObject *tuple = PyTuple_New(1);
    assert(tuple);
    PyTuple_SET_ITEM(tuple, 0, val);
    Py_XINCREF(val);
    PyObject *result = ((PyCFunction) closure)(obj, tuple);
    Py_DECREF(tuple);
    Py_XDECREF(result);
    return result ? 0 : -1;
}

#ifdef __cplusplus

namespace {

template <typename _Tp> struct PySwigBuiltin : public SwigPyObject {

    typedef PySwigBuiltin<_Tp> this_type;
    typedef _Tp obj_type;
    typedef obj_type* pointer;
    typedef obj_type& reference;

    static PyMethodDef methods[];
    static PyGetSetDef getset[];
    static PyNumberMethods number_methods;
    static PyTypeObject pytype;
    static SwigPyClientData clientdata;
};

template <typename _Tp> void py_builtin_dealloc (PyObject *pyobj)
{
    typedef PySwigBuiltin<_Tp> builtin_type;
    builtin_type *obj = (builtin_type*) pyobj;
    if (obj->own)
	delete reinterpret_cast<_Tp*>(obj->ptr);
    (*pyobj->ob_type->tp_free)(pyobj);
}

template <PyCFunction func> PyObject*
pyswig_binaryfunc_closure (PyObject *a, PyObject *b)
{
    PyObject *tuple = PyTuple_New(1);
    assert(tuple);
    PyTuple_SET_ITEM(tuple, 0, b);
    PyObject *result = func(a, tuple);
    Py_DECREF(tuple);
    return result;
}

template <PyCFunction func> PyObject*
pyswig_ternaryfunc_closure (PyObject *a, PyObject *b, PyObject *c)
{
    PyObject *tuple = PyTuple_New(2);
    assert(tuple);
    PyTuple_SET_ITEM(tuple, 0, b);
    PyTuple_SET_ITEM(tuple, 1, c);
    PyObject *result = func(a, tuple);
    Py_DECREF(tuple);
    return result;
}

} // namespace {

#endif
