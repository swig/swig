# file: runme_args.m

# test module loading with arguments
clear all

# access module, no global load
example = example;
assert(example.cvar.ivar == example.ifunc());
clear all
example = example;
assert(example.cvar.ivar == example.ifunc());
clear all

# load module globally
example;
assert(cvar.ivar == ifunc);
assert(exist("example","var"));
clear all
example;
assert(cvar.ivar == ifunc);
assert(exist("example","var"));
clear all

# access module in a function, no global load
function testme
  example = example;
  assert(example.cvar.ivar == example.ifunc());
endfunction
testme
testme
example = example;
assert(example.cvar.ivar == example.ifunc());
clear all
function testme
  example = example;
  assert(example.cvar.ivar == example.ifunc());
endfunction
testme
testme
example = example;
assert(example.cvar.ivar == example.ifunc());
clear all

# load module in a function globally before base context
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

# access module with no cvar, no global load
example2 = example2;
assert(example2.ivar == example2.ifunc());
assert(!isglobal("cvar"))
clear all
example2 = example2;
assert(example2.ivar == example2.ifunc());
assert(!isglobal("cvar"))
clear all

# load module with no cvar globally
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
