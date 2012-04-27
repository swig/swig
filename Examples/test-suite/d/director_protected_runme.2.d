module director_protected_runme;

import std.exception;
import director_protected.Foo;
import director_protected.Bar;

void main() {
  Bar b = new Bar();
  Foo f = b.create();
  auto fb = new FooBar();
  scope fb2 = new FooBar2();

  enforce(fb.used() == "Foo::pang();Bar::pong();Foo::pong();FooBar::ping();", "bad FooBar::used" ~ " - " ~ fb.used());
  enforce(fb2.used() == "FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();", "bad FooBar2::used");
  enforce(b.pong() == "Bar::pong();Foo::pong();Bar::ping();", "bad Bar::pong");
  enforce(f.pong() == "Bar::pong();Foo::pong();Bar::ping();", "bad Foo::pong");
  enforce(fb.pong() == "Bar::pong();Foo::pong();FooBar::ping();", "bad FooBar::pong");
}

class FooBar : Bar {
protected:
  override string ping() {
    return "FooBar::ping();";
  }
}

class FooBar2 : Bar {
protected:
  override string ping() {
    return "FooBar2::ping();";
  }

  override string pang() {
    return "FooBar2::pang();";
  }
}
