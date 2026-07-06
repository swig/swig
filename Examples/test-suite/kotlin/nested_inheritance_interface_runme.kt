@file:JvmName("nested_inheritance_interface_runme")

import nested_inheritance_interface.*

// The %interface(IA) feature is only applied for SWIGJAVA/SWIGCSHARP. For the Kotlin
// module %feature("flatnested") is applied instead and IA is generated as a plain base
// class (no IASwigInterface interface type, and N is flattened to a top-level class).
// The Java runme's interface-reflection assertions and B.N nesting are therefore not
// applicable here; this port simply exercises the generated class hierarchy (N : IA).

private fun takeIA(ia: IA) {
}

fun main() {
    try {
        System.loadLibrary("nested_inheritance_interface")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val d = N()
    if (d !is IA)
        throw RuntimeException("N should be an IA")
    takeIA(d)
}
