clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("li_std_vector", .Platform$dynlib.ext, sep=""))
source("li_std_vector.R")
cacheMetaData(1)

testvec <- c(1, 2, 3)

unittest(half(testvec), testvec/2)
unittest(average(testvec), mean(testvec))
## string vector test
vlen <- 13
stringvec <- paste(letters[1:vlen], as.character(rnorm(vlen)))
unittest(rev(stringvec), RevStringVec(stringvec))

unittest(grepl("^SWIG:NullReferenceError", error_message(function() halve_in_place(NULL))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() vector_append(NULL, 1))), TRUE)
q(save="no")



