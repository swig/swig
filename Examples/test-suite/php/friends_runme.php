<?php

require "tests.php";

check::functions(array('globalscope','mix','get_val2','get_val3','bas','baz','bar','get_val1','set'));
check::classes(array('friends','Foo','A','B','D_i','D_d'));
// No new vars
check::globals(array());

$a = new A(2);

check::equal(get_val1($a), 2);
check::equal(get_val2($a), 4);
check::equal(get_val3($a), 6);

# nice overload working fine
check::equal(get_val1(1, 2, 3), 1);

$b = new B(3);

# David's case
check::equal(mix($a, $b), 5);

$di = new D_i(2);
$dd = new D_d(3.3);

# incredible template overloading working just fine
check::equal(get_val1($di), 2);
check::equal(get_val1($dd), 3.3);

set($di, 4);
set($dd, 1.3);

check::equal(get_val1($di), 4);
check::equal(get_val1($dd), 1.3);

check::done();
