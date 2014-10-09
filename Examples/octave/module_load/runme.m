# file: runme_args.m

# load module
clear all;
swigexample;
assert(cvar.ivar == ifunc);
assert(exist("swigexample","var"));
clear all
swigexample;
assert(cvar.ivar == ifunc);
assert(exist("swigexample","var"));
clear all

# load module in a function globally before base context
clear all;
function testme
  swigexample;
  assert(cvar.ivar == ifunc);
  assert(exist("swigexample","var"));
endfunction
testme
testme
swigexample;
assert(cvar.ivar == ifunc);
assert(exist("swigexample","var"));
clear all
function testme
  swigexample;
  assert(cvar.ivar == ifunc);
  assert(exist("swigexample","var"));
endfunction
testme
testme
swigexample;
assert(cvar.ivar == ifunc);
assert(exist("swigexample","var"));
clear all

# load module in a function globally after base context
clear all;
swigexample;
assert(cvar.ivar == ifunc);
assert(exist("swigexample","var"));
function testme
  swigexample;
  assert(cvar.ivar == ifunc);
  assert(exist("swigexample","var"));
endfunction
testme
testme
clear all
swigexample;
assert(cvar.ivar == ifunc);
assert(exist("swigexample","var"));
function testme
  swigexample;
  assert(cvar.ivar == ifunc);
  assert(exist("swigexample","var"));
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
swigexample2;
assert(swigexample2.ivar == ifunc);
assert(exist("swigexample2","var"));
assert(!isglobal("cvar"))
clear all
swigexample2;
assert(swigexample2.ivar == ifunc);
assert(exist("swigexample2","var"));
assert(!isglobal("cvar"))
clear all
