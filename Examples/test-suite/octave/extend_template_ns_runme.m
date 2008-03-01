extend_template_ns

f = Foo_One();
if (f.test1(37) != 37)
    error
endif

if (f.test2(42) != 42)
    error
endif
