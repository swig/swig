#ifdef __cplusplus

namespace {

template <typename _Tp> struct PySwigBuiltin : public SwigPyObject {

    typedef PySwigBuiltin<_Tp> this_type;
    typedef _Tp obj_type;
    typedef obj_type* pointer;
    typedef obj_type& reference;

    static PyMethodDef methods[];
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

} // namespace {

#endif
