@file:JvmName("java_pgcpp_runme")

import java_pgcpp.*

// Test the premature garbage collection prevention parameter (pgcpp) for the different
// ways of passing objects. As in the Java test, the generated JNI methods take an extra
// object argument alongside each pointer argument; this exercises those signatures by
// calling the JNI layer directly.

fun main() {
    try {
        System.loadLibrary("java_pgcpp")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val obj = Classic()
    val ptr = obj.getCPtrValue()

    java_pgcppJNI.new_Classic__SWIG_1(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)
    java_pgcppJNI.new_Classic__SWIG_2(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj, false)

    java_pgcppJNI.Classic_method(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)
    java_pgcppJNI.Classic_methodconst(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)

    java_pgcppJNI.function(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)
    java_pgcppJNI.functionconst(ptr, obj, ptr, obj, ptr, obj, ptr, obj, ptr, obj)

    java_pgcppJNI.comment_in_typemaps(ptr, obj, ptr, obj, ptr, obj)
}
