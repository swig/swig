@file:JvmName("nspace_extend_runme")

import nspace_extendPackage.Outer.Inner1.*
import nspace_extendPackage.Outer.Inner2.*

fun main() {
    try {
        System.loadLibrary("nspace_extend")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        // constructors and destructors
        val color1 = nspace_extendPackage.Outer.Inner1.Color()
        val color = nspace_extendPackage.Outer.Inner1.Color(color1)
        color1.delete()

        // class methods
        color.colorInstanceMethod(20.0)
        nspace_extendPackage.Outer.Inner1.Color.colorStaticMethod(20.0)
        val created = nspace_extendPackage.Outer.Inner1.Color.create()
    }
    run {
        // constructors and destructors
        val color2 = nspace_extendPackage.Outer.Inner2.Color()
        val color = nspace_extendPackage.Outer.Inner2.Color(color2)
        color2.delete()

        // class methods
        color.colorInstanceMethod(20.0)
        nspace_extendPackage.Outer.Inner2.Color.colorStaticMethod(20.0)
        val created = nspace_extendPackage.Outer.Inner2.Color.create()

        // Same class different namespaces
        val col1 = nspace_extendPackage.Outer.Inner1.Color()
        val col2 = nspace_extendPackage.Outer.Inner2.Color.create()
        col2!!.colors(col1, col1, col2, col2, col2)
    }
}
