@file:JvmName("director_ref_runme")

import director_ref.*

class director_ref_MyFoo : Foo {
    constructor() : super()
    constructor(i: Int) : super(i)

    override fun Msg(msg: String): String {
        return "director_ref_MyFoo-" + msg
    }

    override fun OnDelete() {
        cppDeleted = true
    }

    var cppDeleted = false
}

fun main() {
    try {
        System.loadLibrary("director_ref")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var a = director_ref_MyFoo()
    if (a.GetRefCount() != 1) {
        throw RuntimeException("Refcount test 1 failed.")
    }

    // Make sure director logic still works.
    if (a.GetMsg() != "director_ref_MyFoo-default") {
        throw RuntimeException("Test 1 failed")
    }
    if (a.GetMsg("boo") != "director_ref_MyFoo-boo") {
        throw RuntimeException("Test 2 failed")
    }

    a.delete()  // should delete the object.
    if (a.cppDeleted != true) {
        throw RuntimeException("Unref test 1 failed.")
    }

    a = director_ref_MyFoo()
    val p = FooPtr(a)
    if (a.GetRefCount() != 2) {
        throw RuntimeException("Refcount test 2 failed.")
    }
    a.delete()  // Shouldn't actually delete the underlying object
    if (a.cppDeleted) {
        throw RuntimeException("Unref test 2 failed.")
    }
    if (p.GetOwnedRefCount() != 1) {
        throw RuntimeException("Unref test 3 failed.")
    }
    p.Reset()  // Now it should be deleted on the cpp side.
    // We can't check cppDeleted because the director will stop
    // working after a delete() call.
    if (p.GetOwnedRefCount() != 0) {
        throw RuntimeException("Unref test 4 failed.")
    }
}
