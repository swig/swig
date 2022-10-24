clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("typedef_inherit", .Platform$dynlib.ext, sep=""))
source("typedef_inherit.R")
cacheMetaData(1)


a <- Foo()
b <- Bar()

x <- do_blah(a)
unittest(x, "Foo::blah")

x <- do_blah(b)
unittest(x, "Bar::blah")

c <- Spam()
d <- Grok()

x <- do_blah2(c)
unittest(x, "Spam::blah")

x <- do_blah2(d)
unittest(x, "Grok::blah")

unittest(d$far(), "Spam::far")

q(save="no")
