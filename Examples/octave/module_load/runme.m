# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

# load module
clear all;
assert(exist("swigexample") == 3);
swigexample;
assert(isglobal("swigexample"));
assert(cvar.ivar == ifunc);
clear all
assert(exist("swigexample") == 3);
swigexample;
assert(isglobal("swigexample"));
assert(cvar.ivar == ifunc);
clear all

# load module in a function globally before base context
clear all;
function testme_1
  if compare_versions(version(), '4.4', '>=') && compare_versions(version(), '6', '<')
    % in octave >= 4.4 < 6 'swigexample' is recognized as variable (1) instead of a .oct file (3) on the second call of 'swigexample'
    assert(exist("swigexample") == 3 || exist("swigexample") == 1);
  else
    assert(exist("swigexample") == 3);
  end
  swigexample;
  assert(isglobal("swigexample"));
  assert(cvar.ivar == ifunc);
endfunction
testme_1
testme_1
assert(exist("swigexample") == 3);
swigexample;
assert(isglobal("swigexample"));
assert(cvar.ivar == ifunc);
clear all
function testme_2
  if compare_versions(version(), '4.4', '>=') && compare_versions(version(), '6', '<')
    % in octave >= 4.4 < 6 'swigexample' is recognized as variable (1) instead of a .oct file (3) on the second call of 'swigexample'
    assert(exist("swigexample") == 3 || exist("swigexample") == 1);
  else
    assert(exist("swigexample") == 3);
  end
  swigexample;
  assert(isglobal("swigexample"));
  assert(cvar.ivar == ifunc);
endfunction
testme_2
testme_2
assert(exist("swigexample") == 3);
swigexample;
assert(isglobal("swigexample"));
assert(cvar.ivar == ifunc);
clear all

# load module in a function globally after base context
clear all;
assert(exist("swigexample") == 3);
swigexample;
assert(isglobal("swigexample"));
assert(cvar.ivar == ifunc);
function testme_3
  if compare_versions(version(), '4.4', '>=') && compare_versions(version(), '6', '<')
    % in octave >= 4.4 < 6 'swigexample' is recognized as variable (1) instead of a .oct file (3) on the second call of 'swigexample'
    assert(exist("swigexample") == 3 || exist("swigexample") == 1);
  else
    assert(exist("swigexample") == 3);
  end
  swigexample;
  assert(isglobal("swigexample"));
  assert(cvar.ivar == ifunc);
endfunction
testme_3
testme_3
clear all
assert(exist("swigexample") == 3);
swigexample;
assert(isglobal("swigexample"));
assert(cvar.ivar == ifunc);
function testme_4
  if compare_versions(version(), '4.4', '>=') && compare_versions(version(), '6', '<')
    % in octave >= 4.4 < 6 'swigexample' is recognized as variable (1) instead of a .oct file (3) on the second call of 'swigexample'
    assert(exist("swigexample") == 3 || exist("swigexample") == 1);
  else
    assert(exist("swigexample") == 3);
  end
  swigexample;
  assert(isglobal("swigexample"));
  assert(cvar.ivar == ifunc);
endfunction
testme_4
testme_4
clear all

# octave 3.0.5 randomly crashes on the remaining tests
if !swig_octave_prereq(3,2,0)
  exit
endif

# load module with no cvar
clear all;
who;
assert(exist("swigexample2") == 3);
swigexample2;
assert(isglobal("swigexample2"));
assert(swigexample2.ivar == ifunc);
assert(!exist("cvar", "var"));
clear all
assert(exist("swigexample2") == 3);
swigexample2;
assert(isglobal("swigexample2"));
assert(swigexample2.ivar == ifunc);
assert(!exist("cvar", "var"));
clear all
