@file:JvmName("extend_typedef_class_runme")

import extend_typedef_class.*

fun checkMatch(expected: Int, got: Int) {
    if (expected != got)
        throw RuntimeException("Value incorrect. Expected: " + expected + " got: " + got)
}

fun main() {
    try {
        System.loadLibrary("extend_typedef_class")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // No namespace
    run {
        val s = AClass()
        s.membervar = 10
        checkMatch(s.getvar(), 10)
    }
    run {
        val s = BClass()
        s.membervar = 20
        checkMatch(s.getvar(), 20)
    }
    run {
        val s = CClass()
        s.membervar = 30
        checkMatch(s.getvar(), 30)
    }
    run {
        val s = DClass()
        s.membervar = 40
        checkMatch(s.getvar(), 40)
    }

    // In namespace
    run {
        val s = AStruct()
        s.membervar = 10
        checkMatch(s.getvar(), 10)
    }
    run {
        val s = BStruct()
        s.membervar = 20
        checkMatch(s.getvar(), 20)
    }
    run {
        val s = CStruct()
        s.membervar = 30
        checkMatch(s.getvar(), 30)
    }
    run {
        val s = DStruct()
        s.membervar = 40
        checkMatch(s.getvar(), 40)
    }
}
