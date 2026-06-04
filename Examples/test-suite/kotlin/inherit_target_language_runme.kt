@file:JvmName("inherit_target_language_runme")

import inherit_target_language.*

fun main() {
    try {
        System.loadLibrary("inherit_target_language")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    Derived1().targetLanguageBaseMethod()
    Derived2().targetLanguageBaseMethod()

    MultipleDerived1().targetLanguageBaseMethod()
    MultipleDerived2().targetLanguageBaseMethod()
    MultipleDerived3().f()
    MultipleDerived4().g()

    val baseX = BaseX()
    baseX.basex()
    baseX.targetLanguageBase2Method()

    val derivedX = DerivedX()
    derivedX.basex()
    derivedX.derivedx()
    derivedX.targetLanguageBase2Method()
}
