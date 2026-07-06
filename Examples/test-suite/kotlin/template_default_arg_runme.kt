@file:JvmName("template_default_arg_runme")

import template_default_arg.*

fun main() {
    try {
        System.loadLibrary("template_default_arg")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val helloInt = Hello_int()
        helloInt.foo(Hello_int.Hi.hi)
    }
    run {
        val x = X_int()
        if (x.meth(20.0, 200) != 200)
            throw RuntimeException("X_int test 1 failed")
        if (x.meth(20) != 20)
            throw RuntimeException("X_int test 2 failed")
        if (x.meth() != 0)
            throw RuntimeException("X_int test 3 failed")
    }

    run {
        val y = Y_unsigned()
        if (y.meth(20.0, 200) != 200L)
            throw RuntimeException("Y_unsigned test 1 failed")
        if (y.meth(20) != 20L)
            throw RuntimeException("Y_unsigned test 2 failed")
        if (y.meth() != 0L)
            throw RuntimeException("Y_unsigned test 3 failed")
    }

    run {
        var x = X_longlong()
        x = X_longlong(20.0)
        x = X_longlong(20.0, 200L)
    }
    run {
        var x = X_int()
        x = X_int(20.0)
        x = X_int(20.0, 200)
    }
    run {
        var x = X_hello_unsigned()
        x = X_hello_unsigned(20.0)
        x = X_hello_unsigned(20.0, Hello_int())
    }
    run {
        val y = Y_hello_unsigned()
        y.meth(20.0, Hello_int())
        y.meth(Hello_int())
        y.meth()
    }

    run {
        val fz = Foo_Z_8()
        val x = X_Foo_Z_8()
        val fzc = x.meth(fz)
    }

    // Templated functions
    run {
        // plain function: int ott(Foo<int>)
        if (template_default_arg.ott(Foo_int()) != 30)
            throw RuntimeException("ott test 1 failed")

        // %template(ott) ott<int, int>;
        if (template_default_arg.ott() != 10)
            throw RuntimeException("ott test 2 failed")
        if (template_default_arg.ott(1) != 10)
            throw RuntimeException("ott test 3 failed")
        if (template_default_arg.ott(1, 1) != 10)
            throw RuntimeException("ott test 4 failed")

        if (template_default_arg.ott("hi") != 20)
            throw RuntimeException("ott test 5 failed")
        if (template_default_arg.ott("hi", 1) != 20)
            throw RuntimeException("ott test 6 failed")
        if (template_default_arg.ott("hi", 1, 1) != 20)
            throw RuntimeException("ott test 7 failed")

        // %template(ott) ott<const char *>;
        if (template_default_arg.ottstring(Hello_int(), "hi") != 40)
            throw RuntimeException("ott test 8 failed")

        if (template_default_arg.ottstring(Hello_int()) != 40)
            throw RuntimeException("ott test 9 failed")

        // %template(ott) ott<int>;
        if (template_default_arg.ottint(Hello_int(), 1) != 50)
            throw RuntimeException("ott test 10 failed")

        if (template_default_arg.ottint(Hello_int()) != 50)
            throw RuntimeException("ott test 11 failed")

        // %template(ott) ott<double>;
        if (template_default_arg.ott(Hello_int(), 1.0) != 60)
            throw RuntimeException("ott test 12 failed")

        if (template_default_arg.ott(Hello_int()) != 60)
            throw RuntimeException("ott test 13 failed")
    }

    // Above test in namespaces
    run {
        // plain function: int nsott(Foo<int>)
        if (template_default_arg.nsott(Foo_int()) != 130)
            throw RuntimeException("nsott test 1 failed")

        // %template(nsott) nsott<int, int>;
        if (template_default_arg.nsott() != 110)
            throw RuntimeException("nsott test 2 failed")
        if (template_default_arg.nsott(1) != 110)
            throw RuntimeException("nsott test 3 failed")
        if (template_default_arg.nsott(1, 1) != 110)
            throw RuntimeException("nsott test 4 failed")

        if (template_default_arg.nsott("hi") != 120)
            throw RuntimeException("nsott test 5 failed")
        if (template_default_arg.nsott("hi", 1) != 120)
            throw RuntimeException("nsott test 6 failed")
        if (template_default_arg.nsott("hi", 1, 1) != 120)
            throw RuntimeException("nsott test 7 failed")

        // %template(nsott) nsott<const char *>;
        if (template_default_arg.nsottstring(Hello_int(), "hi") != 140)
            throw RuntimeException("nsott test 8 failed")

        if (template_default_arg.nsottstring(Hello_int()) != 140)
            throw RuntimeException("nsott test 9 failed")

        // %template(nsott) nsott<int>;
        if (template_default_arg.nsottint(Hello_int(), 1) != 150)
            throw RuntimeException("nsott test 10 failed")

        if (template_default_arg.nsottint(Hello_int()) != 150)
            throw RuntimeException("nsott test 11 failed")

        // %template(nsott) nsott<double>;
        if (template_default_arg.nsott(Hello_int(), 1.0) != 160)
            throw RuntimeException("nsott test 12 failed")

        if (template_default_arg.nsott(Hello_int()) != 160)
            throw RuntimeException("nsott test 13 failed")
    }
}
