exec("swigtest.start", -1);

f = new_Foo();
Foo_data_set(f, [0:7]);
checkequal(Foo_data_get(f), [0:7], "Foo_data_get()");

Foo_text_set(f, "abcdefg");
checkequal(Foo_text_get(f), "abcdefg", "Foo_text_get()");
ierr = execstr("Foo_text_set(f, ""abcdefgh"")", "errcatch");
if ierr == 0 then swigtesterror("Foo_text_set() error expected"); end
delete_Foo(f);

m = new_MyBuff();
MyBuff_x_set(m, [0:11]);
checkequal(MyBuff_x_get(m), [0:11], "MyBuff_x_get()");
delete_MyBuff(m);

exec("swigtest.quit", -1);
