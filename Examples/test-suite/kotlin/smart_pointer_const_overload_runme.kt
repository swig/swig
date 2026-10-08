@file:JvmName("smart_pointer_const_overload_runme")

import smart_pointer_const_overload.*

const val CONST_ACCESS = 1
const val MUTABLE_ACCESS = 2

fun Assert(b: Boolean) {
    if (!b)
        throw RuntimeException("Assertion failed")
}

fun test(b: Bar, f: Foo) {
    Assert(f.x1 == 0)

    // Test member variable get
    Assert(b.x1 == 0)
    Assert(f.access1 == CONST_ACCESS)

    // Test member variable set
    b.x1 = 1
    Assert(f.x1 == 1)
    Assert(f.access1 == MUTABLE_ACCESS)

    // Test const method
    Assert(b.getx1() == 1)
    Assert(f.access1 == CONST_ACCESS)

    // Test mutable method
    b.setx1(2)

    Assert(f.x1 == 2)
    Assert(f.access1 == MUTABLE_ACCESS)

    // Test extended const method
    Assert(b.getx2() == 2)
    Assert(f.access1 == CONST_ACCESS)

    // Test extended mutable method
    b.setx2(3)

    Assert(f.x1 == 3)
    Assert(f.access1 == MUTABLE_ACCESS)

    // Test static method
    b.statMethod()

    Assert(f.access1 == CONST_ACCESS)

    // Test const member
    f.access1 = MUTABLE_ACCESS

    Assert(b.y == 0)
    Assert(f.access1 == CONST_ACCESS)

    // Test get through mutable pointer to const member
    f.access1 = MUTABLE_ACCESS

    Assert(smart_pointer_const_overload.get_int(b.yp) == 0)
    Assert(f.access1 == CONST_ACCESS)

    // Test get through const pointer to mutable member
    f.x1 = 4
    f.access1 = MUTABLE_ACCESS

    Assert(smart_pointer_const_overload.get_int(b.xp) == 4)
    Assert(f.access1 == CONST_ACCESS)

    // Test set through const pointer to mutable member
    f.access1 = MUTABLE_ACCESS
    smart_pointer_const_overload.set_int(b.xp, 5)

    Assert(f.x1 == 5)
    Assert(f.access1 == CONST_ACCESS)

    // Test set pointer to const member
    b.yp = smart_pointer_const_overload.new_int(6)

    Assert(f.y == 0)
    Assert(smart_pointer_const_overload.get_int(f.yp) == 6)
    Assert(f.access1 == MUTABLE_ACCESS)

    smart_pointer_const_overload.delete_int(f.yp)
}

fun main() {
    try {
        System.loadLibrary("smart_pointer_const_overload")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = Foo()
    val b = Bar(f)

    test(b, f)
}
