<?php

require "tests.php";

check::functions(array("test1","test2","do_unary","negate","test4","test5","test6"));
check::equal(5,test1(5),"5==test1(5)");
check::equal(get_class(test2(7)),"SWIG\\_p_int","test2(7) is _p_int");
check::globals(array('test3'));

//check::equal(37,test3_get(),'37==test3_get()');
check::equal(37,check::get("test3"),'37==get(test3)');
//test3_set(38);
check::set('test3',38);
//check::equal(38,test3_get(),'38==test3_get() after test3_set(37)');
check::equal(38,check::get('test3'),'38==get(test3) after set(test)');

check::equal(-5,negate(5),"-5==negate(5)");
check::equal(7,do_unary(-7,NEGATE),"7=do_unary(-7,NEGATE)");

check::equal(37,test5(),"37==test5()");
$g = new MemberGrouping();
check::equal(42,$g->method1(42),"42==method1(42)");
check::equal(42,MemberGrouping::method2(42),"42==method2(42)");
check::equal(37,$g->method3(),"37==method3()");

check::done();
