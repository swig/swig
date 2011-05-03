import python_varargs_typemap

if (python_varargs_typemap.testfunc(1, 2.0, "three") != "three") :
    raise RuntimeError("testfunc failed!")
