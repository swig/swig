# file: runme_args.m

# load module
clear all;
example;
assert(cvar.ivar == ifunc);
assert(exist("example","var"));
clear all
example;
assert(cvar.ivar == ifunc);
assert(exist("example","var"));
clear all

# load module in a function globally before base context
clear all;
function testme
  example;
  assert(cvar.ivar == ifunc);
  assert(exist("example","var"));
endfunction
testme
testme
example;
assert(cvar.ivar == ifunc);
assert(exist("example","var"));
clear all
function testme
  example;
  assert(cvar.ivar == ifunc);
  assert(exist("example","var"));
endfunction
testme
testme
example;
assert(cvar.ivar == ifunc);
assert(exist("example","var"));
clear all

# load module in a function globally after base context
clear all;
example;
assert(cvar.ivar == ifunc);
assert(exist("example","var"));
function testme
  example;
  assert(cvar.ivar == ifunc);
  assert(exist("example","var"));
endfunction
testme
testme
clear all
example;
assert(cvar.ivar == ifunc);
assert(exist("example","var"));
function testme
  example;
  assert(cvar.ivar == ifunc);
  assert(exist("example","var"));
endfunction
testme
testme
clear all

# octave 3.0.5 randomly crashes on the remaining tests, so skip them
api_version = sscanf(octave_config_info("api_version"), "api-v%i");
if api_version < 37
  exit
endif

# load module with no cvar
clear all;
example2;
assert(example2.ivar == ifunc);
assert(exist("example2","var"));
assert(!isglobal("cvar"))
clear all
example2;
assert(example2.ivar == ifunc);
assert(exist("example2","var"));
assert(!isglobal("cvar"))
clear all
