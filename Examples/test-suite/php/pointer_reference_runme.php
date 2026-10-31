<?php

require "tests.php";

$s  = pointer_reference::get();
check::equal($s->value, 10, "pointer_reference::get() failed");

$ss = new Struct(20);
pointer_reference::set($ss);
$i = Struct::instance();
check::equal($i->value, 20, "pointer_reference::set() failed");

check::equal(pointer_reference::overloading(1), 111, "overload test 1 failed");
check::equal(pointer_reference::overloading($ss), 222, "overload test 2 failed");

$p = (new ReflectionFunction('pointer_reference_const_volatile'))->getParameters();
check::equal((string)$p[0]->getType(), 'SWIG\_p_p_Struct', "Expected pointer to pointer parameter");
check::equal(pointer_reference::pointer_reference_typedef_const($ss), 20, "typedef const pointer test failed");
$p = (new ReflectionFunction('pointer_reference_typedef_volatile'))->getParameters();
check::equal((string)$p[0]->getType(), 'SWIG\_p_p_Struct', "Expected pointer to pointer parameter");

check::done();
