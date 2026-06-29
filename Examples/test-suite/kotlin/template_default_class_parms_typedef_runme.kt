@file:JvmName("template_default_class_parms_typedef_runme")

import template_default_class_parms_typedef.*

fun main() {
    try {
        System.loadLibrary("template_default_class_parms_typedef")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        var bar = DefaultBar(20.0, SomeType(), 10)
        var d = bar.CType
        bar.CType = d
        val s = bar.DType
        bar.DType = s
        val i = bar.EType
        bar.EType = i
        d = bar.method(d, s!!, i)
        d = bar.method_1(d, s, i)
        d = bar.method_2(d, s, i)
        d = bar.method_3(d, s, i)

        bar = DefaultBar(true, 20.0, SomeType(), 10)
        bar = DefaultBar(true, true, 20.0, SomeType(), 10)
        bar = DefaultBar(true, true, true, 20.0, SomeType(), 10)
    }
    run {
        var foo = DefaultFoo(SomeType())
        var s = foo.TType!!
        s = foo.method(s)!!
        s = foo.method_A(s)!!
        s = foo.method_B(s)!!
        s = foo.method_C(s)!!

        foo = DefaultFoo(SomeType(), SomeType())
        foo = DefaultFoo(SomeType(), SomeType(), SomeType())
        foo = DefaultFoo(SomeType(), SomeType(), SomeType(), SomeType())
    }
    run {
        var bar = BarAnotherTypeBool(AnotherType(), true, 10)
        var a = bar.CType
        bar.CType = a
        val b = bar.DType
        bar.DType = b
        val i = bar.EType
        bar.EType = i

        a = bar.method(a!!, b, i)!!
        a = bar.method_1(a, b, i)!!
        a = bar.method_2(a, b, i)!!
        a = bar.method_3(a, b, i)!!

        bar = BarAnotherTypeBool(true, AnotherType(), true, 10)
        bar = BarAnotherTypeBool(true, true, AnotherType(), true, 10)
        bar = BarAnotherTypeBool(true, true, true, AnotherType(), true, 10)
    }
    run {
        var foo = FooAnotherType(AnotherType())
        var a = foo.TType
        foo.TType = a
        a = foo.method(a!!)!!
        a = foo.method_A(a)!!
        a = foo.method_B(a)!!
        a = foo.method_C(a)!!

        foo = FooAnotherType(AnotherType(), AnotherType())
        foo = FooAnotherType(AnotherType(), AnotherType(), AnotherType())
        foo = FooAnotherType(AnotherType(), AnotherType(), AnotherType(), AnotherType())
    }
    run {
        val u = UsesBarDouble()
        u.use_A(10.1, SomeType(), 10)
        u.use_B(10.1, SomeType(), 10)
        u.use_C(10.1, SomeType(), 10)
        u.use_D(10.1, SomeType(), 10)
    }
}
