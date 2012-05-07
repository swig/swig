module director_protected_runme;

import director_protected.Foo;
import director_protected.Bar;

void main() {
  Bar b = new Bar();
  Foo f = b.create();
  auto fb = new FooBar();
  auto fb2 = new FooBar2();

  char[] s;
  s = fb.used();
  if ( s != ("Foo::pang();Bar::pong();Foo::pong();FooBar::ping();"))
    throw new Exception("bad FooBar::used" ~ " - " ~ s);

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

class FooBar : Bar {
protected:
  override char[] ping() {
    return "FooBar::ping();";
  }
}

class FooBar2 : Bar{
protected:
  override char[] ping() {
    return "FooBar2::ping();";
  }

  override char[] pang() {
    return "FooBar2::pang();";
  }
}
