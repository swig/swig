@file:JvmName("kotlin_director_ptrclass_runme")

import kotlin_director_ptrclass.*

class kotlin_director_ptrclass_TouchingFoo : Foo() {
    override fun MaybeTouch(baz_ptr: Baz?): Baz? {
        baz_ptr!!.SetTouched()
        return baz_ptr
    }
}

fun main() {
    try {
        System.loadLibrary("kotlin_director_ptrclass")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = Foo()
    val ft: Foo = kotlin_director_ptrclass_TouchingFoo()
    val b = Baz()
    if (b.GetTouched()) {
        throw RuntimeException("Baz should not have been touched yet.")
    }

    val b2 = f.FinalMaybeTouch(b)

    if (b2!!.GetTouched() || b.GetTouched()) {
        throw RuntimeException("Baz should not have been touched by Foo.")
    }

    val b3 = ft.FinalMaybeTouch(b)

    if (!b.GetTouched() || !b3!!.GetTouched() || !b2.GetTouched()) {
        throw RuntimeException("Baz was not touched by TouchingFoo. This" +
                " might mean the directorin typemap is not" +
                " parsing the typemap(kstype, Bar) in its" +
                " 'descriptor' kwarg correctly.")
    }
}
