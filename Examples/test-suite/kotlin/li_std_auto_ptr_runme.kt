@file:JvmName("li_std_auto_ptr_runme")

import li_std_auto_ptr.*

fun checkCount(expectedCount: Int) {
    val actualCount = Klass.getTotal_count()
    if (actualCount != expectedCount)
        throw RuntimeException("Counts incorrect, expected:" + expectedCount + " actual:" + actualCount)
}

fun main() {
    try {
        System.loadLibrary("li_std_auto_ptr")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Test raw pointer handling involving virtual inheritance
    run {
        val kini = KlassInheritance("KlassInheritanceInput")
        checkCount(1)
        val s = li_std_auto_ptr.useKlassRawPtr(kini)
        if (s != "KlassInheritanceInput")
            throw RuntimeException("Incorrect string: " + s)
        kini.delete()
        checkCount(0)
    }

    // auto_ptr as input
    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = li_std_auto_ptr.takeKlassAutoPtr(kin)
        checkCount(0)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!li_std_auto_ptr.is_nullptr(kin))
            throw RuntimeException("is_nullptr failed")
        kin.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    run {
        val kin = Klass("KlassInput")
        checkCount(1)
        val s = li_std_auto_ptr.takeKlassAutoPtr(kin)
        checkCount(0)
        if (s != "KlassInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!li_std_auto_ptr.is_nullptr(kin))
            throw RuntimeException("is_nullptr failed")
        var exceptionThrown = false
        try {
            li_std_auto_ptr.takeKlassAutoPtr(kin)
        } catch (e: RuntimeException) {
            if (e.message?.contains("Cannot release ownership as memory is not owned") != true)
                throw RuntimeException("incorrect exception message")
            exceptionThrown = true
        }
        if (!exceptionThrown)
            throw RuntimeException("double usage of takeKlassAutoPtr should have been an error")
        kin.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    run {
        val kin = Klass("KlassInput")
        var exceptionThrown = false
        val notowned = li_std_auto_ptr.get_not_owned_ptr(kin)
        try {
            li_std_auto_ptr.takeKlassAutoPtr(notowned)
        } catch (e: RuntimeException) {
            if (e.message?.contains("Cannot release ownership as memory is not owned") != true)
                throw RuntimeException("incorrect exception message")
            exceptionThrown = true
        }
        if (!exceptionThrown)
            throw RuntimeException("Should have thrown 'Cannot release ownership as memory is not owned' error")
        checkCount(1)
        kin.delete()
        checkCount(0)
    }

    run {
        val kini = KlassInheritance("KlassInheritanceInput")
        checkCount(1)
        val s = li_std_auto_ptr.takeKlassAutoPtr(kini)
        checkCount(0)
        if (s != "KlassInheritanceInput")
            throw RuntimeException("Incorrect string: " + s)
        if (!li_std_auto_ptr.is_nullptr(kini))
            throw RuntimeException("is_nullptr failed")
        kini.delete() // Should not fail, even though already deleted
        checkCount(0)
    }

    li_std_auto_ptr.takeKlassAutoPtr(null)
    li_std_auto_ptr.takeKlassAutoPtr(li_std_auto_ptr.make_null())
    checkCount(0)

    // overloaded parameters
    if (li_std_auto_ptr.overloadTest() != 0)
        throw RuntimeException("overloadTest failed")
    if (li_std_auto_ptr.overloadTest(null) != 1)
        throw RuntimeException("overloadTest failed")
    if (li_std_auto_ptr.overloadTest(Klass("over")) != 1)
        throw RuntimeException("overloadTest failed")
    checkCount(0)

    // auto_ptr as output
    var k1: Klass? = li_std_auto_ptr.makeKlassAutoPtr("first")
    if (k1!!.getLabel() != "first")
        throw RuntimeException("wrong object label")

    var k2: Klass? = li_std_auto_ptr.makeKlassAutoPtr("second")
    checkCount(2)

    k1.delete()
    k1 = null
    checkCount(1)

    if (k2!!.getLabel() != "second")
        throw RuntimeException("wrong object label")

    k2.delete()
    k2 = null
    checkCount(0)

    if (li_std_auto_ptr.makeNullAutoPtr() != null)
        throw RuntimeException("null failure")
}
