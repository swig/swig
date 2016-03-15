clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("li_std_vector", .Platform$dynlib.ext, sep=""))
source("li_std_vector.R")
cacheMetaData(1)

testvec <- c(1, 2, 3)

unittest(half(testvec), testvec/2)
unittest(average(testvec), mean(testvec))
q(save="no")



