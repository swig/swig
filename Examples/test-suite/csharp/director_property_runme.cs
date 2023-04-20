using System;

namespace director_propertyNamespace {

public class runme
{
  static void Main()
  {
    {
      Foo a = new MyFoo();
      if (a.getA() != "") {
        throw new Exception( "Test failed" );
      }
      a.setA("Hello");
      if (a.getA() != "Hello set from MyFoo") {
        throw new Exception( "Test failed" );
      }
      a.setAByRef("Hello");
      if (a.getA() != "Hello setAByRef from MyFoo") {
        throw new Exception( "Test failed" );
      }
      a.Dispose();
    }

    {
      Foo a_original = new MyFoo();
      Foo a = Foo.get_self(a_original);
      if (a.getA() != "") {
        throw new Exception( "Test failed" );
      }
      a.setA("Hello");
      if (a.getA() != "Hello set from MyFoo") {
        throw new Exception( "Test failed" );
      }
      a.setAByRef("Hello");
      if (a.getA() != "Hello setAByRef from MyFoo") {
        throw new Exception( "Test failed" );
      }
      a.Dispose();
    }
  }
}

public class MyFoo : Foo
{
  public MyFoo()
    : base()
  {
  }

  public override void setA(string a)
  {
    base.setA(a + " set from MyFoo");
  }

  public override void setAByRef(string a)
  {
    base.setA(a + " setAByRef from MyFoo");
  }
}

}


