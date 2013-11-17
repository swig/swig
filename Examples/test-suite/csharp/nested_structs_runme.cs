using System;
using nested_structsNamespace;

public class runme {
  static void Main() {
    Outer outer = new Outer();
    nested_structs.setValues(outer, 10);

    Outer_inner1 inner1 = outer.Inner1;
    Outer_inner1 inner2 = outer.Inner2;
    Outer_inner1 inner3 = outer.Inner3;
    Outer_inner1 inner4 = outer.Inner4;
    if (inner1.val != 10) throw new Exception("failed inner1");
    if (inner2.val != 20) throw new Exception("failed inner2");
    if (inner3.val != 20) throw new Exception("failed inner3");
    if (inner4.val != 40) throw new Exception("failed inner4");

    Named inside1 = outer.Inside1;
    Named inside2 = outer.Inside2;
    Named inside3 = outer.Inside3;
    Named inside4 = outer.Inside4;
    if (inside1.val != 100) throw new Exception("failed inside1");
    if (inside2.val != 200) throw new Exception("failed inside2");
    if (inside3.val != 200) throw new Exception("failed inside3");
    if (inside4.val != 400) throw new Exception("failed inside4");
  }
}
