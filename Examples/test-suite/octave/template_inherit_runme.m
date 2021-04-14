# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

template_inherit
a = FooInt();
b = FooDouble();
c = BarInt();
d = BarDouble();
e = FooUInt();
f = BarUInt();

if (!strcmp(a.blah(),"Foo"))
    error("failed");
endif

if (!strcmp(b.blah(),"Foo"))
    error("failed");
endif

if (!strcmp(e.blah(),"Foo"))
    error("failed");
endif

if (!strcmp(c.blah(),"Bar"))
    error("failed");
endif

if (!strcmp(d.blah(),"Bar"))
    error("failed");
endif

if (!strcmp(f.blah(),"Bar"))
    error("failed");
endif

if (!strcmp(c.foomethod(),"foomethod"))
    error("failed");
endif

if (!strcmp(d.foomethod(),"foomethod"))
    error("failed");
endif

if (!strcmp(f.foomethod(),"foomethod"))
    error("failed");
endif

if (!strcmp(invoke_blah_int(a),"Foo"))
    error("failed");
endif

if (!strcmp(invoke_blah_int(c),"Bar"))
    error("failed");
endif

if (!strcmp(invoke_blah_double(b),"Foo"))
    error("failed");
endif

if (!strcmp(invoke_blah_double(d),"Bar"))
    error("failed");
endif

if (!strcmp(invoke_blah_uint(e),"Foo"))
    error("failed");
endif

if (!strcmp(invoke_blah_uint(f),"Bar"))
    error("failed");
endif

