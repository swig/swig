# file: runme_args.m

# test module loading with arguments

##### BEGIN TEST #####
# test help
example -help
assert(!isglobal("example"))

# load module with custom cvar
example -globals mycvar
assert(!isglobal("cvar"))
assert(mycvar.ivar == example.ifunc())
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
# test help
example -help
assert(!isglobal("example"))

# load module with custom cvar
example -globals mycvar
assert(!isglobal("cvar"))
assert(mycvar.ivar == example.ifunc())
##### END TEST #####

clear all;

##### BEGIN TEST #####
# load module with root-level cvar
example -globals .
assert(example.ivar == example.ifunc())
##### END TEST #####
