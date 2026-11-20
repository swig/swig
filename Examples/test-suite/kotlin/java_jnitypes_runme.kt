@file:JvmName("java_jnitypes_runme")

import java_jnitypes.*

class Test

fun testFailed(str: String) {
    throw RuntimeException(str + " test failed")
}

fun main() {
    try {
        System.loadLibrary("java_jnitypes")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val test = Test()
    val booleanArray = booleanArrayOf(true, false)
    val charArray = charArrayOf('A', 'B')
    val byteArray = byteArrayOf(10, 20)
    val shortArray = shortArrayOf(10, 20)
    val intArray = intArrayOf(10, 20)
    val longArray = longArrayOf(10, 20)
    val floatArray = floatArrayOf(10.0f, 20.0f)
    val doubleArray = doubleArrayOf(10.0, 20.0)
    val objectArray = arrayOf<Any?>(Test(), test)

    if (java_jnitypes.jnifunc_bool(true) != true)        testFailed("jboolean")
    if (java_jnitypes.jnifunc('A') != 'A')               testFailed("jchar")
    if (java_jnitypes.jnifunc(100.toByte()) != 100.toByte())   testFailed("jbyte")
    if (java_jnitypes.jnifunc(100.toShort()) != 100.toShort()) testFailed("jshort")
    if (java_jnitypes.jnifunc(100) != 100)               testFailed("jint")
    if (java_jnitypes.jnifunc(100L) != 100L)             testFailed("jlong")
    if (java_jnitypes.jnifunc(100.0f) != 100.0f)         testFailed("jfloat")
    if (java_jnitypes.jnifunc(100.0) != 100.0)           testFailed("jdouble")
    if (java_jnitypes.jnifunc("100") != "100")           testFailed("jstring")
    if (java_jnitypes.jnifunc(test as Any?) !== test)    testFailed("jobject")
    if (java_jnitypes.jnifunc(booleanArray)[1] != false) testFailed("jbooleanArray")
    if (java_jnitypes.jnifunc(charArray)[1] != 'B')      testFailed("jcharArray")
    if (java_jnitypes.jnifunc(byteArray)!![1].toInt() != 20) testFailed("jbyteArray")
    if (java_jnitypes.jnifunc(shortArray)[1].toInt() != 20)  testFailed("jshortArray")
    if (java_jnitypes.jnifunc(intArray)[1] != 20)        testFailed("jintArray")
    if (java_jnitypes.jnifunc(longArray)[1] != 20L)      testFailed("jlongArray")
    if (java_jnitypes.jnifunc(floatArray)[1] != 20.0f)   testFailed("jfloatArray")
    if (java_jnitypes.jnifunc(doubleArray)[1] != 20.0)   testFailed("jdoubleArray")
    if (java_jnitypes.jnifunc(objectArray)[1] !== test)  testFailed("jobjectArray")
}
