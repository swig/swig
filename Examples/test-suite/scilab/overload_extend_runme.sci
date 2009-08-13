exec loader.sce

x = new_Foo();
if Foo_test(x) <> 0 then pause, end
if Foo_test(x, 1) <> 1 then pause, end
if Foo_test(x, 2, 3) <> 5 then pause, end
if Foo_test(x, "Hello, swig!") <> 2 then pause, end

exit
