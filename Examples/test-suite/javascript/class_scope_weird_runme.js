
f = new class_scope_weird.Foo();
g = new class_scope_weird.Foo(3);
if (f.bar(3) != 3)
    throw RuntimeError;
