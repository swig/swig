<?php

require "tests.php";
require "director_protected.php";

// No new functions
check::functions(array(foo_pong,foo_s,foo_q,foo_ping,foo_pang,foo_used,bar_create,bar_pong,bar_used,bar_ping,bar_pang,a_draw,b_draw));
// No new classes
check::classes(array(Foo,Bar,PrivateFoo,A,B,AA,BB));
// now new vars
check::globals(array(bar_a));

class FooBar extends Bar {
  protected function ping() {
    return "FooBar::ping();";
  }
}

class FooBar2 extends Bar {
  function ping() {
    return "FooBar2::ping();";
  }

  function pang() {
    return "FooBar2::pang();";
  }
}

$b = new Bar();
$f = $b->create();
$fb = new FooBar();
$fb2 = new FooBar2();

check::equal($fb->used(), "Foo::pang();Bar::pong();Foo::pong();FooBar::ping();", "bad FooBar::used");

check::equal($fb2->used(), "FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();", "bad FooBar2::used");

check::equal($b->pong(), "Bar::pong();Foo::pong();Bar::ping();", "bad Bar::pong");

check::equal($f->pong(), "Bar::pong();Foo::pong();Bar::ping();", "bad Foo::pong");

check::equal($fb->pong(), "Bar::pong();Foo::pong();FooBar::ping();", "bad FooBar::pong");

$method = new ReflectionMethod('Bar', 'ping');
check::equal($method->isProtected(), true, "Boo::ping should be protected");

$method = new ReflectionMethod('Foo', 'ping');
check::equal($method->isProtected(), true, "Foo::ping should be protected");

$method = new ReflectionMethod('FooBar', 'pang');
check::equal($method->isProtected(), true, "FooBar::pang should be protected");

check::done();
?>
