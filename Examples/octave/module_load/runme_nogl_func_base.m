# file: runme_nogl_func_base.m

# test whether module can be loaded in a function
# before the base context (no global cvar)

1;

##### BEGIN TEST #####
function func
  example -noglobal
  assert(example.cvar.ivar == example.ifunc())
endfunction

# test loading in a function
func

# test a second time to check everything works
func

# test that everything works from the base context
example -noglobal
assert(example.cvar.ivar == example.ifunc())
##### END TEST #####

# clearing a module results in a segfault for Octave <= 3.0.*
# (tested on Octave 3.0.5), so skip the following test
try
  vers = cellfun("str2num", strsplit(OCTAVE_VERSION, "."));
catch
  vers = cellfun("str2num", cellstr(split(OCTAVE_VERSION, ".")));
end_try_catch
assert(length(vers) >= 2);
if vers(1) < 3 || (vers(1) == 3 && vers(2) == 0)
  disp("skipping 'clear all' test");
  return
endif

clear all;

##### BEGIN TEST #####
function func
  example -noglobal
  assert(example.cvar.ivar == example.ifunc())
endfunction

# test loading in a function
func

# test a second time to check everything works
func

# test that everything works from the base context
example -noglobal
assert(example.cvar.ivar == example.ifunc())
##### END TEST #####
