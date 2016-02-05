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
  int jfoo1(CBase1 cb1){
    return cb1.foo1();
  }
  int jbar1(ABase1 ab1){
    return ab1.bar1();
  }
  int jfoo2(CBase2 cb2){
    return cb2.foo2();
  }

  public static void main(String argv[]) {
    //Test Derived1
    Derived1 d1=new Derived1();
    if(d1.foo1()!=3)
      throw new RuntimeException("Derived1::foo1() failed in multiple_inheritance_abstract");
    if(d1.foo2()!=4)
      throw new RuntimeException("Derived::foo2() failed in multiple_inheritance_abstract");

    //Test Derived2
    Derived2 d2=new Derived2();
    if(d2.foo1()!=6)
      throw new RuntimeException("Derived2::foo1() failed in multiple_inheritance_abstract");
    if(d2.bar1()!=5)
      throw new RuntimeException("Derived2::bar1() failed in multiple_inheritance_abstract");

    //Test Derived3
    Derived3 d3=new Derived3();
    if( d3.foo1()!=7)
      throw new RuntimeException("Derived3::foo1() failed in multiple_inheritance_abstract");
    if(d3.foo2()!=8)
      throw new RuntimeException("Derived3::foo2() failed in multiple_inheritance_abstract");
    if(d3.bar1()!=9)
      throw new RuntimeException("Derived3::bar1() failed in multiple_inheritance_abstract");

    //Test interfaces from c++ classes 
    CBase1 cb1=new SWIGTYPE_CBase1();
    CBase2 cb2=new SWIGTYPE_CBase2();
    if(cb1.foo1()!=1)
      throw new RuntimeException("CBase1::foo1() failed in multiple_inheritance_abstract");
    if(cb2.foo2()!=2)
      throw new RuntimeException("CBase2::foo2() failed in multiple_inheritance_abstract");

    //Test abstract class as return value
    ABase1 ab1=d3.clone();
    if( ab1.bar1()!=9)
      throw new RuntimeException("Derived3::bar1() through ABase1 failed in multiple_inheritance_abstract");

    //Test concrete base class as return value
    CBase1 cb6=d2.clone();
    CBase2 cb7=d1.clone();
    if(cb6.foo1()!=6)
      throw new RuntimeException("Derived2::foo1() through CBase1 failed in multiple_inheritance_abstract");
    if(cb7.foo2()!=4)
      throw new RuntimeException("Derived1:foo2() through ABase1 failed in multiple_inheritance_abstract");

    //Test multi inheritance 
    CBase1 cb3=new Derived1();
    CBase1 cb4=new Derived3();
    CBase2 cb5=new Derived3();
    ABase1 ab6=new Derived2();
    if(cb3.foo1()!=3)
      throw new RuntimeException("Derived1::foo1()through CBase1 failed in multiple_inheritance_abstract");
    if(cb4.foo1()!=7)
      throw new RuntimeException("Derived3::foo1()through CBase1 failed in multiple_inheritance_abstract");
    if(cb5.foo2()!=8)
      throw new RuntimeException("Derived3::foo2()through CBase2 failed in multiple_inheritance_abstract");
    if(ab6.bar1()!=5)
      throw new RuntimeException("Derived2::bar1()through ABase1 failed in multiple_inheritance_abstract");  

    //Test base classes as parameter in java 
    multiple_inheritance_abstract_runme mhar=new multiple_inheritance_abstract_runme();
    if(mhar.jfoo1(d1)!=3)
      throw new RuntimeException("jfoo1()through Derived1 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jfoo1(d2)!=6)
      throw new RuntimeException("jfoo1()through Derived2 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jfoo1(d3)!=7)
      throw new RuntimeException("jfoo1()through Derived3 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jfoo2(d1)!=4)
      throw new RuntimeException("jfoo2()through Derived1 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jfoo2(d3)!=8)
      throw new RuntimeException("jfoo2()through Derived3 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jbar1(d2)!=5)
      throw new RuntimeException("jbar1()through Derived2 as parameter failed in multiple_inheritance_abstract");
    if(mhar.jbar1(d3)!=9)
      throw new RuntimeException("jbar1()through Derived3 as parameter failed in multiple_inheritance_abstract");

    /*
    //Test ABase1 as a parameter
    if(multiple_inheritance_abstract.foo6(d2)!=5)
      throw new RuntimeException("foo6() through Derived2 as a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.foo6(d3)!=9)
      throw new RuntimeException("foo6() through Derived3 as a parameter failed in multiple_inheritance_abstract");

    //Test CBase1 CBase2 as parameters
    if(multiple_inheritance_abstract.foo7(d3)!=7)
      throw new RuntimeException("foo7() ,Derived3 as  a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.foo7(d1)!=3)
      throw new RuntimeException("foo7() ,Derived1 as  a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.foo7(d2)!=6)
      throw new RuntimeException("foo7() ,Derived3 as  a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.foo8(d3)!=4)
      throw new RuntimeException("foo8() ,Derived3 as  a parameter failed in multiple_inheritance_abstract");
    if(multiple_inheritance_abstract.foo8(d1)!=8)
      throw new RuntimeException("foo8() ,Derived1 as  a parameter failed in multiple_inheritance_abstract");
    */
  }
}
