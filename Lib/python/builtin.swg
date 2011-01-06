#define PYSWIG_UNARYFUNC_CLOSURE(wrapper)	\
SWIGINTERN PyObject*				\
wrapper##_closure (PyObject *a)			\
{						\
    return wrapper(a, NULL);			\
}

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

template <typename _Tp> struct SwigPyBuiltin : public SwigPyObject {

    typedef SwigPyBuiltin<_Tp> this_type;
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
    typedef SwigPyBuiltin<_Tp> builtin_type;
    builtin_type *obj = (builtin_type*) pyobj;
    if (obj->own)
	delete reinterpret_cast<_Tp*>(obj->ptr);
    (*pyobj->ob_type->tp_free)(pyobj);
}

} // namespace {

#endif

SWIGRUNTIME int py_builtin_bad_init (PyObject *self, PyObject *args, PyObject *kwds)
{
    PyErr_Format(PyExc_TypeError, "Cannot create new instances of type '%.300s'", self->ob_type->tp_name);
    return -1;
}

SWIGRUNTIME void py_builtin_bad_dealloc (PyObject *pyobj)
{
    SwigPyObject *sobj = (SwigPyObject*) pyobj;
    if (sobj->own) {
	PyErr_Format(PyExc_TypeError,
		     "Swig detected a memory leak in type '%s': no callable destructor found.",
		     pyobj->ob_type->tp_name);
    }
}

typedef struct {
    PyCFunction get;
    PyCFunction set;
} SwigPyGetSet;

SWIGRUNTIME PyObject*
pyswig_getter_closure (PyObject *obj, void *closure)
{
    if (!closure)
       return SWIG_Py_Void();
    SwigPyGetSet *getset = (SwigPyGetSet*) closure;
    if (!getset->get)
	return SWIG_Py_Void();
    PyObject *tuple = PyTuple_New(0);
    assert(tuple);
    PyObject *result = (*getset->get)(obj, tuple);
    Py_DECREF(tuple);
    return result;
}

SWIGRUNTIME int
pyswig_setter_closure (PyObject *obj, PyObject *val, void *closure)
{
    if (!closure)
        return -1;
    SwigPyGetSet *getset = (SwigPyGetSet*) closure;
    if (!getset->set)
	return -1;
    PyObject *tuple = PyTuple_New(1);
    assert(tuple);
    PyTuple_SET_ITEM(tuple, 0, val);
    Py_XINCREF(val);
    PyObject *result = (*getset->set)(obj, tuple);
    Py_DECREF(tuple);
    Py_XDECREF(result);
    return result ? 0 : -1;
}

SWIGRUNTIME PyObject*
pyswig_static_getter_closure (PyObject *obj, void *closure)
{
    if (!closure)
       return SWIG_Py_Void();
    SwigPyGetSet *getset = (SwigPyGetSet*) closure;
    if (!getset->get)
	return SWIG_Py_Void();
    PyObject *tuple = PyTuple_New(0);
    assert(tuple);
    PyObject *result = (*getset->get)(obj, tuple);
    Py_DECREF(tuple);
    return result;
}

SWIGRUNTIME int
pyswig_static_setter_closure (PyObject *obj, PyObject *val, void *closure)
{
    if (!closure)
        return -1;
    SwigPyGetSet *getset = (SwigPyGetSet*) closure;
    if (!getset->set)
	return -1;
    PyObject *tuple = PyTuple_New(1);
    assert(tuple);
    PyTuple_SET_ITEM(tuple, 0, val);
    Py_XINCREF(val);
    PyObject *result = (*getset->set)(obj, tuple);
    Py_DECREF(tuple);
    Py_XDECREF(result);
    return result ? 0 : -1;
}

SWIGRUNTIME void
SwigPyStaticVar_dealloc(PyDescrObject *descr)
{
    _PyObject_GC_UNTRACK(descr);
    Py_XDECREF(descr->d_type);
    Py_XDECREF(descr->d_name);
    PyObject_GC_Del(descr);
}

SWIGRUNTIME PyObject *
SwigPyStaticVar_repr(PyGetSetDescrObject *descr)
{
    return PyString_FromFormat("<class attribute '%s' of type '%s'>",
			       PyString_AsString(descr->d_name),
			       descr->d_type->tp_name);
}

SWIGRUNTIME int
SwigPyStaticVar_traverse(PyObject *self, visitproc visit, void *arg)
{
    PyDescrObject *descr = (PyDescrObject *)self;
    Py_VISIT(descr->d_type);
    return 0;
}

