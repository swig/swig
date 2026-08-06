@file:JvmName("cpp11_shared_ptr_overload_runme")

import cpp11_shared_ptr_overload.*

fun main() {
    try {
        System.loadLibrary("cpp11_shared_ptr_overload")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var ret: String

    // ref
    ret = cpp11_shared_ptr_overload.UseA(MyType("123"))
    if (ret != "123 ref") throw RuntimeException("UseA fail:" + ret)

    ret = cpp11_shared_ptr_overload.UseB(0, MyType("123"))
    if (ret != "123 ref") throw RuntimeException("UseB fail:" + ret)

    ret = cpp11_shared_ptr_overload.UseC(0, MyType("123"), MyType("456"))
    if (ret != "123 ref") throw RuntimeException("UseC fail:" + ret)

    // sharedptr
    ret = cpp11_shared_ptr_overload.UseX(MyType("123"))
    if (ret != "123 sharedptr") throw RuntimeException("UseX fail:" + ret)

    ret = cpp11_shared_ptr_overload.UseY(0, MyType("123"))
    if (ret != "123 sharedptr") throw RuntimeException("UseY fail:" + ret)

    ret = cpp11_shared_ptr_overload.UseZ(0, MyType("123"), MyType("456"))
    if (ret != "123 sharedptr") throw RuntimeException("UseZ fail:" + ret)

    // Combo1-4
    ret = cpp11_shared_ptr_overload.Combo1(MyType("XXX"))
    if (ret != "XXXCombo1") throw RuntimeException("Combo1 fail:" + ret)

    ret = cpp11_shared_ptr_overload.Combo2(MyType("XXX"))
    if (ret != "XXXCombo2") throw RuntimeException("Combo2 fail:" + ret)

    ret = cpp11_shared_ptr_overload.Combo3(MyType("XXX"))
    if (ret != "XXXCombo3") throw RuntimeException("Combo3 fail:" + ret)

    ret = cpp11_shared_ptr_overload.Combo4(MyType("XXX"))
    if (ret != "XXXCombo4") throw RuntimeException("Combo4 fail:" + ret)

    // Combo5-7
    ret = cpp11_shared_ptr_overload.Combo5(MyType("XXX"))
    if (ret != "XXXCombo5") throw RuntimeException("Combo5 fail:" + ret)

    ret = cpp11_shared_ptr_overload.Combo6(MyType("XXX"))
    if (ret != "XXXCombo6") throw RuntimeException("Combo6 fail:" + ret)

    ret = cpp11_shared_ptr_overload.Combo7(MyType("XXX"))
    if (ret != "XXXCombo7") throw RuntimeException("Combo7 fail:" + ret)
}
