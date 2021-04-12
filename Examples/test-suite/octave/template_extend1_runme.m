# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

template_extend1

a = template_extend1.lBaz();
b = template_extend1.dBaz();

if (!strcmp(a.foo(),"lBaz::foo"))
    error("failed");
endif

if (!strcmp(b.foo(),"dBaz::foo"))
    error("failed");
endif
