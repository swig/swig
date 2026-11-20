@file:JvmName("nspacemove_nested_runme")

fun main() {
    try {
        System.loadLibrary("nspacemove_nested")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // outer classes
    val oc1 = nspacemove_nestedPackage.Space.OuterClass1()
    val oc2 = nspacemove_nestedPackage.Space.OuterClass2()
    val oc3 = nspacemove_nestedPackage.NewSpace3.OuterClass3()
    val oc4 = nspacemove_nestedPackage.NewSpace4.OuterClass4()
    val oc5 = nspacemove_nestedPackage.OuterClass5()
    val oc6 = nspacemove_nestedPackage.OuterClass6()
    val oc7 = nspacemove_nestedPackage.OuterClass7()

    val oc10 = nspacemove_nestedPackage.Space.OuterClass10()
    val oc20 = nspacemove_nestedPackage.Space.OuterClass20()
    val oc30 = nspacemove_nestedPackage.NewOkay30.OuterClass30()
    val oc40 = nspacemove_nestedPackage.NewOkay40.OuterClass40()
    val oc50 = nspacemove_nestedPackage.NewOkay50.OuterClass50()
    val oc60 = nspacemove_nestedPackage.OuterClass60()
    val oc70 = nspacemove_nestedPackage.OuterClass70()
    val oc80 = nspacemove_nestedPackage.Space.OuterClass80()

    // inner classes
    val ic1 = nspacemove_nestedPackage.Space.OuterClass1.InnerClass1()
    val ic2 = nspacemove_nestedPackage.Space.OuterClass2.InnerClass2()
    val ic3 = nspacemove_nestedPackage.NewSpace3.OuterClass3.InnerClass3()
    val ic4 = nspacemove_nestedPackage.NewSpace4.OuterClass4.InnerClass4()
    val ic5 = nspacemove_nestedPackage.OuterClass5.InnerClass5()
    val ic6 = nspacemove_nestedPackage.OuterClass6.InnerClass6()
    val ic7 = nspacemove_nestedPackage.OuterClass7.InnerClass7()

    val ic10 = nspacemove_nestedPackage.Space.OuterClass10.InnerClass10()
    val ic20 = nspacemove_nestedPackage.Space.OuterClass20.InnerClass20()
    val ic30 = nspacemove_nestedPackage.NewOkay30.OuterClass30.InnerClass30()
    val ic40 = nspacemove_nestedPackage.NewOkay40.OuterClass40.InnerClass40()
    val ic50 = nspacemove_nestedPackage.NewOkay50.OuterClass50.InnerClass50()
    val ic60 = nspacemove_nestedPackage.OuterClass60.InnerClass60()
    val ic70 = nspacemove_nestedPackage.OuterClass70.InnerClass70()
    val ic80 = nspacemove_nestedPackage.Space.OuterClass80.InnerClass80()

    // inner enums
    oc1.take(nspacemove_nestedPackage.Space.OuterClass1.InnerEnum1.ie1a, ic1)
    oc2.take(nspacemove_nestedPackage.Space.OuterClass2.InnerEnum2.ie2a, ic2)
    oc3.take(nspacemove_nestedPackage.NewSpace3.OuterClass3.InnerEnum3.ie3a, ic3)
    oc4.take(nspacemove_nestedPackage.NewSpace4.OuterClass4.InnerEnum4.ie4a, ic4)
    oc5.take(nspacemove_nestedPackage.OuterClass5.InnerEnum5.ie5a, ic5)
    oc6.take(nspacemove_nestedPackage.OuterClass6.InnerEnum6.ie6a, ic6)
    oc7.take(nspacemove_nestedPackage.OuterClass7.InnerEnum7.ie7a, ic7)

    oc10.take(nspacemove_nestedPackage.Space.OuterClass10.InnerEnum10.ie10a, ic10)
    oc20.take(nspacemove_nestedPackage.Space.OuterClass20.InnerEnum20.ie20a, ic20)
    oc30.take(nspacemove_nestedPackage.NewOkay30.OuterClass30.InnerEnum30.ie30a, ic30)
    oc40.take(nspacemove_nestedPackage.NewOkay40.OuterClass40.InnerEnum40.ie40a, ic40)
    oc50.take(nspacemove_nestedPackage.NewOkay50.OuterClass50.InnerEnum50.ie50a, ic50)
    oc60.take(nspacemove_nestedPackage.OuterClass60.InnerEnum60.ie60a, ic60)
    oc70.take(nspacemove_nestedPackage.OuterClass70.InnerEnum70.ie70a, ic70)
    oc80.take(nspacemove_nestedPackage.Space.OuterClass80.InnerEnum80.ie80a, ic80)
}
