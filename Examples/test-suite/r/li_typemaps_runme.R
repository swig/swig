clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("li_typemaps", .Platform$dynlib.ext, sep=""))
source("li_typemaps.R")

unittest(inr_int(3), 3)
unittest(inr_double(2.5), 2.5)
unittest(inr_bool(TRUE), TRUE)
unittest(in_int_multi(3, 4), 7)

# A reference cannot be bound to a null pointer, so NULL is rejected rather than dereferenced in the call
unittest(grepl("^SWIG:NullReferenceError", error_message(function() inr_int(NULL))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() inoutr_int(NULL))), TRUE)

# NULL is not a value for a primitive type passed by value
for (f in c("out_int", "out_bool", "out_float", "out_double")) {
  unittest(grepl("^SWIG:TypeError", error_message(function() get(f)(NULL))), TRUE)
}

# The out_int_multi/inout_int_multi tests other languages have are missing as OUTPUT and INOUT fail in SET_VECTOR_ELT
