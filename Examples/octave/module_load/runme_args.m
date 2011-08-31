# file: runme_args.m

# test module loading with arguments

# test help
example -help
assert(!isglobal("example"))

# load module with custom cvar
example -globals mycvar
assert(!isglobal("cvar"))
assert(mycvar.ivar == example.ifunc())
