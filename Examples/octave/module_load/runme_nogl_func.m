# file: runme_nogl_func.m

# test whether module can be loaded
# in a function (no global cvar)

# test that everything works from the base context
example -noglobal
assert(example.cvar.ivar == example.ifunc())

function func
  example -noglobal
  assert(example.cvar.ivar == example.ifunc())
endfunction

# test loading in a function
func

# test a second time to check everything works
func
