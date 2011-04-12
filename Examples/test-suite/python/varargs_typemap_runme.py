import varargs_typemap

if (varargs_typemap.testfunc(1, 2.0, "three") != "three") :
    raise RuntimeError("testfunc failed!")
