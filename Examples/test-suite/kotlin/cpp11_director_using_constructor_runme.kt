@file:JvmName("cpp11_director_using_constructor_runme")

import cpp11_director_using_constructor.*

// Protected constructors, check both protected and public constructors can be called from a derived class
class MyProtectedBase1(i: Int, s: String) : ProtectedBase1(i, s)
class MyProtectedDerived1(i: Int, s: String) : ProtectedDerived1(i, s)
class MyProtectedBase2 : ProtectedBase2 {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProtectedDerived2 : ProtectedDerived2 {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProtectedBase3 : ProtectedBase3 {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProtectedDerived3 : ProtectedDerived3 {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProtectedBase4 : ProtectedBase4()
class MyProtectedDerived4 : ProtectedDerived4()
class MyProtectedBase5 : ProtectedBase5()
class MyProtectedDerived5 : ProtectedDerived5()

// Protected constructors, just check the protected constructors can be called from a derived class
class MyProotBase1(i: Int, s: String) : ProotBase1(i, s)
class MyProotDerived1a(i: Int, s: String) : ProotDerived1a(i, s)
class MyProotDerived1d(i: Int, s: String) : ProotDerived1d(i, s)
class MyProotDerived1e(i: Int, s: String) : ProotDerived1e(i, s)

// Protected constructors, check both protected and public constructors can be called from a derived class
class MyProotBase2 : ProotBase2 {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProotDerived2a : ProotDerived2a {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProotDerived2b : ProotDerived2b {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProotDerived2c : ProotDerived2c {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProotDerived2d : ProotDerived2d {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProotDerived2e : ProotDerived2e {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
}
class MyProotDerived2f : ProotDerived2f {
    constructor(i: Int, s: String) : super(i, s)
    constructor() : super()
    constructor(i: Int) : super(i)
}

fun main() {
    try {
        System.loadLibrary("cpp11_director_using_constructor")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // This is a copy of cpp11_using_constructor_runme for testing that the expected constructors can be called

    // Public base constructors
    PublicDerived1(0, "hi").meth()
    PublicDerived2().meth()
    PublicDerived2(0, "hi").meth()
    PublicDerived3().meth()
    PublicDerived3(0, "hi").meth()
    PublicDerived4().meth()
    PublicDerived5().meth()

    // Protected base constructors
    // Cannot test most of these as the constructors are protected
    ProtectedDerived5()

    // Mix of public and overloaded constructors
    MixedDerived1a(0, "hi").meth()
    MixedDerived1a().meth()
    MixedDerived1b(0, "hi").meth()
    MixedDerived1b().meth()

    MixedDerived2a(0, "hi").meth()
    MixedDerived2a().meth()
    MixedDerived2b(0, "hi").meth()
    MixedDerived2b().meth()

    MixedDerived2c(0, "hi").meth()
    MixedDerived2c().meth()
    MixedDerived2c(0).meth()

    MixedDerived2d(0, "hi").meth()
    MixedDerived2d().meth()
    MixedDerived2d(0).meth()

    MixedDerived3a(0, "hi").meth()
    MixedDerived3a().meth()
    MixedDerived3b(0, "hi").meth()
    MixedDerived3b().meth()

    MixedDerived3c(0, "hi").meth()
    MixedDerived3c().meth()
    MixedDerived3c(0).meth()

    MixedDerived3d(0, "hi").meth()
    MixedDerived3d().meth()
    MixedDerived3d(0).meth()

    MixedDerived4a(0, "hi").meth()
    MixedDerived4a().meth()
    MixedDerived4b(0, "hi").meth()
    MixedDerived4b().meth()

    MixedDerived4c().meth()
    MixedDerived4c(0).meth()

    MixedDerived4d().meth()
    MixedDerived4d(0).meth()

    MixedDerived4e().meth()

    MixedDerived4f().meth()

    // Mix of protected base constructors and overloading
    ProotDerived1a().meth()

    ProotDerived1b(0, "hi").meth()
    ProotDerived1b().meth()

    ProotDerived1c(0, "hi").meth()
    ProotDerived1c().meth()

    ProotDerived1d(0).meth()
    ProotDerived1d().meth()

    ProotDerived1e(0).meth()
    ProotDerived1e().meth()

    ProotDerived2a(0, "hi").meth()

    ProotDerived2b(0, "hi").meth()

    ProotDerived2c(0, "hi").meth()
    ProotDerived2c().meth()

    ProotDerived2d(0, "hi").meth()
    ProotDerived2d().meth()

    ProotDerived2e(0, "hi").meth()
    ProotDerived2e().meth()

    ProotDerived2f(0, "hi").meth()
    ProotDerived2f().meth()
    ProotDerived2f(0).meth()

    // Deeper inheritance chain
    var db3 = DeepBase3(11)
    db3 = DeepBase3(11, 22)
    db3 = DeepBase3(11, 22, 33)
    val dbp3 = DeepProtectedBase3(11, 22, 33)

    // Missing base
    HiddenDerived1()

    // Templates and public base constructors (derive from non-template)
    TemplatePublicDerived1Int(0, "hi").meth()
    TemplatePublicDerived2Int().meth()
    TemplatePublicDerived2Int(0, "hi").meth()
    TemplatePublicDerived3Int().meth()
    TemplatePublicDerived3Int(0, "hi").meth()
    TemplatePublicDerived4Int().meth()
    TemplatePublicDerived5Int().meth()

    // Templates and public base constructors (derive from template)
    TemplPublicDerived1Int(0, "hi").meth()
    TemplPublicDerived2Int().meth()
    TemplPublicDerived2Int(0, "hi").meth()
    TemplPublicDerived3Int().meth()
    TemplPublicDerived3Int(0, "hi").meth()
    TemplPublicDerived4Int().meth()
    TemplPublicDerived5Int().meth()
    TemplPublicDerived6Int(0, "hi").meth()
    TemplPublicDerived6Int().meth()

    // Templated constructors (public)
    var tcb = TemplateConstructor1Base(0, "hi")
    tcb = TemplateConstructor1Base("hi", "hi")
    tcb = TemplateConstructor1Base(11.1, "hi")
    tcb.normal_method()
    tcb.template_method(0, "hi")
    tcb.template_method("hey", "ho")

    var tcd1 = TemplateConstructor1Derived(0, "hi")
    tcd1 = TemplateConstructor1Derived("hi", "hi")
    tcd1 = TemplateConstructor1Derived(11.1, "hi")
    // Not the best test as these are also in the base class, hence use also introspection below
    tcd1.normal_method()
    tcd1.template_method(0, "hi")
    tcd1.template_method("hey", "ho")

    // Templated methods
    // Introspection to make sure these are actually generated in the derived class
    try {
        TemplateConstructor1Derived::class.java.getDeclaredMethod("normal_method")
        TemplateConstructor1Derived::class.java.getDeclaredMethod("template_method", String::class.java, String::class.java)
        TemplateConstructor1Derived::class.java.getDeclaredMethod("template_method", Int::class.javaPrimitiveType, String::class.java)
    } catch (e: NoSuchMethodException) {
        throw RuntimeException(e)
    }

    // Templated constructors (protected)
    val tcd2 = TemplateConstructor2Derived()
    tcd2.normal_method()
    tcd2.template_method(0, "hi")
    tcd2.template_method("hey", "ho")
}
