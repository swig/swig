@file:JvmName("template_methods_runme")

import template_methods.*

fun main() {
    try {
        System.loadLibrary("template_methods")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val num = 1.1f

    // Global templated functions
    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var i = template_methods.convolve1Bool()
    template_methods.convolve1Bool(true)
    @Suppress("UNUSED_VALUE")
    i = template_methods.convolve2Float()
    template_methods.convolve3FloatRenamed(num)
    @Suppress("UNUSED_VALUE")
    i = template_methods.convolve4Float()
    template_methods.convolve4FloatRenamed(num)
    @Suppress("UNUSED_VALUE")
    i = template_methods.convolve5FloatRenamed()
    template_methods.convolve5FloatRenamed(num)

    // Static templated methods
    val k = Klass()
    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var b = k.KlassTMethodBoolRenamed(true)
    k.KlassTMethodBool()
    @Suppress("UNUSED_VALUE")
    b = Klass.KlassStaticTMethodBoolRenamed(true)
    Klass.KlassStaticTMethodBool()

    // Advanced renaming with %s format specifiers
    val clay = Clay()
    @Suppress("UNUSED_VALUE")
    b = clay.ClayBoolRenamed_cmethod(true)
    clay.ClayCMethodBool()
    @Suppress("UNUSED_VALUE")
    b = Clay.ClayBoolStaticRenamed_staticcmethod(true)
    Clay.ClayStaticCMethodBool()

    @Suppress("UNUSED_VALUE")
    i = clay.ClayIntRenamed_cmethod(99)
    clay.ClayIntRenamed_cmethod()
    @Suppress("UNUSED_VALUE")
    i = Clay.ClayIntStaticRenamed_staticcmethod(88)
    Clay.ClayIntStaticRenamed_staticcmethod()

    //
    val cp = ComponentProperties()
    cp.adda("key1", "val1", "key2", 22.2)
    cp.adda("key1", "val1", "key2", "val2", "key3", "val3")
    cp.adda("key1", 1, "key2", 2, "key3", 3)
}
