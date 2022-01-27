# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

overload_extend_c

f = overload_extend_c.Foo();
if (f.test() != 0)
    error("failed");
endif
if (f.test(3) != 1)
    error("failed");
endif
if (f.test("hello") != 2)
    error("failed");
endif
if (f.test(3,2) != 5)
    error("failed");
endif
if (f.test(3.1)-.1 != 1003) # :)
    error("failed");
endif

