clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("member_funcptr_galore", .Platform$dynlib.ext, sep=""))
source("member_funcptr_galore.R")
cacheMetaData(1)

m <- MemberFuncPtrs()
unittest(m$aaa1(cc1()), 0)
unittest(m$aaa6(cc6()), 0)
unittest(m$aaa7(cc7()), 0)
unittest(m$bbb1(pp1()), 0)
unittest(m$bbb6(pp6()), 0)
unittest(m$bbb7(pp7()), 0)
# Not tested: call1(ADD_BY_VALUE, 1, 2) as the R module does not wrap constants

# A const reference to a member pointer is passed and returned as the member pointer
unittest(m$aaa7(cc1()), 0)
unittest(m$aaa1(cc7()), 0)

# A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
unittest(grepl("^SWIG:TypeError", error_message(function() m$aaa1(pp1()))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() m$aaa7(pp7()))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() m$bbb1(cc1()))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() m$bbb7(cc7()))), TRUE)

# A value that is not a member pointer, such as a pointer to an object, is rejected
unittest(grepl("^SWIG:TypeError", error_message(function() m$aaa1(m))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() m$aaa1(1))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() m$aaa1(NULL))), TRUE)
