exec loader.sce;

x = makeFoo();
if fooCount() <> 1 then pause, end

y = makeFoo();
if fooCount() <> 2 then pause, end

delete_Foo(x);
if fooCount() <> 1 then pause, end

delete_Foo(y);
if fooCount() <> 0 then pause, end

exit
