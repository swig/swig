@file:JvmName("nspacemove_runme")

fun main() {
    try {
        System.loadLibrary("nspacemove")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // constructors and destructors
    val color1 = nspacemovePackage.Ooter.Extra.Inner1.Color()
    val color = nspacemovePackage.Ooter.Extra.Inner1.Color(color1)
    color1.delete()

    // class methods
    color.colorInstanceMethod(20.0)
    nspacemovePackage.Ooter.Extra.Inner1.Color.colorStaticMethod(20.0)
    val created = nspacemovePackage.Ooter.Extra.Inner1.Color.create()

    // class enums
    val someClass = nspacemovePackage.Outer.SomeClass()
    val channel = someClass.GetInner1ColorChannel()
    if (channel != nspacemovePackage.Ooter.Extra.Inner1.Color.Channel.Transmission)
        throw RuntimeException("Transmission wrong")

    // class anonymous enums
    val val1 = nspacemovePackage.Ooter.Extra.Inner1.Color.ColorEnumVal1
    val val2 = nspacemovePackage.Ooter.Extra.Inner1.Color.ColorEnumVal2
    if (val1 != 0 || val2 != 0x22)
        throw RuntimeException("ColorEnumVal wrong")

    // instance member variables
    color.instanceMemberVariable = 123
    if (color.instanceMemberVariable != 123)
        throw RuntimeException("instance member variable failed")

    // static member variables
    nspacemovePackage.Ooter.Extra.Inner1.Color.staticMemberVariable = 789
    if (nspacemovePackage.Ooter.Extra.Inner1.Color.staticMemberVariable != 789)
        throw RuntimeException("static member variable failed")
    if (nspacemovePackage.Ooter.Extra.Inner1.Color.staticConstMemberVariable != 222)
        throw RuntimeException("static const member variable failed")
    if (nspacemovePackage.Ooter.Extra.Inner1.Color.staticConstEnumMemberVariable != nspacemovePackage.Ooter.Extra.Inner1.Color.Channel.Transmission)
        throw RuntimeException("static const enum member variable failed")

    // Same class different namespaces
    val col1 = nspacemovePackage.Ooter.Extra.Inner1.Color()
    val col2 = nspacemovePackage.Outer.Snner2.Color.create()
    col2!!.colors(col1, col1, col2, col2, col2)

    // check globals in a namespace don't get mangled with the nspacemovePackage option
    nspacemovePackage.nspacemove.namespaceFunction(color)
    nspacemovePackage.nspacemove.namespaceVar = 111
    if (nspacemovePackage.nspacemove.namespaceVar != 111)
        throw RuntimeException("global var failed")

    // global enums
    val outerChannel1 = someClass.GetInner1Channel()
    if (outerChannel1 != nspacemovePackage.Euter.Extra.Inner1.Channel.Transmission1)
        throw RuntimeException("Transmission1 wrong")
    val outerChannel2 = someClass.GetInner2Channel()
    if (outerChannel2 != nspacemovePackage.Outer.Enner2.Channel.Transmission2)
        throw RuntimeException("Transmission2 wrong")

    nspacemovePackage.nspacemove.takeGlobalEnum(nspacemovePackage.More.GlobalEnum.bbb)

    // global class
    val gc = nspacemovePackage.Additional.GlobalClass()
    gc.gmethod()

    // turn feature off / ignoring
    val ns = nspacemovePackage.Outer.namespce()
    val nons = nspacemovePackage.NoNSpacePlease()

    // Derived class
    val blue3 = nspacemovePackage.Outer.Inner3.Blue()
    blue3.blueInstanceMethod()
    val blue4 = nspacemovePackage.Outer.Inner4.Blue()
    blue4.blueInstanceMethod()
}
