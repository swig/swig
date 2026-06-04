@file:JvmName("cpp11_std_unique_ptr_runme")

import cpp11_std_unique_ptr.*

fun checkCount(expected_count: Int) {
    val actual_count = Klass.getTotal_count()
    if (actual_count != expected_count)
        throw RuntimeException("Counts incorrect, expected:" + expected_count + " actual:" + actual_count)
}

fun main() {
    try {
        System.loadLibrary("cpp11_std_unique_ptr")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Test raw pointer handling involving virtual inheritance
    run {
        val kini = KlassInheritance("KlassInheritanceInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.useKlassRawPtr(kini)
        if (s != "KlassInheritanceInput")
            throw RuntimeException("Incorrect string: " + s)
        kini.delete()
        checkCount(0)
    }

    ///// INPUT BY VALUE /////
    // unique_ptr as input
    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
        checkCount(0)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw RuntimeException("is_nullptr failed")
        kin.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
        checkCount(0)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw RuntimeException("is_nullptr failed")
        var exception_thrown = false
        try {
            cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
        } catch (e: RuntimeException) {
            if (!e.message!!.contains("Cannot release ownership as memory is not owned"))
                throw RuntimeException("incorrect exception message")
            exception_thrown = true
        }
        if (!exception_thrown)
            throw RuntimeException("double usage of takeKlassUniquePtr should have been an error")
        kin.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    run {
        val kin = Klass("KlassInput")
        var exception_thrown = false
        val notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin)
        try {
            cpp11_std_unique_ptr.takeKlassUniquePtr(notowned)
        } catch (e: RuntimeException) {
            if (!e.message!!.contains("Cannot release ownership as memory is not owned"))
                throw RuntimeException("incorrect exception message")
            exception_thrown = true
        }
        if (!exception_thrown)
            throw RuntimeException("Should have thrown 'Cannot release ownership as memory is not owned' error")
        checkCount(1)
        kin.delete()
        checkCount(0)
    }

    run {
        val kini = KlassInheritance("KlassInheritanceInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.takeKlassUniquePtr(kini)
        checkCount(0)
        if (s != "KlassInheritanceInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kini))
            throw RuntimeException("is_nullptr failed")
        kini.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    cpp11_std_unique_ptr.takeKlassUniquePtr(null)
    cpp11_std_unique_ptr.takeKlassUniquePtr(cpp11_std_unique_ptr.make_null())
    checkCount(0)

    // overloaded parameters
    if (cpp11_std_unique_ptr.overloadTest() != 0)
        throw RuntimeException("overloadTest failed")
    if (cpp11_std_unique_ptr.overloadTest(null) != 1)
        throw RuntimeException("overloadTest failed")
    if (cpp11_std_unique_ptr.overloadTest(Klass("over")) != 1)
        throw RuntimeException("overloadTest failed")
    checkCount(0)


    ///// INPUT BY RVALUE REF /////
    // unique_ptr as input
    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.moveKlassUniquePtr(kin)
        checkCount(0)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw RuntimeException("is_nullptr failed")
        kin.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.moveKlassUniquePtr(kin)
        checkCount(0)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw RuntimeException("is_nullptr failed")
        var exception_thrown = false
        try {
            cpp11_std_unique_ptr.moveKlassUniquePtr(kin)
        } catch (e: RuntimeException) {
            if (!e.message!!.contains("Cannot release ownership as memory is not owned"))
                throw RuntimeException("incorrect exception message")
            exception_thrown = true
        }
        if (!exception_thrown)
            throw RuntimeException("double usage of moveKlassUniquePtr should have been an error")
        kin.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    run {
        val kin = Klass("KlassInput")
        var exception_thrown = false
        val notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin)
        try {
            cpp11_std_unique_ptr.moveKlassUniquePtr(notowned)
        } catch (e: RuntimeException) {
            if (!e.message!!.contains("Cannot release ownership as memory is not owned"))
                throw RuntimeException("incorrect exception message")
            exception_thrown = true
        }
        if (!exception_thrown)
            throw RuntimeException("Should have thrown 'Cannot release ownership as memory is not owned' error")
        checkCount(1)
        kin.delete()
        checkCount(0)
    }

    run {
        val kini = KlassInheritance("KlassInheritanceInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.moveKlassUniquePtr(kini)
        checkCount(0)
        if (s != "KlassInheritanceInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kini))
            throw RuntimeException("is_nullptr failed")
        kini.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    cpp11_std_unique_ptr.moveKlassUniquePtr(null)
    cpp11_std_unique_ptr.moveKlassUniquePtr(cpp11_std_unique_ptr.make_null())
    checkCount(0)

    // overloaded parameters
    if (cpp11_std_unique_ptr.moveOverloadTest() != 0)
        throw RuntimeException("moveOverloadTest failed")
    if (cpp11_std_unique_ptr.moveOverloadTest(null) != 1)
        throw RuntimeException("moveOverloadTest failed")
    if (cpp11_std_unique_ptr.moveOverloadTest(Klass("over")) != 1)
        throw RuntimeException("moveOverloadTest failed")
    checkCount(0)


    ///// INPUT BY NON-CONST LVALUE REF /////
    // unique_ptr as input
    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin)
        checkCount(0)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw RuntimeException("is_nullptr failed")
        kin.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin)
        checkCount(0)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw RuntimeException("is_nullptr failed")
        var exception_thrown = false
        try {
            cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin)
        } catch (e: RuntimeException) {
            if (!e.message!!.contains("Cannot release ownership as memory is not owned"))
                throw RuntimeException("incorrect exception message")
            exception_thrown = true
        }
        if (!exception_thrown)
            throw RuntimeException("double usage of moveRefKlassUniquePtr should have been an error")
        kin.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    run {
        val kin = Klass("KlassInput")
        var exception_thrown = false
        val notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin)
        try {
            cpp11_std_unique_ptr.moveRefKlassUniquePtr(notowned)
        } catch (e: RuntimeException) {
            if (!e.message!!.contains("Cannot release ownership as memory is not owned"))
                throw RuntimeException("incorrect exception message")
            exception_thrown = true
        }
        if (!exception_thrown)
            throw RuntimeException("Should have thrown 'Cannot release ownership as memory is not owned' error")
        checkCount(1)
        kin.delete()
        checkCount(0)
    }

    run {
        val kini = KlassInheritance("KlassInheritanceInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kini)
        checkCount(0)
        if (s != "KlassInheritanceInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!cpp11_std_unique_ptr.is_nullptr(kini))
            throw RuntimeException("is_nullptr failed")
        kini.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    cpp11_std_unique_ptr.moveRefKlassUniquePtr(null)
    cpp11_std_unique_ptr.moveRefKlassUniquePtr(cpp11_std_unique_ptr.make_null())
    checkCount(0)

    // overloaded parameters
    if (cpp11_std_unique_ptr.moveRefOverloadTest() != 0)
        throw RuntimeException("moveRefOverloadTest failed")
    if (cpp11_std_unique_ptr.moveRefOverloadTest(null) != 1)
        throw RuntimeException("moveRefOverloadTest failed")
    if (cpp11_std_unique_ptr.moveRefOverloadTest(Klass("over")) != 1)
        throw RuntimeException("moveRefOverloadTest failed")
    checkCount(0)


    ///// INPUT BY CONST LVALUE REF /////
    // unique_ptr as input
    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.useRefKlassUniquePtr(kin)
        checkCount(1)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        kin.delete()
        checkCount(0)
    }

    run {
        val kini = KlassInheritance("KlassInheritanceInput")
        checkCount(1)
        val s = cpp11_std_unique_ptr.useRefKlassUniquePtr(kini)
        checkCount(1)
        if (s != "KlassInheritanceInput")
            throw RuntimeException("Incorrect string: " + s)
        kini.delete()
        checkCount(0)
    }

    cpp11_std_unique_ptr.useRefKlassUniquePtr(null)
    cpp11_std_unique_ptr.useRefKlassUniquePtr(cpp11_std_unique_ptr.make_null())
    checkCount(0)

    // overloaded parameters
    if (cpp11_std_unique_ptr.useRefOverloadTest() != 0)
        throw RuntimeException("useRefOverloadTest failed")
    if (cpp11_std_unique_ptr.useRefOverloadTest(null) != 1)
        throw RuntimeException("useRefOverloadTest failed")
    run {
        val kin = Klass("over")
        if (cpp11_std_unique_ptr.useRefOverloadTest(kin) != 1)
            throw RuntimeException("useRefOverloadTest failed")
        checkCount(1)
        kin.delete()
    }
    checkCount(0)


    // unique_ptr as output
    var k1 = cpp11_std_unique_ptr.makeKlassUniquePtr("first")
    if (k1!!.getLabel() != "first")
        throw RuntimeException("wrong object label")

    val k2 = cpp11_std_unique_ptr.makeKlassUniquePtr("second")
    checkCount(2)

    k1.delete()
    k1 = null
    checkCount(1)

    if (k2!!.getLabel() != "second")
        throw RuntimeException("wrong object label")

    k2.delete()
    checkCount(0)

    if (cpp11_std_unique_ptr.makeNullUniquePtr() != null)
        throw RuntimeException("null failure")

    // unique_ptr as output (rvalue ref)
    k1 = cpp11_std_unique_ptr.makeRVRKlassUniquePtr("first")
    if (k1!!.getLabel() != "first")
        throw RuntimeException("wrong object label")
    k1 = cpp11_std_unique_ptr.makeRVRKlassUniquePtr(null)
    if (k1 != null)
        throw RuntimeException("not null")

    // unique_ptr as output (lvalue ref)
    k1 = cpp11_std_unique_ptr.makeRefKlassUniquePtr("lvalueref")
    if (k1!!.getLabel() != "lvalueref")
        throw RuntimeException("wrong object label")
    k1 = cpp11_std_unique_ptr.makeRefKlassUniquePtr(null)
    if (k1 != null)
        throw RuntimeException("not null")
}
