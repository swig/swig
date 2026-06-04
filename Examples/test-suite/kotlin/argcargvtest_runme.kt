@file:JvmName("argcargvtest_runme")

import argcargvtest.*

fun main() {
    try {
        System.loadLibrary("argcargvtest")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val largs = arrayOf("hi", "hola", "hello")
    if (argcargvtest.mainc(largs) != 3)
        throw RuntimeException("bad main typemap")

    val targs = arrayOf("hi", "hola")
    if (argcargvtest.mainv(targs, 0) != "hi")
        throw RuntimeException("bad main typemap")
    if (argcargvtest.mainv(targs, 1) != "hola")
        throw RuntimeException("bad main typemap")
    if (argcargvtest.mainv(targs, 2) != "<<NULL>>")
        throw RuntimeException("bad main typemap")

    argcargvtest.initializeApp(largs)

    // Check that an empty array works.
    val emptyArgs = arrayOf<String>()
    if (argcargvtest.mainc(emptyArgs) != 0)
        throw RuntimeException("bad main typemap")
    if (argcargvtest.mainv(emptyArgs, 0) != "<<NULL>>")
        throw RuntimeException("bad main typemap")

    // Check that empty strings are handled.
    val emptyString = arrayOf("hello", "", "world")
    if (argcargvtest.mainc(emptyString) != 3)
        throw RuntimeException("bad main typemap")
    if (argcargvtest.mainv(emptyString, 0) != "hello")
        throw RuntimeException("bad main typemap")
    if (argcargvtest.mainv(emptyString, 1) != "")
        throw RuntimeException("bad main typemap")
    if (argcargvtest.mainv(emptyString, 2) != "world")
        throw RuntimeException("bad main typemap")
    if (argcargvtest.mainv(emptyString, 3) != "<<NULL>>")
        throw RuntimeException("bad main typemap")
}
