<?php
require "tests.php";

// New functions
check::functions(array('doublevalue1','doublevalue2','seek','seek2','seek3','seek4','seek5','seek6','seek7','seek8','seek9','seeka','seekb','anonymous','booltest','casts1','casts2','chartest1','chartest2','chartest3','chartest4','chartest5','chartest6','dummy','afunction','reftest1','reftest2','chops','exceptionspec','constructorcall','cfunc1','cfunc2','cfunc3','slightly_off_square'));
// New classes
check::classes(array('TrickyInPython','default_args','EnumClass','DerivedEnumClass','Tree','Foo','MyClass1','MyClass2','Except','Statics','Tricky','Klass','ConstMethods','Pointf','CDA'));
// New vars
check::globals(array('CONST_NUM'));

$ec = new EnumClass();
check::equal($ec->blah(), true, "EnumClass::blah() default arguments don't work");

$de = new DerivedEnumClass();
$de->accelerate();
$de->accelerate(EnumClass::SLOW);

check::equal(Statics::staticMethod(), 60, "Statics::staticMethod()");

check::equal(cfunc1(1), 2.0, "cfunc1(1)");

check::equal(cfunc2(1), 3.0, "cfunc2(1)");

check::equal(cfunc3(1), 4.0, "cfunc3(1)");

$f = new Foo();

$f->newname();
$f->newname(1);
$f->defaulted1();
$f->defaulted2();

check::equal($f->double_if_void_ptr_is_null(2, Null), 4, "\$f->double_if_void_ptr_is_null(2, Null)");

check::equal($f->double_if_void_ptr_is_null(3), 6, "\$f->double_if_void_ptr_is_null(3)");

check::equal($f->double_if_void_ptr_is_null(4, Null), 8, "\$f->double_if_void_ptr_is_null(4, Null)");

check::equal($f->double_if_void_ptr_is_null(5, Null), 10, "\$f->double_if_void_ptr_is_null(5, Null)");

check::equal($f->double_if_void_ptr_is_null(6, Null), 12, "\$f->double_if_void_ptr_is_null(6, Null)");

check::equal($f->double_if_void_ptr_is_null(7), 14, "\$f->double_if_void_ptr_is_null(7)");

# For the testcases below, PHP 7 emits an error, while PHP 8 throws an
# exception.  To simplify the testcases we install an error handler function
# for PHP7 which throws an ArgumentCountError exception (which we have to
# define ourselves for PHP 7.0).

if (PHP_MAJOR_VERSION == 7) {
  if (PHP_MINOR_VERSION == 0) {
    # ArgumentCountError was added in PHP 7.1.
    class ArgumentCountError extends Error {}
  }
  $old_error_handler = set_error_handler(function($n,$s,$f,$l){throw preg_match('/^Wrong parameter count/', $s) ? new ArgumentCountError($s) : new Error($s);});
}

try {
    $f = new Foo(1);
    check::fail("Foo::Foo ignore is not working");
} catch (ArgumentCountError $e) {
}

try {
    $f = new Foo(1, 2);
    check::fail("Foo::Foo ignore is not working");
} catch (ArgumentCountError $e) {
}

try {
    $f = new Foo(1, 2, 3);
    check::fail("Foo::Foo ignore is not working");
} catch (ArgumentCountError $e) {
}

try {
    $m = $f->meth(1);
    check::fail("Foo::meth ignore is not working");
} catch (Error $e) {
}

try {
    $m = $f->meth(1, 2);
    check::fail("Foo::meth ignore is not working");
} catch (Error $e) {
}

try {
    $m = $f->meth(1, 2, 3);
    check::fail("Foo::meth ignore is not working");
} catch (Error $e) {
}

if (PHP_MAJOR_VERSION == 7) {
  set_error_handler($old_error_handler);
}

check::equal(Klass::inc(100, new Klass(22))->val, 122, "Klass::inc failed");

check::equal(klass::inc(100)->val, 99, "klass::inc failed");

check::equal(klass::inc()->val, 0, "klass::inc failed");

$tricky = new TrickyInPython();
check::equal($tricky->value_m1(10), -1, "trickyvalue_m1 failed");
check::equal($tricky->value_m1(10, 10), 10, "trickyvalue_m1 failed");
check::equal($tricky->value_0xabcdef(10), 0xabcdef, "trickyvalue_0xabcdef failed");
check::equal($tricky->value_0644(10), 420, "trickyvalue_0644 failed");
check::equal($tricky->value_perm(10), 420, "trickyvalue_perm failed");
check::equal($tricky->value_m01(10), -1, "trickyvalue_m01 failed");
check::equal($tricky->booltest2(), True, "booltest2 failed");

check::equal($tricky->max_32bit_int1(), 0x7FFFFFFF, "max_32bit_int1 failed");
// On 32-bit platforms -2147483648 is a PHP float (rather than
// PHP int on 64-bit platforms) so only check equivalence rather
// than strict equality.
check::equivalent($tricky->min_32bit_int1(), -2147483648, "min_32bit_int1 failed");
check::equal($tricky->max_32bit_int2(), 0x7FFFFFFF, "max_32bit_int2 failed");

$tricky->too_big_32bit_int1();
$tricky->too_small_32bit_int1();
$tricky->too_big_32bit_int2();
$tricky->too_small_32bit_int2();

seek();
seek(10);

check::equal(booltest(), True, "booltest failed");

check::equal(slightly_off_square(10), 102, "slightly_off_square(10)");

check::equal(slightly_off_square(), 291, "slightly_off_square()");

check::equal(chartest1(), "x", "chartest1()");

check::equal(chartest2(), "\0", "chartest2()");

check::equal(chartest3(), "\1", "chartest3()");

check::equal(chartest4(), "\n", "chartest4()");

check::equal(chartest5(), "B", "chartest5()");

check::equal(chartest6(), "C", "chartest6()");

if (PHP_MAJOR_VERSION >= 8) {
  // Regression test for bug in initial implementation of PHP type declarations.
  $p = (new ReflectionMethod('TrickyInPython', 'value_m1'))->getParameters();
  // empty array in buggy version
  check::equal(count($p), 2, "Expected 2 parameters");
  check::equal((string)$p[0]->getType(), 'int', "Expected int parameter");
  check::equal((string)$p[1]->getType(), 'int', "Expected int parameter");

  $p = (new ReflectionMethod('EnumClass', 'blah'))->getParameters();
  // empty array in buggy version
  check::equal(count($p), 2, "Expected 2 parameters");
  check::equal((string)$p[0]->getType(), 'int', "Expected int parameter");
  check::equal((string)$p[1]->getType(), 'int', "Expected int parameter");
}

check::done();
