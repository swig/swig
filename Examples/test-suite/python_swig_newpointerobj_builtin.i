%module python_swig_newpointerobj_builtin

// This test checks that SWIG_NewPointerObj works in %inline code
// when the -builtin option is used.  See issue #2613.

%inline %{
struct Foo {
    int n;
};

PyObject *make_foo(int n) {
    Foo *f = new Foo();
    f->n = n;
    return SWIG_NewPointerObj(f, SWIGTYPE_p_Foo, SWIG_POINTER_OWN);
}
%}
