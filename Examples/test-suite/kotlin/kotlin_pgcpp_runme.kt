@file:JvmName("kotlin_pgcpp_runme")

import kotlin_pgcpp.*

// Test the premature garbage collection prevention parameter (pgcpp) for the different
// ways of passing objects. As in the Java test, the generated JNI methods take an extra
// object argument alongside each pointer argument; this exercises those signatures by
// calling the JNI layer directly.

fun main() {
    try {
        System.loadLibrary("kotlin_pgcpp")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val obj = Classic()
    val ptr = obj.getCPtrValue()

    kotlin_pgcppJNI.new_Classic__SWIG_1(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)
    kotlin_pgcppJNI.new_Classic__SWIG_2(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj, false)

    kotlin_pgcppJNI.Classic_method(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)
    kotlin_pgcppJNI.Classic_methodconst(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)

    kotlin_pgcppJNI.function(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)
    kotlin_pgcppJNI.functionconst(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)

    kotlin_pgcppJNI.comment_in_typemaps(ptr, obj, ptr, obj, ptr, obj)
}
