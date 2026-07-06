@file:JvmName("director_wombat_runme")

import director_wombat.*

class director_wombat_Foo_integers_derived : Foo_integers() {
    override fun meth(param: Int): Int {
        return param + 2
    }
}

class director_wombat_Foo_integers_derived_2 : Foo_integers()

class director_wombat_Bar_derived_1 : Bar() {
    override fun foo_meth_ref(foo_obj: Foo_integers, param: Int) {
        if (foo_obj !is director_wombat_Foo_integers_derived_2) {
            throw RuntimeException("Test failed: foo_obj in foo_meth_ref is not director_wombat_Foo_integers_derived_2, got " + foo_obj)
        }
    }

    override fun foo_meth_ptr(foo_obj: Foo_integers?, param: Int) {
        if (foo_obj !is director_wombat_Foo_integers_derived_2) {
            throw RuntimeException("Test failed: foo_obj in foo_meth_ptr is not director_wombat_Foo_integers_derived_2, got " + foo_obj)
        }
    }

    override fun foo_meth_val(foo_obj: Foo_integers, param: Int) {
        if (foo_obj !is director_wombat_Foo_integers_derived_2) {
            throw RuntimeException("Test failed: foo_obj in foo_meth_val is not director_wombat_Foo_integers_derived_2, got " + foo_obj)
        }
    }
}

fun main() {
    try {
        System.loadLibrary("director_wombat")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var b = Bar()
    var a: Foo_integers
    var retval: Int

    a = b.meth()!!
    retval = a.meth(49)
    if (retval != 49) {
        throw RuntimeException("Test failed: retval = " + retval + ", expected 49")
    }

    a.delete()

    a = director_wombat_Foo_integers_derived()
    retval = a.meth(62)
    if (retval != 62 + 2) {
        throw RuntimeException("Test failed: retval = " + retval + ", expected 62 + 2")
    }

    a.delete()

    a = director_wombat_Foo_integers_derived_2()
    retval = a.meth(37)
    if (retval != 37) {
        throw RuntimeException("Test failed: retval = " + retval + ", expected 37")
    }

    b.delete()

    b = director_wombat_Bar_derived_1()
    b.foo_meth_ref(a, 0)
    b.foo_meth_ptr(a, 1)
    b.foo_meth_val(a, 2)
}
