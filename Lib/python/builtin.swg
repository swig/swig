#define PYSWIG_BINARYFUNC_CLOSURE(wrapper)	\
SWIGINTERN PyObject*				\
wrapper##_closure (PyObject *a, PyObject *b)	\
{						\
    PyObject *tuple = PyTuple_New(1);		\
    assert(tuple);				\
    PyTuple_SET_ITEM(tuple, 0, b);		\
    Py_XINCREF(b);				\
    PyObject *result = wrapper(a, tuple);	\
    Py_DECREF(tuple);				\
    return result;				\
}

#define PYSWIG_TERNARYFUNC_CLOSURE(wrapper)			\
SWIGINTERN PyObject*						\
wrapper##_closure (PyObject *a, PyObject *b, PyObject *c)	\
{								\
    PyObject *tuple = PyTuple_New(2);				\
    assert(tuple);						\
    PyTuple_SET_ITEM(tuple, 0, b);				\
    PyTuple_SET_ITEM(tuple, 1, c);				\
    Py_XINCREF(b);						\
    Py_XINCREF(c);						\
    PyObject *result = wrapper(a, tuple);			\
    Py_DECREF(tuple);						\
    return result;						\
}

#define PYSWIG_LENFUNC_CLOSURE(wrapper)			\
SWIGINTERN Py_ssize_t					\
wrapper##_closure (PyObject *a)				\
{							\
    PyObject *resultobj = wrapper(a, NULL);		\
    Py_ssize_t result = PyNumber_AsSsize_t(resultobj, NULL);	\
    Py_DECREF(resultobj);				\
    return result;					\
}

#define PYSWIG_SSIZESSIZEARGFUNC_CLOSURE(wrapper)		\
SWIGINTERN PyObject*						\
wrapper##_closure (PyObject *a, Py_ssize_t b, Py_ssize_t c)	\
{								\
    PyObject *tuple = PyTuple_New(2);				\
    assert(tuple);						\
    PyTuple_SET_ITEM(tuple, 0, _PyLong_FromSsize_t(b));		\
    PyTuple_SET_ITEM(tuple, 1, _PyLong_FromSsize_t(c));		\
    PyObject *result = wrapper(a, tuple);			\
    Py_DECREF(tuple);						\
    return result;						\
}

#define PYSWIG_SSIZESSIZEOBJARGPROC_CLOSURE(wrapper)			\
SWIGINTERN int								\
wrapper##_closure (PyObject *a, Py_ssize_t b, Py_ssize_t c, PyObject *d) \
{									\
    PyObject *tuple = PyTuple_New(d ? 3 : 2);				\
    assert(tuple);							\
    PyTuple_SET_ITEM(tuple, 0, _PyLong_FromSsize_t(b));			\
    PyTuple_SET_ITEM(tuple, 1, _PyLong_FromSsize_t(c));			\
    if (d) {								\
        PyTuple_SET_ITEM(tuple, 2, d);					\
        Py_INCREF(d);							\
    }									\
    PyObject *resultobj = wrapper(a, tuple);				\
    int result = resultobj ? 0 : -1;					\
    Py_DECREF(tuple);							\
    Py_XDECREF(resultobj);						\
    return result;							\
}

#define PYSWIG_SSIZEARGFUNC_CLOSURE(wrapper)		\
SWIGINTERN PyObject*					\
wrapper##_closure (PyObject *a, Py_ssize_t b)		\
{							\
    PyObject *tuple = PyTuple_New(1);			\
    assert(tuple);					\
    PyTuple_SET_ITEM(tuple, 0, _PyLong_FromSsize_t(b));	\
    PyObject *result = wrapper(a, tuple);		\
    Py_DECREF(tuple);					\
    return result;					\
}

#define PYSWIG_SSIZEOBJARGPROC_CLOSURE(wrapper)			\
SWIGINTERN int							\
wrapper##_closure (PyObject *a, Py_ssize_t b, PyObject *c)	\
{								\
    PyObject *tuple = PyTuple_New(2);				\
    assert(tuple);						\
    PyTuple_SET_ITEM(tuple, 0, _PyLong_FromSsize_t(b));		\
    PyTuple_SET_ITEM(tuple, 1, c);				\
    Py_XINCREF(c);						\
    PyObject *resultobj = wrapper(a, tuple);			\
    int result = resultobj ? 0 : -1;				\
    Py_XDECREF(resultobj);					\
    Py_DECREF(tuple);						\
    return result;						\
}

#define PYSWIG_OBJOBJARGPROC_CLOSURE(wrapper)			\
SWIGINTERN int							\
wrapper##_closure (PyObject *a, PyObject *b, PyObject *c)	\
{								\
    PyObject *tuple = PyTuple_New(c ? 2 : 1);			\
    assert(tuple);						\
    PyTuple_SET_ITEM(tuple, 0, b);				\
    Py_XINCREF(b);						\
    if (c) {							\
        PyTuple_SET_ITEM(tuple, 1, c);				\
        Py_XINCREF(c);						\
    }								\
    PyObject *resultobj = wrapper(a, tuple);			\
    int result = resultobj ? 0 : -1;				\
    Py_XDECREF(resultobj);					\
    Py_DECREF(tuple);						\
    return result;						\
}

#ifdef __cplusplus

namespace {

template <typename _Tp> struct PySwigBuiltin : public SwigPyObject {

    typedef PySwigBuiltin<_Tp> this_type;
    typedef _Tp obj_type;
    typedef obj_type* pointer;
    typedef obj_type& reference;

    static PyObject* richcompare (PyObject *self, PyObject *other, int op);

    static PyMethodDef methods[];
    static PyGetSetDef getset[];
    static PyNumberMethods number_methods;
    static PySequenceMethods sequence_methods;
    static PyMappingMethods mapping_methods;
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

SWIGINTERN int
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

} // namespace {

#endif
