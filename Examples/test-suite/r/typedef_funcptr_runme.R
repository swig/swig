clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("typedef_funcptr", .Platform$dynlib.ext, sep=""))
source("typedef_funcptr.R")
cacheMetaData(1)

# C function pointers
unittest(do_op(10, 3, get_op(0)), 13)
unittest(do_op(10, 3, get_op(1)), 7)
unittest(do_op_typedef_int(10, 3, get_op_typedef_int(1)), 7)
unittest(do_op_typedef_Integer(10, 3, get_op(0)), 13)
unittest(do_name(1, get_name_op()), "one")
unittest(do_name_typedef(2, get_name_op()), "many")
unittest(do_op_twice(10, 3, get_op(1)), 4)
unittest(do_two_ops(10, 3, get_op(0), get_op(1)), 137)

# R functions
unittest(do_op(10, 3, function(x, y) as.integer(x * y)), 30)
unittest(do_op_typedef_int(10, 3, function(x, y) as.integer(x - y)), 7)
unittest(do_op_typedef_Integer(10, 3, function(x, y) as.integer(x + y)), 13)
unittest(do_name(1, function(i) "one"), "one")
unittest(do_name_typedef(1, function(i) "one"), "one")

# An R function taking too few arguments fails the check in the R code, whose error message is empty
unittest(error_message(function() do_name(1, function() "one")), "")
unittest(error_message(function() do_op_typedef_int(10, 3, function(x) x)), "")

# An R function called twice and R functions for two parameters of the same type
unittest(do_op_twice(10, 3, function(x, y) as.integer(x - y)), 4)
unittest(do_two_ops(10, 3, function(x, y) as.integer(x + y), function(x, y) as.integer(x - y)), 137)
unittest(do_two_ops(10, 3, get_op(0), function(x, y) as.integer(x - y)), 137)
unittest(do_op_twice(1, 2, function(x, y) do_op(x, y, function(a, b) as.integer(a + b))), 5)

# The R function of a call that did not return normally, as for a double returned for an int, is not called again
unittest(do_op_twice(1, 2, function(x, y) {
  tryCatch(do_op(x, y, function(a, b) a * 2), error = function(e) 0L)
  as.integer(x + y)
}), 5)
invisible(error_message(function() do_op(1, 2, function(x, y) x * 2)))

# A value returned by an R function that cannot be converted gives an R error
unittest(error_message(function() do_op(1, 2, function(x, y) c(1L, 2L))), "SWIG:TypeError in method '_p_f_int_int__int', argument 0 of type 'Integer'")
unittest(error_message(function() do_name(1, function(i) 1L)), "SWIG:TypeError in method '_p_f_int__p_char', argument 0 of type 'char const *'")

# The memory R_alloc() gives optim() for the R function it minimizes is kept when that calls an R function twice
f <- function(p) sum((p - c(3, 4))^2)
expected <- optim(c(1, 2), f, control = list(maxit = 30))$par
unittest(optim(c(1, 2), function(p) {
  do_op_twice(1, 2, function(x, y) {
    gc()
    junk <- lapply(1:500, function(i) rep(i + 0.5, i %% 16 + 1))
    as.integer(x + y)
  })
  f(p)
}, control = list(maxit = 30))$par, expected)

# An R function kept by the C code cannot be called once the function it was passed to returns
OpHolder_static_fn_set(function(x, y) as.integer(x * y))
unittest(error_message(function() do_op(2, 3, OpHolder_static_fn_get())),
         paste("no R function to call for the function pointer (_p_f_int_int__int):",
               "an R function passed for a function pointer can only be called until the wrapped function returns"))
OpHolder_static_fn_set(get_op(1))

# A 'char *' returned by an R function is a copy that can be modified
name <- paste0("abc", "def")
unittest(do_name_modify(1, function(i) name), "Nbcdef")
unittest(name, "abcdef")

# A string built by an R function is kept from the garbage collector until used
gctorture(TRUE)
name <- do_name(3, function(i) paste0("name", i))
name_typedef <- do_name_typedef(4, function(i) paste0("name", i))
gctorture(FALSE)
unittest(name, "name3")
unittest(name_typedef, "name4")
