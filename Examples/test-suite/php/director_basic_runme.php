<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('Foo','A','A1','Bar','MyClass','MyClassT_i','ConstPtrClass'));
// No new vars
check::globals(array());

class PhpFoo extends Foo {
  function ping() {
    return "PhpFoo::ping()";
  }
}

$a = new PhpFoo();

check::equal($a->ping(), "PhpFoo::ping()", "ping failed");

check::equal($a->pong(), "Foo::pong();PhpFoo::ping()", "pong failed");

$b = new Foo();

check::equal($b->ping(), "Foo::ping()", "ping failed");

check::equal($b->pong(), "Foo::pong();Foo::ping()", "pong failed");

$a = new A1(1);

check::equal($a->rg(2), 2, "rg failed");

class PhpClass extends MyClass {
  function vmethod($b) {
    $b->x = $b->x + 31;
    return $b;
  }
}

$b = new Bar(3);
$d = new MyClass();
$c = new PhpClass();

$cc = MyClass::get_self($c);
$dd = MyClass::get_self($d);

$bc = $cc->cmethod($b);
$bd = $dd->cmethod($b);

$cc->method($b);

check::equal($bc->x, 34, "bc failed");
check::equal($bd->x, 16, "bd failed");

check::done();
