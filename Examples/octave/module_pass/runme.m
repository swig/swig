# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

# load module
clear all;
assert(exist("swigexample") == 3);
swigexample;
clA=swigexample.ExClass(5);
assert(clA()==5);
assert(exist("swigexample2") == 3);
swigexample2;
clB=swigexample2.ExClass(7);
assert(clB()==7);
clear all
