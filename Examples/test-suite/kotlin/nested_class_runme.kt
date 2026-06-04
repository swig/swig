@file:JvmName("nested_class_runme")

import nested_class.*

fun main() {
    try {
        System.loadLibrary("nested_class")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val outer = Outer()
    val is1: Outer.InnerStruct1? = outer.makeInnerStruct1()
    val ic1: Outer.InnerClass1? = outer.makeInnerClass1()
    val iu1: Outer.InnerUnion1? = outer.makeInnerUnion1()

    val is2: Outer.InnerStruct2? = outer.makeInnerStruct2()
    val ic2: Outer.InnerClass2? = outer.makeInnerClass2()
    val iu2: Outer.InnerUnion2? = outer.makeInnerUnion2()

    val ic4: Outer.InnerClass4Typedef? = outer.makeInnerClass4Typedef()
    val is4: Outer.InnerStruct4Typedef? = outer.makeInnerStruct4Typedef()
    val iu4: Outer.InnerUnion4Typedef? = outer.makeInnerUnion4Typedef()

    var ic5: Outer.InnerClass5Typedef? = outer.makeInnerClass5()
    var is5: Outer.InnerStruct5Typedef? = outer.makeInnerStruct5()
    var iu5: Outer.InnerUnion5Typedef? = outer.makeInnerUnion5()

    ic5 = outer.makeInnerClass5Typedef()
    is5 = outer.makeInnerStruct5Typedef()
    iu5 = outer.makeInnerUnion5Typedef()

    run {
        val im1: Outer.InnerMultiple? = outer.MultipleInstance1
        val im2: Outer.InnerMultiple? = outer.MultipleInstance2
        val im3: Outer.InnerMultiple? = outer.MultipleInstance3
        val im4: Outer.InnerMultiple? = outer.MultipleInstance4
    }

    run {
        val im1: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance1
        val im2: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance2
        val im3: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance3
        val im4: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance4
    }

    run {
        val im1: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance1
        val im2: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance2
        val im3: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance3
        val im4: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance4
    }

    run {
        val mat1: Outer.InnerMultipleAnonTypedef1? = outer.makeInnerMultipleAnonTypedef1()
        val mat2: Outer.InnerMultipleAnonTypedef1? = outer.makeInnerMultipleAnonTypedef2()
        val mat3: SWIGTYPE_p_p_Outer__InnerMultipleAnonTypedef1? = outer.makeInnerMultipleAnonTypedef3()

        val mnt: Outer.InnerMultipleNamedTypedef1? = outer.makeInnerMultipleNamedTypedef()
        val mnt1: Outer.InnerMultipleNamedTypedef1? = outer.makeInnerMultipleNamedTypedef1()
        val mnt2: Outer.InnerMultipleNamedTypedef1? = outer.makeInnerMultipleNamedTypedef2()
        val mnt3: SWIGTYPE_p_p_Outer__InnerMultipleNamedTypedef? = outer.makeInnerMultipleNamedTypedef3()
    }
    run {
        val isn: Outer.InnerSameName? = outer.makeInnerSameName()
    }
}
