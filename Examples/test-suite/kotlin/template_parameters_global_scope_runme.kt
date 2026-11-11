@file:JvmName("template_parameters_global_scope_runme")

import template_parameters_global_scope.*

fun main() {
    try {
        System.loadLibrary("template_parameters_global_scope")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var alloc = 0

    // Check 1
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bucket1()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bucket2()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bucket3()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bucket4()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bucket5()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bucket6()

    // Check 2
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Spade1()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Spade2()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Spade3()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Spade4()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Spade5()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Spade6()

    // Check 3
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Ball1()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Ball2()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Ball3()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Ball4()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Ball5()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Ball6()

    // Check 4
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bat1()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bat2()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bat3()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bat4()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bat5()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Bat6()

    // Check 5
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Chair1()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Chair2()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Chair3()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Chair4()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Chair5()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Chair6()

    // Check 6
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Table1()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Table2()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Table3()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Table4()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Table5()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.Table6()

    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.rejig1()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.rejig2()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.rejig3()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.rejig4()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.rejig5()
    @Suppress("UNUSED_VALUE")
    alloc = template_parameters_global_scope.rejig6()
}
