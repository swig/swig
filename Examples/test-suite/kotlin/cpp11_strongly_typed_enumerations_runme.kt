@file:JvmName("cpp11_strongly_typed_enumerations_runme")

import cpp11_strongly_typed_enumerations.*

fun enumCheck(actual: Int, expected: Int): Int {
    if (actual != expected)
        throw RuntimeException("Enum value mismatch. Expected " + expected + " Actual: " + actual)
    return expected + 1
}

fun main() {
    try {
        System.loadLibrary("cpp11_strongly_typed_enumerations")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var value = 0
    value = enumCheck(Enum1.Val1.swigValue, value)
    value = enumCheck(Enum1.Val2.swigValue, value)
    value = enumCheck(Enum1.Val3.swigValue, 13)
    value = enumCheck(Enum1.Val4.swigValue, value)
    value = enumCheck(Enum1.Val5a.swigValue, 13)
    value = enumCheck(Enum1.Val6a.swigValue, value)

    value = 0
    value = enumCheck(Enum2.Val1.swigValue, value)
    value = enumCheck(Enum2.Val2.swigValue, value)
    value = enumCheck(Enum2.Val3.swigValue, 23)
    value = enumCheck(Enum2.Val4.swigValue, value)
    value = enumCheck(Enum2.Val5b.swigValue, 23)
    value = enumCheck(Enum2.Val6b.swigValue, value)

    value = 0
    value = enumCheck(Enum4.Val1.swigValue, value)
    value = enumCheck(Enum4.Val2.swigValue, value)
    value = enumCheck(Enum4.Val3.swigValue, 43)
    value = enumCheck(Enum4.Val4.swigValue, value)

    value = 0
    value = enumCheck(Enum5.Val1.swigValue, value)
    value = enumCheck(Enum5.Val2.swigValue, value)
    value = enumCheck(Enum5.Val3.swigValue, 53)
    value = enumCheck(Enum5.Val4.swigValue, value)

    value = 0
    value = enumCheck(Enum6.Val1.swigValue, value)
    value = enumCheck(Enum6.Val2.swigValue, value)
    value = enumCheck(Enum6.Val3.swigValue, 63)
    value = enumCheck(Enum6.Val4.swigValue, value)

    value = 0
    value = enumCheck(Enum7td.Val1.swigValue, value)
    value = enumCheck(Enum7td.Val2.swigValue, value)
    value = enumCheck(Enum7td.Val3.swigValue, 73)
    value = enumCheck(Enum7td.Val4.swigValue, value)

    value = 0
    value = enumCheck(Enum8.Val1.swigValue, value)
    value = enumCheck(Enum8.Val2.swigValue, value)
    value = enumCheck(Enum8.Val3.swigValue, 83)
    value = enumCheck(Enum8.Val4.swigValue, value)

    value = 0
    value = enumCheck(Enum10.Val1.swigValue, value)
    value = enumCheck(Enum10.Val2.swigValue, value)
    value = enumCheck(Enum10.Val3.swigValue, 103)
    value = enumCheck(Enum10.Val4.swigValue, value)

    value = 0
    value = enumCheck(Class1.Enum12.Val1.swigValue, 1121)
    value = enumCheck(Class1.Enum12.Val2.swigValue, 1122)
    value = enumCheck(Class1.Enum12.Val3.swigValue, value)
    value = enumCheck(Class1.Enum12.Val4.swigValue, value)
    value = enumCheck(Class1.Enum12.Val5c.swigValue, 1121)
    value = enumCheck(Class1.Enum12.Val6c.swigValue, value)

    value = 0
    value = enumCheck(Class1.Enum13.Val1.swigValue, 1131)
    value = enumCheck(Class1.Enum13.Val2.swigValue, 1132)
    value = enumCheck(Class1.Enum13.Val3.swigValue, value)
    value = enumCheck(Class1.Enum13.Val4.swigValue, value)
    value = enumCheck(Class1.Enum13.Val5d.swigValue, 1131)
    value = enumCheck(Class1.Enum13.Val6d.swigValue, value)

    value = 0
    value = enumCheck(Class1.Enum14.Val1.swigValue, 1141)
    value = enumCheck(Class1.Enum14.Val2.swigValue, 1142)
    value = enumCheck(Class1.Enum14.Val3.swigValue, value)
    value = enumCheck(Class1.Enum14.Val4.swigValue, value)
    value = enumCheck(Class1.Enum14.Val5e.swigValue, 1141)
    value = enumCheck(Class1.Enum14.Val6e.swigValue, value)

    value = 0
    value = enumCheck(Class1.Struct1.Enum12.Val1.swigValue, 3121)
    value = enumCheck(Class1.Struct1.Enum12.Val2.swigValue, 3122)
    value = enumCheck(Class1.Struct1.Enum12.Val3.swigValue, value)
    value = enumCheck(Class1.Struct1.Enum12.Val4.swigValue, value)
    value = enumCheck(Class1.Struct1.Enum12.Val5f.swigValue, 3121)
    value = enumCheck(Class1.Struct1.Enum12.Val6f.swigValue, value)

    value = 0
    value = enumCheck(Class1.Struct1.Enum13.Val1.swigValue, 3131)
    value = enumCheck(Class1.Struct1.Enum13.Val2.swigValue, 3132)
    value = enumCheck(Class1.Struct1.Enum13.Val3.swigValue, value)
    value = enumCheck(Class1.Struct1.Enum13.Val4.swigValue, value)

    value = 0
    value = enumCheck(Class1.Struct1.Enum14.Val1.swigValue, 3141)
    value = enumCheck(Class1.Struct1.Enum14.Val2.swigValue, 3142)
    value = enumCheck(Class1.Struct1.Enum14.Val3.swigValue, value)
    value = enumCheck(Class1.Struct1.Enum14.Val4.swigValue, value)
    value = enumCheck(Class1.Struct1.Enum14.Val5g.swigValue, 3141)
    value = enumCheck(Class1.Struct1.Enum14.Val6g.swigValue, value)

    value = 0
    value = enumCheck(Class2.Enum12.Val1.swigValue, 2121)
    value = enumCheck(Class2.Enum12.Val2.swigValue, 2122)
    value = enumCheck(Class2.Enum12.Val3.swigValue, value)
    value = enumCheck(Class2.Enum12.Val4.swigValue, value)
    value = enumCheck(Class2.Enum12.Val5h.swigValue, 2121)
    value = enumCheck(Class2.Enum12.Val6h.swigValue, value)

    value = 0
    value = enumCheck(Class2.Enum13.Val1.swigValue, 2131)
    value = enumCheck(Class2.Enum13.Val2.swigValue, 2132)
    value = enumCheck(Class2.Enum13.Val3.swigValue, value)
    value = enumCheck(Class2.Enum13.Val4.swigValue, value)
    value = enumCheck(Class2.Enum13.Val5i.swigValue, 2131)
    value = enumCheck(Class2.Enum13.Val6i.swigValue, value)

    value = 0
    value = enumCheck(Class2.Enum14.Val1.swigValue, 2141)
    value = enumCheck(Class2.Enum14.Val2.swigValue, 2142)
    value = enumCheck(Class2.Enum14.Val3.swigValue, value)
    value = enumCheck(Class2.Enum14.Val4.swigValue, value)
    value = enumCheck(Class2.Enum14.Val5j.swigValue, 2141)
    value = enumCheck(Class2.Enum14.Val6j.swigValue, value)

    value = 0
    value = enumCheck(Class2.Struct1.Enum12.Val1.swigValue, 4121)
    value = enumCheck(Class2.Struct1.Enum12.Val2.swigValue, 4122)
    value = enumCheck(Class2.Struct1.Enum12.Val3.swigValue, value)
    value = enumCheck(Class2.Struct1.Enum12.Val4.swigValue, value)
    value = enumCheck(Class2.Struct1.Enum12.Val5k.swigValue, 4121)
    value = enumCheck(Class2.Struct1.Enum12.Val6k.swigValue, value)

    value = 0
    value = enumCheck(Class2.Struct1.Enum13.Val1.swigValue, 4131)
    value = enumCheck(Class2.Struct1.Enum13.Val2.swigValue, 4132)
    value = enumCheck(Class2.Struct1.Enum13.Val3.swigValue, value)
    value = enumCheck(Class2.Struct1.Enum13.Val4.swigValue, value)
    value = enumCheck(Class2.Struct1.Enum13.Val5l.swigValue, 4131)
    value = enumCheck(Class2.Struct1.Enum13.Val6l.swigValue, value)

    value = 0
    value = enumCheck(Class2.Struct1.Enum14.Val1.swigValue, 4141)
    value = enumCheck(Class2.Struct1.Enum14.Val2.swigValue, 4142)
    value = enumCheck(Class2.Struct1.Enum14.Val3.swigValue, value)
    value = enumCheck(Class2.Struct1.Enum14.Val4.swigValue, value)
    value = enumCheck(Class2.Struct1.Enum14.Val5m.swigValue, 4141)
    value = enumCheck(Class2.Struct1.Enum14.Val6m.swigValue, value)

    val class1 = Class1()
    enumCheck(class1.class1Test1(Enum1.Val5a).swigValue, 13)
    enumCheck(class1.class1Test2(Class1.Enum12.Val5c).swigValue, 1121)
    enumCheck(class1.class1Test3(Class1.Struct1.Enum12.Val5f).swigValue, 3121)

    enumCheck(cpp11_strongly_typed_enumerations.globalTest1(Enum1.Val5a).swigValue, 13)
    enumCheck(cpp11_strongly_typed_enumerations.globalTest2(Class1.Enum12.Val5c).swigValue, 1121)
    enumCheck(cpp11_strongly_typed_enumerations.globalTest3(Class1.Struct1.Enum12.Val5f).swigValue, 3121)
}
