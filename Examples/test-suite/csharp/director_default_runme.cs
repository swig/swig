using System;

namespace director_defaultNamespace {

public class runme
{
  static void Main()
  {
    {
      MyFoo a = new MyFoo();
      a = new MyFoo(10);
      a.Dispose();
    }

    {
      MyFoo a = new MyFoo();
      if (a.GetMsg() != "MyFoo-default") {
        throw new Exception( "Test 1 failed" );
      }
      if (a.GetMsg("boo") != "MyFoo-boo") {
        throw new Exception( "Test 2 failed" );
      }
      a.Dispose();
    }

    {
      Foo b = new Foo();
      if (b.GetMsg() != "Foo-default") {
        throw new Exception( "Test 1 failed" );
      }
      if (b.GetMsg("boo") != "Foo-boo") {
        throw new Exception( "Test 2 failed" );
      }
      b.Dispose();
    }
  }
}

public class MyFoo : Foo
{
  public MyFoo()
    : base()
  {
  }

  public MyFoo(int i)
    : base(i)
  {
  }

  public override string Msg(string msg)
  {
    return "MyFoo-" + msg;
  }
}

}

