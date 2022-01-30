clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("namespace_struct", .Platform$dynlib.ext, sep=""))
source("namespace_struct.R")
cacheMetaData(1)

xy = Y()
xy$x = as.integer(2)
xy$y = as.integer(4)
copyToR(xy)
