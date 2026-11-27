<?php

require "tests.php";

check::functions(array('init','read_b','read_x','assign_ap','assign_hp'));
check::classes(array('A','global_vars'));
check::globals(array('b','a','ap','cap','ar','acp','avp','acvp','x','xp','c_member','vp','h','hp','hr','hcp','hcpr'));

$an = new A();
check::classname('A', $an);
ap_set($an);
check::classname('A', ap_get());
check::equivalent(ap_get(), $an, "global var assignment");
avp_set($an);
check::classname('A', avp_get());
check::equivalent(avp_get(), $an, "volatile pointer global var assignment");

a_get()->x = 7;
check::classname('A', acvp_get());
check::equal(acvp_get()->x, 7, "const volatile pointer global var");

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

assign_hp(hcpr_get());
check::equivalent(hp_get(), hcp_get(), "enum pointer passed by const reference");

check::done();
