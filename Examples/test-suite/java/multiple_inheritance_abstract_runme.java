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

  public static void main(String argv[]) {
    //Test Derived1
    Derived1 d1=new Derived1();
    if(d1.cbase1y()!=3)
      throw new RuntimeException("Derived1::cbase1y() failed in multiple_inheritance_abstract");
    if(d1.cbase2()!=4)
      throw new RuntimeException("Derived::cbase2() failed in multiple_inheritance_abstract");

    //Test Derived2
    Derived2 d2=new Derived2();
    if(d2.cbase1y()!=6)
      throw new RuntimeException("Derived2::cbase1y() failed in multiple_inheritance_abstract");
    if(d2.abase1()!=5)
      throw new RuntimeException("Derived2::abase1() failed in multiple_inheritance_abstract");

    //Test Derived3
    Derived3 d3=new Derived3();
    if( d3.cbase1y()!=7)
      throw new RuntimeException("Derived3::cbase1y() failed in multiple_inheritance_abstract");
    if(d3.cbase2()!=8)
      throw new RuntimeException("Derived3::cbase2() failed in multiple_inheritance_abstract");
    if(d3.abase1()!=9)
      throw new RuntimeException("Derived3::abase1() failed in multiple_inheritance_abstract");

    //Test interfaces from c++ classes 
    CBase1 cb1=new SWIGTYPE_CBase1();
    CBase2 cb2=new SWIGTYPE_CBase2();
    if(cb1.cbase1y()!=1)
      throw new RuntimeException("CBase1::cbase1y() failed in multiple_inheritance_abstract");
    if(cb2.cbase2()!=2)
      throw new RuntimeException("CBase2::cbase2() failed in multiple_inheritance_abstract");

    //Test abstract class as return value
    ABase1 ab1=d3.clone();
    if( ab1.abase1()!=9)
      throw new RuntimeException("Derived3::abase1() through ABase1 failed in multiple_inheritance_abstract");

    //Test concrete base class as return value
    CBase1 cb6=d2.clone();
    CBase2 cb7=d1.clone();
    if(cb6.cbase1y()!=6)
      throw new RuntimeException("Derived2::cbase1y() through CBase1 failed in multiple_inheritance_abstract");
    if(cb7.cbase2()!=4)
      throw new RuntimeException("Derived1:cbase2() through ABase1 failed in multiple_inheritance_abstract");

    //Test multi inheritance 
    CBase1 cb3=new Derived1();
    CBase1 cb4=new Derived3();
    CBase2 cb5=new Derived3();
    ABase1 ab6=new Derived2();
    if(cb3.cbase1y()!=3)
      throw new RuntimeException("Derived1::cbase1y()through CBase1 failed in multiple_inheritance_abstract");
    if(cb4.cbase1y()!=7)
      throw new RuntimeException("Derived3::cbase1y()through CBase1 failed in multiple_inheritance_abstract");
    if(cb5.cbase2()!=8)
      throw new RuntimeException("Derived3::cbase2()through CBase2 failed in multiple_inheritance_abstract");
    if(ab6.abase1()!=5)
      throw new RuntimeException("Derived2::abase1()through ABase1 failed in multiple_inheritance_abstract");  

    //Test base classes as parameter in java 
    multiple_inheritance_abstract_runme mhar=new multiple_inheritance_abstract_runme();
    if(mhar.jcbase1b(d1)!=3)
      throw new RuntimeException("jcbase1b()through Derived1 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jcbase1b(d2)!=6)
      throw new RuntimeException("jcbase1b()through Derived2 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jcbase1b(d3)!=7)
      throw new RuntimeException("jcbase1b()through Derived3 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jcbase2(d1)!=4)
      throw new RuntimeException("jcbase2()through Derived1 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jcbase2(d3)!=8)
      throw new RuntimeException("jcbase2()through Derived3 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jabase1(d2)!=5)
      throw new RuntimeException("jabase1()through Derived2 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jabase1(d3)!=9)
      throw new RuntimeException("jabase1()through Derived3 as parameter failed in multiple_inheritance_abstract");

    /*
    //Test ABase1 as a parameter
    if(multiple_inheritance_abstract.InputABase1(d2)!=5)
      throw new RuntimeException("InputABase1() through Derived2 as a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.InputABase1(d3)!=9)
      throw new RuntimeException("InputABase1() through Derived3 as a parameter failed in multiple_inheritance_abstract");

    //Test CBase1 CBase2 as parameters
    if(multiple_inheritance_abstract.InputCBase1(d3)!=7)
      throw new RuntimeException("InputCBase1() ,Derived3 as  a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.InputCBase1(d1)!=3)
      throw new RuntimeException("InputCBase1() ,Derived1 as  a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.InputCBase1(d2)!=6)
      throw new RuntimeException("InputCBase1() ,Derived3 as  a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.InputCBase2(d3)!=4)
      throw new RuntimeException("InputCBase2() ,Derived3 as  a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.InputCBase2(d1)!=8)
      throw new RuntimeException("InputCBase2() ,Derived1 as  a parameter failed in multiple_inheritance_abstract");
    */
  }
}
