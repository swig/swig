clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("imports_a", .Platform$dynlib.ext, sep=""))
source("imports_a.R")
dyn.load(paste("imports_b", .Platform$dynlib.ext, sep=""))
source("imports_b.R")
cacheMetaData(1)

# imports_a has no casts for B, a class of imports_b, so passes its pointer on unchanged
x <- B()
A_hello(x)
unittest(A_member_virtual_test(x, "memberenum1"), "memberenum2")

c <- C()
unittest(class(c$get_a(c)), "_p_A")
