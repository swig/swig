var nspacemove_nested = require("nspacemove_nested");

// outer classes
var oc1 = new nspacemove_nested.Space.OuterClass1();
var oc2 = new nspacemove_nested.Space.OuterClass2();
var oc3 = new nspacemove_nested.NewSpace3.OuterClass3();
var oc4 = new nspacemove_nested.NewSpace4.OuterClass4();
var oc5 = new nspacemove_nested.OuterClass5();
var oc6 = new nspacemove_nested.OuterClass6();
var oc7 = new nspacemove_nested.OuterClass7();

var oc10 = new nspacemove_nested.Space.OuterClass10();
var oc20 = new nspacemove_nested.Space.OuterClass20();
var oc30 = new nspacemove_nested.NewOkay30.OuterClass30();
var oc40 = new nspacemove_nested.NewOkay40.OuterClass40();
var oc50 = new nspacemove_nested.NewOkay50.OuterClass50();
var oc60 = new nspacemove_nested.OuterClass60();
var oc70 = new nspacemove_nested.OuterClass70();
var oc80 = new nspacemove_nested.Space.OuterClass80();

// inner classes
var ic1 = new nspacemove_nested.Space.InnerClass1();
var ic2 = new nspacemove_nested.Space.InnerClass2();
var ic3 = new nspacemove_nested.NewSpace3.InnerClass3();
var ic4 = new nspacemove_nested.NewSpace4.InnerClass4();
var ic5 = new nspacemove_nested.InnerClass5();
var ic6 = new nspacemove_nested.InnerClass6();
var ic7 = new nspacemove_nested.InnerClass7();

var ic10 = new nspacemove_nested.Space.InnerClass10();
var ic20 = new nspacemove_nested.Space.InnerClass20();
var ic30 = new nspacemove_nested.NewOkay30.InnerClass30();
var ic40 = new nspacemove_nested.NewOkay40.InnerClass40();
var ic50 = new nspacemove_nested.NewOkay50.InnerClass50();
var ic60 = new nspacemove_nested.InnerClass60();
var ic70 = new nspacemove_nested.InnerClass70();
var ic80 = new nspacemove_nested.Space.InnerClass80();

// inner enums
/* await */ (oc1.take(nspacemove_nested.Space.OuterClass1.ie1a, ic1));
/* await */ (oc2.take(nspacemove_nested.Space.OuterClass2.ie2a, ic2));
/* await */ (oc3.take(nspacemove_nested.NewSpace3.OuterClass3.ie3a, ic3));
/* await */ (oc4.take(nspacemove_nested.NewSpace4.OuterClass4.ie4a, ic4));
/* await */ (oc5.take(nspacemove_nested.OuterClass5.ie5a, ic5));
/* await */ (oc6.take(nspacemove_nested.OuterClass6.ie6a, ic6));
/* await */ (oc7.take(nspacemove_nested.OuterClass7.ie7a, ic7));

/* await */ (oc10.take(nspacemove_nested.Space.OuterClass10.ie10a, ic10));
/* await */ (oc20.take(nspacemove_nested.Space.OuterClass20.ie20a, ic20));
/* await */ (oc30.take(nspacemove_nested.NewOkay30.OuterClass30.ie30a, ic30));
/* await */ (oc40.take(nspacemove_nested.NewOkay40.OuterClass40.ie40a, ic40));
/* await */ (oc50.take(nspacemove_nested.NewOkay50.OuterClass50.ie50a, ic50));
/* await */ (oc60.take(nspacemove_nested.OuterClass60.ie60a, ic60));
/* await */ (oc70.take(nspacemove_nested.OuterClass70.ie70a, ic70));
/* await */ (oc80.take(nspacemove_nested.Space.OuterClass80.ie80a, ic80));;
