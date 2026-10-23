clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("li_typemaps", .Platform$dynlib.ext, sep=""))
source("li_typemaps.R")

unittest(in_int(7), 7)
unittest(inr_int(3), 3)
unittest(inr_double(2.5), 2.5)
unittest(inr_bool(TRUE), TRUE)
unittest(in_int_multi(3, 4), 7)

# A reference cannot be bound to a null pointer, so NULL is rejected rather than dereferenced in the call
unittest(grepl("^SWIG:NullReferenceError", error_message(function() inr_int(NULL))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() inoutr_int(NULL))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() inr_int(integer(0)))), TRUE)

# NULL is not a value for a primitive type passed by value
for (f in c("out_int", "out_bool", "out_float", "out_double")) {
  unittest(grepl("^SWIG:TypeError", error_message(function() get(f)(NULL))), TRUE)
  unittest(grepl("^SWIG:TypeError", error_message(function() get(f)(c(1, 2)))), TRUE)
}

# The output values are returned in a list, after the return value if there is one
unittest(out_int(7)[[1]], 7)
unittest(inout_int(7)[[1]], 7)
unittest(inoutr_int(7)[[1]], 7)
unittest(unlist(out_int_multi(5, 6)), c(5, 6))
unittest(unlist(inout_int_multi(7, 8)), c(14, 24))
unittest(out_size_t(7)[[1]], 7)
unittest(inout_ptrdiff_t(7)[[1]], 14)
unittest(unlist(inoutr_int2(3, -2)), c(3, -2))
foo_outputs <- out_foo(4)
unittest(foo_outputs[[1]]$a, 4)
unittest(foo_outputs[[2]], 8)
unittest(foo_outputs[[3]], 12)
