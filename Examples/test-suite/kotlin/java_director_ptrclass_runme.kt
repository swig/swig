@file:JvmName("java_director_ptrclass_runme")

import java_director_ptrclass.*

class java_director_ptrclass_TouchingFoo : Foo() {

    override fun MaybeTouch(f: Baz?): Baz? {
        f!!.SetTouched()
        return f
    }
}

fun main() {
    try {
        System.loadLibrary("java_director_ptrclass")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = Foo()
    val ft: Foo = java_director_ptrclass_TouchingFoo()
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
                " parsing the typemap(jstype, Bar) in its" +
                " 'descriptor' kwarg correctly.")
    }
}
