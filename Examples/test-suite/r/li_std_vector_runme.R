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

# NULL is NULL and an empty vector is an empty std::vector, or a type error where R does not convert a vector
unittest(length(vecintptr(integer(0))), 0)
unittest(grepl("^SWIG:TypeError", error_message(function() vecstruct(list()))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() vecstruct(NULL))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() vecstruct(Structure()))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() vecstruct(integer(0)))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() halve_in_place(numeric(0)))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() RevStringVec(NULL))), TRUE)
unittest(length(RevStringVec(character(0))), 0)
unittest(grepl("^SWIG:TypeError", error_message(function() average(NULL))), TRUE)
q(save="no")



