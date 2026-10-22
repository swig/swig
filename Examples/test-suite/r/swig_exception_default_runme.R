clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("swig_exception_default", .Platform$dynlib.ext, sep=""))
source("swig_exception_default.R")
cacheMetaData(1)

unittest(positive_only(1L), 1)
unittest(grepl("^SWIG:ValueError", error_message(function() positive_only(0L))), TRUE)

unittest(positive_result(1L), 1)
unittest(grepl("^SWIG:ValueError", error_message(function() positive_result(0L))), TRUE)
