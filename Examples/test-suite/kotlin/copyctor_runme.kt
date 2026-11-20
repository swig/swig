@file:JvmName("copyctor_runme")

import copyctor.*

fun main() {
    try {
        System.loadLibrary("copyctor")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var bar = Bar()
    bar = Bar(bar)

    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var foo = Foo()
    @Suppress("UNUSED_VALUE")
    foo = Foo(bar)

    @Suppress("UNUSED_VARIABLE")
    val car = Car()

    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var hoo = Hoo()
    @Suppress("UNUSED_VALUE")
    hoo = Hoo(bar)
    @Suppress("UNUSED_VALUE")
    hoo = Hoo(car)
}
