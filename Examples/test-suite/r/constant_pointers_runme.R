clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("constant_pointers", .Platform$dynlib.ext, sep=""))
source("constant_pointers.R")
cacheMetaData(1)

myb <- B()
bret = bar(myb)
bret2 = cbar(myb)
bret3 = bar(bret2)

q(save="no")
