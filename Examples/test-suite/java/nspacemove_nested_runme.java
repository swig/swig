public class nspacemove_nested_runme {

  static {
    try {
	System.loadLibrary("nspacemove_nested");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // outer classes
    nspacemove_nestedPackage.Space.OuterClass1 oc1 =          new nspacemove_nestedPackage.Space.OuterClass1();
    nspacemove_nestedPackage.Space.OuterClass2 oc2 =          new nspacemove_nestedPackage.Space.OuterClass2();
    nspacemove_nestedPackage.NewSpace3.OuterClass3 oc3 =      new nspacemove_nestedPackage.NewSpace3.OuterClass3();
    nspacemove_nestedPackage.NewSpace4.OuterClass4 oc4 =      new nspacemove_nestedPackage.NewSpace4.OuterClass4();
    nspacemove_nestedPackage.OuterClass5 oc5 =                new nspacemove_nestedPackage.OuterClass5();
    nspacemove_nestedPackage.OuterClass6 oc6 =                new nspacemove_nestedPackage.OuterClass6();
    nspacemove_nestedPackage.OuterClass7 oc7 =                new nspacemove_nestedPackage.OuterClass7();

    nspacemove_nestedPackage.Space.OuterClass10 oc10 =        new nspacemove_nestedPackage.Space.OuterClass10();
    nspacemove_nestedPackage.Space.OuterClass20 oc20 =        new nspacemove_nestedPackage.Space.OuterClass20();
    nspacemove_nestedPackage.NewOkay30.OuterClass30 oc30 =    new nspacemove_nestedPackage.NewOkay30.OuterClass30();
    nspacemove_nestedPackage.NewOkay40.OuterClass40 oc40 =    new nspacemove_nestedPackage.NewOkay40.OuterClass40();
    nspacemove_nestedPackage.NewOkay50.OuterClass50 oc50 =    new nspacemove_nestedPackage.NewOkay50.OuterClass50();
    nspacemove_nestedPackage.OuterClass60 oc60 =              new nspacemove_nestedPackage.OuterClass60();
    nspacemove_nestedPackage.OuterClass70 oc70 =              new nspacemove_nestedPackage.OuterClass70();
    nspacemove_nestedPackage.Space.OuterClass80 oc80 =        new nspacemove_nestedPackage.Space.OuterClass80();

    // inner classes
    nspacemove_nestedPackage.Space.OuterClass1.InnerClass1 ic1 =        new nspacemove_nestedPackage.Space.OuterClass1.InnerClass1();
    nspacemove_nestedPackage.Space.OuterClass2.InnerClass2 ic2 =        new nspacemove_nestedPackage.Space.OuterClass2.InnerClass2();
    nspacemove_nestedPackage.NewSpace3.OuterClass3.InnerClass3 ic3 =    new nspacemove_nestedPackage.NewSpace3.OuterClass3.InnerClass3();
    nspacemove_nestedPackage.NewSpace4.OuterClass4.InnerClass4 ic4 =    new nspacemove_nestedPackage.NewSpace4.OuterClass4.InnerClass4();
    nspacemove_nestedPackage.OuterClass5.InnerClass5 ic5 =              new nspacemove_nestedPackage.OuterClass5.InnerClass5();
    nspacemove_nestedPackage.OuterClass6.InnerClass6 ic6 =              new nspacemove_nestedPackage.OuterClass6.InnerClass6();
    nspacemove_nestedPackage.OuterClass7.InnerClass7 ic7 =              new nspacemove_nestedPackage.OuterClass7.InnerClass7();

    nspacemove_nestedPackage.Space.OuterClass10.InnerClass10 ic10 =     new nspacemove_nestedPackage.Space.OuterClass10.InnerClass10();
    nspacemove_nestedPackage.Space.OuterClass20.InnerClass20 ic20 =     new nspacemove_nestedPackage.Space.OuterClass20.InnerClass20();
    nspacemove_nestedPackage.NewOkay30.OuterClass30.InnerClass30 ic30 = new nspacemove_nestedPackage.NewOkay30.OuterClass30.InnerClass30();
    nspacemove_nestedPackage.NewOkay40.OuterClass40.InnerClass40 ic40 = new nspacemove_nestedPackage.NewOkay40.OuterClass40.InnerClass40();
    nspacemove_nestedPackage.NewOkay50.OuterClass50.InnerClass50 ic50 = new nspacemove_nestedPackage.NewOkay50.OuterClass50.InnerClass50();
    nspacemove_nestedPackage.OuterClass60.InnerClass60 ic60 =           new nspacemove_nestedPackage.OuterClass60.InnerClass60();
    nspacemove_nestedPackage.OuterClass70.InnerClass70 ic70 =           new nspacemove_nestedPackage.OuterClass70.InnerClass70();
    nspacemove_nestedPackage.Space.OuterClass80.InnerClass80 ic80 =     new nspacemove_nestedPackage.Space.OuterClass80.InnerClass80();

    // inner enums
    oc1.take(nspacemove_nestedPackage.Space.OuterClass1.InnerEnum1.ie1a, ic1);
    oc2.take(nspacemove_nestedPackage.Space.OuterClass2.InnerEnum2.ie2a, ic2);
    oc3.take(nspacemove_nestedPackage.NewSpace3.OuterClass3.InnerEnum3.ie3a, ic3);
    oc4.take(nspacemove_nestedPackage.NewSpace4.OuterClass4.InnerEnum4.ie4a, ic4);
    oc5.take(nspacemove_nestedPackage.OuterClass5.InnerEnum5.ie5a, ic5);
    oc6.take(nspacemove_nestedPackage.OuterClass6.InnerEnum6.ie6a, ic6);
    oc7.take(nspacemove_nestedPackage.OuterClass7.InnerEnum7.ie7a, ic7);

    oc10.take(nspacemove_nestedPackage.Space.OuterClass10.InnerEnum10.ie10a, ic10);
    oc20.take(nspacemove_nestedPackage.Space.OuterClass20.InnerEnum20.ie20a, ic20);
    oc30.take(nspacemove_nestedPackage.NewOkay30.OuterClass30.InnerEnum30.ie30a, ic30);
    oc40.take(nspacemove_nestedPackage.NewOkay40.OuterClass40.InnerEnum40.ie40a, ic40);
    oc50.take(nspacemove_nestedPackage.NewOkay50.OuterClass50.InnerEnum50.ie50a, ic50);
    oc60.take(nspacemove_nestedPackage.OuterClass60.InnerEnum60.ie60a, ic60);
    oc70.take(nspacemove_nestedPackage.OuterClass70.InnerEnum70.ie70a, ic70);
    oc80.take(nspacemove_nestedPackage.Space.OuterClass80.InnerEnum80.ie80a, ic80);
  }
}
