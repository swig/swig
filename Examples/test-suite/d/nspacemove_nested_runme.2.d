module nspacemove_nested_runme;

import std.exception;
import nspacemove_nested.nspacemove_nested;
static import nspacemove_nested.Space.OuterClass1;
static import nspacemove_nested.Space.OuterClass2;
static import nspacemove_nested.NewSpace3.OuterClass3;
static import nspacemove_nested.NewSpace4.OuterClass4;
static import nspacemove_nested.OuterClass5;
static import nspacemove_nested.OuterClass6;
static import nspacemove_nested.OuterClass7;
static import nspacemove_nested.Space.OuterClass10;
static import nspacemove_nested.Space.OuterClass20;
static import nspacemove_nested.NewOkay30.OuterClass30;
static import nspacemove_nested.NewOkay40.OuterClass40;
static import nspacemove_nested.NewOkay50.OuterClass50;
static import nspacemove_nested.OuterClass60;
static import nspacemove_nested.OuterClass70;
static import nspacemove_nested.Space.OuterClass80;

void main() {
  // outer classes
  auto oc1 = new nspacemove_nested.Space.OuterClass1.OuterClass1();
  auto oc2 = new nspacemove_nested.Space.OuterClass2.OuterClass2();
  auto oc3 = new nspacemove_nested.NewSpace3.OuterClass3.OuterClass3();
  auto oc4 = new nspacemove_nested.NewSpace4.OuterClass4.OuterClass4();
  auto oc5 = new nspacemove_nested.OuterClass5.OuterClass5();
  auto oc6 = new nspacemove_nested.OuterClass6.OuterClass6();
  auto oc7 = new nspacemove_nested.OuterClass7.OuterClass7();

  auto oc10 = new nspacemove_nested.Space.OuterClass10.OuterClass10();
  auto oc20 = new nspacemove_nested.Space.OuterClass20.OuterClass20();
  auto oc30 = new nspacemove_nested.NewOkay30.OuterClass30.OuterClass30();
  auto oc40 = new nspacemove_nested.NewOkay40.OuterClass40.OuterClass40();
  auto oc50 = new nspacemove_nested.NewOkay50.OuterClass50.OuterClass50();
  auto oc60 = new nspacemove_nested.OuterClass60.OuterClass60();
  auto oc70 = new nspacemove_nested.OuterClass70.OuterClass70();
  auto oc80 = new nspacemove_nested.Space.OuterClass80.OuterClass80();

  // inner classes
  auto ic1 = new nspacemove_nested.Space.InnerClass1.InnerClass1();
  auto ic2 = new nspacemove_nested.Space.InnerClass2.InnerClass2();
  auto ic3 = new nspacemove_nested.NewSpace3.InnerClass3.InnerClass3();
  auto ic4 = new nspacemove_nested.NewSpace4.InnerClass4.InnerClass4();
  auto ic5 = new nspacemove_nested.InnerClass5.InnerClass5();
  auto ic6 = new nspacemove_nested.InnerClass6.InnerClass6();
  auto ic7 = new nspacemove_nested.InnerClass7.InnerClass7();

  auto ic10 = new nspacemove_nested.Space.InnerClass10.InnerClass10();
  auto ic20 = new nspacemove_nested.Space.InnerClass20.InnerClass20();
  auto ic30 = new nspacemove_nested.NewOkay30.InnerClass30.InnerClass30();
  auto ic40 = new nspacemove_nested.NewOkay40.InnerClass40.InnerClass40();
  auto ic50 = new nspacemove_nested.NewOkay50.InnerClass50.InnerClass50();
  auto ic60 = new nspacemove_nested.InnerClass60.InnerClass60();
  auto ic70 = new nspacemove_nested.InnerClass70.InnerClass70();
  auto ic80 = new nspacemove_nested.Space.InnerClass80.InnerClass80();

  // inner enums
  oc1.take(nspacemove_nested.Space.OuterClass1.OuterClass1.InnerEnum1.ie1a, ic1);
  oc2.take(nspacemove_nested.Space.OuterClass2.OuterClass2.InnerEnum2.ie2a, ic2);
  oc3.take(nspacemove_nested.NewSpace3.OuterClass3.OuterClass3.InnerEnum3.ie3a, ic3);
  oc4.take(nspacemove_nested.NewSpace4.OuterClass4.OuterClass4.InnerEnum4.ie4a, ic4);
  oc5.take(nspacemove_nested.OuterClass5.OuterClass5.InnerEnum5.ie5a, ic5);
  oc6.take(nspacemove_nested.OuterClass6.OuterClass6.InnerEnum6.ie6a, ic6);
  oc7.take(nspacemove_nested.OuterClass7.OuterClass7.InnerEnum7.ie7a, ic7);

  oc10.take(nspacemove_nested.Space.OuterClass10.OuterClass10.InnerEnum10.ie10a, ic10);
  oc20.take(nspacemove_nested.Space.OuterClass20.OuterClass20.InnerEnum20.ie20a, ic20);
  oc30.take(nspacemove_nested.NewOkay30.OuterClass30.OuterClass30.InnerEnum30.ie30a, ic30);
  oc40.take(nspacemove_nested.NewOkay40.OuterClass40.OuterClass40.InnerEnum40.ie40a, ic40);
  oc50.take(nspacemove_nested.NewOkay50.OuterClass50.OuterClass50.InnerEnum50.ie50a, ic50);
  oc60.take(nspacemove_nested.OuterClass60.OuterClass60.InnerEnum60.ie60a, ic60);
  oc70.take(nspacemove_nested.OuterClass70.OuterClass70.InnerEnum70.ie70a, ic70);
  oc80.take(nspacemove_nested.Space.OuterClass80.OuterClass80.InnerEnum80.ie80a, ic80);
}
