clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("overload_null", .Platform$dynlib.ext, sep=""))
source("overload_null.R")
cacheMetaData(1)

o <- Overload()
x <- X()

unittest(1, o$byval1(x))
unittest(2, o$byval1(NULL))

unittest(3, o$byval2(NULL))
unittest(4, o$byval2(x))

unittest(5, o$byref1(x))
unittest(6, o$byref1(NULL))

unittest(7, o$byref2(NULL))
unittest(8, o$byref2(x))

unittest(9, o$byconstref1(x))
unittest(10, o$byconstref1(NULL))

unittest(11, o$byconstref2(NULL))
unittest(12, o$byconstref2(x))

# const pointer references
# No SWIGTYPE *const& typemaps for R yet
#unittest(13, o$byval1cpr(x))
#unittest(14, o$byval1cpr(NULL))

#unittest(15, o$byval2cpr(NULL))
#unittest(16, o$byval2cpr(x))

# fwd class declaration
unittest(17, o$byval1fwdptr(x))
unittest(18, o$byval1fwdptr(NULL))

unittest(19, o$byval2fwdptr(NULL))
unittest(20, o$byval2fwdptr(x))

unittest(21, o$byval1fwdref(x))

unittest(22, o$byval2fwdref(x))

q(save="no")

