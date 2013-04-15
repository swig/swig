using director_smartptrNamespace;

public class runme
{

  private class director_smartptr_MyBarFoo : Foo
  {
    public override string ping()
    {
      return "director_smartptr_MyBarFoo.ping();";
    }

    public override string pong()
    {
      return "director_smartptr_MyBarFoo.pong();" + ping();
    }

    public override string fooBar(FooBar fooBar)
    {
      return fooBar.FooBarDo();
    }

    public override Foo makeFoo()
    {
      return new Foo();
    }

    public override FooBar makeFooBar()
    {
      return new FooBar();
    }
  }

  static void Main()
  {
    director_smartptr_MyBarFoo myBarFoo =
      new director_smartptr_MyBarFoo();

    myBarFoo.ping();
  }
}
