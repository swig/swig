using System;

public class runme
{
    static void Main()
    {
      // constructors and destructors
      nspacemoveNamespace.Outer.Inner1.Color color1 = new nspacemoveNamespace.Outer.Inner1.Color();
      nspacemoveNamespace.Outer.Inner1.Color color = new nspacemoveNamespace.Outer.Inner1.Color(color1);
      color1.Dispose();
      color1 = null;

      // class methods
      color.colorInstanceMethod(20.0);
      nspacemoveNamespace.Outer.Inner1.Color.colorStaticMethod(20.0);
      nspacemoveNamespace.Outer.Inner1.Color created = nspacemoveNamespace.Outer.Inner1.Color.create();
      created.Dispose();

      // class enums
      nspacemoveNamespace.Outer.SomeClass someClass = new nspacemoveNamespace.Outer.SomeClass();
      nspacemoveNamespace.Outer.Inner1.Color.Channel channel = someClass.GetInner1ColorChannel();
      if (channel != nspacemoveNamespace.Outer.Inner1.Color.Channel.Transmission)
        throw new ApplicationException("Transmission wrong");

      // class anonymous enums
      int val1 = nspacemoveNamespace.Outer.Inner1.Color.ColorEnumVal1;
      int val2 = nspacemoveNamespace.Outer.Inner1.Color.ColorEnumVal2;
      if (val1 != 0 || val2 != 0x22)
        throw new ApplicationException("ColorEnumVal wrong");

      // instance member variables
      color.instanceMemberVariable = 123;
      if (color.instanceMemberVariable != 123)
        throw new ApplicationException("instance member variable failed");

      // static member variables
      nspacemoveNamespace.Outer.Inner1.Color.staticMemberVariable = 789;
      if (nspacemoveNamespace.Outer.Inner1.Color.staticMemberVariable != 789)
        throw new ApplicationException("static member variable failed");
      if (nspacemoveNamespace.Outer.Inner1.Color.staticConstMemberVariable != 222)
        throw new ApplicationException("static const member variable failed");
      if (nspacemoveNamespace.Outer.Inner1.Color.staticConstEnumMemberVariable != nspacemoveNamespace.Outer.Inner1.Color.Channel.Transmission)
        throw new ApplicationException("static const enum member variable failed");

      // check globals in a namespace don't get mangled with the nspacemoveNamespace option
      nspacemoveNamespace.nspacemove.namespaceFunction(color);
      nspacemoveNamespace.nspacemove.namespaceVar = 111;
      if (nspacemoveNamespace.nspacemove.namespaceVar != 111)
        throw new ApplicationException("global var failed");

      // Same class different namespaces
      nspacemoveNamespace.Outer.Inner1.Color col1 = new nspacemoveNamespace.Outer.Inner1.Color();
      nspacemoveNamespace.Outer.Inner2.Color col2 = nspacemoveNamespace.Outer.Inner2.Color.create();
      col2.colors(col1, col1, col2, col2, col2);

      // global enums
      nspacemoveNamespace.Outer.Inner1.Channel outerChannel1 = someClass.GetInner1Channel();
      if (outerChannel1 != nspacemoveNamespace.Outer.Inner1.Channel.Transmission1)
        throw new ApplicationException("Transmission1 wrong");
      nspacemoveNamespace.Outer.Inner2.Channel outerChannel2 = someClass.GetInner2Channel();
      if (outerChannel2 != nspacemoveNamespace.Outer.Inner2.Channel.Transmission2)
        throw new ApplicationException("Transmission2 wrong");

      // turn feature off / ignoring
      nspacemoveNamespace.Outer.namespce ns = new nspacemoveNamespace.Outer.namespce();
      ns.Dispose();
      nspacemoveNamespace.NoNSpacePlease nons = new nspacemoveNamespace.NoNSpacePlease();
      nons.Dispose();

      // Derived class
      nspacemoveNamespace.Outer.Inner3.Blue blue3 = new nspacemoveNamespace.Outer.Inner3.Blue();
      blue3.blueInstanceMethod();
      nspacemoveNamespace.Outer.Inner4.Blue blue4 = new nspacemoveNamespace.Outer.Inner4.Blue();
      blue4.blueInstanceMethod();
    }
}
