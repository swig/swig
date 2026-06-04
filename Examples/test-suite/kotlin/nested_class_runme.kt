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
    @Suppress("UNUSED_VARIABLE")
    val is1: Outer.InnerStruct1? = outer.makeInnerStruct1()
    @Suppress("UNUSED_VARIABLE")
    val ic1: Outer.InnerClass1? = outer.makeInnerClass1()
    @Suppress("UNUSED_VARIABLE")
    val iu1: Outer.InnerUnion1? = outer.makeInnerUnion1()

    @Suppress("UNUSED_VARIABLE")
    val is2: Outer.InnerStruct2? = outer.makeInnerStruct2()
    @Suppress("UNUSED_VARIABLE")
    val ic2: Outer.InnerClass2? = outer.makeInnerClass2()
    @Suppress("UNUSED_VARIABLE")
    val iu2: Outer.InnerUnion2? = outer.makeInnerUnion2()

    @Suppress("UNUSED_VARIABLE")
    val ic4: Outer.InnerClass4Typedef? = outer.makeInnerClass4Typedef()
    @Suppress("UNUSED_VARIABLE")
    val is4: Outer.InnerStruct4Typedef? = outer.makeInnerStruct4Typedef()
    @Suppress("UNUSED_VARIABLE")
    val iu4: Outer.InnerUnion4Typedef? = outer.makeInnerUnion4Typedef()

    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var ic5: Outer.InnerClass5Typedef? = outer.makeInnerClass5()
    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var is5: Outer.InnerStruct5Typedef? = outer.makeInnerStruct5()
    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var iu5: Outer.InnerUnion5Typedef? = outer.makeInnerUnion5()

    @Suppress("UNUSED_VALUE")
    ic5 = outer.makeInnerClass5Typedef()
    @Suppress("UNUSED_VALUE")
    is5 = outer.makeInnerStruct5Typedef()
    @Suppress("UNUSED_VALUE")
    iu5 = outer.makeInnerUnion5Typedef()

    run {
        @Suppress("UNUSED_VARIABLE")
        val im1: Outer.InnerMultiple? = outer.MultipleInstance1
        @Suppress("UNUSED_VARIABLE")
        val im2: Outer.InnerMultiple? = outer.MultipleInstance2
        @Suppress("UNUSED_VARIABLE")
        val im3: Outer.InnerMultiple? = outer.MultipleInstance3
        @Suppress("UNUSED_VARIABLE")
        val im4: Outer.InnerMultiple? = outer.MultipleInstance4
    }

    run {
        @Suppress("UNUSED_VARIABLE")
        val im1: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance1
        @Suppress("UNUSED_VARIABLE")
        val im2: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance2
        @Suppress("UNUSED_VARIABLE")
        val im3: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance3
        @Suppress("UNUSED_VARIABLE")
        val im4: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance4
    }

    run {
        @Suppress("UNUSED_VARIABLE")
        val im1: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance1
        @Suppress("UNUSED_VARIABLE")
        val im2: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance2
        @Suppress("UNUSED_VARIABLE")
        val im3: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance3
        @Suppress("UNUSED_VARIABLE")
        val im4: Outer.InnerMultipleDerived? = outer.MultipleDerivedInstance4
    }

    run {
        @Suppress("UNUSED_VARIABLE")
        val mat1: Outer.InnerMultipleAnonTypedef1? = outer.makeInnerMultipleAnonTypedef1()
        @Suppress("UNUSED_VARIABLE")
        val mat2: Outer.InnerMultipleAnonTypedef1? = outer.makeInnerMultipleAnonTypedef2()
        @Suppress("UNUSED_VARIABLE")
        val mat3: SWIGTYPE_p_p_Outer__InnerMultipleAnonTypedef1? = outer.makeInnerMultipleAnonTypedef3()

        @Suppress("UNUSED_VARIABLE")
        val mnt: Outer.InnerMultipleNamedTypedef1? = outer.makeInnerMultipleNamedTypedef()
        @Suppress("UNUSED_VARIABLE")
        val mnt1: Outer.InnerMultipleNamedTypedef1? = outer.makeInnerMultipleNamedTypedef1()
        @Suppress("UNUSED_VARIABLE")
        val mnt2: Outer.InnerMultipleNamedTypedef1? = outer.makeInnerMultipleNamedTypedef2()
        @Suppress("UNUSED_VARIABLE")
        val mnt3: SWIGTYPE_p_p_Outer__InnerMultipleNamedTypedef? = outer.makeInnerMultipleNamedTypedef3()
    }
    run {
        @Suppress("UNUSED_VARIABLE")
        val isn: Outer.InnerSameName? = outer.makeInnerSameName()
    }
}
