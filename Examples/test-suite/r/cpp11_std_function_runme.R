clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("cpp11_std_function", .Platform$dynlib.ext, sep=""))
source("cpp11_std_function.R")
cacheMetaData(1)

fn <- pass_checker(420)

# invoke functor via call method
unittest(TRUE, fn$call(420, "Petka"))
unittest(FALSE, fn$call(419, "Chapai"))

# call wrapper
unittest(TRUE, call_function(fn, 420, "Petka"))
unittest(FALSE, call_function(fn, 419, "Chapai"))
