<?php

require "tests.php";

// New functions
check::functions(array());
// New classes
check::classes(array('cpp_enum', 'StructWithEnums', 'Foo'));
// New vars
check::globals(array('hi'));


$f = new Foo();

check::equal($f->hola, Foo::Hello);

$f->hola = Foo::Hi;
check::equal($f->hola, Foo::Hi);

$f->hola = Foo::Hello;
check::equal($f->hola, Foo::Hello);

$hi = Hello;
check::equal($hi, Hello);

check::equal(CASE0A, 10);
check::equal(CASE0B, 10);
check::equal(CASE0C, 10);
check::equal(CASE1A, 10);
check::equal(CASE1B, 10);
check::equal(CASE1C, 10);
check::equal(CASE2A, 10);
check::equal(CASE2B, 10);
check::equal(CASE2C, 10);
check::equal(CASE3A, 10);
check::equal(CASE3B, 10);
check::equal(CASE3C, 10);
check::equal(CASE4A, 10);
check::equal(CASE4B, 10);
check::equal(CASE4C, 10);
check::equal(CASE4D, 10);

check::done();
