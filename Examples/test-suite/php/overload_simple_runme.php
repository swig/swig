<?php
require "tests.php";

check::functions(array('foo','blah','fbool','fint','fdouble','num','fid','ull','ll','malloc_void','free_void','int_object'));
check::classes(array('Foo','Bar','overload_simple','Spam','ClassA'));
// No new vars
check::globals(array());

$f = new Foo();
check::classname("Foo", $f);
$b = new Bar();
check::classname("Bar", $b);
$v = overload_simple::malloc_void(32);
check::classname("SWIG\_p_void", $v);

#
# 'simple' dispatch (no overload) of int and double arguments
#

check::equal(overload_simple::fint(3), "fint:int", "fint(int) - int");

check::equal(overload_simple::fint("1"), "fint:int", "fint(int) - string int");

check::equal(overload_simple::fint(3.0), "fint:int", "fint(int) - double");

check::equal(overload_simple::fint("3.0"), "fint:int", "fint(int) - string double");

# Test handling of cases which aren't simple numbers.

check::equal(overload_simple::fint("l"), "fint:int", "fint(int) - int");

check::equal(overload_simple::fdouble("l"), "fdouble:double", "fint(double) - int");

check::equal(overload_simple::fdouble("1.5/2.0"), "fdouble:double", "fint(double) - double");

# adapted from Perl regression testcase
$n = 3;
$n = $n + 1;
check::equal(overload_simple::fint($n), "fint:int", "fint(int) - int var");

check::equal(overload_simple::fint(4/2), "fint:int", "fint(int) - divide int denom");

check::equal(overload_simple::fint(4/2.0), "fint:int", "fint(int) - divide double denom");

check::equal(overload_simple::fdouble(3), "fdouble:double", "fdouble(double) - int");

check::equal(overload_simple::fdouble("3"), "fdouble:double", "fdouble(double) - string int");

check::equal(overload_simple::fdouble(3.0), "fdouble:double", "fdouble(double) - double");

check::equal(overload_simple::fdouble("3.0"), "fdouble:double", "fdouble(double) - string doubl");

#
# Overload between int and double
#
check::equal(overload_simple::num(3), "num:int", "num(int) - int");

check::equal(overload_simple::num(3.0), "num:double", "num(int) - double");

#
# Overload between int, double, char * and many types.
#
check::equal(overload_simple::foo(3), "foo:int", "foo:int - int");

check::equal(overload_simple::foo(3.0), "foo:double", "foo:double - double");

check::equal(overload_simple::foo("3"), "foo:char *", "foo:char * - string int");

check::equal(overload_simple::foo("3.0"), "foo:char *", "foo:char * - string double");

check::equal(overload_simple::foo("hello"), "foo:char *", "foo:char * string");

check::equal(overload_simple::foo($f), "foo:Foo *", "foo:Foo *");

check::equal(overload_simple::foo($b), "foo:Bar *", "foo:Bar *");

check::equal(overload_simple::foo($v), "foo:void *", "foo:void *");

check::equal(overload_simple::blah("hello"), "blah:char *", "blah:char *");

$s = new Spam();

check::equal($s->foo(3), "foo:int", "Spam::foo:int");

check::equal($s->foo(3.0), "foo:double", "Spam::foo(double)");

check::equal($s->foo("hello"), "foo:char *", "Spam::foo:char *");

check::equal($s->foo($f), "foo:Foo *", "Spam::foo(Foo *)");

check::equal($s->foo($b), "foo:Bar *", "Spam::foo(Bar *)");

check::equal($s->foo($v), "foo:void *", "Spam::foo(void *)");

check::equal(Spam::bar(3), "bar:int", "Spam::bar(int)");

check::equal(Spam::bar(3.0), "bar:double", "Spam::bar(double)");

check::equal(Spam::bar("hello"), "bar:char *", "Spam::bar(char *)");

check::equal(Spam::bar($f), "bar:Foo *", "Spam::bar(Foo *)");

check::equal(Spam::bar($b), "bar:Bar *", "Spam::bar(Bar *)");

check::equal(Spam::bar($v), "bar:void *", "Spam::bar(void *)");

# Test constructors

$s = new Spam();
check::is_a($s, "spam");

check::equal($s->type, "none", "Spam()");

$s = new Spam(3);
check::is_a($s, "spam");

check::equal($s->type, "int", "Spam(int)");

$s = new Spam(3.0);
check::is_a($s, "spam");
check::equal($s->type, "double", "Spam(double)");

$s = new Spam("hello");
check::is_a($s, "spam");
check::equal($s->type, "char *", "Spam(char *)");

$s = new Spam($f);
check::is_a($s, "spam");
check::equal($s->type, "Foo *", "Spam(Foo *)");

$s = new Spam($b);
check::is_a($s, "spam");
check::equal($s->type, "Bar *", "Spam(Bar *)");

$s = new Spam($v);
check::is_a($s, "spam");
check::equal($s->type, "void *", "Spam(void *)");

#
# Combine dispatch
#

check::equal(overload_simple::fid(3, 3.0), "fid:intdouble", "fid(int,double)");

check::equal(overload_simple::fid(3.0, 3), "fid:doubleint", "fid(double,int)");

check::equal(overload_simple::fid(3.0, 3.0), "fid:doubledouble", "fid(double,double)");

check::equal(overload_simple::fid(3, 3), "fid:intint", "fid(int,int)");

check::equal(false, overload_simple::fbool(false), "fbool(bool)");
check::equal(true, overload_simple::fbool(true), "fbool(bool)");
check::equal(2, overload_simple::fbool(2), "fbool(int)");

# int and object overload

check::equal(overload_simple::int_object(1), 1, "int_object(1)");
check::equal(overload_simple::int_object(0), 0, "int_object(0)");
check::equal(overload_simple::int_object(NULL), 999, "int_object(Spam*)");
check::equal(overload_simple::int_object($s), 999, "int_object(Spam*)");

function check($args, $want) {
  if ($want === NULL) {
    try {
      eval("return Spam::bar($args);");
      check::fail("Expected exception");
    } catch (TypeError $e) {
      check::equal(substr($e->getMessage(), 0, 35), "No matching function for overloaded", "Not the expected I expected");
    }
    return;
  }
  check::equal(eval("return Spam::bar($args);"), "bar:$want", "bar($args) => $want");
}

# normal use patterns
check("11", 'int');
check("11.0", 'double');
check("'11'", 'char *');
check("'11.0'", 'char *');
check("-13", 'int');
check("-13.0", 'double');
check("'-13'", 'char *');
check("'-13.0'", 'char *');

check("' '", 'char *');
check("' 11 '", 'char *');

# Check TypeError is thrown when the wrong type is passed.
check("array()", NULL);
check("function(){}", NULL);
check("new stdClass()", NULL);
class NotASwigWrappedClass { };
check("new NotASwigWrappedClass()", NULL);

check::done();
