import multiple_inheritance_abstract.*;

public class multiple_inheritance_abstract_runme {

  static {
    try {
      System.loadLibrary("multiple_inheritance_abstract");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  //Test base class as a parameter in java
  int jcbase1b(CBase1 cb1){
    return cb1.cbase1y();
  }
  int jabase1(ABase1 ab1){
    return ab1.abase1();
  }
  int jcbase2(CBase2 cb2){
    return cb2.cbase2();
  }

  public static void check(boolean fail, String msg) {
    if (fail)
      throw new RuntimeException(msg);
  }

  public static void main(String argv[]) {
    //Test Derived1
    Derived1 d1=new Derived1();
    check(d1.cbase1y()!=3, "Derived1::cbase1y() failed in multiple_inheritance_abstract");
    check(d1.cbase2()!=4, "Derived1::cbase2() failed in multiple_inheritance_abstract");

    //Test Derived2
    Derived2 d2=new Derived2();
    check(d2.cbase1y()!=6, "Derived2::cbase1y() failed in multiple_inheritance_abstract");
    check(d2.abase1()!=5, "Derived2::abase1() failed in multiple_inheritance_abstract");

    //Test Derived3
    Derived3 d3=new Derived3();
    check(d3.cbase1y()!=7, "Derived3::cbase1y() failed in multiple_inheritance_abstract");
    check(d3.cbase2()!=8, "Derived3::cbase2() failed in multiple_inheritance_abstract");
    check(d3.abase1()!=9, "Derived3::abase1() failed in multiple_inheritance_abstract");

    //Test interfaces from c++ classes 
    CBase1 cb1=new SWIGTYPE_CBase1();
    CBase2 cb2=new SWIGTYPE_CBase2();
    check(cb1.cbase1y()!=1, "CBase1::cbase1y() failed in multiple_inheritance_abstract");
    check(cb2.cbase2()!=2, "CBase2::cbase2() failed in multiple_inheritance_abstract");

    //Test abstract class as return value
    ABase1 ab1=d3.clone();
    check(ab1.abase1()!=9, "Derived3::abase1() through ABase1 failed in multiple_inheritance_abstract");

    //Test concrete base class as return value
    CBase1 cb6=d2.clone();
    CBase2 cb7=d1.clone();
    check(cb6.cbase1y()!=6, "Derived2::cbase1y() through CBase1 failed in multiple_inheritance_abstract");
    check(cb7.cbase2()!=4, "Derived1:cbase2() through ABase1 failed in multiple_inheritance_abstract");

    //Test multi inheritance 
    CBase1 cb3=new Derived1();
    CBase1 cb4=new Derived3();
    CBase2 cb5=new Derived3();
    ABase1 ab6=new Derived2();
    check(cb3.cbase1y()!=3, "Derived1::cbase1y() through CBase1 failed in multiple_inheritance_abstract");
    check(cb4.cbase1y()!=7, "Derived3::cbase1y() through CBase1 failed in multiple_inheritance_abstract");
    check(cb5.cbase2()!=8, "Derived3::cbase2() through CBase2 failed in multiple_inheritance_abstract");
    check(ab6.abase1()!=5, "Derived2::abase1() through ABase1 failed in multiple_inheritance_abstract");  

    //Test base classes as parameter in java 
    multiple_inheritance_abstract_runme mhar=new multiple_inheritance_abstract_runme();
    check(mhar.jcbase1b(d1)!=3, "jcbase1b() through Derived1 as parameter failed in multiple_inheritance_abstract");
    check(mhar.jcbase1b(d2)!=6, "jcbase1b() through Derived2 as parameter failed in multiple_inheritance_abstract");
    check(mhar.jcbase1b(d3)!=7, "jcbase1b() through Derived3 as parameter failed in multiple_inheritance_abstract");
    check(mhar.jcbase2(d1)!=4, "jcbase2() through Derived1 as parameter failed in multiple_inheritance_abstract");
    check(mhar.jcbase2(d3)!=8, "jcbase2() through Derived3 as parameter failed in multiple_inheritance_abstract");
    check(mhar.jabase1(d2)!=5, "jabase1() through Derived2 as parameter failed in multiple_inheritance_abstract");
    check(mhar.jabase1(d3)!=9, "jabase1() through Derived3 as parameter failed in multiple_inheritance_abstract");

    //Value parameters
    //Test CBase1 CBase2 as parameters (note slicing for Derived1, Derived2 and Derived3)
    check(multiple_inheritance_abstract.InputValCBase1(d1)!=1, "InputValCBase1(), Derived1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputValCBase1(d2)!=1, "InputValCBase1(), Derived2 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputValCBase1(d3)!=1, "InputValCBase1(), Derived3 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputValCBase2(d3)!=2, "InputValCBase2(), Derived3 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputValCBase2(d1)!=2, "InputValCBase2(), Derived1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputValCBase1(cb1)!=1, "InputValCBase1(), CBase1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputValCBase2(cb2)!=2, "InputValCBase2(), CBase2 as a parameter failed in multiple_inheritance_abstract");

    //Pointer parameters
    //Test ABase1 as a parameter
    check(multiple_inheritance_abstract.InputPtrABase1(d2)!=5, "InputPtrABase1() through Derived2 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputPtrABase1(d3)!=9, "InputPtrABase1() through Derived3 as a parameter failed in multiple_inheritance_abstract");

    //Test CBase1 CBase2 as parameters
    check(multiple_inheritance_abstract.InputPtrCBase1(d1)!=3, "InputPtrCBase1(), Derived1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputPtrCBase1(d2)!=6, "InputPtrCBase1(), Derived2 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputPtrCBase1(d3)!=7, "InputPtrCBase1(), Derived3 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputPtrCBase2(d3)!=8, "InputPtrCBase2(), Derived3 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputPtrCBase2(d1)!=4, "InputPtrCBase2(), Derived1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputPtrCBase1(cb1)!=1, "InputPtrCBase1(), CBase1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputPtrCBase2(cb2)!=2, "InputPtrCBase2(), CBase2 as a parameter failed in multiple_inheritance_abstract");

    //Reference parameters
    //Test ABase1 as a parameter
    check(multiple_inheritance_abstract.InputRefABase1(d2)!=5, "InputRefABase1() through Derived2 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputRefABase1(d3)!=9, "InputRefABase1() through Derived3 as a parameter failed in multiple_inheritance_abstract");

    //Test CBase1 CBase2 as parameters
    check(multiple_inheritance_abstract.InputRefCBase1(d1)!=3, "InputRefCBase1(), Derived1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputRefCBase1(d2)!=6, "InputRefCBase1(), Derived2 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputRefCBase1(d3)!=7, "InputRefCBase1(), Derived3 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputRefCBase2(d3)!=8, "InputRefCBase2(), Derived3 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputRefCBase2(d1)!=4, "InputRefCBase2(), Derived1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputRefCBase1(cb1)!=1, "InputRefCBase1(), CBase1 as a parameter failed in multiple_inheritance_abstract");
    check(multiple_inheritance_abstract.InputRefCBase2(cb2)!=2, "InputRefCBase2(), CBase2 as a parameter failed in multiple_inheritance_abstract");

    //Derived classes as parameters
    check(multiple_inheritance_abstract.InputValDerived1(d1)!=3+4, "InputValDerived1() failed");
    check(multiple_inheritance_abstract.InputValDerived2(d2)!=6+5, "InputValDerived2() failed");
    check(multiple_inheritance_abstract.InputValDerived3(d3)!=7+8+9, "InputValDerived3() failed");

    check(multiple_inheritance_abstract.InputRefDerived1(d1)!=3+4, "InputRefDerived1() failed");
    check(multiple_inheritance_abstract.InputRefDerived2(d2)!=6+5, "InputRefDerived2() failed");
    check(multiple_inheritance_abstract.InputRefDerived3(d3)!=7+8+9, "InputRefDerived3() failed");

    check(multiple_inheritance_abstract.InputPtrDerived1(d1)!=3+4, "InputPtrDerived1() failed");
    check(multiple_inheritance_abstract.InputPtrDerived2(d2)!=6+5, "InputPtrDerived2() failed");
    check(multiple_inheritance_abstract.InputPtrDerived3(d3)!=7+8+9, "InputPtrDerived3() failed");

    // Factory functions
    check(multiple_inheritance_abstract.MakeDerived1_CBase1().cbase1y()!=3, "MakeDerived1_CBase1 failed");
    check(multiple_inheritance_abstract.MakeDerived1_CBase2().cbase2()!=4, "MakeDerived1_CBase2 failed");
    check(multiple_inheritance_abstract.MakeDerived2_CBase1().cbase1y()!=6, "MakeDerived2_CBase1 failed");
    check(multiple_inheritance_abstract.MakeDerived2_ABase1().abase1()!=5, "MakeDerived2_ABase1 failed");
    check(multiple_inheritance_abstract.MakeDerived3_ABase1().abase1()!=9, "MakeDerived3_ABase1 failed");
    check(multiple_inheritance_abstract.MakeDerived3_CBase1().cbase1y()!=7, "MakeDerived3_CBase1 failed");
    check(multiple_inheritance_abstract.MakeDerived3_CBase2().cbase2()!=8, "MakeDerived3_CBase2 failed");
  }
}
