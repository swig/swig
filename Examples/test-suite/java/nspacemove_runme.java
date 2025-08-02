// This tests changes the package name from nspace to nspacePackage as javac can't seem to resolve classes and packages having the same name
public class nspacemove_runme {

  static {
    try {
	System.loadLibrary("nspacemove");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // constructors and destructors
    nspacemovePackage.Ooter.Extra.Inner1.Color color1 = new nspacemovePackage.Ooter.Extra.Inner1.Color();
    nspacemovePackage.Ooter.Extra.Inner1.Color color = new nspacemovePackage.Ooter.Extra.Inner1.Color(color1);
    color1.delete();
    color1 = null;

    // class methods
    color.colorInstanceMethod(20.0);
    nspacemovePackage.Ooter.Extra.Inner1.Color.colorStaticMethod(20.0);
    nspacemovePackage.Ooter.Extra.Inner1.Color created = nspacemovePackage.Ooter.Extra.Inner1.Color.create();

    // class enums
    nspacemovePackage.Outer.SomeClass someClass = new nspacemovePackage.Outer.SomeClass();
    nspacemovePackage.Ooter.Extra.Inner1.Color.Channel channel = someClass.GetInner1ColorChannel();
    if (channel != nspacemovePackage.Ooter.Extra.Inner1.Color.Channel.Transmission)
      throw new RuntimeException("Transmission wrong");

    // class anonymous enums
    int val1 = nspacemovePackage.Ooter.Extra.Inner1.Color.ColorEnumVal1;
    int val2 = nspacemovePackage.Ooter.Extra.Inner1.Color.ColorEnumVal2;
    if (val1 != 0 || val2 != 0x22)
      throw new RuntimeException("ColorEnumVal wrong");

    // instance member variables
    color.setInstanceMemberVariable(123);
    if (color.getInstanceMemberVariable() != 123)
      throw new RuntimeException("instance member variable failed");

    // static member variables
    nspacemovePackage.Ooter.Extra.Inner1.Color.setStaticMemberVariable(789);
    if (nspacemovePackage.Ooter.Extra.Inner1.Color.getStaticMemberVariable() != 789)
      throw new RuntimeException("static member variable failed");
    if (nspacemovePackage.Ooter.Extra.Inner1.Color.staticConstMemberVariable != 222)
      throw new RuntimeException("static const member variable failed");
    if (nspacemovePackage.Ooter.Extra.Inner1.Color.staticConstEnumMemberVariable != nspacemovePackage.Ooter.Extra.Inner1.Color.Channel.Transmission)
      throw new RuntimeException("static const enum member variable failed");

    // Same class different namespaces
    nspacemovePackage.Ooter.Extra.Inner1.Color col1 = new nspacemovePackage.Ooter.Extra.Inner1.Color();
    nspacemovePackage.Outer.Snner2.Color col2 = nspacemovePackage.Outer.Snner2.Color.create();
    col2.colors(col1, col1, col2, col2, col2);

    // check globals in a namespace don't get mangled with the nspacemovePackage option
    nspacemovePackage.nspacemove.namespaceFunction(color);
    nspacemovePackage.nspacemove.setNamespaceVar(111);
    if (nspacemovePackage.nspacemove.getNamespaceVar() != 111)
      throw new RuntimeException("global var failed");

    // global enums
    nspacemovePackage.Euter.Extra.Inner1.Channel outerChannel1 = someClass.GetInner1Channel();
    if (outerChannel1 != nspacemovePackage.Euter.Extra.Inner1.Channel.Transmission1)
      throw new RuntimeException("Transmission1 wrong");
    nspacemovePackage.Outer.Enner2.Channel outerChannel2 = someClass.GetInner2Channel();
    if (outerChannel2 != nspacemovePackage.Outer.Enner2.Channel.Transmission2)
      throw new RuntimeException("Transmission2 wrong");

    nspacemovePackage.nspacemove.takeGlobalEnum(nspacemovePackage.More.GlobalEnum.bbb);

    // global class
    nspacemovePackage.Additional.GlobalClass gc = new nspacemovePackage.Additional.GlobalClass();
    gc.gmethod();

    // turn feature off / ignoring
    nspacemovePackage.Outer.namespce ns = new nspacemovePackage.Outer.namespce();
    nspacemovePackage.NoNSpacePlease nons = new nspacemovePackage.NoNSpacePlease();

    // Derived class
    nspacemovePackage.Outer.Inner3.Blue blue3 = new nspacemovePackage.Outer.Inner3.Blue();
    blue3.blueInstanceMethod();
    nspacemovePackage.Outer.Inner4.Blue blue4 = new nspacemovePackage.Outer.Inner4.Blue();
    blue4.blueInstanceMethod();
  }
}
