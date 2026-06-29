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

    var foo = Foo()
    foo = Foo(bar)

    val car = Car()

    var hoo = Hoo()
    hoo = Hoo(bar)
    hoo = Hoo(car)
}
