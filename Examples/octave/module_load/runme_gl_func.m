# file: runme_gl_func.m

# test whether module can be loaded
# in a function (global cvar)

# test that everything works from the base context
example
global cvar
assert(cvar.ivar == example.ifunc())

function func
  example
  global cvar
  assert(cvar.ivar == example.ifunc())
endfunction

# test loading in a function
func

# test a second time to check everything works
func
