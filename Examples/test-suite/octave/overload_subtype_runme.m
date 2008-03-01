overload_subtype

f = Foo();
b = Bar();

if (spam(f) != 1)
    error("foo")
endif

if (spam(b) != 2)
    error("bar")
endif

