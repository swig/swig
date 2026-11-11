@file:JvmName("multiple_inheritance_interfaces_runme")

import multiple_inheritance_interfaces.*
import java.util.Arrays

fun checkBaseAndInterfaces(cls: Class<*>, interfaceExpected: Boolean, base: String, interfaces: Array<String>) {
    val expectedInterfaces = Array(interfaces.size) { i ->
        "interface multiple_inheritance_interfaces." + interfaces[i]
    }
    val actualInterfaces = cls.interfaces
    val expectedInterfacesString = Arrays.toString(expectedInterfaces)
    val actualInterfacesString = Arrays.toString(actualInterfaces)
    if (expectedInterfacesString != actualInterfacesString)
        throw RuntimeException("Expected interfaces for " + cls.name + ": \n" + expectedInterfacesString + "\n" + "Actual interfaces: \n" + actualInterfacesString)

    var expectedBaseString: String
    if (interfaceExpected) {
        // expecting an interface
        if (!cls.isInterface)
            throw RuntimeException(cls.name + " should be an interface but is not")
        expectedBaseString = if (base.isEmpty()) "" else "multiple_inheritance_interfaces." + base
    } else {
        // expecting a class
        if (cls.isInterface)
            throw RuntimeException(cls.name + " is an interface but it should not be")
        expectedBaseString = if (base.isEmpty()) "java.lang.Object" else "multiple_inheritance_interfaces." + base
    }

    val actualBaseString = if (cls.superclass == null) "" else cls.superclass.name
    if (expectedBaseString != actualBaseString)
        throw RuntimeException("Expected base for " + cls.name + ": [" + expectedBaseString + "]" + " Actual base: [" + actualBaseString + "]")
}

fun main() {
    try {
        System.loadLibrary("multiple_inheritance_interfaces")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    checkBaseAndInterfaces(IA::class.java, true, "", arrayOf())
    checkBaseAndInterfaces(IB::class.java, true, "", arrayOf())
    checkBaseAndInterfaces(IC::class.java, true, "", arrayOf("IA", "IB"))
    checkBaseAndInterfaces(A::class.java, false, "", arrayOf("IA"))
    checkBaseAndInterfaces(B::class.java, false, "", arrayOf("IB"))
    checkBaseAndInterfaces(C::class.java, false, "", arrayOf("IC", "IA", "IB"))
    checkBaseAndInterfaces(D::class.java, false, "", arrayOf("IC", "IA", "IB"))
    checkBaseAndInterfaces(E::class.java, false, "D", arrayOf())

    checkBaseAndInterfaces(IJ::class.java, true, "", arrayOf())
    checkBaseAndInterfaces(IK::class.java, true, "", arrayOf("IJ"))
    checkBaseAndInterfaces(IL::class.java, true, "", arrayOf("IK"))
    checkBaseAndInterfaces(J::class.java, false, "", arrayOf("IJ"))
    checkBaseAndInterfaces(K::class.java, false, "", arrayOf("IK", "IJ"))
    checkBaseAndInterfaces(L::class.java, false, "", arrayOf("IL", "IK", "IJ"))
    checkBaseAndInterfaces(M::class.java, false, "", arrayOf("IL", "IK", "IJ"))

    checkBaseAndInterfaces(P::class.java, false, "", arrayOf())
    checkBaseAndInterfaces(IQ::class.java, true, "", arrayOf())
    checkBaseAndInterfaces(Q::class.java, false, "", arrayOf("IQ"))
    checkBaseAndInterfaces(R::class.java, false, "P", arrayOf("IQ"))
    checkBaseAndInterfaces(S::class.java, false, "P", arrayOf("IQ"))
    checkBaseAndInterfaces(T::class.java, false, "", arrayOf("IQ"))
    checkBaseAndInterfaces(U::class.java, false, "R", arrayOf())
    checkBaseAndInterfaces(V::class.java, false, "S", arrayOf())
    checkBaseAndInterfaces(W::class.java, false, "T", arrayOf())

    checkBaseAndInterfaces(IV1SwigInterface::class.java, true, "", arrayOf("IA"))
    checkBaseAndInterfaces(IV2SwigInterface::class.java, true, "", arrayOf("IA"))
    checkBaseAndInterfaces(IV1::class.java, false, "", arrayOf("IV1SwigInterface", "IA"))
    checkBaseAndInterfaces(IV2::class.java, false, "", arrayOf("IV2SwigInterface", "IA"))
    checkBaseAndInterfaces(V3::class.java, false, "", arrayOf("V3SwigInterface", "IV1SwigInterface", "IA", "IV2SwigInterface"))
    checkBaseAndInterfaces(V3SwigInterface::class.java, true, "", arrayOf("IV1SwigInterface", "IV2SwigInterface"))

    // overloaded methods check
    val d = D()
    d.ia()
    d.ia(10)
    d.ia("bye")
    d.ia("bye", false)

    UndesirablesSwigImpl.UndesiredStaticMethod(UndesirablesSwigImpl.UndesiredEnum.UndesiredEnum1)
}
