clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("funcptr", .Platform$dynlib.ext, sep=""))
source("funcptr.R")
cacheMetaData(1)
unittest(do_op(1, 3, add), 4)
unittest(do_op(2, 3, multiply), 6)
unittest(do_op(2, 3, funcvar()), 5)

# R functions
unittest(do_op(2, 3, function(a, b) as.integer(a * b + 1)), 7)
unittest(do_op(2, 3, function(a, b) a * b + 1), 7)
unittest(error_message(function() do_op(2, 3, function(a, b) c(1L, 2L))), "SWIG:TypeError in method '_p_f_int_int__int', argument 0 of type 'int'")

# A function pointer using bool
funcvarbool(funcvarbool())
unittest(call_funcvarbool(1), 1)
unittest(call_funcvarbool(0), 0)
