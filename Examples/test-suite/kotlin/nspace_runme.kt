@file:JvmName("nspace_runme")

import nspacePackage.Outer.Inner1.*
import nspacePackage.Outer.Inner2.*
import nspacePackage.Outer.Inner3.*
import nspacePackage.Outer.Inner4.*

fun main() {
    try {
        System.loadLibrary("nspace")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // constructors and destructors
    val color1 = nspacePackage.Outer.Inner1.Color()
    val color = nspacePackage.Outer.Inner1.Color(color1)
    color1.delete()

    // class methods
    color.colorInstanceMethod(20.0)
    nspacePackage.Outer.Inner1.Color.colorStaticMethod(20.0)
    val created = nspacePackage.Outer.Inner1.Color.create()

    // class enums
    val someClass = nspacePackage.Outer.SomeClass()
    val channel = someClass.GetInner1ColorChannel()
    if (channel != nspacePackage.Outer.Inner1.Color.Channel.Transmission)
        throw RuntimeException("Transmission wrong")

    // class anonymous enums
    val val1 = nspacePackage.Outer.Inner1.Color.ColorEnumVal1
    val val2 = nspacePackage.Outer.Inner1.Color.ColorEnumVal2
    if (val1 != 0 || val2 != 0x22)
        throw RuntimeException("ColorEnumVal wrong")

    // instance member variables
    color.instanceMemberVariable = 123
    if (color.instanceMemberVariable != 123)
        throw RuntimeException("instance member variable failed")

    // static member variables
    nspacePackage.Outer.Inner1.Color.staticMemberVariable = 789
    if (nspacePackage.Outer.Inner1.Color.staticMemberVariable != 789)
        throw RuntimeException("static member variable failed")
    if (nspacePackage.Outer.Inner1.Color.staticConstMemberVariable != 222)
        throw RuntimeException("static const member variable failed")
    if (nspacePackage.Outer.Inner1.Color.staticConstEnumMemberVariable != nspacePackage.Outer.Inner1.Color.Channel.Transmission)
        throw RuntimeException("static const enum member variable failed")

    // Same class different namespaces
    val col1 = nspacePackage.Outer.Inner1.Color()
    val col2 = nspacePackage.Outer.Inner2.Color.create()
    col2!!.colors(col1, col1, col2, col2, col2)

    // check globals in a namespace don't get mangled with the nspacePackage option
    nspacePackage.nspace.namespaceFunction(color)
    nspacePackage.nspace.namespaceVar = 111
    if (nspacePackage.nspace.namespaceVar != 111)
        throw RuntimeException("global var failed")

    // global enums
    val outerChannel1 = someClass.GetInner1Channel()
    if (outerChannel1 != nspacePackage.Outer.Inner1.Channel.Transmission1)
        throw RuntimeException("Transmission1 wrong")
    val outerChannel2 = someClass.GetInner2Channel()
    if (outerChannel2 != nspacePackage.Outer.Inner2.Channel.Transmission2)
        throw RuntimeException("Transmission2 wrong")

    // turn feature off / ignoring
    val ns = nspacePackage.Outer.namespce()
    val nons = nspacePackage.NoNSpacePlease()

    // Derived class
    val blue3 = nspacePackage.Outer.Inner3.Blue()
    blue3.blueInstanceMethod()
    val blue4 = nspacePackage.Outer.Inner4.Blue()
    blue4.blueInstanceMethod()
}
