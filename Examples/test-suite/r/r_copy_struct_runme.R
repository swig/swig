clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("r_copy_struct", .Platform$dynlib.ext, sep=""))
source("r_copy_struct.R")
cacheMetaData(1)

a <- getA()

r = getARef()

unittest(A_d_get(r), 42)
unittest(r$d, 42)
unittest(r$i, 20)

# An error in trying to access a field that doesn't exist.
try(r$foo) 

r$d <- pi
unittesttol(r$d, 3.141593, 0.0001)
r$i <- -100

r$ui
r$ui <- 10

 # An error since i is unsigned and so must  be positive.
try(r$ui <- -10)


a = A()
unittest(a$i,0)
unittest(a$d,0)
unittest(a$ui,0)
a$ui <- 100
unittest(a$ui,100)
a$d = 1
unittest(a$d,1)

d <- bar()
unittest(class(d), "_p_D")
unittest(d$x, 1)
unittest(d$u, 0)


la <- new("A");
la@ui <- as.integer(5)
# Removing the next line makes this fail in R 2.4
la@str <- ""
# The next two need initialising from R 4.5 onwards to avoid a segfault in
# R_swig_A_i_set/R_swig_A_d_set when copyToC() is called.
# TODO: how to check they are not initialised in C? - Rf_isInteger seems to succeed.
la@i <- as.integer(-6)
la@d <- as.double(1.2)

other = A()
foo <- copyToC(la, other)

aa = A()
aa$i = as.integer(201)
aa$d = pi
aa$str = "foo"
aa$ui = as.integer(0)
copyToR(aa)


