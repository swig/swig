extend_template

f = extend_template.Foo_0();
if (f.test1(37) != 37)
    error("failed");
endif

if (f.test2(42) != 42)
    error("failed");
endif
