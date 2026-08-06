@file:JvmName("cpp11_copyctor_delete_runme")

import cpp11_copyctor_delete.*

fun main() {
    try {
        System.loadLibrary("cpp11_copyctor_delete")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // check copy constructors are generated
    CopyCtorDeletedPublic1(CopyCtorDeletedPublic1.make())
    CopyCtorDeletedProtected1(CopyCtorDeletedProtected1.make())
    CopyCtorDeletedPrivate1(CopyCtorDeletedPrivate1.make())

    DeletedPublic4()
    DeletedPublic5()
    CopyCtorDeletedPublic4()
    CopyCtorDeletedPublic5()

    StackOnly1()
    CopyCtorStackOnly1(CopyCtorStackOnly1())
}
