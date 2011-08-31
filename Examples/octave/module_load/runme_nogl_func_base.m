# file: runme_nogl_func_base.m

# test whether module can be loaded in a function
# before the base context (no global cvar)

1;

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
