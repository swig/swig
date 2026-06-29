@file:JvmName("director_nspace_runme")

// Make sure that directors are connected and disconnected when used inconjunction with
// the %nspace feature

import director_nspacePackage.*
import director_nspacePackage.TopLevel.Bar.*

class director_nspace_MyBarFoo : Foo() {
    override fun ping(): String {
        return "director_nspace_MyBarFoo.ping();"
    }

    override fun pong(): String {
        return "director_nspace_MyBarFoo.pong();" + ping()
    }

    override fun fooBar(fb: FooBar?): String {
        return fb!!.FooBarDo()
    }

    override fun makeFoo(): Foo {
        return Foo()
    }

    override fun makeFooBar(): FooBar {
        return FooBar()
    }
}

fun main() {
    try {
        System.loadLibrary("director_nspace")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val myBarFoo = director_nspace_MyBarFoo()
}
