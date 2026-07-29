%module python_charptr_fragment

%typemap(out,noblock=1,fragment="SWIG_FromCharPtrAndSize") struct tst_str {
  %set_output(SWIG_FromCharPtrAndSize($1.str,$1.len));
}

%extend tst_str2 {
PyObject *getStr() {
    return SWIG_FromCharPtrAndSize("test2", 5);
}
}

%inline %{

struct tst_str {
    size_t len;
    char* str;
};

struct tst_str2 {
    int dummy;
};


struct tst_str getStr()
{
    static struct tst_str r = { 5, "test1" };
    return r;
}

%}
