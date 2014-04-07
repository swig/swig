exec("swigtest.start", -1);

foo = new_Foo();

ierr = execstr("Foo_test_int(foo)", 'errcatch');
checkequal(ierr, 999, "Foo_test_int(foo): ierr");
checkequal(lasterror(), "Exception (int) occured: 37", "Foo_test_int(foo): msg");

ierr = execstr("Foo_test_msg(foo)", 'errcatch');
checkequal(ierr, 999, "Foo_test_msg(foo): ierr");
checkequal(lasterror(), "Exception (char const *) occured: Dead", "Foo_test_msg(foo): msg");

ierr = execstr("Foo_test_multi(foo, 1)", 'errcatch');
checkequal(ierr, 999, "Foo_test_multi(foo, 1): ierr");
checkequal(lasterror(), "Exception (int) occured: 37", "Foo_test_multi(foo, 1): msg");

ierr = execstr("Foo_test_multi(foo, 2)", 'errcatch');
checkequal(ierr, 999, "Foo_test_multi(foo, 2): ierr");
checkequal(lasterror(), "Exception (char const *) occured: Dead", "Foo_test_multi(foo, 2): msg");

ierr = execstr("Foo_test_cls(foo)", 'errcatch');
checkequal(ierr, 998, "Foo_test_cls(foo): ierr");
checkequal(lasterror(), "Exception (Error) occured.", "Foo_test_cls(foo): msg");

delete_Foo(foo);

exec("swigtest.quit", -1);
