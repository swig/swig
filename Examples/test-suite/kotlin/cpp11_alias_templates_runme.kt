@file:JvmName("cpp11_alias_templates_runme")

import cpp11_alias_templates.*

fun main() {
    try {
        System.loadLibrary("cpp11_alias_templates")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Box<int> and Boxed<int> resolve to Container<int> = ContainerInt.
    val b = cpp11_alias_templates.make_box(55)
    if (b.get() != 55) throw RuntimeException("make_box")
    b.set(77)
    if (b.get() != 77) throw RuntimeException("ContainerInt.set/get")

    val bb = cpp11_alias_templates.make_boxed(99)
    if (bb.get() != 99) throw RuntimeException("make_boxed")

    // Quad<float> resolves to FixedArray<float, 4> = FixedArrayFloat4.
    val q = cpp11_alias_templates.make_quad()
    if (q.size() != 4) throw RuntimeException("size")
    q.set(2, 3.5f)
    if (q.get(2) != 3.5f) throw RuntimeException("FixedArrayFloat4.set/get")
}
