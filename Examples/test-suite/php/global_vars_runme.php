<?php

require "tests.php";

check::functions(array('init','read_b','read_x'));
check::classes(array('A','global_vars'));
check::globals(array('b','a','ap','cap','ar','x','xp','c_member','vp','h','hp','hr'));

$an = new A();
check::classname('A', $an);
ap_set($an);
check::classname('A', ap_get());
check::equivalent(ap_get(), $an, "global var assignment");

x_set(17);
check::equal(x_get(), 17, "global var assignment");
check::equal(read_x(), 17, "PHP global var change visible in C++");
init();
check::equal(x_get(), 1234, "C++ global var change visible in PHP");

b_set('test');
check::equal(b_get(), 'test', "global var assignment");
check::equal(read_b(), 'test', "PHP global var change visible in C++");
init();
check::equal(b_get(), 'string b', "C++ global var change visible in PHP");

check::done();
