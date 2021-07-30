# Note that this test is also used by python_default_args_runme.py hence
# the use of __main__ and the run function


def run(module_name):
    default_args = __import__(module_name)
    ec = default_args.EnumClass()
    if not ec.blah():
        raise RuntimeError("EnumClass::blah() default arguments don't work")

    de = default_args.DerivedEnumClass()
    de.accelerate()
    de.accelerate(default_args.EnumClass.SLOW)

    if default_args.Statics_staticMethod() != 60:
        raise RuntimeError

    if default_args.cfunc1(1) != 2:
        raise RuntimeError

    if default_args.cfunc2(1) != 3:
        raise RuntimeError

    if default_args.cfunc3(1) != 4:
        raise RuntimeError

    f = default_args.Foo()

    f.newname()
    f.newname(1)
    f.defaulted1()
    f.defaulted2()

    if f.double_if_void_ptr_is_null(2, None) != 4:
        raise RuntimeError

    if f.double_if_void_ptr_is_null(3) != 6:
        raise RuntimeError

    if f.double_if_handle_is_null(4, None) != 8:
        raise RuntimeError

    if f.double_if_handle_is_null(5) != 10:
        raise RuntimeError

    if f.double_if_dbl_ptr_is_null(6, None) != 12:
        raise RuntimeError

    if f.double_if_dbl_ptr_is_null(7) != 14:
        raise RuntimeError

    try:
        f = default_args.Foo(1)
        error = 1
    except:
        error = 0
    if error:
        raise RuntimeError("Foo::Foo ignore is not working")

    try:
        f = default_args.Foo(1, 2)
        error = 1
    except:
        error = 0
    if error:
        raise RuntimeError("Foo::Foo ignore is not working")

    try:
        f = default_args.Foo(1, 2, 3)
        error = 1
    except:
        error = 0
    if error:
        raise RuntimeError("Foo::Foo ignore is not working")

    try:
        m = f.meth(1)
        error = 1
    except:
        error = 0
    if error:
        raise RuntimeError("Foo::meth ignore is not working")

    try:
        m = f.meth(1, 2)
        error = 1
    except:
        error = 0
    if error:
        raise RuntimeError("Foo::meth ignore is not working")

    try:
        m = f.meth(1, 2, 3)
        error = 1
    except:
        error = 0
    if error:
        raise RuntimeError("Foo::meth ignore is not working")

    Klass_inc = default_args.Klass.inc

    if Klass_inc(100, default_args.Klass(22)).val != 122:
        raise RuntimeError("Klass::inc failed")

    if Klass_inc(100).val != 99:
        raise RuntimeError("Klass::inc failed")

    if Klass_inc().val != 0:
        raise RuntimeError("Klass::inc failed")

    tricky_failure = False
    tricky = default_args.TrickyInPython()
    if tricky.value_m1(10) != -1:
        print "trickyvalue_m1 failed"
        tricky_failure = True
    if tricky.value_m1(10, 10) != 10:
        print "trickyvalue_m1 failed"
        tricky_failure = True
    if tricky.value_0xabcdef(10) != 0xabcdef:
        print "trickyvalue_0xabcdef failed"
        tricky_failure = True
    if tricky.value_0644(10) != 420:
        print "trickyvalue_0644 failed"
        tricky_failure = True
    if tricky.value_perm(10) != 420:
        print "trickyvalue_perm failed"
        tricky_failure = True
    if tricky.value_m01(10) != -1:
        print "trickyvalue_m01 failed"
        tricky_failure = True
    if not tricky.booltest2():
        print "booltest2 failed"
        tricky_failure = True

    if tricky.max_32bit_int1() != 0x7FFFFFFF:
        print "max_32bit_int1 failed"
        tricky_failure = True
    if tricky.min_32bit_int1() != -2147483648:
        print "min_32bit_int1 failed"
        tricky_failure = True
    if tricky.max_32bit_int2() != 0x7FFFFFFF:
        print "max_32bit_int2 failed"
        tricky_failure = True

    tricky.too_big_32bit_int1()
    tricky.too_small_32bit_int1()
    tricky.too_big_32bit_int2()
    tricky.too_small_32bit_int2()

    if tricky_failure:
        raise RuntimeError

    default_args.seek()
    default_args.seek(10)

    if not default_args.booltest():
        raise RuntimeError("booltest failed")

    if default_args.slightly_off_square(10) != 102:
        raise RuntimeError

    if default_args.slightly_off_square() != 291:
        raise RuntimeError

    # It is difficult to test the python:cdefaultargs feature properly as -builtin
    # and -fastproxy do not use the Python layer for default args
    if default_args.CDA().cdefaultargs_test1() != 1:
        raise RuntimeError

    if default_args.CDA().cdefaultargs_test2() != 1:
        raise RuntimeError

    if default_args.chartest1() != "x":
        raise RuntimeError

    if default_args.chartest2() != "\0":
        raise RuntimeError

    if default_args.chartest3() != "\1":
        raise RuntimeError

    if default_args.chartest4() != "\n":
        raise RuntimeError

    if default_args.chartest5() != "B":
        raise RuntimeError

    if default_args.chartest6() != "C":
        raise RuntimeError

if __name__ == "__main__":
    run("default_args")
