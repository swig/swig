@file:JvmName("default_args_runme")

import default_args.*

fun main() {
    try {
        System.loadLibrary("default_args")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (default_args.anonymous() != 7771)
        throw RuntimeException("anonymous (1) failed")
    if (default_args.anonymous(1234) != 1234)
        throw RuntimeException("anonymous (2) failed")

    if (default_args.booltest() != true)
        throw RuntimeException("booltest (1) failed")
    if (default_args.booltest(true) != true)
        throw RuntimeException("booltest (2) failed")
    if (default_args.booltest(false) != false)
        throw RuntimeException("booltest (3) failed")

    val ec = EnumClass()
    if (ec.blah() != true)
        throw RuntimeException("EnumClass failed")

    if (default_args.casts1() != null)
        throw RuntimeException("casts1 failed")

    if (default_args.casts2() != "Hello")
        throw RuntimeException("casts2 failed")

    if (default_args.casts1("Ciao") != "Ciao")
        throw RuntimeException("casts1 not default failed")

    if (default_args.chartest1() != 'x')
        throw RuntimeException("chartest1 failed")

    if (default_args.chartest2() != '\u0000')
        throw RuntimeException("chartest2 failed")

    if (default_args.chartest1('y') != 'y')
        throw RuntimeException("chartest1 not default failed")

    if (default_args.chartest1('y') != 'y')
        throw RuntimeException("chartest1 not default failed")

    if (default_args.reftest1() != 42)
        throw RuntimeException("reftest1 failed")

    if (default_args.reftest1(400) != 400)
        throw RuntimeException("reftest1 not default failed")

    if (default_args.reftest2() != "hello")
        throw RuntimeException("reftest2 failed")

    // rename
    val foo = Foo()
    foo.newname()
    foo.newname(10)
    foo.renamed3arg(10, 10.0)
    foo.renamed2arg(10)
    foo.renamed1arg()

    // exception specifications
    try {
        default_args.exceptionspec()
        throw RuntimeException("exceptionspec 1 failed")
    } catch (e: RuntimeException) {
    }
    try {
        default_args.exceptionspec(-1)
        throw RuntimeException("exceptionspec 2 failed")
    } catch (e: RuntimeException) {
    }
    try {
        default_args.exceptionspec(100)
        throw RuntimeException("exceptionspec 3 failed")
    } catch (e: RuntimeException) {
    }
    var ex = Except(false)
    try {
        ex.exspec()
        throw RuntimeException("exspec 1 failed")
    } catch (e: RuntimeException) {
    }
    try {
        ex.exspec(-1)
        throw RuntimeException("exspec 2 failed")
    } catch (e: RuntimeException) {
    }
    try {
        ex.exspec(100)
        throw RuntimeException("exspec 3 failed")
    } catch (e: RuntimeException) {
    }
    try {
        ex = Except(true)
        throw RuntimeException("Except constructor 1 failed")
    } catch (e: RuntimeException) {
    }
    try {
        ex = Except(true, -2)
        throw RuntimeException("Except constructor 2 failed")
    } catch (e: RuntimeException) {
    }

    // Default parameters in static class methods
    if (Statics.staticmethod() != 10 + 20 + 30)
        throw RuntimeException("staticmethod 1 failed")
    if (Statics.staticmethod(100) != 100 + 20 + 30)
        throw RuntimeException("staticmethod 2 failed")
    if (Statics.staticmethod(100, 200, 300) != 100 + 200 + 300)
        throw RuntimeException("staticmethod 3 failed")

    val tricky = Tricky()
    if (tricky.privatedefault() != 200)
        throw RuntimeException("privatedefault failed")
    if (tricky.protectedint() != 2000)
        throw RuntimeException("protectedint failed")
    if (tricky.protecteddouble() != 987.654)
        throw RuntimeException("protecteddouble failed")
    if (tricky.functiondefault() != 500)
        throw RuntimeException("functiondefault failed")
    if (tricky.contrived() != 'X')
        throw RuntimeException("contrived failed")

    if (default_args.constructorcall()._val != -1)
        throw RuntimeException("constructorcall test 1 failed")

    if (default_args.constructorcall(Klass(2222))._val != 2222)
        throw RuntimeException("constructorcall test 2 failed")

    if (default_args.constructorcall(Klass())._val != -1)
        throw RuntimeException("constructorcall test 3 failed")

    // const methods
    val cm = ConstMethods()
    if (cm.coo() != 20)
        throw RuntimeException("coo test 1 failed")
    if (cm.coo(1.0) != 20)
        throw RuntimeException("coo test 2 failed")
}
