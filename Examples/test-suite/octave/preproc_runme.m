# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

preproc

if (preproc.cvar.endif != 1)
  error("failed");
endif

if (preproc.cvar.define != 1)
  error("failed");
endif

if (preproc.cvar.defined != 1)
  error("failed");
endif

if (2*preproc.one != preproc.two)
  error("failed");
endif

