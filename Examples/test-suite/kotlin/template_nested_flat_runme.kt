@file:JvmName("template_nested_flat_runme")

import template_nested_flat.*

fun main() {
    try {
        System.loadLibrary("template_nested_flat")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    T_NormalTemplateNormalClass().tmethod(NormalClass())
    OuterClass().T_OuterTMethodNormalClass(NormalClass())

    val tf = TemplateFuncs()
    if (tf.T_TemplateFuncs1Int(-10) != -10)
        throw RuntimeException("it failed")
    if (tf.T_TemplateFuncs2Double(-12.3) != -12.3)
        throw RuntimeException("it failed")

    val tn = T_NestedOuterTemplateDouble()
    if (tn.hohum(-12.3) != -12.3)
        throw RuntimeException("it failed")
    val inner1 = OuterClass().useInner1(T_OuterClassInner1Int())
    val inner2 = T_OuterClassInner2NormalClass()
    inner2.embeddedVar = 2
    val inner22 = OuterClass().useInner2Again(inner2)
    val inner3 = T_OuterClassInner1Double()
}
