
clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("template_ref_type", .Platform$dynlib.ext, sep=""))
source("template_ref_type.R")
cacheMetaData(1)

xr = XC()
y = Y()

unittest(Y_find(y, xr), FALSE)

