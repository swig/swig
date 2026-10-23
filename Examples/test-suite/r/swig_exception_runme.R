clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("swig_exception", .Platform$dynlib.ext, sep=""))
source("swig_exception.R")
cacheMetaData(1)

# SWIG_IndexError raises an error, as for the other error codes
result <- tryCatch({
  throwIndexError()
  "no error"
}, error = function(e) {
  conditionMessage(e)
})
unittest(result, "SWIG:IndexError index out of range")
