using System;

namespace director_protectedNamespace {

public class runme
{
  static void Main() 
  {
    runme r = new runme();
    r.run();
  }

  void run()
  {
    Bar b  = new Bar();
    Foo f = b.create();
    FooBar fb = new FooBar();
    FooBar2 fb2 = new FooBar2();

    String s;
    s = fb.used();
    if ( s != ("Foo::pang();Bar::pong();Foo::pong();FooBar::ping();"))
      throw new Exception("bad FooBar::used" + " - " + s);

    s = fb2.used();
    if ( s != ("FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();"))
      throw new Exception("bad FooBar2::used");

    s = b.pong();
    if ( s != ("Bar::pong();Foo::pong();Bar::ping();"))
      throw new Exception("bad Bar::pong");

    s = f.pong();
    if ( s != ("Bar::pong();Foo::pong();Bar::ping();"))
      throw new Exception("bad Foo::pong");

    s = fb.pong();
    if ( s != ("Bar::pong();Foo::pong();FooBar::ping();"))
      throw new Exception("bad FooBar::pong");
  }
}

class FooBar : Bar
{
  public FooBar() : base()
  {
  }

  protected override String ping()
  {
    return "FooBar::ping();";
  }
}

class FooBar2 : Bar
{
  public FooBar2() : base()
  {
  }

  protected override String ping()
  {
    return "FooBar2::ping();";
  }

  protected override String pang()
  {
    return "FooBar2::pang();";
  }
}

}
