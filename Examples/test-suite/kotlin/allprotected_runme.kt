@file:JvmName("allprotected_runme")

import allprotected.*

class MyProtectedBase(name: String) : ProtectedBase(name) {
    fun accessProtected() {
        val s = virtualMethod()
        if (s != "ProtectedBase")
            throw RuntimeException("Failed")

        var k: Klass? = instanceMethod(Klass("xyz"))
        if (k!!.getName() != "xyz")
            throw RuntimeException("Failed")

        k = instanceOverloaded(Klass("xyz"))
        if (k!!.getName() != "xyz")
            throw RuntimeException("Failed")

        k = instanceOverloaded(Klass("xyz"), "abc")
        if (k!!.getName() != "abc")
            throw RuntimeException("Failed")

        k = ProtectedBase.staticMethod(Klass("abc"))
        if (k!!.getName() != "abc")
            throw RuntimeException("Failed")

        k = ProtectedBase.staticOverloaded(Klass("xyz"))
        if (k!!.getName() != "xyz")
            throw RuntimeException("Failed")

        k = ProtectedBase.staticOverloaded(Klass("xyz"), "abc")
        if (k!!.getName() != "abc")
            throw RuntimeException("Failed")

        instanceMemberVariable = 30
        var i = instanceMemberVariable
        if (i != 30)
            throw RuntimeException("Failed")

        staticMemberVariable = 40
        i = staticMemberVariable
        if (i != 40)
            throw RuntimeException("Failed")

        i = staticConstMemberVariable
        if (i != 20)
            throw RuntimeException("Failed")

        anEnum = ProtectedBase.AnEnum.EnumVal1
        val ae = anEnum
        if (ae != ProtectedBase.AnEnum.EnumVal1)
            throw RuntimeException("Failed")
    }
}

class MyAllProtectedBottom : AllProtectedBottom() {
    fun callProtectedMethods() {
        usingOverloaded()
        usingOverloaded(99)
        usingSingle()
        doSomething()
        doSomething(99)
    }
}

fun main() {
    try {
        System.loadLibrary("allprotected")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val mpb = MyProtectedBase("MyProtectedBase")
    mpb.accessProtected()

    val mapb = MyAllProtectedBottom()
    mapb.callProtectedMethods()
}