SWIGRUNTIME PyObject *
SwigPyStaticVar_get (PyGetSetDescrObject *descr, PyObject *obj, PyObject *type)
{
    if (descr->d_getset->get != NULL)
	return descr->d_getset->get(obj, descr->d_getset->closure);
    PyErr_Format(PyExc_AttributeError,
		 "attribute '%.300s' of '%.100s' objects is not readable",
		 PyString_AsString(descr->d_name),
		 descr->d_type->tp_name);
    return NULL;
}

SWIGRUNTIME int
SwigPyStaticVar_set (PyGetSetDescrObject *descr, PyObject *obj, PyObject *value)
{
    int res;

    if (descr->d_getset->set != NULL)
	return descr->d_getset->set(obj, value, descr->d_getset->closure);
    PyErr_Format(PyExc_AttributeError,
		 "attribute '%.300s' of '%.100s' objects is not writable",
		 PyString_AsString(descr->d_name),
		 descr->d_type->tp_name);
    return -1;
}

SWIGRUNTIME PyTypeObject SwigPyStaticVar_Type = {
    PyObject_HEAD_INIT(&PyType_Type)
    0,
    "swig_static_var_getset_descriptor",
    sizeof(PyGetSetDescrObject),
    0,
    (destructor)SwigPyStaticVar_dealloc, /* tp_dealloc */
    0,					/* tp_print */
    0,					/* tp_getattr */
    0,					/* tp_setattr */
    0,					/* tp_compare */
    (reprfunc)SwigPyStaticVar_repr,	/* tp_repr */
    0,					/* tp_as_number */
    0,					/* tp_as_sequence */
    0,					/* tp_as_mapping */
    0,					/* tp_hash */
    0,					/* tp_call */
    0,					/* tp_str */
    PyObject_GenericGetAttr,		/* tp_getattro */
    0,					/* tp_setattro */
    0,					/* tp_as_buffer */
    Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC, /* tp_flags */
    0,					/* tp_doc */
    SwigPyStaticVar_traverse,		/* tp_traverse */
    0,					/* tp_clear */
    0,					/* tp_richcompare */
    0,					/* tp_weaklistoffset */
    0,					/* tp_iter */
    0,					/* tp_iternext */
    0,					/* tp_methods */
    0,					/* tp_members */
    0,					/* tp_getset */
    0,					/* tp_base */
    0,					/* tp_dict */
    (descrgetfunc)SwigPyStaticVar_get,	/* tp_descr_get */
    (descrsetfunc)SwigPyStaticVar_set,	/* tp_descr_set */
};

SWIGRUNTIME int
SwigPyObjectType_setattro(PyTypeObject *type, PyObject *name, PyObject *value)
{
    PyObject *attribute = _PyType_Lookup(type, name);
    if (attribute != NULL) {
	/* Implement descriptor functionality, if any */
	descrsetfunc local_set = attribute->ob_type->tp_descr_set;
	if (local_set != NULL)
	    return local_set(attribute, (PyObject*) type, value);
	PyErr_Format(PyExc_AttributeError,
		     "cannot modify read-only attribute '%.50s.%.400s'",
		     type->tp_name, PyString_AS_STRING(name));
    } else {
	PyErr_Format(PyExc_AttributeError,
		     "type '%.50s' has no attribute '%.400s'",
		     type->tp_name, PyString_AS_STRING(name));
    }

    return -1;
}

SWIGINTERN PyGetSetDescrObject*
SwigPyStaticVar_new_getset (PyTypeObject *type, PyGetSetDef *getset)
{
    PyGetSetDescrObject *descr = (PyGetSetDescrObject*) PyType_GenericAlloc(&SwigPyStaticVar_Type, 0);
    assert(descr);
    Py_XINCREF(type);
    descr->d_type = type;
    descr->d_name = PyString_InternFromString(getset->name);
    descr->d_getset = getset;
    if (descr->d_name == NULL) {
	Py_DECREF(descr);
	descr = NULL;
    }
    return descr;
}

#ifdef __cplusplus

#include <vector>

SWIGINTERN void
pyswig_builtin_init_bases (PyTypeObject *type, std::vector<PyTypeObject*>& bases)
{
    if (!bases.size())
	bases.push_back(SwigPyObject_type());
    type->tp_base = bases[0];
    Py_INCREF((PyObject*) bases[0]);
    PyObject *tuple = PyTuple_New(bases.size());
    int i;
    for (i = 0; i < bases.size(); ++i) {
	PyTuple_SET_ITEM(tuple, i, (PyObject*) bases[i]);
	Py_INCREF((PyObject*) bases[i]);
    }
    type->tp_bases = tuple;
}

#endif
