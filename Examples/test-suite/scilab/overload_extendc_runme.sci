exec loader.sce

x = new_Foo();
if Foo_test(x, 1) <> 1 then pause, end
if Foo_test(x, "Hello swig!") <> 2 then pause, end
if Foo_test(x, 2, 3) <> 3 then pause, end
if Foo_test(x, x) <> 30 then pause, end
if Foo_test(x, x, 4) <> 24 then pause, end
if Foo_test(x, x, 4, 5) <> 9 then pause, end

exit
