clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("c99_parameter_array_declarators", .Platform$dynlib.ext, sep=""))
source("c99_parameter_array_declarators.R")
cacheMetaData(1)

# A variable length array is copied into an array of the size given at runtime, zero filled after a shorter vector
unittest(sum_n_renamed(3L, c(1L, 2L, 3L)), 6L)
unittest(sum_n_renamed(3L, c(1L, 2L)), 3L)
unittest(grepl("^SWIG:OverflowError", error_message(function() sum_n_renamed(2L, c(1L, 2L, 3L)))), TRUE)
unittest(char_length(5L, "abc"), 3L)
unittest(count_names(3L, c("a", "b")), 2L)
unittest(grepl("^SWIG:OverflowError", error_message(function() count_names(1L, c("a", "b")))), TRUE)

# A size that is a global variable is a fixed size, global_n being 5
unittest(sum_global_dimension(2L, c(1L, 2L)), 3L)
unittest(grepl("^SWIG:OverflowError", error_message(function() sum_global_dimension(6L, 1:6))), TRUE)
