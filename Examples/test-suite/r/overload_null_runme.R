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
unittest(13, o$byval1cpr(x))
unittest(14, o$byval1cpr(NULL))

unittest(15, o$byval2cpr(NULL))
unittest(16, o$byval2cpr(x))

# fwd class declaration
unittest(17, o$byval1fwdptr(x))
unittest(18, o$byval1fwdptr(NULL))

unittest(19, o$byval2fwdptr(NULL))
unittest(20, o$byval2fwdptr(x))

unittest(21, o$byval1fwdref(x))

unittest(22, o$byval2fwdref(x))

unittest(23, o$bychar1("a"))
unittest(24, o$bychar1(NULL))

unittest(25, o$byintarray(x))
unittest(26, o$byintarray(NULL))
unittest(26, o$byintarray(c(1L, 2L)))

unittest(27, o$bydoublearray(x))
unittest(28, o$bydoublearray(NULL))
unittest(28, o$bydoublearray(c(1.5, 2.5)))

unittest(29, o$byenumarray(x))
unittest(30, o$byenumarray(NULL))
unittest(30, o$byenumarray(c("OverloadNullEnumValue", "OverloadNullEnumValue")))

unittest(31, o$bystringarray(x))
unittest(32, o$bystringarray(NULL))
unittest(32, o$bystringarray(c("a", "b")))

unittest(33, o$byboolptr(x))
unittest(34, o$byboolptr(NULL))

unittest(35, o$byenumptr(x))
unittest(36, o$byenumptr(NULL))

# NULL is a NULL pointer for an array of char too
unittest(37, o$bychararray(x))
unittest(-38, o$bychararray(NULL))
unittest(38, o$bychararray("ab"))

unittest(39, o$byunsizedchararray(x))
unittest(-40, o$byunsizedchararray(NULL))
unittest(40, o$byunsizedchararray("ab"))

q(save="no")

