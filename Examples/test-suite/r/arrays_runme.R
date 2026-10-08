clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("arrays", .Platform$dynlib.ext, sep=""))
source("arrays.R")
cacheMetaData(1)

# A fixed size array member is set from a vector of up to that many elements, the rest being 0. It is read as a vector
s <- ArrayStruct()
s$array_i <- c(1L, 2L)
unittest(s$array_i, c(1L, 2L))
s$array_d <- 1.5
unittest(s$array_d, c(1.5, 0))
s$array_enum <- c("Three", "One")
unittest(s$array_enum, c("Three", "One"))

unittest(grepl("^SWIG:OverflowError", error_message(function() s$array_i <- 1:3)), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() s$array_i <- NULL)), TRUE)

q(save="no")
