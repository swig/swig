@file:JvmName("cpp11_template_parameters_decltype_runme")

import cpp11_template_parameters_decltype.*

fun main() {
    try {
        System.loadLibrary("cpp11_template_parameters_decltype")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val show = false // for debugging

    cpp11_template_parameters_decltype.tester(show)
    val json0 = Json("hi")
    if (json0.ctor != 0)
        throw RuntimeException("json0 failed")
    if (json0.mmm("bye") != 100)
        throw RuntimeException("json0.mmm failed")

    val converter = Converter()
    val json1 = Json(converter)
    if (json1.ctor != 1)
        throw RuntimeException("json1 failed")
    if (json1.mmm(converter) != 101)
        throw RuntimeException("json1.mmm failed")

    val myMapStringString = MapStringString()
    val json2 = Json(myMapStringString)
    if (json2.ctor != 2)
        throw RuntimeException("json2 failed")
    if (json2.mmm(myMapStringString) != 102)
        throw RuntimeException("json2.mmm failed")

    val myVectorString = VectorString()
    val json3 = Json(myVectorString)
    if (json3.ctor != 3)
        throw RuntimeException("json3 failed")
    if (json3.mmm(myVectorString) != 103)
        throw RuntimeException("json3.mmm failed")
}
